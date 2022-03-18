
void  ()MeteoriteFizzle =  {
   CreateWhiteSmoke (self.origin);
   remove (self);
};


void  ()MeteorThink =  {
   if ( (self.lifetime < time) ) {

      if ( (self.dmg == 10.00000) ) {

         MeteoriteFizzle ();
      } else {

         MultiExplode ();

      }

   }
   if ( (self.dmg > 10.00000) ) {

      CreateWhiteSmoke (self.origin);

   }
   self.think = MeteorThink;
   self.nextthink = (time + 0.30000);
};


void  ()MeteorTouch =  {
   if ( (other.controller == self.owner) ) {

      return ;

   }
   if ( (self.dmg == 10.00000) ) {

      if ( (other == world) ) {

         if ( (!self.pain_finished && (random () < 0.30000)) ) {

            sound (self.controller, CHAN_BODY, "misc/rubble.wav", 1.00000, ATTN_NORM);
            self.pain_finished = TRUE;

         }
         return ;
      } else {

         if ( (other.classname == "meteor") ) {

            return ;

         }

      }
   } else {

      if ( (other == world) ) {

         if ( Skip () ) {

            return ;

         }

      }

   }
   if ( (other.takedamage && other.health) ) {

      T_Damage (other, self, self.owner, self.dmg);

   }
   if ( (self.dmg > 10.00000) ) {

      MultiExplode ();
   } else {

      MeteoriteFizzle ();

   }
};


void  (string type)FireMeteor =  {
local vector org = '0.00000 0.00000 0.00000';
local entity meteor;
   meteor = spawn ();
   setmodel (meteor, "models/tempmetr.mdl");
   if ( (type == "minimeteor") ) {

      meteor.classname = "minimeteor";
      meteor.velocity_x = ((random () * 400.00000) - 200.00000);
      meteor.velocity_y = ((random () * 400.00000) - 200.00000);
      meteor.velocity_z = ((random () * 400.00000) + 200.00000);
      meteor.lifetime = (time + 1.50000);
      meteor.dmg = 10.00000;
      meteor.scale = ((random () * 0.30000) + 0.15000);
      meteor.movetype = MOVETYPE_BOUNCE;
      org = self.origin;
      setsize (meteor, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   } else {

      meteor.hull = HULL_POINT;
      meteor.takedamage = DAMAGE_YES;
      meteor.health = 3.00000;
      meteor.th_die = MultiExplode;
      if ( (self.classname == "player") ) {

         self.velocity += (normalize (v_forward) * -300.00000);
         if ( (self.flags & FL_ONGROUND) ) {

            self.flags -= FL_ONGROUND;

         }

      }
      meteor.classname = "meteor";
      self.punchangle_x = -6.00000;
      sound (self, CHAN_AUTO, "crusader/metfire.wav", 1.00000, ATTN_NORM);
      self.attack_finished = (time + 0.50000);
      self.effects += EF_MUZZLEFLASH;
      makevectors (self.v_angle);
      meteor.speed = 1000.00000;
      meteor.velocity = normalize (v_forward);
      meteor.velocity = (meteor.velocity * meteor.speed);
      meteor.o_angle = (meteor.velocity * meteor.speed);
      meteor.veer = 30.00000;
      meteor.lifetime = (time + 5.00000);
      meteor.dmg = 75.00000;
      meteor.movetype = MOVETYPE_BOUNCEMISSILE;
      org = ((self.origin + self.proj_ofs) + (v_forward * 12.00000));
      setsize (meteor, '-5.00000 -5.00000 -5.00000', '5.00000 5.00000 5.00000');

   }
   meteor.drawflags += MLS_FIREFLICKER;
   meteor.avelocity_x = ((random () * 720.00000) - 360.00000);
   meteor.avelocity_y = ((random () * 720.00000) - 360.00000);
   meteor.avelocity_z = ((random () * 720.00000) - 360.00000);
   if ( (self.classname == "tornato") ) {

      meteor.owner = self.controller;
   } else {

      if ( (self.classname == "meteor") ) {

         meteor.owner = self.owner;
      } else {

         meteor.owner = self;

      }

   }
   meteor.controller = self;
   meteor.solid = SOLID_BBOX;
   meteor.touch = MeteorTouch;
   meteor.think = MeteorThink;
   meteor.nextthink = (time + 0.10000);
   setorigin (meteor, org);
};


void  ()tornato_die =  {
   AdvanceFrame( 24.00000, 47.00000);
   if ( cycle_wrapped ) {

      if ( self.enemy ) {

         self.enemy.avelocity = '0.00000 500.00000 0.00000';
         if ( (self.enemy.flags2 & FL_ALIVE) ) {

            self.enemy.movetype = self.enemy.oldmovetype;

         }

      }
      remove (self.movechain);
      remove (self);

   }
   self.movechain.frame += 1.00000;
   if ( (self.movechain.frame > 24.00000) ) {

      self.movechain.frame = 0.00000;

   }
   if ( (self.movechain.scale > 0.04000) ) {

      self.movechain.scale -= 0.04000;

   }
   if ( (self.movechain.avelocity_y > 0.00000) ) {

      self.movechain.avelocity_y -= 20.00000;

   }
};


void  ()tornato_spin =  {
local float distance = 0.00000;
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local float seekspeed = 0.00000;
local entity sucker;
local float bestdist = 0.00000;
   AdvanceFrame( 0.00000, 23.00000);
   if ( cycle_wrapped ) {

      self.frags += 1.00000;

   }
   if ( (self.frags >= 50.00000) ) {

      self.movechain.drawflags = ((MLS_ABSLIGHT + SCALE_ORIGIN_BOTTOM) + SCALE_TYPE_XYONLY);
      self.think = tornato_die;
      self.nextthink = time;

   }
   self.movechain.frame += 1.00000;
   if ( (self.movechain.frame > 24.00000) ) {

      self.movechain.frame = 0.00000;

   }
   if ( (random () < 0.20000) ) {

      self.velocity_x += (((random () * 200.00000) * self.scale) - (100.00000 * self.scale));
      if ( (fabs (self.velocity_x) > 1000.00000) ) {

         self.velocity_x /= 2.00000;

      }

   }
   if ( (random () < 0.20000) ) {

      self.velocity_y += (((random () * 200.00000) * self.scale) - (100.00000 * self.scale));
      if ( (fabs (self.velocity_y) > 1000.00000) ) {

         self.velocity_y /= 2.00000;

      }

   }
   if ( (pointcontents (self.origin) != CONTENT_EMPTY) ) {

      self.velocity_z += ((random () * 177.00000) + 33.00000);
      particle4 (self.origin, (20.00000 * random ()), (256.00000 + (8.00000 * 15.00000)), PARTICLETYPE_GRAV, (random () * 10.00000));
      particle4 (self.origin, (20.00000 * random ()), ((256.00000 + 150.00000) + (random () * 8.00000)), PARTICLETYPE_GRAV, (random () * 10.00000));
   } else {

      if ( (random () < 0.20000) ) {

         distance = ((random () * 45.00000) - 30.00000);
         if ( ((self.goalentity != world) && (self.enemy != self.goalentity)) ) {

            if ( (self.goalentity.origin_z > self.origin_z) ) {

               distance = ((random () * 60.00000) - 30.00000);

            }

         }
         self.velocity_z += distance;
         if ( (fabs (self.velocity_z) > 333.00000) ) {

            self.velocity_z /= 3.00000;

         }

      }

   }
   if ( (self.enemy != world) ) {

      org = self.origin;
      org_z += (((random () * 10.00000) * self.scale) + (4.00000 * self.scale));
      self.enemy.velocity = '0.00000 0.00000 0.00000';
      setorigin (self.enemy, org);
      if ( ((self.enemy != world) && !(self.enemy.flags2 & FL_ALIVE)) ) {

         if ( ((((random () > 0.20000) || (self.goalentity == world)) || !visible (self.goalentity)) || (self.goalentity.health < 0.00000)) ) {

            self.lifetime = (time + 1.00000);
         } else {

            self.lifetime = -1.00000;
            if ( ((self.goalentity.solid == SOLID_BSP) && (self.goalentity.origin == '0.00000 0.00000 0.00000')) ) {

               dir = normalize ((((self.goalentity.absmax + self.goalentity.absmin) * 0.50000) - self.enemy.origin));
            } else {

               dir = normalize ((self.goalentity.origin - self.enemy.origin));

            }

         }

      }
      if ( ((self.enemy.takedamage && (self.enemy.health > 0.00000)) && (self.lifetime > time)) ) {

         if ( (random () < 0.20000) ) {

            T_Damage (self.enemy, self, self.owner, (3.00000 * self.scale));

         }
      } else {

         self.lifetime = -1.00000;
         if ( -1.00000 ) {

            self.enemy.velocity = ((dir * 350.00000) * self.scale);
         } else {

            self.enemy.velocity_z = ((random () * 200.00000) * self.scale);
            self.enemy.velocity_x = (((random () * 400.00000) * self.scale) - (200.00000 * self.scale));
            self.enemy.velocity_y = (((random () * 400.00000) * self.scale) - (200.00000 * self.scale));

         }
         self.lifetime = time;
         self.enemy.safe_time = (time + 3.00000);
         if ( (self.enemy.flags2 & FL_ALIVE) ) {

            self.enemy.movetype = self.enemy.oldmovetype;
            if ( (self.enemy.classname == "player_sheep") ) {

               sound (self.enemy, CHAN_VOICE, "misc/sheepfly.wav", 1.00000, ATTN_NORM);
               self.enemy.pain_finished = (time + 1.00000);

            }

         }
         self.enemy.avelocity_y = ((random () * 200.00000) * self.scale);
         self.movechain.movechain = world;
         self.enemy = world;

      }
      if ( (self.enemy.classname == "player") ) {

         self.enemy.punchangle_y = ((random () * 9.00000) + 3.00000);
         self.enemy.punchangle_x = ((random () * 3.00000) - 3.00000);
         self.enemy.punchangle_z = ((random () * 3.00000) - 3.00000);

      }
      if ( ((self.enemy != world) && (self.goalentity == self.enemy)) ) {

         self.goalentity = world;

      }

   }
   if ( (random () < 0.30000) ) {

      if ( (((self.goalentity != world) && visible (self.goalentity)) && (self.goalentity.health > 0.00000)) ) {

         seekspeed = ((random () * 177.00000) + 33.00000);
         if ( ((self.goalentity.solid == SOLID_BSP) && (self.goalentity.origin == '0.00000 0.00000 0.00000')) ) {

            distance = vlen ((((self.goalentity.absmax + self.goalentity.absmin) * 0.50000) - self.origin));
         } else {

            distance = vlen ((self.goalentity.origin - self.origin));

         }
         if ( (distance < 256.00000) ) {

            seekspeed += (256.00000 - distance);

         }
         if ( self.goalentity.velocity ) {

            seekspeed += vlen (self.goalentity.velocity);

         }
         self.velocity = (((self.velocity * 3.00000) + ((normalize ((self.goalentity.origin - self.origin)) * seekspeed) * self.scale)) * 0.25000);
      } else {

         self.goalentity = world;
         bestdist = 1001.00000;
         sucker = findradius (self.origin, 1000.00000);
         while ( sucker ) {

            if ( (((((sucker.takedamage && sucker.health) && (sucker != self.enemy)) && (sucker.mass < (500.00000 * self.scale))) && visible (sucker)) && (sucker != self.owner)) ) {

               if ( ((sucker.solid == SOLID_BSP) && (sucker.origin == '0.00000 0.00000 0.00000')) ) {

                  distance = vlen ((((sucker.absmax + sucker.absmin) * 0.50000) - self.origin));
               } else {

                  distance = vlen ((sucker.origin - self.origin));

               }
               if ( (self.goalentity.velocity == '0.00000 0.00000 0.00000') ) {

                  if ( ((sucker.velocity != '0.00000 0.00000 0.00000') && (sucker.flags2 & FL_ALIVE)) ) {

                     bestdist = distance;
                     self.goalentity = sucker;
                  } else {

                     if ( !(self.goalentity.flags2 & FL_ALIVE) ) {

                        if ( (sucker.flags2 & FL_ALIVE) ) {

                           bestdist = distance;
                           self.goalentity = sucker;
                        } else {

                           if ( (distance < bestdist) ) {

                              bestdist = distance;
                              self.goalentity = sucker;

                           }

                        }
                     } else {

                        if ( ((sucker.flags2 & FL_ALIVE) && (distance < bestdist)) ) {

                           bestdist = distance;
                           self.goalentity = sucker;

                        }

                     }

                  }
               } else {

                  if ( (((distance < bestdist) && (sucker.velocity != '0.00000 0.00000 0.00000')) && (sucker.flags2 & FL_ALIVE)) ) {

                     bestdist = distance;
                     self.goalentity = sucker;

                  }

               }

            }
            sucker = sucker.chain;

         }

      }

   }
   if ( (random () < 0.10000) ) {

      if ( (random () < 0.10000) ) {

         self.proj_ofs_z = ((random () * 48.00000) + 6.00000);
         self.v_angle_x = ((random () * 60.00000) - 30.00000);
         self.v_angle_y = ((random () * 720.00000) - 360.00000);
         FireMeteor ("meteor");
      } else {

         FireMeteor ("minimeteor");

      }

   }
   if ( (self.flags & FL_ONGROUND) ) {

      self.velocity_z *= -0.33300;
      self.flags -= FL_ONGROUND;
      dir_z = ((random () * 50.00000) + 20.00000);
      distance = ((random () * 20.00000) + 10.00000);
      SpawnPuff (self.origin, dir, distance, self);
      CreateWhiteSmoke (self.origin);

   }
   if ( self.pain_finished ) {

      sound (self, CHAN_VOICE, "crusader/tornado.wav", 1.00000, ATTN_NORM);
      self.pain_finished = (time + 1.00000);

   }
};

void  ()funnal_touch;

void  ()tornato_merge =  {
   self.scale += 0.02500;
   self.owner.scale += 0.02500;
   self.goalentity.scale -= 0.02400;
   self.goalentity.owner.scale -= 0.02400;
   if ( (self.scale >= self.target_scale) ) {

      self.touch = funnal_touch;
      self.owner.scale = self.target_scale;
      self.scale = self.target_scale;
      self.think = SUB_Null;
      self.nextthink = -1.00000;
      remove (self.goalentity.owner);
      remove (self.goalentity);
   } else {

      self.think = tornato_merge;
      self.nextthink = (time + 0.01000);

   }
};


void  ()funnal_touch =  {
local vector dir = '0.00000 0.00000 0.00000';
   if ( ((((((((other == self.controller) || (other.controller == self.owner)) || (other == world)) || (other == self.owner)) || (other == self.owner)) || (other.classname == "tornato")) || ((other.classname == "funnal") && other.aflag)) || (other.movetype == MOVETYPE_PUSH)) ) {

      return ;

   }
   if ( self.aflag ) {

      self.owner.think = SUB_Remove;
      self.think = SUB_Remove;
      return ;

   }
   if ( ((((other.classname == "funnal") && (other.scale >= 1.00000)) && (self.scale >= 1.00000)) && ((other.scale + self.scale) < 2.50000)) ) {

      tracearea (self.origin, self.origin, (self.mins + other.mins), (self.maxs + other.maxs), TRUE, self);
      if ( (trace_fraction < 1.00000) ) {

         return ;

      }
      self.goalentity = other;
      other.touch = SUB_Null;
      self.touch = SUB_Null;
      if ( (other.controller != self.controller) ) {

         self.controller = self.owner;
         self.owner.controller = self.owner;
         self.owner.owner = self.owner;

      }
      self.drawflags = (MLS_ABSLIGHT + SCALE_ORIGIN_BOTTOM);
      self.owner.drawflags = SCALE_ORIGIN_BOTTOM;
      other.drawflags = ((MLS_ABSLIGHT + SCALE_ORIGIN_BOTTOM) + SCALE_TYPE_XYONLY);
      self.target_scale = (self.scale + other.scale);
      if ( (self.target_scale > 2.50000) ) {

         self.target_scale = 2.50000;

      }
      setsize (self, (self.mins + other.mins), (self.maxs + other.maxs));
      setsize (self.owner, (self.owner.mins + other.owner.mins), (self.owner.maxs + other.owner.maxs));
      tornato_merge ();
   } else {

      if ( ((((other != self.movechain) && other.movetype) && (other.mass < (500.00000 * self.scale))) && (other.classname != "funnal")) ) {

         if ( ((other.health && other.takedamage) && (other.solid != SOLID_BSP)) ) {

            if ( !other.touch ) {

               other.touch = obj_push;

            }
            if ( ((self.movechain == world) && (other.safe_time < time)) ) {

               self.movechain = other;
               other.flags += FL_MOVECHAIN_ANGLE;
               setorigin (other, (self.origin + '0.00000 0.00000 4.00000'));
               other.velocity = '0.00000 0.00000 0.00000';
               if ( (other.flags2 & FL_ALIVE) ) {

                  other.avelocity = '0.00000 0.00000 0.00000';
               } else {

                  other.avelocity_x = (random () * 360.00000);
                  other.avelocity_z = (random () * 360.00000);

               }
               other.oldmovetype = other.movetype;
               other.movetype = MOVETYPE_NONE;
               self.owner.enemy = other;
               self.owner.lifetime = ((time + (random () * 7.00000)) + 3.00000);
               if ( ((other.classname == "player_sheep") && (other.flags2 & FL_ALIVE)) ) {

                  sound (other, CHAN_VOICE, "misc/sheepfly.wav", 1.00000, ATTN_NORM);
                  other.pain_finished = (time + 1.00000);

               }
               return ;

            }

         }
         dir = normalize (self.angles);
         dir_x *= (((random () * 500.00000) + 200.00000) * self.scale);
         other.velocity += dir;
         other.velocity_z = (((random () * 150.00000) + 100.00000) * self.scale);
         if ( (other.flags & FL_ONGROUND) ) {

            other.flags -= FL_ONGROUND;

         }
         if ( other.takedamage ) {

            T_Damage (other, self.owner, self.owner.controller, (3.00000 * self.scale));

         }
         if ( ((other.classname == "player_sheep") && (other.flags2 & FL_ALIVE)) ) {

            sound (other, CHAN_VOICE, "misc/sheepfly.wav", 1.00000, ATTN_NORM);
            other.pain_finished = (time + 1.00000);

         }

      }

   }
};


void  ()tornato_grow =  {
   AdvanceFrame( 48.00000, 72.00000);
   if ( cycle_wrapped ) {

      self.movechain.scale = 1.00000;
      self.think = tornato_spin;
      self.nextthink = time;

   }
   self.movechain.frame += 1.00000;
   if ( (self.movechain.frame > 24.00000) ) {

      self.movechain.frame = 0.00000;

   }
   self.movechain.scale += 0.04000;
};


void  ()FireMeteorTornado =  {
local entity tornato;
local entity funnal;
local vector org = '0.00000 0.00000 0.00000';
   makevectors (self.v_angle);
   org = (self.origin + (normalize (v_forward) * 32.00000));
   org_z = (self.origin_z + 1.00000);
   tornato = spawn ();
   tornato.solid = SOLID_NOT;
   tornato.movetype = MOVETYPE_FLY;
   tornato.controller = self;
   tornato.owner = self;
   tornato.classname = "tornato";
   tornato.enemy = world;
   setmodel (tornato, "models/tornato.mdl");
   setsize (tornato, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 64.00000');
   setorigin (tornato, org);
   tornato.velocity = (normalize (v_forward) * 300.00000);
   tornato.velocity_z = 0.00000;
   tornato.scale = 1.00000;
   if ( (visible (self.enemy) && (self.enemy.flags2 & FL_ALIVE)) ) {

      tornato.goalentity = self.enemy;

   }
   tornato.think = tornato_grow;
   tornato.nextthink = time;
   funnal = spawn ();
   funnal.owner = tornato;
   funnal.solid = SOLID_TRIGGER;
   funnal.classname = "funnal";
   funnal.movetype = MOVETYPE_FLYMISSILE;
   funnal.drawflags += ((MLS_ABSLIGHT + SCALE_ORIGIN_BOTTOM) + SCALE_TYPE_ZONLY);
   funnal.abslight = 0.20000;
   funnal.scale = 0.01000;
   tornato.movechain = funnal;
   funnal.avelocity = '0.00000 100.00000 0.00000';
   funnal.controller = self;
   funnal.touch = funnal_touch;
   funnal.lifetime = (time + 1.70000);
   setmodel (funnal, "models/funnal.mdl");
   setsize (funnal, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 64.00000');
   setorigin (funnal, org);
};

void  ()meteor_ready_loop;
void  ()Cru_Met_Attack;

void  ()meteor_power_fire =  {
   self.wfs = advanceweaponframe (20.00000, 28.00000);
   self.th_weapon = meteor_power_fire;
   if ( ((self.weaponframe == 21.00000) && (self.attack_finished <= time)) ) {

      FireMeteorTornado ();

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.last_attack = time;
      meteor_ready_loop ();

   }
};


void  ()meteor_fire =  {
   self.wfs = advanceweaponframe (20.00000, 28.00000);
   self.th_weapon = meteor_fire;
   if ( ((!self.button0 || (self.attack_finished > time)) && (self.wfs == WF_CYCLE_WRAPPED)) ) {

      self.last_attack = time;
      meteor_ready_loop ();
   } else {

      if ( ((self.weaponframe == 20.00000) && (self.attack_finished <= time)) ) {

         FireMeteor ("meteor");

      }

   }
};


void  ()Cru_Met_Attack =  {
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = self.th_missile;
   } else {

      self.think = player_crusader_crouch_move;

   }
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      self.th_weapon = meteor_power_fire;
   } else {

      self.th_weapon = meteor_fire;

   }
   self.nextthink = time;
};


void  ()meteor_ready_loop =  {
   self.weaponframe = 1.00000;
   self.th_weapon = meteor_ready_loop;
};


void  ()meteor_select =  {
   self.wfs = advanceweaponframe (2.00000, 17.00000);
   self.weaponmodel = "models/meteor.mdl";
   self.th_weapon = meteor_select;
   self.last_attack = time;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Cru_Met_Attack ();
   } else {

      if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

         self.attack_finished = (time - 1.00000);
         meteor_ready_loop ();

      }

   }
};


void  ()meteor_deselect =  {
   self.wfs = advanceweaponframe (17.00000, 2.00000);
   self.th_weapon = meteor_deselect;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

