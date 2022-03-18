void  ()player_paladin_run;
void  ()player_paladin_crouch_stand;
void  ()player_paladin_crouch_move;
void  ()player_paladin_stand1;

void  ()player_paladin_swim =  {
   AdvanceFrame( 196.00000, 216.00000);
   self.th_weapon ();
   if ( (self.waterlevel < 3.00000) ) {

      if ( (self.velocity_x || self.velocity_y) ) {

         self.think = player_paladin_run;
      } else {

         self.think = player_paladin_stand1;

      }

   }
};


void  ()player_paladin_fly =  {
   AdvanceFrame( 126.00000, 143.00000);
   self.th_weapon ();
   if ( (self.waterlevel > 2.00000) ) {

      self.think = player_paladin_swim;
   } else {

      if ( (self.movetype != MOVETYPE_FLY) ) {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = player_paladin_run;
         } else {

            self.think = player_paladin_stand1;

         }

      }

   }
};


void  ()player_paladin_stand1 =  {
   AdvanceFrame( 183.00000, 195.00000);
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_paladin_crouch_stand;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = player_paladin_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = player_paladin_fly;
         } else {

            if ( (self.velocity_x || self.velocity_y) ) {

               self.think = player_paladin_run;

            }

         }

      }

   }
};


void  ()player_paladin_run =  {
   AdvanceFrame( 173.00000, 182.00000);
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_paladin_crouch_move;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = player_paladin_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = player_paladin_fly;
         } else {

            if ( (!self.velocity_x && !self.velocity_y) ) {

               self.think = player_paladin_stand1;

            }

         }

      }

   }
};


void  ()player_paladin_crouch_stand =  {
   self.th_weapon ();
   if ( ((self.frame > 57.00000) || (self.frame < 37.00000)) ) {

      self.frame = 37.00000;

   }
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_paladin_stand1;
   } else {

      if ( (self.movetype == MOVETYPE_FLY) ) {

         self.think = player_paladin_fly;
      } else {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = player_paladin_crouch_move;

         }

      }

   }
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()player_paladin_crouch_move =  {
   AdvanceFrame( 37.00000, 57.00000);
   self.th_weapon ();
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_paladin_run;
   } else {

      if ( (self.movetype == MOVETYPE_FLY) ) {

         self.think = player_paladin_fly;
      } else {

         if ( (!self.velocity_x && !self.velocity_y) ) {

            self.think = player_paladin_crouch_stand;

         }

      }

   }
};


void  ()player_paladin_attack =  {
   AdvanceFrame( 0.00000, 17.00000);
   self.th_weapon ();
   if ( (cycle_wrapped && !self.button0) ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_paladin_stand1;
      } else {

         self.think = player_paladin_run;

      }

   }
};


void  ()player_paladin_crouch_attack =  {
   AdvanceFrame( 27.00000, 36.00000);
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_paladin_crouch_stand;
      } else {

         self.think = player_paladin_crouch_move;

      }

   }
};


void  ()player_paladin_pain =  {
   AdvanceFrame( 159.00000, 162.00000);
   self.th_weapon ();
   if ( (self.frame == 159.00000) ) {

      PainSound ();

   }
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_paladin_stand1;
      } else {

         self.think = player_paladin_run;

      }

   }
};


void  ()player_paladin_jump =  {
   AdvanceFrame( 147.00000, 158.00000);
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = player_paladin_stand1;
      } else {

         self.think = player_paladin_run;

      }

   }
};


void  ()player_paladin_die1 =  {
   AdvanceFrame( 58.00000, 76.00000);
   if ( cycle_wrapped ) {

      self.frame = 76.00000;
      self.think = PlayerDead;

   }
};


void  ()player_paladin_die2 =  {
   AdvanceFrame( 97.00000, 113.00000);
   if ( cycle_wrapped ) {

      self.frame = 113.00000;
      self.think = PlayerDead;

   }
};


void  ()player_paladin_behead =  {
   self.level = 78.00000;
   self.dmg = 96.00000;
   self.cnt = 0.00000;
   player_behead ();
};


void  ()pal_stand1 =  [237.0, pal_stand1] {
   ai_stand ();
};


void  ()pal_die =  {
   remove (self);
};


void  ()player_paladin =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   setmodel (self, "models/paladin.mdl");
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 60.00000');
   self.th_stand = pal_stand1;
   self.th_walk = pal_stand1;
   self.th_run = pal_stand1;
   self.th_pain = pal_die;
   self.th_die = pal_die;
   self.th_missile = pal_stand1;
   self.frame += 48.00000;
};

