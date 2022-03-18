
void  ()ring_touch =  {
local entity stemp;
local float amount = 0.00000;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (other.health <= 0.00000) ) {

      return ;

   }
   amount = random ();
   if ( (amount < 0.50000) ) {

      sprint (other, STR_YOUPOSSESS);
      sprint (other, self.netname);
   } else {

      sprint (other, STR_THE);
      sprint (other, self.netname);
      sprint (other, STR_ISYOURS);

   }
   sprint (other, "\n");
   if ( deathmatch ) {

      self.mdl = self.model;
      self.nextthink = (time + 60.00000);
      self.think = SUB_regen;

   }
   sound (other, CHAN_VOICE, "items/ringpkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   self.model = string_null;
   if ( (self.classname == "Ring_Flight") ) {

      other.rings = (other.rings | RING_FLIGHT);
      other.flight_time = FLIGHT_TIME;
   } else {

      if ( (self.classname == "Ring_WaterBreathing") ) {

         other.rings = (other.rings | RING_WATER);
         other.water_time = WATER_TIME;
         if ( (other.watertype == CONTENT_WATER) ) {

            other.rings_active = (other.rings_active | RING_WATER);
            other.air_finished = (time + WATER_TIME);
            other.water_start = time;
            if ( (other.rings_low & RING_WATER) ) {

               other.rings_low = (other.rings_low - (other.rings_low | RING_WATER));

            }

         }
      } else {

         if ( (self.classname == "Ring_Absorption") ) {

            other.rings = (other.rings | RING_ABSORPTION);
            other.absorption_time = ABSORPTION_TIME;
         } else {

            if ( (self.classname == "Ring_Regeneration") ) {

               other.rings = (other.rings | RING_REGENERATION);
               other.regen_time = REGEN_TIME;
            } else {

               if ( (self.classname == "Ring_Turning") ) {

                  other.rings = (other.rings | RING_TURNING);
                  other.turn_time = TURNING_TIME;

               }

            }

         }

      }

   }
   activator = other;
   SUB_UseTargets ();
};


void  ()Ring_WaterBreathing =  {
   precache_model ("models/ringwb.mdl");
   setmodel (self, "models/ringwb.mdl");
   self.netname = STR_RINGWATERBREATHING;
   self.touch = ring_touch;
   StartItem ();
};


void  ()Ring_Flight =  {
   precache_model ("models/ringft.mdl");
   setmodel (self, "models/ringft.mdl");
   self.netname = STR_RINGFLIGHT;
   self.touch = ring_touch;
   StartItem ();
};


void  ()spawn_ring_abs =  {
   precache_model ("models/rngabs.mdl");
   setmodel (self, "models/rngabs.mdl");
   self.netname = STR_RINGMAGICABSORPTION;
   self.touch = ring_touch;
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   StartItem ();
};


void  ()Ring_Absorption =  {
   self.artifact_respawn = deathmatch;
   spawn_ring_abs ();
};


void  ()Ring_Regeneration =  {
   precache_model ("models/ringre.mdl");
   setmodel (self, "models/ringre.mdl");
   self.netname = STR_RINGREGENERATION;
   self.touch = ring_touch;
   StartItem ();
};


void  ()Ring_Turning =  {
   precache_model ("models/ringtn.mdl");
   setmodel (self, "models/ringtn.mdl");
   self.netname = STR_RINGTURNING;
   self.touch = ring_touch;
   StartItem ();
};

