float stationary   =  1.00000;
void  ()sheep_tranA;
void  ()sheep_tranB;
void  ()sheep_graze_a;
void  ()sheep_graze_b;
void  ()sheep_gstep_a;
void  ()sheep_gstep_b;
void  ()sheep_wait;
void  ()sheep_pain;
void  ()sheep_lookdown;
void  ()sheep_look;
void  ()sheep_lookup;

void  (float vol)sheep_sound =  {
local float r = 0.00000;
local string playsound;
   if ( self.noise ) {

      playsound = self.noise;
   } else {

      r = rint (((random () * 2.00000) + 1.00000));
      if ( (r == 1.00000) ) {

         playsound = "misc/sheep1.wav";
      } else {

         if ( (r == 2.00000) ) {

            playsound = "misc/sheep2.wav";
         } else {

            playsound = "misc/sheep3.wav";

         }

      }

   }
   sound (self, CHAN_VOICE, playsound, vol, ATTN_NORM);
   self.pain_finished = (time + 1.00000);
};


void  ()sheep_turn =  {
   if ( (random () < 0.50000) ) {

      self.angles_y += ((random () * self.yaw_speed) + (self.yaw_speed / 2.00000));
   } else {

      self.angles_y -= ((random () * self.yaw_speed) + (self.yaw_speed / 2.00000));

   }
};


void  (float dist)sheep_move =  {
local vector best_yaw = '0.00000 0.00000 0.00000';
   best_yaw = normalize ((self.goalentity.origin - self.origin));
   best_yaw = vectoangles (best_yaw);
   self.ideal_yaw = best_yaw_y;
   ChangeYaw ();
   movetogoal (dist);
};


void  ()sheep_think =  {
   if ( ((!(self.spawnflags & stationary) && (((self.think == sheep_trot) || (self.think == sheep_gstep_a)) || (self.think == sheep_gstep_b))) && (random () < 0.10000)) ) {

      sheep_turn ();

   }
   if ( (((random () < 0.10000) && (random () < 0.20000)) && (self.pain_finished < time)) ) {

      sheep_sound (((random () * 0.60000) + 0.20000));

   }
   if ( (self.flags & FL_ONGROUND) ) {

      self.last_onground = time;

   }
};


void  ()sheep_tranA =  {
local float r = 0.00000;
   AdvanceFrame( 202.00000, 211.00000);
   if ( self.target ) {

      sheep_move (3.00000);
   } else {

      if ( !walkmove (self.angles_y, 3.00000, FALSE) ) {

         sheep_turn ();

      }

   }
   sheep_think ();
   if ( cycle_wrapped ) {

      r = (rint ((random () * 2.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_wait ();
      } else {

         if ( (r == 2.00000) ) {

            sheep_tranB ();
         } else {

            if ( (r == 3.00000) ) {

               sheep_lookdown ();

            }

         }

      }

   }
};


void  ()sheep_tranB =  {
local float r = 0.00000;
   AdvanceFrame( 212.00000, 223.00000);
   if ( self.target ) {

      sheep_move (3.00000);
   } else {

      if ( !walkmove (self.angles_y, 3.00000, FALSE) ) {

         sheep_turn ();

      }

   }
   sheep_think ();
   if ( cycle_wrapped ) {

      sheep_trot ();

   }
};


void  ()sheep_graze_a =  {
local float r = 0.00000;
   AdvanceFrame( 0.00000, 39.00000);
   sheep_think ();
   if ( ((self.frame == 8.00000) && (random () < 0.50000)) ) {

      sheep_gstep_b ();
   } else {

      if ( (cycle_wrapped && (random () < 0.50000)) ) {

         sheep_lookup ();

      }

   }
};


void  ()sheep_graze_b =  {
local float r = 0.00000;
   AdvanceFrame( 40.00000, 79.00000);
   sheep_think ();
   if ( ((self.frame == 48.00000) && (random () < 0.50000)) ) {

      sheep_gstep_a ();

   }
};


void  ()sheep_gstep_a =  {
local float r = 0.00000;
   AdvanceFrame( 80.00000, 100.00000);
   sheep_think ();
   if ( self.target ) {

      sheep_move (0.30000);
   } else {

      if ( !walkmove (self.angles_y, 0.30000, FALSE) ) {

         sheep_turn ();

      }

   }
   if ( cycle_wrapped ) {

      r = (rint ((random () * 1.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_graze_a ();
      } else {

         sheep_gstep_b ();

      }

   }
};


void  ()sheep_gstep_b =  {
local float r = 0.00000;
   AdvanceFrame( 101.00000, 121.00000);
   sheep_think ();
   if ( self.target ) {

      sheep_move (0.30000);
   } else {

      if ( !walkmove (self.angles_y, 0.30000, FALSE) ) {

         sheep_turn ();

      }

   }
   if ( cycle_wrapped ) {

      r = (rint ((random () * 1.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_graze_b ();
      } else {

         sheep_gstep_a ();

      }

   }
};


void  ()sheep_trot =  {
local float r = 0.00000;
   AdvanceFrame( 224.00000, 233.00000);
   if ( self.target ) {

      sheep_move (3.00000);
   } else {

      if ( !walkmove (self.angles_y, 3.00000, FALSE) ) {

         sheep_turn ();

      }

   }
   sheep_think ();
   if ( cycle_wrapped ) {

      sheep_tranA ();

   }
};


void  ()sheep_wait =  {
local float r = 0.00000;
   AdvanceFrame( 234.00000, 249.00000);
   sheep_think ();
   if ( cycle_wrapped ) {

      r = (rint ((random () * 2.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_wait ();
      } else {

         if ( (r == 2.00000) ) {

            sheep_tranB ();
         } else {

            if ( (r == 3.00000) ) {

               sheep_lookdown ();

            }

         }

      }

   }
};


void  ()sheep_pain =  {
local float r = 0.00000;
   AdvanceFrame( 194.00000, 201.00000);
   ai_pain (1.00000);
   if ( cycle_wrapped ) {

      r = (rint ((random () * 2.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_wait ();
      } else {

         if ( (r == 2.00000) ) {

            sheep_tranB ();
         } else {

            if ( (r == 3.00000) ) {

               sheep_lookdown ();

            }

         }

      }
   } else {

      if ( (self.frame == 194.00000) ) {

         sheep_sound (1.00000);

      }

   }
};


void  ()sheep_lookdown =  {
local float r = 0.00000;
   AdvanceFrame( 133.00000, 122.00000);
   if ( cycle_wrapped ) {

      r = (rint ((random () * 4.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_graze_a ();
      } else {

         if ( (r == 2.00000) ) {

            sheep_graze_b ();
         } else {

            if ( (r == 3.00000) ) {

               sheep_gstep_a ();
            } else {

               if ( (r == 4.00000) ) {

                  sheep_gstep_b ();
               } else {

                  sheep_lookup ();

               }

            }

         }

      }

   }
};


void  ()sheep_look =  {
local float r = 0.00000;
   AdvanceFrame( 134.00000, 193.00000);
   sheep_think ();
   if ( cycle_wrapped ) {

      r = (rint ((random () * 2.00000)) + 1.00000);
      if ( (r == 1.00000) ) {

         sheep_wait ();
      } else {

         if ( (r == 2.00000) ) {

            sheep_tranB ();
         } else {

            if ( (r == 3.00000) ) {

               sheep_lookdown ();

            }

         }

      }

   }
};


void  ()sheep_lookup =  {
local float r = 0.00000;
   AdvanceFrame( 122.00000, 133.00000);
   sheep_think ();
   if ( cycle_wrapped ) {

      sheep_look ();

   }
};


void  ()player_sheep =  {
local float r = 0.00000;
   CreateEntity (self, "models/sheep.mdl", '-16.00000 -16.00000 0.00000', '16.00000 16.00000 32.00000', SOLID_SLIDEBOX, MOVETYPE_STEP, THINGTYPE_FLESH, DAMAGE_YES);
   self.th_pain = sheep_pain;
   self.th_die = chunk_death;
   self.touch = obj_push;
   self.flags = (self.flags | FL_PUSH);
   self.health = 25.00000;
   self.flags2 += FL_ALIVE;
   self.mass = 3.00000;
   self.yaw_speed = 2.00000;
   r = rint (((random () * 2.00000) + 1.00000));
   if ( (r == 1.00000) ) {

      self.noise = "misc/sheep1.wav";
   } else {

      if ( (r == 2.00000) ) {

         self.noise = "misc/sheep2.wav";
      } else {

         self.noise = "misc/sheep3.wav";

      }

   }
   r = (rint ((random () * 10.00000)) + 1.00000);
   if ( (r == 1.00000) ) {

      self.think = sheep_graze_a;
   } else {

      if ( (r == 2.00000) ) {

         self.think = sheep_graze_b;
      } else {

         if ( (r == 3.00000) ) {

            self.think = sheep_gstep_a;
         } else {

            if ( (r == 4.00000) ) {

               self.think = sheep_gstep_b;
            } else {

               if ( (r == 5.00000) ) {

                  self.think = sheep_look;
               } else {

                  if ( (r == 6.00000) ) {

                     self.think = sheep_lookup;
                  } else {

                     if ( (r == 7.00000) ) {

                        self.think = sheep_trot;
                     } else {

                        if ( (r == 8.00000) ) {

                           self.think = sheep_wait;
                        } else {

                           if ( (r == 9.00000) ) {

                              self.think = sheep_lookdown;
                           } else {

                              if ( (r == 10.00000) ) {

                                 self.think = sheep_tranA;
                              } else {

                                 self.think = sheep_tranB;

                              }

                           }

                        }

                     }

                  }

               }

            }

         }

      }

   }
   self.th_stand = self.think;
   self.th_walk = self.think;
   walkmonster_start ();
};

