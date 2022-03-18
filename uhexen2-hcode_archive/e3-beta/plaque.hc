
void  (entity player,entity plaque)plaque_use =  {
   if ( !self.plaqueflg ) {

      self.plaqueflg = 1.00000;
      self.plaqueangle = self.angles;
      plaque_draw (plaque.message);
      if ( (plaque.noise1 != "") ) {

         sound (player, CHAN_VOICE, plaque.noise1, 1.00000, ATTN_NORM);
      } else {

         sound (player, CHAN_ITEM, plaque.noise, 1.00000, ATTN_NORM);

      }
   } else {

      self.plaqueflg = 0.00000;
      plaque_draw (string_null);

   }
};


void  ()plaque_touch =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
   if ( ((other.classname == "player") && !other.plaqueflg) ) {

      makevectors (other.v_angle);
      spot1 = ((other.origin + other.proj_ofs) + (v_up * 4.00000));
      spot2 = (spot1 + (v_forward * 25.00000));
      traceline (spot1, spot2, FALSE, other);
      if ( (trace_ent.classname == "plaque") ) {

         other.plaqueflg = 1.00000;
         other.plaqueangle = self.v_angle;
         plaque_draw (self.message);
         if ( (other.noise1 != "") ) {

            sound (other, CHAN_VOICE, self.noise1, 1.00000, ATTN_NORM);
         } else {

            sound (other, CHAN_ITEM, self.noise, 1.00000, ATTN_NORM);

         }

      }

   }
};


void  ()plaque =  {
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.solid = SOLID_SLIDEBOX;
   self.use = plaque_use;
   precache_sound ("raven/use_plaq.wav");
   self.noise = "raven/use_plaq.wav";
   self.touch = plaque_touch;
};

