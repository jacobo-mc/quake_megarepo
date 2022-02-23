$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10
$frame stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9 pain10
$frame pain11 pain12

$frame guard1 guard2 guard3 guard4 guard5 guard6 guard7 guard8
$frame guard9 guard10 guard11 guard12

$frame atta0 atta1 atta2 atta3 atta4 atta5 atta6 atta7 atta8
$frame atta9 atta10 atta11 atta12

$frame attb1 attb2 attb3 attb4 attb5 attb6 attb7 attb8
$frame attb9 attb10 attb11 attb12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8
$frame xatta9 xatta10 xatta11 xatta12

$frame xattb1 xattb2 xattb3 xattb4 xattb5 xattb6 xattb7 xattb8
$frame xattb9 xattb10 xattb11 xattb12

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8 deatha9 deatha10
$frame deatha11 deatha12 deatha13 deatha14 deatha15 deatha16 deatha17 deatha18 deatha19 deatha20
$frame deatha21 deatha22 deatha23 deatha24 deatha25 deatha26 deatha27 deatha28 deatha29 deatha30

$frame pant1 pant2 pant3 pant4 pant5 pant6 pant7 pant8 pant9 pant10

//====================================================================================

void() apsmall_clone1  = [$stand1, apsmall_clone2 ] {};
void() apsmall_clone2  = [$stand2, apsmall_clone3 ] {};
void() apsmall_clone3  = [$stand3, apsmall_clone4 ] {};
void() apsmall_clone4  = [$stand4, apsmall_clone5 ] {};
void() apsmall_clone5  = [$stand5, apsmall_clone6 ] {};
void() apsmall_clone6  = [$stand6, apsmall_clone7 ] {};
void() apsmall_clone7  = [$stand7, apsmall_clone8 ] {};
void() apsmall_clone8  = [$stand8, apsmall_clone9 ] {};
void() apsmall_clone9  = [$stand9, apsmall_clone10 ] {};
void() apsmall_clone10 = [$stand10, apsmall_clone11 ] {};
void() apsmall_clone11 = [$stand11, apsmall_clone12 ] {};
void() apsmall_clone12 = [$stand12, apsmall_clone13 ] {};
void() apsmall_clone13 = [$stand13, apsmall_clone1 ] {};

//====================================================================================

void() apsmall_stand =  [$walk1, apsmall_stand ] {};

void() apsmall_walk =   [$walk1, apsmall_walk   ]
{
   self.walkframe = self.walkframe + 1;
   if (self.walkframe >= 11)
      self.walkframe = 0;

   if (self.walkframe == 0)       ai_run(9);
   else if (self.walkframe == 1)  ai_run(6);
   else if (self.walkframe == 2)  ai_run(7);
   else if (self.walkframe == 3)  ai_run(8);
   else if (self.walkframe == 4)  ai_run(8);
   else if (self.walkframe == 5)  ai_run(9);
   else if (self.walkframe == 6)  ai_run(14);
   else if (self.walkframe == 7)  ai_run(6);
   else if (self.walkframe == 8)  ai_run(5);
   else if (self.walkframe == 9)  ai_run(7);
   else if (self.walkframe == 10) ai_run(7);
   else if (self.walkframe == 11) ai_run(8);

//   ai_face();

   self.frame = self.frame + self.walkframe;
};

//====================================================================================

void() apsmall_pain =   [$pain1, apsmall_pain   ]
{
   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 11) {
      self.think = self.th_run;
   }

   self.frame = self.frame + self.walkframe;
};

void(entity attacker, float damage) ApocSmallPain =
{
   if (self.spawnflags & SPAWNFLAG_CLONE) {
      self.health = 99999;
      return;
   }

   if (self.pain_finished > time)
      return;

   if (random() * 100 > damage)
      return;

   if (random() * 80 < damage)
      sound(self, CHAN_BODY, "apoc/apain2.wav", 1, ATTN_NORM);
   else if (random() < 0.5)
      sound(self, CHAN_BODY, "apoc/apain4.wav", 1, ATTN_NORM);
   else
      sound(self, CHAN_BODY, "apoc/apain5.wav", 1, ATTN_NORM);

   self.walkframe = -1;
   self.pain_finished = time + 3;
   apsmall_pain();
};

//====================================================================================

void() ApocCheckGuard =
{
   local entity   trav;

   trav = world;
   while ((trav = find(trav, classname, "guided_rocket")) != world) {

      // check that rocket is targetted for self
      if (trav.enemy == self) {     // uh oh
         return;
      }

   }

   // dangerous rocket not found
   self.flags = self.flags - (self.flags & FL_GODMODE);
   self.walkframe = 8;
};

void() apsmall_guard =  [$guard1,   apsmall_guard  ]
{
   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 11)
      self.think = self.th_run;
   else if (self.walkframe == 3)
      self.flags = self.flags | FL_GODMODE;
   else if (self.walkframe == 8) {
      self.walkframe = 7;
      ApocCheckGuard();
   }

   self.frame = self.frame + self.walkframe;
};

void() ApocSmallGuardStart =
{
   self.walkframe = -1;
   apsmall_guard();
};

//====================================================================================

void() apsmall_atta =   [$atta0, apsmall_atta   ]
{
   local vector   vec1;
   local float    frame_diff;

   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 12)
      self.think = self.th_run;

   self.frame = self.frame + self.walkframe;

   frame_diff = fabs(self.frame - $atta7 );
   if (frame_diff <= 3) {
      makevectors(self.angles);
      vec1 = normalize(self.enemy.origin - self.origin);

      if (vlen(v_forward - vec1) < 0.2) {
         if (vlen(self.enemy.origin - self.origin) < (128 - ((frame_diff / 3) * 64)))
            T_Damage(self.enemy, self, self, 12);
      }
   }

   self.nextthink = time + 0.05;
};

void() apsmall_attb =   [$attb1, apsmall_attb   ]
{
   ai_face();
   ai_forward(8);

   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 11)
      self.think = self.th_run;

   self.frame = self.frame + self.walkframe;

   if ((self.frame == $attb3 ) ||
       (self.frame == $attb8 )) {
      if (infront(self.enemy)) {
         if (vlen(self.enemy.origin - self.origin) < 85) {
            sound(self, CHAN_BODY, "apoc/ahit.wav", 1, ATTN_NORM);

            T_Damage(self.enemy, self, self, 20);

            makevectors(self.angles);
            if (!(self.enemy.flags & FL_ONGROUND))
               self.enemy.velocity = v_forward * 200 + '0 0 235';
            else
               self.enemy.velocity = '0 0 235';
            self.enemy.punchangle_x = -10;
         }
      }
   }
};

void() ApocSmallMelee =
{
   self.walkframe = -1;
   apsmall_attb();
};

//====================================================================================

void() ApocBallTouch =
{
   if (other == self.owner)
      return;

   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);

   if (other.takedamage == DAMAGE_AIM)
   {
      spawn_touchblood (10);
      T_Damage(other, self, self.owner, 10);

      if (other.classname == "player") {
         other.velocity = other.velocity + (self.velocity * 0.2) + '0 0 180';
         other.flags = other.flags - (other.flags & FL_ONGROUND);
      }
   }

   remove(self);
};

void(vector org) spawn_apocball =
{
   local entity missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity mpuff;
   //local   vector  vect;

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.classname = "apocball";

   missile.velocity = ProjectVelocity(1100, '0 0 0');

   missile.angles = vectoangles(missile.velocity);
   missile.old_velocity = missile.velocity;

   missile.touch = ApocBallTouch;

   missile.last_touch = 0;
   missile.oldorigin = missile.origin;
   missile.nextthink = time + 20;
   missile.think = SUB_Remove;

   setmodel (missile, "progs/apblast.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, org);
};

void() apsmall_xatta =  [$xatta1,   apsmall_xatta  ]
{
   ai_face();

   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 11)
      self.think = self.th_run;
   else if (self.walkframe == 4) {
      makevectors(self.angles);
      spawn_apocball(self.origin);
   }

   self.frame = self.frame + self.walkframe;
};

void() apsmall_xattb =  [$xattb1,   apsmall_xattb  ]
{
   ai_face();

   self.walkframe = self.walkframe + 1;
   if (self.walkframe == 11)
      self.think = self.th_run;
   else if (self.walkframe == 5) {
      makevectors(self.angles);
      spawn_apocball(self.origin + v_right * 3);
      spawn_apocball(self.origin - v_right * 3);
   }

   self.frame = self.frame + self.walkframe;
};

void() ApocSmallMissile =
{
   local float rnd;

   if (self.spawn_time > (time - 4.5))    // don't attack for 4.5 seconds after shrinking
      return;

   if (self.last_special > (time - 3)) {
      if (vlen(self.origin - self.enemy.origin) < 160) {
         self.walkframe = -1;
         apsmall_atta();
      }
      else {
         self.walkframe = -1;
         self.last_special2 = time;
         apsmall_xatta();
      }
   }
   else {
      self.walkframe = -1;
      self.last_special = time;
      apsmall_xattb();
   }

   rnd = random() * 5;
   if (rnd < 1)
      sound(self, CHAN_VOICE, "apoc/aattack2.wav", 1, ATTN_NORM);
   else if (rnd < 2)
      sound(self, CHAN_VOICE, "apoc/aattack3.wav", 1, ATTN_NORM);
   else if (rnd < 3)
      sound(self, CHAN_VOICE, "apoc/aattack4.wav", 1, ATTN_NORM);

};

//====================================================================================

void() apoc_pant = [ $pant1,  apoc_pant   ]
{
   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 9)
      self.walkframe = 0;

   self.frame = self.frame + self.walkframe;
};

void() apsmall_death =  [$deatha1,   apsmall_death  ]
{
   local entity trav;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector vec1;

   if (self.walkframe < 30)
      self.walkframe = self.walkframe + 1;
/*
   else if (self.walkframe == 35) {
      makevectors(self.angles);
      vec1 = normalize(self.enemy.origin - self.origin);

      if (vlen(self.enemy.origin - self.origin) < 90) {
         if (vlen(v_forward - vec1) < 0.2) {
            T_Damage(self.enemy, self, self, 25);
         }
      }
   }
*/
   else if ((self.walkframe == 30) && (self.enemy.health > 0)) {      // show completed episode 1 sequence

      killed_monsters = killed_monsters + 1;
      WriteByte (MSG_ALL, SVC_KILLEDMONSTER);   // FIXME: reliable broadcast

      trav = find (world, classname, "player");
      while (trav != world)
      {
         trav.view_ofs = '0 0 0';
         trav.nextthink = time + 0.5;
         trav.takedamage = DAMAGE_NO;
         trav.solid = SOLID_NOT;
         trav.movetype = MOVETYPE_NONE;
         trav.weapon_parts = 0;

         trav = find (trav, classname, "player");
      }

      WriteByte (MSG_ALL, SVC_INTERMISSION);
      nextmap = "x2m1";

      serverflags = serverflags - (serverflags & 15); // remove rune items from the consol
      intermission_running = 1;

      SUB_UseTargets ();

      self.think = apoc_pant;
      self.nextthink = time + 0.1;
   }

   self.frame = self.frame + self.walkframe;
};

void() ApocSmallDie =
{
   self.walkframe = -1;
   apsmall_death();
   sound(self, CHAN_VOICE, "apoc/apain2.wav", 1, ATTN_NORM);
};

//====================================================================================

// 20060704 LordHavoc: hushed a compiler warning by making this take no parameters
void() ApocSmallSpawn =
{
   local entity   apoc, oself;

   apoc = spawn();
   apoc.classname = "apocalypse_small";

   setorigin(apoc, self.origin);

   apoc.solid = SOLID_SLIDEBOX;
   apoc.movetype = MOVETYPE_STEP;
   apoc.takedamage = DAMAGE_AIM;

   setmodel (apoc, "progs/apoc.mdl");

   setsize (apoc, VEC_HULL2_MIN, VEC_HULL2_MAX);
   apoc.health = 600;
   apoc.yaw_speed = 20;

   apoc.th_stand = apsmall_stand;
   apoc.th_walk = apsmall_stand;
   apoc.th_run = apsmall_walk;
   apoc.th_pain = ApocSmallPain;
   apoc.th_die = ApocSmallDie;
   apoc.th_melee = ApocSmallMelee;
   apoc.th_missile = ApocSmallMissile;

   apoc.th_guard = ApocSmallGuardStart;
   apoc.x_flags = apoc.x_flags | X_MEGA_HIT;

   oself = self;
   self = apoc;
   walkmonster_start_go();
   self = oself;

   apoc.enemy = apoc.goalentity = self.enemy;
   apoc.think = apoc.th_run;
   apoc.nextthink = time + 0.1;
   apoc.frame = $walk1;
   apoc.spawn_time = time;

   sound(self, CHAN_VOICE, "apoc/miniapoc.wav", 1, ATTN_NORM);

};

void() xmen_apocalypse_small =
{
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_NONE;

   precache_model("progs/apoc.mdl");
   setmodel (self, "progs/apoc.mdl");

   setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
   self.health = 99999;

   self.th_stand = apsmall_clone1;
   self.th_walk = apsmall_clone1;
   self.th_run = apsmall_clone1;
   self.th_pain = ApocSmallPain;
   self.th_die = apsmall_clone1;

   if (self.spawnflags & SPAWNFLAG_CLONE) {
      self.flags = self.flags & FL_GODMODE;
      droptofloor();

      self.think = self.th_stand;
      self.nextthink = time + 0.1;
   }
};