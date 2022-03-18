float SPAWNFLAG_BALLISTA_TRACK   =  1.00000;
void  ()Missile_Arc;
void  (float vol)sheep_sound;
void  ()obj_barrel_roll;
void  ()float;
void  ()sheep_trot;

void  (entity loser)obj_fly_hurt =  {
local float magnitude = 0.00000;
local float my_mass = 0.00000;
local vector dir1 = '0.00000 0.00000 0.00000';
local vector dir2 = '0.00000 0.00000 0.00000';
local float force = 0.00000;
local float dot = 0.00000;
   if ( (self.classname == "player") ) {

      my_mass = self.mass;
   } else {

      if ( !self.mass ) {

         my_mass = 1.00000;
      } else {

         if ( (self.mass <= 10.00000) ) {

            my_mass = 10.00000;
         } else {

            my_mass = (self.mass / 10.00000);

         }

      }

   }
   magnitude = ((vlen (self.velocity) * my_mass) / 10.00000);
   if ( (pointcontents (self.absmax) == CONTENT_WATER) ) {

      magnitude /= 3.00000;

   }
   if ( ((self.classname == "barrel") && self.aflag) ) {

      magnitude *= 3.00000;

   }
   if ( ((self.last_onground + 0.30000) < time) ) {

      if ( ((((magnitude >= 100.00000) && loser.takedamage) && (loser.classname != "catapult")) && (loser != world)) ) {

         dir1 = normalize (self.velocity);
         if ( (loser.origin == '0.00000 0.00000 0.00000') ) {

            dir2 = dir1;
         } else {

            dir2 = normalize ((loser.origin - self.origin));

         }
         dot = (dir1 * dir2);
         if ( (dot >= 0.20000) ) {

            force = dot;
         } else {

            force = 0.00000;

         }
         force *= (magnitude / 50.00000);
         if ( (pointcontents (loser.absmax) == CONTENT_WATER) ) {

            force /= 3.00000;

         }
         if ( ((self.flags & FL_MONSTER) && (loser == world)) ) {

            force /= 2.00000;

         }
         if ( (((force >= 1.00000) && (loser.classname != "player")) || (force >= 10.00000)) ) {

            T_Damage (loser, self, self, force);

         }

      }
      if ( (self.netname == "spider") ) {

         return ;

      }
      if ( (self.classname != "monster_mezzoman") ) {

         if ( (((magnitude >= (100.00000 + self.health)) && (self.classname != "player")) || (magnitude >= 700.00000)) ) {

            if ( (((self.classname == "player") && (self.flags & FL_ONGROUND)) && (magnitude < 1000.00000)) ) {

               magnitude /= 2.00000;
               if ( (self.absorb_time >= time) ) {

                  magnitude /= 2.00000;

               }

            }
            magnitude /= 40.00000;
            magnitude = (magnitude - (force / 2.00000));
            if ( (magnitude >= 1.00000) ) {

               T_Damage (self, world, world, magnitude);

            }

         }

      }
      self.last_impact = time;
      if ( (self.flags & FL_ONGROUND) ) {

         self.last_onground = time;

      }

   }
};


void  ()obj_push =  {
local vector pushdir = '0.00000 0.00000 0.00000';
local vector pushangle = '0.00000 0.00000 0.00000';
local float ontop = 0.00000;
local float pushed = 0.00000;
local float inertia = 0.00000;
local float force = 0.00000;
local float walkforce = 0.00000;
local vector dir1 = '0.00000 0.00000 0.00000';
local vector dir2 = '0.00000 0.00000 0.00000';
local float dot_forward = 0.00000;
local float dot_right = 0.00000;
   if ( (((self.classname == "barrel") && (pointcontents (self.origin) != CONTENT_EMPTY)) && !(self.spawnflags & BARREL_SINK)) ) {

      self.classname = "barrel_floating";
      self.think = float;
      self.nextthink = time;

   }
   if ( ((self.last_impact + 0.10000) <= time) ) {

      obj_fly_hurt (other);

   }
   if ( (((other != world) && (other.absmin_z >= ((self.origin_z + self.maxs_z) - 5.00000))) && (other.velocity_z < 1.00000)) ) {

      ontop = TRUE;
      if ( !(other.flags & FL_ONGROUND) ) {

         other.flags += FL_ONGROUND;

      }

   }
   if ( (self.flags & FL_MONSTER) ) {

      if ( (((other != world) && (self.absmin_z >= ((other.origin_z + other.maxs_z) - 5.00000))) && (self.velocity_z < 1.00000)) ) {

         if ( !(self.flags & FL_ONGROUND) ) {

            self.flags += FL_ONGROUND;

         }

      }
      if ( (!self.frozen && !(self.flags2 & FL_STONED)) ) {

         return ;

      }

   }
   if ( !other.velocity ) {

      return ;

   }
   if ( (self.impulse == 20.00000) ) {

      return ;

   }
   if ( !self.mass ) {

      inertia = 1.00000;

   }
   if ( (self.mass <= 30.00000) ) {

      inertia = (self.mass / 3.00000);
   } else {

      inertia = (self.mass / 33.00000);

   }
   if ( other.strength ) {

      force = (vlen (other.velocity) * ((other.strength / 40.00000) + 0.50000));
   } else {

      force = vlen (other.velocity);

   }
   if ( (((pointcontents (self.origin) == CONTENT_WATER) || (pointcontents (self.origin) == CONTENT_SLIME)) || (pointcontents (self.origin) == CONTENT_LAVA)) ) {

      force /= 3.00000;

   }
   if ( (self.mass >= 1000.00000) ) {

      return ;

   }
   if ( (self.skin == 105.00000) ) {

      self.wait = (time + 10.00000);

   }
   if ( ontop ) {

      return ;

   }
   walkforce = ((force / inertia) / 40.00000);
   if ( ((self.classname == "barrel") && self.aflag) ) {

      self.angles_z = 0.00000;
      self.v_angle_z = 0.00000;
      self.v_angle_x = 0.00000;
      makevectors (self.v_angle);
      if ( ontop ) {

         dir1 = normalize (other.velocity);
      } else {

         dir1 = normalize ((self.origin - other.origin));

      }
      dir2 = normalize (v_forward);
      dir2_z = 0.00000;
      dir1_z = 0.00000;
      dot_forward = (dir1 * dir2);
      self.enemy = other;
      if ( (dot_forward >= 0.90000) ) {

         self.movedir = dir2;
         self.movedir_z = 0.00000;
         self.speed += (force / inertia);
         if ( (self.speed > (other.strength * 300.00000)) ) {

            self.speed = (other.strength * 300.00000);

         }
         traceline (self.origin, (self.origin + (dir2 * 48.00000)), FALSE, self);
         if ( (trace_fraction == 1.00000) ) {

            self.velocity = (self.movedir * self.speed);
            self.think = obj_barrel_roll;
            self.nextthink = time;

         }
      } else {

         if ( (dot_forward <= -0.90000) ) {

            self.movedir = dir2;
            self.movedir_z = 0.00000;
            self.speed += ((force / inertia) * -1.00000);
            if ( (self.speed < (other.strength * -300.00000)) ) {

               self.speed = (other.strength * -300.00000);

            }
            traceline (self.origin, (self.origin + (dir2 * -48.00000)), FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               self.velocity = (self.movedir * self.speed);
               self.think = obj_barrel_roll;
               self.nextthink = time;

            }
         } else {

            dir1 = normalize (other.velocity);
            dir2 = normalize (v_right);
            dot_right = (dir1 * dir2);
            if ( (dot_right > 0.20000) ) {

               if ( (dot_forward > 0.10000) ) {

                  self.angles_y -= (walkforce * 10.00000);
               } else {

                  if ( (dot_forward < -0.10000) ) {

                     self.angles_y += (walkforce * 10.00000);

                  }

               }
            } else {

               if ( (dot_right < -0.20000) ) {

                  if ( (dot_forward > 0.10000) ) {

                     self.angles_y += (walkforce * 10.00000);
                  } else {

                     if ( (dot_forward < -0.10000) ) {

                        self.angles_y -= (walkforce * 10.00000);

                     }

                  }

               }

            }
            self.v_angle_y = self.angles_y;

         }

      }
   } else {

      pushdir = normalize (other.velocity);
      pushangle = vectoangles (pushdir);
      pushed = FALSE;
      walkforce = ((force / inertia) / 20.00000);
      if ( !walkmove (pushangle_y, walkforce, FALSE) ) {

         if ( (other.absmax_z <= (self.origin_z + (self.mins_z * 0.75000))) ) {

            pushdir_z *= 2.00000;

         }
         self.velocity = (((((pushdir * force) * 2.00000) * (1.00000 / inertia)) + self.velocity) * 0.50000);
         if ( (self.flags & FL_ONGROUND) ) {

            if ( (self.velocity_z < 0.00000) ) {

               self.velocity_z = 0.00000;

            }
            self.flags -= FL_ONGROUND;

         }
         if ( self.velocity ) {

            pushed = TRUE;

         }
      } else {

         pushed = TRUE;

      }
      if ( (pushed && (self.classname != "barrel_floating")) ) {

         if ( (self.pain_finished <= time) ) {

            if ( (self.classname == "player_sheep") ) {

               sheep_sound (0.75000);
               if ( (!infront (other) && (random () < 0.50000)) ) {

                  self.think = sheep_trot;

               }
            } else {

               if ( (self.thingtype == THINGTYPE_WOOD) ) {

                  sound (self, CHAN_VOICE, "misc/pushwood.wav", 1.00000, ATTN_NORM);
                  self.pain_finished = (time + 1.04100);
               } else {

                  if ( ((self.thingtype == THINGTYPE_GREYSTONE) || (self.thingtype == THINGTYPE_BROWNSTONE)) ) {

                     sound (self, CHAN_VOICE, "misc/pushston.wav", 1.00000, ATTN_NORM);
                     self.pain_finished = (time + 0.71100);
                  } else {

                     if ( (self.thingtype == THINGTYPE_METAL) ) {

                        sound (self, CHAN_VOICE, "misc/pushmetl.wav", 1.00000, ATTN_NORM);
                        self.pain_finished = (time + 0.83500);

                     }

                  }

               }

            }

         }

      }

   }
};


void  ()HeaveHo =  {
local vector dir = '0.00000 0.00000 0.00000';
local float inertia = 0.00000;
local float lift = 0.00000;
   makevectors (self.v_angle);
   dir = normalize (v_forward);
   traceline ((self.origin + self.proj_ofs), ((self.origin + self.proj_ofs) + (dir * 48.00000)), FALSE, self);
   if ( ((trace_ent.movetype && trace_ent.solid) && (trace_ent != world)) ) {

      if ( !trace_ent.mass ) {

         inertia = 1.00000;
      } else {

         if ( (trace_ent.mass <= 50.00000) ) {

            inertia = (trace_ent.mass / 10.00000);
         } else {

            inertia = (trace_ent.mass / 100.00000);

         }

      }
      lift = ((((self.strength / 40.00000) + 0.50000) * 300.00000) / inertia);
      if ( (lift > 300.00000) ) {

         lift = 300.00000;

      }
      trace_ent.velocity_z += lift;
      if ( (trace_ent.flags & FL_ONGROUND) ) {

         trace_ent.flags -= FL_ONGROUND;

      }
      sound (self, CHAN_BODY, "player/pa1jmp.wav", 1.00000, ATTN_NORM);
      self.attack_finished = (time + 1.00000);

   }
};


void  ()obj_pull =  {
   self.touch = self.touch;
};


void  ()obj_chair =  {
   precache_model ("models/chair.mdl");
   CreateEntity (self, "models/chair.mdl", '-10.00000 -10.00000 -8.00000', '10.00000 10.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 3.00000;

   }
};


void  ()obj_barstool =  {
   precache_model ("models/stool.mdl");
   CreateEntity (self, "models/stool.mdl", '-10.00000 -10.00000 0.00000', '10.00000 10.00000 32.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 3.00000;

   }
};


void  ()obj_tree =  {
   precache_model ("models/tree.mdl");
   CreateEntity (self, "models/tree.mdl", '-42.00000 -42.00000 0.00000', '42.00000 42.00000 160.00000', SOLID_BBOX, MOVETYPE_NONE, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   if ( !self.health ) {

      self.health = 1000.00000;

   }
   if ( !self.mass ) {

      self.mass = 999999.00000;

   }
};


void  ()tree2_death =  {
   self.owner.nextthink = (time + 0.01000);
   self.owner.think = chunk_death;
   chunk_death ();
};


void  ()obj_tree2 =  {
local entity top;
local float hold_z = 0.00000;
   precache_model ("models/tree2.mdl");
   CreateEntity (self, "models/tree2.mdl", '-32.00000 -32.00000 -16.00000', '32.00000 32.00000 210.00000', SOLID_BBOX, MOVETYPE_NONE, THINGTYPE_WOOD_LEAF, DAMAGE_NO_GRENADE);
   self.th_die = tree2_death;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   if ( !self.health ) {

      self.health = 1000.00000;

   }
   top = spawn ();
   top.scale = self.scale;
   CreateEntity (top, top.model, '-140.00000 -140.00000 -16.00000', '140.00000 140.00000 120.00000', SOLID_BBOX, MOVETYPE_NONE, THINGTYPE_LEAVES, DAMAGE_NO_GRENADE);
   top.origin = self.origin;
   if ( self.scale ) {

      top.origin_z += (top.scale * 104.00000);
   } else {

      top.origin_z += 104.00000;

   }
   top.th_die = tree2_death;
   top.touch = SUB_Null;
   top.use = SUB_Null;
   if ( !self.health ) {

      top.health = 200.00000;

   }
   top.classname = "tree2top";
   top.owner = self;
   self.owner = top;
   if ( !self.mass ) {

      self.mass = 999999.00000;

   }
};


void  ()obj_bench =  {
   precache_model ("models/bench.mdl");
   if ( ((self.angles_y == 0.00000) || (self.angles_y == 180.00000)) ) {

      CreateEntity (self, "models/bench.mdl", '-10.00000 -30.00000 0.00000', '10.00000 30.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   } else {

      CreateEntity (self, "models/bench.mdl", '-30.00000 -10.00000 0.00000', '30.00000 10.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);

   }
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.use = SUB_Null;
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 8.00000;

   }
};


void  ()obj_cart =  {
   precache_model ("models/cart.mdl");
   CreateEntity (self, "models/cart.mdl", '-36.00000 -32.00000 -23.00000', '36.00000 75.00000 64.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 7.00000;

   }
};


void  ()obj_chest1 =  {
   precache_model ("models/chest1.mdl");
   CreateEntity (self, "models/chest1.mdl", '-10.00000 -10.00000 -16.00000', '10.00000 10.00000 16.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_pain = SUB_Null;
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 4.00000;

   }
};


void  ()obj_chest2 =  {
   precache_model ("models/chest2.mdl");
   CreateEntity (self, "models/chest2.mdl", '-10.00000 -10.00000 -16.00000', '10.00000 10.00000 16.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   self.th_pain = SUB_Null;
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 25.00000;

   }
   if ( !self.mass ) {

      self.mass = 4.00000;

   }
};


void  ()boulder_fall =  {
   if ( (!(self.flags & FL_ONGROUND) || (self.frags < time)) ) {

      self.movetype = MOVETYPE_BOUNCE;
      if ( (self.velocity_z >= 0.00000) ) {

         self.velocity_z -= 10.00000;

      }

   }
   self.think = boulder_fall;
   self.nextthink = (time + 0.10000);
};


void  ()boulder_push =  {
   if ( self.velocity ) {

      self.avelocity = (self.velocity * -1.00000);

   }
   obj_fly_hurt (other);
   if ( ((((other.movetype && (other.velocity != '0.00000 0.00000 0.00000')) && (other.solid != SOLID_TRIGGER)) && (other.solid != SOLID_PHASE)) && other.solid) ) {

      if ( !walkmove (other.angles_y, 1.00000, TRUE) ) {

         dprint ("can't walk\n");
         self.velocity = ((other.velocity + self.velocity) * 0.50000);
         self.frags = (time + 0.01000);

      }
      if ( (self.flags & FL_ONGROUND) ) {

         self.movetype = MOVETYPE_BOUNCEMISSILE;
         self.flags -= FL_ONGROUND;

      }

   }
};


void  ()obj_boulder =  {
   precache_model ("models/boulder.mdl");
   CreateEntity (self, "models/boulder.mdl", '-24.00000 -24.00000 -16.00000', '24.00000 24.00000 16.00000', SOLID_BBOX, MOVETYPE_BOUNCE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   self.touch = boulder_push;
   self.flags = (self.flags | FL_PUSH);
   if ( !self.health ) {

      self.health = 75.00000;

   }
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   self.think = boulder_fall;
   self.nextthink = (time + 0.10000);
};


void  ()obj_sword =  {
   precache_model ("models/sword.mdl");
   CreateEntity (self, "models/sword.mdl", '-16.00000 -16.00000 -8.00000', '16.00000 16.00000 8.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_METAL, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 50.00000;

   }
   if ( !self.mass ) {

      self.mass = 1.00000;

   }
};


void  ()BalBoltStick =  {
local vector dir = '0.00000 0.00000 0.00000';
   self.velocity = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_NONE;
   self.solid = SOLID_BBOX;
   self.takedamage = DAMAGE_NO_GRENADE;
   if ( !self.health ) {

      self.health = 10.00000;

   }
   self.th_die = chunk_death;
   makevectors (self.angles);
   dir = normalize (v_forward);
   if ( (pointcontents ((self.origin + (dir * 24.00000))) != CONTENT_SOLID) ) {

      remove (self);

   }
};


void  ()BalBoltTouch =  {
local vector dir = '0.00000 0.00000 0.00000';
   if ( other.takedamage ) {

      T_Damage (other, self, self.owner, self.dmg);
      self.touch = SUB_Null;
      self.think = BalBoltStick;
      self.nextthink = (time + 0.10000);
   } else {

      makevectors (self.angles);
      dir = normalize (v_forward);
      self.dmg /= 1.20000;
      if ( (self.movetype != MOVETYPE_BOUNCE) ) {

         if ( (pointcontents ((self.origin + (dir * 52.00000))) == CONTENT_SOLID) ) {

            setorigin (self, (self.origin + (dir * 8.00000)));
            self.velocity = '0.00000 0.00000 0.00000';
            self.avelocity = '0.00000 0.00000 0.00000';
            self.touch = SUB_Null;
            self.movetype = MOVETYPE_NONE;
            self.dmg = 0.00000;
            self.think = SUB_Remove;
            self.nextthink = (time + 2.00000);
         } else {

            self.movetype = MOVETYPE_BOUNCE;
            self.avelocity_x = ((random () * 720.00000) - 360.00000);
            self.avelocity_y = ((random () * 720.00000) - 360.00000);
            self.avelocity_z = ((random () * 720.00000) - 360.00000);

         }

      }

   }
};


void  ()FireBalBolt =  {
local vector org = '0.00000 0.00000 0.00000';
   newmis = spawn ();
   newmis.owner = self;
   makevectors (self.angles);
   org = ((self.origin + self.proj_ofs) + (v_forward * 10.00000));
   if ( (self.spawnflags & SPAWNFLAG_BALLISTA_TRACK) ) {

      newmis.velocity = (normalize ((((self.enemy.absmax + self.enemy.absmin) * 0.50000) - org)) * 1000.00000);
   } else {

      if ( self.goalentity.health ) {

         newmis.velocity = (normalize ((self.goalentity.origin - org)) * 1000.00000);
      } else {

         newmis.velocity = (normalize ((self.view_ofs - org)) * 1000.00000);

      }
      if ( deathmatch ) {

         newmis.think = Missile_Arc;
         newmis.nextthink = (time + 0.20000);

      }

   }
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_PHASE;
   newmis.thingtype = THINGTYPE_WOOD;
   newmis.touch = BalBoltTouch;
   newmis.angles = vectoangles (newmis.velocity);
   newmis.avelocity_z = 500.00000;
   newmis.dmg = self.dmg;
   setmodel (newmis, "models/balbolt.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, org);
};

void  ()ballista_think;

void  ()ballista_fire =  {
   AdvanceFrame( 1.00000, 30.00000);
   if ( (self.frame == 4.00000) ) {

      FireBalBolt ();

   }
   if ( cycle_wrapped ) {

      self.frame = 0.00000;
      self.last_attack = time;
      if ( (self.spawnflags & SPAWNFLAG_BALLISTA_TRACK) ) {

         self.think = ballista_think;
      } else {

         self.think = SUB_Null;

      }

   }
};


void  ()ballista_think =  {
local entity targ;
local float result = 0.00000;
local float pitchmod = 0.00000;
local vector my_pitch = '0.00000 0.00000 0.00000';
local vector ideal_pitch = '0.00000 0.00000 0.00000';
   targ = find (world, classname, "player");
   if ( !targ ) {

      dprint ("Unable to target player!\n");

   }
   self.enemy = targ;
   enemy_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ai_attack_face ();
   makevectors (self.angles);
   my_pitch = normalize (v_forward);
   ideal_pitch = normalize ((self.enemy.origin - self.origin));
   ideal_pitch = vectoangles (ideal_pitch);
   if ( (ideal_pitch_z > my_pitch_z) ) {

      if ( ((ideal_pitch_z - my_pitch_z) > self.count) ) {

         pitchmod = self.count;
      } else {

         pitchmod = (ideal_pitch_z - my_pitch_z);

      }
      self.angles_z += pitchmod;
   } else {

      if ( (ideal_pitch_z < my_pitch_z) ) {

         if ( ((my_pitch_z - ideal_pitch_z) > self.count) ) {

            pitchmod = self.count;
         } else {

            pitchmod = (my_pitch_z - ideal_pitch_z);

         }
         self.angles_z -= pitchmod;

      }

   }
   if ( ((self.last_attack + self.speed) < time) ) {

      if ( visible (self.enemy) ) {

         if ( infront (self.enemy) ) {

            if ( (random () < 0.20000) ) {

               ballista_fire ();

            }

         }

      }

   }
   self.nextthink = (self.ltime + 0.10000);
   self.think = ballista_think;
};


void  ()obj_ballista =  {
   precache_model ("models/ballista.mdl");
   precache_model ("models/balbolt.mdl");
   CreateEntity (self, "models/ballista.mdl", '-45.00000 -45.00000 0.00000', '45.00000 45.00000 60.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_WOOD, DAMAGE_NO_GRENADE);
   if ( !self.cnt ) {

      self.cnt = 30.00000;

   }
   if ( !self.count ) {

      self.count = 5.00000;

   }
   if ( !self.health ) {

      self.takedamage = DAMAGE_NO;

   }
   if ( !self.dmg ) {

      self.dmg = 50.00000;

   }
   if ( !self.speed ) {

      self.speed = 5.00000;

   }
   if ( !self.mass ) {

      self.mass = 400.00000;

   }
   self.oldorigin = self.angles;
   if ( (self.spawnflags & SPAWNFLAG_BALLISTA_TRACK) ) {

      self.yaw_speed = self.count;
      self.th_missile = ballista_fire;
      self.think = ballista_think;
      self.nextthink = (time + 0.50000);
      self.last_attack = (time + 0.50000);

   }
   self.th_weapon = ballista_fire;
   self.proj_ofs = '0.00000 0.00000 48.00000';
   self.view_ofs = '0.00000 0.00000 48.00000';
   self.th_die = chunk_death;
};


void  (float anim)bell_attack =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector bell_angle = '0.00000 0.00000 0.00000';
   if ( !anim ) {

      bell_angle = self.v_angle;
   } else {

      bell_angle = self.v_angle;
      bell_angle_y = (self.v_angle_y - 180.00000);

   }
   makevectors (bell_angle);
   spot1 = (self.origin + '0.00000 0.00000 -180.00000');
   spot2 = (spot1 + (v_forward * 150.00000));
   tracearea (spot1, spot2, '-80.00000 -80.00000 0.00000', '80.00000 80.00000 64.00000', FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   if ( trace_ent.takedamage ) {

      sound (self, CHAN_WEAPON, "weapons/gauntht1.wav", 1.00000, ATTN_NORM);
      if ( !(trace_ent.movetype == MOVETYPE_NONE) ) {

         if ( (trace_ent.flags & FL_ONGROUND) ) {

            trace_ent.flags = (trace_ent.flags - FL_ONGROUND);

         }
         trace_ent.velocity = (trace_ent.origin - self.origin);
         trace_ent.velocity_z = 280.00000;

      }

   }
};


void  ()bell_smallring =  {
   AdvanceFrame( 31.00000, 51.00000);
   self.nextthink = (((time + HX_FRAME_TIME) + HX_FRAME_TIME) + HX_FRAME_TIME);
   if ( cycle_wrapped ) {

      self.frame = 0.00000;
      self.nextthink = (time - 1.00000);
      self.think = SUB_Null;

   }
};


void  ()bell_bigring =  {
   AdvanceFrame( 0.00000, 30.00000);
   self.nextthink = (((time + HX_FRAME_TIME) + HX_FRAME_TIME) + HX_FRAME_TIME);
   if ( (self.frame == 2.00000) ) {

      sound (self, CHAN_VOICE, "misc/bellring.wav", 1.00000, ATTN_IDLE);
      bell_attack (0.00000);

   }
   if ( (self.frame == 8.00000) ) {

      sound (self, CHAN_VOICE, "misc/bellring.wav", 1.00000, ATTN_IDLE);
      bell_attack (1.00000);

   }
   if ( cycle_wrapped ) {

      self.frame = 0.00000;
      self.nextthink = (time - 1.00000);
      self.think = SUB_Null;

   }
};


void  ()bell_ring =  {
   if ( (self.frame != 0.00000) ) {

      return ;

   }
   if ( ((self.last_health - self.health) < 20.00000) ) {

      bell_smallring ();
   } else {

      bell_bigring ();

   }
   self.last_health = self.health;
};


void  ()obj_bell =  {
   precache_sound ("misc/bellring.wav");
   precache_model ("models/bellring.mdl");
   CreateEntity (self, "models/bellring.mdl", '-100.00000 -100.00000 -205.00000', '100.00000 100.00000 8.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_METAL, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 250.00000;

   }
   self.last_health = self.health;
   self.th_pain = bell_ring;
   self.use = bell_bigring;
   if ( !self.mass ) {

      self.mass = 1000.00000;

   }
};


void  ()brush_pushable =  {
   self.max_health = self.health;
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_PUSHPULL;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.classname = "pushable brush";
   self.touch = obj_push;
   if ( !self.mass ) {

      self.mass = 5.00000;

   }
};


void  ()statue_death =  {
   if ( self.enemy ) {

      self.enemy.nextthink = (time + 0.01000);
      self.enemy.think = chunk_death;
      chunk_death ();
   } else {

      chunk_death ();

   }
};


void  ()obj_statue_mummy_head =  {
   precache_model ("models/mhdstatu.mdl");
   CreateEntity (self, "models/mhdstatu.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 50.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_BROWNSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 200.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
   if ( !self.mass ) {

      self.mass = 15.00000;

   }
};


void  ()obj_statue_mummy =  {
local entity head;
   head = spawn ();
   head.scale = self.scale;
   if ( self.scale ) {

      head.origin_z = (132.00000 * self.scale);
      head.mass = (150.00000 * self.scale);
   } else {

      head.origin_z = 132.00000;

   }
   if ( !self.mass ) {

      head.mass = 150.00000;
      self.mass = 150.00000;

   }
   head.origin += self.origin;
   head.angles = self.angles;
   self.enemy = head;
   precache_model ("models/mumstatu.mdl");
   CreateEntity (self, "models/mumstatu.mdl", '-26.00000 -26.00000 0.00000', '26.00000 26.00000 130.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_BROWNSTONE, DAMAGE_NO_GRENADE);
   self.th_die = statue_death;
   if ( !self.health ) {

      self.health = 200.00000;

   }
   self.drawflags += SCALE_ORIGIN_BOTTOM;
   precache_model ("models/mhdstatu.mdl");
   CreateEntity (head, "models/mhdstatu.mdl", '-26.00000 -26.00000 0.00000', '26.00000 26.00000 30.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_BROWNSTONE, DAMAGE_NO_GRENADE);
   head.th_die = statue_death;
   head.health = self.health;
   head.drawflags += SCALE_ORIGIN_BOTTOM;
};


void  ()obj_pot1 =  {
   precache_model ("models/pot1.mdl");
   if ( (world.worldtype == WORLDTYPE_CASTLE) ) {

      self.skin = 0.00000;
   } else {

      if ( (world.worldtype == WORLDTYPE_EGYPT) ) {

         self.skin = 1.00000;
      } else {

         if ( (world.worldtype == WORLDTYPE_MESO) ) {

            self.skin = 2.00000;
         } else {

            if ( (world.worldtype == WORLDTYPE_ROMAN) ) {

               self.skin = 3.00000;

            }

         }

      }

   }
   if ( !self.mass ) {

      self.mass = 100.00000;

   }
   CreateEntity (self, "models/pot1.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 50.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_CLAY, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 10.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
};


void  ()obj_pot2 =  {
   precache_model ("models/pot2.mdl");
   if ( (world.worldtype == WORLDTYPE_CASTLE) ) {

      self.skin = 0.00000;
   } else {

      if ( (world.worldtype == WORLDTYPE_EGYPT) ) {

         self.skin = 1.00000;
      } else {

         if ( (world.worldtype == WORLDTYPE_MESO) ) {

            self.skin = 2.00000;
         } else {

            if ( (world.worldtype == WORLDTYPE_ROMAN) ) {

               self.skin = 3.00000;

            }

         }

      }

   }
   if ( !self.mass ) {

      self.mass = 100.00000;

   }
   CreateEntity (self, "models/pot2.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_CLAY, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 10.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
};


void  ()obj_pot3 =  {
   precache_model ("models/pot3.mdl");
   if ( (world.worldtype == WORLDTYPE_CASTLE) ) {

      self.skin = 0.00000;
   } else {

      if ( (world.worldtype == WORLDTYPE_EGYPT) ) {

         self.skin = 1.00000;
      } else {

         if ( (world.worldtype == WORLDTYPE_MESO) ) {

            self.skin = 2.00000;
         } else {

            if ( (world.worldtype == WORLDTYPE_ROMAN) ) {

               self.skin = 3.00000;

            }

         }

      }

   }
   if ( !self.mass ) {

      self.mass = 100.00000;

   }
   CreateEntity (self, "models/pot3.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_CLAY, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 10.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
};


void  ()obj_statue_tut =  {
   precache_model ("models/tutstatu.mdl");
   if ( !self.mass ) {

      self.mass = 2000.00000;

   }
   CreateEntity (self, "models/tutstatu.mdl", '-36.00000 -36.00000 0.00000', '36.00000 36.00000 248.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_BROWNSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 1000.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
};


void  ()flag_run =  {
   AdvanceFrame( 0.00000, 79.00000);
};


void  ()obj_flag =  {
   precache_model ("models/flag.mdl");
   CreateEntity (self, "models/flag.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 160.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_METAL_CLOTH, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 50.00000;

   }
   if ( !self.mass ) {

      self.mass = 1000.00000;

   }
   self.nextthink = (time + 0.10000);
   self.think = flag_run;
};


void  ()obj_statue_snake =  {
   precache_model ("models/snkstatu.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   CreateEntity (self, "models/snkstatu.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 80.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_BROWNSTONE, DAMAGE_NO_GRENADE);
   if ( (self.spawnflags & 1.00000) ) {

      self.health = 0.00000;
      self.takedamage = DAMAGE_NO;
   } else {

      self.th_die = chunk_death;
      if ( !self.health ) {

         self.health = 100.00000;

      }

   }
};


void  ()obj_hedge1 =  {
   precache_model ("models/hedge1.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   CreateEntity (self, "models/hedge1.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 80.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_WOOD_LEAF, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_hedge2 =  {
   precache_model ("models/hedge2.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   CreateEntity (self, "models/hedge2.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 80.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_WOOD_LEAF, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_hedge3 =  {
   precache_model ("models/hedge3.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   CreateEntity (self, "models/hedge3.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 120.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_WOOD_LEAF, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_fountain =  {
   precache_model ("models/fountain.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   CreateEntity (self, "models/fountain.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 80.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_book_open =  {
   precache_model ("models/bookopen.mdl");
   CreateEntity (self, "models/bookopen.mdl", '-8.00000 -8.00000 0.00000', '8.00000 8.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_book_closed =  {
   precache_model ("models/bookclos.mdl");
   CreateEntity (self, "models/bookclos.mdl", '-8.00000 -8.00000 0.00000', '8.00000 8.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_fence =  {
   precache_model ("models/fence.mdl");
   if ( (self.angles_y == 0.00000) ) {

      CreateEntity (self, "models/fence.mdl", '-10.00000 -26.00000 0.00000', '10.00000 26.00000 70.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_METAL, DAMAGE_NO_GRENADE);
   } else {

      CreateEntity (self, "models/fence.mdl", '-26.00000 -10.00000 0.00000', '26.00000 10.00000 70.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_METAL, DAMAGE_NO_GRENADE);

   }
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_bush1 =  {
   precache_model ("models/bush1.mdl");
   CreateEntity (self, "models/bush1.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_WOOD_LEAF, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_tombstone1 =  {
   precache_model ("models/tombstn1.mdl");
   CreateEntity (self, "models/tombstn1.mdl", '-24.00000 -24.00000 0.00000', '24.00000 24.00000 60.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_tombstone2 =  {
   precache_model ("models/tombstn2.mdl");
   CreateEntity (self, "models/tombstn2.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_statue_angel =  {
   precache_model ("models/anglstat.mdl");
   if ( ((self.angles_y == 0.00000) || (self.angles_y == 180.00000)) ) {

      CreateEntity (self, "models/anglstat.mdl", '-60.00000 -40.00000 0.00000', '60.00000 40.00000 120.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);
   } else {

      CreateEntity (self, "models/anglstat.mdl", '-40.00000 -60.00000 0.00000', '40.00000 60.00000 120.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_GREYSTONE, DAMAGE_NO_GRENADE);

   }
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 150.00000;

   }
};


void  ()webs_think =  {
   AdvanceFrame( 1.00000, 100.00000);
   if ( (self.spawnflags & 8.00000) ) {

      self.touch = SUB_Null;
      if ( cycle_wrapped ) {

         self.touch = webs_think;
         self.nextthink = -1.00000;

      }

   }
};


void  ()webs_touch =  {
   if ( ((!other.movetype || (other.movetype == MOVETYPE_PUSHPULL)) || (other.classname == self.classname)) ) {

      return ;

   }
   if ( !(other.flags & FL_ONGROUND) ) {

      other.flags += FL_ONGROUND;

   }
};


void  ()webs_death =  {
   if ( ((!other.movetype || (other.movetype == MOVETYPE_PUSHPULL)) || (other.classname == self.classname)) ) {

      return ;

   }
   chunk_death ();
};


void  ()obj_webs =  {
   if ( (self.skin == 4.00000) ) {

      precache_model ("models/megaweb.mdl");
      CreateEntity (self, "models/megaweb.mdl", '-25.00000 -25.00000 -25.00000', '25.00000 25.00000 25.00000', SOLID_NOT, MOVETYPE_NONE, THINGTYPE_WEBS, DAMAGE_NO);
      self.skin = 0.00000;
   } else {

      precache_model ("models/webs.mdl");
      CreateEntity (self, "models/webs.mdl", '-25.00000 -25.00000 -25.00000', '25.00000 25.00000 25.00000', SOLID_NOT, MOVETYPE_NONE, THINGTYPE_WEBS, DAMAGE_NO);

   }
   if ( !self.angles_y ) {

      self.angles = self.v_angle;
   } else {

      self.angles_x = self.v_angle_x;
      self.angles_z = self.v_angle_z;

   }
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.solid = SOLID_TRIGGER;

   }
   if ( (self.spawnflags & 1.00000) ) {

      self.solid = SOLID_BBOX;
      self.touch = webs_touch;

   }
   if ( (self.spawnflags & 4.00000) ) {

      if ( !self.solid ) {

         self.solid = SOLID_TRIGGER;

      }
      self.touch = webs_death;

   }
   if ( (self.spawnflags & 8.00000) ) {

      if ( !self.solid ) {

         self.solid = SOLID_TRIGGER;

      }
      self.touch = webs_think;

   }
   if ( (self.spawnflags & 16.00000) ) {

      self.angles_x = 90.00000;
      self.angles_z = 0.00000;
      setsize (self, '-25.00000 -25.00000 -2.00000', '25.00000 25.00000 2.00000');

   }
   if ( !(self.spawnflags & 32.00000) ) {

      self.drawflags = DRF_TRANSLUCENT;

   }
   self.th_die = chunk_death;
   setorigin (self, self.origin);
   if ( (self.spawnflags & 2.00000) ) {

      self.think = webs_think;
      self.nextthink = time;

   }
};


void  ()obj_corpse1 =  {
   precache_model ("models/corps1.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   if ( ((self.angles_y == 0.00000) || (self.angles_y == 180.00000)) ) {

      CreateEntity (self, "models/corps1.mdl", '-32.00000 -16.00000 0.00000', '32.00000 16.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_FLESH, DAMAGE_NO_GRENADE);
   } else {

      CreateEntity (self, "models/corps2.mdl", '-16.00000 -32.00000 0.00000', '16.00000 32.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_FLESH, DAMAGE_NO_GRENADE);

   }
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()obj_corpse2 =  {
   precache_model ("models/corps2.mdl");
   if ( !self.mass ) {

      self.mass = 200.00000;

   }
   if ( ((self.angles_y == 0.00000) || (self.angles_y == 180.00000)) ) {

      CreateEntity (self, "models/corps2.mdl", '-32.00000 -16.00000 0.00000', '32.00000 16.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_FLESH, DAMAGE_NO_GRENADE);
   } else {

      CreateEntity (self, "models/corps2.mdl", '-16.00000 -32.00000 0.00000', '16.00000 32.00000 10.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_FLESH, DAMAGE_NO_GRENADE);

   }
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()cauldron_run =  {
local vector spot1 = '0.00000 0.00000 0.00000';
   spot1 = self.origin;
   spot1_z = (self.origin_z + 35.00000);
   CreateWhiteSmoke (spot1);
   self.think = cauldron_run;
   self.nextthink = ((time + 0.50000) + (random () * 1.00000));
};


void  ()obj_cauldron =  {
   precache_model ("models/cauldron.mdl");
   CreateEntity (self, "models/cauldron.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_METAL, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 50.00000;

   }
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
   if ( !self.mass ) {

      self.mass = 15.00000;

   }
   self.think = cauldron_run;
   self.nextthink = ((time + 0.50000) + (random () * 1.00000));
};


void  ()obj_skullstick =  {
   precache_model ("models/skllstk1.mdl");
   CreateEntity (self, "models/skllstk1.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_METAL_STONE, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 20.00000;

   }
};


void  ()ice_touch =  {
   if ( (other.flags & FL_ONGROUND) ) {

      if ( (random () > self.friction) ) {

         other.flags -= FL_ONGROUND;

      }

   }
};


void  ()obj_ice =  {
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   self.takedamage = DAMAGE_NO_GRENADE;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.classname = "ice";
   self.use = chunk_death;
   self.drawflags += MLS_ABSLIGHT;
   if ( !self.abslight ) {

      self.abslight = 0.75000;

   }
   if ( !(self.spawnflags & 1.00000) ) {

      self.drawflags += DRF_TRANSLUCENT;

   }
   if ( !self.health ) {

      self.health = 20.00000;

   }
   self.max_health = self.health;
   if ( !self.friction ) {

      self.friction = 0.20000;

   }
   self.touch = ice_touch;
   self.th_die = chunk_death;
};


void  ()obj_beefslab =  {
   precache_model ("models/beefslab.mdl");
   CreateEntity (self, "models/beefslab.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 40.00000', SOLID_SLIDEBOX, MOVETYPE_NONE, THINGTYPE_FLESH, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 50.00000;

   }
};


void  ()obj_seaweed =  {
   precache_model ("models/seaweed.mdl");
   CreateEntity (self, "models/seaweed.mdl", '-8.00000 -8.00000 0.00000', '8.00000 8.00000 32.00000', SOLID_NOT, MOVETYPE_NONE, THINGTYPE_LEAVES, DAMAGE_NO_GRENADE);
   self.th_die = chunk_death;
   if ( !self.health ) {

      self.health = 10.00000;

   }
};

