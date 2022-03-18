float ARCHER_STUCK   =  2.00000;
float GREEN_ARROW   =  0.00000;
float RED_ARROW   =  1.00000;
void  ()archer_run;
void  ()archerredraw;
void  ()archerdraw;

void  ()archer_arrow_touch =  {
local float damg = 0.00000;
local vector delta = '0.00000 0.00000 0.00000';
   damg = (5.00000 + (random () * 10.00000));
   if ( ((other.classname == "player") && (self.classname == "red_arrow")) ) {

      delta = (other.origin - self.origin);
      other.velocity = (delta * 20.00000);
      other.flags = (other.flags - FL_ONGROUND);
      other.velocity_z = 225.00000;

   }
   T_Damage (other, self, self.owner, damg);
   self.origin = ((self.origin - (8.00000 * normalize (self.velocity))) - '0.00000 0.00000 40.00000');
   sound (self, CHAN_WEAPON, "weapons/explode.wav", 1.00000, ATTN_NORM);
   if ( (self.classname == "red_arrow") ) {

      CreateRedSpark (self.origin);
   } else {

      CreateGreenSpark (self.origin);

   }
   self.effects = (self.effects | EF_NODRAW);
   remove (self);
};


void  ()archer_possum_up =  {
   AdvanceFrame( 39.00000, 18.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()archer_playdead =  {
   self.frame = 39.00000;
   self.think = archer_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  ()archer_dying =  {
   AdvanceFrame( 18.00000, 39.00000);
   if ( (self.health < -80.00000) ) {

      chunk_death ();
      remove (self);

   }
   if ( cycle_wrapped ) {

      self.frame = 39.00000;
      MakeSolidCorpse ("remove");

   }
};


void  ()archer_die =  {
   if ( (self.health < -40.00000) ) {

      chunk_death ();
      return ;
   } else {

      sound (self, CHAN_VOICE, "archer/death.wav", 1.00000, ATTN_NORM);

   }
   archer_dying ();
};


void  ()archer_pain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = archer_pain;
   if ( (self.frame == 70.00000) ) {

      sound (self, CHAN_VOICE, "archer/pain.wav", 1.00000, ATTN_NORM);

   }
   if ( (AdvanceFrame (69.00000, 92.00000) == AF_END) ) {

      self.pain_finished = ((time + (random () * 3.00000)) + 1.00000);
      self.enemy = world;
      archer_run ();

   }
};


void  (float arrowtype)archer_launcharrow =  {
local vector diff = '0.00000 0.00000 0.00000';
   self.last_attack = time;
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   setmodel (newmis, "models/akarrow.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   makevectors (self.angles);
   setorigin (newmis, (((self.origin + (v_forward * -14.00000)) + (v_right * 10.00000)) + (v_up * 36.00000)));
   diff = ((self.enemy.origin + self.enemy.view_ofs) - newmis.origin);
   newmis.velocity = normalize (diff);
   newmis.velocity = (newmis.velocity * 1000.00000);
   newmis.angles = vectoangles (newmis.velocity);
   if ( (arrowtype == GREEN_ARROW) ) {

      sound (self, CHAN_WEAPON, "archer/arrowg.wav", 1.00000, ATTN_NORM);
      newmis.classname = "green_arrow";
      newmis.skin = 0.00000;
   } else {

      sound (self, CHAN_WEAPON, "archer/arrowr.wav", 1.00000, ATTN_NORM);
      CreateRedFlash ((((self.origin + (v_forward * 24.00000)) + (v_right * 10.00000)) + (v_up * 36.00000)));
      newmis.classname = "red_arrow";
      newmis.skin = 1.00000;

   }
   newmis.nextthink = (time + 2.50000);
   newmis.touch = archer_arrow_touch;
};


void  ()archermissile =  {
local float chance = 0.00000;
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector delta = '0.00000 0.00000 0.00000';
   AdvanceFrame( 64.00000, 68.00000);
   if ( (self.frame == 65.00000) ) {

      makevectors (self.angles);
      spot1 = ((self.origin + (v_right * 10.00000)) + (v_up * 36.00000));
      spot2 = (self.enemy.origin + self.enemy.view_ofs);
      traceline (spot1, spot2, FALSE, self);
      if ( (trace_ent != self.enemy) ) {

         self.attack_finished = ((time + random ()) + 0.50000);
         archer_run ();
      } else {

         enemy_range = range (self.enemy);
         chance = 0.50000;
         if ( (random () < chance) ) {

            archer_launcharrow (RED_ARROW);
         } else {

            archer_launcharrow (GREEN_ARROW);

         }
         self.attack_finished = ((time + (random () * 2.00000)) + 2.00000);

      }

   }
   if ( cycle_wrapped ) {

      if ( (enemy_range == RANGE_MELEE) ) {

         chance = 0.80000;
      } else {

         if ( (enemy_range == RANGE_NEAR) ) {

            chance = 0.60000;
         } else {

            if ( (enemy_range == RANGE_MID) ) {

               chance = 0.30000;
            } else {

               chance = 0.00000;

            }

         }

      }
      if ( (random () < chance) ) {

         self.frame = 126.00000;
         archerredraw ();
      } else {

         self.attack_finished = ((time + (random () * 2.00000)) + 2.00000);
         archer_run ();

      }
   } else {

      ai_face ();

   }
};


void  ()archerredraw =  {
   AdvanceFrame( 117.00000, 140.00000);
   if ( (self.frame == 124.00000) ) {

      dprint (" r ");
      sound (self, CHAN_WEAPON, "archer/draw.wav", 1.00000, ATTN_NORM);

   }
   if ( cycle_wrapped ) {

      archermissile ();
   } else {

      ai_face ();

   }
};


void  ()archerdraw =  {
   AdvanceFrame( 40.00000, 63.00000);
   if ( (self.frame == 49.00000) ) {

      sound (self, CHAN_WEAPON, "archer/draw.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.frame == 41.00000) ) {

      self.frame += 1.00000;

   }
   if ( (self.frame == 43.00000) ) {

      self.frame += 1.00000;

   }
   if ( (self.frame == 45.00000) ) {

      self.frame += 1.00000;

   }
   if ( (self.frame == 47.00000) ) {

      self.frame += 1.00000;

   }
   if ( (self.frame == 49.00000) ) {

      self.frame += 1.00000;

   }
   if ( (self.frame == 51.00000) ) {

      self.frame += 1.00000;

   }
   if ( ((self.frame >= 47.00000) && (self.frame <= 57.00000)) ) {

      if ( (self.spawnflags & ARCHER_STUCK) ) {

         ai_back (0.00000);
      } else {

         ai_back (2.00000);

      }

   }
   if ( cycle_wrapped ) {

      archermissile ();
   } else {

      ai_face ();

   }
};


void  ()archer_run =  {
   AdvanceFrame( 141.00000, 162.00000);
   if ( ((random () < 0.10000) && (self.frame == 141.00000)) ) {

      sound (self, CHAN_VOICE, "archer/growl.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.spawnflags & ARCHER_STUCK) ) {

      self.frame = 141.00000;
      ai_run (0.00000);
   } else {

      ai_run (2.00000);

   }
};


void  ()archer_walk =  {
   AdvanceFrame( 141.00000, 162.00000);
   self.nextthink = ((time + HX_FRAME_TIME) + 0.01000);
   if ( ((random () < 0.05000) && (self.frame == 141.00000)) ) {

      sound (self, CHAN_VOICE, "archer/growl.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.spawnflags & ARCHER_STUCK) ) {

      self.frame = 141.00000;
      ai_walk (0.00000);
   } else {

      ai_walk (2.00000);

   }
};


void  ()archer_stand =  {
   AdvanceFrame( 141.00000, 141.00000);
   ai_stand ();
};


void  ()monster_spew =  {
local entity item;
   if ( (random () < 0.25000) ) {

      item = spawn ();
      item.origin = (self.origin - '0.00000 0.00000 24.00000');
      item.flags = FL_ITEM;
      item.solid = SOLID_TRIGGER;
      item.movetype = MOVETYPE_TOSS;
      item.owner = self;
      item.artifact_ignore_owner_time = (time + 2.00000);
      item.artifact_ignore_time = (time + 1.00000);
      item.velocity_z = 400.00000;
      item.velocity_x = (-20.00000 + (random () * 40.00000));
      item.velocity_y = (-20.00000 + (random () * 40.00000));

   }
};


void  ()monster_archer =  {
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model ("models/archer.mdl");
      precache_model ("models/archerhd.mdl");
      precache_model ("models/gspark.spr");
      precache_sound ("archer/arrowg.wav");
      precache_sound ("archer/arrowr.wav");
      precache_sound ("archer/growl.wav");
      precache_sound ("archer/pain.wav");
      precache_sound ("archer/sight.wav");
      precache_sound ("archer/death.wav");
      precache_sound ("archer/draw.wav");

   }
   setmodel (self, "models/archer.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.thingtype = THINGTYPE_FLESH;
   self.th_stand = archer_stand;
   self.th_walk = archer_walk;
   self.th_run = archer_run;
   self.th_melee = archerdraw;
   self.th_missile = archerdraw;
   self.th_pain = archer_pain;
   self.th_die = archer_die;
   self.th_possum = archer_playdead;
   self.th_possum_up = archer_possum_up;
   self.decap = 0.00000;
   self.mass = 12.00000;
   self.headmodel = "models/archerhd.mdl";
   self.mintel = 7.00000;
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 50.00000');
   self.health = 80.00000;
   self.flags = (self.flags | FL_MONSTER);
   self.yaw_speed = 10.00000;
   self.view_ofs = '0.00000 0.00000 40.00000';
   walkmonster_start ();
};


float  ()ArcherCheckAttack =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local entity targ;
local float chance = 0.00000;
   if ( (time < self.attack_finished) ) {

      return ( FALSE );

   }
   if ( !enemy_vis ) {

      return ( FALSE );

   }
   if ( (enemy_range == RANGE_FAR) ) {

      if ( (self.attack_state != AS_STRAIGHT) ) {

         self.attack_state = AS_STRAIGHT;
         archer_run ();

      }
      return ( FALSE );

   }
   targ = self.enemy;
   makevectors (self.angles);
   spot1 = ((self.origin + (v_right * 10.00000)) + (v_up * 36.00000));
   spot2 = (targ.origin + targ.view_ofs);
   traceline (spot1, spot2, FALSE, self);
   if ( (trace_ent != targ) ) {

      if ( (self.attack_state != AS_STRAIGHT) ) {

         self.attack_state = AS_STRAIGHT;
         archer_run ();

      }
      return ( FALSE );

   }
   if ( (enemy_range == RANGE_MELEE) ) {

      chance = 0.90000;
   } else {

      if ( (enemy_range == RANGE_NEAR) ) {

         chance = 0.70000;
      } else {

         if ( (enemy_range == RANGE_MID) ) {

            chance = 0.50000;
         } else {

            chance = 0.00000;

         }

      }

   }
   if ( (random () < chance) ) {

      self.attack_state = AS_MISSILE;
      return ( TRUE );

   }
   if ( (enemy_range == RANGE_MID) ) {

      if ( (self.attack_state != AS_STRAIGHT) ) {

         self.attack_state = AS_STRAIGHT;
         archer_run ();

      }
   } else {

      if ( (self.attack_state != AS_SLIDING) ) {

         self.attack_state = AS_SLIDING;
         archer_run ();

      }

   }
   return ( FALSE );
};

