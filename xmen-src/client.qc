
// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

.float   modelindex_eyes, modelindex_player;


/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};


void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items &
	(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );

// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;

   parm10 = self.weapon_parts;
};

void() SetNewParms =
{
   if (deathmatch == DM_SPECIAL_POWERS)
    parm1 = IT_AXE;
   else
    parm1 = IT_SHOTGUN | IT_AXE | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER | IT_LIGHTNING;

	parm2 = 100;
	parm3 = 0;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
    if (deathmatch == DM_SPECIAL_POWERS) {
       parm4 = 0;
       parm8 = IT_AXE;
    }
    else {
       parm4 = 25;
       parm8 = IT_SHOTGUN;
    }
	parm9 = 0;

   parm10 = 0;
};

void() DecodeLevelParms =
{
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}

	self.items = parm1;

   if (deathmatch != 10) {
      self.items = self.items | IT_SHOTGUN | IT_AXE | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER | IT_LIGHTNING;
      self.weapon = parm8;
   }
   else {
      self.weapon = IT_AXE;
   }

	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.armortype = parm9 * 0.01;

   self.weapon_parts = parm10;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
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

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	objerror ("FindIntermission: no spot");
	// 20060704 LordHavoc: hushed a compiler warning by adding a return world
	return world;
};


string nextmap;
void() GotoNextMap =
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};

// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//float    finale_index;     // used to show multiple finale stories

void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}

	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
      if (world.model == "maps/x1end.bsp")
      {
         WriteByte (MSG_ALL, SVC_FINALE);
         WriteString (MSG_ALL, "Acknowledging defeat, Apocalypse tells\nyou that although you have defeated\nhim, there is another to carry on his\nwork. Indeed, without Apocalypse to\nkeep him in check, this sinister\ncharacter will undoubtedly increase\nhis determination to destroy and take\nover the world.\n\nYou have done well to destroy\nApocalypse's cloning factory, but there\nis still the matter of the clones that\nhave already been dispatched. Critical\nlocations must be contained in an\nattempt to lessen the damage caused to\nthe world as a whole.\n\nYou must defeat this evil genius before\nthe world falls before him...");

         serverflags = serverflags - (serverflags & 15);

/*
Acknowledging defeat, Apocalypse tells\n
you that although you have defeated\n
him, there is another to carry on his\n
work. Indeed, without Apocalypse to\n
keep him in check, this sinister\n
character will undoubtedly increase\n
his determination to destroy and take\n
over the world.\n\n
You have done well to destroy\n
Apocalypse's cloning factory, but there\n
is still the matter of the clones that\n
have already been dispatched. Critical\n
locations must be contained in an\n
attempt to lessen the damage caused to\n
the world as a whole.\n\n
You must defeat this evil genius before\n
the world falls before him...");
*/
         return;
      }
      else if (world.model == "maps/x2end.bsp")
      {
         WriteByte (MSG_ALL, SVC_FINALE);
         WriteString (MSG_ALL, "Sinister, realizing that his demise is\nat hand, teleports away to places\nunknown. You have thwarted his evil\nplans, and although he lives to see\nanother day, it will take a long time\nfor him to create such devious and\ndestructive ways of conquering the\nEarth again.\n\nMagneto now has the upper hand, and can\nensure the quick and ruthless\ntermination of any other such plans,\nfor in his self-deluded superiority, he\nalone is worthy of world domination.\n\nIt will take time for the population to\nrebuild their shattered lives, but you\nhave done your part in ensuring the\nworld's safety...   for now..");

         serverflags = serverflags - (serverflags & 15);
/*
Sinister, realizing that his demise is\n
at hand, teleports away to places\n
unknown. You have thwarted his evil\n
plans, and although he lives to see\n
another day, it will take a long time\n
for him to create such devious and\n
destructive ways of conquering the\n
Earth again.\n\n
Magneto now has the upper hand, and can\n
ensure the quick and ruthless\n
termination of any other such plans,\n
for in his self-deluded superiority, he\n
alone is worthy of world domination.\n\n
It will take time for the population to\n
rebuild their shattered lives, but you\n
have done your part in ensuring the\n
world's safety...\n\n
..for now..
*/
         return;
      }

		GotoNextMap();
	}

	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}

		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense tremendous invisible forces moving to unseal ancient barriers. Shub-Niggurath had hoped to use the Runes Herself to clear off the Earth, but now instead, you will use them to enter her home and confront her as an avatar of avenging Earth-life. If you defeat her, you will be remembered forever as the savior of the planet. If she conquers, it will be as if you had never been born.");
			return;
		}

	}

	GotoNextMap();
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

	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 3;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local entity	pos;
	local entity	magneto;

	if (other.classname != "player")
		return;

	if (cvar("noexit"))
	{
		T_Damage (other, self, self, 50000);
		return;
	}
	bprint (other.netname);
	bprint (" exited the level\n");

   magneto = find(world, classname, "magneto_sprite");
   if (magneto != world)
      remove(magneto);

	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}

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
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	InitTrigger ();
	self.touch = changelevel_touch;
};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

void() gateway_teleport_think =
{
   self.frame = self.frame + 1;
   if (self.frame > 5)
      self.frame = 1;

   self.nextthink = time + 0.1;
};

void() WhipThink =
{
   local vector   vect;

   self.skin = self.skin + 1;
   if (self.skin > 7)
      self.skin = 0;

   self.frame = self.frame + 1;
   if (self.frame > 2)
      self.frame = 0;

   makevectors(self.owner.angles);
   setorigin(self, self.owner.origin + v_forward * 40 + v_up * 30 - v_right * 13);

   if (self.last_flame < (time - self.last_flame_sound)) {
      // shoot out some random lightning
      makevectors(self.angles);
      vect = (v_right * (random() * -4)) + (v_up * random() * 4);
      vect = normalize(vect);
      traceline(self.origin, self.origin + vect * 512, FALSE, self);

      sound (self, CHAN_AUTO, "storm/l_attack.wav", 0.2, 1);

      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_LIGHTNING3);
      WriteEntity (MSG_BROADCAST, self);
      WriteCoord (MSG_BROADCAST, self.origin_x);
      WriteCoord (MSG_BROADCAST, self.origin_y);
      WriteCoord (MSG_BROADCAST, self.origin_z);
      WriteCoord (MSG_BROADCAST, trace_endpos_x);
      WriteCoord (MSG_BROADCAST, trace_endpos_y);
      WriteCoord (MSG_BROADCAST, trace_endpos_z);

      self.last_flame_sound = 0.3 + random() * 0.8;
      self.last_flame = time;
   }

   self.nextthink = time + 0.1;
};

void() SpawnGatewayWhip =
{
   local entity   whip;

   whip = spawn();
   whip.classname = "gateway_whip";
   whip.owner = self;
   whip.angles = self.angles;
   setmodel(whip, "progs/whip.mdl");

   makevectors(self.angles);
   setorigin(whip, self.origin + v_forward * 40 + v_up * 30 - v_right * 13);

   whip.think = WhipThink;
   whip.nextthink = time + 0.1;
};

void() xmen_teleport =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector o;
   local string str;

   if (!self.map)
      objerror ("changelevel trigger (xmen_teleport) doesn't have map");

   setsize(self, VEC_HULL2_MIN + '0 0 8', VEC_HULL2_MAX);
   if (!droptofloor()) {
      bprint("xmen_teleport fell out of level at ");
      str = vtos(self.origin);
      bprint(str);
      bprint(" ");
      remove(self);
      return;
   }

   precache_model("progs/gateway2.mdl");
   precache_model("progs/whip.mdl");

   setmodel(self, "progs/gateway2.mdl");

   SpawnGatewayWhip();

   self.solid = SOLID_TRIGGER;

   setorigin(self, self.origin + '0 0 1');
   self.touch = changelevel_touch;

   self.think = gateway_teleport_think;
   self.nextthink = time + 0.05;
};

//   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if ((coop) && (num_clients > 1))
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


void(entity plyr) KillFlameEntities =
{
   if (plyr.flame_ent1 == world)
      return;

   remove(plyr.flame_ent1);
   remove(plyr.flame_ent2);
   remove(plyr.flame_ent3);

   plyr.flame_ent1 = world;
   plyr.flame_ent2 = world;
   plyr.flame_ent3 = world;
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");

   KillFlameEntities(self);

	set_suicide_frame ();
   self.modelindex = self.modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
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
   local entity spot;
   local vector oldorg;
   local float nospot, i;

//spot = spawn();
//spot.classname = "info_player_start";
//spot.origin = '0 0 0';

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{
      i = 0;
      oldorg = self.origin;
      nospot = FALSE;

      while (!nospot && (i < 16)) {
         lastspawn = find(lastspawn, classname, "info_player_deathmatch");
         if (lastspawn == world) {
            lastspawn = find (lastspawn, classname, "info_player_deathmatch");
         }

         if (lastspawn != world) {
            setorigin(self, lastspawn.origin + '0 0 1');

            if (droptofloor()) {
               setorigin(self, oldorg);
               return lastspawn;
            }
         }
         else {
            nospot = TRUE;
         }

         i = i + 1;
      }
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
};

entity() spawn_flame_ent =
{
   local entity new_flame_ent;

   new_flame_ent = spawn();
   new_flame_ent.owner = self;
   setorigin(new_flame_ent, self.origin);
//   setmodel(new_flame_ent, "progs/eyes.mdl");
   new_flame_ent.think = flame_ent_think;
   new_flame_ent.nextthink = -1;

   return new_flame_ent;
};

void() MirrorThink =
{
   makevectors(self.owner.angles);
   setorigin(self, self.owner.origin + v_forward * 64);

   self.angles = self.owner.angles;
   self.angles_y = anglemod(self.owner.angles_y + 180);

   self.frame = self.owner.frame;
   self.nextthink = time + 0.01;
};

void() SpawnMirrorPlayer =
{
   local entity   ent;

   ent = spawn();
   ent.classname = "player_mirror";
   setmodel(ent, self.model);
   makevectors(self.angles);
   setorigin(ent, self.origin + v_forward * 64);
   ent.owner = self;
   ent.think = MirrorThink;
   ent.nextthink = time + 0.05;
};

void() SetDeathmatchModel =
{
   if (self.team == CHAR_WOLVERINE) {
      setmodel(self, "progs/dmwolvy.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_STORM) {
      setmodel(self, "progs/dmstorm2.mdl");
      self.char_type = CT_FEMALE;
   }
   else if (self.team == CHAR_ICEMAN) {
      setmodel(self, "progs/dmice.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_CYCLOPS) {
      setmodel(self, "progs/dmcyclop.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_PSYLOCKE) {
      setmodel(self, "progs/dmpsy.mdl");
      self.char_type = CT_FEMALE;
   }
   else if (self.team == CHAR_ANGEL) {
      setmodel(self, "progs/dmangel.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_BEAST) {
      setmodel(self, "progs/dmbeast.mdl");
      self.char_type = CT_MALE_LARGE;
   }
   else if (self.team == CHAR_GAMBIT) {
      setmodel(self, "progs/dmgambit.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_BISHOP) {
      setmodel(self, "progs/dmbishop.mdl");
      self.char_type = CT_MALE_LARGE;
   }
   else if (self.team == CHAR_ROGUE) {
      setmodel(self, "progs/dmrogue.mdl");
      self.char_type = CT_FEMALE;
   }
   else if (self.team == CHAR_CANNONBALL) {
      setmodel(self, "progs/dmcannon.mdl");
      self.char_type = CT_MALE_NORMAL;
   }
   else if (self.team == CHAR_PHOENIX) {
      setmodel(self, "progs/dmphoen.mdl");
      self.char_type = CT_FEMALE;
   }
   else {   // select a random character
      self.team = rint(random() * CHAR_PHOENIX);
      self.character = self.team;
      SetDeathmatchModel();
   }
};


/*
----------------
ClientMessagesThink

Used to send Clear V_CSHIFT messages, etc to client upon start a level
----------------
*/
void() ClientMessagesThink =
{
   stuffcmd(self.owner, "cl\n");
   stuffcmd(self.owner, "host_framerate 0\n");    // if user quits while in slow-motion in X1END, this will put it back
   stuffcmd(self.owner, "bf\n");    // this is a hack, but fixes Lava Death, screen stays red upon respawn

   if (self.owner.chasecam == world)
   {
	   stuffcmd(self.owner, "cl_bobup 1\n");
	   stuffcmd(self.owner, "r_drawviewmodel 1\n");
   }
   else
   {
	   stuffcmd(self.owner, "cl_bobup 0\n");
	   stuffcmd(self.owner, "r_drawviewmodel 0\n");
   }

   if (executable == "glQuake")
      stuffcmd(self.owner, "r_wateralpha 0.5\n");

   remove(self);
};


/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;

void() PutClientInServer =
{
	local	entity spot, thinker;

	self.classname = "player";
	self.health = self.start_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
   self.x_flags = 0;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

   serverflags = serverflags | (cvar("temp1") / 2);

   self.spawn_time = time;

   setmodel (self, "progs/eyes.mdl");
   self.modelindex_eyes = self.modelindex;

   if (self.character == 0) {
       if (deathmatch || coop) {
          setmodel(self, "progs/dmskel.mdl");
          index_skeleton = self.modelindex;

          self.character = self.team;
          SetDeathmatchModel();
       }
       else {
          setmodel (self, "progs/cyborg.mdl");
       }
      self.modelindex_player = self.modelindex;
   }

 	DecodeLevelParms ();

   if (self.weapon != IT_AXE) {
      if (self.weapon == IT_LIGHTNING)
         self.weapon_idleframe = 2;
      else
         self.weapon_idleframe = 5;
   }
   else
      self.weapon_idleframe = 6;

	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;

   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
//   setorigin(self, spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

/*
bprint("Player spawned at: ");
bprint(vtos(self.origin));
bprint("\n");
*/

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

   self.view_ofs = '0 0 22';
   if (self.character == CHAR_STORM)
      self.view_ofs_z = self.view_ofs_z + STORM_VOFS_Z;

	player_stand1 ();

	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);

    self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);
    self.change_weapon_status = 0;

   if (self.flame_ent1 == world) {
      // create flamethrower entities
      self.flame_ent1 = spawn_flame_ent();
      self.flame_ent2 = spawn_flame_ent();
      self.flame_ent3 = spawn_flame_ent();
   }

   // create laser beam junctions
//   self.beam_ent = spawn();
//   self.beam_ent.beam_ent = spawn();

   // Morph into current weapon
   self.change_weapon_status = CW_FADEIN;
   self.weaponframe = 0;
   self.fadein_endframe = 5;

   // Create a thinker that sends client messages out after 0.5 seconds
   thinker = spawn();
   thinker.owner = self;
   thinker.think = ClientMessagesThink;
   thinker.nextthink = time + 0.5;

   if (deathmatch == 69) {
      // Spawn a mirror image of the player for testing
      SpawnMirrorPlayer();
   }

//    Chase_cam_level_start();
//    Start_chase_cam(self);

};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/

void() shootrockets =
{
   self.currentammo = self.ammo_rockets = 50;
   W_FireGuidedRockets();

   self.nextthink = time + 5;
};


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
//   self.v_angle = self.angles;
//   self.think = shootrockets;
//   self.nextthink = time + 5;
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
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
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags + 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags + 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags + 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags + 8;
		}
		else
		{
			mapname = "start";
			serverflags = serverflags - 15;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;

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
	local	float		timelimit;
	local	float		fraglimit;

	if (gameover)	// someone else quit the game already
		return;

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}

	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}
};

//============================================================================

void() PlayerDeathThink =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local entity	old_self;
	local float		forward;

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


void() RandomFlapSound;
void() PlayerJump =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local vector start, end;

	if (self.flags & FL_WATERJUMP)
		return;

	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

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

    if (!(self.flags & FL_ONGROUND) && (self.character != CHAR_ANGEL))
        return;

	if ( !(self.flags & FL_JUMPRELEASED) ) {     // still holding jump
      if ((self.character != CHAR_ANGEL) || ((self.origin_z > self.last_jump_z) || (self.velocity_z > 0)))
   		return;		// don't pogo stick
   }
   else {      // just pressed jump
      self.last_jump_z = self.origin_z;
   }

 	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

   if (self.character != CHAR_ANGEL)
   	self.flags = self.flags - (self.flags & FL_ONGROUND);	// don't stairwalk
   else if (self.last_jump > (time - 0.5)) {    // prevent flapping too fast
      return;
   }

   self.last_jump = time;

	self.button2 = 0;
// player jumping sound
   if (self.character != CHAR_ANGEL) {
//   	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
      self.velocity_z = self.velocity_z + 270;

      self.x_flags = self.x_flags | X_JUMP_PRESSED;
   }
   else {
      RandomFlapSound();
      self.velocity_z = self.velocity_z + 380;
      if (self.velocity_z > 500)
         self.velocity_z = 500;

/*
      start = self.velocity;
      start_z = 0;
      if (vlen(start) < 200) {
         if (vlen(start) > 20)
            start = normalize(start) * 200;
      }
//      if (vlen(start) > 200) {
//            start = normalize(start) * 200;
//      }

      self.velocity_x = start_x;
      self.velocity_y = start_y;
*/
   }
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
//		if (self.air_finished < time)
//			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
//		else if (self.air_finished < time + 9)
//			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
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
	{	// do damage
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
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}

	if ( !(self.flags & FL_INWATER) )
	{

// player enter water sound

//		if (self.watertype == CONTENT_LAVA)
//			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
//		if (self.watertype == CONTENT_SLIME)
//			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}

	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
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
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
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
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	float	mspeed, aspeed;
	//local	float	r;
   local string str;

//bprint(ftos(self.weaponframe));
//bprint(" ");

//bprint("> ");
//bprint(vtos(self.origin));
//bprint("\n");

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

   if ((self.modelindex == index_skeleton) && (self.health >= 100)) {
      self.modelindex = self.modelindex_player;
	  if (self.chasecam == world)
		stuffcmd(self, "r_drawviewmodel 1\n");
   }

   // check beast power view shake
   if ((self.view_ofs != '0 0 22') &&
       (find(world, classname, "beast_power") == world) &&
       (self.health > 0)) {
      self.view_ofs = '0 0 22';
   }

   // check for GOD mode cheating
   if (!deathmatch && !coop && (self.flags & FL_GODMODE) && !(self.x_flags & X_GODCHEAT)) {
      self.flags = self.flags - FL_GODMODE;
      sprint(self, "Sinister has changed the cheat codes\n");
      sound(self, CHAN_BODY, "misc/snicker1.wav", 1, ATTN_NORM);
//      T_Damage(self, world, world, self.health - 1);
   }

   if (self.x_flags & X_FLYING)
      self.velocity = self.old_velocity;
/*
   else if ((self.x_flags & X_ANGEL_DEFENSE) && !(self.x_flags & X_TRACTOR_BEAM_HOLD)) {
      if (vlen(self.old_velocity) > ((320 * frametime) + 50))
         self.velocity = self.old_velocity - (normalize(self.old_velocity) * 320 * frametime);
      else
         self.velocity = '0 0 0';
   }
*/
   if ((self.character == CHAR_WOLVERINE) &&
       (self.health < 100) &&
       (self.health > 0) &&
       (self.last_health_regen < (time - 2)))
   {
      self.health = self.health + 1;

      if (self.health > 100)
         self.health = 100;

      self.last_health_regen = time;
   }

   if ((self.x_flags & X_RAPID_FIRE) && (self.rapid_time < time)) {
      self.x_flags = self.x_flags - X_RAPID_FIRE;
      self.items = self.items - (self.items & IT_INVISIBILITY);
      self.x_flags = self.x_flags - (self.x_flags & X_RAPID_WARNING);
   }
   else if ((self.x_flags & X_RAPID_FIRE) && !(self.x_flags & X_RAPID_WARNING) &&
            (self.rapid_time < (time + 3))) {
      self.x_flags = self.x_flags | X_RAPID_WARNING;
      sound(self, CHAN_ITEM, "misc/rapidout.wav", 1, ATTN_NORM);
      sprint(self, "Rapid Fire is running out!\n");
   }

	makevectors (self.v_angle);		// is this still used

	CheckRules ();
	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}

	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if ((self.button2) && (self.health > 0) && (self.parallize_time < time) && !(self.x_flags & X_ANGEL_DEFENSE))
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// X-Men: Phoenix Tractor Beam
   if (self.x_flags & X_TRACTOR_BEAM_HOLD) {
//      if (self.start_tractor_time < (time - 4))
//         self.x_flags = self.x_flags - X_TRACTOR_BEAM_HOLD;
//      else
         self.velocity = self.tractor_vel;
   }
// done

// teleporters can force a non-moving pause time
	if (time < self.pausetime)
		self.velocity = '0 0 0';

   if (self.x_flags & X_PARALLIZED) {
      self.button0 = FALSE;
      if (self.flags & FL_ONGROUND) {
         // set velocity
         self.velocity = self.parallized_velocity;
      }
   }
   else {
      if ((deathmatch || coop) && (self.skin != 0))
         self.skin = 0;

      if (self.last_clear < (time - 2)) {        // make sure the screen doesn't stay v_cshift'ed
         stuffcmd(self, "cl\n");
         self.last_clear = time;
      }
   }

   if ((deathmatch || coop) && ((self.character == CHAR_ANGEL) || (self.character == CHAR_STORM))) {
      if (self.velocity_z < 0) {
         if ((self.old_velocity_z - self.velocity_z) > (cvar("sv_gravity") * frametime * 0.25))
            self.velocity_z = self.old_velocity_z - (cvar("sv_gravity") * frametime * 0.25);
      }
   }

   self.old_velocity = self.velocity;

   if ((capture) && (last_capture <= (time - 0.05))) {
      if (capture_count >= 100) {
         capture_count = 0;
         capture_index = capture_index + 1;
         return;
      }

      str = ftos(capture_index);
      stuffcmd(self, "ss");
      stuffcmd(self, str);
      stuffcmd(self, "\n");

      last_capture = time;
      capture_count = capture_count + 1;
   }
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

   if (self.modelindex == index_skeleton)
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
				sprint (self, "Ring of Shadows magic is fading\n");
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
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}

	// use the eyes
		self.frame = 0;
        self.modelindex = self.modelindex_eyes;
	}
	else
        self.modelindex = self.modelindex_player;    // don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Ruby of Cyttorak is almost worn out\n");
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
		{	// just stopped
			self.items = self.items - (self.items & IT_INVULNERABILITY);
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Superpower is wearing off\n");
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
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// suit
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
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
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	float	mspeed, aspeed;
	local	float	r, vol;

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale
	if (self.deadflag)
		return;

   if (self.colormap != 0) {
      self.colormap = 0;

//      if (deathmatch && (self.spawn_time < (time - 2)))
//         sprint(self, "You must re-connect to use the new character\n");
   }

/*
   if ((self.parallize_time > time) && (self.flags & FL_ONGROUND)) {
      setorigin(self, self.oldorigin);
   }
   else
*/
   if ((self.parallize_time < time) && (self.x_flags & X_PARALLIZED)) {
      self.x_flags = self.x_flags - X_PARALLIZED;
      stuffcmd(self, "cl\n");
      stuffcmd(self, "bf\n");
   }

// do weapon stuff
   if (!(self.x_flags & X_PARALLIZED))
      W_WeaponFrame ();

// check to see if player landed and play landing sound
	if ((self.jump_flag < -100) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
      if ((self.modelindex == index_skeleton) && (self.jump_flag < -500)) {
         T_Damage (self, world, world, self.health + 20);
      }

		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5);
         if (!deathmatch && !coop) {
            r = random() * 4;
            if (r < 1)
               sound (self, CHAN_VOICE, "player/land1.wav", 1, ATTN_NORM);
            else if (r < 3)
               sound (self, CHAN_VOICE, "player/land3.wav", 1, ATTN_NORM);
            else if (r < 4)
               sound (self, CHAN_VOICE, "player/land4.wav", 1, ATTN_NORM);
         }
			self.deathtype = "falling";
		}
		else {
         if (!deathmatch && !coop) {
            vol = ((-1 * self.jump_flag) - 100) / 550;
            vol = vol * vol;                          // reduce sound somewhat

            if (vol < 0.1)
               vol = 0.1;

            r = random() * 4;
            if (r < 1)
               sound (self, CHAN_VOICE, "player/land1.wav", vol, ATTN_NORM);
            else if (r < 3)
               sound (self, CHAN_VOICE, "player/land3.wav", vol, ATTN_NORM);
            else if (r < 4)
               sound (self, CHAN_VOICE, "player/land4.wav", vol, ATTN_NORM);
         }
      }

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups ();
/*
    if (self.chasecam != world) {
        self = self.chasecam;
        self.think();
        self = self.owner;
    }
*/
    if (self.character == CHAR_ANGEL)
      self.flags = self.flags | FL_ONGROUND;

   if (self.chasecam != world) {
      self = self.chasecam;
      CamThink();
      self = self.owner;
   }

};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game as ");
   bprint(GetCharacterString(self.team));
   bprint ("\n");

	num_clients = num_clients + 1;

// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

   KillFlameEntities(self);

   // attempt to clear the screen of any c_shift stuff (doesn't work very well, but worth a shot)
   stuffcmd(self, "cl\n");

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "skeleton/crunch.wav", 1, ATTN_NONE);
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
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);

				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
					bprint (" tries to put the pin back in\n");
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;
				if (rnum == IT_AXE)
				{
					deathstring = " was killed by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SHOTGUN)
				{
					deathstring = " was blasted by ";
					deathstring2 = "'s shotgun\n";
				}
				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " was mowed down by ";
					deathstring2 = "'s chaingun\n";
				}
				if (rnum == IT_NAILGUN)
				{
					deathstring = " was burnt by ";
					deathstring2 = "'s flameball\n";
				}
				if (rnum == IT_SUPER_NAILGUN)
				{
					deathstring = " sucked down ";
					deathstring2 = "'s flamethrower\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER)
				{
               deathstring = " ate ";
               deathstring2 = "'s orb\n";
				}
				if (rnum == IT_ROCKET_LAUNCHER)
				{
					deathstring = " couldn't avoid ";
					deathstring2 = "'s smart rocket\n";
				}
				if (rnum == IT_LIGHTNING)
				{
					deathstring = " was obliterated by ";
   				deathstring2 = "'s energy ball\n";
				}
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{

			// killed by a montser?
			if (attacker.flags & FL_MONSTER)
			{
            bprint(self.netname);

				if (attacker.classname == "xmen_bishop")
					bprint (" was shot by a Bishop X-Clone\n");
				if (attacker.classname == "xmen_wolverine")
					bprint (" was clawed by a Wolverine X-Clone\n");
				if (attacker.classname == "xmen_beast")
					bprint (" was thumped by a Beast X-Clone\n");
				if (attacker.classname == "xmen_cyclops")
					bprint (" was blasted by a Cyclops X-Clone\n");
				if (attacker.classname == "xmen_gambit")
					bprint (" was slain by a Gambit X-Clone\n");
				if (attacker.classname == "xmen_psylocke")
					bprint (" succumbed to a Psylocke X-Clone's martial artistry\n");
				if (attacker.classname == "xmen_rogue")
					bprint (" was killed by a Rogue X-Clone\n");
				if (attacker.classname == "xmen_phoenix")
					bprint (" was killed by a Phoenix X-Clone\n");
				if (attacker.classname == "xmen_storm")
               bprint (" was fried by a Storm X-Clone's bolt\n");
				if (attacker.classname == "xmen_angel")
					bprint (" was feathered by an Arch-Angel X-Clone\n");
				if (attacker.classname == "xmen_iceman")
					bprint (" was iced by an Iceman X-Clone\n");
            if (attacker.classname == "xmen_cannonball")
               bprint (" was killed by a Cannonball X-Clone\n");
            if (attacker.classname == "xmen_apocalypse")
               bprint (" was killed by Apocalypse\n");
            if (attacker.classname == "apocalypse_small")
               bprint (" was killed by Apocalypse\n");
            if (attacker.classname == "xmen_sinister")
               bprint (" was killed by Sinister\n");

				return;
			}

         targ.frags = targ.frags - 1;
         bprint (targ.netname);

			// tricks and traps
			// Begin Xmen  (cl2)
			if (attacker.classname == "tripwire_endpoint" || attacker.classname == "tripwire_startpoint")
			{
				bprint (" was blown to pieces\n");
				return;
			}
         if (attacker.classname == "info_lightning")
         {
            bprint (" was fried by a lightning bolt\n");
            return;
         }
			// End Xmen

			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{
				bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint (" fell to their death\n");
				return;
			}

			// hell if I know; he's just dead!!!
			bprint (" died\n");
		}
	}
};
