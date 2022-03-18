
void  ()AI_Decision_Dead =  {
   if ( (self.health > -80.00000) ) {

      if ( ((self.ai_state != AI_DEAD) && (self.ai_state != AI_DEAD_TWITCH)) ) {

         self.ai_new_state = AI_DEAD;
      } else {

         if ( (self.ai_poss_states & AI_DEAD_TWITCH) ) {

            self.ai_new_state = AI_DEAD_TWITCH;
            self.ai_state = AI_DECIDE;
         } else {

            self.ai_new_state = AI_DEAD;

         }

      }
      self.ai_duration = (time + 15.00000);
   } else {

      self.ai_new_state = AI_DEAD_GIB;

   }
};


float  ()AI_face_enemy =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   if ( FacingIdeal () ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity targ)AI_infront =  {
local vector vec = '0.00000 0.00000 0.00000';
local float dot = 0.00000;
   makevectors (self.angles);
   vec = normalize ((targ.origin - self.origin));
   dot = (vec * v_forward);
   if ( (dot > 0.30000) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity targ)AI_visionblocked =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
   spot1 = (self.origin + self.view_ofs);
   spot2 = (targ.origin + targ.view_ofs);
   traceline (spot1, spot2, TRUE, self);
   if ( (trace_inopen && trace_inwater) ) {

      return ( FALSE );

   }
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity targ)AI_calc_range =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local float rnge = 0.00000;
   spot1 = (self.origin + self.view_ofs);
   spot2 = (targ.origin + targ.view_ofs);
   rnge = vlen ((spot1 - spot2));
   if ( (rnge < 50.00000) ) {

      return ( RANGE_MELEE );

   }
   if ( (rnge < 400.00000) ) {

      return ( RANGE_NEAR );

   }
   if ( (rnge < 1000.00000) ) {

      return ( RANGE_MID );

   }
   return ( RANGE_FAR );
};


float  ()AI_TargetSearch =  {
local entity client;
local float r = 0.00000;
   client = checkclient ();
   if ( !client ) {

      return ( FALSE );

   }
   if ( (client.classname != "player") ) {

      return ( FALSE );

   }
   if ( (client.flags & FL_NOTARGET) ) {

      return ( FALSE );

   }
   if ( (client.items & IT_INVISIBILITY) ) {

      return ( FALSE );

   }
   return ( client );
};


entity  ()AI_Target =  {
local entity targ;
   if ( self.just_hurt ) {

      targ = self.enemy;
   } else {

      if ( (self.enemy == world) ) {

         targ = AI_TargetSearch ();
      } else {

         targ = self.enemy;

      }

   }
   return ( targ );
};


void  ()AI_MeleeAttack =  {
   AI_face_enemy ();
};


void  ()AI_MissileAttack =  {
   AI_face_enemy ();
};


void  ()AI_Stand =  {
};


void  ()AI_Pain =  {
   AI_face_enemy ();
};


void  ()AI_Walk =  {
   movetogoal (self.move_distance);
};


void  ()AI_Wander =  {
   movetogoal (self.move_distance);
};


void  ()AI_Charge =  {
local float rnge = 0.00000;
   rnge = AI_calc_range (self.enemy);
   if ( (rnge == RANGE_MELEE) ) {

      self.ai_new_state = AI_DECIDE;
   } else {

      movetogoal (self.move_distance);

   }
};


void  ()AI_Dead_Gib =  {
   chunk_death ();
   remove (self);
};


void  ()AI_Dead =  {
   if ( (self.ai_duration <= time) ) {

      remove (self);

   }
};


void  ()AI_TurnLook =  {
   self.angles_y += 4.00000;
};


void  (entity targ)AI_Change_State =  {
   self.ai_state_func ();
   if ( (self.ai_new_state == AI_STAND) ) {

      self.ai_move_func = AI_Stand;
      self.goalentity = self.pathentity;
      self.enemy = world;
   } else {

      if ( (self.ai_new_state == AI_WALK) ) {

         self.ai_move_func = AI_Walk;
         self.goalentity = self.pathentity;
         self.enemy = world;
      } else {

         if ( (self.ai_new_state == AI_CHARGE) ) {

            self.ai_move_func = AI_Charge;
            self.goalentity = targ;
            self.enemy = targ;
         } else {

            if ( (self.ai_new_state == AI_MISSILE_ATTACK) ) {

               self.ai_move_func = AI_MissileAttack;
               self.goalentity = targ;
               self.enemy = targ;
               self.ai_duration = (time + 9999.00000);
            } else {

               if ( (self.ai_new_state == AI_MISSILE_REATTACK) ) {

                  self.ai_move_func = AI_MissileAttack;
                  self.goalentity = targ;
                  self.enemy = targ;
                  self.ai_duration = (time + 9999.00000);
               } else {

                  if ( (self.ai_new_state == AI_MELEE_ATTACK) ) {

                     self.ai_move_func = AI_MeleeAttack;
                     self.goalentity = targ;
                     self.enemy = targ;
                     self.ai_duration = (time + 9999.00000);
                  } else {

                     if ( (((self.ai_new_state == AI_PAIN) || (self.ai_new_state == AI_PAIN_CLOSE)) || (self.ai_new_state == AI_PAIN_FAR)) ) {

                        self.ai_move_func = AI_Pain;
                        self.goalentity = self.enemy;
                        self.ai_duration = (time + 9999.00000);
                     } else {

                        if ( (self.ai_new_state == AI_DEAD) ) {

                           self.ai_move_func = AI_Dead;
                           self.ai_duration = (time + 15.00000);
                        } else {

                           if ( (self.ai_new_state == AI_DEAD_TWITCH) ) {

                              self.ai_move_func = AI_Dead;
                              self.goalentity = world;
                              self.enemy = world;
                           } else {

                              if ( (self.ai_new_state == AI_DEAD_GIB) ) {

                                 self.ai_move_func = AI_Dead_Gib;
                                 self.goalentity = world;
                                 self.enemy = world;
                              } else {

                                 if ( (self.ai_new_state == AI_TURNLOOK) ) {

                                    self.ai_move_func = AI_TurnLook;
                                    self.goalentity = world;
                                    self.enemy = world;
                                 } else {

                                    if ( (self.ai_new_state == AI_WANDER) ) {

                                       self.ai_move_func = AI_Wander;
                                       self.goalentity = world;
                                       self.enemy = world;
                                    } else {

                                       self.ai_move_func = AI_Walk;
                                       self.goalentity = self.pathentity;

                                    }

                                 }

                              }

                           }

                        }

                     }

                  }

               }

            }

         }

      }

   }
   self.ai_state = self.ai_new_state;
};


entity  (float in_sight,float in_front,entity targ)AI_Decision_Melee =  {
local float chance = 0.00000;
local entity newtarg;
   if ( self.just_hurt ) {

      if ( (self.ai_poss_states & AI_PAIN_CLOSE) ) {

         self.ai_new_state = AI_PAIN_CLOSE;
      } else {

         self.ai_new_state = AI_PAIN;

      }
      self.just_hurt = FALSE;
      newtarg = targ;
   } else {

      chance = random ();
      if ( (chance < 0.90000) ) {

         if ( (self.health > 10.00000) ) {

            self.ai_new_state = AI_MELEE_ATTACK;
         } else {

            self.ai_new_state = AI_MISSILE_ATTACK;

         }
         self.ai_state = AI_DECIDE;
      } else {

         self.ai_new_state = AI_WANDER;
         self.angles_y += (random () * 40.00000);
         self.ai_duration = ((time + (random () * 2.00000)) + 2.00000);

      }
      newtarg = targ;

   }
   return ( newtarg );
};


entity  (float in_sight,float in_front,entity targ)AI_Decision_Near =  {
local float chance = 0.00000;
local entity newtarg;
   if ( self.just_hurt ) {

      if ( (self.ai_poss_states & AI_PAIN_CLOSE) ) {

         self.ai_new_state = AI_PAIN_CLOSE;
      } else {

         self.ai_new_state = AI_PAIN;

      }
      self.just_hurt = FALSE;
      newtarg = targ;
   } else {

      chance = random ();
      if ( (chance <= 1.00000) ) {

         self.ai_new_state = AI_CHARGE;
         self.ai_state = AI_DECIDE;
      } else {

         self.ai_new_state = AI_WANDER;
         self.angles_y += (random () * 40.00000);
         self.ai_duration = ((time + (random () * 2.00000)) + 2.00000);

      }
      newtarg = targ;

   }
   return ( newtarg );
};


entity  (float in_sight,float in_front,entity targ)AI_Decision_Mid =  {
local float chance = 0.00000;
local entity newtarg;
   if ( self.just_hurt ) {

      if ( (self.ai_poss_states & AI_PAIN_CLOSE) ) {

         self.ai_new_state = AI_PAIN_CLOSE;
      } else {

         self.ai_new_state = AI_PAIN;

      }
      self.just_hurt = FALSE;
      newtarg = targ;
   } else {

      if ( (in_sight && in_front) ) {

         if ( (self.ai_poss_states & AI_MISSILE_ATTACK) ) {

            chance = random ();
            if ( (chance <= 0.70000) ) {

               if ( ((self.ai_state != AI_MISSILE_ATTACK) && (self.ai_state != AI_MISSILE_REATTACK)) ) {

                  self.ai_new_state = AI_MISSILE_ATTACK;
               } else {

                  self.ai_new_state = AI_MISSILE_REATTACK;
                  self.ai_state = AI_DECIDE;

               }
            } else {

               self.ai_new_state = AI_CHARGE;
               self.ai_duration = ((time + (random () * 2.00000)) + 1.00000);

            }
         } else {

            self.ai_new_state = AI_CHARGE;
            self.ai_duration = ((time + (random () * 2.00000)) + 1.00000);

         }
         newtarg = targ;
      } else {

         if ( in_sight ) {

            chance = random ();
            if ( ((chance <= 0.80000) || (self.ai_state != AI_WALK)) ) {

               self.ai_new_state = AI_WALK;
               self.ai_duration = (time + (random () * 4.00000));
            } else {

               self.ai_new_state = AI_TURNLOOK;
               self.ai_duration = ((time + random ()) + 1.00000);

            }
            newtarg = world;
         } else {

            if ( (self.ai_state == AI_DECIDE) ) {

               self.ai_new_state = AI_STAND;
            } else {

               self.ai_new_state = self.ai_state;

            }
            newtarg = world;

         }

      }

   }
   return ( newtarg );
};


entity  (float in_sight,float in_front,entity targ)AI_Decision_Far =  {
local float chance = 0.00000;
local entity newtarg;
   if ( self.just_hurt ) {

      if ( (self.ai_poss_states & AI_PAIN_FAR) ) {

         self.ai_new_state = AI_PAIN_FAR;
      } else {

         self.ai_new_state = AI_PAIN;

      }
      self.just_hurt = FALSE;
      newtarg = targ;
   } else {

      if ( ((self.ai_state == AI_PAIN_FAR) || (self.ai_state == AI_PAIN)) ) {

         chance = random ();
         if ( (chance <= 0.10000) ) {

            self.ai_new_state = AI_WANDER;
            self.ai_duration = ((time + (random () * 2.00000)) + 2.00000);
         } else {

            if ( (chance <= 55.00000) ) {

               if ( (self.ai_state & AI_MISSILE_ATTACK) ) {

                  self.ai_new_state = AI_MISSILE_ATTACK;
                  newtarg = targ;
               } else {

                  self.ai_new_state = AI_CHARGE;
                  self.ai_duration = ((time + (random () * 4.00000)) + 4.00000);
                  newtarg = targ;

               }
            } else {

               self.ai_new_state = AI_CHARGE;
               self.ai_duration = ((time + (random () * 4.00000)) + 4.00000);
               newtarg = targ;

            }

         }
      } else {

         if ( self.pathentity ) {

            self.ai_new_state = AI_WALK;
            self.goalentity = self.pathentity;
            newtarg = world;
         } else {

            self.ai_new_state = AI_STAND;
            newtarg = world;

         }

      }

   }
   return ( newtarg );
};


void  (float state_demanded)AI_Decision_Tree =  {
local float rnge = 0.00000;
local float in_sight = 0.00000;
local float in_front = 0.00000;
local entity targ;
local entity finaltarg;
   if ( ((state_demanded == FALSE) || (self.ai_new_state == AI_DECIDE)) ) {

      if ( ((self.ai_duration > time) && (self.ai_new_state != AI_DECIDE)) ) {

         return ;

      }
      if ( (self.health > 0.00000) ) {

         if ( (self.ai_new_state == AI_DECIDE) ) {

            self.ai_duration = (time - 1.00000);

         }
         targ = AI_Target ();
         rnge = AI_calc_range (targ);
         in_sight = AI_visionblocked (targ);
         in_front = AI_infront (targ);
         if ( (rnge == RANGE_FAR) ) {

            finaltarg = AI_Decision_Far (in_sight, in_front, targ);
         } else {

            if ( (rnge == RANGE_MID) ) {

               finaltarg = AI_Decision_Mid (in_sight, in_front, targ);
            } else {

               if ( (rnge == RANGE_NEAR) ) {

                  finaltarg = AI_Decision_Near (in_sight, in_front, targ);
               } else {

                  if ( (rnge == RANGE_MELEE) ) {

                     finaltarg = AI_Decision_Melee (in_sight, in_front, targ);

                  }

               }

            }

         }
      } else {

         AI_Decision_Dead ();

      }
   } else {

      finaltarg = self.enemy;

   }
   if ( (self.ai_new_state != self.ai_state) ) {

      AI_Change_State (finaltarg);

   }
};


void  ()AI_Main =  {
local float demand_state = 0.00000;
   if ( !comamode ) {

      self.ai_frame_time = 0.00000;
      demand_state = FALSE;
      do {

         AI_Decision_Tree (demand_state);
         self.ai_self_func ();
         if ( (self.ai_state != self.ai_new_state) ) {

            demand_state = TRUE;
         } else {

            demand_state = FALSE;
            self.ai_move_func ();
            if ( (self.ai_state != self.ai_new_state) ) {

               demand_state = TRUE;
            } else {

               demand_state = FALSE;

            }

         }
      } while ( (demand_state == TRUE) );
   } else {

      AI_TargetSearch ();

   }
   if ( !self.ai_frame_time ) {

      self.nextthink = (time + HX_FRAME_TIME);
   } else {

      self.nextthink = (time + self.ai_frame_time);

   }
};


void  ()AI_start =  {
   self.origin_z += 1.00000;
   droptofloor ();
   if ( !walkmove (0.00000, 0.00000, FALSE) ) {

      dprint ("walkmonster in wall at: ");
      dprint (vtos (self.origin));
      dprint ("\n");

   }
   if ( self.target ) {

      self.pathentity = find (world, targetname, self.target);
      self.goalentity = find (world, targetname, self.target);
      self.ideal_yaw = vectoyaw ((self.goalentity.origin - self.origin));
      if ( !self.pathentity ) {

         dprint ("Monster can't find target at ");
         dprint (vtos (self.origin));
         dprint ("\n");

      }

   }
   self.think = AI_Main;
   self.nextthink = (self.nextthink + (random () * 0.50000));
};


void  ()AI_Land_Init =  {
   self.takedamage = DAMAGE_YES;
   self.flags2 += FL_ALIVE;
   self.ideal_yaw = (self.angles * '0.00000 1.00000 0.00000');
   if ( !self.yaw_speed ) {

      self.yaw_speed = 20.00000;

   }
   self.view_ofs = '0.00000 0.00000 25.00000';
   self.use = monster_use;
   self.flags = (self.flags | FL_MONSTER);
   self.enemy = world;
   self.ai_state = AI_DECIDE;
   self.nextthink = (self.nextthink + (random () * 0.50000));
   self.think = AI_start;
   total_monsters += 1.00000;
};

