float fam_start   =  82.00000;
float fam_end   =  97.00000;
float fam_speed   =  3.00000;
float FamRiderFrames [5]   = { 152.00000,
    120.00000,    0.00000,    136.00000,    50.00000};
float FH_STAGE_NORMAL   =  0.00000;
float FH_STAGE_BEGIN_REAR   =  1.00000;
float FH_STAGE_MIDDLE_REAR   =  2.00000;
float FH_STAGE_END_REAR   =  3.00000;
float FH_STAGE_ATTACK   =  4.00000;
float FH_STAGE_STANDING   =  5.00000;

void  (entity horse)create_famrider =  {
local entity rider;
   rider = spawn ();
   rider.solid = SOLID_NOT;
   rider.movetype = MOVETYPE_NONE;
   rider.origin = horse.origin;
   rider.angles = self.angles;
   setmodel (rider, "models/boss/famrider.mdl");
   rider.skin = 0.00000;
   horse.movechain = rider;
   rider.flags = (rider.flags | FL_MOVECHAIN_ANGLE);
};

void  ()famhorse_move;

void  ()famhorse_rear =  {
local float retval = 0.00000;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.monster_stage == FH_STAGE_BEGIN_REAR) ) {

      self.speed = (self.speed / 1.20000);
      riderpath_move (self.speed);
      retval = AdvanceFrame (50.00000, 65.00000);
      if ( (retval == AF_END) ) {

         self.monster_stage = FH_STAGE_MIDDLE_REAR;

      }
      self.movechain.frame = ((FamRiderFrames->1.00000) + (self.frame - 50.00000));
   } else {

      if ( (self.monster_stage == FH_STAGE_MIDDLE_REAR) ) {

         retval = AdvanceFrame (0.00000, 49.00000);
         if ( (retval == AF_END) ) {

            if ( ((self.enemy != world) && (random () < 0.70000)) ) {

               self.monster_stage = FH_STAGE_STANDING;
            } else {

               self.monster_stage = FH_STAGE_END_REAR;

            }

         }
         self.movechain.frame = ((FamRiderFrames->2.00000) + (self.frame - 0.00000));
      } else {

         if ( (self.monster_stage == FH_STAGE_END_REAR) ) {

            retval = AdvanceFrame (66.00000, 81.00000);
            if ( (retval == AF_END) ) {

               self.think = famhorse_move;
               self.monster_stage = FH_STAGE_NORMAL;
               self.speed = (fam_speed->self.rider_gallop_mode);
            } else {

               self.speed = (self.speed * 1.30000);

            }
            riderpath_move (self.speed);
            self.movechain.frame = ((FamRiderFrames->3.00000) + (self.frame - 66.00000));

         }

      }

   }
};


void  ()famhorse_move =  {
local float retval = 0.00000;
   self.think = famhorse_move;
   self.nextthink = (time + HX_FRAME_TIME);
   retval = AdvanceFrame ((fam_start->self.rider_gallop_mode), (fam_end->self.rider_gallop_mode));
   if ( !self.path_current ) {

      riderpath_init ();

   }
   riderpath_move (self.speed);
   if ( (retval == AF_BEGINNING) ) {

      retval = fabs (self.rider_y_change);
      self.frame = (fam_start->self.rider_gallop_mode);
      if ( ((retval < 1.00000) && (random () < 0.10000)) ) {

         self.think = famhorse_rear;
         self.monster_stage = FH_STAGE_BEGIN_REAR;

      }

   }
   if ( (self.monster_stage == FH_STAGE_ATTACK) ) {

      if ( (self.rider_gallop_mode == 0.00000) ) {

         self.movechain.frame = ((FamRiderFrames->4.00000) + (self.frame - (fam_start->self.rider_gallop_mode)));

      }
   } else {

      self.movechain.frame = ((FamRiderFrames->self.rider_gallop_mode) + (self.frame - (fam_start->self.rider_gallop_mode)));

   }
   if ( (retval == AF_END) ) {

      self.monster_stage = FH_STAGE_NORMAL;

   }
   if ( (fabs (((fam_speed->self.rider_gallop_mode) - self.speed)) < 0.20000) ) {

      self.speed = (fam_speed->self.rider_gallop_mode);
   } else {

      if ( ((fam_speed->self.rider_gallop_mode) > self.speed) ) {

         self.speed += 0.20000;
      } else {

         self.speed -= 0.20000;

      }

   }
};

void  ()rider_death;

void  ()rider_famine =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/boss/famhorse.mdl");
   precache_model2 ("models/boss/famrider.mdl");
   precache_model2 ("models/boss/shaft.mdl");
   precache_model2 ("models/boss/circle.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.yaw_speed = 2.00000;
   setmodel (self, "models/boss/famhorse.mdl");
   self.skin = 0.00000;
   setsize (self, '-55.00000 -55.00000 0.00000', '55.00000 55.00000 100.00000');
   self.health = 1.00000;
   self.takedamage = DAMAGE_YES;
   self.rider_gallop_mode = 0.00000;
   self.speed = (fam_speed->self.rider_gallop_mode);
   self.rider_path_distance = 200.00000;
   self.monster_stage = FH_STAGE_NORMAL;
   self.mass = 30000.00000;
   create_famrider (self);
   self.th_die = rider_die;
   self.think = famhorse_move;
   self.nextthink = (time + 0.20000);
};

