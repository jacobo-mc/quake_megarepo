float REFLECT_RETURN   =  1.00000;
float REFLECT_TOGGLE   =  2.00000;
float REFLECT_START_OPEN   =  4.00000;
void  ()reflect_trigger_touch;
void  ()reflect_go_down;

entity  (vector fmins,vector fmaxs,entity door)reflect_spawn_field =  {
local entity trigger;
local vector t1 = '0.00000 0.00000 0.00000';
local vector t2 = '0.00000 0.00000 0.00000';
   trigger = spawn ();
   trigger.movetype = MOVETYPE_NOCLIP;
   trigger.solid = SOLID_TRIGGER;
   trigger.owner = self;
   trigger.touch = reflect_trigger_touch;
   t1 = fmins;
   t2 = fmaxs;
   setsize (trigger, (t1 - '30.00000 30.00000 30.00000'), (t2 + '30.00000 30.00000 30.00000'));
   return ( trigger );
};


void  ()reflect_crush =  {
   T_Damage (other, self, self, 20.00000);
};


void  ()reflect_touch =  {
local vector newv = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local vector endspot = '0.00000 0.00000 0.00000';
local vector endplane = '0.00000 0.00000 0.00000';
local vector dif = '0.00000 0.00000 0.00000';
local float remainder = 0.00000;
local float reflect_count = 0.00000;
local float magnitude = 0.00000;
   if ( ((other.movetype != MOVETYPE_FLYMISSILE) && (other.movetype != MOVETYPE_BOUNCEMISSILE)) ) {

      return ;

   }
   if ( ((other.safe_time > time) && self.active) ) {

      return ;

   }
   dir = normalize (other.velocity);
   magnitude = vlen (other.velocity);
   org = other.origin;
   vec = (org + (dir * 31.00000));
   traceline (org, vec, TRUE, other);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   endplane = trace_plane_normal;
   dir += (2.00000 * endplane);
   dir = normalize (dir);
   other.safe_time = (time + (100.00000 / magnitude));
   other.velocity = (dir * magnitude);
   other.angles = vectoangles (other.velocity);
};


void  ()reflect_trigger_touch =  {
   if ( self.active ) {

      reflect_touch ();

   }
};


void  ()reflect_hit_top =  {
   sound (self, CHAN_VOICE, self.noise1, 1.00000, ATTN_NORM);
   self.state = STATE_TOP;
   self.think = reflect_go_down;
   if ( (self.spawnflags & REFLECT_RETURN) ) {

      self.nextthink = (self.ltime + self.wait);
   } else {

      self.nextthink = -1.00000;

   }
};


void  ()reflect_hit_bottom =  {
   sound (self, CHAN_VOICE, self.noise1, 1.00000, ATTN_NORM);
   self.state = STATE_BOTTOM;
};


void  ()reflect_go_down =  {
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   self.state = STATE_DOWN;
   SUB_CalcMove (self.pos2, self.speed, reflect_hit_bottom);
};


void  ()reflect_go_up =  {
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   self.state = STATE_UP;
   SUB_CalcMove (self.pos1, self.speed, reflect_hit_top);
};


void  ()reflect_use =  {
   if ( (self.state == STATE_BOTTOM) ) {

      reflect_go_up ();
   } else {

      if ( (self.state == STATE_TOP) ) {

         reflect_go_down ();

      }

   }
};


void  ()func_reflect =  {
local entity t;
   if ( !self.t_length ) {

      self.t_length = 80.00000;

   }
   if ( !self.t_width ) {

      self.t_width = 10.00000;

   }
   if ( (self.soundtype == 0.00000) ) {

      self.soundtype = 2.00000;

   }
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("plats/plat1.wav");
      precache_sound ("plats/plat2.wav");
      self.noise = "plats/plat1.wav";
      self.noise1 = "plats/plat2.wav";

   }
   if ( (self.soundtype == 2.00000) ) {

      precache_sound ("plats/medplat1.wav");
      precache_sound ("plats/medplat2.wav");
      self.noise = "plats/medplat1.wav";
      self.noise1 = "plats/medplat2.wav";

   }
   SetMovedir ();
   self.classname = "reflect";
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   self.blocked = reflect_crush;
   if ( !self.speed ) {

      self.speed = 150.00000;

   }
   if ( !self.wait ) {

      self.wait = 3.00000;

   }
   if ( !self.lip ) {

      self.lip = 4.00000;

   }
   self.pos1 = self.origin;
   self.pos2 = (self.pos1 + (self.movedir * (fabs ((self.movedir * self.size)) - self.lip)));
   self.state = STATE_BOTTOM;
   if ( (self.spawnflags & REFLECT_START_OPEN) ) {

      setorigin (self, self.pos2);
      self.pos2 = self.pos1;
      self.pos1 = self.origin;

   }
   setorigin (self, self.pos2);
   self.movechain = reflect_spawn_field (self.absmin, self.absmax, self);
   self.use = reflect_use;
   self.touch = reflect_touch;
   self.active = 1.00000;
};


void  ()reflect_trigger_use =  {
   if ( (other.classname == "trigger_activate") ) {

      self.active = 1.00000;
   } else {

      if ( (other.classname == "trigger_deactivate") ) {

         self.active = 0.00000;

      }

   }
};


void  ()trigger_reflect =  {
   self.use = reflect_trigger_use;
   self.touch = reflect_trigger_touch;
   if ( (self.spawnflags & 1.00000) ) {

      self.active = 0.00000;
   } else {

      self.active = 1.00000;

   }
   InitTrigger ();
};

