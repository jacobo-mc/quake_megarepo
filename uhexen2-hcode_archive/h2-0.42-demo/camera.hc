/*
 * $Header: /H3/game/hcode/camera.hc 20    9/09/97 3:59p Mgummelt $
 */

/*QUAKED target_null (1 0 0) (-8 -8 -8) (8 8 8)
A null target for the camera 
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void target_null (void)
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_NONE;

	precache_model ("models/sprites/null.spr");
	setmodel(self,"models/sprites/null.spr");
}


/*-----------------------------------------
	play_camera - play noise for when popping in or out of camera mode
  -----------------------------------------*/
void() play_camera =
{
	sound (self, CHAN_VOICE, "misc/camera.wav", 1, ATTN_NORM);
	remove (self);
};


/*-----------------------------------------
	CameraUse - place player in camera remote
  -----------------------------------------*/
void CameraUse (void)
{
	entity snd_ent;

	other = other.enemy;	// Use the enemy of the trigger or button

	if (other.classname != "player")
		return;

	stuffcmd (other, "bf\n");

	other.cameramode = self;
	other.camera_time = time + self.wait;

	other.oldangles = other.angles;
	other.lastweapon = other.weaponmodel;
	other.weaponmodel = string_null;

	msg_entity = other;
	WriteByte (MSG_ONE, 5);					// 5 = SVC_SETVIEWPORT
	WriteEntity (MSG_ONE, self);
	WriteByte (MSG_ONE, 10);				// 10 = SVC_SETVIEWANGLES
	WriteAngle (MSG_ONE,360 - self.angles_x);		// pitch
	WriteAngle (MSG_ONE,self.angles_y);		// yaw
	WriteAngle (MSG_ONE,self.angles_z);		// roll

	snd_ent = spawn ();
	snd_ent.origin = self.origin;

	thinktime snd_ent : HX_FRAME_TIME;
	snd_ent.think = play_camera;
}

/*-----------------------------------------
	CameraReturn - return the player to his body
  -----------------------------------------*/
void CameraReturn(void)
{
	entity snd_ent;

	self.cameramode = world;
	self.weaponmodel = self.lastweapon;

	stuffcmd (self, "bf\n");

	msg_entity = self;
	self.angles = self.oldangles;

	WriteByte (MSG_ONE, 5);					// 5 = SVC_SETVIEWPORT
	WriteEntity (MSG_ONE, self);
	WriteByte (MSG_ONE, 10);				// 10 = SVC_SETVIEWANGLES
	WriteAngle (MSG_ONE, self.angles_x);
	WriteAngle (MSG_ONE, self.angles_y);
	WriteAngle (MSG_ONE, self.angles_z);

	snd_ent = spawn ();
	snd_ent.origin = self.origin;
	thinktime snd_ent : HX_FRAME_TIME;
	snd_ent.think = play_camera;
}

/*-----------------------------------------
	camera_target- point the camera at it's target
  -----------------------------------------*/
void camera_target (void)
{
	self.enemy = find (world,targetname,self.target);
	self.angles = vectoangles(self.enemy.origin - self.origin);
}

/*QUAKED camera_remote (1 0 0) (-8 -8 -8) (8 8 8)
A camera which the player becomes when triggered. 
-------------------------FIELDS-------------------------
"wait" - amount of time player is stuck in camera mode
   (default 3 seconds)

To point camera in a direction

target a "target_null" entity


or fill out the angle fields:
angles_x - pitch of camera
angles_y - yaw of camera


--------------------------------------------------------
*/
void camera_remote (void)
{
	if(deathmatch)
	{
		remove(self);
		return;
	}

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	precache_model ("models/sprites/null.spr");
	setmodel(self,"models/sprites/null.spr");

	self.use = CameraUse;

	if (!self.wait)
		self.wait = 3;

	if (self.target)	
	{
		self.think = camera_target;
		self.nextthink = time + 0.02; // Give target a chance to spawn into the world
	}

	setsize(self, '-1 -1 0', '1 1 1');
}

