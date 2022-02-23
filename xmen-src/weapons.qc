/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;

void() player_stand1;

// entity values for chasecam purposes
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//.vector last_roll;
.entity chasecam;
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//.float  tracking_speed;
//.float  chasecam_zoom;
.float  last_weapon_channel;

float  DEFAULT_TRACKING_SPEED = 0;
vector CHASECAM_CLOSE = '16 0 16';
//vector CHASECAM_FAR   = '20 0 48';
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//float chasecam_alt;
float chasecam_dist = 16;
float chasecam_zofs = 6;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

    self.punchangle_y = -8;
    self.punchangle_x = -4;
    self.punchangle_z = 0;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;

	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 20);
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
/*
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
*/
    makevectors(other.angles);
    vel = normalize(v_forward*(random() - 0.85) + v_up*(random() - 0.5) + v_right*(random() - 0.5));
    vel = vel * 300;

	return vel;
};

//float   SLIDE_SPEED = 1;

void() BloodWallSlide =
{
    local vector    pt1;

    if (self.attack_finished < time) {
        remove(self);
        return;
    }

    pt1 = self.origin + self.v_angle*8;
    traceline(pt1, pt1 - '0 0 0.5', TRUE, self);
    if (trace_fraction < 1) {
        remove(self);
        return;
    }

    pt1 = trace_endpos;
    traceline(pt1, pt1 - (self.v_angle*12), TRUE, self);
    setorigin(self, trace_endpos);
//bprint("blood wall slide\n");
    self.last_blood_think = time;
    self.nextthink = time + 0.1;
};

void() BloodTouch =
{
    local vector    dir;

    if (other != world) {
        remove(self);
        return;
    }

//bprint("blood touch\n");

    dir = normalize(self.velocity);
    makevectors(dir);
    traceline(self.origin - dir*4, self.origin + dir*12, TRUE, self);
    if ((trace_fraction < 1) && (fabs(trace_plane_normal_z) < 0.2)) {
        // start sliding down wall
        self.movetype = MOVETYPE_NONE;
        self.velocity = '0 0 0';
        self.v_angle = trace_plane_normal;
        self.last_blood_think = time;
        self.frame = self.frame + 1;
        self.think = BloodWallSlide;
        self.nextthink = time + 0.1;
        self.attack_finished = time + 7;
        self.angles = vectoangles(trace_plane_normal);
    }
};

/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	entity mpuff;
	//local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
    missile.solid = SOLID_BBOX;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 150 + 50*random();

    missile.avelocity = '300 100 200';

    missile.touch = BloodTouch;

// set missile duration
    missile.nextthink = time + 5;
	missile.think = SUB_Remove;

    setmodel (missile, "progs/blood.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
    local vector    vrand, vect;
    local float     num_gibs;

    particle (org, vel* -0.1, 73, damage*2);

    if (deathmatch) {       // preserve bandwidth
        return;
    }

    num_gibs = ceil(damage / 15);

    while (num_gibs > 0) {
        vrand = '8 0 0' * random() + '0 8 0' * random() + '0 0 4' * random() - '4 4 2';
        vect = normalize(vrand + vel);
        SpawnMeatSpray(org + vect*24, vect*(100 + random()*400));
        num_gibs = num_gibs - 1;
    }
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
    local vector    vel, vrand;
    local float     num_gibs;

	vel = wall_velocity () * 0.2;

    if (deathmatch) {
        SpawnBlood (self.origin + vel*0.01, vel, damage);
        return;
    }

    num_gibs = damage / 10;

    while (num_gibs > 0) {
        vrand = '8 0 0' * random() + '0 8 0' * random() + '0 0 4' * random() - '4 4 2';
        SpawnMeatSpray(self.origin + vrand + vel*0.01, vel + vrand*20);
        num_gibs = num_gibs - 1;
    }
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
//    particle (org, vel*0.02, 0, 10);
    SpawnBlood(org, vel*0.02, 5);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;

	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(entity ent, float  num_gibs) IcemanShardGib;
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;

	vel = normalize(dir*5 + v_up*random() + v_right*crandom());
//	vel = vel + 2*trace_plane_normal;
//	vel = normalize(vel);

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
      org = trace_ent.origin;
      if ((trace_ent.classname != "xmen_sinister") || (trace_ent.x_flags & X_MEGA_HIT)) {
         if ((trace_ent.classname != "xmen_iceman") && (trace_ent.character != CHAR_ICEMAN)) {
            if ((trace_ent.flags & FL_MONSTER) ||
                (trace_ent.flags & FL_CLIENT)) {
               if (random() < 0.8)
                  SpawnBlood (org, vel * 12, damage);
               else
                  SpawnBlood (org, vel * -2, damage);
            }
         }
         else {
            IcemanShardGib(trace_ent, damage / 6);
         }
      }

		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10 + '0 0 12';
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local float rnd;
	local vector dir;

	if (self.currentammo <= 1)
      self.currentammo = self.ammo_shells = 0;
   else
      self.currentammo = self.ammo_shells = self.ammo_shells - 1;

   sound (self ,CHAN_WEAPON, "weapons/shotfir6.wav", 1, ATTN_NORM);

	self.punchangle_x = -8;

	dir = aim (self, 100000);
 	FireBullets (7, dir, '0.06 0.06 0');

   if (vlen(self.velocity) < 10) {     // add some bounce if stationery
      self.velocity = self.velocity + '0 0 150';
   }

   v_forward_z = 0;
   self.velocity = self.velocity - (v_forward * 40);

};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()  s_explode1  =   [0,     s_explode2] {};
void()  s_explode2  =   [1,     s_explode3] {self.effects = self.effects | EF_DIMLIGHT;};
void()	s_explode3	=	[2,		s_explode4] {};
void()  s_explode4  =   [3,     s_explode5] {self.effects = self.effects - EF_DIMLIGHT;};
void()  s_explode5  =   [4,     s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;

	if (other.health)
	{
		if (other.classname == "xmen_storm")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() cannon_xatta16;
void() T_GuidedMissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

   if (self.dmg == 0)
       damg = 35 + random()*5;
   else
      damg = self.dmg;

   if (self.classname == "dm_phoenix_blast")
      damg = damg / 2;

   if (self.classname == "phoenix_blast")
      damg = damg / 2;

   if ((other.classname == "xmen_cannonball") && (other.flags & FL_GODMODE)) {
      if (other.last_rocket_hit > (time - 0.5)) {
         other.x_flags = other.x_flags | X_CANNONFLYABORT;
//         other.think = cannon_xatta16;
      }

	}

   if (other != world)
      other.last_rocket_hit = time;

	if (other.health)
	{
      if (!(other.x_flags & X_ANGEL_DEFENSE))
   		T_Damage (other, self, self.owner, damg );

      // 20060705 LordHavoc: added a check to see if the entity might have already been removed (other.model != ""), as is the case with Iceman's gibbing code.
      if ((other.model != "") && (other.movetype) && (other.flags & FL_ONGROUND) && (other.classname != "apocalypse_small") && (other.classname != "xmen_sinister")) {   // give some velocity
         other.velocity = other.velocity + normalize(self.velocity) * 180;
         if (other.velocity_z < 140)
            other.velocity_z = 140;
         other.flags = other.flags - (other.flags & FL_ONGROUND);
         setorigin(other, other.origin + '0 0 1');
      }
	}

   if (self.classname != "phoenix_blast") {
      // don't do radius damage to the other, because all the damage
      // was done in the impact
       T_RadiusDamage (self, self.owner, 40, other);
   }

    sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 0.6, ATTN_NORM);
 	 self.origin = self.origin - 8*normalize(self.velocity);

    BecomeExplosion ();
};

/*******************************
  FindSightEnemy
    Returns an entity that is within "angle_range" of "dir"
    use filter_classname to exclude all entitys with the given classname
      from being returned (use "world" to for to include all classes)
 *******************************/

entity(vector org, vector dir, float dist, float angle_range, string filter_class, entity ignore) FindSightEnemy =
{
        local entity    trav;
        local float     trav_yaw, dir_yaw;

        dir_yaw = vectoyaw(dir);

        trav = findradius(org, dist);

        while (trav != world) {
              if (((filter_class == "all") || (filter_class == trav.classname)) && (trav != ignore) && ((ignore != world) && (trav != ignore.owner))) {
                if ((trav.takedamage == DAMAGE_AIM)
                    && (trav.health > 0)) {

                        // make sure trav is within the angle_range
                        trav_yaw = vectoyaw(trav.origin - org);
                        if (fabs(angle_diff(dir_yaw, trav_yaw)) <= angle_range) {
                                // check there is a clear line of sight
                                traceline(org, trav.origin, TRUE, world);
                                if (trace_fraction == 1) {
                                        return trav;
                                }
                        }
                }
              }

              trav = trav.chain;
        }

        return trav;
};

void() T_MissileTouch;

// lower weight, means more accurate
void(vector target_org, float weight) RocketSeek =
{
        local float     current_speed;
        local vector    target_vector, vel, unit_velocity;

        current_speed = vlen(self.velocity);

        target_vector = normalize(target_org - self.origin);
        unit_velocity = normalize(self.velocity);
        self.velocity = normalize(target_vector + unit_velocity*weight) * current_speed;
        vel = normalize(self.velocity);
        self.angles = vectoangles(vel);

        self.nextthink = time + 0.05;
};

void() GuidedRocketThink =
{
	local vector dir;
	local vector new_targ;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local vector reflect;
	local vector endpos;
	local float interdist;

        if (self.attack_finished < time) {
                remove(self);
                return;
        }

        dir = normalize(self.velocity);
        self.angles = vectoangles(dir);
        self.angles_x = -1 * self.angles_x;

        if (self.classname == "prox_missile")
           particle(self.origin, self.velocity * 0.5, 44, 10);

        if (self.enemy != world) {
            if ((self.enemy.health <= 0) ||
                ((self.enemy.classname == "xmen_phoenix") &&
                 (self.enemy.flags & FL_GODMODE))) {
                    self.enemy = world;
            }
            else
            {
                traceline(self.origin, self.enemy.origin, TRUE, self);
                if (trace_fraction == 1) {  // clear path
                    if (self.classname == "prox_missile")
                       RocketSeek(self.enemy.origin, 0.5);
                    else if (self.classname == "dm_phoenix_blast")
                       RocketSeek(self.enemy.origin, 8);
                    else
                       RocketSeek(self.enemy.origin, 5);
                    return;
                }
            }
        }
        else if ((self.enemy == world) && (self.last_guided_search < (time - 0.2)))   // search for a new target every 0.5 seconds
        {
            makevectors(self.angles);
            dir = v_forward;

            if (self.classname == "pheonix_blast")
               self.enemy = FindSightEnemy(self.origin, dir, 1500, 30, "player", self);
            else
               self.enemy = FindSightEnemy(self.origin, dir, 1500, 30, "all", self);
            self.last_guided_search = time;
        }

        // avoid walls
        dir = normalize(self.velocity);
        traceline(self.origin, self.origin + dir*256, TRUE, self);
        if ((trace_fraction < 1) && (trace_ent == world)) {       // heading for a wall
            endpos = trace_endpos;
            interdist = 256 * trace_fraction;
//            reflect = GetReflectionVect(trace_endpos, dir, trace_plane_normal);
            new_targ = endpos + trace_plane_normal * interdist;
            RocketSeek(new_targ, 3);
            return;
        }

        self.nextthink = time + 0.05;
};

void() GuidedRocketStart =
{
    local entity    missile_enemy;
    local vector  dir;

    dir = normalize(self.velocity);

   if (self.enemy == world) {
     if ((missile_enemy = FindSightEnemy(self.origin, dir, 1500, 30, "all", self.owner)) != world) {
             self.enemy = missile_enemy;

             if (missile_enemy.th_guard) {
                if (missile_enemy.enemy == self.owner) {  // alert Enemy
                   missile_enemy.guard_flag = TRUE;
                }
             }
     }
     else {
      self.velocity = self.old_velocity + normalize(self.velocity) * 3;
      self.velocity = normalize(self.velocity);
      self.angles = vectoangles(self.velocity);
      self.angles_x = -1 * self.angles_x;
      self.velocity = self.velocity * 500;
     }
   }

   self.think = GuidedRocketThink;
   self.nextthink = time + 0.05;
};

void(vector origdir, vector ofs) GuidedMissile =
{
    local entity    missile, missile_enemy;
    local vector    dir;

	missile = spawn ();
   missile.classname = "guided_rocket";
    missile.attack_finished = time + 3;
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;

//     dir = normalize(origdir);

      dir = v_forward;

     if ((missile_enemy = FindSightEnemy(missile.origin, dir, 1500, 30, "all", self)) != world) {
             self.enemy = missile_enemy;

             if (missile_enemy.th_guard) {
                if (missile_enemy.enemy == self) {  // alert Enemy
                   missile_enemy.guard_flag = TRUE;
                }
             }
     }
     missile.think = GuidedRocketStart;
     missile.last_guided_search = time;
     missile.nextthink = time + 0.3;

   missile.old_velocity = normalize(origdir);

// set missile speed

    missile.velocity = dir;
    missile.velocity = missile.velocity * 500;
	missile.angles = vectoangles(missile.velocity);

    missile.touch = T_GuidedMissileTouch;

    setmodel (missile, "progs/missmall.mdl");
    setsize (missile, '0 0 0', '0 0 0');
    setorigin (missile, self.origin + origdir + ofs + v_forward * 8 + '0 0 16');
};

void() W_FireGuidedRockets =
{
   if (self.ammo_rockets <= 2)
      self.currentammo = self.ammo_rockets = 0;
   else
     	self.currentammo = self.ammo_rockets = self.ammo_rockets - 2;

   sound (self, CHAN_WEAPON, "weapons/guidfire.wav", 1, ATTN_NORM);
	self.punchangle_x = -12;

	makevectors (self.v_angle);
/*
    GuidedMissile(v_forward*3 + v_up);
    GuidedMissile(v_forward*3 + v_right);
    GuidedMissile(v_forward*3 - v_right);
*/
//    GuidedMissile(v_forward*5 - v_right);
//    GuidedMissile(v_forward*5 + v_right);
   GuidedMissile(v_right * 2, v_right * 6);
   GuidedMissile(v_right * -2, v_right * 6);
};

/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	entity mpuff;

//	self.currentammo = self.ammo_rockets = self.ammo_rockets - 3;

//    sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";

// set missile speed

	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);

	missile.touch = T_MissileTouch;

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');

   W_FireGuidedRockets();
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

.float remove_time;

void() bolt_think =
{
    self.angles_z = random() * 340 - 170;

    if (self.remove_time < time)
    {
        remove(self);
        return;
    }

    self.frame = self.speed;
    self.nextthink = time + 0.05;
};

void(vector start, vector end, string modelstr, vector angle_ofs, float bolt_life) FillBetweenPoints =
{
    local vector    org, dir, dir_angle;
    local float     dist;
    local entity    newbolt;

    dist = vlen(start - end);
    dir  = normalize(end - start);
    dir_angle = vectoangles(dir);
    org = start;

    while (vlen(org - start) < dist)
    {
//bprint("b");
        newbolt = spawn();
        setmodel(newbolt, modelstr);
        setorigin(newbolt, org);
        newbolt.frame = 0; //frame_num;
        newbolt.speed = 0; //frame_num;
        newbolt.angles = dir_angle + angle_ofs;
        newbolt.angles_z = random() * 340 - 170;
        newbolt.remove_time = time + bolt_life; //0.07;
        newbolt.think = bolt_think;
        newbolt.nextthink = time + 0.05;

        if (modelstr == "progs/bolt3.mdl")
           org = org + dir*128;
         else
           org = org + dir*32;

    }
//bprint("\n");
};

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};

void(vector org_start, vector dir_start) ReflectLightning =
{
    local float     reflect_count, NUM_REFLECTIONS, frac, total_dist, MAX_DIST, length;
    local vector    org, dir, normal, endpos;
    local entity    ent, junction;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local string str;

    NUM_REFLECTIONS = 2;
    MAX_DIST        = 800;

    org = org_start;
    dir = dir_start;
    reflect_count = 0;
    total_dist = 0;
    junction = self;

    while (reflect_count <= NUM_REFLECTIONS) {
        traceline (org, org + dir*600, FALSE, self);
        frac = trace_fraction;
        ent = trace_ent;
        normal = trace_plane_normal;
        endpos = trace_endpos;

        length = vlen(endpos - org);
        if ((total_dist + length) > MAX_DIST) {
          endpos = org + dir * (MAX_DIST - total_dist);
          reflect_count = NUM_REFLECTIONS;
        }

//        if (trace_fraction < 0.05)
//            return;

         WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
         WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
         WriteEntity (MSG_BROADCAST, junction);
         WriteCoord (MSG_BROADCAST, org_x);
         WriteCoord (MSG_BROADCAST, org_y);
         WriteCoord (MSG_BROADCAST, org_z);
         WriteCoord (MSG_BROADCAST, endpos_x);
         WriteCoord (MSG_BROADCAST, endpos_y);
         WriteCoord (MSG_BROADCAST, endpos_z);

        LightningDamage (org, endpos + dir*4, self, 30 * (1 - (total_dist/480))); // lose power over distance

//str = ftos(frac);
//bprint(str);
//bprint("\n");
        if ((frac < 1) && (ent == world)) {
            org = endpos;
            dir = GetReflectionVect(org, dir, normal);

            reflect_count = reflect_count + 1;
        }
        else {
            reflect_count = NUM_REFLECTIONS + 1;
            total_dist = MAX_DIST;
        }

//        junction = junction.beam_ent;
    }
};

void() W_FireLightning =
{
	local	vector		org;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	float		cells;

   stuffcmd(self, "bf\n");
	self.punchangle = '-10 0 0' + '10 0 0' * random() + '0 10 0' * random() + '0 0 10' * random() - '5 5 5';

//	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';

    makevectors(self.v_angle);

   traceline(org, org + v_forward * 1000, FALSE, self);

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, org_x);
   WriteCoord (MSG_BROADCAST, org_y);
   WriteCoord (MSG_BROADCAST, org_z);
   WriteCoord (MSG_BROADCAST, trace_endpos_x);
   WriteCoord (MSG_BROADCAST, trace_endpos_y);
   WriteCoord (MSG_BROADCAST, trace_endpos_z);

   if ((trace_ent != world) &&
       !(trace_ent.x_flags & X_MEGA_HIT) &&
       ((trace_ent.owner.classname == "xmen_apocalypse") ||
        (trace_ent.classname == "xmen_sinister"))) {
      T_Damage(trace_ent, self, self, 5000);
   }

};

void() ProximityAttack =
{
   local vector   vect;
   local float    dist;
   local entity   ent;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   oself;

   if (other == world) {
      remove(self);
      return;
   }

   if (other != self.enemy)
      return;

   ent = self.enemy;

//   oself = self;
//   self = self.owner;

   vect = normalize(ent.origin - self.oldorigin);
   dist = vlen(ent.origin - self.oldorigin);

   if (dist > 200)
      dist = 200;

   if ((ent.classname != "apocalypse_small") && (ent.classname != "xmen_sinister"))
      ent.velocity = ent.velocity + vect * (200 - dist) + '0 0 180';

   ent.flags = ent.flags - (ent.flags & FL_ONGROUND);

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, ent.origin_x);
   WriteCoord (MSG_BROADCAST, ent.origin_y);
   WriteCoord (MSG_BROADCAST, ent.origin_z);

   SpawnBlood (ent.origin, '0 0 0', 20);

   if ((ent.classname == "xmen_sinister") || (ent.classname == "apocalypse_small"))
      self.prox_power = self.prox_power / 5;

   T_Damage(ent, self, self.owner, ent.start_health * (self.prox_power / 100) + 10);

//   self = oself;
   remove(self);
};

void() ProximityThink =
{
   // remove if player is dead
   if ((self.owner.health <= 0) || (self.modelindex == index_skeleton) || (intermission_running)) {
      self.owner.prox_ent = world;
      remove(self);
      return;
   }

   if (self.owner.last_prox_think < (time - 5)) {
      self.owner.prox_ent = world;
      remove(self);
      return;
   }

   self.frame = self.frame + 1;
   if (self.frame > 5)
      self.frame = 0;

   if (self.last_flame_sound < (time - 0.75)) {
      if (random() < 0.5)
         sound(self, CHAN_AUTO, "weapons/prox1.wav", self.owner.prox_power / 100, ATTN_NORM);
      else
         sound(self, CHAN_AUTO, "weapons/prox2.wav", self.owner.prox_power / 100, ATTN_NORM);

      self.last_flame_sound = time;
   }

   if (self.last_flame < (time - 0.05)) {     // increase power
      if ((self.owner.currentammo > 0) && (self.owner.prox_power < 100)) {
         self.owner.currentammo = self.owner.ammo_cells = self.owner.ammo_cells - 1;
         self.owner.prox_power = self.owner.prox_power + 1;

         if ((self.owner.currentammo > 0) && (self.owner.prox_power < 100)) {
            self.owner.currentammo = self.owner.ammo_cells = self.owner.ammo_cells - 1;
            self.owner.prox_power = self.owner.prox_power + 1;
         }
         if ((self.owner.currentammo > 0) && (self.owner.prox_power < 100)) {
            self.owner.currentammo = self.owner.ammo_cells = self.owner.ammo_cells - 1;
            self.owner.prox_power = self.owner.prox_power + 1;
         }

         // faster under rapid fire
         if ((self.owner.x_flags & X_RAPID_FIRE) && (self.owner.currentammo > 0) && (self.owner.prox_power < 100)) {
            self.owner.currentammo = self.owner.ammo_cells = self.owner.ammo_cells - 1;
            self.owner.prox_power = self.owner.prox_power + 1;
         }
         if ((self.owner.x_flags & X_RAPID_FIRE) && (self.owner.currentammo > 0) && (self.owner.prox_power < 100)) {
            self.owner.currentammo = self.owner.ammo_cells = self.owner.ammo_cells - 1;
            self.owner.prox_power = self.owner.prox_power + 1;
         }

         if ((self.model == "progs/atom1.mdl") && (self.owner.prox_power > 40))
            setmodel(self, "progs/atom2.mdl");
         else if ((self.model == "progs/atom2.mdl") && (self.owner.prox_power > 70))
            setmodel(self, "progs/atom3.mdl");

         self.last_flame = time;
      }
      else if ((self.owner.prox_power >= 50) && (self.last_flame < (time - 3))) {
         T_Damage(self.owner, world, world, 2);
         self.last_flame = time - 2;      // next hurt after 1 seconds only
      }
   }

   if (self.movetype != MOVETYPE_BOUNCE) {
      // align with owner
      makevectors(self.owner.v_angle);
      setorigin(self, self.owner.origin + v_forward * 24 + '0 0 22');
   }

   self.nextthink = time + 0.01;
};

void() StartProximity =
{
   local entity   prox;

   if (self.prox_ent != world) {
	   remove(self.prox_ent);
	   self.prox_ent = world;
   }

   prox = spawn();
   self.prox_ent = prox;
   prox.classname = "proximity_ball";
   prox.owner = self;
   prox.spawn_time = time;

   prox.movetype = MOVETYPE_FLY;
   prox.avelocity = '100 0 0' * random() + '0 100 0' * random() + '0 0 100' * random() - '50 50 50';

   setmodel(prox, "progs/atom1.mdl");

   self.last_prox_think = time;

   prox.think = ProximityThink;
   self = prox;
   ProximityThink();
   self = self.owner;
};

void(entity targ) SpawnProxMissile =
{
    local entity    missile;
    local vector    dir, vect;

   missile = spawn ();
   missile.classname = "prox_missile";
   missile.attack_finished = time + 3;
   missile.owner = self.owner;
   missile.oldorigin = self.origin;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;

   missile.prox_power = self.owner.prox_power;

   dir = normalize(targ.origin - self.origin);

   dir = normalize('0 0 1' + dir * 5);

   missile.enemy = targ;

   missile.think = GuidedRocketStart;
   missile.nextthink = time + 0.05;

   missile.old_velocity = dir;

// set missile speed

   missile.velocity = dir;
   missile.velocity = missile.velocity * 750;
   missile.angles = vectoangles(missile.velocity);

   missile.touch = ProximityAttack;

   setmodel (missile, "progs/atomshot.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   vect = normalize(self.velocity);
   setorigin (missile, self.origin - vect * 8);
};

void() ProximityTouch =
{
   local entity   trav;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   expthink;
   local float    num;

   if (other == self.owner)
      return;

   sound(self, CHAN_ITEM, "items/damage2.wav", 1, ATTN_NORM);
//   sound(self, CHAN_BODY, "weapons/r_exp3.wav", 0.4, ATTN_NORM);

   num = rint(6 * (self.prox_power / 100)) + 2;

   trav = findradius(self.origin, 800);
   while ((trav != world) && (num > 0)) {
      if ((trav.takedamage) && (trav != self.owner)) {
         // check visibility
         traceline(self.origin, trav.origin, TRUE, trav);
         if ((trace_fraction == 1) || (trace_ent == trav)) {

            if (((trav.classname != "xmen_sinister") || (self.x_flags & X_MEGA_HIT)) &&
                 (trav.classname != "xmen_apocalypse")) {
               SpawnProxMissile(trav);
               num = num - 1;
            }
/*
            expthink = spawn();
            expthink.enemy = trav;
            expthink.owner = self.owner;
            expthink.prox_power = self.prox_power;
            expthink.think = ProximityAttack;
            expthink.nextthink = time + vlen(trav.origin - self.origin) / 400;
*/
//            ProximityAttack(trav);
         }
      }

      trav = trav.chain;
   }

   if (other.takedamage)
      T_Damage(other, self, self, self.owner.prox_power);

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   BecomeExplosion ();

   self.owner.prox_ent = world;
};

void() W_FireProximity =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector      org;
   //local float       cells;
   //local entity      trav, expthink;

/*
   if (self.ammo_cells < 1)
   {
      self.weapon = W_BestWeapon ();
      W_SetCurrentAmmo ();
      return;
   }

   if (self.ammo_cells > 50) {
      cells = 50;
      self.currentammo = self.ammo_cells = self.ammo_cells - 50;
   }
   else {
      cells = self.ammo_cells;
      self.currentammo = self.ammo_cells = 0;
   }
*/

   if (self.prox_ent == world)      // nothing to throw
      return;

   // Throw the proxmity ball
   self.prox_ent.solid = SOLID_TRIGGER;
   self.prox_ent.movetype = MOVETYPE_FLYMISSILE;
   setsize(self.prox_ent, '0 0 0', '0 0 0');
   self.prox_ent.touch = ProximityTouch;
   self.prox_ent.prox_power = self.prox_power;
   self.prox_ent.think = SUB_Null;

   makevectors(self.v_angle);
//   self.prox_ent.velocity = self.velocity + (v_forward*2 + v_up*0.5) * 50 + '0 0 80';
   self.prox_ent.velocity = v_forward * 750;

   self.attack_finished = time + 2;

//   stuffcmd(self, "bf\n");

   sound(self, CHAN_ITEM, "cannon/takeoff.wav", 1, ATTN_NORM);

/*
   sound(self, CHAN_WEAPON, "items/damage2.wav", 1, ATTN_NORM);
   sound(self, CHAN_BODY, "weapons/r_exp3.wav", 0.4, ATTN_NORM);

   trav = findradius(self.origin, 800);
   while (trav != world) {
      if ((trav.takedamage) && (trav != self)) {
         // check visibility
         traceline(self.origin, trav.origin, TRUE, trav);
         if ((trace_fraction == 1) || (trace_ent == trav)) {
            expthink = spawn();
            expthink.enemy = trav;
            expthink.owner = self;
            expthink.think = ProximityAttack;
            expthink.nextthink = time + vlen(trav.origin - self.origin) / 400;

//            ProximityAttack(trav);
         }
      }

      trav = trav.chain;
   }
*/
};

//=============================================================================


void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 60, world);

/*
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
*/
   // 20060704 LordHavoc: added a check to see if the entity might have already been removed (other.model != ""), as is the case with Iceman's gibbing code.
   if ((other.model != "") && (other.movetype) && (other.flags & FL_ONGROUND) && (other.classname != "xmen_sinister") && (other.classname != "apocalypse_small")) {   // give some velocity
      other.velocity = other.velocity + normalize(self.velocity) * 100 + '0 0 220';
      other.flags = other.flags - (other.flags & FL_ONGROUND);
      setorigin(other, other.origin + '0 0 1');
   }

   sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

   if ((other.classname == "xmen_phoenix") &&
       (other.flags & FL_GODMODE))
      return;

	if ((other.takedamage == DAMAGE_AIM) && !(other.x_flags & X_ANGEL_DEFENSE))
	{
		GrenadeExplode();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	entity mpuff;
	local	entity phoenix;

   if (self.ammo_rockets > 0)
   	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "orb";

// set missile speed

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*900 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 900;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	missile.touch = GrenadeTouch;

// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/orb1.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_right * 6 + v_forward * 16);

   missile.old_velocity = missile.velocity;

   // check for Pheonix defence
   phoenix = find(world, classname, "xmen_phoenix");
   while (phoenix != world) {
      if (phoenix.enemy == self)
          phoenix.guard_flag = TRUE;

      phoenix = find(phoenix, classname, "xmen_phoenix");
   }

};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

// 20060704 LordHavoc: hushed a compiler warning by making this take no parameters
void() W_FireSuperSpikes =
{
   local vector   dir;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   old;
    local string    sample;
    local float   shells;

    sample = "weapons/chnfire5.wav";

    if (self.last_weapon_channel != CHAN_WEAPON) {
        sound (self, CHAN_WEAPON, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_WEAPON;
    } else {
        sound (self, CHAN_ITEM, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_ITEM;
    }

   self.attack_finished = time + 0.2;

   if (random() < 0.5)
      shells = 1;
   else
      shells = 2;

   dir = aim (self, 100000);

   if (self.ammo_shells <= shells) {
      self.currentammo = self.ammo_shells = 0;
   }
   else {
      self.currentammo = self.ammo_shells = self.ammo_shells - shells;
   }

   FireBullets (shells, dir, '0.04 0.04 0');

/*
   self.currentammo = self.ammo_shells = self.ammo_shells - 1;
   dir = aim (self, 1000);
   launch_spike (self.origin + '0 0 16' + ox * v_right, dir);
   newmis.touch = superspike_touch;
   setmodel (newmis, "progs/s_spike.mdl");
   setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
*/
   self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
   local vector   dir;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   old;

   makevectors (self.v_angle);

   if (self.weapon == IT_SHOTGUN)
   {
      W_FireSuperSpikes ();
      return;
   }

   if (self.ammo_nails < 1)
   {
      self.weapon = W_BestWeapon ();
      W_SetCurrentAmmo ();
      return;
   }

   sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
   self.attack_finished = time + 0.2;
   self.currentammo = self.ammo_nails = self.ammo_nails - 1;
   dir = aim (self, 1000);
   launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

   self.punchangle_x = -2;
};


/*
===============
  Lazer Gun stuff
===============
*/
void() Flameball_Touch =
{
   local vector org;

   if (other == self.owner)
      return;     // don't explode on owner

   if (pointcontents(self.origin) == CONTENT_SKY)
   {
      remove(self);
      return;
   }

//   sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
   org = self.origin - 8*normalize(self.velocity);
   if ((other.health) && (other.classname != "xmen_bishop"))
   {
      SpawnBlood (org, self.velocity*0.2, 12);
      T_Damage (other, self, self.owner, 12);
   }
   else
   {
      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_GUNSHOT);
      WriteCoord (MSG_BROADCAST, org_x);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);
   }

   self.origin = self.origin - 8*normalize(self.velocity);

   BecomeExplosion ();

};


void() FlameballThink =
{
   self.angles_z = (random() * 360) - 180;

   if (self.spawn_time < (time - 6)) {
      remove(self);
      return;
   }

   self.nextthink = time + 0.1;
};

void(vector org, vector dir) Launch_Flameball =
{
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;

   newmis.angles = vectoangles(dir);

   newmis.touch = Flameball_Touch;
   newmis.classname = "flameball";
   newmis.think = FlameballThink;
   newmis.nextthink = time + 0.1;
   setmodel (newmis, "progs/flamball.mdl");
   setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
   setorigin (newmis, org);
   newmis.spawn_time = time;
   newmis.angles_z = (random() * 360) - 180;

   newmis.velocity = dir * 1500;
};



// X-Men: fires a laser projectile
void(float ox) W_FireFlameball =
{
   local vector   dir;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   old;
   local string   sample;

   makevectors (self.v_angle);

   sample = "weapons/f_start.wav";

    if (self.last_weapon_channel != CHAN_WEAPON) {
        sound (self, CHAN_WEAPON, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_WEAPON;
    } else {
        sound (self, CHAN_ITEM, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_ITEM;
    }

   if (self.ammo_nails < 1)
   {
      self.weapon = W_BestWeapon ();
      W_SetCurrentAmmo ();
      return;
   }

//   sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);
   self.attack_finished = time + 0.2;
   self.currentammo = self.ammo_nails = self.ammo_nails - 1;
   dir = v_forward;
   Launch_Flameball (self.origin + '0 0 16' + v_right*4, dir);

   self.punchangle_x = -2;
};


// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//.float hit_z;
void() spike_touch =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local float rand;
	local float damg;
	local vector   vect;

	if ((other == self.owner) || (other.owner == self.owner))
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
      if (!self.dmg)
         damg = 9;
      else
         damg = self.dmg;

		spawn_touchblood (damg);
		T_Damage (other, self, self.owner, damg);

      remove(self);
      return;
	}
	else if (self.classname == "angel_dart") {
      vect = normalize(self.velocity);
      setorigin(self, self.origin + vect*2);

      self.velocity = '0 0 0';
      self.solid = SOLID_NOT;
      self.movetype = MOVETYPE_NONE;

      self.think = SUB_Remove;
      self.nextthink = time + 5;

      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_SPIKE);
      WriteCoord (MSG_BROADCAST, self.origin_x);
      WriteCoord (MSG_BROADCAST, self.origin_y);
      WriteCoord (MSG_BROADCAST, self.origin_z);

      return;
   }

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);

   if (self.classname == "wizspike")
      WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
   else if (self.classname == "gambit_card")
      WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
   else
      WriteByte (MSG_BROADCAST, TE_SPIKE);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

	remove(self);

};

void() superspike_touch =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

/*
================
W_FireFlameThrower
================
*/

void(float num_bubbles) DeathBubbles;
void() W_FireFlameThrower =
{
   local string   sample;

   if (self.classname == "player") {
      if (self.ammo_nails < 1)
      {
         self.weapon = W_BestWeapon ();
         W_SetCurrentAmmo ();
         return;
      }

      if (self.ammo_nails < 4)
         self.ammo_nails = 0;
      else
         self.ammo_nails = self.ammo_nails - 4;

      self.currentammo = self.ammo_nails;

      if (self.waterlevel >= 3) {      // can't fire while underwater
         self.flags = self.flags - (self.flags & FL_FLAMEON);
         self.water_flame_flag = TRUE;
         DeathBubbles(1);
         return;
      }
   }

   sample = "weapons/flame.wav";

   if (self.last_flame_sound < (time - SNDLEN_FLAME)) {
    if (self.last_weapon_channel != CHAN_WEAPON) {
        sound (self, CHAN_WEAPON, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_WEAPON;
    } else {
        sound (self, CHAN_ITEM, sample, 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_ITEM;
    }

    self.last_flame_sound = time + (random() * 0.2) - 0.05;
   }

   if (!(self.flags & FL_FLAMEON))
   {
//bprint("starting flame..\n");
      setorigin(self.flame_ent1, self.origin + v_forward * 16);
      setorigin(self.flame_ent2, self.origin + v_forward * 16);
      setorigin(self.flame_ent3, self.origin + v_forward * 96);
      self.flame_ent1.nextthink = time + 0.05;
      self.flame_ent1.speed = 0;
      self.flame_ent2.speed = 0;
      self.flame_ent3.speed = 0;

      setmodel(self.flame_ent1, "progs/fl_th1.mdl");
      setmodel(self.flame_ent2, "progs/null.spr");
      setmodel(self.flame_ent3, "progs/fl_th5.mdl");
   }

   if (self.water_flame_flag) {
      self.flags = self.flags | FL_FLAMEON;
      self.water_flame_flag = FALSE;
   }

   self.last_flame = time;
};

void(entity ent, vector pos, float dist) movetopos =
{
   local vector   vect;

   if (vlen(ent.origin - pos) > dist) {
      vect = normalize(pos - ent.origin);
      setorigin(ent, ent.origin + vect * dist);
   }
   else
   {
      setorigin(ent, pos);
   }
};

void(vector p1, vector p2) FlameParticles =
{
   local float    rcol, rnd;
   local vector   vect, avect, rvect, org, vel;

   // random color between 228 - 233
   rnd = random();
   rcol = 228 + floor(rnd * 2);

   // do vector stuff
   vect = normalize(p2 - p1);
   avect = vectoangles(vect);
   avect_x = -1 * vect_x;

   makevectors(avect);

   rvect = ('1 0 0' * random()) + ('0 1 0' * random()) + ('0 0 1' * random()) - '0.5 0.5 0.5';

   org = p1 +
         v_forward * 32 +
         v_forward * rnd * FLAME_DIST * 0.5;

   vel = normalize(v_forward + (rvect * 0.3) + '0 0 0.2') * 20;

   particle( org, v_forward * 10, 235, 20);
   particle( org, vel, rcol, 50);

   // flame_ent_think() requires the following line..
   makevectors(self.owner.v_angle);
};

void() flame_ent_think =
{
   local entity   ent, ent_parent;
   local vector   vect, ideal_pnt, ofs, oldangles;
   local float    this_dist, this_speed, dist_from, dist1, dist2, short_flag;
   local entity   ent_burn;

   short_flag = FALSE;

   // set flame distance
   if (!(self.owner.flags & FL_FLAMEON)) {
//bprint("stopping flame..\n");
//      if ((vlen(self.origin - self.owner.origin) < 32) ||
//          (self.owner.last_flame < (time - 1)))            {  // flame has run out

         setmodel(self.owner.flame_ent1, string_null);
         setmodel(self.owner.flame_ent2, string_null);
         setmodel(self.owner.flame_ent3, string_null);

         self.owner.flame_ent1.effects = 0;
         self.owner.flame_ent2.effects = 0;
         self.owner.flame_ent3.effects = 0;

         self.nextthink = -1;
         return;
//      }

	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	/*
      this_dist = -2 * FLAME_DIST;

      self.speed = self.speed - (FLAME_ENT_SPEED * frametime * 0.5);
      if (self.speed < 0)
         self.speed = 0;
	*/
   }
   else {
      this_dist = FLAME_DIST;
   }

   self.nextthink = time + 0.05;

   ent_burn = world;
   makevectors(self.owner.v_angle);

   ofs = v_forward * 32 + v_right * 10 + '0 0 36' - v_up * 28;
   if (self.owner.character == CHAR_STORM)
      ofs_z = ofs_z + STORM_VOFS_Z;

// move 1st junction to ideal position    ****************************************************
   ent = self;
   ent_parent = self.owner;
   traceline(ent_parent.origin + ofs - v_forward * 32, ent_parent.origin + ofs + v_forward * this_dist * 0.5, FALSE, self.owner);

   dist_from = vlen(ent.origin - trace_endpos);

//   ent.angles = vectoangles(v_forward);
//   ent.angles_z = (360 * random()) - 180;
   ent.angles = self.owner.v_angle;
   ent.angles_x = -1 * ent.angles_x;
   ent.angles_z = random() * 360 - 180;

   movetopos(ent, trace_endpos, FLAME_ENT_SPEED * frametime);

/*
   FlameParticles(ent.owner.origin + ofs * 2 - '0 0 4', ent.origin);
   FlameParticles(ent.owner.origin + ofs * 2 - '0 0 4', ent.origin);
   FlameParticles(ent.owner.origin + ofs * 2 - '0 0 4', ent.origin);
*/

   // fill with flame bits
//   FillBetweenPoints(ent_parent.origin + ofs, ent.origin, "progs/fl_th1.mdl", '0 0 0', 0.07);
//   ent.effects = ent.effects | EF_MUZZLEFLASH;
   if (ent.speed < FLAME_DIST) {
      ent.speed = ent.speed + (FLAME_ENT_SPEED * frametime * 0.5);
      if (ent.speed > FLAME_DIST)
         ent.speed = FLAME_DIST;
   }
   if (trace_fraction < 1) {
      setorigin(self.owner.flame_ent2, ent.origin);
      self.owner.flame_ent2.speed = 0;
      setorigin(self.owner.flame_ent3, ent.origin);
      self.owner.flame_ent3.speed = 0;

      if ((trace_ent != world) && (trace_ent.takedamage)) {
         ent_burn = trace_ent;
      }

      short_flag = TRUE;
   }

//   T_RadiusDamage(ent, self.owner, 10, self.owner);

// move 2nd junction to ideal position    ****************************************************
   ent_parent = self.owner.flame_ent1;
   ent = self.owner.flame_ent2;
   traceline(ent_parent.origin - v_forward * 2, ent_parent.origin + v_forward * this_dist, FALSE, self.owner);

   dist_from = vlen(ent.origin - trace_endpos);

   if (dist_from < 4)
    ent.angles = vectoangles('0 0 1');
   else {
    vect = normalize(ent.origin - trace_endpos);
    ent.angles = vectoangles(vect);
   }

   ent.angles_z = (360 * random()) - 180;

   this_speed = FLAME_ENT_SPEED * (dist_from / 64);

   if (this_speed > (FLAME_ENT_SPEED * 2))
      this_speed = FLAME_ENT_SPEED*2;

   movetopos(ent, trace_endpos, dist_from / 2); //this_speed * frametime);
//   movetopos(ent, trace_endpos, this_speed * frametime);

   if (trace_fraction == 1) {
      vect = normalize(ent.origin - ent_parent.origin);
      setorigin(ent, ent_parent.origin + (vect * ent.speed));
   }

//   FlameParticles(ent.owner.origin, ent.origin);

   // fill with flame bits
   dist_from = vlen(ent.origin - ent_parent.origin);
   if (dist_from > 32)
      FillBetweenPoints(ent_parent.origin, ent.origin - v_forward * 30, "progs/fl_th2.mdl", '0 0 0', 0.07);
   ent.effects = ent.effects | EF_DIMLIGHT;
   if (ent.speed < FLAME_DIST) {
      ent.speed = ent.speed + (FLAME_ENT_SPEED * frametime * 0.5);
      if (ent.speed > FLAME_DIST * 0.75)
         ent.speed = FLAME_DIST * 0.75;
   }

   if (trace_fraction < 1) {
      setorigin(self.owner.flame_ent3, ent.origin);
      self.owner.flame_ent3.speed = 0;

      if ((trace_ent != world) && (trace_ent.takedamage)) {
         ent_burn = trace_ent;
      }

      short_flag = TRUE;
   }

   if (deathmatch)
      T_RadiusDamage(ent, self.owner, 15, self.owner);
   else
      T_RadiusDamage(ent, self.owner, 10, self.owner);


// move 3rd junction to ideal position    ****************************************************
   v_forward = vect;

   ent_parent = self.owner.flame_ent2;
   ent = self.owner.flame_ent3;
   ideal_pnt = ent_parent.origin + v_forward * this_dist * 0.75;
   traceline(ent_parent.origin - v_forward * 2, ideal_pnt, FALSE, self.owner);

   dist_from = vlen(ent.origin - trace_endpos);

//   if (dist_from < 4)
//    ent.angles = vectoangles('0 0 1');
//   else {
//    vect = normalize(ent.origin - trace_endpos);
//    ent.angles = vectoangles(vect);
//   }

//   ent.angles_z = (360 * random()) - 180;

// 20060704 LordHavoc: disabled this animation code because the flame models are self-animating framegroups, so this just wastes net traffic and spews developer warnings
//   ent.frame = random() * 5.9;
//   ent.frame = floor(ent.frame);


   dist_from = vlen(ent.origin - ideal_pnt); //trace_endpos);
   this_speed = FLAME_ENT_SPEED * (dist_from / 256);

   if (this_speed > (FLAME_ENT_SPEED * 2))
      this_speed = FLAME_ENT_SPEED*2;

   this_speed = this_speed * 3;

   ent.oldorigin = ent.origin;
   movetopos(ent, trace_endpos, dist_from / 3); //this_speed * frametime);

   if (vlen(ent.origin - ent_parent.origin) > this_dist * 0.75) {
      vect = normalize(ent.origin - ent_parent.origin);
      setorigin(ent, ent_parent.origin + (vect * this_dist * 0.75));
   }

   oldangles = ent.angles;
   if ((trace_fraction == 1) && (!short_flag)) {
      vect = normalize(ent.origin - ent_parent.origin);
      ent.angles = vectoangles(vect);
      if (ent.model != "progs/fl_th5.mdl")
         setmodel(ent, "progs/fl_th5.mdl");
   }
   else {
      vect = normalize(ent.origin - self.owner.origin);
      ent.angles = vectoangles(vect);
//      ent.angles_x = ent.angles_x + 45;
      if (ent.model != "progs/fl_th6.mdl")
         setmodel(ent, "progs/fl_th6.mdl");
   }

//   ent.angles_x = -1 * ent.angles_x;

   // calculate Z rotation to match "sway" movement
   makevectors(ent.angles);
   vect = ent.origin - ent.oldorigin;
   dist1 = vlen(vect + v_right);
   dist2 = vlen(vect - v_right);
   if ((!short_flag) && (vlen(vect) > 4)) {
      if ((dist1 - dist2) > 0) { // moving towards RIGHT
         ent.angles_z = MoveToAngle(oldangles_z, 320, 500);
      }
      else if ((dist1 - dist2) < 0) {  // moving towards LEFT
         ent.angles_z = MoveToAngle(oldangles_z, 40, 500);
      }
   }
   else {      // move towards 0
      ent.angles_z = MoveToAngle(oldangles_z, 0, 500);
   }

   vect = normalize(ent.origin - ent.owner.origin);
   dist_from = vlen(vect);

/*
   if ((vlen(ent.origin - self.owner.origin) > FLAME_DIST) || (trace_fraction < 1)) {
//      if (trace_fraction == 1) {
//         vect = normalize(ent.origin - ent_parent.origin);
//         setorigin(ent, ent_parent.origin + (vect * ent.speed));
//      }

      if (ent.model != "progs/fl_th3.mdl")
         setmodel(ent, "progs/fl_th3.mdl");
   }
   else {
      if (ent.model != "progs/fl_th2.mdl")
         setmodel(ent, "progs/fl_th2.mdl");
   }
*/
//   FlameParticles(ent.owner.origin, ent.origin);

   // fill with flame bits
//   FillBetweenPoints(ent_parent.origin + vect * (dist_from / 2), ent.origin, "progs/fl_th3.mdl", '45 0 0', 0.07);
   ent.effects = ent.effects | EF_DIMLIGHT;
   if (ent.speed < FLAME_DIST) {
      ent.speed = ent.speed + (FLAME_ENT_SPEED * frametime * 0.5);
      if (ent.speed > FLAME_DIST * 0.5)
         ent.speed = FLAME_DIST * 0.5;
   }

   if ((trace_ent != world) && (trace_ent.takedamage)) {
      ent_burn = trace_ent;
   }

   if (deathmatch)
      T_RadiusDamage(ent, self.owner, 20, self.owner);
   else
      T_RadiusDamage(ent, self.owner, 13, self.owner);

   if (ent_burn != world && deathmatch) {
      T_Damage(trace_ent, self.owner, self.owner, 8);
   }

};

void() SetSpecialWeaponModel =
{
   if (self.character == CHAR_WOLVERINE) {
      self.weaponmodel = "progs/v_wol.mdl";
   }
   else if (self.character == CHAR_STORM) {
      self.weaponmodel = "progs/v_sto.mdl";
   }
   else if (self.character == CHAR_CYCLOPS) {
      self.weaponmodel = "progs/v_cyc.mdl";
   }
   else if (self.character == CHAR_PSYLOCKE) {
      self.weaponmodel = "progs/v_psy.mdl";
   }
   else if (self.character == CHAR_ANGEL) {
      self.weaponmodel = "progs/v_ang.mdl";
   }
   else if (self.character == CHAR_BEAST) {
      self.weaponmodel = "progs/v_bea.mdl";
   }
   else if (self.character == CHAR_GAMBIT) {
      self.weaponmodel = "progs/v_gam.mdl";
   }
   else if (self.character == CHAR_ICEMAN) {
      self.weaponmodel = "progs/v_ice.mdl";
   }
   else if (self.character == CHAR_BISHOP) {
      self.weaponmodel = "progs/v_bis.mdl";
   }
   else if (self.character == CHAR_ROGUE) {
      self.weaponmodel = "progs/v_rog.mdl";
   }
   else if (self.character == CHAR_CANNONBALL) {
      self.weaponmodel = "progs/v_can.mdl";
   }
   else if (self.character == CHAR_PHOENIX) {
      self.weaponmodel = "progs/v_pho.mdl";
   }
   else {
      self.weaponmodel = "";
      sprint(self, "ERROR: Unknown character setting\n");
   }
};

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() SpecialWeaponChange;
void() W_SetCurrentAmmo =
{
//	player_run ();		// get out of any weapon firing states

   if (self.modelindex == index_skeleton)
      return;

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;

      if (deathmatch || coop) {
         SetSpecialWeaponModel();
      }
      else {
   		self.weaponmodel = "progs/v_xfist.mdl";
      }
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
      self.weaponmodel = "progs/v_xshot1.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
      self.weaponmodel = "progs/v_xchain.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
      self.weaponmodel = "progs/v_xfire1.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
      self.weaponmodel = "progs/v_xflame.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_xorb.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_xrock.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_xshock.mdl";
		self.items = self.items | IT_CELLS;
	}
   else if (self.weapon == IT_SPECIAL_WEAPON)
   {
      self.currentammo = self.ammo_special;
      self.weaponmodel = "progs/v_xmega.mdl";
      self.items = self.items | IT_CELLS;
   }
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
	}
};

float() W_BestWeapon =
{
	local	float	it;

	it = self.items;

   if(self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
      return IT_LIGHTNING;
   else if(self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER) )
      return IT_ROCKET_LAUNCHER;
   else if(self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER) )
      return IT_GRENADE_LAUNCHER;
   else if (self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;

	return IT_AXE;
};

float() W_CheckNoAmmo =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local float     best;

	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;

//	self.nextweapon = W_BestWeapon ();

//   best = W_BestWeapon ();
//   SetNewWeapon(best);

//	W_SetCurrentAmmo ();

// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()   player_att1;
void()	player_laser1;
void()	player_flame1;
void()   player_prox1;
void()   player_orb;
void()	player_rocket1;

void()   player_shotgun1;
void()   player_chain1;
void()   player_fist;
void()   player_mega;

void() W_Attack =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	float	r;
	local	float	best;

   if (self.modelindex == index_skeleton)
      return;

   if (self.change_weapon_status) {       // no firing during fading
//      sprint(self, "can't fire, changing weapons\n");
      return;
    }

    if (self.weapon_flags & W_RELOADING) {
//      sprint(self, "can't fire, reloading\n");
      return;
    }

	if (!W_CheckNoAmmo ()) {
      best = W_BestWeapon ();
      SetNewWeapon(best);

		return;
   }

/*
   if ((self.weapon == IT_NAILGUN) && (self.num_lasers >= 5))
      return;
   else if ((self.num_lasers > 0) && (self.weapon != IT_NAILGUN))
      self.num_lasers = 0;
*/

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_AXE)
	{
      if (deathmatch || coop) {
         if ((!(self.weapon_flags & W_RELOADING)) &&
             ((self.character != CHAR_CANNONBALL) || (self.last_special2 < (time - 1.5)))) {
            player_att1 ();
         }
      }
      else {
         player_fist();
      }

//		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
      if (self.think != player_shotgun1) {
         self.weaponframe = 5;
   		player_shotgun1 ();
      }
		self.attack_finished = time + 0.3;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
      if (self.weaponframe > 11)
         self.weaponframe = 6;

      if (time > self.w_pausetime)
         self.last_pausetime = 0;

      player_chain1 ();
	}
	else if (self.weapon == IT_NAILGUN)
   {
//      self.weaponmodel = "progs/v_xlas2.mdl";

//		player_nail1 ();

      self.fire_reload_frames = 0;
      player_laser1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
      player_flame1();
      self.attack_finished = time + 0.1;
      if (self.waterlevel < 3) {      // can't fire while underwater
         if (!(self.flags & FL_FLAMEON))
            sound(self, CHAN_BODY, "weapons/f_start.wav", 1, ATTN_NORM);

         self.flags = self.flags | FL_FLAMEON;
      }
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_orb();
//		W_FireGrenade();
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
//       W_FireRocket();
      W_FireGuidedRockets();
		self.attack_finished = time + 1.6;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
//      if (self.prox_ent != world)
//         return;

		player_prox1();
		self.attack_finished = time + 0.2;
//		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
   else if (self.weapon == IT_SPECIAL_WEAPON)
   {
      player_mega();
      self.attack_finished = time + 0.2;
      sound (self, CHAN_ITEM, "weapons/m_start.wav", 1, ATTN_NORM);
      sound (self, CHAN_WEAPON, "weapons/mega.wav", 1, ATTN_NONE);
   }
};

float(float  wpn) GetLastMoveFrame =
{
   if (wpn == IT_SHOTGUN) return 25;
   if (wpn == IT_SUPER_SHOTGUN) return 12;
   if (wpn == IT_NAILGUN) return 15;
   if (wpn == IT_SUPER_NAILGUN) return 9;
   if (wpn == IT_GRENADE_LAUNCHER) return 18;
   if (wpn == IT_LIGHTNING) return 0;
   if (wpn == IT_ROCKET_LAUNCHER) return 17;
   if (wpn == IT_AXE)
      if (deathmatch || coop)
         return 0;
      else
         return 16;

   return 0;
};

float(float  wpn) GetFirstMoveFrame =
{
   if (wpn == IT_SHOTGUN) return 30;       // NOTE: frame 31 = frame 1
   if (wpn == IT_SUPER_SHOTGUN) return 17;
   if (wpn == IT_NAILGUN) return 20;
   if (wpn == IT_SUPER_NAILGUN) return 15;
   if (wpn == IT_GRENADE_LAUNCHER) return 23;
   if (wpn == IT_LIGHTNING) return 4;
   if (wpn == IT_ROCKET_LAUNCHER) return 23;
   if (wpn == IT_AXE)
      if (deathmatch || coop)
         return 5;
      else
         return 22;

   return 0;
};

// Return true if next weapon is on a different hand to the current weapon
float() ChangingHands =
{
   if ((deathmatch || coop) && (self.nextweapon == IT_AXE) && (self.weapon != IT_AXE))
      return TRUE;

   if (self.nextweapon == IT_LIGHTNING)
      return TRUE;

   if (self.nextweapon == IT_SPECIAL_WEAPON)
      return TRUE;

   if ((self.nextweapon & (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_AXE)) &&
       (self.weapon & (IT_NAILGUN | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER))) {
      return TRUE;
   }

   if ((self.nextweapon & (IT_NAILGUN | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER)) &&
       (self.weapon & (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_AXE))) {
      return TRUE;
   }
	// 20060704 LordHavoc: hushed a compiler warning by adding a return FALSE
	return FALSE;
};

/*
  =================
   FADE WEAPON OUT
  =================
*/
void() FadeWeaponOut =
{
   local float    newframe;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local string   str;

   if (self.weapon_flags & W_RELOADING)
      return;

   if (self.chasecam != world) {	// change immediately
     self.weapon = self.nextweapon;
     if (self.weapon == IT_AXE)
        SpecialWeaponChange();
     W_SetCurrentAmmo ();
     self.weaponframe = newframe;
     self.change_weapon_status = CW_FADEIN;
   }

   self.last_fade = time;

//bprint("fade out\n");
   if (self.weapon & (IT_NAILGUN | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_AXE | IT_GRENADE_LAUNCHER)) {
      self.weaponframe = self.weaponframe - 1;

      if (self.weaponframe <= self.fadeout_endframe) {
         if ((self.fadeout_endframe == 0) && (ChangingHands()) && (GetLastMoveFrame(self.weapon) > 0)) {
            self.fadeout_endframe = GetLastMoveFrame(self.weapon);
            self.weaponframe = GetFirstMoveFrame(self.weapon);
            return;
         }

         // if we're still here then weapon must have completed fading out
         if (ChangingHands()) {
            newframe = GetLastMoveFrame(self.nextweapon);
            self.fadein_endframe = GetFirstMoveFrame(self.nextweapon);
         }
         else {
            newframe = 0;
            self.fadein_endframe = 5;     // all morphing animations end at frame 5
         }

         self.weapon = self.nextweapon;
         if (self.weapon == IT_AXE)
            SpecialWeaponChange();
         W_SetCurrentAmmo ();
         self.weaponframe = newframe;
         self.change_weapon_status = CW_FADEIN;
      }
   }
   else {
      self.weaponframe = 0;
      self.weapon = self.nextweapon;
      if (self.weapon == IT_AXE)
         SpecialWeaponChange();
      W_SetCurrentAmmo ();
      self.change_weapon_status = CW_FADEIN;
   }
};

/*
  =================
   FADE WEAPON IN
  =================
*/
void() FadeWeaponIn =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local string   str;

   if (self.chasecam != world) {	// change immediately
      self.weaponframe = self.weapon_idleframe;
      self.change_weapon_status = CW_DONE;
	  return;
   }

   self.last_fade = time;

   if (self.weapon & (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_AXE | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER)) {
      self.weaponframe = self.weaponframe + 1;

      if (self.weaponframe >= self.fadein_endframe) {
         if (self.fadein_endframe >= 10) {               // weapon has entered the screen
            self.fadein_endframe = self.weapon_idleframe;
            self.weaponframe = 0;
         }
         else {
            self.change_weapon_status = CW_DONE;
         }
      }
   }
   else if (self.weapon == IT_SPECIAL_WEAPON) {
      self.weaponframe = self.weaponframe + 1;

      if (self.weaponframe == 11) {
         self.change_weapon_status = CW_DONE;
      }
   }
   else {
      self.weaponframe = self.weapon_idleframe;
      self.change_weapon_status = CW_DONE;
   }
};

// Starts the morphing towards the new weapon
void(float wpn) SetNewWeapon =
{
//   if (wpn & IT_LIGHTNING) {
//      return;
//   }
   if (deathmatch == DM_SPECIAL_POWERS) {
      self.weapon_idleframe = 6;
      return;
   }

   if ((self.think != player_run) && (self.think != player_stand1))     // only change if idle
      return;

   if (wpn == self.weapon)
      return;

   if ((self.weapon == IT_LIGHTNING) &&
       (self.prox_ent != world))
      return;

   // make sure we start at the idle frame
   self.weaponframe = self.weapon_idleframe;

   if ((deathmatch || coop) && (wpn == IT_AXE)) {
      self.weapon_idleframe = 6;
   }
   else {
      self.weapon_idleframe = 5;
   }

   self.nextweapon = wpn;
   self.change_weapon_status = CW_FADEOUT;
   self.fadeout_endframe = 0;
   FadeWeaponOut();
};

/*
============
W_ChangeWeapon
============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl, new_idle;

   if (self.modelindex == index_skeleton)
      return;

   if ((deathmatch == DM_SPECIAL_POWERS) && (self.impulse != 1))
      return;

	it = self.items;
	am = 0;

	if (self.impulse == 1)
	{
		fl = IT_AXE;
      new_idle = 6;

      if ((deathmatch || coop) && (self.weapon == IT_AXE)) {
         self.special_weapon = !self.special_weapon;
      }
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
      new_idle = 5;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
      new_idle = 5;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
      new_idle = 5;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
      new_idle = 5;
		if (self.ammo_rockets < 1)
			am = 1;                 // not available yet
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
      new_idle = 5;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
      new_idle = 2;
		if (self.ammo_cells < 1)
			am = 1;
	}
   else if (self.impulse == 13)     // mega-weapon
   {
      fl = IT_SPECIAL_WEAPON;
      new_idle = 11;
      if (self.ammo_special < 1)
         am = 1;
   }

	self.impulse = 0;

	if ((!(self.items & fl)) && (deathmatch || coop))  // X-Men: in singleplayer, weapons are already present
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}

	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
//   self.weapon_idleframe = new_idle;

   if (self.weapon != fl)
      SetNewWeapon(fl);
   else if (self.weapon == IT_AXE) {
      self.weapon = fl;
      SpecialWeaponChange();
      W_SetCurrentAmmo ();
   }
};

/*
============
CheatCommand
============
*/
void() CheatCommand =      // cheats disabled
{
   if (deathmatch)// || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 150;
	self.items = self.items |
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

//   SetNewWeapon(IT_ROCKET_LAUNCHER);


//	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
//	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am, fl;

   if (self.modelindex == index_skeleton)
      return;

	it = self.items;
	self.impulse = 0;
   fl = self.weapon;

   if (deathmatch == DM_SPECIAL_POWERS) {
      self.special_weapon = !self.special_weapon;
      self.weapon = fl;
      SpecialWeaponChange();
      W_SetCurrentAmmo ();

      return;
   }

	while (1)
	{
		am = 0;

		if (fl == IT_LIGHTNING)
		{
			fl = IT_AXE;
		}
		else if (fl == IT_AXE)
		{
			fl = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (fl == IT_SHOTGUN)
		{
			fl = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (fl == IT_SUPER_SHOTGUN)
		{
			fl = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (fl == IT_NAILGUN)
		{
			fl = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (fl == IT_SUPER_NAILGUN)
		{
			fl = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (fl == IT_GRENADE_LAUNCHER)
		{
			fl = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (fl == IT_ROCKET_LAUNCHER)
		{
			fl = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if (am == 0)
		{
         SetNewWeapon(fl);

//			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am, fl;

   if (self.modelindex == index_skeleton)
      return;

	it = self.items;
	self.impulse = 0;
   fl = self.weapon;

   if (deathmatch == DM_SPECIAL_POWERS) {
      self.special_weapon = !self.special_weapon;
      self.weapon = fl;
      SpecialWeaponChange();
      W_SetCurrentAmmo ();

      return;
   }

	while (1)
	{
		am = 0;

		if (fl == IT_LIGHTNING)
		{
			fl = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (fl == IT_ROCKET_LAUNCHER)
		{
			fl = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (fl == IT_GRENADE_LAUNCHER)
		{
			fl = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (fl == IT_SUPER_NAILGUN)
		{
			fl = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (fl == IT_NAILGUN)
		{
			fl = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (fl == IT_SUPER_SHOTGUN)
		{
			fl = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (fl == IT_SHOTGUN)
		{
			fl = IT_AXE;
		}
		else if (fl == IT_AXE)
		{
			fl = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if (am == 0)
		{
         SetNewWeapon(fl);

//			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
Impulse Commands

============
*/
float capture, last_capture, capture_count, capture_index;

void() ImpulseCommands =
{
   local float    ftemp;
   local string   str;

    if (self.impulse == 248) {
      capture = !capture;
      capture_index = 0;
   }

    if (!((self.change_weapon_status) || (self.weapon_flags & W_RELOADING) || ((self.think != player_run) && (self.think != player_stand1)))) {
       // weapon is ready for changing

       if (self.remember_impulse && (self.remember_impulse != 13)) { // prevent from changing while waiting for mega-weapon to come up
         self.impulse = self.remember_impulse;
         self.remember_impulse = 0;
       }

       if ((self.impulse >= 1 && self.impulse <= 8) || (self.impulse == 13))
         W_ChangeWeapon ();
       else if (self.impulse == 10)
         CycleWeaponCommand ();
       else if (self.impulse == 12)
         CycleWeaponReverseCommand ();
    }
    else {
      if ((self.impulse <= 13) && (!self.remember_impulse))
         self.remember_impulse = self.impulse;
    }

    if (!self.impulse)
        return;

    else if (self.impulse == 11)
		ServerflagsCommand ();

    else if (self.impulse == 20)    // re-print last trigger_multiple/single message
      centerprint(self, self.last_centerprint);

    else if (self.impulse == 40)    // toggle chasecam
    {
      if (self.chasecam == world)
         InitCam(self);
      else
         DisableCam(self);
    }

    // any impulses > 200 are debuggin only
    if (deathmatch) {
      self.impulse = 0;
      return;
    }

    else if (self.impulse == 99)
      CheatCommand ();
    else if (self.impulse == 200)
      show_damage = !show_damage;

    else if (self.impulse == 202) {    // give all weapon parts
      self.weapon_parts = 4;
      serverflags = serverflags | 15;
    }

    else if (self.impulse == 250) {
      ftemp = cvar("coop") - 1;
      if (ftemp < 1) ftemp = 12;
      str = ftos(ftemp);
      cvar_set("coop", str);
      stuffcmd(self, "restart\n");
    }
    else if (self.impulse == 251) {
      ftemp = cvar("coop") + 1;
      if (ftemp > 12) ftemp = 1;
      str = ftos(ftemp);
      cvar_set("coop", str);
      stuffcmd(self, "restart\n");
    }

    else if (self.impulse == 222) {
      if (self.x_flags & X_GODCHEAT) {
         self.x_flags = self.x_flags - X_GODCHEAT;
         self.flags = self.flags - (self.flags & FL_GODMODE);
         stuffcmd(self, "bf\n");
         sprint(self, "Invincibility disabled\n");
      }
      else {
         self.x_flags = self.x_flags | X_GODCHEAT;
         self.flags = self.flags | FL_GODMODE;
         sprint(self, "Invincibility enabled\n");
      }
    }

//    else if (self.impulse == 255)
//      QuadCheat ();

    self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
    if ((self.change_weapon_status) && (self.last_fade < (time - 0.07))) {
      if (self.change_weapon_status == CW_FADEOUT)
         FadeWeaponOut();
      else
         FadeWeaponIn();
    }

   ImpulseCommands ();

	if (time < self.attack_finished)
		return;

   if (self.change_weapon_status)
      return;

// check for attack
	if ((self.button0) && (self.modelindex != index_skeleton))
	{
		SuperDamageSound ();
		W_Attack ();

      if ((self.flags & FL_FLAMEON) &&
          (self.weapon != IT_SUPER_NAILGUN)) {
         self.flags = self.flags - FL_FLAMEON;
      }
	}
   else {
      self.flags = self.flags - (self.flags & FL_FLAMEON);
   }

};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};
