/*
 * cl.input.c -- builds an intended movement command to send to the server
 *
 * Quake is a trademark of Id Software, Inc., (c) 1996 Id Software, Inc.
 * All rights reserved.
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

/*
===============================================================================

KEY BUTTONS

Continuous button event tracking is complicated by the fact that two different
input sources (say, mouse button 1 and the control key) can both press the
same button, but the button should only be released when both of the
pressing key have been released.

When a key event issues a button command (+forward, +attack, etc), it appends
its key number as a parameter to the command so it can be matched up with
the release.

state bit 0 is the current state of the key
state bit 1 is edge triggered on the up to down transition
state bit 2 is edge triggered on the down to up transition

===============================================================================
*/

kbutton_t	in_mlook, in_klook;
kbutton_t	in_left, in_right, in_forward, in_back;
kbutton_t	in_lookup, in_lookdown, in_moveleft, in_moveright;
kbutton_t	in_strafe, in_speed, in_use, in_jump, in_attack;
kbutton_t	in_up, in_down, in_crouch;
kbutton_t	in_infoplaque;

int		in_impulse;
qboolean	info_up = false;

static void KeyDown (kbutton_t *b)
{
	int		k;
	const char	*c;

	c = Cmd_Argv(1);
	if (c[0])
		k = atoi(c);
	else	k = -1;		// typed manually at the console for continuous down

	if (k == b->down[0] || k == b->down[1])
		return;		// repeating key

	if (!b->down[0])
		b->down[0] = k;
	else if (!b->down[1])
		b->down[1] = k;
	else
	{
		Con_Printf ("Three keys down for a button!\n");
		return;
	}

	if (b->state & 1)
		return;		// still down
	b->state |= 1 + 2;	// down + impulse down
}

static void KeyUp (kbutton_t *b)
{
	int		k;
	const char	*c;

	c = Cmd_Argv(1);
	if (c[0])
	{
		k = atoi(c);
	}
	else
	{ // typed manually at the console, assume for unsticking, so clear all
		b->down[0] = b->down[1] = 0;
		b->state = 4;	// impulse up
		return;
	}

	if (b->down[0] == k)
		b->down[0] = 0;
	else if (b->down[1] == k)
		b->down[1] = 0;
	else	return;		// key up without coresponding down (menu pass through)

	if (b->down[0] || b->down[1])
		return;		// some other key is still holding it down

	if (!(b->state & 1))
		return;		// still up (this should not happen)

	b->state &= ~1;		// now up
	b->state |= 4; 		// impulse up
}

static void IN_KLookDown (void)
{
	KeyDown(&in_klook);
}

static void IN_KLookUp (void)
{
	KeyUp(&in_klook);
}

static void IN_MLookDown (void)
{
	KeyDown(&in_mlook);
}

static void IN_MLookUp (void)
{
	KeyUp(&in_mlook);
	if (!(in_mlook.state & 1) && lookspring.integer)
		V_StartPitchDrift();
}

static void IN_UpDown (void)
{
	KeyDown(&in_up);
}

static void IN_UpUp (void)
{
	KeyUp(&in_up);
}

static void IN_DownDown (void)
{
	KeyDown(&in_down);
}

static void IN_DownUp (void)
{
	KeyUp(&in_down);
}

static void IN_LeftDown (void)
{
	KeyDown(&in_left);
}

static void IN_LeftUp (void)
{
	KeyUp(&in_left);
}

static void IN_RightDown (void)
{
	KeyDown(&in_right);
}

static void IN_RightUp (void)
{
	KeyUp(&in_right);
}

static void IN_ForwardDown (void)
{
	KeyDown(&in_forward);
}

static void IN_ForwardUp (void)
{
	KeyUp(&in_forward);
}

static void IN_BackDown (void)
{
	KeyDown(&in_back);
}

static void IN_BackUp (void)
{
	KeyUp(&in_back);
}

static void IN_LookupDown (void)
{
	KeyDown(&in_lookup);
}

static void IN_LookupUp (void)
{
	KeyUp(&in_lookup);
}

static void IN_LookdownDown (void)
{
	KeyDown(&in_lookdown);
}

static void IN_LookdownUp (void)
{
	KeyUp(&in_lookdown);
}

static void IN_MoveleftDown (void)
{
	KeyDown(&in_moveleft);
}

static void IN_MoveleftUp (void)
{
	KeyUp(&in_moveleft);
}

static void IN_MoverightDown (void)
{
	KeyDown(&in_moveright);
}

static void IN_MoverightUp (void)
{
	KeyUp(&in_moveright);
}

static void IN_SpeedDown (void)
{
	KeyDown(&in_speed);
}

static void IN_SpeedUp (void)
{
	KeyUp(&in_speed);
}

static void IN_StrafeDown (void)
{
	KeyDown(&in_strafe);
}

static void IN_StrafeUp (void)
{
	KeyUp(&in_strafe);
}

static void IN_AttackDown (void)
{
	KeyDown(&in_attack);
}

static void IN_AttackUp (void)
{
	KeyUp(&in_attack);
}

static void IN_UseDown (void)
{
	KeyDown(&in_use);
}

static void IN_UseUp (void)
{
	KeyUp(&in_use);
}

static void IN_JumpDown (void)
{
	KeyDown(&in_jump);
}

static void IN_JumpUp (void)
{
	KeyUp(&in_jump);
}

static void IN_Impulse (void)
{
	in_impulse = atoi(Cmd_Argv(1));
}

static void IN_CrouchDown (void)
{
	if (Key_GetDest() == key_game)
	{
//		int state = in_crouch.state;
		KeyDown(&in_crouch);
//		if (!(state & 1) && (in_crouch.state & 1))
//			in_impulse = 22;
	}
}

static void IN_CrouchUp (void)
{
//	if (Key_GetDest() == key_game)
//	{
//		int state = in_crouch.state;
		KeyUp(&in_crouch);
//		if ((state & 1) && !(in_crouch.state & 1))
//			in_impulse = 22;
//	}
}

static void IN_infoPlaqueUp (void)
{
// lower the plaque
//	if (Key_GetDest() == key_game)
//	{
		info_up = false;
		KeyUp(&in_infoplaque);
//	}
}

static void IN_infoPlaqueDown (void)
{
// show the plaque
	if (Key_GetDest() == key_game)
	{
		info_up = true;
		KeyDown(&in_infoplaque);
	}
}

/*
===============
CL_KeyState

Returns 0.25 if a key was pressed and released during the frame,
0.5 if it was pressed and held
0 if held then released, and
1.0 if held for the entire time
===============
*/
static float CL_KeyState (kbutton_t *key)
{
	float		val;
	qboolean	impulsedown, impulseup, down;

	impulsedown = key->state & 2;
	impulseup = key->state & 4;
	down = key->state & 1;
	val = 0;

	if (impulsedown && !impulseup)
	{
		if (down)
			val = 0.5;	// pressed and held this frame
		else	val = 0;
	}
	if (impulseup && !impulsedown)
	{
		if (down)
			val = 0;
		else	val = 0;	// released this frame
	}
	if (!impulsedown && !impulseup)
	{
		if (down)
			val = 1.0;	// held the entire frame
		else	val = 0;	// up the entire frame
	}
	if (impulsedown && impulseup)
	{
		if (down)
			val = 0.75;	// released and re-pressed this frame
		else	val = 0.25;	// pressed and released this frame
	}

	key->state &= 1;		// clear impulses

	return val;
}


//==========================================================================

cvar_t	cl_upspeed = {"cl_upspeed", "200", CVAR_NONE};
cvar_t	cl_forwardspeed = {"cl_forwardspeed", "200", CVAR_ARCHIVE};
cvar_t	cl_backspeed = {"cl_backspeed", "200", CVAR_ARCHIVE};
cvar_t	cl_sidespeed = {"cl_sidespeed", "225", CVAR_NONE};
cvar_t	cl_movespeedkey = {"cl_movespeedkey", "2.0", CVAR_NONE};
cvar_t	cl_yawspeed = {"cl_yawspeed", "140", CVAR_NONE};
cvar_t	cl_pitchspeed = {"cl_pitchspeed", "150", CVAR_NONE};
cvar_t	cl_anglespeedkey = {"cl_anglespeedkey", "1.5", CVAR_NONE};


/*
================
CL_AdjustAngles

Moves the local angle positions
================
*/
static void CL_AdjustAngles (void)
{
	float	speed;
	float	up, down;

	if (in_speed.state & 1)
		speed = host_frametime * cl_anglespeedkey.value;
	else	speed = host_frametime;

	if (!(in_strafe.state & 1))
	{
		cl.viewangles[YAW] -= speed*cl_yawspeed.value*CL_KeyState (&in_right);
		cl.viewangles[YAW] += speed*cl_yawspeed.value*CL_KeyState (&in_left);
		cl.viewangles[YAW] = anglemod(cl.viewangles[YAW]);
	}
	if (in_klook.state & 1)
	{
		V_StopPitchDrift ();
		cl.viewangles[PITCH] -= speed*cl_pitchspeed.value * CL_KeyState (&in_forward);
		cl.viewangles[PITCH] += speed*cl_pitchspeed.value * CL_KeyState (&in_back);
	}

// FIXME: This is a cheap way of doing this, it belongs in V_CalcViewRoll
// but I don't see where I can get the yaw velocity.
	cl.idealroll = 0;
	if (cl.v.movetype == MOVETYPE_FLY)
	{
		if (CL_KeyState (&in_left) != 0)
			cl.idealroll = -10;
		else if (CL_KeyState (&in_right) != 0)
			cl.idealroll = 10;
	}

	up = CL_KeyState (&in_lookup);
	down = CL_KeyState(&in_lookdown);

	cl.viewangles[PITCH] -= speed*cl_pitchspeed.value * up;
	cl.viewangles[PITCH] += speed*cl_pitchspeed.value * down;

	if (up || down)
		V_StopPitchDrift ();

	if (cl.viewangles[PITCH] > 80)
		cl.viewangles[PITCH] = 80;
	if (cl.viewangles[PITCH] < -70)
		cl.viewangles[PITCH] = -70;

	if (cl.viewangles[ROLL] > 50)
		cl.viewangles[ROLL] = 50;
	if (cl.viewangles[ROLL] < -50)
		cl.viewangles[ROLL] = -50;
}

/*
================
CL_BaseMove

Send the intended movement message to the server
================
*/
void CL_BaseMove (usercmd_t *cmd)
{
	if (cls.signon != SIGNONS)
		return;
	if (cl.v.cameramode)	// stuck in a different camera so don't move
	{
		memset (cmd, 0, sizeof(*cmd));
		return;
	}

	CL_AdjustAngles ();

	memset (cmd, 0, sizeof(*cmd));

	if (in_strafe.state & 1)
	{
//		cmd->sidemove += cl_sidespeed.value * CL_KeyState (&in_right);
//		cmd->sidemove -= cl_sidespeed.value * CL_KeyState (&in_left);
		cmd->sidemove += 225 * CL_KeyState (&in_right);
		cmd->sidemove -= 225 * CL_KeyState (&in_left);
	}

//	cmd->sidemove += cl_sidespeed.value * CL_KeyState (&in_moveright);
//	cmd->sidemove -= cl_sidespeed.value * CL_KeyState (&in_moveleft);
	cmd->sidemove += 225 * CL_KeyState (&in_moveright);
	cmd->sidemove -= 225 * CL_KeyState (&in_moveleft);

	cmd->upmove += cl_upspeed.value * CL_KeyState (&in_up);
	cmd->upmove -= cl_upspeed.value * CL_KeyState (&in_down);

	if (! (in_klook.state & 1))
	{
//		cmd->forwardmove += cl_forwardspeed.value * CL_KeyState (&in_forward);
		cmd->forwardmove += 200 * CL_KeyState (&in_forward);
//		cmd->forwardmove -= cl_backspeed.value * CL_KeyState (&in_back);
		cmd->forwardmove -= 200 * CL_KeyState (&in_back);
	}

// adjust for speed key, but not if "always run" has been chosen
// speed key now acts as slow key when always run is chosen - OS
//	if ( ((cl_forwardspeed.value > 200) ||(in_speed.state & 1))
	if ( ((cl_forwardspeed.value > 200) ^ (in_speed.state & 1))
					     && (cl.v.hasted <= 1) )
	{
		cmd->forwardmove *= cl_movespeedkey.value;
		cmd->sidemove *= cl_movespeedkey.value;
		cmd->upmove *= cl_movespeedkey.value;
	}

// Hasted player?
	if (cl.v.hasted)
	{
		cmd->forwardmove = cmd->forwardmove * cl.v.hasted;
		cmd->sidemove = cmd->sidemove * cl.v.hasted;
		cmd->upmove = cmd->upmove * cl.v.hasted;
	}

	cmd->lightlevel = cl.light_level;
}


/*
==============
CL_SendMove
==============
*/
void CL_SendMove (const usercmd_t *cmd)
{
	int	i, bits;
	sizebuf_t	buf;
	byte	data[128];

	SZ_Init (&buf, data, sizeof(data));

	cl.cmd = *cmd;

// send the movement message
	MSG_WriteByte (&buf, clc_frame);
	MSG_WriteByte (&buf, cl.reference_frame);
	MSG_WriteByte (&buf, cl.current_sequence);

	MSG_WriteByte (&buf, clc_move);

	MSG_WriteFloat (&buf, cl.mtime[0]);	// so server can get ping times

	for (i = 0; i < 3; i++)
		MSG_WriteAngle (&buf, cl.viewangles[i]);

	MSG_WriteShort (&buf, cmd->forwardmove);
	MSG_WriteShort (&buf, cmd->sidemove);
	MSG_WriteShort (&buf, cmd->upmove);

// send button bits
	bits = 0;

	if (in_attack.state & 3)
		bits |= 1;
	in_attack.state &= ~2;

	if (in_jump.state & 3)
		bits |= 2;
	in_jump.state &= ~2;

	if (in_crouch.state & 1)
		bits |= 4;

	MSG_WriteByte (&buf, bits);

	MSG_WriteByte (&buf, in_impulse);
	in_impulse = 0;

// light level
	MSG_WriteByte (&buf, cmd->lightlevel);

// deliver the message
	if (cls.demoplayback)
		return;

// always dump the first two message, because it may
// contain leftover inputs from the last level
	if (++cl.movemessages <= 2)
		return;

	if (NET_SendUnreliableMessage (cls.netcon, &buf) == -1)
	{
		Con_Printf ("%s: lost server connection\n", __thisfunc__);
		CL_Disconnect ();
	}
}


/*
============
CL_InitInput
============
*/
void CL_InitInput (void)
{
	Cmd_AddCommand ("+moveup",IN_UpDown);
	Cmd_AddCommand ("-moveup",IN_UpUp);
	Cmd_AddCommand ("+movedown",IN_DownDown);
	Cmd_AddCommand ("-movedown",IN_DownUp);
	Cmd_AddCommand ("+left",IN_LeftDown);
	Cmd_AddCommand ("-left",IN_LeftUp);
	Cmd_AddCommand ("+right",IN_RightDown);
	Cmd_AddCommand ("-right",IN_RightUp);
	Cmd_AddCommand ("+forward",IN_ForwardDown);
	Cmd_AddCommand ("-forward",IN_ForwardUp);
	Cmd_AddCommand ("+back",IN_BackDown);
	Cmd_AddCommand ("-back",IN_BackUp);
	Cmd_AddCommand ("+lookup", IN_LookupDown);
	Cmd_AddCommand ("-lookup", IN_LookupUp);
	Cmd_AddCommand ("+lookdown", IN_LookdownDown);
	Cmd_AddCommand ("-lookdown", IN_LookdownUp);
	Cmd_AddCommand ("+strafe", IN_StrafeDown);
	Cmd_AddCommand ("-strafe", IN_StrafeUp);
	Cmd_AddCommand ("+moveleft", IN_MoveleftDown);
	Cmd_AddCommand ("-moveleft", IN_MoveleftUp);
	Cmd_AddCommand ("+moveright", IN_MoverightDown);
	Cmd_AddCommand ("-moveright", IN_MoverightUp);
	Cmd_AddCommand ("+speed", IN_SpeedDown);
	Cmd_AddCommand ("-speed", IN_SpeedUp);
	Cmd_AddCommand ("+attack", IN_AttackDown);
	Cmd_AddCommand ("-attack", IN_AttackUp);
	Cmd_AddCommand ("+use", IN_UseDown);
	Cmd_AddCommand ("-use", IN_UseUp);
	Cmd_AddCommand ("+jump", IN_JumpDown);
	Cmd_AddCommand ("-jump", IN_JumpUp);
	Cmd_AddCommand ("impulse", IN_Impulse);
	Cmd_AddCommand ("+klook", IN_KLookDown);
	Cmd_AddCommand ("-klook", IN_KLookUp);
	Cmd_AddCommand ("+mlook", IN_MLookDown);
	Cmd_AddCommand ("-mlook", IN_MLookUp);

	Cmd_AddCommand ("+crouch", IN_CrouchDown);
	Cmd_AddCommand ("-crouch", IN_CrouchUp);

	Cmd_AddCommand ("+infoplaque", IN_infoPlaqueDown);
	Cmd_AddCommand ("-infoplaque", IN_infoPlaqueUp);
}

/*
============
CL_ClearStates
============
*/
#if 0
void CL_ClearStates (void)
{
	in_mlook.state = 0;
	in_klook.state = 0;
	in_left.state = 0;
	in_right.state = 0;
	in_forward.state = 0;
	in_back.state = 0;
	in_lookup.state = 0;
	in_lookdown.state = 0;
	in_moveleft.state = 0;
	in_moveright.state = 0;
	in_strafe.state = 0;
	in_speed.state = 0;
	in_use.state = 0;
	in_jump.state = 0;
	in_attack.state = 0;
	in_up.state = 0;
	in_down.state = 0;
	in_crouch.state = 0;
}
#endif

