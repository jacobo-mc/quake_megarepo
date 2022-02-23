/*
==============================================================================

CYCLOPS

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26 paina27 paina28 paina29 paina30

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20

$frame deata1 deata2 deata3 deata4 deata5 deata6 deata7 deata8 deata9 deata10
$frame deata11 deata12 deata13 deata14 deata15 deata16 deata17 deata18 deata19 deata20
$frame deata21 deata22 deata23 deata24 deata25 deata26 deata27 deata28 deata29 deata30
$frame deata31 deata32 deata33 deata34 deata35 deata36

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12

/*
void() Cyclops_Laser_Touch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, self.velocity*0.2, 15);
		T_Damage (other, self, self.owner, 15);
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

void(vector org, vector vec) LaunchLaser =
{
	local	vector	vec;

	if (self.classname == "monster_enforcer")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/claser1.mdl");
	setsize (newmis, '0 0 0', '0 0 0');

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Cyclops_Laser_Touch;
};
*/

void() LaserTouch =
{
        if (other == self.owner)
                return;

   if (other.takedamage == DAMAGE_AIM)
   {
                spawn_touchblood (10);
                T_Damage(other, self, self.owner, 10);
                remove(self);
      return;
   }

        self.last_touch = time;

   sound (self, CHAN_WEAPON, "doors/airdoor2.wav", 1, ATTN_NORM);
   if (self.velocity == '0 0 0')
          remove(self);

};

void(vector org, vector dir) spawn_laser =
{
   local entity missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity mpuff;
        local   vector  vect;

   missile = spawn ();
   missile.owner = self;
        missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
        missile.classname = "laser";

// set missile speed

        vect = normalize(dir);

        missile.velocity = ProjectVelocity(1000, '0 0 -16');

        missile.angles = vectoangles(missile.velocity);
        missile.old_velocity = missile.velocity;

        missile.touch = LaserTouch;

// set missile duration
//        missile.last_idle = time;

        missile.last_touch = 0;
        missile.oldorigin = missile.origin;
        missile.nextthink = time + 2;
        // 20060705 LordHavoc: added missile.cnt = time + 0.2; for enhanced laser stuckness check
        missile.cnt = time + 0.2;
//        missile.think = GrenadeExplode;
        missile.think = SUB_Remove;

        setmodel (missile, "progs/claser1.mdl");
        setsize (missile, '0 0 0', '0 0 0');
        setorigin (missile, org);
};


void() enforcer_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);

   sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);

	org = self.origin + v_forward * 1 + '0 0 24';

	spawn_laser(org, self.enemy.origin - self.origin);
};

//============================================================================

void()	enf_stand1	=[	$stand1,	enf_stand2	] {ai_stand();};
void()	enf_stand2	=[	$stand2,	enf_stand3	] {ai_stand();};
void()	enf_stand3	=[	$stand3,	enf_stand4	] {ai_stand();};
void()	enf_stand4	=[	$stand4,	enf_stand5	] {ai_stand();};
void()	enf_stand5	=[	$stand5,	enf_stand6	] {ai_stand();};
void()	enf_stand6	=[	$stand6,	enf_stand7	] {ai_stand();};
void()	enf_stand7	=[	$stand7,	enf_stand8	] {ai_stand();};
void()   enf_stand8  =[ $stand8, enf_stand9  ] {ai_stand();};
void()   enf_stand9  =[ $stand9, enf_stand10 ] {ai_stand();};
void()   enf_stand10 =[ $stand10, enf_stand11 ] {ai_stand();};
void()   enf_stand11 =[ $stand11, enf_stand12 ] {ai_stand();};
void()   enf_stand12 =[ $stand12, enf_stand13 ] {ai_stand();};
void()   enf_stand13 =[ $stand13, enf_stand1  ] {ai_stand();};

void()	enf_walk1	=[	$walk1 ,	enf_walk2	] {
//if (random() < 0.2)
//	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_walk(6);};
void()	enf_walk2	=[	$walk2 ,	enf_walk3	] {ai_walk(8);};
void()	enf_walk3	=[	$walk3 ,	enf_walk4	] {ai_walk(7);};
void()	enf_walk4	=[	$walk4 ,	enf_walk5	] {ai_walk(7);};
void()	enf_walk5	=[	$walk5 ,	enf_walk6	] {ai_walk(7);};
void()	enf_walk6	=[	$walk6 ,	enf_walk7	] {ai_walk(6);};
void()	enf_walk7	=[	$walk7 ,	enf_walk8	] {ai_walk(4);};
void()	enf_walk8	=[	$walk8 ,	enf_walk9	] {ai_walk(7);};
void()	enf_walk9	=[	$walk9 ,	enf_walk10	] {ai_walk(7);};
void()	enf_walk10	=[	$walk10,	enf_walk11	] {ai_walk(6);};
void()	enf_walk11	=[	$walk11,	enf_walk12	] {ai_walk(6);};
void()	enf_walk12	=[	$walk12,	enf_walk1 	] {ai_walk(7);};

void()	enf_run1	=[	$run1  ,	enf_run2	] {
//if (random() < 0.2)
//	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_run(12);};
void()	enf_run2	=[	$run2  ,	enf_run3	] {ai_run(12);};
void()	enf_run3	=[	$run3  ,	enf_run4	] {ai_run(11);};
void()	enf_run4	=[	$run4  ,	enf_run5	] {ai_run(14);};
void()	enf_run5	=[	$run5  ,	enf_run6	] {ai_run(13);};
void()	enf_run6	=[	$run6  ,	enf_run7	] {ai_run(12);};
void()	enf_run7	=[	$run7  ,	enf_run8	] {ai_run(14);};
void()	enf_run8	=[	$run8  ,	enf_run9	] {ai_run(16);};
void()   enf_run9 =[ $run9  , enf_run10 ] {ai_run(13);};
void()   enf_run10 =[ $run10  , enf_run1 ] {ai_run(14);};

void()   enf_pain1   =[ $pain1, enf_pain2  ] {};
void()   enf_pain2   =[ $pain2, enf_pain3  ] {};
void()   enf_pain3   =[ $pain3, enf_pain4  ] {};
void()   enf_pain4   =[ $pain4, enf_pain5  ] {};
void()   enf_pain5   =[ $pain5, enf_pain6  ] {};
void()   enf_pain6   =[ $pain6, enf_run1 ] {};

void()   enf_paina1  =[ $paina1, enf_paina2  ] {self.nextthink = time + 0.05;};
void()   enf_paina2  =[ $paina2, enf_paina3  ] {self.nextthink = time + 0.05;};
void()   enf_paina3  =[ $paina3, enf_paina4  ] {self.nextthink = time + 0.05;};
void()   enf_paina4  =[ $paina4, enf_paina5  ] {self.nextthink = time + 0.05;};
void()   enf_paina5  =[ $paina5, enf_paina6  ] {self.nextthink = time + 0.05;};
void()   enf_paina6  =[ $paina6, enf_paina7  ] {self.nextthink = time + 0.05;};
void()   enf_paina7  =[ $paina7, enf_paina8  ] {self.nextthink = time + 0.05;};
void()   enf_paina8  =[ $paina8, enf_paina9  ] {self.nextthink = time + 0.05;};
void()   enf_paina9  =[ $paina9, enf_paina10 ] {self.nextthink = time + 0.05;};
void()   enf_paina10 =[ $paina10, enf_paina11 ] {self.nextthink = time + 0.05;};
void()   enf_paina11 =[ $paina11, enf_paina12 ] {self.nextthink = time + 0.05;};
void()   enf_paina12 =[ $paina12, enf_paina13 ] {self.nextthink = time + 0.05;};
void()   enf_paina13 =[ $paina13, enf_paina14 ] {self.nextthink = time + 0.05;};
void()   enf_paina14 =[ $paina14, enf_paina15 ] {self.nextthink = time + 0.05;};
void()   enf_paina15 =[ $paina15, enf_paina16 ] {self.nextthink = time + 0.05;};
void()   enf_paina16 =[ $paina16, enf_paina17 ] {self.nextthink = time + 0.05;};
void()   enf_paina17 =[ $paina17, enf_paina18 ] {self.nextthink = time + 0.05;};
void()   enf_paina18 =[ $paina18, enf_paina19 ] {self.nextthink = time + 0.05;};
void()   enf_paina19 =[ $paina19, enf_paina20 ] {self.nextthink = time + 0.05;};
void()   enf_paina20 =[ $paina20, enf_paina21 ] {self.nextthink = time + 0.05;};
void()   enf_paina21 =[ $paina21, enf_paina22 ] {self.nextthink = time + 0.05;};
void()   enf_paina22 =[ $paina22, enf_paina23 ] {self.nextthink = time + 0.05;};
void()   enf_paina23 =[ $paina23, enf_paina24 ] {self.nextthink = time + 0.05;};
void()   enf_paina24 =[ $paina24, enf_paina25 ] {self.nextthink = time + 0.05;};
void()   enf_paina25 =[ $paina25, enf_paina26 ] {self.nextthink = time + 0.05;};
void()   enf_paina26 =[ $paina26, enf_paina27 ] {self.nextthink = time + 0.05;};
void()   enf_paina27 =[ $paina27, enf_paina28 ] {self.nextthink = time + 0.05;};
void()   enf_paina28 =[ $paina28, enf_paina29 ] {self.nextthink = time + 0.05;};
void()   enf_paina29 =[ $paina29, enf_paina30 ] {self.nextthink = time + 0.05;};
void()   enf_paina30 =[ $paina30, enf_run1   ] {self.nextthink = time + 0.05;};


void(entity attacker, float damage) enf_pain;
void()	enf_atk1	=[	$attack1,	enf_atk2	] {ai_face(); self.start_attack_health = self.health;};
void()	enf_atk2	=[	$attack2,	enf_atk3	] {ai_face();};
void()	enf_atk3	=[	$attack3,	enf_atk4	] {ai_face();};
void()	enf_atk4	=[	$attack4,	enf_atk5	] {ai_face();};
void()	enf_atk5	=[	$attack5,	enf_atk6	] {ai_face();};
void()	enf_atk6	=[	$attack6,	enf_atk7	] {ai_face();};
void()	enf_atk7	=[	$attack7,	enf_atk8	] {ai_face();
   if (self.health < self.start_attack_health) {
      enf_pain(self.enemy, self.start_attack_health - self.health);
   }
};
void()	enf_atk8	=[	$attack8,	enf_atk9	] {ai_face();};
void()	enf_atk9	=[	$attack9,	enf_atk10	] {enforcer_fire();};
void()	enf_atk10	=[	$attack10,	enf_atk11	] {ai_face();};
void()	enf_atk11	=[	$attack11,	enf_atk12	] {ai_face();};
void()	enf_atk12	=[	$attack12,	enf_run1	] {ai_face();
SUB_CheckRefire (enf_atk1);
};

void(entity attacker, float damage)	enf_pain =
{
	local float r;

/*
bprint("enforcer pain: ");
bprint(ftos(damage));
bprint("\n");
*/

	r = random ();
	if (self.pain_finished > time)
		return;

   if (random()*200 > damage)
      return;     // didn't flinch

	if ((random()*10 < 8) || ((damage > 50) && (random() < 0.5)))
	{
      MalePainSound(2);
		self.pain_finished = time + 1;
		enf_paina1 ();
	}
	else
	{
      MalePainSound(2);
		self.pain_finished = time + 4;
		enf_paina1 ();
	}
};

//============================================================================




void()	enf_die1	=[	$death1,	enf_die2	] {};
void()	enf_die2	=[	$death2,	enf_die3	] {};
void()	enf_die3	=[	$death3,	enf_die4	] {self.solid = SOLID_NOT;self.ammo_cells = 5;};
void()	enf_die4	=[	$death4,	enf_die5	] {};
void()	enf_die5	=[	$death5,	enf_die6	] {};
void()	enf_die6	=[	$death6,	enf_die7	] {};
void()	enf_die7	=[	$death7,	enf_die8	] {};
void()	enf_die8	=[	$death8,	enf_die9	] {};
void()	enf_die9	=[	$death9,	enf_die10	] {};
void()	enf_die10	=[	$death10,	enf_die11	] {};
void()	enf_die11	=[	$death11,	enf_die12	] {};
void()	enf_die12	=[	$death12,	enf_die13	] {};
void()	enf_die13	=[	$death13,	enf_die14	] {};
void()   enf_die14   =[ $death14,   enf_die15   ] {};
void()   enf_die15   =[ $death15,   enf_die16   ] {};
void()   enf_die16   =[ $death16,   enf_die17   ] {};
void()   enf_die17   =[ $death17,   enf_die18   ] {};
void()   enf_die18   =[ $death18,   enf_die19   ] {};
void()	enf_die19   =[	$death19,	enf_die20	] {};
void()   enf_die20   =[ $death20,   enf_die20   ] {};

void()	enf_fdie1	=[	$deata1,	enf_fdie2	] {};
void()	enf_fdie2	=[	$deata2,	enf_fdie3	] {};
void()	enf_fdie3	=[	$deata3,	enf_fdie4	]
{self.solid = SOLID_NOT;self.ammo_cells = 5;};
void()	enf_fdie4	=[	$deata4,	enf_fdie5	] {};
void()	enf_fdie5	=[	$deata5,	enf_fdie6	] {};
void()	enf_fdie6	=[	$deata6,	enf_fdie7	] {};
void()	enf_fdie7	=[	$deata7,	enf_fdie8	] {};
void()	enf_fdie8	=[	$deata8,	enf_fdie9	] {};
void()	enf_fdie9	=[	$deata9,	enf_fdie10	] {};
void()	enf_fdie10	=[	$deata10,	enf_fdie11	] {};
void()   enf_fdie11  =[ $deata11,   enf_fdie12  ] {};
void()   enf_fdie12  =[ $deata12,   enf_fdie13  ] {};
void()   enf_fdie13  =[ $deata13,   enf_fdie14  ] {};
void()   enf_fdie14  =[ $deata14,   enf_fdie15  ] {};
void()   enf_fdie15  =[ $deata15,   enf_fdie16  ] {};
void()   enf_fdie16  =[ $deata16,   enf_fdie17  ] {};
void()   enf_fdie17  =[ $deata17,   enf_fdie18  ] {};
void()   enf_fdie18  =[ $deata18,   enf_fdie19  ] {};
void()	enf_fdie19	=[	$deata19,	enf_fdie20	] {};
void()   enf_fdie20  =[ $deata20,   enf_fdie21  ] {};
void()   enf_fdie21  =[ $deata21,   enf_fdie22  ] {};
void()   enf_fdie22  =[ $deata22,   enf_fdie23  ] {};
void()   enf_fdie23  =[ $deata23,   enf_fdie24  ] {};
void()   enf_fdie24  =[ $deata24,   enf_fdie25  ] {};
void()   enf_fdie25  =[ $deata25,   enf_fdie26  ] {};
void()   enf_fdie26  =[ $deata26,   enf_fdie27  ] {};
void()   enf_fdie27  =[ $deata27,   enf_fdie28  ] {};
void()   enf_fdie28  =[ $deata28,   enf_fdie29  ] {};
void()   enf_fdie29  =[ $deata29,   enf_fdie30  ] {};
void()   enf_fdie30  =[ $deata30,   enf_fdie31  ] {};
void()   enf_fdie31  =[ $deata31,   enf_fdie32  ] {};
void()   enf_fdie32  =[ $deata32,   enf_fdie33  ] {};
void()   enf_fdie33  =[ $deata33,   enf_fdie34  ] {};
void()   enf_fdie34  =[ $deata34,   enf_fdie35  ] {};
void()   enf_fdie35  =[ $deata35,   enf_fdie36  ] {};
void()   enf_fdie36  =[ $deata36,   enf_fdie36  ] {};

void() enf_die =
{
// regular death
   MaleDeathSound(2);
	if (random() >= 0.4)
		enf_die1 ();
	else
		enf_fdie1 ();
};


/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_enforcer =
{
   remove(self);
};

void() xmen_cyclops =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model2 ("progs/cyclops.mdl");
   precache_model2 ("progs/claser1.mdl");

   // XMen matched ID sounds
   precache_sound2 ("items/inv1.wav");
   precache_sound2 ("doors/airdoor2.wav");

   // Unmatched sounds

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/cyclops.mdl");

   setsize (self, '-16 -16 -24', '16 16 40');
   self.health = 90 + cvar("skill")*10;

   self.th_stand = enf_stand1;
   self.th_walk = enf_walk1;
   self.th_run = enf_run1;
   self.th_pain = enf_pain;
   self.th_die = enf_die;
   self.th_missile = enf_atk1;

   walkmonster_start();
};