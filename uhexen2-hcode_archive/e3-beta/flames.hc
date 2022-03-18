void  (vector org)SpawnFlameAt;

void  ()FireFizzle =  {
   sound (self, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);
   DeathBubbles (1.00000);
   remove (self);
};


void  ()FireDie =  {
   T_RadiusDamage (self, self.owner, (((self.dmg - 1.00000) * 125.00000) + 25.00000), world);
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
   BecomeExplosion (FALSE);
   remove (self);
};


void  ()FireDamage =  {
local float damagemult = 0.00000;
   if ( (self.trigger_field.skin > 110.00000) ) {

      self.wait = 0.00000;
   } else {

      self.wait = (self.wait - 1.00000);

   }
   if ( ((self.trigger_field.classname == "player") && (self.owner.classname != "player")) ) {

      self.owner = self.trigger_field;

   }
   if ( (self.trigger_field.waterlevel > 2.00000) ) {

      if ( (self.trigger_field.watertype == CONTENT_LAVA) ) {

         if ( (self.trigger_field.classname == "player") ) {

            sprint (self.owner, self.trigger_field.netname);
            sprint (self.owner, " jumped out of the frying pan into the fire!\n");

         }
         self.trigger_field.effects = (self.trigger_field.effects - self.trigger_field.effects);
         self.trigger_field.onfire = 0.00000;
         FireDie ();
      } else {

         if ( (self.trigger_field.classname == "player") ) {

            sound (self.owner, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);
            sprint (self.owner, self.trigger_field.netname);

         }
         sprint (self.owner, " saved his ass by jumping in the water!\n");
         self.trigger_field.effects = (self.trigger_field.effects - self.trigger_field.effects);
         self.trigger_field.onfire = 0.00000;
         remove (self);

      }

   }
   if ( (((((self.waterlevel > 2.00000) || (self.watertype == CONTENT_WATER)) || (self.watertype == CONTENT_SLIME)) || (pointcontents (self.origin) == CONTENT_WATER)) || (pointcontents (self.origin) == CONTENT_SLIME)) ) {

      sound (self.owner, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);
      sprint (self.owner, "Fireball fizzled underwater\n");
      self.trigger_field.effects = (self.trigger_field.effects - self.trigger_field.effects);
      self.trigger_field.onfire = 0.00000;
      remove (self);

   }
   if ( (self.aflag != 5.00000) ) {

      if ( ((self.wait < 1.00000) || (self.trigger_field.health <= 0.00000)) ) {

         self.trigger_field.effects = (self.trigger_field.effects - self.trigger_field.effects);
         self.trigger_field.onfire = 0.00000;
         remove (self);

      }
   } else {

      if ( ((self.wait < 1.00000) || (self.trigger_field.health <= 6.00000)) ) {

         self.dmg = 2.00000;
         self.trigger_field.onfire = 0.00000;
         self.trigger_field.effects = (self.trigger_field.effects - self.trigger_field.effects);
         FireDie ();

      }

   }
   if ( (self.trigger_field.onfire > 0.50000) ) {

      self.trigger_field.onfire = 0.50000;

   }
   if ( !(self.trigger_field.flags & FL_FIRERESIST) ) {

      if ( (self.aflag > 0.10000) ) {

         damagemult = self.aflag;
      } else {

         damagemult = 0.10000;

      }
      if ( (self.trigger_field.flags & FL_FIREHEAL) ) {

         self.trigger_field.health = (self.trigger_field.health + ((2.00000 * damagemult) * self.trigger_field.onfire));
      } else {

         T_Damage (self.trigger_field, self, self.owner, (damagemult * self.trigger_field.onfire));

      }

   }
   if ( (self.trigger_field.health <= 17.00000) ) {

      if ( (self.trigger_field.thingtype == THINGTYPE_WOOD) ) {

         self.trigger_field.skin = 111.00000;
         self.trigger_field.deathtype = "burnt crumble";
      } else {

         if ( (self.trigger_field.thingtype == THINGTYPE_FLESH) ) {

            self.trigger_field.skin = 112.00000;
            self.trigger_field.deathtype = "burnt crumble";

         }

      }

   }
   if ( (random () < 0.50000) ) {

      SpawnFlameAt (self.origin);

   }
   self.origin = (self.trigger_field.origin + '0.00000 0.00000 6.00000');
   self.think = FireDamage;
   self.nextthink = (time + 0.10000);
};


void  ()FireTouch2 =  {
   self.trigger_field.effects = EF_BRIGHTLIGHT;
   if ( (self.trigger_field.onfire <= 0.00000) ) {

      self.trigger_field.onfire = 1.00000;

   }
   self.think = FireDamage;
   self.nextthink = time;
};


void  ()FireTouch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   if ( ((((other.takedamage && (other.thingtype != 1.00000)) && (other.thingtype != 0.00000)) && (other.thingtype != 3.00000)) && (other.skin < 111.00000)) ) {

      if ( other.onfire ) {

         other.onfire = (other.onfire + 0.10000);
         remove (self);
      } else {

         other.onfire = 0.10000;

      }
      sound (self, CHAN_WEAPON, "misc/combust.wav", 1.00000, ATTN_NORM);
      self.trigger_field = other;
      self.origin = (other.origin + '0.00000 0.00000 6.00000');
      if ( ((other.classname == "player") || (self.aflag == 5.00000)) ) {

         self.wait = 180.00000;
      } else {

         self.wait = 40.00000;

      }
      setsize (self, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      self.think = FireTouch2;
      self.nextthink = time;
      self.movetype = MOVETYPE_NOCLIP;
      self.velocity = '0.00000 0.00000 0.00000';
      self.avelocity = '0.00000 0.00000 1000.00000';
      if ( ((other.waterlevel < 2.00000) && (other.classname == "player")) ) {

         sprint (other, "You're burning up!\n");

      }
      return ;
   } else {

      if ( (self.movetype == MOVETYPE_FLYMISSILE) ) {

         FireDie ();

      }

   }
   sound (self, CHAN_WEAPON, "misc/fburn_sm.wav", 0.75000, ATTN_STATIC);
   SpawnPuff (self.origin, '0.00000 0.00000 0.00000', 10.00000, other);
   SpawnFlameAt (self.origin);
   if ( (self.velocity == '0.00000 0.00000 0.00000') ) {

      self.avelocity = '0.00000 0.00000 0.00000';

   }
   if ( (self.aflag == 5.00000) ) {

      self.trigger_field = self.enemy;
      self.nextthink = (time + 0.05000);
      self.think = FireTouch2;

   }
};


void  ()FireThink =  {
   if ( (((pointcontents (self.origin) == CONTENT_WATER) || (pointcontents (self.origin) == CONTENT_SLIME)) || (self.waterlevel > 2.00000)) ) {

      FireFizzle ();

   }
   self.attack_finished = (self.attack_finished + 0.10000);
   if ( (self.attack_finished > 5.00000) ) {

      if ( (self.model == "models/lavaball.spr") ) {

         FireDie ();
      } else {

         remove (self);

      }

   }
   self.nextthink = (time + 0.10000);
   self.think = FireThink;
};


void  (entity loser)SpawnFlameOn =  {
local entity fire;
   if ( (pointcontents (loser.origin) < -2.00000) ) {

      return ;

   }
   if ( (pointcontents (self.origin) < -2.00000) ) {

      sound (self, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);
      return ;

   }
   fire = spawn ();
   fire.controller = self;
   fire.movetype = MOVETYPE_FLYMISSILE;
   fire.solid = SOLID_BBOX;
   fire.classname = "fire";
   fire.dmg = 1.00000;
   fire.aflag = 0.25000;
   fire.avelocity = '300.00000 300.00000 300.00000';
   fire.touch = FireTouch;
   fire.nextthink = (time + 0.10000);
   fire.think = FireThink;
   setmodel (fire, "models/null.spr");
   setsize (fire, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   if ( (self.classname == "archvile") ) {

      fire.enemy = self;
      setorigin (fire, self.origin);
      fire.owner = world;
   } else {

      if ( ((self.classname == "fireballblast") || (self.classname == "flaming arrow")) ) {

         fire.enemy = loser;
         setorigin (fire, loser.origin);
         fire.owner = self;
      } else {

         setorigin (fire, self.enemy.origin);
         fire.enemy = self.enemy;
         fire.owner = self.controller;

      }

   }
};


void  (vector org)SpawnFlameAt =  {
local entity fireflame;
local float xorg = 0.00000;
local float yorg = 0.00000;
local float zorg = 0.00000;
   if ( (pointcontents (self.origin) < -2.00000) ) {

      return ;

   }
   fireflame = spawn ();
   setmodel (fireflame, "models/flame2.mdl");
   fireflame.movetype = MOVETYPE_FLY;
   fireflame.solid = SOLID_NOT;
   fireflame.classname = "missile";
   fireflame.drawflags = MLS_ABSLIGHT;
   fireflame.abslight = 0.50000;
   fireflame.frame = rint ((random () * 1.00000));
   setsize (fireflame, '-2.00000 -2.00000 -2.00000', '1.00000 1.00000 1.00000');
   xorg = ((random () * 30.00000) - 15.00000);
   yorg = ((random () * 30.00000) - 15.00000);
   zorg = ((random () * 50.00000) - 25.00000);
   setorigin (fireflame, (((org + (v_forward * xorg)) + (v_right * yorg)) + (v_up * zorg)));
   fireflame.velocity_x = (fireflame.velocity_x + ((80.00000 * random ()) - 40.00000));
   fireflame.velocity_y = (fireflame.velocity_y + ((80.00000 * random ()) - 40.00000));
   fireflame.velocity_z = (fireflame.velocity_z + (300.00000 * random ()));
   fireflame.avelocity = '0.00000 0.00000 0.00000';
   if ( (random () < 0.30000) ) {

      sound (self, CHAN_WEAPON, "misc/fburn_sm.wav", 1.00000, ATTN_NORM);

   }
   fireflame.nextthink = (time + 0.50000);
   fireflame.think = SUB_Remove;
};


void  ()FlameTouch =  {
local float rn = 0.00000;
   if ( other.takedamage ) {

      if ( (other.flags & FL_FIREHEAL) ) {

         other.health = (other.health + 1.00000);
      } else {

         if ( !(other.flags & FL_FIRERESIST) ) {

            T_Damage (other, self, self.owner, 5.00000);

         }

      }
      if ( ((other.thingtype == THINGTYPE_FLESH) || (other.thingtype == THINGTYPE_WOOD)) ) {

         rn = random ();
         if ( ((rn <= 0.50000) || (other.onfire >= 1.00000)) ) {

            if ( other.onfire ) {

               other.onfire = (other.onfire + 0.10000);

            }
            remove (self);

         }
         other.onfire = (other.onfire + 0.10000);
         if ( (self.owner.movetype == MOVETYPE_NONE) ) {

            self.wait = 20.00000;
         } else {

            self.wait = 60.00000;

         }
         self.aflag = 0.10000;
         self.trigger_field = other;
         self.think = FireTouch2;
         self.nextthink = time;
         self.solid = SOLID_NOT;
         setmodel (self, "models/flame2.mdl");
      } else {

         if ( (self.netname == "firespike") ) {

            remove (self);

         }

      }
   } else {

      if ( (self.netname == "firespike") ) {

         if ( ((other.thingtype == THINGTYPE_FLESH) || (other.thingtype == THINGTYPE_WOOD)) ) {

            SpawnFlameAt (self.origin);

         }
         remove (self);
      } else {

         self.velocity = '0.00000 0.00000 0.00000';
         self.velocity_z = ((random () * 24.00000) + 24.00000);

      }

   }
};


void  (float offset)W_FireFlame =  {
local entity flame;
local float rn = 0.00000;
   if ( (self.movetype != MOVETYPE_NONE) ) {

      if ( (self.waterlevel > 2.00000) ) {

         rn = random ();
         if ( (rn < 0.50000) ) {

            sound (self, CHAN_WEAPON, "player/swim1.wav", 1.00000, ATTN_NORM);
         } else {

            sound (self, CHAN_WEAPON, "player/swim2.wav", 1.00000, ATTN_NORM);

         }
         flame = spawn ();
         flame.owner = flame;
         setorigin (flame, (((self.origin + self.proj_ofs) + (v_forward * 32.00000)) + (v_up * ((random () * 16.00000) - 8.00000))));
         flame.think = DeathBubblesSpawn;
         flame.nextthink = time;
         return ;

      }
   } else {

      if ( (((random () >= 0.10000) && (random () >= 0.20000)) || !other.takedamage) ) {

         return ;

      }

   }
   sound (self, CHAN_WEAPON, "paladin/purfire.wav", 1.00000, ATTN_NORM);
   flame = spawn ();
   flame.owner = self;
   flame.movetype = MOVETYPE_FLYMISSILE;
   flame.solid = SOLID_BBOX;
   flame.classname = "fire";
   flame.drawflags = MLS_ABSLIGHT;
   flame.abslight = 0.50000;
   if ( (((self.classname == "player") && (self.playerclass == CLASS_PALADIN)) && (self.weapon == IT_WEAPON4)) ) {

      self.punchangle_x = -1.00000;
      setmodel (flame, "models/purfir1.mdl");
      flame.netname = "firespike";
   } else {

      setmodel (flame, "models/flame2.mdl");

   }
   setsize (flame, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   if ( (self.movetype == MOVETYPE_NONE) ) {

      flame.velocity = '0.00000 0.00000 100.00000';
      setorigin (flame, (self.origin + '0.00000 0.00000 16.00000'));
   } else {

      makevectors (self.v_angle);
      flame.velocity = (((normalize (v_forward) * 700.00000) + ((v_up * random ()) * 32.00000)) + (v_right * (((random () * offset) * 2.00000) - offset)));
      setorigin (flame, (((self.origin + self.proj_ofs) + (v_forward * 32.00000)) + (v_up * ((random () * 16.00000) - 8.00000))));

   }
   if ( (flame.netname == "firespike") ) {

      flame.angles = vectoangles (flame.velocity);

   }
   flame.touch = FlameTouch;
   flame.think = FireThink;
   flame.nextthink = time;
   self.attack_finished = (time + 0.10000);
};

