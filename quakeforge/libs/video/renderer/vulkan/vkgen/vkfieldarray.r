#include <PropertyList.h>

#include "vkfieldarray.h"
#include "vkfieldtype.h"
#include "vkgen.h"
#include "vktype.h"

@implementation ArrayField

-init:(PLItem *) item struct:(Struct *)strct field:(string)fname
{
	self = [super init:item struct:strct field:fname];
	if (!self) {
		return self;
	}

	PLItem     *desc = [item getObjectForKey:"type"];
	type = [[FieldType fieldType:[desc getObjectAtIndex:1]] retain];

	value_field = [[item getObjectForKey:"values"] string];
	size_field = [[item getObjectForKey:"size"] string];
	return self;
}

-writeParseData
{
	fprintf (output_file, "static parse_array_t parse_%s_%s_data = {\n",
			 struct_name, field_name);
	[type writeParseData];
	fprintf (output_file, "\tfield_offset (%s, %s),\n",
			 struct_name, value_field);
	if (size_field) {
		fprintf (output_file, "\tfield_offset (%s, %s),\n",
				 struct_name, size_field);
	} else {
		fprintf (output_file, "\t-1,\n");
	}
	fprintf (output_file, "};\n");
	return self;
}

-writeField
{
	fprintf (output_file, "\t{\"%s\", 0, %s, parse_%s, &parse_%s_%s_data},\n",
			 field_name, "QFArray", "array", struct_name, field_name);
	return self;
}

@end
