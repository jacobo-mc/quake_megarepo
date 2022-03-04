#include <PropertyList.h>

#include "vkfieldsingle.h"
#include "vkfieldtype.h"
#include "vkgen.h"
#include "vktype.h"

@implementation SingleField

-init:(PLItem *) item struct:(Struct *)strct field:(string)fname
{
	self = [super init:item struct:strct field:fname];
	if (!self) {
		return self;
	}

	PLItem     *desc = [item getObjectForKey:"type"];
	type = [[FieldType fieldType:[desc getObjectAtIndex:1]] retain];

	value_field = [[item getObjectForKey:"value"] string];
	return self;
}

-writeParseData
{
	fprintf (output_file, "static parse_single_t parse_%s_%s_data = {\n",
			 struct_name, field_name);
	[type writeParseData];
	fprintf (output_file, "\tfield_offset (%s, %s),\n",
			 struct_name, value_field);
	fprintf (output_file, "};\n");
	return self;
}

-writeField
{
	string      parse_type = [type parseType];
	fprintf (output_file, "\t{\"%s\", 0, %s, parse_%s, &parse_%s_%s_data},\n",
			 field_name, parse_type, "single", struct_name, field_name);
	return self;
}

@end
