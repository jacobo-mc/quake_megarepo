/*==========================================================================

   phoenix

==========================================================================*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20

$frame guard1 guard2 guard3 guard4 guard5 guard6 guard7 guard8 guard9
$frame guard10 guard11 guard12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8 xatta9 xatta10
$frame xatta11 xatta12

$frame xattb1 xattb2 xattb3 xattb4 xattb5 xattb6 xattb7 xattb8 xattb9 xattb10
$frame xattb11 xattb12

$frame xattc1 xattc2 xattc3 xattc4 xattc5 xattc6 xattc7 xattc8 xattc9 xattc10
$frame xattc11 xattc12 xattc13 xattc14 xattc15 xattc16 xattc17

void() phoenix_stand1  = [   $stand1,    phoenix_stand2  ] {ai_stand();};
void() phoenix_stand2  = [   $stand2,    phoenix_stand3  ] {ai_stand();};
void() phoenix_stand3  = [   $stand3,    phoenix_stand4  ] {ai_stand();};
void() phoenix_stand4  = [   $stand4,    phoenix_stand5  ] {ai_stand();};
void() phoenix_stand5  = [   $stand5,    phoenix_stand6  ] {ai_stand();};
void() phoenix_stand6  = [   $stand6,    phoenix_stand7  ] {ai_stand();};
void() phoenix_stand7  = [   $stand7,    phoenix_stand8  ] {ai_stand();};
void() phoenix_stand8  = [   $stand8,    phoenix_stand9  ] {ai_stand();};
void() phoenix_stand9  = [   $stand9,    phoenix_stand10 ] {ai_stand();};
void() phoenix_stand10 = [   $stand10,   phoenix_stand11 ] {ai_stand();};
void() phoenix_stand11 = [   $stand11,   phoenix_stand12 ] {ai_stand();};
void() phoenix_stand12 = [   $stand12,   phoenix_stand13 ] {ai_stand();};
void() phoenix_stand13 = [   $stand13,   phoenix_stand1  ] {ai_stand();};

void() phoenix_walk1  = [   $walk1,    phoenix_walk2  ] {ai_walk(5);};
void() phoenix_walk2  = [   $walk2,    phoenix_walk3  ] {ai_walk(4);};
void() phoenix_walk3  = [   $walk3,    phoenix_walk4  ] {ai_walk(4);};
void() phoenix_walk4  = [   $walk4,    phoenix_walk5  ] {ai_walk(5);};
void() phoenix_walk5  = [   $walk5,    phoenix_walk6  ] {ai_walk(5);};
void() phoenix_walk6  = [   $walk6,    phoenix_walk7  ] {ai_walk(6);};
void() phoenix_walk7  = [   $walk7,    phoenix_walk8  ] {ai_walk(6);};
void() phoenix_walk8  = [   $walk8,    phoenix_walk9  ] {ai_walk(4);};
void() phoenix_walk9  = [   $walk9,    phoenix_walk10 ] {ai_walk(4);};
void() phoenix_walk10 = [   $walk10,   phoenix_walk11 ] {ai_walk(5);};
void() phoenix_walk11 = [   $walk11,   phoenix_walk12 ] {ai_walk(5);};
void() phoenix_walk12 = [   $walk12,   phoenix_walk1  ] {ai_walk(6);};

void() phoenix_runwalk1;
void() phoenix_run1  = [   $run1,    phoenix_run2  ]
{
   if (vlen(self.enemy.origin - self.origin) < 196) {
      phoenix_runwalk1();
      return;
   }

   ai_run(19);
};
void() phoenix_run2  = [   $run2,    phoenix_run3  ] {ai_run(19);};
void() phoenix_run3  = [   $run3,    phoenix_run4  ] {ai_run(18);};
void() phoenix_run4  = [   $run4,    phoenix_run5  ] {ai_run(18);};
void() phoenix_run5  = [   $run5,    phoenix_run6  ] {ai_run(19);};
void() phoenix_run6  = [   $run6,    phoenix_run7  ] {ai_run(19);};
void() phoenix_run7  = [   $run7,    phoenix_run8  ] {ai_run(18);};
void() phoenix_run8  = [   $run8,    phoenix_run1  ] {ai_run(18);};

void() phoenix_runwalk1  = [   $walk1,    phoenix_runwalk2  ]
{
   if (vlen(self.enemy.origin - self.origin) > 256) {
      phoenix_run1();
      return;
   }

   ai_run(4);
};
void() phoenix_runwalk2  = [   $walk2,    phoenix_runwalk3  ] {ai_run(4);};
void() phoenix_runwalk3  = [   $walk3,    phoenix_runwalk4  ] {ai_run(3);};
void() phoenix_runwalk4  = [   $walk4,    phoenix_runwalk5  ] {ai_run(4);};
void() phoenix_runwalk5  = [   $walk5,    phoenix_runwalk6  ] {ai_run(4);};
void() phoenix_runwalk6  = [   $walk6,    phoenix_runwalk7  ] {ai_run(3);};
void() phoenix_runwalk7  = [   $walk7,    phoenix_runwalk8  ] {ai_run(3);};
void() phoenix_runwalk8  = [   $walk8,    phoenix_runwalk9  ] {ai_run(4);};
void() phoenix_runwalk9  = [   $walk9,    phoenix_runwalk10 ] {ai_run(4);};
void() phoenix_runwalk10 = [   $walk10,   phoenix_runwalk11 ] {ai_run(3);};
void() phoenix_runwalk11 = [   $walk11,   phoenix_runwalk12 ] {ai_run(4);};
void() phoenix_runwalk12 = [   $walk12,   phoenix_runwalk1  ] {ai_run(4);};

//============================================================================

void() phoenix_pain1  = [   $pain1,    phoenix_pain2  ] {};
void() phoenix_pain2  = [   $pain2,    phoenix_pain3  ] {};
void() phoenix_pain3  = [   $pain3,    phoenix_pain4  ] {};
void() phoenix_pain4  = [   $pain4,    phoenix_pain5  ] {};
void() phoenix_pain5  = [   $pain5,    phoenix_pain6  ] {};
void() phoenix_pain6  = [   $pain6,    phoenix_run1   ] {};

void() phoenix_paina1  = [   $paina1,    phoenix_paina2  ] {};
void() phoenix_paina2  = [   $paina2,    phoenix_paina3  ] {};
void() phoenix_paina3  = [   $paina3,    phoenix_paina4  ] {};
void() phoenix_paina4  = [   $paina4,    phoenix_paina5  ] {};
void() phoenix_paina5  = [   $paina5,    phoenix_paina6  ] {};
void() phoenix_paina6  = [   $paina6,    phoenix_paina7  ] {};
void() phoenix_paina7  = [   $paina7,    phoenix_paina8  ] {};
void() phoenix_paina8  = [   $paina8,    phoenix_paina9  ] {};
void() phoenix_paina9  = [   $paina9,    phoenix_paina10 ] {};
void() phoenix_paina10 = [   $paina10,   phoenix_paina11 ] {};
void() phoenix_paina11 = [   $paina11,   phoenix_paina12 ] {};
void() phoenix_paina12 = [   $paina12,   phoenix_paina13 ] {};
void() phoenix_paina13 = [   $paina13,   phoenix_paina14 ] {};
void() phoenix_paina14 = [   $paina14,   phoenix_paina15 ] {};
void() phoenix_paina15 = [   $paina15,   phoenix_paina16 ] {};
void() phoenix_paina16 = [   $paina16,   phoenix_paina17 ] {};
void() phoenix_paina17 = [   $paina17,   phoenix_paina18 ] {};
void() phoenix_paina18 = [   $paina18,   phoenix_paina19 ] {};
void() phoenix_paina19 = [   $paina19,   phoenix_paina20 ] {};
void() phoenix_paina20 = [   $paina20,   phoenix_paina21 ] {};
void() phoenix_paina21 = [   $paina21,   phoenix_paina22 ] {};
void() phoenix_paina22 = [   $paina22,   phoenix_paina23 ] {};
void() phoenix_paina23 = [   $paina23,   phoenix_paina24 ] {};
void() phoenix_paina24 = [   $paina24,   phoenix_run1    ] {};

void(entity attacker, float damage) PhoenixPain =
{
   if (self.pain_finished > time)
      return;

   if (self.health <= 0)
      return;

   FemalePainSound();

   if ((damage > 10) && (random() < 0.4)) {
      sound(self, CHAN_AUTO, "items/protect3.wav", 1, ATTN_NORM);
      self.pain_finished = time + 2;
      phoenix_paina1();
   }
   else {
      self.pain_finished = time + 5;
      phoenix_pain1();
   }
};

//============================================================================

void() phoenix_death1  = [   $death1,    phoenix_death2  ] {};
void() phoenix_death2  = [   $death2,    phoenix_death3  ] {};
void() phoenix_death3  = [   $death3,    phoenix_death4  ] {self.solid = SOLID_NOT;};
void() phoenix_death4  = [   $death4,    phoenix_death5  ] {};
void() phoenix_death5  = [   $death5,    phoenix_death6  ] {};
void() phoenix_death6  = [   $death6,    phoenix_death7  ] {};
void() phoenix_death7  = [   $death7,    phoenix_death8  ] {};
void() phoenix_death8  = [   $death8,    phoenix_death9  ] {};
void() phoenix_death9  = [   $death9,    phoenix_death10 ] {};
void() phoenix_death10 = [   $death10,   phoenix_death11 ] {};
void() phoenix_death11 = [   $death11,   phoenix_death12 ] {};
void() phoenix_death12 = [   $death12,   phoenix_death13 ] {};
void() phoenix_death13 = [   $death13,   phoenix_death14 ] {};
void() phoenix_death14 = [   $death14,   phoenix_death15 ] {};
void() phoenix_death15 = [   $death15,   phoenix_death16 ] {};
void() phoenix_death16 = [   $death16,   phoenix_death17 ] {};
void() phoenix_death17 = [   $death17,   phoenix_death18 ] {};
void() phoenix_death18 = [   $death18,   phoenix_death19 ] {};
void() phoenix_death19 = [   $death19,   phoenix_death20 ] {};
void() phoenix_death20 = [   $death20,   phoenix_death20 ] {if (self.angles_x != 0) AngelPitch();};

void() PhoenixDie =
{
   FemaleDeathSound();

   phoenix_death1();
};

//============================================================================

void() phoenix_guard1  = [   $guard1,    phoenix_guard2  ] {self.nextthink = time + 0.05;};
void() phoenix_guard2  = [   $guard2,    phoenix_guard3  ] {self.nextthink = time + 0.05;};
void() phoenix_guard3  = [   $guard3,    phoenix_guard4  ] {self.nextthink = time + 0.05;};
void() phoenix_guard4  = [   $guard4,    phoenix_guard5  ] {
sound(self, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
self.flags = self.flags | FL_GODMODE;};
void() phoenix_guard5  = [   $guard5,    phoenix_guard6  ] {};
void() phoenix_guard6  = [   $guard6,    phoenix_guard7  ] {};
void() phoenix_guard7  = [   $guard7,    phoenix_guard8  ] {};
void() phoenix_guard8  = [   $guard8,    phoenix_guard9  ] {};
void() phoenix_guard9  = [   $guard9,    phoenix_guard10 ] {};
void() phoenix_guard10 = [   $guard10,   phoenix_guard11 ] {};
void() phoenix_guard11 = [   $guard11,   phoenix_guard12 ] {};
void() phoenix_guard12 = [   $guard12,   phoenix_run1    ] {self.flags = self.flags - FL_GODMODE;};

//============================================================================

void() PhoenixFireHoming =
{
    local entity    missile;
    // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
    //local entity    missile_enemy;
    local vector    dir;

   missile = spawn ();
   missile.classname = "phoenix_blast";
   missile.attack_finished = time + 3;
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;

   missile.enemy = self.enemy;
   missile.think = GuidedRocketThink;
   missile.last_guided_search = time;
   missile.nextthink = time + 0.05;

   // set missile speed
   makevectors(self.angles);

   missile.velocity = v_forward;
   missile.velocity = missile.velocity * 800;
   missile.angles = vectoangles(missile.velocity);

   missile.touch = T_GuidedMissileTouch;

   missile.avelocity_z = 300;

   setmodel (missile, "progs/psyblast.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, self.origin + dir*8 + '0 0 12');

};

void() phoenix_xatta1  = [   $xatta1,    phoenix_xatta2  ] {ai_face();};
void() phoenix_xatta2  = [   $xatta2,    phoenix_xatta3  ] {ai_face();};
void() phoenix_xatta3  = [   $xatta3,    phoenix_xatta4  ] {ai_face();};
void() phoenix_xatta4  = [   $xatta4,    phoenix_xatta5  ] {ai_face();};
void() phoenix_xatta5  = [   $xatta5,    phoenix_xatta6  ] {PhoenixFireHoming();};
void() phoenix_xatta6  = [   $xatta6,    phoenix_xatta7  ] {};
void() phoenix_xatta7  = [   $xatta7,    phoenix_xatta8  ] {};
void() phoenix_xatta8  = [   $xatta8,    phoenix_xatta9  ] {};
void() phoenix_xatta9  = [   $xatta9,    phoenix_xatta10 ] {};
void() phoenix_xatta10 = [   $xatta10,   phoenix_xatta11 ] {};
void() phoenix_xatta11 = [   $xatta11,   phoenix_xatta12 ] {};
void() phoenix_xatta12 = [   $xatta12,   phoenix_run1    ] {};

void() phoenix_xattb1  = [   $xattb1,    phoenix_xattb2  ] {ai_face();};
void() phoenix_xattb2  = [   $xattb2,    phoenix_xattb3  ] {ai_face();};
void() phoenix_xattb3  = [   $xattb3,    phoenix_xattb4  ] {ai_face();};
void() phoenix_xattb4  = [   $xattb4,    phoenix_xattb5  ] {ai_face();};
void() phoenix_xattb5  = [   $xattb5,    phoenix_xattb6  ] {ai_face();};
void() phoenix_xattb6  = [   $xattb6,    phoenix_xattb7  ] {ai_face();};
void() phoenix_xattb7  = [   $xattb7,    phoenix_xattb8  ] {ai_face();};
void() phoenix_xattb8  = [   $xattb8,    phoenix_xattb9  ]
{
   // hurt enemy
   T_Damage(self.enemy, self, self, 10);
   self.enemy.punchangle_x = -8;

   self.last_special2 = time;
};
void() phoenix_xattb9  = [   $xattb9,    phoenix_xattb10 ] {};
void() phoenix_xattb10 = [   $xattb10,   phoenix_xattb11 ] {};
void() phoenix_xattb11 = [   $xattb11,   phoenix_xattb12 ] {};
void() phoenix_xattb12 = [   $xattb12,   phoenix_run1    ] {};

void() TractorParticleThink =
{
   local float dist, r;
   local vector   vect;

   if (!(self.owner.enemy.x_flags & X_TRACTOR_BEAM_HOLD)) {
      setmodel(self, "");
      self.nextthink = -1;
      return;
   }

   vect = self.owner.enemy.origin - self.owner.origin;
   dist = vlen(vect);
   vect = normalize(vect);

   self.t_length = self.t_length + self.speed * (time - self.last_special);
   if (self.t_length >= dist - 48)
      self.t_length = 0;

   if (self == self.owner.flame_ent2)  // rotate in other direction
      self.angles_z = anglemod(self.angles_z - self.speed * (time - self.last_special));
   else
      self.angles_z = anglemod(self.angles_z + self.speed * (time - self.last_special));

   self.z_ofs = self.z_ofs + self.z_ofs_vel;
   if ((self.z_ofs <= -30) || (self.z_ofs >= 30)) {
      self.z_ofs = -1 * self.z_ofs;
   }


   makevectors(self.angles);
   setorigin(self, self.owner.origin + vect * self.t_length + v_up * self.z_ofs);

   // random colored particle
//   r = random() * 3.9;
//   r = floor(r);
   particle(self.origin, vect * 10, 241, 10 + r*5);

   self.last_special = time;
   self.nextthink = time + 0.05;
};

void() PhoenixStartBeam =
{
   // if player is already in a beam, abort attack
   if (self.enemy.x_flags & X_TRACTOR_BEAM_HOLD) {
      self.th_run();
      return;
   }

   self.flags = self.flags | FL_GODMODE;

   sound(self.enemy, CHAN_WEAPON, "items/damage3.wav", 1, ATTN_NORM);

   self.last_special = time;

   self.enemy.x_flags = self.enemy.x_flags | X_TRACTOR_BEAM_HOLD;
   self.enemy.tractor_vel = '0 0 10';
   setorigin(self.enemy, self.enemy.origin + '0 0 1');
   self.enemy.flags = self.enemy.flags - (self.enemy.flags & FL_ONGROUND);

   self.start_tractor_time = time;
   self.enemy.start_tractor_time = time;

   setmodel(self.flame_ent1, "progs/beampart.mdl");
   setmodel(self.flame_ent2, "progs/beampart.mdl");
   setmodel(self.flame_ent3, "progs/beampart.mdl");

   setorigin(self.flame_ent1, self.origin);
   setorigin(self.flame_ent2, self.origin);
   setorigin(self.flame_ent3, self.origin);

   self.flame_ent1.nextthink = time + 0.05;
   self.flame_ent2.nextthink = time + 0.05;
   self.flame_ent3.nextthink = time + 0.05;

   // speed to travel
   self.flame_ent1.speed = 800;
   self.flame_ent2.speed = 400;
   self.flame_ent3.speed = 200;

   // distance from Phoenix
   self.flame_ent1.t_length = 0;
   self.flame_ent2.t_length = 0;
   self.flame_ent3.t_length = 0;

   // distance from center of tractor beam
   self.flame_ent1.z_ofs = 10;
   self.flame_ent2.z_ofs = 5;
   self.flame_ent3.z_ofs = 0;

   // 1 = travelling away from center, -1 = travelling towards center
   self.flame_ent1.z_ofs_vel = -2;
   self.flame_ent2.z_ofs_vel =  2.5;
   self.flame_ent3.z_ofs_vel =  1;
};

void() phoenix_xattc9;
void() PhoenixBeamThink =
{
   self.enemy.tractor_vel_z = self.enemy.tractor_vel_z + 50;
   if (self.enemy.tractor_vel_z > 100)
      self.enemy.tractor_vel_z = 100;

/*
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
   WriteEntity (MSG_BROADCAST, self.enemy);
   WriteCoord (MSG_BROADCAST, self.enemy.origin_x);
   WriteCoord (MSG_BROADCAST, self.enemy.origin_y);
   WriteCoord (MSG_BROADCAST, self.enemy.origin_z);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
*/

   traceline(self.origin, self.enemy.origin, TRUE, self);

   if ((self.start_tractor_time < (time - 3)) || (trace_fraction < 1)) {
      phoenix_xattc9();
   }
};

void() PhoenixBeamEnd =
{
   self.enemy.x_flags = self.enemy.x_flags - (self.enemy.x_flags & X_TRACTOR_BEAM_HOLD);
   self.enemy.velocity = normalize(self.enemy.origin - self.origin) * 250 + '0 0 100';

   // hurt enemy
   T_Damage(self.enemy, self, self, 10);
   self.enemy.punchangle_x = -8;

   self.flags = self.flags - (self.flags & FL_GODMODE);
};

void() phoenix_xattc1  = [   $xattc1,    phoenix_xattc2  ] {ai_face(); self.start_attack_health = self.health;};
void() phoenix_xattc2  = [   $xattc2,    phoenix_xattc3  ] {ai_face(); self.nextthink = time + 0.2;};
void() phoenix_xattc3  = [   $xattc3,    phoenix_xattc4  ] {ai_face(); self.nextthink = time + 0.2;};
void() phoenix_xattc4  = [   $xattc4,    phoenix_xattc5  ]
{
   ai_face();
   if (self.start_attack_health == self.health)
      PhoenixStartBeam();
   else
      // 20060704 LordHavoc: hushed a compiler warning by changing self.th_run; to self.th_run();
      self.th_run();
};
void() phoenix_xattc5  = [   $xattc5,    phoenix_xattc6  ] {PhoenixBeamThink();};
void() phoenix_xattc6  = [   $xattc6,    phoenix_xattc7  ] {PhoenixBeamThink();};
void() phoenix_xattc7  = [   $xattc7,    phoenix_xattc8  ] {PhoenixBeamThink();};
void() phoenix_xattc8  = [   $xattc8,    phoenix_xattc5  ] {PhoenixBeamThink();};
void() phoenix_xattc9  = [   $xattc9,    phoenix_xattc10 ] {};
void() phoenix_xattc10 = [   $xattc10,   phoenix_xattc11 ] {};
void() phoenix_xattc11 = [   $xattc11,   phoenix_xattc12 ] {};
void() phoenix_xattc12 = [   $xattc12,   phoenix_xattc13 ] {PhoenixBeamEnd();};
void() phoenix_xattc13 = [   $xattc13,   phoenix_xattc14 ] {};
void() phoenix_xattc14 = [   $xattc14,   phoenix_xattc15 ] {};
void() phoenix_xattc15 = [   $xattc15,   phoenix_xattc16 ] {};
void() phoenix_xattc16 = [   $xattc16,   phoenix_xattc17 ] {};
void() phoenix_xattc17 = [   $xattc17,   phoenix_run1    ] {};

void() PhoenixMissile =
{
   local float rnd;

   rnd = random();
   if ((rnd < 0.3) && (self.last_special2 < (time - 6)))
      phoenix_xattb1();
   else if ((vlen(self.origin - self.enemy.origin) > 128) && (rnd < 0.8) && (self.last_special < (time - 4)))
      phoenix_xattc1();
   else
      phoenix_xatta1();
};

//============================================================================

void() monster_shalrath =
{
   remove(self);
   return;
};

void() xmen_phoenix =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model ("progs/phoenix.mdl");
   precache_model ("progs/psyblast.mdl");

   // XMen matched ID sounds
   precache_sound ("items/protect3.wav");

   precache_sound ("items/damage3.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/phoenix.mdl");

   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   self.health = 180 + cvar("skill")*10;

   self.th_stand = phoenix_stand1;
   self.th_walk = phoenix_walk1;
   self.th_run = phoenix_run1;
   self.th_pain = PhoenixPain;
   self.th_die = PhoenixDie;
   self.th_missile = PhoenixMissile;

   self.th_guard = phoenix_guard1;

   walkmonster_start();

   precache_model("progs/beampart.mdl");

   // create beam entities
   self.flame_ent1 = spawn();
   self.flame_ent2 = spawn();
   self.flame_ent3 = spawn();

   self.flame_ent1.think = TractorParticleThink;
   self.flame_ent2.think = TractorParticleThink;
   self.flame_ent3.think = TractorParticleThink;

   self.flame_ent1.owner = self;
   self.flame_ent2.owner = self;
   self.flame_ent3.owner = self;
};