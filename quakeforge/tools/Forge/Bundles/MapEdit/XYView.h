#ifndef XYView_h
#define XYView_h

#include <AppKit/AppKit.h>

#include "QF/mathlib.h"

#include "SetBrush.h"

#include "render.h"

extern id  xyview_i;

#define MINSCALE    0.125
#define MAXSCALE    2.0

extern vec3_t   xy_viewnormal;      // v_forward for xy view
extern float    xy_viewdist;        // clip behind this plane

extern NSRect  xy_draw_rect;

void        linestart (float r, float g, float b);
void        lineflush (void);
void        linecolor (float r, float g, float b);

void        XYmoveto (vec3_t pt);
void        XYlineto (vec3_t pt);

@interface XYView: NSView
{
	NSRect      realbounds, newrect, combinedrect;
	NSPoint     midpoint;
	NSFont      *font;
	NSFont      *scaledFont;
	int         gridsize;
	float       scale;

//
// for textured view
//
	int         xywidth, xyheight;
	float       *xyzbuffer;
	unsigned    *xypicbuffer;

	drawmode_t  drawmode;

//
// UI links
//
	id  mode_radio_i;
}

- (float) currentScale;

- (id) setModeRadio: m;

- (id) drawMode: sender;
- (id) setDrawMode: (drawmode_t)mode;

- (id) newSuperBounds;
- (id) newRealBounds: (NSRect)nb;

- (id) addToScrollRange: (float)x
   : (float)y;

- (id) setOrigin: (NSPoint)pt scale: (float)sc;

- (id) centerOn: (vec3_t)org;

- (id) drawMode: sender;

- (id) superviewChanged;

- (int) gridsize;
- (float) snapToGrid: (float)f;

- (NSFont *) scaledFont;

@end

@interface NSView (XYView)
- (void) setFrame: (NSRect)frame
   bounds: (NSRect)bounds
   scale: (NSSize)scale;
@end
#endif // XYView_h
