void  ()CB_BoltStick;
void  (float offset)W_FireFlame;
void  (string type)FireMeteor;

void  ()BlowUp =  {
   if ( (self.dmg < 2.50000) ) {

      self.v_angle_x = (random () * 360.00000);
      self.v_angle_y = (random () * 360.00000);
      self.v_angle_z = (random () * 360.00000);
      self.scale = self.dmg;
      T_RadiusDamage (self, self.owner, (self.dmg * 100.00000), world);
      self.dmg += 0.10000;
      self.think = BlowUp;
      self.nextthink = (time + 0.05000);
   } else {

      self.think = SUB_Remove;
      self.nextthink = time;

   }
};


void  ()SprayFire =  {
local entity fireballblast;
   sound (self, CHAN_AUTO, "weapons/fbfire.wav", 1.00000, ATTN_NORM);
   fireballblast = spawn ();
   fireballblast.movetype = MOVETYPE_NOCLIP;
   fireballblast.owner = self.owner;
   fireballblast.classname = "fireballblast";
   fireballblast.solid = SOLID_NOT;
   fireballblast.drawflags += ((MLS_ABSLIGHT + SCALE_TYPE_UNIFORM) + SCALE_ORIGIN_CENTER);
   fireballblast.abslight = 1.00000;
   fireballblast.scale = 0.10000;
   setmodel (fireballblast, "models/blast.mdl");
   setsize (fireballblast, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (fireballblast, self.origin);
   fireballblast.effects = EF_BRIGHTLIGHT;
   fireballblast.dmg = 0.10000;
   fireballblast.avelocity = '50.00000 50.00000 50.00000';
   fireballblast.think = BlowUp;
   fireballblast.nextthink = time;
   remove (self);
};


void  ()SmallExplosion =  {
   sound (self, CHAN_AUTO, "weapons/explode.wav", 0.50000, ATTN_NORM);
   BecomeExplosion (CE_SM_EXPLOSION);
};


void  ()DarkExplosion =  {
   sound (self, CHAN_AUTO, "weapons/explode.wav", 1.00000, ATTN_NORM);
   T_RadiusDamage (self, self.owner, self.dmg, world);
   BecomeExplosion (FALSE);
};


void  ()MultiExplode =  {
local float nummeteorites = 0.00000;
   if ( (self.classname == "stickmine") ) {

      SprayFire ();

   }
   T_RadiusDamage (self, self.owner, self.dmg, world);
   if ( (self.classname == "meteor") ) {

      nummeteorites = ((random () * 7.00000) + 3.00000);
      while ( (nummeteorites > 0.00000) ) {

         FireMeteor ("minimeteor");
         nummeteorites = (nummeteorites - 1.00000);

      }

   }
   if ( (self.flags2 & FL_SMALL) ) {

      SmallExplosion ();
   } else {

      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_EXPLOSION);
      WriteCoord (MSG_BROADCAST, self.origin_x);
      WriteCoord (MSG_BROADCAST, self.origin_y);
      WriteCoord (MSG_BROADCAST, self.origin_z);
      BecomeExplosion (FALSE);

   }
};

void  ()SuperGrenadeExplode;

void  ()GrenadeTouch2 =  {
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (((other.owner == self.owner) && (other.classname == self.classname)) && (self.classname == "minigrenade")) ) {

      return ;

   }
   if ( (other.takedamage == DAMAGE_YES) ) {

      if ( (self.classname == "multigrenade") ) {

         self.think = SuperGrenadeExplode;
      } else {

         if ( ((self.classname == "minigrenade") || (self.classname == "flaming arrow")) ) {

            self.think = DarkExplosion;
         } else {

            self.think = MultiExplode;

         }

      }
      self.nextthink = time;
   } else {

      sound (self, CHAN_WEAPON, "assassin/gbounce.wav", 1.00000, ATTN_NORM);
      if ( (self.velocity == '0.00000 0.00000 0.00000') ) {

         self.avelocity = '0.00000 0.00000 0.00000';

      }

   }
};


void  ()StickMineTouch =  {
local vector stickdir = '0.00000 0.00000 0.00000';
   if ( (other == self.owner) ) {

      return ;

   }
   sound (self, CHAN_WEAPON, "idweapons/pkup.wav", 1.00000, ATTN_NORM);
   if ( other.takedamage ) {

      T_Damage (other, self, self.owner, 3.00000);
      if ( (other.solid != SOLID_BSP) ) {

         stickdir = (other.origin + (normalize ((self.origin - other.origin)) * 12.00000));
         if ( (other.classname == "player") ) {

            stickdir_z = ((other.origin_z + other.proj_ofs_z) + 1.00000);
         } else {

            if ( (other.classname == "monster_spider") ) {

               stickdir_z = ((self.origin_z + ((other.origin_z + (other.size_z * 0.20000)) * 3.00000)) * 0.25000);
            } else {

               stickdir_z = ((self.origin_z + ((other.origin_z + (other.size_z * 0.60000)) * 3.00000)) * 0.25000);

            }

         }
         setorigin (self, stickdir);
         SpawnPuff ((self.origin + (v_forward * 8.00000)), ('0.00000 0.00000 0.00000' - (v_forward * 24.00000)), 10.00000, other);

      }
   } else {

      SpawnPuff ((self.origin + (v_forward * 8.00000)), ('0.00000 0.00000 0.00000' - (v_forward * 24.00000)), 10.00000, world);

   }
   self.velocity = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_NOCLIP;
   self.solid = SOLID_NOT;
   self.touch = SUB_Null;
   self.wait = (time + 2.00000);
   self.health = other.health;
   if ( other.movetype ) {

      self.enemy = other;
      self.view_ofs = (self.origin - other.origin);
      self.o_angle = (self.angles - self.enemy.angles);
      self.think = CB_BoltStick;
      self.nextthink = time;
   } else {

      self.movetype = MOVETYPE_NONE;
      self.think = MultiExplode;
      self.nextthink = (time + 2.00000);

   }
};


void  ()Use_StickMine =  {
local entity missile;
   self.attack_finished = (time + 0.20000);
   makevectors (self.v_angle);
   missile = spawn ();
   missile.owner = self;
   missile.classname = "stickmine";
   missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
   missile.touch = StickMineTouch;
   missile.dmg = 50.00000;
   missile.velocity = ((normalize (v_forward) * 700.00000) + (v_up * 200.00000));
   missile.avelocity_x = ((random () * 600.00000) - 300.00000);
   missile.avelocity_y = ((random () * 600.00000) - 300.00000);
   missile.avelocity_z = ((random () * 600.00000) - 300.00000);
   setmodel (missile, "models/stikgren.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (missile, ((self.origin + self.proj_ofs) + (v_forward * 16.00000)));
   missile.think = MultiExplode;
   missile.nextthink = (time + 10.00000);
};


void  ()ParticleTester =  {
};

