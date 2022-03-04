#include "QF/sys.h"

#import <AppKit/NSEvent.h>
#include "CameraView.h"
#include "Map.h"
#include "QuakeEd.h"
#include "XYView.h"
#include "ZView.h"

id  cameraview_i;
extern NSBezierPath  *path;

BOOL  timedrawing = 0;

@implementation CameraView
/*
==================
initWithFrame:
==================
*/
- (id) initWithFrame: (NSRect)frameRect
{
	int  size;

	[super initWithFrame: frameRect];

	cameraview_i = self;

	xa = ya = za = 0;

	[self matrixFromAngles];

	origin[0] = 64;
	origin[1] = 64;
	origin[2] = 48;

	move = 16;

	camwidth = _bounds.size.width ;
	camheight = _bounds.size.height;
	size = camwidth * camheight;
	zbuffer = malloc (size * sizeof (float));
	imagebuffer = malloc (size * sizeof (unsigned));

	return self;
}

- (BOOL) isOpaque
{
	return YES;
}

- (void) awakeFromNib
{
	NSBezierPath  *path;

	path = zcamera = [NSBezierPath new];
	[path setLineWidth: 0.3];
	[path moveToPoint: NSMakePoint (-16, 0)];
	[path relativeLineToPoint: NSMakePoint (16, 8)];
	[path relativeLineToPoint: NSMakePoint (16, -8)];
	[path relativeLineToPoint: NSMakePoint (-16, -8)];
	[path relativeLineToPoint: NSMakePoint (-16, 8)];
	[path relativeLineToPoint: NSMakePoint (32, 0)];
	[path moveToPoint: NSMakePoint (-15, -47)];
	[path relativeLineToPoint: NSMakePoint (29, 0)];
	[path relativeLineToPoint: NSMakePoint (0, 54)];
	[path relativeLineToPoint: NSMakePoint (-29, 0)];
	[path relativeLineToPoint: NSMakePoint (0, -54)];

	path = xycamera = [NSBezierPath new];
	[path setLineWidth: 0.3];
	[path moveToPoint: NSMakePoint (-16, 0)];
	[path relativeLineToPoint: NSMakePoint (16, 8)];
	[path relativeLineToPoint: NSMakePoint (16, -8)];
	[path relativeLineToPoint: NSMakePoint (-16, -8)];
	[path relativeLineToPoint: NSMakePoint (-16, 8)];
	[path relativeLineToPoint: NSMakePoint (32, 0)];

	path = xycamera_aim = [NSBezierPath new];
	[path setLineWidth: 0.3];
	[path moveToPoint: NSMakePoint (0, 0)];
	[path relativeLineToPoint: NSMakePoint (45, 45)];
	[path moveToPoint: NSMakePoint (0, 0)];
	[path relativeLineToPoint: NSMakePoint (45, -45)];
}

- (id) setXYOrigin: (NSPoint *)pt
{
	origin[0] = pt->x;
	origin[1] = pt->y;
	return self;
}

- (id) setZOrigin: (float)pt
{
	origin[2] = pt;
	return self;
}

- (id) setOrigin: (vec3_t)org
   angle: (float)angle
{
	VectorCopy (org, origin);
	ya = angle;
	[self matrixFromAngles];
	return self;
}

- (id) getOrigin: (vec3_t)org
{
	VectorCopy (origin, org);
	return self;
}

- (float) yawAngle
{
	return ya;
}

- (id) upFloor: sender
{
	sb_floor_dir = 1;
	sb_floor_dist = 99999;
	[map_i makeAllPerform: @selector (feetToFloor)];
	if (sb_floor_dist == 99999) {
		Sys_Printf ("already on top floor\n");
		return self;
	}
	Sys_Printf ("up floor\n");
	origin[2] += sb_floor_dist;
	[quakeed_i updateCamera];
	return self;
}

- (id) downFloor: sender
{
	sb_floor_dir = -1;
	sb_floor_dist = -99999;
	[map_i makeAllPerform: @selector (feetToFloor)];
	if (sb_floor_dist == -99999) {
		Sys_Printf ("already on bottom floor\n");
		return self;
	}
	Sys_Printf ("down floor\n");
	origin[2] += sb_floor_dist;
	[quakeed_i updateCamera];
	return self;
}

/*
===============================================================================

UI TARGETS

===============================================================================
*/

/*
============
homeView
============
*/
- (id) homeView: sender
{
	xa = za = 0;

	[self matrixFromAngles];

	[quakeed_i updateAll];

	Sys_Printf ("homed view angle\n");

	return self;
}

- (id) drawMode: sender
{
	drawmode = [sender selectedColumn];
	[quakeed_i updateCamera];
	return self;
}

- (id) setDrawMode: (drawmode_t)mode
{
	drawmode = mode;
	[mode_radio_i selectCellAtRow: 0 column: mode];
	[quakeed_i updateCamera];
	return self;
}

/*
===============================================================================

TRANSFORMATION METHODS

===============================================================================
*/

- (id) matrixFromAngles
{
	if (xa > M_PI * 0.4)
		xa = M_PI * 0.4;
	if (xa < -M_PI * 0.4)
		xa = -M_PI * 0.4;

	// vpn
	matrix[2][0] = cos (xa) * cos (ya);
	matrix[2][1] = cos (xa) * sin (ya);
	matrix[2][2] = sin (xa);

	// vup
	matrix[1][0] = cos (xa + M_PI / 2) * cos (ya);
	matrix[1][1] = cos (xa + M_PI / 2) * sin (ya);
	matrix[1][2] = sin (xa + M_PI / 2);

	// vright
	CrossProduct (matrix[2], matrix[1], matrix[0]);

	return self;
}

- (id) inverseTransform: (vec_t *)invec
   to: (vec_t *)outvec
{
	vec3_t  inverse[3];
	vec3_t  temp;
	int     i, j;

	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++)
			inverse[i][j] = matrix[j][i];
	}

	temp[0] = DotProduct (invec, inverse[0]);
	temp[1] = DotProduct (invec, inverse[1]);
	temp[2] = DotProduct (invec, inverse[2]);

	VectorAdd (temp, origin, outvec);

	return self;
}

/*
===============================================================================

                        DRAWING METHODS

===============================================================================
*/

typedef  struct {
	vec3_t  trans;
	int     clipflags;
	vec3_t  screen;                 // valid only if clipflags == 0
} campt_t;

#define CLIP_RIGHT  1
#define CLIP_LEFT   2
#define CLIP_TOP    4
#define CLIP_BOTTOM 8
#define CLIP_FRONT  16

int         cam_cur;
campt_t     campts[2];

vec3_t  r_matrix[3];
vec3_t  r_origin;
float   mid_x, mid_y;
float   topscale = (240.0 / 3) / 160;
float   bottomscale = (240.0 * 2 / 3) / 160;

extern plane_t  rfrustum[5];

void
MakeCampt (vec3_t in, campt_t * pt)
{
	vec3_t  temp;
	float   scale;

	// transform the points
	VectorSubtract (in, r_origin, temp);

	pt->trans[0] = DotProduct (temp, r_matrix[0]);
	pt->trans[1] = DotProduct (temp, r_matrix[1]);
	pt->trans[2] = DotProduct (temp, r_matrix[2]);

	// check clip flags
	if (pt->trans[2] < 1)
		pt->clipflags = CLIP_FRONT;
	else
		pt->clipflags = 0;

	if (pt->trans[0] > pt->trans[2])
		pt->clipflags |= CLIP_RIGHT;
	else if (-pt->trans[0] > pt->trans[2])
		pt->clipflags |= CLIP_LEFT;

	if (pt->trans[1] > pt->trans[2] * topscale)
		pt->clipflags |= CLIP_TOP;
	else if (-pt->trans[1] > pt->trans[2] * bottomscale)
		pt->clipflags |= CLIP_BOTTOM;

	if (pt->clipflags)
		return;

	// project
	scale = mid_x / pt->trans[2];
	pt->screen[0] = mid_x + pt->trans[0] * scale;
	pt->screen[1] = mid_y + pt->trans[1] * scale;
}

void
CameraMoveto (vec3_t p)
{
	campt_t  *pt;

	if ([path elementCount] > 2048)
		lineflush ();

	pt = &campts[cam_cur];
	cam_cur ^= 1;
	MakeCampt (p, pt);
	if (!pt->clipflags) {   // onscreen, so move there immediately
		NSPoint  point = {pt->screen[0], pt->screen[1]};
		[path moveToPoint: point];
	}
}

void
ClipLine (vec3_t p1, vec3_t p2, int planenum)
{
	float       d, d2, frac;
	vec3_t      new;
	plane_t     *pl;
	float       scale;
	NSPoint     point;

	if (planenum == 5) {    // draw it!
		scale = mid_x / p1[2];
		point.x = mid_x + p1[0] * scale;
		point.y = mid_y + p1[1] * scale;
		[path moveToPoint: point];

		scale = mid_x / p2[2];
		point.x = mid_x + p2[0] * scale;
		point.y = mid_y + p2[1] * scale;
		[path lineToPoint: point];
		return;
	}

	pl = &rfrustum[planenum];

	d = DotProduct (p1, pl->normal) - pl->dist;
	d2 = DotProduct (p2, pl->normal) - pl->dist;
	if (d <= ON_EPSILON && d2 <= ON_EPSILON)    // off screen
		return;

	if (d >= 0 && d2 >= 0) {    // on front
		ClipLine (p1, p2, planenum + 1);
		return;
	}

	frac = d / (d - d2);
	new[0] = p1[0] + frac * (p2[0] - p1[0]);
	new[1] = p1[1] + frac * (p2[1] - p1[1]);
	new[2] = p1[2] + frac * (p2[2] - p1[2]);

	if (d > 0)
		ClipLine (p1, new, planenum + 1);
	else
		ClipLine (new, p2, planenum + 1);
}

int  c_off, c_on, c_clip;

void
CameraLineto (vec3_t p)
{
	campt_t     *p1, *p2;
	int         bits;

	p2 = &campts[cam_cur];
	cam_cur ^= 1;
	p1 = &campts[cam_cur];
	MakeCampt (p, p2);

	if (p1->clipflags & p2->clipflags) {    // entirely off screen
		c_off++;
		return;
	}

	bits = p1->clipflags | p2->clipflags;
	if (!bits) {    // entirely on screen
		NSPoint     point1 = {p1->screen[0], p1->screen[1]};
		NSPoint     point2 = {p2->screen[0], p2->screen[1]};

		c_on++;
		[path moveToPoint: point1];
		[path lineToPoint: point2];
		return;
	}

	// needs to be clipped
	c_clip++;

	ClipLine (p1->trans, p2->trans, 0);
}

/*
=============
drawSolid
=============
*/
- (id) drawSolid
{
	unsigned char  *planes[5];

	// draw it
	VectorCopy (origin, r_origin);
	VectorCopy (matrix[0], r_matrix[0]);
	VectorCopy (matrix[1], r_matrix[1]);
	VectorCopy (matrix[2], r_matrix[2]);

	r_width = _bounds.size.width;
	r_height = _bounds.size.height;
	if (r_width != camwidth || r_height != camheight) {
		int size;
		camwidth = r_width;
		camheight = r_height;
		size = camwidth * camheight;
		if (imagebuffer) {
			free (zbuffer);
			free (imagebuffer);
		}
		zbuffer = malloc (size * sizeof (float));
		imagebuffer = malloc (size * sizeof (unsigned));
	}
	r_picbuffer = imagebuffer;
	r_zbuffer = zbuffer;

	r_drawflat = (drawmode == dr_flat);

	REN_BeginCamera ();
	REN_ClearBuffers ();

	// render the setbrushes
	[map_i makeAllPerform: @selector (CameraRenderSelf)];

	// display the output
	[[self window] setBackingType: NSBackingStoreRetained];

	planes[0] = (unsigned char *) imagebuffer;
	NSDrawBitmap (_bounds, r_width, r_height, 8, 3, 32, r_width * 4, NO, NO,
	              NSCalibratedRGBColorSpace, (const unsigned char **) planes);

	[[self window] setBackingType: NSBackingStoreBuffered];

	return self;
}

/*
===================
drawWire
===================
*/
- (id) drawWire: (NSRect)rect
{
	// copy current info to globals for the C callbacks
	mid_x = _bounds.size.width / 2;
	mid_y = 2 * _bounds.size.height / 3;

	VectorCopy (origin, r_origin);
	VectorCopy (matrix[0], r_matrix[0]);
	VectorCopy (matrix[1], r_matrix[1]);
	VectorCopy (matrix[2], r_matrix[2]);

	r_width = _bounds.size.width;
	r_height = _bounds.size.height;
	if (r_width != camwidth || r_height != camheight) {
		int size;
		camwidth = r_width;
		camheight = r_height;
		size = camwidth * camheight;
		if (imagebuffer) {
			free (zbuffer);
			free (imagebuffer);
		}
		zbuffer = malloc (size * sizeof (float));
		imagebuffer = malloc (size * sizeof (unsigned));
	}
	r_picbuffer = imagebuffer;
	r_zbuffer = zbuffer;

	REN_BeginCamera ();

	// erase window
	NSEraseRect (rect);

	// draw all entities
	linestart (0, 0, 0);
	[map_i makeUnselectedPerform: @selector (CameraDrawSelf)];
	lineflush ();

	return self;
}

/*
===================
drawSelf
===================
*/
- (void) drawRect: (NSRect)rect
{
	float  drawtime = 0;

	if (timedrawing)
		drawtime = Sys_DoubleTime ();

	if (drawmode == dr_texture || drawmode == dr_flat) {
		[quakeed_i cameraNoRestore: _bounds];
		[self drawSolid];
	} else {
		[quakeed_i cameraNoRestore: rect];
		[self drawWire: rect];
	}

	if (timedrawing) {
		drawtime = Sys_DoubleTime () - drawtime;
		printf ("CameraView drawtime: %5.3f\n", drawtime);
	}
}

/*
=============
XYDrawSelf
=============
*/
- (void) XYDrawSelf
{
	NSBezierPath        *path;
	NSAffineTransform   *trans;

	[[NSColor blueColor] set];

	trans = [NSAffineTransform transform];
	[trans translateXBy: origin[0] yBy: origin[1]];

	path = [xycamera copy];
	[path transformUsingAffineTransform: trans];
	[path stroke];
	[path release];

	[trans rotateByRadians: ya];

	path = [xycamera_aim copy];
	[path transformUsingAffineTransform: trans];
	[path stroke];
	[path release];
}

/*
=============
ZDrawSelf
=============
*/
- (void) ZDrawSelf
{
	NSBezierPath        *path;
	NSAffineTransform   *trans;

	[[NSColor blueColor] set];

	trans = [NSAffineTransform transform];
	[trans translateXBy: 0 yBy: origin[2]];

	path = [zcamera copy];
	[path transformUsingAffineTransform: trans];
	[path stroke];
	[path release];
}

/*
===============================================================================

                        XYZ mouse view methods

===============================================================================
*/

/*
================
modalMoveLoop
================
*/
- (id) modalMoveLoop: (NSPoint *)basept
   : (vec3_t)movemod
   : converter
{
	vec3_t      originbase;
	NSEvent     *event = 0;
	unsigned    eventMask = (NSLeftMouseUpMask | NSLeftMouseDraggedMask
	                         | NSRightMouseUpMask | NSRightMouseDraggedMask
	                         | NSApplicationDefinedMask);
	NSPoint     newpt;
	vec3_t      delta;
	int         i;

	Sys_Printf ("moving camera position\n");

	VectorCopy (origin, originbase);

	// modal event loop using instance drawing
	goto drawentry;

	while ([event type] != NSLeftMouseUp && [event type] != NSRightMouseUp) {
		// calculate new point
		newpt = [event locationInWindow];
		newpt = [converter convertPoint: newpt fromView: NULL];

		delta[0] = newpt.x - basept->x;
		delta[1] = newpt.y - basept->y;
		delta[2] = delta[1];        // height change

		for (i = 0; i < 3; i++)
			origin[i] = originbase[i] + movemod[i] * delta[i];

#if 0   // FIXME
		// if command is down, look towards brush or entity
		if (event->flags & NS_SHIFTMASK) {
			NSPoint     brushpt;
			id          ent;
			vec3_t      temp;

			ent = [quakemap_i selectedEntity];
			if (ent) {
				[ent origin: temp];
				brushpt.x = temp[0];
				brushpt.y = temp[1];
			} else {
				brushpt = [brush_i centerPoint];
			} ya = atan2 (brushpt.y - newpt.y, brushpt.x - newpt.x);
			[self matrixFromAngles];
		}
#endif

	drawentry:
		// instance draw new frame
		[quakeed_i newinstance];
		[self display];
		event = [NSApp nextEventMatchingMask: eventMask
		                           untilDate: [NSDate distantFuture]
		                              inMode: NSEventTrackingRunLoopMode dequeue:
		         YES];
		if ([event type] == NSKeyDown) {
			[self _keyDown: event];
			[self display];
			goto drawentry;
		}
	}

	return self;
}

// ============================================================================

/*
===============
XYmouseDown
===============
*/
- (BOOL) XYmouseDown: (NSPoint *)pt
   flags: (int)flags
// return YES if brush handled
{
	vec3_t  movemod;

	if (fabs (pt->x - origin[0]) > 16 || fabs (pt->y - origin[1]) > 16)
		return NO;

#if 0
	if (flags & NSAlternateKeyMask) {   // up / down drag
		movemod[0] = 0;
		movemod[1] = 0;
		movemod[2] = 1;
	} else
#endif
	{
		movemod[0] = 1;
		movemod[1] = 1;
		movemod[2] = 0;
	}

	[self modalMoveLoop: pt: movemod: xyview_i];

	return YES;
}

/*
===============
ZmouseDown
===============
*/
- (BOOL) ZmouseDown: (NSPoint *)pt
   flags: (int)flags
// return YES if brush handled
{
	vec3_t  movemod;

	if (fabs (pt->y - origin[2]) > 16 || pt->x < -8 || pt->x > 8)
		return NO;

	movemod[0] = 0;
	movemod[1] = 0;
	movemod[2] = 1;

	[self modalMoveLoop: pt: movemod: zview_i];

	return YES;
}

// =============================================================================

/*
===================
viewDrag:
===================
*/
- (id) viewDrag: (NSPoint *)pt
{
	float       dx, dy;
	NSEvent     *event = 0;
	NSPoint     newpt;

	// modal event loop using instance drawing
	goto drawentry;

	while ([event type] != NSRightMouseUp) {
		// calculate new point
		newpt = [event locationInWindow];
		newpt = [self convertPoint: newpt fromView: NULL];

		dx = newpt.x - pt->x;
		dy = newpt.y - pt->y;
		*pt = newpt;

		ya -= dx / _bounds.size.width * M_PI / 2 * 4;
		xa += dy / _bounds.size.width * M_PI / 2 * 4;

		[self matrixFromAngles];

	drawentry:
		[quakeed_i newinstance];
		[self display];
		event = [NSApp nextEventMatchingMask: NSRightMouseUpMask
		         | NSRightMouseDraggedMask
		                           untilDate: [NSDate distantFuture]
		                              inMode: NSEventTrackingRunLoopMode dequeue:
		         YES];
		if ([event type] == NSKeyDown) {
			[self _keyDown: event];
			[self display];
			goto drawentry;
		}
	}

	return self;
}

// =============================================================================

/*
===================
mouseDown
===================
*/
- (void) mouseDown: (NSEvent *)theEvent
{
	NSPoint     pt;
	int         i;
	vec3_t      p1, p2;
	float       forward, right, up;
	int         flags;

	pt = [theEvent locationInWindow];

	pt = [self convertPoint: pt fromView: NULL];

	VectorCopy (origin, p1);
	forward = 160;
	right = pt.x - 160;
	up = pt.y - 240 * 2 / 3;
	for (i = 0; i < 3; i++) {
		p2[i] =
		    forward * matrix[2][i] + up * matrix[1][i] + right * matrix[0][i];
	}
	for (i = 0; i < 3; i++)
		p2[i] = p1[i] + 100 * p2[i];

	flags =
	    [theEvent modifierFlags] & (NSShiftKeyMask | NSControlKeyMask |
	                                NSAlternateKeyMask | NSCommandKeyMask);

	// bare click to select a texture
	if (flags == 0) {
		[map_i getTextureRay: p1 : p2];
		return;
	}
	// shift click to select / deselect a brush from the world
	if (flags == NSShiftKeyMask) {
		[map_i selectRay: p1 : p2 : NO];
		return;
	}

	// cmd-shift click to set a target/targetname entity connection
	if (flags == (NSShiftKeyMask | NSCommandKeyMask)) {
		[map_i entityConnect: p1 : p2];
		return;
	}

	// alt click = set entire brush texture
	if (flags == NSAlternateKeyMask) {
		if (drawmode != dr_texture) {
			Sys_Printf ("No texture setting except in texture mode!\n");
			NopSound ();
			return;
		}
		[map_i setTextureRay: p1 : p2 : YES];
		[quakeed_i updateAll];
		return;
	}

	// ctrl-alt click = set single face texture
	if (flags == (NSControlKeyMask | NSAlternateKeyMask)) {
		if (drawmode != dr_texture) {
			Sys_Printf ("No texture setting except in texture mode!\n");
			NopSound ();
			return;
		}
		[map_i setTextureRay: p1 : p2 : NO];
		[quakeed_i updateAll];
		return;
	}

	Sys_Printf ("bad flags for click %x\n", flags);
	NopSound ();

	return;
}

/*
===================
rightMouseDown
===================
*/
- (void) rightMouseDown: (NSEvent *)theEvent
{
	NSPoint     pt;
	int         flags;

	pt = [theEvent locationInWindow];

	[self convertPoint: pt fromView: NULL];

	flags = [theEvent modifierFlags]
	        & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask
	           | NSCommandKeyMask);

	// click = drag camera
	if (flags == 0) {
		Sys_Printf ("looking\n");
		[self viewDrag: &pt];
		return;
	}

	Sys_Printf ("bad flags for click\n");
	NopSound ();

	return;
}

/*
===============
keyDown
===============
*/

- (id) _keyDown: (NSEvent *)theEvent
{
	NSString    *chars = [theEvent characters];
	unichar     c = ([chars length] == 1) ? [chars characterAtIndex: 0] : '\0';

	switch (c) {
		case 13:
			return self;

		case 'a':
		case 'A':
			xa += M_PI / 8;
			[self matrixFromAngles];
			[quakeed_i updateCamera];
			return self;

		case 'z':
		case 'Z':
			xa -= M_PI / 8;
			[self matrixFromAngles];
			[quakeed_i updateCamera];
			return self;

		case NSRightArrowFunctionKey:
			ya -= M_PI * move / (64 * 2);
			[self matrixFromAngles];
			[quakeed_i updateCamera];
			break;

		case NSLeftArrowFunctionKey:
			ya += M_PI * move / (64 * 2);
			[self matrixFromAngles];
			[quakeed_i updateCamera];
			break;

		case NSUpArrowFunctionKey:
			origin[0] += move * cos (ya);
			origin[1] += move * sin (ya);
			[quakeed_i updateCamera];
			break;

		case NSDownArrowFunctionKey:
			origin[0] -= move * cos (ya);
			origin[1] -= move * sin (ya);
			[quakeed_i updateCamera];
			break;

		case '.':
			origin[0] += move * cos (ya - M_PI_2);
			origin[1] += move * sin (ya - M_PI_2);
			[quakeed_i updateCamera];
			break;

		case ',':
			origin[0] -= move * cos (ya - M_PI_2);
			origin[1] -= move * sin (ya - M_PI_2);
			[quakeed_i updateCamera];
			break;

		case 'd':
		case 'D':
			origin[2] += move;
			[quakeed_i updateCamera];
			break;

		case 'c':
		case 'C':
			origin[2] -= move;
			[quakeed_i updateCamera];
			break;
	} /* switch */

	return self;
}

@end
