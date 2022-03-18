float WHITE_PUFF   =  0.00000;
float RED_PUFF   =  1.00000;
float GREEN_PUFF   =  2.00000;
float GREY_PUFF   =  3.00000;

void  (vector spot)CreateBlueExplosion =  {
   starteffect (CE_BLUE_EXPLOSION, spot);
};


void  (vector spot)CreateLittleBlueFlash =  {
   starteffect (CE_SM_BLUE_FLASH, spot);
};


void  (vector spot)CreateBlueFlash =  {
   starteffect (CE_BLUE_FLASH, spot);
};


void  (vector spot)CreateWhiteFlash =  {
   starteffect (CE_WHITE_FLASH, spot);
};


void  (vector org)CreateWhiteSmoke =  {
   starteffect (CE_WHITE_SMOKE, org);
};


void  (vector org)CreateSlowWhiteSmoke =  {
   starteffect (CE_SLOW_WHITE_SMOKE, org);
};


void  (vector org)CreateRedSmoke =  {
   starteffect (CE_RED_SMOKE, org);
};


void  (vector org)CreateGreySmoke =  {
   starteffect (CE_GREY_SMOKE, org);
};


void  (vector org)CreateGreenSmoke =  {
   starteffect (CE_GREEN_SMOKE, org);
};


void  (vector spot)CreateLittleWhiteFlash =  {
   starteffect (CE_SM_WHITE_FLASH, spot);
};


void  (vector spot)CreateExplosion29 =  {
   starteffect (CE_BG_CIRCLE_EXP, spot);
};


void  (vector spot)CreateFireCircle =  {
   starteffect (CE_SM_CIRCLE_EXP, spot);
};


void  (vector spot)CreateRedSpark =  {
   starteffect (CE_REDSPARK, spot);
};


void  (vector spot)CreateGreenSpark =  {
   starteffect (CE_GREENSPARK, spot);
};


void  (vector spot)CreateBSpark =  {
   starteffect (CE_BLUESPARK, spot);
};


void  (vector spot)CreateSpark =  {
   starteffect (CE_YELLOWSPARK, spot);
};


void  (vector spot)CreateYRFlash =  {
   starteffect (CE_YELLOWRED_FLASH, spot);
};


void  ()splash_run =  {
local float result = 0.00000;
   result = AdvanceFrame (0.00000, 5.00000);
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = splash_run;
   if ( (result == AF_END) ) {

      self.nextthink = (time + HX_FRAME_TIME);
      self.think = SUB_Remove;

   }
};


void  (vector spot)CreateWaterSplash =  {
local entity newent;
   newent = spawn ();
   setmodel (newent, "models/wsplash.spr");
   setorigin (newent, spot);
   newent.movetype = MOVETYPE_NOCLIP;
   newent.solid = SOLID_NOT;
   newent.velocity = '0.00000 0.00000 0.00000';
   newent.nextthink = (time + 0.05000);
   newent.think = splash_run;
};


void  (vector org,vector vel,float damage,entity victim)SpawnPuff =  {
local float part_color = 0.00000;
local float rad = 0.00000;
   if ( ((victim.thingtype == THINGTYPE_FLESH) && (self.classname != "mummy")) ) {

      part_color = ((8.00000 * 16.00000) + 9.00000);
   } else {

      if ( ((victim.thingtype == THINGTYPE_GREYSTONE) || (victim.thingtype == THINGTYPE_BROWNSTONE)) ) {

         part_color = (256.00000 + (1.00000 * 16.00000));
      } else {

         if ( (victim.thingtype == THINGTYPE_METAL) ) {

            part_color = (256.00000 + (8.00000 * 15.00000));
         } else {

            if ( (victim.thingtype == THINGTYPE_WOOD) ) {

               part_color = (256.00000 + (5.00000 * 16.00000));
            } else {

               part_color = ((256.00000 + (3.00000 * 16.00000)) + 4.00000);

            }

         }

      }

   }
   rad = vlen (vel);
   if ( !rad ) {

      rad = ((random () * 10.00000) + 10.00000);

   }
   particle4 (org, rad, part_color, PARTICLETYPE_GRAV, (2.00000 * damage));
};


void  (vector spot)CreateRedFlash =  {
   starteffect (CE_RED_FLASH, spot);
};

void  ()DeathBubblesSpawn;

void  ()flash_remove =  {
   remove (self);
};


void  ()smoke_generator_use =  {
   self.use = smoke_generator_use;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( !self.wait ) {

      self.wait = 2.00000;

   }
   self.owner = other;
};


void  ()smoke_generator_run =  {
   if ( (self.thingtype == WHITE_PUFF) ) {

      CreateWhiteSmoke (self.origin);
   } else {

      if ( (self.thingtype == RED_PUFF) ) {

         CreateRedSmoke (self.origin);
      } else {

         if ( (self.thingtype == GREEN_PUFF) ) {

            CreateGreenSmoke (self.origin);
         } else {

            if ( (self.thingtype == GREY_PUFF) ) {

               CreateGreySmoke (self.origin);

            }

         }

      }

   }
   self.nextthink = (time + (random () * self.wait));
   self.think = smoke_generator_run;
};


void  ()fx_smoke_generator =  {
   setmodel (self, "models/null.spr");
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   setsize (self, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   self.th_die = SUB_Remove;
   if ( !self.targetname ) {

      self.nextthink = (time + HX_FRAME_TIME);

   }
   self.use = smoke_generator_use;
   if ( !self.wait ) {

      self.wait = 2.00000;

   }
   self.think = smoke_generator_run;
};


void  (vector org)fx_flash =  {
local entity newent;
   newent = spawn ();
   setmodel (newent, "models/s_bubble.spr");
   setorigin (newent, (org + '0.00000 0.00000 24.00000'));
   newent.movetype = MOVETYPE_NOCLIP;
   newent.solid = SOLID_NOT;
   newent.velocity = '0.00000 0.00000 0.00000';
   newent.nextthink = (time + 0.50000);
   newent.think = flash_remove;
   newent.classname = "bubble";
   newent.effects = EF_BRIGHTLIGHT;
   setsize (newent, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
};


void  ()friction_change_touch =  {
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (other.classname == "player") ) {

      other.friction = self.friction;

   }
};


void  ()fx_friction_change =  {
   self.movetype = MOVETYPE_NONE;
   self.owner = self;
   self.solid = SOLID_TRIGGER;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.modelindex = 0.00000;
   self.model = "";
   setsize (self, self.mins, self.maxs);
   self.touch = friction_change_touch;
};


void  ()explosion_done =  {
   self.effects = EF_DIMLIGHT;
};


void  ()explosion_use =  {
local vector vel = '0.00000 0.00000 0.00000';
   sound (self, CHAN_BODY, self.noise1, 1.00000, ATTN_NORM);
   particleexplosion (self.origin, self.color, self.exploderadius, self.counter);
};


void  ()fx_particle_explosion =  {
   self.effects = 0.00000;
   self.use = explosion_use;
   self.movetype = MOVETYPE_NOCLIP;
   self.owner = self;
   self.solid = SOLID_NOT;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   if ( (!self.color || (self.color > 254.00000)) ) {

      self.color = 101.00000;

   }
   if ( (self.soundtype > 2.00000) ) {

      self.soundtype = 0.00000;
   } else {

      if ( !self.soundtype ) {

         self.soundtype = 1.00000;

      }

   }
   if ( (self.soundtype == 0.00000) ) {

      self.noise1 = "misc/null.wav";
   } else {

      if ( (self.soundtype == 1.00000) ) {

         self.noise1 = "weapons/explode.wav";
      } else {

         if ( (self.soundtype == 2.00000) ) {

            self.noise1 = "weapons/grenade.wav";

         }

      }

   }
   self.exploderadius = (10.00000 - self.exploderadius);
   if ( ((self.exploderadius < 1.00000) || (self.exploderadius > 10.00000)) ) {

      self.exploderadius = 5.00000;

   }
   if ( ((self.counter < 1.00000) || (self.counter > 1024.00000)) ) {

      self.counter = 512.00000;

   }
};

