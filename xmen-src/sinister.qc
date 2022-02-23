/****************************************************************************

   SINISTER (2nd Episode boss)

 ****************************************************************************/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10
$frame stand11 stand12 stand13

$frame laugh1 laugh2 laugh3 laugh4 laugh5 laugh6 laugh7 laugh8 laugh9 laugh10
$frame laugh11 laugh12

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9

$frame guard1 guard2 guard3 guard4 guard5 guard6 guard7 guard8
$frame guard9 guard10 guard11 guard12

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8
$frame xatta9 xatta10 xatta11 xatta12

$frame xattb1 xattb2 xattb3 xattb4 xattb5 xattb6 xattb7 xattb8
$frame xattb9 xattb10 xattb11 xattb12

$frame diss1 diss2 diss3 diss4 diss5 diss6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20
$frame death21 death22 death23 death24 death25 death26 death27 death28 death29 death30
$frame death31 death32 death33 death34

//============================================================================

void() CheckPlayerSight =
{
   local entity sin, current;

   if (self.spawnflags & SPAWNFLAG_CLONE)
      return;

   if (self.enemy == world)
      self.enemy = self.goalentity = find(world, classname, "player");

   if (self.enemy.health <= 0) {
      return;
   }

   if (self.enemy != world) {
      traceline(self.origin + '0 0 40', self.enemy.origin + '0 0 40', TRUE, world);

      if (trace_fraction == 1) {
         self.th_run();

         if (self.x_flags & X_SINISTER_FINAL) {

            // remove all other sinisters still in the map
            sin = find(world, classname, "xmen_sinister");
            while (sin != world) {
               current = sin;

               if (sin != self)
                  remove(sin);

               sin = find(current, classname, "xmen_sinister");
            }

            self.last_flame = time;
            sound(self, CHAN_ITEM, "sinister/mrsin1.wav", 1, ATTN_NONE);

         }
      }
   }
};

void() sin_laugh1;

void() sin_stand1 =  [ $stand1,  sin_stand2  ] {CheckPlayerSight();};
void() sin_stand2 =  [ $stand2,  sin_stand3  ] {CheckPlayerSight();};
void() sin_stand3 =  [ $stand3,  sin_stand4  ] {CheckPlayerSight();};
void() sin_stand4 =  [ $stand4,  sin_stand5  ] {CheckPlayerSight();};
void() sin_stand5 =  [ $stand5,  sin_stand6  ] {CheckPlayerSight();};
void() sin_stand6 =  [ $stand6,  sin_stand7  ] {CheckPlayerSight();};
void() sin_stand7 =  [ $stand7,  sin_stand8  ] {CheckPlayerSight();};
void() sin_stand8 =  [ $stand8,  sin_stand9  ] {CheckPlayerSight();};
void() sin_stand9 =  [ $stand9,  sin_stand10 ] {CheckPlayerSight();};
void() sin_stand10 =  [ $stand10,  sin_stand11 ] {CheckPlayerSight();};
void() sin_stand11 =  [ $stand11,  sin_stand12 ] {CheckPlayerSight();};
void() sin_stand12 =  [ $stand12,  sin_stand13 ] {CheckPlayerSight();};
void() sin_stand13 =  [ $stand13,  sin_stand1  ]
{
   if (!(self.x_flags & X_SINISTER_FINAL)) {
      self.count = self.count + 1;
      if ((random() < 0.4) || (self.count == 3)) {
         self.count = 0;
         self.think = sin_laugh1;
      }
   }
};

void() sin_laugh1 =  [ $laugh1,  sin_laugh2  ]
{
   local float rnd;

   if ((self.count == 0) && (self.last_flame < (time - 4))) {
      rnd = random() * 8;
      if (rnd < 1)
         sound(self, CHAN_VOICE, "sinister/laugh1.wav", 1, 2);
      else if (rnd < 2)
         sound(self, CHAN_VOICE, "sinister/laugh2.wav", 1, 2);
      else if (rnd < 2)
         sound(self, CHAN_VOICE, "sinister/cackle1.wav", 1, 2);
      else if (rnd < 4)
         sound(self, CHAN_VOICE, "sinister/cackle2.wav", 1, 2);
      else if (rnd < 5)
         sound(self, CHAN_VOICE, "sinister/cackle3.wav", 1, 2);
      else if (rnd < 6)
         sound(self, CHAN_VOICE, "sinister/threat1.wav", 1, 2);
      else if (rnd < 7)
         sound(self, CHAN_VOICE, "sinister/threat2.wav", 1, 2);
      else
         sound(self, CHAN_VOICE, "sinister/threat3.wav", 1, 2);
   }
};
void() sin_laugh2 =  [ $laugh2,  sin_laugh3  ] {CheckPlayerSight();};
void() sin_laugh3 =  [ $laugh3,  sin_laugh4  ] {CheckPlayerSight();};
void() sin_laugh4 =  [ $laugh4,  sin_laugh5  ] {CheckPlayerSight();};
void() sin_laugh5 =  [ $laugh5,  sin_laugh6  ] {CheckPlayerSight();};
void() sin_laugh6 =  [ $laugh6,  sin_laugh7  ] {CheckPlayerSight();};
void() sin_laugh7 =  [ $laugh7,  sin_laugh8  ] {CheckPlayerSight();};
void() sin_laugh8 =  [ $laugh8,  sin_laugh9  ] {CheckPlayerSight();};
void() sin_laugh9 =  [ $laugh9,  sin_laugh10 ] {CheckPlayerSight();};
void() sin_laugh10 =  [ $laugh10,  sin_laugh11 ] {CheckPlayerSight();};
void() sin_laugh11 =  [ $laugh11,  sin_laugh12 ] {CheckPlayerSight();};
void() sin_laugh12 =  [ $laugh12,  sin_laugh1 ]
{
   self.count = self.count + 1;
   if (self.count >= 4) {
      self.count = 0;
      self.think = sin_stand1;
   }
};

//============================================================================

void() SinisterMissile;
void() sin_sightlaugh1 =  [ $laugh1,  sin_sightlaugh2  ]
{
   local float rnd;

   if (self.count == 0) {
      rnd = random() * 8;
      if (rnd < 1)
         sound(self, CHAN_VOICE, "sinister/laugh1.wav", 1, 2);
      else if (rnd < 2)
         sound(self, CHAN_VOICE, "sinister/laugh2.wav", 1, 2);
      else if (rnd < 2)
         sound(self, CHAN_VOICE, "sinister/cackle1.wav", 1, 2);
      else if (rnd < 4)
         sound(self, CHAN_VOICE, "sinister/cackle2.wav", 1, 2);
      else if (rnd < 5)
         sound(self, CHAN_VOICE, "sinister/cackle3.wav", 1, 2);
      else if (rnd < 6)
         sound(self, CHAN_VOICE, "sinister/threat1.wav", 1, 2);
      else if (rnd < 7)
         sound(self, CHAN_VOICE, "sinister/threat2.wav", 1, 2);
      else
         sound(self, CHAN_VOICE, "sinister/threat3.wav", 1, 2);
   }
};
void() sin_sightlaugh2 =  [ $laugh2,  sin_sightlaugh3  ] {};
void() sin_sightlaugh3 =  [ $laugh3,  sin_sightlaugh4  ] {};
void() sin_sightlaugh4 =  [ $laugh4,  sin_sightlaugh5  ] {};
void() sin_sightlaugh5 =  [ $laugh5,  sin_sightlaugh6  ] {};
void() sin_sightlaugh6 =  [ $laugh6,  sin_sightlaugh7  ] {};
void() sin_sightlaugh7 =  [ $laugh7,  sin_sightlaugh8  ] {};
void() sin_sightlaugh8 =  [ $laugh8,  sin_sightlaugh9  ] {};
void() sin_sightlaugh9 =  [ $laugh9,  sin_sightlaugh10 ] {};
void() sin_sightlaugh10 =  [ $laugh10,  sin_sightlaugh11 ] {};
void() sin_sightlaugh11 =  [ $laugh11,  sin_sightlaugh12 ] {};
void() sin_sightlaugh12 =  [ $laugh12,  sin_sightlaugh1 ]
{
   self.count = self.count + 1;
   if (self.count >= 4) {
      self.count = 0;
      self.think = SinisterMissile;
   }
};

void() sin_walk1 =  [ $walk1,  sin_walk2  ] {ai_run(3);};
void() sin_walk2 =  [ $walk2,  sin_walk3  ] {ai_run(2);};
void() sin_walk3 =  [ $walk3,  sin_walk4  ] {ai_run(3);};
void() sin_walk4 =  [ $walk4,  sin_walk5  ] {ai_run(5);};
void() sin_walk5 =  [ $walk5,  sin_walk6  ] {ai_run(6);};
void() sin_walk6 =  [ $walk6,  sin_walk7  ] {ai_run(6);};
void() sin_walk7 =  [ $walk7,  sin_walk8  ] {ai_run(5);};
void() sin_walk8 =  [ $walk8,  sin_walk9  ] {ai_run(3);};
void() sin_walk9 =  [ $walk9,  sin_walk10 ] {ai_run(3);};
void() sin_walk10 = [ $walk10, sin_walk11 ] {ai_run(4);};
void() sin_walk11 = [ $walk11, sin_walk12 ] {ai_run(5);};
void() sin_walk12 = [ $walk12, sin_walk1 ]  {ai_run(6);};

//============================================================================

void() sin_pain1 =  [ $pain1,  sin_pain2  ] {};
void() sin_pain2 =  [ $pain2,  sin_pain3  ] {};
void() sin_pain3 =  [ $pain3,  sin_pain4  ] {};
void() sin_pain4 =  [ $pain4,  sin_pain5  ] {};
void() sin_pain5 =  [ $pain5,  sin_pain6  ] {};
void() sin_pain6 =  [ $pain6,  sin_pain7  ] {};
void() sin_pain7 =  [ $pain7,  sin_pain8  ] {};
void() sin_pain8 =  [ $pain8,  sin_pain9  ] {};
void() sin_pain9 =  [ $pain9,  sin_walk1  ] {};

void() sin_diss1;
void(entity attacker, float damage) SinisterPain =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local float    best;
   //local entity   stemp;

   if (self.spawnflags & SPAWNFLAG_CLONE) {
      self.health = 99999;
      return;
   }

   if (self.x_flags & X_SINISTER_FINAL) {
//self.health =1;
//return;

      if (attacker.weapon == IT_SPECIAL_WEAPON) {
         if (self.health < 10000) {    // special weapon has removed invulnerability
            self.health = self.start_health = 500;
            self.x_flags = self.x_flags | X_MEGA_HIT;

            attacker.currentammo = attacker.ammo_special = 0;

            self.th_run();

            return;
         }

         if (self.pain_finished > time)
            return;

         self.pain_finished = time + 5;
//         sin_pain1();
         return;
      }

      if (!(self.x_flags & X_MEGA_HIT)) {
         self.health = 99999;
         return;
      }

      if (self.pain_finished > time)
         return;

      if ((random() * 20) > damage)       // don't flinch
         return;

      self.pain_finished = time + 2;
      sin_pain1();
      return;
   }
   else {   // move to next spot
      sin_diss1();
   }

   self.health = 99999;
};

//============================================================================
void() sin_guard8;

void() sin_guard1 =  [ $guard1,  sin_guard2  ] {};
void() sin_guard2 =  [ $guard2,  sin_guard3  ] {};
void() sin_guard3 =  [ $guard3,  sin_guard4  ] {};
void() sin_guard4 =  [ $guard4,  sin_guard5  ] {};
void() sin_guard5 =  [ $guard5,  sin_guard6  ] {};
void() sin_guard6 =  [ $guard6,  sin_guard7  ] {self.flags = self.flags | FL_GODMODE;};
void() sin_guard7 =  [ $guard7,  sin_guard7  ]
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
   self.think = sin_guard8;
};
void() sin_guard8 =  [ $guard8,  sin_guard9  ] {};
void() sin_guard9 =  [ $guard9,  sin_guard10 ] {};
void() sin_guard10 =  [ $guard10,  sin_guard11 ] {};
void() sin_guard11 =  [ $guard11,  sin_guard12 ] {};
void() sin_guard12 =  [ $guard12,  sin_walk1 ] {};

//============================================================================
void() SinisterMissile;

void() SinMissileTouch =
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
      spawn_touchblood (5);
      T_Damage(other, self, self.owner, 5);
   }

   remove(self);
};

void(vector org) spawn_sinister_missile =
{
   local entity missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity mpuff;
   //local   vector  vect;

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.classname = "sin_missile";

   missile.velocity = ProjectVelocity(750, '0 0 0');

   missile.angles = vectoangles(missile.velocity);
   missile.old_velocity = missile.velocity;

   missile.touch = SinMissileTouch;

   missile.last_touch = 0;
   missile.oldorigin = missile.origin;
   missile.nextthink = time + 10;
   missile.think = SUB_Remove;

   setmodel (missile, "progs/sinblast.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, org);
};


void() sin_xatta1 =  [ $xatta1,  sin_xatta2  ] {ai_face();};
void() sin_xatta2 =  [ $xatta2,  sin_xatta3  ] {ai_face();};
void() sin_xatta3 =  [ $xatta3,  sin_xatta4  ] {ai_face();};
void() sin_xatta4 =  [ $xatta4,  sin_xatta5  ] {ai_face();};
void() sin_xatta5 =  [ $xatta5,  sin_xatta6  ]
{
   ai_face();

   makevectors(self.angles);
   spawn_sinister_missile(self.origin + v_right * 4);
   spawn_sinister_missile(self.origin + v_right * -4);
};
void() sin_xatta6 =  [ $xatta6,  sin_xatta7  ] {ai_face();};
void() sin_xatta7 =  [ $xatta7,  sin_xatta8  ] {ai_face();};
void() sin_xatta8 =  [ $xatta8,  sin_xatta9  ] {ai_face();};
void() sin_xatta9 =  [ $xatta9,  sin_xatta10 ] {ai_face();};
void() sin_xatta10 =  [ $xatta10,  sin_xatta11 ] {ai_face();};
void() sin_xatta11 =  [ $xatta11,  sin_xatta12 ] {ai_face();};
void() sin_xatta12 =  [ $xatta12,  sin_walk1 ]
{
   if (!(self.x_flags & X_SINISTER_FINAL))
      SinisterMissile();
};


void() sin_xattb1 =  [ $xattb1,  sin_xattb2  ] {ai_face();};
void() sin_xattb2 =  [ $xattb2,  sin_xattb3  ] {ai_face();};
void() sin_xattb3 =  [ $xattb3,  sin_xattb4  ]
{
   ai_face();

   makevectors(self.angles);
   spawn_sinister_missile(self.origin + v_right * 4);
};
void() sin_xattb4 =  [ $xattb4,  sin_xattb5  ] {ai_face();};
void() sin_xattb5 =  [ $xattb5,  sin_xattb6  ] {ai_face();};
void() sin_xattb6 =  [ $xattb6,  sin_xattb7  ]
{
   ai_face();

   makevectors(self.angles);
   spawn_sinister_missile(self.origin + v_right * -4);
};
void() sin_xattb7 =  [ $xattb7,  sin_xattb8  ] {ai_face();};
void() sin_xattb8 =  [ $xattb8,  sin_xattb9  ] {ai_face();};
void() sin_xattb9 =  [ $xattb9,  sin_xattb10 ]
{
   ai_face();

   makevectors(self.angles);
   spawn_sinister_missile(self.origin + v_right * 4);
};
void() sin_xattb10 =  [ $xattb10,  sin_xattb11 ] {ai_face();};
void() sin_xattb11 =  [ $xattb11,  sin_xattb12 ] {ai_face();};
void() sin_xattb12 =  [ $xattb12,  sin_walk1 ]
{
   if (!(self.x_flags & X_SINISTER_FINAL))
      SinisterMissile();
};

void() SinisterMissile =
{
   if ((self.x_flags & X_SINISTER_FINAL) && !(self.x_flags & X_MEGA_HIT) && (random() < 0.9)) {
      self.count = 0;
      sin_sightlaugh1();
      return;
   }

   if (random() < 0.7)
      sin_xatta1();
   else
      sin_xattb1();
};

//============================================================================

void() SinNextSpot =
{
   local entity stemp;
   local entity trav;

   if (!(self.x_flags & X_SINISTER_FINAL)) {
      self.state = self.state + 1;
      self.enemy = world;

      stemp = find(world, classname, "xmen_sinister_spot");
      while (stemp != world) {
         if (stemp.state == self.state) {
            spawn_tfog(stemp.origin);
            setorigin(self, stemp.origin);
            droptofloor();
            self.angles = stemp.angles;
            self.velocity = '0 0 0';

            self.th_stand();

            return;
         }
         else
            stemp = find(stemp, classname, "xmen_sinister_spot");
      }

      // no spot found, so disappear altogether
      remove(self);
   }
   else {      // random teleport

      stemp = find(world, classname, "xmen_sinister_teleport");
      while (stemp != world) {
         if ((random() < 0.1) && (vlen(stemp.origin - self.origin) > 128)) {

            self.oldorigin = self.origin;
            setorigin(self, stemp.origin);
            droptofloor();

            if (!walkmove(0,0)) {
               setorigin(self, self.oldorigin);
            }
            else {
               spawn_tfog(stemp.origin);

               self.angles = stemp.angles;
               self.velocity = '0 0 0';

               self.th_run();

               trav = find(world, classname, "guided_rocket");
               while (trav != world) {
                  if (trav.enemy == self)
                     trav.enemy = world;

                  trav = find(trav, classname, "guided_rocket");
               }

               return;
            }
         }
         else {
            stemp = find(stemp, classname, "xmen_sinister_teleport");
            if (stemp == world) {
               stemp = find(world, classname, "xmen_sinister_teleport");
            }
         }
      }

   }
};

void() sin_diss1 =  [ $diss1,  sin_diss2  ] {};
void() sin_diss2 =  [ $diss2,  sin_diss3  ] {};
void() sin_diss3 =  [ $diss3,  sin_diss4  ] {};
void() sin_diss4 =  [ $diss4,  sin_diss5  ] {};
void() sin_diss5 =  [ $diss5,  sin_diss6  ] {};
void() sin_diss6 =  [ $diss6,  SinNextSpot ] {spawn_tfog(self.origin);};

//============================================================================

void() sin_death1  =  [ $death1,  sin_death2  ] {};
void() sin_death2  =  [ $death2,  sin_death3  ] {};
void() sin_death3  =  [ $death3,  sin_death4  ] {};
void() sin_death4  =  [ $death4,  sin_death5  ] {};
void() sin_death5  =  [ $death5,  sin_death6  ] {};
void() sin_death6  =  [ $death6,  sin_death7  ] {};
void() sin_death7  =  [ $death7,  sin_death8  ] {};
void() sin_death8  =  [ $death8,  sin_death9  ] {};
void() sin_death9  =  [ $death9,  sin_death10 ] {};
void() sin_death10 =  [ $death10, sin_death11 ] {};
void() sin_death11 =  [ $death11, sin_death12 ] {};
void() sin_death12 =  [ $death12, sin_death13 ] {};
void() sin_death13 =  [ $death13, sin_death14 ] {};
void() sin_death14 =  [ $death14, sin_death15 ] {};
void() sin_death15 =  [ $death15, sin_death16 ] {};
void() sin_death16 =  [ $death16, sin_death17 ] {};
void() sin_death17 =  [ $death17, sin_death18 ] {};
void() sin_death18 =  [ $death18, sin_death19 ] {};
void() sin_death19 =  [ $death19, sin_death20 ] {};
void() sin_death20 =  [ $death20, sin_death21 ] {};
void() sin_death21 =  [ $death21, sin_death22 ] {};
void() sin_death22 =  [ $death22, sin_death23 ] {};
void() sin_death23 =  [ $death23, sin_death24 ] {};
void() sin_death24 =  [ $death24, sin_death25 ] {};
void() sin_death25 =  [ $death25, sin_death26 ] {};
void() sin_death26 =  [ $death26, sin_death27 ] {};
void() sin_death27 =  [ $death27, sin_death28 ] {};
void() sin_death28 =  [ $death28, sin_death29 ] {};
void() sin_death29 =  [ $death29, sin_death30 ] {};
void() sin_death30 =  [ $death30, sin_death31 ] {sound(self, CHAN_VOICE, "sinister/cackle2.wav", 1, 0);};
void() sin_death31 =  [ $death31, sin_death32 ] {};
void() sin_death32 =  [ $death32, sin_death33 ] {};
void() sin_death33 =  [ $death33, sin_death34 ] {spawn_tfog(self.origin);};
void() sin_death34 =  [ $death34, sin_death34 ]
{
   local entity   trav;

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
      trav.modelindex = 0;
      trav = find (trav, classname, "player");
   }

   WriteByte (MSG_ALL, SVC_INTERMISSION);
   nextmap = "start";

   intermission_running = 1;

   SUB_UseTargets ();
   remove (self);
};

//============================================================================

// Sinister teleport destination, use self.state to set sequence
void() xmen_sinister;
void() xmen_sinister_spot =
{
   self.classname = "xmen_sinister";
   xmen_sinister();
};

//============================================================================

void() xmen_sinister =
{
   if (deathmatch)
   {
      remove(self);
      return;
   }

   precache_model ("progs/sinister.mdl");
   precache_model ("progs/sinblast.mdl");

   precache_sound ("sinister/laugh1.wav");
   precache_sound ("sinister/laugh2.wav");
   precache_sound ("sinister/cackle1.wav");
   precache_sound ("sinister/cackle2.wav");
   precache_sound ("sinister/cackle3.wav");
   precache_sound ("sinister/mrsin1.wav");

   precache_sound ("sinister/threat1.wav");
   precache_sound ("sinister/threat2.wav");
   precache_sound ("sinister/threat3.wav");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/sinister.mdl");

   setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
   self.health = 99999;

   self.th_stand = sin_stand1;
   self.th_walk = sin_stand1;
   self.th_run = sin_sightlaugh1;
   self.th_pain = SinisterPain;
   self.th_die = sin_death1;
   self.th_missile = SinisterMissile;

   if (!(self.spawnflags & SPAWNFLAG_CLONE))
      walkmonster_start();
   else {
      self.flags = self.flags | FL_GODMODE;
      self.think = self.th_stand;
      self.nextthink = time + 0.1;
   }

   self.health = 99999;
};

void() xmen_sinister_final =
{
   self.x_flags = self.x_flags | X_SINISTER_FINAL;
   self.classname = "xmen_sinister";
   xmen_sinister();

   self.th_guard = sin_diss5;
   self.th_run = sin_walk1;
};

void() xmen_sinister_teleport = {};