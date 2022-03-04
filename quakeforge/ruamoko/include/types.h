#ifndef __types_h
#define __types_h

#define EV_TYPE(type) ev_##type,
typedef enum {
#include <QF/progs/pr_type_names.h>
	ev_invalid,			// invalid type. used for instruction checking
	ev_type_count		// not a type, gives number of types
} etype_t;

typedef enum {
	ty_basic,				///< VM type (float, int, pointer, field, etc)
	ty_struct,
	ty_union,
	ty_enum,
	ty_array,
	ty_class,
	ty_alias,
} ty_meta_e;

typedef struct qfot_alias_s {
	etype_t     type;
	struct qfot_type_s *aux_type;
	struct qfot_type_s *full_type;
	string      name;
} qfot_alias_t;

typedef struct qfot_fldptr_s {
	etype_t     type;
	struct qfot_type_s *aux_type;
} qfot_fldptr_t;

typedef struct qfot_func_s {
	etype_t     type;
	struct qfot_type_s *return_type;
	int         num_params;
	struct qfot_type_s *param_types[1];
} qfot_func_t;

typedef struct qfot_var_s {
	struct qfot_type_s *type;
	string      name;
	int         offset;				// value for enum, 0 for union
} qfot_var_t;

typedef struct qfot_struct_s {
	string      tag;
	int         num_fields;
	qfot_var_t  fields[1];
} qfot_struct_t;

typedef struct qfot_array_s {
	struct qfot_type_s *type;
	int         base;
	int         size;
} qfot_array_t;

typedef struct qfot_type_s {
	ty_meta_e   meta;
	int         size;
	string      encoding;
	union {
		etype_t     type;
		qfot_fldptr_t fldptr;
		qfot_func_t func;
		qfot_struct_t strct;
		qfot_array_t array;
		string      class;
		qfot_alias_t alias;
	};
} qfot_type_t;

// the minimum size of a type encoding
#define TYPESIZE 4

typedef struct qfot_type_encodings_s {
	qfot_type_t *types;
	int         size;
} qfot_type_encodings_t;

@extern string ty_meta_name[7];
@extern string pr_type_name[ev_type_count];
@extern int pr_type_size[ev_type_count];

#endif
