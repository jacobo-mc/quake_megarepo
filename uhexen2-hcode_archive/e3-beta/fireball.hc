
void  ()fireballTouch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   if ( self.dmg ) {

      damg = self.dmg;
   } else {

      damg = (12.00000 + (random () * 10.00000));

   }
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   T_RadiusDamage (self, self.owner, damg, other);
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
   remove (self);
};


void  ()fireball_1 =  [  0.0, fireball_2] {
   if ( (pointcontents (self.origin) != CONTENT_EMPTY) ) {

      FireFizzle ();

   }
};


void  ()fireball_2 =  [  1.0, fireball_3] {
};


void  ()fireball_3 =  [  2.0, fireball_4] {
};


void  ()fireball_4 =  [  3.0, fireball_5] {
};


void  ()fireball_5 =  [  4.0, fireball_6] {
};


void  ()fireball_6 =  [  5.0, fireball_7] {
};


void  ()fireball_7 =  [  6.0, fireball_8] {
};


void  ()fireball_8 =  [  7.0, fireball_9] {
};


void  ()fireball_9 =  [  8.0, fireball_10] {
};


void  ()fireball_10 =  [  9.0, fireball_1] {
};


void  (vector offset)do_fireball =  {
local entity missile;
local vector vec = '0.00000 0.00000 0.00000';
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.health = 10.00000;
   setmodel (missile, "models/fireball.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   makevectors (self.angles);
   setorigin (missile, ((((self.origin + self.view_ofs) + (offset_x * v_right)) + (offset_y * v_forward)) + (offset_z * v_up)));
   vec = ((self.enemy.origin - missile.origin) + self.enemy.view_ofs);
   vec = normalize (vec);
   missile.velocity = (vec * 500.00000);
   missile.angles = vectoangles (('0.00000 0.00000 0.00000' - missile.velocity));
   missile.touch = fireballTouch;
   missile.think = fireball_1;
   missile.nextthink = (time + 0.05000);
};

