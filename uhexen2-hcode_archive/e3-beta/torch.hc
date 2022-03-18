
void  ()light_torch_eqypt =  {
   precache_model2 ("models/egtorch.mdl");
   precache_model2 ("models/eflmtrch.mdl");
   precache_sound ("raven/flame1.wav");
   if ( self.targetname ) {

      self.use = torch_use;

   }
   self.mdl = "models/egtorch.mdl";
   self.weaponmodel = "models/eflmtrch.mdl";
   self.thingtype = THINGTYPE_WOOD;
   setsize (self, '-6.00000 -6.00000 -8.00000', '6.00000 6.00000 8.00000');
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   if ( (self.style >= 32.00000) ) {

      if ( !self.lightvalue2 ) {

         self.lightvalue2 = 11.00000;

      }
      if ( !self.fadespeed ) {

         self.fadespeed = 1.00000;

      }
      initialize_lightstyle ();
      self.think = torch_think;
      self.nextthink = (time + 1.00000);
   } else {

      setmodel (self, self.weaponmodel);

   }
   if ( (!self.health && !self.targetname) ) {

      makestatic (self);

   }
};


void  ()light_torch_castle =  {
   precache_model2 ("models/castrch.mdl");
   precache_model2 ("models/cflmtrch.mdl");
   precache_sound ("raven/flame1.wav");
   self.weaponmodel = "models/cflmtrch.mdl";
   self.mdl = "models/castrch.mdl";
   if ( self.targetname ) {

      self.use = torch_use;

   }
   self.thingtype = THINGTYPE_METAL;
   setsize (self, '-6.00000 -6.00000 -8.00000', '6.00000 6.00000 8.00000');
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   if ( (self.style >= 32.00000) ) {

      if ( !self.lightvalue2 ) {

         self.lightvalue2 = 11.00000;

      }
      if ( !self.fadespeed ) {

         self.fadespeed = 1.00000;

      }
      initialize_lightstyle ();
      self.think = torch_think;
      self.nextthink = (time + 1.00000);
   } else {

      setmodel (self, self.weaponmodel);

   }
   if ( (!self.health && !self.targetname) ) {

      makestatic (self);

   }
};


void  ()light_torch_meso =  {
   precache_model2 ("models/mesotrch.mdl");
   precache_model2 ("models/mflmtrch.mdl");
   precache_sound ("raven/flame1.wav");
   self.weaponmodel = "models/mflmtrch.mdl";
   self.mdl = "models/mesotrch.mdl";
   if ( self.targetname ) {

      self.use = torch_use;

   }
   self.thingtype = THINGTYPE_BROWNSTONE;
   setsize (self, '-12.00000 -12.00000 -16.00000', '12.00000 12.00000 16.00000');
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   if ( self.health ) {

      if ( !self.lightvalue2 ) {

         self.lightvalue2 = 11.00000;

      }
      if ( !self.fadespeed ) {

         self.fadespeed = 1.00000;

      }
      initialize_lightstyle ();
      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   if ( (self.style >= 32.00000) ) {

      self.think = torch_think;
      self.nextthink = (time + 1.00000);
   } else {

      setmodel (self, self.weaponmodel);

   }
   if ( (!self.health && !self.targetname) ) {

      makestatic (self);

   }
};


void  ()light_torch_rome =  {
   precache_model2 ("models/rometrch.mdl");
   precache_model2 ("models/rflmtrch.mdl");
   precache_sound ("raven/flame1.wav");
   self.weaponmodel = "models/rflmtrch.mdl";
   self.mdl = "models/rometrch.mdl";
   if ( self.targetname ) {

      self.use = torch_use;

   }
   self.thingtype = THINGTYPE_GREYSTONE;
   setsize (self, '-6.00000 -6.00000 -8.00000', '6.00000 6.00000 8.00000');
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   if ( (self.style >= 32.00000) ) {

      if ( !self.lightvalue2 ) {

         self.lightvalue2 = 11.00000;

      }
      if ( !self.fadespeed ) {

         self.fadespeed = 1.00000;

      }
      initialize_lightstyle ();
      self.think = torch_think;
      self.nextthink = (time + 1.00000);
   } else {

      setmodel (self, self.weaponmodel);

   }
   if ( (!self.health && !self.targetname) ) {

      makestatic (self);

   }
};

