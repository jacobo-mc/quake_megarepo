/*
==============================================================================

beast

==============================================================================
*/
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame runa1 runa2 runa3 runa4 runa5 runa6 runa7 runa8 runa9 runa10
$frame runa11 runa12

$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8 runb9 runb10
$frame runb11 runb12

$frame runc1 runc2 runc3 runc4 runc5 runc6 runc7 runc8 runc9 runc10
$frame runc11 runc12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12

$frame deata1 deata2 deata3 deata4 deata5 deata6 deata7 deata8 deata9 deata10
$frame deata11 deata12

$frame atta1 atta2 atta3 atta4 atta5 atta6 atta7 atta8
$frame atta9 atta10 atta11 atta12

$frame attb1 attb2 attb3 attb4 attb5 attb6 attb7 attb8
$frame attb9 attb10 attb11 attb12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8
$frame xatta9 xatta10 xatta11 xatta12 xatta13 xatta14 xatta15 xatta16 xatta17 xatta18


void() beast_atta1;
void() beast_atta8;
void() beast_runa1;

/*
================
beast_bite

================
*/
void() beast_bite =
{
local vector   delta;
local float    ldmg;
local entity   plyr;

   makevectors(self.v_angle);
   if ((plyr = FindSightEnemy(self.origin, v_forward, 60, 40, "all", self)) == world)
      return;

   delta = plyr.origin - self.origin;

   if (vlen(delta) > 60)
      return;

   ldmg = 9 + random() * 3;
   T_Damage (plyr, self, self, ldmg);

   if (self.frame >= $attb1 ) {
      if (random() < 0.5)
         sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
      else
         sound(self, CHAN_WEAPON, "generic/punch3.wav", 1, ATTN_NORM);
   }
   else
      sound(self, CHAN_WEAPON, "generic/punch1.wav", 1, ATTN_NORM);

};

/*
void()	beast_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;

	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 300 )
		{
			ldmg = 15 + 10*random();
			T_Damage (other, self, self, ldmg);
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//bprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = beast_atta1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = beast_atta8;
	self.nextthink = time + 0.05;
};
*/

void() beast_stand1	=[	$stand1,	beast_stand2	] {ai_stand();};
void() beast_stand2	=[	$stand2,	beast_stand3	] {ai_stand();};
void() beast_stand3	=[	$stand3,	beast_stand4	] {ai_stand();};
void() beast_stand4	=[	$stand4,	beast_stand5	] {ai_stand();};
void() beast_stand5	=[	$stand5,	beast_stand6	] {ai_stand();};
void() beast_stand6	=[	$stand6,	beast_stand7	] {ai_stand();};
void() beast_stand7	=[	$stand7,	beast_stand8	] {ai_stand();};
void() beast_stand8	=[	$stand8,	beast_stand9	] {ai_stand();};
void() beast_stand9 =[ $stand9, beast_stand10  ] {ai_stand();};
void() beast_stand10	=[	$stand10,	beast_stand11	] {ai_stand();};
void() beast_stand11   =[ $stand11,   beast_stand12 ] {ai_stand();};
void() beast_stand12   =[ $stand12,   beast_stand13 ] {ai_stand();};
void() beast_stand13   =[ $stand13,   beast_stand1 ] {ai_stand();};

/*
void() beast_walk1	=[	$walk1 ,	beast_walk2	] {
ai_walk(8);};
void() beast_walk2	=[	$walk2 ,	beast_walk3	] {ai_walk(8);};
void() beast_walk3	=[	$walk3 ,	beast_walk4	] {ai_walk(8);};
void() beast_walk4	=[	$walk4 ,	beast_walk5	] {ai_walk(8);};
void() beast_walk5	=[	$walk5 ,	beast_walk6	] {ai_walk(8);};
void() beast_walk6	=[	$walk6 ,	beast_walk7	] {ai_walk(8);};
void() beast_walk7	=[	$walk7 ,	beast_walk8	] {ai_walk(8);};
void() beast_walk8	=[	$walk8 ,	beast_walk1	] {ai_walk(8);};
*/

void() beast_random_run;

void() beast_runa1     =[ $runa1 , beast_runa2   ] {
ai_run(32);};
void() beast_runa2     =[ $runa2  ,   beast_runa3   ] {ai_run(32);};
void() beast_runa3     =[ $runa3  ,   beast_runa4   ] {ai_run(32);};
void() beast_runa4     =[ $runa4  ,   beast_runa5   ] {ai_run(20);};
void() beast_runa5     =[ $runa5  ,   beast_runa6   ] {ai_run(32);};
void() beast_runa6     =[ $runa6  ,   beast_runa7   ] {ai_run(32);};
void() beast_runa7     =[ $runa7  ,   beast_runa8   ] {ai_run(26);};
void() beast_runa8     =[ $runa8  ,   beast_runa9   ] {ai_run(32);};
void() beast_runa9     =[ $runa9  ,   beast_runa10  ] {ai_run(32);};
void() beast_runa10 =[ $runa10  ,  beast_runa11  ] {ai_run(20);};
void() beast_runa11 =[ $runa11  ,  beast_runa12  ] {ai_run(32);};
void() beast_runa12 =[ $runa12  ,  beast_runa1   ]
{
   ai_run(32);
   beast_random_run();
};

void() beast_runb1     =[ $runb1 , beast_runb2   ] {
ai_run(32);};
void() beast_runb2     =[ $runb2  ,   beast_runb3   ] {ai_run(32);};
void() beast_runb3     =[ $runb3  ,   beast_runb4   ] {ai_run(32);};
void() beast_runb4     =[ $runb4  ,   beast_runb5   ] {ai_run(20);};
void() beast_runb5     =[ $runb5  ,   beast_runb6   ] {ai_run(32);};
void() beast_runb6     =[ $runb6  ,   beast_runb7   ] {ai_run(32);};
void() beast_runb7     =[ $runb7  ,   beast_runb8   ] {ai_run(26);};
void() beast_runb8     =[ $runb8  ,   beast_runb9   ] {ai_run(32);};
void() beast_runb9     =[ $runb9  ,   beast_runb10  ] {ai_run(32);};
void() beast_runb10 =[ $runb10  ,  beast_runb11  ] {ai_run(20);};
void() beast_runb11 =[ $runb11  ,  beast_runb12  ] {ai_run(32);};
void() beast_runb12 =[ $runb12  ,  beast_runb1   ]
{
   ai_run(32);
   beast_random_run();
};

void() beast_runc1     =[ $runc1 , beast_runc2   ] {
ai_run(32);};
void() beast_runc2     =[ $runc2  ,   beast_runc3   ] {ai_run(32);};
void() beast_runc3     =[ $runc3  ,   beast_runc4   ] {ai_run(32);};
void() beast_runc4     =[ $runc4  ,   beast_runc5   ] {ai_run(20);};
void() beast_runc5     =[ $runc5  ,   beast_runc6   ] {ai_run(32);};
void() beast_runc6     =[ $runc6  ,   beast_runc7   ] {ai_run(32);};
void() beast_runc7     =[ $runc7  ,   beast_runc8   ] {ai_run(26);};
void() beast_runc8     =[ $runc8  ,   beast_runc9   ] {ai_run(32);};
void() beast_runc9     =[ $runc9  ,   beast_runc10  ] {ai_run(32);};
void() beast_runc10 =[ $runc10  ,  beast_runc11  ] {ai_run(20);};
void() beast_runc11 =[ $runc11  ,  beast_runc12  ] {ai_run(32);};
void() beast_runc12 =[ $runc12  ,  beast_runc1   ]
{
   ai_run(32);
   beast_random_run();
};

void() beast_random_run =
{
   local float    rnd;

   rnd = random() * 3;

   if (rnd < 1)
      self.think = beast_runa1;
   else if (rnd < 2)
      self.think = beast_runb1;
   else
      self.think = beast_runc1;
};

float()  CheckbeastMelee;

void() beast_attb1  =[ $attb1,  beast_attb2   ] {ai_charge(10);};
void() beast_attb2  =[ $attb2,  beast_attb3   ] {ai_charge(10);};
void() beast_attb3  =[ $attb3,  beast_attb4   ] {ai_charge(10);};
void() beast_attb4  =[ $attb4,  beast_attb5   ] {
beast_bite();};
void() beast_attb5  =[ $attb5,  beast_attb6   ] {ai_charge(10);};
void() beast_attb6  =[ $attb6,  beast_attb7   ]
{
   ai_charge(10);

   // check if enemy is still in striking distance
   if (!CheckbeastMelee())
      beast_runa1();
};
void() beast_attb7  =[ $attb7,  beast_attb8   ] {
beast_bite();};
void() beast_attb8  =[ $attb8,  beast_attb9   ] {ai_charge(10);};
void() beast_attb9  =[ $attb9,   beast_attb10 ] {ai_charge(10);};
void() beast_attb10  =[ $attb10,   beast_attb11 ] {
beast_bite();};
void() beast_attb11  =[ $attb11,   beast_attb12 ] {ai_charge(10);};
void() beast_attb12  =[ $attb12,   beast_runa1 ] {ai_charge(10);};

void() beast_atta1  =[ $atta1,  beast_atta2   ] {ai_charge(10);};
void() beast_atta2  =[ $atta2,  beast_atta3   ] {ai_charge(10);};
void() beast_atta3  =[ $atta3,  beast_atta4   ] {ai_charge(10);};
void() beast_atta4  =[ $atta4,  beast_atta5   ] {ai_charge(10);};
void() beast_atta5  =[ $atta5,  beast_atta6   ] {ai_charge(10);};
void() beast_atta6  =[ $atta6,  beast_atta7   ] {ai_charge(10);};
void() beast_atta7  =[ $atta7,  beast_atta8   ] {ai_charge(10);};
void() beast_atta8  =[ $atta8,  beast_atta9   ] {ai_charge(10);};
void() beast_atta9  =[ $atta9,   beast_atta10 ] {
beast_bite();
beast_bite();
ai_charge(10);};
void() beast_atta10  =[ $atta10,   beast_atta11 ] {ai_charge(10);};
void() beast_atta11  =[ $atta11,   beast_atta12 ] {ai_charge(10);};
void() beast_atta12  =[ $atta12,   beast_runa1 ] {ai_charge(10);};

void() beast_melee =
{
   if (random() < 0.5)
      beast_atta1();
   else
      beast_attb1();
};


// special attack
void() BeastPowTouch =
{
   local float damg;

   if ((other == self.owner) || (other == world))
      return;

   damg = 25 + random()*10;

   if (other.health)
   {
      T_Damage (other, self, self.owner, damg );
   }

   other.velocity = other.velocity + self.velocity + '0 0 200';
   other.flags = other.flags - (other.flags & FL_ONGROUND);
   setorigin(other, other.origin + '0 0 1');

   sound (self.owner, CHAN_WEAPON, "weapons/r_exp3.wav", 0.2, ATTN_NORM);

   self.origin = self.origin - 8*normalize(self.velocity);

/*
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
*/

//   BecomeExplosion ();
   remove(self);
};

void() BeastPowThink =
{
   local entity   trav;
   local vector   vec;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local float    dist;
   local float    ratio;

   if ((self.spawn_time < (time - 3)) || (self.origin == self.oldorigin)) {
      sound (self.owner, CHAN_WEAPON, "weapons/r_exp3.wav", 0.2, ATTN_NORM);
      remove(self);
      return;
   }

   self.frame = self.frame + 1;
   if (self.frame >= 8)
      self.frame = 0;

   vec = self.velocity;

   traceline(self.origin + vec*frametime*2 + '0 0 32', self.origin + vec*frametime*2 - '0 0 48', TRUE, world);
   if (trace_fraction == 1) {
      sound (self.owner, CHAN_WEAPON, "weapons/r_exp3.wav", 0, ATTN_NORM);
      remove(self);
      return;
   }
   else {
      self.velocity = normalize(trace_endpos + '0 0 24' - self.origin) * 750;

      self.flags = self.flags - (self.flags & FL_ONGROUND);

      traceline(self.origin + '0 0 32', self.origin - '0 0 48', TRUE, world);
      setorigin(self, trace_endpos + '0 0 24');
   }

   // earth-shake
   trav = findradius(self.origin, 512);
   while (trav != world) {
      if (trav.classname == "player") {
         // shake view
         vec = '12 0 0' * random() + '0 12 0' * random() + '0 0 22' * random() - '6 6 14';
         ratio = 1 - (vlen(trav.origin - self.origin) / 512);
         if (ratio > 1)
            ratio = 1;
         vec = vec * ratio;
         trav.view_ofs = '0 0 22' + vec;
         trav.punchangle = vec * 0.5;
         if (trav.view_ofs == '0 0 0')
            trav.view_ofs = '0 0 1';
      }

      trav = trav.chain;
   }

   self.oldorigin = self.origin;

   self.nextthink = time + 0.05;
};

void() BeastSpecialAttack =
{
   local entity   trav;
   local entity   missile;

   missile = spawn();
   missile.classname = "beast_power";
   missile.owner = self;
   missile.solid = SOLID_TRIGGER;
   missile.movetype = MOVETYPE_FLY;

   // 20060704 LordHavoc: swapped setmodel/setsize order to make this work properly rather than being stuck in the floor
   setmodel(missile, "progs/pow.mdl");
   // 20060704 LordHavoc: changed setsize to '-16 16 16', '16 16 16' from '0 0 0', '0 0 0' to mimick the Quake bug that was occurring in setmodel
   setsize(missile, '-16 -16 -16', '16 16 16');
   missile.velocity = normalize(self.enemy.origin - self.origin + self.enemy.velocity * 0.5) * 750;
   missile.velocity_z = 0;
   missile.old_velocity = missile.velocity;

   makevectors(self.angles);

   setorigin(missile, self.origin + v_forward * 16);

   missile.touch = BeastPowTouch;
   missile.think = BeastPowThink;
   missile.spawn_time = time;
   missile.nextthink = time + 0.05;

/*
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, missile.origin_x);
   WriteCoord (MSG_BROADCAST, missile.origin_y);
   WriteCoord (MSG_BROADCAST, missile.origin_z);
*/

   sound (self, CHAN_BODY, "weapons/r_exp3.wav", 0.4, ATTN_NORM);
   sound (self, CHAN_WEAPON, "doors/stndr1.wav", 1, ATTN_NORM);

   // send players airbourne
   trav = find(world, classname, "player");
   while (trav != world) {
      if ((trav.flags & FL_ONGROUND) && (vlen(trav.origin - self.origin) < 256))
         trav.velocity_z = 225;

      trav = find(trav, classname, "player");
   }
};

void() beast_xatta1  =[ $xatta1,  beast_xatta2   ] {self.last_special = time;};
void() beast_xatta2  =[ $xatta2,  beast_xatta3   ] {};
void() beast_xatta3  =[ $xatta3,  beast_xatta4   ] {};
void() beast_xatta4  =[ $xatta4,  beast_xatta5   ] {};
void() beast_xatta5  =[ $xatta5,  beast_xatta6   ] {};
void() beast_xatta6  =[ $xatta6,  beast_xatta7   ] {};
void() beast_xatta7  =[ $xatta7,  beast_xatta8   ] {};
void() beast_xatta8  =[ $xatta8,  beast_xatta9   ] {};
void() beast_xatta9  =[ $xatta9,  beast_xatta10  ] {};
void() beast_xatta10 =[ $xatta10, beast_xatta11  ] {};
void() beast_xatta11 =[ $xatta11, beast_xatta12  ] {BeastSpecialAttack();};
void() beast_xatta12 =[ $xatta12, beast_xatta13  ] {};
void() beast_xatta13 =[ $xatta13, beast_xatta14  ] {};
void() beast_xatta14 =[ $xatta14, beast_xatta15  ] {};
void() beast_xatta15 =[ $xatta15, beast_xatta16  ] {};
void() beast_xatta16 =[ $xatta16, beast_xatta17  ] {};
void() beast_xatta17 =[ $xatta17, beast_xatta18  ] {};
void() beast_xatta18 =[ $xatta18, beast_runa1   ] {};


void() beast_pain1	=[	$pain1 ,	beast_pain2	] {};
void() beast_pain2	=[	$pain2 ,	beast_pain3	] {};
void() beast_pain3	=[	$pain3 ,	beast_pain4	] {};
void() beast_pain4	=[	$pain4 ,	beast_pain5	] {};
void() beast_pain5	=[	$pain5 ,	beast_pain6	] {};
void() beast_pain6	=[	$pain6 ,	beast_runa1	] {};

void(entity attacker, float damage) beast_pain =
{
   if (self.pain_finished > time)
      return;

   MalePainSound(1);

   if (random()*100 > damage)
      return;

   self.pain_finished = time + 2;
   beast_pain1 ();
};

void() beast_die1		=[	$death1,	beast_die2	] {};
void() beast_die2		=[	$death2,	beast_die3	] {};
void() beast_die3		=[	$death3,	beast_die4	] {};
void() beast_die4		=[	$death4,	beast_die5	] {};
void() beast_die5		=[	$death5,	beast_die6	] {};
void() beast_die6		=[	$death6,	beast_die7	] {};
void() beast_die7		=[	$death7,	beast_die8	] {};
void() beast_die8		=[	$death8,	beast_die9	] {};
void() beast_die9		=[	$death9,	beast_die10	] {};
void() beast_die10      =[ $death10, beast_die11 ] {};
void() beast_die11      =[ $death11, beast_die12 ] {};
void() beast_die12      =[ $death12, beast_die12 ] {};

void() beast_diea1      =[ $deata1, beast_diea2 ] {};
void() beast_diea2      =[ $deata2, beast_diea3 ] {};
void() beast_diea3      =[ $deata3, beast_diea4 ] {};
void() beast_diea4      =[ $deata4, beast_diea5 ] {};
void() beast_diea5      =[ $deata5, beast_diea6 ] {};
void() beast_diea6      =[ $deata6, beast_diea7 ] {};
void() beast_diea7      =[ $deata7, beast_diea8 ] {};
void() beast_diea8      =[ $deata8, beast_diea9 ] {};
void() beast_diea9      =[ $deata9, beast_diea10   ] {};
void() beast_diea10      =[ $deata10, beast_diea11 ] {};
void() beast_diea11      =[ $deata11, beast_diea12 ] {};
void() beast_diea12      =[ $deata12, beast_diea12 ] {};


void() beast_die =
{
// regular death
   MaleDeathSound(1);
	self.solid = SOLID_NOT;

	if (random() > 0.5)
		beast_die1 ();
	else
		beast_diea1 ();
};

//============================================================================

/*
==============
CheckbeastMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckbeastMelee =
{
	if ((enemy_range == RANGE_MELEE) && (vlen(self.origin - self.enemy.origin) < 96))
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};

/*
==============
CheckbeastJump

==============
*/
float()	CheckbeastJump =
{
	local	vector	dist, p1, p2;
	local	float	d;

   if (self.last_special > (time - 4))
      return FALSE;

   // check for head room
   traceline(self.origin, self.origin + '0 0 64', TRUE, self);
   if (trace_fraction < 1)
      return FALSE;

   // check if on same level as enemy
   traceline(self.origin, self.origin - '0 0 64', TRUE, self);
   p1 = trace_endpos;

   traceline(self.enemy.origin, self.enemy.origin - '0 0 64', TRUE, self);
   p2 = trace_endpos;

   if (p1_z != p2_z)
      return FALSE;

   // now, check line of sight (between p1 and p2)
   p1 = p1 + '0 0 1';
   p2 = p2 + '0 0 1';

   traceline(p1, p2, TRUE, world);

   if (trace_fraction < 1)
      return FALSE;

	dist = self.enemy.origin - self.origin;
	dist_z = 0;

	d = vlen(dist);

	if (d < 80)
		return FALSE;

	if (d > 256)
		return FALSE;

	return TRUE;
};

float()	beastCheckAttack =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	vector	vec;

// if close enough for slashing, go for it
	if (CheckbeastMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}

	if (CheckbeastJump ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	return FALSE;
};


//===========================================================================

/*QUAKED monster_beast (1 0 0) (-32 -32 -24) (32 32 40) Ambush

*/

void() monster_dog =
{
   remove(self);
};

void() xmen_beast =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model ("progs/beast.mdl");
   precache_model ("progs/pow.mdl");

   // XMen matched ID sounds
//   precache_sound ("zombie/z_hit.wav");
   precache_sound ("zombie/z_miss.wav");
   precache_sound ("doors/stndr1.wav");

   precache_sound ("generic/punch1.wav");
   precache_sound ("generic/punch2.wav");
   precache_sound ("generic/punch3.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/beast.mdl");

   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   self.health = 100 + cvar("skill")*10;

   self.th_stand = beast_stand1;
   self.th_walk = beast_stand1;
   self.th_run = beast_runa1;
   self.th_pain = beast_pain;
   self.th_die = beast_die;
   self.th_melee = beast_melee;
   self.th_missile = beast_xatta1;

   walkmonster_start();
};
