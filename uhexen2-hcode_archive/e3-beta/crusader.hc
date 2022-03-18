void  ()player_crusader_run;
void  ()player_crusader_crouch_stand;
void  ()player_crusader_stand;

void  ()player_crusader_jump =  {
   AdvanceFrame( 41.00000, 55.00000);
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = self.th_stand;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()player_crusader_swim =  {
   self.th_weapon ();
   if ( (self.waterlevel < 3.00000) ) {

      if ( (self.velocity_x || self.velocity_y) ) {

         self.think = self.th_run;
      } else {

         self.think = self.th_stand;

      }

   }
};


void  ()player_crusader_hammer_swim =  {
   AdvanceFrame( 41.00000, 55.00000);
   player_crusader_swim ();
};


void  ()player_crusader_sunstaff_swim =  {
   AdvanceFrame( 151.00000, 164.00000);
   player_crusader_swim ();
};


void  ()player_crusader_ice_swim =  {
   AdvanceFrame( 99.00000, 113.00000);
   player_crusader_swim ();
};


void  ()player_crusader_fly =  {
   self.th_weapon ();
   if ( (self.waterlevel > 2.00000) ) {

      self.think = self.th_swim;
   } else {

      if ( (self.movetype != MOVETYPE_FLY) ) {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = self.th_run;
         } else {

            self.think = self.th_stand;

         }

      }

   }
};


void  ()player_crusader_hammer_fly =  {
   AdvanceFrame( 41.00000, 55.00000);
   player_crusader_fly ();
};


void  ()player_crusader_sunstaff_fly =  {
   AdvanceFrame( 151.00000, 164.00000);
   player_crusader_fly ();
};


void  ()player_crusader_ice_fly =  {
   AdvanceFrame( 99.00000, 113.00000);
   player_crusader_fly ();
};


void  ()player_crusader_stand =  {
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_crusader_crouch_stand;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = self.th_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = self.th_fly;
         } else {

            if ( (self.velocity_x || self.velocity_y) ) {

               self.think = self.th_run;

            }

         }

      }

   }
};


void  ()player_crusader_hammer_stand =  {
   AdvanceFrame( 74.00000, 86.00000);
   player_crusader_stand ();
};


void  ()player_crusader_sunstaff_stand =  {
   AdvanceFrame( 190.00000, 202.00000);
   player_crusader_stand ();
};


void  ()player_crusader_ice_stand =  {
   AdvanceFrame( 138.00000, 150.00000);
   player_crusader_stand ();
};


void  ()player_crusader_run =  {
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_crusader_crouch_move;
   } else {

      if ( (self.waterlevel > 2.00000) ) {

         self.think = self.th_swim;
      } else {

         if ( (self.movetype == MOVETYPE_FLY) ) {

            self.think = self.th_fly;
         } else {

            if ( (!self.velocity_x && !self.velocity_y) ) {

               self.think = self.th_stand;

            }

         }

      }

   }
};


void  ()player_crusader_hammer_run =  {
   AdvanceFrame( 87.00000, 98.00000);
   player_crusader_run ();
};


void  ()player_crusader_sunstaff_run =  {
   AdvanceFrame( 173.00000, 184.00000);
   player_crusader_run ();
};


void  ()player_crusader_ice_run =  {
   AdvanceFrame( 122.00000, 133.00000);
   player_crusader_run ();
};


void  ()player_crusader_crouch_stand =  {
   self.th_weapon ();
   if ( ((self.frame > 19.00000) || (self.frame < 0.00000)) ) {

      self.frame = 0.00000;

   }
   if ( (self.movetype == MOVETYPE_FLY) ) {

      self.think = self.th_fly;
   } else {

      if ( (self.hull == HULL_NORMAL) ) {

         self.think = self.th_stand;
      } else {

         if ( (self.velocity_x || self.velocity_y) ) {

            self.think = player_crusader_crouch_move;

         }

      }

   }
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()player_crusader_crouch_move =  {
   AdvanceFrame( 0.00000, 19.00000);
   self.th_weapon ();
   if ( (self.movetype == MOVETYPE_FLY) ) {

      self.think = player_crusader_fly;
   } else {

      if ( (self.hull == HULL_NORMAL) ) {

         self.think = self.th_run;
      } else {

         if ( (!self.velocity_x && !self.velocity_y) ) {

            self.think = player_crusader_crouch_stand;

         }

      }

   }
};


void  ()player_crusader_attack =  {
   self.th_weapon ();
   if ( (cycle_wrapped && !self.button0) ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = self.th_stand;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()player_crusader_hammer_attack =  {
   AdvanceFrame( 56.00000, 65.00000);
   player_crusader_attack ();
};


void  ()player_crusader_ice_attack =  {
   AdvanceFrame( 134.00000, 137.00000);
   player_crusader_attack ();
};


void  ()player_crusader_sunstaff_attack =  {
   AdvanceFrame( 185.00000, 189.00000);
   player_crusader_attack ();
};


void  ()player_crusader_pain =  {
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = self.th_stand;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()player_crusader_hammer_pain =  {
   AdvanceFrame( 66.00000, 73.00000);
   if ( (self.frame == 66.00000) ) {

      PainSound ();

   }
   player_crusader_pain ();
};


void  ()player_crusader_sunstaff_pain =  {
   AdvanceFrame( 165.00000, 172.00000);
   if ( (self.frame == 165.00000) ) {

      PainSound ();

   }
   player_crusader_pain ();
};


void  ()player_crusader_ice_pain =  {
   AdvanceFrame( 114.00000, 121.00000);
   if ( (self.frame == 114.00000) ) {

      PainSound ();

   }
   player_crusader_pain ();
};


void  ()player_crusader_die1 =  {
   AdvanceFrame( 20.00000, 39.00000);
   if ( cycle_wrapped ) {

      self.frame = 39.00000;
      self.think = PlayerDead;

   }
};


void  ()player_crusader_die2 =  {
   AdvanceFrame( 20.00000, 39.00000);
   if ( cycle_wrapped ) {

      self.frame = 39.00000;
      self.think = PlayerDead;

   }
};


void  ()player_crusader_behead =  {
   self.level = 20.00000;
   self.dmg = 39.00000;
   self.cnt = 0.00000;
   player_behead ();
};


void  ()Cru_Change_Weapon =  {
   if ( (self.weapon == IT_WEAPON1) ) {

      self.th_stand = player_crusader_hammer_stand;
      self.th_missile = player_crusader_hammer_attack;
      self.th_run = player_crusader_hammer_run;
      self.th_pain = player_crusader_hammer_pain;
      self.th_swim = player_crusader_hammer_swim;
      self.th_fly = player_crusader_hammer_fly;
   } else {

      if ( (self.weapon == IT_WEAPON2) ) {

         self.th_stand = player_crusader_ice_stand;
         self.th_missile = player_crusader_ice_attack;
         self.th_run = player_crusader_ice_run;
         self.th_pain = player_crusader_ice_pain;
         self.th_swim = player_crusader_ice_swim;
         self.th_fly = player_crusader_ice_fly;
      } else {

         self.th_stand = player_crusader_sunstaff_stand;
         self.th_missile = player_crusader_sunstaff_attack;
         self.th_run = player_crusader_sunstaff_run;
         self.th_pain = player_crusader_sunstaff_pain;
         self.th_swim = player_crusader_sunstaff_swim;
         self.th_fly = player_crusader_sunstaff_fly;

      }

   }
   if ( (self.hull != HULL_CROUCH) ) {

      self.think = self.th_stand;

   }
};

