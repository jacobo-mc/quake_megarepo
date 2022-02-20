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
// host.c -- coordinates spawning and killing of local servers

#include "buildinfo.h"
#include "cdaudio.h"
#include "cmd.h"
#include "console.h"
#include "draw.h"
#include "host.h"
#include "input.h"
#include "keys.h"
#include "menu.h"
#include "model.h"
#include "net.h"
#include "protocol.h"
#include "quakedef.h"
#include "sbar.h"
#include "screen.h"
#include "server.h"
#include "sound.h"
#include "sys.h"
#include "view.h"
#include "wad.h"

#ifdef GLQUAKE
#include "glquake.h"
#else
#include "r_local.h"
#include "render.h"
#endif

/*
 * A server can always be started, even if the system started out as a client
 * to a remote system.
 *
 * A client can NOT be started if the system started as a dedicated server.
 *
 * Memory is cleared/released when a server or client begins, not when they
 * end.
 */

quakeparms_t host_parms;

qboolean host_initialized;	// true if into command execution

double host_frametime;
double host_time;
double realtime;		// without any filtering or bounding
static double oldrealtime;	// last frame run
int host_framecount;

int host_hunklevel;

int minimum_memory;

int fps_count;

static jmp_buf host_abort;

byte *host_basepal;
byte *host_colormap;
byte **host_transtables;

cvar_t host_framerate = { "host_framerate", "0" };	// set for slow motion
cvar_t host_speeds = { "host_speeds", "0" };	// set for running times

cvar_t sys_ticrate = { "sys_ticrate", "0.05" };
cvar_t serverprofile = { "serverprofile", "0" };

cvar_t fraglimit = { "fraglimit", "0", .server = true };
cvar_t timelimit = { "timelimit", "0", .server = true };
cvar_t teamplay = { "teamplay", "0", .server = true };

cvar_t samelevel = { "samelevel", "0" };
cvar_t noexit = { "noexit", "0", .server = true };

cvar_t developer = { "developer", "0" };

cvar_t skill = { "skill", "1" };	// 0 - 3
cvar_t deathmatch = { "deathmatch", "0" };	// 0, 1, or 2
cvar_t coop = { "coop", "0" };	// 0 or 1

cvar_t pausable = { "pausable", "1" };

cvar_t temp1 = { "temp1", "0" };


/*
================
Host_EndGame
================
*/
void
Host_EndGame(const char *message, ...)
{
    va_list argptr;
    char string[MAX_PRINTMSG];

    va_start(argptr, message);
    qvsnprintf(string, sizeof(string), message, argptr);
    va_end(argptr);
    Con_DPrintf("%s: %s\n", __func__, string);

    if (sv.active)
	Host_ShutdownServer(false);

    if (cls.state == ca_dedicated)
	Sys_Error("%s: %s", __func__, string); // dedicated servers exit

    if (cls.demonum != -1)
	CL_NextDemo();
    else
	CL_Disconnect();

    longjmp(host_abort, 1);
}

/*
================
Host_Error

This shuts down both the client and server
================
*/
void
Host_Error(const char *error, ...)
{
    va_list argptr;
    char string[MAX_PRINTMSG];
    static qboolean inerror = false;

    if (inerror)
	Sys_Error("%s: recursively entered", __func__);
    inerror = true;

    SCR_EndLoadingPlaque();	// reenable screen updates

    va_start(argptr, error);
    qvsnprintf(string, sizeof(string), error, argptr);
    va_end(argptr);
    Con_Printf("%s: %s\n", __func__, string);

    if (sv.active)
	Host_ShutdownServer(false);

    if (cls.state == ca_dedicated)
	Sys_Error("%s: %s", __func__, string); // dedicated servers exit

    CL_Disconnect();
    cls.demonum = -1;

    inerror = false;

    longjmp(host_abort, 1);
}

/*
================
Host_FindMaxClients
================
*/
void
Host_FindMaxClients(void)
{
    int i;

    svs.maxclients = 1;

    i = COM_CheckParm("-dedicated");
    if (i) {
	cls.state = ca_dedicated;
	if (i != (com_argc - 1)) {
	    svs.maxclients = Q_atoi(com_argv[i + 1]);
	} else
	    svs.maxclients = 8;
    } else
	cls.state = ca_disconnected;

    i = COM_CheckParm("-listen");
    if (i) {
	if (cls.state == ca_dedicated)
	    Sys_Error("Only one of -dedicated or -listen can be specified");
	if (i != (com_argc - 1))
	    svs.maxclients = Q_atoi(com_argv[i + 1]);
	else
	    svs.maxclients = 8;
    }
    if (svs.maxclients < 1)
	svs.maxclients = 8;
    else if (svs.maxclients > MAX_SCOREBOARD)
	svs.maxclients = MAX_SCOREBOARD;

    svs.maxclientslimit = svs.maxclients;
    if (svs.maxclientslimit < 4)
	svs.maxclientslimit = 4;
    svs.clients =
	Hunk_AllocName(svs.maxclientslimit * sizeof(client_t), "clients");

    if (svs.maxclients > 1)
	Cvar_SetValue("deathmatch", 1.0);
    else
	Cvar_SetValue("deathmatch", 0.0);
}

/*
=======================
SV_InitLocal
======================
*/
static void
SV_InitLocal(void)
{
    if (COM_CheckParm("-developer"))
	Cvar_SetValue("developer", 1);

    Host_FindMaxClients();

    host_time = 1.0;		// so a think at time 0 won't get called
}


/*
===============
Host_WriteConfiguration

Writes key bindings and archived cvars to config.cfg
===============
*/
void
Host_WriteConfiguration(void)
{
    FILE *config_file;

// dedicated servers initialize the host but don't parse and set the
// config.cfg cvars
    if (host_initialized & !isDedicated) {
        config_file = COM_FOpenFileCreate("config.cfg", "w");
        if (config_file) {
            Key_WriteBindings(config_file);
            Cvar_WriteVariables(config_file, CVAR_CONFIG | CVAR_VIDEO);
            fclose(config_file);
        } else {
	    Con_Printf("Couldn't write config.cfg.\n");
        }

        config_file = COM_FOpenFileCreate("video.cfg", "w");
        if (config_file) {
            Cvar_WriteVariables(config_file, CVAR_VIDEO);
            fclose(config_file);
        } else {
	    Con_Printf("Couldn't write video.cfg.\n");
        }
    }
}


/*
=================
SV_ClientPrintf

Sends text across to be displayed
FIXME: make this just a stuffed echo?
=================
*/
void
SV_ClientPrintf(client_t *client, const char *fmt, ...)
{
    va_list argptr;

    MSG_WriteByte(&client->message, svc_print);
    va_start(argptr, fmt);
    MSG_WriteStringvf(&client->message, fmt, argptr);
    va_end(argptr);
}

/*
=================
SV_BroadcastPrintf

Sends text to all active clients
=================
*/
void
SV_BroadcastPrintf(const char *fmt, ...)
{
    va_list argptr;
    int i;

    for (i = 0; i < svs.maxclients; i++)
	if (svs.clients[i].active && svs.clients[i].spawned) {
	    MSG_WriteByte(&svs.clients[i].message, svc_print);
	    va_start(argptr, fmt);
	    MSG_WriteStringvf(&svs.clients[i].message, fmt, argptr);
	    va_end(argptr);
	}
}

/*
=================
Host_ClientCommands

Send text over to the client to be executed
=================
*/
void
Host_ClientCommands(client_t *client, const char *fmt, ...)
{
    va_list argptr;

    MSG_WriteByte(&client->message, svc_stufftext);
    va_start(argptr, fmt);
    MSG_WriteStringvf(&client->message, fmt, argptr);
    va_end(argptr);
}

/*
=====================
SV_DropClient

Called when the player is getting totally kicked off the host
if (crash = true), don't bother sending signofs
=====================
*/
void
SV_DropClient(client_t *client, qboolean crash)
{
    int i;
    client_t *notify;

    if (!crash) {
	/* send any final messages (don't check for errors) */
	if (NET_CanSendMessage(client->netconnection)) {
	    MSG_WriteByte(&client->message, svc_disconnect);
	    NET_SendMessage(client->netconnection, &client->message);
	}
	if (client->edict && client->spawned) {
	    /*
	     * call the prog function for removing a client
	     * this will set the body to a dead frame, among other things
	     */
	    const int save_self = pr_global_struct->self;
	    pr_global_struct->self = EDICT_TO_PROG(client->edict);
	    PR_ExecuteProgram(pr_global_struct->ClientDisconnect);
	    pr_global_struct->self = save_self;
	}
	Sys_Printf("Client %s removed\n", client->name);
    }

    /* break the net connection */
    NET_Close(client->netconnection);
    client->netconnection = NULL;

    /* free the client (the body stays around) */
    client->active = false;
    client->name[0] = 0;
    client->old_frags = -999999;
    net_activeconnections--;

    /* send notification to all clients */
    notify = svs.clients;
    for (i = 0; i < svs.maxclients; i++, notify++) {
	if (!client->active)
	    continue;
	MSG_WriteByte(&notify->message, svc_updatename);
	MSG_WriteByte(&notify->message, client - svs.clients);
	MSG_WriteString(&notify->message, "");
	MSG_WriteByte(&notify->message, svc_updatefrags);
	MSG_WriteByte(&notify->message, client - svs.clients);
	MSG_WriteShort(&notify->message, 0);
	MSG_WriteByte(&notify->message, svc_updatecolors);
	MSG_WriteByte(&notify->message, client - svs.clients);
	MSG_WriteByte(&notify->message, 0);
    }
}

/*
==================
Host_ShutdownServer

This only happens at the end of a game, not between levels
==================
*/
void
Host_ShutdownServer(qboolean crash)
{
    client_t *client;
    int i, count;
    sizebuf_t buf;
    byte message[4];
    double start;

    if (!sv.active)
	return;

    sv.active = false;

    /* stop all client sounds immediately */
    if (cls.state >= ca_connected)
	CL_Disconnect();

    /* flush any pending messages - like the score!!! */
    start = Sys_DoubleTime();
    do {
	count = 0;
	client = svs.clients;
	for (i = 0; i < svs.maxclients; i++, client++) {
	    if (!client->active || !client->message.cursize || !client->netconnection)
		continue;
	    if (NET_CanSendMessage(client->netconnection)) {
		NET_SendMessage(client->netconnection, &client->message);
		SZ_Clear(&client->message);
	    } else {
		NET_GetMessage(client->netconnection);
		count++;
	    }
	}
	if ((Sys_DoubleTime() - start) > 3.0)
	    break;
    } while (count);

    /* make sure all the clients know we're disconnecting */
    buf.data = message;
    buf.maxsize = 4;
    buf.cursize = 0;
    MSG_WriteByte(&buf, svc_disconnect);
    count = NET_SendToAll(&buf, 5);
    if (count)
	Con_Printf("%s: NET_SendToAll failed for %u clients\n", __func__,
		   count);

    client = svs.clients;
    for (i = 0; i < svs.maxclients; i++, client++)
	if (client->active)
	    SV_DropClient(client, crash);

    /* clear structures */
    memset(&sv, 0, sizeof(sv));
    memset(svs.clients, 0, svs.maxclientslimit * sizeof(client_t));
}


/*
================
Host_ClearMemory

This clears all the memory used by both the client and server, but does
not reinitialize anything.
================
*/
void
Host_ClearMemory()
{
    Con_DPrintf("Clearing memory\n");
    D_FlushCaches();
    Mod_ClearAll();
    S_ClearOverflow();
    BGM_ClearBuffers();
    if (host_hunklevel)
	Hunk_FreeToLowMark(host_hunklevel);

    cls.signon = 0;
    memset(&sv, 0, sizeof(sv));
    memset(&cl, 0, sizeof(cl));
}


//============================================================================


/*
===================
Host_FilterTime

Returns false if the time is too short to run a frame
===================
*/
qboolean
Host_FilterTime(float time)
{
    realtime += time;

    if (!cls.timedemo && realtime - oldrealtime < 1.0 / 72.0)
	return false;		// framerate is too high

    host_frametime = realtime - oldrealtime;
    oldrealtime = realtime;

    if (host_framerate.value > 0)
	host_frametime = host_framerate.value;
    else {			// don't allow really long or short frames
	if (host_frametime > 0.1)
	    host_frametime = 0.1;
	if (host_frametime < 0.001)
	    host_frametime = 0.001;
    }

    return true;
}


/*
===================
Host_GetConsoleCommands

Add them exactly as if they had been typed at the console
===================
*/
void
Host_GetConsoleCommands(void)
{
    char *cmd;

    while (1) {
	cmd = Sys_ConsoleInput();
	if (!cmd)
	    break;
	Cbuf_AddText("%s", cmd);
    }
}


/*
==================
Host_ServerFrame

==================
*/
#ifdef FPS_20

void
_Host_ServerFrame(void)
{
// run the world state
    pr_global_struct->frametime = host_frametime;

// read client messages
    SV_RunClients();

// move things around and think
// always pause in single player if in console or menus
    if (!sv.paused && (svs.maxclients > 1 || key_dest == key_game))
	SV_Physics();
}

void
Host_ServerFrame(void)
{
    float save_host_frametime;
    float temp_host_frametime;

// run the world state
    pr_global_struct->frametime = host_frametime;

// set the time and clear the general datagram
    SV_ClearDatagram();

// check for new clients
    SV_CheckForNewClients();

    temp_host_frametime = save_host_frametime = host_frametime;
    while (temp_host_frametime > (1.0 / 72.0)) {
	if (temp_host_frametime > 0.05)
	    host_frametime = 0.05;
	else
	    host_frametime = temp_host_frametime;
	temp_host_frametime -= host_frametime;
	_Host_ServerFrame();
    }
    host_frametime = save_host_frametime;

// send all messages to the clients
    SV_SendClientMessages();
}

#else

void
Host_ServerFrame(void)
{
    /* run the world state */
    pr_global_struct->frametime = host_frametime;

    /* set the time and clear the general datagram */
    SV_ClearDatagram();

    /* check for new clients */
    SV_CheckForNewClients();

    /* read client messages */
    SV_RunClients();

    /*
     * Move things around and think. Always pause in single player if in
     * console or menus
     */
    if (!sv.paused && (svs.maxclients > 1 || key_dest == key_game))
	SV_Physics();

    /* send all messages to the clients */
    SV_SendClientMessages();
}

#endif


/*
==================
Host_Frame

Runs all active servers
==================
*/
void
_Host_Frame(float time)
{
    static double time1 = 0;
    static double time2 = 0;
    static double time3 = 0;
    int pass1, pass2, pass3;

    /* something bad happened, or the server disconnected */
    if (setjmp(host_abort))
	return;

    /* keep the random time dependent */
    rand();

    /*
     * Decide the simulation time. Don't run too fast, or packets will flood
     * out.
     */
    if (!Host_FilterTime(time))
	return;

    /* get new key events */
    Sys_SendKeyEvents();

    /* allow mice or other external controllers to add commands */
    IN_Commands();

    /* process console commands */
    Cbuf_Execute();

    NET_Poll();

    /* if running the server locally, make intentions now */
    if (sv.active)
	CL_SendCmd();

//-------------------
//
// server operations
//
//-------------------

    /* check for commands typed to the host */
    Host_GetConsoleCommands();

    if (sv.active)
	Host_ServerFrame();

//-------------------
//
// client operations
//
//-------------------

    /*
     * if running the server remotely, send intentions now after the incoming
     * messages have been read
     */
    if (!sv.active)
	CL_SendCmd();

    host_time += host_frametime;

    /* fetch results from server */
    if (cls.state >= ca_connected)
	CL_ReadFromServer();

    /* update video */
    if (host_speeds.value)
	time1 = Sys_DoubleTime();

    SCR_UpdateScreen();
    CL_RunParticles();

    if (host_speeds.value)
	time2 = Sys_DoubleTime();

    /* update audio */
    if (cls.state == ca_active) {
	S_Update(r_origin, vpn, vright, vup);
	CL_DecayLights();
    } else
	S_Update(vec3_origin, vec3_origin, vec3_origin, vec3_origin);

    CDAudio_Update();

    if (host_speeds.value) {
	pass1 = (time1 - time3) * 1000;
	time3 = Sys_DoubleTime();
	pass2 = (time2 - time1) * 1000;
	pass3 = (time3 - time2) * 1000;
	Con_Printf("%3i tot %3i server %3i gfx %3i snd\n",
		   pass1 + pass2 + pass3, pass1, pass2, pass3);
    }

    host_framecount++;
    fps_count++;
}

void
Host_Frame(float time)
{
    double time1, time2;
    static double timetotal;
    static int timecount;
    int i, c, m;

    if (!serverprofile.value) {
	_Host_Frame(time);
	return;
    }

    time1 = Sys_DoubleTime();
    _Host_Frame(time);
    time2 = Sys_DoubleTime();

    timetotal += time2 - time1;
    timecount++;

    if (timecount < 1000)
	return;

    m = timetotal * 1000 / timecount;
    timecount = 0;
    timetotal = 0;
    c = 0;
    for (i = 0; i < svs.maxclients; i++) {
	if (svs.clients[i].active)
	    c++;
    }

    Con_Printf("serverprofile: %2i clients %2i msec\n", c, m);
}

//============================================================================

void Host_Gamedir_f();
void Host_Gamedir_Arg_f(struct stree_root *root, int argnum)
{
    if (argnum == 1) {
        COM_ScanBaseDir(root, Cmd_Argv(1));
    } else if (argnum == 2) {
        const char *arg = Cmd_Argv(2);
        const char *args[] = { "-hipnotic", "-quoth", "-rogue" };
        int arg_len = arg ? strlen(arg) : 0;
        for (int i = 0; i < ARRAY_SIZE(args); i++)
            if (!arg || !strncasecmp(args[i], arg, arg_len))
                STree_InsertAlloc(root, args[i], false);
    }
}

static void
Commands_Init()
{
    Memory_AddCommands();
    Cmd_AddCommands();
    CDAudio_AddCommands();
    COM_AddCommands();
    Con_AddCommands();
    Key_AddCommands();
    M_AddCommands();
    Mod_AddCommands();
    PR_AddCommands();

    /* Note cls.state not set at this stage, so can't check for ca_dedicated */
    if (!COM_CheckParm("-dedicated")) {
        R_AddCommands();
        IN_AddCommands();
        SCR_AddCommands();
        S_AddCommands();
        VID_AddCommands();
        VID_Mode_AddCommands();
        CL_AddCommands();
        Sbar_AddCommands();
        V_AddCommands();
    }

    SV_AddCommands();

    Cmd_AddCommand("game", Host_Gamedir_f);
    Cmd_SetCompletion("game", Host_Gamedir_Arg_f);
}

static void
Cvars_Init()
{
    Sys_RegisterVariables();
    CDAudio_RegisterVariables();
    COM_RegisterVariables();
    Con_RegisterVariables();
    Key_RegisterVariables();
    PR_RegisterVariables();
    NET_RegisterVariables();

    /* Note cls.state not set at this stage, so can't check for ca_dedicated */
    if (!COM_CheckParm("-dedicated")) {
        R_RegisterVariables();
        Draw_RegisterVariables();
        IN_RegisterVariables();
        SCR_RegisterVariables();
        S_RegisterVariables();
        VID_RegisterVariables();
        VID_Mode_RegisterVariables();
        Chase_RegisterVariables();
        CL_RegisterVariables();
        V_RegisterVariables();
    }

    SV_RegisterVariables();
}

/*
 * Returns an error message on failure, or NULL on success.
 */
static const char *
Host_LoadPalettes()
{
    host_basepal = COM_LoadHunkFile("gfx/palette.lmp", NULL);
    if (!host_basepal)
        return "Couldn't load gfx/palette.lmp";
    host_colormap = COM_LoadHunkFile("gfx/colormap.lmp", NULL);
    if (!host_colormap)
        return "Couldn't load gfx/colormap.lmp";

    return NULL;
}

/*
 * Called when the filesystem has been initialised (and assuming
 * palette and colormap are already loaded) to load various graphical
 * resources: palette, charset, console background, menu pics, etc.
 */
static void
Host_NewGame()
{
    Alpha_Init();
    Draw_Init();
    SCR_Init();
    R_Init();
    Sbar_Init();
}


/*
 * ====================
 *  Host_Init
 * ====================
 * The system code can optionally pass a null terminated list of function pointers which can be
 * called by host init to find more basedir candidates if the initial (CWD) one fails.
 */
void
Host_Init(quakeparms_t *parms, basedir_fn *basedir_fns)
{
    if (standard_quake)
	minimum_memory = MINIMUM_MEMORY;
    else
	minimum_memory = MINIMUM_MEMORY_LEVELPAK;

    if (COM_CheckParm("-minmemory"))
	parms->memsize = minimum_memory;

    host_parms = *parms;

    if (parms->memsize < minimum_memory)
	Sys_Error("Only %4.1f megs of memory reported, can't execute game",
		  parms->memsize / (float)0x100000);

    com_argc = parms->argc;
    com_argv = parms->argv;

    Memory_Init(parms->membase, parms->memsize);
    Cvars_Init();
    Commands_Init();
    Cbuf_Init();

    V_Init();
    SV_InitLocal();
    Key_Init();
    Con_Init();
    M_Init();
    PR_Init();
    Mod_Init(R_AliasModelLoader(), R_BrushModelLoader());
    NET_Init();
    SV_Init();

    Con_Printf("Exe: %s\n", Build_DateString());
    Con_Printf("%4.1f megabyte heap\n", parms->memsize / (1024 * 1024.0));

    R_InitTextures(); // needed even for dedicated servers (TODO: why? shouldn't be...)

next_basedir:
    COM_InitFileSystem();
    COM_InitGameDirectoryFromCommandLine();

    if (cls.state != ca_dedicated) {
        /*
         * Attempt to load palettes.  If this fails, the caller may have supplied alternative
         * basedirs to try.  Try each in turn until we succeed or run out of options.
         */
        const char *error = Host_LoadPalettes();
        if (error) {
            if (!COM_CheckParm("-basedir")) {
                while (basedir_fns && *basedir_fns) {
                    host_parms.basedir = (*basedir_fns++)();
                    if (host_parms.basedir) {
                        goto next_basedir;
                    }
                }
            }
            Sys_Error("%s", error);
        }

        VID_Init(host_basepal);
        Host_NewGame();

	S_Init();
	CDAudio_Init();
	CL_Init();
	IN_Init();
    }
    Mod_InitAliasCache();

    Hunk_AllocName(0, "--HOST--");
    host_hunklevel = Hunk_LowMark();

    host_initialized = true;
    Sys_Printf("======= Quake Initialized =======\n");

    /* In case exec of quake.rc fails */
    if (!setjmp(host_abort)) {
	Cbuf_InsertText("exec quake.rc\n");
	Cbuf_Execute();
    }
}

/*
 * Host_Reinit - Called after Host_NewGame() to finish setting up the host, ready to spawn the level
 */
void
Host_Reinit()
{
    if (cls.state != ca_dedicated) {
        S_Init();
        CL_Reinit();
    }
    Mod_InitAliasCache();

    Hunk_AllocName(0, "--HOST--");
    host_hunklevel = Hunk_LowMark();
}

void
Host_Gamedir(const char *directory, enum game_type game_type)
{
    qboolean changing = COM_CheckForGameDirectoryChange(Cmd_Argv(1), game_type);
    if (!changing)
        return;

    /*
     * TODO: We are relying on VID_SetMode() to free all textures and re-init them
     *       If we can avoid a mode set and do this ourselves, we should.
     */
    CL_Disconnect();
    Host_ShutdownServer(true);
    Host_ClearMemory();

    /*
     * We need a full sound shutdown because some sound drivers hunk
     * allocate their buffers.
     */
    S_Shutdown();

    scr_block_drawing = true;
    COM_Gamedir(Cmd_Argv(1), game_type);
    const char *error = Host_LoadPalettes();
    if (error)
        Sys_Error("%s", error);

    if (cls.state != ca_dedicated) {
        VID_InitColormap(host_basepal);
        VID_SetMode(vid_currentmode, host_basepal);
    }

    Host_NewGame();
    Host_Reinit();
    scr_block_drawing = false;

    Cbuf_AddText("exec quake.rc\n");
}

void
Host_Gamedir_f()
{
    if (Cmd_Argc() == 1)
        goto print_current;
    if (Cmd_Argc() < 2 || Cmd_Argc() > 3)
        goto print_usage;

    enum game_type game_type = GAME_TYPE_ID1;
    if (Cmd_Argc() == 3) {
        if (!strcmp(Cmd_Argv(2), "-hipnotic"))
            game_type = GAME_TYPE_HIPNOTIC;
        else if (!strcmp(Cmd_Argv(2), "-rogue"))
            game_type = GAME_TYPE_ROGUE;
        else if (!strcmp(Cmd_Argv(2), "-quoth"))
            game_type = GAME_TYPE_QUOTH;
        else
            goto print_usage;
    }

    qboolean changing = COM_CheckForGameDirectoryChange(Cmd_Argv(1), game_type);
    if (changing) {
        Host_Gamedir(Cmd_Argv(1), game_type);
        return;
    }

print_current:
    if (com_game_type < GAME_TYPE_HIPNOTIC) {
        Con_Printf("game is \"%s\"\n", com_gamedirfile);
    } else {
        Con_Printf("game is \"%s\" -%s\n", com_gamedirfile, com_game_type_names[com_game_type]);
    }
    return;

print_usage:
    Con_Printf("Usage: game <directory> [-hipnotic|-rogue|-quoth]\n");
    return;
}

/*
===============
Host_Shutdown

FIXME: this is a callback from Sys_Quit and Sys_Error.  It would be better
to run quit through here before the final handoff to the sys code.
===============
*/
void
Host_Shutdown(void)
{
    static qboolean isdown = false;

    if (isdown) {
	printf("recursive shutdown\n");
	return;
    }
    isdown = true;

// keep Con_Printf from trying to update the screen
    scr_disabled_for_loading = true;

    Host_WriteConfiguration();

    CDAudio_Shutdown();
    NET_Shutdown();
    S_Shutdown();
    IN_Shutdown();

    if (cls.state != ca_dedicated) {
	VID_Shutdown();
    }
}
