
void  ()info_null =  {
   remove (self);
};

float POWERPOOL_HEALTH   =  1.00000;
float POWERPOOL_EXPERIENCE   =  2.00000;
float POWERPOOL_GREENMANA   =  4.00000;
float POWERPOOL_BLUEMANA   =  8.00000;
float ROTATE_BREAK   =  16.00000;

void  ()power_pool_touch =  {
   if ( (time < self.ltime) ) {

      return ;

   }
   self.cnt = (self.cnt + 1.00000);
   if ( (self.cnt > self.count) ) {

      self.touch = SUB_Null;
      return ;

   }
   if ( (self.spawnflags & POWERPOOL_HEALTH) ) {

      other.health = (other.health + 1.00000);

   }
   if ( (self.spawnflags & POWERPOOL_EXPERIENCE) ) {

      other.experience = (other.experience + 1.00000);

   }
   if ( (self.spawnflags & POWERPOOL_GREENMANA) ) {

      other.greenmana = (other.greenmana + 1.00000);

   }
   if ( (self.spawnflags & POWERPOOL_BLUEMANA) ) {

      other.bluemana = (other.bluemana + 1.00000);

   }
   self.ltime = (time + 0.15000);
};


void  ()power_pool =  {
   if ( !self.spawnflags ) {

      remove (self);
      return ;

   }
   self.touch = power_pool_touch;
   self.solid = SOLID_TRIGGER;
   if ( !self.count ) {

      self.count = 5.00000;

   }
};


void  (float offset)launch_spread =  {
local vector offang = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local entity mis;
   org = self.origin;
   offang = vectoangles ((self.movedir - org));
   offang_y = (offang_y + (offset * 6.00000));
   makevectors (offang);
   vec = normalize (v_forward);
   vec_z = 0.00000;
   mis = spawn ();
   mis.owner = self;
   mis.movetype = MOVETYPE_FLYMISSILE;
   mis.solid = SOLID_BBOX;
   mis.angles = vectoangles (vec);
   mis.touch = spike_touch;
   mis.classname = "spike";
   mis.think = SUB_Remove;
   mis.nextthink = (time + 6.00000);
   setmodel (mis, "models/spike.mdl");
   setsize (mis, VEC_ORIGIN, VEC_ORIGIN);
   setorigin (mis, org);
   mis.velocity = (vec * 1000.00000);
};

void  ()fire_fly;
void  ()fire_touch;

void  ()misc_fireball =  {
   precache_model ("models/lavaball.mdl");
   self.classname = "fireball";
   self.nextthink = (time + (random () * 5.00000));
   self.think = fire_fly;
   if ( !self.speed ) {


   }
};


void  ()fire_fly =  {
local entity fireball;
   fireball = spawn ();
   fireball.solid = SOLID_TRIGGER;
   fireball.movetype = MOVETYPE_TOSS;
   fireball.velocity = '0.00000 0.00000 1000.00000';
   fireball.velocity_x = ((random () * 100.00000) - 50.00000);
   fireball.velocity_y = ((random () * 100.00000) - 50.00000);
   fireball.velocity_z = (self.speed + (random () * 200.00000));
   fireball.classname = "fireball";
   setmodel (fireball, "models/lavaball.mdl");
   setsize (fireball, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (fireball, self.origin);
   fireball.nextthink = (time + 5.00000);
   fireball.think = SUB_Remove;
   fireball.touch = fire_touch;
   self.nextthink = ((time + (random () * 5.00000)) + 3.00000);
   self.think = fire_fly;
};


void  ()fire_touch =  {
   T_Damage (other, self, self, 20.00000);
   remove (self);
};

float SPAWNFLAG_SUPERSPIKE   =  1.00000;
float SPAWNFLAG_LASER   =  2.00000;

void  ()Laser_Touch =  {
local vector org = '0.00000 0.00000 0.00000';
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   org = (self.origin - (8.00000 * normalize (self.velocity)));
   if ( other.health ) {

      SpawnPuff (org, (self.velocity * 0.20000), 15.00000, other);
      T_Damage (other, self, self.owner, 15.00000);
   } else {

      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_GUNSHOT);
      WriteCoord (MSG_BROADCAST, org);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);

   }
   remove (self);
};


void  (vector org,vector vec)LaunchLaser =  {
   vec = normalize (vec);
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_FLY;
   newmis.solid = SOLID_BBOX;
   newmis.effects = EF_DIMLIGHT;
   setmodel (newmis, "models/javproj.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, org);
   newmis.velocity = (vec * 600.00000);
   newmis.angles = vectoangles (newmis.velocity);
   newmis.angles_y = (newmis.angles_y + 30.00000);
   newmis.nextthink = (time + 5.00000);
   newmis.think = SUB_Remove;
   newmis.touch = Laser_Touch;
};


void  ()spikeshooter_use =  {
local float spread = 5.00000;
local vector newdir = '0.00000 0.00000 0.00000';
   self.enemy = other.enemy;
   if ( (self.spawnflags & SPAWNFLAG_LASER) ) {

      LaunchLaser (self.origin, self.movedir);
   } else {

      sound (self, CHAN_VOICE, "weapons/spike2.wav", 1.00000, ATTN_NORM);
      launch_spike (self.origin, self.movedir);
      newmis.velocity = (self.movedir * 500.00000);
      if ( (self.spawnflags & SPAWNFLAG_SUPERSPIKE) ) {

         newmis.touch = superspike_touch;

      }

   }
};


void  ()shooter_think =  {
   spikeshooter_use ();
   self.nextthink = (time + self.wait);
};


void  ()sprayshooter_use =  {
   sound (self, CHAN_VOICE, "weapons/spike2.wav", 1.00000, ATTN_NORM);
   launch_spread ((random () * 10.00000));
};


void  ()sprayshooter_think =  {
   sprayshooter_use ();
   self.nextthink = (time + self.wait);
};


void  ()trap_spikeshooter_spray =  {
   SetMovedir ();
   self.use = sprayshooter_use;
   precache_sound ("weapons/spike2.wav");
   if ( (self.wait == 0.00000) ) {

      self.wait = 1.00000;

   }
   self.nextthink = ((self.nextthink + self.wait) + self.ltime);
   self.think = sprayshooter_think;
};


void  ()trap_spikeshooter =  {
   SetMovedir ();
   self.use = spikeshooter_use;
   if ( (self.spawnflags & SPAWNFLAG_LASER) ) {

      precache_model2 ("models/laser.mdl");
   } else {

      precache_sound ("weapons/spike2.wav");

   }
};


void  ()trap_shooter =  {
   trap_spikeshooter ();
   if ( (self.wait == 0.00000) ) {

      self.wait = 1.00000;

   }
   self.nextthink = ((self.nextthink + self.wait) + self.ltime);
   self.think = shooter_think;
};


void  ()trap_lightning_track =  {
local vector p1 = '0.00000 0.00000 0.00000';
local vector p2 = '0.00000 0.00000 0.00000';
local entity targ;
local float len = 0.00000;
   targ = find (world, classname, "player");
   if ( !targ ) {

      dprint ("No target for lightning");
      return ;

   }
   if ( (targ.health <= 0.00000) ) {

      self.nextthink = -1.00000;
      return ;

   }
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   p1 = self.origin;
   p2 = targ.origin;
   len = vlen ((p2 - p1));
   traceline (p1, p2, TRUE, self);
   if ( ((len >= self.aflag) || (trace_fraction < 1.00000)) ) {

      if ( ((self.wait == -1.00000) || (self.spawnflags & 2.00000)) ) {

         self.nextthink = -1.00000;
      } else {

         if ( (self.wait == 1.00000) ) {

            self.nextthink = ((time + self.wait) + (random () * 2.00000));
         } else {

            self.nextthink = (time + self.wait);

         }

      }
      return ;

   }
   WriteByte (MSG_ALL, SVC_TEMPENTITY);
   WriteByte (MSG_ALL, TE_LIGHTNING1);
   WriteEntity (MSG_ALL, self);
   WriteCoord (MSG_ALL, p1);
   WriteCoord (MSG_ALL, p1_y);
   WriteCoord (MSG_ALL, p1_z);
   WriteCoord (MSG_ALL, p2);
   WriteCoord (MSG_ALL, p2_y);
   WriteCoord (MSG_ALL, p2_z);
   LightningDamage (p1, p2, self, self.dmg, "lightning");
   fx_flash (p2);
   self.think = trap_lightning_track;
   if ( ((self.wait == -1.00000) || (self.spawnflags & 2.00000)) ) {

      self.nextthink = -1.00000;
   } else {

      if ( (self.wait == 1.00000) ) {

         self.nextthink = ((time + self.wait) + (random () * 2.00000));
      } else {

         self.nextthink = (time + self.wait);

      }

   }
};


void  ()trap_lightning_use =  {
local vector p1 = '0.00000 0.00000 0.00000';
local vector p2 = '0.00000 0.00000 0.00000';
local entity targ;
   if ( !self.target ) {

      dprint ("No target for lightning");
      return ;

   }
   targ = find (world, targetname, self.target);
   if ( !targ ) {

      dprint ("No target for lightning");
      return ;

   }
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   p1 = self.origin;
   p2 = targ.origin;
   WriteByte (MSG_ALL, SVC_TEMPENTITY);
   WriteByte (MSG_ALL, TE_LIGHTNING1);
   WriteEntity (MSG_ALL, self);
   WriteCoord (MSG_ALL, p1);
   WriteCoord (MSG_ALL, p1_y);
   WriteCoord (MSG_ALL, p1_z);
   WriteCoord (MSG_ALL, p2);
   WriteCoord (MSG_ALL, p2_y);
   WriteCoord (MSG_ALL, p2_z);
   LightningDamage (p1, p2, self, self.dmg, "lightning");
   fx_flash (p2);
};


void  ()trap_lightning =  {
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   if ( !self.noise ) {

      self.noise = "raven/lightng1.wav";

   }
   if ( !self.dmg ) {

      self.dmg = 10.00000;

   }
   if ( !self.wait ) {

      self.wait = 1.00000;

   }
   if ( !self.aflag ) {

      self.aflag = 500.00000;

   }
   self.ltime = time;
   self.noise = "raven/lightng1.wav";
   precache_sound ("raven/lightng1.wav");
   if ( (self.spawnflags & 1.00000) ) {

      self.use = trap_lightning_track;
   } else {

      self.use = trap_lightning_use;

   }
};

void  ()make_bubbles;
void  ()bubble_remove;

void  ()air_bubbles =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model ("models/s_bubble.spr");
   self.nextthink = (time + 1.00000);
   self.think = make_bubbles;
};


void  ()make_bubbles =  {
local entity bubble;
   bubble = spawn ();
   setmodel (bubble, "models/s_bubble.spr");
   setorigin (bubble, self.origin);
   bubble.movetype = MOVETYPE_NOCLIP;
   bubble.solid = SOLID_NOT;
   bubble.velocity = '0.00000 0.00000 15.00000';
   bubble.nextthink = (time + 0.50000);
   bubble.think = bubble_bob;
   bubble.touch = bubble_remove;
   bubble.classname = "bubble";
   bubble.frame = 0.00000;
   bubble.cnt = 0.00000;
   setsize (bubble, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
   self.nextthink = ((time + random ()) + 0.50000);
   self.think = make_bubbles;
};


void  ()bubble_split =  {
local entity bubble;
   bubble = spawn ();
   setmodel (bubble, "models/s_bubble.spr");
   setorigin (bubble, self.origin);
   bubble.movetype = MOVETYPE_NOCLIP;
   bubble.solid = SOLID_NOT;
   bubble.velocity = self.velocity;
   bubble.nextthink = (time + 0.50000);
   bubble.think = bubble_bob;
   bubble.touch = bubble_remove;
   bubble.classname = "bubble";
   bubble.frame = 1.00000;
   bubble.cnt = 10.00000;
   setsize (bubble, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
   self.frame = 1.00000;
   self.cnt = 10.00000;
   if ( (self.waterlevel != 3.00000) ) {

      remove (self);

   }
};


void  ()bubble_remove =  {
   if ( (other.classname == self.classname) ) {

      return ;

   }
   remove (self);
};


void  ()bubble_bob =  {
local float rnd1 = 0.00000;
local float rnd2 = 0.00000;
local float rnd3 = 0.00000;
local vector vtmp1 = '0.00000 0.00000 0.00000';
local vector modi = '0.00000 0.00000 0.00000';
local float waterornot = 0.00000;
   waterornot = pointcontents (self.origin);
   if ( ((waterornot != CONTENT_WATER) && (waterornot != CONTENT_SLIME)) ) {

      remove (self);

   }
   self.cnt = (self.cnt + 1.00000);
   if ( (self.cnt == 4.00000) ) {

      bubble_split ();

   }
   if ( (self.cnt == 20.00000) ) {

      remove (self);

   }
   rnd1 = (self.velocity_x + (-10.00000 + (random () * 20.00000)));
   rnd2 = (self.velocity_y + (-10.00000 + (random () * 20.00000)));
   rnd3 = ((self.velocity_z + 10.00000) + (random () * 10.00000));
   if ( (rnd1 > 10.00000) ) {

      rnd1 = 5.00000;

   }
   if ( (rnd1 < -10.00000) ) {

      rnd1 = -5.00000;

   }
   if ( (rnd2 > 10.00000) ) {

      rnd2 = 5.00000;

   }
   if ( (rnd2 < -10.00000) ) {

      rnd2 = -5.00000;

   }
   if ( (rnd3 < 10.00000) ) {

      rnd3 = 15.00000;

   }
   if ( (rnd3 > 30.00000) ) {

      rnd3 = 25.00000;

   }
   self.velocity_x = rnd1;
   self.velocity_y = rnd2;
   self.velocity_z = rnd3;
   self.nextthink = (time + 0.50000);
   self.think = bubble_bob;
};


void  ()viewthing =  {
   self.movetype = MOVETYPE_NONE;
   self.solid = SOLID_NOT;
   precache_model ("models/player.mdl");
   setmodel (self, "models/player.mdl");
};


void  ()func_wall_use =  {
   self.frame = (1.00000 - self.frame);
};


void  ()func_wall =  {
   self.angles = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_PUSH;
   self.solid = SOLID_BSP;
   self.classname = "solid wall";
   self.use = func_wall_use;
   setmodel (self, self.model);
   if ( (self.spawnflags & 1.00000) ) {

      self.drawflags = DRF_TRANSLUCENT;

   }
   if ( self.abslight ) {

      self.drawflags += MLS_ABSLIGHT;

   }
};


void  ()func_illusionary =  {
   if ( (self.spawnflags & 1.00000) ) {

      self.drawflags = (self.drawflags | DRF_TRANSLUCENT);

   }
   if ( (self.spawnflags & 2.00000) ) {

      self.drawflags = (self.drawflags | MLS_ABSLIGHT);

   }
   self.classname = "illusionary wall";
   self.angles = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_NONE;
   self.solid = SOLID_NOT;
   setmodel (self, self.model);
   makestatic ();
};


void  ()noise_think =  {
   self.nextthink = (time + 0.50000);
};


void  ()misc_noisemaker =  {
   self.nextthink = ((time + 0.10000) + random ());
   self.think = noise_think;
};

void  ()rotating_use;
void  ()rotating_touch;

void  ()rotate_wait =  {
   self.nextthink = (time + 1410065408.00000);
};


void  ()rotate_reset =  {
   if ( self.wait ) {

      self.think = rotating_use;
      self.nextthink = (time + self.wait);
   } else {

      self.think = SUB_Null;
      self.nextthink = -1.00000;

   }
};


void  ()rotate_wait_startpos =  {
   if ( (self.angles == self.o_angle) ) {

      self.avelocity = '0.00000 0.00000 0.00000';
      rotate_reset ();
   } else {

      self.nextthink = (time + 0.05000);

   }
};


void  ()rotate_slowdown =  {
   self.level -= (self.speed / self.anglespeed);
   if ( (((self.dmg == -1.00000) || (self.dmg == 666.00000)) && (self.level < 100.00000)) ) {

      self.touch = SUB_Null;

   }
   if ( ((self.level < 1.00000) || ((self.level <= (self.speed / self.anglespeed)) && (self.spawnflags & KEEP_START))) ) {

      if ( (self.spawnflags & KEEP_START) ) {

         self.think = rotate_wait_startpos;
         self.nextthink = time;
      } else {

         self.avelocity = '0.00000 0.00000 0.00000';
         rotate_reset ();

      }
   } else {

      self.avelocity = (self.movedir * self.level);
      self.think = rotate_slowdown;
      self.nextthink = (time + 0.01000);

   }
};


void  ()rotate_startup =  {
   self.level += (self.speed / self.anglespeed);
   if ( ((((self.dmg == -1.00000) || (self.dmg == 666.00000)) && (self.level >= 100.00000)) && (self.touch == SUB_Null)) ) {

      self.touch = rotating_touch;

   }
   if ( ((self.pain_finished <= time) && self.lifetime) ) {

      self.think = rotating_use;
      self.nextthink = time;
      return ;

   }
   if ( (self.level < self.speed) ) {

      self.avelocity = (self.movedir * self.level);
      self.think = rotate_startup;
      self.nextthink = (time + 0.01000);
   } else {

      self.level = self.speed;
      self.avelocity = (self.movedir * self.speed);
      if ( ((self.pain_finished > time) && self.lifetime) ) {

         self.think = rotating_use;
         self.nextthink = self.pain_finished;
         return ;
      } else {

         self.think = rotate_wait;
         self.nextthink = (time + 1410065408.00000);

      }

   }
};


void  ()rotating_use =  {
   if ( (self.avelocity != '0.00000 0.00000 0.00000') ) {

      if ( !(self.spawnflags & GRADUAL) ) {

         self.avelocity = '0.00000 0.00000 0.00000';
         rotate_reset ();
      } else {

         if ( (self.think == rotate_slowdown) ) {

            return ;
         } else {

            sound (self, CHAN_VOICE, self.noise2, 1.00000, ATTN_NORM);
            self.think = rotate_slowdown;
            self.nextthink = time;

         }

      }
   } else {

      if ( self.lifetime ) {

         self.pain_finished = (time + self.lifetime);

      }
      if ( (self.spawnflags & TOGGLE_REVERSE) ) {

         self.movedir = (self.movedir * -1.00000);

      }
      if ( !(self.spawnflags & GRADUAL) ) {

         self.avelocity = (self.movedir * self.speed);
         self.think = rotating_use;
         self.nextthink = (time + 1410065408.00000);
      } else {

         sound (self, CHAN_VOICE, self.noise1, 1.00000, ATTN_NORM);
         self.think = rotate_startup;
         self.nextthink = time;

      }

   }
};


void  (entity chopped_liver)rotating_damage =  {
local float damg = 0.00000;
   if ( (self.dmg == 666.00000) ) {

      if ( ((chopped_liver.classname == "player") && (chopped_liver.flags2 & FL_ALIVE)) ) {

         chopped_liver.decap = TRUE;
         T_Damage (chopped_liver, self, self, (chopped_liver.health + 300.00000));
      } else {

         T_Damage (chopped_liver, self, self, (chopped_liver.health + 50.00000));

      }
   } else {

      if ( ((self.dmg == -1.00000) && chopped_liver.health) ) {

         chopped_liver.deathtype = "chopped";
         damg = vlen (self.avelocity);
         T_Damage (chopped_liver, self, self, damg);

      }

   }
};


void  ()rotating_touch =  {
   if ( !other.takedamage ) {

      return ;

   }
   rotating_damage (other);
};


void  ()rotating_blocked =  {
   if ( !other.takedamage ) {

      return ;

   }
   rotating_damage (other);
   if ( ((other.health > 100.00000) && !(other.flags2 & FL_ALIVE)) ) {

      self.avelocity = '0.00000 0.00000 0.00000';
      self.level = 0.00000;
      self.touch = SUB_Null;
      self.think = rotating_use;
      self.nextthink = (time + self.wait);

   }
};


void  ()func_rotating =  {
   if ( (self.spawnflags & 4.00000) ) {

      self.movedir = '0.00000 0.00000 1.00000';
   } else {

      if ( (self.spawnflags & 8.00000) ) {

         self.movedir = '1.00000 0.00000 0.00000';
      } else {

         self.movedir = '0.00000 1.00000 0.00000';

      }

   }
   if ( (self.spawnflags & 2.00000) ) {

      self.movedir = (self.movedir * -1.00000);

   }
   if ( (self.spawnflags & TOGGLE_REVERSE) ) {

      self.movedir = (self.movedir * -1.00000);

   }
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   self.classname = "rotating non-door";
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.use = rotating_use;
   self.blocked = rotating_blocked;
   self.touch = SUB_Null;
   if ( !self.speed ) {

      self.speed = 100.00000;

   }
   if ( !self.anglespeed ) {

      self.anglespeed = 10.00000;

   }
   if ( (self.dmg == 0.00000) ) {

      self.dmg = 2.00000;

   }
   if ( self.lifetime ) {

      if ( !self.wait ) {

         self.wait = 3.00000;

      }

   }
   self.noise1 = "doors/hydro1.wav";
   self.noise2 = "doors/hydro2.wav";
   precache_sound ("doors/hydro1.wav");
   precache_sound ("doors/hydro2.wav");
   if ( self.abslight ) {

      self.drawflags = (self.drawflags | MLS_ABSLIGHT);

   }
   if ( (self.spawnflags & ROTATE_BREAK) ) {

      if ( !self.thingtype ) {

         self.thingtype = THINGTYPE_WOOD;

      }
      if ( !self.health ) {

         if ( (self.thingtype == THINGTYPE_GLASS) ) {

            self.health = 25.00000;
         } else {

            if ( ((self.thingtype == THINGTYPE_GREYSTONE) || (self.thingtype == THINGTYPE_BROWNSTONE)) ) {

               self.health = 75.00000;
            } else {

               if ( (self.thingtype == THINGTYPE_WOOD) ) {

                  self.health = 50.00000;
               } else {

                  if ( (self.thingtype == THINGTYPE_METAL) ) {

                     self.health = 100.00000;
                  } else {

                     if ( (self.thingtype == THINGTYPE_FLESH) ) {

                        self.health = 30.00000;
                     } else {

                        self.health = 25.00000;

                     }

                  }

               }

            }

         }

      }
      self.takedamage = DAMAGE_YES;
      self.th_die = chunk_death;

   }
   if ( (self.spawnflags & KEEP_START) ) {

      self.o_angle = self.angles;

   }
   if ( (self.spawnflags & 1.00000) ) {

      self.use ();

   }
   if ( self.flags2 ) {

      self.touch = rotating_touch;

   }
};


void  ()trigger_find_owner =  {
local entity found;
   found = find (world, target, self.targetname);
   if ( (found == world) ) {

      remove (self);
   } else {

      self.owner = found;

   }
};


void  ()trigger_fan_blow_touch =  {
local vector blowdir = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local float blowhard = 0.00000;
local float blowdist = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (self.owner.origin == '0.00000 0.00000 0.00000') ) {

      org = ((self.owner.absmin + self.owner.absmax) * 0.50000);
   } else {

      org = self.owner.origin;

   }
   if ( (self.owner.avelocity_x != 0.00000) ) {

      blowhard = (self.owner.avelocity_x / 3.00000);
      blowdir = '0.00000 1.00000 0.00000';
      blowdist = fabs ((org_y - other.origin_y));
   } else {

      if ( (self.owner.avelocity_y != 0.00000) ) {

         blowhard = self.owner.avelocity_y;
         blowdir = '0.00000 0.00000 1.00000';
         blowdist = fabs ((org_z - other.origin_z));
      } else {

         if ( (self.owner.avelocity_z != 0.00000) ) {

            blowhard = (self.owner.avelocity_z / 3.00000);
            blowdir = '1.00000 0.00000 0.00000';
            blowdist = fabs ((org_x - other.origin_x));
         } else {

            return ;

         }

      }

   }
   if ( (blowdist < 100.00000) ) {

      blowdist = 0.00000;

   }
   if ( (blowhard > 0.00000) ) {

      blowhard -= blowdist;
      if ( (blowhard <= 0.00000) ) {

         return ;

      }
   } else {

      blowhard += blowdist;
      if ( (blowhard >= 0.00000) ) {

         return ;

      }

   }
   blowhard /= 10.00000;
   blowdir_x *= blowhard;
   if ( (blowdir_z < 0.00000) ) {

      blowdir_x *= 10.00000;

   }
   if ( (other.velocity != blowdir) ) {

      other.velocity += blowdir;

   }
   if ( (other.flags & FL_ONGROUND) ) {

      other.flags -= FL_ONGROUND;
      if ( (other.velocity_z == 0.00000) ) {

         other.velocity_z += 7.00000;

      }

   }
};


void  ()trigger_fan_blow =  {
   InitTrigger ();
   self.touch = trigger_fan_blow_touch;
   self.think = trigger_find_owner;
   self.nextthink = (time + 0.10000);
};


void  ()angletrigger_done =  {
   self.active = 0.00000;
};


void  ()angletrigger_blocked =  {
   T_Damage (other, self, self, self.dmg);
};


void  ()angletrigger_use =  {
local vector newvect = '0.00000 0.00000 0.00000';
   if ( self.active ) {

      return ;
   } else {

      self.active = 1.00000;

   }
   if ( (self.angles_x >= 360.00000) ) {

      self.angles_x -= 360.00000;
   } else {

      if ( (self.angles_x <= -360.00000) ) {

         self.angles_x += 360.00000;

      }

   }
   if ( (self.angles_y >= 360.00000) ) {

      self.angles_y -= 360.00000;
   } else {

      if ( (self.angles_y <= -360.00000) ) {

         self.angles_y += 360.00000;

      }

   }
   if ( (self.angles_z >= 360.00000) ) {

      self.angles_z -= 360.00000;
   } else {

      if ( (self.angles_z <= -360.00000) ) {

         self.angles_z += 360.00000;

      }

   }
   newvect = (self.movedir * self.cnt);
   if ( ((self.angles + newvect) == self.mangle) ) {

      self.aflag = 1.00000;
      SUB_UseTargets ();
   } else {

      if ( self.aflag ) {

         self.aflag = 0.00000;
         SUB_UseTargets ();

      }

   }
   SUB_CalcAngleMove ((self.angles + newvect), self.speed, angletrigger_done);
};


void  ()func_angletrigger =  {
local vector vec = '0.00000 0.00000 0.00000';
local vector cmins = '0.00000 0.00000 0.00000';
local vector cmaxs = '0.00000 0.00000 0.00000';
   if ( (self.spawnflags & 2.00000) ) {

      self.movedir = '0.00000 0.00000 1.00000';
   } else {

      if ( (self.spawnflags & 4.00000) ) {

         self.movedir = '1.00000 0.00000 0.00000';
      } else {

         self.movedir = '0.00000 1.00000 0.00000';

      }

   }
   if ( (self.spawnflags & 1.00000) ) {

      self.movedir = (self.movedir * -1.00000);

   }
   self.pos1 = self.angles;
   self.pos2 = (self.angles + (self.movedir * self.cnt));
   self.max_health = self.health;
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.classname = "angletrigger";
   self.aflag = 0.00000;
   if ( self.abslight ) {

      self.drawflags = (self.drawflags | MLS_ABSLIGHT);

   }
   if ( !self.speed ) {

      self.speed = 100.00000;

   }
   if ( (self.wait == 0.00000) ) {

      self.wait = 1.00000;

   }
   if ( !self.dmg ) {

      self.dmg = 2.00000;

   }
   precache_sound ("doors/hydro1.wav");
   precache_sound ("doors/hydro2.wav");
   precache_sound ("doors/basetry.wav");
   precache_sound ("doors/baseuse.wav");
   self.noise2 = "doors/hydro1.wav";
   self.noise1 = "doors/hydro2.wav";
   self.noise3 = "doors/basetry.wav";
   self.noise4 = "doors/baseuse.wav";
   self.blocked = angletrigger_blocked;
   self.use = angletrigger_use;
   if ( !self.targetname ) {

      self.touch = angletrigger_use;

   }
   self.active = 0.00000;
};

