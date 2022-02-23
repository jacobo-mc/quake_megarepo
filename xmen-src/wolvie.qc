/*
==============================================================================

WOLVERINE

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

.float in_pain;

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11 paina12 paina13 paina14 paina15 paina16 paina17 paina18 paina19 paina20
$frame paina21 paina22 paina23 paina24 paina25 paina26 paina27 paina28 paina29 paina30
$frame paina31 paina32 paina33 paina34 paina35 paina36 paina37 paina38

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9
$frame death10 death11 death12 death13 death14 death15 death16 death17

$frame rise1 rise2 rise3 rise4 rise5 rise6 rise7 rise8 rise9
$frame rise10 rise11 rise12 rise13 rise14 rise15 rise16 rise17 rise18 rise19 rise20
$frame rise21 rise22 rise23 rise24 rise25 rise26 rise27 rise28 rise29 rise30 rise31

$frame deata1 deata2 deata3 deata4 deata5 deata6 deata7 deata8 deata9 deata10
$frame deata11 deata12 deata13 deata14 deata15 deata16 deata17 deata18 deata19 deata20
$frame deata21 deata22 deata23 deata24 deata25 deata26 deata27 deata28 deata29 deata30
$frame deata31 deata32 deata33 deata34 deata35 deata36 deata37 deata38 deata39 deata40
$frame deata41 deata42 deata43 deata44 deata45 deata46 deata47 deata48 deata49

$frame risea1 risea2 risea3 risea4 risea5 risea6 risea7 risea8 risea9 risea10
$frame risea11 risea12 risea13 risea14 risea15 risea16 risea17 risea18 risea19 risea20
$frame risea21 risea22 risea23 risea24 risea25 risea26 risea27 risea28 risea29 risea30
$frame risea31 risea32 risea33 risea34 risea35 risea36 risea37 risea38 risea39 risea40
$frame risea41 risea42 risea43 risea44 risea45 risea46 risea47 risea48 risea49 risea50
$frame risea51 risea52

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================

void()  Demon_JumpTouch;

void()	demon1_stand1	=[	$stand1,	demon1_stand2	] {
    ai_stand();
    sound(self, CHAN_AUTO, "wolvie/breath.wav", 1, 3);};
void()	demon1_stand2	=[	$stand2,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	$stand3,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	$stand4,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	$stand5,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	$stand6,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	$stand7,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	$stand8,	demon1_stand9	] {ai_stand();};
void()	demon1_stand9	=[	$stand9,	demon1_stand10	] {ai_stand();};
void()	demon1_stand10	=[	$stand10,	demon1_stand11	] {ai_stand();};
void()	demon1_stand11	=[	$stand11,	demon1_stand12	] {ai_stand();};
void()	demon1_stand12	=[	$stand12,	demon1_stand13	] {ai_stand();};
void()	demon1_stand13	=[	$stand13,	demon1_stand1	] {ai_stand();};

void()	demon1_walk1	=[	$walk1,		demon1_walk2	] {ai_walk(3);};
void()   demon1_walk2   =[ $walk2,     demon1_walk3   ] {ai_walk(10);};
void()	demon1_walk3	=[	$walk3,		demon1_walk4	] {ai_walk(9);};
void()	demon1_walk4	=[	$walk4,		demon1_walk5	] {ai_walk(10);};
void()	demon1_walk5	=[	$walk5,		demon1_walk6	] {ai_walk(3);};
void()	demon1_walk6	=[	$walk6,		demon1_walk7	] {ai_walk(8);};
void()   demon1_walk7   =[ $walk7,     demon1_walk8   ] {ai_walk(7);};
void()	demon1_walk8	=[	$walk8,		demon1_walk1	] {ai_walk(10);};

void()  demon1_run1 =[  $run1,      demon1_run2 ] {
    ai_run(15);
    /*sound(self, CHAN_AUTO, "wolvie/step.wav", 1, ATTN_NORM);*/};
void()  demon1_run2 =[  $run2,      demon1_run3 ] {ai_run(12);};
void()  demon1_run3 =[  $run3,      demon1_run4 ] {ai_run(28);};
void()  demon1_run4 =[  $run4,      demon1_run5 ] {ai_run(15);};
void()  demon1_run5 =[  $run5,      demon1_run6 ] {
    ai_run(12);
    /*sound(self, CHAN_AUTO, "wolvie/step.wav", 1, ATTN_NORM);*/};
void()  demon1_run6 =[  $run6,      demon1_run1 ] {ai_run(28);};

void() SetJumpAngle =
{
    local vector    vel;

    vel = normalize(self.velocity);
    self.angles = vectoangles(vel);
    if (self.angles_x < 0)
        self.angles_x = 0;
};

void()	demon1_jump1	=[	$leap1,		demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	$leap2,		demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	$leap3,		demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	$leap4,		demon1_jump5	]
{

	ai_face();

    self.touch = Demon_JumpTouch;

   self.angles = vectoangles(self.enemy.origin - self.origin);
   self.angles_x = 0;
	makevectors (self.angles);

	self.origin_z = self.origin_z + 1;
    v_forward_z = -1 * v_forward_z;
    self.velocity = v_forward * 700 + '0 0 150';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()  demon1_jump5    =[  $leap5,     demon1_jump6    ] {SetJumpAngle();};
void()  demon1_jump6    =[  $leap6,     demon1_jump7    ] {SetJumpAngle();};
void()  demon1_jump7    =[  $leap7,     demon1_jump8    ] {SetJumpAngle();};
void()  demon1_jump8    =[  $leap8,     demon1_jump9    ] {SetJumpAngle();};
void()  demon1_jump9    =[  $leap9,     demon1_jump10   ]
{
    SetJumpAngle();
};
void()  demon1_jump10   =[  $leap10,    demon1_jump1    ] {
self.nextthink = time + 3;
// if three seconds pass, assume demon is stuck and jump again
};

void()	demon1_jump11	=[ 	$leap11,	demon1_jump12	] {};
void()  demon1_jump12   =[  $leap12,    demon1_walk1 ] {self.angles_x = 0;};

float() CheckDemonMelee;
void()  demon1_atta1    =[  $attacka1,      demon1_atta2    ] {ai_charge(5);};
void()  demon1_atta2    =[  $attacka2,      demon1_atta3    ] {ai_charge(5);};
void()  demon1_atta3    =[  $attacka3,      demon1_atta4    ] {ai_charge(5);};
void()  demon1_atta4    =[  $attacka4,      demon1_atta5    ] {ai_charge(5);};
void()  demon1_atta5    =[  $attacka5,      demon1_atta6    ] {ai_charge(5); Demon_Melee(200);};
void()  demon1_atta6    =[  $attacka6,      demon1_atta7    ] {ai_charge(5);};
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	]
{
        ai_charge(5);

        if (vlen(self.enemy.origin - self.origin) > 100) {      // abort attack
                self.think = self.th_run;
        }
};
void()  demon1_atta8    =[  $attacka8,      demon1_atta9    ] {ai_charge(5);};
void()  demon1_atta9    =[  $attacka9,      demon1_atta10] {ai_charge(5);};
void()  demon1_atta10   =[  $attacka10,     demon1_atta11] {ai_charge(5);};
void()	demon1_atta11	=[	$attacka11,		demon1_atta12]
{
    // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
    //local float rnd;

    Demon_Melee(-200);
};
void()  demon1_atta12   =[  $attacka12,     demon1_atta13] {ai_charge(5);};
void()  demon1_atta13   =[  $attacka13,     demon1_atta14] {ai_charge(5);};
void()  demon1_atta14   =[  $attacka14,     demon1_atta15] {ai_charge(5);};
void()  demon1_atta15   =[  $attacka15,     demon1_run1] {
    ai_charge(5);
    if (CheckDemonMelee()) {
        if (self.enemy.health > 0)
           self.think = demon1_atta1;
        else
           self.think = self.th_walk;
    }
};

void()  demon1_pain1    =[      $pain1,         demon1_pain2    ] {self.in_pain = TRUE;};
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {};
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {};
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {};
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {};
void()  demon1_pain6    =[      $pain6,         demon1_run1     ] {self.in_pain = FALSE;};

void()  demon1_paina1     =[  $paina1,        demon1_paina2 ] {self.in_pain = TRUE;};
void()  demon1_paina2     =[  $paina2,        demon1_paina3 ] {};
void()  demon1_paina3     =[  $paina3,        demon1_paina4 ] {};
void()  demon1_paina4     =[  $paina4,        demon1_paina5 ] {};
void()  demon1_paina5     =[  $paina5,        demon1_paina6 ] {};
void()  demon1_paina6     =[  $paina6,        demon1_paina7 ] {};
void()  demon1_paina7     =[  $paina7,        demon1_paina8 ] {};
void()  demon1_paina8     =[  $paina8,        demon1_paina9 ] {};
void()  demon1_paina9     =[  $paina9,        demon1_paina10 ] {};
void()  demon1_paina10    =[  $paina10,       demon1_paina11 ] {};
void()  demon1_paina11    =[  $paina11,       demon1_paina12 ] {};
void()  demon1_paina12    =[  $paina12,       demon1_paina13 ] {};
void()  demon1_paina13    =[  $paina13,       demon1_paina14 ] {};
void()  demon1_paina14    =[  $paina14,       demon1_paina15 ] {};
void()  demon1_paina15    =[  $paina15,       demon1_paina16 ] {};
void()  demon1_paina16    =[  $paina16,       demon1_paina17 ] {};
void()  demon1_paina17    =[  $paina17,       demon1_paina18 ] {};
void()  demon1_paina18    =[  $paina18,       demon1_paina19 ] {};
void()  demon1_paina19    =[  $paina19,       demon1_paina20 ] {};
void()  demon1_paina20    =[  $paina20,       demon1_paina21 ] {};
void()  demon1_paina21    =[  $paina21,       demon1_paina22 ] {};
void()  demon1_paina22    =[  $paina22,       demon1_paina23 ] {};
void()  demon1_paina23    =[  $paina23,       demon1_paina24 ] {};
void()  demon1_paina24    =[  $paina24,       demon1_paina25 ] {};
void()  demon1_paina25    =[  $paina25,       demon1_paina26 ] {};
void()  demon1_paina26    =[  $paina26,       demon1_paina27 ] {};
void()  demon1_paina27    =[  $paina27,       demon1_paina28 ] {};
void()  demon1_paina28    =[  $paina28,       demon1_paina29 ] {};
void()  demon1_paina29    =[  $paina29,       demon1_paina30 ] {};
void()  demon1_paina30    =[  $paina30,       demon1_paina31 ] {};
void()  demon1_paina31    =[  $paina31,       demon1_paina32 ] {};
void()  demon1_paina32    =[  $paina32,       demon1_paina33 ] {};
void()  demon1_paina33    =[  $paina33,       demon1_paina34 ] {};
void()  demon1_paina34    =[  $paina34,       demon1_paina35 ] {};
void()  demon1_paina35    =[  $paina35,       demon1_paina36 ] {};
void()  demon1_paina36    =[  $paina36,       demon1_paina37 ] {};
void()  demon1_paina37    =[  $paina37,       demon1_run1   ] {self.in_pain = FALSE;};

void(entity attacker, float damage)	demon1_pain =
{
        // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
        //local vector    vect;
        //local float     rnd;

	if (self.touch == Demon_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;

   MalePainSound(2);

	if (random()*200 > damage)
		return;		// didn't flinch

        if (attacker.classname == "player") {
                self.enemy = attacker;
        }

    if (self.in_pain)
        return;

    if (damage > 60)
        demon1_paina1 ();
    else
        demon1_pain1 ();
};

void()  demon1_die17;
void() demon1_rise1             =[      $rise1,         demon1_rise2]
{
        self.solid = SOLID_SLIDEBOX;
        if (!walkmove(0,0)) {
            self.think = demon1_rise1;
            self.solid = SOLID_NOT;
            self.nextthink = time + 1;      // try again in 1 second

            return;
        }

        self.skin = 0;

   self.speed = self.speed - 0.35;
   self.health = self.start_health * self.speed;
   SetDamageSkin(self);
};
void() demon1_rise2             =[      $rise2,         demon1_rise3] {};
void() demon1_rise3             =[      $rise3,         demon1_rise4] {};
void() demon1_rise4             =[      $rise4,         demon1_rise5] {};
void() demon1_rise5             =[      $rise5,         demon1_rise6] {};
void() demon1_rise6             =[      $rise6,         demon1_rise7] {};
void() demon1_rise7             =[      $rise7,         demon1_rise8] {};
void() demon1_rise8             =[      $rise8,         demon1_rise9] {};
void() demon1_rise9             =[      $rise9,         demon1_rise10] {};
void() demon1_rise10            =[      $rise10,        demon1_rise11] {};
void() demon1_rise11            =[      $rise11,        demon1_rise12] {};
void() demon1_rise12            =[      $rise12,        demon1_rise13] {};
void() demon1_rise13            =[      $rise13,        demon1_rise14] {};
void() demon1_rise14            =[      $rise14,        demon1_rise15] {};
void() demon1_rise15            =[      $rise15,        demon1_rise16] {};
void() demon1_rise16            =[      $rise16,        demon1_rise17] {};
void() demon1_rise17            =[      $rise17,        demon1_rise18] {};
void() demon1_rise18            =[      $rise18,        demon1_rise19] {};
void() demon1_rise19            =[      $rise19,        demon1_rise20] {};
void() demon1_rise20            =[      $rise20,        demon1_rise21] {};
void() demon1_rise21            =[      $rise21,        demon1_rise22] {};
void() demon1_rise22            =[      $rise22,        demon1_rise23] {};
void() demon1_rise23            =[      $rise23,        demon1_rise24] {};
void() demon1_rise24            =[      $rise24,        demon1_rise25] {};
void() demon1_rise25            =[      $rise25,        demon1_rise26] {};
void() demon1_rise26            =[      $rise26,        demon1_rise27] {};
void() demon1_rise27            =[      $rise27,        demon1_rise28] {};
void() demon1_rise28            =[      $rise28,        demon1_rise29] {};
void() demon1_rise29            =[      $rise29,        demon1_rise30] {};
void() demon1_rise30            =[      $rise30,        demon1_rise31] {};
void() demon1_rise31            =[      $rise31,        demon1_run1]
{
//    self.solid = SOLID_SLIDEBOX;
//    self.movetype = MOVETYPE_STEP;
//        self.enemy = world;
	self.takedamage = DAMAGE_AIM;
};

void()	demon1_die1		=[	$death1,		demon1_die2	] {};
void()  demon1_die2     =[  $death2,        demon1_die3 ] {};
void()  demon1_die3     =[  $death3,        demon1_die4 ] {};
void()  demon1_die4     =[  $death4,        demon1_die5 ] {};
void()  demon1_die5     =[  $death5,        demon1_die6 ] {};
void()  demon1_die6     =[  $death6,        demon1_die7 ] {self.solid = SOLID_NOT;};
void()  demon1_die7     =[  $death7,        demon1_die8 ] {};
void()  demon1_die8     =[  $death8,        demon1_die9 ] {};
void()  demon1_die9             =[      $death9,                demon1_die10 ] {};
void()  demon1_die10            =[      $death10,               demon1_die11 ] {};
void()  demon1_die11            =[      $death11,               demon1_die12 ] {};
void()  demon1_die12            =[      $death12,               demon1_die13 ] {};
void()  demon1_die13            =[      $death13,               demon1_die14 ] {};
void()  demon1_die14            =[      $death14,               demon1_die15 ] {};
void()  demon1_die15            =[      $death15,               demon1_die16 ] {};
void()  demon1_die16            =[      $death16,               demon1_die17 ] {};
void()  demon1_die17            =[      $death17,               demon1_die17 ]
{
   if (self.speed < 0.4)
      return;

   self.in_pain = FALSE;

   if (!(self.spawnflags & SPAWNFLAG_CLONE)) {
      self.think = demon1_rise1;
      self.nextthink = time + 20* random() + 20;
   }
};

void()  demon1_risea1;
void()  demon1_diea1     =[  $deata1,        demon1_diea2 ] {};
void()  demon1_diea2     =[  $deata2,        demon1_diea3 ] {};
void()  demon1_diea3     =[  $deata3,        demon1_diea4 ] {};
void()  demon1_diea4     =[  $deata4,        demon1_diea5 ] {};
void()  demon1_diea5     =[  $deata5,        demon1_diea6 ] {self.solid = SOLID_NOT;};
void()  demon1_diea6     =[  $deata6,        demon1_diea7 ] {};
void()  demon1_diea7     =[  $deata7,        demon1_diea8 ] {};
void()  demon1_diea8     =[  $deata8,        demon1_diea9 ] {};
void()  demon1_diea9     =[  $deata9,        demon1_diea10 ] {};
void()  demon1_diea10    =[  $deata10,       demon1_diea11 ] {};
void()  demon1_diea11    =[  $deata11,       demon1_diea12 ] {};
void()  demon1_diea12    =[  $deata12,       demon1_diea13 ] {};
void()  demon1_diea13    =[  $deata13,       demon1_diea14 ] {};
void()  demon1_diea14    =[  $deata14,       demon1_diea15 ] {};
void()  demon1_diea15    =[  $deata15,       demon1_diea16 ] {};
void()  demon1_diea16    =[  $deata16,       demon1_diea17 ] {};
void()  demon1_diea17    =[  $deata17,       demon1_diea18 ] {};
void()  demon1_diea18    =[  $deata18,       demon1_diea19 ] {};
void()  demon1_diea19    =[  $deata19,       demon1_diea20 ] {};
void()  demon1_diea20    =[  $deata20,       demon1_diea21 ] {};
void()  demon1_diea21    =[  $deata21,       demon1_diea22 ] {};
void()  demon1_diea22    =[  $deata22,       demon1_diea23 ] {};
void()  demon1_diea23    =[  $deata23,       demon1_diea24 ] {};
void()  demon1_diea24    =[  $deata24,       demon1_diea25 ] {};
void()  demon1_diea25    =[  $deata25,       demon1_diea26 ] {};
void()  demon1_diea26    =[  $deata26,       demon1_diea27 ] {};
void()  demon1_diea27    =[  $deata27,       demon1_diea28 ] {};
void()  demon1_diea28    =[  $deata28,       demon1_diea29 ] {};
void()  demon1_diea29    =[  $deata29,       demon1_diea30 ] {};
void()  demon1_diea30    =[  $deata30,       demon1_diea31 ] {};
void()  demon1_diea31    =[  $deata31,       demon1_diea32 ] {};
void()  demon1_diea32    =[  $deata32,       demon1_diea33 ] {};
void()  demon1_diea33    =[  $deata33,       demon1_diea34 ] {};
void()  demon1_diea34    =[  $deata34,       demon1_diea35 ] {};
void()  demon1_diea35    =[  $deata35,       demon1_diea36 ] {};
void()  demon1_diea36    =[  $deata36,       demon1_diea37 ] {};
void()  demon1_diea37    =[  $deata37,       demon1_diea38 ] {};
void()  demon1_diea38    =[  $deata38,       demon1_diea39 ] {};
void()  demon1_diea39    =[  $deata39,       demon1_diea40 ] {};
void()  demon1_diea40    =[  $deata40,       demon1_diea41 ] {};
void()  demon1_diea41    =[  $deata41,       demon1_diea42 ] {};
void()  demon1_diea42    =[  $deata42,       demon1_diea43 ] {};
void()  demon1_diea43    =[  $deata43,       demon1_diea44 ] {};
void()  demon1_diea44    =[  $deata44,       demon1_diea45 ] {};
void()  demon1_diea45    =[  $deata45,       demon1_diea46 ] {};
void()  demon1_diea46    =[  $deata46,       demon1_diea47 ] {};
void()  demon1_diea47    =[  $deata47,       demon1_diea48 ] {};
void()  demon1_diea48    =[  $deata48,       demon1_diea49 ] {};
void()  demon1_diea49    =[  $deata49,       demon1_diea49 ]
{
   local float rise_delay;

   if (self.speed < 0.4)
      return;

   self.in_pain = FALSE;

   if (!(self.spawnflags & SPAWNFLAG_CLONE)) {
      self.think = demon1_risea1;
      rise_delay = (-0.5 * self.health) + 15;
      if (rise_delay > 45) rise_delay = 45;
      else if (rise_delay < 20) rise_delay = 20;
      self.nextthink = time + rise_delay;
   }
};

void()  demon1_risea1     =[  $risea1,        demon1_risea2 ]
{
        self.solid = SOLID_SLIDEBOX;
        if (!walkmove(0,0)) {
            self.think = demon1_risea1;
            self.solid = SOLID_NOT;
            self.nextthink = time + 1;      // try again in 1 second

            return;
        }

        self.skin = 0;

   self.speed = self.speed - 0.35;
   self.health = self.start_health * self.speed;
   SetDamageSkin(self);

};
void()  demon1_risea2     =[  $risea2,        demon1_risea3 ] {};
void()  demon1_risea3     =[  $risea3,        demon1_risea4 ] {};
void()  demon1_risea4     =[  $risea4,        demon1_risea5 ] {};
void()  demon1_risea5     =[  $risea5,        demon1_risea6 ] {};
void()  demon1_risea6     =[  $risea6,        demon1_risea7 ] {};
void()  demon1_risea7     =[  $risea7,        demon1_risea8 ] {};
void()  demon1_risea8     =[  $risea8,        demon1_risea9 ] {};
void()  demon1_risea9     =[  $risea9,        demon1_risea10 ] {};
void()  demon1_risea10    =[  $risea10,       demon1_risea11 ] {};
void()  demon1_risea11    =[  $risea11,       demon1_risea12 ] {};
void()  demon1_risea12    =[  $risea12,       demon1_risea13 ] {};
void()  demon1_risea13    =[  $risea13,       demon1_risea14 ] {};
void()  demon1_risea14    =[  $risea14,       demon1_risea15 ] {};
void()  demon1_risea15    =[  $risea15,       demon1_risea16 ] {};
void()  demon1_risea16    =[  $risea16,       demon1_risea17 ] {};
void()  demon1_risea17    =[  $risea17,       demon1_risea18 ] {};
void()  demon1_risea18    =[  $risea18,       demon1_risea19 ] {};
void()  demon1_risea19    =[  $risea19,       demon1_risea20 ] {};
void()  demon1_risea20    =[  $risea20,       demon1_risea21 ] {};
void()  demon1_risea21    =[  $risea21,       demon1_risea22 ] {};
void()  demon1_risea22    =[  $risea22,       demon1_risea23 ] {};
void()  demon1_risea23    =[  $risea23,       demon1_risea24 ] {};
void()  demon1_risea24    =[  $risea24,       demon1_risea25 ] {};
void()  demon1_risea25    =[  $risea25,       demon1_risea26 ] {};
void()  demon1_risea26    =[  $risea26,       demon1_risea27 ] {};
void()  demon1_risea27    =[  $risea27,       demon1_risea28 ] {};
void()  demon1_risea28    =[  $risea28,       demon1_risea29 ] {};
void()  demon1_risea29    =[  $risea29,       demon1_risea30 ] {};
void()  demon1_risea30    =[  $risea30,       demon1_risea31 ] {};
void()  demon1_risea31    =[  $risea31,       demon1_risea32 ] {};
void()  demon1_risea32    =[  $risea32,       demon1_risea33 ] {};
void()  demon1_risea33    =[  $risea33,       demon1_risea34 ] {};
void()  demon1_risea34    =[  $risea34,       demon1_risea35 ] {};
void()  demon1_risea35    =[  $risea35,       demon1_risea36 ] {};
void()  demon1_risea36    =[  $risea36,       demon1_risea37 ] {};
void()  demon1_risea37    =[  $risea37,       demon1_risea38 ] {};
void()  demon1_risea38    =[  $risea38,       demon1_risea39 ] {};
void()  demon1_risea39    =[  $risea39,       demon1_risea40 ] {};
void()  demon1_risea40    =[  $risea40,       demon1_risea41 ] {};
void()  demon1_risea41    =[  $risea41,       demon1_risea42 ] {};
void()  demon1_risea42    =[  $risea42,       demon1_risea43 ] {};
void()  demon1_risea43    =[  $risea43,       demon1_risea44 ] {};
void()  demon1_risea44    =[  $risea44,       demon1_risea45 ] {};
void()  demon1_risea45    =[  $risea45,       demon1_risea46 ] {};
void()  demon1_risea46    =[  $risea46,       demon1_risea47 ] {};
void()  demon1_risea47    =[  $risea47,       demon1_risea48 ] {};
void()  demon1_risea48    =[  $risea48,       demon1_risea49 ] {};
void()  demon1_risea49    =[  $risea49,       demon1_risea50 ] {};
void()  demon1_risea50    =[  $risea50,       demon1_risea51 ] {};
void()  demon1_risea51    =[  $risea51,       demon1_risea52 ] {};
void()  demon1_risea52    =[  $risea52,       demon1_run1 ]
{
	self.takedamage = DAMAGE_AIM;
};


void() demon_die =
{
    local float rnd;

    self.angles_x = 0;
    self.skin = 3;

    MaleDeathSound(2);

// regular death
    rnd = random();
    if ((self.health < -20) && (rnd < 0.7))
        demon1_diea1 ();
    else if (rnd < 0.3)
        demon1_diea1 ();
    else
        demon1_die1 ();
};


void() Demon_MeleeAttack =
{
	demon1_atta1 ();
};


/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_demon1 =
{
   remove(self);
};


void() xmen_wolverine =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }
   precache_model ("progs/wolvie2.mdl");

// precache_model ("progs/h_demon.mdl");


   // XMen Matched ID sounds
//   precache_sound ("hknight/sight1.wav");

   precache_sound ("demon/dhit2.wav");
//   precache_sound ("demon/djump.wav");
//   precache_sound ("demon/idle1.wav");

// Wolvie sounds
   precache_sound ("wolvie/breath.wav");
// end

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/wolvie2.mdl");
   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

   self.health = 210 + cvar("skill")*10;
   self.speed = 1;      // used to reduce health for each regen.

   self.in_pain = FALSE;

   self.th_stand = demon1_stand1;
   self.th_walk = demon1_walk1;
   self.th_run = demon1_run1;
   self.th_die = demon_die;
   self.th_melee = Demon_MeleeAttack;     // one of two attacks
   self.th_missile = demon1_jump1;        // jump attack
   self.th_pain = demon1_pain;

   walkmonster_start();
};

/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckDemonMelee =
{
//	if (enemy_range == RANGE_MELEE)
//	{	// FIXME: check canreach
        if (vlen(self.enemy.origin - self.origin) < 128) {
            self.attack_state = AS_MELEE;
            return TRUE;
        }
//	}

	return FALSE;
};

/*
==============
CheckDemonJump

==============
*/
float()	CheckDemonJump =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	vector	dist;
	//local	float	d;

    if (random() < 0.9)
        return FALSE;

    if (vlen(self.origin - self.enemy.origin) > 512)
        return FALSE;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;

	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;

    traceline(self.origin, self.enemy.origin, TRUE, self);
    if (trace_fraction < 1)
        return FALSE;

/*
	dist = self.enemy.origin - self.origin;
	dist_z = 0;

	d = vlen(dist);

	if (d < 100)
		return FALSE;

	if (d > 200)
	{
//        if (random() < 0.9)
			return FALSE;
	}
*/

	return TRUE;
};

float()	DemonCheckAttack =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local	vector	vec;
	//local   float   rnd;

// if close enough for slashing, go for it
    if ((CheckDemonMelee ()) && (self.health > 50))
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}

	if (CheckDemonJump ())
	{
		self.attack_state = AS_MISSILE;

		return TRUE;
	}

	return FALSE;
};


//===========================================================================

void(float side)	Demon_Melee =
{
	local	float	ldmg;
	local vector	delta;

   ai_face ();
   walkmove (self.ideal_yaw, 12);	// allow a little closing

   delta = self.enemy.origin - self.origin;

   if (vlen(delta) > 64)
      return;
   if (!CanDamage (self.enemy, self))
      return;

   ldmg = 4 + random() * 2;
	ldmg = rint(ldmg);

   sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	T_Damage (self.enemy, self, self, ldmg);

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void()	Demon_JumpTouch =
{

	local	float	ldmg;
    local vector    dir;

	if (self.health <= 0)
		return;

    // check for enemy getting hit
    dir = normalize(self.velocity);
    traceline(self.origin, self.origin + dir * 64, FALSE, self);
    if ((trace_ent != world) && (trace_ent == self.enemy)) {
        ldmg = (5 * cvar("skill")) + 10*random();
        T_Damage (other, self, self, ldmg);
        trace_ent.punchangle_x = -10;
    }

//    if (other.takedamage)
//    {
//        if ( vlen(self.velocity) > 400 )
//        {
//            ldmg = (5 * cvar("skill")) + 10*random();
//            T_Damage (other, self, self, ldmg);
//        }
//    }

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = demon1_jump1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};

