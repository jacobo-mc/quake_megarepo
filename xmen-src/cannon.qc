/*==========================================================================

   CANNONBALL

==========================================================================*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26 paina27 paina28 paina29

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16

$frame atta1 atta2 atta3 atta4 atta5 atta6 atta7 atta8 atta9


$frame xatta1 xatta2 xatta3 xatta4 xatta5
$frame xatta24 xatta25 xatta26 xatta27


void() cannon_stand1  = [   $stand1,    cannon_stand2  ] {ai_stand();};
void() cannon_stand2  = [   $stand2,    cannon_stand3  ] {ai_stand();};
void() cannon_stand3  = [   $stand3,    cannon_stand4  ] {ai_stand();};
void() cannon_stand4  = [   $stand4,    cannon_stand5  ] {ai_stand();};
void() cannon_stand5  = [   $stand5,    cannon_stand6  ] {ai_stand();};
void() cannon_stand6  = [   $stand6,    cannon_stand7  ] {ai_stand();};
void() cannon_stand7  = [   $stand7,    cannon_stand8  ] {ai_stand();};
void() cannon_stand8  = [   $stand8,    cannon_stand9  ] {ai_stand();};
void() cannon_stand9  = [   $stand9,    cannon_stand10 ] {ai_stand();};
void() cannon_stand10 = [   $stand10,   cannon_stand11 ] {ai_stand();};
void() cannon_stand11 = [   $stand11,   cannon_stand12 ] {ai_stand();};
void() cannon_stand12 = [   $stand12,   cannon_stand13 ] {ai_stand();};
void() cannon_stand13 = [   $stand13,   cannon_stand1  ] {ai_stand();};

void() cannon_walk1  = [   $walk1,    cannon_walk2  ] {ai_walk(6);};
void() cannon_walk2  = [   $walk2,    cannon_walk3  ] {ai_walk(4);};
void() cannon_walk3  = [   $walk3,    cannon_walk4  ] {ai_walk(4);};
void() cannon_walk4  = [   $walk4,    cannon_walk5  ] {ai_walk(4);};
void() cannon_walk5  = [   $walk5,    cannon_walk6  ] {ai_walk(6);};
void() cannon_walk6  = [   $walk6,    cannon_walk7  ] {ai_walk(7);};
void() cannon_walk7  = [   $walk7,    cannon_walk8  ] {ai_walk(7);};
void() cannon_walk8  = [   $walk8,    cannon_walk9  ] {ai_walk(4);};
void() cannon_walk9  = [   $walk9,    cannon_walk10 ] {ai_walk(4);};
void() cannon_walk10 = [   $walk10,   cannon_walk11 ] {ai_walk(5);};
void() cannon_walk11 = [   $walk11,   cannon_walk12 ] {ai_walk(6);};
void() cannon_walk12 = [   $walk12,   cannon_walk1  ] {ai_walk(7);};

void() cannon_run1  = [   $run1,    cannon_run2  ] {ai_run(16);};
void() cannon_run2  = [   $run2,    cannon_run3  ] {ai_run(16);};
void() cannon_run3  = [   $run3,    cannon_run4  ] {ai_run(16);};
void() cannon_run4  = [   $run4,    cannon_run5  ] {ai_run(16);};
void() cannon_run5  = [   $run5,    cannon_run6  ] {ai_run(16);};
void() cannon_run6  = [   $run6,    cannon_run7  ] {ai_run(16);};
void() cannon_run7  = [   $run7,    cannon_run8  ] {ai_run(16);};
void() cannon_run8  = [   $run8,    cannon_run1  ] {ai_run(16);};

//============================================================================

void() cannon_pain1  = [   $pain1,    cannon_pain2  ] {};
void() cannon_pain2  = [   $pain2,    cannon_pain3  ] {};
void() cannon_pain3  = [   $pain3,    cannon_pain4  ] {};
void() cannon_pain4  = [   $pain4,    cannon_pain5  ] {};
void() cannon_pain5  = [   $pain5,    cannon_pain6  ] {};
void() cannon_pain6  = [   $pain6,    cannon_run1   ] {};

void() cannon_paina1  = [   $paina1,    cannon_paina2  ] {};
void() cannon_paina2  = [   $paina2,    cannon_paina3  ] {};
void() cannon_paina3  = [   $paina3,    cannon_paina4  ] {};
void() cannon_paina4  = [   $paina4,    cannon_paina5  ] {};
void() cannon_paina5  = [   $paina5,    cannon_paina6  ] {};
void() cannon_paina6  = [   $paina6,    cannon_paina7  ] {};
void() cannon_paina7  = [   $paina7,    cannon_paina8  ] {};
void() cannon_paina8  = [   $paina8,    cannon_paina9  ] {};
void() cannon_paina9  = [   $paina9,    cannon_paina10 ] {};
void() cannon_paina10 = [   $paina10,   cannon_paina11 ] {};
void() cannon_paina11 = [   $paina11,   cannon_paina12 ] {};
void() cannon_paina12 = [   $paina12,   cannon_paina13 ] {};
void() cannon_paina13 = [   $paina13,   cannon_paina14 ] {sound(self, CHAN_BODY, "cannon/flyloop.wav", 1, ATTN_NORM);};
void() cannon_paina14 = [   $paina14,   cannon_paina15 ] {};
void() cannon_paina15 = [   $paina15,   cannon_paina16 ] {};
void() cannon_paina16 = [   $paina16,   cannon_paina17 ] {};
void() cannon_paina17 = [   $paina17,   cannon_paina18 ] {};
void() cannon_paina18 = [   $paina18,   cannon_paina19 ] {};
void() cannon_paina19 = [   $paina19,   cannon_paina20 ] {};
void() cannon_paina20 = [   $paina20,   cannon_paina21 ] {};
void() cannon_paina21 = [   $paina21,   cannon_paina22 ] {};
void() cannon_paina22 = [   $paina22,   cannon_paina23 ] {};
void() cannon_paina23 = [   $paina23,   cannon_paina24 ] {};
void() cannon_paina24 = [   $paina24,   cannon_paina25 ] {};
void() cannon_paina25 = [   $paina25,   cannon_paina26 ] {};
void() cannon_paina26 = [   $paina26,   cannon_paina27 ] {};
void() cannon_paina27 = [   $paina27,   cannon_paina28 ] {};
void() cannon_paina28 = [   $paina28,   cannon_paina29 ] {};
void() cannon_paina29 = [   $paina29,   cannon_run1    ] {};

void(entity attacker, float damage) CannonPain =
{
   if (self.pain_finished > time)
      return;

   MalePainSound(2);

   if (self.model != "progs/cannon1.mdl")
      return;

   if (self.health <= 0)
      return;

   if ((damage > 10) && (random() < 0.4)) {
      self.pain_finished = time + 3;
      cannon_paina1();
   }
   else {
      self.pain_finished = time + 3;
      cannon_pain1();
   }
};

//============================================================================

void() cannon_death1  = [   $death1,    cannon_death2  ] {};
void() cannon_death2  = [   $death2,    cannon_death3  ] {};
void() cannon_death3  = [   $death3,    cannon_death4  ] {self.solid = SOLID_NOT;};
void() cannon_death4  = [   $death4,    cannon_death5  ] {};
void() cannon_death5  = [   $death5,    cannon_death6  ] {};
void() cannon_death6  = [   $death6,    cannon_death7  ] {};
void() cannon_death7  = [   $death7,    cannon_death8  ] {};
void() cannon_death8  = [   $death8,    cannon_death9  ] {};
void() cannon_death9  = [   $death9,    cannon_death10 ] {};
void() cannon_death10 = [   $death10,   cannon_death11 ] {};
void() cannon_death11 = [   $death11,   cannon_death12 ] {};
void() cannon_death12 = [   $death12,   cannon_death13 ] {};
void() cannon_death13 = [   $death13,   cannon_death14 ] {};
void() cannon_death14 = [   $death14,   cannon_death15 ] {};
void() cannon_death15 = [   $death15,   cannon_death16 ] {};
void() cannon_death16 = [   $death16,   cannon_death16 ] {if (self.angles_x != 0) AngelPitch();};

void() cannon_xatta24;
void() CannonDie =
{
   if (self.model != "progs/cannon1.mdl") {
      cannon_xatta24();
      return;
   }

   MaleDeathSound(2);

   cannon_death1();
};

//============================================================================

void() CannonPunch =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;

   if (!infront(self.enemy))
      return;

   if (vlen(self.enemy.origin - self.origin) > 64)
      return;

   T_Damage(self.enemy, self, self, 15);

   self.enemy.punchangle_x = -15;
};

void() cannon_atta1  = [   $atta1,    cannon_atta2  ] {ai_charge(4);};
void() cannon_atta2  = [   $atta2,    cannon_atta3  ] {ai_charge(4);sound (self, CHAN_WEAPON, "generic/swing1.wav", 1, ATTN_NORM);};
void() cannon_atta3  = [   $atta3,    cannon_atta4  ] {ai_charge(4);};
void() cannon_atta4  = [   $atta4,    cannon_atta5  ] {ai_charge(4);CannonPunch();};
void() cannon_atta5  = [   $atta5,    cannon_atta6  ] {};
void() cannon_atta6  = [   $atta6,    cannon_atta7  ] {};
void() cannon_atta7  = [   $atta7,    cannon_atta8  ] {};
void() cannon_atta8  = [   $atta8,    cannon_atta9  ] {};
void() cannon_atta9  = [   $atta9,    cannon_run1   ] {};

//============================================================================

void() xmen_cannonball;

void() cannon_xatta1  = [   $xatta1,    cannon_xatta2  ] {sound(self, CHAN_ITEM, "cannon/takeoff.wav", 1, ATTN_NORM); self.flags = self.flags | FL_GODMODE;};
void() cannon_xatta2  = [   $xatta2,    cannon_xatta3  ] {};
void() cannon_xatta3  = [   $xatta3,    cannon_xatta4  ] {};
void() cannon_xatta4  = [   $xatta4,    cannon_xatta5  ] {sound(self, CHAN_BODY, "cannon/flyloop.wav", 1, ATTN_NORM);};
void() cannon_xatta5  = [   $xatta5,    cannon_xatta7  ] {self.flags = self.flags | FL_FLY; self.yaw_speed = 8;};

/* see cannon2.qc for flying attack frames */

void() cannon_xatta24 = [   $xatta24,   cannon_xatta25 ]
{
   setmodel(self, "progs/cannon1.mdl");
   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   setorigin(self, self.origin + '0 0 1');

   self.flags = self.flags - FL_FLY;
   self.flags = self.flags - (self.flags & FL_ONGROUND);

   self.angles_x = 0;
   self.angles_z = 0;
};
void() cannon_xatta25 = [   $xatta25,   cannon_xatta26 ] {};
void() cannon_xatta26 = [   $xatta26,   cannon_xatta27 ] {};
void() cannon_xatta27 = [   $xatta27,   cannon_xatta27 ]
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   new, oself;

   if (self.origin == self.oldorigin) {

/*
      new = spawn();
      new.classname = "xmen_cannonball";
      new.health = 99;
      setorigin(new, self.origin);
      new.angles = self.angles;

      self.solid = SOLID_NOT;

      oself = self;
      self = new;
      xmen_cannonball();
      walkmonster_start_go();
      self = oself;

      new.last_special = self.last_special;
      new.frame = self.frame;

      new.health = self.health;
      new.pausetime = 0;
      new.enemy = new.goalentity = self.enemy;

      remove(self);

      self = new;
*/

      setmodel (self, "progs/cannon1.mdl");
      setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

      self.flags = self.flags - (self.flags & FL_GODMODE);

      self.th_run();
   }
   else {
      self.oldorigin = self.origin;
   }
};

//============================================================================

void() CannonCheckSpecial =
{
   if (self.last_special < (time - 8))
      cannon_xatta1();
};

void() xmen_cannonball =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }

   if (self.health == 0) {
      // Xmen Sounds: matched ID sounds
//      precache_sound ("boss1/throw.wav");

      precache_sound ("cannon/takeoff.wav");
      precache_sound ("cannon/flyloop.wav");
      precache_sound ("generic/swing1.wav");
      precache_sound ("generic/punch2.wav");
      precache_sound ("generic/crash1.wav");

      precache_model ("progs/cannon1.mdl");
      precache_model ("progs/cannon2.mdl");
   }

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/cannon1.mdl");
   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   self.health = 120 + cvar("skill")*10;

   self.yaw_speed = 20;

   self.th_stand = cannon_stand1;
   self.th_walk = cannon_walk1;
   self.th_run = cannon_run1;
   self.th_die = CannonDie;
   self.th_pain = CannonPain;
   self.th_melee = cannon_atta1;
   self.th_missile = CannonCheckSpecial;

   self.think = walkmonster_start;
   self.nextthink = time + 0.1 + random ()*0.1;
};