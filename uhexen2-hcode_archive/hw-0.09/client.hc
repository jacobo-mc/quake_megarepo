/*
 * $Header: /HexenWorld/HCode/Client.hc 58    5/25/98 1:30p Mgummelt $
 */

// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void (vector org, entity death_owner) spawn_tdeath;
void() DecrementSuperHealth;
void CheckRings (void);


void FreezeAllEntities(void)
{
	entity search;

	search = nextent(world);
	while(search != world)
	{
		if (search.classname != "player")
		{
			thinktime search : 99999;
		}
		search = nextent(search);
	}
}

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission. Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
-----------------------FIELDS-------------------------

--------------------------------------------------------
*/
void info_intermission(void)
{
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity FindIntermission(void)
{
entity spot;
float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random(4);
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
}


string nextmap;
string nextstartspot;

void GotoNextMap(void)
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
	{
		changelevel (mapname, startspot);
	}
	else
	{
		changelevel (nextmap, nextstartspot);
	}
}


void ExitIntermission(void)
{
	// skip any text in deathmatch
	if (deathmatch)
	{
		intermission_exittime = 
		intermission_running = 0;
	}

	other = find (world, classname, "player");
	while (other != world)
	{
		stuffcmd(other, "-showdm\n");
		other.frags=0;//reset frags
		other.takedamage = DAMAGE_YES;
		other.solid = SOLID_BBOX;
		other.movetype = MOVETYPE_WALK;
		other.flags(-)FL_NOTARGET;
		other.effects=FALSE;
		other.weaponmodel=other.lastweapon;
		other = find (other, classname, "player");
	}	

	if (deathmatch)
	{
		gameover = FALSE;
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	//
	// run some text if at the end of an episode
	//

	if (intermission_running == 2)
		GotoNextMap();
}

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void IntermissionThink(void)
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
}

void() execute_changelevel =
{
	intermission_running = 1;
	
// enforce a wait time before allowing changelevel

	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;


	other = find (world, classname, "player");
	while (other != world)
	{
//		other.sv_flags=serverflags;
		thinktime other : 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.flags(+)FL_NOTARGET;
		other.effects=EF_NODRAW;
		other.lastweapon=other.weaponmodel;
		stuffcmd(other,"+showdm\n");
		other = find (other, classname, "player");
	}	
};

void FindDMLevel(void)
{
	serverflags (+) SFL_NEW_UNIT;

	nextmap = string_null;

	if (cvar("registered") != 0 || cvar("oem") != 0)
	{
		if (mapname == "demo1")
			nextmap = "demo2";
		else if (mapname == "demo2")
			nextmap = "demo3";
		else if (mapname == "demo3")
			nextmap = "village1";
		else if (mapname == "village1")
			nextmap = "village2";
		else if (mapname == "village2")
			nextmap = "village3";
		else if (mapname == "village3")
			nextmap = "village4";
		else if (mapname == "village4")
			nextmap = "village5";
		else if (mapname == "village5")
			nextmap = "rider1a";
		else if (mapname == "rider1a")
			nextmap = "demo1";

		else if (mapname == "meso1")
			nextmap = "meso2";
		else if (mapname == "meso2")
			nextmap = "meso3";
		else if (mapname == "meso3")
			nextmap = "meso4";
		else if (mapname == "meso4")
			nextmap = "meso5";
		else if (mapname == "meso5")
			nextmap = "meso6";
		else if (mapname == "meso6")
			nextmap = "meso8";
		else if (mapname == "meso8")
			nextmap = "meso9";
		else if (mapname == "meso9")
			nextmap = "meso1";

		else if (mapname == "egypt1")
			nextmap = "egypt2";
		else if (mapname == "egypt2")
			nextmap = "egypt3";
		else if (mapname == "egypt3")
			nextmap = "egypt4";
		else if (mapname == "egypt4")
			nextmap = "egypt5";
		else if (mapname == "egypt5")
			nextmap = "egypt6";
		else if (mapname == "egypt6")
			nextmap = "egypt7";
		else if (mapname == "egypt7")
			nextmap = "rider2c";
		else if (mapname == "rider2c")
			nextmap = "egypt1";

		else if (mapname == "romeric1")
			nextmap = "romeric2";
		else if (mapname == "romeric2")
			nextmap = "romeric3";
		else if (mapname == "romeric3")
			nextmap = "romeric4";
		else if (mapname == "romeric4")
			nextmap = "romeric5";
		else if (mapname == "romeric5")
			nextmap = "romeric6";
		else if (mapname == "romeric6")
			nextmap = "romeric7";
		else if (mapname == "romeric7")
			nextmap = "romeric1";

		else if (mapname == "cath")
			nextmap = "tower";
		else if (mapname == "tower")
			nextmap = "castle4";
		else if (mapname == "castle4")
			nextmap = "castle5";
		else if (mapname == "castle5")
			nextmap = "eidolon";
		else if (mapname == "eidolon")
			nextmap = "cath";

		else if (mapname == "ravdm1")
			nextmap = "ravdm2";
		else if (mapname == "ravdm2")
			nextmap = "ravdm3";
		else if (mapname == "ravdm3")
			nextmap = "ravdm4";
		else if (mapname == "ravdm4")
			nextmap = "ravdm5";
		else if (mapname == "ravdm5")
			nextmap = "ravdm1";
	}
	else
	{
		if (mapname == "demo1")
			nextmap = "demo2";
		else if (mapname == "demo2")
			nextmap = "ravdm1";
		else if (mapname == "ravdm1")
			nextmap = "demo1";
	}
}

void() changelevel_touch =
{

	if (other.classname != "player")//||(!infront_of_ent(self,other)))
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
// rjr quake2 change		T_Damage (other, self, self, 50000, 1000, TRUE);
		T_Damage (other, self, self, 50000);
		return;
	}

	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	//FIXME: temp server flags fix
//	other.sv_flags=serverflags;
	if (coop || deathmatch)
	{
		bprintname (PRINT_MEDIUM, other);
		bprinti (PRINT_MEDIUM, STR_EXITEDLEVEL);
	}
	
	if (deathmatch)
		FindDMLevel();
	else
	{
		nextmap = self.map;
		nextstartspot = self.target;
	}

	SUB_UseTargets ();

	if (cvar("registered") == 0 && cvar("oem") == 0 && nextmap == "village1")
	{
		remove(self);
		intermission_running = 2;
		intermission_exittime = time + 20;
		WriteByte (MSG_ALL, SVC_INTERMISSION);
		WriteByte (MSG_ALL, 5);
		FreezeAllEntities();
		return;
	}

/*	if (self.spawnflags & 2)
	{
		serverflags (+) SFL_NEW_UNIT;
		serverflags (-) SFL_CROSS_TRIGGERS;
	}
	else
		serverflags (-) SFL_NEW_UNIT;
	if (self.spawnflags & 4)
	{
		serverflags (+) SFL_NEW_EPISODE;
		serverflags (-) SFL_CROSS_TRIGGERS;
	}
	else
		serverflags (-) SFL_NEW_EPISODE; */

//	rjr   spawnflag 1 use to be "no intermission" - removed the option completely
//	if ( (self.spawnflags & 1) && (deathmatch == 0) )

	if ( (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	thinktime self : 0.1;
};

void() changelevel_use =
{
	local	entity	saveOther;

	saveOther = other;
	other = activator;
	changelevel_touch ();
	other = saveOther;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? x END_OF_UNIT END_OF_EPISODE
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
	self.use = changelevel_use;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

//void() set_suicide_frame;
void(vector dir)GibPlayer;
// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		SolidPlayer();
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
	
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		SolidPlayer();
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		if(parm7)
			changelevel (mapname, startspot);
		else
			localcmd ("restart restore\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	if (self.last_use_time < time - 3)
	{
		bprintname (PRINT_MEDIUM, self);
		bprinti (PRINT_MEDIUM, STR_SUICIDES);
		self.model=self.init_model;
		GibPlayer('0 0 1');
		self.frags -= 2;	// extra penalty

		drop_level(self,2);
		respawn ();
		self.last_use_time = time;
	}
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
//@@ TODO: not fixed order!!!
entity() SelectSpawnPoint =
{//FIXME: if start on 2nd - 5th hubs, fill in correct startspot string
	entity spot;
	entity thing;
	float  pcount;
	float ok;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
// choose a info_player_deathmatch point
	if(self.newclass)
	{
		spot = find(world, classname, "classchangespot");
		if(spot)
		{
			spot.think=SUB_Remove;
			thinktime spot : 1;
			return spot;
		}
	}

	if (coop)
	{
		spot = lastspawn;
		pcount = 1;
		while (pcount > 0 && pcount < 3)
		{
			spot = find(spot, classname, "info_player_coop");
			if (spot != world && 
			    (spot.targetname == startspot) ||
				(startspot == string_null && spot.spawnflags & 1))
			{
				thing = findradius(spot.origin, 64);
				ok = TRUE;
				while (thing)
				{
					if (thing.classname == "player")
					{
						thing = world;
						ok = FALSE;
					}
					else thing = thing.chain;
				}
				if (ok)
				{
					lastspawn = spot;
					return lastspawn;
				}
			}
			if (spot == world)
				pcount += 1;
		}
//		dprint("Resorting to info_player_start\n");
		lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{
		spot = lastspawn;
		while (1)
		{
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot != world)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 64);
				while(thing)
				{
					if (thing.classname == "player")
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

	if (startspot)
	{
		spot = world;
		pcount = 1;
		while(pcount)
		{
			spot = find (spot, classname, "info_player_start");
			if (!spot)
				pcount = 0;
			else if (spot.targetname == startspot)
				pcount = 0;
		}
	}
	
	if (!spot)
	{
		spot = find (world, classname, "info_player_start");
		if (!spot)
			error ("PutClientInServer: no info_player_start on level");
	}

	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void(float damage, vector dir) PlayerDie;

void() PutClientInServer =
{
entity spot;

	spot = SelectSpawnPoint ();

	if(deathmatch)
	{
		if(!altRespawn)
		{
			self.items(-)IT_WEAPON4|IT_WEAPON3|IT_WEAPON4_1|IT_WEAPON4_2|IT_WEAPON2;
		}
		self.skin=0;
	}
//	else if(self.sv_flags)
//		serverflags=self.sv_flags;


	self.classname = "player";
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.deathtype="";
	self.viewentity=self;
	self.wallspot='0 0 0';
	self.scale=1;
	self.skin=0;
	self.drawflags=self.abslight=self.effects=0;
	self.flags(+)FL_CLIENT;
	self.flags2(+)FL_ALIVE;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.thingtype=THINGTYPE_FLESH;
	self.adjust_velocity = '-999 -999 -999';
//Reset all time-based fields
	self.act_state =
	self.show_hostile = 
	self.onfire=
	self.invisible_time=
	self.camptime=
	self.last_attack=
	self.torchtime=
	self.healthtime=
	self.catapult_time=
	self.safe_time=
	self.absorb_time=
	self.last_impact=
	self.sheep_sound_time=
	self.still_time=
	self.last_onground=
	self.invisible_finished=
	self.invincible_time=
	self.splash_time=
	self.ring_regen_time=
	self.rings_low=
	self.pausetime = 
	self.teleport_time = 
	self.sheep_time =
	self.attack_finished = 
	self.super_damage_time=
	self.haste_time =
	self.tome_time =
	self.camera_time=
	self.ring_regen_time=
	self.ring_flight_time=
	self.ring_water_time=
	self.ring_turning_time=
	self.super_damage=
	self.super_damage_low=
	self.hasted=
	self.decap=
	self.frozen=
	self.plaqueflg = 0;
	self.artifact_active(-)ARTFLAG_FROZEN|ARTFLAG_STONED;
	self.gameFlags (-) GF_HAS_TOKEN;
	self.effects (-) EF_BRIGHTFIELD;//Hey!  I set effects to "0" above...

	self.last_use_time = time;

	if(tomeMode == 2)
	{
		self.poweredFlags = 0;
	}

	if (self.playerclass != self.next_playerclass)
	{
		self.playerclass = self.next_playerclass;
		if (self.playerclass)
		{
			setclass(self, self.playerclass);
			stats_NewClass(self);
		}
	}

	if(self.newclass)
	{
		bprintname(PRINT_MEDIUM, self);
		bprint(PRINT_MEDIUM, " becomes a ");
		if(self.newclass==CLASS_PALADIN)
			bprint(PRINT_MEDIUM, "Paladin!\n");
		else if(self.newclass==CLASS_CRUSADER)
			bprint(PRINT_MEDIUM, "Crusader!\n");
		else if(self.newclass==CLASS_NECROMANCER)
			bprint(PRINT_MEDIUM, "Necromancer!\n");
		else
			bprint(PRINT_MEDIUM, "Assassin!\n");
		self.playerclass=self.newclass;
		setclass(self,self.playerclass);
		stats_NewClass(self);
		self.newclass=FALSE;
	}

	if(deathmatch&&randomclass)
		self.playerclass=CLASS_NONE;

	if (self.playerclass == CLASS_NONE)
	{ // Default it to the paladin if not selected
		if (cvar("registered") != 0 || cvar("oem") != 0)
		{
			setclass(self,rint(random(1,4)));
		}
		else
		{
			if (random() < 0.5)
				setclass(self,CLASS_PALADIN);
			else
				setclass(self,CLASS_ASSASSIN);
		}
	}

	if(fixedLevel)
	{
		PlayerAdvanceLevel(fixedLevel);
	}

//	bprint(PRINT_MEDIUM, "Health is ");
//	bprint(PRINT_MEDIUM, ftos(self.health));
//	bprint(PRINT_MEDIUM, "\n");

	if(self.max_health<=0 || deathmatch)
	{
		if(!fixedLevel)
		{
			self.strength = 0;
			stats_NewPlayer(self);
		}
	}
	else
		self.health = self.max_health;
	
	if(self.max_health<=0||self.health<=0)
	{
		dprint("ERROR: Respawned Dead!\n");
		dprintf("Class: %s\n",self.playerclass);
		dprint("Map: ");
		dprint(mapname);
		dprint("\n");
		dprintf("Max: %s\n",self.max_health);
		dprintf("Health: %s\n",self.health);
		dprint("Autofix: health default to 100\n");
		self.health=self.max_health=100;
	}

	self.deadflag = DEAD_NO;

	setorigin(self, spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	if(!self.weapon)
	{
		self.items=IT_WEAPON1;
		self.weapon=IT_WEAPON1;
		self.oldweapon=IT_WEAPON1;
	}
	if(deathmatch)
		self.weapon=IT_WEAPON1;

	if(coop)
	{//Need more mana in coop, especially if you die
		if(self.bluemana<25)
			self.bluemana=25;
		if(self.greenmana<25)
			self.greenmana=25;
	}
	
	W_SetCurrentAmmo ();

	SetModelAndThinks();

	if(deathmatch)
	{
		self.effects=0;
		self.artifact_active=ART_INVINCIBILITY;
		self.invincible_time = time + 3;
		self.artifact_low(+)ART_INVINCIBILITY;

		if(self.playerclass==CLASS_CRUSADER)
			self.skin = GLOBAL_SKIN_STONE;
		else if(self.playerclass==CLASS_PALADIN)
			self.effects(+)EF_BRIGHTLIGHT; 
		else if(self.playerclass==CLASS_ASSASSIN)
			self.colormap=140;
		else if(self.playerclass==CLASS_NECROMANCER)
			self.effects(+)EF_DARKLIGHT;
	}
	self.ring_regen_time = 0;
	self.ring_flight_time=0;	
	self.ring_water_time=0;	
	self.ring_turning_time=0;

	self.ring_flight=0;			// Health of rings 0 - 100
	self.ring_water=0;			// 
	self.ring_turning=0;		//
	self.ring_regeneration=0;	//
	self.rings = 0;

	self.view_ofs = '0 0 50';
	self.proj_ofs=' 0 0 44';
	self.hull=HULL_PLAYER;
	self.idealpitch = cvar("sv_walkpitch");

	PlayerSpeed_Calc();

	self.button0 = self.button1 = self.button2 = 0;
	self.attack_finished=time+0.5;//so no respawn fire

//	self.th_stand();
	player_frames();
	
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		GenerateTeleportEffect(self.origin,0);
	}

	spawn_tdeath (self.origin, self);

	if(tomeRespawn)
	{
		self.cnt_tome += 1;
		Use_TomeofPower();
		self.tome_time = time + 15;
	}
	if(w2Respawn)
	{
		self.items(+)IT_WEAPON2;
		if(self.bluemana<25)
		{
			self.bluemana=25;
		}
	}

	if(self.items & (IT_WEAPON2|IT_WEAPON3|IT_WEAPON4))
	{
		if(self.items & IT_WEAPON4)
		{
			self.weapon = IT_WEAPON4;
		}
		else if(self.items & IT_WEAPON3)
		{
			self.weapon = IT_WEAPON3;
		}
		else
		{
			self.weapon = IT_WEAPON2;
		}
		self.oldweapon = IT_WEAPON1;

		W_SetCurrentAmmo ();

		SetModelAndThinks();
	}
};


void ClientReEnter(float TimeDiff)
{
/*
	Called for living players entering a level
	(except for first starting a game)
	or when	you die any time other than on the
	first level	you started playing on.
*/
entity spot;
//string tempmodel;

	if(!self.flags2&FL_ALIVE||self.health<1||(self.newclass&&!deathmatch&&!coop))
	{//If dead, put them in the right spot.
		self.weapon=IT_WEAPON1;
		PutClientInServer();
		return;
	}

	// Need to reset these because they could still point to entities in the previous map
	self.enemy = self.groundentity = self.chain = self.goalentity = self.dmg_inflictor = 
		self.owner = world;

//RESET TIMERS:
	if(deathmatch)
	{
		self.items(-)IT_WEAPON4|IT_WEAPON2|IT_WEAPON3|IT_WEAPON4_1|IT_WEAPON4_2;
		self.skin=0;
	}
//	else if(self.sv_flags)
//		serverflags=self.sv_flags;

	self.movetype=MOVETYPE_WALK;
	self.viewentity=self;
	self.wallspot='0 0 0';
	self.deathtype="";
	self.act_state =
	self.onfire=
	self.healthtime=
	self.splash_time=
	self.decap=
	self.frozen= 
	self.plaqueflg = 0;
	self.artifact_active(-)ARTFLAG_FROZEN|ARTFLAG_STONED;

	self.ring_flight_time = 0;
	self.ring_flight = 0;
	self.rings (-) RING_FLIGHT;
	self.rings_active (-) RING_FLIGHT;

	self.air_finished = time + 12;

	self.ring_regen_time += TimeDiff; 
	self.ring_water_time += TimeDiff; 
	self.ring_turning_time += TimeDiff; 

	self.super_damage_time += TimeDiff; 
	self.haste_time  += TimeDiff; 
	self.tome_time  += TimeDiff; 
	self.camera_time  += TimeDiff; 
	self.torchtime += TimeDiff; 

	self.pausetime += TimeDiff; 
	self.teleport_time += TimeDiff; 
	self.sheep_time += TimeDiff; 
	self.attack_finished += TimeDiff;
	self.catapult_time+= TimeDiff;
	self.safe_time+= TimeDiff;
	self.absorb_time+= TimeDiff;
	self.last_impact+= TimeDiff;
	self.sheep_sound_time+= TimeDiff;
	self.still_time+= TimeDiff;
	self.last_onground+= TimeDiff;
	self.invincible_time+= TimeDiff;
	self.show_hostile+= TimeDiff;
	self.invisible_time+= TimeDiff;
	self.camptime+= TimeDiff;
	self.last_attack= self.attack_finished=0;

	self.light_level = 128;		// So the assassin doesn't go invisible coming out of the teleporter

	self.dmg = 2;   		// initial water damage

	setsize (self, '-16 -16 0', '16 16 56');	
	self.hull=HULL_PLAYER;
	self.view_ofs = '0 0 50';
	self.proj_ofs='0 0 44';

	spot = SelectSpawnPoint ();
	setorigin(self, spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.adjust_velocity = '-999 -999 -999';

	if (deathmatch || coop)
	{
		makevectors(self.angles);
		GenerateTeleportEffect(self.origin,0);
	}

	spawn_tdeath (self.origin, self);

	SetModelAndThinks();
	PlayerSpeed_Calc();
	W_SetCurrentAmmo ();

	force_retouch = 2;		// make sure even still objects get hit

	self.think=player_frames;
	thinktime self : 0;
}

void SetNewParms(void)
{
}

void SetChangeParms(void)
{
}

/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 0) (16 16 56)
The normal starting point for a level.
-----------------------FIELDS-------------------------

--------------------------------------------------------
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 0) (16 16 56)
Only used on start map for the return point from an episode.
-----------------------FIELDS-------------------------

--------------------------------------------------------
*/
void() info_player_start2 =
{
};


/*
saved out by quak ed in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 0) (16 16 56)
potential spawning position for deathmatch games
-----------------------FIELDS-------------------------

--------------------------------------------------------
*/
void() info_player_deathmatch =
{
	if(!deathmatch)
		remove(self);
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 0) (16 16 56) DEFAULT
potential spawning position for coop games
-----------------------FIELDS-------------------------

--------------------------------------------------------
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
	entity o;

	FindDMLevel();

	o = spawn();
	o.map = nextmap;

	if (nextmap == "")
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "demo1";
			o.map = mapname;
		}
	}

	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		thinktime o : 0.1;
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
float		timelimit;
float		fraglimit;
	
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
float		forward;

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
		if (self.button2 || self.button0)
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

void CheckWaterJump()
{
vector start, end;

// check for a climb out of water
	makevectors (self.angles);
	start = self.origin + self.proj_ofs - '0 0 8';
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		if(self.model=="models/sheep.mdl")
			start_z = self.origin_z + self.proj_ofs_z + 26;//was absmax - 8
		else
			start_z = self.origin_z + self.proj_ofs_z + 6;//was absmax - 8
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags(+)FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags(-)FL_JUMPRELEASED;
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
}

void()catapult_fire;
void() PlayerJump =
{
	if(self.flags&FL_ONGROUND)
	{
		traceline(self.origin,self.origin-'0 0 3',FALSE,self);
		if(trace_ent.classname=="catapult"&&trace_ent.frame==20)
		{
			trace_ent.think=catapult_fire;
			thinktime trace_ent : 0;
		}
	}

	if (self.flags & FL_WATERJUMP)
		return;

	if (self.movetype==MOVETYPE_FLY)
		return;

	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100*self.scale;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80*self.scale;
		else
			self.velocity_z = 50*self.scale;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "player/swim1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "player/swim2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.act_state=ACT_JUMP;

	self.flags(-)FL_JUMPRELEASED;

	self.flags(-)FL_ONGROUND;	// don't stairwalk
	
	self.button2 = 0;
// player jumping sound

	if(self.model=="models/sheep.mdl")//self.modelindex==modelindex_sheep)
		sheep_sound(1);
	else if(self.playerclass==CLASS_ASSASSIN)
		sound (self, CHAN_BODY,"player/assjmp.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_BODY,"player/paljmp.wav", 1, ATTN_NORM);

	self.velocity_z = self.velocity_z + 270*self.scale;
};




/*
===========
WaterMove

============
*/

void() WaterMove =
{

//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health <= 0)
		return;

	if ((self.flags & FL_INWATER) && (self.watertype == CONTENT_WATER) && (self.waterlevel == 3) && (!self.lefty))
	{
		DeathBubbles(10);
		self.lefty = 1;
	}

	if (self.waterlevel != 3) // Not up to the eyes
	{
		if (self.air_finished < time)
		{
			if (self.model=="models/sheep.mdl")
				sheep_sound(1);
			else if(self.playerclass==CLASS_ASSASSIN)
				sound (self, CHAN_VOICE, "player/assgasp1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/palgasp1.wav", 1, ATTN_NORM);
		}
		else if (self.air_finished < time + 9)
		{
			if (self.model=="models/sheep.mdl")
				sheep_sound(1);
			else if(self.playerclass==CLASS_ASSASSIN)
				sound (self, CHAN_VOICE, "player/assgasp2.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/palgasp2.wav", 1, ATTN_NORM);
		}
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	// Completely submerged and no air
	else if ((self.air_finished < time) && (!self.rings & RING_WATER))
	{
		if(self.playerclass==CLASS_PALADIN&&self.flags&FL_SPECIAL_ABILITY1)
		{
			self.air_finished = time + 12;
			self.dmg = 2;
		}
		else if (self.pain_finished < time)
		{// Drown
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{  // Getting out of the water
		if (self.flags & FL_INWATER)	
		{	// play leave water sound
			sound (self, CHAN_BODY, "raven/outwater.wav", 1, ATTN_NORM);
			self.flags(-)FL_INWATER;
			self.lefty = 0;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.5;

			if(other.flags&FL_FIREHEAL)
				other.health=other.health+5*self.waterlevel;
			else if(!other.flags&FL_FIRERESIST)
				T_Damage (self, world, world, 5*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}

	// Just entering fluid
	if (!(self.flags & FL_INWATER))
	{
		self.splash_time = time + 0.05;
		// player enter water sound
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "raven/inlava.wav", 1, ATTN_NORM);
		else if (self.watertype == CONTENT_WATER)
		{
			sound (self, CHAN_BODY, "raven/inh2o.wav", 1, ATTN_NORM);
		}
		else if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn1.wav", 1, ATTN_NORM);

		self.flags(+)FL_INWATER;
		self.dmgtime = 0;

	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void CheckCrouch (void)
{
	if ((self.crouch_time) && (self.crouch_time < time))  // Time to crouch or uncrouch a little
	{
		if (self.hull==HULL_CROUCH) // Player crouching
		{
			self.crouch_stuck = 0;
			self.view_ofs_z -= 10;
			self.proj_ofs_z -= 10;
			if (self.view_ofs_z < 24)
			{
				self.view_ofs_z = 24;
				self.proj_ofs_z = 18;
				self.crouch_time = 0;
			}	 
			else
				self.crouch_time = time + HX_FRAME_TIME/4;
		}
		else
		{
			self.view_ofs_z += 10;
			self.proj_ofs_z += 10;
			if (self.view_ofs_z > 50)
			{
				self.view_ofs_z = 50;
				self.proj_ofs_z = 44;
				self.crouch_time = 0;
			}	 
			else
				self.crouch_time = time + HX_FRAME_TIME/4;
		}
	}

	if ((self.flags2 & FL2_CROUCHED||self.model=="models/sheep.mdl"||self.flags2&FL2_CROUCH_TOGGLE) && (self.hull!=HULL_CROUCH)) 
		PlayerCrouching ();
	else if (((!self.flags2 & FL2_CROUCHED&&self.model!="models/sheep.mdl"&&!self.flags2&FL2_CROUCH_TOGGLE) && (self.hull==HULL_CROUCH)) ||
			(self.crouch_stuck))  // If stuck, constantly try to unstick
		PlayerUnCrouching();

}

void CheckIncapacities ()
{
vector dir;
	if(self.frozen>0)
		if(self.flags2&FL_ALIVE&&self.health)
		{
			if(self.colormap>144)
			{
				self.colormap-=0.5;
				self.abslight-=0.025;
			}
			else
			{
				self.colormap=0;
				self.abslight=0.5;
				self.skin=GLOBAL_SKIN_ICE;
			}
			if(self.pausetime<=time)
			{
				if(self.skin==GLOBAL_SKIN_ICE)
					self.skin=self.oldskin;
				self.colormap=0;
				self.abslight=0;
				self.thingtype=THINGTYPE_FLESH;
				self.drawflags(-)DRF_TRANSLUCENT|MLS_ABSLIGHT;
				self.frozen=FALSE;
				self.artifact_active(-)ARTFLAG_FROZEN;
			}
		}
		else
			self.frozen=self.pausetime=self.teleport_time=0;


	if(self.pausetime>time&&self.model!=self.headmodel)
	{
		if(self.model=="models/flesh1.mdl")
		{
			dir=normalize(self.wallspot-self.origin+self.view_ofs);
			dir=vectoangles(dir);
			self.o_angle_x=dir_x*-1;
			self.o_angle_y=dir_y;
			self.o_angle_z=self.v_angle_z;
		}
		else if(!self.flags2&FL_ALIVE&&self.enemy.flags2&FL_ALIVE)//&&visible(self.enemy))
		{//face enemy
			self.o_angle=normalize(self.enemy.origin+self.enemy.proj_ofs-self.origin+self.view_ofs);
			self.o_angle=vectoangles(self.o_angle);
			self.o_angle_x*=-1;//have to reverse the pitch
			if(self.o_angle_y>180)
				self.o_angle_y-=360;
			else if(self.o_angle_y<-180)
				self.o_angle_y+=360;
			self.o_angle_z=self.v_angle_z;
			self.o_angle-=self.v_angle;
			if(self.o_angle_x>7)
				self.o_angle_x=7;
			else if(self.o_angle_x<-7)
				self.o_angle_x=-7;
			if(self.o_angle_y>10)
				self.o_angle_y=10;
			else if(self.o_angle_y<-10)
				self.o_angle_y=-10;
			self.o_angle+=self.v_angle;
		}

        msg_entity = self;
	    WriteByte (MSG_ONE, 10);
        WriteAngle (MSG_ONE, self.o_angle_x);
	    WriteAngle (MSG_ONE, self.o_angle_y);
        WriteAngle (MSG_ONE, self.o_angle_z);
	    if(self.flags&FL_ONGROUND)
			self.velocity='0 0 0';
        self.button0=0;
		self.button2=0;
		if((self.impulse != 23)&&(self.impulse != 100))
 			self.impulse=0;					//allow item use while frozen
		else if(!(self.flags2 & FL_ALIVE))	//unless also dead
			self.impulse = 0;
	}

	if(self.flags2&FL_CHAINED)
		self.button0=self.button1=self.button2=0;
}

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	vector	spot1, spot2;	

//	if(self.velocity!='0 0 0'&&random()<0.01)
//		dprintv("pre_th: %s\n",self.velocity);

	/*If have problems being thrown out of world when die
	if ((self.health<=0) && (self.movetype!=MOVETYPE_NOCLIP))
	{
		if(pointcontents(self.origin)==CONTENT_SOLID&&self.origin!='0 0 0')
		{
			self.velocity='0 0 0';
			self.solid=SOLID_NOT;
			self.movetype=MOVETYPE_NOCLIP;
			setorigin(self,self.oldorigin);
		}
	}
*/
	if (!self.flags & FL_INWATER) self.aflag = 0;

//	dprint(teststr[1]);
//	dprint("\n");

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0'&&
		self.viewentity.classname!="chasecam"&&
		!self.button0&&!self.button2)//Causing them to not be able to respawn?
		return;		// intermission or finale

	if (self.adjust_velocity_x != -999)
	{
		self.velocity_x = self.adjust_velocity_x;
	}
	if (self.adjust_velocity_y != -999)
	{
		self.velocity_y = self.adjust_velocity_y;
	}
	if (self.adjust_velocity_z != -999)
	{
		self.velocity_z = self.adjust_velocity_z;
	}
	self.adjust_velocity = '-999 -999 -999';

	CheckIncapacities();

	if(self.viewentity!=self)
	{
		CameraViewPort(self,self.viewentity);
		if(self.viewentity.classname!="chasecam")//&&self.viewentity.classname!="camera_remote")
		{
			self.weaponframe=self.viewentity.weaponframe;
			self.weaponmodel=self.viewentity.weaponmodel;
			CameraViewAngles(self,self.viewentity);
		}
		else
			self.weaponmodel="";
	}

	makevectors (self.v_angle);		// is this still used

	self.friction=0;   // If in entity FRICTION_TOUCH will reset this

	CheckRules ();
	CheckRings ();
	CheckAbilities ();
	CheckCrouch ();

	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	// Turn off plaque if it is on
	if (self.plaqueflg)
	{	// Is moving or looking around so kill plaque
		if (((self.velocity_x) || (self.velocity_y) || (self.velocity_z)) ||
			(self.plaqueangle != self.v_angle))
		{
			makevectors (self.v_angle);

			spot1 = self.origin + self.view_ofs;
			spot2 = spot1 + (v_forward*25); // Look just a little ahead
			traceline (spot1, spot2 , FALSE, self);

			if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
			{
				traceline (spot1, spot2 - (v_up * 30), FALSE, self);  // 30 down
			
				if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
				{
					traceline (spot1, spot2 + v_up * 30, FALSE, self);  // 30 up
				
					if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
					{
						self.plaqueflg=0;
						msg_entity = self;
						plaque_draw(MSG_ONE,0);
					}
				}
			}

			if (self.plaqueflg)
				self.plaqueangle = self.v_angle;
		}
	}

	// Twitch every so often if not moving
	if ((!self.velocity_x) && (!self.velocity_y) && (!self.velocity_z))
	{
		// FIXME: needs to be a random number between 5 - 8 minutes or so
		if ((self.camptime + 600) < time)
		{
			if (self.playerclass==CLASS_PALADIN)
			{
				if (self.weapon==IT_WEAPON1)
					gauntlet_twitch();
				else if (self.weapon==IT_WEAPON2)
					vorpal_twitch();
				self.camptime = time + random(840,420);
			}
		}
	}
	else
		self.camptime = time + random(420,840);


	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
		PlayerJump ();
	else
		self.flags(+)FL_JUMPRELEASED;

// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	// Change weapon
	if (time > self.attack_finished && self.weapon != IT_WEAPON1)
	{
		if (((self.weapon == IT_WEAPON3) && (self.greenmana<1)) ||
			((self.weapon == IT_WEAPON4) && (self.bluemana<1) && (self.greenmana<1)))
		{
			W_BestWeapon ();
			W_SetCurrentWeapon ();
		}
	}
};

void CheckRings (void)
{
	entity victim;
	vector dir;
	float chance;

	if (self.health <= 0)
		return;

	if (self.rings & RING_REGENERATION)
	{	
		if (self.ring_regen_time < time)
		{
			if (self.health < self.max_health)
			{
				self.ring_regeneration -= 100/RING_REGENERATION_MAX;
				self.health += 1;				
				self.ring_regen_time = time + 1;
			}	

			if ((self.ring_regeneration < 10)  && (!self.rings_low & RING_REGENERATION))
			{
				self.rings_low (+) RING_REGENERATION;
				centerprint (self, "Ring of Regeneration is running low");
				sound (self, CHAN_BODY, "misc/comm.wav", 1, ATTN_NORM);
			}

			if (self.ring_regeneration <=0)
			{
				self.ring_regeneration = 0;
				self.rings (-) RING_REGENERATION;
				self.rings_active (-) RING_REGENERATION;
			}
		}
	}

	if (self.rings & RING_FLIGHT)
	{	
		if (self.ring_flight_time < time)
		{
			self.ring_flight -= 100/RING_FLIGHT_MAX;

			if ((self.ring_flight < 25)  && (!self.rings_low & RING_FLIGHT))
			{
				self.rings_low (+) RING_FLIGHT;
				centerprint (self, "Ring of Flight is running low");
				sound (self, CHAN_BODY, "misc/comm.wav", 1, ATTN_NORM);
			}

			if (self.ring_flight <=0)
			{
				self.ring_flight = 0;
				self.rings (-) RING_FLIGHT;
				self.rings_active (-) RING_FLIGHT;
				player_stopfly();
				if (deathmatch)
					self.cnt_flight -= 1;
			}
			self.ring_flight_time = time + 1;
		}
	}


	if ((self.rings & RING_WATER) && (self.waterlevel == 3) && (self.air_finished < time))
	{	
		self.rings_active (+) RING_WATER;
		if (self.ring_water_time < time)
		{
			self.ring_water -= 100/RING_WATER_MAX;

			if ((self.ring_water < 25)  && (!self.rings_low & RING_WATER))
			{
				self.rings_low (+) RING_WATER;
				centerprint (self, "Ring of Water Breathing is running low");
				sound (self, CHAN_BODY, "misc/comm.wav", 1, ATTN_NORM);
			}

			if (self.ring_water <=0)
			{
				self.ring_water = 0;
				self.rings (-) RING_WATER;
				self.rings_active (-) RING_WATER;
			}
			self.ring_water_time = time + 1;
		}
	}
	else
		self.rings_active (-) RING_WATER;

	if (self.rings & RING_TURNING)
	{	
		victim = findradius( self.origin, 100);
		while(victim)
		{
			if ((victim.movetype == MOVETYPE_FLYMISSILE) && (victim.owner != self))
			{
				victim.owner = self;
				chance = random();
				dir = victim.origin + (v_forward * -1);
				CreateLittleWhiteFlash(dir);
				sound (self, CHAN_WEAPON, "weapons/vorpturn.wav", 1, ATTN_NORM);
				if (chance < 0.9)  // Deflect it
				{
					victim.v_angle = self.v_angle + randomv('0 0 0', '360 360 360'); 
					makevectors (victim.v_angle);
					victim.velocity = v_forward * 1000;
				}
				else  // reflect missile
					victim.velocity = '0 0 0' - victim.velocity;
			}
			victim = victim.chain;
		}


		if (self.ring_turning_time < time)
		{
			self.ring_turning -= 100/RING_TURNING_MAX;

			if ((self.ring_turning < 10)  && (!self.rings_low & RING_TURNING))
			{
				self.rings_low (+) RING_TURNING;
				centerprint (self, "Ring of Reflection is running low");
				sound (self, CHAN_BODY, "misc/comm.wav", 1, ATTN_NORM);
			}

			if (self.ring_turning <=0)
			{
				self.ring_turning = 0;
				self.rings (-) RING_TURNING;
				self.rings_active (-) RING_TURNING;
			}

			self.ring_turning_time = time + 1;
		}
	}

}
	
void remove_invincibility(entity loser)
{
	loser.artifact_low(-)ART_INVINCIBILITY;
	loser.artifact_active (-) ART_INVINCIBILITY;
	loser.invincible_time = 0;
	loser.air_finished = time + 12;
	if(loser.playerclass==CLASS_CRUSADER)
		loser.skin = 0;
	else if(loser.playerclass==CLASS_PALADIN)
		loser.effects(-)EF_BRIGHTLIGHT; 
	else if(loser.playerclass==CLASS_ASSASSIN)
		loser.colormap=0;
	else if(loser.playerclass==CLASS_NECROMANCER)
		loser.effects(-)EF_DARKLIGHT;
}


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

	if (self.divine_time < time)
		self.artifact_active (-) ARTFLAG_DIVINE_INTERVENTION;
		
	// Crusader's special ability to smite 
	if (self.super_damage)
	{
		if (self.super_damage_time < time) 
		{
			self.super_damage = 0;		
		}
		else if (((self.super_damage_time - 10) < time) && (!self.super_damage_low))
		{
			self.super_damage_low = 1;
			sprint (self, PRINT_MEDIUM, "Holy Strength begins to wane\n");
			stuffcmd (self, "bf\n");
		}
	}

	if (self.artifact_active & ART_HASTE)
	{
		if (self.haste_time < time)
		{
			self.artifact_low =self.artifact_low - (self.artifact_low & ART_HASTE);
			self.artifact_active =self.artifact_active - (self.artifact_active & ART_HASTE);
			self.effects(-)EF_DARKFIELD;
			PlayerSpeed_Calc();
			self.haste_time = 0;
			self.air_finished = time + 12;
		}
		else if ((self.haste_time - 10) < time)
			self.artifact_low = self.artifact_low | ART_HASTE;
	}


	if (self.artifact_active & ART_INVINCIBILITY)
	{
		if (self.invincible_time < time)
			remove_invincibility(self);
		else if ((self.invincible_time - 10) < time)
			self.artifact_low = self.artifact_low | ART_INVINCIBILITY;
	}

//	if (self.artifact_active & ART_TOMEOFPOWER)
//	{
		if ((self.drawflags & MLS_MASKIN) != MLS_POWERMODE)
			self.drawflags = (self.drawflags & MLS_MASKOUT)| MLS_POWERMODE;

		if (self.tome_time < time)
		{
			self.artifact_low = self.artifact_low - (self.artifact_low & ART_TOMEOFPOWER);
			self.artifact_active = self.artifact_active - (self.artifact_active & ART_TOMEOFPOWER);
			self.tome_time = 0;
			self.drawflags = (self.drawflags & MLS_MASKOUT)| 0;
		}
		else if ((self.tome_time - 10) < time)
			self.artifact_low = self.artifact_low | ART_TOMEOFPOWER;
//	}
	

// invisibility
	if (self.artifact_active & ART_INVISIBILITY)
	{
		if (self.invisible_time < time)
		{	// just stopped
			self.artifact_low = self.artifact_low - (self.artifact_low & ART_INVISIBILITY);
			self.artifact_active = self.artifact_active - (self.artifact_active & ART_INVISIBILITY);
			self.invisible_time = 0;
			msg_entity=self;
			WriteByte(MSG_ONE, SVC_CLEAR_VIEW_FLAGS);
			WriteByte(MSG_ONE,DRF_TRANSLUCENT);
			self.effects(-)EF_NODRAW|EF_LIGHT;
		}
		else
		{
			if ((self.invisible_time - 10) < time)
				self.artifact_low = self.artifact_low | ART_INVISIBILITY;
		}

	}

	if (self.sheep_time<time+3&&self.model=="models/sheep.mdl")//self.modelindex==modelindex_sheep)
	{
		// sound and screen flash when items starts to run out
		if (!self.sheep_sound_time)
		{
			sprint (self, PRINT_MEDIUM, "Polymorph Spell is wearing off...");
			stuffcmd (self, "bf\n");
//oops!
//			sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
			self.sheep_sound_time=TRUE;
		}
			
		if (self.sheep_time < time)
		{
			sound(self,CHAN_VOICE,"misc/sheepfly.wav",1,ATTN_NORM);
			particleexplosion((self.absmin+self.absmax)*0.5,random(144,159),self.absmax_z-self.absmin_z,50);
			GenerateTeleportEffect(self.origin,1);

			self.oldweapon = FALSE;
			self.weapon = IT_WEAPON1;
			restore_weapon();
			SetModelAndThinks();

			setsize (self, '-16 -16 0', '16 16 28');	
			self.hull=HULL_CROUCH;
			PlayerSpeed_Calc();

			self.think=player_frames;
			thinktime self : 0;
		}
	}

	if(self.cameramode != world)
	{
		if(deathmatch)
		{
			if(self.velocity!='0 0 0'||self.pain_finished>time||self.button0||self.button2)
				CameraReturn ();
		}
		else if (self.camera_time < time)
			CameraReturn ();
	}
};

/*
================
Player Touch

Mainly used to allow player to climb on top of monsters,
other players, etc.
================
*/
void PlayerTouch (void)
{
/*
	if(self.velocity!='0 0 0')
		dprintv("touched %s\n",self.velocity);
	else
		dprint("Touch with no vel!\n");
*/

	if(other.classname=="monster_eidolon")
		return;

	if(other.dmg==666&&(other.velocity!='0 0 0'||other.avelocity!='0 0 0'))
	{
		self.decap=TRUE;
		T_Damage (self, other, other, self.health+300);
		return;
	}

	if(((vlen(self.velocity)*(self.mass/10)>=100&&self.last_onground+0.3<time)||other.thingtype>=THINGTYPE_WEBS)&&self.last_impact+0.1<=time)
		obj_fly_hurt(other);

	if(other==world)
		return;

/*Client pushing client- doesn't work in HW
	if(coop||deathmatch)
	{
		if(other.classname=="player")
		{
		entity pusher,pushee;
			if(self.adjust_velocity!='0 0 0')
				self.velocity=self.adjust_velocity;
			if(other.adjust_velocity!='0 0 0')
				other.velocity=other.adjust_velocity;
			if(self.velocity!='0 0 0')
			{
				pusher=self;
				pushee=other;
			}
			else if(other.velocity!='0 0 0')
			{
				pusher=other;
				pushee=self;
			}
			if(pusher!=world)
			{
				sprint(pusher,PRINT_HIGH,"You are pushing\n");
				sprint(pushee,PRINT_HIGH,"You are being pushed\n");
				if(normalize(pusher.velocity)*normalize(pushee.origin-pusher.origin)>0.2)
				{
					if(fabs(pushee.origin_z-pusher.origin_z)<48)
					{
					float push_mod;
						if(pusher.flags&FL_ONGROUND)
							push_mod=.33;
						else
							push_mod=.77;
						if(pushee.flags&FL_ONGROUND&&pusher.velocity_z<0)
						{
							pushee.velocity_x=(pushee.velocity_x/push_mod+pusher.velocity_x*push_mod)*push_mod;
							pushee.velocity_y=(pushee.velocity_y/push_mod+pusher.velocity_y*push_mod)*push_mod;
						}
						else
							pushee.velocity=(pushee.velocity*(1/push_mod)+pusher.velocity*push_mod)*push_mod;
						pushee.flags(-)FL_ONGROUND;
						pushee.adjust_velocity=pushee.velocity;
					}
				}
			}
			else
				sprint(self,PRINT_HIGH,"Neither one is moving\n");
		}
	}
*/
	if(self.flags&FL_ONGROUND)
		return;
	else if((other.classname=="player"||other.flags&FL_ONGROUND||other.health)&&self.origin_z>=(other.absmin_z+other.absmax_z)*0.5&&self.velocity_z<10)
		self.flags(+)FL_ONGROUND;
}

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	if (intermission_running)
		return;

	if (self.deadflag)
		return;
// do weapon stuff

	W_WeaponFrame ();

	if(self.viewentity.classname=="chasecam")
		self.weaponmodel="";

// check to see if player landed and play landing sound	
	if ((self.jump_flag*(self.mass/10) < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if(self.absorb_time>=time)
			self.jump_flag/=2;
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojmp.wav", 1, ATTN_NORM);
		else if (self.jump_flag*(self.mass/10) < -500)//was -650
		{
			if(self.playerclass==CLASS_ASSASSIN)
				sound (self, CHAN_VOICE, "player/asslnd.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/pallnd.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
		if(self.scale>1&&self.jump_flag*(self.mass/10) < -500)
			MonsterQuake((self.mass/10)*self.jump_flag);
		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
	else
		self.last_onground=time;

	CheckPowerups ();

	if(self.artifact_flags & AFL_TORCH)
	{
		if (self.torchtime < time)
			self.torchthink ();
		if (self.frozen)
		{
			self.frozen -= 8;
			if(self.frozen <= 0)
			{
				self.attack_finished = time;
				self.pausetime = time;	//so it'll release you
				thinktime self : 0.01;
				self.frozen = 0.01;		//as soon as it checks for frozen
			}
		}
	}

//	if ((self.artifact_flags & AFL_TORCH) && (self.torchtime < time))
//		self.torchthink ();

	if ((self.artifact_flags & AFL_SUPERHEALTH) && (self.healthtime < time))
		DecrementSuperHealth ();

//	if(self.velocity!='0 0 0')
//		dprintv("post_th: %s\n",self.velocity);
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (PRINT_MEDIUM, self.netname);
	bprinti (PRINT_MEDIUM, STR_JOINEDTHEGAME);

	if(dmMode == DM_CAPTURE_THE_TOKEN)
	{
		centerprint(self, "Server is running Hoard the Icon...");
	}
	else if(dmMode == DM_HUNTER)
	{
		centerprint(self, "Server is running Hunter...");
	}

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
	entity curPlayer;

	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprintname (PRINT_MEDIUM, self);
	bprinti (PRINT_MEDIUM, STR_LEFTTHEGAMEWITH);
	bprint (PRINT_MEDIUM, ftos(self.frags));
	bprinti (PRINT_MEDIUM, STR_FRAGS);
	sound (self, CHAN_BODY, "player/leave.wav", 1, ATTN_NONE);
	GibPlayer('0 0 1');
	set_suicide_frame ();

	if(dmMode == DM_HUNTER)
	{	// to properly remove the guy...
		self.gameFlags (+) GF_HAS_LEFT_HUNTER;

		curPlayer = find(world, classname, "player");
		while(curPlayer != world)
		{
			if(curPlayer.targetPlayer == self)
			{
				curPlayer.targetPlayer = world;
			}
			curPlayer = find(curPlayer, classname, "player");
		}
	}
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker, entity inflictor) ClientObituary =
{
	float rnum,tclass,aclass,reversed,powered_up, exp_mult;
	string iclass;
	float deathstring, deathstring2;
	if (targ.classname != "player")
		return;

	if(dmMode == DM_CAPTURE_THE_TOKEN)
	{	// scoring only takes place when one of the two characters has the token in this game mode
		if((!(targ.gameFlags & GF_HAS_TOKEN))&&(!(attacker.gameFlags & GF_HAS_TOKEN)))
		{
			return;
		}
	}
	else if (dmMode == DM_HUNTER)
	{
		if(attacker.classname == "player")
		{
			if(attacker.targetPlayer == targ)
			{
				attacker.frags += 1;

				bprintname (PRINT_MEDIUM, attacker);
				bprint (PRINT_MEDIUM, " slew his target!\n");

				if(targ.targetPlayer == attacker)
				{	// pick a new random target
					GetRandomTarget(attacker);
					centerprint2(attacker, "Your new target is ",attacker.targetPlayer.netname);
				}
				else
				{
					attacker.targetPlayer = targ.targetPlayer;
					centerprint2(attacker, "Your new target is ",attacker.targetPlayer.netname);
					targ.targetPlayer = attacker;
					centerprint2(targ, "Your new target is ",targ.targetPlayer.netname);
				}
			}
			else if(targ.targetPlayer == attacker)
			{	// nothing actually happens in this case...
				bprintname (PRINT_MEDIUM, attacker);
				bprint (PRINT_MEDIUM, " valiantly fought off an attacker!\n");
			}
			else if(attacker == targ)
			{
				attacker.frags -= 1;
				bprintname (PRINT_MEDIUM, attacker);
				bprint (PRINT_MEDIUM, " killed himself!\n");
			}
			else
			{
				targ.targetPlayer = attacker;

				attacker.frags -= 2;
				bcenterprint2(attacker.netname, " killed an innocent!");
				centerprint2(targ, "Your new target is ",targ.targetPlayer.netname);
			}
		}
		return;
	}

	tclass=targ.playerclass;
	aclass=attacker.playerclass;
	iclass=inflictor.classname;
	powered_up=inflictor.frags;
	exp_mult=1;
	rnum = random();

	if (targ.deathtype == "teledeath")
	{
		bprintname (PRINT_MEDIUM, targ);
		bprinti (PRINT_MEDIUM, STR_WASTELEFRAGGEDBY);
		bprintname (PRINT_MEDIUM, attacker);
		bprint (PRINT_MEDIUM, "\n");

		attacker.frags += 1;
		return;
	}

	if (targ.deathtype == "teledeath2")
	{
		bprint (PRINT_MEDIUM, "The power of invincibility reflects ");
		bprintname (PRINT_MEDIUM, targ);
		bprint (PRINT_MEDIUM, "'s telefrag\n");

		targ.frags -= 1;
		return;
	}

	if (targ.deathtype == "teledeath3")
	{
		bprintname (PRINT_MEDIUM, attacker);
		bprint (PRINT_MEDIUM, " telefragged ");
		bprintname (PRINT_MEDIUM, targ);
		bprint (PRINT_MEDIUM, ", his own teammate!\n");

		attacker.frags -= 1;
		return;
	}

	if (targ.deathtype == "teledeath4")
	{
			bprintname (PRINT_MEDIUM, attacker);
			bprint (PRINT_MEDIUM, "'s invincibility met ");
			bprintname (PRINT_MEDIUM, targ);
			bprint (PRINT_MEDIUM, "'s invincibility and mutual annihilation resulted!\n");

		targ.frags -= 1;
		return;
	}

	// Was killed by a player
	if (attacker.classname == "player")
	{
		if (targ == attacker)
		{
			// killed self
			attacker.frags -= 1;
			bprintname (PRINT_MEDIUM, targ);
			
			if(random()<0.5)
				bprinti (PRINT_MEDIUM, STR_MUSTBEMASOCHIST);
			else
				bprinti (PRINT_MEDIUM, STR_BECOMESBORED);
			return;
		}
		else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
		{
			if (rnum < 0.25)
				deathstring = STR_MOWSTEAMMATE;
			else if (rnum < 0.50)
				deathstring = STR_CHECKSGLASSES;
			else if (rnum < 0.75)
				deathstring = STR_GETSFRAGFOROTHER;
			else
				deathstring = STR_LOSESANOTHERFRIEND;
			bprintname (PRINT_MEDIUM, attacker);
			bprinti (PRINT_MEDIUM, deathstring);
			attacker.frags -= 1;
			return;
		}
		else
		{
			attacker.frags += 1;

			rnum = attacker.weapon;
			if(attacker.model=="models/sheep.mdl")
			{
				deathstring = STR_WASNIBBLED;
				deathstring2 = STR_THESHEEP;
			}
			else if(targ.decap==1)
			{
				if(tclass==CLASS_ASSASSIN)
					deathstring = STR_LOSTHERHEAD;
				else
					deathstring = STR_LOSTHISHEAD;
				deathstring2 = STR_EXCLAMRETURN;
			}
			else if (targ.decap==2)
			{
				if (tclass==CLASS_ASSASSIN)
				{
					deathstring = STR_GOTHERHEADBLOWN;
					deathstring2 = STR_EXCLAMRETURN;
				}
				else
				{
					deathstring = STR_GOTHISHEADBLOWN;
					deathstring2 = STR_EXCLAMRETURN;
				}
			}
			else if (iclass=="cube_of_force")
			{
				deathstring = STR_WASVENTILATED;
				deathstring2 = STR_SFORCECUBE;
			}
			else if(iclass=="tripwire")
			{
				deathstring = STR_TRIPPEDON;
				deathstring2 = STR_STRIPPEDWIRE;
			}
			else if(iclass=="fireballblast")
			{
				deathstring = STR_WASBLOWNAWAY;
				deathstring2 = STR_SDELAYEDFIREBALL;
			}
			else if(iclass=="proximity")
			{
				deathstring = STR_GOTTOOCLOSE;
				deathstring2 = STR_SPROXIMITYGLYPH;
			}
			else if(iclass=="timebomb")
			{
				deathstring = STR_WASINWRONGPLACE;
				deathstring2 = STR_STIMEBOMB;
			}
			else if(iclass=="tornato")
			{
				deathstring = STR_ISNTINKANSAS;
				deathstring2 = STR_STORNADO;
			}
			else if(iclass=="blizzard")
			{
				deathstring = STR_WASSNOWEDIN;
				deathstring2 = STR_SBLIZZARD;
			}
			else if(targ.deathtype=="hammercrush")
			{
				deathstring = STR_WASCRUSHEDBYRIGHTEOUS;
				deathstring2 = STR_SHAMMER;
			}
			else if (iclass == "monster_imp_lord")
			{
				deathstring =STR_WASJACKEDUP;
				deathstring2 =STR_SSUMMONEDIMP;
			}
			else if(inflictor.frags==2)
			{
				deathstring = STR_WASDESTROYEDBYPOWER;
				deathstring2 = STR_SDISCOFREPUL;
			}
			else if (rnum == IT_WEAPON1) 
			{
				if(attacker.artifact_active&ART_TOMEOFPOWER)
					exp_mult=1.5;
				else
					exp_mult=2;
				if(aclass==CLASS_ASSASSIN)
				{
					deathstring = STR_GOTPENETRATED;
					deathstring2 = STR_SKATAR;
				}
				else if(aclass==CLASS_CRUSADER)
				{
					if(exp_mult==1.5)
					{
						deathstring = STR_WASFRIEDBYHOLY;
						deathstring2 = STR_SMJOLNIR;
					}
					else
					{
						deathstring = STR_WASWHALLOPED;
						deathstring2 = STR_SHAMMER2;
					}
				}
				else if(aclass==CLASS_PALADIN)
				{
					deathstring = STR_GOTKODBY;
					deathstring2 = STR_SFISTSOFFURY;
				}
				else
				{
					deathstring = STR_WASSLICEDANDDICED;
					deathstring2 = STR_SSICKLE;
				}
			}
			else if (rnum == IT_WEAPON2) 
			{
				if(powered_up)
					exp_mult=1;
				else
					exp_mult=1.2;
				if(aclass==CLASS_ASSASSIN)
				{
					if(powered_up)
					{
						deathstring = STR_WASSTUCKLIKEPIG;
						deathstring2 = STR_SARROWS;
					}
					else
					{
						deathstring = STR_TOOKONEOF;
						deathstring2 = STR_SARROWTOHEART;
					}
				}
				else if(aclass==CLASS_CRUSADER)
				{
					if(powered_up)
					{
						deathstring = STR_BEFELLTHESUB;
						deathstring2 = SBLIZZARD;
					}
					else
					{
						deathstring = STR_GETSCOLDSHOULDER;
						deathstring2 = STR_EXCLAMRETURN;//HEY STEVE!! DON'T RE-ENTER ME IN STRING LIST!!!!
					}
				}
				else if(aclass==CLASS_PALADIN)
				{
					if(powered_up)
					{
						deathstring = STR_TOOKASHOCKTOSYS;
						deathstring2 = STR_SVORPALSHOCK;
					}
					else
					{
						deathstring = STR_WASCUTTOPIECES;
						deathstring2 = STR_SVORPALSWORD;
					}
				}
				else
				{
					if(powered_up)
					{
						deathstring = STR_WASTRACKEDDOWN;
						deathstring2 = STR_SMAGICMISSILES;
					}
					else
					{
						deathstring = STR_WASMOWEDDOWN;
						deathstring2 = STR_SMAGICMISSILES;//NO REPEATY PLEEZ!!!!!
					}
				}
			}
			else if (rnum == IT_WEAPON3) 
			{
				if(powered_up)
					exp_mult=0.8;
				else
					exp_mult=1;
				if(aclass==CLASS_ASSASSIN)
				{
					if(powered_up)
					{
						reversed=TRUE;
						deathstring = STR_OPENEDWHOOPASS;
						deathstring2 = STR_EXCLAMRETURN;//HEY STEVE!! DON'T RE-ENTER ME IN STRING LIST!!!!
					}
					else
					{
						deathstring = STR_SUCKEDDOWN;
						deathstring2 = STR_SGRENADE;
					}
				}
				else if(aclass==CLASS_CRUSADER)
				{
					if(powered_up)
					{
						deathstring = STR_WASWHISKEDAWAY;
						deathstring2 = STR_STORNADO;
					}
					else
					{
						deathstring = STR_TOOKNICEMETEOR;
						deathstring2 = STR_EXCLAMRETURN;//HEY STEVE!! DON'T RE-ENTER ME IN STRING LIST!!!!
					}
				}
				else if(aclass==CLASS_PALADIN)
				{
					if(powered_up)
					{
						deathstring = STR_WASCUTDOWNBY;
						deathstring2 = STR_SMAGICAXEBLADES;
					}
					else
					{
						deathstring = STR_GOTNASTYPAPER;
						deathstring2 = STR_SAXEBLADE;
					}
				}
				else
				{
					if(powered_up)
					{
						deathstring = STR_WASFRAGGEDBY;
						deathstring2 = STR_SFRAGBONES;
					}
					else
					{
						reversed=TRUE;
						deathstring = STR_BROKE;
						deathstring2 = STR_SBONESWITHBONESHARD;
					}
				}
			}
			else if (rnum == IT_WEAPON4) 
			{
				if(powered_up)
					exp_mult=0.5;
				else
					exp_mult=0.8;
				if(aclass==CLASS_ASSASSIN)
				{
					if(powered_up)
					{
						deathstring = STR_GOTINTOSANDM;
						deathstring2 = STR_SCHAINS;
					}
					else
					{
						deathstring = STR_GOTCOREDBY;
						deathstring2 = STR_SSCARABSTAFF;
					}
				}
				else if(aclass==CLASS_CRUSADER)
				{
					if(attacker.artifact_active&ART_TOMEOFPOWER)
					{
						exp_mult=0.5;
						deathstring = STR_NEEDSSPF5MIL;
						deathstring2 = STR_SSUNSTAFF;
					}
					else
					{
						deathstring = STR_SMELLSLIKECHICKEN;
						deathstring2 = STR_SSUNSTAFF;//AGAIN: NO REPEATY PLEEZ!!!!!
					}
				}
				else if(aclass==CLASS_PALADIN)
				{
					if(powered_up)
					{
						deathstring = STR_WASBLOWNINTONEXTWEEK;
						deathstring2 = STR_SPURIFIERSEEKER;
					}
					else
					{
						deathstring = STR_SEVILWAYSPURIFIED;
						deathstring2 = STR_EXCLAMRETURN;//HEY STEVE!! DON'T RE-ENTER ME IN STRING LIST!!!!
					}
				}
				else
				{
					if(powered_up)
					{
						deathstring = STR_SUCCUMBEDTOBLACK;
						deathstring2 = STR_SRAVENS;
					}
					else
					{
						deathstring = STR_BEFELLBLACKMAGIC;
						deathstring2 = STR_SRAVENSTAFF;
					}
				}
			}
			if(reversed)
			{
				bprintname (PRINT_MEDIUM, attacker);
				bprinti (PRINT_MEDIUM, deathstring);
				bprintname (PRINT_MEDIUM, targ);
				bprinti (PRINT_MEDIUM, deathstring2);
			}
			else
			{
				bprintname (PRINT_MEDIUM, targ);
				bprinti (PRINT_MEDIUM, deathstring);
				bprintname (PRINT_MEDIUM, attacker);
				bprinti (PRINT_MEDIUM, deathstring2);
			}
		}
		return;
	}

	// was not killed by a player
	else
	{
		targ.frags -= 1;
		bprint (PRINT_MEDIUM, targ.netname);

		if (attacker.flags & FL_MONSTER)
		{
			if(attacker.model=="models/sheep.mdl")
				if(random()<0.5)
					bprint (PRINT_MEDIUM, " was savagely mauled by a sheep!\n");
				else
					bprint (PRINT_MEDIUM, " says 'HELLO DOLLY!'\n");
			if (attacker.classname == "monster_archer")
				bprint (PRINT_MEDIUM, " was skewered by an Archer!\n");
			if (attacker.classname == "monster_archer_lord")
				bprint (PRINT_MEDIUM, " got Horshacked!\n");
			if (attacker.classname == "monster_fallen_angel")
				bprint (PRINT_MEDIUM, " was felled by the Fallen Angel\n");
			if (attacker.classname == "monster_fallen_angel_lord")
				bprint (PRINT_MEDIUM, " was decimated by a Fallen Angel Lord!\n");
			if (attacker.classname == "monster_golem_bronze")
				if(targ.decap==1)
					bprint (PRINT_MEDIUM, "'s head was taken as a trophy for the Bronze Golem!\n");
				else if(targ.decap==2)
					bprint (PRINT_MEDIUM, " became a permanent stain on the wall!\n");
				else
					bprint (PRINT_MEDIUM, " was squished like an insect by a Bronze Golem!\n");
			if (attacker.classname == "monster_golem_iron")
			{
				if (inflictor.classname == "golem_iron_proj")
					bprint(PRINT_MEDIUM, " felt the sting of the Iron Golem's jewel!\n");
				else if(targ.decap==2)
					bprint (PRINT_MEDIUM, "'s brains make nice wall decorations!\n");
				else
					bprint (PRINT_MEDIUM, " was crushed by the Iron Golem's fist!\n");
			}
			if (attacker.classname == "monster_golem_stone")
				if(targ.decap==2)
					bprint (PRINT_MEDIUM, " is feeling a little light-headed!\n");
				else
					bprint (PRINT_MEDIUM, " was pummeled by a Stone Golem!\n");
			if (attacker.classname == "monster_golem_crystal")
				bprint (PRINT_MEDIUM, " was mangled by the Enchanted Crystal Golem!\n");
			if (attacker.classname == "monster_hydra")
				bprint (PRINT_MEDIUM, " becomes food for the Hydra!\n");
			if (attacker.classname == "monster_imp_fire")
				bprint (PRINT_MEDIUM, " was roasted by a Fire Imp!\n");
			if (attacker.classname == "monster_imp_ice")
				bprint (PRINT_MEDIUM, " chills out with the Ice Imps!\n");
			if (attacker.classname == "monster_medusa")
				if (attacker.skin==1)
					bprint (PRINT_MEDIUM, " was stricken by the beauty of the Crimson Medusa!\n");
				else
					bprint (PRINT_MEDIUM, " is helpless in the face of the Medusa's beauty!\n");
			if (attacker.classname == "monster_mezzoman")
				if (attacker.skin==1)
					bprint (PRINT_MEDIUM, " is not yet worthy of facing the WerePanther!\n");
				else
					bprint (PRINT_MEDIUM, " is no match for the WereJaguar!\n");
			if (attacker.classname == "monster_mummy")
				bprint (PRINT_MEDIUM, " got mummified!\n");
			if (attacker.classname == "monster_mummy_lord")
				bprint (PRINT_MEDIUM, " was escorted to the Underworld by a Mummy Lord!\n");
			if (attacker.classname == "monster_scorpion_black")
				bprint (PRINT_MEDIUM, " submits to the sting of the Black Scorpion!\n");
			if (attacker.classname == "monster_scorpion_yellow")
				bprint (PRINT_MEDIUM, " was poisoned by the fatal Golden Scorpion!\n");
			if (attacker.classname == "monster_skull_wizard")
				bprint (PRINT_MEDIUM, " succumbed to the Skull Wizard's magic!\n");
			if (attacker.classname == "monster_skull_wizard_lord")
				bprint (PRINT_MEDIUM, " was Skull-duggeried!\n");
			if (attacker.classname == "monster_snake")
				bprint (PRINT_MEDIUM, " was bitten by the lethal Cobra!\n");
			if (attacker.classname == "monster_spider_red_large")
				bprint (PRINT_MEDIUM, " was overcome by the Crimson Spiders!\n");
			if (attacker.classname == "monster_spider_red_small")
				bprint (PRINT_MEDIUM, " was eaten alive by the spiders!\n");
			if (attacker.classname == "monster_spider_yellow_large")
				bprint (PRINT_MEDIUM, " was overwhelmed by the Golden Spiders!\n");
			if (attacker.classname == "monster_spider_yellow_small")
				bprint (PRINT_MEDIUM, " is a meal for the spiders!\n");
			if (attacker.classname == "rider_famine")
				bprint(PRINT_MEDIUM, " was drained of life-force by Famine!\n");
			if (attacker.classname == "rider_death")
				if(inflictor==attacker)
					bprint(PRINT_MEDIUM, " was snuffed out of existance by Death!\n");
				else if(inflictor.netname=="deathbone")
					bprint(PRINT_MEDIUM, " had his bones crushed to a fine powder by Death!\n");
				else if(iclass=="deathmissile")
					bprint(PRINT_MEDIUM, " was shot down by Death's crimson bolts!\n");
				else
					bprint(PRINT_MEDIUM, " was smitten by Death's unholy fire\n");
			if (attacker.classname == "rider_pestilence")
				if(targ.deathtype=="poison")
					bprint(PRINT_MEDIUM, " was poisoned to death by Pestilence's Crossbow!\n");
				else
					bprint(PRINT_MEDIUM, "'s rotted corpse is the possession of Pestilence!\n");
			if (attacker.classname == "rider_war")
				bprint(PRINT_MEDIUM, " was taught the true meaning of War!\n");
			if (attacker.classname == "monster_eidolon")
				if(inflictor==attacker)
					bprint(PRINT_MEDIUM, " was squashed like an insect by Eidolon!\n");
				else if(inflictor.classname=="eidolon fireball")
					bprint(PRINT_MEDIUM, " was obliterated by Eidolon's fireballs!\n");
				else if(inflictor.classname=="eidolon spell")
					bprint(PRINT_MEDIUM, " was introduced to a new level of pain by Eidolon's Magic!\n");
				else if(inflictor.classname=="eidolon flames")
					bprint(PRINT_MEDIUM, " was roasted to a crisp by Eidolon's Hellfire!\n");
			return;
		}

		// tricks and traps
		if(targ.decap==1)
		{
			if(targ.playerclass==CLASS_ASSASSIN)
				bprint(PRINT_MEDIUM, " should have quit while she was a head... oh, she IS a head!\n");
			else
				bprint(PRINT_MEDIUM, " should have quit while he was a head... oh, he IS a head!\n");
			return;
		}
		if(targ.decap==2)
		{
			if(targ.playerclass==CLASS_ASSASSIN)
				bprint(PRINT_MEDIUM, " got her head blown off!\n");
			else
				bprint(PRINT_MEDIUM, " got his head blown off!\n");
			return;
		}
		if(attacker.classname=="light_thunderstorm")
		{
			if(mapname=="eidolon")
				bprint(PRINT_MEDIUM, " was smited by Eidolon's unholy lightning!\n");
			else
				bprint(PRINT_MEDIUM, " shouldn't mess with Mother Nature!\n");
			return;
		}
		if(targ.deathtype=="zap")
		{
			bprint(PRINT_MEDIUM, " was electrocuted!\n");
			return;
		}
		if(targ.deathtype=="chopped")
		{
			bprint(PRINT_MEDIUM, " was sliced AND diced!\n");
			return;
		}
		if (attacker.solid == SOLID_BSP && attacker != world)
		{	
			bprint(PRINT_MEDIUM, " was squished\n");
			return;
		}
		if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
		{
			bprint(PRINT_MEDIUM, " was spiked");
			if (attacker.enemy.classname == "player" && attacker.enemy != targ)
			{
			 bprint(PRINT_MEDIUM, " by ");
			 bprint(PRINT_MEDIUM, attacker.enemy.netname);
			 attacker.enemy.frags += 1;
			}
			bprint(PRINT_MEDIUM, "\n");
			return;
		}
		if (attacker.classname == "fireball")
		{
			bprint(PRINT_MEDIUM, " ate a lavaball\n");
			return;
		}
		if (attacker.classname == "trigger_changelevel")
		{
			bprint(PRINT_MEDIUM, " tried to leave\n");
			return;
		}

		// in-water deaths
		rnum = targ.watertype;
		if (rnum == -3)
		{
			if (random() < 0.5)
				bprint(PRINT_MEDIUM, " takes a nice, deep breath of H2O!\n");
			else
				bprint(PRINT_MEDIUM, " needed gills\n");
			return;
		}
		else if (rnum == -4)
		{
			if (random() < 0.5)
				bprint(PRINT_MEDIUM, " gulped a load of slime\n");
			else
				bprint(PRINT_MEDIUM, " can't exist on slime alone\n");
			return;
		}
		else if (rnum == -5)
		{
			if (random() < 0.3)
				bprint(PRINT_MEDIUM, " needs a cold shower\n");
			else if (random() < 0.5)
				bprint(PRINT_MEDIUM, " likes it HOT!\n");
			else
				bprint(PRINT_MEDIUM, " smells like burnt hair\n");
			return;
		}

		// fell to their death?
		if (targ.deathtype == "falling")
		{
			targ.deathtype = "";
			bprinti (PRINT_MEDIUM, STR_CHUNKYSALSA);
			return;
		}

		// hell if I know; he's just dead!!!
		bprinti (PRINT_MEDIUM, STR_CEASEDTOFUNCTION);
	}
};

