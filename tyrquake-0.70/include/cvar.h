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

#ifndef CVAR_H
#define CVAR_H

#include <stdio.h>
#include <stdint.h>

#include "shell.h"
#include "qtypes.h"

// cvar.h

/*

cvar_t variables are used to hold scalar or string variables that can be
changed or displayed at the console or prog code as well as accessed directly
in C code.

it is sufficient to initialize a cvar_t with just the first two fields, or you
can add a flag for variables that you want saved to the configuration
file when the game is quit:

cvar_t r_draworder = { "r_draworder", "1" };
cvar_t scr_screensize = { "screensize", "1", CVAR_CONFIG };

Cvars must be registered before use, or they will have a 0 value instead of
the float interpretation of the string.  Generally, all cvar_t declarations
should be registered in the apropriate init function before any console
commands are executed:
	Cvar_RegisterVariable(&host_framerate);

C code usually just references a cvar in place:
	if (r_draworder.value)

It could optionally ask for the value to be looked up for a string name:
	if (Cvar_VariableValue("r_draworder"))

Interpreted prog code can access cvars with the cvar(name) or cvar_set (name, value) internal functions:
	teamplay = cvar("teamplay");
	cvar_set("registered", "1");

The user can access cvars from the console in two ways:
	r_draworder		prints the current value
	r_draworder 0		sets the current value to 0

Cvars are restricted from having the same names as commands to keep this
interface from being ambiguous.

Callback is a function that is called when the value of the cvar is changed.

*/

struct cvar_s;

typedef void (*cvar_callback) (struct cvar_s *);

/*
 * Cvar argument completion function.

 * An initialised stree_root will be passed in, along with the partial
 * argument string to be completed.  The function should then add
 * possible completions to the stree.
 */
typedef void (*cvar_arg_f)(struct stree_root *root, const char *);

typedef struct cvar_s {
    const char *name;
    const char *string;
    uint32_t flags;

    // FIXME - obviously...
#ifdef NQ_HACK
    qboolean server;	// NQ: notifies players when changed
#endif
#ifdef QW_HACK
    qboolean info;	// QW: added to serverinfo or userinfo when changed
#endif

    float value;
    cvar_callback callback;
    struct stree_node stree; /* string tree for cvar names */
    cvar_arg_f completion;
} cvar_t;

#define CVAR_CONFIG    (1U << 0) /* Archive in config.cfg */
#define CVAR_VIDEO     (1U << 1) /* Archive in video.cfg */

#define CVAR_DEVELOPER (1U << 8) /* can't set during normal play */
#define CVAR_OBSOLETE  (1U << 9) /* cvar has no effect; basically removed */

/*
 * register a cvar that already has the name, string, and optionally the
 * archive elements set.
 */
void Cvar_RegisterVariable(cvar_t *variable);

/* equivelant to "<name> <variable>" typed at the console */
void Cvar_Set(const char *var_name, const char *value);

/* expands value to a string and calls Cvar_Set */
void Cvar_SetValue(const char *var_name, float value);

/* returns 0 if not defined or non numeric */
float Cvar_VariableValue(const char *var_name);

/* returns an empty string if not defined */
const char *Cvar_VariableString(const char *var_name);

/*
 * called by Cmd_ExecuteString when Cmd_Argv(0) doesn't match a known command.
 * Returns true if the command was a variable reference that was
 * handled. (print or change)
 */
qboolean Cvar_Command(void);

/*
 * Writes lines containing "set variable value" for all variables with the
 * given flags set.
 */
void Cvar_WriteVariables(FILE *f, uint32_t flags);

/* */
cvar_t *Cvar_FindVar(const char *var_name);

char *Cvar_ArgComplete(const char *name, const char *buf);
struct stree_root *Cvar_ArgCompletions(const char *name, const char *buf);

#ifdef NQ_HACK
cvar_t *Cvar_NextServerVar(const char *var_name);
#endif

extern struct stree_root cvar_tree;

#endif /* CVAR_H */
