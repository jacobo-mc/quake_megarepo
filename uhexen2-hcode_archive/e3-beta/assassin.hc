void  ()player_assassin_run;
void  ()player_assassin_crouch_stand;
void  ()player_assassin_crouch_move;
void  ()player_assassin_stand1;

void  ()player_assassin_swim =  {
   AdvanceFrame( 121.00000, 142.00000);
   self.th_weapon ();
   if ( (self.waterlevel < 3.00000) ) {

      if ( (self.velocity_x || self.velocity_y) ) {

         self.think = player_assassin_run;
      } else {

         self.think = player_assassin_stand1;

      }

   }
};


void  ()player_assassin_fly =  {
   AdvanceFrame( 64.00000, 77.00000);
   self.th_weapon ();
   if ( (self.waterlevel > 2.00000) ) {

      self.think = player_assassin_swim;
   } else {

      if ( (self.movetype != MOVETYPE_FLY) ) {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = player_assassin_run;
         } else {

            self.think = player_assassin_stand1;

         }

      }

   }
};


void  ()player_assassin_stand1 =  {
   AdvanceFrame( 106.00000, 120.00000);
   self.th_weapon ();
   if ( ((self.hull == HULL_CROUCH) || ((self.hull == HULL_NORMAL) && (self.scale == 1.70000))) ) {

      self.think = player_assassin_crouch_stand;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = player_assassin_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = player_assassin_fly;
         } else {

            if ( (self.velocity_x || self.velocity_y) ) {

               self.think = player_assassin_run;

            }

         }

      }

   }
};


void  ()player_assassin_run =  {
   AdvanceFrame( 96.00000, 105.00000);
   self.th_weapon ();
   if ( ((self.hull == HULL_CROUCH) || ((self.hull == HULL_NORMAL) && (self.scale == 1.70000))) ) {

      self.think = player_assassin_crouch_move;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = player_assassin_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = player_assassin_fly;
         } else {

            if ( (!self.velocity_x && !self.velocity_y) ) {

               self.think = player_assassin_stand1;

            }

         }

      }

   }
};


void  ()player_assassin_crouch_stand =  {
   self.th_weapon ();
   if ( ((self.frame > 38.00000) || (self.frame < 19.00000)) ) {

      self.frame = 19.00000;

   }
   if ( (self.movetype == MOVETYPE_FLY) ) {

      self.think = player_assassin_fly;
   } else {

      if ( (((self.hull == HULL_NORMAL) && (self.scale == 1.00000)) || (self.hull == HULL_BIG)) ) {

         self.think = player_assassin_stand1;
      } else {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = player_assassin_crouch_move;

         }

      }

   }
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()player_assassin_crouch_move =  {
   AdvanceFrame( 19.00000, 38.00000);
   self.th_weapon ();
   if ( (self.movetype == MOVETYPE_FLY) ) {

      self.think = player_assassin_fly;
   } else {

      if ( (((self.hull == HULL_NORMAL) && (self.scale == 1.00000)) || (self.hull == HULL_BIG)) ) {

         self.think = player_assassin_run;
      } else {

         if ( (!self.velocity_x && !self.velocity_y) ) {

            self.think = player_assassin_crouch_stand;

         }

      }

   }
};


void  ()player_assassin_attack =  {
   AdvanceFrame( 1.00000, 6.00000);
   self.th_weapon ();
   if ( (cycle_wrapped && !self.button0) ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_assassin_stand1;
      } else {

         self.think = player_assassin_run;

      }

   }
};


void  ()player_assassin_crouch_attack =  {
   AdvanceFrame( 7.00000, 18.00000);
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_assassin_crouch_stand;
      } else {

         self.think = player_assassin_crouch_move;

      }

   }
};


void  ()player_assassin_pain =  {
   AdvanceFrame( 91.00000, 95.00000);
   self.th_weapon ();
   if ( (self.frame == 91.00000) ) {

      PainSound ();
   } else {

      if ( cycle_wrapped ) {

         if ( (!self.velocity_x && !self.velocity_y) ) {

            self.think = player_assassin_stand1;
         } else {

            self.think = player_assassin_run;

         }

      }

   }
};


void  ()player_assassin_jump =  {
   AdvanceFrame( 78.00000, 90.00000);
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_assassin_stand1;
      } else {

         self.think = player_assassin_run;

      }

   }
};


void  ()player_assassin_die1 =  {
   AdvanceFrame( 39.00000, 57.00000);
   if ( cycle_wrapped ) {

      self.frame = 57.00000;
      self.think = PlayerDead;

   }
};


void  ()player_assassin_die2 =  {
   AdvanceFrame( 163.00000, 181.00000);
   if ( cycle_wrapped ) {

      self.frame = 181.00000;
      self.think = PlayerDead;

   }
};


void  ()player_assassin_behead =  {
   self.level = 183.00000;
   self.dmg = 200.00000;
   self.cnt = 0.00000;
   player_behead ();
};


void  ()assassin_run =  {
   AdvanceFrame (96.00000, 105.00000);
   if ( ((self.frame >= 96.00000) && (self.frame <= 105.00000)) ) {

      self.move_distance = 6.00000;
   } else {

      self.move_distance = 5.00000;

   }
};


void  ()assassin_melee =  {
local float result = 0.00000;
   AdvanceFrame (1.00000, 6.00000);
   if ( (self.frame == 3.00000) ) {

      result = AI_face_enemy ();
      if ( result ) {

         if ( (random () < 0.20000) ) {

            self.artifacts = ART_TOMEOFPOWER;
         } else {

            self.artifacts = FALSE;

         }
         self.weapon = IT_WEAPON1;
         self.v_angle = self.angles;
         W_Attack ();
         self.ai_new_state = AI_DECIDE;
      } else {

         self.frame -= 1.00000;

      }
   } else {

      if ( (self.frame == 5.00000) ) {

         self.ai_new_state = AI_DECIDE;

      }

   }
};


void  ()assassin_missile =  {
local float result = 0.00000;
   AdvanceFrame (1.00000, 5.00000);
   if ( (self.frame == 3.00000) ) {

      result = AI_face_enemy ();
      if ( result ) {

         if ( (random () < 0.20000) ) {

            self.artifacts = ART_TOMEOFPOWER;
         } else {

            self.artifacts = FALSE;

         }
         if ( ((random () < 0.50000) || (vlen ((self.origin - self.enemy.origin)) < 100.00000)) ) {

            self.weapon = IT_WEAPON3;
         } else {

            self.weapon = IT_WEAPON2;

         }
         self.v_angle = self.angles;
         W_Attack ();
         self.ai_new_state = AI_DECIDE;
      } else {

         self.frame -= 1.00000;

      }
   } else {

      if ( (self.frame == 5.00000) ) {

         self.ai_new_state = AI_DECIDE;

      }

   }
};


void  ()assassin_pain =  {
   AdvanceFrame( 143.00000, 148.00000);
   if ( (random () < 0.50000) ) {

      ai_pain (3.00000);

   }
   if ( (self.frame >= 148.00000) ) {

      assassin_run ();

   }
};


void  ()assassin_walk =  {
   AdvanceFrame (143.00000, 162.00000);
   if ( ((self.frame >= 143.00000) && (self.frame <= 162.00000)) ) {

      self.move_distance = 3.00000;
   } else {

      self.move_distance = 2.50000;

   }
};


void  ()assassin_stand =  {
   AdvanceFrame( 121.00000, 142.00000);
   ai_stand ();
};


void  ()assassin_changestate =  {
   if ( ((self.ai_new_state == AI_WALK) || (self.ai_new_state == AI_WANDER)) ) {

      self.ai_self_func = assassin_walk;
      self.move_distance = 1.00000;
   } else {

      if ( (self.ai_new_state == AI_CHARGE) ) {

         self.ai_self_func = assassin_run;
         self.move_distance = 1.00000;
      } else {

         if ( (self.ai_new_state == AI_STAND) ) {

            self.ai_self_func = assassin_stand;
            self.move_distance = 0.00000;
         } else {

            if ( (self.ai_new_state == AI_MELEE_ATTACK) ) {

               self.move_distance = 0.00000;
               self.ai_self_func = assassin_melee;
            } else {

               if ( (self.ai_new_state == AI_MISSILE_ATTACK) ) {

                  self.ai_self_func = assassin_missile;
                  self.move_distance = 0.00000;
               } else {

                  self.ai_new_state = AI_WALK;
                  self.ai_self_func = assassin_walk;

               }

            }

         }

      }

   }
};


void  ()player_assassin =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   self.thingtype = THINGTYPE_FLESH;
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.yaw_speed = 4.50000;
   self.takedamage = DAMAGE_YES;
   self.health = 300.00000;
   setmodel (self, "models/assassin.mdl");
   self.skin = 0.00000;
   setsize (self, '-16.00000 -16.00000 -4.00000', '16.00000 16.00000 50.00000');
   self.th_stand = assassin_stand;
   self.th_walk = assassin_walk;
   self.th_run = assassin_run;
   self.th_die = SUB_Remove;
   self.th_melee = assassin_melee;
   self.th_missile = assassin_missile;
   self.th_pain = assassin_pain;
   self.flags = (self.flags | FL_MONSTER);
   self.ai_state_func = assassin_changestate;
   self.ai_poss_states = (((((((AI_STAND | AI_WALK) | AI_CHARGE) | AI_WANDER) | AI_MELEE_ATTACK) | AI_MISSILE_ATTACK) | AI_PAIN) | AI_DEAD_GIB);
   AI_Land_Init ();
};

