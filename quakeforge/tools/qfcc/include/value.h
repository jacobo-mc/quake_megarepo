/*
	value.h

	value handling

	Copyright (C) 2002 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2002/06/04

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

#ifndef __value_h
#define __value_h

/** \defgroup qfcc_value Constant values.
	\ingroup qfcc_expr
*/
///@{

struct def_s;
struct ex_value_s;
struct tempop_s;
struct type_s;

struct ex_value_s *new_string_val (const char *string_val);
struct ex_value_s *new_double_val (double double_val);
struct ex_value_s *new_float_val (float float_val);
struct ex_value_s *new_vector_val (const float *vector_val);
struct ex_value_s *new_entity_val (int entity_val);
struct ex_value_s *new_field_val (int field_val, struct type_s *type,
								  struct def_s *def);
struct ex_value_s *new_func_val (int func_val, struct type_s *type);
struct ex_value_s *new_pointer_val (int val, struct type_s *type,
									struct def_s *def,
									struct operand_s *tempop);
struct ex_value_s *new_quaternion_val (const float *quaternion_val);
struct ex_value_s *new_int_val (int int_val);
struct ex_value_s *new_uint_val (int uint_val);
struct ex_value_s *new_short_val (short short_val);
struct ex_value_s *new_nil_val (struct type_s *type);

struct ex_value_s *convert_value (struct ex_value_s *value,
								  struct type_s *type);
struct ex_value_s *alias_value (struct ex_value_s *value, struct type_s *type);
struct def_s *emit_value (struct ex_value_s *value, struct def_s *def);

int	ReuseString (const char *str);

void clear_immediates (void);

///@}

#endif//__value_h
