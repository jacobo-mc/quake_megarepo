void  ()GolemBMeleeDecide;
void  ()GolemBPunchLeft;
void  ()GolemBPoundRight;

void  ()golemb_gbirth1 =  [  0.0, golemb_gbirth2] {
};


void  ()golemb_gbirth2 =  [  1.0, golemb_gbirth3] {
};


void  ()golemb_gbirth3 =  [  2.0, golemb_gbirth4] {
};


void  ()golemb_gbirth4 =  [  3.0, golemb_gbirth5] {
};


void  ()golemb_gbirth5 =  [  4.0, golemb_gbirth6] {
};


void  ()golemb_gbirth6 =  [  5.0, golemb_gbirth7] {
};


void  ()golemb_gbirth7 =  [  6.0, golemb_gbirth8] {
};


void  ()golemb_gbirth8 =  [  7.0, golemb_gbirth9] {
};


void  ()golemb_gbirth9 =  [  8.0, golemb_gbirth10] {
};


void  ()golemb_gbirth10 =  [  9.0, golemb_gbirth11] {
};


void  ()golemb_gbirth11 =  [ 10.0, golemb_gbirth12] {
};


void  ()golemb_gbirth12 =  [ 11.0, golemb_gbirth1] {
};


void  ()golemb_gstand1 =  [  0.0, golemb_gstand1] {
   ai_stand ();
};


void  ()GolemBMeleeDecide =  {
   if ( (random () > 0.50000) ) {

      GolemBPunchLeft ();
   } else {

      GolemBPoundRight ();

   }
};


void  ()GolemBPunchLeft =  {
   AdvanceFrame( 174.00000, 195.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 182.00000) && (self.frame < 191.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()GolemBPoundRight =  {
   AdvanceFrame( 196.00000, 215.00000);
   if ( cycle_wrapped ) {

      golem_run_init ();
      return ;

   }
   if ( ((self.frame > 206.00000) && (self.frame < 212.00000)) ) {

      ai_charge (2.00000);
      ai_melee ();

   }
   ai_face ();
};


void  ()golemb_pain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   if ( golem_flinch (63.00000, 122.00000) ) {

      return ;

   }
   if ( golem_flinch (149.00000, 173.00000) ) {

      return ;

   }
   if ( golem_flinch (174.00000, 195.00000) ) {

      return ;

   }
   if ( golem_flinch (196.00000, 215.00000) ) {

      return ;

   }
   golem_flinch (216.00000, 245.00000);
};


void  ()monster_golem_bronze =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/golem_b.mdl");
   precache_model2 ("models/h_golem.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.thingtype = THINGTYPE_METAL;
   self.yaw_speed = 4.50000;
   self.mass = 50.00000;
   self.mintel = 2.00000;
   setmodel (self, "models/golem_b.mdl");
   setsize (self, '-20.00000 -20.00000 0.00000', '20.00000 20.00000 80.00000');
   self.health = 400.00000;
   self.experience_value = 800.00000;
   self.th_stand = golemb_gstand1;
   self.th_walk = golem_walk;
   self.th_run = golem_run_init;
   self.th_die = golem_die_init;
   self.th_melee = GolemBMeleeDecide;
   self.th_pain = golemb_pain;
   self.th_possum = golem_playdead;
   self.th_possum_up = golem_possum_up;
   self.view_ofs = '0.00000 0.00000 64.00000';
   walkmonster_start ();
};

