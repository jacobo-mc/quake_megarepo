
void  ()corpseblink =  {
   self.think = corpseblink;
   self.nextthink = (time + 0.10000);
   self.scale -= 0.10000;
   if ( (self.scale < 0.10000) ) {

      remove (self);

   }
};


void  ()init_corpseblink =  {
   CreateYRFlash (self.origin);
   self.drawflags += DRF_TRANSLUCENT;
   self.drawflags = ((self.drawflags & SCALE_TYPE_MASKOUT) | SCALE_TYPE_ZONLY);
   self.drawflags += SCALE_ORIGIN_BOTTOM;
   self.scale = 1.00000;
   corpseblink ();
};


void  ()CorpsePain =  {
local vector org = '0.00000 0.00000 0.00000';
   if ( (self.onfire == 0.00000) ) {

      org = ((self.absmin + self.absmax) * 0.50000);
      particle4 (org, 20.00000, 236.00000, 6.00000, 10.00000);

   }
};


void  ()CorpseMove =  {
   if ( ((((other.origin_z > (self.origin_z + 10.00000)) && !(other.flags & FL_ONGROUND)) && other.health) && (other.velocity_z < 1.00000)) ) {

      other.flags = (other.flags + FL_ONGROUND);

   }
   if ( (other.takedamage != DAMAGE_YES) ) {

      self.velocity = '0.00000 0.00000 0.00000';
      return ;

   }
   if ( (other.classname == "corpse") ) {

      self.velocity_x = other.velocity_x;
      self.velocity_y = other.velocity_y;
   } else {

      self.velocity_x = (other.velocity_x / 3.00000);
      self.velocity_y = (other.velocity_y / 3.00000);
      if ( (((other.classname == "player") && (self.origin_z > other.origin_z)) && (other.velocity_z > 0.00000)) ) {

         self.velocity_z = other.velocity_z;

      }
      self.velocity = (self.velocity + '0.00000 0.00000 7.00000');

   }
   if ( (self.flags & FL_ONGROUND) ) {

      self.flags = (self.flags - FL_ONGROUND);

   }
};


void  ()CorpseDie =  {
local float i = 0.00000;
local float j = 0.00000;
   sound (self, CHAN_VOICE, "player/gib2.wav", 1.00000, ATTN_NORM);
   i = 0.00000;
   while ( (i < 3.00000) ) {

      j = random ();
      if ( (j > 0.60000) ) {

         ThrowGib ("models/gib3.mdl", self.health);
      } else {

         if ( (j > 0.30000) ) {

            ThrowGib ("models/gib3.mdl", self.health);
         } else {

            ThrowGib ("models/gib3.mdl", self.health);

         }

      }
      i = (i + 1.00000);

   }
   if ( (!self.decap && (self.netname != "remove")) ) {

      ThrowSolidHead (self.netname, self.health);
   } else {

      remove (self);

   }
};


void  ()CorpseOnlyDie =  {
local float i = 0.00000;
local float j = 0.00000;
   sound (self, CHAN_VOICE, "player/gib2.wav", 1.00000, ATTN_NORM);
   i = 0.00000;
   while ( (i < 3.00000) ) {

      j = random ();
      if ( (j > 0.60000) ) {

         ThrowGib ("model/gib3.mdl", (self.health * 5.00000));
      } else {

         if ( (j > 0.30000) ) {

            ThrowGib ("model/gib3.mdl", (self.health * 5.00000));
         } else {

            ThrowGib ("model/gib3.mdl", (self.health * 5.00000));

         }

      }
      i = (i + 1.00000);

   }
   if ( (!self.decap && (self.netname != "remove")) ) {

      ThrowSolidHead (self.netname, (self.health * 5.00000));
   } else {

      remove (self);

   }
};


void  ()Spurt =  {
local float bloodleak = 0.00000;
   makevectors (self.angles);
   bloodleak = (rint ((random () * 5.00000)) + 3.00000);
   SpawnPuff (((self.origin + (v_forward * 24.00000)) + '0.00000 0.00000 -22.00000'), ('0.00000 0.00000 -5.00000' + (v_forward * ((random () * 20.00000) + 20.00000))), bloodleak, self);
   sound (self, CHAN_AUTO, "misc/decomp.wav", 0.30000, ATTN_NORM);
   if ( ((self.lifetime < time) || (self.watertype == CONTENT_LAVA)) ) {

      T_Damage (self, world, world, self.health);

   }
   self.think = Spurt;
   self.nextthink = ((time + (random () * 5.00000)) + 0.50000);
};


void  ()CorpseThink =  {
   self.think = CorpseThink;
   self.nextthink = (time + 3.00000);
   if ( (self.watertype == CONTENT_LAVA) ) {

      T_Damage (self, self, self, self.health);

   }
   if ( (self.lifetime < time) ) {

      if ( ((self.scale == 0.00000) || (self.scale == 1.00000)) ) {

         init_corpseblink ();
      } else {

         remove (self);

      }

   }
};


void  (string headmdl)MakeSolidCorpse =  {
   self.th_stand = SUB_Null;
   self.th_walk = SUB_Null;
   self.th_run = SUB_Null;
   self.th_pain = CorpsePain;
   self.th_melee = SUB_Null;
   self.th_missile = SUB_Null;
   self.th_die = chunk_death;
   self.touch = CorpseMove;
   self.health = 25.00000;
   self.takedamage = DAMAGE_YES;
   self.solid = SOLID_PHASE;
   if ( (self.classname != "hydra") ) {

      self.movetype = MOVETYPE_STEP;

   }
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 5.00000');
   if ( (self.flags & FL_ONGROUND) ) {

      self.flags = (self.flags - (self.flags & FL_ONGROUND));

   }
   self.flags = (self.flags & !FL_MONSTER);
   self.controller = self;
   self.netname = headmdl;
   self.onfire = FALSE;
   if ( (deathmatch || teamplay) ) {

      self.lifetime = ((time + (random () * 20.00000)) + 20.00000);
   } else {

      self.lifetime = ((time + (random () * 10.00000)) + 10.00000);

   }
   if ( (self.decap && (self.classname == "player")) ) {

      self.owner = self;
      self.think = Spurt;
      self.nextthink = ((time + (random () * 3.00000)) + 1.00000);
   } else {

      self.think = CorpseThink;
      self.nextthink = time;

   }
};

