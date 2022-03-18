void  ()player_necromancer_run;
void  ()player_necromancer_crouch_stand;
void  ()player_necromancer_stand;

void  ()player_necromancer_swim =  {
   self.th_weapon ();
   if ( (self.waterlevel < 3.00000) ) {

      if ( (self.velocity_x || self.velocity_y) ) {

         self.think = self.th_run;
      } else {

         self.think = self.th_stand;

      }

   }
};


void  ()player_necromancer_sickle_swim =  {
   AdvanceFrame( 126.00000, 139.00000);
   player_necromancer_swim ();
};


void  ()player_necromancer_setstaff_swim =  {
   AdvanceFrame( 180.00000, 193.00000);
   player_necromancer_swim ();
};


void  ()player_necromancer_spell_swim =  {
   AdvanceFrame( 68.00000, 81.00000);
   player_necromancer_swim ();
};


void  ()player_necromancer_fly =  {
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


void  ()player_necromancer_sickle_fly =  {
   AdvanceFrame( 126.00000, 139.00000);
   player_necromancer_fly ();
};


void  ()player_necromancer_setstaff_fly =  {
   AdvanceFrame( 180.00000, 193.00000);
   player_necromancer_fly ();
};


void  ()player_necromancer_spell_fly =  {
   AdvanceFrame( 68.00000, 81.00000);
   player_necromancer_fly ();
};


void  ()player_necromancer_stand =  {
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_necromancer_crouch_stand;
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


void  ()player_necromancer_sickle_stand =  {
   AdvanceFrame( 160.00000, 171.00000);
   player_necromancer_stand ();
};


void  ()player_necromancer_setstaff_stand =  {
   AdvanceFrame( 214.00000, 225.00000);
   player_necromancer_stand ();
};


void  ()player_necromancer_spell_stand =  {
   AdvanceFrame( 102.00000, 113.00000);
   player_necromancer_stand ();
};


void  ()player_necromancer_run =  {
   self.th_weapon ();
   if ( (self.hull == HULL_CROUCH) ) {

      self.think = player_necromancer_crouch_move;
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


void  ()player_necromancer_sickle_run =  {
   AdvanceFrame( 148.00000, 159.00000);
   player_necromancer_run ();
};


void  ()player_necromancer_setstaff_run =  {
   AdvanceFrame( 202.00000, 213.00000);
   player_necromancer_run ();
};


void  ()player_necromancer_spell_run =  {
   AdvanceFrame( 90.00000, 101.00000);
   player_necromancer_run ();
};


void  ()player_necromancer_crouch_stand =  {
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

            self.think = player_necromancer_crouch_move;

         }

      }

   }
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()player_necromancer_crouch_move =  {
   AdvanceFrame( 0.00000, 19.00000);
   self.th_weapon ();
   if ( (self.movetype == MOVETYPE_FLY) ) {

      self.think = player_necromancer_fly;
   } else {

      if ( (self.hull == HULL_NORMAL) ) {

         self.think = self.th_run;
      } else {

         if ( (!self.velocity_x && !self.velocity_y) ) {

            self.think = player_necromancer_crouch_stand;

         }

      }

   }
};


void  ()player_necromancer_attack =  {
   self.th_weapon ();
   if ( (cycle_wrapped && !self.button0) ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = self.th_stand;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()player_necromancer_sickle_attack =  {
   AdvanceFrame( 114.00000, 125.00000);
   player_necromancer_attack ();
};


void  ()player_necromancer_spell_attack =  {
   AdvanceFrame( 60.00000, 67.00000);
   player_necromancer_attack ();
};


void  ()player_necromancer_setstaff_attack =  {
   AdvanceFrame( 172.00000, 179.00000);
   player_necromancer_attack ();
};


void  ()player_necromancer_pain =  {
   self.th_weapon ();
   if ( cycle_wrapped ) {

      if ( (!self.velocity_x && !self.velocity_y) ) {

         self.think = self.th_stand;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()player_necromancer_sickle_pain =  {
   AdvanceFrame( 140.00000, 147.00000);
   if ( (self.frame == 140.00000) ) {

      PainSound ();

   }
   player_necromancer_pain ();
};


void  ()player_necromancer_setstaff_pain =  {
   AdvanceFrame( 194.00000, 201.00000);
   if ( (self.frame == 194.00000) ) {

      PainSound ();

   }
   player_necromancer_pain ();
};


void  ()player_necromancer_spell_pain =  {
   AdvanceFrame( 82.00000, 89.00000);
   if ( (self.frame == 82.00000) ) {

      PainSound ();

   }
   player_necromancer_pain ();
};


void  ()player_necromancer_die1 =  {
   AdvanceFrame( 20.00000, 29.00000);
   if ( cycle_wrapped ) {

      self.frame = 29.00000;
      self.think = PlayerDead;

   }
};


void  ()player_necromancer_die2 =  {
   AdvanceFrame( 20.00000, 29.00000);
   if ( cycle_wrapped ) {

      self.frame = 29.00000;
      self.think = PlayerDead;

   }
};


void  ()player_necromancer_behead =  {
   self.level = 41.00000;
   self.dmg = 59.00000;
   self.cnt = 0.00000;
   player_behead ();
};


void  ()Nec_Change_Weapon =  {
   if ( (self.weapon == IT_WEAPON1) ) {

      self.th_stand = player_necromancer_sickle_stand;
      self.th_missile = sickle_decide_attack;
      self.th_run = player_necromancer_sickle_run;
      self.th_pain = player_necromancer_sickle_pain;
      self.th_swim = player_necromancer_sickle_swim;
      self.th_fly = player_necromancer_sickle_fly;
   } else {

      if ( (self.weapon == IT_WEAPON4) ) {

         self.th_stand = player_necromancer_setstaff_stand;
         self.th_missile = setstaff_decide_attack;
         self.th_run = player_necromancer_setstaff_run;
         self.th_pain = player_necromancer_setstaff_pain;
         self.th_swim = player_necromancer_setstaff_swim;
         self.th_fly = player_necromancer_setstaff_fly;
      } else {

         self.th_stand = player_necromancer_spell_stand;
         if ( (self.weapon == IT_WEAPON2) ) {

            self.th_missile = Nec_Mis_Attack;
         } else {

            self.th_missile = Nec_Bon_Attack;

         }
         self.th_run = player_necromancer_spell_run;
         self.th_pain = player_necromancer_spell_pain;
         self.th_swim = player_necromancer_spell_swim;
         self.th_fly = player_necromancer_spell_fly;

      }

   }
   if ( (self.hull != HULL_CROUCH) ) {

      self.think = self.th_stand;

   }
};

