void  (float dist)ai_mirage;

void  ()mirage_run1 =  [  0.0, mirage_run2] {
   if ( (time > self.ltime) ) {

      self.owner.holo_engaged = 0.00000;
      remove (self);
      return ;

   }
   if ( ((time + 3.00000) > self.ltime) ) {

      self.model = string_null;

   }
   ai_mirage (11.00000);
};


void  ()mirage_run2 =  [  1.0, mirage_run3] {
   ai_mirage (8.00000);
};


void  ()mirage_run3 =  [  2.0, mirage_run4] {
   if ( ((time + 3.00000) > self.ltime) ) {

      self.model = "models/player.mdl";

   }
   ai_mirage (10.00000);
};


void  ()mirage_run4 =  [  3.0, mirage_run5] {
   ai_mirage (10.00000);
};


void  ()mirage_run5 =  [  4.0, mirage_run6] {
   ai_mirage (8.00000);
};


void  ()mirage_run6 =  [  5.0, mirage_run1] {
   ai_mirage (15.00000);
};


void  (float dist)ai_mirage =  {
local vector delta = '0.00000 0.00000 0.00000';
local float axis = 0.00000;
local float direct = 0.00000;
local float ang_rint = 0.00000;
local float ang_floor = 0.00000;
local float ang_ceil = 0.00000;
   movedist = dist;
   if ( (self.enemy.health <= 0.00000) ) {

      self.enemy = world;
      if ( (self.oldenemy.health > 0.00000) ) {

         self.enemy = self.oldenemy;
         HuntTarget ();
      } else {

         self.th_run ();
         return ;

      }

   }
   self.show_hostile = (time + 1.00000);
   enemy_vis = visible (self.enemy);
   if ( enemy_vis ) {

      self.search_time = (time + 5.00000);

   }
   if ( (coop && (self.search_time < time)) ) {

      if ( FindTarget () ) {

         return ;

      }

   }
   enemy_infront = infront (self.enemy);
   enemy_range = range (self.enemy);
   enemy_yaw = vectoyaw ((self.enemy.origin - self.origin));
   if ( (self.attack_state == AS_SLIDING) ) {

      ai_run_slide ();
      return ;

   }
   movetogoal (dist);
};


void  ()remove_mirage =  {
local entity mirage;
   mirage = world;
   while ( (mirage.owner != self) ) {

      mirage = find (mirage, classname, "mirage");
      if ( (mirage == world) ) {

         bprint ("Error: Mirage not found\n");
         return ;

      }

   }
   remove (mirage);
   bprint ("Mirage disengaged\n");
   if ( ((time + 0.50000) > mirage.ltime) ) {

      self.holo_engaged = 0.00000;
   } else {

      self.holo_engaged = (mirage.ltime - time);

   }
};


void  ()init_mirage =  {
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_STEP;
   setmodel (self, self.owner.model);
   setsize (self, '-16.00000 -16.00000 -24.00000', '16.00000 16.00000 40.00000');
   self.health = 666.00000;
   self.weapon = IT_SHOTGUN;
   self.ltime = (time + self.owner.holo_engaged);
   self.th_stand = mirage_run1;
   self.th_walk = mirage_run1;
   self.th_run = mirage_run1;
   self.classname = "mirage";
   self.takedamage = DAMAGE_NO;
   self.angles = self.owner.angles;
   self.yaw_speed = 20.00000;
   self.view_ofs = '0.00000 0.00000 25.00000';
   self.proj_ofs = '0.00000 0.00000 25.00000';
   setorigin (self, self.owner.origin);
   FindTarget ();
   self.pathentity = self.goalentity;
   self.owner.holo_engaged += 100.00000;
   bprint ("Mirage engaged\n");
   mirage_run1 ();
};


void  ()Mirage =  {
local entity mirage;
   if ( (self.classname != "player") ) {

      return ;

   }
   if ( (self.holo_engaged == 0.00000) ) {

      bprint ("Mirage not available\n");
   } else {

      if ( (self.holo_engaged >= 100.00000) ) {

         remove_mirage ();
      } else {

         mirage = spawn ();
         mirage.owner = self;
         mirage.nextthink = (time + 0.05000);
         mirage.think = init_mirage;

      }

   }
};


void  ()item_mirage_touch =  {
local entity mirage;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (other.health <= 0.00000) ) {

      return ;

   }
   remove (self);
   sound (other, CHAN_VOICE, "items/artpkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf");
   bprint ("Got Mirage");
   other.holo_engaged += 15.00000;
   if ( (other.holo_engaged >= 115.00000) ) {

      while ( (mirage.owner != other) ) {

         mirage = find (mirage, classname, "mirage");
         if ( (mirage == world) ) {

            return ;

         }

      }
      mirage.model = "models/player.mdl";
      mirage.ltime += 15.00000;
   } else {

      if ( (other.holo_engaged > 100.00000) ) {

         other.holo_engaged = 100.00000;

      }

   }
};


void  ()item_mirage =  {
   precache_model ("models/mirage.mdl");
   setmodel (self, "models/mirage.mdl");
   self.touch = item_mirage_touch;
   StartItem ();
};

