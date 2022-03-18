
void  ()sound_ambient =  {
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("ambience/windmill.wav");
      self.noise1 = "ambience/windmill.wav";

   }
   ambientsound (self.origin, self.noise1, 1.00000, ATTN_STATIC);
};

