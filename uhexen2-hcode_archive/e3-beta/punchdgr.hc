void  ()assassin_run;
void  ()player_assassin_attack;
void  ()player_assassin_crouch_attack;
void  ()Ass_Pdgr_Fire;

void  ()punchdagger_idle =  {
   self.th_weapon = punchdagger_idle;
   self.weaponframe = 0.00000;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Ass_Pdgr_Fire ();

   }
};


void  ()punchdagger_d =  {
   self.th_weapon = punchdagger_d;
   self.wfs = advanceweaponframe (54.00000, 72.00000);
   if ( (self.weaponframe == 58.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.weaponframe == 61.00000) ) {

      FireMelee (PUNCHDGR_DAMAGE, PUNCHDGR_ADD_DAMAGE, 64.00000);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      punchdagger_idle ();

   }
};


void  ()punchdagger_c =  {
   self.th_weapon = punchdagger_c;
   self.wfs = advanceweaponframe (36.00000, 53.00000);
   if ( (self.weaponframe == 43.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.weaponframe == 46.00000) ) {

      FireMelee (PUNCHDGR_DAMAGE, PUNCHDGR_ADD_DAMAGE, 64.00000);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      punchdagger_idle ();

   }
};


void  ()punchdagger_b =  {
   self.th_weapon = punchdagger_b;
   self.wfs = advanceweaponframe (18.00000, 35.00000);
   if ( (self.weaponframe == 26.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.weaponframe == 29.00000) ) {

      FireMelee (PUNCHDGR_DAMAGE, PUNCHDGR_ADD_DAMAGE, 64.00000);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      punchdagger_idle ();

   }
};


void  ()punchdagger_a =  {
   self.th_weapon = punchdagger_a;
   self.wfs = advanceweaponframe (1.00000, 17.00000);
   if ( (self.weaponframe == 4.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.weaponframe == 8.00000) ) {

      FireMelee (PUNCHDGR_DAMAGE, PUNCHDGR_ADD_DAMAGE, 64.00000);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      punchdagger_idle ();

   }
};


void  ()Ass_Pdgr_Fire =  {
local float r = 0.00000;
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_assassin_attack;
   } else {

      self.think = player_assassin_crouch_attack;

   }
   self.attack_finished = (time + 0.70000);
   r = rint (((random () * 3.00000) + 1.00000));
   if ( (r == 1.00000) ) {

      punchdagger_a ();
   } else {

      if ( (r == 2.00000) ) {

         punchdagger_b ();
      } else {

         if ( (r == 3.00000) ) {

            punchdagger_c ();
         } else {

            punchdagger_d ();

         }

      }

   }
};


void  ()punchdagger_select =  {
   self.th_weapon = punchdagger_select;
   self.wfs = advanceweaponframe (5.00000, 1.00000);
   self.weaponmodel = "models/punchdgr.mdl";
   if ( (self.wfs == WF_CYCLE_STARTED) ) {

      sound (self, CHAN_WEAPON, "weapons/unsheath.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      punchdagger_idle ();

   }
};


void  ()punchdagger_deselect =  {
   self.th_weapon = punchdagger_deselect;
   self.wfs = advanceweaponframe (1.00000, 5.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

