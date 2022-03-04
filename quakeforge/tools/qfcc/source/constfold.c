/*
	constfold.c

	expression constant folding

	Copyright (C) 2004 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2004/01/22

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
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif
#include <stdlib.h>

#include <QF/dstring.h>
#include <QF/mathlib.h>

#include "tools/qfcc/include/diagnostic.h"
#include "tools/qfcc/include/expr.h"
#include "tools/qfcc/include/options.h"
#include "tools/qfcc/include/qfcc.h"
#include "tools/qfcc/include/strpool.h"
#include "tools/qfcc/include/type.h"
#include "tools/qfcc/include/value.h"

#include "tools/qfcc/source/qc-parse.h"

typedef expr_t *(*operation_t) (int op, expr_t *e, expr_t *e1, expr_t *e2);
typedef expr_t *(*unaryop_t) (int op, expr_t *e, expr_t *e1);

static expr_t *
cf_cast_expr (type_t *type, expr_t *e)
{
	e = cast_expr (type, e);
	return e;
}

static __attribute__((pure)) int
valid_op (int op, int *valid_ops)
{
	while (*valid_ops && op != *valid_ops)
		valid_ops++;
	return *valid_ops == op;
}

static expr_t *
cmp_result_expr (int result)
{
	if (is_float (type_default)) {
		return new_float_expr (result);
	} else {
		return new_int_expr(result);
	}
}

static int
is_addsub (int op)
{
	return op == '+' || op == '-';
}

static int
inv_addsub (int op)
{
	return op == '+' ? '-' : '+';
}

static expr_t *
do_op_string (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	const char *s1, *s2;
	static dstring_t *temp_str;
	static int  valid[] = {'+', LT, GT, LE, GE, EQ, NE, 0};

	if (!valid_op (op, valid))
		return error (e1, "invalid operand for string");

	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	} else {
		e->e.expr.type = &type_string;
	}

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	s1 = expr_string (e1);
	s2 = expr_string (e2);
	if (!s1)
		s1 = "";
	if (!s2)
		s2 = "";

	switch (op) {
		case '+':
			if (!temp_str)
				temp_str = dstring_newstr ();
			dstring_clearstr (temp_str);
			dstring_appendstr (temp_str, s1);
			dstring_appendstr (temp_str, s2);
			e = new_string_expr (save_string (temp_str->str));
			break;
		case LT:
			e = cmp_result_expr (strcmp (s1, s2) < 0);
			break;
		case GT:
			e = cmp_result_expr (strcmp (s1, s2) > 0);
			break;
		case LE:
			e = cmp_result_expr (strcmp (s1, s2) <= 0);
			break;
		case GE:
			e = cmp_result_expr (strcmp (s1, s2) >= 0);
			break;
		case EQ:
			e = cmp_result_expr (strcmp (s1, s2) == 0);
			break;
		case NE:
			e = cmp_result_expr (strcmp (s1, s2));
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
convert_to_float (expr_t *e)
{
	if (is_float(get_type (e)))
		return e;

	switch (e->type) {
		case ex_value:
			switch (e->e.value->lltype) {
				case ev_int:
					convert_int (e);
					return e;
				case ev_short:
					convert_short (e);
					return e;
				case ev_double:
					convert_double (e);
					return e;
				default:
					internal_error (e, "bad conversion to float: %d",
									e->e.value->lltype);
			}
			break;
		case ex_symbol:
		case ex_expr:
		case ex_uexpr:
		case ex_temp:
		case ex_block:
			e = cf_cast_expr (&type_float, e);
			return e;
		default:
			internal_error (e, 0);
	}
}

static expr_t *
convert_to_double (expr_t *e)
{
	if (is_double(get_type (e)))
		return e;

	switch (e->type) {
		case ex_value:
			switch (e->e.value->lltype) {
				case ev_int:
					e->e.value = new_double_val (expr_int (e));
					return e;
				case ev_short:
					e->e.value = new_double_val (expr_short (e));
					return e;
				case ev_float:
					e->e.value = new_double_val (expr_float (e));
					return e;
				default:
					internal_error (e, 0);
			}
			break;
		case ex_symbol:
		case ex_expr:
		case ex_uexpr:
		case ex_temp:
		case ex_block:
			e = cf_cast_expr (&type_float, e);
			return e;
		default:
			internal_error (e, 0);
	}
}

static expr_t *
do_op_float (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	float       f1, f2;
	expr_t     *conv;
	type_t     *type = &type_float;
	static int  valid[] = {
		'+', '-', '*', '/', '&', '|', '^', '%',
		SHL, SHR, AND, OR, LT, GT, LE, GE, EQ, NE, 0
	};

	if (!valid_op (op, valid))
		return error (e1, "invalid operator for float");

	if ((conv = convert_to_float (e1)) != e1) {
		e->e.expr.e1 = e1 = conv;
	}
	if ((conv = convert_to_float (e2)) != e2) {
		e->e.expr.e2 = e2 = conv;
	}
	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			type = &type_int;
		else
			type = &type_float;
	}
	e->e.expr.type = type;

	if (op == '*' && is_constant (e1) && expr_float (e1) == 1)
		return e2;
	if (op == '*' && is_constant (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '*' && is_constant (e1) && expr_float (e1) == 0)
		return e1;
	if (op == '*' && is_constant (e2) && expr_float (e2) == 0)
		return e2;
	if (op == '/' && is_constant (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '/' && is_constant (e2) && expr_float (e2) == 0)
		return error (e, "division by zero");
	if (op == '/' && is_constant (e1) && expr_float (e1) == 0)
		return e1;
	if (op == '+' && is_constant (e1) && expr_float (e1) == 0)
		return e2;
	if (op == '+' && is_constant (e2) && expr_float (e2) == 0)
		return e1;
	if (op == '-' && is_constant (e2) && expr_float (e2) == 0)
		return e1;

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	f1 = expr_float (e1);
	f2 = expr_float (e2);

	switch (op) {
		case '+':
			e = new_float_expr (f1 + f2);
			break;
		case '-':
			e = new_float_expr (f1 - f2);
			break;
		case '*':
			e = new_float_expr (f1 * f2);
			break;
		case '/':
			if (!f2)
				return error (e1, "divide by zero");
			e = new_float_expr (f1 / f2);
			break;
		case '&':
			e = new_float_expr ((int)f1 & (int)f2);
			break;
		case '|':
			e = new_float_expr ((int)f1 | (int)f2);
			break;
		case '^':
			e = new_float_expr ((int)f1 ^ (int)f2);
			break;
		case '%':
			e = new_float_expr ((int)f1 % (int)f2);
			break;
		case SHL:
			e = new_float_expr ((int)f1 << (int)f2);
			break;
		case SHR:
			e = new_float_expr ((int)f1 >> (int)f2);
			break;
		case AND:
			e = cmp_result_expr (f1 && f2);
			break;
		case OR:
			e = cmp_result_expr (f1 || f2);
			break;
		case LT:
			e = cmp_result_expr (f1 < f2);
			break;
		case GT:
			e = cmp_result_expr (f1 > f2);
			break;
		case LE:
			e = cmp_result_expr (f1 <= f2);
			break;
		case GE:
			e = cmp_result_expr (f1 >= f2);
			break;
		case EQ:
			e = cmp_result_expr (f1 == f2);
			break;
		case NE:
			e = cmp_result_expr (f1 != f2);
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_double (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	double      d1, d2;
	expr_t     *conv;
	type_t     *type = &type_double;
	static int  valid[] = {
		'+', '-', '*', '/', '%',
		LT, GT, LE, GE, EQ, NE, 0
	};

	if (!valid_op (op, valid))
		return error (e1, "invalid operator for double");

	if ((conv = convert_to_double (e1)) != e1) {
		e->e.expr.e1 = e1 = conv;
	}
	if ((conv = convert_to_double (e2)) != e2) {
		e->e.expr.e2 = e2 = conv;
	}
	if (is_compare (op) || is_logic (op)) {
		type = &type_int;
	}
	e->e.expr.type = type;

	if (op == '*' && is_constant (e1) && expr_double (e1) == 1)
		return e2;
	if (op == '*' && is_constant (e2) && expr_double (e2) == 1)
		return e1;
	if (op == '*' && is_constant (e1) && expr_double (e1) == 0)
		return e1;
	if (op == '*' && is_constant (e2) && expr_double (e2) == 0)
		return e2;
	if (op == '/' && is_constant (e2) && expr_double (e2) == 1)
		return e1;
	if (op == '/' && is_constant (e2) && expr_double (e2) == 0)
		return error (e, "division by zero");
	if (op == '/' && is_constant (e1) && expr_double (e1) == 0)
		return e1;
	if (op == '+' && is_constant (e1) && expr_double (e1) == 0)
		return e2;
	if (op == '+' && is_constant (e2) && expr_double (e2) == 0)
		return e1;
	if (op == '-' && is_constant (e2) && expr_double (e2) == 0)
		return e1;

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	d1 = expr_double (e1);
	d2 = expr_double (e2);

	switch (op) {
		case '+':
			e = new_double_expr (d1 + d2);
			break;
		case '-':
			e = new_double_expr (d1 - d2);
			break;
		case '*':
			e = new_double_expr (d1 * d2);
			break;
		case '/':
			if (!d2)
				return error (e1, "divide by zero");
			e = new_double_expr (d1 / d2);
			break;
		case '%':
			e = new_double_expr ((int)d1 % (int)d2);
			break;
		case LT:
			e = cmp_result_expr (d1 < d2);
			break;
		case GT:
			e = cmp_result_expr (d1 > d2);
			break;
		case LE:
			e = cmp_result_expr (d1 <= d2);
			break;
		case GE:
			e = cmp_result_expr (d1 >= d2);
			break;
		case EQ:
			e = cmp_result_expr (d1 == d2);
			break;
		case NE:
			e = cmp_result_expr (d1 != d2);
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_vector (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	const float *v1, *v2;
	vec3_t      v, float_vec;
	static int  valid[] = {'+', '-', '*', SCALE, EQ, NE, 0};
	expr_t     *t;

	if (!is_vector(get_type (e1))) {

		if (op != '*')
			return error (e1, "invalid operator for vector");

		t = e1;
		e->e.expr.e1 = e1 = e2;
		e2 = t;
	}
	if (!is_vector(get_type (e2))) {
		e->e.expr.e2 = e2 = convert_to_float (e2);
		if (op != SCALE && op != '/')
			return error (e1, "invalid operator for vector");
	} else {
		if (!valid_op (op, valid))
			return error (e1, "invalid operator for vector");
	}
	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	} else if (op == '*' && is_vector(get_type (e2))) {
		e->e.expr.type = &type_float;
	} else if (op == '/' && !is_constant (e1)) {
		e2 = fold_constants (binary_expr ('/', new_float_expr (1), e2));
		e = fold_constants (binary_expr ('*', e1, e2));
	} else {
		e->e.expr.type = &type_vector;
	}

	if (op == '*' && is_float_val (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '*' && is_float_val (e2) && expr_float (e2) == 0)
		return new_vector_expr (vec3_origin);
	if (op == '/' && is_float_val (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '/' && is_float_val (e2) && expr_float (e2) == 0)
		return error (e, "division by zero");
	if (op == '+' && is_constant (e1) && VectorIsZero (expr_vector (e1)))
		return e2;
	if (op == '+' && is_constant (e2) && VectorIsZero (expr_vector (e2)))
		return e1;
	if (op == '-' && is_constant (e1) && VectorIsZero (expr_vector (e1))
		&& is_constant (e2)) {
		vec3_t      v;
		VectorNegate (expr_vector (e2), v);
		e = new_vector_expr (v);
		e->file = e2->file;
		e->line = e2->line;
		return e;
	}
	if (op == '-' && is_constant (e2) && VectorIsZero (expr_vector (e2)))
		return e1;

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	if (is_float_val (e1)) {
		float_vec[0] = expr_float (e1);
		v2 = float_vec;
		v1 = expr_vector (e2);
	} else if (is_float_val (e2)) {
		float_vec[0] = expr_float (e2);
		v2 = float_vec;
		v1 = expr_vector (e1);
	} else {
		v1 = expr_vector (e1);
		v2 = expr_vector (e2);
	}

	switch (op) {
		case '+':
			VectorAdd (v1, v2, v);
			e = new_vector_expr (v);
			break;
		case '-':
			VectorSubtract (v1, v2, v);
			e = new_vector_expr (v);
			break;
		case '/':
			if (!v2[0])
				return error (e1, "divide by zero");
			VectorScale (v1, 1 / v2[0], v);
			e = new_vector_expr (v);
			break;
		case '*':
			if (is_vector(get_type (e2))) {
				e = new_float_expr (DotProduct (v1, v2));
			} else {
				VectorScale (v1, v2[0], v);
				e = new_vector_expr (v);
			}
			break;
		case EQ:
			e = cmp_result_expr (VectorCompare (v1, v2));
			break;
		case NE:
			e = cmp_result_expr (!VectorCompare (v1, v2));
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_entity (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	type_t     *type = get_type (e2);

	if (op == '.' && type->type == ev_field) {
		return e;
	}
	if (op == EQ || op == NE) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
		return e;
	}
	if (!is_entity(type))
		return error (e1, "invalid operator for entity");
	e->e.expr.type = &type_entity;
	return e;
}

static expr_t *
do_op_field (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	return error (e1, "invalid operator for field");
}

static expr_t *
do_op_func (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	if (op == EQ || op == NE) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
		return e;
	}
	return error (e1, "invalid operator for func");
}

static expr_t *
do_op_pointer (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	type_t     *type;
	static int  valid[] = {'-', '.', EQ, NE, 0};

	if (is_integral (type = get_type (e2)) && (op == '-' || op == '+')) {
		// pointer arithmetic
		expr_t     *ptoi = new_alias_expr (type, e1);
		e->e.expr.e1 = ptoi;
		e = fold_constants (e);
		return new_alias_expr (get_type (e1), e);
	}
	if (!valid_op (op, valid))
		return error (e1, "invalid operator for pointer: %s",
					  get_op_string (op));

	if (op == '-') {
		type = get_type (e1);
		if (type != get_type (e2))
			return error (e2, "invalid operands to binary -");
		e1 = new_alias_expr (&type_int, e1);
		e2 = new_alias_expr (&type_int, e2);
		e = binary_expr ('-', e1, e2);
		if (type_size (type) != 1)
			e = binary_expr ('/', e, new_int_expr (type_size (type)));
		return e;
	}
	if (op == EQ || op == NE) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	}
	if (op != '.' && extract_type (e1) != extract_type (e2))
		return type_mismatch (e1, e2, op);
	if (op == '.' && is_uint(get_type (e2)))
		e->e.expr.e2 = cf_cast_expr (&type_int, e2);
	return e;
}

static expr_t *
do_op_quatvect (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	if (op != '*')
		return error (e1, "invalid operator for quaternion and vector");
	if (is_constant (e1) && QuatIsZero (expr_quaternion (e1)))
		return new_vector_expr (vec3_origin);
	if (is_constant (e2) && VectorIsZero (expr_vector (e2)))
		return new_vector_expr (vec3_origin);
	if (is_constant (e1) && is_constant (e2)) {
		const vec_t *q, *v;
		vec3_t      r;

		q = expr_quaternion (e1);
		v = expr_vector (e2);
		QuatMultVec (q, v, r);
		return new_vector_expr (r);
	}
	e->e.expr.type = &type_vector;
	return e;
}

static expr_t *
do_op_quaternion (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	const float *q1, *q2;
	quat_t      q, float_quat;
	static int  valid[] = {'+', '-', '*', EQ, NE, 0};
	expr_t     *t;

	if (!is_quaternion(get_type (e1))) {

		if (op != '*' && op != '/')
			return error (e1, "invalid operator for quaternion");

		if (op == '*') {
			t = e1;
			e->e.expr.e1 = e1 = e2;
			e2 = t;
		}
	}
	if (!is_quaternion(get_type (e2))) {
		e->e.expr.e2 = e2 = convert_to_float (e2);
		if (op != '*' && op != '/')
			return error (e1, "invalid operator for quaternion");
	} else {
		if (!valid_op (op, valid))
			return error (e1, "invalid operator for quaternion");
	}
	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	} else if (op == '/' && !is_constant (e1)) {
		e2 = fold_constants (binary_expr ('/', new_float_expr (1), e2));
		e = fold_constants (binary_expr ('*', e1, e2));
	} else {
		e->e.expr.type = &type_quaternion;
	}

	if (op == '*' && is_float_val (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '*' && is_float_val (e2) && expr_float (e2) == 0)
		return new_quaternion_expr (quat_origin);
	if (op == '/' && is_float_val (e2) && expr_float (e2) == 1)
		return e1;
	if (op == '/' && is_float_val (e2) && expr_float (e2) == 0)
		return error (e, "division by zero");
	if (op == '+' && is_constant (e1) && QuatIsZero (expr_quaternion (e1)))
		return e2;
	if (op == '+' && is_constant (e2) && QuatIsZero (expr_quaternion (e2)))
		return e1;
	if (op == '-' && is_constant (e2) && QuatIsZero (expr_quaternion (e2)))
		return e1;

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	if (is_float_val (e1)) {
		QuatSet (0, 0, 0, expr_float (e1), float_quat);
		q2 = float_quat;
		q1 = expr_quaternion (e2);
	} else if (is_float_val (e2)) {
		QuatSet (0, 0, 0, expr_float (e2), float_quat);
		q2 = float_quat;
		q1 = expr_quaternion (e1);
	} else {
		q1 = expr_quaternion (e1);
		q2 = expr_quaternion (e2);
	}

	switch (op) {
		case '+':
			QuatAdd (q1, q2, q);
			e = new_quaternion_expr (q);
			break;
		case '-':
			QuatSubtract (q1, q2, q);
			e = new_quaternion_expr (q);
			break;
		case '/':
			if (is_float_val (e2)) {
				QuatScale (q1, 1 / expr_float (e2), q);
			} else {
				QuatInverse (q2, q);
				QuatScale (q2, expr_float (e1), q);
			}
			e = new_quaternion_expr (q);
			break;
		case '*':
			if (is_quaternion(get_type (e2))) {
				QuatMult (q1, q2, q);
			} else {
				QuatScale (q1, q2[3], q);
			}
			e = new_quaternion_expr (q);
			break;
		case EQ:
			e = cmp_result_expr (QuatCompare (q1, q2));
			break;
		case NE:
			e = cmp_result_expr (!QuatCompare (q1, q2));
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_int (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	int         isval1 = 0, isval2 = 0;
	int         val1 = 0, val2 = 0;
	static int  valid[] = {
		'+', '-', '*', '/', '&', '|', '^', '%',
		SHL, SHR, AND, OR, LT, GT, LE, GE, EQ, NE, 0
	};

	if (!valid_op (op, valid))
		return error (e1, "invalid operator for int");

	if (is_short_val (e1)) {
		isval1 = 1;
		val1 = expr_short (e1);
	}
	if (is_int_val (e1)) {
		isval1 = 1;
		val1 = expr_int (e1);
	}

	if (is_short_val (e2)) {
		isval2 = 1;
		val2 = expr_short (e2);
	}
	if (is_int_val (e2)) {
		isval2 = 1;
		val2 = expr_int (e2);
	}

	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	} else {
		e->e.expr.type = &type_int;
	}

	if (op == '*' && isval1 && val1 == 1)
		return e2;
	if (op == '*' && isval2 && val2 == 1)
		return e1;
	if (op == '*' && isval1 && val1 == 0)
		return e1;
	if (op == '*' && isval2 && val2 == 0)
		return e2;
	if (op == '/' && isval2 && val2 == 1)
		return e1;
	if (op == '/' && isval2 && val2 == 0)
		return error (e, "division by zero");
	if (op == '/' && isval1 && val1 == 0)
		return e1;
	if (op == '+' && isval1 && val1 == 0)
		return e2;
	if (op == '+' && isval2 && val2 == 0)
		return e1;
	if (op == '-' && isval2 && val2 == 0)
		return e1;

	if (!isval1) {
		if (e1->type == ex_expr) {
			// at most one of the two sub-expressions is constant otherwise
			// e1 would be a constant
			if (is_constant (e1->e.expr.e1)) {
				if ((op == '*' && e1->e.expr.op == '*')
					|| (is_addsub (op) && is_addsub (e1->e.expr.op))) {
					expr_t     *c = binary_expr (op, e1->e.expr.e1, e2);
					e = binary_expr (e1->e.expr.op, c, e1->e.expr.e2);
				}
			} else if (is_constant (e1->e.expr.e2)) {
				if ((op == '*' && e1->e.expr.op == '*')
					|| (is_addsub (op) && e1->e.expr.op == '+')) {
					expr_t     *c = binary_expr (op, e1->e.expr.e2, e2);
					e = binary_expr (e1->e.expr.op, e1->e.expr.e1, c);
				} else if (is_addsub (op) && e1->e.expr.op == '-') {
					// must ivert op
					expr_t     *c = binary_expr (inv_addsub (op),
												 e1->e.expr.e2, e2);
					e = binary_expr (e1->e.expr.op, e1->e.expr.e1, c);
				}
			}
		}
		return e;
	} else if (!isval2) {
		if (e2->type == ex_expr) {
			// at most one of the two sub-expressions is constant otherwise
			// e2 would be a constant
			if (is_constant (e2->e.expr.e1)) {
				if ((op == '*' && e2->e.expr.op == '*')
					|| (op == '+' && is_addsub (e2->e.expr.op))) {
					expr_t     *c = binary_expr (op, e1, e2->e.expr.e1);
					e = binary_expr (e2->e.expr.op, c, e2->e.expr.e2);
				} else if (op == '-' && is_addsub (e2->e.expr.op)) {
					expr_t     *c = binary_expr (op, e1, e2->e.expr.e1);
					c = fold_constants (c);
					e = binary_expr (inv_addsub (e2->e.expr.op),
									 c, e2->e.expr.e2);
				}
			} else if (is_constant (e2->e.expr.e2)) {
				if ((op == '*' && e2->e.expr.op == '*')
					|| (op == '+' && is_addsub (e2->e.expr.op))) {
					expr_t     *c = binary_expr (e2->e.expr.op,
												 e1, e2->e.expr.e2);
					e = binary_expr (op, c, e2->e.expr.e1);
				} else if (op == '-' && is_addsub (e2->e.expr.op)) {
					expr_t     *c = binary_expr (inv_addsub (e2->e.expr.op),
												 e1, e2->e.expr.e2);
					e = binary_expr (op, c, e2->e.expr.e1);
				}
			}
		}
		return e;
	}
	if (!isval1 || !isval2)
		return e;

	switch (op) {
		case '+':
			e = new_int_expr (val1 + val2);
			break;
		case '-':
			e = new_int_expr (val1 - val2);
			break;
		case '*':
			e = new_int_expr (val1 * val2);
			break;
		case '/':
			if (options.warnings.integer_divide)
				warning (e2, "%d / %d == %d", val1, val2, val1 / val2);
			e = new_int_expr (val1 / val2);
			break;
		case '&':
			e = new_int_expr (val1 & val2);
			break;
		case '|':
			e = new_int_expr (val1 | val2);
			break;
		case '^':
			e = new_int_expr (val1 ^ val2);
			break;
		case '%':
			e = new_int_expr (val1 % val2);
			break;
		case SHL:
			e = new_int_expr (val1 << val2);
			break;
		case SHR:
			e = new_int_expr (val1 >> val2);
			break;
		case AND:
			e = cmp_result_expr (val1 && val2);
			break;
		case OR:
			e = cmp_result_expr (val1 || val2);
			break;
		case LT:
			e = cmp_result_expr (val1 < val2);
			break;
		case GT:
			e = cmp_result_expr (val1 > val2);
			break;
		case LE:
			e = cmp_result_expr (val1 <= val2);
			break;
		case GE:
			e = cmp_result_expr (val1 >= val2);
			break;
		case EQ:
			e = cmp_result_expr (val1 == val2);
			break;
		case NE:
			e = cmp_result_expr (val1 != val2);
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_uint (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	return e;
}

static expr_t *
do_op_short (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	short       i1, i2;
	static int  valid[] = {
		'+', '-', '*', '/', '&', '|', '^', '%',
		SHL, SHR, AND, OR, LT, GT, LE, GE, EQ, NE, 0
	};

	if (!valid_op (op, valid))
		return error (e1, "invalid operator for short");

	if (is_compare (op) || is_logic (op)) {
		if (options.code.progsversion > PROG_ID_VERSION)
			e->e.expr.type = &type_int;
		else
			e->e.expr.type = &type_float;
	} else {
		e->e.expr.type = &type_short;
	}

	if (!is_constant (e1) || !is_constant (e2))
		return e;

	i1 = expr_short (e1);
	i2 = expr_short (e2);

	switch (op) {
		case '+':
			e = new_short_expr (i1 + i2);
			break;
		case '-':
			e = new_short_expr (i1 - i2);
			break;
		case '*':
			e = new_short_expr (i1 * i2);
			break;
		case '/':
			if (options.warnings.integer_divide)
				warning (e2, "%d / %d == %d", i1, i2, i1 / i2);
			e = new_short_expr (i1 / i2);
			break;
		case '&':
			e = new_short_expr (i1 & i2);
			break;
		case '|':
			e = new_short_expr (i1 | i2);
			break;
		case '^':
			e = new_short_expr (i1 ^ i2);
			break;
		case '%':
			e = new_short_expr (i1 % i2);
			break;
		case SHL:
			e = new_short_expr (i1 << i2);
			break;
		case SHR:
			e = new_short_expr (i1 >> i2);
			break;
		case AND:
			e = new_short_expr (i1 && i2);
			break;
		case OR:
			e = new_short_expr (i1 || i2);
			break;
		case LT:
			e = cmp_result_expr (i1 < i2);
			break;
		case GT:
			e = cmp_result_expr (i1 > i2);
			break;
		case LE:
			e = cmp_result_expr (i1 <= i2);
			break;
		case GE:
			e = cmp_result_expr (i1 >= i2);
			break;
		case EQ:
			e = cmp_result_expr (i1 == i2);
			break;
		case NE:
			e = cmp_result_expr (i1 != i2);
			break;
		default:
			internal_error (e1, 0);
	}
	e->file = e1->file;
	e->line = e1->line;
	return e;
}

static expr_t *
do_op_struct (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	return error (e1, "invalid operator for struct");
}

static expr_t *
do_op_compound (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	type_t     *t1 = get_type (e1);
	type_t     *t2 = get_type (e2);
	if (is_struct (t1) && is_struct (t2))
		return do_op_struct (op, e, e1, e2);
	if (is_scalar (t1) && is_scalar (t2)) {
		if (is_enum (t1)) {
			if (t2->type == ev_double)
				return do_op_float (op, e, e1, e2);
			if (t2->type == ev_double)
				return do_op_float (op, e, e1, e2);
			return do_op_int (op, e, e1, e2);
		}
		if (is_enum (t2)) {
			if (t1->type == ev_double)
				return do_op_double (op, e, e1, e2);
			if (t1->type == ev_float)
				return do_op_float (op, e, e1, e2);
			return do_op_int (op, e, e1, e2);
		}
	}
	return error (e1, "invalid operator for compound");
}

static operation_t *do_op[ev_type_count];
static expr_t *
do_op_invalid (int op, expr_t *e, expr_t *e1, expr_t *e2)
{
	type_t     *t1 = get_type (e1);
	type_t     *t2 = get_type (e2);

	if (is_scalar (t1) && is_scalar (t2)) {
		// one or both expressions are an enum, and the other is one of
		// int, float or short. Treat the enum as the other type, or as
		// the default type if both are enum.
		etype_t     t;
		if (!is_enum (t1))
			t = t1->type;
		else if (!is_enum (t2))
			t = t2->type;
		else
			t = type_default->type;
		return do_op[t][t] (op, e, e1, e2);
	} else {
		dstring_t  *enc1 = dstring_newstr ();
		dstring_t  *enc2 = dstring_newstr ();

		print_type_str (enc1, t1);
		print_type_str (enc2, t2);

		//print_expr (e);
		e1 = error (e1, "invalid operands for binary %s: %s %s",
					get_op_string (op), enc1->str, enc2->str);
		dstring_delete (enc1);
		dstring_delete (enc2);
		return e1;
	}
}

static operation_t op_void[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_invalid,
    [ev_vector]     = do_op_invalid,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_invalid,
    [ev_uint]       = do_op_invalid,
    [ev_short]      = do_op_invalid,
    [ev_double]     = do_op_invalid,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_string[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_string,
    [ev_float]      = do_op_invalid,
    [ev_vector]     = do_op_invalid,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_invalid,
    [ev_uint]       = do_op_invalid,
    [ev_short]      = do_op_invalid,
    [ev_double]     = do_op_invalid,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_float[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_float,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_float,
    [ev_uint]       = do_op_float,
    [ev_short]      = do_op_float,
    [ev_double]     = do_op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_vector[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_vector,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_vector,
    [ev_uint]       = do_op_vector,
    [ev_short]      = do_op_vector,
    [ev_double]     = do_op_vector,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_entity[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_invalid,
    [ev_vector]     = do_op_invalid,
    [ev_entity]     = do_op_entity,
    [ev_field]      = do_op_entity,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_invalid,
    [ev_uint]       = do_op_invalid,
    [ev_short]      = do_op_invalid,
    [ev_double]     = do_op_invalid,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_field[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_invalid,
    [ev_vector]     = do_op_invalid,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_field,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_invalid,
    [ev_uint]       = do_op_invalid,
    [ev_short]      = do_op_invalid,
    [ev_double]     = do_op_invalid,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_func[ev_type_count] = {
    [ev_void]       = do_op_func,
    [ev_string]     = do_op_func,
    [ev_float]      = do_op_func,
    [ev_vector]     = do_op_func,
    [ev_entity]     = do_op_func,
    [ev_field]      = do_op_func,
    [ev_func]       = do_op_func,
    [ev_ptr]        = do_op_func,
    [ev_quaternion] = do_op_func,
    [ev_int]        = do_op_func,
    [ev_uint]       = do_op_func,
    [ev_short]      = do_op_func,
    [ev_double]     = do_op_func,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_func,
};

static operation_t op_pointer[ev_type_count] = {
    [ev_void]       = do_op_pointer,
    [ev_string]     = do_op_pointer,
    [ev_float]      = do_op_pointer,
    [ev_vector]     = do_op_pointer,
    [ev_entity]     = do_op_pointer,
    [ev_field]      = do_op_pointer,
    [ev_func]       = do_op_pointer,
    [ev_ptr]        = do_op_pointer,
    [ev_quaternion] = do_op_pointer,
    [ev_int]        = do_op_pointer,
    [ev_uint]       = do_op_pointer,
    [ev_short]      = do_op_pointer,
    [ev_double]     = do_op_pointer,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_pointer,
};

static operation_t op_quaternion[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_quaternion,
    [ev_vector]     = do_op_quatvect,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_quaternion,
    [ev_uint]       = do_op_quaternion,
    [ev_short]      = do_op_quaternion,
    [ev_double]     = do_op_quaternion,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_int[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_float,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_int,
    [ev_uint]       = do_op_uint,
    [ev_short]      = do_op_int,
    [ev_double]     = do_op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_uint[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_float,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_uint,
    [ev_uint]       = do_op_uint,
    [ev_short]      = do_op_uint,
    [ev_double]     = do_op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_short[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_float,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_int,
    [ev_uint]       = do_op_uint,
    [ev_short]      = do_op_short,
    [ev_double]     = do_op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_double[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_float,
    [ev_vector]     = do_op_vector,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_quaternion,
    [ev_int]        = do_op_int,
    [ev_uint]       = do_op_uint,
    [ev_short]      = do_op_short,
    [ev_double]     = do_op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = do_op_invalid,
};

static operation_t op_compound[ev_type_count] = {
    [ev_void]       = do_op_invalid,
    [ev_string]     = do_op_invalid,
    [ev_float]      = do_op_compound,
    [ev_vector]     = do_op_invalid,
    [ev_entity]     = do_op_invalid,
    [ev_field]      = do_op_invalid,
    [ev_func]       = do_op_invalid,
    [ev_ptr]        = do_op_invalid,
    [ev_quaternion] = do_op_invalid,
    [ev_int]        = do_op_compound,
    [ev_uint]       = do_op_compound,
    [ev_short]      = do_op_compound,
    [ev_double]     = do_op_compound,
    [ev_long]       = do_op_compound,
    [ev_ulong]      = do_op_compound,
    [ev_invalid]    = do_op_compound,
};

static operation_t *do_op[ev_type_count] = {
    [ev_void]       = op_void,
    [ev_string]     = op_string,
    [ev_float]      = op_float,
    [ev_vector]     = op_vector,
    [ev_entity]     = op_entity,
    [ev_field]      = op_field,
    [ev_func]       = op_func,
    [ev_ptr]        = op_pointer,
    [ev_quaternion] = op_quaternion,
    [ev_int]        = op_int,
    [ev_uint]       = op_uint,
    [ev_short]      = op_short,
    [ev_double]     = op_double,
    [ev_long]       = 0,
    [ev_ulong]      = 0,
    [ev_invalid]    = op_compound,
};

static unaryop_t do_unary_op[ev_type_count];
static expr_t *
uop_invalid (int op, expr_t *e, expr_t *e1)
{
	type_t     *t1 = get_type (e1);
	if (is_scalar (t1)) {
		// The expression is an enum. Treat the enum as the default type.
		etype_t     t;
		t = type_default->type;
		return do_unary_op[t] (op, e, e1);
	} else {
		dstring_t  *enc1 = dstring_newstr ();

		print_type_str (enc1, t1);

		//print_expr (e);
		e1 = error (e1, "invalid operand for unary %s: %s",
					get_op_string (op), enc1->str);
		dstring_delete (enc1);
		return e1;
	}
}

static expr_t *
uop_string (int op, expr_t *e, expr_t *e1)
{
	// + - ! ~ *
	static int  valid[] = { '!', 0 };
	const char *s;

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for string: %s",
					  get_op_string (op));

	if (!is_constant (e1))
		return e;

	s = expr_string (e1);
	return cmp_result_expr (!s || !s[0]);
}

static expr_t *
uop_float (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', '~', 'C', 0 };
	type_t     *type;

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for float: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	type = get_type (e);
	if (op == 'C' && !is_int(type) && !is_double(type))
		return error (e1, "invalid cast of float");
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			return new_float_expr (-expr_float (e1));
		case '!':
			print_type (get_type (e));
			return cmp_result_expr (!expr_float (e1));
		case '~':
			return new_float_expr (~(int) expr_float (e1));
		case 'C':
			if (is_int(type)) {
				return new_int_expr (expr_float (e1));
			} else {
				return new_double_expr (expr_float (e1));
			}
	}
	internal_error (e, "float unary op blew up");
}

static expr_t *
uop_vector (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', 0 };
	vec3_t      v;

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for vector: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			VectorNegate (expr_vector (e), v);
			return new_vector_expr (v);
		case '!':
			return cmp_result_expr (!VectorIsZero (expr_vector (e1)));
	}
	internal_error (e, "vector unary op blew up");
}

static expr_t *
uop_entity (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '!', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for entity: %s",
					  get_op_string (op));
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '!':
			internal_error (e, "!entity");
	}
	internal_error (e, "entity unary op blew up");
}

static expr_t *
uop_field (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '!', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for field: %s",
					  get_op_string (op));
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '!':
			internal_error (e, "!field");
	}
	internal_error (e, "field unary op blew up");
}

static expr_t *
uop_func (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '!', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for func: %s",
					  get_op_string (op));
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '!':
			internal_error (e, "!func");
	}
	internal_error (e, "func unary op blew up");
}

static expr_t *
uop_pointer (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '!', '.', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for pointer: %s",
					  get_op_string (op));
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '!':
			internal_error (e, "!pointer");
		case '.':
			debug (e, ".pointer");
			return e;
	}
	internal_error (e, "pointer unary op blew up");
}

static expr_t *
uop_quaternion (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', '~', 0 };
	quat_t      q;

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for quaternion: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			QuatNegate (expr_vector (e), q);
			return new_quaternion_expr (q);
		case '!':
			return cmp_result_expr (!QuatIsZero (expr_quaternion (e1)));
		case '~':
			QuatConj (expr_vector (e), q);
			return new_quaternion_expr (q);
	}
	internal_error (e, "quaternion unary op blew up");
}

static expr_t *
uop_int (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', '~', 'C', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for int: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	if (op == 'C' && !is_float(get_type (e)))
		return error (e1, "invalid cast of int");
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			return new_int_expr (-expr_int (e1));
		case '!':
			return cmp_result_expr (!expr_int (e1));
		case '~':
			return new_int_expr (~expr_int (e1));
		case 'C':
			return new_float_expr (expr_int (e1));
	}
	internal_error (e, "int unary op blew up");
}

static expr_t *
uop_uint (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', '~', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for uint: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			return new_uint_expr (-expr_uint (e1));
		case '!':
			return cmp_result_expr (!expr_uint (e1));
		case '~':
			return new_uint_expr (~expr_uint (e1));
	}
	internal_error (e, "uint unary op blew up");
}

static expr_t *
uop_short (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', '~', 0 };

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for short: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			return new_short_expr (-expr_short (e1));
		case '!':
			return cmp_result_expr (!expr_short (e1));
		case '~':
			return new_short_expr (~expr_short (e1));
	}
	internal_error (e, "short unary op blew up");
}

static expr_t *
uop_double (int op, expr_t *e, expr_t *e1)
{
	static int  valid[] = { '+', '-', '!', 'C', 0 };
	type_t     *type;

	if (!valid_op (op, valid))
		return error (e1, "invalid unary operator for double: %s",
					  get_op_string (op));
	if (op == '+')
		return e1;
	type = get_type (e);
	if (op == 'C' && !is_int(type) && !is_float(type))
		return error (e1, "invalid cast of double");
	if (!is_constant (e1))
		return e;
	switch (op) {
		case '-':
			return new_double_expr (-expr_double (e1));
		case '!':
			print_type (get_type (e));
			return cmp_result_expr (!expr_double (e1));
		case 'C':
			if (is_int(type)) {
				return new_int_expr (expr_double (e1));
			} else {
				return new_float_expr (expr_double (e1));
			}
	}
	internal_error (e, "float unary op blew up");
}

static expr_t *
uop_compound (int op, expr_t *e, expr_t *e1)
{
	type_t     *t1 = get_type (e1);

	if (is_scalar (t1)) {
		if (is_enum (t1)) {
			return uop_int (op, e, e1);
		}
	}
	return error (e1, "invalid operand for unary %s", get_op_string (op));
}

static unaryop_t do_unary_op[ev_type_count] = {
	uop_invalid,						// ev_void
	uop_string,							// ev_string
	uop_float,							// ev_float
	uop_vector,							// ev_vector
	uop_entity,							// ev_entity
	uop_field,							// ev_field
	uop_func,							// ev_func
	uop_pointer,						// ev_ptr
	uop_quaternion,						// ev_quaternion
	uop_int,							// ev_int
	uop_uint,							// ev_uint
	uop_short,							// ev_short
	uop_double,							// ev_double
	uop_compound,						// ev_invalid
};

expr_t *
fold_constants (expr_t *e)
{
	int         op;
	expr_t     *e1, *e2;
	etype_t     t1, t2;

	if (e->type == ex_uexpr) {
		e1 = e->e.expr.e1;
		if (!e1) {
			return e;
		}
		op = e->e.expr.op;
		t1 = extract_type (e1);
		if (t1 >= ev_type_count || !do_unary_op[t1]) {
			print_expr (e);
			internal_error (e, "invalid type: %d", t1);
		}
		return do_unary_op[t1] (op, e, e1);
	} else if (e->type == ex_expr) {
		e1 = e->e.expr.e1;
		e2 = e->e.expr.e2;
		if (!is_constant (e1) && !is_constant (e2)) {
			return e;
		}

		op = e->e.expr.op;

		t1 = extract_type (e1);
		t2 = extract_type (e2);

		if (t1 >= ev_type_count || t2 >= ev_type_count
			|| !do_op[t1] || !do_op[t1][t2])
			internal_error (e, "invalid type %d %d", t1, t2);
		return do_op[t1][t2] (op, e, e1, e2);
	}
	return e;
}
