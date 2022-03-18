
void  ()target_null =  {
local float hold = 0.00000;
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_NONE;
   precache_model ("models/sprites/null.spr");
   setmodel (self, "models/sprites/null.spr");
};


void  ()play_camera =  {
   sound (self, CHAN_VOICE, "misc/camera.wav", 1.00000, ATTN_NORM);
   remove (self);
};


void  ()CameraUse =  {
local entity snd_ent;
   other = other.enemy;
   if ( (other.classname != "player") ) {

      return ;

   }
   stuffcmd (other, "bf\n");
   other.cameramode = 1.00000;
   other.camera_time = (time + self.wait);
   other.enemy = self;
   other.oldangles = other.angles;
   other.lastweapon = other.weaponmodel;
   other.weaponmodel = string_null;
   msg_entity = other;
   WriteByte (MSG_ONE, 5.00000);
   WriteEntity (MSG_ONE, self);
   WriteByte (MSG_ONE, 10.00000);
   WriteAngle (MSG_ONE, (360.00000 - self.angles_x));
   WriteAngle (MSG_ONE, self.angles_y);
   WriteAngle (MSG_ONE, self.angles_z);
   snd_ent = spawn ();
   snd_ent.origin = self.origin;
   snd_ent.nextthink = (time + 0.05000);
   snd_ent.think = play_camera;
};


void  ()CameraReturn =  {
local entity snd_ent;
   self.cameramode = 0.00000;
   self.weaponmodel = self.lastweapon;
   stuffcmd (self, "bf\n");
   msg_entity = self;
   self.angles = self.oldangles;
   WriteByte (MSG_ONE, 5.00000);
   WriteEntity (MSG_ONE, self);
   WriteByte (MSG_ONE, 10.00000);
   WriteAngle (MSG_ONE, self.angles_x);
   WriteAngle (MSG_ONE, self.angles_y);
   WriteAngle (MSG_ONE, self.angles_z);
   snd_ent = spawn ();
   snd_ent.origin = self.origin;
   snd_ent.nextthink = (time + 0.05000);
   snd_ent.think = play_camera;
};


void  ()camera_target =  {
   self.enemy = find (world, targetname, self.target);
   self.angles = vectoangles ((self.enemy.origin - self.origin));
};


void  ()camera_remote =  {
local float hold = 0.00000;
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   precache_model ("models/sprites/null.spr");
   setmodel (self, "models/sprites/null.spr");
   self.use = CameraUse;
   if ( !self.wait ) {

      self.wait = 3.00000;

   }
   if ( self.target ) {

      self.think = camera_target;
      self.nextthink = (time + 0.02000);

   }
   setsize (self, '-1.00000 -1.00000 0.00000', '1.00000 1.00000 1.00000');
};

