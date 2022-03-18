float death_start   =  0.00000;
float death_end   =  11.00000;
float death_speed   =  12.00000;
float DeathRiderFrames [4]   = { 0.00000,
    12.00000,    19.00000,    20.00000};
float DH_STAGE_NORMAL   =  0.00000;
float DH_STAGE_ATTACK   =  4.00000;

void  (entity horse)create_deathrider =  {
local entity rider;
   rider = spawn ();
   rider.solid = SOLID_NOT;
   rider.movetype = MOVETYPE_NONE;
   rider.origin = horse.origin;
   rider.angles = self.angles;
   setmodel (rider, "models/boss/dthrider.mdl");
   rider.skin = 0.00000;
   horse.movechain = rider;
   rider.flags = (rider.flags | FL_MOVECHAIN_ANGLE);
};


void  ()deathhorse_move =  {
local float retval = 0.00000;
   self.think = deathhorse_move;
   self.nextthink = (time + HX_FRAME_TIME);
   retval = AdvanceFrame (death_start[self.rider_gallop_mode], death_end[self.rider_gallop_mode]);
   if ( !self.path_current ) {

      riderpath_init ();

   }
   riderpath_move (self.speed);
   if ( (retval == AF_BEGINNING) ) {

      retval = fabs (self.rider_y_change);
      self.frame = death_start[self.rider_gallop_mode];

   }
   if ( (self.monster_stage == DH_STAGE_ATTACK) ) {

      if ( (self.rider_gallop_mode == 0.00000) ) {

         self.movechain.frame = DeathRiderFrames[1] + (self.frame - death_start[self.rider_gallop_mode]);
         if (self.movechain.frame == DeathRiderFrames[2]) {

            waraxe (self.enemy, '3.00000 3.00000 82.00000', 1.00000);
         } else {

            if (self.movechain.frame == DeathRiderFrames[3]) {

               waraxe (self.enemy, '-3.00000 3.00000 70.00000', 1.00000);

            }

         }

      }
   } else {

      self.movechain.frame = DeathRiderFrames[self.rider_gallop_mode] + (self.frame - death_start[self.rider_gallop_mode]);

   }
   if ( (retval == AF_END) ) {

      self.monster_stage = DH_STAGE_NORMAL;

   }
   if (fabs(death_speed[self.rider_gallop_mode] - self.speed) < 0.20000) {

      self.speed = death_speed[self.rider_gallop_mode];
   } else {

      if (death_speed[self.rider_gallop_mode] > self.speed) {

         self.speed += 0.20000;
      } else {

         self.speed -= 0.20000;

      }

   }
};


void  ()rider_death =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/boss/dthhorse.mdl");
   precache_model2 ("models/boss/dthrider.mdl");
   precache_model2 ("models/boss/waraxe.mdl");
   precache_model2 ("models/boss/shaft.mdl");
   precache_model2 ("models/boss/circle.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_FLY;
   self.yaw_speed = 4.00000;
   setmodel (self, "models/boss/dthhorse.mdl");
   self.skin = 0.00000;
   self.flags = (self.flags | FL_FLY);
   setsize (self, '-55.00000 -55.00000 0.00000', '55.00000 55.00000 100.00000');
   self.health = 1.00000;
   self.takedamage = DAMAGE_YES;
   self.rider_gallop_mode = 0.00000;
   self.speed = death_speed[self.rider_gallop_mode];
   self.rider_path_distance = 100.00000;
   self.monster_stage = DH_STAGE_NORMAL;
   self.mass = 30000.00000;
   create_deathrider (self);
   self.th_die = rider_die;
   self.think = deathhorse_move;
   self.nextthink = (time + 0.20000);
};

