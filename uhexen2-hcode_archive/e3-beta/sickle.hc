void  ()sickle_decide_attack;
void  ()player_necromancer_sickle_attack;

void  ()FireSickle =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local float damg = 0.00000;
   makevectors (self.v_angle);
   source = (self.origin + self.proj_ofs);
   traceline (source, (source + (v_forward * 64.00000)), FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   org = (trace_endpos - (v_forward * 4.00000));
   if ( trace_ent.takedamage ) {

      trace_ent.axhitme = 1.00000;
      damg = (GAUNT_BASE_DAMAGE + (random () * GAUNT_ADD_DAMAGE));
      T_Damage (trace_ent, self, self, 20.00000);
      sound (self, CHAN_WEAPON, "raven/gauntht1.wav", 1.00000, ATTN_NORM);
   } else {

      sound (self, CHAN_WEAPON, "player/hitwall.wav", 1.00000, ATTN_NORM);
      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_GUNSHOT);
      WriteCoord (MSG_BROADCAST, org_x);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);

   }
};


void  ()sickle_idle =  {
   self.th_weapon = sickle_idle;
   self.weaponframe = 0.00000;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      sickle_decide_attack ();

   }
};


void  ()sickle_d =  {
   self.th_weapon = sickle_d;
   self.wfs = advanceweaponframe (88.00000, 104.00000);
   if ( (self.weaponframe == 89.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 92.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 88.00000) ) {

      dprint ("\n SICKLE D");
      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 88.00000) ) {

         FireMelee (SICKLE_DAMAGE, SICKLE_ADD_DAMAGE, 64.00000);
      } else {

         if ( (self.wfs == WF_LAST_FRAME) ) {

            sickle_idle ();

         }

      }

   }
};


void  ()sickle_c =  {
   self.th_weapon = sickle_c;
   self.wfs = advanceweaponframe (51.00000, 87.00000);
   if ( (self.weaponframe == 51.00000) ) {

      dprint ("\n SICKLE C");
      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 52.00000) ) {

         FireMelee (SICKLE_DAMAGE, SICKLE_ADD_DAMAGE, 64.00000);
      } else {

         if ( (self.wfs == WF_LAST_FRAME) ) {

            sickle_idle ();

         }

      }

   }
};


void  ()sickle_b =  {
   self.th_weapon = sickle_b;
   self.wfs = advanceweaponframe (17.00000, 50.00000);
   if ( (self.weaponframe == 19.00000) ) {

      dprint ("\n SICKLE B");
      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 18.00000) ) {

         FireMelee (SICKLE_DAMAGE, SICKLE_ADD_DAMAGE, 64.00000);
      } else {

         if ( (self.wfs == WF_LAST_FRAME) ) {

            sickle_idle ();

         }

      }

   }
};


void  ()sickle_a =  {
   self.th_weapon = sickle_a;
   self.wfs = advanceweaponframe (0.00000, 16.00000);
   if ( (self.weaponframe == 1.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 2.00000) ) {

         FireMelee (SICKLE_DAMAGE, SICKLE_ADD_DAMAGE, 64.00000);
      } else {

         if ( (self.wfs == WF_LAST_FRAME) ) {

            sickle_idle ();

         }

      }

   }
};


void  ()sickle_select =  {
   self.th_weapon = sickle_select;
   self.wfs = advanceweaponframe (0.00000, 16.00000);
   self.weaponmodel = "models/sickle.mdl";
   if ( (self.wfs == WF_CYCLE_STARTED) ) {

      sound (self, CHAN_WEAPON, "weapons/unsheath.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      sickle_idle ();

   }
};


void  ()sickle_deselect =  {
   self.th_weapon = sickle_deselect;
   self.wfs = advanceweaponframe (16.00000, 0.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

float sickle_cnt   =  0.00000;

void  ()sickle_decide_attack =  {
local float r = 0.00000;
   self.think = player_necromancer_sickle_attack;
   if ( (sickle_cnt < 0.25000) ) {

      sickle_a ();
   } else {

      if ( (sickle_cnt < 0.50000) ) {

         sickle_b ();
      } else {

         if ( (sickle_cnt < 0.75000) ) {

            sickle_c ();
         } else {

            sickle_d ();

         }

      }

   }
   sickle_cnt += 0.25000;
   if ( (sickle_cnt > 1.00000) ) {

      sickle_cnt = 0.00000;

   }
   self.attack_finished = (time + 0.50000);
};

