/*
==============================================================================

Rogue

==============================================================================
*/
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12

$frame deata1 deata2 deata3 deata4 deata5 deata6 deata7 deata8 deata9 deata10
$frame deata11 deata12

$frame punch1 punch2 punch3 punch4 punch5 punch6 punch7 punch8
$frame punch9 punch10 punch11 punch12

$frame atta1 atta2 atta3 atta4 atta5 atta6 atta7 atta8
$frame atta9 atta10 atta11 atta12

//=====================================================================

void() rogue_stand1   = [   $stand1,   rogue_stand2   ] {ai_stand();};
void() rogue_stand2   = [   $stand2,   rogue_stand3   ] {ai_stand();};
void() rogue_stand3   = [   $stand3,   rogue_stand4   ] {ai_stand();};
void() rogue_stand4   = [   $stand4,   rogue_stand5   ] {ai_stand();};
void() rogue_stand5   = [   $stand5,   rogue_stand6   ] {ai_stand();};
void() rogue_stand6   = [   $stand6,   rogue_stand7   ] {ai_stand();};
void() rogue_stand7   = [   $stand7,   rogue_stand8   ] {ai_stand();};
void() rogue_stand8   = [   $stand8,   rogue_stand9   ] {ai_stand();};
void() rogue_stand9   = [   $stand9,   rogue_stand10  ] {ai_stand();};
void() rogue_stand10  = [   $stand10,  rogue_stand11  ] {ai_stand();};
void() rogue_stand11  = [   $stand11,  rogue_stand12  ] {ai_stand();};
void() rogue_stand12  = [   $stand12,  rogue_stand13  ] {ai_stand();};
void() rogue_stand13  = [   $stand13,  rogue_stand1   ] {ai_stand();};

//=====================================================================

void() rogue_walk1    = [   $walk1,    rogue_walk2   ] {ai_walk(10);};
void() rogue_walk2    = [   $walk2,    rogue_walk3   ] {ai_walk(10);};
void() rogue_walk3    = [   $walk3,    rogue_walk4   ] {ai_walk(10);};
void() rogue_walk4    = [   $walk4,    rogue_walk5   ] {ai_walk(10);};
void() rogue_walk5    = [   $walk5,    rogue_walk6   ] {ai_walk(10);};
void() rogue_walk6    = [   $walk6,    rogue_walk7   ] {ai_walk(10);};
void() rogue_walk7    = [   $walk7,    rogue_walk8   ] {ai_walk(10);};
void() rogue_walk8    = [   $walk8,    rogue_walk9   ] {ai_walk(10);};
void() rogue_walk9    = [   $walk9,    rogue_walk10  ] {ai_walk(10);};
void() rogue_walk10   = [   $walk10,   rogue_walk11  ] {ai_walk(10);};
void() rogue_walk11   = [   $walk11,   rogue_walk12  ] {ai_walk(10);};
void() rogue_walk12   = [   $walk12,   rogue_walk13  ] {ai_walk(10);};
void() rogue_walk13   = [   $walk13,   rogue_walk1   ] {ai_walk(10);};

//=====================================================================

void() rogue_run1    = [   $run1,    rogue_run2   ] {ai_run(15);};
void() rogue_run2    = [   $run2,    rogue_run3   ] {ai_run(15);};
void() rogue_run3    = [   $run3,    rogue_run4   ] {ai_run(15);};
void() rogue_run4    = [   $run4,    rogue_run5   ] {ai_run(15);};
void() rogue_run5    = [   $run5,    rogue_run6   ] {ai_run(15);};
void() rogue_run6    = [   $run6,    rogue_run7   ] {ai_run(15);};
void() rogue_run7    = [   $run7,    rogue_run8   ] {ai_run(15);};
void() rogue_run8    = [   $run8,    rogue_run9   ] {ai_run(15);};
void() rogue_run9    = [   $run9,    rogue_run10  ] {ai_run(15);};
void() rogue_run10   = [   $run10,   rogue_run11  ] {ai_run(15);};
void() rogue_run11   = [   $run11,   rogue_run12  ] {ai_run(15);};
void() rogue_run12   = [   $run12,   rogue_run1   ] {ai_run(15);};

//=====================================================================

void() rogue_pain1    = [   $pain1,    rogue_pain2   ] {};
void() rogue_pain2    = [   $pain2,    rogue_pain3   ] {};
void() rogue_pain3    = [   $pain3,    rogue_pain4   ] {};
void() rogue_pain4    = [   $pain4,    rogue_pain5   ] {};
void() rogue_pain5    = [   $pain5,    rogue_pain6   ] {};
void() rogue_pain6    = [   $pain6,    rogue_run1    ] {};

void() rogue_pain =
{
   if (self.pain_finished > time)
      return;

   // play a sound here
   FemalePainSound();

   self.pain_finished = time + 2.5;
   rogue_pain1();
};

//=====================================================================

void() rogue_death1    = [   $death1,    rogue_death2   ] {};
void() rogue_death2    = [   $death2,    rogue_death3   ] {};
void() rogue_death3    = [   $death3,    rogue_death4   ] {self.solid = SOLID_NOT;};
void() rogue_death4    = [   $death4,    rogue_death5   ] {};
void() rogue_death5    = [   $death5,    rogue_death6   ] {};
void() rogue_death6    = [   $death6,    rogue_death7   ] {};
void() rogue_death7    = [   $death7,    rogue_death8   ] {};
void() rogue_death8    = [   $death8,    rogue_death9   ] {};
void() rogue_death9    = [   $death9,    rogue_death10  ] {};
void() rogue_death10   = [   $death10,   rogue_death11  ] {};
void() rogue_death11   = [   $death11,   rogue_death12  ] {};
void() rogue_death12   = [   $death12,   rogue_death12  ] {if (self.angles_x != 0) AngelPitch();};

void() rogue_deata1    = [   $deata1,    rogue_deata2   ] {};
void() rogue_deata2    = [   $deata2,    rogue_deata3   ] {};
void() rogue_deata3    = [   $deata3,    rogue_deata4   ] {self.solid = SOLID_NOT;};
void() rogue_deata4    = [   $deata4,    rogue_deata5   ] {};
void() rogue_deata5    = [   $deata5,    rogue_deata6   ] {};
void() rogue_deata6    = [   $deata6,    rogue_deata7   ] {};
void() rogue_deata7    = [   $deata7,    rogue_deata8   ] {};
void() rogue_deata8    = [   $deata8,    rogue_deata9   ] {};
void() rogue_deata9    = [   $deata9,    rogue_deata10  ] {};
void() rogue_deata10   = [   $deata10,   rogue_deata11  ] {};
void() rogue_deata11   = [   $deata11,   rogue_deata12  ] {};
void() rogue_deata12   = [   $deata12,   rogue_deata12  ] {if (self.angles_x != 0) AngelPitch();};

void() rogue_die =
{

   FemaleDeathSound();

   self.velocity_x = -200 + 400*random();
   self.velocity_y = -200 + 400*random();
   self.velocity_z = 100 + 100*random();
   self.flags = self.flags - (self.flags & FL_ONGROUND);
   self.enemy = world;

   if (random() < 0.5)
      rogue_death1 ();
   else
      rogue_deata1 ();

};

//=====================================================================

void() rogue_punch4;
float(float move_dist) RogueCheckPunch =
{
   ai_face();

   if (!ai_forward(move_dist)) {        // abort
      self.think = self.th_run;
      return FALSE;
   }

   self.nextthink = time + 0.05;

   if (!infront(self.enemy)) {      // abort attack
      self.think = self.th_run;
      return FALSE;
   }

   if (vlen(self.enemy.origin - self.origin) > 96)
      return FALSE;

   // striking distance!
   return TRUE;
};

void() RoguePunchPosition =
{
   local float   distance1;

   distance1 = vlen(self.enemy.origin - self.origin);
   ai_back(5);
};

void() rogue_punch1    = [   $punch1,    rogue_punch2   ] {RoguePunchPosition(); self.attack_finished = time + 4;};
void() rogue_punch2    = [   $punch2,    rogue_punch3   ] {RoguePunchPosition();};
void() rogue_punch3    = [   $punch3,    rogue_punch3   ] {if (RogueCheckPunch(35)) rogue_punch4();};
void() rogue_punch4    = [   $punch4,    rogue_punch5   ] {ai_forward(15); ai_face();};
void() rogue_punch5    = [   $punch5,    rogue_punch6   ] {ai_forward(12); ai_face();};
void() rogue_punch6    = [   $punch6,    rogue_punch7   ] {ai_forward(8); ai_face();};
void() rogue_punch7    = [   $punch7,    rogue_punch8   ]
{
   local vector   vect;

   if (RogueCheckPunch(0)) {
      // hit em
      sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);

      T_Damage(self.enemy, self, self, 25);

      vect = normalize(self.enemy.origin - self.origin);
      self.enemy.velocity = vect * 300;
      self.enemy.velocity_z = 300;
      self.enemy.punchangle_x = -15;
   }
};
void() rogue_punch8    = [   $punch8,    rogue_punch9   ] {};
void() rogue_punch9    = [   $punch9,    rogue_punch10  ] {};
void() rogue_punch10   = [   $punch10,   rogue_punch11  ] {};
void() rogue_punch11   = [   $punch11,   rogue_punch12  ] {};
void() rogue_punch12   = [   $punch12,   rogue_run1     ] {};

//=================================================================

void() rogue_atta1    = [   $atta1,    rogue_atta2   ]
{
   ai_face();
   if (vlen(self.enemy.origin - self.origin) < 64)
      ai_forward(-10);
};
void() rogue_atta2    = [   $atta2,    rogue_atta3   ] {ai_face();};
void() rogue_atta3    = [   $atta3,    rogue_atta4   ] {ai_face();};
void() rogue_atta4    = [   $atta4,    rogue_atta5   ] {ai_face();};
void() rogue_atta5    = [   $atta5,    rogue_atta6   ] {ai_face();};
void() rogue_atta6    = [   $atta6,    rogue_atta7   ] {ai_face();};
void() rogue_atta7    = [   $atta7,    rogue_atta8   ]
{
   ai_face();

   if (RogueCheckPunch(0)) {
      sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
      self.enemy.punchangle_x = -7;
      T_Damage(self.enemy, self, self, 10);
   }
};
void() rogue_atta8    = [   $atta8,    rogue_atta9   ] {ai_face();};
void() rogue_atta9    = [   $atta9,    rogue_atta10  ] {ai_face();};
void() rogue_atta10   = [   $atta10,   rogue_atta11  ] {ai_face();};
void() rogue_atta11   = [   $atta11,   rogue_atta12  ] {ai_face();};
void() rogue_atta12   = [   $atta12,   rogue_run1  ] {ai_face();};

//=================================================================

/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void() monster_ogre =
{
   remove(self);
};

void() xmen_rogue =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }

   precache_model ("progs/rogue.mdl");

   precache_sound ("generic/punch2.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/rogue.mdl");
   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   self.health = 210 + cvar("skill")*10;

   self.yaw_speed = 10;

   self.th_stand = rogue_stand1;
   self.th_walk = rogue_walk1;
   self.th_run = rogue_run1;
   self.th_die = rogue_die;
   self.th_pain = rogue_pain;
   self.th_melee = rogue_atta1;
   self.th_missile = rogue_punch1;

   self.think = flymonster_start;
   self.nextthink = time + 0.1 + random ()*0.1;
};