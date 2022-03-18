float MONSTER_STAND_GROUND   =  1.00000;
float MONSTER_HOVER   =  2.00000;
float SF_IMP_DORMANT   =  16.00000;
float PICKUP   =  32.00000;

void  ()imp_fire =  {
   if ( ((self.classname == "monster_imp_ice") || (self.classname == "monster_ice_imp")) ) {

      sound (self, CHAN_WEAPON, "imp/shard.wav", 1.00000, ATTN_NORM);
      makevectors (self.angles);
      do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), '0.00000 0.00000 0.00000');
      do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), (((v_forward * ((random () * 40.00000) - 20.00000)) + (v_right * ((random () * 40.00000) - 20.00000))) + (v_up * ((random () * 20.00000) - 10.00000))));
      do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), (((v_forward * ((random () * 40.00000) - 20.00000)) + (v_right * ((random () * 40.00000) - 20.00000))) + (v_up * ((random () * 20.00000) - 10.00000))));
      if ( (random () < 0.50000) ) {

         do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), (((v_forward * ((random () * 40.00000) - 20.00000)) + (v_right * ((random () * 40.00000) - 20.00000))) + (v_up * ((random () * 20.00000) - 10.00000))));

      }
      if ( (random () < 0.50000) ) {

         do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), (((v_forward * ((random () * 40.00000) - 20.00000)) + (v_right * ((random () * 40.00000) - 20.00000))) + (v_up * ((random () * 20.00000) - 10.00000))));

      }
      if ( (random () < 0.50000) ) {

         do_shard ('14.00000 8.00000 0.00000', (360.00000 + (random () * 150.00000)), (((v_forward * ((random () * 40.00000) - 20.00000)) + (v_right * ((random () * 40.00000) - 20.00000))) + (v_up * ((random () * 20.00000) - 10.00000))));

      }
   } else {

      sound (self, CHAN_WEAPON, "imp/fireball.wav", 1.00000, ATTN_NORM);
      do_fireball ('14.00000 8.00000 0.00000');

   }
   checkenemy ();
};

float IMP_STAGE_WAIT   =  0.00000;
float IMP_STAGE_FLY   =  1.00000;
float IMP_STAGE_HOVER   =  2.00000;
float IMP_STAGE_STRAIGHT   =  3.00000;
float IMP_STAGE_FERRY   =  4.00000;
void  ()ice_imp_fly1;
void  ()imp_init;
void  ()ice_imp_touch;
void  ()ice_imp_die;

void  ()stone_imp_awaken =  {
local float chunk_count = 0.00000;
   AdvanceFrame( 61.00000, 77.00000);
   if ( (self.frame == 64.00000) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
      self.count = 0.00000;
      self.monster_stage = IMP_STAGE_FLY;
      self.monster_duration = 0.00000;
      self.monster_awake = TRUE;
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 55.00000');
      self.mass = 3.00000;
      self.health = self.max_health;
      self.flags = (self.flags | FL_MONSTER);
      self.flags = (self.flags | FL_FLY);
      self.movetype = MOVETYPE_FLY;
      self.takedamage = DAMAGE_YES;
      self.touch = ice_imp_touch;
      self.th_die = ice_imp_die;
      self.spawnflags -= SF_IMP_DORMANT;
      self.flags2 -= FL_STONED;
      sound (self, CHAN_VOICE, "fx/wallbrk.wav", 1.00000, ATTN_NORM);
      while ( (chunk_cnt < CHUNK_MAX) ) {

         CreateModelChunks (self.size, 0.70000);
         chunk_cnt += 1.00000;

      }
      self.skin = self.oldskin;
      if ( self.skin ) {

         self.classname = "monster_imp_ice";
      } else {

         self.classname = "monster_imp_fire";

      }
      self.thingtype = THINGTYPE_FLESH;
      self.scale = 1.00000;
   } else {

      if ( (self.frame == 77.00000) ) {

         self.think = ice_imp_fly1;

      }

   }
};


void  ()imp_use =  {
   self.use = SUB_Null;
   self.targetname = "";
   if ( (activator.classname == "player") ) {

      self.goalentity = activator;
      self.enemy = activator;
   } else {

      dprint ("ERROR: monster not activated by player!\n");

   }
   self.frame = 55.00000;
   self.think = stone_imp_awaken;
   self.nextthink = (time + random ());
};


void  ()imp_init =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   self.nextthink = ((time + (random () / 2.00000)) + 0.10000);
   self.count = 0.00000;
   self.monster_stage = IMP_STAGE_FLY;
   self.monster_duration = 0.00000;
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 55.00000');
   self.monster_awake = TRUE;
};


void  ()imp_stand =  {
local float self_infront = 0.00000;
local float self_vis = 0.00000;
local float enemy_dist = 0.00000;
local float r1 = 0.00000;
local float r2 = 0.00000;
   if ( LocateTarget () ) {

      if ( (self.spawnflags & SF_IMP_DORMANT) ) {

         self_infront = infront_of_ent (self, self.enemy);
         self_vis = visible2ent (self, self.enemy);
         enemy_dist = vlen ((self.origin - self.enemy.origin));
         r1 = random ();
         r2 = random ();
         if ( (((((self_infront && self_vis) && (r1 < 0.10000)) && (r2 < 0.50000)) && (enemy_dist < 1000.00000)) || (enemy_dist <= RANGE_MELEE)) ) {

            self.goalentity = self.enemy;
            self.think = stone_imp_awaken;
         } else {

            self.enemy = world;
            self.goalentity = world;
            return ;

         }
      } else {

         self.goalentity = self.enemy;
         self.think = self.th_run;

      }

   }
};


void  (float thrust)imp_up =  {
   movestep (0.00000, 0.00000, thrust, FALSE);
   walkmove (self.angles_y, (thrust / 2.00000), FALSE);
};


void  (float InView)imp_attack =  {
local float retval = 0.00000;
   enemy_infront = infront (self.enemy);
   if ( enemy_infront ) {

      if ( ((InView >= -5.00000) && (InView <= 5.00000)) ) {

         if ( (self.frame == 49.00000) ) {

            retval = CheckMonsterAttack (MA_MISSILE, 3.00000);
            if ( (retval == MA_SUCCESSFUL) ) {

               self.velocity = '0.00000 0.00000 0.00000';

            }
         } else {

            if ( ((self.frame == 35.00000) && !(self.spawnflags & MONSTER_STAND_GROUND)) ) {

               if ( (((self.origin_z - self.enemy.origin_z) > 50.00000) && (vhlen ((self.origin - self.enemy.origin)) > 300.00000)) ) {

                  retval = CheckMonsterAttack ((MA_MELEE | MA_FAR_MELEE), 3.00000);
                  if ( (retval == MA_SUCCESSFUL) ) {

                     self.velocity = '0.00000 0.00000 0.00000';

                  }

               }

            }

         }

      }

   }
};


void  ()imp_up_down =  {
local vector end_vec = '0.00000 0.00000 0.00000';
   if ( ((self.velocity_z > -5.00000) && (self.velocity_z < 5.00000)) ) {

      self.velocity_z = 0.00000;
      if ( (random () < 0.05000) ) {

         if ( (random () < 0.50000) ) {

            makevectors (self.angles);
            end_vec = ((self.origin + (v_up * -90.00000)) + (v_forward * 100.00000));
            traceline (self.origin, end_vec, FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               self.velocity_z = -30.00000;

            }
         } else {

            makevectors (self.angles);
            end_vec = ((self.origin + (v_up * 60.00000)) + (v_forward * 100.00000));
            traceline (self.origin, end_vec, FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               self.velocity_z = 30.00000;

            }

         }
         if ( (self.flags & FL_ONGROUND) ) {

            self.flags = (self.flags - FL_ONGROUND);

         }

      }
   } else {

      self.velocity_z = (self.velocity_z / 1.05000);

   }
};


void  (float thrust)imp_fly =  {
local float dist = 0.00000;
local float retval = 0.00000;
   dist = 8.00000;
   if ( (self.monster_duration > 0.00000) ) {

      self.monster_duration = (self.monster_duration - 1.00000);

   }
   if ( ((self.enemy != world) && (self.enemy != self)) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   } else {

      self.ideal_yaw += (random () * 45.00000);

   }
   retval = ChangeYaw ();
   if ( ((retval > 20.00000) || (retval < -20.00000)) ) {

      dist = (dist / 1.50000);

   }
   if ( ((((self.monster_duration <= 0.00000) && (retval > -1.00000)) && (retval < 1.00000)) && (random () < 0.01000)) ) {

      self.monster_stage = IMP_STAGE_HOVER;
      self.monster_duration = ((random () * 40.00000) + 20.00000);
      return ;

   }
   if ( ((self.enemy != world) && (self.enemy != self)) ) {

      imp_attack (retval);

   }
   imp_up_down ();
   if ( (self.spawnflags & MONSTER_STAND_GROUND) ) {

      return ;

   }
   dist = (dist + (thrust * 4.00000));
   retval = walkmove (self.angles_y, dist, FALSE);
   if ( (((self.monster_duration <= 0.00000) && (self.enemy != world)) && (self.enemy != self)) ) {

      traceline (self.origin, self.enemy.origin, FALSE, self);
      if ( (trace_ent == self.enemy) ) {

         self.monster_last_seen = self.enemy.origin;

      }

   }
   if ( ((self.enemy != self) && (self.enemy != world)) ) {

      if ( ((self.monster_duration <= 0.00000) && !retval) ) {

         find_path (3.00000, 4.00000, 1.00000, 2.00000, retval, self.enemy.origin);
      } else {

         if ( ((self.monster_duration <= 0.00000) && (trace_ent != self.enemy)) ) {

            find_path (1.00000, 2.00000, 3.00000, 4.00000, retval, self.enemy.origin);
         } else {

            dist = vhlen ((self.origin - self.enemy.origin));
            if ( (dist < 100.00000) ) {

               self.monster_stage = IMP_STAGE_STRAIGHT;
               self.monster_duration = (300.00000 + (300.00000 * random ()));
               self.monster_check = 0.00000;

            }

         }

      }

   }
};


void  (float thrust)imp_hover =  {
local float retval = 0.00000;
   if ( ((self.enemy != world) && (self.enemy != self)) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   } else {

      self.ideal_yaw += (random () * 45.00000);

   }
   retval = ChangeYaw ();
   if ( (self.monster_duration > 0.00000) ) {

      self.monster_duration = (self.monster_duration - 1.00000);
   } else {

      self.monster_stage = IMP_STAGE_FLY;
      self.monster_duration = 0.00000;
      return ;

   }
   if ( ((self.enemy != world) && (self.enemy != self)) ) {

      imp_attack (retval);

   }
   imp_up_down ();
};


void  (float thrust)imp_straight =  {
local float dist = 0.00000;
local float retval = 0.00000;
   dist = 10.00000;
   imp_up_down ();
   self.monster_check = (self.monster_check + 1.00000);
   dist = (dist + (thrust * 4.00000));
   retval = walkmove (self.angles_y, dist, FALSE);
   if ( (!retval && (self.monster_check < 10.00000)) ) {

      self.angles_y = FindDir ();

   }
   dist = vhlen ((self.origin - self.enemy.origin));
   if ( ((dist > self.monster_duration) || !retval) ) {

      self.monster_stage = IMP_STAGE_FLY;
      self.monster_duration = 0.00000;

   }
};


void  (float thrust)imp_reverse =  {
};


void  ()imp_drop =  {
   if ( (self.enemy.flags & FL_FLY) ) {

      self.enemy.flags -= FL_FLY;

   }
   self.monster_stage = IMP_STAGE_HOVER;
};


void  (float thrust)imp_ferry =  {
local float retval = 0.00000;
local float dist = 0.00000;
local vector org = '0.00000 0.00000 0.00000';
local vector best_yaw = '0.00000 0.00000 0.00000';
   dist = 8.00000;
   best_yaw = normalize ((self.goalentity.origin - self.origin));
   best_yaw = vectoangles (best_yaw);
   self.ideal_yaw = best_yaw_y;
   retval = ChangeYaw ();
   if ( ((retval > 20.00000) || (retval < -20.00000)) ) {

      dist = (dist / 1.50000);

   }
   dist = (dist + (thrust * 4.00000));
   retval = walkmove (self.angles_y, dist, FALSE);
   org = self.enemy.origin;
   org_z = self.enemy.absmax_z;
   dist = vlen ((self.origin - org));
   if ( (dist > 200.00000) ) {

      imp_drop ();
      return ;
   } else {

      self.enemy.velocity = ((normalize ((self.origin - org)) * dist) * 5.00000);

   }
   self.enemy.angles = self.angles;
};


void  ()imp_pick_up =  {
   if ( !(self.enemy.flags & FL_FLY) ) {

      self.enemy.flags += FL_FLY;

   }
   self.monster_stage = IMP_STAGE_FERRY;
   self.goalentity = find (world, targetname, self.target);
   if ( !self.goalentity ) {

      dprint ("No target!\n");
   } else {

      dprint (self.goalentity.classname);

   }
};


void  (float thrust)imp_ai =  {
local float retval = 0.00000;
   if ( (self.frame == 35.00000) ) {

      sound (self, CHAN_WEAPON, "imp/fly.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.monster_stage == IMP_STAGE_FERRY) ) {

      if ( (vlen ((self.origin - self.goalentity.origin)) < 48.00000) ) {

         imp_drop ();
      } else {

         imp_ferry (thrust);

      }
      return ;

   }
   if ( ((self.enemy == world) || (self.enemy.health <= 0.00000)) ) {

      if ( (self.oldenemy.health > 0.00000) ) {
         0;/* ??? !!! */
      } else {

         LocateTarget ();

      }

   }
   enemy_range = range (self.enemy);
   if ( (enemy_range == RANGE_FAR) ) {

      self.velocity_z = 0.00000;
      thrust = (thrust - 4.00000);
      retval = movestep (0.00000, 0.00000, thrust, FALSE);
      if ( (retval == 0.00000) ) {

         self.think = self.th_stand;
         setsize (self, '-16.00000 -16.00000 15.00000', '16.00000 16.00000 55.00000');
         self.enemy = world;
         self.monster_stage = IMP_STAGE_WAIT;
         self.monster_awake = FALSE;

      }
      return ;
   } else {

      if ( (((((enemy_range == RANGE_MELEE) && (random () < 0.20000)) && (self.target != "")) && (self.origin_z > (self.enemy.absmax_z - 8.00000))) && (self.spawnflags & PICKUP)) ) {

         imp_pick_up ();
         return ;
      } else {

         movestep (0.00000, 0.00000, thrust, FALSE);
         if ( (self.monster_stage == IMP_STAGE_FLY) ) {

            imp_fly (thrust);
         } else {

            if ( (self.monster_stage == IMP_STAGE_HOVER) ) {

               imp_hover (thrust);
            } else {

               if ( (self.monster_stage == IMP_STAGE_STRAIGHT) ) {

                  imp_straight (thrust);

               }

            }

         }

      }

   }
};


void  ()imp_fireagain =  {
local float retval = 0.00000;
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   retval = ChangeYaw ();
   enemy_infront = infront (self.enemy);
   if ( enemy_infront ) {

      if ( ((retval >= -5.00000) && (retval <= 5.00000)) ) {

         retval = CheckMonsterAttack (MA_MISSILE, 2.00000);
         if ( (retval == MA_SUCCESSFUL) ) {

            self.velocity = '0.00000 0.00000 0.00000';

         }

      }

   }
};


void  ()imp_swoopstart =  {
   self.yaw_speed = 15.00000;
   self.count = 140.00000;
   self.velocity = '0.00000 0.00000 0.00000';
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   sound (self, CHAN_WEAPON, "imp/swoop.wav", 1.00000, ATTN_NORM);
};

void  ()ice_imp_swoop14;

void  ()imp_swoopdive =  {
local vector vec = '0.00000 0.00000 0.00000';
   self.count = (self.count * 1.15000);
   if ( (self.frame >= 113.00000) ) {

      vec = ((self.enemy.origin - self.origin) + self.enemy.proj_ofs);
      vec = normalize (vec);
      self.velocity = (vec * self.count);
      if ( (self.frame <= 114.00000) ) {

         self.velocity_y = 0.00000;
         self.velocity_x = 0.00000;

      }

   }
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   if ( ((self.frame == 113.00000) || (self.frame == 114.00000)) ) {

      if ( (self.flags & FL_ONGROUND) ) {

         self.flags = (self.flags - FL_ONGROUND);
         self.think = ice_imp_swoop14;
         self.count = 280.00000;

      }
      if ( ((self.origin_z - self.enemy.origin_z) < 60.00000) ) {

         self.think = ice_imp_swoop14;
         self.count = 280.00000;

      }

   }
};

void  ()ice_imp_swoop_end1;
void  ()ice_imp_swoop_out1;

void  ()imp_swoop =  {
local vector vec = '0.00000 0.00000 0.00000';
   vec = ((self.enemy.origin - self.origin) + self.enemy.proj_ofs);
   vec = normalize (vec);
   self.velocity = (vec * 480.00000);
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   self.count = (self.count + 1.00000);
   if ( ((self.flags & FL_ONGROUND) || (self.count > 20.00000)) ) {

      self.flags = (self.flags - FL_ONGROUND);
      ice_imp_swoop_out1 ();

   }
};


void  ()imp_swoopendinit =  {
   self.velocity_z = 0.00000;
   if ( (self.flags & FL_ONGROUND) ) {

      self.flags = (self.flags - FL_ONGROUND);

   }
};


void  ()imp_swoopend =  {
   if ( (self.flags & FL_ONGROUND) ) {

      self.flags = (self.flags - FL_ONGROUND);

   }
   self.velocity_z = (self.velocity_z + 15.00000);
   self.velocity_x = (self.velocity_x / 1.20000);
   self.velocity_y = (self.velocity_y / 1.20000);
   if ( ((self.frame == 140.00000) || (self.frame == 155.00000)) ) {

      self.velocity = '0.00000 0.00000 0.00000';
      self.yaw_speed = 5.00000;

   }
   checkenemy ();
};


void  ()ice_imp_touch =  {
local float damg = 0.00000;
local vector punch = '0.00000 0.00000 0.00000';
   if ( ((self.frame >= 122.00000) && (self.frame <= 125.00000)) ) {

      if ( (self.flags & FL_ONGROUND) ) {

         self.flags = (self.flags - FL_ONGROUND);

      }
      if ( (other == self.enemy) ) {

         sound (self, CHAN_WEAPON, "imp/swoophit.wav", 1.00000, ATTN_NORM);
         damg = (10.00000 + (self.count / 2.00000));
         T_Damage (self.enemy, self, self.owner, damg);
         punch = (normalize (self.angles) * -1.00000);
         punch = (punch * damg);
         other.punchangle = punch;
         self.enemy.velocity_x = (self.enemy.velocity_x + self.velocity_x);
         self.enemy.velocity_y = (self.enemy.velocity_y + self.velocity_y);
         ice_imp_swoop_end1 ();
      } else {

         ice_imp_swoop_out1 ();

      }

   }
};


void  ()imp_possum_up =  {
   AdvanceFrame( 13.00000, 0.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()imp_playdead =  {
   self.frame = 13.00000;
   self.think = imp_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  ()imp_die =  {
   if ( (self.frame != 13.00000) ) {

      AdvanceFrame (0.00000, 13.00000);

   }
   if ( (self.frame == 0.00000) ) {

      sound (self, CHAN_WEAPON, "imp/die.wav", 1.00000, ATTN_NORM);
      makevectors (self.angles);
      self.movetype = MOVETYPE_BOUNCE;
      self.velocity_z = 0.00000;
      self.velocity = (self.velocity + (v_forward * 80.00000));
      if ( (self.monster_stage == IMP_STAGE_FERRY) ) {

         imp_drop ();

      }

   }
   if ( ((self.frame == 6.00000) || (self.frame == 7.00000)) ) {

      self.nextthink = ((time + 0.05000) + (random () / 6.00000));

   }
   if ( (self.frame == 7.00000) ) {

      if ( (self.flags & FL_ONGROUND) ) {

         sound (self, CHAN_BODY, "player/land.wav", 1.00000, ATTN_NORM);
         self.velocity_y = 0.00000;
         self.velocity_x = 0.00000;
      } else {
         self.frame == 6;
      }

   }
   if ( (self.frame == 13.00000) ) {

      MakeSolidCorpse ("models/h_imp.mdl");
   } else {

      if ( (self.health < -40.00000) ) {

         chunk_death ();
      } else {

         if ( (self.health > 0.00000) ) {

            self.takedamage = DAMAGE_YES;
            self.flags = (self.flags | FL_FLY);
            self.flags2 += FL_ALIVE;
            self.solid = SOLID_SLIDEBOX;
            self.movetype = MOVETYPE_FLY;
            setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 55.00000');
            self.th_stand ();
            return ;
         } else {

            self.think = imp_die;
            self.nextthink = (time + HX_FRAME_TIME);

         }

      }

   }
};


void  ()ice_imp_fir1 =  [ 14.0, ice_imp_fir2] {
   imp_up (-0.20000);
};


void  ()ice_imp_fir2 =  [ 15.0, ice_imp_fir3] {
   imp_up (-0.30000);
};


void  ()ice_imp_fir3 =  [ 16.0, ice_imp_fir4] {
   imp_up (-0.40000);
};


void  ()ice_imp_fir4 =  [ 17.0, ice_imp_fir5] {
   imp_up (-0.50000);
};


void  ()ice_imp_fir5 =  [ 18.0, ice_imp_fir6] {
   imp_up (-0.60000);
};


void  ()ice_imp_fir6 =  [ 19.0, ice_imp_fir7] {
   imp_up (-0.70000);
};


void  ()ice_imp_fir7 =  [ 20.0, ice_imp_fir8] {
   imp_up (-0.80000);
};


void  ()ice_imp_fir8 =  [ 21.0, ice_imp_fir9] {
   imp_up (-0.90000);
};


void  ()ice_imp_fir9 =  [ 22.0, ice_imp_fir10] {
};


void  ()ice_imp_fir10 =  [ 23.0, ice_imp_fir11] {
   imp_up (0.20000);
};


void  ()ice_imp_fir11 =  [ 24.0, ice_imp_fir12] {
   imp_up (0.30000);
};


void  ()ice_imp_fir12 =  [ 25.0, ice_imp_fir13] {
   imp_up (0.40000);
};


void  ()ice_imp_fir13 =  [ 26.0, ice_imp_fir14] {
   imp_up (0.50000);
};


void  ()ice_imp_fir14 =  [ 27.0, ice_imp_fir15] {
   imp_up (0.60000);
};


void  ()ice_imp_fir15 =  [ 28.0, ice_imp_fir16] {
   imp_up (0.70000);
   imp_fire ();
};


void  ()ice_imp_fir16 =  [ 29.0, ice_imp_fir17] {
   imp_up (0.80000);
};


void  ()ice_imp_fir17 =  [ 30.0, ice_imp_fir18] {
   imp_up (0.90000);
};


void  ()ice_imp_fir18 =  [ 31.0, ice_imp_fir19] {
};


void  ()ice_imp_fir19 =  [ 32.0, ice_imp_fir20] {
};


void  ()ice_imp_fir20 =  [ 33.0, ice_imp_fir21] {
};


void  ()ice_imp_fir21 =  [ 34.0, ice_imp_fly16] {
   imp_fireagain ();
};

void  ()ice_imp_fly16;

void  ()ice_imp_swoop1 =  [102.0, ice_imp_swoop2] {
   imp_swoopstart ();
};


void  ()ice_imp_swoop2 =  [103.0, ice_imp_swoop3] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop3 =  [104.0, ice_imp_swoop4] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop4 =  [105.0, ice_imp_swoop5] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop5 =  [106.0, ice_imp_swoop6] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop6 =  [107.0, ice_imp_swoop7] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop7 =  [108.0, ice_imp_swoop8] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop8 =  [109.0, ice_imp_swoop9] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop9 =  [110.0, ice_imp_swoop10] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop10 =  [111.0, ice_imp_swoop11] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop11 =  [112.0, ice_imp_swoop12] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop12 =  [113.0, ice_imp_swoop13] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop13 =  [114.0, ice_imp_swoop12] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop14 =  [115.0, ice_imp_swoop15] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop15 =  [116.0, ice_imp_swoop16] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop16 =  [117.0, ice_imp_swoop17] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop17 =  [118.0, ice_imp_swoop18] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop18 =  [119.0, ice_imp_swoop19] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop19 =  [120.0, ice_imp_swoop20] {
   imp_swoopdive ();
};


void  ()ice_imp_swoop20 =  [121.0, ice_imp_cycle1] {
   imp_swoopdive ();
   self.count = 0.00000;
};


void  ()ice_imp_cycle1 =  [122.0, ice_imp_cycle2] {
   imp_swoop ();
};


void  ()ice_imp_cycle2 =  [123.0, ice_imp_cycle3] {
   imp_swoop ();
};


void  ()ice_imp_cycle3 =  [124.0, ice_imp_cycle4] {
   imp_swoop ();
};


void  ()ice_imp_cycle4 =  [125.0, ice_imp_cycle1] {
   imp_swoop ();
};


void  ()ice_imp_swoop_end1 =  [126.0, ice_imp_swoop_end2] {
   imp_swoopendinit ();
};


void  ()ice_imp_swoop_end2 =  [127.0, ice_imp_swoop_end3] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end3 =  [128.0, ice_imp_swoop_end4] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end4 =  [129.0, ice_imp_swoop_end5] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end5 =  [130.0, ice_imp_swoop_end6] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end6 =  [131.0, ice_imp_swoop_end7] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end7 =  [132.0, ice_imp_swoop_end8] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end8 =  [133.0, ice_imp_swoop_end9] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end9 =  [134.0, ice_imp_swoop_end10] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end10 =  [135.0, ice_imp_swoop_end11] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end11 =  [136.0, ice_imp_swoop_end12] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end12 =  [137.0, ice_imp_swoop_end13] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end13 =  [138.0, ice_imp_swoop_end14] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end14 =  [139.0, ice_imp_swoop_end15] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_end15 =  [140.0, ice_imp_fly2] {
   imp_swoopend ();
};

void  ()ice_imp_fly2;

void  ()ice_imp_swoop_out1 =  [141.0, ice_imp_swoop_out2] {
   imp_swoopendinit ();
};


void  ()ice_imp_swoop_out2 =  [142.0, ice_imp_swoop_out3] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out3 =  [143.0, ice_imp_swoop_out4] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out4 =  [144.0, ice_imp_swoop_out5] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out5 =  [145.0, ice_imp_swoop_out6] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out6 =  [146.0, ice_imp_swoop_out7] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out7 =  [147.0, ice_imp_swoop_out8] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out8 =  [148.0, ice_imp_swoop_out9] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out9 =  [149.0, ice_imp_swoop_out10] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out10 =  [150.0, ice_imp_swoop_out11] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out11 =  [151.0, ice_imp_swoop_out12] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out12 =  [152.0, ice_imp_swoop_out13] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out13 =  [153.0, ice_imp_swoop_out14] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out14 =  [154.0, ice_imp_swoop_out15] {
   imp_swoopend ();
};


void  ()ice_imp_swoop_out15 =  [155.0, ice_imp_fly2] {
   imp_swoopend ();
};


void  ()test1 =  [125.0, test2] {
   makevectors (self.angles);
   setorigin (self, (self.origin + (v_forward * 20.00000)));
   self.angles_x = 50.00000;
   dprint ("CYCLE\n");
   self.nextthink = (time + 2.00000);
};


void  ()test2 =  [125.0, test3] {
   self.nextthink = (time + 2.00000);
};


void  ()test3 =  [126.0, test4] {
   self.angles_x = 0.00000;
   dprint ("SWOOP\n");
   self.nextthink = (time + 2.00000);
   makevectors (self.angles);
   setorigin (self, (self.origin + (v_forward * -20.00000)));
};


void  ()test4 =  [126.0, test1] {
   self.nextthink = (time + 2.00000);
};


void  ()ice_imp_up1 =  [ 55.0, ice_imp_up2] {
   sound (self, CHAN_WEAPON, "imp/up.wav", 1.00000, ATTN_NORM);
   imp_init ();
   imp_up (0.00000);
};


void  ()ice_imp_up2 =  [ 56.0, ice_imp_up3] {
   imp_up (0.00000);
};


void  ()ice_imp_up3 =  [ 57.0, ice_imp_up4] {
   imp_up (0.00000);
};


void  ()ice_imp_up4 =  [ 58.0, ice_imp_up5] {
   imp_up (0.00000);
};


void  ()ice_imp_up5 =  [ 59.0, ice_imp_up6] {
   imp_up (0.00000);
};


void  ()ice_imp_up6 =  [ 60.0, ice_imp_up7] {
   imp_up (0.00000);
};


void  ()ice_imp_up7 =  [ 61.0, ice_imp_up8] {
   imp_up (0.00000);
};


void  ()ice_imp_up8 =  [ 62.0, ice_imp_up9] {
   imp_up (0.00000);
};


void  ()ice_imp_up9 =  [ 63.0, ice_imp_up10] {
   imp_up (1.00000);
};


void  ()ice_imp_up10 =  [ 64.0, ice_imp_up11] {
   imp_up (2.00000);
};


void  ()ice_imp_up11 =  [ 65.0, ice_imp_up12] {
   imp_up (2.00000);
};


void  ()ice_imp_up12 =  [ 66.0, ice_imp_up13] {
   imp_up (2.00000);
};


void  ()ice_imp_up13 =  [ 67.0, ice_imp_up14] {
   imp_up (3.00000);
};


void  ()ice_imp_up14 =  [ 68.0, ice_imp_up15] {
   imp_up (3.00000);
};


void  ()ice_imp_up15 =  [ 69.0, ice_imp_up16] {
   imp_up (3.00000);
};


void  ()ice_imp_up16 =  [ 70.0, ice_imp_up17] {
   imp_up (3.00000);
};


void  ()ice_imp_up17 =  [ 71.0, ice_imp_up18] {
   imp_up (4.00000);
};


void  ()ice_imp_up18 =  [ 72.0, ice_imp_up19] {
   imp_up (4.00000);
};


void  ()ice_imp_up19 =  [ 73.0, ice_imp_up20] {
   imp_up (5.00000);
};


void  ()ice_imp_up20 =  [ 74.0, ice_imp_up21] {
   imp_up (6.00000);
};


void  ()ice_imp_up21 =  [ 75.0, ice_imp_up22] {
   imp_up (7.00000);
};


void  ()ice_imp_up22 =  [ 76.0, ice_imp_up23] {
   imp_up (5.00000);
};


void  ()ice_imp_up23 =  [ 77.0, ice_imp_fly1] {
   imp_up (2.00000);
};


void  ()ice_imp_fly1 =  [ 35.0, ice_imp_fly2] {
   imp_ai (-0.40000);
};


void  ()ice_imp_fly2 =  [ 36.0, ice_imp_fly3] {
   imp_ai (-0.20000);
};


void  ()ice_imp_fly3 =  [ 37.0, ice_imp_fly4] {
   imp_ai (0.00000);
};


void  ()ice_imp_fly4 =  [ 38.0, ice_imp_fly5] {
   imp_ai (0.00000);
};


void  ()ice_imp_fly5 =  [ 39.0, ice_imp_fly6] {
   imp_ai (0.20000);
};


void  ()ice_imp_fly6 =  [ 40.0, ice_imp_fly7] {
   imp_ai (0.40000);
};


void  ()ice_imp_fly7 =  [ 41.0, ice_imp_fly8] {
   imp_ai (0.40000);
};


void  ()ice_imp_fly8 =  [ 42.0, ice_imp_fly9] {
   imp_ai (0.60000);
};


void  ()ice_imp_fly9 =  [ 43.0, ice_imp_fly10] {
   imp_ai (0.60000);
};


void  ()ice_imp_fly10 =  [ 44.0, ice_imp_fly11] {
   imp_ai (0.80000);
};


void  ()ice_imp_fly11 =  [ 45.0, ice_imp_fly12] {
   imp_ai (0.60000);
};


void  ()ice_imp_fly12 =  [ 46.0, ice_imp_fly13] {
   imp_ai (0.40000);
};


void  ()ice_imp_fly13 =  [ 47.0, ice_imp_fly14] {
   imp_ai (0.00000);
};


void  ()ice_imp_fly14 =  [ 48.0, ice_imp_fly15] {
   imp_ai (0.00000);
};


void  ()ice_imp_fly15 =  [ 49.0, ice_imp_fly16] {
   imp_ai (-0.20000);
};


void  ()ice_imp_fly16 =  [ 50.0, ice_imp_fly17] {
   imp_ai (-0.40000);
};


void  ()ice_imp_fly17 =  [ 51.0, ice_imp_fly18] {
   imp_ai (-0.80000);
};


void  ()ice_imp_fly18 =  [ 52.0, ice_imp_fly19] {
   imp_ai (-0.80000);
};


void  ()ice_imp_fly19 =  [ 53.0, ice_imp_fly20] {
   imp_ai (-0.80000);
};


void  ()ice_imp_fly20 =  [ 54.0, ice_imp_fly1] {
   imp_ai (-0.40000);
};


void  ()ice_imp_wait =  [ 78.0, ice_imp_wait] {
   imp_stand ();
};


void  ()ice_imp_wat1 =  [ 78.0, ice_imp_wat3] {
};

void  ()ice_imp_wat3;

void  ()ice_imp_wat2 =  [ 79.0, ice_imp_wat3] {
};


void  ()ice_imp_wat3 =  [ 80.0, ice_imp_wat4] {
};


void  ()ice_imp_wat4 =  [ 81.0, ice_imp_wat5] {
   imp_stand ();
};


void  ()ice_imp_wat5 =  [ 82.0, ice_imp_wat6] {
};


void  ()ice_imp_wat6 =  [ 83.0, ice_imp_wat7] {
};


void  ()ice_imp_wat7 =  [ 84.0, ice_imp_wat8] {
};


void  ()ice_imp_wat8 =  [ 85.0, ice_imp_wat9] {
   imp_stand ();
};


void  ()ice_imp_wat9 =  [ 86.0, ice_imp_wat10] {
};


void  ()ice_imp_wat10 =  [ 87.0, ice_imp_wat11] {
};


void  ()ice_imp_wat11 =  [ 88.0, ice_imp_wat12] {
};


void  ()ice_imp_wat12 =  [ 89.0, ice_imp_wat13] {
   imp_stand ();
};


void  ()ice_imp_wat13 =  [ 90.0, ice_imp_wat14] {
};


void  ()ice_imp_wat14 =  [ 91.0, ice_imp_wat15] {
};


void  ()ice_imp_wat15 =  [ 92.0, ice_imp_wat16] {
};


void  ()ice_imp_wat16 =  [ 93.0, ice_imp_wat17] {
   imp_stand ();
};


void  ()ice_imp_wat17 =  [ 94.0, ice_imp_wat18] {
};


void  ()ice_imp_wat18 =  [ 95.0, ice_imp_wat19] {
};


void  ()ice_imp_wat19 =  [ 96.0, ice_imp_wat20] {
};


void  ()ice_imp_wat20 =  [ 97.0, ice_imp_wat21] {
   imp_stand ();
};


void  ()ice_imp_wat21 =  [ 98.0, ice_imp_wat22] {
};


void  ()ice_imp_wat22 =  [ 99.0, ice_imp_wat23] {
};


void  ()ice_imp_wat23 =  [100.0, ice_imp_wat24] {
};


void  ()ice_imp_wat24 =  [101.0, ice_imp_wat1] {
   imp_stand ();
};


void  ()imp_FlyWait =  {
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (35.00000, 54.00000) == AF_END) ) {

      imp_stand ();

   }
};


void  ()imp_flyattack =  [ 35.0, imp_flyattack] {
   imp_init ();
   ice_imp_fly1 ();
};


void  ()ice_imp_die =  {
   setsize (self, '-16.00000 -16.00000 -15.00000', '16.00000 16.00000 40.00000');
   imp_die ();
};


void  (entity attacker,float damage)ice_imp_pain =  {
   if ( ((self.targetname != "") && (self.skin == 2.00000)) ) {

      self.think = SUB_Null;
      self.nextthink = -1.00000;
      return ;

   }
   if ( (self.spawnflags & SF_IMP_DORMANT) ) {

      self.frame = 55.00000;
      self.think = stone_imp_awaken;

   }
   if ( ((self.monster_stage == IMP_STAGE_FERRY) && (random () < 0.20000)) ) {

      imp_drop ();

   }
};


void  ()impmonster_start_go =  {
   self.ideal_yaw = (self.angles * '0.00000 1.00000 0.00000');
   if ( !self.yaw_speed ) {

      self.yaw_speed = 5.00000;

   }
   self.view_ofs = '0.00000 0.00000 25.00000';
   if ( !self.use ) {

      self.use = monster_use;

   }
   self.pausetime = 100000000.00000;
   if ( self.targetname ) {

      self.frame = 78.00000;
      self.think = imp_use;
      self.nextthink = -1.00000;
   } else {

      self.th_stand ();

   }
};


void  ()impmonster_start =  {
   self.nextthink = (self.nextthink + (random () * 0.50000));
   self.think = impmonster_start_go;
   total_monsters = (total_monsters + 1.00000);
};


void  (float which_skin)init_imp =  {
   if ( (deathmatch && (self.wait != -1.00000)) ) {

      remove (self);
      return ;

   }
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model2 ("models/imp.mdl");
      precache_model2 ("models/h_imp.mdl");
      if ( ((self.classname == "monster_ice_imp") || (self.classname == "monster_imp_ice")) ) {

         precache_model2 ("models/shardice.mdl");
      } else {

         precache_model2 ("models/fireball.mdl");

      }
      precache_sound2 ("imp/up.wav");
      precache_sound2 ("imp/die.wav");
      precache_sound2 ("imp/swoophit.wav");
      precache_sound2 ("imp/swoop.wav");
      precache_sound2 ("imp/fly.wav");
      precache_sound2 ("imp/fireball.wav");
      precache_sound2 ("imp/shard.wav");

   }
   self.solid = SOLID_SLIDEBOX;
   setmodel (self, "models/imp.mdl");
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 55.00000');
   if ( (self.wait != -1.00000) ) {

      self.monster_stage = IMP_STAGE_WAIT;
      self.movetype = MOVETYPE_FLY;
      self.takedamage = DAMAGE_YES;
      self.skin = which_skin;
      self.impType = which_skin;
      if ( which_skin ) {

         self.flags += FL_COLDHEAL;
      } else {

         self.flags += FL_FIREHEAL;

      }
      self.flags2 += FL_ALIVE;
      self.thingtype = THINGTYPE_FLESH;
      self.health = 100.00000;
      self.max_health = 100.00000;
      self.experience_value = 500.00000;
      self.mass = 3.00000;
      self.mintel = 5.00000;
      if ( (self.spawnflags & MONSTER_HOVER) ) {

         self.th_stand = imp_FlyWait;
         self.th_walk = imp_flyattack;
      } else {

         self.th_stand = ice_imp_wat1;
         self.th_walk = ice_imp_up1;

      }
      self.th_run = self.th_walk;
      self.th_pain = ice_imp_pain;
      self.th_die = ice_imp_die;
      self.th_missile = ice_imp_fir1;
      self.th_melee = ice_imp_swoop1;
      self.th_possum = imp_playdead;
      self.th_possum_up = imp_possum_up;
      self.touch = ice_imp_touch;

   }
   if ( (self.spawnflags & SF_IMP_DORMANT) ) {

      self.classname = "gargoyle";
      self.scale = 1.50000;
      self.flags2 += FL_STONED;
      setsize (self, '-16.00000 -16.00000 -14.00000', '16.00000 16.00000 55.00000');
      setorigin (self, (self.origin + '0.00000 0.00000 14.00000'));
      self.takedamage = DAMAGE_NO_GRENADE;
      self.thingtype = THINGTYPE_GREYSTONE;
      self.movetype = MOVETYPE_PUSHPULL;
      self.touch = obj_push;
      self.health += 100.00000;
      self.mass = 100.00000;
      self.th_die = chunk_death;
      if ( (self.wait != -1.00000) ) {

         self.use = imp_use;
         self.oldskin = self.skin;
         self.th_stand = ice_imp_wait;

      }
      self.skin = 2.00000;
   } else {

      self.flags = (self.flags | FL_MONSTER);
      self.flags = (self.flags | FL_FLY);

   }
   precache_model2 ("models/ring.mdl");
   if ( (self.wait != -1.00000) ) {

      impmonster_start ();
   } else {

      self.frame = 78.00000;

   }
};


void  ()monster_imp_ice =  {
   init_imp (1.00000);
};


void  ()monster_ice_imp =  {
   init_imp (1.00000);
};


void  ()monster_imp_fire =  {
   init_imp (0.00000);
};


void  ()monster_fire_imp =  {
   init_imp (0.00000);
};

