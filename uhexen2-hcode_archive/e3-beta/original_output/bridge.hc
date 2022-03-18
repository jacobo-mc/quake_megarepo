
void  ()ropebridge_touch =  {
local entity link;
local float difference = 0.00000;
   if ( ((other.movetype != MOVETYPE_STEP) && (other.movetype != MOVETYPE_WALK)) ) {

      return ;

   }
   if ( (other == self.enemy) ) {

      return ;

   }
   link = self.owner.movechain;
   self.enemy = other;
   while ( (link != self) ) {

      link.dmg = (link.dmg - (link.cnt / self.cnt));
      link = link.movechain;

   }
   self.dmg = (self.dmg + self.cnt);
   difference = (1.00000 / (self.count - self.cnt));
   link = self.movechain;
   while ( link.movechain ) {

      link.dmg = (link.dmg - (difference * (self.count - link.cnt)));
      link = link.movechain;

   }
   link = self.owner.movechain;
   while ( link.movechain ) {

      link.oldorigin_z = link.dmg;
      setorigin (link, (link.origin + link.oldorigin));
      link = link.movechain;

   }
};


void  (entity focal)ropebridge_relieveweight =  {
local entity link;
   link = self.owner.movechain;
};


void  ()ropebridge_think =  {
local entity link;
   link = self.movechain;
   while ( link.movechain ) {

      if ( (link.enemy != world) ) {

         if ( !EntitiesTouching (link, link.enemy) ) {

            ropebridge_relieveweight (link);
            link.enemy = world;

         }

      }
      if ( link.t_length ) {

         setorigin (link, (link.origin + (link.movedir * link.yaw_speed)));
      } else {

         setorigin (link, (link.origin - (link.movedir * link.yaw_speed)));

      }
      if ( link.t_width ) {

         link.yaw_speed += 0.70000;
         if ( (link.yaw_speed >= link.speed) ) {

            link.t_width = 0.00000;
            link.yaw_speed = link.speed;

         }
      } else {

         link.yaw_speed -= 0.70000;
         if ( (link.yaw_speed < 0.00000) ) {

            link.t_length = 0.00000;
            link.t_width = 1.00000;
            link.yaw_speed = 0.00000;

         }

      }
      link = link.movechain;

   }
   self.nextthink = (time + 0.05000);
};


void  ()ropebridge_init =  {
local entity link;
local float midpoint = 0.00000;
local float thispoint = 0.00000;
   link = self;
   while ( link.target ) {

      if ( (link.classname != "ropebridge") ) {

         bprint ("Error: Rope bridge link ");
         bprint (ftos (self.count));
         bprint (" is targeted wrong\n");
         return ;

      }
      link.owner = self;
      link.movechain = find (world, targetname, link.target);
      link.cnt = self.count;
      link = link.movechain;
      self.count = (self.count + 1.00000);

   }
   link = self;
   midpoint = (self.count * 0.50000);
   thispoint = 1.00000;
   while ( (thispoint <= self.count) ) {

      if ( (thispoint < midpoint) ) {

         link.speed = sqrt ((thispoint - 1.00000));
      } else {

         link.speed = sqrt ((self.count - thispoint));

      }
      link.yaw_speed = link.speed;
      link.count = self.count;
      link = link.movechain;
      thispoint = (thispoint + 1.00000);

   }
   self.nextthink = (time + 0.05000);
   self.think = ropebridge_think;
};


void  ()ropebridge_link =  {
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   self.classname = "ropebridge";
   self.movedir = '0.00000 1.00000 -0.40000';
   setmodel (self, self.model);
   setorigin (self, self.origin);
   if ( self.spawnflags ) {

      self.count = 1.00000;
      self.nextthink = (time + 0.05000);
      self.think = ropebridge_init;
   } else {

      self.touch = ropebridge_touch;

   }
};

