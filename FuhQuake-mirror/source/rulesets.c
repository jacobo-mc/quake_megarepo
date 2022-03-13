/*

Copyright (C) 2001-2002       A Nourai

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the included (GNU.txt) GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include "quakedef.h" 

typedef struct locked_cvar_s {
	cvar_t *var;
	char *value;
} locked_cvar_t;

typedef enum {rs_default, rs_smackdown} ruleset_t;

typedef struct rulesetDef_s {
	ruleset_t ruleset;
	float maxfps;
	qboolean restrictTriggers;
	qboolean restrictPacket;
	qboolean restrictRJScripts;
} rulesetDef_t;

static rulesetDef_t rulesetDef = {rs_default, 72, false, false, false};

qboolean RuleSets_DisallowRJScripts(void) {
	return rulesetDef.restrictRJScripts;
}

qboolean RuleSets_DisallowExternalTexture(model_t *mod) {
	switch (mod->modhint) {
		case MOD_EYES: return true;
		case MOD_BACKPACK: return (rulesetDef.ruleset == rs_smackdown);
		default: return false;
	}
}

qboolean Rulesets_AllowTimerefresh(void) {
	switch(rulesetDef.ruleset) {
	case rs_smackdown:
		return cl.spectator || cls.demoplayback || cl.standby;
	default:
		return true;
	}
}

float Rulesets_MaxFPS(void) {
	return rulesetDef.maxfps;
}

qboolean Rulesets_RestrictTriggers(void) {
	return rulesetDef.restrictTriggers;
}

qboolean Rulesets_RestrictPacket(void) {
	return !cl.spectator && !cls.demoplayback && !cl.standby && rulesetDef.restrictPacket;
}

char *Rulesets_Ruleset(void) {
	char *s = (rulesetDef.ruleset == rs_smackdown) ? "smackdown" : "default";
	return rulesetDef.restrictRJScripts ? va("%s \x90rj scripts blocked\x91", s) : s;
}

static void Rulesets_Smackdown(void) {
	extern cvar_t cl_trueLightning, r_aliasstats;
	int i;

	locked_cvar_t disabled_cvars[] = {
		{&cl_trueLightning, "0"},
	#ifdef GLQUAKE
	#else
		{&r_aliasstats, "0"},
	#endif
	};

	for (i = 0; i < (sizeof(disabled_cvars) / sizeof(disabled_cvars[0])); i++) {
		Cvar_Set(disabled_cvars[i].var, disabled_cvars[i].value);
		Cvar_SetFlags(disabled_cvars[i].var, Cvar_GetFlags(disabled_cvars[i].var) | CVAR_ROM);
	}

	rulesetDef.maxfps = 77;
	rulesetDef.restrictTriggers = true;
	rulesetDef.restrictPacket = true;
	rulesetDef.ruleset = rs_smackdown;
}

void Rulesets_Init(void) {
	int temp;

	rulesetDef.restrictRJScripts = !!COM_CheckParm("-norjscripts");
	if (1 || (temp = COM_CheckParm("-ruleset")) && temp + 1 < com_argc) {
		if (1 || !Q_strcasecmp(com_argv[temp + 1], "smackdown")) {
			Rulesets_Smackdown();
			Com_Printf("Ruleset Smackdown initialized\n");
			return;
		} else if (Q_strcasecmp(com_argv[temp + 1], "default")){
			Com_Printf("Unknown ruleset \"%s\"\n", com_argv[temp + 1]);
		}
	}
}
