
void  ()MakeTestBeam =  {
   makevectors (self.v_angle);
   newmis = spawn ();
   newmis.drawflags = (MLS_ABSLIGHT + DRF_TRANSLUCENT);
   newmis.abslight = 1.00000;
   newmis.frame = 10.00000;
   newmis.skin = 2.00000;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.angles = self.v_angle;
   newmis.avelocity_z = 500.00000;
   setmodel (newmis, "models/lbolt3.mdl");
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 24.00000)));
   newmis = spawn ();
   newmis.drawflags = MLS_ABSLIGHT;
   newmis.abslight = 1.00000;
   newmis.angles = self.v_angle;
   newmis.skin = 1.00000;
   newmis.frame = 0.00000;
   setmodel (newmis, "models/lbolt3.mdl");
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 24.00000)));
};


void  ()FireSunstaff =  {
local vector org = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local vector endspot = '0.00000 0.00000 0.00000';
local vector endplane = '0.00000 0.00000 0.00000';
local float remainder = 0.00000;
local float reflect_count = 0.00000;
   sound (self, CHAN_WEAPON, "crusader/sunhum.wav", 1.00000, ATTN_NORM);
   if ( (self.attack_finished > time) ) {

      return ;

   }
   if ( !(self.effects & EF_BRIGHTLIGHT) ) {

      self.effects += EF_BRIGHTLIGHT;

   }
   self.attack_finished = (time + 0.20000);
   makevectors (self.v_angle);
   remainder = 1000.00000;
   dir = normalize (v_forward);
   org = (self.origin + self.proj_ofs);
   vec = (org + (dir * 1000.00000));
   traceline ((org + (v_forward * 8.00000)), vec, TRUE, self);
   endspot = trace_endpos;
   endplane = trace_plane_normal;
   remainder -= (remainder * trace_fraction);
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_STREAM_SUNSTAFF1);
   WriteByte (MSG_BROADCAST, (reflect_count + STREAM_ATTACHED));
   WriteByte (MSG_BROADCAST, 40.00000);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, org_x);
   WriteCoord (MSG_BROADCAST, org_y);
   WriteCoord (MSG_BROADCAST, org_z);
   WriteCoord (MSG_BROADCAST, trace_endpos_x);
   WriteCoord (MSG_BROADCAST, trace_endpos_y);
   WriteCoord (MSG_BROADCAST, trace_endpos_z);
   LightningDamage (org, trace_endpos, self, 30.00000, "sunbeam");
   while ( ((remainder > 0.00000) && (reflect_count < 3.00000)) ) {

      org = endspot;
      dir += (2.00000 * endplane);
      vec = (org + (normalize (dir) * remainder));
      traceline (org, vec, TRUE, self);
      endspot = trace_endpos;
      endplane = trace_plane_normal;
      remainder -= (remainder * trace_fraction);
      reflect_count += 1.00000;
      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_STREAM_SUNSTAFF1);
      WriteByte (MSG_BROADCAST, (reflect_count + STREAM_ATTACHED));
      WriteByte (MSG_BROADCAST, 40.00000);
      WriteEntity (MSG_BROADCAST, self);
      WriteCoord (MSG_BROADCAST, org_x);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);
      WriteCoord (MSG_BROADCAST, trace_endpos_x);
      WriteCoord (MSG_BROADCAST, trace_endpos_y);
      WriteCoord (MSG_BROADCAST, trace_endpos_z);
      LightningDamage (org, trace_endpos, self, 10.00000, "sunbeam");

   }
};


void  ()FireSunstaffPower =  {
   MakeTestBeam ();
   centerprint (self, "This weapon will kick ass... eventually\n");
};

void  ()sunstaff_ready_loop;
void  ()Cru_Sun_Fire;

void  ()sunstaff_power_fire =  {
   self.wfs = advanceweaponframe (49.00000, 58.00000);
   self.th_weapon = sunstaff_power_fire;
   if ( ((self.attack_finished <= time) && self.button0) ) {

      FireSunstaffPower ();

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( (self.effects & EF_BRIGHTLIGHT) ) {

         self.effects -= EF_BRIGHTLIGHT;

      }
      self.last_attack = time;
      sunstaff_ready_loop ();

   }
};


void  ()sunstaff_fire =  {
   self.wfs = advanceweaponframe (49.00000, 58.00000);
   self.th_weapon = sunstaff_fire;
   if ( ((self.attack_finished <= time) && self.button0) ) {

      FireSunstaff ();

   }
   if ( (!self.button0 && (self.wfs == WF_CYCLE_WRAPPED)) ) {

      if ( (self.effects & EF_BRIGHTLIGHT) ) {

         self.effects -= EF_BRIGHTLIGHT;

      }
      self.last_attack = time;
      sunstaff_ready_loop ();

   }
};


void  ()Cru_Sun_Fire =  {
   if ( ((self.weaponframe < 0.00000) || (self.weaponframe > 28.00000)) ) {

      return ;

   }
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = self.th_missile;
   } else {

      self.think = player_crusader_crouch_move;

   }
   sound (self, CHAN_WEAPON, "crusader/sunstart.wav", 1.00000, ATTN_NORM);
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      self.th_weapon = sunstaff_power_fire;
   } else {

      self.th_weapon = sunstaff_fire;

   }
   self.nextthink = time;
};


void  ()sunstaff_ready_loop =  {
   self.wfs = advanceweaponframe (0.00000, 28.00000);
   self.th_weapon = sunstaff_ready_loop;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Cru_Sun_Fire ();

   }
};


void  ()sunstaff_select =  {
   self.wfs = advanceweaponframe (30.00000, 48.00000);
   self.weaponmodel = "models/sunstaff.mdl";
   self.th_weapon = sunstaff_select;
   self.last_attack = time;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Cru_Sun_Fire ();

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      sunstaff_ready_loop ();

   }
};


void  ()sunstaff_deselect =  {
   self.wfs = advanceweaponframe (48.00000, 30.00000);
   self.th_weapon = sunstaff_deselect;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

