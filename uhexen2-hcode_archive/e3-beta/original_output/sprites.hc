
void  ()sprite_tree1 =  {
   precache_model ("gfx/tree1.spr");
   setmodel (self, "gfx/tree1.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.th_die = chunk_death;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-32.00000 -32.00000 -95.00000', '32.00000 32.00000 90.00000');
};


void  ()sprite_tree2 =  {
   precache_model ("gfx/tree2.spr");
   setmodel (self, "gfx/tree2.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.th_die = chunk_death;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-32.00000 -32.00000 -95.00000', '32.00000 32.00000 90.00000');
};


void  ()sprite_treetop =  {
   precache_model ("gfx/treetop.spr");
   setmodel (self, "gfx/treetop.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.angles_x = -90.00000;
   self.th_die = SUB_Null;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-32.00000 -32.00000 -95.00000', '32.00000 32.00000 90.00000');
};


void  ()sprite_backgrnd_1 =  {
   setmodel (self, "gfx/bckgrnd1.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.th_die = SUB_Null;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-32.00000 -32.00000 -16.00000', '32.00000 32.00000 16.00000');
};


void  ()sprite_backgrnd_2 =  {
   setmodel (self, "gfx/bckgrnd2.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.th_die = SUB_Null;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-32.00000 -32.00000 -16.00000', '32.00000 32.00000 16.00000');
};


void  ()sprite_moss1 =  {
   precache_model ("gfx/moss1.spr");
   setmodel (self, "gfx/moss1.spr");
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.th_die = SUB_Null;
   self.touch = SUB_Null;
   self.use = SUB_Null;
   setsize (self, '-16.00000 -16.00000 -10.00000', '16.00000 16.00000 10.00000');
};

