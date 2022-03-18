
void  ()shardTouch =  {
local float damg = 0.00000;
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (pointcontents (self.origin) == CONTENT_SKY) ) {

      remove (self);
      return ;

   }
   damg = (5.00000 + (random () * 5.00000));
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   self.origin = (self.origin - (8.00000 * normalize (self.velocity)));
   remove (self);
};


void  ()shard_1 =  [  0.0, shard_1] {
};


void  (vector offset,float set_speed,vector dest_offset)do_shard =  {
local entity missile;
local vector vec = '0.00000 0.00000 0.00000';
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.health = 10.00000;
   setmodel (missile, "models/shardice.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   makevectors (self.angles);
   setorigin (missile, (((self.origin + (offset_x * v_right)) + (offset_y * v_forward)) + (offset_z * v_up)));
   vec = (((self.enemy.origin - missile.origin) + self.enemy.proj_ofs) + dest_offset);
   vec = normalize (vec);
   missile.velocity = (vec * set_speed);
   missile.angles = vectoangles (missile.velocity);
   missile.touch = shardTouch;
   missile.think = shard_1;
   missile.nextthink = (time + 0.05000);
};

