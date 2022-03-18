
void  ()dust_touch =  {
local float numPuffs = 0.00000;
local float thisPuff = 0.00000;
local vector dustpos = '0.00000 0.00000 0.00000';
local vector dustvect = '0.00000 0.00000 0.00000';
   numPuffs = ((random () * 10.00000) + 2.00000);
   thisPuff = 1.00000;
   while ( (thisPuff < numPuffs) ) {

      if ( (random () < 0.50000) ) {

         dustpos_x = (self.maxs_x - (random () * 100.00000));
         dustpos_y = (self.maxs_y - (random () * 100.00000));
         dustpos_z = self.maxs_z;
      } else {

         dustpos_x = (self.mins_x + (random () * 100.00000));
         dustpos_y = (self.mins_y + (random () * 100.00000));
         dustpos_z = self.maxs_z;

      }
      if ( (dustpos_x < self.mins_x) ) {

         dustpos_x = self.mins_x;

      }
      if ( (dustpos_y < self.mins_y) ) {

         dustpos_y = self.mins_y;

      }
      if ( (dustpos_x > self.maxs_x) ) {

         dustpos_x = self.maxs_x;

      }
      if ( (dustpos_y > self.maxs_y) ) {

         dustpos_y = self.maxs_y;

      }
      dustvect_x = (random () * 20.00000);
      dustvect_y = (random () * 20.00000);
      dustvect_z = ((random () * 10.00000) * -1.00000);
      SpawnPuff (dustpos, dustvect, 414.00000, world);
      thisPuff += 1.00000;

   }
};


void  ()weather_dust =  {
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.modelindex = 0.00000;
   self.model = "";
   self.touch = dust_touch;
   self.use = dust_touch;
   if ( !self.color ) {

      self.color = 101.00000;

   }
};


void  ()rain_use =  {
   rain_go (self.mins, self.maxs, self.size, '125.00000 100.00000 0.00000', self.color, self.counter);
   self.nextthink = (time + self.wait);
};


void  ()weather_rain =  {
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.modelindex = 0.00000;
   self.model = "";
   if ( !self.wait ) {

      self.wait = 0.10000;

   }
   if ( !self.color ) {

      self.color = 101.00000;

   }
   if ( !self.counter ) {

      self.counter = 500.00000;

   }
   starteffect (CE_RAIN, self.mins, self.maxs, self.size, '125.00000 100.00000 0.00000', self.color, self.counter);
};


void  ()weather_lightning_use =  {
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
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_STREAM_LIGHTNING);
   WriteByte (MSG_BROADCAST, 1.00000);
   WriteByte (MSG_BROADCAST, 4.00000);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, p1_x);
   WriteCoord (MSG_BROADCAST, p1_y);
   WriteCoord (MSG_BROADCAST, p1_z);
   WriteCoord (MSG_BROADCAST, p2_x);
   WriteCoord (MSG_BROADCAST, p2_y);
   WriteCoord (MSG_BROADCAST, p2_z);
   LightningDamage (p1, p2, self, 10.00000, "lightning");
   if ( (self.lifetime > time) ) {

      self.nextthink = (time + 0.20000);
      return ;

   }
   if ( (self.wait > -1.00000) ) {

      self.nextthink = (time + self.wait);
      self.think = weather_lightning_use;
      self.lifetime = (self.lifespan + self.nextthink);

   }
};


void  ()lightning_init =  {
   if ( (self.lifetime > time) ) {

      return ;

   }
   self.think = weather_lightning_use;
   self.lifetime = (self.lifespan + time);
   weather_lightning_use ();
   fx_particle_explosion ();
};


void  ()weather_lightning_start =  {
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   if ( !self.noise ) {

      self.noise = "raven/lightng1.wav";

   }
   self.noise = "raven/lightng1.wav";
   precache_sound ("raven/lightng1.wav");
   self.use = lightning_init;
   self.think = weather_lightning_use;
   if ( (self.wait == 0.00000) ) {

      self.wait = 5.00000;

   }
   if ( (self.wait > -1.00000) ) {

      self.nextthink = (time + self.wait);
      self.lifetime = ((time + self.lifespan) + self.wait);

   }
};


void  ()weather_lightning_end =  {
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setorigin (self, self.origin);
   setsize (self, self.mins, self.maxs);
};

