#include <string.h>
#include "ruamoko/qwaq/device/nameview.h"

@implementation NameView

-initWithName:(string)name
{
	if (!(self = [super init])) {
		return nil;
	}
	self.name = name;
	return self;
}

-(void)dealloc
{
	str_free (name);
	[super dealloc];
}

+(NameView *)withName:(string)name
{
	return [[[self alloc] initWithName:name] autorelease];
}

-draw
{
	[super draw];
	[self mvaddstr:{0, 0}, str_mid (name, 0, xlen)];
	return self;
}

@end
