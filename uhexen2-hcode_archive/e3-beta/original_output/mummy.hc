float MUMMY_NONE   =  0.00000;
float MUMMY_LARM   =  1.00000;
float MUMMY_RARM   =  2.00000;
float MUMMY_LEG   =  3.00000;
float MUMMY_WAVER   =  1.00000;
float MUMMY_DOWN   =  2.00000;
void  ()mummyrun;
void  ()mummywalk;
void  ()mummymelee;

void  ()mflame_rundown =  {
   AdvanceFrame( 7.00000, 0.00000);
   if ( cycle_wrapped ) {

      remove (self);

   }
};


void  ()mflame_runup =  {
   AdvanceFrame( 0.00000, 7.00000);
   if ( cycle_wrapped ) {

      self.frame = 7.00000;
      self.think = mflame_rundown;
      self.nextthink = (time + 0.05000);

   }
};


void  ()mflame_burn =  {
local float damg = 0.00000;
   if ( ((other.health && (other != self.owner)) && (self.pain_finished < time)) ) {

      damg = (5.00000 + (random () * 5.00000));
      T_Damage (other, self, self.owner, damg);
      self.pain_finished = (time + 0.05000);

   }
};


void  ()SpawnMummyFlame =  {
local entity new;
   traceline (self.origin, (self.origin - '0.00000 0.00000 600.00000'), TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   new = spawn ();
   setorigin (new, trace_endpos);
   setmodel (new, "models/mumshot.mdl");
   new.movetype = MOVETYPE_NONE;
   new.solid = SOLID_TRIGGER;
   setsize (new, '-8.00000 -8.00000 0.00000', '8.00000 8.00000 16.00000');
   new.owner = self.owner;
   new.pain_finished = 0.00000;
   new.drawflags = MLS_ABSLIGHT;
   new.abslight = 0.50000;
   new.think = mflame_runup;
   new.nextthink = (time + HX_FRAME_TIME);
   new.touch = mflame_burn;
   if ( (self.lifetime < time) ) {

      remove (self);
   } else {

      self.nextthink = (time + 0.08000);
      self.think = SpawnMummyFlame;

   }
};


void  ()mumshot_gone =  {
local float damg = 0.00000;
   if ( other.health ) {

      damg = (15.00000 + (random () * 10.00000));
      T_Damage (other, self, self.owner, damg);

   }
   remove (self);
};


void  ()launch_mumshot =  {
local vector diff = '0.00000 0.00000 0.00000';
   self.last_attack = time;
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   setmodel (newmis, "models/mumshot.mdl");
   newmis.effects = EF_NODRAW;
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, (((self.origin + (v_forward * -14.00000)) + (v_right * -15.00000)) + (v_up * 50.00000)));
   CreateRedFlash ((((self.origin + (v_forward * -14.00000)) + (v_right * -15.00000)) + (v_up * 50.00000)));
   sound (self, CHAN_WEAPON, "mummy/mislfire.wav", 1.00000, ATTN_NORM);
   makevectors (self.angles);
   diff = ((self.enemy.origin + '0.00000 0.00000 20.00000') - newmis.origin);
   newmis.velocity = normalize (diff);
   newmis.velocity = (newmis.velocity * 1200.00000);
   newmis.classname = "mummymissile";
   newmis.avelocity = '0.00000 0.00000 1000.00000';
   newmis.angles = vectoangles (newmis.velocity);
   newmis.touch = mumshot_gone;
   newmis.lifetime = (time + 2.50000);
   newmis.nextthink = (time + 0.04000);
   newmis.think = SpawnMummyFlame;
};


void  ()launch_mumshot2 =  {
local vector diff = '0.00000 0.00000 0.00000';
   self.last_attack = time;
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   setmodel (newmis, "models/fireball.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, (((self.origin + (v_forward * -14.00000)) + (v_right * -15.00000)) + (v_up * 50.00000)));
   sound (self, CHAN_WEAPON, "mummy/mislfire.wav", 1.00000, ATTN_NORM);
   makevectors (self.angles);
   diff = ((self.enemy.origin + '0.00000 0.00000 20.00000') - newmis.origin);
   newmis.velocity = normalize (diff);
   newmis.velocity = (newmis.velocity * 600.00000);
   newmis.classname = "mummymissile";
   newmis.avelocity = '0.00000 0.00000 1000.00000';
   newmis.angles = vectoangles (newmis.velocity);
   newmis.touch = T_MissileTouch;
   newmis.nextthink = (time + 2.50000);
   newmis.think = SUB_Remove;
};


void  ()mummy_die =  {
   sound (self, CHAN_VOICE, "mummy/die.wav", 1.00000, ATTN_NORM);
   chunk_death ();
   self.nextthink = (time + 0.01000);
   self.think = SUB_Remove;
   return ;
};


void  ()mummy_throw_rightleg =  {
local entity new;
   new = spawn ();
   new.origin = (self.origin + '0.00000 10.00000 40.00000');
   setmodel (new, "models/leg.mdl");
   setsize (new, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   new.velocity = VelocityForDamage (40.00000);
   new.movetype = MOVETYPE_BOUNCE;
   new.solid = SOLID_NOT;
   new.avelocity_x = (random () * 600.00000);
   new.avelocity_y = (random () * 600.00000);
   new.avelocity_z = (random () * 600.00000);
   new.think = SUB_Remove;
   new.ltime = time;
   new.nextthink = ((time + 10.00000) + (random () * 10.00000));
   self.parts_gone = MUMMY_LEG;
   self.mummy_state = MUMMY_WAVER;
};


void  ()mummy_throw_rightarm =  {
local entity new;
   new = spawn ();
   new.origin = (self.origin + '0.00000 10.00000 40.00000');
   setmodel (new, "models/larm.mdl");
   setsize (new, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   new.velocity = VelocityForDamage (40.00000);
   new.movetype = MOVETYPE_BOUNCE;
   new.solid = SOLID_NOT;
   new.avelocity_x = (random () * 600.00000);
   new.avelocity_y = (random () * 600.00000);
   new.avelocity_z = (random () * 600.00000);
   new.think = SUB_Remove;
   new.ltime = time;
   new.nextthink = ((time + 10.00000) + (random () * 10.00000));
   self.parts_gone = MUMMY_RARM;
};


void  ()mummy_throw_leftarm =  {
local entity new;
   new = spawn ();
   new.origin = (self.origin + '0.00000 -10.00000 40.00000');
   setmodel (new, "models/larm.mdl");
   setsize (new, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   new.velocity = VelocityForDamage (40.00000);
   new.movetype = MOVETYPE_BOUNCE;
   new.solid = SOLID_NOT;
   new.avelocity_x = (random () * 600.00000);
   new.avelocity_y = (random () * 600.00000);
   new.avelocity_z = (random () * 600.00000);
   new.think = SUB_Remove;
   new.ltime = time;
   new.nextthink = ((time + 10.00000) + (random () * 10.00000));
   self.parts_gone = MUMMY_LARM;
};


void  ()mummy_pain =  {
local float hold_parts = 0.00000;
   if ( (self.pain_finished > time) ) {

      return ;

   }
   sound (self, CHAN_VOICE, "mummy/pain.wav", 1.00000, ATTN_NORM);
   hold_parts = self.parts_gone;
   if ( (self.health < 30.00000) ) {

      if ( (self.parts_gone <= MUMMY_NONE) ) {

         mummy_throw_leftarm ();

      }
      if ( (self.parts_gone <= MUMMY_LARM) ) {

         mummy_throw_rightarm ();

      }
      if ( (self.parts_gone <= MUMMY_RARM) ) {

         mummy_throw_rightleg ();

      }
   } else {

      if ( (self.health < 60.00000) ) {

         if ( (self.parts_gone <= MUMMY_NONE) ) {

            mummy_throw_leftarm ();

         }
         if ( (self.parts_gone <= MUMMY_LARM) ) {

            mummy_throw_rightarm ();

         }
      } else {

         if ( (self.health < 100.00000) ) {

            if ( (self.parts_gone == MUMMY_NONE) ) {

               mummy_throw_leftarm ();

            }

         }

      }

   }
   if ( (hold_parts != self.parts_gone) ) {

      sound (self, CHAN_BODY, "mummy/limbloss.wav", 1.00000, ATTN_NORM);

   }
};


void  ()mummymissile =  {
local float result = 0.00000;
local vector delta = '0.00000 0.00000 0.00000';
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = mummymissile;
   delta = (self.enemy.origin - self.origin);
   if ( (vlen (delta) < 70.00000) ) {

      mummymelee ();

   }
   if ( (self.parts_gone == MUMMY_NONE) ) {

      result = AdvanceFrame (13.00000, 36.00000);
      if ( (self.frame == 22.00000) ) {

         sound (self, CHAN_WEAPON, "mummy/tap.wav", 1.00000, ATTN_NORM);

      }
      if ( (self.frame == 29.00000) ) {

         launch_mumshot ();

      }
      if ( (result == AF_END) ) {

         mummyrun ();
      } else {

         ai_face ();

      }
   } else {

      if ( (self.parts_gone == MUMMY_LARM) ) {

         result = AdvanceFrame (97.00000, 112.00000);
         if ( (self.frame == 112.00000) ) {

            launch_mumshot ();

         }
         if ( (result == AF_END) ) {

            mummyrun ();
         } else {

            ai_face ();

         }
      } else {

         mummyrun ();

      }

   }
};


void  ()mummypunch =  {
local vector delta = '0.00000 0.00000 0.00000';
local float ldmg = 0.00000;
   delta = (self.enemy.origin - self.origin);
   if ( (vlen (delta) > 50.00000) ) {

      return ;

   }
   self.last_attack = time;
   ldmg = (random () * DMG_MUMMY_PUNCH);
   T_Damage (self.enemy, self, self, ldmg);
   sound (self, CHAN_WEAPON, "weapons/gauntht1.wav", 1.00000, ATTN_NORM);
};


void  ()mummymelee =  {
local float result = 0.00000;
local vector delta = '0.00000 0.00000 0.00000';
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = mummymelee;
   if ( (self.parts_gone == MUMMY_NONE) ) {

      result = AdvanceFrame (47.00000, 64.00000);
      if ( (self.frame == 54.00000) ) {

         sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);

      }
      if ( (self.frame == 57.00000) ) {

         mummypunch ();

      }
   } else {

      if ( (self.parts_gone == MUMMY_LARM) ) {

         result = AdvanceFrame (65.00000, 82.00000);
         if ( (self.frame == 72.00000) ) {

            sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);

         }
         if ( (self.frame == 75.00000) ) {

            mummypunch ();

         }
      } else {

         if ( (self.parts_gone == MUMMY_RARM) ) {

            result = AdvanceFrame (37.00000, 46.00000);
            if ( (self.frame == 41.00000) ) {

               sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

            }
            if ( (self.frame == 44.00000) ) {

               mummypunch ();

            }
         } else {

            mummywalk ();

         }

      }

   }
   if ( (result == AF_END) ) {

      delta = (self.enemy.origin - self.origin);
      if ( (vlen (delta) > 80.00000) ) {

         mummyrun ();

      }
   } else {

      ai_charge (1.00000);

   }
};


void  ()mummyrun =  {
local float distance = 0.00000;
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = mummyrun;
   if ( (self.parts_gone == MUMMY_NONE) ) {

      if ( ((random () < 0.10000) && (self.frame == 83.00000)) ) {

         sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

      }
      AdvanceFrame (83.00000, 96.00000);
      if ( (self.frame == 88.00000) ) {

         sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.frame == 89.00000) ) {

            sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

         }

      }
      if ( ((self.frame >= 83.00000) && (self.frame <= 86.00000)) ) {

         distance = 3.25000;
      } else {

         distance = 2.25000;

      }
   } else {

      if ( (self.parts_gone == MUMMY_LARM) ) {

         if ( ((random () < 0.10000) && (self.frame == 97.00000)) ) {

            sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

         }
         AdvanceFrame (97.00000, 112.00000);
         if ( (self.frame == 102.00000) ) {

            sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
         } else {

            if ( (self.frame == 104.00000) ) {

               sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

            }

         }
         distance = 3.00000;
      } else {

         if ( (self.parts_gone == MUMMY_RARM) ) {

            if ( ((random () < 0.10000) && (self.frame == 113.00000)) ) {

               sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

            }
            AdvanceFrame (113.00000, 130.00000);
            if ( (self.frame == 120.00000) ) {

               sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
            } else {

               if ( (self.frame == 122.00000) ) {

                  sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

               }

            }
            distance = 3.00000;
         } else {

            if ( (self.parts_gone <= MUMMY_LEG) ) {

               if ( (self.mummy_state == MUMMY_WAVER) ) {

                  AdvanceFrame (0.00000, 12.00000);
                  if ( (self.frame == 12.00000) ) {

                     self.mummy_state = MUMMY_DOWN;

                  }
               } else {

                  AdvanceFrame (131.00000, 140.00000);

               }
               distance = 0.00000;

            }

         }

      }

   }
   ai_run (distance);
};


void  ()mummywalk =  {
local float distance = 0.00000;
   self.nextthink = ((time + HX_FRAME_TIME) + 0.02000);
   self.think = mummywalk;
   if ( (self.parts_gone == MUMMY_NONE) ) {

      if ( ((random () < 0.10000) && (self.frame == 83.00000)) ) {

         sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

      }
      AdvanceFrame (83.00000, 96.00000);
      if ( (self.frame == 88.00000) ) {

         sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.frame == 89.00000) ) {

            sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

         }

      }
      if ( ((self.frame >= 83.00000) && (self.frame <= 86.00000)) ) {

         distance = 3.25000;
      } else {

         distance = 2.25000;

      }
   } else {

      if ( (self.parts_gone == MUMMY_LARM) ) {

         if ( ((random () < 0.10000) && (self.frame == 97.00000)) ) {

            sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

         }
         AdvanceFrame (97.00000, 112.00000);
         distance = 2.25000;
         if ( (self.frame == 102.00000) ) {

            sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
         } else {

            if ( (self.frame == 104.00000) ) {

               sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

            }

         }
      } else {

         if ( (self.parts_gone == MUMMY_RARM) ) {

            if ( ((random () < 0.10000) && (self.frame == 113.00000)) ) {

               sound (self, CHAN_VOICE, "mummy/moan.wav", 1.00000, ATTN_NORM);

            }
            AdvanceFrame (113.00000, 130.00000);
            distance = 2.25000;
            if ( (self.frame == 120.00000) ) {

               sound (self, CHAN_BODY, "mummy/step.wav", 1.00000, ATTN_NORM);
            } else {

               if ( (self.frame == 122.00000) ) {

                  sound (self, CHAN_BODY, "mummy/slide.wav", 1.00000, ATTN_NORM);

               }

            }
         } else {

            if ( (self.parts_gone <= MUMMY_LEG) ) {

               if ( (self.mummy_state == MUMMY_WAVER) ) {

                  AdvanceFrame (0.00000, 12.00000);
                  if ( (self.frame == 12.00000) ) {

                     self.mummy_state = MUMMY_DOWN;

                  }
               } else {

                  AdvanceFrame (131.00000, 140.00000);
                  if ( (self.frame == 131.00000) ) {

                     sound (self, CHAN_BODY, "mummy/crawl.wav", 1.00000, ATTN_NORM);

                  }

               }
               distance = 0.00000;

            }

         }

      }

   }
   ai_walk (distance);
};


void  ()mummystand =  {
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = mummystand;
   self.frame = 83.00000;
   ai_stand ();
};


void  ()monster_mummy =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model ("models/mummy.mdl");
      precache_model ("models/h_ogre.mdl");
      precache_model ("models/larm.mdl");
      precache_model ("models/leg.mdl");
      precache_model ("models/mumshot.mdl");
      precache_sound ("mummy/sight.wav");
      precache_sound ("mummy/die.wav");
      precache_sound ("mummy/mislfire.wav");
      precache_sound ("mummy/limbloss.wav");
      precache_sound ("mummy/moan.wav");
      precache_sound ("mummy/pain.wav");
      precache_sound ("mummy/crawl.wav");
      precache_sound ("mummy/slide.wav");
      precache_sound ("mummy/step.wav");
      precache_sound ("mummy/tap.wav");

   }
   setmodel (self, "models/mummy.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.mass = 8.00000;
   self.mintel = 3.00000;
   self.thingtype = THINGTYPE_FLESH;
   self.th_stand = mummystand;
   self.th_walk = mummywalk;
   self.th_run = mummyrun;
   self.th_melee = mummymelee;
   self.th_missile = mummymissile;
   self.th_pain = mummy_pain;
   self.th_die = mummy_die;
   self.parts_gone = MUMMY_NONE;
   if ( !(self.spawnflags & NO_JUMP) ) {

      self.spawnflags += NO_JUMP;

   }
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 50.00000');
   self.health = 150.00000;
   self.flags = (self.flags | FL_MONSTER);
   self.yaw_speed = 10.00000;
   self.experience_value = 500.00000;
   walkmonster_start ();
};

