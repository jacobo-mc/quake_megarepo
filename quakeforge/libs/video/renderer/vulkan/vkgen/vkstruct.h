#ifndef __renderer_vulkan_vkgen_vkstruct_h
#define __renderer_vulkan_vkgen_vkstruct_h

#include <Object.h>

#include "vkgen.h"
#include "vktype.h"

@class PLItem;

@interface Struct: Type
{
	string outname;
}
-(void) queueFieldTypes;
-(qfot_var_t *)findField:(string) fieldName;
-(void) writeTable;
-(void) writeSymtabInit;
-(void) writeSymtabEntry;
-(string) outname;
@end

#endif//__renderer_vulkan_vkgen_vkstruct_h
