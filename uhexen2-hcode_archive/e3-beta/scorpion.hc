float SCORPION_YELLOW   =  0.00000;
float SCORPION_BLACK   =  1.00000;
void  (float type)ScorpionInit;
void  ()ScorpionStand;
void  ()ScorpionWake;
void  ()ScorpionWalk;
void  ()ScorpionRun;
void  ()ScorpionPain;
void  ()ScorpionMeleeDecide;
void  ()ScorpionMelee1;
void  ()ScorpionMelee2;
void  ()ScorpionMelee3;
void  ()ScorpionDie;
void  ()ScorpionDieInit;
float ScorpionStandFrames [6]   = { 124.00000,
    125.00000,    126.00000,    127.00000,    126.00000,
    125.00000};

void  ()monster_scorpion =  {
   dprint ("Hey!  Use monster_scorpion_black or _yellow from now on!\n");
   dprint ("Jeez, silly designer types, I fart in your general direction...");
};


void  ()monster_scorpion_yellow =  {
   ScorpionInit (SCORPION_YELLOW);
};


void  ()monster_scorpion_black =  {
   ScorpionInit (SCORPION_BLACK);
};


void  ()scorpion_possum_up =  {
   AdvanceFrame( 89.00000, 74.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()scorpion_playdead =  {
   self.frame = 89.00000;
   self.think = scorpion_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  (float type)ScorpionInit =  {
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model ("models/scorpion.mdl");

   }
   setmodel (self, "models/scorpion.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.thingtype = THINGTYPE_FLESH;
   self.yaw_speed = 10.00000;
   self.mass = 9.00000;
   self.mintel = 4.00000;
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 64.00000');
   self.health = 100.00000;
   self.takedamage = DAMAGE_YES;
   self.th_stand = ScorpionStand;
   self.th_walk = ScorpionWalk;
   self.th_run = ScorpionRun;
   self.th_melee = ScorpionMeleeDecide;
   self.th_pain = ScorpionPain;
   self.th_die = ScorpionDieInit;
   self.th_possum = scorpion_playdead;
   self.th_possum_up = scorpion_possum_up;
   self.view_ofs = '0.00000 0.00000 12.00000';
   if ( !(self.spawnflags & NO_JUMP) ) {

      self.spawnflags += NO_JUMP;

   }
   self.scorpionType = type;
   if ( (type == SCORPION_BLACK) ) {

      self.skin = 1.00000;

   }
   walkmonster_start ();
};


void  ()ScorpionStand =  {
   self.think = ScorpionStand;
   self.nextthink = (time + 0.20000);
   self.scorpionRest += 1.00000;
   if ( ((self.scorpionRest < 0.00000) || (self.scorpionRest > 5.00000)) ) {

      self.scorpionRest = 0.00000;

   }
   self.frame = ScorpionStandFrames[self.scorpionRest];
   ai_stand ();
   if ( (self.think != ScorpionStand) ) {

      self.th_save = self.think;
      self.think = ScorpionWake;

   }
};


void  ()ScorpionWake =  {
   AdvanceFrame( 124.00000, 153.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_save;
      self.think ();

   }
};


void  ()ScorpionWalk =  {
   AdvanceFrame( 154.00000, 169.00000);
   ai_walk (2.00000);
};


void  ()ScorpionRun =  {
   AdvanceFrame( 154.00000, 169.00000);
   ai_run (6.00000);
};


void  ()ScorpionPain =  {
   AdvanceFrame( 90.00000, 99.00000);
   if ( cycle_wrapped ) {

      ScorpionRun ();

   }
};


void  ()ScorpionMeleeDecide =  {
local float r = 0.00000;
   r = random ();
   self.last_attack = time;
   if ( (r < 0.33000) ) {

      ScorpionMelee1 ();
   } else {

      if ( (r < 0.66000) ) {

         ScorpionMelee2 ();
      } else {

         ScorpionMelee3 ();

      }

   }
};


void  ()ScorpionMelee1 =  {
   AdvanceFrame( 0.00000, 24.00000);
   if ( ((self.frame > 15.00000) && (self.frame < 19.00000)) ) {

      ai_charge (4.00000);
      ai_melee ();
   } else {

      ai_charge (2.00000);

   }
   if ( cycle_wrapped ) {

      self.think = ScorpionRun;

   }
};


void  ()ScorpionMelee2 =  {
   AdvanceFrame( 25.00000, 51.00000);
   if ( ((self.frame > 40.00000) && (self.frame < 44.00000)) ) {

      ai_charge (4.00000);
      ai_melee ();
   } else {

      ai_charge (2.00000);

   }
   if ( cycle_wrapped ) {

      self.think = ScorpionRun;

   }
};


void  ()ScorpionMelee3 =  {
   AdvanceFrame( 52.00000, 73.00000);
   if ( ((self.frame > 67.00000) && (self.frame < 71.00000)) ) {

      ai_charge (4.00000);
      ai_melee ();
   } else {

      ai_charge (2.00000);

   }
   if ( cycle_wrapped ) {

      self.think = ScorpionRun;

   }
};


void  ()ScorpionDie =  {
   if ( (self.frame == 89.00000) ) {

      MakeSolidCorpse ("remove");
      return ;

   }
   if ( (self.health < -40.00000) ) {

      chunk_death ();

   }
   self.frame += 1.00000;
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()ScorpionDieInit =  [ 74.0, ScorpionDie] {
};

