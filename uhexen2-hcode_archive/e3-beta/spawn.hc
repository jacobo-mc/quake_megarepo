void  (vector org)spawn_tfog;

void  (float newscale,entity subject)ScaleBoundingBox =  {
local float modifier = 0.00000;
local float obj_height = 0.00000;
   if ( !newscale ) {

      return ;

   }
   if ( (newscale > 2.50000) ) {

      dprint ("Scale can't be bigger than 2.5");
      newscale = subject.scale;
   } else {

      if ( (newscale < 0.01000) ) {

         dprint ("Scale can't be less than .01");
         newscale = subject.scale;

      }

   }
   self.mins = self.orgnl_mins;
   self.maxs = self.orgnl_maxs;
   self.mins = (self.mins * newscale);
   self.maxs = (self.maxs * newscale);
   setsize (subject, self.mins, self.maxs);
   self.mass = (self.mass * newscale);
};


void  (entity subject,string modelname,vector boxmin,vector boxmax,float newsolid,float newmovetype,float newthingtype,float newtakedamage)CreateEntity =  {
   setmodel (subject, modelname);
   subject.solid = newsolid;
   subject.movetype = newmovetype;
   subject.thingtype = newthingtype;
   subject.orgnl_mins = boxmin;
   subject.orgnl_maxs = boxmax;
   setsize (subject, boxmin, boxmax);
   if ( subject.scale ) {

      ScaleBoundingBox (subject.scale, subject);

   }
   subject.takedamage = newtakedamage;
};

void  ()monster_imp_fire;
void  ()monster_imp_ice;
void  ()monster_archer;
void  ()monster_skull_wizard;
void  ()monster_scorpion_black;
void  ()monster_scorpion_yellow;
void  ()monster_spider_red_large;
void  ()monster_spider_red_small;
void  ()monster_spider_yellow_large;
void  ()monster_spider_yellow_small;
void  (vector org,entity death_owner)spawn_tdeath;

void  ()spawnspot_activate =  {
   self.deadflag = FALSE;
};


float  ()monster_spawn_precache =  {
local float have_monsters = 0.00000;
   if ( (self.spawnflags & IMP) ) {

      precache_sound2 ("imp/up.wav");
      precache_sound2 ("imp/die.wav");
      precache_sound2 ("imp/swoophit.wav");
      precache_sound2 ("imp/swoop.wav");
      precache_sound2 ("imp/fly.wav");
      precache_sound2 ("imp/fireball.wav");
      precache_sound2 ("imp/shard.wav");
      precache_model2 ("models/imp.mdl");
      precache_model2 ("models/h_imp.mdl");
      precache_model2 ("models/shardice.mdl");
      precache_model2 ("models/fireball.mdl");
      have_monsters = TRUE;

   }
   if ( (self.spawnflags & ARCHER) ) {

      precache_model ("models/archer.mdl");
      precache_model ("models/h_ogre.mdl");
      have_monsters = TRUE;

   }
   if ( (self.spawnflags & WIZARD) ) {

      precache_model ("models/skullwiz.mdl");
      precache_model ("models/skulbook.mdl");
      precache_model ("models/skulhead.mdl");
      precache_model ("models/skulshot.mdl");
      precache_model ("models/spider.mdl");
      have_monsters = TRUE;

   }
   if ( (self.spawnflags & SCORPION) ) {

      precache_model ("models/scorpion.mdl");
      have_monsters = TRUE;

   }
   if ( (self.spawnflags & SPIDER) ) {

      precache_model ("models/spider.mdl");
      have_monsters = TRUE;

   }
   return ( have_monsters );
};


float  ()check_monsterspawn_ok =  {
local vector org = '0.00000 0.00000 0.00000';
local entity findspot;
local float foundspot = 0.00000;
local float founddead = 0.00000;
local float foundthink = 0.00000;
local float rnd = 0.00000;
   if ( self.spawnername ) {

      findspot = find (self.controller, netname, self.netname);
      while ( !foundspot ) {

         if ( (findspot.spawnername == self.spawnername) ) {

            if ( (findspot.aflag == (self.level + 1.00000)) ) {

               if ( findspot.deadflag ) {

                  founddead = TRUE;
                  self.level = findspot.aflag;
               } else {

                  foundspot = TRUE;

               }

            }
            if ( (findspot == self.controller) ) {

               if ( (self.level == 0.00000) ) {

                  if ( founddead ) {

                     return ( FALSE );
                  } else {

                     remove (self);
                     return ( FALSE );

                  }
               } else {

                  self.level = 0.00000;

               }

            }

         }
         if ( !foundspot ) {

            findspot = find (findspot, netname, self.netname);

         }

      }
      self.level = findspot.aflag;
      self.controller = findspot;
      org = findspot.origin;
   } else {

      org = self.origin;

   }
   if ( ((self.controller.spawnflags & ONDEATH) && (self.controller.goalentity.flags2 & FL_ALIVE)) ) {

      return ( FALSE );

   }
   tracearea (org, org, self.mins, self.maxs, FALSE, self);
   newmis = spawn ();
   if ( (trace_fraction < 1.00000) ) {

      if ( (trace_ent.flags2 & FL_ALIVE) ) {

         remove (newmis);
         return ( FALSE );
      } else {

         spawn_tdeath (trace_ent.origin, newmis);

      }

   }
   newmis.angles = self.angles;
   newmis.flags2 += FL_SUMMONED;
   while ( !foundthink ) {

      rnd = rint (((random () * 4.00000) + 1.00000));
      rnd = byte_me (rnd);
      if ( (self.controller.spawnflags & rnd) ) {

         foundthink = TRUE;

      }

   }
   if ( (rnd == IMP) ) {

      if ( (random () < 0.50000) ) {

         newmis.think = monster_imp_ice;
      } else {

         newmis.think = monster_imp_fire;

      }
   } else {

      if ( (rnd == ARCHER) ) {

         newmis.think = monster_archer;
      } else {

         if ( (rnd == WIZARD) ) {

            newmis.think = monster_skull_wizard;
         } else {

            if ( (rnd == SCORPION) ) {

               if ( (random () < 0.50000) ) {

                  newmis.think = monster_scorpion_black;
               } else {

                  newmis.think = monster_scorpion_yellow;

               }
            } else {

               rnd = rint (((random () * 3.00000) + 1.00000));
               if ( (rnd == 4.00000) ) {

                  newmis.think = monster_spider_yellow_large;
               } else {

                  if ( (rnd == 3.00000) ) {

                     newmis.think = monster_spider_yellow_small;
                  } else {

                     if ( (rnd == 2.00000) ) {

                        newmis.think = monster_spider_red_large;
                     } else {

                        newmis.think = monster_spider_red_small;

                     }

                  }

               }

            }

         }

      }

   }
   self.controller.goalentity = newmis;
   setorigin (newmis, org);
   if ( !(self.controller.spawnflags & QUIET) ) {

      spawn_tfog (org);

   }
   newmis.nextthink = time;
   return ( TRUE );
};


void  ()monsterspawn_active =  {
   self.think = monsterspawn_active;
   if ( check_monsterspawn_ok () ) {

      self.controller.frags += 1.00000;
      if ( (self.controller != self) ) {

         self.frags += 1.00000;

      }
      if ( (self.controller != self) ) {

         self.controller.deadflag = TRUE;
         self.controller.think = self.controller.use;
         self.controller.nextthink = (time + self.controller.wait);

      }
      if ( (self.controller.frags >= self.controller.cnt) ) {

         remove (self.controller);

      }
      if ( (self.frags >= self.cnt) ) {

         remove (self);

      }
      if ( (self.spawnflags & TRIGGERONLY) ) {

         self.nextthink = -1.00000;
      } else {

         self.nextthink = (time + self.wait);

      }
   } else {

      if ( (self.spawnflags & TRIGGERONLY) ) {

         self.nextthink = -1.00000;
      } else {

         self.nextthink = (time + 0.10000);

      }

   }
};


void  ()func_monsterspawner =  {
   if ( !self.cnt ) {

      self.cnt = 17.00000;

   }
   if ( !self.wait ) {

      self.wait = 0.50000;

   }
   self.netname = "monsterspawn_spot";
   if ( self.spawnername ) {

      self.controller = world;
   } else {

      self.controller = self;

   }
   self.level = 0.00000;
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
   setorigin (self, self.origin);
   if ( (!monster_spawn_precache () && !self.spawnername) ) {

      remove (self);

   }
   if ( self.targetname ) {

      self.use = monsterspawn_active;
   } else {

      self.think = monsterspawn_active;
      self.nextthink = (time + 3.00000);

   }
};


void  ()func_monsterspawn_spot =  {
   if ( !self.aflag ) {

      dprint ("Ooo!  You didn't include me in the spawn cycle!  FIX ME!\n");
      remove (self);

   }
   if ( !self.cnt ) {

      self.cnt = 17.00000;

   }
   self.netname = "monsterspawn_spot";
   if ( !monster_spawn_precache () ) {

      dprint ("You didn't give me any monsters to spawn!!!\n");
      remove (self);

   }
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
   setorigin (self, self.origin);
   if ( self.targetname ) {

      self.deadflag = TRUE;
   } else {

      self.use = spawnspot_activate;

   }
};

