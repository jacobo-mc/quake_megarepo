/*
==============================================================================

Psyloche

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26 paina27 paina28 paina29

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16

$frame jatta1 jatta2 jatta3 jatta4 jatta5 jatta6 jatta7 jatta8
$frame jatta9 jatta10 jatta11 jatta12

$frame jattb1 jattb2 jattb3 jattb4 jattb5 jattb6 jattb7 jattb8
$frame jattb9 jattb10 jattb11 jattb12

$frame satta1 satta2 satta3 satta4 satta5 satta6 satta7 satta8
$frame satta9 satta10 satta11 satta12

$frame sattb1 sattb2 sattb3 sattb4 sattb5 sattb6 sattb7 sattb8
$frame sattb9 sattb10 sattb11 sattb12

$frame sattc1 sattc2 sattc3 sattc4 sattc5 sattc6 sattc7 sattc8
$frame sattc9 sattc10 sattc11 sattc12

$frame sattd1 sattd2 sattd3 sattd4 sattd5 sattd6 sattd7 sattd8
$frame sattd9 sattd10 sattd11 sattd12

$frame xatt1 xatt2 xatt3 xatt4 xatt5 xatt6 xatt7 xatt8
$frame xatt9 xatt10 xatt11 xatt12

void()	knight_stand1	=[	$stand1,	knight_stand2	] {ai_stand();};
void()	knight_stand2	=[	$stand2,	knight_stand3	] {ai_stand();};
void()	knight_stand3	=[	$stand3,	knight_stand4	] {ai_stand();};
void()	knight_stand4	=[	$stand4,	knight_stand5	] {ai_stand();};
void()	knight_stand5	=[	$stand5,	knight_stand6	] {ai_stand();};
void()	knight_stand6	=[	$stand6,	knight_stand7	] {ai_stand();};
void()	knight_stand7	=[	$stand7,	knight_stand8	] {ai_stand();};
void()	knight_stand8	=[	$stand8,	knight_stand9	] {ai_stand();};
void()	knight_stand9	=[	$stand9,	knight_stand10	] {ai_stand();};
void()   knight_stand10 =[ $stand10, knight_stand11  ] {ai_stand();};
void()   knight_stand11 =[ $stand11, knight_stand12  ] {ai_stand();};
void()   knight_stand12 =[ $stand12, knight_stand13  ] {ai_stand();};
void()   knight_stand13 =[ $stand13, knight_stand1   ] {ai_stand();};

void()	knight_walk1	=[	$walk1,		knight_walk2	] {ai_walk(7);};
void()	knight_walk2	=[	$walk2,		knight_walk3	] {ai_walk(6);};
void()	knight_walk3	=[	$walk3,		knight_walk4	] {ai_walk(5);};
void()	knight_walk4	=[	$walk4,		knight_walk5	] {ai_walk(5);};
void()	knight_walk5	=[	$walk5,		knight_walk6	] {ai_walk(5);};
void()	knight_walk6	=[	$walk6,		knight_walk7	] {ai_walk(6);};
void()	knight_walk7	=[	$walk7,		knight_walk8	] {ai_walk(8);};
void()	knight_walk8	=[	$walk8,		knight_walk9	] {ai_walk(8);};
void()	knight_walk9	=[	$walk9,		knight_walk10	] {ai_walk(6);};
void()	knight_walk10	=[	$walk10,	   knight_walk11	] {ai_walk(5);};
void()	knight_walk11	=[	$walk11,	   knight_walk12	] {ai_walk(4);};
void()	knight_walk12	=[	$walk12,	   knight_walk1	] {ai_walk(5);};


void()	knight_run1	=[	$run1,		knight_run2	] {ai_run(24);};
void()	knight_run2	=[	$run2,		knight_run3	] {ai_run(30);};
void()	knight_run3	=[	$run3,		knight_run4	] {ai_run(20);};
void()	knight_run4	=[	$run4,		knight_run5	] {ai_run(13);};
void()	knight_run5	=[	$run5,		knight_run6	] {ai_run(22);};
void()	knight_run6	=[	$run6,		knight_run1	] {ai_run(30);};


void()	knight_runatk1	=[	$jatta1,		knight_runatk2	]
{
sound (self, CHAN_WEAPON, "voice/female/attack1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()	knight_runatk2	=[	$jatta2,	knight_runatk3	] {ai_charge_side();};
void()	knight_runatk3	=[	$jatta3,	knight_runatk4	] {ai_charge_side();};
void()	knight_runatk4	=[	$jatta4,	knight_runatk5	] {ai_charge_side();};
void()	knight_runatk5	=[	$jatta5,	knight_runatk6	] {ai_melee_side();};
void()	knight_runatk6	=[	$jatta6,	knight_runatk7	] {ai_melee_side();};
void()	knight_runatk7	=[	$jatta7,	knight_runatk8	] {ai_melee_side();};
void()	knight_runatk8	=[	$jatta8,	knight_runatk9	] {ai_melee_side();};
void()	knight_runatk9	=[	$jatta9,	knight_runatk10	] {ai_melee_side();};
void()	knight_runatk10	=[	$jatta10,	knight_runatk11 ] {ai_charge_side();};
void()	knight_runatk11	=[	$jatta11,	knight_runatk12 ] {ai_charge(10);};
void()   knight_runatk12   =[ $jatta12,  knight_run1 ] {ai_charge(10);};

void()   knight_runatkb1 =[ $jattb1,    knight_runatkb2 ]
{
if (random() > 0.5)
   sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
else
   sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void()   knight_runatkb2 =[ $jattb2, knight_runatkb3 ] {ai_charge_side();};
void()   knight_runatkb3 =[ $jattb3, knight_runatkb4 ] {ai_charge_side();};
void()   knight_runatkb4 =[ $jattb4, knight_runatkb5 ] {ai_charge_side();};
void()   knight_runatkb5 =[ $jattb5, knight_runatkb6 ] {ai_melee_side();};
void()   knight_runatkb6 =[ $jattb6, knight_runatkb7 ] {ai_melee_side();};
void()   knight_runatkb7 =[ $jattb7, knight_runatkb8 ] {ai_melee_side();};
void()   knight_runatkb8 =[ $jattb8, knight_runatkb9 ] {ai_melee_side();};
void()   knight_runatkb9 =[ $jattb9, knight_runatkb10   ] {ai_melee_side();};
void()   knight_runatkb10   =[ $jattb10,   knight_runatkb11 ] {ai_charge_side();};
void()   knight_runatkb11   =[ $jattb11,   knight_runatkb12 ] {ai_charge(10);};
void()   knight_runatkb12   =[ $jattb12,  knight_run1 ] {ai_charge(10);};

void()   knight_runattack =
{
   if (random() < 0.5)
      knight_runatk1();
   else
      knight_runatkb1();
};



void()	knight_atk1	=[	$satta1,		knight_atk2	]
{
sound (self, CHAN_WEAPON, "voice/female/attack1.wav", 1, ATTN_NORM);
ai_charge(0);};
void()	knight_atk2	=[	$satta2,		knight_atk3	] {ai_charge(7);};
void()	knight_atk3	=[	$satta3,		knight_atk4	] {ai_charge(4);};
void()	knight_atk4	=[	$satta4,		knight_atk5	] {ai_charge(0);};
void()	knight_atk5	=[	$satta5,		knight_atk6	] {ai_charge(3);};
void()	knight_atk6	=[	$satta6,		knight_atk7	] {ai_charge(4); ai_melee();};
void()	knight_atk7	=[	$satta7,		knight_atk8	] {ai_charge(1); ai_melee();};
void()	knight_atk8	=[	$satta8,		knight_atk9	] {ai_charge(3); ai_melee();};
void()	knight_atk9	=[	$satta9,		knight_atk10] {ai_charge(1);};
void()	knight_atk10=[	$satta10,		knight_atk11	] {ai_charge(5);};
void()   knight_atk11=[ $satta11,    knight_atk12 ] {ai_charge(5);};
void()   knight_atk12=[ $satta12,    knight_run1 ] {ai_charge(5);};

void()   knight_atkb1 =[ $sattb1,    knight_atkb2 ]
{
sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(0);};
void()   knight_atkb2 =[ $sattb2,    knight_atkb3 ] {ai_charge(7);};
void()   knight_atkb3 =[ $sattb3,    knight_atkb4 ] {ai_charge(4);};
void()   knight_atkb4 =[ $sattb4,    knight_atkb5 ] {ai_charge(0);};
void()   knight_atkb5 =[ $sattb5,    knight_atkb6 ] {ai_charge(3);};
void()   knight_atkb6 =[ $sattb6,    knight_atkb7 ] {ai_charge(4); ai_melee();};
void()   knight_atkb7 =[ $sattb7,    knight_atkb8 ] {ai_charge(1); ai_melee();};
void()   knight_atkb8 =[ $sattb8,    knight_atkb9 ] {ai_charge(3); ai_melee();};
void()   knight_atkb9 =[ $sattb9,    knight_atkb10] {ai_charge(1);};
void()   knight_atkb10=[ $sattb10,      knight_atkb11   ] {ai_charge(5);};
void()   knight_atkb11=[ $sattb11,    knight_atkb12 ] {ai_charge(5);};
void()   knight_atkb12=[ $sattb12,    knight_run1 ] {ai_charge(5);};

void()   knight_atkc1 =[ $sattc1,    knight_atkc2 ]
{
sound (self, CHAN_WEAPON, "voice/female/attack1.wav", 1, ATTN_NORM);
ai_charge(0);};
void()   knight_atkc2 =[ $sattc2,    knight_atkc3 ] {ai_charge(7);};
void()   knight_atkc3 =[ $sattc3,    knight_atkc4 ] {ai_charge(4);};
void()   knight_atkc4 =[ $sattc4,    knight_atkc5 ] {ai_charge(0);};
void()   knight_atkc5 =[ $sattc5,    knight_atkc6 ] {ai_charge(3);};
void()   knight_atkc6 =[ $sattc6,    knight_atkc7 ] {ai_charge(4); ai_melee();};
void()   knight_atkc7 =[ $sattc7,    knight_atkc8 ] {ai_charge(1); ai_melee();};
void()   knight_atkc8 =[ $sattc8,    knight_atkc9 ] {ai_charge(3); ai_melee();};
void()   knight_atkc9 =[ $sattc9,    knight_atkc10] {ai_charge(1);};
void()   knight_atkc10=[ $sattc10,      knight_atkc11   ] {ai_charge(5);};
void()   knight_atkc11=[ $sattc11,    knight_atkc12 ] {ai_charge(5);};
void()   knight_atkc12=[ $sattc12,    knight_run1 ] {ai_charge(5);};

void()   knight_atkd1 =[ $sattd1,    knight_atkd2 ]
{
sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(0);};
void()   knight_atkd2 =[ $sattd2,    knight_atkd3 ] {ai_charge(7);};
void()   knight_atkd3 =[ $sattd3,    knight_atkd4 ] {ai_charge(4);};
void()   knight_atkd4 =[ $sattd4,    knight_atkd5 ] {ai_charge(0);};
void()   knight_atkd5 =[ $sattd5,    knight_atkd6 ] {ai_charge(3);};
void()   knight_atkd6 =[ $sattd6,    knight_atkd7 ] {ai_charge(4); ai_melee();};
void()   knight_atkd7 =[ $sattd7,    knight_atkd8 ] {ai_charge(1); ai_melee();};
void()   knight_atkd8 =[ $sattd8,    knight_atkd9 ] {ai_charge(3); ai_melee();};
void()   knight_atkd9 =[ $sattd9,    knight_atkd10] {ai_charge(1);};
void()   knight_atkd10=[ $sattd10,      knight_atkd11   ] {ai_charge(5);};
void()   knight_atkd11=[ $sattd11,    knight_atkd12 ] {ai_charge(5);};
void()   knight_atkd12=[ $sattd12,    knight_run1 ] {ai_charge(5);};

// Psyloche's special parallise attack
void()   knight_special =
{
   makevectors(self.angles);
   traceline(self.origin, self.origin + v_forward*48, FALSE, self);

   if ((trace_ent == self.enemy) && (self.enemy.classname == "player")) {
      // got 'em
      sound(self, CHAN_WEAPON, "player/what_1.wav", 1, ATTN_NORM);

      self.enemy.parallize_time = time + 2 + random();
      self.enemy.x_flags = self.enemy.x_flags | X_PARALLIZED;
      self.enemy.parallized_velocity = '0 0 0';
      centerprint(self.enemy, "You have been paralyzed");
      stuffcmd(self.enemy, "v_cshift 0 0 0 180\n");
   }
};

void()   knight_xatk1 =[ $xatt1,    knight_xatk2 ]
{
sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(0);
self.nextthink = time + 0.05;};
void()   knight_xatk2 =[ $xatt2,    knight_xatk3 ] {ai_charge(0);self.nextthink = time + 0.05;};
void()   knight_xatk3 =[ $xatt3,    knight_xatk4 ] {ai_charge(0);self.nextthink = time + 0.05;};
void()   knight_xatk4 =[ $xatt4,    knight_xatk5 ] {ai_charge(0);self.nextthink = time + 0.05;};
void()   knight_xatk5 =[ $xatt5,    knight_xatk6 ] {ai_charge(0);self.nextthink = time + 0.05;};
void()   knight_xatk6 =[ $xatt6,    knight_xatk7 ] {ai_charge(0);self.nextthink = time + 0.05;};
void()   knight_xatk7 =[ $xatt7,    knight_xatk8 ] {ai_charge(3);self.nextthink = time + 0.05;};
void()   knight_xatk8 =[ $xatt8,    knight_xatk9 ] {ai_charge(5);self.nextthink = time + 0.05;};
void()   knight_xatk9 =[ $xatt9,    knight_xatk10] {ai_charge(10); knight_special();};
void()   knight_xatk10=[ $xatt10,   knight_xatk11  ] {ai_charge(0);};
void()   knight_xatk11=[ $xatt11,    knight_xatk12 ] {ai_charge(0);};
void()   knight_xatk12=[ $xatt12,    knight_run1 ] {ai_charge(0);};

void()   knight_atk =
{
   local float    rnd;

   // check for special attack
   if ((vlen(self.enemy.velocity) < 20) && (self.last_special < (time - 5)) && (self.enemy.classname == "player")) {
      self.last_special = time;
      knight_xatk1();
      return;
   }

   rnd = random() * 4;
   if (rnd < 1)
      knight_atk1();
   else if (rnd < 2)
      knight_atkb1();
   else if (rnd < 3)
      knight_atkc1();
   else
      knight_atkd1();
};


float() PsylockeCheckAttack =
{
   local float dist;

   dist = vlen(self.enemy.origin - self.origin);
   if (dist > 256)
      return FALSE;

   if (!infront(self.enemy))
      return FALSE;

   if (dist > 96) {
      self.attack_state = AS_MISSILE;
   }
   else {
      self.attack_state = AS_MELEE;
   }

   return TRUE;
};


//===========================================================================

void()	knight_pain1	=[	$pain1,		knight_pain2	] {};
void()	knight_pain2	=[	$pain2,		knight_pain3	] {};
void()	knight_pain3	=[	$pain3,		knight_pain4	] {};
void()   knight_pain4   =[ $pain4,     knight_pain5 ] {};
void()   knight_pain5   =[ $pain5,     knight_pain6 ] {};
void()   knight_pain6   =[ $pain6,     knight_run1 ] {};

void()	knight_paina	=
{
   self.frame = self.frame + 1;

   if (self.frame > $paina29 )
      knight_run1();
   else  {
      self.think = knight_paina;
      self.nextthink = time + 0.05;
   }

};

void(entity attacker, float damage)	knight_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random();

   FemalePainSound();

	if (r < 0.85)
	{
		knight_pain1 ();
		self.pain_finished = time + 2;
	}
	else
	{
      self.frame = $paina1 - 1;
		knight_paina ();
		self.pain_finished = time + 5;
	}

};


void()	knight_die1	=[	$death1,	knight_die2	] {};
void()	knight_die2	=[	$death2,	knight_die3	] {};
void()	knight_die3	=[	$death3,	knight_die4	]
{self.solid = SOLID_NOT;};
void()	knight_die4	=[	$death4,	knight_die5	] {};
void()	knight_die5	=[	$death5,	knight_die6	] {};
void()	knight_die6	=[	$death6,	knight_die7	] {};
void()	knight_die7	=[	$death7,	knight_die8	] {};
void()	knight_die8	=[	$death8,	knight_die9	] {};
void()	knight_die9	=[	$death9,	knight_die10] {};
void()	knight_die10=[	$death10,	knight_die11] {};
void()   knight_die11=[ $death11,   knight_die12] {};
void()   knight_die12=[ $death12,   knight_die13] {};
void()   knight_die13=[ $death13,   knight_die14] {};
void()   knight_die14=[ $death14,   knight_die15] {};
void()   knight_die15=[ $death15,   knight_die16] {};
void()   knight_die16=[ $death16,   knight_die16] {};

void() knight_die =
{
   FemaleDeathSound();

   knight_die1 ();
};


/*QUAKED monster_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_knight =
{
   remove(self);
};

void() xmen_psylocke =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }

   precache_model ("progs/psy1.mdl");
// precache_model ("progs/h_knight.mdl");

   precache_sound ("voice/female/attack1.wav");

   // XMen Matched ID sounds
   precache_sound ("knight/sword1.wav");
   precache_sound ("knight/sword2.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/psy1.mdl");

   setsize (self, '-16 -16 -24', '16 16 40');
   self.health = 150 + cvar("skill")*10;

   self.th_stand = knight_stand1;
   self.th_walk = knight_walk1;
   self.th_run = knight_run1;
   self.th_melee = knight_atk;
   self.th_missile = knight_runattack;
   self.th_pain = knight_pain;
   self.th_die = knight_die;

   walkmonster_start ();
};