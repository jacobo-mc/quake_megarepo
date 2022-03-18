void  (float num_bubbles)DeathBubbles;

float  ()Skip =  {
local vector dir1 = '0.00000 0.00000 0.00000';
local vector dir2 = '0.00000 0.00000 0.00000';
local float dot = 0.00000;
   dir1 = normalize (self.velocity);
   traceline ((self.origin - (dir1 * 4.00000)), (self.origin + (dir1 * 16.00000)), TRUE, self);
   dir2 = trace_plane_normal;
   dir1_x *= -1.00000;
   dot = (dir1 * dir2);
   if ( ((dot <= 0.15000) && (trace_fraction < 1.00000)) ) {

      return ( TRUE );
   } else {

      return ( FALSE );

   }
};


void  (float turn)Spiral =  {
local vector veerdir = '0.00000 0.00000 0.00000';
   veerdir_x = (((random () * 2.00000) * turn) - turn);
   veerdir_y = (((random () * 2.00000) * turn) - turn);
   veerdir_z = (((random () * 2.00000) * turn) - turn);
   self.velocity = (self.velocity + veerdir);
   self.angles = vectoangles (self.velocity);
};


void  (float amount)Veer =  {
local vector veerdir = '0.00000 0.00000 0.00000';
   veerdir_x = (((random () * amount) * 2.00000) - amount);
   veerdir_y = (((random () * amount) * 2.00000) - amount);
   veerdir_z = (((random () * amount) * 2.00000) - amount);
   self.velocity = (self.velocity + veerdir);
   self.angles = vectoangles (self.velocity);
};


void  ()VeerThink =  {
   Veer (self.veer);
   if ( (self.think == Veer) ) {

      self.nextthink = (time + 0.10000);

   }
};


float  (entity loser,entity from)ahead =  {
local vector proj_dir = '0.00000 0.00000 0.00000';
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local float accept = 0.00000;
local float dot = 0.00000;
   proj_dir = normalize (from.velocity);
   spot1 = from.origin;
   spot2 = ((loser.absmin + loser.absmax) * 0.50000);
   if ( (from.frags && !(from.flags & FL_CLIENT)) ) {

      accept = from.frags;
   } else {

      accept = 0.20000;

   }
   vec = normalize ((spot2 - spot1));
   dot = (vec * proj_dir);
   if ( (dot > accept) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity loser,entity from)heading =  {
local vector proj_dir = '0.00000 0.00000 0.00000';
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local float accept = 0.00000;
local float dot = 0.00000;
   proj_dir = normalize (from.velocity);
   spot1 = from.origin;
   spot2 = ((loser.absmin + loser.absmax) * 0.50000);
   accept = 0.80000;
   vec = normalize ((spot2 - spot1));
   dot = (vec * proj_dir);
   if ( (dot > accept) ) {

      return ( TRUE );

   }
   return ( FALSE );
};

void  ()HomeThink;

void  ()HomeFindTarget =  {
local entity loser;
local float dist = 0.00000;
local float bestdist = 0.00000;
   if ( (self.think != HomeThink) ) {

      bestdist = 5000.00000;
   } else {

      bestdist = 1000.00000;

   }
   loser = findradius (self.origin, bestdist);
   bestdist += 1.00000;
   while ( loser ) {

      if ( (((((((loser.health && loser.takedamage) && (loser.flags2 & FL_ALIVE)) && visible (loser)) && (loser != self)) && (loser != world)) && (loser != self.owner)) && !(loser.flags2 & FL_STONED)) ) {

         if ( ((!self.aflag || self.ideal_yaw) && !ahead (loser, self)) ) {

            dprint ("");
         } else {

            dist = vlen ((self.origin - loser.origin));
            if ( (dist < bestdist) ) {

               bestdist = dist;
               self.enemy = loser;

            }
            if ( (bestdist < 100.00000) ) {

               self.aflag = TRUE;
               return ( self.enemy );

            }

         }

      }
      loser = loser.chain;

   }
   self.aflag = TRUE;
   if ( self.enemy ) {

      return ( self.enemy );
   } else {

      return ( world );

   }
};


void  ()HomeThink =  {
local vector huntdir = '0.00000 0.00000 0.00000';
local float waterornot = 0.00000;
local vector olddir = '0.00000 0.00000 0.00000';
local float oldvelmult = 0.00000;
local float newveldiv = 0.00000;
   if ( (self.thingtype == THINGTYPE_FIRE) ) {

      waterornot = pointcontents (self.origin);
      if ( ((waterornot == CONTENT_WATER) || (waterornot == CONTENT_SLIME)) ) {

         DeathBubbles (1.00000);

      }

   }
   if ( (self.enemy != world) ) {

      if ( ((!visible (self.enemy) || !self.enemy.health) || !(self.enemy.flags2 & FL_ALIVE)) ) {

         self.oldenemy = self.enemy;
         self.enemy = world;

      }

   }
   if ( (self.enemy == world) ) {

      HomeFindTarget ();
      if ( (((((self.enemy == world) && (self.oldenemy != world)) && visible (self.oldenemy)) && self.oldenemy.health) && (self.oldenemy.flags2 & FL_ALIVE)) ) {

         self.enemy = self.oldenemy;

      }

   }
   if ( (self.enemy != world) ) {

      olddir = normalize (self.velocity);
      huntdir = ((self.enemy.absmin + self.enemy.absmax) * 0.50000);
      huntdir = normalize ((huntdir - self.origin));
      oldvelmult = self.turn_time;
      newveldiv = (1.00000 / (self.turn_time + 1.00000));
      if ( (self.velocity != (huntdir * self.speed)) ) {

         self.velocity = ((((olddir * oldvelmult) + huntdir) * newveldiv) * self.speed);

      }

   }
   if ( self.veer ) {

      Veer (self.veer);

   }
   if ( (self.think == HomeThink) ) {

      if ( (self.lifetime < time) ) {

         self.th_die ();
      } else {

         self.nextthink = (time + self.homerate);

      }

   }
};


void  ()SpiralThink =  {
   self.count = (self.count + (self.veer * 0.25000));
   if ( (((self.veer > 0.00000) && (self.count > self.veer)) || ((self.veer < 0.00000) && (self.count < self.veer))) ) {

      self.count = (0.00000 - self.veer);

   }
   Spiral (self.count);
   if ( ((random () < 0.20000) && (self.homerate > 0.00000)) ) {

      HomeThink ();

   }
   self.think = SpiralThink;
   self.nextthink = (time + 0.10000);
};


void  ()Missile_Arc =  {
local vector newpitch = '0.00000 0.00000 0.00000';
   self.velocity_z -= 60.00000;
   newpitch = vectoangles (self.velocity);
   self.angles_x = newpitch_x;
   self.think = Missile_Arc;
   self.nextthink = (time + 0.10000);
};

