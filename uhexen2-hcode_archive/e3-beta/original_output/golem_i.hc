void  ()GolemIMeleeDecide;
void  ()GolemIPunchRight;
void  ()GolemIPoundLeft;

void  ()golemi_gbirth1 =  [  0.0, golemi_gbirth2] {
};


void  ()golemi_gbirth2 =  [  1.0, golemi_gbirth3] {
};


void  ()golemi_gbirth3 =  [  2.0, golemi_gbirth4] {
};


void  ()golemi_gbirth4 =  [  3.0, golemi_gbirth5] {
};


void  ()golemi_gbirth5 =  [  4.0, golemi_gbirth6] {
};


void  ()golemi_gbirth6 =  [  5.0, golemi_gbirth7] {
};


void  ()golemi_gbirth7 =  [  6.0, golemi_gbirth8] {
};


void  ()golemi_gbirth8 =  [  7.0, golemi_gbirth9] {
};


void  ()golemi_gbirth9 =  [  8.0, golemi_gbirth10] {
};


void  ()golemi_gbirth10 =  [  9.0, golemi_gbirth11] {
};


void  ()golemi_gbirth11 =  [ 10.0, golemi_gbirth12] {
};


void  ()golemi_gbirth12 =  [ 11.0, golemi_gbirth1] {
};


void  ()golemi_gstand1 =  [  0.0, golemi_gstand1] {
   ai_stand ();
};


void  ()GolemIMeleeDecide =  {
   if ( (random () > 0.50000) ) {

      GolemIPunchRight ();
   } else {

      GolemIPoundLeft ();

   }
};


void  ()GolemIPunchRight =  {
   AdvanceFrame( 194.00000, 215.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 202.00000) && (self.frame < 211.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()GolemIPoundLeft =  {
   AdvanceFrame( 174.00000, 193.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 184.00000) && (self.frame < 190.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()golemi_pain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   if ( golem_flinch (63.00000, 122.00000) ) {

      return ;

   }
   if ( golem_flinch (149.00000, 173.00000) ) {

      return ;

   }
   if ( golem_flinch (194.00000, 215.00000) ) {

      return ;

   }
   golem_flinch (174.00000, 193.00000);
};


void  ()monster_golem_iron =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/golem_i.mdl");
   precache_model2 ("models/h_golem.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.thingtype = THINGTYPE_METAL;
   self.yaw_speed = 4.50000;
   self.mass = 100.00000;
   self.mintel = 2.00000;
   setmodel (self, "models/golem_i.mdl");
   setsize (self, '-20.00000 -20.00000 0.00000', '20.00000 20.00000 80.00000');
   self.health = 250.00000;
   self.experience_value = 800.00000;
   self.th_stand = golemi_gstand1;
   self.th_walk = golem_walk;
   self.th_run = golem_run_init;
   self.th_die = golem_die_init;
   self.th_melee = GolemIMeleeDecide;
   self.th_pain = golemi_pain;
   self.th_possum = golem_playdead;
   self.th_possum_up = golem_possum_up;
   self.view_ofs = '0.00000 0.00000 64.00000';
   walkmonster_start ();
};

