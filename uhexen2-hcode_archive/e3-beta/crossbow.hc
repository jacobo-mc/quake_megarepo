
void  ()FallAndRemove =  {
   if ( (pointcontents (self.origin) == CONTENT_SOLID) ) {

      self.solid = SOLID_PHASE;

   }
   self.movetype = MOVETYPE_BOUNCE;
   self.velocity_z = ((random () * 20.00000) + 20.00000);
   RandomSpin ('50.00000 50.00000 50.00000');
   self.think = SUB_Remove;
   self.nextthink = (time + self.wait);
};


void  ()CB_BoltStick =  {
   if ( (self.wait <= time) ) {

      if ( (self.classname == "bolt") ) {

         self.wait = 2.00000;
         self.think = FallAndRemove;
      } else {

         self.think = DarkExplosion;

      }
   } else {

      if ( ((self.enemy.health <= 0.00000) && self.health) ) {

         self.health = 0.00000;
         if ( (self.classname == "bolt") ) {

            self.wait = (1.00000 + (random () * 2.00000));
            self.think = FallAndRemove;
         } else {

            if ( (pointcontents (self.origin) == CONTENT_SOLID) ) {

               self.solid = SOLID_PHASE;

            }
            self.movetype = MOVETYPE_BOUNCE;
            self.velocity_z = ((random () * 20.00000) + 20.00000);
            RandomSpin ('50.00000 50.00000 50.00000');

         }
      } else {

         if ( (self.movetype != MOVETYPE_BOUNCE) ) {

            setorigin (self, (self.enemy.origin + self.view_ofs));
            self.angles = (self.o_angle + self.enemy.angles);
            self.think = CB_BoltStick;

         }

      }

   }
   self.nextthink = time;
};


void  ()CB_BoltHit =  {
local vector stickdir = '0.00000 0.00000 0.00000';
local float waterornot = 0.00000;
   if ( ((other == self.owner) || (other.owner == self.owner)) ) {

      return ;

   }
   if ( ((other == world) && (self.classname == "bolt")) ) {

      if ( Skip () ) {

         return ;

      }

   }
   sound (self, CHAN_BODY, "misc/null.wav", 1.00000, ATTN_NORM);
   setsize (self, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   self.takedamage = DAMAGE_NO;
   self.velocity = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_NOCLIP;
   self.solid = SOLID_NOT;
   self.touch = SUB_Null;
   self.health = other.health;
   if ( (other.thingtype == THINGTYPE_FLESH) ) {

      sound (self, CHAN_WEAPON, "assassin/arr2flsh.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (other.thingtype == THINGTYPE_WOOD) ) {

         sound (self, CHAN_WEAPON, "assassin/arr2wood.wav", 1.00000, ATTN_NORM);
      } else {

         sound (self, CHAN_WEAPON, "weapons/met2stn.wav", 1.00000, ATTN_NORM);

      }

   }
   if ( other.takedamage ) {

      if ( (self.classname == "bolt") ) {

         T_Damage (other, self, self.owner, 17.00000);
      } else {

         T_Damage (other, self, self.owner, 3.00000);

      }
      SpawnPuff ((self.origin + (v_forward * 8.00000)), ('0.00000 0.00000 0.00000' - (v_forward * 24.00000)), 10.00000, other);
      if ( (other.solid != SOLID_BSP) ) {

         stickdir = (other.origin + (normalize ((self.origin - other.origin)) * 12.00000));
         if ( (other.classname == "player") ) {

            stickdir_z = ((other.origin_z + other.proj_ofs_z) + 1.00000);
         } else {

            if ( other.spiderType ) {

               stickdir_z = ((self.origin_z + ((other.origin_z + (other.size_z * 0.20000)) * 3.00000)) * 0.25000);
            } else {

               stickdir_z = ((self.origin_z + ((other.origin_z + (other.size_z * 0.60000)) * 3.00000)) * 0.25000);

            }

         }
         setorigin (self, stickdir);
         self.wait = (time + random ());

      }
   } else {

      SpawnPuff ((self.origin + (v_forward * 8.00000)), ('0.00000 0.00000 0.00000' - (v_forward * 24.00000)), 10.00000, world);
      if ( (self.classname == "bolt") ) {

         if ( (random () < 0.70000) ) {

            chunk_death ();
         } else {

            if ( (random () < 0.50000) ) {

               self.movetype = MOVETYPE_BOUNCE;
               self.avelocity_x = ((random () * 720.00000) - 360.00000);
               self.avelocity_y = ((random () * 720.00000) - 360.00000);
               self.avelocity_z = ((random () * 720.00000) - 360.00000);
               self.touch = SUB_Null;
               self.think = SUB_Remove;
               self.nextthink = ((time + (random () * 1.00000)) + 0.50000);
               return ;

            }

         }

      }
      self.wait = ((time + 1.00000) + (random () * 2.00000));

   }
   if ( other.movetype ) {

      waterornot = pointcontents (self.origin);
      if ( (((((self.classname == "flaming arrow") && (waterornot != CONTENT_WATER)) && (waterornot != CONTENT_SLIME)) && other.takedamage) && ((other.thingtype == THINGTYPE_FLESH) || (other.thingtype == THINGTYPE_WOOD))) ) {

         if ( other.onfire ) {

            other.onfire += 0.20000;
         } else {

            SpawnFlameOn (other);

         }

      }
      self.enemy = other;
      self.view_ofs = (self.origin - other.origin);
      self.o_angle = (self.angles - self.enemy.angles);
      self.think = CB_BoltStick;
      self.nextthink = time;
   } else {

      self.movetype = MOVETYPE_NONE;
      if ( (self.classname == "bolt") ) {

         self.think = SUB_Remove;
      } else {

         self.think = DarkExplosion;

      }
      self.nextthink = (time + 2.00000);

   }
};


void  ()ArrowFlyThink =  {
   if ( ((self.lifetime < time) && (self.mins == '0.00000 0.00000 0.00000')) ) {

      self.takedamage = DAMAGE_YES;
      setsize (self, '-3.00000 -3.00000 -2.00000', '3.00000 3.00000 2.00000');

   }
   self.angles = vectoangles (self.velocity);
   self.think = ArrowFlyThink;
   self.nextthink = (time + 0.10000);
};


void  ()ArrowSound =  {
   sound (self, CHAN_BODY, "assassin/arrowfly.wav", 1.00000, ATTN_NORM);
   self.think = ArrowFlyThink;
   self.nextthink = time;
};


void  ()FlamingArrowThink =  {
local float waterornot = 0.00000;
   waterornot = pointcontents (self.origin);
   if ( ((waterornot == CONTENT_WATER) || (waterornot == CONTENT_SLIME)) ) {

      sound (self, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);
      DeathBubbles (1.00000);
      setmodel (self, "models/NFarrow.mdl");

   }
   ArrowSound ();
};


void  ()ArrowThink =  {
local vector dir = '0.00000 0.00000 0.00000';
   dir = normalize (self.velocity);
   traceline (self.origin, (self.origin + (dir * 1000.00000)), FALSE, self);
   if ( !trace_ent.takedamage ) {

      HomeThink ();

   }
   self.angles = vectoangles (self.velocity);
   if ( (self.classname == "bolt") ) {

      self.think = ArrowSound;
   } else {

      self.think = FlamingArrowThink;

   }
   self.nextthink = time;
};


void  (float offset,float powered_up)FireCB_Bolt =  {
local entity missile;
   makevectors (self.v_angle);
   missile = spawn ();
   missile.owner = self;
   missile.solid = SOLID_BBOX;
   missile.hull = HULL_POINT;
   missile.health = 3.00000;
   if ( powered_up ) {

      missile.thingtype = THINGTYPE_METAL;
      missile.movetype = MOVETYPE_FLYMISSILE;
      missile.classname = "flaming arrow";
      setmodel (missile, "models/flaming.mdl");
      missile.dmg = 30.00000;
      missile.drawflags = MLS_FIREFLICKER;
      missile.th_die = MultiExplode;
   } else {

      missile.thingtype = THINGTYPE_WOOD;
      missile.movetype = MOVETYPE_BOUNCEMISSILE;
      missile.classname = "bolt";
      setmodel (missile, "models/arrow.mdl");
      missile.th_die = chunk_death;

   }
   missile.frags = 0.90000;
   missile.touch = CB_BoltHit;
   missile.speed = ((random () * 350.00000) + 650.00000);
   missile.velocity = ((normalize (v_forward) * missile.speed) + (v_right * offset));
   missile.o_angle = ((normalize (v_forward) * missile.speed) + (v_right * offset));
   missile.angles = vectoangles (missile.velocity);
   missile.ideal_yaw = TRUE;
   missile.turn_time = 0.00000;
   missile.veer = 0.00000;
   missile.think = ArrowThink;
   missile.nextthink = time;
   missile.lifetime = (time + 0.50000);
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (missile, ((self.origin + self.proj_ofs) + (v_forward * 8.00000)));
};

void  ()crossbow_fire;

void  ()crossbow_idle =  {
   self.th_weapon = crossbow_idle;
   self.weaponframe = 0.00000;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      crossbow_fire ();

   }
};


void  ()crossbow_fire =  {
   self.wfs = advanceweaponframe (0.00000, 14.00000);
   self.th_weapon = crossbow_fire;
   if ( (self.wfs == WF_CYCLE_STARTED) ) {

      sound (self, CHAN_WEAPON, "raven/gaunt1.wav", 1.00000, ATTN_NORM);
      if ( (self.hull == HULL_NORMAL) ) {

         self.think = player_assassin_attack;
      } else {

         self.think = player_assassin_crouch_attack;

      }
   } else {

      if ( (self.weaponframe == 2.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            sound (self, CHAN_WEAPON, "assassin/firefblt.wav", 1.00000, ATTN_NORM);
            FireCB_Bolt (0.00000, TRUE);
            FireCB_Bolt (-100.00000, TRUE);
            FireCB_Bolt (100.00000, TRUE);
            FireCB_Bolt (-200.00000, TRUE);
            FireCB_Bolt (200.00000, TRUE);
            self.attack_finished = (time + 0.30000);
         } else {

            sound (self, CHAN_WEAPON, "assassin/firebolt.wav", 1.00000, ATTN_NORM);
            FireCB_Bolt (0.00000, FALSE);
            FireCB_Bolt (-100.00000, FALSE);
            FireCB_Bolt (100.00000, FALSE);
            self.attack_finished = (time + 0.50000);

         }
      } else {

         if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

            crossbow_idle ();

         }

      }

   }
};


void  ()crossbow_select =  {
   self.wfs = advanceweaponframe (25.00000, 15.00000);
   self.weaponmodel = "models/crossbow.mdl";
   self.th_weapon = crossbow_select;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      crossbow_idle ();

   }
};


void  ()crossbow_deselect =  {
   self.wfs = advanceweaponframe (15.00000, 25.00000);
   self.th_weapon = crossbow_deselect;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

