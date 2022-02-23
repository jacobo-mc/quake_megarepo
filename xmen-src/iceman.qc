/*
==============================================================================

iceman

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame run1 run2 run3 run4 run5 run6

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26 paina27 paina28 paina29

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16

$frame rise1 rise2 rise3 rise4 rise5 rise6 rise7 rise8 rise9
$frame rise10 rise11 rise12 rise13 rise14 rise15 rise16 rise17 rise18 rise19

$frame melt1 melt2 melt3 melt4 melt5 melt6 melt7 melt8

$frame satta1 satta2 satta3 satta4 satta5 satta6 satta7 satta8
$frame satta9 satta10 satta11 satta12

$frame sattb1 sattb2 sattb3 sattb4 sattb5 sattb6 sattb7 sattb8
$frame sattb9 sattb10 sattb11 sattb12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8
$frame xatta9 xatta10 xatta11 xatta12


void() iceman_Laser_Touch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, self.velocity*0.2, 15);
		T_Damage (other, self, self.owner, 10);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}

	remove(self);
};

void(vector org, vector vec) Ice_LaunchShard =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	vector	vec;


	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

    setmodel (newmis, "progs/iceshard.mdl");
	setsize (newmis, '0 0 0', '0 0 0');

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

    newmis.nextthink = time + 3;
	newmis.think = SUB_Remove;
    newmis.touch = iceman_Laser_Touch;
};


void() ice_atkb1;
void() ice_xatk1;

void() ShardTouch =
{
        // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
        //local vector t1
        //local vector t2;
        local vector vec;
        vec = self.old_velocity;
        if (other == self.owner)
                return;
        if (other == world)
         {
         if (random() < 0.5)
            sound(self, CHAN_AUTO, "weapons/tink1.wav", 1, 3);

         self.state = 0;
         self.avelocity_x = random()*500;
         self.avelocity_y = random()*500;
         self.avelocity_z = random()*500;

         // give seom random upwards velocity
         self.velocity_z = random() * 500 - 100;
         }

   if (other.takedamage == DAMAGE_AIM)
   {
                spawn_touchblood (20);
                T_Damage(other, self, self.owner, 3);
                remove(self);
      return;
   }

        self.last_touch = time;

   if (self.velocity == '0 0 0')
          remove(self);

};

void(vector org, vector dir) spawn_shard =
{
   local entity missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity mpuff;
        local   vector  vect;

   missile = spawn ();
   missile.owner = self;
        missile.movetype = MOVETYPE_BOUNCE;
   missile.state = 1;
   missile.solid = SOLID_SLIDEBOX;
        missile.classname = "shard";

// set missile speed

        vect = normalize(dir);

        missile.velocity = vect * 1000;
//        missile.velocity_z = 0;

        missile.angles = vectoangles(missile.velocity);
        missile.old_velocity = missile.velocity;

        missile.touch = ShardTouch;

// set missile duration
//        missile.last_idle = time;

        missile.last_touch = 0;
        missile.oldorigin = missile.origin;
        missile.nextthink = time + 2.8;
//        missile.think = GrenadeExplode;
        missile.think = SUB_Remove;

        setmodel (missile, "progs/iceshard.mdl");
        setsize (missile, '0 0 0', '0 0 0');
        setorigin (missile, org);
        self.old_velocity = self.velocity;
};


void(float offs) iceman_fire =
{
	local vector org, vect, ang;

   ang = self.angles;
   ang_y = anglemod(ang_y + offs);

	makevectors (ang);
   vect = v_forward;

    org = self.origin + '0 0 12';

    spawn_shard(org, vect);
};

void() iceballTouch =
{
        if (other == self.owner)
                return;

   if (((other.classname == "player") || (coop && (other.flags & FL_MONSTER))) && (other.parallize_time < (time - 4)))
   {
      if (!deathmatch && (other.flags & FL_CLIENT))
         other.parallize_time = time + 2;
      else
         other.parallize_time = time + 3;

      other.x_flags = other.x_flags | X_PARALLIZED;
      other.parallized_velocity = '0 0 0';

      if (other.flags & FL_CLIENT)
      {
         centerprint(other, "You have been iced!");
         stuffcmd(other, "v_cshift 128 128 256 180\n");
      }
      else
      {
         other.think = other.th_stand;
         other.enemy = world;
      }

      sound(other, CHAN_BODY, "generic/frozen1.wav", 1, ATTN_NORM);

      if (deathmatch)
         other.skin = 1;

      remove(self);
      return;
   }

   remove(self);

};

void(vector org, vector dir) spawn_iceball =
{
   local entity missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity mpuff;
        local   vector  vect;

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.classname = "iceblast";

// set missile speed

        vect = normalize(dir);

        if (self.flags & FL_MONSTER)
           missile.velocity = ProjectVelocity(1400, '0 0 0');
        else
           missile.velocity = vect * 1400;

        missile.angles = vectoangles(missile.velocity);
        missile.old_velocity = missile.velocity;

        missile.touch = iceballTouch;

// set missile duration
//        missile.last_idle = time;

        missile.last_touch = 0;
        missile.oldorigin = missile.origin;
        missile.nextthink = time + 2;
//        missile.think = GrenadeExplode;
        missile.think = SUB_Remove;
        missile.avelocity_z = 300;

        setmodel (missile, "progs/iceblast.mdl");
        setsize (missile, '0 0 0', '0 0 0');
        setorigin (missile, org);
};


void () ice_fire_iceball =
{
    local vector org,o2;

	makevectors (self.angles);

    org = self.origin + v_forward * 1 + '0 0 12';

    o2 = self.enemy.origin + v_right * ((random() * 64) - 32);
    spawn_iceball(org, o2 - self.origin);

};
//============================================================================

void()  ice_stand1  =[  $stand1,    ice_stand2  ] {ai_stand();};
void()  ice_stand2  =[  $stand2,    ice_stand3  ] {ai_stand();};
void()  ice_stand3  =[  $stand3,    ice_stand4  ] {ai_stand();};
void()  ice_stand4  =[  $stand4,    ice_stand5  ] {ai_stand();};
void()  ice_stand5  =[  $stand5,    ice_stand6  ] {ai_stand();};
void()  ice_stand6  =[  $stand6,    ice_stand7  ] {ai_stand();};
void()  ice_stand7  =[  $stand7,    ice_stand8  ] {ai_stand();};
void()   ice_stand8  =[ $stand8, ice_stand9  ] {ai_stand();};
void()   ice_stand9  =[ $stand9, ice_stand10 ] {ai_stand();};
void()   ice_stand10 =[ $stand10, ice_stand11 ] {ai_stand();};
void()   ice_stand11 =[ $stand11, ice_stand12 ] {ai_stand();};
void()   ice_stand12 =[ $stand12, ice_stand13 ] {ai_stand();};
void()   ice_stand13 =[ $stand13, ice_stand1  ] {ai_stand();};

void()  ice_walk1   =[  $walk1 ,    ice_walk2   ] {ai_walk(7);};
void()  ice_walk2   =[  $walk2 ,    ice_walk3   ] {ai_walk(4);};
void()  ice_walk3   =[  $walk3 ,    ice_walk4   ] {ai_walk(4);};
void()  ice_walk4   =[  $walk4 ,    ice_walk5   ] {ai_walk(4);};
void()  ice_walk5   =[  $walk5 ,    ice_walk6   ] {ai_walk(4);};
void()  ice_walk6   =[  $walk6 ,    ice_walk7   ] {ai_walk(5);};
void()  ice_walk7   =[  $walk7 ,    ice_walk8   ] {ai_walk(5);};
void()  ice_walk8   =[  $walk8 ,    ice_walk9   ] {ai_walk(4);};
void()  ice_walk9   =[  $walk9 ,    ice_walk10  ] {ai_walk(7);};
void()  ice_walk10  =[  $walk10,    ice_walk11  ] {ai_walk(4);};
void()  ice_walk11  =[  $walk11,    ice_walk12  ] {ai_walk(0);};
void()  ice_walk12  =[  $walk12,    ice_walk1   ] {ai_walk(5);};

void()  ice_run1    =[  $run1  ,    ice_run2    ] {
ai_run(14);};
void()  ice_run2    =[  $run2  ,    ice_run3    ] {ai_run(16);};
void()  ice_run3    =[  $run3  ,    ice_run4    ] {ai_run(16);};
void()  ice_run4    =[  $run4  ,    ice_run5    ] {ai_run(16);};
void()  ice_run5    =[  $run5  ,    ice_run6    ] {ai_run(16);};
void()  ice_run6    =[  $run6  ,    ice_run1    ] {ai_run(16);};

void()   ice_pain1   =[ $pain1, ice_pain2  ] {};
void()   ice_pain2   =[ $pain2, ice_pain3  ] {};
void()   ice_pain3   =[ $pain3, ice_pain4  ] {};
void()   ice_pain4   =[ $pain4, ice_pain5  ] {};
void()   ice_pain5   =[ $pain5, ice_pain6  ] {};
void()   ice_pain6   =[ $pain6, ice_run1 ] {};

void()   ice_melt1   =[ $melt1, ice_melt2  ] {};
void()   ice_melt2   =[ $melt2, ice_melt3  ] {};
void()   ice_melt3   =[ $melt3, ice_melt4  ] {};
void()   ice_melt4   =[ $melt4, ice_melt5  ] {};
void()   ice_melt5   =[ $melt5, ice_melt6  ] {};
void()   ice_melt6   =[ $melt6, ice_melt7  ] {};
void()   ice_melt7   =[ $melt7, ice_melt8  ] {};
void()   ice_melt8   =[ $melt8, ice_melt8  ] {

 setmodel(self, "progs/puddle.mdl");
 self.skin = 0;
 self.solid = SOLID_NOT;
 self.deadflag = DEAD_DEAD;
 self.think = SUB_Remove;
 self.nextthink = time + 120 + random() * 30;
};

void()   ice_paina1  =[ $paina1, ice_paina2  ] {};
void()   ice_paina2  =[ $paina2, ice_paina3  ] {};
void()   ice_paina3  =[ $paina3, ice_paina4  ] {};
void()   ice_paina4  =[ $paina4, ice_paina5  ] {};
void()   ice_paina5  =[ $paina5, ice_paina6  ] {};
void()   ice_paina6  =[ $paina6, ice_paina7  ] {};
void()   ice_paina7  =[ $paina7, ice_paina8  ] {};
void()   ice_paina8  =[ $paina8, ice_paina9  ] {};
void()   ice_paina9  =[ $paina9, ice_paina10 ] {};
void()   ice_paina10 =[ $paina10, ice_paina11 ] {};
void()   ice_paina11 =[ $paina11, ice_paina12 ] {};
void()   ice_paina12 =[ $paina12, ice_paina13 ] {};
void()   ice_paina13 =[ $paina12, ice_paina14 ] {};
void()   ice_paina14 =[ $paina12, ice_paina15 ] {};
void()   ice_paina15 =[ $paina13, ice_paina16 ] {};
void()   ice_paina16 =[ $paina14, ice_paina17 ] {};
void()   ice_paina17 =[ $paina15, ice_paina18 ] {};
void()   ice_paina18 =[ $paina16, ice_paina19 ] {};
void()   ice_paina19 =[ $paina16, ice_paina20 ] {};
void()   ice_paina20 =[ $paina16, ice_paina21 ] {};
void()   ice_paina21 =[ $paina17, ice_paina22 ] {};
void()   ice_paina22 =[ $paina18, ice_paina23 ] {};
void()   ice_paina23 =[ $paina19, ice_paina24 ] {};
void()   ice_paina24 =[ $paina20, ice_paina25 ] {};
void()   ice_paina25 =[ $paina21, ice_paina26 ] {};
void()   ice_paina26 =[ $paina22, ice_paina27 ] {};
void()   ice_paina27 =[ $paina23, ice_paina28 ] {};
void()   ice_paina28 =[ $paina24, ice_paina29 ] {};
void()   ice_paina29 =[ $paina25, ice_paina30 ] {};
void()   ice_paina30 =[ $paina26, ice_paina31 ] {};
void()   ice_paina31 =[ $paina27, ice_paina32 ] {};
void()   ice_paina32 =[ $paina28, ice_paina33 ] {};
void()   ice_paina33 =[ $paina29, ice_run1   ] {};


//============================================================================


void(entity attacker, float damage) ice_pain;
void()  ice_atk1    =[  $satta1,   ice_atk2    ]
 {
 ai_face();
 self.start_attack_health = self.health;
 if (self.count) ai_forward(24);
 };

void()  ice_atk2    =[  $satta2,   ice_atk3    ]
 {
 ai_face();
 iceman_fire(-15);
 if (self.count) ai_forward(14);
 };

void()  ice_atk3    =[  $satta3,   ice_atk4    ]
 {
 ai_face();
 iceman_fire(-9);
 if (self.count) ai_forward(8);
 };

void()  ice_atk4    =[  $satta4,   ice_atk5    ]
 {
 ai_face();
 iceman_fire(-3);
 if (self.count) ai_forward(4);
 };

void()  ice_atk5    =[  $satta5,   ice_atk6    ]
 {
 ai_face();
 iceman_fire(3);
 if (self.count) ai_forward(2);
 self.count = 0;
 };
void()  ice_atk6    =[  $satta6,   ice_atk7    ] {iceman_fire(9);};
void()  ice_atk7    =[  $satta7,   ice_atk8    ]
{
iceman_fire(15);
if (self.health < self.start_attack_health)
    {
    ice_pain(self.enemy, self.start_attack_health - self.health);
    }
};

void()  ice_atk8    =[  $satta8,   ice_atk9    ] {};
void()  ice_atk9    =[  $satta9,   ice_atk10   ] {};
void()  ice_atk10   =[  $satta10,  ice_atk11   ] {};
void()  ice_atk11   =[  $satta11,  ice_atk12   ] {};
void()  ice_atk12   =[  $satta12,  ice_run1    ] {};

void()  ice_xatk1    =[  $xatta1,   ice_xatk2    ]
 {
 ai_face();
 self.start_attack_health = self.health;
 if (self.count) ai_forward(24);
 };
void()  ice_xatk2    =[  $xatta2,   ice_xatk3    ]
 {
 ai_face();
 if (self.count) ai_forward(14);
 };
void()  ice_xatk3    =[  $xatta3,   ice_xatk4    ]
 {
 ai_face();
 if (self.count) ai_forward(8);
 };
void()  ice_xatk4    =[  $xatta4,   ice_xatk5    ]
 {
 ai_face();
 if (self.count) ai_forward(4);
 };
void()  ice_xatk5    =[  $xatta5,   ice_xatk6    ]
 {
 ai_face();
 if (self.count) ai_forward(2);
 self.count = 0;
 };
void()  ice_xatk6    =[  $xatta6,   ice_xatk7    ] {ai_face();};
void()  ice_xatk7    =[  $xatta7,   ice_xatk8    ]
{ai_face();
   if (self.health < self.start_attack_health) {
      ice_pain(self.enemy, self.start_attack_health - self.health);
   }
};
void()  ice_xatk8    =[  $xatta8,   ice_xatk9    ] {ai_face();};
void()  ice_xatk9    =[  $xatta9,   ice_xatk10   ] {ai_face();};
void()  ice_xatk10   =[  $xatta10,  ice_xatk11   ] {ai_face();};
void()  ice_xatk11   =[  $xatta11,  ice_xatk12   ] {ai_face();};
void()  ice_xatk12   =[  $xatta12,  ice_run1    ] {ai_face();
ice_fire_iceball();
};


void(entity attacker, float damage) ice_pain =
{
	local float r;

   if (self.enemy.weapon == IT_SUPER_NAILGUN)
      return;

	r = random ();
	if (self.pain_finished > time)
		return;



   if (random()*40 > damage)
      return;     // didn't flinch

   MalePainSound(2);

	if ((random()*10 < 8) || ((damage > 50) && (random() < 0.5)))
	{
        self.pain_finished = time + 2;
        ice_pain1 ();
	}
	else
	{
		self.pain_finished = time + 4;
        ice_paina1 ();
	}
};

void()  ice_atkb1    =[  $sattb1,   ice_atkb2    ]
 {
 ai_face();
 self.start_attack_health = self.health;
 if (self.count) ai_forward(32);
 };

void()  ice_atkb2    =[  $sattb2,   ice_atkb3    ]
 {
 ai_face();
 iceman_fire(15);
 if (self.count) ai_forward(24);
 };

void()  ice_atkb3    =[  $sattb3,   ice_atkb4    ]
 {
 ai_face();
 iceman_fire(9);
 if (self.count) ai_forward(16);
 };

void()  ice_atkb4    =[  $sattb4,   ice_atkb5    ]
 {
 ai_face();
 iceman_fire(3);
 if (self.count) ai_forward(8);
 };
void()  ice_atkb5    =[  $sattb5,   ice_atkb6    ]
{
 ai_face();
iceman_fire(-3);
if (self.count) ai_forward(8);
self.count = 0;
};
void()  ice_atkb6    =[  $sattb6,   ice_atkb7    ] {iceman_fire(-9);};
void()  ice_atkb7    =[  $sattb7,   ice_atkb8    ] {
   if (self.health < self.start_attack_health) {
      ice_pain(self.enemy, self.start_attack_health - self.health);
   iceman_fire(-15);
   }
};
void()  ice_atkb8    =[  $sattb8,   ice_atkb9    ] {};
void()  ice_atkb9    =[  $sattb9,   ice_atkb10   ] {};
void()  ice_atkb10   =[  $sattb10,  ice_atkb11   ] {};
void()  ice_atkb11   =[  $sattb11,  ice_atkb12   ] {};
void()  ice_atkb12   =[  $sattb12,  ice_run1    ] {};

void() ice_attack =
{
   local float rnd;

   rnd = random();
   if (rnd < 0.3)
      ice_atk1();
   else if (rnd < 0.6)
      ice_atkb1();
   else if (self.last_special < (time - 8)) {
      self.last_special = time;
      ice_xatk1();
   }
   else {
      ice_atk1();
   }
};

//============================================================================

void () iceman_melt_go =
{
self.deadflag = DEAD_DYING;
self.pain_finished = time + 99;
ice_melt1();
};

void (entity e) iceman_melt =
{
   //e.health = 1;
   e.think = iceman_melt_go;
   e.nextthink = time + 0.1;

   // up the kill count, since he is now officially DEAD
   killed_monsters = killed_monsters + 1;
   WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
};

void () ice_getup =
{
self.takedamage = DAMAGE_AIM;
self.solid = SOLID_SLIDEBOX;
if (!walkmove(0,0))
 {
 self.think = ice_getup;
 self.solid = SOLID_NOT;
 self.nextthink = time + 0.5;
 return;
 }
self.health = self.start_health;
ice_run1();
};

void()  ice_rise1    =[  $rise1,    ice_rise2    ]
{
   self.solid = SOLID_SLIDEBOX;
   if (!walkmove(0,0))
   {
      self.think = ice_rise1;
      self.solid = SOLID_NOT;
      self.nextthink = time + 0.5;
      return;
   }
};
void()  ice_rise2    =[  $rise2,    ice_rise3    ] {};
void()  ice_rise3    =[  $rise3,    ice_rise4    ] {};
void()  ice_rise4    =[  $rise4,    ice_rise5    ] {};
void()  ice_rise5    =[  $rise5,    ice_rise6    ] {};
void()  ice_rise6    =[  $rise6,    ice_rise7    ] {};
void()  ice_rise7    =[  $rise7,    ice_rise8    ] {};
void()  ice_rise8    =[  $rise8,    ice_rise9    ] {};
void()  ice_rise9    =[  $rise9,    ice_rise10   ] {};
void()  ice_rise10   =[  $rise10,   ice_rise11   ] {};
void()  ice_rise11   =[  $rise11,   ice_rise12   ] {};
void()  ice_rise12   =[  $rise12,   ice_rise13   ] {};
void()  ice_rise13   =[  $rise13,   ice_rise14   ] {};
void()  ice_rise14   =[ $rise14,   ice_rise15   ] {};
void()  ice_rise15   =[ $rise15,   ice_rise16   ] {};
void()  ice_rise16   =[ $rise16,   ice_rise17   ] {};
void()  ice_rise17   =[ $rise17,   ice_rise18   ] {};
void()  ice_rise18   =[ $rise18,   ice_rise19   ] {};
void()  ice_rise19   =[ $rise19,   ice_getup    ] {};

void()  ice_die1    =[  $death1,    ice_die2    ] {};
void()  ice_die2    =[  $death2,    ice_die3    ] {};
void()  ice_die3    =[  $death3,    ice_die4    ] {self.solid = SOLID_NOT;self.ammo_cells = 5;};
void()  ice_die4    =[  $death4,    ice_die5    ] {};
void()  ice_die5    =[  $death5,    ice_die6    ] {};
void()  ice_die6    =[  $death6,    ice_die7    ] {};
void()  ice_die7    =[  $death7,    ice_die8    ] {};
void()  ice_die8    =[  $death8,    ice_die9    ] {};
void()  ice_die9    =[  $death9,    ice_die10   ] {};
void()  ice_die10   =[  $death10,   ice_die11   ] {};
void()  ice_die11   =[  $death11,   ice_die12   ] {};
void()  ice_die12   =[  $death12,   ice_die13   ] {};
void()  ice_die13   =[  $death13,   ice_die14   ] {};
void()   ice_die14   =[ $death14,   ice_die15   ] {};
void()   ice_die15   =[ $death15,   ice_die16   ] {};
void()   ice_die16   =[ $death16,   ice_die16   ] {
   if (!(self.spawnflags & SPAWNFLAG_CLONE)) {
      self.solid = SOLID_NOT;
      self.think = ice_rise1;
      self.takedamage = DAMAGE_NO;
      self.nextthink = time + 20 + random() * 20;
   }
};


void() GibShardThink =
{
   if (self.velocity_z == 0)
      remove(self);
   else
      self.nextthink = time + 0.2;
};

void(entity ent, float  num_gibs) IcemanShardGib =
{
   local entity   shard;
   local float    num;
   local vector   vect;

   if (damage_inflictor.classname == "guided_rocket") {
      vect = normalize(damage_inflictor.velocity);
   }
   else {
      vect = '0 0 0';
   }

   num = num_gibs;

   while (num > 0) {
      shard = spawn();
      shard.movetype = MOVETYPE_BOUNCE;

      shard.velocity_x = random() * 150 - 75;
      shard.velocity_y = random() * 150 - 75;
      shard.velocity_z = 220 + random() * 150;

      shard.velocity = shard.velocity + vect * 200;

      shard.angles = shard.velocity;
      shard.avelocity = '200 200 200';

      setsize(shard, '0 0 0', '0 0 0');
      setmodel(shard, "progs/iceshard.mdl");
      setorigin(shard, ent.origin + shard.velocity * 0.1);

      shard.frame = 1;

      shard.think = GibShardThink;
      shard.nextthink = time + 1;

      num = num - 1;
   }
};

void() ice_die =
{
   // check for shard gib
   if ((damage_inflictor.classname == "guided_rocket") ||
       (damage_inflictor.classname == "orb") ||
       (damage_inflictor.classname == "prox_missile") ||
       (damage_inflictor.classname == "proximity_ball")) {
      IcemanShardGib(self, 15);
      remove(self);
      return;
   }

   ice_die1 ();
};


/*QUAKED monster_iceman (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_zombie =
{
   remove(self);
};

void() xmen_iceman =
{
    if ((deathmatch) || (self.spawnflags & 1))
   {
      remove(self);
      return;
   }
    precache_model2 ("progs/iceshard.mdl");
    precache_model2 ("progs/puddle.mdl");
    precache_model2 ("progs/iceblast.mdl");

    precache_sound  ("generic/frozen1.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

    if ((self.map == "green") || (self.map == ""))
    {
    precache_model2("progs/ice1.mdl");
    setmodel (self, "progs/ice1.mdl");
    }
    if (self.map == "blue")
    {
    precache_model2("progs/ice2.mdl");
    setmodel (self, "progs/ice2.mdl");
    }
    if (self.map == "purple")
    {
    precache_model2("progs/ice3.mdl");
    setmodel (self, "progs/ice3.mdl");
    }
    if (self.map == "brown")
    {
    precache_model2("progs/ice4.mdl");
    setmodel (self, "progs/ice4.mdl");
    }
    if (self.map == "gold")
    {
    precache_model2("progs/ice5.mdl");
    setmodel (self, "progs/ice5.mdl");
    }
    setsize (self, '-16 -16 -24', '16 16 40');
    self.health = 80 + cvar("skill") * 10;


    self.th_stand = ice_stand1;
    self.th_walk = ice_walk1;
    self.th_run = ice_run1;
    self.th_pain = ice_pain;
    self.th_die = ice_die;

    self.th_missile = ice_attack;
    self.count = 0;

   walkmonster_start();
};