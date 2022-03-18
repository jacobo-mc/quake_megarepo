/*
 * sv_main.c -- hexenworld server main program
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 1997-1998  Raven Software Corp.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "quakedef.h"
#include "huffman.h"

static int	sv_protocol = 0;

quakeparms_t	*host_parms;

qboolean	host_initialized;		// true if into command execution (compatability)

double		host_frametime;
double		realtime;			// without any filtering or bounding

int			host_hunklevel;

netadr_t	master_adr[MAX_MASTERS];	// address of group servers

client_t	*host_client;			// current client

cvar_t	sv_mintic = {"sv_mintic", "0.03", CVAR_NONE};	// bound the size of the
cvar_t	sv_maxtic = {"sv_maxtic", "0.1", CVAR_NONE};	// physics time tic

cvar_t	developer = {"developer", "0", CVAR_NONE};	// show extra messages

static	cvar_t	timeout = {"timeout", "65", CVAR_NONE};		// seconds without any message
static	cvar_t	zombietime = {"zombietime", "2", CVAR_NONE};	// seconds to sink messages
								// after disconnect

static	cvar_t	rcon_password = {"rcon_password", "", CVAR_NONE};	// password for remote server commands
static	cvar_t	password = {"password", "", CVAR_NONE};		// password for entering the game
static	cvar_t	spectator_password = {"spectator_password", "", CVAR_NONE};	// password for entering as a sepctator

cvar_t	sv_highchars = {"sv_highchars", "1", CVAR_NONE};

cvar_t	sv_phs = {"sv_phs", "1", CVAR_NONE};
cvar_t	sv_namedistance = {"sv_namedistance", "600", CVAR_NONE};

cvar_t	allow_download = {"allow_download", "1", CVAR_NONE};
cvar_t	allow_download_skins = {"allow_download_skins", "1", CVAR_NONE};
cvar_t	allow_download_models = {"allow_download_models", "1", CVAR_NONE};
cvar_t	allow_download_sounds = {"allow_download_sounds", "1", CVAR_NONE};
cvar_t	allow_download_maps = {"allow_download_maps", "1", CVAR_NONE};

//
// game rules mirrored in svs.info
//
cvar_t	fraglimit = {"fraglimit", "0", CVAR_NOTIFY|CVAR_SERVERINFO};
cvar_t	timelimit = {"timelimit", "0", CVAR_NOTIFY|CVAR_SERVERINFO};
cvar_t	teamplay = {"teamplay", "0", CVAR_NOTIFY|CVAR_SERVERINFO};
cvar_t	samelevel = {"samelevel", "0", CVAR_NOTIFY|CVAR_SERVERINFO};
cvar_t	maxclients = {"maxclients","8", CVAR_SERVERINFO};
cvar_t	maxspectators = {"maxspectators","8", CVAR_SERVERINFO};
cvar_t	skill = {"skill","1", CVAR_NONE};		// 0 - 3
cvar_t	coop = {"coop", "0", CVAR_SERVERINFO};			// 0 or 1
cvar_t	deathmatch = {"deathmatch", "1", CVAR_SERVERINFO};	// 0, 1, or 2
cvar_t	randomclass = {"randomclass", "0", CVAR_SERVERINFO};	
cvar_t	damageScale = {"damagescale", "1.0", CVAR_SERVERINFO};
cvar_t	shyRespawn = {"shyRespawn", "0", CVAR_SERVERINFO};
cvar_t	spartanPrint = {"spartanPrint", "1.0", CVAR_SERVERINFO};
cvar_t	meleeDamScale = {"meleeDamScale", "0.66666", CVAR_SERVERINFO};
cvar_t	manaScale = {"manascale", "1.0", CVAR_SERVERINFO};
cvar_t	tomeMode = {"tomemode", "0", CVAR_SERVERINFO};
cvar_t	tomeRespawn = {"tomerespawn", "0", CVAR_SERVERINFO};
cvar_t	w2Respawn = {"w2respawn", "0", CVAR_SERVERINFO};
cvar_t	altRespawn = {"altrespawn", "0", CVAR_SERVERINFO};
cvar_t	fixedLevel = {"fixedlevel", "0", CVAR_SERVERINFO};
cvar_t	autoItems = {"autoitems", "0", CVAR_SERVERINFO};
cvar_t	dmMode = {"dmmode", "0", CVAR_SERVERINFO};
cvar_t	easyFourth = {"easyfourth", "0", CVAR_SERVERINFO};
cvar_t	patternRunner= {"patternrunner", "0", CVAR_SERVERINFO};
cvar_t	spawn = {"spawn", "0", CVAR_SERVERINFO};

cvar_t	hostname = {"hostname", "unnamed", CVAR_SERVERINFO};

cvar_t	sv_ce_scale = {"sv_ce_scale", "1", CVAR_ARCHIVE};
cvar_t	sv_ce_max_size = {"sv_ce_max_size", "0", CVAR_ARCHIVE};

cvar_t	noexit = {"noexit", "0", CVAR_NOTIFY|CVAR_SERVERINFO};

FILE	*sv_logfile;
FILE	*sv_fraglogfile;

static void Master_Shutdown (void);


//
// external cvars
//
extern	cvar_t	sv_maxvelocity;
extern	cvar_t	sv_gravity;
extern	cvar_t	sv_aim;
extern	cvar_t	sv_stopspeed;
extern	cvar_t	sv_spectatormaxspeed;
extern	cvar_t	sv_accelerate;
extern	cvar_t	sv_airaccelerate;
extern	cvar_t	sv_wateraccelerate;
extern	cvar_t	sv_friction;
extern	cvar_t	sv_waterfriction;


//============================================================================

/*
================
SV_Shutdown

Quake calls this before calling Sys_Quit or Sys_Error
================
*/
void SV_Shutdown (void)
{
	Master_Shutdown ();
	if (sv_logfile)
	{
		fclose (sv_logfile);
		sv_logfile = NULL;
	}
	if (sv_fraglogfile)
	{
		fclose (sv_fraglogfile);
		sv_logfile = NULL;
	}
	NET_Shutdown ();
}


/*
================
SV_Error

Sends a datagram to all the clients informing them of the server crash,
then exits
================
*/
void SV_Error (const char *error, ...)
{
	va_list		argptr;
	static	char		string[1024];
	static	qboolean inerror = false;

	if (inerror)
		Sys_Error ("%s: recursive error! (%s)", __thisfunc__, string);

	inerror = true;

	va_start (argptr, error);
	q_vsnprintf (string, sizeof(string), error, argptr);
	va_end (argptr);

	Con_Printf ("%s: %s\n", __thisfunc__, string);

	SV_FinalMessage (va("server crashed: %s\n", string));

	SV_Shutdown ();

	Sys_Error ("%s: %s\n", __thisfunc__, string);
}


/*
==================
SV_FinalMessage

Used by SV_Error and SV_Quit_f to send a final message to all connected
clients before the server goes down.  The messages are sent immediately,
not just stuck on the outgoing message list, because the server is going
to totally exit after returning from this function.
==================
*/
void SV_FinalMessage (const char *message)
{
	int			i;
	client_t	*cl;

	SZ_Clear (&net_message);
	MSG_WriteByte (&net_message, svc_print);
	MSG_WriteByte (&net_message, PRINT_HIGH);
	MSG_WriteString (&net_message, message);
	MSG_WriteByte (&net_message, svc_disconnect);

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state >= cs_spawned)
			Netchan_Transmit (&cl->netchan, net_message.cursize, net_message.data);
	}
}


/*
=====================
SV_DropClient

Called when the player is totally leaving the server, either willingly
or unwillingly.  This is NOT called if the entire server is quiting
or crashing.
=====================
*/
void SV_DropClient (client_t *drop)
{
	// add the disconnect
	MSG_WriteByte (&drop->netchan.message, svc_disconnect);

	if (drop->state == cs_spawned)
	{
		if (!drop->spectator)
		{
			// call the prog function for removing a client
			// this will set the body to a dead frame, among other things
			*sv_globals.self = EDICT_TO_PROG(drop->edict);
			PR_ExecuteProgram (*sv_globals.ClientDisconnect);
		}
		else if (SpectatorDisconnect)
		{
			// call the prog function for removing a client
			// this will set the body to a dead frame, among other things
			*sv_globals.self = EDICT_TO_PROG(drop->edict);
			PR_ExecuteProgram (SpectatorDisconnect);
		}
	}
	else if (dmMode.integer == DM_SIEGE && SV_PROGS_HAVE_SIEGE)
	{
		if (*PR_GetString(drop->edict->v.puzzle_inv1) != '\0')
		{
			// this guy has a puzzle piece, call this function anyway
			// to make sure he leaves it behind
			Con_Printf("Client in unspawned state had puzzle piece, forcing drop\n");
			*sv_globals.self = EDICT_TO_PROG(drop->edict);
			PR_ExecuteProgram (*sv_globals.ClientDisconnect);
		}
	}

	if (drop->spectator)
		Con_Printf ("Spectator %s removed\n",drop->name);
	else
		Con_Printf ("Client %s removed\n",drop->name);

	if (drop->download)
	{
		fclose (drop->download);
		drop->download = NULL;
	}

	drop->state = cs_zombie;		// become free in a few seconds
	drop->connection_started = realtime;	// for zombie timeout

	drop->old_frags = 0;
	drop->edict->v.frags = 0;
	drop->name[0] = 0;
	memset (drop->userinfo, 0, sizeof(drop->userinfo));

	// send notification to all remaining clients
	SV_FullClientUpdate (drop, &sv.reliable_datagram);
}


//====================================================================

/*
===================
SV_CalcPing

===================
*/
int SV_CalcPing (client_t *cl)
{
	float		ping;
	int			i;
	int			count;
	register	client_frame_t *frame;

	ping = 0;
	count = 0;
	for (frame = cl->frames, i = 0; i < UPDATE_BACKUP; i++, frame++)
	{
		if (frame->ping_time > 0)
		{
			ping += frame->ping_time;
			count++;
		}
	}
	if (!count)
		return 9999;
	ping /= count;

	return ping*1000;
}


/*
===================
SV_FullClientUpdate

Writes all update values to a sizebuf
===================
*/
unsigned int	defLosses;	// Defenders losses in Siege
unsigned int	attLosses;	// Attackers Losses in Siege

void SV_FullClientUpdate (client_t *client, sizebuf_t *buf)
{
	int		i;
	char	info[MAX_INFO_STRING];

//	Con_Printf("%s\n", __thisfunc__);
	i = client - svs.clients;

//	Sys_Printf("%s:  Updated frags for client %d\n", __thisfunc__, i);

	MSG_WriteByte (buf, svc_updatedminfo);
	MSG_WriteByte (buf, i);
	MSG_WriteShort (buf, client->old_frags);
	MSG_WriteByte (buf, (client->playerclass<<5)|((int)client->edict->v.level&31));

	if (dmMode.integer == DM_SIEGE && SV_PROGS_HAVE_SIEGE)
	{
		MSG_WriteByte (buf, svc_updatesiegeinfo);
		MSG_WriteByte (buf, (int)ceil(timelimit.value));
		MSG_WriteByte (buf, (int)ceil(fraglimit.value));

		MSG_WriteByte (buf, svc_updatesiegeteam);
		MSG_WriteByte (buf, i);
		MSG_WriteByte (buf, client->siege_team);

		MSG_WriteByte (buf, svc_updatesiegelosses);
		MSG_WriteByte (buf, *sv_globals.defLosses);
		MSG_WriteByte (buf, *sv_globals.attLosses);

		MSG_WriteByte (buf, svc_time);//send server time upon connection
		MSG_WriteFloat (buf, sv.time);
	}

	MSG_WriteByte (buf, svc_updateping);
	MSG_WriteByte (buf, i);
	MSG_WriteShort (buf, SV_CalcPing (client));

	MSG_WriteByte (buf, svc_updateentertime);
	MSG_WriteByte (buf, i);
	MSG_WriteFloat (buf, realtime - client->connection_started);

	strcpy (info, client->userinfo);
	Info_RemovePrefixedKeys (info, '_');	// server passwords, etc

	MSG_WriteByte (buf, svc_updateuserinfo);
	MSG_WriteByte (buf, i);
	MSG_WriteLong (buf, client->userid);
	MSG_WriteString (buf, info);
}


/*
==============================================================================

CONNECTIONLESS COMMANDS

==============================================================================
*/

/*
================
SVC_Status

Responds with all the info that qplug or qspy can see
This message can be up to around 5k with worst case string lengths.
================
*/
static void SVC_Status (void)
{
	int		i;
	client_t	*cl;
	int		ping;
	int		top, bottom;

	Cmd_TokenizeString ("status");
	SV_BeginRedirect (RD_PACKET);
	Con_Printf ("%s\n", svs.info);
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		cl = &svs.clients[i];
		if ((cl->state == cs_connected || cl->state == cs_spawned ) && !cl->spectator)
		{
			top = atoi(Info_ValueForKey (cl->userinfo, "topcolor"));
			bottom = atoi(Info_ValueForKey (cl->userinfo, "bottomcolor"));
			ping = SV_CalcPing (cl);
			Con_Printf ("%i %i %i %i \"%s\" \"%s\" %i %i\n", cl->userid, 
				cl->old_frags, (int)(realtime - cl->connection_started)/60,
				ping, cl->name, Info_ValueForKey (cl->userinfo, "skin"), top, bottom);
		}
	}
	SV_EndRedirect ();
}


/*
===================
SV_CheckLog

===================
*/
#define	LOG_HIGHWATER	4096
#define	LOG_FLUSH	10*60

static void SV_CheckLog (void)
{
	sizebuf_t	*sz;

	sz = &svs.log[svs.logsequence&1];

	// bump sequence if allmost full, or ten minutes have passed and
	// there is something still sitting there
	if (sz->cursize > LOG_HIGHWATER
		|| (realtime - svs.logtime > LOG_FLUSH && sz->cursize) )
	{
		// swap buffers and bump sequence
		svs.logtime = realtime;
		svs.logsequence++;
		sz = &svs.log[svs.logsequence&1];
		sz->cursize = 0;
		Con_Printf ("beginning fraglog sequence %i\n", svs.logsequence);
	}
}


/*
================
SVC_Log

Responds with all the logged frags for ranking programs.
If a sequence number is passed as a parameter and it is
the same as the current sequence, an A2A_NACK will be returned
instead of the data.
================
*/
static void SVC_Log (void)
{
	int		seq;
	char	data[MAX_DATAGRAM+64];

	if (Cmd_Argc() == 2)
		seq = atoi(Cmd_Argv(1));
	else
		seq = -1;

	if (seq == svs.logsequence-1 || !sv_fraglogfile)
	{	// they already have this data, or we aren't logging frags
		data[0] = A2A_NACK;
		NET_SendPacket (1, data, &net_from);
		return;
	}

	Con_DPrintf ("sending log %i to %s\n", svs.logsequence-1, NET_AdrToString(&net_from));

	q_snprintf(data, sizeof(data), "stdlog %i\n", svs.logsequence-1);
	q_strlcat (data, (char *)svs.log_buf[((svs.logsequence-1)&1)], sizeof(data));

	NET_SendPacket (strlen(data)+1, data, &net_from);
}


/*
================
SVC_Ping

Just responds with an acknowledgement
================
*/
static void SVC_Ping (void)
{
	char	data;

	data = A2A_ACK;

	NET_SendPacket (1, &data, &net_from);
}


/*
==================
SVC_DirectConnect

A connection request that did not come from the master
==================
*/
static void SVC_DirectConnect (void)
{
	char		userinfo[1024];
	static		int	userid;
	netadr_t	adr;
	int			i;
	client_t	*cl, *newcl;
	client_t	temp;
	edict_t		*ent;
	int			edictnum;
	const char		*s;
	int			clients, spectators;
	qboolean	spectator;

	q_strlcpy (userinfo, Cmd_Argv(2), sizeof(userinfo));

	// check for password or spectator_password
	s = Info_ValueForKey (userinfo, "spectator");
	if (s[0] && strcmp(s, "0"))
	{
		if (spectator_password.string[0] && 
			q_strcasecmp(spectator_password.string, "none") &&
			strcmp(spectator_password.string, s) )
		{	// failed
			Con_Printf ("%s:spectator password failed\n", NET_AdrToString (&net_from));
			Netchan_OutOfBandPrint (&net_from, "%c\nrequires a spectator password\n\n", A2C_PRINT);
			return;
		}
		Info_SetValueForStarKey (userinfo, "*spectator", "1", MAX_INFO_STRING);
		spectator = true;
		Info_RemoveKey (userinfo, "spectator"); // remove passwd
	}
	else
	{
		s = Info_ValueForKey (userinfo, "password");
		if (password.string[0] && 
			q_strcasecmp(password.string, "none") &&
			strcmp(password.string, s) )
		{
			Con_Printf ("%s:password failed\n", NET_AdrToString (&net_from));
			Netchan_OutOfBandPrint (&net_from, "%c\nserver requires a password\n\n", A2C_PRINT);
			return;
		}
		spectator = false;
		Info_RemoveKey (userinfo, "password"); // remove passwd
	}

	adr = net_from;
	userid++;	// so every client gets a unique id

	newcl = &temp;
	memset (newcl, 0, sizeof(client_t));

	newcl->userid = userid;
	newcl->portals = atoi(Cmd_Argv(1));

	// works properly
	if (!sv_highchars.integer)
	{
		byte	*p, *q;

		for (p = (byte *)newcl->userinfo, q = (byte *)userinfo;
			*q && p < (byte *)newcl->userinfo + sizeof(newcl->userinfo)-1; q++)
		{
			if (*q > 31 && *q <= 127)
				*p++ = *q;
		}
	}
	else
	{
		q_strlcpy (newcl->userinfo, userinfo, sizeof(newcl->userinfo));
	}

	// if there is already a slot for this ip, drop it
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state == cs_free)
			continue;
		if (NET_CompareAdr (&adr, &cl->netchan.remote_address))
		{
			Con_Printf ("%s:reconnect\n", NET_AdrToString (&adr));
			SV_DropClient (cl);
			break;
		}
	}

	// count up the clients and spectators
	clients = 0;
	spectators = 0;
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state == cs_free)
			continue;
		if (cl->spectator)
			spectators++;
		else
			clients++;
	}

	// if at server limits, refuse connection
	if (maxclients.integer > MAX_CLIENTS)
		Cvar_SetValueQuick (&maxclients, MAX_CLIENTS);
	if (maxspectators.integer > MAX_CLIENTS)
		Cvar_SetValueQuick (&maxspectators, MAX_CLIENTS);
	if (maxspectators.integer + maxclients.integer > MAX_CLIENTS)
		Cvar_SetValueQuick (&maxspectators, MAX_CLIENTS - maxspectators.integer + maxclients.integer);
	if ( (spectator && spectators >= maxspectators.integer)
		|| (!spectator && clients >= maxclients.integer) )
	{
		Con_Printf ("%s:full connect\n", NET_AdrToString (&adr));
		Netchan_OutOfBandPrint (&adr, "%c\nserver is full\n\n", A2C_PRINT);
		return;
	}

	// find a client slot
	newcl = NULL;
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state == cs_free)
		{
			newcl = cl;
			break;
		}
	}
	if (!newcl)
	{
		Con_Printf ("WARNING: miscounted available clients\n");
		return;
	}

	// build a new connection
	// accept the new client
	// this is the only place a client_t is ever initialized
	*newcl = temp;

	if (sv_protocol != 0)
		newcl->protocol = sv_protocol;
	else {
		s = Info_ValueForKey(userinfo, "*cap");
		if (strstr(s, "c"))
			newcl->protocol = PROTOCOL_VERSION_EXT;
		else	newcl->protocol = PROTOCOL_VERSION;
	}

	Netchan_OutOfBandPrint (&adr, "%c", S2C_CONNECTION );

	edictnum = (newcl-svs.clients)+1;

	Netchan_Setup (&newcl->netchan, &adr);

	newcl->state = cs_connected;

	SZ_Init (&newcl->datagram, newcl->datagram_buf, sizeof(newcl->datagram_buf));
	newcl->datagram.allowoverflow = true;

	// spectator mode can ONLY be set at join time
	newcl->spectator = spectator;

	ent = EDICT_NUM(edictnum);
	newcl->edict = ent;
	ED_ClearEdict (ent);

	// parse some info from the info strings
	SV_ExtractFromUserinfo (newcl);

	// JACK: Init the floodprot stuff.
	for (i = 0; i < 10; i++)
		newcl->whensaid[i] = 0.0;
	newcl->whensaidhead = 0;
	newcl->lockedtill = 0;

	// call the progs to get default spawn parms for the new client
	PR_ExecuteProgram (*sv_globals.SetNewParms);
	for (i = 0; i < NUM_SPAWN_PARMS; i++)
		newcl->spawn_parms[i] = sv_globals.parm[i];

	if (newcl->spectator)
		Con_Printf ("Spectator %s connected\n", newcl->name);
	else
		Con_DPrintf ("Client %s connected\n", newcl->name);
}


static int Rcon_Validate (void)
{
	if (rcon_password.string[0] == '\0')
		return 0;

	if (strcmp (Cmd_Argv(1), rcon_password.string) )
		return 0;

	return 1;
}


/*
===============
SVC_RemoteCommand

A client issued an rcon command.
Shift down the remaining args
Redirect all printfs
===============
*/
static void SVC_RemoteCommand (void)
{
	int		i;
	char	remaining[1024];

	i = Rcon_Validate ();

	if (i == 0)
	{
		Con_Printf ("Bad rcon from %s:\n%s\n", NET_AdrToString(&net_from), net_message.data + 4);
		SV_BeginRedirect (RD_PACKET);
		Con_Printf ("Bad rcon_password.\n");
	}
	else
	{
		Con_Printf ("Rcon from %s:\n%s\n", NET_AdrToString(&net_from), net_message.data + 4);
		SV_BeginRedirect (RD_PACKET);
		remaining[0] = 0;

		for (i = 2; i < Cmd_Argc(); i++)
		{
			q_strlcat (remaining, Cmd_Argv(i), sizeof(remaining));
			q_strlcat (remaining, " ", sizeof(remaining));
		}

		Cmd_ExecuteString (remaining, src_command);
	}

	SV_EndRedirect ();
}


/*
=================
SV_ConnectionlessPacket

A connectionless packet has four leading 0xff
characters to distinguish it from a game channel.
Clients that are in the game can still send
connectionless packets.
=================
*/
static void SV_ConnectionlessPacket (void)
{
	const char	*s;
	const char	*c;

	MSG_BeginReading ();
	MSG_ReadLong ();	// skip the -1 marker

	s = MSG_ReadStringLine ();

	Cmd_TokenizeString (s);

	c = Cmd_Argv(0);

	if (!strcmp(c, "ping") || ( c[0] == A2A_PING && (c[1] == 0 || c[1] == '\n')) )
	{
		SVC_Ping ();
		return;
	}
	if (c[0] == A2A_ACK && (c[1] == 0 || c[1] == '\n') )
	{
		Con_Printf ("A2A_ACK from %s\n", NET_AdrToString (&net_from));
		return;
	}
	else if (c[0] == A2S_ECHO)
	{
		NET_SendPacket (net_message.cursize, net_message.data, &net_from);
		return;
	}
	else if (!strcmp(c,"status"))
	{
		SVC_Status ();
		return;
	}
	else if (!strcmp(c,"log"))
	{
		SVC_Log ();
		return;
	}
	else if (!strcmp(c,"connect"))
	{
		SVC_DirectConnect ();
		return;
	}
	else if (!strcmp(c, "rcon"))
		SVC_RemoteCommand ();
	else
		Con_Printf ("bad connectionless packet from %s:\n%s\n", NET_AdrToString (&net_from), s);
}


/*
==============================================================================

PACKET FILTERING

You can add or remove addresses from the filter list with:

addip <ip>
removeip <ip>

The ip address is specified in dot format, and any unspecified
digits will match any value, so you can specify an entire class
C network with "addip 192.246.40".

Removeip will only remove an address specified exactly the same
way.  You cannot addip a subnet, then removeip a single host.

listip
Prints the current list of filters.

writeip
Dumps "addip <ip>" commands to listip.cfg so it can be execed at
a later date.  The filter lists are not saved and restored by
default, because I beleive it would cause too much confusion.

filterban <0 or 1>

If 1 (the default), then ip addresses matching the current list will
be prohibited from entering the game.  This is the default setting.

If 0, then only addresses matching the list will be allowed.  This
lets you easily set up a private game, or a game that only allows
players from your local network.

==============================================================================
*/

typedef struct
{
	unsigned int	mask;
	unsigned int	compare;
} ipfilter_t;

#define	MAX_IPFILTERS	1024

static ipfilter_t	ipfilters[MAX_IPFILTERS];
static int		numipfilters;

static	cvar_t	filterban = {"filterban", "1", CVAR_NONE};


/*
=================
StringToFilter
=================
*/
static qboolean StringToFilter (const char *s, ipfilter_t *f)
{
	char	num[128];
	int		i, j;
	byte	b[4];
	byte	m[4];

	for (i = 0; i < 4; i++)
	{
		b[i] = 0;
		m[i] = 0;
	}

	for (i = 0; i < 4; i++)
	{
		if (*s < '0' || *s > '9')
		{
			Con_Printf ("Bad filter address: %s\n", s);
			return false;
		}

		j = 0;
		while (*s >= '0' && *s <= '9')
		{
			num[j++] = *s++;
		}
		num[j] = 0;
		b[i] = atoi(num);
		if (b[i] != 0)
			m[i] = 255;

		if (!*s)
			break;
		s++;
	}

	memcpy (&f->mask, m, 4);
	memcpy (&f->compare, b, 4);

	return true;
}


/*
=================
SV_AddIP_f
=================
*/
static void SV_AddIP_f (void)
{
	int		i;

	for (i = 0; i < numipfilters; i++)
	{
		if (ipfilters[i].compare == 0xffffffff)
			break;	// free spot
	}

	if (i == numipfilters)
	{
		if (numipfilters == MAX_IPFILTERS)
		{
			Con_Printf ("IP filter list is full\n");
			return;
		}
		numipfilters++;
	}

	if (!StringToFilter (Cmd_Argv(1), &ipfilters[i]))
		ipfilters[i].compare = 0xffffffff;
}


/*
=================
SV_RemoveIP_f
=================
*/
static void SV_RemoveIP_f (void)
{
	ipfilter_t	f;
	int		i, j;

	if (!StringToFilter (Cmd_Argv(1), &f))
		return;

	for (i = 0; i < numipfilters; i++)
	{
		if (ipfilters[i].mask == f.mask && ipfilters[i].compare == f.compare)
		{
			for (j = i+1; j < numipfilters; j++)
				ipfilters[j-1] = ipfilters[j];
			numipfilters--;
			Con_Printf ("Removed.\n");
			return;
		}
	}

	Con_Printf ("Didn't find %s.\n", Cmd_Argv(1));
}


/*
=================
SV_ListIP_f
=================
*/
static void SV_ListIP_f (void)
{
	int		i;
	byte	*b;

	Con_Printf ("Filter list:\n");
	for (i = 0; i < numipfilters; i++)
	{
		b = (byte *)&ipfilters[i].compare;
		Con_Printf ("%3i.%3i.%3i.%3i\n", b[0], b[1], b[2], b[3]);
	}
}


/*
=================
SV_WriteIP_f
=================
*/
static void SV_WriteIP_f (void)
{
	FILE	*f;
	const char	*name;
	byte	*b;
	int	i;

	name = FS_MakePath(FS_USERDIR, NULL, "listip.cfg");
	Con_Printf ("Writing %s.\n", name);

	f = fopen (name, "wb");
	if (!f)
	{
		Con_Printf ("Couldn't open %s\n", name);
		return;
	}

	for (i = 0; i < numipfilters; i++)
	{
		b = (byte *)&ipfilters[i].compare;
		fprintf (f, "addip %i.%i.%i.%i\n", b[0], b[1], b[2], b[3]);
	}

	fclose (f);
}


/*
=================
SV_SendBan
=================
*/
static void SV_SendBan (void)
{
	static byte data[] = { 0xff, 0xff, 0xff, 0xff, A2C_PRINT,
		'\n', 'b', 'a', 'n', 'n', 'e', 'd', '.', '\n', '\0' };

	NET_SendPacket (15, data, &net_from);
}


/*
=================
SV_FilterPacket
=================
*/
static qboolean SV_FilterPacket (void)
{
	int		i;
	unsigned int	in;

	memcpy (&in, net_from.ip, 4);

	for (i = 0; i < numipfilters; i++)
	{
		if ( (in & ipfilters[i].mask) == ipfilters[i].compare)
			return filterban.integer;
	}

	return !filterban.integer;
}


//============================================================================

/*
=================
SV_ReadPackets
=================
*/
static void SV_ReadPackets (void)
{
	int			i;
	client_t	*cl;

	while (NET_GetPacket ())
	{
		if (SV_FilterPacket ())
		{
			SV_SendBan ();	// tell them we aren't listening...
			continue;
		}

		// check for connectionless packet (0xffffffff) first
		if (*(int *)net_message.data == -1)
		{
			SV_ConnectionlessPacket ();
			continue;
		}

		// check for packets from connected clients
		for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
		{
			if (cl->state == cs_free)
				continue;
			if (!NET_CompareAdr (&net_from, &cl->netchan.remote_address))
				continue;
			if (Netchan_Process(&cl->netchan))
			{	// this is a valid, sequenced packet, so process it
				svs.stats.packets++;
				cl->send_message = true;	// reply at end of frame
				if (cl->state != cs_zombie)
					SV_ExecuteClientMessage (cl);
			}
			break;
		}

		if (i != MAX_CLIENTS)
			continue;

		// packet is not from a known client
		//	Con_Printf ("%s:sequenced packet without connection\n", NET_AdrToString(&net_from));
	}
}


/*
==================
SV_CheckTimeouts

If a packet has not been received from a client in timeout.value
seconds, drop the conneciton.

When a client is normally dropped, the client_t goes into a zombie state
for a few seconds to make sure any final reliable message gets resent
if necessary
==================
*/
static void SV_CheckTimeouts (void)
{
	int		i;
	client_t	*cl;
	float	droptime;

	droptime = realtime - timeout.value;

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if ( (cl->state == cs_connected || cl->state == cs_spawned)
			&& cl->netchan.last_received < droptime)
		{
			SV_BroadcastPrintf (PRINT_HIGH, "%s timed out\n", cl->name);
			SV_DropClient (cl);
			cl->state = cs_free;	// don't bother with zombie state
		}
		if (cl->state == cs_zombie && realtime - cl->connection_started > zombietime.value)
		{
			cl->state = cs_free;	// can now be reused
		}
	}
}


/*
===================
SV_GetConsoleCommands

Add them exactly as if they had been typed at the console
===================
*/
static void SV_GetConsoleCommands (void)
{
	const char	*cmd;

	while (1)
	{
		cmd = Sys_ConsoleInput ();
		if (!cmd)
			break;
		Cbuf_AddText (cmd);
	}
}


/*
===================
SV_CheckVars

===================
*/
static void SV_CheckVars (void)
{
	int	v;

	if (! ((password.flags | spectator_password.flags) & CVAR_CHANGED))
		return;

	password.flags &= ~CVAR_CHANGED;
	spectator_password.flags &= ~CVAR_CHANGED;

	v = 0;
	if (password.string[0] && strcmp(password.string, "none"))
		v |= 1;
	if (spectator_password.string[0] && strcmp(spectator_password.string, "none"))
		v |= 2;

	Con_Printf ("Updated needpass.\n");
	if (!v)
		Info_SetValueForKey (svs.info, "needpass", "", MAX_SERVERINFO_STRING);
	else
		Info_SetValueForKey (svs.info, "needpass", va("%i",v), MAX_SERVERINFO_STRING);
}


/*
==================
SV_Frame

==================
*/
void SV_Frame (float time)
{
	static double	start, end;

	start = Sys_DoubleTime ();
	svs.stats.idle += start - end;

// keep the random time dependent
	rand ();

// decide the simulation time
	realtime += time;
	sv.time += time;

// check timeouts
	SV_CheckTimeouts ();

// toggle the log buffer if full
	SV_CheckLog ();

// move autonomous things around if enough time has passed
	SV_Physics ();

// get packets
	SV_ReadPackets ();

// check for commands typed to the host
	SV_GetConsoleCommands ();

// process console commands
	Cbuf_Execute ();

	SV_CheckVars ();

// send messages back to the clients that had packets read this frame
	SV_SendClientMessages ();

// send a heartbeat to the master if needed
	Master_Heartbeat ();

// collect timing statistics
	end = Sys_DoubleTime ();
	svs.stats.active += end-start;
	if (++svs.stats.count == STATFRAMES)
	{
		svs.stats.latched_active = svs.stats.active;
		svs.stats.latched_idle = svs.stats.idle;
		svs.stats.latched_packets = svs.stats.packets;
		svs.stats.active = 0;
		svs.stats.idle = 0;
		svs.stats.packets = 0;
		svs.stats.count = 0;
	}
}


/* cvar callback functions : */
static void SV_Callback_Serverinfo (cvar_t *var)
{
	Info_SetValueForKey (svs.info, var->name, var->string, MAX_SERVERINFO_STRING);
	SV_BroadcastCommand ("fullserverinfo \"%s\"\n", svs.info);
}

/*
===============
SV_InitLocal
===============
*/
static void SV_InitLocal (void)
{
	int		i;

	SV_InitOperatorCommands	();
	SV_UserInit ();

	Cvar_RegisterVariable (&developer);
	if (COM_CheckParm("-developer"))
	{
		Cvar_Set ("developer", "1");
		Cvar_LockVar ("developer");
	}

	Cvar_RegisterVariable (&sys_nostdout);

	Cvar_RegisterVariable (&rcon_password);
	Cvar_RegisterVariable (&password);
	Cvar_RegisterVariable (&spectator_password);

	Cvar_RegisterVariable (&sv_mintic);
	Cvar_RegisterVariable (&sv_maxtic);

	Cvar_SetCallback (&deathmatch, SV_Callback_Serverinfo);
	Cvar_SetCallback (&coop, SV_Callback_Serverinfo);
	Cvar_SetCallback (&fraglimit, SV_Callback_Serverinfo);
	Cvar_SetCallback (&timelimit, SV_Callback_Serverinfo);
	Cvar_SetCallback (&teamplay, SV_Callback_Serverinfo);
	Cvar_SetCallback (&samelevel, SV_Callback_Serverinfo);
	Cvar_SetCallback (&maxclients, SV_Callback_Serverinfo);
	Cvar_SetCallback (&maxspectators, SV_Callback_Serverinfo);
	Cvar_SetCallback (&randomclass, SV_Callback_Serverinfo);
	Cvar_SetCallback (&damageScale, SV_Callback_Serverinfo);
	Cvar_SetCallback (&shyRespawn, SV_Callback_Serverinfo);
	Cvar_SetCallback (&spartanPrint, SV_Callback_Serverinfo);
	Cvar_SetCallback (&meleeDamScale, SV_Callback_Serverinfo);
	Cvar_SetCallback (&manaScale, SV_Callback_Serverinfo);
	Cvar_SetCallback (&tomeMode, SV_Callback_Serverinfo);
	Cvar_SetCallback (&tomeRespawn, SV_Callback_Serverinfo);
	Cvar_SetCallback (&w2Respawn, SV_Callback_Serverinfo);
	Cvar_SetCallback (&altRespawn, SV_Callback_Serverinfo);
	Cvar_SetCallback (&fixedLevel, SV_Callback_Serverinfo);
	Cvar_SetCallback (&autoItems, SV_Callback_Serverinfo);
	Cvar_SetCallback (&dmMode, SV_Callback_Serverinfo);
	Cvar_SetCallback (&easyFourth, SV_Callback_Serverinfo);
	Cvar_SetCallback (&patternRunner, SV_Callback_Serverinfo);
	Cvar_SetCallback (&spawn, SV_Callback_Serverinfo);
	Cvar_SetCallback (&hostname, SV_Callback_Serverinfo);
	Cvar_SetCallback (&noexit, SV_Callback_Serverinfo);
	Cvar_SetCallback (&sv_maxspeed, SV_Callback_Serverinfo);

	Cvar_RegisterVariable (&fraglimit);
	Cvar_RegisterVariable (&timelimit);
	Cvar_RegisterVariable (&teamplay);
	Cvar_RegisterVariable (&samelevel);
	Cvar_RegisterVariable (&maxclients);
	Cvar_RegisterVariable (&maxspectators);
	Cvar_RegisterVariable (&hostname);
	Cvar_RegisterVariable (&skill);
	Cvar_RegisterVariable (&coop);
	Cvar_RegisterVariable (&deathmatch);
	Cvar_RegisterVariable (&randomclass);
	Cvar_RegisterVariable (&damageScale);
	Cvar_RegisterVariable (&meleeDamScale);
	Cvar_RegisterVariable (&shyRespawn);
	Cvar_RegisterVariable (&spartanPrint);
	Cvar_RegisterVariable (&manaScale);
	Cvar_RegisterVariable (&tomeMode);
	Cvar_RegisterVariable (&tomeRespawn);
	Cvar_RegisterVariable (&w2Respawn);
	Cvar_RegisterVariable (&altRespawn);
	Cvar_RegisterVariable (&fixedLevel);
	Cvar_RegisterVariable (&autoItems);
	Cvar_RegisterVariable (&dmMode);
	Cvar_RegisterVariable (&easyFourth);
	Cvar_RegisterVariable (&patternRunner);
	Cvar_RegisterVariable (&spawn);
	Cvar_RegisterVariable (&noexit);

	Cvar_RegisterVariable (&timeout);
	Cvar_RegisterVariable (&zombietime);

	Cvar_RegisterVariable (&sv_maxvelocity);
	Cvar_RegisterVariable (&sv_gravity);
	Cvar_RegisterVariable (&sv_stopspeed);
	Cvar_RegisterVariable (&sv_maxspeed);
	Cvar_RegisterVariable (&sv_spectatormaxspeed);
	Cvar_RegisterVariable (&sv_accelerate);
	Cvar_RegisterVariable (&sv_airaccelerate);
	Cvar_RegisterVariable (&sv_wateraccelerate);
	Cvar_RegisterVariable (&sv_friction);
	Cvar_RegisterVariable (&sv_waterfriction);

	Cvar_RegisterVariable (&sv_aim);

	Cvar_RegisterVariable (&filterban);

	Cvar_RegisterVariable (&allow_download);
	Cvar_RegisterVariable (&allow_download_skins);
	Cvar_RegisterVariable (&allow_download_models);
	Cvar_RegisterVariable (&allow_download_sounds);
	Cvar_RegisterVariable (&allow_download_maps);

	Cvar_RegisterVariable (&sv_highchars);

	Cvar_RegisterVariable (&sv_phs);
	Cvar_RegisterVariable (&sv_namedistance);

	Cvar_RegisterVariable (&sv_ce_scale);
	Cvar_RegisterVariable (&sv_ce_max_size);

	Cmd_AddCommand ("addip", SV_AddIP_f);
	Cmd_AddCommand ("removeip", SV_RemoveIP_f);
	Cmd_AddCommand ("listip", SV_ListIP_f);
	Cmd_AddCommand ("writeip", SV_WriteIP_f);

	for (i = 0; i < MAX_MODELS; i++)
		sprintf (localmodels[i], "*%i", i);

	Info_SetValueForStarKey (svs.info, "*version", va("%4.2f", ENGINE_VERSION), MAX_SERVERINFO_STRING);

	// init fraglog stuff
	svs.logsequence = 1;
	svs.logtime = realtime;
	SZ_Init (&svs.log[0], svs.log_buf[0], sizeof(svs.log_buf[0]));
	SZ_Init (&svs.log[1], svs.log_buf[1], sizeof(svs.log_buf[1]));
	svs.log[0].allowoverflow = true;
	svs.log[1].allowoverflow = true;
}


//============================================================================

/*
================
Master_Heartbeat

Send a message to the master every few minutes to
let it know we are alive, and log information
================
*/
#define	HEARTBEAT_SECONDS	300
void Master_Heartbeat (void)
{
	char	text[32];
	int	i, active;

	if (realtime - svs.last_heartbeat < HEARTBEAT_SECONDS)
		return;		// not time to send yet

	svs.last_heartbeat = realtime;

	//
	// count active users
	//
	active = 0;
	for (i = 0; i < MAX_CLIENTS; i++)
	{
		if (svs.clients[i].state == cs_connected || svs.clients[i].state == cs_spawned )
			active++;
	}

	svs.heartbeat_sequence++;
	q_snprintf (text, sizeof(text), "%c\n%i\n%i\n", S2M_HEARTBEAT,
			svs.heartbeat_sequence, active);

	// send to group master
	for (i = 0; i < MAX_MASTERS; i++)
	{
		if (master_adr[i].port)
		{
			Con_Printf ("Sending heartbeat to %s\n", NET_AdrToString (&master_adr[i]));
			NET_SendPacket (strlen(text), text, &master_adr[i]);
		}
	}
}


/*
=================
Master_Shutdown

Informs all masters that this server is going down
=================
*/
static void Master_Shutdown (void)
{
	static char	text[] = { S2M_SHUTDOWN, '\n', '\0', '\0' };
	int			i;

	// send to group master
	for (i = 0; i < MAX_MASTERS; i++)
	{
		if (master_adr[i].port)
		{
			Con_Printf ("Sending heartbeat to %s\n", NET_AdrToString (&master_adr[i]));
			NET_SendPacket (3, text, &master_adr[i]);
		}
	}
}


/*
=================
SV_ExtractFromUserinfo

Pull specific info from a newly changed userinfo string
into a more C freindly form.
=================
*/
void SV_ExtractFromUserinfo (client_t *cl)
{
	const char	*val;
	char		*p, *q;
	int		i, dupc = 1;
	client_t	*client;
	char		newname[80];	// 80 > 32 == sizeof(cl->name) because we
							// will be trimming below

	// name for C code
	val = Info_ValueForKey (cl->userinfo, "name");

	// trim user name
	q_strlcpy(newname, val, sizeof(newname));
	for (p = newname; *p == ' ' && *p; p++)
		;

	if (p != newname && *p)
	{
		for (q = newname; *p; *q++ = *p++)
			;

		*q = 0;
	}

	for (p = newname + strlen(newname) - 1; p != newname && *p == ' '; p--)
		;

	p[1] = 0;

	if (strcmp(val, newname))
	{
		Info_SetValueForKey (cl->userinfo, "name", newname, MAX_INFO_STRING);
		val = Info_ValueForKey (cl->userinfo, "name");
	}

	if (!val[0] || !q_strcasecmp(val, "console"))
	{
		Info_SetValueForKey (cl->userinfo, "name", "unnamed", MAX_INFO_STRING);
		val = Info_ValueForKey (cl->userinfo, "name");
	}

	// check to see if another user by the same name exists
	while (1)
	{
		for (i = 0, client = svs.clients; i < MAX_CLIENTS; i++, client++)
		{
			if (client->state != cs_spawned || client == cl)
				continue;
			if (!q_strcasecmp(client->name, val))
				break;
		}
		if (i != MAX_CLIENTS)
		{	// dup name
			const char	*ptr = val;

			if (val[0] == '(')
			{
				if (val[2] == ')')
					ptr = val + 3;
				else if (val[3] == ')')
					ptr = val + 4;
			}
			// limit to sizeof(cl->name) here to make it fit
			q_snprintf(newname, sizeof(cl->name), "(%d)%-.40s", dupc++, ptr);
			Info_SetValueForKey (cl->userinfo, "name", newname, MAX_INFO_STRING);
			val = Info_ValueForKey (cl->userinfo, "name");
		}
		else
			break;
	}

	q_strlcpy (cl->name, val, sizeof(cl->name));

	// rate command
	val = Info_ValueForKey (cl->userinfo, "rate");
	if (*val)
	{
		i = atoi(val);
		if (i < 500)
			i = 500;
		if (i > 10000)
			i = 10000;
		cl->netchan.rate = 1.0/i;
	}

	// playerclass command
	val = Info_ValueForKey (cl->userinfo, "playerclass");
	if (*val)
	{
		i = atoi(val);
		if (i > CLASS_DEMON && (dmMode.integer != DM_SIEGE || !SV_PROGS_HAVE_SIEGE))
			i = CLASS_PALADIN;
		if (i < 0 || i > MAX_PLAYER_CLASS || (!cl->portals && i == CLASS_DEMON))
		{
			i = 0;
		}
		cl->next_playerclass = cl->edict->v.next_playerclass = i;

		if (cl->edict->v.health > 0)
		{
			sprintf(newname,"%d",cl->playerclass);
			Info_SetValueForKey (cl->userinfo, "playerclass", newname, MAX_INFO_STRING);
		}
	}

	// msg command
	val = Info_ValueForKey (cl->userinfo, "msg");
	if (*val)
	{
		cl->messagelevel = atoi(val);
	}
}


//============================================================================

/*
====================
SV_InitNet
====================
*/
static void SV_InitNet (void)
{
	int	port;
	int	p;

	port = PORT_SERVER;
	p = COM_CheckParm ("-port");
	if (p && p < com_argc-1)
	{
		port = atoi(com_argv[p+1]);
		Con_Printf ("Port: %i\n", port);
	}
	NET_Init (port);

	Netchan_Init ();

	svs.last_heartbeat = -99999;	// send immediately
}


/*
====================
SV_Init
====================
*/
void SV_Init (void)
{
	int i;

	Sys_Printf ("Host_Init\n");

	i = COM_CheckParm ("-protocol");
	if (i && i < com_argc - 1) {
		switch ((sv_protocol = atoi (com_argv[i + 1]))) {
		case PROTOCOL_VERSION_EXT:
		case PROTOCOL_VERSION:
			Sys_Printf ("Server using protocol %i\n", sv_protocol);
			break;
		default:
			Sys_Error ("Bad protocol version request %i. Accepted values: %i, %i.",
					sv_protocol, PROTOCOL_VERSION, PROTOCOL_VERSION_EXT);
		}
	}

	Memory_Init (host_parms->membase, host_parms->memsize);
	HuffInit ();
	Cbuf_Init ();
	Cmd_Init ();

	COM_Init ();
	FS_Init ();

	PR_Init ();
	Mod_Init ();

	SV_InitNet ();

	SV_InitLocal ();
	Pmove_Init ();

	Hunk_AllocName (0, "-HOST_HUNKLEVEL-");
	host_hunklevel = Hunk_LowMark ();

	host_initialized = true;
	Con_Printf ("Exe: " __TIME__ " " __DATE__ "\n");
	Con_Printf ("%4.1f megabyte heap\n", host_parms->memsize/(1024*1024.0));
	Con_Printf ("======== HexenWorld Initialized ========\n");

	Cvar_UnlockAll ();			/* unlock the early-set cvars after init */

	Cbuf_InsertText ("exec server.cfg\n");
	Cbuf_Execute ();

	Cmd_StuffCmds_f ();				/* process command line arguments */
	Cbuf_Execute ();

	if (sv.state == ss_dead)	/* no map specified on the command line: spawn demo1.map */
		Cmd_ExecuteString ("map demo1", src_command);
	if (sv.state == ss_dead)
		SV_Error ("Couldn't spawn a server");
}

