/*
==============================================================================

Gambit

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18

$frame jump1 jump2 jump3 jump4 jump5 jump6 jump7 jump8 jump9 jump10
$frame jump11 jump12 jump13 jump14

$frame satta1 satta2 satta3 satta4 satta5 satta6 satta7 satta8
$frame satta9 satta10 satta11 satta12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8 xatta9 xatta10
$frame xatta11 xatta12 xatta13 xatta14

$frame xattb1 xattb2 xattb3 xattb4 xattb5 xattb6 xattb7 xattb8 xattb9 xattb10
$frame xattb11 xattb12

void()	gambit_stand1	=[	$stand1,	gambit_stand2	] {ai_stand();};
void()	gambit_stand2	=[	$stand2,	gambit_stand3	] {ai_stand();};
void()	gambit_stand3	=[	$stand3,	gambit_stand4	] {ai_stand();};
void()	gambit_stand4	=[	$stand4,	gambit_stand5	] {ai_stand();};
void()	gambit_stand5	=[	$stand5,	gambit_stand6	] {ai_stand();};
void()	gambit_stand6	=[	$stand6,	gambit_stand7	] {ai_stand();};
void()	gambit_stand7	=[	$stand7,	gambit_stand8	] {ai_stand();};
void()	gambit_stand8	=[	$stand8,	gambit_stand9	] {ai_stand();};
void()	gambit_stand9	=[	$stand9,	gambit_stand10 ] {ai_stand();};
void()   gambit_stand10 =[ $stand10, gambit_stand11 ] {ai_stand();};
void()   gambit_stand11 =[ $stand11, gambit_stand12 ] {ai_stand();};
void()   gambit_stand12 =[ $stand12, gambit_stand13 ] {ai_stand();};
void()   gambit_stand13 =[ $stand13, gambit_stand1 ] {ai_stand();};

//===========================================================================

void()	gambit_walk1	=[	$walk1,		gambit_walk2	] {ai_walk(5);};
void()	gambit_walk2	=[	$walk2,		gambit_walk3	] {ai_walk(5);};
void()	gambit_walk3	=[	$walk3,		gambit_walk4	] {ai_walk(4);};
void()	gambit_walk4	=[	$walk4,		gambit_walk5	] {ai_walk(4);};
void()	gambit_walk5	=[	$walk5,		gambit_walk6	] {ai_walk(4);};
void()	gambit_walk6	=[	$walk6,		gambit_walk7	] {ai_walk(5);};
void()	gambit_walk7	=[	$walk7,		gambit_walk8	] {ai_walk(6);};
void()	gambit_walk8	=[	$walk8,		gambit_walk9	] {ai_walk(6);};
void()	gambit_walk9	=[	$walk9,		gambit_walk10	] {ai_walk(4);};
void()	gambit_walk10	=[	$walk10,	gambit_walk11	] {ai_walk(4);};
void()	gambit_walk11	=[	$walk11,	gambit_walk12	] {ai_walk(4);};
void()	gambit_walk12	=[	$walk12,	gambit_walk1	] {ai_walk(4);};

//===========================================================================

void()	gambit_run1	=[	$run1,		gambit_run2	] {ai_run (20);};
void()	gambit_run2	=[	$run2,		gambit_run3	] {ai_run(25);};
void()	gambit_run3	=[	$run3,		gambit_run4	] {ai_run(18);};
void()	gambit_run4	=[	$run4,		gambit_run5	] {ai_run(16);};
void()	gambit_run5	=[	$run5,		gambit_run6	] {ai_run(14);};
void()	gambit_run6	=[	$run6,		gambit_run7	] {ai_run(25);};
void()	gambit_run7	=[	$run7,		gambit_run8	] {ai_run(21);};
void()	gambit_run8	=[	$run8,		gambit_run1	] {ai_run(13);};

void()   gambit_jump1;
void()   gambit_jump12;
void() GambitJumpTouch =
{
   if (!checkbottom(self))
   {
      if (self.flags & FL_ONGROUND)
      {  // jump randomly to not get hung up
         self.touch = SUB_Null;
         self.think = gambit_jump1;
         self.nextthink = time + 0.1;
      }
      return;  // not on ground yet
   }

   self.touch = SUB_Null;
   self.think = gambit_jump12;
   self.nextthink = time + 0.1;
};

void()   gambit_jump1 =[ $jump1,      gambit_jump2 ]
{
   makevectors(self.angles);
   self.velocity = v_forward * 300;
   self.velocity_z = 200;
   self.flags = self.flags - (self.flags & FL_ONGROUND);
   setorigin(self, self.origin + '0 0 1');

   self.touch = GambitJumpTouch;

   self.nextthink = time + 0.05;
};
void()   gambit_jump2 =[ $jump2,      gambit_jump3 ] {self.nextthink = time + 0.05;};
void()   gambit_jump3 =[ $jump3,      gambit_jump4 ] {self.nextthink = time + 0.05;};
void()   gambit_jump4 =[ $jump4,      gambit_jump5 ] {self.nextthink = time + 0.05;};
void()   gambit_jump5 =[ $jump5,      gambit_jump6 ] {self.nextthink = time + 0.05;};
void()   gambit_jump6 =[ $jump6,      gambit_jump7 ] {self.nextthink = time + 0.05;};
void()   gambit_jump7 =[ $jump7,      gambit_jump8 ] {self.nextthink = time + 0.05;};
void()   gambit_jump8 =[ $jump8,      gambit_jump9 ] {self.nextthink = time + 0.05;};
void()   gambit_jump9 =[ $jump9,      gambit_jump10 ] {self.nextthink = time + 0.05;};
void()   gambit_jump10 =[ $jump10,    gambit_jump11 ] {self.nextthink = time + 0.05;};
void()   gambit_jump11 =[ $jump11,    gambit_jump11 ] {self.nextthink = time + 0.05;};    // stay on this frame until landing
void()   gambit_jump12 =[ $jump12,    gambit_jump13 ] {ai_forward(10);};
void()   gambit_jump13 =[ $jump13,    gambit_jump14 ] {ai_forward(6);};
void()   gambit_jump14 =[ $jump14,    gambit_run1  ] {};

//============================================================================

void()	gambit_pain1	=[	$pain1,		gambit_pain2	] {};
void()	gambit_pain2	=[	$pain2,		gambit_pain3	] {};
void()	gambit_pain3	=[	$pain3,		gambit_pain4	] {};
void()	gambit_pain4	=[	$pain4,		gambit_pain5	] {};
void()   gambit_pain5  =[ $pain5,     gambit_pain6  ] {};
void()	gambit_pain6	=[	$pain6,		gambit_run1	] {};

void()   gambit_paina1  =[ $paina1,     gambit_paina2  ] {};
void()   gambit_paina2  =[ $paina2,     gambit_paina3  ] {};
void()   gambit_paina3  =[ $paina3,     gambit_paina4  ] {};
void()   gambit_paina4  =[ $paina4,     gambit_paina5  ] {};
void()   gambit_paina5  =[ $paina5,     gambit_paina6  ] {};
void()   gambit_paina6  =[ $paina6,     gambit_paina7  ] {};
void()   gambit_paina7  =[ $paina7,     gambit_paina8  ] {};
void()   gambit_paina8  =[ $paina8,     gambit_paina9  ] {};
void()   gambit_paina9  =[ $paina9,     gambit_paina10 ] {};
void()   gambit_paina10  =[ $paina10,     gambit_paina11  ] {};
void()   gambit_paina11  =[ $paina11,     gambit_paina12  ] {};
void()   gambit_paina12  =[ $paina12,     gambit_paina13  ] {};
void()   gambit_paina13  =[ $paina13,     gambit_paina14  ] {};
void()   gambit_paina14  =[ $paina14,     gambit_paina15  ] {};
void()   gambit_paina15  =[ $paina15,     gambit_paina16  ] {};
void()   gambit_paina16  =[ $paina16,     gambit_paina17  ] {};
void()   gambit_paina17  =[ $paina17,     gambit_paina18  ] {};
void()   gambit_paina18  =[ $paina18,     gambit_paina19  ] {};
void()   gambit_paina19  =[ $paina19,     gambit_paina20  ] {};
void()   gambit_paina20  =[ $paina20,     gambit_paina21  ] {};
void()   gambit_paina21  =[ $paina21,     gambit_paina22  ] {};
void()   gambit_paina22  =[ $paina22,     gambit_paina23  ] {};
void()   gambit_paina23  =[ $paina23,     gambit_paina24  ] {};
void()   gambit_paina24  =[ $paina24,     gambit_paina25  ] {};
void()   gambit_paina25  =[ $paina25,     gambit_paina26  ] {};
void()   gambit_paina26  =[ $paina26,     gambit_run1   ] {};

//============================================================================

void()	gambit_die1	=[	$death1,	gambit_die2	] {};
void()	gambit_die2	=[	$death2,	gambit_die3	] {};
void()	gambit_die3	=[	$death3,	gambit_die4	] {self.solid = SOLID_NOT;};
void()	gambit_die4	=[	$death4,	gambit_die5	] {};
void()	gambit_die5	=[	$death5,	gambit_die6	] {};
void()	gambit_die6	=[	$death6,	gambit_die7	] {};
void()	gambit_die7	=[	$death7,	gambit_die8	] {};
void()   gambit_die8 =[ $death8, gambit_die9 ] {};
void()   gambit_die9 =[ $death9, gambit_die10 ] {};
void()   gambit_die10 =[ $death10, gambit_die11 ] {};
void()	gambit_die11	=[	$death11,	gambit_die12	] {};
void()	gambit_die12	=[	$death12,	gambit_die13	] {};
void()	gambit_die13	=[	$death13,	gambit_die14	] {};
void()	gambit_die14	=[	$death14,	gambit_die15	] {};
void()	gambit_die15	=[	$death15,	gambit_die16	] {};
void()   gambit_die16   =[ $death16,   gambit_die17   ] {};
void()   gambit_die17   =[ $death17,   gambit_die18   ] {};
void()   gambit_die18   =[ $death18,   gambit_die18   ] {};

void() gambit_die =
{
   MaleDeathSound(2);
   gambit_die1 ();
};

//============================================================================


void(entity attacker, float damage)	gambit_pain =
{
	if (self.pain_finished > time)
		return;

   MalePainSound(2);

	if (time - self.pain_finished > 8)
	{	// always go into pain frame if it has been a while
		gambit_pain1 ();
		self.pain_finished = time + 3;
		return;
	}

   if (random() < 0.75) {
      self.pain_finished = time + 3;
      gambit_pain1 ();
   }
   else {
      self.pain_finished = time + 5;
      gambit_paina1 ();
   }
};

//============================================================================

void() GambitStrike =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;
   local float    damg;

   if (vlen(self.enemy.origin - self.origin) > 64)
      return;

   if (!infront(self.enemy))
      return;

   // hurt enemy
   damg = 15 + random() * 5;
   T_Damage(self.enemy, self, self, damg);
};

void() gambit_satta1 =[ $satta1, gambit_satta2  ] {ai_charge(4);};
void() gambit_satta2 =[ $satta2, gambit_satta3  ] {ai_charge(8);};
void() gambit_satta3 =[ $satta3, gambit_satta4  ] {ai_charge(8);};
void() gambit_satta4 =[ $satta4, gambit_satta5  ] {ai_charge(8);};
void() gambit_satta5 =[ $satta5, gambit_satta6  ] {ai_charge(4);};
void() gambit_satta6 =[ $satta6, gambit_satta7  ] {};
void() gambit_satta7 =[ $satta7, gambit_satta8  ] {GambitStrike();};
void() gambit_satta8 =[ $satta8, gambit_satta9  ] {};
void() gambit_satta9 =[ $satta9, gambit_satta10 ] {ai_forward(4);};
void() gambit_satta10 =[ $satta10, gambit_satta11 ] {ai_forward(8);};
void() gambit_satta11 =[ $satta11, gambit_satta12 ] {ai_forward(8);};
void() gambit_satta12 =[ $satta12, gambit_run1 ] {ai_forward(4);};

void() gambit_melee =
{
	sound (self, CHAN_WEAPON, "generic/swing1.wav", 1, ATTN_NORM);
   gambit_satta1 ();
};

//============================================================================

void(float  heading_ofs, float zofs) GambitCard =
{
   local vector   newangle, targ_vect, ofs;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   targ_vect = normalize(self.enemy.origin - self.origin);
   newangle  = vectoangles(targ_vect);
   newangle_y = anglemod(newangle_y + heading_ofs);
   newangle_x = -1 * newangle_x;

   makevectors(newangle);

   ofs = '0 0 0';
   ofs_z = zofs;
   launch_spike (self.origin + ofs + v_forward*14, v_forward);
   newmis.classname = "gambit_card";
   setmodel (newmis, "progs/card.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void() gambit_xatta1 =[ $xatta1, gambit_xatta2  ] {ai_forward(4);};
void() gambit_xatta2 =[ $xatta2, gambit_xatta3  ] {ai_forward(8);};
void() gambit_xatta3 =[ $xatta3, gambit_xatta4  ] {ai_forward(8);};
void() gambit_xatta4 =[ $xatta4, gambit_xatta5  ] {ai_forward(8);ai_face();};
void() gambit_xatta5 =[ $xatta5, gambit_xatta6  ] {ai_forward(10);ai_face();};
void() gambit_xatta6 =[ $xatta6, gambit_xatta7  ] {ai_forward(10);ai_face();};
void() gambit_xatta7 =[ $xatta7, gambit_xatta8  ] {ai_forward(10);ai_face();};
void() gambit_xatta8 =[ $xatta8, gambit_xatta9  ] {ai_forward(8);ai_face();};
void() gambit_xatta9 =[ $xatta9, gambit_xatta10 ] {ai_forward(8);sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);GambitCard(-5, 16);};
void() gambit_xatta10 =[ $xatta10, gambit_xatta11 ] {ai_forward(8);GambitCard( 0, 16);};
void() gambit_xatta11 =[ $xatta11, gambit_xatta12 ] {ai_forward(8);GambitCard( 5, 16);};
void() gambit_xatta12 =[ $xatta12, gambit_xatta13 ] {ai_forward(6);};
void() gambit_xatta13 =[ $xatta13, gambit_xatta14 ] {ai_forward(4);};
void() gambit_xatta14 =[ $xatta14, gambit_run1 ]    {ai_forward(2);};

void() gambit_xattb1 =[ $xattb1, gambit_xattb2  ] {ai_forward(-1);};
void() gambit_xattb2 =[ $xattb2, gambit_xattb3  ] {ai_forward(-1);sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);GambitCard(-6, 4);};
void() gambit_xattb3 =[ $xattb3, gambit_xattb4  ] {ai_forward(-3);GambitCard(-3, 4);};
void() gambit_xattb4 =[ $xattb4, gambit_xattb5  ] {ai_forward(-8);GambitCard( 0, 4);};
void() gambit_xattb5 =[ $xattb5, gambit_xattb6  ] {ai_forward(-10);GambitCard( 3, 4);};
void() gambit_xattb6 =[ $xattb6, gambit_xattb7  ] {ai_forward(-10);GambitCard( 6, 4);};
void() gambit_xattb7 =[ $xattb7, gambit_xattb8  ] {ai_forward(-10);};
void() gambit_xattb8 =[ $xattb8, gambit_xattb9  ] {ai_forward(-8);};
void() gambit_xattb9 =[ $xattb9, gambit_xattb10 ] {ai_forward(-8);};
void() gambit_xattb10 =[ $xattb10, gambit_xattb11 ] {ai_forward(-8);};
void() gambit_xattb11 =[ $xattb11, gambit_xattb12 ] {ai_forward(-4);};
void() gambit_xattb12 =[ $xattb12, gambit_run1 ] {};

void() gambit_special =
{
   if (self.last_special > (time - 2))
      return;

   self.last_special = time;

   // check head-room
   traceline(self.origin, self.origin + '0 0 54', TRUE, self);
   if (trace_fraction < 1)
      gambit_xatta1();
   else {
      if (random() < 0.5)
         gambit_xatta1();
      else
         gambit_xattb1();
   }

};

//============================================================================

float()  CheckGambitMelee =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector vect;

   if ((enemy_range == RANGE_MELEE) && (vlen(self.origin - self.enemy.origin) < 96))
   {  // FIXME: check canreach
      self.attack_state = AS_MELEE;
      return TRUE;
   }
   return FALSE;
};

/*
==============
CheckGambitSpecial

==============
*/
float()  CheckGambitSpecial =
{
   local vector   dist, p1, p2, vect;
   local float d;

   if (self.last_special > (time - 4)) {
      makevectors(self.angles);

      if (random() < 0.1) {      // jump if looking at player
         vect = normalize(self.enemy.origin - self.origin);
         if (vlen(v_forward - vect) < 0.5)
            gambit_jump1();
      }

      return FALSE;
   }

   // now, check line of sight (between p1 and p2)
   p1 = self.origin;
   p2 = self.enemy.origin;

   traceline(p1, p2, FALSE, self);

   if ((trace_fraction < 1) && (trace_ent != self.enemy))
      return FALSE;

   dist = self.enemy.origin - self.origin;
   dist_z = 0;

   d = vlen(dist);

   if (d < 100)
      return FALSE;

   if (d > 312)
      return FALSE;

   return TRUE;
};

float()  GambitCheckAttack =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vec;

// if close enough for slashing, go for it
   if (CheckGambitMelee ())
   {
      self.attack_state = AS_MELEE;
      return TRUE;
   }

   if (CheckGambitSpecial ())
   {
      self.attack_state = AS_MISSILE;
      return TRUE;
   }

   return FALSE;
};

//============================================================================

/*QUAKED monster_hell_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_hell_knight =
{
   remove(self);
};

void() xmen_gambit =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model2 ("progs/gambit1.mdl");
   precache_model2 ("progs/card.mdl");

   // Xmen Sounds: matched ID sounds
   precache_sound ("boss1/throw.wav");

   precache_sound ("generic/swing1.wav");

/*
   // Unmatched HKnight sounds
   precache_sound2 ("hknight/attack1.wav");
   precache_sound2 ("hknight/death1.wav");
   precache_sound2 ("hknight/pain1.wav");
   precache_sound2 ("hknight/sight1.wav");
   precache_sound  ("hknight/hit.wav");    // used by C code, so don't sound2
   precache_sound2 ("hknight/idle.wav");
   precache_sound2 ("hknight/grunt.wav");

   precache_sound ("knight/sword1.wav");
   precache_sound ("knight/sword2.wav");
*/

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/gambit1.mdl");

   setsize (self, '-16 -16 -24', '16 16 40');
   self.health = 120 + cvar("skill")*10;

   self.th_stand = gambit_stand1;
   self.th_walk = gambit_walk1;
   self.th_run = gambit_run1;
   self.th_melee = gambit_melee;
   self.th_missile = gambit_special;
   self.th_pain = gambit_pain;
   self.th_die = gambit_die;

   walkmonster_start ();
};
