void  ()GolemSPunchLeft;
void  ()GolemSPunchRight;
void  ()GolemSPound;
void  ()golem_run_init;

void  ()golems_gbirth1 =  [  0.0, golems_gbirth2] {
};


void  ()golems_gbirth2 =  [  1.0, golems_gbirth3] {
};


void  ()golems_gbirth3 =  [  2.0, golems_gbirth4] {
};


void  ()golems_gbirth4 =  [  3.0, golems_gbirth5] {
};


void  ()golems_gbirth5 =  [  4.0, golems_gbirth6] {
};


void  ()golems_gbirth6 =  [  5.0, golems_gbirth7] {
};


void  ()golems_gbirth7 =  [  6.0, golems_gbirth8] {
};


void  ()golems_gbirth8 =  [  7.0, golems_gbirth9] {
};


void  ()golems_gbirth9 =  [  8.0, golems_gbirth10] {
};


void  ()golems_gbirth10 =  [  9.0, golems_gbirth11] {
};


void  ()golems_gbirth11 =  [ 10.0, golems_gbirth12] {
};


void  ()golems_gbirth12 =  [ 11.0, golems_gbirth1] {
};


void  ()golems_gstand1 =  [  0.0, golems_gstand1] {
   ai_stand ();
};


void  ()GolemSMeleeDecide =  {
local float rnd = 0.00000;
   rnd = random ();
   if ( (rnd > 0.66000) ) {

      GolemSPunchLeft ();
   } else {

      if ( (rnd > 0.33000) ) {

         GolemSPunchRight ();
      } else {

         GolemSPound ();

      }

   }
};


void  ()GolemSPunchLeft =  {
   AdvanceFrame( 169.00000, 190.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 177.00000) && (self.frame < 186.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()GolemSPunchRight =  {
   AdvanceFrame( 191.00000, 212.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 199.00000) && (self.frame < 208.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()GolemSPound =  {
   AdvanceFrame( 149.00000, 168.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 157.00000) && (self.frame < 166.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()golem_run =  {
   if ( (self.frame == 122.00000) ) {

      self.frame = 63.00000;
   } else {

      self.frame += 1.00000;

   }
   self.nextthink = (time + HX_FRAME_TIME);
   ai_run (1.00000);
};


void  ()golem_run_init =  {
   if ( ((self.frame < 63.00000) || (self.frame > 122.00000)) ) {

      self.frame = 63.00000;

   }
   self.nextthink = (time + HX_FRAME_TIME);
   self.think = golem_run;
   ai_run (1.00000);
};


void  ()golem_walk =  {
   AdvanceFrame( 63.00000, 122.00000);
   ai_walk (1.00000);
};


void  ()golem_possum_up =  {
   AdvanceFrame( 62.00000, 12.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()golem_playdead =  {
   self.frame = 62.00000;
   self.think = golem_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  ()golem_die =  {
   if ( (self.frame == 62.00000) ) {

      self.nextthink = (time - 1.00000);
      MakeSolidCorpse ("models/h_golem.mdl");
      return ;

   }
   if ( (self.frame == 47.00000) ) {

      self.solid = SOLID_NOT;

   }
   if ( (self.health < -50.00000) ) {

      self.think = chunk_death;

   }
   if ( (self.flags & FL_ONGROUND) ) {

      self.frame += 1.00000;

   }
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()golem_die_init =  [ 12.0, golem_die] {
};


float  (float firstFrame,float lastFrame)golem_flinch =  {
   if ( ((self.frame < firstFrame) || (self.frame > lastFrame)) ) {

      return ( 0.00000 );

   }
   self.nextthink = ((self.nextthink + 0.10000) + (random () * 0.20000));
   self.frame = ((self.frame - 8.00000) - rint ((random () * 12.00000)));
   self.pain_finished = (time + 1.00000);
   if ( (self.frame < firstFrame) ) {

      self.frame = ((lastFrame + 1.00000) - (firstFrame - self.frame));

   }
   return ( 1.00000 );
};


void  ()golems_pain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   if ( golem_flinch (63.00000, 122.00000) ) {

      return ;

   }
   if ( golem_flinch (169.00000, 190.00000) ) {

      return ;

   }
   if ( golem_flinch (191.00000, 212.00000) ) {

      return ;

   }
   golem_flinch (149.00000, 168.00000);
};


void  ()monster_golem_stone =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model ("models/golem_s.mdl");
   precache_model ("models/h_golem.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.thingtype = THINGTYPE_GREYSTONE;
   self.yaw_speed = 4.50000;
   self.mass = 75.00000;
   self.mintel = 2.00000;
   setmodel (self, "models/golem_s.mdl");
   setsize (self, '-20.00000 -20.00000 0.00000', '20.00000 20.00000 80.00000');
   self.health = 250.00000;
   self.experience_value = 800.00000;
   self.th_stand = golems_gstand1;
   self.th_walk = golem_walk;
   self.th_run = golem_run_init;
   self.th_die = golem_die_init;
   self.th_melee = GolemSMeleeDecide;
   self.th_pain = golems_pain;
   self.th_possum = golem_playdead;
   self.th_possum_up = golem_possum_up;
   self.view_ofs = '0.00000 0.00000 64.00000';
   walkmonster_start ();
};

