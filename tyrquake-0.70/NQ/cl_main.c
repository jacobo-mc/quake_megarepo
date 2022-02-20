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
// cl_main.c  -- client main loop

#include "client.h"
#include "cmd.h"
#include "console.h"
#include "cvar.h"
#include "host.h"
#include "input.h"
#include "model.h"
#include "net.h"
#include "protocol.h"
#include "quakedef.h"
#include "render.h"
#include "screen.h"
#include "server.h"
#include "sound.h"

// we need to declare some mouse variables here, because the menu system
// references them even when on a unix system.

// these two are not intended to be set directly
cvar_t cl_name = { "_cl_name", "player", CVAR_CONFIG };
cvar_t cl_color = { "_cl_color", "0", CVAR_CONFIG };

cvar_t cl_shownet = { "cl_shownet", "0" };	// can be 0, 1, or 2
cvar_t cl_nolerp = { "cl_nolerp", "0" };

cvar_t lookspring = { "lookspring", "0", CVAR_CONFIG };
cvar_t lookstrafe = { "lookstrafe", "0", CVAR_CONFIG };
cvar_t sensitivity = { "sensitivity", "3", CVAR_CONFIG };

cvar_t m_pitch = { "m_pitch", "0.022", CVAR_CONFIG };
cvar_t m_yaw = { "m_yaw", "0.022", CVAR_CONFIG };
cvar_t m_forward = { "m_forward", "1", CVAR_CONFIG };
cvar_t m_side = { "m_side", "0.8", CVAR_CONFIG };

cvar_t cl_maxpitch = {"cl_maxpitch", "90", CVAR_CONFIG };
cvar_t cl_minpitch = {"cl_minpitch", "-90", CVAR_CONFIG };

cvar_t m_freelook = { "m_freelook", "0", CVAR_CONFIG };

client_static_t cls;
client_state_t cl;

// FIXME: put these on hunk?
efrag_t cl_efrags[MAX_EFRAGS];
entity_t cl_entities[MAX_EDICTS];
entity_t cl_static_entities[MAX_STATIC_ENTITIES];
lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES];
dlight_t cl_dlights[MAX_DLIGHTS];

int cl_numvisedicts;
entity_t *cl_visedicts[MAX_VISEDICTS];
int cl_visedicts_framenum;

/*
 * FIXME - horribly hackish because we don't have a way to tell if the
 *         entity is a player just by looking at it's properties/pointer.
 *
 * CL_PlayerEntity()
 * Returns the player number if the entity is a player, 0 otherwise
 */
int
CL_PlayerEntity(const entity_t *e)
{
    ptrdiff_t offset;
    int i;

    /* might be a pointer directly into cl_entities... */
    offset =  e - cl_entities;
    if (offset >= 1 && offset <= cl.maxclients)
	return offset;

    /* ...but if not, try to find a match */
    for (i = 1; i <= cl.maxclients; i++) {
	/* Compare just the top of the struct, up to the lerp info */
	if (!memcmp(e, &cl_entities[i], offsetof(entity_t, lerp)))
	    return i;
    }

    return 0;
}

/*
=====================
CL_ClearState

=====================
*/
void
CL_ClearState(void)
{
    int i;

    if (!sv.active)
	Host_ClearMemory();

    CL_ClearTEnts();

// wipe the entire cl structure
    memset(&cl, 0, sizeof(cl));

    SZ_Clear(&cls.message);

// clear other arrays
    memset(cl_efrags, 0, sizeof(cl_efrags));
    memset(cl_entities, 0, sizeof(cl_entities));
    memset(cl_dlights, 0, sizeof(cl_dlights));
    memset(cl_lightstyle, 0, sizeof(cl_lightstyle));

//
// allocate the efrags and chain together into a free list
//
    cl.free_efrags = cl_efrags;
    for (i = 0; i < MAX_EFRAGS - 1; i++)
	cl.free_efrags[i].entnext = &cl.free_efrags[i + 1];
    cl.free_efrags[i].entnext = NULL;
}

/*
=====================
CL_Disconnect

Sends a disconnect message to the server
This is also called on Host_Error, so it shouldn't cause any errors
=====================
*/
void
CL_Disconnect(void)
{
    int i;

// stop sounds (especially looping!)
    BGM_Stop();
    S_StopAllSounds(true);

    /* Clear up view, remove palette shift */
    scr_centertime_off = 0;
    for (i = 0; i < NUM_CSHIFTS; i++)
        cl.cshifts[i].percent = 0;
    if (cls.state != ca_dedicated)
        VID_SetPalette(host_basepal);

// if running a local server, shut it down
    if (cls.demoplayback)
	CL_StopPlayback();
    else if (cls.state >= ca_connected) {
	if (cls.demorecording)
	    CL_Stop_f();

	Con_DPrintf("Sending clc_disconnect\n");
	SZ_Clear(&cls.message);
	MSG_WriteByte(&cls.message, clc_disconnect);
	NET_SendUnreliableMessage(cls.netcon, &cls.message);
	SZ_Clear(&cls.message);
	NET_Close(cls.netcon);

	cls.state = ca_disconnected;
	if (sv.active)
	    Host_ShutdownServer(false);
    }

    cls.demoplayback = false;
    cls.timedemo = false;
    cls.signon = 0;
    cl.intermission = 0; /* FIXME - for SCR_UpdateScreen */

    /* In case we failed to load the requested level */
    SCR_EndLoadingPlaque();
}

void
CL_Disconnect_f(void)
{
    CL_Disconnect();
    if (sv.active)
	Host_ShutdownServer(false);
}




/*
=====================
CL_EstablishConnection

Host should be either "local" or a net address to be passed on
=====================
*/
void
CL_EstablishConnection(const char *host)
{
    if (cls.state == ca_dedicated)
	return;
    if (cls.demoplayback)
	return;

    CL_Disconnect();

    cls.netcon = NET_Connect(host);
    if (!cls.netcon)
	Host_Error("CL_Connect: connect failed");

    Con_DPrintf("CL_EstablishConnection: connected to %s\n", host);

    cls.demonum = -1;		// not in the demo loop now
    cls.state = ca_connected;
    cls.signon = 0;		// need all the signon messages before playing
}

/*
=====================
CL_SignonReply

An svc_signonnum has been received, perform a client side setup
=====================
*/
void
CL_SignonReply(void)
{
    Con_DPrintf("CL_SignonReply: %i\n", cls.signon);

    switch (cls.signon) {
    case 1:
	MSG_WriteByte(&cls.message, clc_stringcmd);
	MSG_WriteString(&cls.message, "prespawn");
	break;

    case 2:
	MSG_WriteByte(&cls.message, clc_stringcmd);
	MSG_WriteStringf(&cls.message, "name \"%s\"\n", cl_name.string);

	MSG_WriteByte(&cls.message, clc_stringcmd);
	MSG_WriteStringf(&cls.message, "color %i %i\n",
			 ((int)cl_color.value) >> 4,
			 ((int)cl_color.value) & 15);

	MSG_WriteByte(&cls.message, clc_stringcmd);
	MSG_WriteStringf(&cls.message, "spawn %s", cls.spawnparms);
	break;

    case 3:
	MSG_WriteByte(&cls.message, clc_stringcmd);
	MSG_WriteString(&cls.message, "begin");
	Cache_Report();		// print remaining memory

	// FIXME - this the right place for it?
	cls.state = ca_firstupdate;
	break;

    case 4:
	SCR_EndLoadingPlaque();	// allow normal screen updates

	// FIXME - this the right place for it?
	cls.state = ca_active;
	break;
    }
}

/*
=====================
CL_NextDemo

Called to play the next demo in the demo loop
=====================
*/
void
CL_NextDemo(void)
{
    char str[1024];

    if (cls.demonum == -1)
	return;			// don't play demos

    SCR_BeginLoadingPlaque();
    CL_Disconnect();

    if (!cls.demos[cls.demonum][0] || cls.demonum == MAX_DEMOS) {
	cls.demonum = 0;
	if (!cls.demos[cls.demonum][0]) {
	    Con_Printf("No demos listed with startdemos\n");
	    cls.demonum = -1;
	    return;
	}
    }

    qsnprintf(str, sizeof(str), "playdemo %s\n", cls.demos[cls.demonum]);
    Cbuf_InsertText(str);
    cls.demonum++;
}

/*
==============
CL_PrintEntities_f
==============
*/
void
CL_PrintEntities_f(void)
{
    const entity_t *ent;
    int i;

    for (i = 0, ent = cl_entities; i < cl.num_entities; i++, ent++) {
	Con_Printf("%3i:", i);
	if (!ent->model) {
	    Con_Printf("EMPTY\n");
	    continue;
	}
	Con_Printf("%s:%2i  (%5.1f,%5.1f,%5.1f) [%5.1f %5.1f %5.1f]\n",
		   ent->model->name, ent->frame, ent->origin[0],
		   ent->origin[1], ent->origin[2], ent->angles[0],
		   ent->angles[1], ent->angles[2]);
    }
}

void
CL_Name_f(void)
{
    char new_name[16];
    const char *arg;

    if (Cmd_Argc() == 1) {
	Con_Printf("\"name\" is \"%s\"\n", cl_name.string);
	return;
    }
    arg = (Cmd_Argc() == 2) ? Cmd_Argv(1) : Cmd_Args();
    qsnprintf(new_name, sizeof(new_name), "%s", arg);
    if (!strcmp(cl_name.string, new_name))
	return;

    Cvar_Set("_cl_name", new_name);
    Cmd_ForwardToServer();
}

/*
==================
CL_Color_f
==================
*/
static void
CL_Color_f(void)
{
    int top, bottom;

    if (Cmd_Argc() == 1) {
	top = (int)cl_color.value >> 4;
	bottom = (int)cl_color.value & 15;
	Con_Printf("\"color\" is \"%i %i\"\n"
		   "color <0-13> [0-13]\n", top, bottom);
	return;
    }

    if (Cmd_Argc() == 2)
	top = bottom = atoi(Cmd_Argv(1)) & 15;
    else {
	top = atoi(Cmd_Argv(1)) & 15;
	bottom = atoi(Cmd_Argv(2)) & 15;
    }
    if (top > 13)
	top = 13;
    if (bottom > 13)
	bottom = 13;

    Cvar_SetValue("_cl_color", top * 16 + bottom);
    if (cls.state >= ca_connected)
	Cmd_ForwardToServer();
}

/*
===============
SetPal

Debugging tool, just flashes the screen
===============
*/
void
SetPal(int i)
{
#if 0
    static int old;
    byte pal[768];
    int c;

    if (i == old)
	return;
    old = i;

    if (i == 0)
	VID_SetPalette(host_basepal);
    else if (i == 1) {
	for (c = 0; c < 768; c += 3) {
	    pal[c] = 0;
	    pal[c + 1] = 255;
	    pal[c + 2] = 0;
	}
	VID_SetPalette(pal);
    } else {
	for (c = 0; c < 768; c += 3) {
	    pal[c] = 0;
	    pal[c + 1] = 0;
	    pal[c + 2] = 255;
	}
	VID_SetPalette(pal);
    }
#endif
}

const float dl_colors[4][4] = {
    { 0.2, 0.1, 0.05, 0.7 },	/* FLASH */
    { 0.05, 0.05, 0.3, 0.7 },	/* BLUE */
    { 0.5, 0.05, 0.05, 0.7 },	/* RED */
    { 0.5, 0.05, 0.4, 0.7 }	/* PURPLE */
};

/*
===============
CL_AllocDlight

===============
*/
dlight_t *
CL_AllocDlight(int key)
{
    int i;
    dlight_t *dl;

// first look for an exact key match
    if (key) {
	dl = cl_dlights;
	for (i = 0; i < MAX_DLIGHTS; i++, dl++) {
	    if (dl->key == key) {
		memset(dl, 0, sizeof(*dl));
		dl->color = dl_colors[DLIGHT_FLASH];
		dl->key = key;
		return dl;
	    }
	}
    }
// then look for anything else
    dl = cl_dlights;
    for (i = 0; i < MAX_DLIGHTS; i++, dl++) {
	if (dl->die < cl.time) {
	    memset(dl, 0, sizeof(*dl));
	    dl->color = dl_colors[DLIGHT_FLASH];
	    dl->key = key;
	    return dl;
	}
    }

    dl = &cl_dlights[0];
    memset(dl, 0, sizeof(*dl));
    dl->color = dl_colors[DLIGHT_FLASH];
    dl->key = key;
    return dl;
}


/*
===============
CL_DecayLights

===============
*/
void
CL_DecayLights(void)
{
    int i;
    dlight_t *dl;
    float time;

    time = cl.time - cl.oldtime;

    dl = cl_dlights;
    for (i = 0; i < MAX_DLIGHTS; i++, dl++) {
	if (dl->die < cl.time || !dl->radius)
	    continue;

	dl->radius -= time * dl->decay;
	if (dl->radius < 0)
	    dl->radius = 0;
    }
}


/*
===============
CL_LerpPoint

Determines the fraction between the last two messages that the objects
should be put at.
===============
*/
float
CL_LerpPoint(void)
{
    float f, frac;

    f = cl.mtime[0] - cl.mtime[1];

    if (!f || cl_nolerp.value || cls.timedemo || sv.active) {
	cl.time = cl.mtime[0];
	return 1;
    }

    if (f > 0.1) {		// dropped packet, or start of demo
	cl.mtime[1] = cl.mtime[0] - 0.1;
	f = 0.1;
    }
    frac = (cl.time - cl.mtime[1]) / f;
//Con_Printf ("frac: %f\n",frac);
    if (frac < 0) {
	if (frac < -0.01) {
	    SetPal(1);
	    cl.time = cl.mtime[1];
//                              Con_Printf ("low frac\n");
	}
	frac = 0;
    } else if (frac > 1) {
	if (frac > 1.01) {
	    SetPal(2);
	    cl.time = cl.mtime[0];
//                              Con_Printf ("high frac\n");
	}
	frac = 1;
    } else
	SetPal(0);

    return frac;
}


/*
===============
CL_RelinkEntities
===============
*/
void
CL_RelinkEntities(void)
{
    entity_t *ent;
    int i, j;
    float frac, lerpfrac, angledelta;
    vec3_t delta;
    float bobjrotate;
    vec3_t oldorg;
    dlight_t *dl;

// determine partial update time
    frac = CL_LerpPoint();

    /* Record the frame number at which we last updated the visedicts */
    cl_visedicts_framenum++;

    cl_numvisedicts = 0;

//
// interpolate player info
//
    for (i = 0; i < 3; i++)
	cl.velocity[i] = cl.mvelocity[1][i] +
	    frac * (cl.mvelocity[0][i] - cl.mvelocity[1][i]);

    if (cls.demoplayback) {
	// interpolate the angles
	for (j = 0; j < 3; j++) {
	    angledelta = cl.mviewangles[0][j] - cl.mviewangles[1][j];
	    if (angledelta >= 180)
		angledelta -= 360;
	    else if (angledelta < -180)
		angledelta += 360;
	    cl.viewangles[j] = cl.mviewangles[1][j] + frac * angledelta;
	}
    }

    bobjrotate = anglemod(100 * cl.time);

// start on the entity after the world
    for (i = 1, ent = cl_entities + 1; i < cl.num_entities; i++, ent++) {
	if (!ent->model) {	// empty slot
	    if (ent->forcelink)
		R_RemoveEfrags(ent);	// just became empty
	    continue;
	}

        /* if the object wasn't included in the last packet, remove it */
	if (ent->msgtime != cl.mtime[0]) {
	    ent->model = NULL;
            ent->lerp.flags |= LERP_RESETMOVE | LERP_RESETANIM;
	    continue;
	}

	VectorCopy(ent->origin, oldorg);

	if (ent->forcelink) {
	    /*
	     * the entity was not updated in the last message
	     * so move to the final spot
	     */
	    VectorCopy(ent->msg_origins[0], ent->origin);
	    VectorCopy(ent->msg_angles[0], ent->angles);
	} else {
	    lerpfrac = frac;
	    for (j = 0; j < 3; j++) {
		delta[j] = ent->msg_origins[0][j] - ent->msg_origins[1][j];
		if (delta[j] > 100 || delta[j] < -100) {
		    lerpfrac = 1; /* assume a teleport and don't lerp */
                    ent->lerp.flags |= LERP_RESETMOVE;
                }
	    }
            /* Don't cl_lerp entities that will r_lerped */
            if (r_lerpmove.value && (ent->lerp.flags & LERP_MOVESTEP))
                lerpfrac = 1;

	    /*
	     * interpolate the origin and angles
	     */
	    for (j = 0; j < 3; j++) {
		ent->origin[j] = ent->msg_origins[1][j] + lerpfrac * delta[j];
		angledelta = ent->msg_angles[0][j] - ent->msg_angles[1][j];
		if (angledelta >= 180)
		    angledelta -= 360;
		else if (angledelta < -180)
		    angledelta += 360;
		ent->angles[j] = ent->msg_angles[1][j] + lerpfrac * angledelta;
	    }
	}

// rotate binary objects locally
	if (ent->model->flags & MOD_EF_ROTATE)
	    ent->angles[1] = bobjrotate;

	/*
	 * FIXME - Some of these entity effects may be mutually exclusive?
	 * work out which bits can be done better (e.g. I've already done the
	 * RED|BLUE bit a little better...)
	 */
	if (ent->effects & ENT_EF_BRIGHTFIELD)
	    R_EntityParticles(ent);
	if (ent->effects & ENT_EF_MUZZLEFLASH) {
	    vec3_t fv, rv, uv;

	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->origin[2] += 16;
	    AngleVectors(ent->angles, fv, rv, uv);

	    VectorMA(dl->origin, 18, fv, dl->origin);
	    dl->radius = 200 + (rand() & 31);
	    dl->minlight = 32;
	    dl->die = cl.time + 0.1;
	    dl->color = dl_colors[DLIGHT_FLASH];

            /*
             * Assume muzzle flash is accompanied by muzzle flare,
             * which looks bad when lerped.  Disable lerping for two
             * frames.
             */
            if (r_lerpmodels.value != 2) {
                if (ent == &cl_entities[cl.viewentity])
                    cl.viewent.lerp.flags |= LERP_RESETANIM | LERP_RESETANIM2;
                else
                    ent->lerp.flags |= LERP_RESETANIM | LERP_RESETANIM2;
            }
	}
	if (ent->effects & ENT_EF_BRIGHTLIGHT) {
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->origin[2] += 16;
	    dl->radius = 400 + (rand() & 31);
	    dl->die = cl.time + 0.001;
	    dl->color = dl_colors[DLIGHT_FLASH];
	}
	if (ent->effects & ENT_EF_DIMLIGHT) {
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->radius = 200 + (rand() & 31);
	    dl->die = cl.time + 0.001;
	    dl->color = dl_colors[DLIGHT_FLASH];
	}
	if ((ent->effects & (ENT_EF_RED | ENT_EF_BLUE)) == (ENT_EF_RED | ENT_EF_BLUE)) {
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->radius = 200 + (rand() & 31);
	    dl->die = cl.time + 0.001;
	    dl->color = dl_colors[DLIGHT_PURPLE];
	} else if (ent->effects & ENT_EF_BLUE) {
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->radius = 200 + (rand() & 31);
	    dl->die = cl.time + 0.001;
	    dl->color = dl_colors[DLIGHT_BLUE];
	} else if (ent->effects & ENT_EF_RED) {
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->radius = 200 + (rand() & 31);
	    dl->die = cl.time + 0.001;
	    dl->color = dl_colors[DLIGHT_RED];
	}

	if (ent->model->flags & MOD_EF_GIB)
	    R_RocketTrail(oldorg, ent->origin, 2);
	else if (ent->model->flags & MOD_EF_ZOMGIB)
	    R_RocketTrail(oldorg, ent->origin, 4);
	else if (ent->model->flags & MOD_EF_TRACER)
	    R_RocketTrail(oldorg, ent->origin, 3);
	else if (ent->model->flags & MOD_EF_TRACER2)
	    R_RocketTrail(oldorg, ent->origin, 5);
	else if (ent->model->flags & MOD_EF_ROCKET) {
	    R_RocketTrail(oldorg, ent->origin, 0);
	    dl = CL_AllocDlight(i);
	    VectorCopy(ent->origin, dl->origin);
	    dl->radius = 200;
	    dl->die = cl.time + 0.01;
	} else if (ent->model->flags & MOD_EF_GRENADE)
	    R_RocketTrail(oldorg, ent->origin, 1);
	else if (ent->model->flags & MOD_EF_TRACER3)
	    R_RocketTrail(oldorg, ent->origin, 6);

	ent->forcelink = false;

	if (i == cl.viewentity && !chase_active.value)
	    continue;

	if (cl_numvisedicts < MAX_VISEDICTS) {
	    cl_visedicts[cl_numvisedicts] = ent;
	    cl_numvisedicts++;
	}
    }
}


/*
===============
CL_ReadFromServer

Read all incoming data from the server
===============
*/
int
CL_ReadFromServer(void)
{
    int ret;

    cl.oldtime = cl.time;
    cl.time += host_frametime;

    do {
	ret = CL_GetMessage();
	if (ret == -1)
	    Host_Error("CL_ReadFromServer: lost server connection");
	if (!ret)
	    break;

	cl.last_received_message = realtime;
	CL_ParseServerMessage();
    } while (ret && cls.state >= ca_connected);

    if (cl_shownet.value)
	Con_Printf("\n");

    /* bring the links up to date */
    CL_RelinkEntities();
    CL_UpdateTEnts();

    return 0;
}

void
CL_AddCommands()
{
    Cmd_AddCommand("entities", CL_PrintEntities_f);
    Cmd_AddCommand("disconnect", CL_Disconnect_f);
    Cmd_AddCommand("record", CL_Record_f);
    Cmd_AddCommand("stop", CL_Stop_f);
    Cmd_AddCommand("playdemo", CL_PlayDemo_f);
    Cmd_SetCompletion("playdemo", CL_Demo_Arg_f);
    Cmd_AddCommand("timedemo", CL_TimeDemo_f);
    Cmd_SetCompletion("timedemo", CL_Demo_Arg_f);
    Cmd_AddCommand("mcache", Mod_Print);

    Cmd_AddCommand("name", CL_Name_f);
    Cmd_AddCommand("color", CL_Color_f);
    Cmd_AddCommand("status", NULL);
    Cmd_AddCommand("ping", NULL);
    Cmd_AddCommand("say", NULL);
    Cmd_AddCommand("say_team", NULL);
    Cmd_AddCommand("tell", NULL);

    Cmd_AddCommand("pause", NULL);
    Cmd_AddCommand("kill", NULL);
    Cmd_AddCommand("kick", NULL);

    Cmd_AddCommand("god", NULL);
    Cmd_AddCommand("fly", NULL);
    Cmd_AddCommand("noclip", NULL);
    Cmd_AddCommand("notarget", NULL);
    Cmd_AddCommand("give", NULL);

    CL_Input_AddCommands();
}

void
CL_RegisterVariables()
{
    Cvar_RegisterVariable(&cl_name);
    Cvar_RegisterVariable(&cl_color);
    Cvar_RegisterVariable(&cl_upspeed);
    Cvar_RegisterVariable(&cl_forwardspeed);
    Cvar_RegisterVariable(&cl_backspeed);
    Cvar_RegisterVariable(&cl_sidespeed);
    Cvar_RegisterVariable(&cl_movespeedkey);
    Cvar_RegisterVariable(&cl_yawspeed);
    Cvar_RegisterVariable(&cl_pitchspeed);
    Cvar_RegisterVariable(&cl_anglespeedkey);
    Cvar_RegisterVariable(&cl_run);
    Cvar_RegisterVariable(&cl_shownet);
    Cvar_RegisterVariable(&cl_nolerp);
    Cvar_RegisterVariable(&lookspring);
    Cvar_RegisterVariable(&lookstrafe);
    Cvar_RegisterVariable(&sensitivity);

    Cvar_RegisterVariable(&m_pitch);
    Cvar_RegisterVariable(&m_yaw);
    Cvar_RegisterVariable(&m_forward);
    Cvar_RegisterVariable(&m_side);

    Cvar_RegisterVariable(&cl_maxpitch);
    Cvar_RegisterVariable(&cl_minpitch);

    Cvar_RegisterVariable(&m_freelook);

    CL_Input_RegisterVariables();
}

/*
=================
CL_Init
=================
*/
void
CL_Init(void)
{
    SZ_HunkAlloc(&cls.message, 1024);
    CL_InitTEnts();
}

void
CL_Reinit()
{
    assert(!cls.message.cursize);
    CL_Init();

    /* Reset demos */
    cls.demonum = 0;
    cls.demos[0][0] = 0;
    cls.demoplayback = false;
}
