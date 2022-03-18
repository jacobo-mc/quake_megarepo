
void  ()faBladeTouch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   damg = (12.00000 + (random () * 10.00000));
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   remove (self);
};


void  ()frame_BLADE =  [  0.0, frame_BLADE] {
};


void  (vector offset,float set_speed,vector dest_offset)do_faBlade =  {
local entity missile;
local vector vec = '0.00000 0.00000 0.00000';
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.flags = FL_FLY;
   missile.health = 10.00000;
   setmodel (missile, "models/fablade.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   makevectors (self.angles);
   setorigin (missile, (((self.origin + (offset_x * v_right)) + (offset_y * v_forward)) + (offset_z * v_up)));
   vec = (((self.enemy.origin - missile.origin) + self.enemy.proj_ofs) + dest_offset);
   vec = normalize (vec);
   missile.velocity = (vec * set_speed);
   missile.angles = vectoangles (missile.velocity);
   missile.touch = faBladeTouch;
};

