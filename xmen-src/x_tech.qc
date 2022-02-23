$frame a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16
$frame b1 b2 b3 b4 b5 b6 b7 b8 b9 b10
$frame d1 d2 d3 d4 d5 d6 d7 d8 d9 d10
$frame d11 d12 d13 d14 d15 d16 d17 d18 d19 d20
$frame d21 d22 d23 d24 d25 d26 d27 d28 d29 d30
$frame d31 d32 d33 d34 d35 d36 d37 d38 d39 d40
$frame d41 d42 d43 d44 d45 d46

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10 death11 death12

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12

$frame walka1 walka2 walka3 walka4 walka5 walka6 walka7 walka8 walka9 walka10
$frame walka11 walka12

$frame duck1 duck2 duck3 duck4 duck5 duck6

$frame cower1 cower2
void() tech_die =
{
   self.deadflag = DEAD_DEAD;
   self.solid = SOLID_NOT;
   self.takedamage = DAMAGE_NO;
   if ((self.frame < $death1 ) || (self.frame > $death12 ))
      self.frame = $death1;
   else
      self.frame = self.frame + 1;

   if (self.frame == $death12 ) {
      self.nextthink = -1;
      return;
   }

   self.think = tech_die;
   self.nextthink = time + 0.1;
};

void() tech_hide1 = [ $duck1, tech_hide2 ] {};
void() tech_hide2 = [ $duck2, tech_hide3 ] {};
void() tech_hide3 = [ $duck3, tech_hide4 ] {};
void() tech_hide4 = [ $duck4, tech_hide5 ] {};
void() tech_hide5 = [ $duck5, tech_hide6 ] {};
void() tech_hide6 = [ $duck6, tech_cower1 ] {};
void() tech_cower1 = [ $cower1, tech_cower2 ] {};
void() tech_cower2 = [ $cower2, tech_cower1 ] {};

void() tech_think =
{
   local entity   plyr, btn, oself;
   local vector   oldpos, vectmove, anglemove;

   self.frame = self.frame + 1;
   if (self.frame > self.last_frame) {
      self.frame = self.start_frame;
      if ((self.tech_state != TECH_WALKING) && (random() < 0.5))                 // somewhat randomize the speed of animation
         self.speed = 0.1;
      else
         self.speed = 0.05;
   }

   if (self.tech_state == TECH_WALKING) {    // move towards target switch
      oldpos = self.origin;
      movetogoal(6);
      vectmove = normalize(self.origin - oldpos);
      anglemove = vectoangles(vectmove);
      self.ideal_yaw = anglemove_y;

      ChangeYaw();

      if (vlen(self.origin - self.movetarget.origin) < 64) {   // fire button, start hiding
//bprint("tech firing target\n");
         oself = self;
         activator = self;
         self = self.movetarget.owner;
         if (self.use)
            self.use();
//         else {
//            objerror("Technician target doesn't have a use function\n");
//         }
         self = oself;

         remove(self.movetarget);
         self.tech_state = TECH_HIDING;
         tech_hide1();
         return;
      }
   }
   else if ((self.tech_state == TECH_IDLE) && (self.target != "") && (self.frame == self.start_frame)) {     // check for sighting intruder
      plyr = world;
      while ((plyr = find(plyr, classname, "player")) != world) {

         // check if visible
         traceline(self.origin + '0 0 16', plyr.origin + '0 0 16', TRUE, world);

         if (trace_fraction == 1) {       // player is visible
            if ((btn = find(world, targetname, self.target)) == world) {
               bprint("xmen_techdude: cannot find target\n");
            }
            else {
               self.movetarget = spawn();
               self.enemy = self.goalentity = self.movetarget;
               self.movetarget.owner = btn;
               self.movetarget.origin = btn.absmin + ((btn.absmax - btn.absmin) * 0.5);
            }

            self.speed = 0.05;
            self.tech_state = TECH_WALKING;

//            if (random() < 0.5) {
               self.start_frame = self.frame = $walk1;
               self.last_frame = $walk12;
//            }
//            else {
//               self.start_frame = self.frame = $walka1;
//               self.last_frame = $walka12;
//            }
         }

      }
   }

   self.nextthink = time + self.speed;
};

void() tech_pain =
{
   self.health = self.health;       // should we play a sound here?
};

void() tech_drop =
{
   droptofloor();
/*
   if (!walkmove(0,0)) {
      bprint("xmen_techdude fell out of level at ");
      bprint(vtos(self.origin));
      bprint("\n");
   }
*/
   self.think = tech_think;
   self.nextthink = time + self.speed;
};

void() xmen_techdude =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local string   str;
   local float    rnd;

   if (deathmatch) {
      remove(self);
      return;
   }

   precache_model("progs/tech.mdl");

   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel(self, "progs/tech.mdl");
   setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

   rnd = random() * 3;
   if (rnd <= 1) {
      self.start_frame = $a1;
      self.last_frame  = $a16;
   }
   else if (rnd <= 2) {
      self.start_frame = $b1;
      self.last_frame  = $b10;
   }
   else {
      self.start_frame = $d1;
      self.last_frame  = $d46;
   }

   self.tech_state = TECH_IDLE;
   self.yaw_speed = 90;

   self.takedamage = DAMAGE_AIM;
   self.health = self.start_health = 25;

   self.th_die = tech_die;
   self.th_pain = tech_pain;

   self.speed = 0.1;             // speed of animation

   self.think = tech_drop;
   self.nextthink = time + 0.2;
};