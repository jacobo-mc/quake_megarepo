#include "ProxyView.h"

@implementation ProxyView

-(id)initWithBounds:(Rect)aRect title:(View *)aTitle view:(View *)aView
{
	self = [super initWithBounds:aRect];
	if (!self)
		return self;

	title = aTitle;
	view = aView;
	return self;
}

- (int) keyEvent:(int)key unicode:(int)unicode down:(int)down
{
	return [view keyEvent:key unicode:unicode down:down];
}

- (void) draw
{
	[title draw];
	[view draw];
}

- (void) setBasePosFromView: (View *) aview
{
    [super setBasePosFromView:aview];
	[title setBasePosFromView:self];
	[view setBasePosFromView:self];
}

@end
