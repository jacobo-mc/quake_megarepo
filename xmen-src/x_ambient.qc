void() ambient_water_leaky_pipe =
{
   precache_sound ("ambience/water/leakpipe.wav");
   ambientsound (self.origin, "ambience/water/leaky_pipe.wav", 1, ATTN_STATIC);
};

void() ambient_water_sewer =
{
   precache_sound ("ambience/water/sewer.wav");
   ambientsound (self.origin, "ambience/water/sewer.wav", 1, ATTN_STATIC);
};

void() ambient_water_flow_light =
{
   precache_sound ("ambience/water/flowlght.wav");
   ambientsound (self.origin, "ambience/water/flowlght.wav", 1, ATTN_STATIC);
};

void() ambient_water_stream_heavy =
{
   precache_sound ("ambience/water/strmhvy.wav");
   ambientsound (self.origin, "ambience/water/strmhvy.wav", 1, ATTN_STATIC);
};

void() ambient_water_stream_light =
{
   precache_sound ("ambience/water/strmlght.wav");
   ambientsound (self.origin, "ambience/water/strmlght.wav", 1, ATTN_STATIC);
};

void() ambient_water_tunnel_light =
{
   precache_sound ("ambience/water/tnnl_lt.wav");
   ambientsound (self.origin, "ambience/water/tnnl_lt.wav", 1, ATTN_STATIC);
};

void() ambient_airhose =
{
   precache_sound ("ambience/airhose.wav");
   ambientsound (self.origin, "ambience/airhose.wav", 1, ATTN_STATIC);
};

void() ambient_drill =
{
   precache_sound ("ambience/drill_x.wav");
   ambientsound (self.origin, "ambience/drill_x.wav", 1, ATTN_STATIC);
};

void() xmen_ambient =
{
   precache_sound (self.noise);
   ambientsound (self.origin, self.noise, 1, ATTN_STATIC);
};