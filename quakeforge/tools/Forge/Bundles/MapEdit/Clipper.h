#ifndef Clipper_h
#define Clipper_h

#include <AppKit/AppKit.h>

#include "QF/mathlib.h"

#include "SetBrush.h"

extern id  clipper_i;

@interface Clipper: NSObject
{
	int         num;
	vec3_t      pos[3];
	plane_t     plane;
}

- (BOOL) hide;
- (id) XYClick: (NSPoint)pt;
- (BOOL) XYDrag: (NSPoint *)pt;
- (id) ZClick: (NSPoint)pt;
- (id) carve;
- (void) flipNormal;
- (BOOL) getFace: (face_t *)pl;

- (void) cameraDrawSelf;
- (void) XYDrawSelf;
- (void) ZDrawSelf;

@end
#endif // Clipper_h
