float SPAWNFLAG_BUTTON_ACTIVATE   =  1.00000;
float FIRE_MULTIPLE   =  4.00000;
void  ()button_return;
void  ()pressure_use;
void  ()pressure_touch;
void  ()catapult_button_turn;
void  ()catapult_button_think;

void  ()button_wait =  {
   self.state = STATE_TOP;
   if ( (self.wait == -1.00000) ) {

      if ( self.active ) {

         self.nextthink = -1.00000;
      } else {

         self.nextthink = (self.ltime + 0.30000);

      }
   } else {

      self.nextthink = (self.ltime + self.wait);

   }
   self.think = button_return;
   activator = self.enemy;
   if ( self.active ) {

      SUB_UseTargets ();

   }
   self.frame = 1.00000;
};


void  ()button_done =  {
   self.state = STATE_BOTTOM;
};


void  ()button_return =  {
   self.state = STATE_DOWN;
   SUB_CalcMove (self.pos1, self.speed, button_done);
   self.frame = 0.00000;
   if ( self.health ) {

      self.takedamage = DAMAGE_NO_GRENADE;

   }
};


void  ()button_blocked =  {
};


void  ()button_fire =  {
   if ( !self.active ) {

      if ( (other.classname == "player") ) {

         centerprint (other, self.msg2);

      }
      return ;

   }
   if ( (self.state == STATE_UP) ) {

      return ;

   }
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   self.state = STATE_UP;
   SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void  ()button_use =  {
   if ( (other.classname == "trigger_activate") ) {

      if ( !self.active ) {

         self.active = 1.00000;
      } else {

         self.active = 0.00000;

      }
      return ;
   } else {

      if ( (other.classname == "trigger_deactivate") ) {

         self.active = 0.00000;
         return ;

      }

   }
   self.enemy = activator;
   button_fire ();
};


void  ()button_touch =  {
   if ( (!(other.flags & FL_PUSH) && (other.classname != "player")) ) {

      return ;

   }
   if ( (self.state == STATE_TOP) ) {

      return ;

   }
   self.enemy = other;
   button_fire ();
};


void  ()button_killed =  {
   self.enemy = damage_attacker;
   self.health = self.max_health;
   self.takedamage = DAMAGE_NO;
   button_fire ();
};


void  ()func_button =  {
local float gtemp = 0.00000;
local float ftemp = 0.00000;
   if ( (self.soundtype == 0.00000) ) {

      precache_sound ("buttons/airbut1.wav");
      self.noise = "buttons/airbut1.wav";

   }
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("buttons/switch21.wav");
      self.noise = "buttons/switch21.wav";

   }
   if ( (self.soundtype == 2.00000) ) {

      precache_sound ("buttons/switch02.wav");
      self.noise = "buttons/switch02.wav";

   }
   if ( (self.soundtype == 3.00000) ) {

      precache_sound ("buttons/switch04.wav");
      self.noise = "buttons/switch04.wav";

   }
   SetMovedir ();
   if ( self.abslight ) {

      self.drawflags = (self.drawflags | MLS_ABSLIGHT);

   }
   self.classname = "button";
   self.movetype = MOVETYPE_PUSH;
   self.solid = SOLID_BSP;
   setmodel (self, self.model);
   self.blocked = button_blocked;
   self.use = button_use;
   if ( self.health ) {

      self.max_health = self.health;
      if ( (self.spawnflags & FIRE_MULTIPLE) ) {

         self.th_pain = button_use;

      }
      self.th_die = button_killed;
      self.takedamage = DAMAGE_NO_GRENADE;

   }
   if ( !(self.spawnflags & 2.00000) ) {

      if ( !self.health ) {

         self.health = 10.00000;

      }
      self.touch = button_touch;

   }
   if ( !self.speed ) {

      self.speed = 40.00000;

   }
   if ( !self.wait ) {

      self.wait = 1.00000;

   }
   if ( !self.lip ) {

      self.lip = 4.00000;

   }
   if ( (self.spawnflags & SPAWNFLAG_BUTTON_ACTIVATE) ) {

      self.active = 0.00000;
   } else {

      self.active = 1.00000;

   }
   self.state = STATE_BOTTOM;
   self.pos1 = self.origin;
   self.pos2 = (self.pos1 + (self.movedir * (fabs ((self.movedir * self.size)) - self.lip)));
   self.ltime = time;
};


void  ()pressure_wait =  {
local vector org1 = '0.00000 0.00000 0.00000';
local vector org2 = '0.00000 0.00000 0.00000';
local vector destin1 = '0.00000 0.00000 0.00000';
local vector destin2 = '0.00000 0.00000 0.00000';
local vector bsize = '0.00000 0.00000 0.00000';
   bsize = (self.absmax - self.absmin);
   org1 = self.absmin;
   org1_x = ((self.absmin_x + self.absmax_x) * 0.50000);
   org1_y = ((self.absmin_y + self.absmax_y) * 0.50000);
   org2 = (self.absmax + '0.00000 0.00000 1.00000');
   org2_x = ((self.absmin_x + self.absmax_x) * 0.50000);
   org2_y = ((self.absmin_y + self.absmax_y) * 0.50000);
   destin1_x = ((bsize_x * -1.00000) / 2.00000);
   destin1_y = ((bsize_y * -1.00000) / 2.00000);
   destin1_z = 0.00000;
   destin2_x = ((bsize_x * 1.00000) / 2.00000);
   destin2_y = ((bsize_y * 1.00000) / 2.00000);
   destin2_z = 0.00000;
   tracearea (org1, org2, destin1, destin2, FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      self.aflag = 0.00000;
      pressure_use ();
      self.touch = pressure_touch;
      SUB_CalcMove (self.pos1, self.speed, SUB_Null);
      return ;
   } else {

      self.nextthink = (self.ltime + 0.10000);

   }
};


void  ()pressure_fire =  {
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   self.state = STATE_UP;
   self.touch = SUB_Null;
   SUB_UseTargets ();
   SUB_CalcMove (self.pos2, self.speed, pressure_wait);
};


void  ()pressure_use =  {
   if ( (other.classname == "trigger_activate") ) {

      if ( !self.active ) {

         self.active = 1.00000;
      } else {

         self.active = 0.00000;

      }
      return ;
   } else {

      if ( (other.classname == "trigger_deactivate") ) {

         self.active = 0.00000;
         return ;

      }

   }
   self.enemy = activator;
   pressure_fire ();
};


void  ()pressure_touch =  {
local vector org = '0.00000 0.00000 0.00000';
local vector destin = '0.00000 0.00000 0.00000';
local float len = 0.00000;
local float totalmass = 0.00000;
local entity head;
   org_x = self.origin_x;
   org_y = self.origin_y;
   org_z = self.absmax_z;
   destin_x = self.mins_x;
   destin_y = self.mins_y;
   destin_z = self.maxs_z;
   tracearea (org, (destin + '0.00000 0.00000 10.00000'), self.mins, destin, FALSE, self);
   if ( (trace_fraction < 1.00000) ) {

      org = ((self.absmax + self.absmin) * 0.50000);
      len = vlen ((self.absmax - self.absmin));
      head = findradius (org, len);
      do {

         totalmass += head.mass;
         head = head.chain;
      } while ( head );
      if ( (totalmass >= self.mass) ) {

         self.aflag = 1.00000;
         self.flags = 1.00000;
         self.touch = SUB_Null;
         pressure_use ();

      }

   }
};


void  ()pressure_blocked =  {
   return ;
};


void  ()func_pressure =  {
local float gtemp = 0.00000;
local float ftemp = 0.00000;
   if ( (self.soundtype == 0.00000) ) {

      precache_sound ("buttons/airbut1.wav");
      self.noise = "buttons/airbut1.wav";

   }
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("buttons/switch21.wav");
      self.noise = "buttons/switch21.wav";

   }
   if ( (self.soundtype == 2.00000) ) {

      precache_sound ("buttons/switch02.wav");
      self.noise = "buttons/switch02.wav";

   }
   if ( (self.soundtype == 3.00000) ) {

      precache_sound ("buttons/switch04.wav");
      self.noise = "buttons/switch04.wav";

   }
   SetMovedir ();
   self.movetype = MOVETYPE_PUSH;
   self.solid = SOLID_BSP;
   setmodel (self, self.model);
   self.blocked = pressure_blocked;
   self.use = pressure_use;
   self.touch = pressure_touch;
   self.ltime = time;
   if ( self.health ) {

      self.max_health = self.health;
      self.th_die = button_killed;
      self.takedamage = DAMAGE_NO_GRENADE;
   } else {

      self.touch = pressure_touch;

   }
   if ( !self.speed ) {

      self.speed = 40.00000;

   }
   if ( !self.wait ) {

      self.wait = 1.00000;

   }
   if ( !self.lip ) {

      self.lip = 4.00000;

   }
   if ( (self.spawnflags & SPAWNFLAG_BUTTON_ACTIVATE) ) {

      self.active = 0.00000;
   } else {

      self.active = 1.00000;

   }
   self.state = STATE_BOTTOM;
   self.pos1 = self.origin;
   self.pos2 = (self.pos1 + (self.movedir * (fabs ((self.movedir * self.size)) - self.lip)));
};

