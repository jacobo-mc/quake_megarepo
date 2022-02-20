/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// cvar.c -- dynamic variable tracking

#include "cmd.h"
#include "common.h"
#include "console.h"
#include "cvar.h"
#include "shell.h"
#include "zone.h"

#ifdef NQ_HACK
#include "server.h"
#include "quakedef.h"
#include "host.h"
#endif

#ifdef SERVERONLY
#include "qwsvdef.h"
#include "server.h"
#else
#ifdef QW_HACK
#include "quakedef.h"
#include "client.h"
#endif
#endif

#define cvar_entry(ptr) container_of(ptr, struct cvar_s, stree)
DECLARE_STREE_ROOT(cvar_tree);

/*
============
Cvar_FindVar
============
*/
cvar_t *
Cvar_FindVar(const char *var_name)
{
    struct cvar_s *ret = NULL;
    struct stree_node *n;

    n = STree_Find(&cvar_tree, var_name);
    if (n)
	ret = cvar_entry(n);

    return ret;
}

/*
 * Return a string tree with all possible argument completions of the given
 * buffer for the given cvar.
 */
struct stree_root *
Cvar_ArgCompletions(const char *name, const char *buf)
{
    cvar_t *cvar;
    struct stree_root *root = NULL;

    cvar = Cvar_FindVar(name);
    if (cvar && cvar->completion) {
        root = Z_Malloc(mainzone, sizeof(*root));
        if (root) {
            *root = STREE_ROOT;
            STree_AllocInit();
            cvar->completion(root, buf);
        }
    }

    return root;
}

/*
 * Call the argument completion function for cvar "name".
 * Returned result should be Z_Free'd after use.
 */
char *
Cvar_ArgComplete(const char *name, const char *buf)
{
    char *result = NULL;
    struct stree_root *root;

    root = Cvar_ArgCompletions(name, buf);
    if (root) {
	result = STree_MaxMatch(root, buf);
	Z_Free(mainzone, root);
    }

    return result;
}


#ifdef NQ_HACK
/*
 * For NQ/net_dgrm.c, command == CCREQ_RULE_INFO case
 */
cvar_t *
Cvar_NextServerVar(const char *var_name)
{
    cvar_t *ret = NULL;
    cvar_t *var;
    struct stree_node *n;

    if (var_name[0] == '\0')
	var_name = NULL;

    STree_ForEach_After(&cvar_tree, n, var_name) {
	var = cvar_entry(n);
	if (var->server) {
	    ret = var;
	    STree_ForEach_break(&cvar_tree);
	}
    }

    return ret;
}
#endif

/*
============
Cvar_VariableValue
============
*/
float
Cvar_VariableValue(const char *var_name)
{
    cvar_t *var;

    var = Cvar_FindVar(var_name);
    if (!var)
	return 0;
    return Q_atof(var->string);
}


/*
============
Cvar_VariableString
============
*/
const char *
Cvar_VariableString(const char *var_name)
{
    cvar_t *var;

    var = Cvar_FindVar(var_name);

    return var ? var->string : "";
}


/*
============
Cvar_Set
============
*/
void
Cvar_Set(const char *var_name, const char *value)
{
    cvar_t *var;
    qboolean changed = false;

    var = Cvar_FindVar(var_name);
    if (!var) {
	/* there is an error in C code if this happens */
	Con_Printf("Cvar_Set: variable %s not found\n", var_name);
	return;
    }

    if (var->flags & CVAR_OBSOLETE) {
	Con_Printf("%s is obsolete.\n", var_name);
	return;
    }

    if (var->string) {
	changed = strcmp(var->string, value);

	/* Check for developer-only cvar */
	if (changed && (var->flags & CVAR_DEVELOPER) && !developer.value) {
	    Con_Printf("%s is settable only in developer mode.\n", var_name);
	    return;
	}

#ifdef SERVERONLY
	if (var->info) {
	    Info_SetValueForKey(svs.info, var_name, value, MAX_SERVERINFO_STRING);
	    SV_SendServerInfoChange(var_name, value);
	}
#else
#ifdef QW_HACK
	if (var->info) {
	    Info_SetValueForKey(cls.userinfo, var_name, value, MAX_INFO_STRING);
	    if (cls.state >= ca_connected) {
		MSG_WriteByte(&cls.netchan.message, clc_stringcmd);
		MSG_WriteStringf(&cls.netchan.message, "setinfo \"%s\" \"%s\"\n",
				 var_name, value);
	    }
	}
#endif
#endif

	Z_Free(mainzone, var->string);
    }

    var->string = Z_StrDup(mainzone, value);
    var->value = Q_atof(var->string);

#ifdef NQ_HACK
    if (var->server && changed) {
	if (sv.active)
	    SV_BroadcastPrintf("\"%s\" changed to \"%s\"\n", var->name,
			       var->string);
    }
#endif

    if (changed && var->callback)
	var->callback(var);

#ifdef NQ_HACK
    // Don't allow deathmatch and coop at the same time...
    if ((var->value != 0) && (!strcmp(var->name, deathmatch.name)))
	Cvar_Set("coop", "0");
    if ((var->value != 0) && (!strcmp(var->name, coop.name)))
	Cvar_Set("deathmatch", "0");
#endif
}

/*
============
Cvar_SetValue
============
*/
void
Cvar_SetValue(const char *var_name, float value)
{
    char val[32];

    qsnprintf(val, sizeof(val), "%f", value);
    Cvar_Set(var_name, val);
}


/*
============
Cvar_RegisterVariable

Adds a freestanding variable to the variable list.
============
*/
void
Cvar_RegisterVariable(cvar_t *variable)
{
    const char *initial_string;
    float old_developer;

    /* first check to see if it has already been defined */
    if (Cvar_FindVar(variable->name)) {
	Con_Printf("Can't register variable %s, already defined\n",
		   variable->name);
	return;
    }
    /* check for overlap with a command */
    if (Cmd_Exists(variable->name)) {
	Con_Printf("Cvar_RegisterVariable: %s is a command\n",
		   variable->name);
	return;
    }

    variable->stree.string = variable->name;
    STree_Insert(&cvar_tree, &variable->stree);

    /*
     * FIXME (BARF) - readonly cvars need to be initialised
     *                developer 1 allows set
     */
    /* set it through the function to be consistant */
    old_developer = developer.value;
    developer.value = 1;

    /* The string will be Z_Free/Zalloc'd, so zero the pointer first */
    initial_string = variable->string;
    variable->string = NULL;
    Cvar_Set(variable->name, initial_string);

    developer.value = old_developer;
}

/*
============
Cvar_Command

Handles variable inspection and changing from the console
============
*/
qboolean
Cvar_Command(void)
{
    cvar_t *v;

// check variables
    v = Cvar_FindVar(Cmd_Argv(0));
    if (!v)
	return false;

// perform a variable print or set
    if (Cmd_Argc() == 1) {
	if (v->flags & CVAR_OBSOLETE)
	    Con_Printf("%s is obsolete.\n", v->name);
	else
	    Con_Printf("\"%s\" is \"%s\"\n", v->name, v->string);
	return true;
    }

    Cvar_Set(v->name, Cmd_Argv(1));
    return true;
}


/*
============
Cvar_WriteVariables

Writes lines containing "set variable value" for all variables
with the given flags set.
============
*/
void
Cvar_WriteVariables(FILE *f, uint32_t flags)
{
    cvar_t *var;
    struct stree_node *n;

    STree_ForEach(&cvar_tree, n) {
	var = cvar_entry(n);
	if (var->flags & flags)
	    fprintf(f, "%s \"%s\"\n", var->name, var->string);
    }
}
