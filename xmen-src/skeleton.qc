/*
   --------
   Skeleton
   --------

   All monsters killed with a Flamethrower change to a skeleton to be "finished off"
*/

void () skeleton_animate =
{
   self.frame = self.frame + 1;
   if (self.frame > (self.start_frame + 12))
      self.frame = self.start_frame;

   self.skin = self.skin + 1;
   if (self.skin > 3)
      self.skin = 0;

   if (random()*100 < 1)
      sound (self, CHAN_AUTO, "zombie/idle_w2.wav", 1, ATTN_STATIC);

   self.think = skeleton_animate;
   self.nextthink = time + 0.1;
};

void() skeleton_die =
{

   // play crunch sound, and spawn some bone parts
   sound(self, CHAN_BODY, "skeleton/crunch.wav", 1, ATTN_NORM);

   ThrowGib ("progs/gib01.mdl", self.health);

   ThrowGib ("progs/gib02.mdl", self.health);
   ThrowGib ("progs/gib02.mdl", self.health);
   ThrowGib ("progs/gib02.mdl", self.health);
   ThrowGib ("progs/gib02.mdl", self.health);

   ThrowGib ("progs/gib03.mdl", self.health);
   ThrowGib ("progs/gib03.mdl", self.health);
   ThrowGib ("progs/gib03.mdl", self.health);
   ThrowGib ("progs/gib03.mdl", self.health);

   remove(self);
};

void(entity e) skeleton_morph =
{
   local float rnd;

   e.classname = "xmen_skeleton";
   setmodel(e, "progs/skel.mdl");

   // fall from the air
   if (e.flags & FL_FLY) {
//      e.velocity_z = 100;

//      setmodel(e, "progs/skel.mdl");
      setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
//      setorigin(e, e.origin + '0 0 1');

      e.flags = e.flags - (e.flags & FL_ONGROUND);
      e.flags = e.flags - (e.flags & FL_FLY);

      e.angles_x = 0;
      e.angles_z = 0;
   }
   else {
      setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);
      setorigin(e, e.origin - '0 0 1' * e.z_ofs);
   }

   e.flags = e.flags - (e.flags & FL_GODMODE);
   e.x_flags = e.x_flags - (e.x_flags & X_ANGEL_DEFENSE);

   rnd = random() * 3;
   if (rnd < 1) {
      e.start_frame = 0;
   }
   else if (rnd < 2) {
      e.start_frame = 13;
   }
   else {
      e.start_frame = 26;
   }
   e.frame = e.start_frame;

   e.health = 1;

   e.think = skeleton_animate;
   e.nextthink = time + 0.1;

   e.th_die = skeleton_die;
   e.th_pain = skeleton_animate;
   e.th_guard = skeleton_animate;
   e.th_stand = skeleton_animate;
   e.th_melee = skeleton_animate;
   e.th_missile = skeleton_animate;
   e.th_walk = skeleton_animate;
   e.th_run = skeleton_animate;
   e.th_guard = SUB_Null;
};