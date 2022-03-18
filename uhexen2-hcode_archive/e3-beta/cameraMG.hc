
void  (entity voyeur,entity viewentity)CameraViewPort =  {
   msg_entity = voyeur;
   WriteByte (MSG_ONE, SVC_SETVIEWPORT);
   WriteEntity (MSG_ONE, viewentity);
};


void  (entity voyeur,entity viewentity)CameraViewAngles =  {
   msg_entity = voyeur;
   WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
   WriteAngle (MSG_ONE, viewentity.angles_x);
   WriteAngle (MSG_ONE, viewentity.angles_y);
   WriteAngle (MSG_ONE, viewentity.angles_z);
};


void  ()CameraThink =  {
local vector viewdir = '0.00000 0.00000 0.00000';
   if ( !(self.owner.flags2 & FL_CAMERA_VIEW) ) {

      remove (self);
   } else {

      if ( (self.cnt < 68.00000) ) {

         self.cnt += 1.00000;

      }
      if ( (self.owner.weaponmodel != "") ) {

         self.owner.lastweapon = self.owner.weaponmodel;
         self.owner.weaponmodel = "";

      }
      makevectors (self.owner.v_angle);
      viewdir = normalize (v_forward);
      traceline (((self.owner.origin + self.owner.proj_ofs) + '0.00000 0.00000 6.00000'), (((self.owner.origin + self.owner.proj_ofs) + '0.00000 0.00000 6.00000') - (viewdir * self.cnt)), TRUE, self.owner);
      viewdir = normalize ((((self.owner.origin + self.owner.proj_ofs) + '0.00000 0.00000 6.00000') - trace_endpos));
      setorigin (self, (trace_endpos + (viewdir * 4.00000)));
      CameraViewPort (self.owner, self);
      self.think = CameraThink;
      self.nextthink = time;

   }
};


void  ()MakeCamera =  {
local entity viewentity;
   if ( (self.flags2 & FL_CAMERA_VIEW) ) {

      CameraViewPort (self, self);
      CameraViewAngles (self, self);
      self.weaponmodel = self.lastweapon;
      self.flags2 -= FL_CAMERA_VIEW;
      self.view_ofs = (self.proj_ofs + '0.00000 0.00000 6.00000');
   } else {

      localcmd ("color 3 5\n");
      self.lastweapon = self.weaponmodel;
      self.weaponmodel = "";
      makevectors (self.v_angle);
      viewentity = spawn ();
      viewentity.owner = self;
      viewentity.angles = self.angles;
      viewentity.think = CameraThink;
      viewentity.nextthink = time;
      viewentity.cnt = 4.00000;
      self.flags2 += FL_CAMERA_VIEW;
      self.view_ofs = '0.00000 0.00000 0.00000';
      setmodel (viewentity, "models/null.spr");
      setsize (viewentity, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      setorigin (viewentity, (((self.origin + self.proj_ofs) + '0.00000 0.00000 6.00000') - (v_forward * 4.00000)));
      CameraViewPort (self, viewentity);
      CameraViewAngles (self, viewentity);

   }
};

