/*
	type.h

	type system

	Copyright (C) 2001 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2001/12/11

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

#ifndef __type_h
#define __type_h

#include "QF/progs/pr_type.h"

#include "def.h"

typedef struct ty_func_s {
	struct type_s *type;
	int         num_params;
	struct type_s **param_types;
	union {
		struct {
			unsigned    no_va_list:1;///< don't inject va_list for ... function
			unsigned    void_return:1;///< special handling for return value
		};
		unsigned    attribute_bits;
	};
} ty_func_t;

typedef struct ty_fldptr_s {
	struct type_s *type;
} ty_fldptr_t;

typedef struct ty_array_s {
	struct type_s *type;
	int         base;
	int         size;
} ty_array_t;

typedef struct ty_alias_s {
	struct type_s *aux_type;	///< other aliases stripped
	struct type_s *full_type;	///< full alias chain
} ty_alias_t;

typedef struct type_s {
	etype_t     type;		///< ev_invalid means structure/array etc
	const char *name;
	int         alignment;	///< required alignment for instances
	int         width;		///< components in vector types, otherwise 1
							///< vector and quaternion are 1 (separate from
							///< vec3 and vec4)
	/// function/pointer/array/struct types are more complex
	ty_meta_e   meta;
	union {
		// no data for ty_basic when not a func, field or pointer
		ty_func_t   func;
		ty_fldptr_t fldptr;
		ty_array_t  array;
		struct symtab_s *symtab;
		struct class_s *class;
		ty_alias_t  alias;
	} t;
	struct type_s *next;
	int         freeable;
	int         allocated;
	int         printid;	///< for dot output
	struct protocollist_s *protos;
	const char *encoding;	///< Objective-QC encoding
	struct def_s *type_def;	///< offset of qfo encodoing
} type_t;

typedef struct {
	type_t     *type;
	struct param_s *params;
	struct symbol_s *sym;	///< for dealing with "int id" etc
	storage_class_t storage;
	union {
		struct {
			unsigned    multi_type:1;
			unsigned    multi_store:1;
			unsigned    is_signed:1;
			unsigned    is_unsigned:1;
			unsigned    is_short:1;
			unsigned    is_long:1;
			unsigned    is_typedef:1;
			unsigned    is_overload:1;
			unsigned    nosave:1;
			unsigned    no_va_list:1;
			unsigned    void_return:1;
		};
		unsigned    spec_bits;
	};
} specifier_t;

#define EV_TYPE(type) extern type_t type_##type;
#include "QF/progs/pr_type_names.h"

#define VEC_TYPE(type_name, base_type) extern type_t type_##type_name;
#include "tools/qfcc/include/vec_types.h"

extern	type_t	type_invalid;
extern	type_t	type_floatfield;

extern	type_t	*type_nil;		// for passing nil into ...
extern	type_t	*type_default;	// default type (float or int)
extern	type_t	*type_long_int;	// supported type for long
extern	type_t	*type_ulong_uint;// supported type for ulong

extern	type_t	type_va_list;
extern	type_t	type_param;
extern	type_t	type_zero;
extern	type_t	type_type_encodings;
extern	type_t	type_xdef;
extern	type_t	type_xdef_pointer;
extern	type_t	type_xdefs;

extern struct symtab_s *vector_struct;
extern struct symtab_s *quaternion_struct;

struct dstring_s;

etype_t low_level_type (type_t *type) __attribute__((pure));
type_t *new_type (void);
void free_type (type_t *type);
void chain_type (type_t *type);

/**	Append a type to the end of a type chain.

	The type chain must be made up of only field, pointer, function, and
	array types, as other types do not have auxiliary type fields.

	\param type		The type chain to which the type will be appended.
	\param new		The type to be appended. May be any type.
	\return			The type chain with the type appended at the deepest
					level.
*/
type_t *append_type (type_t *type, type_t *new);
type_t *find_type (type_t *new);
void new_typedef (const char *name, type_t *type);
type_t *field_type (type_t *aux);
type_t *pointer_type (type_t *aux);
type_t *array_type (type_t *aux, int size);
type_t *based_array_type (type_t *aux, int base, int top);
type_t *alias_type (type_t *type, type_t *alias_chain, const char *name);
const type_t *unalias_type (const type_t *type) __attribute__((pure));
const type_t *dereference_type (const type_t *type) __attribute__((pure));
void print_type_str (struct dstring_s *str, const type_t *type);
void print_type (const type_t *type);
void dump_dot_type (void *t, const char *filename);
const char *encode_params (const type_t *type);
void encode_type (struct dstring_s *encoding, const type_t *type);
const char *type_get_encoding (const type_t *type);

#define EV_TYPE(t) int is_##t (const type_t *type) __attribute__((pure));
#include "QF/progs/pr_type_names.h"

int is_enum (const type_t *type) __attribute__((pure));
int is_integral (const type_t *type) __attribute__((pure));
int is_real (const type_t *type) __attribute__((pure));
int is_scalar (const type_t *type) __attribute__((pure));
int is_nonscalar (const type_t *type) __attribute__((pure));
int is_math (const type_t *type) __attribute__((pure));
int is_struct (const type_t *type) __attribute__((pure));
int is_array (const type_t *type) __attribute__((pure));
int is_structural (const type_t *type) __attribute__((pure));
int type_compatible (const type_t *dst, const type_t *src) __attribute__((pure));
int type_assignable (const type_t *dst, const type_t *src);
int type_same (const type_t *dst, const type_t *src) __attribute__((pure));
int type_size (const type_t *type) __attribute__((pure));
int type_width (const type_t *type) __attribute__((pure));

void init_types (void);
void chain_initial_types (void);

void clear_typedefs (void);

extern type_t *ev_types[];

#endif//__type_h
