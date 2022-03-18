
void  ()ResetWaypoints =  {
   self.controller.goalentity = self.controller.enemy;
   remove (self);
};


void  ()TransferWaypoint =  {
   if ( (self.goalentity.classname == "waypoint") ) {

      self.controller.goalentity = self.goalentity;
   } else {

      self.controller.goalentity = self.enemy;

   }
   remove (self);
};


void  ()WaypointTouch =  {
   if ( (other != self.controller) ) {

      return ;

   }
   if ( (self.controller.mintel >= self.point_seq) ) {

      TransferWaypoint ();
   } else {

      ResetWaypoints ();

   }
};


void  ()SetNextWaypoint =  {
local entity waypoint;
   if ( (visible (self.enemy) && (self.classname == "waypoint")) ) {

      self.wallspot = ((self.enemy.absmin + self.enemy.absmax) * 0.50000);
   } else {

      if ( ((self.lastwaypointspot != self.wallspot) && (((self.classname != "waypoint") && (self.mintel > 0.00000)) || ((self.classname == "waypoint") && (self.point_seq < self.controller.mintel)))) ) {

         self.lastwaypointspot = self.wallspot;
         waypoint = spawn ();
         waypoint.lockentity = self;
         waypoint.classname = "waypoint";
         waypoint.point_seq = (self.point_seq + 1.00000);
         waypoint.movetype = MOVETYPE_NONE;
         waypoint.solid = SOLID_TRIGGER;
         waypoint.touch = TransferWaypoint;
         waypoint.view_ofs = self.view_ofs;
         setmodel (waypoint, "models/null.spr");
         waypoint.effects = EF_NODRAW;
         setsize (waypoint, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
         setorigin (waypoint, self.wallspot);
         self.goalentity = waypoint;
         if ( (self.classname == "waypoint") ) {

            waypoint.controller = self.controller;
            self.enemy = self.controller.enemy;
         } else {

            waypoint.controller = self;

         }
         waypoint.enemy = self.enemy;
         waypoint.wallspot = ((waypoint.enemy.absmin + waypoint.enemy.absmax) * 0.50000);
         waypoint.think = SetNextWaypoint;
         waypoint.nextthink = time;
         waypoint.lifetime = (time + 30.00000);

      }

   }
   if ( (self.classname == "waypoint") ) {

      if ( (((self.controller.enemy != self.enemy) || !(self.enemy.flags2 & FL_ALIVE)) || !(self.controller.flags2 & FL_ALIVE)) ) {

         ResetWaypoints ();

      }
      if ( visible2ent (self.controller.enemy, self.controller) ) {

         dprint ("\n");
         ResetWaypoints ();

      }
      if ( (self.lockentity.goalentity != self) ) {

         remove (self);
      } else {

         if ( visible2ent (self.goalentity, self.controller) ) {

            if ( (self.controller.mintel >= self.point_seq) ) {

               TransferWaypoint ();
            } else {

               ResetWaypoints ();

            }
         } else {

            if ( ((vhlen ((self.origin - self.controller.origin)) < 36.00000) && visible2ent (self, self.controller)) ) {

               TransferWaypoint ();

            }

         }

      }
      self.think = SetNextWaypoint;
      if ( (self.lifetime < time) ) {

         self.nextthink = -1.00000;
      } else {

         self.nextthink = (time + 0.20000);

      }

   }
};

