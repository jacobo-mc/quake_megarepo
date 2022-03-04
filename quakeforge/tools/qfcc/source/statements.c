/*
	statements.c

	Internal statements

	Copyright (C) 2011 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2011/06/18

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
#include <inttypes.h>

#include "qfalloca.h"

#include "QF/alloc.h"
#include "QF/mathlib.h"
#include "QF/va.h"

#include "tools/qfcc/include/class.h"
#include "tools/qfcc/include/dags.h"
#include "tools/qfcc/include/defspace.h"
#include "tools/qfcc/include/diagnostic.h"
#include "tools/qfcc/include/dot.h"
#include "tools/qfcc/include/expr.h"
#include "tools/qfcc/include/function.h"
#include "tools/qfcc/include/method.h"
#include "tools/qfcc/include/options.h"
#include "tools/qfcc/include/qfcc.h"
#include "tools/qfcc/include/reloc.h"
#include "tools/qfcc/include/statements.h"
#include "tools/qfcc/include/strpool.h"
#include "tools/qfcc/include/symtab.h"
#include "tools/qfcc/include/type.h"
#include "tools/qfcc/include/value.h"

#include "tools/qfcc/source/qc-parse.h"

const char *op_type_names[] = {
	"op_def",
	"op_value",
	"op_label",
	"op_temp",
	"op_alias",
	"op_nil",
	"op_pseudo",
};

const char *st_type_names[] = {
	"st_none",
	"st_expr",
	"st_assign",
	"st_ptrassign",
	"st_move",
	"st_ptrmove",
	"st_memset",
	"st_ptrmemset",
	"st_state",
	"st_func",
	"st_flow",
	"st_address",
};

const char *
optype_str (op_type_e type)
{
	if (type > op_temp)
		return "<invalid op_type>";
	return op_type_names[type];
}

static const char *
tempop_string (operand_t *tmpop)
{
	tempop_t   *tempop = &tmpop->tempop;
	if (tempop->alias) {
		return va (0, "<tmp %s %p:%d:%p:%d:%d>",
				   pr_type_name[tempop->type->type],
				   tmpop, tempop->users,
				   tempop->alias,
				   tempop->offset,
				   tempop->alias->tempop.users);
	}
	return va (0, "<tmp %s %p:%d>", pr_type_name[tempop->type->type],
			   tmpop, tempop->users);
}

const char *
operand_string (operand_t *op)
{
	if (!op)
		return "";
	switch (op->op_type) {
		case op_def:
			return op->def->name;
		case op_value:
			switch (op->value->lltype) {
				case ev_string:
					return va (0, "\"%s\"",
							   quote_string (op->value->v.string_val));
				case ev_double:
					return va (0, "%g", op->value->v.double_val);
				case ev_float:
					return va (0, "%g", op->value->v.float_val);
				case ev_vector:
					return va (0, "'%g %g %g'",
							   op->value->v.vector_val[0],
							   op->value->v.vector_val[1],
							   op->value->v.vector_val[2]);
				case ev_quaternion:
					return va (0, "'%g %g %g %g'",
							   op->value->v.quaternion_val[0],
							   op->value->v.quaternion_val[1],
							   op->value->v.quaternion_val[2],
							   op->value->v.quaternion_val[3]);
				case ev_ptr:
					if (op->value->v.pointer.def) {
						return va (0, "ptr %s+%d",
								   op->value->v.pointer.def->name,
								   op->value->v.pointer.val);
					} else if(op->value->v.pointer.tempop) {
						operand_t  *tempop = op->value->v.pointer.tempop;
						return va (0, "ptr %s+%d", tempop_string (tempop),
								   op->value->v.pointer.val);
					} else {
						return va (0, "ptr %d", op->value->v.pointer.val);
					}
				case ev_field:
					return va (0, "field %d", op->value->v.pointer.val);
				case ev_entity:
					return va (0, "ent %d", op->value->v.int_val);
				case ev_func:
					return va (0, "func %d", op->value->v.int_val);
				case ev_int:
					return va (0, "int %d", op->value->v.int_val);
				case ev_uint:
					return va (0, "uint %u", op->value->v.uint_val);
				case ev_long:
					return va (0, "long %"PRIi64, op->value->v.long_val);
				case ev_ulong:
					return va (0, "ulong %"PRIu64, op->value->v.ulong_val);
				case ev_short:
					return va (0, "short %d", op->value->v.short_val);
				case ev_ushort:
					return va (0, "ushort %d", op->value->v.ushort_val);
				case ev_void:
					return "(void)";
				case ev_invalid:
					return "(invalid)";
				case ev_type_count:
					return "(type_count)";
			}
			break;
		case op_label:
			return op->label->name;
		case op_temp:
			return tempop_string (op);
		case op_alias:
			{
				const char *alias = operand_string (op->alias);
				char       *buf = alloca (strlen (alias) + 1);
				strcpy (buf, alias);
				return va (0, "alias(%s,%s)", pr_type_name[op->type->type],
						   buf);
			}
		case op_nil:
			return "nil";
		case op_pseudo:
			return va (0, "pseudo: %s", op->pseudoop->name);
	}
	return ("??");
}

static void
_print_operand (operand_t *op)
{
	switch (op->op_type) {
		case op_def:
			printf ("(%s) ", pr_type_name[op->type->type]);
			printf ("%s", op->def->name);
			break;
		case op_value:
			printf ("(%s) ", pr_type_name[op->type->type]);
			switch (op->value->lltype) {
				case ev_string:
					printf ("\"%s\"", op->value->v.string_val);
					break;
				case ev_double:
					printf ("%g", op->value->v.double_val);
					break;
				case ev_float:
					printf ("%g", op->value->v.float_val);
					break;
				case ev_vector:
					printf ("'%g", op->value->v.vector_val[0]);
					printf (" %g", op->value->v.vector_val[1]);
					printf (" %g'", op->value->v.vector_val[2]);
					break;
				case ev_quaternion:
					printf ("'%g", op->value->v.quaternion_val[0]);
					printf (" %g", op->value->v.quaternion_val[1]);
					printf (" %g", op->value->v.quaternion_val[2]);
					printf (" %g'", op->value->v.quaternion_val[3]);
					break;
				case ev_ptr:
					printf ("(%s)[%d]",
							pr_type_name[op->value->v.pointer.type->type],
							op->value->v.pointer.val);
					break;
				case ev_field:
					printf ("%d", op->value->v.pointer.val);
					break;
				case ev_entity:
				case ev_func:
				case ev_int:
					printf ("%d", op->value->v.int_val);
					break;
				case ev_uint:
					printf ("%u", op->value->v.uint_val);
					break;
				case ev_long:
					printf ("%"PRIu64, op->value->v.long_val);
					break;
				case ev_ulong:
					printf ("%"PRIu64, op->value->v.ulong_val);
					break;
				case ev_short:
					printf ("%d", op->value->v.short_val);
					break;
				case ev_ushort:
					printf ("%d", op->value->v.ushort_val);
					break;
				case ev_void:
				case ev_invalid:
				case ev_type_count:
					internal_error (op->expr, "weird value type");
			}
			break;
		case op_label:
			printf ("block %p", op->label->dest);
			break;
		case op_temp:
			printf ("tmp (%s) %p", pr_type_name[op->type->type], op);
			if (op->tempop.def)
				printf (" %s", op->tempop.def->name);
			break;
		case op_alias:
			printf ("alias(%s,", pr_type_name[op->type->type]);
			_print_operand (op->alias);
			printf (")");
			break;
		case op_nil:
			printf ("nil");
			break;
		case op_pseudo:
			printf ("pseudo: %s", op->pseudoop->name);
			break;
	}
}

void
print_operand (operand_t *op)
{
	_print_operand (op);
	puts ("");
}

static void
print_operand_chain (const char *name, operand_t *op)
{
	if (op) {
		printf ("    %s:", name);
		while (op) {
			printf (" ");
			_print_operand (op);
			op = op->next;
		}
		printf ("\n");
	}
}

void
print_statement (statement_t *s)
{
	printf ("(%s, ", s->opcode);
	if (s->opa)
		_print_operand (s->opa);
	printf (", ");
	if (s->opb)
		_print_operand (s->opb);
	printf (", ");
	if (s->opc)
		_print_operand (s->opc);
	printf (")\n");
	print_operand_chain ("use", s->use);
	print_operand_chain ("def", s->def);
	print_operand_chain ("kill", s->kill);
}

static pseudoop_t *pseudoops_freelist;
static sblock_t *sblocks_freelist;
static statement_t *statements_freelist;
static operand_t *operands_freelist;

sblock_t *
new_sblock (void)
{
	sblock_t   *sblock;
	ALLOC (256, sblock_t, sblocks, sblock);
	sblock->tail = &sblock->statements;
	return sblock;
}

void
sblock_add_statement (sblock_t *sblock, statement_t *statement)
{
	// this should normally be null, but might be inserting
	statement->next = *sblock->tail;
	*sblock->tail = statement;
	sblock->tail = &statement->next;
}

statement_t *
new_statement (st_type_t type, const char *opcode, expr_t *expr)
{
	statement_t *statement;
	ALLOC (256, statement_t, statements, statement);
	statement->type = type;
	statement->opcode = save_string (opcode);
	statement->expr = expr;
	statement->number = -1;	// indicates flow analysis not done yet
	return statement;
}

static void
statement_add_use (statement_t *s, operand_t *use)
{
	if (use) {
		use->next = s->use;
		s->use = use;
	}
}

static void
statement_add_def (statement_t *s, operand_t *def)
{
	if (def) {
		def->next = s->def;
		s->def = def;
	}
}

static void
statement_add_kill (statement_t *s, operand_t *kill)
{
	if (kill) {
		kill->next = s->kill;
		s->kill = kill;
	}
}

static pseudoop_t *
new_pseudoop (const char *name)
{
	pseudoop_t *pseudoop;
	ALLOC (256, pseudoop_t, pseudoops, pseudoop);
	pseudoop->name = save_string (name);
	return pseudoop;

}

static operand_t *
new_operand (op_type_e op, expr_t *expr, void *return_addr)
{
	operand_t *operand;
	ALLOC (256, operand_t, operands, operand);
	operand->op_type = op;
	operand->expr = expr;
	operand->return_addr = return_addr;
	return operand;
}

static operand_t *
copy_operand (operand_t *src)
{
	if (!src) {
		return 0;
	}
	operand_t  *cpy = new_operand (src->op_type, src->expr, 0);
	*cpy = *src;
	cpy->return_addr = __builtin_return_address (0);
	return cpy;
}

void
free_operand (operand_t *op)
{
	FREE (operands, op);
}

static void
free_statement (statement_t *s)
{
//	if (s->opa)
//		free_operand (s->opa);
//	if (s->opb)
//		free_operand (s->opb);
//	if (s->opc)
//		free_operand (s->opc);
	FREE (statements, s);
}

static void
free_sblock (sblock_t *sblock)
{
	while (sblock->statements) {
		statement_t *s = sblock->statements;
		sblock->statements = s->next;
		free_statement (s);
	}
	FREE (sblocks, sblock);
}

static operand_t *
pseudo_operand (pseudoop_t *pseudoop, expr_t *expr)
{
	operand_t  *op;
	op = new_operand (op_pseudo, expr, __builtin_return_address (0));
	op->pseudoop = pseudoop;
	op->size = 1;
	return op;
}

operand_t *
nil_operand (type_t *type, expr_t *expr)
{
	operand_t  *op;
	op = new_operand (op_nil, expr, __builtin_return_address (0));
	op->type = type;
	op->size = type_size (type);
	op->width = type_width (type);
	return op;
}

operand_t *
def_operand (def_t *def, type_t *type, expr_t *expr)
{
	operand_t  *op;

	if (!type)
		type = def->type;
	op = new_operand (op_def, expr, __builtin_return_address (0));
	op->type = type;
	op->size = type_size (type);
	op->width = type_width (type);
	op->def = def;
	return op;
}

operand_t *
return_operand (type_t *type, expr_t *expr)
{
	symbol_t   *return_symbol;
	return_symbol = make_symbol (".return", &type_param, pr.symtab->space,
								 sc_extern);
	if (!return_symbol->table) {
		symtab_addsymbol (pr.symtab, return_symbol);
	}
	def_t      *return_def = return_symbol->s.def;
	return def_operand (alias_def (return_def, type, 0), 0, expr);
}

operand_t *
value_operand (ex_value_t *value, expr_t *expr)
{
	operand_t  *op;
	op = new_operand (op_value, expr, __builtin_return_address (0));
	op->type = value->type;
	op->size = type_size (value->type);
	op->width = type_width (value->type);
	op->value = value;
	return op;
}

operand_t *
temp_operand (type_t *type, expr_t *expr)
{
	operand_t  *op = new_operand (op_temp, expr, __builtin_return_address (0));

	op->tempop.type = type;
	op->type = type;
	op->size = type_size (type);
	op->width = type_width (type);
	return op;
}

int
tempop_overlap (tempop_t *t1, tempop_t *t2)
{
	int         offs1 = t1->offset;
	int         offs2 = t2->offset;
	int         size1 = type_size (t1->type);
	int         size2 = type_size (t2->type);

	if (t1->alias) {
		offs1 += t1->alias->tempop.offset;
	}
	if (t2->alias) {
		offs2 += t2->alias->tempop.offset;
	}
	if (offs1 <= offs2 && offs1 + size1 >= offs2 + size2)
		return 2;	// t1 fully overlaps t2
	if (offs1 < offs2 + size2 && offs2 < offs1 + size1)
		return 1;	// t1 and t2 at least partially overlap
	return 0;
}

int
tempop_visit_all (tempop_t *tempop, int overlap,
			   int (*visit) (tempop_t *, void *), void *data)
{
	tempop_t   *start_tempop = tempop;
	operand_t  *top;
	int         ret;

	if ((ret = visit (tempop, data)))
		return ret;
	if (tempop->alias) {
		top = tempop->alias;
		if (top->op_type != op_temp) {
			internal_error (top->expr, "temp alias of non-temp operand");
		}
		tempop = &top->tempop;
		if ((ret = visit (tempop, data)))
			return ret;
	} else {
		overlap = 0;
	}
	for (top = tempop->alias_ops; top; top = top->next) {
		if (top->op_type != op_temp) {
			internal_error (top->expr, "temp alias of non-temp operand");
		}
		tempop = &top->tempop;
		if (tempop == start_tempop)
			continue;
		if (overlap && tempop_overlap (tempop, start_tempop) < overlap)
			continue;
		if ((ret = visit (tempop, data)))
			return ret;
	}
	return 0;
}

operand_t *
alias_operand (type_t *type, operand_t *op, expr_t *expr)
{
	operand_t  *aop;

	if (type_size (type) != type_size (op->type)) {
		internal_error (op->expr,
						"aliasing operand with type of different size: %d, %d",
						type_size (type), type_size (op->type));
	}
	aop = new_operand (op_alias, expr, __builtin_return_address (0));
	aop->alias = op;
	aop->type = type;
	aop->size = type_size (type);
	aop->width = type_width (type);
	return aop;
}

operand_t *
label_operand (expr_t *label)
{
	operand_t  *lop;

	if (label->type != ex_label) {
		internal_error (label, "not a label expression");
	}
	lop = new_operand (op_label, label, __builtin_return_address (0));
	lop->label = &label->e.label;
	return lop;
}

static operand_t *
short_operand (short short_val, expr_t *expr)
{
	ex_value_t *val = new_short_val (short_val);
	return value_operand (val, expr);
}

static const char *
convert_op (int op)
{
	switch (op) {
		case OR:	return "or";
		case AND:	return "and";
		case EQ:	return "eq";
		case NE:	return "ne";
		case LE:	return "le";
		case GE:	return "ge";
		case LT:	return "lt";
		case GT:	return "gt";
		case '+':	return "add";
		case '-':	return "sub";
		case '*':	return "mul";
		case '/':	return "div";
		case '%':	return "rem";
		case MOD:	return "mod";
		case '&':	return "bitand";
		case '|':	return "bitor";
		case '^':	return "bitxor";
		case '~':	return "bitnot";
		case '!':	return "not";
		case SHL:	return "shl";
		case SHR:	return "shr";
		case '.':	return "load";
		case CROSS:	return "cross";
		case DOT:	return "dot";
		case SCALE:	return "scale";
		default:
			return 0;
	}
}

int
statement_is_cond (statement_t *s)
{
	if (!s)
		return 0;
	return !strncmp (s->opcode, "if", 2);
}

int
statement_is_goto (statement_t *s)
{
	if (!s)
		return 0;
	return !strcmp (s->opcode, "jump") && !s->opb;
}

int
statement_is_jumpb (statement_t *s)
{
	if (!s)
		return 0;
	return !strcmp (s->opcode, "jump") && s->opb;
}

int
statement_is_call (statement_t *s)
{
	if (!s)
		return 0;
	if (!strncmp (s->opcode, "call", 4))
		return 1;
	if (!strncmp (s->opcode, "rcall", 5))
		return 2;
	return 0;
}

int
statement_is_return (statement_t *s)
{
	if (!s)
		return 0;
	return !strncmp (s->opcode, "return", 6);
}

static ex_label_t **
statement_get_labelref (statement_t *s)
{
	if (statement_is_cond (s)
		|| statement_is_goto (s)
		|| statement_is_jumpb (s)) {
		return &s->opa->label;
	}
	return 0;
}

sblock_t *
statement_get_target (statement_t *s)
{
	ex_label_t **label = statement_get_labelref (s);
	return label ? (*label)->dest : 0;
}

sblock_t **
statement_get_targetlist (statement_t *s)
{
	sblock_t  **target_list;
	int         count = 0, i;
	def_t      *table = 0;
	element_t  *e;

	if (statement_is_cond (s)) {
		count = 1;
	} else if (statement_is_goto (s)) {
		count = 1;
	} else if (statement_is_jumpb (s)) {
		table = s->opa->def;
		count = table->type->t.array.size;
	}
	target_list = malloc ((count + 1) * sizeof (sblock_t *));
	target_list[count] = 0;
	if (statement_is_cond (s)) {
		target_list[0] = statement_get_target (s);
	} else if (statement_is_goto (s)) {
		target_list[0] = statement_get_target (s);
	} else if (statement_is_jumpb (s)) {
		if (table->alias)
			internal_error (s->opa->expr, "aliased jump table");
		e = table->initializer->e.compound.head;	//FIXME check!!!
		for (i = 0; i < count; e = e->next, i++)
			target_list[i] = e->expr->e.labelref.label->dest;
	}
	return target_list;
}

static void
invert_conditional (statement_t *s)
{
	if (!strcmp (s->opcode, "ifnz"))
		s->opcode = "ifz";
	else if (!strcmp (s->opcode, "ifz"))
		s->opcode = "ifnz";
	else if (!strcmp (s->opcode, "ifbe"))
		s->opcode = "ifa";
	else if (!strcmp (s->opcode, "ifb"))
		s->opcode = "ifae";
	else if (!strcmp (s->opcode, "ifae"))
		s->opcode = "ifb";
	else if (!strcmp (s->opcode, "ifa"))
		s->opcode = "ifbe";
}

typedef sblock_t *(*statement_f) (sblock_t *, expr_t *);
typedef sblock_t *(*expr_f) (sblock_t *, expr_t *, operand_t **);

static sblock_t *statement_subexpr (sblock_t *sblock, expr_t *e,
									operand_t **op);
static sblock_t *statement_slist (sblock_t *sblock, expr_t *e);
static sblock_t *expr_symbol (sblock_t *sblock, expr_t *e, operand_t **op);
static sblock_t *expr_def (sblock_t *sblock, expr_t *e, operand_t **op);

static sblock_t *
expr_address (sblock_t *sblock, expr_t *e, operand_t **op)
{
	statement_t *s;
	expr_t      *lvalue = e->e.address.lvalue;
	expr_t      *offset = e->e.address.offset;

	if (lvalue->type == ex_alias && offset && is_constant (offset)) {
		lvalue = new_offset_alias_expr (lvalue->e.alias.type,
										lvalue->e.alias.expr,
										expr_int (offset));
		offset = 0;
	}

	s = new_statement (st_address, "lea", e);
	sblock = statement_subexpr (sblock, lvalue, &s->opa);
	if (offset) {
		sblock = statement_subexpr (sblock, offset, &s->opb);
	}
	s->opc = temp_operand (e->e.address.type, e);
	sblock_add_statement (sblock, s);
	*(op) = s->opc;
	return sblock;
}

static operand_t *
operand_address (operand_t *reference, expr_t *e)
{
	def_t      *def;
	type_t     *type;
	int         offset = 0;

	type = reference->type;
	switch (reference->op_type) {
		case op_def:
			// assumes aliasing is only one level deep which should be the
			// case
			def = reference->def;
			if (def->alias) {
				offset = def->offset;
				def = def->alias;
			}
			return value_operand (new_pointer_val (offset, type, def, 0), e);
		case op_temp:
			// assumes aliasing is only one level deep which should be the
			// case
			if (reference->tempop.alias) {
				offset = reference->tempop.offset;
				reference = reference->tempop.alias;
			}
			return value_operand (new_pointer_val (offset, type, 0,
												   reference), e);
		case op_alias:
			//op_alias comes only from alias_operand and that is called
			// by dags, so not expected
		case op_value:
		case op_label:
		case op_nil:
		case op_pseudo:
			break;
	}
	internal_error (e, "invalid operand type for operand address: %s",
					op_type_names[reference->op_type]);
}

static __attribute__((pure)) int
is_indirect (expr_t *e)
{
	if ((e->type == ex_expr || e->type == ex_uexpr)
		&& e->e.expr.op == '.') {
		return 1;
	}
	return 0;
}

static sblock_t *addressing_mode (sblock_t *sblock, expr_t *ref,
								  operand_t **base, operand_t **offset,
								  pr_ushort_t *mode, operand_t **target);
static statement_t *lea_statement (operand_t *pointer, operand_t *offset,
								   expr_t *e);

static sblock_t *
expr_assign_copy (sblock_t *sblock, expr_t *e, operand_t **op, operand_t *src)
{
	statement_t *s;
	expr_t     *dst_expr = e->e.assign.dst;
	expr_t     *src_expr = e->e.assign.src;
	type_t     *dst_type = get_type (dst_expr);
	type_t     *src_type = get_type (src_expr);
	unsigned    count;
	expr_t     *count_expr;
	operand_t  *dst = 0;
	operand_t  *size = 0;
	static const char *opcode_sets[][2] = {
		{"move", "movep"},
		{"memset", "memsetp"},
	};
	const unsigned max_count = 1 << 16;
	const char **opcode_set = opcode_sets[0];
	const char *opcode;
	int         need_ptr = 0;
	st_type_t   type = st_move;
	operand_t  *use = 0;
	operand_t  *def = 0;
	operand_t  *kill = 0;

	if ((src && src->op_type == op_nil) || src_expr->type == ex_nil) {
		// switch to memset because nil is type agnostic 0 and structures
		// can be any size
		src_expr = new_int_expr (0);
		sblock = statement_subexpr (sblock, src_expr, &src);
		opcode_set = opcode_sets[1];
		if (op) {
			*op = nil_operand (dst_type, src_expr);
		}
		type = st_memset;
		if (is_indirect (dst_expr)) {
			need_ptr = 1;
		}
	} else {
		if (is_indirect (src_expr)) {
			src_expr = expr_file_line (address_expr (src_expr, 0), e);
			need_ptr = 1;
		}
		if (!src) {
			// This is the very right-hand node of a non-nil assignment chain
			// (there may be more chains somwhere within src_expr, but they
			// are not part of this chain as they are separated by another
			// expression).
			sblock = statement_subexpr (sblock, src_expr, &src);
		}
		// send the source operand back up through the assignment chain
		// before modifying src if its address is needed
		if (op) {
			*op = src;
		}
		if (is_indirect (dst_expr)) {
			if (is_variable (src_expr)) {
				// FIXME this probably needs to be more agressive
				// shouldn't emit code...
				sblock = statement_subexpr (sblock, src_expr, &use);
			}
			if (options.code.progsversion == PROG_VERSION) {
				// FIXME it was probably a mistake extracting the operand
				// type from the statement expression in dags. Also, can't
				// use address_expr() because src_expr may be a function call
				// and unary_expr doesn't like that
				src_expr = expr_file_line (
						new_address_expr (get_type (src_expr), src_expr, 0),
										  src_expr);
				s = lea_statement (src, 0, src_expr);
				sblock_add_statement (sblock, s);
				src = s->opc;
			} else {
				src = operand_address (src, src_expr);
			}
			need_ptr = 1;
		}
	}
	if (need_ptr) {
		// dst_expr and/or src_expr are dereferenced pointers, so need to
		// un-dereference dst_expr to get the pointer and switch to movep
		// or memsetp instructions.
		if (is_variable (dst_expr)) {
			// FIXME this probably needs to be more agressive
			// shouldn't emit code...
			sblock = statement_subexpr (sblock, dst_expr, &def);
			sblock = statement_subexpr (sblock, dst_expr, &kill);
		}
		dst_expr = expr_file_line (address_expr (dst_expr, 0), e);
		need_ptr = 1;
	}
	sblock = statement_subexpr (sblock, dst_expr, &dst);

	if (type_size (dst_type) != type_size (src_type)) {
		bug (e, "dst and src sizes differ in expr_assign_copy: %d %d",
			 type_size (dst_type), type_size (src_type));
	}
	count = min (type_size (dst_type), type_size (src_type));
	if (count < (1 << 16)) {
		count_expr = expr_file_line (new_short_expr (count), e);
	} else {
		count_expr = expr_file_line (new_int_expr (count), e);
	}
	sblock = statement_subexpr (sblock, count_expr, &size);

	if (count < max_count && !need_ptr) {
		opcode = opcode_set[0];
	} else {
		opcode = opcode_set[1];
		type++;	// from st_move/st_memset to st_ptrmove/st_ptrmemset
	}

	s = new_statement (type, opcode, e);
	s->opa = src;
	s->opb = size;
	s->opc = dst;
	s->use = use;
	s->def = def;
	s->kill = kill;
	sblock_add_statement (sblock, s);
	return sblock;
}

static sblock_t *
expr_assign (sblock_t *sblock, expr_t *e, operand_t **op)
{
	statement_t *s;
	expr_t     *src_expr = e->e.assign.src;
	expr_t     *dst_expr = e->e.assign.dst;
	type_t     *dst_type = get_type (dst_expr);
	operand_t  *src = 0;
	operand_t  *dst = 0;
	operand_t  *ofs = 0;
	operand_t  *target = 0;
	pr_ushort_t mode = 0;	// assign
	const char *opcode = "assign";
	st_type_t   type = st_assign;

	if (src_expr->type == ex_assign) {
		sblock = statement_subexpr (sblock, src_expr, &src);
		if (is_structural (dst_type)) {
			return expr_assign_copy (sblock, e, op, src);
		}
		if (is_indirect (dst_expr)) {
			goto dereference_dst;
		} else {
			sblock = statement_subexpr (sblock, dst_expr, &dst);
		}
	} else {
		if (is_structural (dst_type)) {
			return expr_assign_copy (sblock, e, op, src);
		}

		if (is_indirect (dst_expr)) {
			// If both dst_expr and src_expr are indirect, then a staging temp
			// is needed, but emitting src_expr first generates that temp
			// because src is null. If src_expr is not indirect and is a simple
			// variable reference, then just the ref will be generated and thus
			// will be assigned to the dereferenced destination. If src_expr
			// is not simple, then a temp will be generated, so all good.
			sblock = statement_subexpr (sblock, src_expr, &src);
			goto dereference_dst;
		} else {
			// dst_expr is direct and known to be an l-value, so emitting
			// its expression will simply generate a reference to that l-value
			// which will be used as the default location to store src_expr's
			// result
			sblock = statement_subexpr (sblock, dst_expr, &dst);
			src = dst;
			sblock = statement_subexpr (sblock, src_expr, &src);
		}
	}

	if (0) {
dereference_dst:
		// dst_expr is a dereferenced pointer, so need to get its addressing
		// parameters (base and offset) and switch to store instructions.
		sblock = addressing_mode (sblock, dst_expr, &dst, &ofs, &mode, &target);
		if (mode != 0) {
			opcode = "store";
			type = st_ptrassign;
		} else {
			ofs = 0;
		}
	}
	if (op) {
		*op = src;
	}
	if (src == dst) {
		return sblock;
	}

	if (options.code.progsversion < PROG_VERSION
		&& is_entity (dst->type) && ofs && is_field (ofs->type)) {
		// need to get a pointer type, entity.field expressions do not provide
		// one directly. FIXME it was probably a mistake extracting the operand
		// type from the statement expression in dags
		dst_expr = expr_file_line (address_expr (dst_expr, 0), dst_expr);
		s = new_statement (st_address, "lea", dst_expr);
		s->opa = dst;
		s->opb = ofs;
		s->opc = temp_operand (&type_ptr, dst_expr);
		sblock_add_statement (sblock, s);
		dst = s->opc;
		ofs = 0;
	}
	s = new_statement (type, opcode, e);
	s->opa = dst;
	s->opb = ofs;
	s->opc = src;
	statement_add_def (s, copy_operand (target));
	statement_add_kill (s, target);
	sblock_add_statement (sblock, s);
	return sblock;
}

static sblock_t *
vector_call (sblock_t *sblock, expr_t *earg, expr_t *param, int ind,
			 operand_t **op)
{
	//FIXME this should be done in the expression tree
	expr_t     *a, *v, *n;
	int         i;
	static const char *names[] = {"x", "y", "z"};

	for (i = 0; i < 3; i++) {
		n = new_name_expr (names[i]);
		v = new_float_expr (earg->e.value->v.vector_val[i]);
		a = assign_expr (field_expr (param, n), v);
		param = new_param_expr (get_type (earg), ind);
		a->line = earg->line;
		a->file = earg->file;
		sblock = statement_slist (sblock, a);
	}
	sblock = statement_subexpr (sblock, param, op);
	return sblock;
}

static sblock_t *
expr_call_v6p (sblock_t *sblock, expr_t *call, operand_t **op)
{
	expr_t     *func = call->e.branch.target;
	expr_t     *args = call->e.branch.args;
	expr_t     *a;
	expr_t     *param;
	operand_t  *arguments[2] = {0, 0};
	int         count = 0;
	int         ind;
	const char *opcode;
	const char *pref = "";
	statement_t *s;

	// function arguments are in reverse order
	for (a = args; a; a = a->next) {
		if (a->type == ex_args) {
			// v6p uses callN and pr_argc
			continue;
		}
		count++;
	}
	ind = count;
	for (a = args; a; a = a->next) {
		if (a->type == ex_args) {
			// v6p uses callN and pr_argc
			continue;
		}
		ind--;
		param = new_param_expr (get_type (a), ind);
		if (count && options.code.progsversion != PROG_ID_VERSION && ind < 2) {
			pref = "r";
			sblock = statement_subexpr (sblock, param, &arguments[ind]);
			if (options.code.vector_calls && a->type == ex_value
				&& a->e.value->lltype == ev_vector)
				sblock = vector_call (sblock, a, param, ind, &arguments[ind]);
			else
				sblock = statement_subexpr (sblock, a, &arguments[ind]);
			continue;
		}
		if (is_struct (get_type (param))) {
			expr_t     *mov = assign_expr (param, a);
			mov->line = a->line;
			mov->file = a->file;
			sblock = statement_slist (sblock, mov);
		} else {
			if (options.code.vector_calls && a->type == ex_value
				&& a->e.value->lltype == ev_vector) {
				sblock = vector_call (sblock, a, param, ind, 0);
			} else {
				operand_t  *p = 0;
				operand_t  *arg;
				sblock = statement_subexpr (sblock, param, &p);
				arg = p;
				sblock = statement_subexpr (sblock, a, &arg);
				if (arg != p) {
					s = new_statement (st_assign, "assign", a);
					s->opa = p;
					s->opc = arg;
					sblock_add_statement (sblock, s);
				}
			}
		}
	}
	opcode = va (0, "%scall%d", pref, count);
	s = new_statement (st_func, opcode, call);
	sblock = statement_subexpr (sblock, func, &s->opa);
	s->opb = arguments[0];
	s->opc = arguments[1];
	if (op) {
		*op = return_operand (call->e.branch.ret_type, call);
	}
	sblock_add_statement (sblock, s);
	sblock->next = new_sblock ();
	return sblock->next;
}

static sblock_t *
expr_call (sblock_t *sblock, expr_t *call, operand_t **op)
{
	if (options.code.progsversion < PROG_VERSION) {
		return expr_call_v6p (sblock, call, op);
	}
	if (!current_func->arguments) {
		current_func->arguments = defspace_new (ds_virtual);
	}
	defspace_t *arg_space = current_func->arguments;
	expr_t     *func = call->e.branch.target;
	expr_t    **args = 0;
	expr_t     *args_va_list = 0;	// .args (...) parameter
	expr_t     *args_params = 0;	// first arg in ...
	operand_t  *use = 0;
	operand_t  *kill = 0;
	int         num_params = 0;

	defspace_reset (arg_space);

	int         num_args = 0;
	for (expr_t *a = call->e.branch.args; a; a = a->next) {
		num_args++;
	}
	if (num_args) {
		int         i = num_args;
		args = alloca (num_args * sizeof (expr_t *));
		for (expr_t *a = call->e.branch.args; a; a = a->next) {
			args[--i] = a;
		}
	}
	int         arg_num = 0;
	for (int i = 0; i < num_args; i++) {
		expr_t     *a = args[i];
		const char *arg_name = va (0, ".arg%d", arg_num++);
		def_t      *def = new_def (arg_name, 0, current_func->arguments,
								   sc_local);
		type_t     *arg_type = get_type (a);
		int         size = type_size (arg_type);
		int         alignment = arg_type->alignment;
		if (alignment < 4) {
			alignment = 4;
		}
		def->offset = defspace_alloc_aligned_highwater (arg_space, size,
														alignment);
		def->type = arg_type;
		def->reg = current_func->temp_reg;
		expr_t     *def_expr = expr_file_line (new_def_expr (def), call);
		if (a->type == ex_args) {
			args_va_list = def_expr;
		} else {
			if (args_va_list && !args_params) {
				args_params = def_expr;
			}
			if (args_va_list) {
				num_params++;
			}
			expr_t     *assign = assign_expr (def_expr, a);
			expr_file_line (assign, call);
			sblock = statement_slist (sblock, assign);
		}

		// The call both uses and kills the arguments: use is obvious, but kill
		// is because the callee has direct access to them and might modify
		// them
		// need two ops for the one def because there's two lists
		operand_t  *u = def_operand (def, arg_type, call);
		operand_t  *k = def_operand (def, arg_type, call);
		u->next = use;
		use = u;
		k->next = kill;
		kill = k;
	}
	if (args_va_list) {
		expr_t     *assign;
		expr_t     *count;
		expr_t     *list;
		expr_t     *args_count = field_expr (args_va_list,
											 new_name_expr ("count"));
		expr_t     *args_list = field_expr (args_va_list,
											new_name_expr ("list"));
		expr_file_line (args_count, call);
		expr_file_line (args_list, call);

		count = new_short_expr (num_params);
		assign = assign_expr (args_count, count);
		expr_file_line (assign, call);
		sblock = statement_slist (sblock, assign);

		if (args_params) {
			list = address_expr (args_params, &type_param);
		} else {
			list = new_nil_expr ();
		}
		expr_file_line (list, call);
		assign = assign_expr (args_list, list);
		expr_file_line (assign, call);
		sblock = statement_slist (sblock, assign);
	}
	statement_t *s = new_statement (st_func, "call", call);
	sblock = statement_subexpr (sblock, func, &s->opa);
	if (!op) {
		s->opc = short_operand (0, call);
	} else {
		if (!*op) {
			*op = temp_operand (call->e.branch.ret_type, call);
		}
		s->opc = *op;
	}
	s->use = use;
	s->kill = kill;
	sblock_add_statement (sblock, s);
	sblock->next = new_sblock ();
	return sblock->next;
}

static sblock_t *
expr_branch (sblock_t *sblock, expr_t *e, operand_t **op)
{
	if (e->e.branch.type != pr_branch_call) {
		internal_error (e, "unexpected branch type in expression: %d",
						e->e.branch.type);
	}
	return expr_call (sblock, e, op);
}

static sblock_t *
statement_branch (sblock_t *sblock, expr_t *e)
{
	static const char *opcodes[] = {
		"ifz",
		"ifb",
		"ifa",
		0,			// special handling
		"ifnz",
		"ifae",
		"ifbe",
		0,			// not used here
	};
	statement_t *s = 0;
	const char *opcode;

	if (e->e.branch.type == pr_branch_call) {
		return expr_call (sblock, e, 0);
	}
	if (e->e.branch.type == pr_branch_jump) {
		if (e->e.branch.index) {
			s = new_statement (st_flow, "jump", e);
			sblock = statement_subexpr (sblock, e->e.branch.target, &s->opa);
			sblock = statement_subexpr (sblock, e->e.branch.index, &s->opb);
		} else {
			s = new_statement (st_flow, "jump", e);
			s->opa = label_operand (e->e.branch.target);
		}
	} else {
		opcode = opcodes [e->e.branch.type];
		s = new_statement (st_flow, opcode, e);
		sblock = statement_subexpr (sblock, e->e.branch.test, &s->opc);
		s->opa = label_operand (e->e.branch.target);
	}

	sblock_add_statement (sblock, s);
	sblock->next = new_sblock ();
	return sblock->next;
}

static operand_t *
find_def_operand (expr_t *ref)
{
	operand_t  *op = 0;
	if (ref->type == ex_alias) {
		return find_def_operand (ref->e.alias.expr);
	} else if (ref->type == ex_address) {
		return find_def_operand (ref->e.address.lvalue);
	} else if (ref->type == ex_symbol) {
		expr_symbol (0, ref, &op);
	} else if (ref->type == ex_def) {
		expr_def (0, ref, &op);
	} else {
		internal_error (ref, "unexpected expr type: %s",
						expr_names[ref->type]);
	}
	return op;
}

static sblock_t *
ptr_addressing_mode (sblock_t *sblock, expr_t *ref,
				 operand_t **base, operand_t **offset, pr_ushort_t *mode,
				 operand_t **target)
{
	type_t     *type = get_type (ref);
	if (!is_ptr (type)) {
		internal_error (ref, "expected pointer in ref");
	}
	if (ref->type == ex_address
		&& (!ref->e.address.offset || is_constant (ref->e.address.offset))
		&& ref->e.address.lvalue->type == ex_alias
		&& (!ref->e.address.lvalue->e.alias.offset
			|| is_constant (ref->e.address.lvalue->e.alias.offset))) {
		expr_t     *lvalue = ref->e.address.lvalue;
		expr_t     *offs = ref->e.address.offset;
		expr_t     *alias;
		if (lvalue->e.alias.offset) {
			if (offs) {
				offs = binary_expr ('+', offs, lvalue->e.alias.offset);
			} else {
				offs = lvalue->e.alias.offset;
			}
		}
		type = type->t.fldptr.type;
		if (offs) {
			expr_t     *lv = lvalue->e.alias.expr;
			type_t     *lvtype = get_type (lv);
			int         o = expr_int (offs);
			if (o < 0 || o + type_size (type) > type_size (lvtype)) {
				// not a valid offset for the type, which technically should
				// be an error, but there may be legitimate reasons for doing
				// such pointer shenanigans
				goto just_a_pointer;
			}
			alias = new_offset_alias_expr (type, lv, expr_int (offs));
		} else {
			alias = new_alias_expr (type, lvalue->e.alias.expr);
		}
		expr_file_line (alias, ref);
		return addressing_mode (sblock, alias, base, offset, mode, target);
	} else if (ref->type != ex_alias || ref->e.alias.offset) {
		// probably just a pointer
just_a_pointer:
		sblock = statement_subexpr (sblock, ref, base);
		*offset = short_operand (0, ref);
		*mode = 2;	// mode C: ptr + constant index
	} else if (is_ptr (get_type (ref->e.alias.expr))) {
		// cast of one pointer type to another
		return ptr_addressing_mode (sblock, ref->e.alias.expr, base, offset,
									mode, target);
	} else {
		// alias with no offset
		if (!is_integral (get_type (ref->e.alias.expr))) {
			internal_error (ref, "expected integer expr in ref");
		}
		expr_t     *intptr = ref->e.alias.expr;
		if (intptr->type != ex_expr
			|| (intptr->e.expr.op != '+'
				&& intptr->e.expr.op != '-')) {
			// treat ref as simple pointer
			sblock = statement_subexpr (sblock, ref, base);
			*offset = short_operand (0, ref);
			*mode = 2;	// mode C: ptr + constant index
		} else {
			expr_t     *ptr = intptr->e.expr.e1;
			expr_t     *offs = intptr->e.expr.e2;
			int         const_offs;
			if (target) {
				if (ptr->type == ex_alias
					&& is_ptr (get_type (ptr->e.alias.expr))) {
					*target = find_def_operand (ptr->e.alias.expr);
				}
			}
			// move the +/- to the offset
			offs = unary_expr (intptr->e.expr.op, offs);
			// make the base a pointer again
			ptr = new_alias_expr (ref->e.alias.type, ptr);
			sblock = statement_subexpr (sblock, ptr, base);
			if (is_constant (offs)
				&& (const_offs = expr_int (offs)) < 32768
				&& const_offs >= -32768) {
				*mode = 2;
				*offset = short_operand (const_offs, ref);
			} else {
				*mode = 3;
				sblock = statement_subexpr (sblock, offs, offset);
			}
		}
	}
	return sblock;
}

static sblock_t *
addressing_mode (sblock_t *sblock, expr_t *ref,
				 operand_t **base, operand_t **offset, pr_ushort_t *mode,
				 operand_t **target)
{
	if (is_indirect (ref)) {
		// ref is known to be either ex_expr or ex_uexpr, with '.' for
		// the operator
		if (ref->type == ex_expr) {
			expr_t     *ent_expr = ref->e.expr.e1;
			expr_t     *fld_expr = ref->e.expr.e2;
			if (!is_entity (get_type (ent_expr))
				|| !is_field (get_type (fld_expr))) {
				print_expr (ref);
				internal_error (ref, "expected entity.field");
			}
			sblock = statement_subexpr (sblock, ent_expr, base);
			sblock = statement_subexpr (sblock, fld_expr, offset);
			*mode = 1;//entity.field
		} else if (ref->type == ex_uexpr) {
			sblock = ptr_addressing_mode (sblock, ref->e.expr.e1, base, offset,
										  mode, target);
		} else {
			internal_error (ref, "unexpected expression type for indirect: %s",
							expr_names[ref->type]);
		}
	} else {
		sblock = statement_subexpr (sblock, ref, base);
		*offset = short_operand (0, ref);
		*mode = 0;
		*target = 0;
	}
	return sblock;
}

static sblock_t *
statement_return (sblock_t *sblock, expr_t *e)
{
	const char *opcode;
	statement_t *s;

	debug (e, "RETURN");
	opcode = "return";
	if (!e->e.retrn.ret_val) {
		if (options.code.progsversion == PROG_ID_VERSION) {
			e->e.retrn.ret_val = new_float_expr (0);
		}
	}
	s = new_statement (st_func, opcode, e);
	if (options.code.progsversion < PROG_VERSION) {
		if (e->e.retrn.ret_val) {
			expr_t     *ret_val = e->e.retrn.ret_val;
			type_t     *ret_type = get_type (ret_val);

			// at_return is used for passing the result of a void_return
			// function through void. v6 progs always use .return for the
			// return value, so don't need to do anything special: just call
			// the function and do a normal void return
			if (!e->e.retrn.at_return) {
				s->opa = return_operand (ret_type, e);
			}
			sblock = statement_subexpr (sblock, ret_val, &s->opa);
		}
	} else {
		if (!e->e.retrn.at_return && e->e.retrn.ret_val) {
			expr_t     *ret_val = e->e.retrn.ret_val;
			type_t     *ret_type = get_type (ret_val);
			operand_t  *target = 0;
			pr_ushort_t ret_crtl = type_size (ret_type) - 1;
			pr_ushort_t mode = 0;
			sblock = addressing_mode (sblock, ret_val, &s->opa, &s->opb, &mode,
									  &target);
			ret_crtl |= mode << 5;
			s->opc = short_operand (ret_crtl, e);
			statement_add_use (s, target);
		} else {
			if (e->e.retrn.at_return) {
				expr_t     *call = e->e.retrn.ret_val;
				if (!call || !is_function_call (call)) {
					internal_error (e, "@return with no call");
				}
				// FIXME hard-coded reg, and assumes 3 is free
				#define REG 3
				expr_t     *with = new_with_expr (11, REG, new_short_expr (0));
				def_t      *ret_ptr = new_def (0, 0, 0, sc_local);
				operand_t  *ret_op = def_operand (ret_ptr, &type_void, e);
				ret_ptr->reg = REG;
				expr_file_line (with, e);
				sblock = statement_slist (sblock, with);
				sblock = statement_subexpr (sblock, call, &ret_op);
			}
			s->opa = short_operand (0, e);
			s->opb = short_operand (0, e);
			s->opc = short_operand (-1, e);	// void return
		}
	}
	sblock_add_statement (sblock, s);
	sblock->next = new_sblock ();
	sblock = sblock->next;

	return sblock;
}

static sblock_t *
statement_adjstk (sblock_t *sblock, expr_t *e)
{
	statement_t *s = new_statement (st_func, "adjstk", e);
	s->opa = short_operand (e->e.adjstk.mode, e);
	s->opb = short_operand (e->e.adjstk.offset, e);

	sblock_add_statement (sblock, s);
	return sblock;
}

static sblock_t *
statement_with (sblock_t *sblock, expr_t *e)
{
	statement_t *s = new_statement (st_func, "with", e);
	s->opa = short_operand (e->e.with.mode, e);
	s->opc = short_operand (e->e.with.reg, e);
	sblock = statement_subexpr (sblock, e->e.with.with, &s->opb);
	sblock_add_statement (sblock, s);
	return sblock;
}

static statement_t *
lea_statement (operand_t *pointer, operand_t *offset, expr_t *e)
{
	statement_t *s = new_statement (st_address, "lea", e);
	s->opa = pointer;
	s->opb = offset;
	s->opc = temp_operand (&type_ptr, e);
	return s;
}

static statement_t *
movep_statement (operand_t *dst, operand_t *src, type_t *type, expr_t *e)
{
	operand_t  *dst_addr = operand_address (dst, e);
	statement_t *s = new_statement (st_ptrmove, "movep", e);
	s->opa = src;
	//FIXME large types
	s->opb = short_operand (type_size (type), e);
	s->opc = dst_addr;
	return s;
}

static statement_t *
load_statement (operand_t *ptr, operand_t *offs, operand_t *op, expr_t *e)
{
	statement_t *s = new_statement (st_expr, "load", e);
	s->opa = ptr;
	s->opb = offs;
	s->opc = op;
	return s;
}

static statement_t *
assign_statement (operand_t *dst, operand_t *src, expr_t *e)
{
	statement_t *s = new_statement (st_assign, "assign", e);
	s->opa = dst;
	s->opc = src;
	return s;
}

static sblock_t *
expr_deref (sblock_t *sblock, expr_t *deref, operand_t **op)
{
	type_t     *load_type = deref->e.expr.type;
	expr_t     *ptr_expr = deref->e.expr.e1;
	operand_t  *base = 0;
	operand_t  *offset = 0;
	operand_t  *target = 0;
	pr_ushort_t mode;
	statement_t *s;

	sblock = addressing_mode (sblock, deref, &base, &offset, &mode, &target);

	if (!*op) {
		*op = temp_operand (load_type, deref);
	}

	switch (mode) {
		case 0://direct def access
			// FIXME should check that offset is 0, but currently,
			// addressing_mode always sets offset to 0 for mode 0
			s = assign_statement (*op, base, deref);
			sblock_add_statement (sblock, s);
			statement_add_use (s, target);
			return sblock;
		case 1://entity.field
		case 2://const indexed pointer
		case 3://var indexed pointer
			break;
		default:
			internal_error (deref, "unexpected addressing mode: %d", mode);
	}

	if (low_level_type (load_type) == ev_void) {
		s = lea_statement (base, offset, ptr_expr);
		sblock_add_statement (sblock, s);

		s = movep_statement (*op, s->opc, load_type, deref);
		sblock_add_statement (sblock, s);
	} else {
		s = load_statement (base, offset, *op, deref);
		sblock_add_statement (sblock, s);
	}
	statement_add_use (s, target);

	return sblock;
}

static sblock_t *
expr_block (sblock_t *sblock, expr_t *e, operand_t **op)
{
	if (!e->e.block.result)
		internal_error (e, "block sub-expression without result");
	sblock = statement_slist (sblock, e->e.block.head);
	sblock = statement_subexpr (sblock, e->e.block.result, op);
	return sblock;
}

static sblock_t *
expr_alias (sblock_t *sblock, expr_t *e, operand_t **op)
{
	operand_t *aop = 0;
	operand_t *top;
	type_t    *type;
	def_t     *def;
	int        offset = 0;

	if (e->e.alias.offset) {
		offset = expr_int (e->e.alias.offset);
	}
	type = e->e.alias.type;
	sblock = statement_subexpr (sblock, e->e.alias.expr, &aop);
	if (type_compatible (aop->type, type)) {
		if (offset) {
			//For types to be compatible, they must be the same size, thus this
			//seemingly mismatched error
			internal_error (e, "offset alias of same size type");
		}
		*op = aop;
		return sblock;
	}
	if (aop->op_type == op_temp) {
		while (aop->tempop.alias) {
			aop = aop->tempop.alias;
			if (aop->op_type != op_temp)
				internal_error (e, "temp alias of non-temp var");
			if (aop->tempop.alias)
				bug (e, "aliased temp alias");
		}
		for (top = aop->tempop.alias_ops; top; top = top->next) {
			if (top->type == type && top->tempop.offset == offset) {
				break;
			}
		}
		if (!top) {
			top = temp_operand (type, e);
			top->tempop.alias = aop;
			top->tempop.offset = offset;
			top->next = aop->tempop.alias_ops;
			aop->tempop.alias_ops = top;
		}
		*op = top;
	} else if (aop->op_type == op_def) {
		def = aop->def;
		while (def->alias)
			def = def->alias;
		*op = def_operand (alias_def (def, type, offset), 0, e);
	} else if (aop->op_type == op_value) {
		*op = value_operand (aop->value, e);
		(*op)->type = type;
	} else {
		internal_error (e, "invalid alias target: %s: %s",
						optype_str (aop->op_type), operand_string (aop));
	}
	return sblock;
}

static sblock_t *
expr_expr (sblock_t *sblock, expr_t *e, operand_t **op)
{
	const char *opcode;
	statement_t *s;

	opcode = convert_op (e->e.expr.op);
	if (!opcode)
		internal_error (e, "ice ice baby");
	if (strcmp (opcode, "ne") == 0 && is_string (get_type (e->e.expr.e1))) {
		opcode = "cmp";
	}
	if (strcmp (opcode, "dot") == 0) {
		if (is_vector (get_type (e->e.expr.e1))) {
			opcode = "vdot";
		}
		if (is_quaternion (get_type (e->e.expr.e1))) {
			opcode = "qdot";
		}
	}
	s = new_statement (st_expr, opcode, e);
	sblock = statement_subexpr (sblock, e->e.expr.e1, &s->opa);
	sblock = statement_subexpr (sblock, e->e.expr.e2, &s->opb);
	if (!*op)
		*op = temp_operand (e->e.expr.type, e);
	s->opc = *op;
	sblock_add_statement (sblock, s);

	return sblock;
}

static int type_map[ev_type_count] = {
	[ev_int] = 0,
	[ev_float] = 1,
	[ev_long] = 2,
	[ev_double] = 3,
	[ev_uint] = 4,
	//[ev_bool32] = 5,
	[ev_ulong] = 6,
	//[ev_bool64] = 7,
};

static sblock_t *
expr_cast (sblock_t *sblock, expr_t *e, operand_t **op)
{
	type_t     *src_type;
	type_t     *type = e->e.expr.type;
	statement_t *s;

	src_type = get_type (e->e.expr.e1);
	if (is_scalar (src_type) && is_scalar (type)) {
		operand_t  *src = 0;
		sblock = statement_subexpr (sblock, e->e.expr.e1, &src);
		*op = temp_operand (e->e.expr.type, e);
		s = new_statement (st_expr, "conv", e);
		s->opa = src;
		if (options.code.progsversion == PROG_VERSION) {
			int         from = type_map[src_type->type];
			int         to = type_map[type->type];
			int         width = type_width (src_type) - 1;
			int         conv = (width << 6) | (from << 3) | to;
			s->opb = short_operand (conv, e);
		}
		s->opc = *op;
		sblock_add_statement (sblock, s);
	} else {
		sblock = expr_alias (sblock, e, op);
	}
	return sblock;
}

static sblock_t *
expr_negate (sblock_t *sblock, expr_t *e, operand_t **op)
{
	expr_t     *neg;
	expr_t     *zero;

	zero = new_nil_expr ();
	zero->file = e->file;
	zero->line = e->line;
	convert_nil (zero, e->e.expr.type);
	neg = binary_expr ('-', zero, e->e.expr.e1);
	neg->file = e->file;
	neg->line = e->line;
	return statement_subexpr (sblock, neg, op);
}

static sblock_t *
expr_uexpr (sblock_t *sblock, expr_t *e, operand_t **op)
{
	const char *opcode;
	statement_t *s;

	switch (e->e.expr.op) {
		case '.':
			sblock = expr_deref (sblock, e, op);
			break;
		case 'C':
			sblock = expr_cast (sblock, e, op);
			break;
		case '-':
			// progs has no neg instruction!?!
			sblock = expr_negate (sblock, e, op);
			break;
		default:
			opcode = convert_op (e->e.expr.op);
			if (!opcode)
				internal_error (e, "ice ice baby");
			s = new_statement (st_expr, opcode, e);
			sblock = statement_subexpr (sblock, e->e.expr.e1, &s->opa);
			if (!*op)
				*op = temp_operand (e->e.expr.type, e);
			s->opc = *op;
			sblock_add_statement (sblock, s);
	}
	return sblock;
}

static sblock_t *
expr_horizontal (sblock_t *sblock, expr_t *e, operand_t **op)
{
	const char *opcode = "hops";
	statement_t *s;
	int         hop;
	type_t     *res_type = e->e.hop.type;
	type_t     *vec_type = get_type (e->e.hop.vec);

	switch (e->e.hop.op) {
		case '&':
			hop = 0;
			break;
		case '|':
			hop = 1;
			break;
		case '^':
			hop = 2;
			break;
		case '+':
			if (is_integral (vec_type)) {
				hop = 3;
			} else {
				hop = 7;
			}
			break;
		case NAND:
			hop = 4;
			break;
		case NOR:
			hop = 5;
			break;
		case XNOR:
			hop = 6;
			break;
		default:
			internal_error (e, "invalid horizontal op");
	}
	hop |= (type_width (vec_type) - 1) << 3;
	hop |= (pr_type_size[vec_type->type] - 1) << 5;

	s = new_statement (st_expr, opcode, e);
	sblock = statement_subexpr (sblock, e->e.hop.vec, &s->opa);
	s->opb = short_operand (hop, e);
	if (!*op) {
		*op = temp_operand (res_type, e);
	}
	s->opc = *op;
	sblock_add_statement (sblock, s);

	return sblock;
}

static sblock_t *
expr_def (sblock_t *sblock, expr_t *e, operand_t **op)
{
	*op = def_operand (e->e.def, e->e.def->type, e);
	return sblock;
}

static sblock_t *
expr_symbol (sblock_t *sblock, expr_t *e, operand_t **op)
{
	symbol_t   *sym = e->e.symbol;

	if (sym->sy_type == sy_var) {
		*op = def_operand (sym->s.def, sym->type, e);
	} else if (sym->sy_type == sy_const) {
		*op = value_operand (sym->s.value, e);
	} else if (sym->sy_type == sy_func) {
		if (!sym->s.func) {
			make_function (sym, 0, pr.symtab->space, sc_extern);
		}
		*op = def_operand (sym->s.func->def, 0, e);
	} else {
		internal_error (e, "unexpected symbol type: %s for %s",
						symtype_str (sym->sy_type), sym->name);
	}
	return sblock;
}

static sblock_t *
expr_temp (sblock_t *sblock, expr_t *e, operand_t **op)
{
	if (!e->e.temp.op)
		e->e.temp.op = temp_operand (e->e.temp.type, e);
	*op = e->e.temp.op;
	return sblock;
}

static sblock_t *
expr_vector_e (sblock_t *sblock, expr_t *e, operand_t **op)
{
	expr_t     *x, *y, *z, *w;
	expr_t     *s, *v;
	expr_t     *ax, *ay, *az, *aw;
	expr_t     *as, *av;
	expr_t     *tmp;
	type_t     *vec_type = get_type (e);
	int         file = pr.source_file;
	int         line = pr.source_line;

	pr.source_file = e->file;
	pr.source_line = e->line;

	tmp = new_temp_def_expr (vec_type);
	if (is_vector(vec_type)) {
		// guaranteed to have three elements
		x = e->e.vector.list;
		y = x->next;
		z = y->next;
		ax = new_name_expr ("x");
		ay = new_name_expr ("y");
		az = new_name_expr ("z");
		ax = assign_expr (field_expr (tmp, ax), x);
		ay = assign_expr (field_expr (tmp, ay), y);
		az = assign_expr (field_expr (tmp, az), z);
		sblock = statement_slist (sblock, ax);
		sblock = statement_slist (sblock, ay);
		sblock = statement_slist (sblock, az);
	} else {
		// guaranteed to have two or four elements
		if (e->e.vector.list->next->next) {
			// four vals: x, y, z, w
			x = e->e.vector.list;
			y = x->next;
			z = y->next;
			w = z->next;
			ax = new_name_expr ("x");
			ay = new_name_expr ("y");
			az = new_name_expr ("z");
			aw = new_name_expr ("w");
			ax = assign_expr (field_expr (tmp, ax), x);
			ay = assign_expr (field_expr (tmp, ay), y);
			az = assign_expr (field_expr (tmp, az), z);
			aw = assign_expr (field_expr (tmp, aw), w);
			sblock = statement_slist (sblock, ax);
			sblock = statement_slist (sblock, ay);
			sblock = statement_slist (sblock, az);
			sblock = statement_slist (sblock, aw);
		} else {
			// v, s
			v = e->e.vector.list;
			s = v->next;
			av = new_name_expr ("v");
			as = new_name_expr ("s");
			av = assign_expr (field_expr (tmp, av), v);
			as = assign_expr (field_expr (tmp, as), s);
			sblock = statement_slist (sblock, av);
			sblock = statement_slist (sblock, as);
		}
	}
	pr.source_file = file;
	pr.source_line = line;
	sblock = statement_subexpr (sblock, tmp, op);
	return sblock;
}

static sblock_t *
expr_nil (sblock_t *sblock, expr_t *e, operand_t **op)
{
	type_t     *nil = e->e.nil;
	expr_t     *size_expr;
	size_t      nil_size;
	operand_t  *zero;
	operand_t  *size;
	statement_t *s;

	if (!is_struct (nil) && !is_array (nil)) {
		*op = value_operand (new_nil_val (nil), e);
		return sblock;
	}
	if (!*op) {
		*op = temp_operand (nil, e);
	}
	nil_size = type_size (nil);
	if (nil_size < 0x10000) {
		size_expr = new_short_expr (nil_size);
	} else {
		size_expr = new_int_expr (nil_size);
	}
	sblock = statement_subexpr (sblock, new_int_expr(0), &zero);
	sblock = statement_subexpr (sblock, size_expr, &size);

	s = new_statement (st_memset, "memset", e);
	s->opa = zero;
	s->opb = size;
	s->opc = *op;
	sblock_add_statement (sblock, s);

	return sblock;
}

static sblock_t *
expr_value (sblock_t *sblock, expr_t *e, operand_t **op)
{
	*op = value_operand (e->e.value, e);
	return sblock;
}

static sblock_t *
expr_selector (sblock_t *sblock, expr_t *e, operand_t **op)
{
	return statement_subexpr (sblock, e->e.selector.sel_ref, op);
}

static sblock_t *
statement_subexpr (sblock_t *sblock, expr_t *e, operand_t **op)
{
	static expr_f sfuncs[ex_count] = {
		[ex_block] = expr_block,
		[ex_expr] = expr_expr,
		[ex_uexpr] = expr_uexpr,
		[ex_horizontal] = expr_horizontal,
		[ex_def] = expr_def,
		[ex_symbol] = expr_symbol,
		[ex_temp] = expr_temp,
		[ex_vector] = expr_vector_e,
		[ex_nil] = expr_nil,
		[ex_value] = expr_value,
		[ex_selector] = expr_selector,
		[ex_alias] = expr_alias,
		[ex_address] = expr_address,
		[ex_assign] = expr_assign,
		[ex_branch] = expr_branch,
	};
	if (!e) {
		*op = 0;
		return sblock;
	}

	if (e->type >= ex_count)
		internal_error (e, "bad sub-expression type: %d", e->type);
	if (!sfuncs[e->type])
		internal_error (e, "unexpected sub-expression type: %s",
						expr_names[e->type]);

	sblock = sfuncs[e->type] (sblock, e, op);
	return sblock;
}

static sblock_t *
statement_ignore (sblock_t *sblock, expr_t *e)
{
	return sblock;
}

static sblock_t *
statement_state (sblock_t *sblock, expr_t *e)
{
	statement_t *s;

	s = new_statement (st_state, "state", e);
	sblock = statement_subexpr (sblock, e->e.state.frame, &s->opa);
	sblock = statement_subexpr (sblock, e->e.state.think, &s->opb);
	sblock = statement_subexpr (sblock, e->e.state.step, &s->opc);
	sblock_add_statement (sblock, s);
	return sblock;
}

static void
build_bool_block (expr_t *block, expr_t *e)
{
	switch (e->type) {
		case ex_bool:
			build_bool_block (block, e->e.bool.e);
			return;
		case ex_label:
			e->next = 0;
			append_expr (block, e);
			return;
		case ex_assign:
			e->next = 0;
			append_expr (block, e);
			return;
		case ex_branch:
			e->next = 0;
			append_expr (block, e);
			return;
		case ex_expr:
			if (e->e.expr.op == OR || e->e.expr.op == AND) {
				build_bool_block (block, e->e.expr.e1);
				build_bool_block (block, e->e.expr.e2);
			} else {
				e->next = 0;
				append_expr (block, e);
			}
			return;
		case ex_uexpr:
			break;
		case ex_block:
			if (!e->e.block.result) {
				expr_t     *t;
				for (e = e->e.block.head; e; e = t) {
					t = e->next;
					build_bool_block (block, e);
				}
				return;
			}
			break;
		default:
			;
	}
	internal_error (e, "bad boolean");
}

static int
is_goto_expr (expr_t *e)
{
	return e && e->type == ex_branch && e->e.branch.type == pr_branch_jump
			&& !e->e.branch.index;
}

static int
is_if_expr (expr_t *e)
{
	return e && e->type == ex_branch && e->e.branch.type == pr_branch_ne;
}

static int
is_ifnot_expr (expr_t *e)
{
	return e && e->type == ex_branch && e->e.branch.type == pr_branch_eq;
}

static sblock_t *
statement_bool (sblock_t *sblock, expr_t *e)
{
	expr_t    **s;
	expr_t     *l;
	expr_t     *block = new_block_expr ();

	build_bool_block (block, e);

	s = &block->e.block.head;
	while (*s) {
		if (is_if_expr (*s) && is_goto_expr ((*s)->next)) {
			l = (*s)->e.branch.target;
			for (e = (*s)->next->next; e && e->type == ex_label; e = e->next) {
				if (e == l) {
					l->e.label.used--;
					e = *s;
					e->e.branch.type = pr_branch_eq;
					e->e.branch.target = e->next->e.branch.target;
					e->next = e->next->next;
					break;
				}
			}
			s = &(*s)->next;
		} else if (is_ifnot_expr (*s) && is_goto_expr ((*s)->next)) {
			l = (*s)->e.branch.target;
			for (e = (*s)->next->next; e && e->type == ex_label; e = e->next) {
				if (e == l) {
					l->e.label.used--;
					e = *s;
					e->e.branch.type = pr_branch_ne;
					e->e.branch.target = e->next->e.branch.target;
					e->next = e->next->next;
					break;
				}
			}
			s = &(*s)->next;
		} else if (is_goto_expr (*s)) {
			l = (*s)->e.branch.target;
			for (e = (*s)->next; e && e->type == ex_label; e = e->next) {
				if (e == l) {
					l->e.label.used--;
					*s = (*s)->next;
					l = 0;
					break;
				}
			}
			if (l)
				s = &(*s)->next;
		} else {
			s = &(*s)->next;
		}
	}
	sblock = statement_slist (sblock, block->e.block.head);
	return sblock;
}

static sblock_t *
statement_label (sblock_t *sblock, expr_t *e)
{
	if (sblock->statements) {
		sblock->next = new_sblock ();
		sblock = sblock->next;
	}
	if (e->e.label.used) {
		e->e.label.dest = sblock;
		e->e.label.next = sblock->labels;
		sblock->labels = &e->e.label;
	} else {
		if (e->e.label.symbol) {
			warning (e, "unused label %s", e->e.label.symbol->name);
		} else {
			debug (e, "dropping unused label %s", e->e.label.name);
		}
	}
	return sblock;
}

static sblock_t *
statement_block (sblock_t *sblock, expr_t *e)
{
	if (sblock->statements) {
		sblock->next = new_sblock ();
		sblock = sblock->next;
	}
	sblock = statement_slist (sblock, e->e.block.head);
	if (e->e.block.is_call) {
		// for a fuction call, the call expresion is in only the result, not
		// the actual block
		sblock = statement_slist (sblock, e->e.block.result);
	}
	return sblock;
}

static sblock_t *
statement_expr (sblock_t *sblock, expr_t *e)
{
	if (e->e.expr.op < 256)
		debug (e, "e %c", e->e.expr.op);
	else
		debug (e, "e %d", e->e.expr.op);
	if (options.warnings.executable)
		warning (e, "Non-executable statement; executing programmer instead.");
	return sblock;
}

static sblock_t *
statement_uexpr (sblock_t *sblock, expr_t *e)
{
	debug (e, "e ue %d", e->e.expr.op);
	if (options.warnings.executable)
		warning (e, "Non-executable statement; executing programmer instead.");
	return sblock;
}

static sblock_t *
statement_memset (sblock_t *sblock, expr_t *e)
{
	expr_t     *dst = e->e.memset.dst;
	expr_t     *val = e->e.memset.val;
	expr_t     *count = e->e.memset.count;
	const char *opcode = "memset";
	statement_t *s;

	if (is_constant (count)) {
		if (is_int (get_type (count))
			&& (unsigned) expr_int (count) < 0x10000) {
			count = new_short_expr (expr_int (count));
		}
		if (is_uint (get_type (count)) && expr_int (count) < 0x10000) {
			count = new_short_expr (expr_uint (count));
		}
	}
	s = new_statement (st_move, opcode, e);
	sblock = statement_subexpr (sblock, dst, &s->opc);
	sblock = statement_subexpr (sblock, count, &s->opb);
	sblock = statement_subexpr (sblock, val, &s->opa);
	sblock_add_statement (sblock, s);
	return sblock;
}

static sblock_t *
statement_assign (sblock_t *sblock, expr_t *e)
{
	return expr_assign (sblock, e, 0);
}

static sblock_t *
statement_nonexec (sblock_t *sblock, expr_t *e)
{
	if (!e->rvalue && options.warnings.executable)
		warning (e, "Non-executable statement; executing programmer instead.");
	return sblock;
}

static sblock_t *
statement_slist (sblock_t *sblock, expr_t *e)
{
	static statement_f sfuncs[ex_count] = {
		[ex_error] = statement_ignore,
		[ex_state] = statement_state,
		[ex_bool] = statement_bool,
		[ex_label] = statement_label,
		[ex_block] = statement_block,
		[ex_expr] = statement_expr,
		[ex_uexpr] = statement_uexpr,
		[ex_def] = statement_nonexec,
		[ex_symbol] = statement_nonexec,
		[ex_temp] = statement_nonexec,
		[ex_vector] = statement_nonexec,
		[ex_nil] = statement_nonexec,
		[ex_value] = statement_nonexec,
		[ex_memset] = statement_memset,
		[ex_assign] = statement_assign,
		[ex_branch] = statement_branch,
		[ex_return] = statement_return,
		[ex_adjstk] = statement_adjstk,
		[ex_with] = statement_with,
	};

	for (/**/; e; e = e->next) {
		if (e->type >= ex_count || !sfuncs[e->type])
			internal_error (e, "bad expression type");
		sblock = sfuncs[e->type] (sblock, e);
	}
	return sblock;
}

static void
move_labels (sblock_t *dst, sblock_t *src)
{
	ex_label_t *src_labels = src->labels;

	if (!src_labels)
		return;
	src_labels->dest = dst;
	while (src_labels->next) {
		src_labels = src_labels->next;
		src_labels->dest = dst;
	}
	src_labels->next = dst->labels;
	dst->labels = src->labels;
	src->labels = 0;
}

static void
move_code (sblock_t *dst, sblock_t *src)
{
	if (!src->statements)
		return;
	*dst->tail = src->statements;
	dst->tail = src->tail;
	src->statements = 0;
	src->tail = &src->statements;
}

static sblock_t *
merge_blocks (sblock_t *blocks)
{
	sblock_t  **sb;
	sblock_t   *sblock;
	statement_t *s;

	if (!blocks)
		return blocks;
	// merge any blocks that can be merged
	for (sblock = blocks; sblock; sblock = sblock->next) {
		if (sblock->statements && sblock->next) {
			s = (statement_t *) sblock->tail;
			// func and flow statements end blocks
			if (s->type >= st_func)
				continue;
			// labels begin blocks
			if (sblock->next->labels)
				continue;
			// blocks can be merged
			move_code (sblock, sblock->next);
		}
	}
	for (sb = &blocks; (*sb)->next;) {
		if (!(*sb)->statements) {
			// empty non-final block
			// move labels from empty block to next block
			if ((*sb)->labels)
				move_labels ((*sb)->next, (*sb));
			sblock = *sb;
			*sb = (*sb)->next;
			free_sblock (sblock);
			continue;
		}
		sb = &(*sb)->next;
	}
	// so long as blocks doesn't become null, remove an empty final block
	if (sb != &blocks) {
		if (!(*sb)->statements && !(*sb)->labels) {
			// empty final block with no labels
			sblock = *sb;
			*sb = (*sb)->next;
			free_sblock (sblock);
		}
	}
	return blocks;
}

static void
remove_label_from_dest (ex_label_t *label)
{
	sblock_t   *sblock;
	ex_label_t **l;

	if (!label || !label->dest)
		return;

	debug (0, "dropping deceased label %s", label->name);
	sblock = label->dest;
	label->dest = 0;
	for (l = &sblock->labels; *l; l = &(*l)->next) {
		if (*l == label) {
			*l = label->next;
			label->next = 0;
			break;
		}
	}
}

static void
unuse_label (ex_label_t *label)
{
	if (label && !--label->used)
		remove_label_from_dest (label);
}

static int
thread_jumps (sblock_t *blocks)
{
	sblock_t   *sblock;
	int         did_something = 0;

	if (!blocks)
		return 0;
	for (sblock = blocks; sblock; sblock = sblock->next) {
		statement_t *s;
		ex_label_t **label, *l;

		if (!sblock->statements)
			continue;
		s = (statement_t *) sblock->tail;
		if (statement_is_goto (s)) {
			label = &s->opa->label;
			if (!(*label)->dest && (*label)->symbol) {
				error (s->opa->expr, "undefined label `%s'",
					   (*label)->symbol->name);
				(*label)->symbol = 0;
			}
		} else if (statement_is_cond (s)) {
			label = &s->opa->label;
		} else {
			continue;
		}
		for (l = *label;
			 l->dest && l->dest->statements
			 && statement_is_goto (l->dest->statements);
			 l = *statement_get_labelref (l->dest->statements)) {
			// empty loop
		}
		if (l != *label) {
			unuse_label (*label);
			l->used++;
			*label = l;
			did_something = 1;
		}
		if ((statement_is_goto (s) || statement_is_cond (s))
			&& (*label)->dest == sblock->next) {
			statement_t **p;
			unuse_label (*label);
			for (p = &sblock->statements; *p != s; p = &(*p)->next)
				;
			free_statement (s);
			*p = 0;
			sblock->tail = p;
			did_something = 1;
		}
	}
	return did_something;
}

static int
remove_dead_blocks (sblock_t *blocks)
{
	sblock_t   *sblock;
	int         did_something;
	int         did_anything = 0;
	int         pass = 0;

	if (!blocks)
		return 0;

	do {
		debug (0, "dead block pass %d", pass++);
		did_something = 0;
		blocks->reachable = 1;
		for (sblock = blocks; sblock->next; sblock = sblock->next) {
			sblock_t   *sb = sblock->next;
			statement_t *s;

			if (sb->labels) {
				sb->reachable = 1;
				continue;
			}
			if (!sblock->statements) {
				sb->reachable = 1;
				continue;
			}
			s = (statement_t *) sblock->tail;
			if (statement_is_cond (s)
				&& sb->statements && statement_is_goto (sb->statements)
				&& statement_get_target (s) == sb->next) {
				debug (0, "merging if/goto %p %p", sblock, sb);
				ex_label_t **labelref = statement_get_labelref(s);
				unuse_label (*labelref);
				*labelref = *statement_get_labelref (sb->statements);
				(*labelref)->used++;
				invert_conditional (s);
				sb->reachable = 0;
				for (sb = sb->next; sb; sb = sb->next)
					sb->reachable = 1;
				break;
			} else if (!statement_is_goto (s) && !statement_is_return (s)) {
				sb->reachable = 1;
				continue;
			}
			sb->reachable = 0;
		}
		for (sblock = blocks; sblock; sblock = sblock->next) {
			while (sblock->next && !sblock->next->reachable) {
				sblock_t   *sb = sblock->next;
				statement_t *s;
				ex_label_t *label = 0;

				debug (0, "removing dead block %p", sb);

				if (sb->statements) {
					s = (statement_t *) sb->tail;
					ex_label_t **labelref = statement_get_labelref (s);
					label = labelref ? *labelref : 0;
				}
				unuse_label (label);
				did_something = 1;
				did_anything = 1;

				sblock->next = sb->next;
				free_sblock (sb);
			}
		}
	} while (did_something);
	return did_anything;
}

static void
super_dealloc_warning (expr_t *expr, pseudoop_t *op)
{
	warning (expr,
			 "control may reach end of derived -dealloc without invoking %s",
			 op->name);
}

static void
search_for_super_dealloc (sblock_t *sblock)
{
	operand_t  *op;
	pseudoop_t *super_dealloc = new_pseudoop ("[super dealloc]");
	int         super_dealloc_found = 0;
	super_dealloc->next = current_func->pseudo_ops;
	current_func->pseudo_ops = super_dealloc;
	super_dealloc->uninitialized = super_dealloc_warning;
	while (sblock) {
		for (statement_t *st = sblock->statements; st; st = st->next) {
			if (statement_is_return (st)) {
				op = pseudo_operand (super_dealloc, st->expr);
				op->next = st->use;
				st->use = op;
				continue;
			}
			if (!statement_is_call (st)) {
				continue;
			}
			// effectively checks target
			if (st->opa->op_type != op_def
				|| strcmp (st->opa->def->name, "obj_msgSend_super") != 0) {
				continue;
			}
			// function arguments are in reverse order, and the selector
			// is the second argument (or second last in the list)
			expr_t     *arg;
			for (arg = st->expr->e.branch.args;
				 arg && arg->next && arg->next->next; arg = arg->next) {
			}
			if (arg && arg->next && is_selector (arg)) {
				selector_t *sel = get_selector (st->expr->e.branch.args);
				if (sel && strcmp (sel->name, "dealloc") == 0) {
					op = pseudo_operand (super_dealloc, st->expr);
					op->next = st->use;
					st->def = op;
					super_dealloc_found++;
				}
			}
		}
		sblock = sblock->next;
	}
	// warn only when NOT optimizing because flow analysis will catch the
	// missed invokation
	if (!super_dealloc_found && !options.code.optimize) {
		warning (0, "Derived class -dealloc does not call [super dealloc]");
	}
}

static void
check_final_block (sblock_t *sblock)
{
	statement_t *s = 0;

	if (!sblock)
		return;
	while (sblock->next)
		sblock = sblock->next;
	if (sblock->statements) {
		s = (statement_t *) sblock->tail;
		if (statement_is_goto (s))
			return;				// the end of function is the end of a loop
		if (statement_is_return (s))
			return;
	}
	if (!is_void(current_func->sym->type->t.func.type))
		warning (0, "control reaches end of non-void function");
	if (s && s->type >= st_func) {
		// func and flow end blocks, so we need to add a new block to take the
		// return
		sblock->next = new_sblock ();
		sblock = sblock->next;
	}
	s = new_statement (st_func, "return", 0);
	if (options.code.progsversion == PROG_VERSION) {
		s->opa = short_operand (0, 0);
		s->opb = short_operand (0, 0);
		s->opc = short_operand (-1, 0);
	} else {
		if (options.traditional
			|| options.code.progsversion == PROG_ID_VERSION) {
			s->opa = return_operand (&type_void, 0);
		}
	}
	sblock_add_statement (sblock, s);
}

void
dump_dot_sblock (void *data, const char *fname)
{
	print_sblock ((sblock_t *) data, fname);
}

sblock_t *
make_statements (expr_t *e)
{
	sblock_t   *sblock = new_sblock ();
	int         did_something;
	int         pass = 0;
	class_t    *class;

	if (options.block_dot.expr)
		dump_dot ("expr", e, dump_dot_expr);
	statement_slist (sblock, e);
	if (options.block_dot.initial)
		dump_dot ("initial", sblock, dump_dot_sblock);
	do {
		did_something = thread_jumps (sblock);
		if (options.block_dot.thread)
			dump_dot (va (0, "thread-%d", pass), sblock, dump_dot_sblock);
		did_something |= remove_dead_blocks (sblock);
		sblock = merge_blocks (sblock);
		if (options.block_dot.dead)
			dump_dot (va (0, "dead-%d", pass), sblock, dump_dot_sblock);
		pass++;
	} while (did_something);
	check_final_block (sblock);
	if (current_class && (class = extract_class (current_class))) {
		// If the class is a root class, then it is not possible for there
		// to be a call to [super dealloc] so do not check. However, any
		// derived class implementeing -dealloc must call [super dealloc]
		// (or some other deallocator (FIXME: later))
		// FIXME better check for dealloc?
		if (class->super_class && !strcmp (current_func->name, "-dealloc")) {
			search_for_super_dealloc (sblock);
		}
	}
	if (options.block_dot.final)
		dump_dot ("final", sblock, dump_dot_sblock);

	return sblock;
}

static void
count_temp (operand_t *op)
{
	if (!op)
		return;
	if (op->op_type == op_temp) {
		while (op->tempop.alias)
			op = op->tempop.alias;
		op->tempop.users++;
	}
}

void
statements_count_temps (sblock_t *sblock)
{
	statement_t *st;

	while (sblock) {
		for (st = sblock->statements; st; st = st->next) {
			count_temp (st->opa);
			count_temp (st->opb);
			count_temp (st->opc);
		}
		sblock = sblock->next;
	}
}
