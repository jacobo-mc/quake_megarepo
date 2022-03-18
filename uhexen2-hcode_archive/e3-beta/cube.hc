
float  ()cube_find_target =  {
local entity item;
local vector vec = '0.00000 0.00000 0.00000';
local vector realVec = '0.00000 0.00000 0.00000';
local float diff = 0.00000;
   item = findradius (self.origin, 500.00000);
   while ( item ) {

      if ( ((item.flags & FL_MONSTER) && (item.health > 0.00000)) ) {

         self.enemy = item;
         return ( TRUE );

      }
      item = item.chain;

   }
   return ( FALSE );
};

void  (vector offset)do_fireball;

void  ()cube_fire =  {
local float Distance = 0.00000;
local entity temp;
   if ( ((time > self.health) || (self.owner.health <= 0.00000)) ) {

      self.owner.artifact_flags = (self.owner.artifact_flags - self.artifact_flags);
      remove (self);
      return ;

   }
   if ( !self.enemy ) {

      self.cnt = (self.cnt + 1.00000);
      if ( (self.cnt > 5.00000) ) {

         cube_find_target ();
         self.cnt = 0.00000;

      }

   }
   if ( self.enemy ) {

      if ( (self.enemy.health <= 0.00000) ) {

         self.enemy = world;

      }

   }
   if ( self.enemy ) {

      if ( (random () < 0.01000) ) {

         Distance = vlen ((self.origin - self.enemy.origin));
         if ( (Distance > 600.00000) ) {

            self.enemy = world;
         } else {

            temp = self.owner;
            self.owner = self;
            tracearea (self.origin, self.enemy.origin, self.mins, self.maxs, FALSE, self);
            if ( (trace_ent == self.enemy) ) {

               do_fireball ('0.00000 0.00000 0.00000');

            }
            self.owner = temp;

         }

      }

   }
};

float CubeRate   =  6.00000;

void  ()CubeThinkerB =  {
local vector NewSpot = '0.00000 0.00000 0.00000';
local vector Diff = '0.00000 0.00000 0.00000';
local vector Direction = '0.00000 0.00000 0.00000';
   cube_fire ();
   self.angles = self.owner.angles;
   self.count = ((self.count + 4.00000) + (random () * 2.00000));
   if ( (self.count > 360.00000) ) {

      self.count = (self.count - 360.00000);

   }
   makevectors (self.owner.angles);
   if ( (self.artifact_flags & AFL_CUBE_LEFT) ) {

      NewSpot = (((self.owner.origin + (v_forward * 90.00000)) + (v_right * 60.00000)) + (v_up * 40.00000));
   } else {

      NewSpot = (((self.owner.origin + (v_forward * 90.00000)) - (v_right * 60.00000)) + (v_up * 40.00000));

   }
   NewSpot = (NewSpot + ((v_right * cos (self.count)) * 20.00000));
   NewSpot = (NewSpot + ((v_up * sin (self.count)) * 20.00000));
   self.movedir_z = ((self.movedir_z + 10.00000) + (random () * 2.00000));
   if ( (self.movedir_z > 360.00000) ) {

      self.movedir_z = (self.movedir_z - 360.00000);

   }
   NewSpot = (NewSpot + ((v_forward * sin (self.movedir_z)) * 20.00000));
   Diff = (NewSpot - self.origin);
   if ( (Diff_x > CubeRate) ) {

      Diff_x = CubeRate;

   }
   if ( (Diff_x < (0.00000 - CubeRate)) ) {

      Diff_x = (0.00000 - CubeRate);

   }
   if ( (Diff_y > CubeRate) ) {

      Diff_y = CubeRate;

   }
   if ( (Diff_y < (0.00000 - CubeRate)) ) {

      Diff_y = (0.00000 - CubeRate);

   }
   if ( (Diff_z > CubeRate) ) {

      Diff_z = CubeRate;

   }
   if ( (Diff_z < (0.00000 - CubeRate)) ) {

      Diff_z = (0.00000 - CubeRate);

   }
   NewSpot = (self.origin + Diff);
   setorigin (self, NewSpot);
   self.think = CubeThinkerB;
   self.nextthink = (time + 0.05000);
};


void  ()CubeThinkerA =  {
local vector NewSpot = '0.00000 0.00000 0.00000';
local vector Diff = '0.00000 0.00000 0.00000';
local vector Direction = '0.00000 0.00000 0.00000';
   cube_fire ();
   self.angles = self.owner.angles;
   self.count = (self.count + 4.00000);
   if ( (self.count > 360.00000) ) {

      self.count = (self.count - 360.00000);

   }
   makevectors (self.owner.angles);
   self.movedir_z = (self.movedir_z + 10.00000);
   if ( (self.movedir_z > 360.00000) ) {

      self.movedir_z = (self.movedir_z - 360.00000);

   }
   NewSpot_x = (self.owner.origin_x + (cos (self.count) * self.movedir_x));
   NewSpot_y = (self.owner.origin_y + (sin (self.count) * self.movedir_y));
   NewSpot_z = (self.owner.origin_z + (sin (self.movedir_z) * 10.00000));
   Diff = (NewSpot - self.origin);
   Direction = vectoangles (Diff);
   walkmove (Direction_y, 6.00000, FALSE);
   if ( (Diff_z > 10.00000) ) {

      Diff_z = 10.00000;

   }
   if ( (Diff_z < -10.00000) ) {

      Diff_z = -10.00000;

   }
   movestep (0.00000, 0.00000, Diff_z, FALSE);
   self.think = CubeThinkerA;
   self.nextthink = (time + 0.01000);
};


void  ()UseCubeOfForce =  {
local entity cube;
   if ( ((self.artifact_flags & AFL_CUBE_LEFT) && (self.artifact_flags & AFL_CUBE_RIGHT)) ) {

      return ;

   }
   cube = spawn ();
   cube.owner = self;
   cube.solid = SOLID_NOT;
   cube.movetype = MOVETYPE_NOCLIP;
   cube.flags = (FL_FLY | FL_NOTARGET);
   setorigin (cube, cube.owner.origin);
   setmodel (cube, "models/s_light.spr");
   setsize (cube, '-5.00000 -5.00000 -5.00000', '5.00000 5.00000 5.00000');
   cube.classname = "cube_of_force";
   if ( !(self.artifact_flags & AFL_CUBE_LEFT) ) {

      self.artifact_flags = (self.artifact_flags | AFL_CUBE_LEFT);
      cube.artifact_flags = AFL_CUBE_LEFT;
   } else {

      self.artifact_flags = (self.artifact_flags | AFL_CUBE_RIGHT);
      cube.artifact_flags = AFL_CUBE_RIGHT;

   }
   cube.think = CubeThinkerB;
   cube.nextthink = (time + 0.01000);
   cube.health = (time + 30.00000);
   cube.movedir = '100.00000 100.00000 0.00000';
   cube.count = (360.00000 * random ());
   self.movedir_z = (360.00000 * random ());
   self.cnt_cubeofforce = (self.cnt_cubeofforce - 1.00000);
};

