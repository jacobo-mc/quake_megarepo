/*
==============================================================================

Storm

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6

$frame wind1 wind2 wind3 wind4 wind5 wind6 wind7 wind8 wind9
$frame wind10 wind11 wind12 wind13 wind14 wind15 wind16

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8 attack9 attack10
$frame attack11 attack12 attack13 attack14 attack15 attack16 attack17 attack18 attack19 attack20

$frame paina1 paina2 paina3 paina4 paina5 paina6

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9 pain10
$frame pain11 pain12 pain13 pain14 pain15 pain16 pain17 pain18 pain19 pain20
$frame pain21 pain22 pain23 pain24 pain25 pain26 pain27 pain28 pain29 pain30
$frame pain31 pain32 pain33 pain34 pain35 pain36 pain37 pain38 pain39 pain40

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9
$frame death10 death11 death12 death13 death14 death15 death16

$frame deata1 deata2 deata3 deata4 deata5 deata6 deata7 deata8 deata9
$frame deata10 deata11 deata12 deata13 deata14 deata15 deata16 deata17

/*
$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12 fly13 fly14

$frame magatt1 magatt2 magatt3 magatt4 magatt5 magatt6 magatt7
$frame magatt8 magatt9 magatt10 magatt11 magatt12 magatt13

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7 death8
*/

/*
==============================================================================

Storm

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

void() storm_run1;
void() storm_wind1;

float(float drange) DangerousEntityInRange =
{
   local entity   trav;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local float    strength, dist;
   local vector   vect, vect_angle;

   trav = findradius(self.origin, drange);
   while (trav != world) {

      // check that the object is damage-able and is infront of self
      vect = normalize(trav.origin - self.origin);
      vect_angle = vectoangles(vect);

      if ((trav != self) &&
          (trav.movetype) &&
          (fabs( angle_diff( vect_angle_y, self.angles_y)) < 60)) {    // dangerous in range
         return TRUE;
      }

      trav = trav.chain;
   }

   return FALSE;
};


/*
=================
StormCheckAttack
=================
*/
float()	StormCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local entity	trav;
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_vis)
		return FALSE;

   // look for a rocket in close vicinity
   if ((self.last_wind < (time - 3)) && (DangerousEntityInRange(128))) {
       self.attack_state = AS_SLIDING;
       storm_wind1 ();
       return FALSE;
   }

	if (enemy_range == RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			storm_run1 ();
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
			storm_run1 ();
		}
		return FALSE;
	}

   if ((self.last_wind < (time - 3)) && (vlen(self.enemy.origin - self.origin) < 196)) {
       self.attack_state = AS_SLIDING;
       storm_wind1 ();
       return FALSE;
   }

	if (enemy_range == RANGE_MELEE)
		chance = 0.4;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.2;
	else if (enemy_range == RANGE_MID)
		chance = 0.1;
	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			storm_run1 ();
		}
	}
	else
	{
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
		}
	}

	return FALSE;
};

/*
=================
StormAttackFinished
=================
*/
// 20060704 LordHavoc: hushed a compiler warning by making this return void instead of float
void()	StormAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = storm_run1;
	}
	else if (self.last_wind < (time - 3))
	{
		self.attack_state = AS_SLIDING;
		self.think = storm_wind1;
	}
};

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() storm_idlesound =
{
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
/*
local float wr;

return;

	wr = random() * 5;

	if (self.waitmin < time)
	{
	 	self.waitmin = time + 2;
	 	if (wr > 4.5)
	 		sound (self, CHAN_VOICE, "wizard/widle1.wav", 1,  ATTN_IDLE);
	 	if (wr < 1.5)
	 		sound (self, CHAN_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
	return;
*/
};

void()	storm_stand1	=[	$stand1,		storm_stand2	] {ai_stand();};
void()	storm_stand2	=[	$stand2,		storm_stand3	] {ai_stand();};
void()	storm_stand3	=[	$stand3,		storm_stand4	] {ai_stand();};
void()	storm_stand4	=[	$stand4,		storm_stand5	] {ai_stand();};
void()	storm_stand5	=[	$stand5,		storm_stand6	] {ai_stand();};
void()	storm_stand6	=[	$stand6,		storm_stand7	] {ai_stand();};
void()	storm_stand7	=[	$stand7,		storm_stand8	] {ai_stand();};
void()   storm_stand8  =[ $stand8,    storm_stand9  ] {ai_stand();};
void()   storm_stand9  =[ $stand9,    storm_stand10 ] {ai_stand();};
void()   storm_stand10 =[ $stand10,   storm_stand11 ] {ai_stand();};
void()   storm_stand11 =[ $stand11,   storm_stand12 ] {ai_stand();};
void()   storm_stand12 =[ $stand12,   storm_stand13 ] {ai_stand();};
void()	storm_stand13 =[	$stand13,	storm_stand1	] {ai_stand();};

void()	storm_walk1	=[	$walk1,		storm_walk2	] {ai_walk(8);
storm_idlesound();};
void()	storm_walk2	=[	$walk2,		storm_walk3	] {ai_walk(8);};
void()	storm_walk3	=[	$walk3,		storm_walk4	] {ai_walk(8);};
void()	storm_walk4	=[	$walk4,		storm_walk5	] {ai_walk(8);};
void()	storm_walk5	=[	$walk5,		storm_walk6	] {ai_walk(8);};
void()	storm_walk6	=[	$walk6,		storm_walk7	] {ai_walk(8);};
void()	storm_walk7	=[	$walk7,		storm_walk8	] {ai_walk(8);};
void()	storm_walk8	=[	$walk8,		storm_walk9	] {ai_walk(8);};
void()   storm_walk9   =[ $walk9,     storm_walk10  ] {ai_walk(8);};
void()   storm_walk10  =[ $walk10,    storm_walk11  ] {ai_walk(8);};
void()   storm_walk11  =[ $walk11,    storm_walk12  ] {ai_walk(8);};
void()   storm_walk12  =[ $walk12,    storm_walk1   ] {ai_walk(8);};

void()  set_offset =
{
   self.origin_z = self.origin_z - self.z_ofs;
   self.z_ofs = self.z_ofs + (self.z_ofs_vel * random() * 2);

   if (self.z_ofs >= (MAX_Z_OFS)) {
      self.z_ofs_vel = -1 * self.z_ofs_vel;
      self.z_ofs = MAX_Z_OFS;
   }
   else if (self.z_ofs <= 0) {
      self.z_ofs_vel = -1 * self.z_ofs_vel;
      self.z_ofs = 0;
   }
   else {      // add some randomness
      if (random() <= 0.1)
         self.z_ofs_vel = -1 * self.z_ofs_vel;
   }

   self.origin_z = self.origin_z + self.z_ofs;
};

void()	storm_run1	=[	$run1,		storm_run2	] {
set_offset();
ai_run(6);
storm_idlesound();};
void()	storm_run2	=[	$run2,		storm_run3	] {ai_run(6);set_offset();};
void()	storm_run3	=[	$run3,		storm_run4	] {ai_run(6);set_offset();};
void()	storm_run4	=[	$run4,		storm_run5	] {ai_run(6);set_offset();};
void()	storm_run5	=[	$run5,		storm_run6	] {ai_run(6);set_offset();};
void()	storm_run6	=[	$run6,		storm_run1	] {ai_run(6);set_offset();};

void() storm_Wind =
{
   local entity   trav;
   local float    strength, dist;
   local vector   vect, vect_angle;

   trav = findradius(self.origin, 256);
   while (trav != world) {

      // check that the object is damage-able and is infront of self
      vect = normalize(trav.origin - self.origin);
      vect_angle = vectoangles(vect);

      if ((trav != self) &&
          (trav.classname == "player") &&
          (fabs( angle_diff( vect_angle_y, self.angles_y)) < 35)) {    // give em some wind

         strength = 200;
         dist = vlen(trav.origin - self.origin);
         if (dist > 128) {    // reduce strength of blast
            strength = ((dist - 128) / 128) * strength;
         }

         // blast now
         trav.flags = trav.flags - (trav.flags & FL_ONGROUND);
         trav.velocity = (trav.velocity * 0.5) + (vect * 600);
         trav.velocity_z = 300;

         trav.angles = trav.v_angle = self.angles;
         trav.punchangle_x = -20;
         trav.fixangle = TRUE;
      }

      trav = trav.chain;
   }

   self.last_wind = time;
};

void()   storm_wind1   =[ $wind1,        storm_wind2   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind2   =[ $wind2,        storm_wind3   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind3   =[ $wind3,        storm_wind4   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind4   =[ $wind4,        storm_wind5   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind5   =[ $wind5,        storm_wind6   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind6   =[ $wind6,        storm_wind7   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind7   =[ $wind7,        storm_wind8   ] {ai_face(); sound (self, CHAN_WEAPON, "storm/w_attack.wav", 1, ATTN_NORM); self.nextthink = time + 0.05;};
void()   storm_wind8   =[ $wind8,        storm_wind9   ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind9   =[ $wind9,        storm_wind10  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind10  =[ $wind10,       storm_wind11  ] {ai_face(); storm_Wind(); self.nextthink = time + 0.05;};
void()   storm_wind11  =[ $wind11,       storm_wind12  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind12  =[ $wind12,       storm_wind13  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind13  =[ $wind13,       storm_wind14  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind14  =[ $wind14,       storm_wind15  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind15  =[ $wind15,       storm_wind16  ] {ai_face(); self.nextthink = time + 0.05;};
void()   storm_wind16  =[ $wind16,       storm_run1    ] {ai_face(); self.nextthink = time + 0.05;};

void() StormCastLightning =
{
   local vector   org, dir;

   self.effects = self.effects | EF_MUZZLEFLASH;

   ai_face ();

   org = self.origin + '0 0 40';

   dir = self.enemy.origin + '0 0 16' - org - (self.enemy.velocity * 0.5);
   dir = normalize (dir);

   traceline (org, self.origin + dir*1200, FALSE, self);
   sound (self, CHAN_WEAPON, "storm/l_attack.wav", 1, ATTN_NORM);

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_LIGHTNING3);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, org_x);
   WriteCoord (MSG_BROADCAST, org_y);
   WriteCoord (MSG_BROADCAST, org_z - 20);
   WriteCoord (MSG_BROADCAST, trace_endpos_x);
   WriteCoord (MSG_BROADCAST, trace_endpos_y);
   WriteCoord (MSG_BROADCAST, trace_endpos_z);

   LightningDamage (org, trace_endpos + dir * 8, self, 20);
};

void()	storm_fast1	=[	$attack1,		storm_fast2	] {ai_face();};
void()	storm_fast2	=[	$attack2,		storm_fast3	] {ai_face();};
void()	storm_fast3	=[	$attack3,		storm_fast4	] {ai_face();};
void()	storm_fast4	=[	$attack4,		storm_fast5	] {ai_face();};
void()	storm_fast5	=[	$attack5,		storm_fast6	] {ai_face();};
void()	storm_fast6	=[	$attack6,		storm_fast7	] {ai_face();};
void()	storm_fast7	=[	$attack7,		storm_fast8	] {ai_face();};
void()	storm_fast8	=[	$attack8,		storm_fast9	] {ai_face();};
void()	storm_fast9	=[	$attack9,		storm_fast10	] {ai_face();};
void()   storm_fast10  =[ $attack10,     storm_fast11  ] {ai_face();};
void()   storm_fast11  =[ $attack11,     storm_fast12  ] {ai_face(); StormCastLightning();};
void()   storm_fast12  =[ $attack12,     storm_fast13  ] {ai_face();};
void()   storm_fast13  =[ $attack13,     storm_fast14  ] {ai_face();};
void()   storm_fast14  =[ $attack14,     storm_fast15  ] {ai_face();};
void()   storm_fast15  =[ $attack15,     storm_fast16  ] {ai_face();};
void()   storm_fast16  =[ $attack16,     storm_fast17  ] {ai_face();};
void()   storm_fast17  =[ $attack17,     storm_fast18  ] {ai_face();};
void()   storm_fast18  =[ $attack18,     storm_fast19  ] {ai_face();};
void()   storm_fast19  =[ $attack19,     storm_fast20  ] {ai_face();};
void()	storm_fast20	=[	$attack20,		storm_run1 	] {ai_face();SUB_AttackFinished(2);StormAttackFinished ();};

void()	storm_pain1	=[	$pain1,		storm_pain2	] {self.nextthink = time + 0.05;};
void()	storm_pain2	=[	$pain2,		storm_pain3	] {self.nextthink = time + 0.05;};
void()	storm_pain3	=[	$pain3,		storm_pain4	] {self.nextthink = time + 0.05;};
void()   storm_pain4   =[ $pain4,     storm_pain5   ] {self.nextthink = time + 0.05;};
void()   storm_pain5   =[ $pain5,     storm_pain6   ] {self.nextthink = time + 0.05;};
void()   storm_pain6   =[ $pain6,     storm_pain7   ] {self.nextthink = time + 0.05;};
void()   storm_pain7   =[ $pain7,     storm_pain8   ] {self.nextthink = time + 0.05;};
void()   storm_pain8   =[ $pain8,     storm_pain9   ] {self.nextthink = time + 0.05;};
void()   storm_pain9   =[ $pain9,     storm_pain10  ] {self.nextthink = time + 0.05;};
void()   storm_pain10  =[ $pain10,    storm_pain11  ] {self.nextthink = time + 0.05;};
void()   storm_pain11  =[ $pain11,    storm_pain12  ] {self.nextthink = time + 0.05;};
void()   storm_pain12  =[ $pain12,    storm_pain13  ] {self.nextthink = time + 0.05;};
void()   storm_pain13  =[ $pain13,    storm_pain14  ] {self.nextthink = time + 0.05;};
void()   storm_pain14  =[ $pain14,    storm_pain15  ] {self.nextthink = time + 0.05;};
void()   storm_pain15  =[ $pain15,    storm_pain16  ] {self.nextthink = time + 0.05;};
void()   storm_pain16  =[ $pain16,    storm_pain17  ] {self.nextthink = time + 0.05;};
void()   storm_pain17  =[ $pain17,    storm_pain18  ] {self.nextthink = time + 0.05;};
void()   storm_pain18  =[ $pain18,    storm_pain19  ] {self.nextthink = time + 0.05;};
void()   storm_pain19  =[ $pain19,    storm_pain20  ] {self.nextthink = time + 0.05;};
void()   storm_pain20  =[ $pain20,    storm_pain21  ] {self.nextthink = time + 0.05;};
void()   storm_pain21  =[ $pain21,    storm_pain22  ] {self.nextthink = time + 0.05;};
void()   storm_pain22  =[ $pain22,    storm_pain23  ] {self.nextthink = time + 0.05;};
void()   storm_pain23  =[ $pain23,    storm_pain24  ] {self.nextthink = time + 0.05;};
void()   storm_pain24  =[ $pain24,    storm_pain25  ] {self.nextthink = time + 0.05;};
void()   storm_pain25  =[ $pain25,    storm_pain26  ] {self.nextthink = time + 0.05;};
void()   storm_pain26  =[ $pain26,    storm_pain27  ] {self.nextthink = time + 0.05;};
void()   storm_pain27  =[ $pain27,    storm_pain28  ] {self.nextthink = time + 0.05;};
void()   storm_pain28  =[ $pain28,    storm_pain29  ] {self.nextthink = time + 0.05;};
void()   storm_pain29  =[ $pain29,    storm_pain30  ] {self.nextthink = time + 0.05;};
void()   storm_pain30  =[ $pain30,    storm_pain31  ] {self.in_pain = FALSE;self.nextthink = time + 0.05;};
void()   storm_pain31  =[ $pain31,    storm_pain32  ] {self.nextthink = time + 0.05;};
void()   storm_pain32  =[ $pain32,    storm_pain33  ] {self.nextthink = time + 0.05;};
void()   storm_pain33  =[ $pain33,    storm_pain34  ] {self.nextthink = time + 0.05;};
void()   storm_pain34  =[ $pain34,    storm_pain35  ] {self.nextthink = time + 0.05;};
void()   storm_pain35  =[ $pain35,    storm_pain36  ] {self.nextthink = time + 0.05;};
void()   storm_pain36  =[ $pain36,    storm_pain37  ] {self.nextthink = time + 0.05;};
void()   storm_pain37  =[ $pain37,    storm_pain38  ] {self.nextthink = time + 0.05;};
void()   storm_pain38  =[ $pain38,    storm_pain39  ] {self.nextthink = time + 0.05;};
void()   storm_pain39  =[ $pain39,    storm_pain40  ] {self.nextthink = time + 0.05;};
void()   storm_pain40  =[ $pain40,    storm_run1  ] {self.nextthink = time + 0.05;};

void()   storm_painb1   =[ $paina1,     storm_painb2   ] {};
void()   storm_painb2   =[ $paina2,     storm_painb3   ] {};
void()   storm_painb3   =[ $paina3,     storm_painb4   ] {};
void()   storm_painb4   =[ $paina4,     storm_painb5   ] {};
void()   storm_painb5   =[ $paina5,     storm_painb6 ] {};
void()   storm_painb6   =[ $paina6,     storm_run1 ] {};


void()	storm_death1	=[	$death1,		storm_death2	] {

self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
self.angles_x = 0;
self.angles_z = 0;
};
void()	storm_death2	=[	$death2,		storm_death3	] {};
void()	storm_death3	=[	$death3,		storm_death4	]{self.solid = SOLID_NOT;};
void()	storm_death4	=[	$death4,		storm_death5	] {};
void()	storm_death5	=[	$death5,		storm_death6	] {};
void()	storm_death6	=[	$death6,		storm_death7	] {};
void()	storm_death7	=[	$death7,		storm_death8	] {};
void()	storm_death8	=[	$death8,		storm_death9	] {};
void()   storm_death9  =[ $death9,    storm_death10 ] {};
void()   storm_death10 =[ $death10,   storm_death11 ] {};
void()   storm_death11 =[ $death11,   storm_death12 ] {};
void()   storm_death12 =[ $death12,   storm_death13 ] {};
void()   storm_death13 =[ $death13,   storm_death14 ] {};
void()   storm_death14 =[ $death14,   storm_death15 ] {};
void()   storm_death15 =[ $death15,   storm_death16 ] {};
void()   storm_death16 =[ $death16,   storm_death16 ] {};

void()   storm_deata1   =[ $deata1,    storm_deata2   ] {

self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
self.angles_x = 0;
self.angles_z = 0;
};
void()   storm_deata2   =[ $deata2,    storm_deata3   ] {};
void()   storm_deata3   =[ $deata3,    storm_deata4   ]{self.solid = SOLID_NOT;};
void()   storm_deata4   =[ $deata4,    storm_deata5   ] {};
void()   storm_deata5   =[ $deata5,    storm_deata6   ] {};
void()   storm_deata6   =[ $deata6,    storm_deata7   ] {};
void()   storm_deata7   =[ $deata7,    storm_deata8   ] {};
void()   storm_deata8   =[ $deata8,    storm_deata9   ] {};
void()   storm_deata9  =[ $deata9,    storm_deata10 ] {};
void()   storm_deata10 =[ $deata10,   storm_deata11 ] {};
void()   storm_deata11 =[ $deata11,   storm_deata12 ] {};
void()   storm_deata12 =[ $deata12,   storm_deata13 ] {};
void()   storm_deata13 =[ $deata13,   storm_deata14 ] {};
void()   storm_deata14 =[ $deata14,   storm_deata15 ] {};
void()   storm_deata15 =[ $deata15,   storm_deata16 ] {};
void()   storm_deata16 =[ $deata16,   storm_deata17 ] {};
void()   storm_deata17 =[ $deata17,   storm_deata17 ] {};

void() storm_die =
{

   FemaleDeathSound();

   if (!(self.deadflag == DEAD_DEAD)) {
      if (random() < 0.5)
      	storm_death1 ();
      else
         storm_deata1 ();
   }

   self.deadflag = DEAD_DEAD;
};


void(entity attacker, float damage) storm_Pain =
{

   if (self.in_pain) {
        return;
   }

   self.in_pain = TRUE;

   FemalePainSound();

	if (random()*70 > damage)
		return;		// didn't flinch

   if ((damage > 30) && (random() < 0.3))
      storm_pain1 ();
   else
      storm_painb1 ();
};


void() storm_Missile =
{
	storm_fast1();
};

/*QUAKED monster_shambler (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_shambler =
{
   remove(self);
};

void() xmen_storm =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }

   precache_model ("progs/storm2.mdl");

   precache_sound ("wizard/hit.wav");     // used by c code
   precache_sound ("storm/l_attack.wav");
   precache_sound ("storm/w_attack.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/storm2.mdl");

   setsize (self, '-16 -16 -24', '16 16 64');
   self.health = 150 + cvar("skill")*10;

   self.th_stand = storm_stand1;
   self.th_walk = storm_walk1;
   self.th_run = storm_run1;
   self.th_missile = storm_Missile;
   self.th_pain = storm_Pain;
   self.th_die = storm_die;

   self.z_ofs = 0;
   self.z_ofs_vel = 1;

// flymonster_start ();
   walkmonster_start ();
};