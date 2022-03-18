
void  ()SpitTouch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   damg = (12.00000 + (random () * 10.00000));
   damg = 0.00000;
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   T_RadiusDamage (self, self.owner, damg, other);
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   remove (self);
};


void  ()spit_1 =  [  0.0, spit_1] {
};


void  (vector offset)do_spit =  {
local entity missile;
local vector vec = '0.00000 0.00000 0.00000';
   self.last_attack = time;
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   setmodel (missile, "models/spit.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   makevectors (self.angles);
   setorigin (missile, (((self.origin + (offset_x * v_right)) + (offset_y * v_forward)) + (offset_z * v_up)));
   vec = ((self.enemy.origin - missile.origin) + self.enemy.proj_ofs);
   vec = normalize (vec);
   missile.velocity = (vec * 200.00000);
   missile.angles = vectoangles (('0.00000 0.00000 0.00000' - missile.velocity));
   missile.touch = SpitTouch;
   missile.think = spit_1;
   missile.nextthink = (time + 0.05000);
};

