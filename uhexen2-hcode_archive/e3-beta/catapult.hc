
void  ()movechain_target =  {
local entity found;
   if ( self.target ) {

      found = find (world, targetname, self.target);
      if ( (found == self) ) {

         found = nextent (self);
         found = find (found, targetname, self.target);

      }
      self.movechain = found;
      if ( !(found.flags & FL_MOVECHAIN_ANGLE) ) {

         found.flags += FL_MOVECHAIN_ANGLE;

      }
   } else {

      dprint (self.classname);
      dprint (" has no target set\n");

   }
   self.nextthink = -1.00000;
};


void  ()BSP_stop =  {
   self.velocity = '0.00000 0.00000 0.00000';
   self.think = BSP_stop;
   self.nextthink = (time - 1.00000);
};


void  ()BSP_push =  {
local vector pos = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
   if ( ((other.absmin_z > (self.absmin_z + 4.00000)) || (vlen (other.velocity) < 150.00000)) ) {

      return ;

   }
   dir = normalize ((other.velocity + self.velocity));
   dir_z = 0.00000;
   pos = ((dir * 10.00000) + self.origin);
   SUB_CalcMove (pos, 10.00000, BSP_stop);
};


void  ()obj_stairs =  {
   if ( !self.thingtype ) {

      self.thingtype = THINGTYPE_WOOD;

   }
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   self.flags += FL_PUSH;
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   self.touch = BSP_push;
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
};


void  ()obj_bridge =  {
   if ( !self.thingtype ) {

      self.thingtype = THINGTYPE_WOOD;

   }
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;
      self.th_die = chunk_death;

   }
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_PUSHPULL;
   self.touch = obj_push;
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
};


void  ()catapult_button_turn =  {
};


void  ()catapult_button_think =  {
};

