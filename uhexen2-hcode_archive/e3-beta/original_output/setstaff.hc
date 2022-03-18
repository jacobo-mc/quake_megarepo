void  ()player_necromancer_setstaff_attack;
void  ()setstaff_decide_attack;

void  ()set_explode =  {
   if ( (self.enemy.health > 0.00000) ) {

      T_Damage (self.enemy, self, self.owner, 300.00000);
      sound (self, CHAN_WEAPON, "weapons/explode.wav", 1.00000, ATTN_NORM);
      MakeExplosion ();

   }
   remove (self);
};


void  ()shakeit =  {
local float dist = 0.00000;
local float rand = 0.00000;
   self.enemy.angles_y += ((random () * 30.00000) - 10.00000);
   rand = ((random () * 10.00000) - 5.00000);
   if ( (((self.enemy.angles_x + rand) > 10.00000) || ((self.enemy.angles_x + rand) < -10.00000)) ) {

      self.enemy.angles_x -= rand;
   } else {

      self.enemy.angles_x += rand;

   }
   rand = ((random () * 10.00000) - 5.00000);
   if ( (((self.enemy.angles_z + rand) > 10.00000) || ((self.enemy.angles_z + rand) < -10.00000)) ) {

      self.enemy.angles_z -= rand;
   } else {

      self.enemy.angles_z += rand;

   }
   if ( (self.lifetime > time) ) {

      self.think = shakeit;
   } else {

      self.think = set_explode;

   }
   self.nextthink = (time + 0.10000);
};


void  (entity victim,vector m_org)SpawnSetExplode =  {
local entity missile;
   missile = spawn ();
   missile.enemy = victim;
   missile.think = shakeit;
   missile.nextthink = (time + HX_FRAME_TIME);
   missile.origin = m_org;
   missile.scale = victim.scale;
   missile.lifetime = ((time + (random () * 2.00000)) + 1.50000);
   if ( (victim.scale == 0.00000) ) {

      victim.scale = 1.00000;

   }
   missile.enemy.drawflags = ((missile.enemy.drawflags & SCALE_TYPE_MASKOUT) | SCALE_TYPE_UNIFORM);
};


void  (vector dir_mod)launch_superset =  {
local vector dir = '0.00000 0.00000 0.00000';
local vector new_org = '0.00000 0.00000 0.00000';
local entity missile;
local float v_length = 0.00000;
local float max = 0.00000;
local float i = 0.00000;
   self.attack_finished = (time + 0.50000);
   makevectors (self.v_angle);
   traceline ((self.origin + self.proj_ofs), ((self.origin + self.proj_ofs) + (v_forward * 99999.00000)), TRUE, self);
   v_length = vlen (((self.origin + self.proj_ofs) - trace_endpos));
   max = (v_length / 120.00000);
   dprint (ftos (v_length));
   new_org = ((self.origin + self.proj_ofs) + (v_forward * 120.00000));
   while ( (i < max) ) {

      CreateWhiteSmoke ((new_org + '0.00000 0.00000 40.00000'));
      new_org = (new_org + (v_forward * 120.00000));
      i += 1.00000;

   }
   traceline ((self.origin + self.proj_ofs), ((self.origin + self.proj_ofs) + (v_forward * 99999.00000)), FALSE, self);
   while ( trace_ent ) {

      SpawnSetExplode (trace_ent, trace_endpos);
      traceline (trace_ent.origin, (trace_ent.origin + (v_forward * 99999.00000)), FALSE, trace_ent);

   }
};


void  (vector dir_mod)launch_set =  {
local vector dir = '0.00000 0.00000 0.00000';
local entity missile;
   self.attack_finished = (time + 0.50000);
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   makevectors ((self.v_angle + dir_mod));
   missile.velocity = normalize (v_forward);
   missile.velocity = (missile.velocity * 1000.00000);
   missile.angles = vectoangles (missile.velocity);
   missile.touch = T_MissileTouch;
   setmodel (missile, "models/axblade.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (missile, (((self.origin + self.proj_ofs) + (v_forward * 14.00000)) + (v_right * 10.00000)));
   missile.classname = "set_missile";
};


void  ()setstaff_fire =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
   if ( ((self.artifact_active & ART_TOMEOFPOWER) && (self.greenmana > 7.00000)) ) {

      launch_superset ('0.00000 0.00000 0.00000');
      self.greenmana -= 8.00000;
   } else {

      launch_set ('0.00000 -5.00000 0.00000');
      launch_set ('0.00000 5.00000 0.00000');
      launch_set ('0.00000 0.00000 0.00000');
      self.greenmana -= 2.00000;

   }
};


void  ()setstaff_idle =  {
   self.th_weapon = setstaff_idle;
};


void  ()setstaff_c =  {
   self.wfs = advanceweaponframe (20.00000, 33.00000);
   self.th_weapon = setstaff_c;
   dprint (" setstaff b");
   if ( (self.weaponframe == 3.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      setstaff_idle ();

   }
};


void  ()setstaff_b =  {
   self.wfs = advanceweaponframe (20.00000, 33.00000);
   self.th_weapon = setstaff_b;
   dprint (" setstaff b");
   if ( (self.weaponframe == 3.00000) ) {

      sound (self, CHAN_WEAPON, "weapons/gaunt1.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      setstaff_idle ();

   }
};


void  ()setstaff_readyfire =  {
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      if ( ((self.weaponframe >= 2.00000) && (self.weaponframe <= 6.00000)) ) {

         self.weaponframe_cnt += 1.00000;
         if ( (self.weaponframe_cnt > 5.00000) ) {

            self.wfs = advanceweaponframe (2.00000, 14.00000);
            self.weaponframe_cnt = 0.00000;

         }
      } else {

         self.wfs = advanceweaponframe (2.00000, 14.00000);

      }
   } else {

      self.wfs = advanceweaponframe (2.00000, 14.00000);

   }
   self.th_weapon = setstaff_readyfire;
   if ( (self.weaponframe == 9.00000) ) {

      setstaff_fire ();

   }
   if ( (self.wfs == WF_LAST_FRAME) ) {

      setstaff_idle ();

   }
};


void  ()setstaff_select =  {
   self.wfs = advanceweaponframe (15.00000, 19.00000);
   self.weaponmodel = "models/setstaff.mdl";
   self.th_weapon = setstaff_select;
   self.last_attack = time;
   if ( (self.wfs == WF_LAST_FRAME) ) {

      self.attack_finished = (time - 1.00000);
      self.weaponframe = 0.00000;
      setstaff_idle ();

   }
};


void  ()setstaff_deselect =  {
   self.wfs = advanceweaponframe (19.00000, 15.00000);
   self.th_weapon = setstaff_deselect;
   if ( (self.wfs == WF_LAST_FRAME) ) {

      W_SetCurrentAmmo ();

   }
};


void  ()setstaff_decide_attack =  {
local float r = 0.00000;
   self.think = player_necromancer_setstaff_attack;
   setstaff_readyfire ();
   self.attack_finished = (time + 0.50000);
};

