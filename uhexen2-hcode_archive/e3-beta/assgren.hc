
void  (vector spinspeed)RandomSpin =  {
   self.avelocity_x = (((random () * spinspeed_x) * 2.00000) - spinspeed_x);
   self.avelocity_y = (((random () * spinspeed_y) * 2.00000) - spinspeed_y);
   self.avelocity_z = (((random () * spinspeed_z) * 2.00000) - spinspeed_z);
};


void  ()MiniSpread =  {
   if ( (self.aflag && (HomeFindTarget () != world)) ) {

      self.wait = (time + 2.00000);
      self.veer = FALSE;
      self.homerate = 0.25000;
      self.avelocity = '10.00000 200.00000 10.00000';
      self.think = HomeThink;
      self.nextthink = time;
   } else {

      if ( self.aflag ) {

         Veer (50.00000);

      }
      self.think = MultiExplode;
      self.nextthink = (time + 2.00000);

   }
};


void  (float spread,float spin)ThrowMiniGrenade =  {
local entity missile;
   spread = 100.00000;
   self.attack_finished = (time + 0.35000);
   makevectors (self.v_angle);
   sound (self, CHAN_WEAPON, "misc/whoosh.wav", 1.00000, ATTN_NORM);
   missile = spawn ();
   missile.owner = self;
   missile.classname = "minigrenade";
   missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
   missile.hull = HULL_POINT;
   missile.takedamage = DAMAGE_YES;
   missile.health = 3.00000;
   missile.th_die = MultiExplode;
   missile.touch = GrenadeTouch2;
   missile.dmg = 50.00000;
   missile.aflag = spin;
   missile.velocity = ((normalize (v_forward) * 500.00000) + '0.00000 0.00000 200.00000');
   if ( !spin ) {

      missile.avelocity_x = ((random () * 600.00000) - 300.00000);
      missile.avelocity_y = ((random () * 600.00000) - 300.00000);
      missile.avelocity_z = ((random () * 600.00000) - 300.00000);
   } else {

      missile.angles = self.angles;

   }
   setmodel (missile, "models/assgren.mdl");
   missile.scale = 0.77000;
   setsize (missile, '-7.00000 -7.00000 -10.00000', '7.00000 7.00000 10.00000');
   setorigin (missile, (((self.origin + self.proj_ofs) + (v_forward * 8.00000)) + (v_right * 8.00000)));
   missile.think = DarkExplosion;
   missile.nextthink = (time + 2.00000);
};


void  ()SuperGrenadeExplode =  {
local entity missile;
local float attack_counter = 0.00000;
local float number_explosions = 0.00000;
   attack_counter = 0.00000;
   number_explosions = rint (((random () * 3.00000) + 3.00000));
   while ( (attack_counter < number_explosions) ) {

      attack_counter += 1.00000;
      missile = spawn ();
      missile.owner = self.owner;
      missile.classname = "minigrenade";
      if ( (random () < 0.50000) ) {

         missile.movetype = MOVETYPE_BOUNCE;
         missile.velocity_x = ((random () * 400.00000) - 200.00000);
         missile.velocity_y = ((random () * 400.00000) - 200.00000);
         missile.velocity_z = ((random () * 400.00000) + 200.00000);
      } else {

         missile.movetype = MOVETYPE_FLYMISSILE;
         missile.velocity_x = ((random () * 160.00000) - 80.00000);
         missile.velocity_y = ((random () * 160.00000) - 80.00000);
         missile.velocity_z = (random () * 200.00000);

      }
      missile.dmg = (self.dmg * 0.50000);
      missile.solid = SOLID_NOT;
      setmodel (missile, "models/null.spr");
      setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      setorigin (missile, self.origin);
      if ( (missile.dmg < 12.50000) ) {

         missile.flags2 += FL_SMALL;

      }
      if ( (random () < 0.20000) ) {

         missile.think = SuperGrenadeExplode;
      } else {

         missile.think = DarkExplosion;

      }
      missile.nextthink = ((time + (random () * 0.50000)) + 0.10000);

   }
   if ( ((self.classname == "multigrenade") && (random () < 0.30000)) ) {

      MonsterQuake (200.00000);

   }
   MultiExplode ();
};


void  ()ThrowMultiGrenade =  {
local entity missile;
   makevectors (self.v_angle);
   sound (self, CHAN_WEAPON, "misc/whoosh.wav", 1.00000, ATTN_NORM);
   missile = spawn ();
   missile.owner = self;
   missile.classname = "multigrenade";
   missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
   missile.hull = HULL_POINT;
   missile.takedamage = DAMAGE_YES;
   missile.health = 3.00000;
   missile.th_die = MultiExplode;
   missile.touch = GrenadeTouch2;
   missile.dmg = 150.00000;
   missile.velocity = ((normalize (v_forward) * 750.00000) + (v_up * 250.00000));
   missile.avelocity_x = ((random () * 600.00000) - 300.00000);
   missile.avelocity_y = ((random () * 600.00000) - 300.00000);
   missile.avelocity_z = ((random () * 600.00000) - 300.00000);
   setmodel (missile, "models/assgren.mdl");
   missile.scale = 2.00000;
   setsize (missile, '-7.00000 -7.00000 -10.00000', '7.00000 7.00000 10.00000');
   setorigin (missile, (((self.origin + self.proj_ofs) + (v_forward * 8.00000)) + (v_right * 8.00000)));
   missile.think = SuperGrenadeExplode;
   missile.nextthink = (time + 2.00000);
   self.attack_finished = (time + 0.40000);
};

void  ()grenade_select;
void  ()grenade_throw;

void  ()grenade_idle =  {
   self.th_weapon = grenade_idle;
   self.weaponframe = 7.00000;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      grenade_throw ();

   }
};


void  ()grenade_throw =  {
   self.th_weapon = grenade_throw;
   self.wfs = advanceweaponframe (8.00000, 19.00000);
   if ( (self.wfs == WF_CYCLE_STARTED) ) {

      if ( (self.hull == HULL_NORMAL) ) {

         self.think = player_assassin_attack;
      } else {

         self.think = player_assassin_crouch_attack;

      }
   } else {

      if ( (self.weaponframe == 17.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            ThrowMultiGrenade ();
            self.attack_finished = (time + 0.70000);
         } else {

            attck_cnt = (attck_cnt + 1.00000);
            if ( (attck_cnt == 3.00000) ) {

               ThrowMiniGrenade (((random () * 32.00000) - 16.00000), TRUE);
               attck_cnt = 0.00000;
            } else {

               ThrowMiniGrenade (((random () * 32.00000) - 16.00000), FALSE);

            }
            self.attack_finished = (time + 0.30000);

         }
      } else {

         if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

            grenade_select ();

         }

      }

   }
};


void  ()grenade_select =  {
   self.th_weapon = grenade_select;
   self.wfs = advanceweaponframe (1.00000, 6.00000);
   self.weaponmodel = "models/v_assgr.mdl";
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      grenade_idle ();

   }
};


void  ()grenade_deselect =  {
   self.th_weapon = grenade_deselect;
   self.wfs = advanceweaponframe (6.00000, 1.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

