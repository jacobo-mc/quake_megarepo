void  (string gibname,float dm)ThrowGib;
vector  (float dm)VelocityForDamage;

void  ()HeadDeath =  {
   ThrowGib ("models/gib1.mdl", self.health);
   sound (self, CHAN_VOICE, "misc/decomp.wav", 1.00000, ATTN_NORM);
   self.nextthink = time;
   self.think = SUB_Remove;
   self.movetype = MOVETYPE_BOUNCE;
   self.takedamage = DAMAGE_NO;
   self.solid = SOLID_NOT;
   self.th_die = SUB_Null;
   remove (self);
};


void  ()HeadPain =  {
local vector org = '0.00000 0.00000 0.00000';
   org = ((self.absmin + self.absmax) * 0.50000);
   particle4 (org, 20.00000, 236.00000, 6.00000, 10.00000);
};


void  ()HeadMove =  {
local float dir = 0.00000;
   if ( ((((other.origin_z > (self.origin_z + 10.00000)) && !(other.flags & FL_ONGROUND)) && other.health) && (other.velocity_z < 1.00000)) ) {

      other.flags = (other.flags + FL_ONGROUND);

   }
   if ( (other.takedamage != DAMAGE_YES) ) {

      return ;

   }
   if ( (other.classname == "player") ) {

      self.angles_x = (self.angles_x + (other.velocity_y / 7.00000));
      self.angles_z = (self.angles_z + (other.velocity_x / 7.00000));
      if ( ((self.origin_z > other.origin_z) && (other.velocity_z > 0.00000)) ) {

         self.velocity_z = other.velocity_z;

      }
      self.lifetime += (self.lifetime - time);

   }
   self.velocity_x = other.velocity_x;
   self.velocity_y = other.velocity_y;
   self.velocity = (self.velocity + '0.00000 0.00000 7.00000');
   if ( (self.flags & FL_ONGROUND) ) {

      self.flags = (self.flags - FL_ONGROUND);

   }
};


void  ()HeadThink =  {
local float hbob = 0.00000;
   if ( (((self.lifetime < time) && !deathmatch) || (self.watertype == CONTENT_LAVA)) ) {

      HeadDeath ();

   }
   self.think = HeadThink;
   self.nextthink = (time + 0.50000);
};


void  (string gibname,float dm)ThrowSolidHead =  {
   setmodel (self, gibname);
   self.th_stand = SUB_Null;
   self.th_walk = SUB_Null;
   self.th_run = SUB_Null;
   self.th_melee = SUB_Null;
   self.th_missile = SUB_Null;
   self.th_pain = HeadPain;
   self.frame = 0.00000;
   self.movetype = MOVETYPE_STEP;
   self.takedamage = DAMAGE_YES;
   self.solid = SOLID_PHASE;
   setsize (self, '-8.00000 -8.00000 -12.00000', '8.00000 8.00000 10.00000');
   if ( (dm != -666.00000) ) {

      self.velocity = VelocityForDamage (dm);

   }
   self.flags = (self.flags - (self.flags & FL_ONGROUND));
   self.health = 10.00000;
   self.th_die = HeadDeath;
   self.flags = (self.flags & !FL_MONSTER);
   self.angles_z = (random () * 600.00000);
   self.angles_x = (random () * 600.00000);
   self.angles_y = (random () * 600.00000);
   self.classname = "head";
   self.controller = self;
   self.touch = HeadMove;
   self.onfire = FALSE;
   self.lifetime = ((time + 25.00000) + (random () * 10.00000));
   if ( ((!deathmatch && !coop) && !teamplay) ) {

      self.think = HeadThink;
      self.nextthink = (time + 0.50000);
   } else {

      self.think = SUB_Null;
      self.nextthink = -1.00000;

   }
};

