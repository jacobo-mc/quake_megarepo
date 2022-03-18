float SPIDER_RED_LARGE   =  0.00000;
float SPIDER_RED_SMALL   =  1.00000;
float SPIDER_YELLOW_LARGE   =  2.00000;
float SPIDER_YELLOW_SMALL   =  3.00000;
void  (float type)SpiderInit;
void  ()SpiderStand;
void  ()SpiderWalk;
void  ()SpiderRun;
void  ()SpiderMelee;
void  ()SpiderMeleeEnd;
void  ()SpiderPause;
void  ()SpiderPain;
void  ()SpiderPainLow;
void  ()SpiderPainHigh;
void  ()SpiderDie;
void  ()SpiderGone;
float SpiderHealth [4]   = { 85.00000,
    30.00000,    120.00000,    50.00000};
float SpiderExp [4]   = { 800.00000,
    800.00000,    800.00000,    800.00000};

void  ()monster_spider =  {
};


void  ()monster_spider_red_large =  {
   SpiderInit (SPIDER_RED_LARGE);
};


void  ()monster_spider_red_small =  {
   SpiderInit (SPIDER_RED_SMALL);
};


void  ()monster_spider_yellow_large =  {
   SpiderInit (SPIDER_YELLOW_LARGE);
};


void  ()monster_spider_yellow_small =  {
   SpiderInit (SPIDER_YELLOW_SMALL);
};


void  ()spider_possum_up =  {
   AdvanceFrame( 117.00000, 98.00000);
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()spider_playdead =  {
   self.frame = 117.00000;
   self.think = spider_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  (float type)SpiderInit =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model ("models/spider.mdl");
      precache_sound ("spider/scuttle.wav");
      precache_sound ("spider/bite.wav");
      precache_sound ("spider/pain.wav");
      precache_sound ("spider/death.wav");

   }
   setmodel (self, "models/spider.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.yaw_speed = 10.00000;
   if ( (type > SPIDER_RED_SMALL) ) {

      self.skin = 1.00000;

   }
   if ( (type & 1.00000) ) {

      self.scale = (0.70000 + (random () * 0.20000));
      self.mass = 1.00000;
      setsize (self, '-12.00000 -12.00000 0.00000', '12.00000 12.00000 16.00000');
   } else {

      self.scale = 1.30000;
      self.mass = 3.00000;
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 26.00000');

   }
   self.drawflags = SCALE_ORIGIN_BOTTOM;
   self.spiderType = type;
   self.spiderGoPause = 35.00000;
   self.mintel = 10.00000;
   self.netname = "spider";
   self.health = (SpiderHealth->type);
   self.experience_value = (SpiderExp->type);
   self.thingtype = THINGTYPE_FLESH;
   self.th_stand = SpiderStand;
   self.th_walk = SpiderWalk;
   self.th_run = SpiderRun;
   self.th_die = SpiderDie;
   self.th_melee = SpiderMeleeBegin;
   self.th_missile = SpiderJumpBegin;
   self.th_pain = SpiderPain;
   self.th_possum = spider_playdead;
   self.th_possum_up = spider_possum_up;
   self.flags = (self.flags | FL_MONSTER);
   walkmonster_start ();
};


void  ()SpiderDie =  {
   AdvanceFrame( 98.00000, 117.00000);
   if ( (self.frame == 98.00000) ) {

      sound (self, CHAN_BODY, "spider/death.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.frame == 117.00000) ) {

      self.think = SpiderGone;

   }
   if ( (self.health < -40.00000) ) {

      chunk_death ();

   }
};


void  ()SpiderGone =  {
   MakeSolidCorpse ("remove");
};


void  ()SpiderPain =  {
   sound (self, CHAN_BODY, "spider/pain.wav", 1.00000, ATTN_NORM);
   if ( ((self.frame < 49.00000) || (self.frame > 63.00000)) ) {

      SpiderPainLow ();
   } else {

      SpiderPainHigh ();

   }
};


void  ()SpiderPainLow =  {
   AdvanceFrame( 80.00000, 89.00000);
   if ( cycle_wrapped ) {

      self.enemy = world;
      SpiderRun ();

   }
};


void  ()SpiderPainHigh =  {
   AdvanceFrame( 90.00000, 97.00000);
   if ( cycle_wrapped ) {

      self.enemy = world;
      SpiderRun ();

   }
};


void  ()SpiderMeleeBegin =  {
   AdvanceFrame( 42.00000, 53.00000);
   ai_charge (3.00000);
   if ( (self.frame == 42.00000) ) {

      self.last_attack = time;
   } else {

      if ( (self.frame == 53.00000) ) {

         self.think = SpiderMelee;

      }

   }
};


void  ()SpiderMeleeSettle =  {
   AdvanceFrame( 75.00000, 79.00000);
   ai_charge (3.00000);
   if ( (self.frame == 79.00000) ) {

      self.think = self.th_run;

   }
};


void  ()SpiderJumpBegin =  {
   AdvanceFrame( 64.00000, 74.00000);
   if ( (self.frame == 64.00000) ) {

      if ( !CheckJump () ) {

         self.think = SpiderRun;
         self.nextthink = time;
         return ;
      } else {

         self.last_attack = time;

      }

   }
   if ( (self.frame < 68.00000) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
      self.angles_y = vectoyaw ((self.enemy.origin - self.origin));
      ai_charge (3.00000);
   } else {

      if ( (self.frame == 68.00000) ) {

         makevectors (self.angles);
         self.jump_flag = (time + 7.00000);
         self.velocity = (((v_forward * self.level) * 15.00000) * self.scale);
         self.velocity_z = ((self.level * 10.00000) * self.scale);
         if ( (self.flags & FL_ONGROUND) ) {

            self.flags -= FL_ONGROUND;

         }
      } else {

         if ( (self.frame == 74.00000) ) {

            self.frame = 48.00000;
            self.think = SpiderMeleeBegin;

         }

      }

   }
};


void  ()SpiderMelee =  {
   AdvanceFrame( 54.00000, 63.00000);
   if ( (self.frame == 60.00000) ) {

      ai_melee ();

   }
   if ( (self.frame == 59.00000) ) {

      sound (self, CHAN_BODY, "spider/bite.wav", 1.00000, ATTN_NORM);

   }
   if ( ((self.frame > 58.00000) && (self.frame < 62.00000)) ) {

      ai_charge (4.00000);
   } else {

      ai_charge (2.00000);

   }
   if ( (self.frame == 63.00000) ) {

      self.think = SpiderMeleeEnd;

   }
};


void  ()SpiderMeleeEnd =  {
   AdvanceFrame( 53.00000, 42.00000);
   if ( (self.frame == 42.00000) ) {

      self.think = SpiderRun;

   }
};


void  ()SpiderPauseInit =  {
   self.th_save = self.think;
   self.spiderPauseLength = (7.00000 + (random () * 8.00000));
   self.spiderGoPause = (16.00000 + (random () * 16.00000));
   self.spiderActiveCount = 0.00000;
   self.spiderPauseCount = 0.00000;
   SpiderPause ();
};


void  ()SpiderPause =  {
   AdvanceFrame( 16.00000, 41.00000);
   self.spiderPauseCount += 1.00000;
   if ( (self.spiderPauseCount > self.spiderPauseLength) ) {

      self.think = self.th_save;
      if ( !(self.think) ) {

         self.think = SpiderStand;

      }

   }
};


void  ()SpiderRun =  {
   AdvanceFrame( 0.00000, 15.00000);
   self.spiderActiveCount += 1.00000;
   if ( (self.spiderActiveCount > self.spiderGoPause) ) {

      SpiderPauseInit ();
      return ;

   }
   if ( (self.spiderType & 1.00000) ) {

      ai_run (4.00000);
   } else {

      ai_run (8.00000);

   }
};


void  ()SpiderStand =  {
   AdvanceFrame( 16.00000, 40.00000);
   ai_stand ();
};


void  ()SpiderWalk =  {
   AdvanceFrame( 0.00000, 15.00000);
   ai_walk (2.00000);
};

