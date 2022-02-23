
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
   // X-Men: Lightning Bolts cannot harm Storm
   if ((inflictor.classname == "info_lightning") &&
       ((targ.classname == "xmen_storm") || (targ.classname == "apocalypse_small") || (targ.classname == "apoc_torso"))) {
      return FALSE;
   }
   // end

// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;

	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

   // check for Apocalypse laugh
   if ((attacker.classname == "xmen_apocalypse") &&
       (targ.classname == "player")) {
      sound(self, CHAN_VOICE, "apoc/alaugh.wav", 1, ATTN_NONE);
   }

// bump the monster counter
	if ((self.flags & FL_MONSTER) && (!(self.spawnflags & SPAWNFLAG_CLONE)) && (self.classname != "xmen_wolverine") && !(self.x_flags & X_MEGA_HIT) && (self.classname != "xmen_sinister") && (self.classname != "xmen_apocalypse") && (self.classname != "apocalypse_small") && ((self.classname != "xmen_wolverine")))
   {
      self.angles_z = 0;

      if (!(self.spawnflags & SPAWNFLAG_CLONE)) {
   		killed_monsters = killed_monsters + 1;
		   WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
      }

      self.skin = 3; // death skin
	}

	ClientObituary(self, attacker);

	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

   if (self.classname != "xmen_techdude")
   	monster_death_use();

	self.th_die ();

	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity e) skeleton_morph;
void(entity e) iceman_melt;
void() phoenix_xattc12;
void() player_run;
void() DM_PhoenixBeamEnd;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	local	vector	dir;
	local	entity	oldself;
	local	float	save;
	local	float	take;

//bprint("T_Damage\n");

   damage_inflictor = inflictor;

   // Apocalype: if hurting torso entity, change target to owner
   if (targ.classname == "apoc_torso") {
      targ = targ.owner;
   }

//   if (((targ.flags & FL_MONSTER) || (targ.classname == "player")) && (targ.health <= 0))
//      return;

	if (!targ.takedamage)
		return;


   // don't hurt clones of same type
   if ((attacker.flags & FL_MONSTER) && (attacker.classname == targ.classname))
      return;

   if (((inflictor.classname == "proximity_ball") || (inflictor.classname == "prox_missile")) &&
       (targ.classname == "xmen_bishop"))
      return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

   if ((targ.model == "progs/skel.mdl") && (damage_attacker.weapon == IT_SUPER_NAILGUN)) {
//      self.health = 1;
      return;
   }

// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
		damage = damage * 2;

// Bishop not get hurt as much by Plasma and NERD
   if ((targ.character == CHAR_BISHOP) &&
       ((inflictor.classname == "flameball") ||
        (inflictor.classname == "prox_missile") ||
        (inflictor.classname == "proximity_ball"))) {
      damage = damage / 2;
   }

// save damage based on the target's armor level

	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
      if (!deathmatch)
         dir_z = 0;
		targ.velocity = targ.velocity + (dir*damage*8);
	}

// check for godmode or invincibility
	if (targ.flags & FL_GODMODE) {

      // first check for Pheonix abort while in Tractor Beam
      if (((targ.classname == "xmen_phoenix") || (targ.character == CHAR_PHOENIX)) && (targ.start_tractor_time < (time - 0.75))) {

         if ((targ.character == CHAR_PHOENIX) && (targ.move_ent != world)) {
            oldself = self;
            self = targ;

            DM_PhoenixBeamEnd();

            self = oldself;
         }

         if (targ.classname == "xmen_phoenix") {
            targ.enemy.x_flags = targ.enemy.x_flags - (targ.enemy.x_flags & X_TRACTOR_BEAM_HOLD);
            targ.enemy.velocity = normalize(targ.enemy.origin - targ.origin) * 250 + '0 0 100';
            targ.think = phoenix_xattc12;
         }
      }

		return;
   }

   // Check for DM Angel wing defense
   if ((targ.x_flags & X_ANGEL_DEFENSE) && ((inflictor.classname == "guided_rocket") || (inflictor.classname == "orb")))
      return;

	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
	if ( (teamplay == 1) && (targ.team > 0)&&(targ.team == attacker.team) )
		return;

//bprint("doing damage..\n");

// do the damage
	targ.health = targ.health - take;

   if ((targ.classname == "player") && (targ.armorvalue <= 0) && (targ.health < 50)) {
      if (attacker.weapon == IT_SUPER_NAILGUN) {
         if (targ.model != "progs/skel.mdl") {
            targ.health = 1;
            targ.modelindex = index_skeleton;

            targ.weaponmodel = "";
            targ.think = player_run;

            centerprint(targ, "You have been torched!");
         }
      }
   }

	if (targ.health <= 0)
	{
      if (deathmatch || coop) {
         if (attacker.weapon == IT_SUPER_NAILGUN) {   // skeleton time!
//            targ.health = 1;
            targ.modelindex = index_skeleton;

            targ.weaponmodel = "";
            targ.think = player_run;

            centerprint(targ, "You have been torched!");
         }
         else
            Killed (targ, attacker);
      }
      else if ((attacker.weapon == IT_SUPER_NAILGUN) && (targ.classname != "xmen_wolverine") && ((targ.flags & FL_MONSTER) || (targ.classname == "xmen_techdude")) && (targ.classname != "xmen_sinister") && (targ.classname != "apocalypse_small")) {
         if ((targ.classname != "xmen_iceman") ) {
            if (targ.model != "progs/skel.mdl")
               skeleton_morph(targ);
         }
         else
            iceman_melt(targ);
      }
      else
   		Killed (targ, attacker);

		return;
	}
   else {
      SetDamageSkin(targ);
   }

// react to the damage
	oldself = self;
	self = targ;

	if ( (self.parallize_time < time) && (self.flags & FL_MONSTER) && (attacker != world) && !(attacker.flags & FL_MONSTER) && (!(self.spawnflags & SPAWNFLAG_CLONE)))
	{
      // get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if (self.classname != attacker.classname)
			{
				if (self.enemy.classname == "player") {
					self.oldenemy = self.enemy;
            }

            // bosses only attack player
            if ((self.classname != "xmen_apocalypse") || (self.classname != "apocalypse_small") || (self.classname != "xmen_sinister")) {
               if (attacker.classname == "player") {
                  self.enemy = attacker;
                  FoundTarget ();
               }
            }
            else {      // other monsters attack anything
               self.enemy = attacker;
               FoundTarget ();
            }
			}
		}
	}

    if (self.th_pain)
	{
        if ((!(self.weapon_flags & W_RELOADING)) && !(self.change_weapon_status)) {
            self.th_pain (attacker, take);
        // nightmare mode monsters don't go into pain frames often
            if (skill == 3)
                self.pain_finished = time + 5;
        }
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);

	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
   					T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;

	head = findradius(attacker.origin, damage+40);

	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					if (head.classname == "xmen_storm")
						T_Damage (head, attacker, attacker, points*0.5);
					else
						T_Damage (head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};

