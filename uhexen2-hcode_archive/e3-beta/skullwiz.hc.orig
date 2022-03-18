void  ()skullwiz_walk;
void  ()skullwiz_run;
void  ()skullwiz_melee;
void  ()skullwiz_blink;
void  ()skullwiz_push;
float SKULLBOOK   =  0.00000;
float SKULLHEAD   =  1.00000;

void  (float part)skullwiz_throw =  {
local entity new;
   new = spawn ();
   new.origin = (self.origin + '0.00000 -10.00000 40.00000');
   if ( (part == SKULLBOOK) ) {

      setmodel (new, "models/skulbook.mdl");
   } else {

      setmodel (new, "models/skulhead.mdl");

   }
   setsize (new, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   new.velocity = VelocityForDamage (400.00000);
   new.movetype = MOVETYPE_BOUNCE;
   new.solid = SOLID_NOT;
   new.avelocity_x = (random () * 600.00000);
   new.avelocity_y = (random () * 600.00000);
   new.avelocity_z = (random () * 600.00000);
   new.think = SUB_Remove;
   new.ltime = time;
   new.nextthink = ((time + 10.00000) + (random () * 10.00000));
};


void  ()skullwiz_possum_up =  {
   AdvanceFrame( 14.00000, 0.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()skullwiz_playdead =  {
   self.frame = 14.00000;
   self.think = skullwiz_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};

void  ()skullwiz_summon;

void  (float spider_cnt)spider_spawn =  {
   newmis = spawn ();
   newmis.cnt = spider_cnt;
   newmis.flags2 = FL_SUMMONED;
   newmis.nextthink = (time + 0.01000);
   newmis.think = skullwiz_summon;
   newmis.origin = self.origin;
   newmis.controller = self;
   newmis.angles = self.angles;
};


void  ()skullwiz_die =  {
   AdvanceFrame( 0.00000, 14.00000);
   self.nextthink = (time + (HX_FRAME_TIME * 1.50000));
   if ( (self.frame == 0.00000) ) {

      self.effects = FALSE;
      self.solid = SOLID_NOT;
      sound (self, CHAN_VOICE, "player/gib2.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.frame == 6.00000) ) {

      skullwiz_throw (SKULLBOOK);
      skullwiz_throw (SKULLHEAD);

   }
   if ( ((self.frame >= 0.00000) && (self.frame <= 3.00000)) ) {

      spider_spawn (((self.frame - 0.00000) + 1.00000));

   }
   if ( (self.frame == 14.00000) ) {

      self.nextthink = (time + 15.00000);
      self.think = SUB_Remove;

   }
};


void  ()spider_grow =  {
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = spider_grow;
   self.scale += 0.03000;
   if ( (self.scale >= 0.50000) ) {

      walkmonster_start ();

   }
};


void  ()skullwiz_summon =  {
local entity spider;
local entity hold;
local vector newangle = '0.00000 0.00000 0.00000';
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector spot3 = '0.00000 0.00000 0.00000';
local float loop_cnt = 0.00000;
   setmodel (self, "models/spider.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.drawflags = SCALE_ORIGIN_BOTTOM;
   self.yaw_speed = 10.00000;
   setsize (self, '-7.00000 -7.00000 0.00000', '7.00000 7.00000 10.00000');
   self.spiderType = 1.00000;
   self.spiderGoPause = 35.00000;
   self.skin = 1.00000;
   self.health = 10.00000;
   self.experience_value = (SpiderExp->1.00000);
   self.thingtype = THINGTYPE_FLESH;
   self.th_stand = SpiderStand;
   self.th_walk = SpiderWalk;
   self.th_run = SpiderRun;
   self.th_die = SpiderDie;
   self.th_melee = SpiderMeleeBegin;
   self.th_pain = SpiderPain;
   self.flags = (self.flags | FL_MONSTER);
   if ( (self.controller.flags2 & FL_ALIVE) ) {

      trace_fraction = 0.00000;
      loop_cnt = 0.00000;
      while ( (trace_fraction < 1.00000) ) {

         newangle = self.angles;
         if ( self.cnt ) {

            newangle_y -= (random () * 45.00000);
         } else {

            newangle_y += (random () * 45.00000);

         }
         makevectors (newangle);
         spot1 = self.origin;
         spot2 = (spot1 + (v_forward * ((random () * 100.00000) + 60.00000)));
         traceline (spot1, spot2, FALSE, self);
         if ( (trace_fraction == 1.00000) ) {

            tracearea (spot1, spot2, '-30.00000 -30.00000 0.00000', '30.00000 30.00000 64.00000', FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               spot3 = (spot2 + (v_up * -4.00000));
               traceline (spot2, spot3, FALSE, self);
               if ( (trace_fraction == 1.00000) ) {

                  trace_fraction = 0.00000;
               } else {

                  trace_fraction = 1.00000;

               }

            }

         }
         loop_cnt += 1.00000;
         if ( (loop_cnt > 500.00000) ) {

            self.nextthink = (time + 2.00000);
            return ;

         }

      }
      spot2 = (spot2 + (v_forward * -16.00000));
   } else {

      self.angles_y += (self.cnt * 90.00000);
      makevectors (self.angles);
      spot2 = ((self.controller.origin + (v_forward * 36.00000)) + '0.00000 0.00000 3.00000');

   }
   self.scale = 0.10000;
   setorigin (self, spot2);
   CreateWhiteSmoke ((self.origin + '0.00000 0.00000 3.00000'));
   spider_grow ();
};


void  ()skullwiz_summoninit =  {
local entity spider;
local entity spider2;
   AdvanceFrame( 15.00000, 44.00000);
   if ( (self.frame == 35.00000) ) {

      spider = spawn ();
      spider.cnt = 0.00000;
      spider.nextthink = (time + 0.01000);
      spider.think = skullwiz_summon;
      spider.controller = self;
      spider.angles = self.angles;
      setorigin (spider, self.origin);
      if ( (random () < 0.15000) ) {

         spider2 = spawn ();
         spider2.cnt = 1.00000;
         spider2.nextthink = (time + 0.03000);
         spider2.think = skullwiz_summon;
         spider2.angles = self.angles;
         setorigin (spider2, self.origin);

      }

   }
   if ( cycle_wrapped ) {

      skullwiz_run ();

   }
};


void  ()skullwiz_transition =  {
   AdvanceFrame( 94.00000, 100.00000);
   if ( (self.frame == 94.00000) ) {

      self.attack_finished = ((time + (random () * 3.00000)) + 0.50000);

   }
   if ( cycle_wrapped ) {

      skullwiz_run ();

   }
};


void  ()skullwiz_pain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = skullwiz_pain;
   if ( (AdvanceFrame (45.00000, 56.00000) == AF_END) ) {

      self.pain_finished = ((time + (random () * 2.00000)) + 1.00000);
      self.enemy = world;
      if ( (random () < 0.20000) ) {

         skullwiz_blink ();
      } else {

         skullwiz_transition ();

      }

   }
};


void  ()launch_skullshot =  {
local vector diff = '0.00000 0.00000 0.00000';
   self.last_attack = time;
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.drawflags = MLS_FIREFLICKER;
   setmodel (newmis, "models/skulshot.mdl");
   newmis.hull = HULL_POINT;
   newmis.takedamage = DAMAGE_YES;
   newmis.health = 3.00000;
   newmis.dmg = 10.00000;
   newmis.th_die = MultiExplode;
   setsize (newmis, '-7.00000 -7.00000 -10.00000', '7.00000 7.00000 10.00000');
   setorigin (newmis, (((self.origin + (v_forward * -14.00000)) + (v_right * 8.00000)) + (v_up * 50.00000)));
   makevectors (self.angles);
   diff = ((self.enemy.origin + self.enemy.view_ofs) - newmis.origin);
   newmis.velocity = normalize (diff);
   newmis.velocity = (newmis.velocity * 600.00000);
   newmis.classname = "mummymissile";
   newmis.angles = vectoangles (newmis.velocity);
   newmis.scale = 1.70000;
   newmis.touch = T_MissileTouch;
   newmis.nextthink = (time + 2.50000);
   newmis.think = T_MissileTouch;
};


void  ()skullwiz_missile =  {
local float result = 0.00000;
local vector delta = '0.00000 0.00000 0.00000';
   AdvanceFrame( 63.00000, 77.00000);
   delta = (self.enemy.origin - self.origin);
   if ( (vlen (delta) < 50.00000) ) {

      skullwiz_melee ();

   }
   if ( (self.frame == 73.00000) ) {

      ai_face ();
      launch_skullshot ();

   }
   if ( cycle_wrapped ) {

      if ( (random () < 0.50000) ) {

         skullwiz_missile ();
      } else {

         skullwiz_transition ();

      }
   } else {

      ai_face ();

   }
};


void  ()skullwiz_missile_init =  {
   AdvanceFrame( 57.00000, 62.00000);
   if ( cycle_wrapped ) {

      skullwiz_missile ();

   }
};


void  ()skullwiz_blinkin =  {
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = skullwiz_blinkin;
   self.scale += 0.10000;
   ai_face ();
   if ( (self.scale >= 1.00000) ) {

      self.scale = 0.00000;
      self.th_pain = skullwiz_pain;
      skullwiz_run ();

   }
};


void  ()skullwiz_blinkin1 =  {
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = skullwiz_blinkin;
   setmodel (self, "models/skullwiz.mdl");
   setsize (self, '-24.00000 -24.00000 0.00000', '24.00000 24.00000 64.00000');
};


void  ()skullwiz_ininit =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector spot3 = '0.00000 0.00000 0.00000';
local vector newangle = '0.00000 0.00000 0.00000';
local float loop_cnt = 0.00000;
   trace_fraction = 0.00000;
   loop_cnt = 0.00000;
   while ( (trace_fraction < 1.00000) ) {

      newangle = self.angles;
      newangle_y = (random () * 360.00000);
      makevectors (newangle);
      spot1 = self.origin;
      spot2 = (spot1 + (v_forward * ((random () * 600.00000) + 100.00000)));
      traceline (spot1, spot2, FALSE, self);
      if ( (trace_fraction == 1.00000) ) {

         tracearea (spot1, spot2, '-32.00000 -32.00000 0.00000', '32.00000 32.00000 64.00000', FALSE, self);
         if ( (trace_fraction == 1.00000) ) {

            spot3 = (spot2 + (v_up * -4.00000));
            traceline (spot2, spot3, FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               trace_fraction = 0.00000;
            } else {

               trace_fraction = 1.00000;

            }

         }

      }
      loop_cnt += 1.00000;
      if ( (loop_cnt > 500.00000) ) {

         self.nextthink = (time + 2.00000);
         return ;

      }

   }
   spot2 = (spot2 + (v_forward * -32.00000));
   self.origin = spot2;
   self.think = skullwiz_blinkin1;
   self.nextthink = (time + 0.20000);
   CreateRedFlash ((self.origin + '0.00000 0.00000 40.00000'));
};


void  ()skullwiz_blinkout =  {
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = skullwiz_blinkout;
   self.scale -= 0.10000;
   if ( ((self.scale > 0.19000) && (self.scale < 0.29000)) ) {

      CreateRedFlash ((self.origin + '0.00000 0.00000 40.00000'));

   }
   if ( (self.scale < 0.10000) ) {

      setmodel (self, string_null);
      self.nextthink = ((time + (random () * 2.50000)) + 0.50000);
      self.think = skullwiz_ininit;

   }
};


void  ()skullwiz_blink =  {
   AdvanceFrame( 78.00000, 93.00000);
   if ( (self.frame == 93.00000) ) {

      self.scale = 1.00000;
      if ( (self.spawnflags & 32.00000) ) {

         self.drawflags = ((MLS_ABSLIGHT + SCALE_ORIGIN_BOTTOM) + SCALE_TYPE_ZONLY);
      } else {

         self.drawflags = ((self.drawflags & SCALE_TYPE_MASKOUT) | SCALE_TYPE_XYONLY);

      }
      self.th_pain = SUB_Null;
      skullwiz_blinkout ();

   }
};


void  ()skullwiz_push =  {
local vector delta = '0.00000 0.00000 0.00000';
local float ldmg = 0.00000;
   delta = (self.enemy.origin - self.origin);
   if ( (vlen (delta) > 80.00000) ) {

      return ;

   }
   self.last_attack = time;
   ldmg = (random () * 10.00000);
   T_Damage (self.enemy, self, self, ldmg);
   self.enemy.velocity = (delta * 10.00000);
   if ( (self.enemy.flags & FL_ONGROUND) ) {

      self.enemy.flags = (self.enemy.flags - FL_ONGROUND);

   }
   self.enemy.velocity_z = 200.00000;
};


void  ()skullwiz_melee =  {
local float result = 0.00000;
local vector delta = '0.00000 0.00000 0.00000';
   AdvanceFrame( 63.00000, 77.00000);
   if ( (self.frame == 73.00000) ) {

      if ( (random () < 0.20000) ) {

         skullwiz_summoninit ();
      } else {

         skullwiz_push ();
         if ( (random () < 0.50000) ) {

            skullwiz_missile_init ();

         }

      }

   }
   if ( cycle_wrapped ) {

      delta = (self.enemy.origin - self.origin);
      if ( (vlen (delta) > 80.00000) ) {

         skullwiz_run ();

      }
   } else {

      ai_charge (1.30000);

   }
};


void  ()skullwiz_run =  {
local vector delta = '0.00000 0.00000 0.00000';
   AdvanceFrame( 101.00000, 124.00000);
   delta = (self.enemy.origin - self.origin);
   if ( (vlen (delta) < 80.00000) ) {

      self.attack_finished = (time - 1.00000);

   }
   if ( (self.frame == 101.00000) ) {

      if ( (random () < 0.15000) ) {

         skullwiz_blink ();

      }

   }
   if ( (self.attack_finished > time) ) {

      movetogoal (1.30000);
   } else {

      ai_run (1.30000);

   }
};


void  ()skullwiz_walk =  {
   AdvanceFrame( 101.00000, 124.00000);
   ai_walk (1.30000);
};


void  ()skullwiz_stand =  {
   AdvanceFrame( 101.00000, 101.00000);
   ai_stand ();
};


void  ()monster_skull_wizard =  {
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model ("models/skullwiz.mdl");
      precache_model ("models/skulbook.mdl");
      precache_model ("models/skulhead.mdl");
      precache_model ("models/skulshot.mdl");
      precache_model ("models/spider.mdl");

   }
   setmodel (self, "models/skullwiz.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.mass = 4.00000;
   self.mintel = 5.00000;
   self.thingtype = THINGTYPE_FLESH;
   self.th_stand = skullwiz_stand;
   self.th_walk = skullwiz_walk;
   self.th_run = skullwiz_run;
   self.th_melee = skullwiz_melee;
   self.th_missile = skullwiz_missile_init;
   self.th_pain = skullwiz_pain;
   self.th_die = skullwiz_die;
   self.th_possum = skullwiz_playdead;
   self.th_possum_up = skullwiz_possum_up;
   setsize (self, '-24.00000 -24.00000 0.00000', '24.00000 24.00000 64.00000');
   self.health = 120.00000;
   self.flags = (self.flags | FL_MONSTER);
   self.yaw_speed = 10.00000;
   if ( (self.spawnflags & 32.00000) ) {

      self.drawflags = MLS_ABSLIGHT;
      self.abslight = 0.00000;
      self.effects = EF_DARKLIGHT;
      self.solid = SOLID_PHASE;

   }
   walkmonster_start ();
};

