/*
==============================================================================

WIZARD

==============================================================================
*/

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8 hover9
$frame hover10 hover11 hover12 hover13

$frame slow1 slow2 slow3 slow4 slow5 slow6 slow7 slow8 slow9
$frame slow10 slow11 slow12 slow13

$frame fast1 fast2 fast3 fast4 fast5 fast6 fast7 fast8

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame guard1 guard2 guard3 guard4 guard5 guard6 guard7 guard8 guard9
$frame guard10 guard11 guard12

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8 deatha9 deatha10
$frame deatha11 deatha12 deatha13 deatha14 deatha15 deatha16 deatha17 deatha18 deatha19 deatha20

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13

/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

/*
=============
LaunchMissile

Sets the given entities velocity and angles so that it will hit self.enemy
if self.enemy maintains it's current velocity
0.1 is moderately accurate, 0.0 is totally accurate
=============
*/
void(entity missile, float mspeed, float accuracy) LaunchMissile =
{
	local	vector	vec, move;
	local	float	fly;

	makevectors (self.angles);

// set missile speed
	vec = self.enemy.origin + self.enemy.mins + self.enemy.size * 0.7 - missile.origin;

// calc aproximate time for missile to reach vec
	fly = vlen (vec) / mspeed;

// get the entities xy velocity
	move = self.enemy.velocity;
	move_z = 0;

// project the target forward in time
	vec = vec + move * fly;

	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);

	missile.velocity = vec * mspeed;

	missile.angles = '0 0 0';
	missile.angles_y = vectoyaw(missile.velocity);

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;
};


void() wiz_run1;
void() wiz_side1;

/*
=================
WizardCheckAttack
=================
*/
float()	WizardCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_vis)
		return FALSE;

	if (enemy_range == RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}

	targ = self.enemy;

// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}

	if (enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if (enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if ((enemy_range == RANGE_MID) && (vlen(self.origin - self.enemy.origin) > 256)) // keep at a distance
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
	}
	else
	{
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			wiz_side1 ();
		}
	}

	return FALSE;
};

/*
=================
WizardAttackFinished
=================
*/
// 20060704 LordHavoc: hushed a compiler warning by making this return void instead of float
void()	WizardAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = wiz_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = wiz_side1;
	}
};

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() Wiz_FastFire =
{
	local vector		vec;
	local vector		dst;

	if (self.owner.health > 0)
	{
		self.owner.effects = self.owner.effects | EF_MUZZLEFLASH;

		makevectors (self.enemy.angles);
		dst = self.enemy.origin - 13*self.movedir + (self.enemy.velocity * 0.3);

		vec = normalize(dst - self.origin);
		launch_spike (self.origin, vec);
		newmis.velocity = vec*600;
		newmis.owner = self.owner;
		newmis.classname = "angel_dart";
		setmodel (newmis, "progs/dart.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	}

	remove (self);
};


void() Wiz_StartFast =
{
	local	entity	missile;

	self.v_angle = self.angles;
	makevectors (self.angles);

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 0.6;
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.8;
	missile.think = Wiz_FastFire;
	missile.movedir = v_right;

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 1;
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right* -14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.3;
	missile.think = Wiz_FastFire;
	missile.movedir = VEC_ORIGIN - v_right;
};

void(float  heading_ofs)   AngelFeather =
{
   local vector   newangle, targ_vect;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   newangle = self.angles;
   newangle_y = anglemod(newangle_y + heading_ofs);

   targ_vect = normalize(self.enemy.origin - (self.origin + '0 0 30'));
   targ_vect = vectoangles(targ_vect);
   newangle_x = -1 * targ_vect_x;
   newangle_x = newangle_x + (random() * 20) - 10;

   makevectors(newangle);

   launch_spike (self.origin + '0 0 30' + v_forward*14, v_forward);
   newmis.classname = "angel_dart";
   setmodel (newmis, "progs/dart.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};


void() Wiz_idlesound =
{
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
/*
local float wr;

	return;
*/
};

void() AngelPitch =
{
   local vector   vect;

   if (self.enemy != world)
      vect = normalize(self.enemy.origin - self.origin);
   else
      vect = '1 0 0';

   vect = vectoangles(vect);
   vect_x = -1 * vect_x;

   if (vect_x < -25) vect_x = -25;
   else if (vect_x > 40) vect_x = 40;

   vect_x = anglemod(vect_x);
   self.angles_x = anglemod(self.angles_x);

   if (self.solid != SOLID_NOT)
      self.angles_x = MoveToAngle(self.angles_x, vect_x, 45);
   else
      self.angles_x = MoveToAngle(self.angles_x, vect_x, 180);

   if (self.angles_x > 180)
      self.angles_x = self.angles_x - 360;
};


void() RandomFlapSound =
{
   local float rnd;

   rnd = random() * 6;

   if (rnd < 1)
      self.noise = "angel/flap1.wav";
   else if (rnd < 2)
      self.noise = "angel/flap2.wav";
   else if (rnd < 3)
      self.noise = "angel/flap3.wav";
   else if (rnd < 4)
      self.noise = "angel/flap4.wav";
   else if (rnd < 5)
      self.noise = "angel/flap5.wav";
   else if (rnd < 6)
      self.noise = "angel/flap6.wav";

   sound(self, CHAN_BODY, self.noise, 1, 3);
};


void()	wiz_stand1	=[	$hover1,		wiz_stand2	] {ai_stand();};
void()	wiz_stand2	=[	$hover2,		wiz_stand3	] {ai_stand();};
void()	wiz_stand3	=[	$hover3,		wiz_stand4	] {ai_stand();};
void()	wiz_stand4	=[	$hover4,		wiz_stand5	] {ai_stand();};
void()	wiz_stand5	=[	$hover5,		wiz_stand6	] {ai_stand(); RandomFlapSound();};
void()	wiz_stand6	=[	$hover6,		wiz_stand7	] {ai_stand();};
void()	wiz_stand7	=[	$hover7,		wiz_stand8	] {ai_stand();};
void()	wiz_stand8	=[	$hover8,		wiz_stand9	] {ai_stand();};
void()   wiz_stand9  =[ $hover9,    wiz_stand10 ] {ai_stand();};
void()   wiz_stand10 =[ $hover10,   wiz_stand11 ] {ai_stand();};
void()   wiz_stand11 =[ $hover11,   wiz_stand12 ] {ai_stand();};
void()   wiz_stand12 =[ $hover12,   wiz_stand13 ] {ai_stand();};
void()   wiz_stand13 =[ $hover13,   wiz_stand1  ] {ai_stand();};

void()	wiz_walk1	=[	$slow1,		wiz_walk2	] {ai_walk(10);};
void()	wiz_walk2	=[	$slow2,		wiz_walk3	] {ai_walk(10);};
void()	wiz_walk3	=[	$slow3,		wiz_walk4	] {ai_walk(10); RandomFlapSound();};
void()	wiz_walk4	=[	$slow4,		wiz_walk5	] {ai_walk(10);};
void()	wiz_walk5	=[	$slow5,		wiz_walk6	] {ai_walk(10);};
void()	wiz_walk6	=[	$slow6,		wiz_walk7	] {ai_walk(10);};
void()	wiz_walk7	=[	$slow7,		wiz_walk8	] {ai_walk(10);};
void()	wiz_walk8	=[	$slow8,		wiz_walk9	] {ai_walk(10);};
void()   wiz_walk9   =[ $slow9,     wiz_walk10  ] {ai_walk(10);};
void()   wiz_walk10  =[ $slow10,    wiz_walk11  ] {ai_walk(10);};
void()   wiz_walk11  =[ $slow11,    wiz_walk12  ] {ai_walk(10);};
void()   wiz_walk12  =[ $slow12,    wiz_walk13  ] {ai_walk(10);};
void()   wiz_walk13  =[ $slow13,    wiz_walk1   ] {ai_walk(10);};

void()   wiz_side1   =[ $slow1,     wiz_side2   ] {ai_run(14);};
void()   wiz_side2   =[ $slow2,     wiz_side3   ] {ai_run(14);};
void()   wiz_side3   =[ $slow3,     wiz_side4   ] {ai_run(14); RandomFlapSound();};
void()   wiz_side4   =[ $slow4,     wiz_side5   ] {ai_run(14);};
void()   wiz_side5   =[ $slow5,     wiz_side6   ] {ai_run(14);};
void()   wiz_side6   =[ $slow6,     wiz_side7   ] {ai_run(14);};
void()   wiz_side7   =[ $slow7,     wiz_side8   ] {ai_run(14);};
void()   wiz_side8   =[ $slow8,     wiz_side9   ] {ai_run(14);};
void()   wiz_side9   =[ $slow9,     wiz_side10  ] {ai_run(14);};
void()   wiz_side10  =[ $slow10,    wiz_side11  ] {ai_run(14);};
void()   wiz_side11  =[ $slow11,    wiz_side12  ] {ai_run(14);};
void()   wiz_side12  =[ $slow12,    wiz_side13  ] {ai_run(14);};
void()   wiz_side13  =[ $slow13,    wiz_side1   ] {ai_run(14);};

void()   wiz_run1   =[ $slow1,     wiz_run2   ] {ai_run(20);};
void()   wiz_run2   =[ $slow2,     wiz_run3   ] {ai_run(20);};
void()   wiz_run3   =[ $slow3,     wiz_run4   ] {ai_run(20);};
void()   wiz_run4   =[ $slow4,     wiz_run5   ] {ai_run(20);};
void()   wiz_run5   =[ $slow5,     wiz_run6   ] {ai_run(20);};
void()   wiz_run6   =[ $slow6,     wiz_run7   ] {ai_run(20);};
void()   wiz_run7   =[ $slow7,     wiz_run8   ] {ai_run(20);};
void()   wiz_run8   =[ $slow8,     wiz_run9   ] {ai_run(20);};
void()   wiz_run9   =[ $slow9,     wiz_run10  ] {ai_run(20);};
void()   wiz_run10  =[ $slow10,    wiz_run11  ] {ai_run(20);};
void()   wiz_run11  =[ $slow11,    wiz_run12  ] {ai_run(20);};
void()   wiz_run12  =[ $slow12,    wiz_run13  ] {ai_run(20);};
void()   wiz_run13  =[ $slow13,    wiz_run1   ] {ai_run(20);};

float() AngelCheckGuard =
{
   local entity   trav;

   trav = world;
   while ((trav = find(trav, classname, "guided_rocket")) != world) {

      // check that rocket is targetted for self
      if (trav.enemy == self) {     // uh oh
         return TRUE;
      }

   }

   // dangerous rocket not found
   self.think = self.th_run;

   self.flags = self.flags - (self.flags & FL_GODMODE);

   return FALSE;
};

void()   wiz_guard1  =[ $guard1,  wiz_guard2  ]  {self.nextthink = time + 0.05;};
void()   wiz_guard2  =[ $guard2,  wiz_guard3  ]  {self.nextthink = time + 0.05;};
void()   wiz_guard3  =[ $guard3,  wiz_guard4  ]  {self.nextthink = time + 0.05;};
void()   wiz_guard4  =[ $guard4,  wiz_guard5  ]  {self.nextthink = time + 0.05;};
void()   wiz_guard5  =[ $guard5,  wiz_guard6  ]  {self.nextthink = time + 0.05;};
void()   wiz_guard6  =[ $guard6,  wiz_guard7  ]  {self.flags = self.flags | FL_GODMODE;};
void()   wiz_guard7  =[ $guard7,  wiz_guard8  ]  {};
void()   wiz_guard8  =[ $guard8,  wiz_guard9  ]  {};
void()   wiz_guard9  =[ $guard9,  wiz_guard10 ]  {};
void()   wiz_guard10 =[ $guard10, wiz_guard11 ]  {};
void()   wiz_guard11 =[ $guard11, wiz_guard12 ]  {};
void()   wiz_guard12 =[ $guard12, wiz_guard12 ]  {AngelCheckGuard();};

void()	wiz_attack1	=[	$attack1,		wiz_attack2	] {ai_face();};
void()	wiz_attack2	=[	$attack2,		wiz_attack3	] {};
void()	wiz_attack3	=[	$attack3,		wiz_attack4	] {ai_face(); RandomFlapSound();};
void()	wiz_attack4	=[	$attack4,		wiz_attack5	] {};
void()	wiz_attack5	=[	$attack5,		wiz_attack6	] {
//sound(self, CHAN_WEAPON, "hknight/slash1.wav", 1, ATTN_NORM);
ai_face();};
void()	wiz_attack6	=[	$attack6,		wiz_attack7	] {AngelFeather(-25);AngelFeather(-20);};
void()	wiz_attack7	=[	$attack7,		wiz_attack8	] {AngelFeather(-15);AngelFeather(-10);};
void()   wiz_attack8   =[ $attack8,    wiz_attack9   ] {AngelFeather(-5);AngelFeather(0);};
void()   wiz_attack9   =[ $attack9,    wiz_attack10  ] {AngelFeather(5);AngelFeather(10);};
void()   wiz_attack10  =[ $attack10,   wiz_attack11  ] {AngelFeather(15);AngelFeather(20);};
void()   wiz_attack11  =[ $attack11,   wiz_attack12  ] {ai_face();};
void()   wiz_attack12  =[ $attack12,   wiz_attack13  ] {ai_face();};
void()	wiz_attack13  =[ $attack13,	wiz_run1 	] {SUB_AttackFinished(2);WizardAttackFinished ();};

void()	wiz_pain1	=[	$pain1,		wiz_pain2	] {};
void()	wiz_pain2	=[	$pain2,		wiz_pain3	] {};
void()	wiz_pain3	=[	$pain3,		wiz_pain4	] {};
void()   wiz_pain4   =[ $pain4,     wiz_pain5   ] {};
void()   wiz_pain5   =[ $pain5,     wiz_pain6   ] {};
void()	wiz_pain6	=[	$pain6,		wiz_run1	] {};

void()	wiz_death1	=[	$death1,		wiz_death2	] {
self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
self.enemy = world;
};
void()	wiz_death2	=[	$death2,		wiz_death3	] {};
void()	wiz_death3	=[	$death3,		wiz_death4	]{self.solid = SOLID_NOT;};
void()	wiz_death4	=[	$death4,		wiz_death5	] {};
void()	wiz_death5	=[	$death5,		wiz_death6	] {};
void()	wiz_death6	=[	$death6,		wiz_death7	] {};
void()	wiz_death7	=[	$death7,		wiz_death8	] {};
void()	wiz_death8	=[	$death8,		wiz_death9	] {};
void()   wiz_death9  =[ $death9,    wiz_death10 ] {};
void()   wiz_death10 =[ $death10,    wiz_death11  ] {};
void()   wiz_death11 =[ $death11,    wiz_death12  ] {};
void()   wiz_death12 =[ $death12,    wiz_death13  ] {};
void()   wiz_death13 =[ $death13,    wiz_death14  ] {};
void()   wiz_death14 =[ $death14,    wiz_death15  ] {};
void()   wiz_death15 =[ $death15,    wiz_death16  ] {};
void()   wiz_death16 =[ $death16,    wiz_death17  ] {};
void()   wiz_death17 =[ $death17,    wiz_death18  ] {};
void()   wiz_death18 =[ $death18,    wiz_death19  ] {};
void()   wiz_death19 =[ $death19,    wiz_death20  ] {};
void()   wiz_death20 =[ $death20,    wiz_death20  ] {if (self.angles_x != 0) AngelPitch();};

void()   wiz_deatha1  =[ $deatha1,    wiz_deatha2  ] {
self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
self.enemy = world;
};
void()   wiz_deatha2  =[ $deatha2,    wiz_deatha3  ] {};
void()   wiz_deatha3  =[ $deatha3,    wiz_deatha4  ]{self.solid = SOLID_NOT;};
void()   wiz_deatha4  =[ $deatha4,    wiz_deatha5  ] {};
void()   wiz_deatha5  =[ $deatha5,    wiz_deatha6  ] {};
void()   wiz_deatha6  =[ $deatha6,    wiz_deatha7  ] {};
void()   wiz_deatha7  =[ $deatha7,    wiz_deatha8  ] {};
void()   wiz_deatha8  =[ $deatha8,    wiz_deatha9  ] {};
void()   wiz_deatha9  =[ $deatha9,    wiz_deatha10 ] {};
void()   wiz_deatha10 =[ $deatha10,    wiz_deatha11  ] {};
void()   wiz_deatha11 =[ $deatha11,    wiz_deatha12  ] {};
void()   wiz_deatha12 =[ $deatha12,    wiz_deatha13  ] {};
void()   wiz_deatha13 =[ $deatha13,    wiz_deatha14  ] {};
void()   wiz_deatha14 =[ $deatha14,    wiz_deatha15  ] {};
void()   wiz_deatha15 =[ $deatha15,    wiz_deatha16  ] {};
void()   wiz_deatha16 =[ $deatha16,    wiz_deatha17  ] {};
void()   wiz_deatha17 =[ $deatha17,    wiz_deatha18  ] {};
void()   wiz_deatha18 =[ $deatha18,    wiz_deatha19  ] {};
void()   wiz_deatha19 =[ $deatha19,    wiz_deatha20  ] {};
void()   wiz_deatha20 =[ $deatha20,    wiz_deatha20  ] {if (self.angles_x != 0) AngelPitch();};

void() wiz_die =
{
   MaleDeathSound(2);

   if (random() < 0.5)
   	wiz_death1 ();
   else
      wiz_deatha1 ();
};


void(entity attacker, float damage) Wiz_Pain =
{

   if (self.pain_finished > time)
      return;

   MalePainSound(2);

	if (random()*40 > damage)
		return;		// didn't flinch

   self.pain_finished = time + 2;

	wiz_pain1 ();
};


void() Wiz_Missile =
{
	wiz_attack1();
};

/*QUAKED xmen_angel (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() xmen_angel =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/angel1.mdl");

//	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/dart.mdl");

   // XMen matched ID sounds
//   precache_sound ("hknight/slash1.wav");

   precache_sound ("angel/flap1.wav");
   precache_sound ("angel/flap2.wav");
   precache_sound ("angel/flap3.wav");
   precache_sound ("angel/flap4.wav");
   precache_sound ("angel/flap5.wav");
   precache_sound ("angel/flap6.wav");

	precache_sound ("wizard/hit.wav");		// used by c code

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/angel1.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
   self.health = 110 + cvar("skill")*10;

   self.yaw_speed = 9;

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = Wiz_Missile;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;

   self.th_guard = wiz_guard1;

	flymonster_start ();
};

void() monster_wizard =
{
   remove(self);
};