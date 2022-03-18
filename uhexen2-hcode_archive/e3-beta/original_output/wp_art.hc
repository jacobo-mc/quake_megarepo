
void  ()wp_weapon2 =  {
   precache_model ("models/w_l2_c1.mdl");
   precache_model ("models/w_l2_c2.mdl");
   precache_model ("models/w_l2_c3.mdl");
   precache_model ("models/w_l2_c4.mdl");
   setmodel (self, "models/w_l2_c1.mdl");
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   self.flags = (self.flags | FL_CLASS_DEPENDENT);
   self.touch = weapon_touch;
   StartItem ();
};


void  ()wp_weapon3 =  {
   precache_model ("models/w_l3_c1.mdl");
   precache_model ("models/w_l3_c2.mdl");
   precache_model ("models/w_l3_c3.mdl");
   precache_model ("models/w_l3_c4.mdl");
   setmodel (self, "models/w_l3_c1.mdl");
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   self.flags = (self.flags | FL_CLASS_DEPENDENT);
   self.touch = weapon_touch;
   StartItem ();
};


void  ()wp_weapon4_head =  {
   precache_model ("models/w_l41_c1.mdl");
   precache_model ("models/w_l41_c2.mdl");
   precache_model ("models/w_l41_c3.mdl");
   precache_model ("models/w_l41_c4.mdl");
   setmodel (self, "models/w_l41_c1.mdl");
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   self.flags = (self.flags | FL_CLASS_DEPENDENT);
   self.touch = weapon_touch;
   StartItem ();
};


void  ()wp_weapon4_staff =  {
   precache_model ("models/w_l42_c1.mdl");
   precache_model ("models/w_l42_c2.mdl");
   precache_model ("models/w_l42_c3.mdl");
   precache_model ("models/w_l42_c4.mdl");
   setmodel (self, "models/w_l42_c1.mdl");
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   self.flags = (self.flags | FL_CLASS_DEPENDENT);
   self.touch = weapon_touch;
   StartItem ();
};

