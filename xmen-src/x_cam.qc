// X-Men chase-cam

float SVC_SETVIEWPORT   = 5;
.entity chasecam;

vector CAM_OFFSET = '-36 0 6';      // forward, right, up
vector CAM_ORIGIN_OFFSET = '-8 0 8';
float CAM_TRACKSPEED = 0.5;

void(entity player) DisableCam =
{
   if (player.chasecam == world)
      return;

   msg_entity = player;                         // target of message
   WriteByte (MSG_ONE, SVC_SETVIEWPORT);
   WriteEntity (MSG_ONE, player);           // view port

   stuffcmd(player, "cl_bobup 1\n");
   stuffcmd(player, "r_drawviewmodel 1\n");

   remove(player.chasecam);
   player.chasecam = world;
};

void(entity player) InitCam =
{
   local entity   cam;

   if (player.chasecam != world)
      return;

   cam = spawn();
   player.chasecam = cam;
   cam.owner=player;

   cam.solid = SOLID_NOT;
   cam.movetype = MOVETYPE_NONE;

   cam.angles = cam.owner.angles;

   setmodel (cam, "progs/eyes.mdl" );
   setsize (cam, '0 0 0', '0 0 0');
   setorigin( cam, cam.owner.origin );
   cam.classname = "cam";

   msg_entity = cam.owner;                         // target of message
   WriteByte (MSG_ONE, SVC_SETVIEWPORT);
   WriteEntity (MSG_ONE, cam);           // view port

   stuffcmd(player, "cl_bobup 0\n");
   stuffcmd(player, "r_drawviewmodel 0\n");
};

void() CamThink =
{
   local vector   pos, vec, org, angle;
   local float    dist;

   angle = self.owner.v_angle;

   angle_x = 0;
   makevectors(angle);
   org = self.owner.origin + v_up * CAM_ORIGIN_OFFSET_z
                           + v_forward * CAM_ORIGIN_OFFSET_x;

   makevectors(self.owner.v_angle);
   pos = org + v_forward * CAM_OFFSET_x
             + v_right   * CAM_OFFSET_y
             + v_up      * CAM_OFFSET_z;

   if ((self.owner.character == CHAR_STORM) ||
	   (self.owner.character == CHAR_ANGEL))
   {
	   pos = pos + v_up      * 12;
   }

   vec = normalize(pos - org);
   traceline(org, pos, TRUE, world);

   dist = vlen(pos - self.origin);

   if (trace_fraction == 1) { // check ceiling
      traceline(org, pos + '0 0 32', TRUE, world);

      if (trace_fraction < 1)
         trace_endpos = trace_endpos - '0 0 32';
   }

   if (trace_fraction < 1) {
      if (trace_ent == world)  // move away from wall
         setorigin(self, trace_endpos + trace_plane_normal * 8);
      else
         setorigin(self, trace_endpos - vec * 4);
   }
   else { // move towards ideal pos
      if (vlen((pos - self.origin) * frametime * dist * CAM_TRACKSPEED) < dist)
         setorigin(self, self.origin + ((pos - self.origin) * frametime * dist * CAM_TRACKSPEED));
      else
         setorigin(self, pos);
   }

};