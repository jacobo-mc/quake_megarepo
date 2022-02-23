/*************************************************************************

   Apocalypse - Episode 1 Boss

**************************************************************************/

$frame stand101

$frame atta101 atta102 atta103 atta104 atta105 atta106 atta107
$frame atta108 atta109 atta110 atta111 atta112

$frame attb101 attb102 attb103 attb104 attb105 attb106 attb107
$frame attb108 attb109 attb110 attb111 attb112

$frame attc101 attc102 attc103 attc104 attc105 attc106 attc107
$frame attc108 attc109 attc110 attc111 attc112

$frame stomp101 stomp102 stomp103 stomp104 stomp105 stomp106 stomp107
$frame stomp108 stomp109 stomp110

$frame pain101 pain102 pain103 pain104 pain105 pain106 pain107 pain108 pain109 pain110
$frame pain111 pain112 pain113 pain114 pain115 pain116 pain117 pain118 pain119 pain120
$frame pain121 pain122 pain123 pain124 pain125 pain126 pain127 pain128 pain129 pain130
$frame pain131 pain132 pain133 pain134 pain135 pain136 pain137 pain138 pain139 pain140
$frame pain141 pain142 pain143 pain144 pain145 pain146 pain147 pain148 pain149 pain150

//====================================================================================

void() apoc_stand1 = [  $stomp101,  apoc_stand1 ]
{
   if (self.spawn_time < (time - 1)) {
      ai_stand();

      if (self.enemy != world) {
         self.last_flame = time;
         cvar_set("host_framerate", "0.02");
      }
   }
};

//====================================================================================

void() apoc_stomp =
{
   local vector   vect, vecta;
   local float    old_yaw, old_yaw_body;


   if (vlen(self.enemy.origin - self.origin) < 32) {  // in-between legs
//      apoc_attb1();
      return;
   }

   vect = normalize(self.enemy.origin - self.origin);
   vecta = vectoangles(vect);

   // rotate legs
   self = self.leg;
   old_yaw = self.angles_y;

   self.ideal_yaw = self.owner.ideal_yaw;
   ChangeYaw();
   self = self.owner;

   // move body according to the leg movement
   self.angles_y = anglemod(self.angles_y + (self.leg.angles_y - old_yaw));

   // set frame according to the direction of rotation
   if (old_yaw < self.leg.angles_y)
      self.frame = self.frame + 1;
   else
      self.frame = self.frame - 1;

   if (self.frame > $stomp110 )
      self.frame = $stomp101;
   else if (self.frame < $stomp101 )
      self.frame = $stomp110;

   // rotate body
   old_yaw_body = self.angles_y;
   self.ideal_yaw = vecta_y;

   self.angles_y = anglemod(self.angles_y + (self.leg.angles_y - old_yaw));
//   ChangeYaw();
   if (fabs(angle_diff(self.angles_y, self.leg.angles_y)) > 75) {
      self.angles_y = old_yaw_body;
   }

};

//====================================================================================

// this keeps apocalypse facing the player, unless the player goes out of the angle range
void() apoc_face =
{
   local vector   vect, vecta;

   if (vlen(self.enemy.origin - self.origin) < 32) {  // in-between legs
      return;
   }

   vect = normalize(self.enemy.origin - self.origin);
   vecta = vectoangles(vect);

   self.ideal_yaw = vecta_y;

   if (fabs(angle_diff(self.ideal_yaw, self.leg.angles_y)) < 75) {
      ChangeYaw();
   }

};

void() earth_quake_think =
{
   local vector   vec;
   local float    ratio;

   if (self.last_flame < (time - 0.75)) {
      remove(self);
      return;
   }

   // shake view
   vec = '12 0 0' * random() + '0 12 0' * random() + '0 0 22' * random() - '6 6 14';
   ratio = (vlen(self.enemy.origin - self.origin) / 256);
   if (ratio > 1)
      ratio = 1;
   vec = vec * ratio;
   self.enemy.punchangle = vec * (0.75 - (time - self.last_flame));
};

void() apoc_thump =
{
   local entity   thinker;

   makevectors(self.angles);
   if (vlen(self.origin + (v_forward * 128) - self.enemy.origin) < 128)
      T_Damage(self.enemy, self, self, 40);

   sound(self, CHAN_BODY, "apoc/thump.wav", 1, ATTN_NONE);

   thinker = spawn();
   thinker.enemy = self.enemy;
   thinker.last_flame = time;
   thinker.think = earth_quake_think;
   thinker.nextthink = time + 0.05;

   self.nextthink = time + 0.05;
};

void() apoc_atta1 = [ $atta101,    apoc_atta2 ] {apoc_face();};
void() apoc_atta2 = [ $atta102,    apoc_atta3 ] {apoc_face();};
void() apoc_atta3 = [ $atta103,    apoc_atta4 ] {apoc_face();};
void() apoc_atta4 = [ $atta104,    apoc_atta5 ] {apoc_face();};
void() apoc_atta5 = [ $atta105,    apoc_atta6 ] {apoc_face();};
void() apoc_atta6 = [ $atta106,    apoc_atta7 ] {apoc_face(); apoc_thump();};
void() apoc_atta7 = [ $atta107,    apoc_atta8 ] {apoc_face();};
void() apoc_atta8 = [ $atta108,    apoc_atta9 ] {apoc_face();};
void() apoc_atta9 = [ $atta109,    apoc_atta10 ] {apoc_face();};
void() apoc_atta10 = [ $atta110,   apoc_atta11 ] {apoc_face();};
void() apoc_atta11 = [ $atta111,   apoc_atta12 ] {apoc_face();};
void() apoc_atta12 = [ $atta112,   apoc_melee ] {apoc_face();};

void() apoc_swipe =
{
   local vector   vect;
   local float    ang;

   vect = normalize(self.enemy.origin - self.origin);
   vect = vectoangles(vect);

   ang = angle_diff(self.angles_y, vect_y);

   if ((fabs(ang) < 90) && (vlen(self.enemy.origin - self.origin) < 300)) {
      if (!(self.enemy.x_flags & X_PARALLIZED))
         self.enemy.x_flags = self.enemy.x_flags | X_PARALLIZED;

      makevectors(self.angles);
      if (vlen(self.origin + (v_forward * 128) - self.enemy.origin) > 16)
         self.enemy.parallized_velocity = normalize(self.origin + (v_forward * 128) - self.enemy.origin) * 200;
      else
         self.enemy.parallized_velocity = '0 0 0';

      T_Damage(self.enemy, self, self, 2);
   }
};

void() apoc_attb1 = [ $attb101,    apoc_attb2 ] {apoc_face();};
void() apoc_attb2 = [ $attb102,    apoc_attb3 ] {apoc_face();};
void() apoc_attb3 = [ $attb103,    apoc_attb4 ] {apoc_face();};
void() apoc_attb4 = [ $attb104,    apoc_attb5 ] {apoc_face();   sound(self, CHAN_ITEM, "apoc/swipe.wav", 1, ATTN_NONE);};
void() apoc_attb5 = [ $attb105,    apoc_attb6 ] {apoc_face(); apoc_swipe();};
void() apoc_attb6 = [ $attb106,    apoc_attb7 ] {apoc_face(); apoc_swipe();};
void() apoc_attb7 = [ $attb107,    apoc_attb8 ] {apoc_face(); apoc_swipe();};
void() apoc_attb8 = [ $attb108,    apoc_attb9 ] {apoc_face(); apoc_swipe();};
void() apoc_attb9 = [ $attb109,    apoc_attb10 ] {apoc_face(); apoc_swipe();};
void() apoc_attb10 = [ $attb110,   apoc_attb11 ] {apoc_face(); apoc_swipe();};
void() apoc_attb11 = [ $attb111,   apoc_attb12 ] {apoc_face(); apoc_swipe();};
void() apoc_attb12 = [ $attb112,   apoc_melee ]
{
   apoc_face();

   if (self.enemy.x_flags & X_PARALLIZED)
      self.enemy.x_flags = self.enemy.x_flags - X_PARALLIZED;
};

void() apoc_spike =
{
   if (vlen(self.origin - self.enemy.origin) < 96)
      T_Damage(self.enemy, self, self, 10);

   sound(self, CHAN_BODY, "apoc/spike.wav", 1, ATTN_NONE);
};

void() apoc_attc1 = [ $attc101,    apoc_attc2 ] {apoc_face();};
void() apoc_attc2 = [ $attc102,    apoc_attc3 ] {apoc_face();};
void() apoc_attc3 = [ $attc103,    apoc_attc4 ] {apoc_face(); apoc_spike();};
void() apoc_attc4 = [ $attc104,    apoc_attc5 ] {apoc_face();};
void() apoc_attc5 = [ $attc105,    apoc_attc6 ] {apoc_face();};
void() apoc_attc6 = [ $attc106,    apoc_attc7 ] {apoc_face(); apoc_spike();};
void() apoc_attc7 = [ $attc107,    apoc_attc8 ] {apoc_face();};
void() apoc_attc8 = [ $attc108,    apoc_attc9 ] {apoc_face();};
void() apoc_attc9 = [ $attc109,    apoc_attc10 ] {apoc_face(); apoc_spike();};
void() apoc_attc10 = [ $attc110,   apoc_attc11 ] {apoc_face();};
void() apoc_attc11 = [ $attc111,   apoc_attc12 ] {apoc_face();};
void() apoc_attc12 = [ $attc112,   apoc_melee ] {apoc_face();};

void() apoc_melee =
{
   local vector   vect, vecta;

   if (self.last_flame > (time - 2.3)) {
//      apoc_face();
      if ((self.spawn_time != 99) && (self.last_flame > (time - 0.2))) {    // found an enemy
         sound(self, CHAN_VOICE, "apoc/astart.wav", 1, ATTN_NONE);
         self.spawn_time = 99;
      }

      self.nextthink = time + 0.2;
      return;
   }
   else if (self.spawn_time == 99) {
      cvar_set("host_framerate", "0");
      self.spawn_time = 0;
   }

   // first check if stomping (aligning legs with arms) is required
   if (vlen(self.enemy.origin - self.origin) > 64) {
      vect = normalize(self.enemy.origin - self.origin);
      vecta = vectoangles(vect);

      if (fabs(angle_diff(vecta_y, self.leg.angles_y)) > 30) {
         // stomp!!
         apoc_stomp();
         self.nextthink = time + 0.05;
         return;
      }
   }


   if (vlen(self.enemy.origin - self.origin) < 96)
      apoc_attc1();
   else if (fabs(angle_diff(vecta_y, self.angles_y)) > 10)
      apoc_attb1();
   else
      apoc_atta1();
};

//====================================================================================

void() apoc_pain101 =   [ $pain101, apoc_die   ]
{
   local entity   trav;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   last;

   sound(self, CHAN_VOICE, "apoc/apocno.wav", 1, ATTN_NORM);

   // prevent torso from taking damage
   trav = find(world, classname, "apoc_torso");
   if (trav != world) {
      trav.solid = SOLID_NOT;
      trav.takedamage = DAMAGE_NO;
   }

   // remove the bounding boxes for legs
   remove(self.leg.leg.leg);
   remove(self.leg.leg);

   self.leg.leg = world;

   self.x_flags = self.x_flags | X_MEGA_HIT;

   self.enemy.currentammo = self.enemy.ammo_special = 0;
};

void() apoc_die =
{
   local entity trav;

   self.frame = self.frame + 1;

   self.skin = 1 - self.skin;
   self.leg.skin = 1 - self.leg.skin;

   if (self.frame == $pain150 ) {

      remove(self.leg);

      trav = find(world, classname, "apoc_torso");
      if (trav != world)
         remove(trav);

      // this is where the new smaller version of Apocalypse will kick in
      ApocSmallSpawn();

      self.think = SUB_Remove;
      self.nextthink = time + 0.05;
   }

   self.nextthink = time + 0.1;
};

//====================================================================================

void() apoc_pain =
{
//bprint("apoc pain: ");
//bprint(ftos(self.health));
//bprint("\n");
   // special weapon does 1000+ damage per strike

   if (self.health > 99000)
      self.health = 99999;
};

//====================================================================================

void() ApocLegsThink =
{
   // sync frames with body
   self.frame = self.owner.frame;

   if (self.leg != world) {
      // move leg bounding boxes
      makevectors(self.angles);
      setorigin(self.leg,     self.origin + (v_right * 58));
      setorigin(self.leg.leg, self.origin - (v_right * 58));
   }

   self.nextthink = time + 0.05;
};

void() SpawnApocLegs =
{
   local entity   ent;

   ent = spawn();
   ent.owner = self;

   setmodel(ent, "progs/appy1.mdl");

   traceline(self.origin, self.origin - '0 0 1024', TRUE, world);
   setorigin(ent, trace_endpos + '0 0 24');
   ent.angles = self.angles;
   ent.yaw_speed = 5;

   ent.think = ApocLegsThink;
   ent.nextthink = time + 0.1;

   self.leg = ent;

  // now make the two solid leg boxes

  // left
   ent = spawn();
   ent.owner = self.leg;
   ent.classname = "apoc_leg";

   ent.solid = SOLID_BBOX;
   setsize(ent, VEC_HULL_MIN, VEC_HULL_MAX);

   self.leg.leg = ent;

  // right
   ent = spawn();
   ent.owner = self.leg;
   ent.classname = "apoc_leg";

   ent.solid = SOLID_BBOX;
   setsize(ent, VEC_HULL_MIN, VEC_HULL_MAX);

   self.leg.leg.leg = ent;
};

void() SpawnApocTorso =
{
   local entity   ent;

   ent = spawn();
   ent.classname = "apoc_torso";
   ent.owner = self;

   ent.solid = SOLID_BBOX;
   ent.takedamage = DAMAGE_AIM;
   ent.health = 99999;
   setorigin(ent, self.origin + '0 0 330');
   setsize(ent, '-138 -138 -300', '138 138 100');

};

//====================================================================================

void() xmen_apocalypse =
{
   if (deathmatch) {
      remove(self);
      return;
   }

   precache_model("progs/appy1.mdl");
   precache_model("progs/appy2.mdl");
   precache_model("progs/apoc.mdl");

   precache_model("progs/apblast.mdl");

   precache_sound("apoc/thump.wav");
   precache_sound("apoc/spike.wav");
   precache_sound("apoc/swipe.wav");

   precache_sound("apoc/astart.wav");
   precache_sound("apoc/alaugh.wav");
   precache_sound("apoc/apain2.wav");
   precache_sound("apoc/apain4.wav");
   precache_sound("apoc/apain5.wav");
   precache_sound("apoc/apocno.wav");
   precache_sound("apoc/miniapoc.wav");
   precache_sound("apoc/aattack2.wav");
   precache_sound("apoc/aattack3.wav");
   precache_sound("apoc/aattack4.wav");
   precache_sound("apoc/ahit.wav");

   SpawnApocLegs();
   SpawnApocTorso();

//   self.solid = SOLID_BBOX;

   setsize (self, '-128 -128 -24', '128 128 256');
   setmodel(self, "progs/appy2.mdl");
   self.health = 99999;

   setorigin(self, self.leg.origin);

   self.yaw_speed = 6;
   self.takedamage = DAMAGE_AIM;

   self.ideal_yaw = self.angles * '0 1 0';
   self.view_ofs = '0 0 25';

   self.spawn_time = time;

   self.flags = self.flags | FL_MONSTER;

   self.th_stand = apoc_stand1;
//   self.th_walk = apoc_stand1;
   self.th_run = apoc_melee;
   self.th_pain = apoc_pain;
   self.th_die = apoc_pain101;
   self.th_melee = apoc_melee;
   self.th_missile = apoc_melee;

   self.pausetime = 99999999;

   self.think = apoc_stand1;
   self.nextthink = time + 0.1;

};