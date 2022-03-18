
void  ()SetModelAndThinks =  {
   self.touch = PlayerTouch;
   if ( (self.playerclass == CLASS_ASSASSIN) ) {

      self.mass = 6.00000;
      self.th_missile = player_assassin_attack;
      self.th_melee = player_assassin_crouch_attack;
      self.th_stand = player_assassin_stand1;
      self.th_run = player_assassin_run;
      self.th_walk = player_assassin_crouch_move;
      self.th_pain = player_assassin_pain;
      self.th_die = PlayerDie;
      self.th_swim = player_assassin_swim;
      self.th_jump = player_assassin_jump;
      self.th_fly = player_assassin_fly;
      self.th_die1 = player_assassin_die1;
      self.th_die2 = player_assassin_die2;
      self.th_goredeath = player_assassin_behead;
      setmodel (self, "models/assassin.mdl");
      modelindex_assassin = self.modelindex;
      self.headmodel = "models/h_ass.mdl";
      if ( (self.weapon == IT_WEAPON3) ) {

         self.th_weapon = crossbow_select;
      } else {

         if ( (self.weapon == IT_WEAPON2) ) {

            self.th_weapon = grenade_select;
         } else {

            self.th_weapon = punchdagger_select;

         }

      }
   } else {

      if ( (self.playerclass == CLASS_CRUSADER) ) {

         self.mass = 7.00000;
         self.th_walk = player_crusader_crouch_move;
         self.th_die = PlayerDie;
         self.th_jump = player_crusader_jump;
         self.th_die1 = player_crusader_die1;
         self.th_die2 = player_crusader_die2;
         self.th_goredeath = player_crusader_behead;
         setmodel (self, "models/crusader.mdl");
         self.headmodel = "models/h_cru.mdl";
         modelindex_crusader = self.modelindex;
         Cru_Change_Weapon ();
         if ( (self.weapon == IT_WEAPON4) ) {

            self.th_weapon = sunstaff_select;
         } else {

            if ( (self.weapon == IT_WEAPON3) ) {

               self.th_weapon = meteor_select;
            } else {

               if ( (self.weapon == IT_WEAPON2) ) {

                  self.th_weapon = icestaff_select;
               } else {

                  self.th_weapon = warhammer_select;

               }

            }

         }
      } else {

         if ( (self.playerclass == CLASS_PALADIN) ) {

            self.mass = 8.00000;
            self.th_missile = player_paladin_attack;
            self.th_melee = player_paladin_crouch_attack;
            self.th_stand = player_paladin_stand1;
            self.th_run = player_paladin_run;
            self.th_walk = player_paladin_crouch_move;
            self.th_pain = player_paladin_pain;
            self.th_die = PlayerDie;
            self.th_swim = player_paladin_swim;
            self.th_jump = player_paladin_jump;
            self.th_fly = player_paladin_fly;
            self.th_die1 = player_paladin_die1;
            self.th_die2 = player_paladin_die2;
            self.th_goredeath = player_paladin_behead;
            setmodel (self, "models/paladin.mdl");
            self.headmodel = "models/h_pal.mdl";
            modelindex_paladin = self.modelindex;
            if ( (self.weapon == IT_WEAPON4) ) {

               self.th_weapon = purifier_select;
            } else {

               if ( (self.weapon == IT_WEAPON2) ) {

                  self.th_weapon = vorpal_select;
               } else {

                  self.th_weapon = gauntlet_select;

               }

            }
         } else {

            if ( (self.playerclass == CLASS_NECROMANCER) ) {

               self.mass = 7.00000;
               self.th_walk = player_necromancer_crouch_move;
               self.th_die = PlayerDie;
               self.th_jump = SUB_Null;
               self.th_die1 = player_necromancer_die1;
               self.th_die2 = player_necromancer_die2;
               self.th_goredeath = player_necromancer_behead;
               setmodel (self, "models/necro.mdl");
               self.headmodel = "models/h_nec.mdl";
               modelindex_necromancer = self.modelindex;
               Nec_Change_Weapon ();
               if ( (self.weapon == IT_WEAPON4) ) {

                  self.th_weapon = setstaff_select;
               } else {

                  if ( (self.weapon == IT_WEAPON1) ) {

                     self.th_weapon = sickle_select;
                  } else {

                     if ( (self.weapon == IT_WEAPON2) ) {

                        self.th_weapon = magicmis_select;
                     } else {

                        self.th_weapon = boneshard_select;

                     }

                  }

               }

            }

         }

      }

   }
   self.init_modelindex = self.modelindex;
};

