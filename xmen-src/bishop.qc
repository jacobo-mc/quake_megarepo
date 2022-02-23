/*
==============================================================================

Bishop

==============================================================================

Attack : Bishop enjoys using a BIG gun, He also has the ability to
absorb energy, allowing him to redirect it back towards his attacker.
Bishops main weapon is two cool futuristic laser type guns. If the
player uses an energy weapon against him, Bishop will not be effected,
but will store up energy for a special (magic) attack.
Bishop will do his special attack at random times. This will be a
huge energy burst from his hands.

Defence : The ability to Store energy attacks

Best weapon to use : Chaingun.
Worst weapon to use : Lazer will not be effectual
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8
$frame xatta9 xatta10 xatta11 xatta12

void(float  r_ofs) bishop_fire;
void() bishop_specialfire;

void()	bishop_stand1	=[	$stand1,	bishop_stand2	] {ai_stand();};
void()	bishop_stand2	=[	$stand2,	bishop_stand3	] {ai_stand();};
void()	bishop_stand3	=[	$stand3,	bishop_stand4	] {ai_stand();};
void()	bishop_stand4	=[	$stand4,	bishop_stand5	] {ai_stand();};
void()	bishop_stand5	=[	$stand5,	bishop_stand6	] {ai_stand();};
void()	bishop_stand6	=[	$stand6,	bishop_stand7	] {ai_stand();};
void()	bishop_stand7	=[	$stand7,	bishop_stand8	] {ai_stand();};
void()	bishop_stand8	=[	$stand8,	bishop_stand9	] {ai_stand();};
void()   bishop_stand9  =[ $stand9, bishop_stand10 ] {ai_stand();};
void()   bishop_stand10 =[ $stand10, bishop_stand11 ] {ai_stand();};
void()   bishop_stand11 =[ $stand11, bishop_stand12 ] {ai_stand();};
void()   bishop_stand12 =[ $stand12, bishop_stand13 ] {ai_stand();};
void()   bishop_stand13 =[ $stand13, bishop_stand1  ] {ai_stand();};

void()	bishop_walk1	=[	$walk1,	bishop_walk2	] {
//if (random() < 0.2)
//	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
ai_walk(6);};
void()	bishop_walk2	=[	$walk2,	bishop_walk3	] {ai_walk(6);};
void()	bishop_walk3	=[	$walk3,	bishop_walk4	] {ai_walk(6);};
void()	bishop_walk4	=[	$walk4,	bishop_walk5	] {ai_walk(6);};
void()	bishop_walk5	=[	$walk5,	bishop_walk6	] {ai_walk(7);};
void()	bishop_walk6	=[	$walk6,	bishop_walk7	] {ai_walk(7);};
void()	bishop_walk7	=[	$walk7,	bishop_walk8	] {ai_walk(8);};
void()	bishop_walk8	=[	$walk8,	bishop_walk9	] {ai_walk(7);};
void()	bishop_walk9	=[	$walk9,	bishop_walk10	] {ai_walk(5);};
void()	bishop_walk10	=[	$walk10,	bishop_walk11	] {ai_walk(5);};
void()	bishop_walk11	=[	$walk11,	bishop_walk12	] {ai_walk(6);};
void()	bishop_walk12	=[	$walk12,	bishop_walk1	] {ai_walk(7);};

void()	bishop_run1	=[	$run1,		bishop_run2	] {
//if (random() < 0.2)
//	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
ai_run(14);};
void()	bishop_run2	=[	$run2,		bishop_run3	] {ai_run(16);};
void()	bishop_run3	=[	$run3,		bishop_run4	] {ai_run(12);};
void()	bishop_run4	=[	$run4,		bishop_run5	] {ai_run(12);};
void()	bishop_run5	=[	$run5,		bishop_run6	] {ai_run(10);};
void()	bishop_run6	=[	$run6,		bishop_run7	] {ai_run(14);};
void()	bishop_run7	=[	$run7,		bishop_run8	] {ai_run(12);};
void()	bishop_run8	=[	$run8,		bishop_run1	] {ai_run(10);};

void()   bishop_xatta1  =[ $xatta1,  bishop_xatta2  ] {ai_face();};
void()   bishop_xatta2  =[ $xatta2,  bishop_xatta3  ] {ai_face();};
void()   bishop_xatta3  =[ $xatta3,  bishop_xatta4  ] {ai_face();};
void()   bishop_xatta4  =[ $xatta4,  bishop_xatta5  ] {ai_face();};
void()   bishop_xatta5  =[ $xatta5,  bishop_xatta6  ] {ai_face();};
void()   bishop_xatta6  =[ $xatta6,  bishop_xatta7  ] {bishop_specialfire();};
void()   bishop_xatta7  =[ $xatta7,  bishop_xatta8  ] {};
void()   bishop_xatta8  =[ $xatta8,  bishop_xatta9  ] {};
void()   bishop_xatta9  =[ $xatta9,  bishop_xatta10 ] {};
void()   bishop_xatta10 =[ $xatta10, bishop_xatta11 ] {};
void()   bishop_xatta11 =[ $xatta11, bishop_xatta12 ] {};
void()   bishop_xatta12 =[ $xatta12, bishop_run1 ] {};

void()	bishop_shoot1	=[	$shoot1,	bishop_shoot2	]
{
   ai_face();

   if ((self.last_special < (time - 5)) && (enemy_range >= RANGE_NEAR) && (enemy_range <= RANGE_MID) && (random() < 0.4)) {
      self.last_special = time;
      bishop_xatta1();
      return;
   }

};
void()	bishop_shoot2	=[	$shoot2,	bishop_shoot3	] {ai_face();bishop_fire(6);};
void()	bishop_shoot3	=[	$shoot3,	bishop_shoot4	] {ai_face();};
void()	bishop_shoot4	=[	$shoot4,	bishop_shoot5	] {ai_face();};
void()	bishop_shoot5	=[	$shoot5,	bishop_shoot6	] {ai_face();};
void()	bishop_shoot6	=[	$shoot6,	bishop_shoot7	] {ai_face();bishop_fire(-6);};
void()	bishop_shoot7	=[	$shoot7,	bishop_shoot8	] {ai_face();};
void()	bishop_shoot8	=[	$shoot8,	bishop_run1	] {ai_face();SUB_CheckRefire (bishop_shoot1);};


void()	bishop_pain1	=[	$pain1,		bishop_pain2	] {};
void()	bishop_pain2	=[	$pain2,		bishop_pain3	] {};
void()	bishop_pain3	=[	$pain3,		bishop_pain4	] {};
void()	bishop_pain4	=[	$pain4,		bishop_pain5	] {};
void()	bishop_pain5	=[	$pain5,		bishop_pain6	] {};
void()   bishop_pain6   =[ $pain6,     bishop_pain7   ] {};
void()   bishop_pain7   =[ $pain7,     bishop_pain8   ] {};
void()   bishop_pain8   =[ $pain8,     bishop_pain9   ] {};
void()   bishop_pain9   =[ $pain9,     bishop_run1    ] {};

void()   bishop_paina1   =[ $paina1,     bishop_paina2   ] {};
void()   bishop_paina2   =[ $paina2,     bishop_paina3   ] {};
void()   bishop_paina3   =[ $paina3,     bishop_paina4   ] {};
void()   bishop_paina4   =[ $paina4,     bishop_paina5   ] {};
void()   bishop_paina5   =[ $paina5,     bishop_paina6   ] {};
void()   bishop_paina6   =[ $paina6,     bishop_paina7   ] {};
void()   bishop_paina7   =[ $paina7,     bishop_paina8   ] {};
void()   bishop_paina8   =[ $paina8,     bishop_paina9   ] {};
void()   bishop_paina9   =[ $paina9,     bishop_paina10  ] {};
void()   bishop_paina10  =[ $paina10,    bishop_paina11  ] {};
void()   bishop_paina11  =[ $paina11,    bishop_paina12  ] {};
void()   bishop_paina12  =[ $paina12,    bishop_paina13  ] {};
void()   bishop_paina13  =[ $paina13,    bishop_paina14  ] {};
void()   bishop_paina14  =[ $paina14,    bishop_paina15  ] {};
void()   bishop_paina15  =[ $paina15,    bishop_paina16  ] {};
void()   bishop_paina16  =[ $paina16,    bishop_paina17  ] {};
void()   bishop_paina17  =[ $paina17,    bishop_paina18  ] {};
void()   bishop_paina18  =[ $paina18,    bishop_paina19  ] {};
void()   bishop_paina19  =[ $paina19,    bishop_paina20  ] {};
void()   bishop_paina20  =[ $paina20,    bishop_paina21  ] {};
void()   bishop_paina21  =[ $paina21,    bishop_paina22  ] {};
void()   bishop_paina22  =[ $paina22,    bishop_paina23  ] {};
void()   bishop_paina23  =[ $paina23,    bishop_run1   ] {};

void(entity attacker, float damage)	bishop_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

   MalePainSound(1);

   r = random();
	if (r < 0.8)
	{
		self.pain_finished = time + 3;
		bishop_pain1 ();
	}
	else
	{
		self.pain_finished = time + 6;
		bishop_paina1 ();
	}
};


void(float  r_ofs) bishop_fire =
{
   local vector   vect;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   ai_face();
   self.effects = self.effects | EF_MUZZLEFLASH;

   makevectors(self.angles);

   // allow for up/down aiming
   vect = normalize(self.enemy.origin - self.origin);
   v_forward_z = vect_z;
   v_forward = normalize(v_forward);

   sound (self, CHAN_WEAPON, "doors/airdoor2.wav", 1, ATTN_NORM);

   launch_spike (self.origin + '0 0 8' + v_forward*14 + v_right * r_ofs, v_forward);
   newmis.classname = "gambit_card";
   setmodel (newmis, "progs/laser.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void() BishopSpecialTouch =
{
        if (other == self.owner)
                return;

   if (other.takedamage == DAMAGE_AIM)
   {
       spawn_touchblood (30);
       T_Damage(other, self, self.owner, 20);
   }

   T_RadiusDamage(self, self.owner, 20, other);

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   remove(self);

};

void() bishop_specialfire =
{
   local vector   vect;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   self.effects = self.effects | EF_MUZZLEFLASH;

   sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);

   vect = (self.enemy.origin - self.origin) + self.enemy.velocity * (vlen(self.enemy.origin - self.origin) / 750);
   vect = normalize(vect);

   launch_spike (self.origin + '0 0 8' + v_forward*14, vect);
   newmis.velocity = newmis.velocity * 0.75;
   newmis.classname = "bishop_special";
   newmis.touch = BishopSpecialTouch;
   newmis.avelocity_z = 300;
   setmodel (newmis, "progs/bisblast.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};


void()	bishop_die1	=[	$death1,	bishop_die2	] {};
void()	bishop_die2	=[	$death2,	bishop_die3	] {};
void()	bishop_die3	=[	$death3,	bishop_die4	] {self.solid = SOLID_NOT;};
void()	bishop_die4	=[	$death4,	bishop_die5	] {};
void()	bishop_die5	=[	$death5,	bishop_die6	] {};
void()	bishop_die6	=[	$death6,	bishop_die7	] {};
void()	bishop_die7	=[	$death7,	bishop_die8	] {};
void()	bishop_die8	=[	$death8,	bishop_die9	] {};
void()	bishop_die9	=[	$death9,	bishop_die10	] {};
void()	bishop_die10	=[	$death10,	bishop_die11	] {};
void()   bishop_die11   =[ $death11,   bishop_die12   ] {};
void()   bishop_die12   =[ $death12,   bishop_die13   ] {};
void()   bishop_die13   =[ $death13,   bishop_die14   ] {};
void()   bishop_die14   =[ $death14,   bishop_die15   ] {};
void()   bishop_die15   =[ $death15,   bishop_die16   ] {};
void()   bishop_die16   =[ $death16,   bishop_die16   ] {};

void() bishop_die =
{

// regular death
   MaleDeathSound(1);
   bishop_die1 ();
};


/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_army =
{
   remove(self);
};

void() xmen_bishop =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model ("progs/bishop.mdl");
   precache_model ("progs/laser.mdl");
   precache_model ("progs/bisblast.mdl");

   // Xmen Sounds: matched ID sounds
   precache_sound ("boss1/throw.wav");
   precache_sound2 ("doors/airdoor2.wav");

/*
   // Old Soldier sounds
   precache_sound ("soldier/death1.wav");
   precache_sound ("soldier/idle.wav");
   precache_sound ("soldier/pain1.wav");
   precache_sound ("soldier/pain2.wav");
   precache_sound ("soldier/sattck1.wav");
   precache_sound ("soldier/sight1.wav");
*/

   precache_sound ("player/udeath.wav");     // gib death

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/bishop.mdl");

   setsize (self, '-16 -16 -24', '16 16 40');
   self.health = 180;

   self.th_stand = bishop_stand1;
   self.th_walk = bishop_walk1;
   self.th_run = bishop_run1;
   self.th_missile = bishop_shoot1;
   self.th_pain = bishop_pain;
   self.th_die = bishop_die;

   walkmonster_start ();
};