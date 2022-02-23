void() clone_touch =
{
   if (other.classname != "player")
      return;
   
   if (self.classname == "xmen_wclone") {
      stuffcmd(other, "color 0 0\n");
   }
   else if (self.classname == "xmen_sclone") {
      stuffcmd(other, "color 1 1\n");
   }

   stuffcmd(other, "connect\n");
};

void() clone_think =
{
   self.frame = self.frame + 1;
   if (self.frame > 12)
      self.frame = 0;

   self.nextthink = time + 0.1;
};

void() xmen_wclone =
{
   self.touch = clone_touch;
   setsize(self, '-8 -8 -8', '8 8 8');
   self.solid = SOLID_TRIGGER;

   precache_model("progs/wolvie2.mdl");
   setmodel(self, "progs/wolvie2.mdl");
   self.think = clone_think;
   self.nextthink = time + 0.1;
};

void() xmen_sclone =
{
   self.touch = clone_touch;
   setsize(self, '-8 -8 -8', '8 8 8');
   self.solid = SOLID_TRIGGER;

   precache_model("progs/storm2.mdl");
   setmodel(self, "progs/storm2.mdl");
   self.think = clone_think;
   self.nextthink = time + 0.1;
};