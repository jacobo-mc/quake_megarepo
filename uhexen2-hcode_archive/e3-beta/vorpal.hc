float VORP_BASE_DAMAGE   =  15.00000;
float VORP_ADD_DAMAGE   =  15.00000;
float VORP_PWR_BASE_DAMAGE   =  50.00000;
float VORP_PWR_ADD_DAMAGE   =  30.00000;
float VORP_RADIUS   =  150.00000;
float VORP_PUSH   =  5.00000;

void  ()missile_gone =  {
   sound (self, CHAN_VOICE, "misc/null.wav", 1.00000, ATTN_NORM);
   sound (self, CHAN_WEAPON, "misc/null.wav", 1.00000, ATTN_NORM);
   remove (self);
};


void  ()vshock_end =  {
   if ( (self.skin == 0.00000) ) {

      self.skin = 1.00000;
   } else {

      self.skin = 0.00000;

   }
   self.scale -= 0.25000;
   if ( (self.scale <= 0.00000) ) {

      remove (self);

   }
   self.think = vshock_end;
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()vshock_run =  {
local float damg = 0.00000;
   if ( (self.skin == 0.00000) ) {

      self.skin = 1.00000;
   } else {

      self.skin = 0.00000;

   }
   if ( self.enemy.health ) {

      if ( (self.classname == "vorpalhalfshock") ) {

         damg = 2.50000;
      } else {

         damg = 5.00000;

      }
      T_Damage (self.enemy, self, self.owner, damg);

   }
   self.think = vshock_run;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.lifetime < time) ) {

      vshock_end ();

   }
};


void  (entity victim)vorp_shock =  {
local entity newent;
local vector org = '0.00000 0.00000 0.00000';
   newent = spawn ();
   newent.owner = self;
   newent.movetype = MOVETYPE_NONE;
   newent.solid = SOLID_NOT;
   newent.enemy = victim;
   if ( (self.classname == "halfvorpmissile") ) {

      newent.classname = "vorpalhalfshock";
   } else {

      newent.classname = "vorpalshock";

   }
   newent.drawflags = MLS_ABSLIGHT;
   newent.abslight = 0.50000;
   org = (self.origin - (8.00000 * normalize (self.velocity)));
   setorigin (newent, self.origin);
   setmodel (newent, "models/vorpshok.mdl");
   setsize (newent, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   newent.think = vshock_run;
   newent.nextthink = (time + HX_FRAME_TIME);
   newent.lifetime = (time + 0.50000);
   newent.scale = 1.00000;
};


void  ()vorpmissile_touch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      missile_gone ();
      return ;

   }
   damg = (10.00000 + (random () * 10.00000));
   if ( (self.classname == "halfvorpmissile") ) {

      damg = (damg * 0.50000);

   }
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   sound (self, CHAN_WEAPON, "weapons/explode.wav", 1.00000, ATTN_NORM);
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   setorigin (self, self.origin);
   vorp_shock (other);
   missile_gone ();
};


void  ()vorpmissile_run =  {
   AdvanceFrame( 16.00000, 29.00000);
   if ( (self.skin == 0.00000) ) {

      self.skin = 1.00000;
   } else {

      if ( (self.skin == 1.00000) ) {

         self.skin = 0.00000;

      }

   }
   if ( (self.scale < 2.40000) ) {

      self.scale += 0.20000;

   }
   if ( (self.scale > 2.40000) ) {

      self.scale = 2.40000;

   }
};


void  ()vorpmissile_birth =  {
   AdvanceFrame( 0.00000, 15.00000);
   if ( (self.skin == 0.00000) ) {

      self.skin = 1.00000;
   } else {

      if ( (self.skin == 1.00000) ) {

         self.skin = 0.00000;

      }

   }
   self.frame += 2.00000;
   if ( (self.scale < 2.40000) ) {

      self.scale += 0.15000;

   }
   if ( (self.scale > 2.40000) ) {

      self.scale = 2.40000;

   }
   if ( (self.frame >= 14.00000) ) {

      vorpmissile_run ();

   }
};


void  ()launch_vorpal_missile =  {
local vector dir = '0.00000 0.00000 0.00000';
local entity missile;
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.classname = "vorpalmissile";
   makevectors (self.v_angle);
   missile.velocity = aim (self, (((self.origin + (v_forward * 10.00000)) + (v_right * 1.00000)) + (v_up * 40.00000)), 1000.00000);
   missile.velocity = (missile.velocity * 1000.00000);
   missile.touch = vorpmissile_touch;
   missile.angles = vectoangles (missile.velocity);
   missile.angles_x += 180.00000;
   missile.drawflags = MLS_ABSLIGHT;
   missile.abslight = 0.50000;
   setmodel (missile, "models/vorpshot.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (missile, (self.origin + (v_up * 40.00000)));
   missile.scale = 0.50000;
   if ( (self.bluemana < 4.00000) ) {

      missile.classname = "halfvorpmissile";

   }
   missile.nextthink = (time + HX_FRAME_TIME);
   missile.think = vorpmissile_birth;
   missile.lifetime = (time + 2.00000);
};


void  ()vorpal_melee =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local float damg = 0.00000;
local float no_flash = 0.00000;
local float inertia = 0.00000;
   makevectors (self.v_angle);
   source = (self.origin + self.proj_ofs);
   traceline (source, (source + (v_forward * 64.00000)), FALSE, self);
   self.enemy = world;
   if ( (trace_fraction == 1.00000) ) {

      traceline (source, ((source + (v_forward * 64.00000)) - (v_up * 30.00000)), FALSE, self);
      if ( (trace_fraction == 1.00000) ) {

         traceline (source, ((source + (v_forward * 64.00000)) + (v_up * 30.00000)), FALSE, self);
         if ( (trace_fraction == 1.00000) ) {

            return ;

         }

      }

   }
   org = (trace_endpos + (v_forward * 2.00000));
   if ( trace_ent.takedamage ) {

      SpawnPuff (org, '0.00000 0.00000 0.00000', 20.00000, trace_ent);
      self.enemy = trace_ent;
      if ( !trace_ent.mass ) {

         inertia = 1.00000;
      } else {

         if ( (trace_ent.mass <= 5.00000) ) {

            inertia = trace_ent.mass;
         } else {

            inertia = (trace_ent.mass / 10.00000);

         }

      }
      no_flash = 0.00000;
      if ( ((self.bluemana >= 4.00000) && (self.artifact_active & ART_TOMEOFPOWER)) ) {

         damg = (VORP_BASE_DAMAGE + (random () * VORP_ADD_DAMAGE));
         damg += (damg * 0.25000);
      } else {

         if ( (self.bluemana >= 2.00000) ) {

            damg = (VORP_BASE_DAMAGE + (random () * VORP_ADD_DAMAGE));
            self.bluemana -= 2.00000;
         } else {

            no_flash = 1.00000;
            damg = ((VORP_BASE_DAMAGE + (random () * VORP_ADD_DAMAGE)) * 0.50000);

         }

      }
      org = (trace_endpos + (v_forward * -1.00000));
      if ( !no_flash ) {

         CreateLittleWhiteFlash (org);

      }
      sound (self, CHAN_WEAPON, "weapons/vorpht1.wav", 1.00000, ATTN_NORM);
      dir = (trace_ent.origin - self.origin);
      trace_ent.velocity = ((dir * VORP_PUSH) * (1.00000 / inertia));
      if ( (trace_ent.flags & FL_ONGROUND) ) {

         trace_ent.flags = (trace_ent.flags - FL_ONGROUND);

      }
      trace_ent.velocity_z = (80.00000 / inertia);
      T_Damage (trace_ent, self, self, damg);
   } else {

      sound (self, CHAN_WEAPON, "weapons/vorpht2.wav", 1.00000, ATTN_NORM);
      org = (trace_endpos + (v_forward * -1.00000));
      org += '0.00000 0.00000 10.00000';
      CreateSlowWhiteSmoke (org);

   }
};


void  ()vorpal_downmissile =  {
local vector source = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local entity victim;
local float chance = 0.00000;
local entity hold;
   if ( !(self.artifact_active & ART_TOMEOFPOWER) ) {

      return ;

   }
   victim = findradius (self.origin, 150.00000);
   while ( victim ) {

      if ( ((victim.movetype == MOVETYPE_FLYMISSILE) && (victim.owner != self)) ) {

         victim.owner = self;
         chance = random ();
         dir = (victim.origin + (v_forward * -1.00000));
         CreateLittleWhiteFlash (dir);
         sound (self, CHAN_WEAPON, "weapons/vorpturn.wav", 1.00000, ATTN_NORM);
         if ( (chance < 0.90000) ) {

            victim.v_angle = self.v_angle;
            victim.v_angle_x = (victim.v_angle_x + (crandom () * 180.00000));
            victim.v_angle_y = (victim.v_angle_y + (crandom () * 180.00000));
            victim.v_angle_z = (victim.v_angle_z + (crandom () * 180.00000));
            makevectors (victim.v_angle);
            victim.velocity = normalize (v_forward);
            victim.velocity = (victim.velocity * 1000.00000);
         } else {

            victim.velocity = (victim.velocity * -1.00000);

         }

      }
      victim = victim.chain;

   }
};


void  ()vorpal_normal_fire =  {
local vector source = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local entity victim;
local float v_length = 0.00000;
local float push = 0.00000;
local float percent = 0.00000;
local float points = 0.00000;
local float damage_flg = 0.00000;
local float damg = 0.00000;
   vorpal_melee ();
   if ( (self.bluemana < 4.00000) ) {

      return ;

   }
   damage_flg = 0.00000;
   victim = findradius (self.origin, 100.00000);
   while ( victim ) {

      if ( ((victim.health && (victim != self)) && (victim != self.enemy)) ) {

         traceline ((self.origin + self.owner.view_ofs), victim.origin, FALSE, self);
         if ( (trace_ent == victim) ) {

            damage_flg = 1.00000;
            sound (self, CHAN_WEAPON, "weapons/vorpblst.wav", 1.00000, ATTN_NORM);
            CreateWhiteSmoke ((victim.origin + '0.00000 0.00000 30.00000'));
            points = (VORP_BASE_DAMAGE + (random () * VORP_ADD_DAMAGE));
            T_Damage (victim, self, self, points);

         }

      }
      victim = victim.chain;

   }
   if ( damage_flg ) {

      self.bluemana -= 2.00000;

   }
};


void  ()vorpal_tome_fire =  {
   vorpal_melee ();
   launch_vorpal_missile ();
   if ( (self.bluemana >= 4.00000) ) {

      self.bluemana -= 4.00000;

   }
};


void  ()vorpal_fire =  {
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      vorpal_tome_fire ();
   } else {

      vorpal_normal_fire ();

   }
};


void  ()vorpal_ready =  {
   self.weaponframe = 0.00000;
   self.th_weapon = vorpal_ready;
};


void  ()vorpal_twitch =  {
   self.wfs = advanceweaponframe (1.00000, 22.00000);
   self.th_weapon = vorpal_twitch;
   if ( (self.weaponframe == 8.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 13.00000) ) {

         sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);

      }

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      vorpal_ready ();

   }
};


void  ()vorpal_d =  {
   self.wfs = advanceweaponframe (62.00000, 85.00000);
   self.th_weapon = vorpal_d;
   if ( (self.weaponframe == 66.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 67.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 68.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 69.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 70.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 76.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 77.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 78.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 79.00000) ) {

      self.weaponframe += 1.00000;

   }
   if ( (self.weaponframe == 71.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 75.00000) ) {

         vorpal_fire ();

      }

   }
   if ( (self.weaponframe >= 75.00000) ) {

      vorpal_downmissile ();

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.th_weapon = vorpal_ready;

   }
};


void  ()vorpal_c =  {
   self.wfs = advanceweaponframe (51.00000, 61.00000);
   self.th_weapon = vorpal_c;
   if ( (self.weaponframe == 52.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 55.00000) ) {

         vorpal_fire ();

      }

   }
   if ( (self.weaponframe >= 55.00000) ) {

      vorpal_downmissile ();

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.th_weapon = vorpal_ready;

   }
};


void  ()vorpal_b =  {
   self.wfs = advanceweaponframe (36.00000, 50.00000);
   self.th_weapon = vorpal_b;
   if ( (self.weaponframe == 41.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.weaponframe == 44.00000) ) {

         vorpal_fire ();

      }

   }
   if ( (self.weaponframe >= 44.00000) ) {

      vorpal_downmissile ();

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.th_weapon = vorpal_ready;

   }
};


void  ()moveswipe =  {
local vector org = '0.00000 0.00000 0.00000';
   AdvanceFrame( 0.00000, 6.00000);
   makevectors (self.owner.v_angle);
   org = ((self.owner.origin + self.owner.view_ofs) - '0.00000 0.00000 25.00000');
   setorigin (self, org);
   self.angles = self.owner.v_angle;
   self.angles_y += 180.00000;
   self.think = moveswipe;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.frame > 5.00000) ) {

      self.think = SUB_Remove;

   }
};


void  ()SpawnSwipe =  {
local entity swipe;
local vector org = '0.00000 0.00000 0.00000';
   swipe = spawn ();
   swipe.angles = self.v_angle;
   swipe.angles_y += 180.00000;
   makevectors (self.v_angle);
   org = ((self.origin + self.view_ofs) - '0.00000 0.00000 25.00000');
   setorigin (swipe, org);
   swipe.counter = 0.00000;
   swipe.owner = self;
   swipe.movetype = MOVETYPE_NONE;
   swipe.velocity = '0.00000 0.00000 0.00000';
   swipe.touch = SUB_Null;
   setmodel (swipe, "models/vorpswip.mdl");
   swipe.solid = SOLID_NOT;
   swipe.takedamage = DAMAGE_NO;
   swipe.drawflags = (swipe.drawflags | DRF_TRANSLUCENT);
   swipe.think = moveswipe;
   swipe.nextthink = (time + HX_FRAME_TIME);
};


void  ()vorpal_a =  {
   self.wfs = advanceweaponframe (23.00000, 35.00000);
   self.th_weapon = vorpal_a;
   if ( (self.weaponframe == 25.00000) ) {

      if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

         sound (self, CHAN_WEAPON, "weapons/vorppwr.wav", 1.00000, ATTN_NORM);
      } else {

         sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);

      }
   } else {

      if ( (self.weaponframe == 28.00000) ) {

         vorpal_fire ();

      }

   }
   if ( (self.weaponframe == 25.00000) ) {

      SpawnSwipe ();

   }
   if ( (self.weaponframe >= 28.00000) ) {

      vorpal_downmissile ();

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.th_weapon = vorpal_ready;

   }
};


void  ()vorpal_select =  {
   self.wfs = advanceweaponframe (5.00000, 1.00000);
   self.weaponmodel = "models/vorpal.mdl";
   self.th_weapon = vorpal_select;
   self.last_attack = time;
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.attack_finished = (time - 1.00000);
      vorpal_twitch ();

   }
};


void  ()vorpal_deselect =  {
   self.wfs = advanceweaponframe (74.00000, 78.00000);
   self.th_weapon = vorpal_deselect;
   self.oldweapon = IT_WEAPON2;
   if ( (self.wfs == WF_LAST_FRAME) ) {

      W_SetCurrentAmmo ();

   }
};


void  ()pal_vorpal_fire =  {
   self.think = player_paladin_attack;
   if ( !(self.artifact_active & ART_TOMEOFPOWER) ) {

      vorpal_a ();
   } else {

      vorpal_a ();

   }
   self.attack_finished = (time + 0.70000);
};

