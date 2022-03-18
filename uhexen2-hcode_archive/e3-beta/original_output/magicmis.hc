
void  ()MagicMissileTouch =  {
   if ( ((other.classname == self.classname) && (other.owner == self.owner)) ) {

      return ;

   }
   remove (self.movechain.movechain);
   remove (self.movechain);
   self.level = FALSE;
   if ( other.takedamage ) {

      T_Damage (other, self, self.owner, self.dmg);
      self.dmg *= 0.50000;

   }
   T_RadiusDamage (self, self.owner, self.dmg, self);
   self.effects += EF_BRIGHTLIGHT;
   sound (self, CHAN_AUTO, "weapons/explode.wav", 1.00000, ATTN_NORM);
   BecomeExplosion (CE_SM_EXPLOSION);
};


void  ()TorpedoTrail =  {
   particle4 (self.origin, 7.00000, (160.00000 + (random () * 16.00000)), PARTICLETYPE_EXPLODE2, ((random () * 10.00000) + 10.00000));
};


void  ()StarTwinkle =  {
   if ( !self.owner.level ) {

      remove (self);

   }
   if ( !self.aflag ) {

      self.scale += 0.05000;
      if ( (self.scale >= 2.00000) ) {

         self.aflag = TRUE;

      }
   } else {

      self.scale -= 0.05000;
      if ( (self.scale <= 0.01000) ) {

         self.aflag = FALSE;

      }

   }
   if ( (random () < 0.30000) ) {

      TorpedoTrail ();

   }
   self.think = StarTwinkle;
   self.nextthink = (time + 0.05000);
};


void  (float offset)FireMagicMissile =  {
local entity star1;
local entity star2;
local vector spread = '0.00000 0.00000 0.00000';
   makevectors (self.v_angle);
   if ( !(self.effects & EF_MUZZLEFLASH) ) {

      self.effects += EF_MUZZLEFLASH;

   }
   newmis = spawn ();
   newmis.classname = "magic missile";
   newmis.owner = self;
   newmis.drawflags += MLS_POWERMODE;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.touch = MagicMissileTouch;
   newmis.dmg = ((random () * 3.00000) + 7.00000);
   newmis.speed = 1000.00000;
   spread = (normalize (v_right) * (offset * 25.00000));
   newmis.velocity = ((normalize (v_forward) * newmis.speed) + spread);
   newmis.avelocity_z = ((random () * 300.00000) + 300.00000);
   newmis.level = TRUE;
   setmodel (newmis, "models/ball.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, ((((self.origin + self.proj_ofs) + (v_forward * 8.00000)) + (v_right * 7.00000)) + '0.00000 0.00000 7.00000'));
   sound (newmis, CHAN_AUTO, "necro/mmfire.wav", 1.00000, ATTN_NORM);
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      newmis.effects = EF_DIMLIGHT;
      newmis.dmg = ((random () * 10.00000) + 25.00000);
      newmis.veer = 100.00000;
      newmis.homerate = 0.10000;
      newmis.turn_time = 3.00000;
      newmis.lifetime = (time + 5.00000);
      newmis.th_die = MagicMissileTouch;
      newmis.think = HomeThink;
      newmis.nextthink = (time + 0.20000);

   }
   star1 = spawn ();
   newmis.movechain = star1;
   star1.drawflags += MLS_ABSLIGHT;
   star1.abslight = 0.50000;
   star1.avelocity_z = 400.00000;
   star1.avelocity_y = 300.00000;
   star1.angles_y = 90.00000;
   star1.scale = 0.30000;
   setmodel (star1, "models/star.mdl");
   setorigin (star1, newmis.origin);
   star2 = spawn ();
   star1.movechain = star2;
   star2.drawflags += MLS_ABSLIGHT;
   star2.abslight = 0.50000;
   star2.avelocity_z = -400.00000;
   star2.avelocity_y = -300.00000;
   star2.scale = 0.30000;
   setmodel (star2, "models/star.mdl");
   setorigin (star2, newmis.origin);
   star2.movetype = MOVETYPE_NOCLIP;
   star1.movetype = MOVETYPE_NOCLIP;
   star2.owner = newmis;
   star1.owner = newmis;
   star2.think = StarTwinkle;
   star1.think = StarTwinkle;
   star2.nextthink = time;
   star1.nextthink = time;
};


void  ()flash_think =  {
   makevectors (self.owner.v_angle);
   self.angles_x = (self.owner.v_angle_x * -1.00000);
   self.angles_y = self.owner.v_angle_y;
   setorigin (self, ((((self.owner.origin + self.owner.proj_ofs) + '0.00000 0.00000 4.00000') + (v_right * 1.00000)) + (v_forward * 7.00000)));
   self.scale += 0.02500;
   self.nextthink = (time + 0.05000);
   if ( (self.scale >= 0.20000) ) {

      remove (self);

   }
};


void  ()FireFlash =  {
   makevectors (self.v_angle);
   newmis = spawn ();
   newmis.movetype = MOVETYPE_NOCLIP;
   newmis.owner = self;
   newmis.abslight = 0.75000;
   newmis.drawflags = (DRF_TRANSLUCENT + MLS_ABSLIGHT);
   newmis.scale = 0.01000;
   setmodel (newmis, "models/flash.mdl");
   setorigin (newmis, ((((self.origin + self.proj_ofs) + '0.00000 0.00000 4.00000') + (v_right * 1.00000)) + (v_forward * 7.00000)));
   newmis.angles = self.v_angle;
   newmis.angles_x = (self.v_angle_x * -1.00000);
   if ( (random () < 0.50000) ) {

      newmis.avelocity_z = ((random () * 200.00000) + 200.00000);
   } else {

      newmis.avelocity_z = ((random () * -200.00000) - 200.00000);

   }
   newmis.think = flash_think;
   newmis.nextthink = time;
};


void  ()mmis_power =  {
   if ( (self.attack_finished > time) ) {

      return ;

   }
   FireMagicMissile (-3.00000);
   FireMagicMissile (0.00000);
   FireMagicMissile (3.00000);
   self.attack_finished = (time + 0.70000);
};


void  ()mmis_normal =  {
   if ( (self.attack_finished > time) ) {

      return ;

   }
   FireMagicMissile (0.00000);
   self.attack_finished = (time + 0.20000);
};

void  ()magicmis_ready_loop;
void  ()Nec_Mis_Attack;
void  ()player_necromancer_spell_attack;
void  ()player_necromancer_crouch_move;

void  ()magicmis_ready_fire =  {
   if ( ((self.button0 && (self.weaponframe == 2.00000)) && !(self.artifact_active & ART_TOMEOFPOWER)) ) {

      self.weaponframe = 2.00000;
   } else {

      self.wfs = advanceweaponframe (0.00000, 9.00000);

   }
   self.th_weapon = magicmis_ready_fire;
   self.last_attack = time;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      magicmis_ready_loop ();
   } else {

      if ( (self.weaponframe == 2.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            mmis_power ();
         } else {

            mmis_normal ();

         }

      }

   }
};


void  ()magicmis_relax_fire =  {
   if ( ((self.button0 && (self.weaponframe == 14.00000)) && !(self.artifact_active & ART_TOMEOFPOWER)) ) {

      self.weaponframe = 14.00000;
   } else {

      self.wfs = advanceweaponframe (10.00000, 17.00000);

   }
   self.th_weapon = magicmis_relax_fire;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      magicmis_ready_loop ();
   } else {

      if ( (self.weaponframe == 14.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            mmis_power ();
         } else {

            mmis_normal ();

         }

      }

   }
};


void  ()Nec_Mis_Attack =  {
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_necromancer_spell_attack;
   } else {

      self.think = player_necromancer_crouch_move;

   }
   if ( (self.weaponframe == 20.00000) ) {

      magicmis_relax_fire ();
   } else {

      magicmis_ready_fire ();

   }
   self.nextthink = time;
};


void  ()magicmis_relax_loop =  {
   self.weaponframe = 20.00000;
   self.th_weapon = magicmis_relax_loop;
};


void  ()magicmis_ready_to_relax =  {
   self.wfs = advanceweaponframe (66.00000, 74.00000);
   self.th_weapon = magicmis_ready_to_relax;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      magicmis_relax_loop ();

   }
};


void  ()magicmis_ready_loop =  {
   if ( ((self.last_attack + 4.00000) > time) ) {

      self.weaponframe = 19.00000;

   }
   self.th_weapon = magicmis_ready_loop;
   if ( (self.last_attack < (time - 30.00000)) ) {

      magicmis_ready_to_relax ();

   }
};


void  ()magicmis_select =  {
   self.wfs = advanceweaponframe (21.00000, 41.00000);
   self.weaponmodel = "models/magicmis.mdl";
   self.th_weapon = magicmis_select;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      magicmis_relax_loop ();

   }
};


void  ()magicmis_deselect =  {
   self.wfs = advanceweaponframe (41.00000, 21.00000);
   self.th_weapon = magicmis_deselect;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};


void  ()magicmis_select_from_bone_ready =  {
   self.wfs = advanceweaponframe (42.00000, 55.00000);
   self.weaponmodel = "models/magicmis.mdl";
   self.th_weapon = magicmis_select_from_bone_ready;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      magicmis_relax_loop ();

   }
};


void  ()magicmis_select_from_bone_relax =  {
   self.wfs = advanceweaponframe (56.00000, 65.00000);
   self.weaponmodel = "models/magicmis.mdl";
   self.th_weapon = magicmis_select_from_bone_relax;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      magicmis_relax_loop ();

   }
};

