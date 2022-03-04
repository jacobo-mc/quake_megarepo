#ifndef __qwaq_ui_draw_h
#define __qwaq_ui_draw_h

#include <Object.h>

#include "ruamoko/qwaq/ui/rect.h"

@class DrawBuffer;

@protocol DrawBuffer
- blitFromBuffer: (DrawBuffer *) srcBuffer to: (Point) pos from: (Rect) rect;
- (Rect) rect;
- (Extent) size;
- (int *) buffer;
@end

@protocol TextContext
- (void) release;
- blitFromBuffer: (DrawBuffer *) srcBuffer to: (Point) pos from: (Rect) rect;
- clearReact: (Rect) rect;
- (Extent) size;
- (void) resizeTo: (Extent) newSize;	// absolute size

- (void) bkgd: (int) ch;
- (void) clear;
- (void) printf: (string) fmt, ...;
- (void) vprintf: (string) fmt, @va_list args;
- (void) addch: (int) ch;
- (void) addstr: (string) str;
- (void) mvprintf: (Point) pos, string fmt, ...;
- (void) mvvprintf: (Point) pos, string fmt, @va_list args;
- (void) mvaddch: (Point) pos, int ch;
- (void) mvaddstr: (Point) pos, string str;
- (void) mvhline:(Point)pos, int ch, int len;
- (void) mvvline:(Point)pos, int ch, int len;
@end

@interface DrawBuffer : Object <DrawBuffer, TextContext>
{
	int        *buffer;
	Extent      size;
	Point       cursor;
	int         background;
}
+(DrawBuffer *)buffer:(Extent)size;
-initWithSize:(Extent)size;
@end

#endif//__qwaq_ui_draw_h
