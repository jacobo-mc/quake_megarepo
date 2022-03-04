#include "ZScrollView.h"

@implementation ZScrollView
/*
====================
initWithFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/
- (id) initWithFrame: (NSRect)frameRect
   button1: b1
{
	[super initWithFrame: frameRect];

	[self addSubview: b1];

	button1 = b1;

	[self setHasHorizontalScroller: YES];
	[self setHasVerticalScroller: YES];

	[self setBorderType: NSBezelBorder];

	return self;
}

- (BOOL) isOpaque
{
	return YES;
}

/*
================
tile

Adjust the size for the pop up scale menu
=================
*/
- (id) tile
{
	NSRect  scrollerframe;

	[super tile];
	scrollerframe = [_horizScroller frame];
	[button1 setFrame: scrollerframe];

	scrollerframe.size.width = 0;
	[_horizScroller setFrame: scrollerframe];
	[_horizScroller setHidden: YES];

	return self;
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

#if 0
- (id) superviewSizeChanged: (const NSSize *)oldSize
{
	[super superviewSizeChanged: oldSize];

	[[self documentView] newSuperBounds];

	return self;
}

#endif

@end
