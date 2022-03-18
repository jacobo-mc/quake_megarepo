float  ()ArcherCheckAttack;
float  ()MedusaCheckAttack;
void  ()SetNextWaypoint;
void  ()SpiderMeleeBegin;
float  (entity targ,entity from)infront_of_ent;
float current_yaw   =  0.00000;
entity sight_entity;
float sight_entity_time   =  0.00000;

float  (float v)anglemod =  {
   while ( (v >= 360.00000) ) {

      v = (v - 360.00000);

   }
   while ( (v < 0.00000) ) {

      v = (v + 360.00000);

   }
   return ( v );
};


float  (entity targ)range =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local float r = 0.00000;
local float melee = 0.00000;
   if ( (((self.solid == SOLID_BSP) || (self.solid == SOLID_TRIGGER)) && (self.origin == '0.00000 0.00000 0.00000')) ) {

      spot1 = ((self.absmax + self.absmin) * 0.50000);
   } else {

      spot1 = (self.origin + self.view_ofs);

   }
   if ( (((targ.solid == SOLID_BSP) || (targ.solid == SOLID_TRIGGER)) && (targ.origin == '0.00000 0.00000 0.00000')) ) {

      spot2 = ((targ.absmax + targ.absmin) * 0.50000);
   } else {

      spot2 = (targ.origin + targ.view_ofs);

   }
   r = vlen ((spot1 - spot2));
   if ( (self.classname == "monster_mummy") ) {

      melee = 50.00000;
   } else {

      melee = 100.00000;

   }
   if ( (r < melee) ) {

      return ( RANGE_MELEE );

   }
   if ( (r < 500.00000) ) {

      return ( RANGE_NEAR );

   }
   if ( (r < 1000.00000) ) {

      return ( RANGE_MID );

   }
   return ( RANGE_FAR );
};


float  (entity targ)visible =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
   if ( (((self.solid == SOLID_BSP) || (self.solid == SOLID_TRIGGER)) && (self.origin == '0.00000 0.00000 0.00000')) ) {

      spot1 = ((self.absmax + self.absmin) * 0.50000);
   } else {

      spot1 = (self.origin + self.view_ofs);

   }
   if ( (((targ.solid == SOLID_BSP) || (targ.solid == SOLID_TRIGGER)) && (targ.origin == '0.00000 0.00000 0.00000')) ) {

      spot2 = ((targ.absmax + targ.absmin) * 0.50000);
   } else {

      spot2 = (targ.origin + targ.view_ofs);

   }
   traceline (spot1, spot2, TRUE, self);
   if ( (trace_inopen && trace_inwater) ) {

      return ( FALSE );

   }
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity targ)infront =  {
local vector vec = '0.00000 0.00000 0.00000';
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local float dot = 0.00000;
local float accept = 0.00000;
   if ( (self.classname == "player") ) {

      makevectors (self.v_angle);
   } else {

      if ( (self.classname == "monster_medusa") ) {

         makevectors ((self.angles + self.angle_ofs));
      } else {

         makevectors (self.angles);

      }

   }
   if ( (((self.solid == SOLID_BSP) || (self.solid == SOLID_TRIGGER)) && (self.origin == '0.00000 0.00000 0.00000')) ) {

      spot1 = ((self.absmax + self.absmin) * 0.50000);
   } else {

      spot1 = (self.origin + self.view_ofs);

   }
   if ( (((targ.solid == SOLID_BSP) || (targ.solid == SOLID_TRIGGER)) && (targ.origin == '0.00000 0.00000 0.00000')) ) {

      spot2 = ((targ.absmax + targ.absmin) * 0.50000);
   } else {

      spot2 = targ.origin;

   }
   accept = 0.30000;
   vec = normalize ((spot2 - spot1));
   dot = (vec * v_forward);
   if ( (dot > accept) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


void  ()HuntTarget =  {
   self.goalentity = self.enemy;
   if ( (self.spawnflags & PLAY_DEAD) ) {

      self.think = self.th_possum_up;
      self.spawnflags = (self.spawnflags - PLAY_DEAD);
   } else {

      self.think = self.th_run;

   }
   self.ideal_yaw = vectoyaw ((self.goalentity.origin - self.origin));
   self.nextthink = (time + 0.10000);
};


void  ()SightSound =  {
local float rsnd = 0.00000;
   if ( (self.classname == "monster_archer") ) {

      sound (self, CHAN_WEAPON, "archer/sight.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.classname == "monster_mummy") ) {

         sound (self, CHAN_WEAPON, "mummy/sight.wav", 1.00000, ATTN_NORM);

      }

   }
};


void  ()FoundTarget =  {
   if ( (self.enemy.classname == "player") ) {

      sight_entity = self;
      sight_entity_time = time;

   }
   self.show_hostile = (time + 1.00000);
   SightSound ();
   HuntTarget ();
};


void  ()FindTarget =  {
local entity client;
local float r = 0.00000;
   if ( ((sight_entity_time >= (time - 0.10000)) && !(self.spawnflags & 3.00000)) ) {

      client = sight_entity;
      if ( (client.enemy == self.enemy) ) {

         return ;

      }
   } else {

      client = checkclient ();
      if ( !client ) {

         return ( FALSE );

      }

   }
   if ( (client == self.enemy) ) {

      return ( FALSE );

   }
   if ( (client.flags & FL_NOTARGET) ) {

      return ( FALSE );

   }
   if ( (client.items & IT_INVISIBILITY) ) {

      return ( FALSE );

   }
   r = range (client);
   if ( (r == RANGE_FAR) ) {

      return ( FALSE );

   }
   if ( !visible (client) ) {

      return ( FALSE );

   }
   if ( (r == RANGE_NEAR) ) {

      if ( ((client.show_hostile < time) && !infront (client)) ) {

         return ( FALSE );

      }
   } else {

      if ( (r == RANGE_MID) ) {

         if ( !infront (client) ) {

            return ( FALSE );

         }

      }

   }
   self.enemy = client;
   if ( (self.enemy.classname != "player") ) {

      self.enemy = self.enemy.enemy;
      if ( (self.enemy.classname != "player") ) {

         self.enemy = world;
         return ( FALSE );

      }

   }
   if ( (self.spawnflags & PLAY_DEAD) ) {

      if ( (r == RANGE_MELEE) ) {

         FoundTarget ();
         return ( TRUE );
      } else {

         if ( ((!infront_of_ent (self, self.enemy) && (random () < 0.10000)) && (random () < 0.10000)) ) {

            FoundTarget ();
            return ( TRUE );
         } else {

            self.enemy = world;
            return ( FALSE );

         }

      }

   }
   FoundTarget ();
   return ( TRUE );
};

void  ()SpiderJumpBegin;

void  ()CheckJump =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector jumpdir = '0.00000 0.00000 0.00000';
local float jump_height = 0.00000;
local float jumpup = 0.00000;
   makevectors (self.angles);
   jumpdir = normalize ((self.goalentity.origin - self.origin));
   jumpdir_z = 0.00000;
   jump_height = (jumpdir * v_forward);
   if ( (jump_height < 0.30000) ) {

      return ;

   }
   spot1 = self.origin;
   spot2 = self.enemy.origin;
   spot1_z = 0.00000;
   spot2_z = 0.00000;
   jump_height = 16.00000;
   if ( (self.jump_flag > time) ) {

      return ;
   } else {

      if ( (pointcontents (self.goalentity.origin) != CONTENT_EMPTY) ) {

         return ;
      } else {

         if ( !visible (self.goalentity) ) {

            return ;
         } else {

            if ( ((((self.goalentity.absmin_z + 36.00000) >= self.absmin_z) && (self.think != SpiderJumpBegin)) && (self.classname != "monster_mezzoman")) ) {

               return ;
            } else {

               if ( !(self.flags & FL_ONGROUND) ) {

                  return ;
               } else {

                  if ( (!(self.goalentity.flags & FL_ONGROUND) && (self.goalentity.classname != "waypoint")) ) {

                     return ;
                  } else {

                     if ( !infront (self.goalentity) ) {

                        return ;
                     } else {

                        if ( (vlen ((spot1 - spot2)) > 777.00000) ) {

                           return ;
                        } else {

                           if ( ((vlen ((spot1 - spot2)) <= RANGE_MELEE) && (self.think != SpiderMeleeBegin)) ) {

                              return ;

                           }

                        }

                     }

                  }

               }

            }

         }

      }

   }
   if ( (self.think == SpiderJumpBegin) ) {

      jump_height = (vlen ((((self.goalentity.absmax + self.goalentity.absmin) * 0.50000) - self.origin)) / 13.00000);
   } else {

      if ( (self.classname == "monster_mezzoman") ) {

         if ( (self.goalentity.absmin_z >= (self.absmin_z + 36.00000)) ) {

            jump_height = (vlen ((((self.goalentity.absmax + self.goalentity.absmin) * 0.50000) - self.origin)) / 13.00000);
            jumpup = TRUE;
         } else {

            if ( (self.goalentity.absmin_z > (self.absmin_z - 36.00000)) ) {

               return ;

            }

         }

      }

   }
   spot1 = self.origin;
   spot1_z = self.absmax_z;
   spot2 = spot1;
   spot2_z += 36.00000;
   traceline (spot1, spot2, FALSE, self);
   if ( (trace_fraction < 1.00000) ) {

      return ;

   }
   if ( !jumpup ) {

      spot1 += (jumpdir * ((self.maxs_x + self.maxs_y) * 0.50000));
      traceline (self.origin, (spot1 + '0.00000 0.00000 36.00000'), FALSE, self);
      if ( (trace_fraction < 1.00000) ) {

         return ;

      }
      traceline (spot1, ((spot1 + (jumpdir * 64.00000)) - '0.00000 0.00000 500.00000'), FALSE, self);
      if ( (((pointcontents (trace_endpos) == CONTENT_WATER) || (pointcontents (trace_endpos) == CONTENT_SLIME)) || (pointcontents (trace_endpos) == CONTENT_LAVA)) ) {

         return ;

      }

   }
   self.ideal_yaw = jumpdir_y;
   ChangeYaw ();
   if ( (self.think != SpiderJumpBegin) ) {

      self.jump_flag = (time + 7.00000);
      SightSound ();
      if ( !jumpup ) {

         self.velocity = (((jumpdir * jump_height) * 17.00000) * self.scale);
         self.velocity_z = ((jump_height * 12.00000) * self.scale);
      } else {

         self.velocity = (((jumpdir * jump_height) * 10.00000) * self.scale);
         self.velocity_z = ((jump_height * 14.00000) * self.scale);

      }
      if ( (self.flags & FL_ONGROUND) ) {

         self.flags -= FL_ONGROUND;

      }
      if ( self.th_jump ) {

         self.th_jump ();
      } else {

         self.nextthink = (time + 0.30000);

      }
   } else {

      self.level = jump_height;
      return ( TRUE );

   }
};


void  ()MonsterCheckContents =  {
   if ( (pointcontents (self.origin) == CONTENT_LAVA) ) {

      T_Damage (self, world, world, 20.00000);

   }
};


void  (float dist)ai_forward =  {
   walkmove (self.angles_y, dist, FALSE);
};


void  (float dist)ai_back =  {
   walkmove ((self.angles_y + 180.00000), dist, FALSE);
};


void  (float dist)ai_pain =  {
   ai_back (dist);
};


void  (float dist)ai_painforward =  {
   walkmove (self.ideal_yaw, dist, FALSE);
};


void  (float dist)ai_walk =  {
local vector mtemp = '0.00000 0.00000 0.00000';
   MonsterCheckContents ();
   movedist = dist;
   if ( FindTarget () ) {

      return ;

   }
   movetogoal (dist);
};


void  ()ai_stand =  {
   MonsterCheckContents ();
   if ( FindTarget () ) {

      return ;

   }
   if ( (self.spawnflags & PLAY_DEAD) ) {

      return ;

   }
   if ( (time > self.pausetime) ) {

      self.th_walk ();
      return ;

   }
};


void  ()ai_turn =  {
   if ( FindTarget () ) {

      return ;

   }
   ChangeYaw ();
};


void  (vector dest3)ChooseTurn =  {
local vector dir = '0.00000 0.00000 0.00000';
local vector newdir = '0.00000 0.00000 0.00000';
   dir = (self.origin - dest3);
   newdir_x = trace_plane_normal_y;
   newdir_y = (0.00000 - trace_plane_normal_x);
   newdir_z = 0.00000;
   if ( ((dir * newdir) > 0.00000) ) {

      dir_x = (0.00000 - trace_plane_normal_y);
      dir_y = trace_plane_normal_x;
   } else {

      dir_x = trace_plane_normal_y;
      dir_y = (0.00000 - trace_plane_normal_x);

   }
   dir_z = 0.00000;
   self.ideal_yaw = vectoyaw (dir);
};


float  ()FacingIdeal =  {
local float delta = 0.00000;
   delta = anglemod ((self.angles_y - self.ideal_yaw));
   if ( ((delta > 45.00000) && (delta < 315.00000)) ) {

      return ( FALSE );

   }
   return ( TRUE );
};


void  ()CheckAnyAttack =  {
   if ( !enemy_vis ) {

      if ( self.mintel ) {

         SetNextWaypoint ();

      }
      return ;
   } else {

      if ( self.mintel ) {

         self.goalentity = self.enemy;
         self.wallspot = ((self.enemy.absmin + self.enemy.absmax) * 0.50000);

      }

   }
   if ( (self.classname == "monster_archer") ) {

      return ( ArcherCheckAttack () );

   }
   if ( (self.classname == "monster_medusa") ) {

      return ( MedusaCheckAttack () );

   }
   return ( CheckAttack () );
};


void  ()ai_attack_face =  {
   self.ideal_yaw = enemy_yaw;
   ChangeYaw ();
   if ( FacingIdeal () ) {

      if ( (self.attack_state == AS_MISSILE) ) {

         self.th_missile ();
      } else {

         if ( (self.attack_state == AS_MELEE) ) {

            self.th_melee ();

         }

      }
      self.attack_state = AS_STRAIGHT;

   }
};


void  ()ai_run_slide =  {
local float ofs = 0.00000;
   self.ideal_yaw = enemy_yaw;
   ChangeYaw ();
   if ( self.lefty ) {

      ofs = 90.00000;
   } else {

      ofs = -90.00000;

   }
   if ( walkmove ((self.ideal_yaw + ofs), movedist, FALSE) ) {

      return ;

   }
   self.lefty = (1.00000 - self.lefty);
   walkmove ((self.ideal_yaw - ofs), movedist, FALSE);
};


void  (float dist)ai_run =  {
local vector delta = '0.00000 0.00000 0.00000';
local float axis = 0.00000;
local float direct = 0.00000;
local float ang_rint = 0.00000;
local float ang_floor = 0.00000;
local float ang_ceil = 0.00000;
   MonsterCheckContents ();
   movedist = dist;
   if ( ((self.enemy.health <= 0.00000) || (self.enemy.flags2 & FL_STONED)) ) {

      self.enemy = world;
      if ( (self.oldenemy.health > 0.00000) ) {

         self.enemy = self.oldenemy;
         HuntTarget ();
      } else {

         if ( self.pathentity ) {

            self.th_walk ();
         } else {

            self.th_stand ();

         }
         return ;

      }

   }
   self.show_hostile = (time + 1.00000);
   enemy_vis = visible (self.enemy);
   if ( enemy_vis ) {

      self.search_time = (time + 5.00000);
      if ( self.mintel ) {

         self.goalentity = self.enemy;
         self.wallspot = ((self.enemy.absmin + self.enemy.absmax) * 0.50000);

      }
   } else {

      if ( self.mintel ) {

         SetNextWaypoint ();

      }

   }
   if ( ((((random () < 0.50000) && !(self.flags & FL_SWIM)) && !(self.flags & FL_FLY)) && !(self.spawnflags & NO_JUMP)) ) {

      CheckJump ();

   }
   if ( (coop && (self.search_time < time)) ) {

      if ( FindTarget () ) {

         return ;

      }

   }
   enemy_infront = infront (self.enemy);
   enemy_range = range (self.enemy);
   enemy_yaw = vectoyaw ((self.enemy.origin - self.origin));
   if ( ((self.attack_state == AS_MISSILE) || (self.attack_state == AS_MELEE)) ) {

      ai_attack_face ();
      return ;

   }
   if ( CheckAnyAttack () ) {

      return ;

   }
   if ( (self.attack_state == AS_SLIDING) ) {

      ai_run_slide ();
      return ;

   }
   movetogoal (dist);
};

