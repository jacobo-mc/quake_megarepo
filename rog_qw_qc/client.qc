
// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

void(entity targ, entity attacker) dmatch_score;

float   modelindex_eyes, modelindex_player;

float allITpowerups = 7864320;  //IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD
float allIT2powerups = 192;             //IT2_SHIELD | IT2_ANTIGRAV


// OSK--
// ZOID: with several effects doing the dimlight thing, they just can't
// turn it off.  Do not set self.effects with EF_DIMLIGHT directly.  This
// will automatically do it when CheckPowerups is called
// EF_DIMLIGHT is used;
// 1. Invincible (Pentagram)
// 2. Super Damage (Quad Power)
// 3. Having Flag in Capture
// self is player
void () CheckDimLight = {
	local float flag;

	flag = 0;
	// invincable
	if (self.invincible_finished > time)
		flag = 1;
	// quad
	else if (self.super_damage_finished > time)
		flag = 1;
	// flag
	else if (self.ctf_flags & (CTF_FLAG_TEAM1 | CTF_FLAG_TEAM2))
		flag = 1;

	if (flag)
		self.effects = self.effects | EF_DIMLIGHT;
	else
		self.effects = self.effects - (self.effects & EF_DIMLIGHT);
};
// --OSK

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

string nextmap;

float   intermission_running;
float   intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
	self.angles = self.mangle;      // so C can get at it
};



void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		parm14 = self.team;    // Save the current team of the player
		return;
	}
 
// remove items
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 |
								IT_INVULNERABILITY | IT_SUIT | 
								IT_QUAD | IT_INVISIBILITY) );
								
	self.items2 = self.items2 - (self.items2 & 
					(IT2_ANTIGRAV | IT2_SHIELD | IT2_SUPERHEALTH));
	
// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;

	
	teamplay = stof(infokey(world, "teamplay"));
	if (teamplay >= TEAM_CTF)       // don't carry items between levels in CTF
		SetNewParms();
	else 
	{
		parm1 = self.items;
		parm2 = self.health;
		parm3 = self.armorvalue;
		if (self.ammo_shells1 < 25)
			parm4 = 25;
		else
			parm4 = self.ammo_shells1;
		parm5 = self.ammo_nails1;
		parm6 = self.ammo_rockets1;
		parm7 = self.ammo_cells1;
		parm8 = self.weapon;
		parm9 = self.armortype * 100;
		parm10 = self.items2;
		parm11 = self.ammo_lava_nails;
		parm12 = self.ammo_multi_rockets;
		parm13 = self.ammo_plasma;
	}
	parm14 = self.team; // save team setting
};

void() SetNewParms =
{
//ZOID--
	if (deathmatch && teamplay >= TEAM_CTF) {
		parm1 = IT_SHOTGUN | IT_AXE | IT_GRAPPLE;
		parm10 = IT2_ARMOR1;
		parm3 = 50;
		parm9 = 30;
	} else {
		parm1 = IT_SHOTGUN | IT_AXE;
		parm3 = 0;
		parm9 = 0;
		parm10 = 0;
	}
//--ZOID
	parm2 = 100;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm11 = 0;
	parm12 = 0;
	parm13 = 0;
//ZOID--
	parm14 = -1;            // CTF: reset current team selection
//--ZOID
};

void() DecodeLevelParms =
{
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();         // take away all stuff on starting new episode
	}
	if (world.model == "maps/r2m1.bsp" && !deathmatch)
		SetNewParms ();
	// PGM - 01/29 change to have level 8 reset all your stuff.

	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells1 = parm4;
	self.ammo_nails1 = parm5;
	self.ammo_rockets1 = parm6;
	self.ammo_cells1 = parm7;
	// cute bug, if grapple was selected, it still will be on level change
	if (parm8 == IT_GRAPPLE && teamplay < TEAM_CTF)
		self.weapon = IT_AXE;
	else
		self.weapon = parm8;
	self.armortype = parm9 * 0.01;
	self.items2 = parm10;
	self.ammo_lava_nails = parm11;
	self.ammo_multi_rockets = parm12;
	self.ammo_plasma = parm13;
//ZOID--
	if (TeamColorIsLegal(parm14)) {
		self.team = parm14;
		TeamSetSkin();
	}
//--ZOID
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local   entity spot;
	local   float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{       // pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
};


void() GotoNextMap =
{
	local string newmap;

//ZOID: 12-13-96, samelevel is overloaded, only 1 works for same level
	if (cvar("samelevel") == 1)     // if samelevel is set, stay on same level
		changelevel (mapname);
	else {
		// configurable map lists, see if the current map exists as a
		// serverinfo/localinfo var
		newmap = infokey(world, mapname);
		if (newmap != "")
			changelevel (newmap);
		else
			changelevel (nextmap);
	}
};



/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	GotoNextMap ();
};

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void() execute_changelevel =
{
	local entity    pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	pos = FindIntermission ();

// play intermission music
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);

	WriteByte (MSG_ALL, SVC_INTERMISSION);
	WriteCoord (MSG_ALL, pos.origin_x);
	WriteCoord (MSG_ALL, pos.origin_y);
	WriteCoord (MSG_ALL, pos.origin_z);
	WriteAngle (MSG_ALL, pos.mangle_x);
	WriteAngle (MSG_ALL, pos.mangle_y);
	WriteAngle (MSG_ALL, pos.mangle_z);
	
	other = find (world, classname, "player");
	while (other != world)
	{
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		other = find (other, classname, "player");
	}       

};


void() changelevel_touch =
{
	local entity    pos;

	if (other.classname != "player")
		return;

// if "noexit" is set, blow up the player trying to leave
//ZOID, 12-13-96, noexit isn't supported in QW.  Overload samelevel
//      if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	if ((cvar("samelevel") == 2) || ((cvar("samelevel") == 3) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	bprint (PRINT_HIGH, other.netname);
	bprint (PRINT_HIGH," exited the level\n");
	
	nextmap = self.map;

	SUB_UseTargets ();

	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map) {
		dprint ("chagnelevel trigger doesn't have map");
		self.map = "r2m2";  //there seems to be a bit of a problem with the trigger_changelevel in
					  //r2m1 since the key is "map " not "map" so lets assume that the reason
					  //we can't find a level here is that we are on r2m1 and hardcode r2m2
					  //as the next map whenever there is nothing in the "map" field
	}
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	// make a copy of the dead body for appearances sake
	CopyToBodyQue (self);
	// set default spawn parms
	SetNewParms ();
	// respawn              
	PutClientInServer ();
	// set the skin correctly.
	TeamSetSkin();
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	local entity    vSphere;

// ZOID--
	if (self.suicide_count > 3)
	{
		sprint(self, PRINT_HIGH, "You have suicided too much already.\n");
		return;
	}
    TeamDropFlagOfPlayer(self);
	self.suicide_count = self.suicide_count + 1;
// --ZOID

	if ( tag_token_owner == self)
	{
		self.health = 0;
		self.solid = SOLID_NOT;
		tag_token_drop();
	}

	if ( self.items2 & IT2_V_SPHERE)
	{
		vSphere = find ( world, classname, "Vengeance");
		while (vSphere)
		{
			if ( vSphere.owner == self )
			{
				remove (vSphere);
			}
			vSphere = find(vSphere, classname, "Vengeance");
		}
	}

	bprint (PRINT_MEDIUM, self.netname);
	bprint (PRINT_MEDIUM, " suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	logfrag (self, self);
	self.frags = self.frags - 2;    // extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local   entity spot, newspot, thing;
	local   float   numspots, totalspots;
	local   float   rnum, pcount;
	local   float   rs;
	local entity spots;

	numspots = 0;
	totalspots = 0;

//ZOID--
	local   entity  startspot;
	local   float   t;
//--ZOID

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
// choose a info_player_deathmatch point
	startspot = spot = lastspawn;
	t = 0;
	if (!self.ctf_killed && teamplay >= TEAM_CTF)
	{
		if (self.team == TEAM1)
		{
			startspot = spot = team1_lastspawn;
			t = TEAM1;
		} 
		else if (self.team == TEAM2)
		{
			startspot = spot = team2_lastspawn;
			t = TEAM2;
		}
	}
// ok, find all spots that don't have players nearby

	spots = world;

	if (t == TEAM1)
		spot = find(spot, classname, "info_player_team1");
	else if (t == TEAM2)
		spot = find(spot, classname, "info_player_team2");
	else
		spot = find(spot, classname, "info_player_deathmatch");
		while (spot)
	{
		if (spot == world)
			t = 0;          // pgm fix for ctf in levels w/o ctf support
		else {
			totalspots = totalspots + 1;
	
			thing=findradius(spot.origin, 84);                      pcount = 0;
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
	
			if (pcount == 0) {
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}
				// Get the next spot in the chain
			if (t == TEAM1)
				spot = find(spot, classname, "info_player_team1");
			else if (t == TEAM2)
				spot = find(spot, classname, "info_player_team2");
			else
				spot = find(spot, classname, "info_player_deathmatch");
		}
	}
	totalspots=totalspots - 1;
	if (!numspots) {
		// ack, they are all full, just pick one at random
//              bprint (PRINT_HIGH, "Ackk! All spots are full. Selecting random spawn spot\n");
		totalspots = rint((random() * totalspots));
		spot = find (world, classname, "info_player_deathmatch");       
		while (totalspots > 0) {
			totalspots = totalspots - 1;
			spot = find (spot, classname, "info_player_deathmatch");
		}
		return spot;
	}

// We now have the number of spots available on the map in numspots

// Generate a random number between 1 and numspots

	numspots = numspots - 1;

	numspots = rint((random() * numspots ) );
	
	spot = spots;
	while (numspots > 0) {
		spot = spot.goalentity;
		numspots = numspots - 1;
	}

	return spot;
};

void() DecodeLevelParms;
void() PlayerDie;
void() player_touch;

/*
===========
ValidateUser


============
*/
float(entity e) ValidateUser =
{
/*
	local string    s;
	local string    userclan;
	local float     rank, rankmin, rankmax;

//
// if the server has set "clan1" and "clan2", then it
// is a clan match that will allow only those two clans in
//
	s = serverinfo("clan1");
	if (s)
	{
		userclan = masterinfo(e,"clan");
		if (s == userclan)
			return true;
		s = serverinfo("clan2");
		if (s == userclan)
			return true;
		return false;
	}

//
// if the server has set "rankmin" and/or "rankmax" then
// the users rank must be between those two values
//
	s = masterinfo (e, "rank");
	rank = stof (s);

	s = serverinfo("rankmin");
	if (s)
	{
		rankmin = stof (s);
		if (rank < rankmin)
			return false;
	}
	s = serverinfo("rankmax");
	if (s)
	{
		rankmax = stof (s);
		if (rankmax < rank)
			return false;
	}

	return true;
*/
};


/*
===========
PutClientInServer

called each time a player enters a new level
============
*/
void() PutClientInServer =
{
	local   entity spot;
	local   string  s;

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;                   // initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	self.shield_finished = 0;
	self.antigrav_finished = 0;
	self.gravity = 1;
		
//ZOID--
	self.ctf_lastreturnedflag = -10;
	self.ctf_lastfraggedcarrier = -10;
	self.ctf_flagsince = -10;
	self.ctf_lasthurtcarrier = -10;
//--ZOID

	DecodeLevelParms ();
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;           // turn this way immediately

	self.touch = player_touch;

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

// Mod - Xian (May.20.97)
// Bug where player would have velocity from their last kill

	self.velocity = '0 0 0';

	player_stand1 ();
	
	makevectors(self.angles);
	spawn_tfog (self.origin + v_forward*20);

	//Grapple stuff
	self.on_hook = FALSE;
	self.hook_out = FALSE;

	spawn_tdeath (self.origin, self);

	// Set Rocket Jump Modifiers
	if (stof(infokey(world, "rj")) != 0)
	{                
		rj = stof(infokey(world, "rj"));
	}

	if (deathmatch == 4)
	{
		self.ammo_shells = 0;
		if (stof(infokey(world, "axe")) == 0)
		{
			self.ammo_nails = 255;
			self.ammo_shells = 255;
			self.ammo_rockets = 255;
			self.ammo_cells = 255;
			self.items = self.items | IT_NAILGUN;
			self.items = self.items | IT_SUPER_NAILGUN;
			self.items = self.items | IT_SUPER_SHOTGUN;
			self.items = self.items | IT_ROCKET_LAUNCHER;
//              self.items = self.items | IT_GRENADE_LAUNCHER;
			self.items = self.items | IT_LIGHTNING;
		}
		self.items = self.items - (self.items2 & (IT2_ARMOR1 | IT2_ARMOR2 | IT2_ARMOR3)) + IT2_ARMOR3;
		self.armorvalue = 200;
		self.armortype = 0.8;
		self.health = 250;
		self.items = self.items | IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + 3;
	}

	if (deathmatch == 5)
	{
		self.ammo_nails = 80;
		self.ammo_shells = 30;
		self.ammo_rockets = 10;
		self.ammo_cells = 30;
		self.items = self.items | IT_NAILGUN;
		self.items = self.items | IT_SUPER_NAILGUN;
		self.items = self.items | IT_SUPER_SHOTGUN;
		self.items = self.items | IT_ROCKET_LAUNCHER;
		self.items = self.items | IT_GRENADE_LAUNCHER;
		self.items = self.items | IT_LIGHTNING;
		self.items = self.items - (self.items2 & (IT2_ARMOR1 | IT2_ARMOR2 | IT2_ARMOR3)) + IT2_ARMOR3;
		self.armorvalue = 200;
		self.armortype = 0.8;
		self.health = 200;
		self.items = self.items | IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + 3;
	}

};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
	SpawnRunes();
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void() NextLevel =
{
	local entity o;
	local string newmap;

	if (nextmap != "")
		return; // already done

	if (mapname == "start")
	{
/*
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}
 */
		// PGM 03/02/97 - make it always go to rogue level1 when in our progs
		mapname = "r1m1";

		o = spawn();
		o.map = mapname;
	}
	else
	{
// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start")
		{       // go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{       
	if (timelimit && time >= timelimit)
		NextLevel ();
	
	if (fraglimit && self.frags >= fraglimit)
		NextLevel ();

//ZOID--
	// update team scores? 
	TeamCheckUpdate();
//--ZOID
};

//============================================================================

void() PlayerDeathThink =
{
	local entity    old_self;
	local float             forward;
	
	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else    
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	local vector start, end;
	local float     grav_modifier;

	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;         // don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);       
	self.button2 = 0;

// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

};


/*
===========
WaterMove

============
*/
.float  dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{       // drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
		if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{       
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{       // do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{       // do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{       

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}       
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{       // solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{       // open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;  // safety net
			return;
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	local   float   mspeed, aspeed;
	local   float   r;

	if (intermission_running)
	{
		IntermissionThink ();   // otherwise a button could be missed between
		return;                                 // the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale

	if (earthquake_active)
	{
		if ( self.flags & FL_ONGROUND )
		{
			self.velocity_x = self.velocity_x + 
								(random() * earthquake_intensity * 2) -
								earthquake_intensity;
			self.velocity_y = self.velocity_y + 
								(random() * earthquake_intensity * 2) -
								earthquake_intensity;
			self.velocity_z = self.velocity_z + 
								(random() * earthquake_intensity * 2) -
								earthquake_intensity;
		}
	}


	makevectors (self.v_angle);             // is this still used

      self.deathtype = ""; 

//ZOID--
	// TeamCheckLock performs all necessary teamlock checking, and performs all
	// actions needed.
	if (time - self.lastteamcheck > 1) {
		TeamCheckLock();
		self.lastteamcheck = time;
	}
	
//--ZOID

	CheckMOTD();
	CheckRules ();
	WaterMove ();
/*
	if (self.waterlevel == 2)
		CheckWaterJump ();
*/

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return; // dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// teleporters can force a non-moving pause time        
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if (self.items2 & IT2_ANTIGRAV)
	{
	if ( time > self.AGping )
		{
			sound ( self, CHAN_AUTO, "belt/use.wav", 0.4, ATTN_NORM);
			self. AGping = time + 3;
			if(self. AGping >= (self.antigrav_finished - 3))
				self. AGping = self.antigrav_finished + 3;
		}

	}
	RuneApplyElder(self); // regeneration rune 

	// Track the grapple
	if (self.hook_out)
		GrappleService();
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;    // don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, PRINT_HIGH, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{       // just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
// Handled by CheckDimLight
	    if (self.invincible_finished > time)
			self.effects = self.effects | EF_RED;
//                      self.effects = self.effects | EF_DIMLIGHT;
	      else
			self.effects = self.effects - (self.effects & EF_RED);
//                      self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				if (deathmatch == 4)
					sprint (self, PRINT_HIGH, "OctaPower is wearing off\n");
				else
					sprint (self, PRINT_HIGH, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}         
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{       // just stopped
			self.items = self.items - IT_QUAD;
			if (deathmatch == 4)
			{
				self.ammo_cells = 255;
				self.armorvalue = 1;
				self.armortype = 0.8;
				self.health = 100;
			}
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
// Handled by CheckDimLight
	      if (self.super_damage_finished > time)
			self.effects = self.effects | EF_BLUE;
//                      self.effects = self.effects | EF_DIMLIGHT;
	      else
			self.effects = self.effects - (self.effects & EF_BLUE);
//                      self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}       

// suit 
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;          // don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, PRINT_HIGH, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{       // just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}       

	if(self.shield_finished)
	{
		if ( self.shield_finished < time + 3)
		{
			if (self.shield_time == 1)
			{
				sprint (self, PRINT_HIGH, "Shield failing...\n");
				sound (self, CHAN_AUTO, "shield/fadeout.wav", 1, ATTN_NORM);
				self.shield_time = 0;
			}
			if (self.shield_time < time)
			{
				self.shield_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if ( self.shield_finished < time)
		{
			sprint (self, PRINT_HIGH, "Shield Lost.\n");
			self.shield_finished = 0;
			self.items2 = self.items2 - IT2_SHIELD;
		}
	}

	if(self.antigrav_finished)
	{
		if ( self.antigrav_finished < time + 3)
		{
			if (self.antigrav_time == 1)
			{
				sprint (self, PRINT_HIGH, "Antigrav failing...\n");
				self.antigrav_time = 0;
				sound (self, CHAN_AUTO, "belt/fadeout.wav", 1, ATTN_NORM);
			}
			if (self.antigrav_time < time)
			{
				self.antigrav_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if ( self.antigrav_finished < time)
		{
			sprint (self, PRINT_HIGH, "Antigrav Lost.\n");
			self.antigrav_finished = 0;
			self.items2 = self.items2 - IT2_ANTIGRAV;
			self.gravity = 1.0;
		}
	}
	// Check to see about DIMLIGHT effects
	CheckDimLight();
};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/

void() PlayerPostThink =
{
	local   float   mspeed, aspeed;
	local   float   r;

//dprint ("post think\n");
	if (self.view_ofs == '0 0 0')
		return;         // intermission or finale
	if (self.deadflag)
		return;

// check to see if player landed and play landing sound 
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			self.deathtype = "falling";
			T_Damage (self, world, world, 5); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}

	self.jump_flag = self.velocity_z;

	if ((self.items & allITpowerups) || (self.items2 & allIT2powerups))
		CheckPowerups ();

	W_WeaponFrame ();

};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (PRINT_HIGH, self.netname);
	bprint (PRINT_HIGH, " entered the game\n");
			
//ZOID--
	self.suicide_count = 0;
	self.ctf_killed = 0;

	SetMOTD();

	// If this is our first connection, parm14 is < 0
	// Set lastteam negative.
	if (parm14 < 0 && teamplay > 0 && teamplay != TEAM_DMATCH_TAG)
	{
		if (stof(infokey(world, "gamecfg")) & GAMECFG_USE_COLOR)
			self.team = self.team; // accept joining players color if legal
		else
			self.team = -50; // always reassign
		TeamCheckTeam();
	}
//--ZOID
	
// a client connecting during an intermission can cause problems
	if (intermission_running)
		GotoNextMap ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	// let everyone else know
	bprint (PRINT_HIGH, self.netname);
	bprint (PRINT_HIGH, " left the game with ");
	bprint (PRINT_HIGH, ftos(self.frags));
	bprint (PRINT_HIGH, " frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

	sphere_remove(self);
	if ( tag_token_owner == self)
		tag_token_drop();
	
//ZOID--
    TeamDropFlagOfPlayer(self);
	self.team = -50;
	self.team = 0;
//--ZOID

	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local   float rnum;
	local   string deathstring, deathstring2;
	local   string s;
	local   string attackerteam, targteam;

	rnum = random();
	//ZOID 12-13-96: self.team doesn't work in QW.  Use keys
	attackerteam = infokey(attacker, "team");
	targteam = infokey(targ, "team");

	if (targ.classname == "player")
	{
// ZOID--
		TeamResetCarrier(targ);
// --ZOID
		if (deathmatch > 3)     
		{
			if (targ.deathtype == "selfwater")
			{
				bprint (PRINT_MEDIUM, targ.netname);
				bprint (PRINT_MEDIUM," electrocutes himself.\n ");
				targ.frags = targ.frags - 1;
				return;
			}
		}

		if (attacker.classname == "teledeath")
		{
			bprint (PRINT_MEDIUM,targ.netname);
			bprint (PRINT_MEDIUM," was telefragged by ");
			bprint (PRINT_MEDIUM,attacker.owner.netname);
			bprint (PRINT_MEDIUM,"\n");
			logfrag (attacker.owner, targ);
			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint (PRINT_MEDIUM,"Satan's power deflects ");
			bprint (PRINT_MEDIUM,targ.netname);
			bprint (PRINT_MEDIUM,"'s telefrag\n");

			targ.frags = targ.frags - 1;
			logfrag (targ, targ);
			return;
		}
		// double 666 telefrag (can happen often in deathmatch 4)
		if (attacker.classname == "teledeath3") 
		{
			bprint (PRINT_MEDIUM,targ.netname);
			bprint (PRINT_MEDIUM," was telefragged by ");
			bprint (PRINT_MEDIUM,attacker.owner.netname);
			bprint (PRINT_MEDIUM, "'s Satan's power\n");
			targ.frags = targ.frags - 1;
			logfrag (targ, targ);
			return;
		}
		if (targ.deathtype == "squish")
		{
			if (teamplay && targteam == attackerteam && attackerteam != "" && targ != attacker)
			{
				logfrag (attacker, attacker);
				attacker.frags = attacker.frags - 1; 
				bprint (PRINT_MEDIUM,attacker.netname);
				bprint (PRINT_MEDIUM," squished a teammate\n");
				return;
			}
			else if (attacker.classname == "player" && attacker != targ)
			{
				logfrag (attacker, targ);
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM," squishes ");
				bprint (PRINT_MEDIUM,targ.netname);
				bprint (PRINT_MEDIUM,"\n");
				logfrag (attacker, targ);
				attacker.frags = attacker.frags + 1;
				return;
			}
			else
			{
				logfrag (targ, targ);
				targ.frags = targ.frags - 1;            // killed self
				bprint (PRINT_MEDIUM,targ.netname);
				bprint (PRINT_MEDIUM," was squished\n");
				return;
			}
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				logfrag (attacker, attacker);
				attacker.frags = attacker.frags - 1;
				bprint (PRINT_MEDIUM,targ.netname);
				
				if (targ.deathtype == "grenade")
					bprint (PRINT_MEDIUM," tries to put the pin back in\n");
				else if (targ.deathtype == "rocket")
					bprint (PRINT_MEDIUM," becomes bored with life\n");
				else if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					if (targ.watertype == CONTENT_SLIME)
						bprint (PRINT_MEDIUM," discharges into the slime\n");
					else if (targ.watertype == CONTENT_LAVA)
						bprint (PRINT_MEDIUM," discharges into the lava\n");
					else
						bprint (PRINT_MEDIUM," discharges into the water.\n");
				}
//ZOID--
//gibbed for changing teams
				else if (teamplay && (attackerteam != targteam) && (teamplay != TEAM_DMATCH_TAG))
				{
					if (cvar("gamecfg") & GAMECFG_ALLOW_CHG)
						bprint(PRINT_MEDIUM, " changed teams\n");
					else
						bprint(PRINT_MEDIUM, " tried to change teams\n");
				}
//--ZOID
				else
					bprint (PRINT_MEDIUM," checks if his weapon is loaded\n");
				return;
			}
			else if ( (teamplay == 2) && (targteam == attackerteam) &&
				(attackerteam != "") )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (PRINT_MEDIUM, attacker.netname);
				bprint (PRINT_MEDIUM, deathstring);
				attacker.frags = attacker.frags - 1;
				//ZOID 12-13-96:  killing a teammate logs as suicide
				logfrag (attacker, attacker);
				return;
			}
			else
			{
				logfrag (attacker, targ);
				if (teamplay == TEAM_DMATCH_TAG)
					dmatch_score (targ, attacker);
				else
				{
				attacker.frags = attacker.frags + 1;
//ZOID--
				TeamAssists(targ, attacker);
//--ZOID
				}

				rnum = attacker.weapon;
//ZOID--
				if (targ.deathtype == "hook")
				{
					deathstring = " was grappled by ";
					deathstring2 = "\n";
				}
//--ZOID
				if (targ.deathtype == "nail")

				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				else if (targ.deathtype == "supernail")
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				else if (targ.deathtype == "grenade")
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				else if (targ.deathtype == "rocket")
				{
					if (attacker.super_damage_finished > 0 && targ.health < -40)
					{
						rnum = random();
						if (rnum < 0.3)
							deathstring = " was brutalized by ";
						else if (rnum < 0.6)
							deathstring = " was smeared by ";
						else
						{
							bprint (PRINT_MEDIUM, attacker.netname);
							bprint (PRINT_MEDIUM, " rips ");
							bprint (PRINT_MEDIUM, targ.netname);
							bprint (PRINT_MEDIUM, " a new one\n");
							return;
						}
						if  (deathmatch == 4)
							deathstring2 = "'s OctaRocket\n";
						else
							deathstring2 = "'s quad rocket\n";
					}
					else
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";
						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n" ;
						}
					}
				}
				else if (targ.deathtype == "lavanail")
				{
					deathstring = " was burned by ";
					deathstring2 = "\n";
				}
				else if (targ.deathtype == "multirocket")
				{
					deathstring = " was blasted to bits by ";
					deathstring2 = "\n";
				}
				else if (targ.deathtype == "plasma" || rnum == IT_PLASMA_GUN)
				{
					deathstring = " was fused by ";
					deathstring2 = "\n";
				}
				else if (rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				else if (rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				else if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				else if (rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				bprint (PRINT_MEDIUM,targ.netname);
				bprint (PRINT_MEDIUM,deathstring);
				bprint (PRINT_MEDIUM,attacker.netname);
				bprint (PRINT_MEDIUM,deathstring2);
			}
			return;
		}
		else
		{
			logfrag (targ, targ);
			targ.frags = targ.frags - 1;            // killed self
			rnum = targ.watertype;

			bprint (PRINT_MEDIUM,targ.netname);
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," sleeps with the fishes\n");
				else
					bprint (PRINT_MEDIUM," sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," gulped a load of slime\n");
				else
					bprint (PRINT_MEDIUM," can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (PRINT_MEDIUM," burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (PRINT_MEDIUM," turned into hot slag\n");
				else
					bprint (PRINT_MEDIUM," visits the Volcano God\n");
				return;
			}
			if (attacker.classname == "explo_box")
			{
				bprint (PRINT_MEDIUM," blew up\n");
				return;
			}
			if (targ.deathtype == "nail" || targ.deathtype == "supernail")
			{
				bprint (PRINT_MEDIUM," was spiked\n");
				return;
			}
			if (targ.deathtype == "lavanail")
			{
				bprint (PRINT_MEDIUM," was spiked\n");
				return;
			}
			if (targ.deathtype == "laser")
			{
				bprint (PRINT_MEDIUM," was zapped\n");

				return;
			}

			if (attacker.classname == "fireball" || targ.deathtype == "fireball")
			{
				bprint (PRINT_MEDIUM," ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (PRINT_MEDIUM," tried to leave\n");
				return;
			}
			if (attacker.classname == "ltrail_start" || 
				attacker.classname == "ltrail_relay")
			{
				bprint (PRINT_MEDIUM, " rode the lightning\n");
				return;
			}
			if (attacker.classname == "pendulum")
			{
				bprint (PRINT_MEDIUM, " was cleaved in two\n");
				return;
			}
			if (attacker.classname == "buzzsaw")
			{
				bprint (PRINT_MEDIUM, " was sliced to pieces\n");
				return;  
			}
			if (attacker.classname == "plasma")
			{
				bprint (PRINT_MEDIUM,  " was turned to plasma\n");
				return;
			}
			if (attacker.classname == "Vengeance")
			{
				// vengeance sphere doesn't count as a negative frag
				targ.frags = targ.frags + 1;
				bprint (PRINT_MEDIUM,  " was purged by the Vengeance Sphere\n");
				return;
			}
			if (attacker.classname == "power_shield")
			{
				// shield attacks should count for frags too..
				// shield death doesn't count as a negative frag
				targ.frags = targ.frags + 1;
				attacker.owner.frags = attacker.owner.frags + 1;
				TeamAssists(targ, attacker.owner);                      //PGM

				deathstring = " was smashed by ";
				deathstring2 = "\n";
				bprint (PRINT_MEDIUM, deathstring);
				bprint (PRINT_MEDIUM, attacker.owner.netname);
				bprint (PRINT_MEDIUM, deathstring2);
				return;
			}
			if (targ.deathtype == "falling")
			{
				bprint (PRINT_MEDIUM," fell to his death\n");
				return;
			}
			bprint (PRINT_MEDIUM," died\n");
		}
	}
};
