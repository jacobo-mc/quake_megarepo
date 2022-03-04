/*
	bi_mersenne.c

	Ruamoko Mersenne Twister api

	Copyright (C) 2021 Bill Currie

	Author: Bill Currie <bill@taniwha.org>
	Date: 2021/12/21

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

#include "QF/mersenne.h"
#include "QF/progs.h"

#include "rua_internal.h"

typedef struct {
	//FIXME each mtstate_t is 2500 bytes and the map has 1024 elements
	//per row, so having only one mtstate_t has an overhead of about 2.5MB
	PR_RESMAP (mtstate_t) state_map;
} mtwist_resources_t;

static mtstate_t *
state_new (mtwist_resources_t *res)
{
	return PR_RESNEW (res->state_map);
}

static void
state_free (mtwist_resources_t *res, mtstate_t *state)
{
	PR_RESFREE (res->state_map, state);
}

static void
state_reset (mtwist_resources_t *res)
{
	PR_RESRESET (res->state_map);
}

static inline mtstate_t *
state_get (mtwist_resources_t *res, int index)
{
	return PR_RESGET(res->state_map, index);
}

static inline int __attribute__((pure))
state_index (mtwist_resources_t *res, mtstate_t *state)
{
	return PR_RESINDEX(res->state_map, state);
}

static void
bi_mtwist_new (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = (mtwist_resources_t *) _res;
	mtstate_t  *mt = state_new (res);
	mtwist_seed (mt, P_INT (pr, 0));
	R_INT (pr) = state_index (res, mt);
}

static mtstate_t * __attribute__((pure))
get_state (progs_t *pr, mtwist_resources_t *res, const char *name, int index)
{
	mtstate_t *mt = state_get (res, index);

	if (!mt)
		PR_RunError (pr, "invalid Mersenne Twister state index passed to %s",
					 name + 3);
	return mt;
}

static void
bi_mtwist_delete (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = _res;
	mtstate_t  *mt = get_state (pr, res, __FUNCTION__, P_INT (pr, 0));
	state_free (res, mt);
}

static void
bi_mtwist_seed (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = _res;
	mtstate_t  *mt = get_state (pr, res, __FUNCTION__, P_INT (pr, 0));
	mtwist_seed (mt, P_INT (pr, 1));
}

static void
bi_mtwist_rand (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = _res;
	mtstate_t  *mt = get_state (pr, res, __FUNCTION__, P_INT (pr, 0));
	R_INT (pr) = mtwist_rand (mt);
}

static void
bi_mtwist_rand_0_1 (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = _res;
	mtstate_t  *mt = get_state (pr, res, __FUNCTION__, P_INT (pr, 0));
	R_FLOAT (pr) = mtwist_rand_0_1 (mt);
}

static void
bi_mtwist_rand_m1_1 (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = _res;
	mtstate_t  *mt = get_state (pr, res, __FUNCTION__, P_INT (pr, 0));
	R_FLOAT (pr) = mtwist_rand_m1_1 (mt);
}

static void
bi_mtwist_clear (progs_t *pr, void *_res)
{
	mtwist_resources_t *res = (mtwist_resources_t *) _res;
	state_reset (res);
}

#define bi(x,np,params...) {#x, bi_##x, -1, np, {params}}
#define p(type) PR_PARAM(type)
static builtin_t builtins[] = {
	bi(mtwist_new,       1, p(int)),
	bi(mtwist_delete,    1, p(ptr)),
	bi(mtwist_seed,      2, p(ptr), p(int)),
	bi(mtwist_rand,      1, p(ptr)),
	bi(mtwist_rand_0_1,  1, p(ptr)),
	bi(mtwist_rand_m1_1, 1, p(ptr)),
	{0}
};

void
RUA_Mersenne_Init (progs_t *pr, int secure)
{
	mtwist_resources_t *res = calloc (1, sizeof (mtwist_resources_t));

	PR_Resources_Register (pr, "Mersenne Twister", res, bi_mtwist_clear);
	PR_RegisterBuiltins (pr, builtins, res);
}
