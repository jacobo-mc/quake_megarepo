void  ()mezzo_skid;
void  ()mezzo_block;
void  ()mezzo_block_wait;
void  ()mezzo_jump;
void  ()mezzo_roar;
void  ()mezzo_in_air;
void  ()mezzo_run_loop;

void  ()mezzo_idle_sound =  {
local string soundstr;
   if ( (random () < 0.50000) ) {

      soundstr = "mezzo/snort.wav";
   } else {

      soundstr = "mezzo/growl.wav";

   }
   sound (self, CHAN_VOICE, soundstr, 1.00000, ATTN_NORM);
};


void  ()mezzo_possum_up =  {
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()mezzo_playdead =  {
   self.think = mezzo_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


entity  ()mezzo_look_projectiles =  {
local entity found;
local entity enemy_proj;
local float dist = 0.00000;
local float bestdist = 0.00000;
   found = findradius (self.origin, 1000.00000);
   bestdist = 1001.00000;
   while ( found ) {

      if ( (((found.movetype == MOVETYPE_FLYMISSILE) || (found.movetype == MOVETYPE_BOUNCE)) || (found.movetype == MOVETYPE_BOUNCEMISSILE)) ) {

         if ( visible (found) ) {

            dist = vlen ((found.origin - self.origin));
            if ( (dist < bestdist) ) {

               if ( heading (self, found) ) {

                  bestdist = dist;
                  enemy_proj = found;

               }

            }

         }

      }
      found = found.chain;

   }
   if ( enemy_proj ) {

      self.level = (bestdist / vlen (enemy_proj.velocity));
      return ( enemy_proj );
   } else {

      return ( world );

   }
};


void  ()mezzo_roll_right =  {
local vector rollangle = '0.00000 0.00000 0.00000';
   AdvanceFrame( 140.00000, 123.00000);
   makevectors (self.angles);
   rollangle = vectoangles (v_right);
   walkmove (rollangle_y, 7.00000, FALSE);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      if ( !(self.flags & FL_ONGROUND) ) {

         self.think = mezzo_in_air;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()mezzo_roll_left =  {
local vector rollangle = '0.00000 0.00000 0.00000';
   AdvanceFrame( 123.00000, 140.00000);
   makevectors (self.angles);
   rollangle = vectoangles (v_right);
   walkmove (rollangle_y, -7.00000, FALSE);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      if ( !(self.flags & FL_ONGROUND) ) {

         self.think = mezzo_in_air;
      } else {

         self.think = self.th_run;

      }

   }
};


void  ()mezzo_duck =  {
local vector newmaxs = '0.00000 0.00000 0.00000';
   AdvanceFrame( 75.00000, 84.00000);
   if ( (self.frame == 76.00000) ) {

      newmaxs = self.maxs;
      newmaxs_z = (self.maxs_z * 0.50000);
      setsize (self, self.mins, newmaxs);
   } else {

      if ( (self.frame == 80.00000) ) {

         newmaxs = self.maxs;
         newmaxs_z = (self.maxs_z * 2.00000);
         setsize (self, self.mins, newmaxs);
      } else {

         if ( (self.frame == 78.00000) ) {

            self.nextthink = (time + 0.50000);
         } else {

            if ( cycle_wrapped ) {

               self.nextthink = time;
               self.think = self.th_run;

            }

         }

      }

   }
};


float  (entity proj)mezzo_check_duck =  {
local float proj_minz = 0.00000;
local float duck_hite = 0.00000;
local float proj_velz = 0.00000;
   proj_minz = (proj.origin_z - proj.mins_z);
   duck_hite = (self.origin_z + (self.maxs_z / 2.00000));
   proj_velz = proj.velocity_z;
   if ( ((proj_minz > duck_hite) && (proj_velz >= 0.00000)) ) {

      return ( TRUE );
   } else {

      return ( FALSE );

   }
};


float  (entity proj)mezzo_check_jump =  {
local float impact_hite = 0.00000;
local float jump_hite = 0.00000;
local vector proj_dir = '0.00000 0.00000 0.00000';
local vector proj_top = '0.00000 0.00000 0.00000';
   if ( !(self.flags & FL_ONGROUND) ) {

      return ( FALSE );

   }
   proj_dir = normalize (proj.velocity);
   proj_top = proj.origin;
   proj_top_z = proj.absmax_z;
   traceline (proj_top, (proj_top + (proj_dir * 1000.00000)), FALSE, proj);
   if ( (trace_ent != self) ) {

      return ( FALSE );

   }
   impact_hite = trace_endpos_z;
   tracearea (self.origin, (self.origin + '0.00000 0.00000 56.00000'), self.mins, self.maxs, FALSE, self);
   jump_hite = (trace_fraction * 56.00000);
   if ( (jump_hite < 24.00000) ) {

      return ( FALSE );

   }
   if ( (((self.origin_z + (jump_hite / 2.00000)) > (impact_hite + proj.maxs_z)) && (random () < 0.70000)) ) {

      self.velocity_z = (jump_hite * 7.00000);
      if ( (self.flags & FL_ONGROUND) ) {

         self.flags -= FL_ONGROUND;

      }
      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity object)check_heading_left_or_right =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local float dot = 0.00000;
local float rng = 0.00000;
   makevectors (self.angles);
   spot1 = (self.origin + self.view_ofs);
   spot2 = object.origin;
   rng = vlen ((spot1 - spot2));
   spot2 += (normalize (object.velocity) * (rng + 15.00000));
   vec = normalize ((spot2 - spot1));
   dot = (vec * v_right);
   if ( (dot > 0.00000) ) {

      return ( -1.00000 );

   }
   dot = (vec * (v_right * -1.00000));
   if ( (dot > 0.00000) ) {

      return ( 1.00000 );

   }
   return ( 0.00000 );
};


void  (entity proj)mezzo_choose_roll =  {
local float proj_dir = 0.00000;
   proj_dir = check_heading_left_or_right (proj);
   if ( (proj_dir == 0.00000) ) {

      if ( mezzo_check_duck (proj) ) {

         self.nextthink = time;
         self.think = mezzo_duck;
      } else {

         self.nextthink = time;
         self.think = mezzo_block;

      }
      return ;
   } else {

      makevectors (self.angles);
      tracearea (self.origin, (self.origin + ((v_right * 36.00000) * proj_dir)), self.mins, self.maxs, FALSE, self);
      if ( (trace_fraction == 1.00000) ) {

         traceline (trace_endpos, (trace_endpos - '0.00000 0.00000 300.00000'), TRUE, self);
         if ( (pointcontents (trace_endpos) != CONTENT_EMPTY) ) {

            trace_fraction = FALSE;
         } else {

            trace_fraction = TRUE;

         }

      }
      if ( (trace_fraction == 1.00000) ) {

         if ( (proj_dir > 0.00000) ) {

            self.nextthink = time;
            self.think = mezzo_roll_right;
         } else {

            self.nextthink = time;
            self.think = mezzo_roll_left;

         }
         return ;
      } else {

         if ( mezzo_check_duck (proj) ) {

            self.nextthink = time;
            self.think = mezzo_duck;
         } else {

            self.nextthink = time;
            self.think = mezzo_block;

         }

      }

   }
};


void  ()mezzo_check_defense =  {
local entity enemy_proj;
local float r = 0.00000;
local vector enemy_dir = '0.00000 0.00000 0.00000';
   if ( ((((self.enemy.last_attack + 0.50000) < time) && ((self.oldenemy.last_attack + 0.50000) < time)) || self.aflag) ) {

      return ;

   }
   enemy_proj = mezzo_look_projectiles ();
   if ( !enemy_proj ) {

      if ( lineofsight (self, self.enemy) ) {

         enemy_proj = self.enemy;
         self.level = (vlen ((self.enemy.origin - self.origin)) / 1000.00000);
      } else {

         return ;

      }

   }
   if ( (self.flags & FL_ONGROUND) ) {

      self.velocity = '0.00000 0.00000 0.00000';

   }
   r = range (enemy_proj);
   if ( ((self.enemy.weapon == IT_WEAPON1) && (r <= RANGE_NEAR)) ) {

      if ( (r == RANGE_MELEE) ) {

         if ( ((random () < 0.70000) || (self.enemy.v_angle_x >= 0.00000)) ) {

            self.nextthink = time;
            self.think = mezzo_duck;
         } else {

            self.nextthink = time;
            self.think = mezzo_block;

         }
      } else {

         if ( (random () < 0.50000) ) {

            mezzo_choose_roll (enemy_proj);
         } else {

            if ( ((random () < 0.70000) || (self.enemy.v_angle_x >= 0.00000)) ) {

               self.nextthink = time;
               self.think = mezzo_duck;
            } else {

               self.nextthink = time;
               self.think = mezzo_block;

            }

         }

      }
      return ;

   }
   if ( (self.level > 0.30000) ) {

      mezzo_choose_roll (enemy_proj);
   } else {

      if ( mezzo_check_jump (enemy_proj) ) {

         self.think = mezzo_jump;
         enemy_infront = infront (self.enemy);
         enemy_vis = visible (self.enemy);
         trace_fraction = 0.00000;
         if ( (((((random () < 0.30000) || (self.think == mezzo_run_loop)) && enemy_infront) && enemy_vis) && (self.enemy != world)) ) {

            enemy_dir = normalize ((self.enemy.origin - self.origin));
            traceline (self.origin, ((self.origin + (enemy_dir * 64.00000)) + '0.00000 0.00000 56.00000'), FALSE, self);
            if ( (trace_fraction == 1.00000) ) {

               traceline (trace_endpos, (trace_endpos - '0.00000 0.00000 300.00000'), TRUE, self);
               if ( (pointcontents (trace_endpos) == CONTENT_EMPTY) ) {

                  self.velocity += (enemy_dir * vlen ((self.enemy.origin - self.origin)));
                  trace_fraction = 1.00000;
                  self.think = self.th_jump;
               } else {

                  trace_fraction = 0.00000;

               }
            } else {

               trace_fraction = 0.00000;

            }

         }
         if ( ((random () < 0.50000) && (trace_fraction < 1.00000)) ) {

            if ( (random () < 0.50000) ) {

               r = 1.00000;
            } else {

               r = -1.00000;

            }
            makevectors (self.angles);
            traceline (self.origin, ((self.origin + ((v_right * 36.00000) * r)) + '0.00000 0.00000 56.00000'), FALSE, self);
            if ( (trace_fraction < 1.00000) ) {

               traceline (self.origin, ((self.origin - ((v_right * 36.00000) * r)) + '0.00000 0.00000 56.00000'), FALSE, self);
               if ( (trace_fraction < 1.00000) ) {

                  self.think = mezzo_jump;
               } else {

                  traceline (trace_endpos, (trace_endpos - '0.00000 0.00000 300.00000'), TRUE, self);
                  if ( (pointcontents (trace_endpos) != CONTENT_EMPTY) ) {

                     self.think = mezzo_jump;
                  } else {

                     self.velocity -= ((v_right * r) * 200.00000);
                     if ( ((r * -1.00000) > 0.00000) ) {

                        self.think = mezzo_roll_right;
                     } else {

                        self.think = mezzo_roll_left;

                     }

                  }

               }
            } else {

               traceline (trace_endpos, (trace_endpos - '0.00000 0.00000 300.00000'), TRUE, self);
               if ( (pointcontents (trace_endpos) != CONTENT_EMPTY) ) {

                  self.think = mezzo_jump;
               } else {

                  self.velocity += ((v_right * r) * 200.00000);
                  if ( (r > 0.00000) ) {

                     self.think = mezzo_roll_right;
                  } else {

                     self.think = mezzo_roll_left;

                  }

               }

            }

         }
         self.nextthink = time;
         if ( (((self.think != mezzo_jump) && (self.think != mezzo_roll_right)) && (self.think != mezzo_roll_left)) ) {

            dprint ("What the FUCK!!!\n");
            self.think = mezzo_jump;

         }
         return ;
      } else {

         if ( mezzo_check_duck (enemy_proj) ) {

            self.nextthink = time;
            self.think = mezzo_duck;
         } else {

            if ( infront (enemy_proj) ) {

               if ( (self.think == mezzo_block_wait) ) {

                  self.t_width = (time + 1.70000);
                  return ;
               } else {

                  if ( (self.think == mezzo_run_loop) ) {

                     self.nextthink = time;
                     self.think = mezzo_skid;
                  } else {

                     self.nextthink = time;
                     self.think = mezzo_block;

                  }

               }

            }

         }

      }

   }
   return ;
};

void  ()mezzo_charge_stop;

void  ()mezzo_slam =  {
local float inertia = 0.00000;
local vector punchdir = '0.00000 0.00000 0.00000';
   if ( ((!other.movetype || (other.mass > 100.00000)) || (other.solid == SOLID_BSP)) ) {

      return ;

   }
   if ( (!infront (other) || (other.safe_time > time)) ) {

      return ;

   }
   if ( ((other.origin_z > (self.absmax_z - 6.00000)) || (other.absmax_z < (self.origin_z + 6.00000))) ) {

      return ;

   }
   sound (self, CHAN_VOICE, "mezzo/slam.wav", 1.00000, ATTN_NORM);
   if ( (other.mass < 10.00000) ) {

      inertia = 1.00000;
   } else {

      inertia = (other.mass / 10.00000);

   }
   makevectors (self.angles);
   punchdir = ((v_forward * 300.00000) + '0.00000 0.00000 100.00000');
   T_Damage (other, self, self, (10.00000 * (self.aflag + 1.00000)));
   other.velocity += (punchdir * (1.00000 / inertia));
   if ( (other.flags & FL_ONGROUND) ) {

      other.flags -= FL_ONGROUND;

   }
   self.ltime += 1.00000;
   other.safe_time = (time + 1.25000);
   if ( (self.think != mezzo_charge_stop) ) {

      self.nextthink = time;
      self.think = mezzo_charge_stop;

   }
};


void  ()mezzo_reflect_trig_touch =  {
local vector newv = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local vector endspot = '0.00000 0.00000 0.00000';
local vector endplane = '0.00000 0.00000 0.00000';
local vector dif = '0.00000 0.00000 0.00000';
local float remainder = 0.00000;
local float reflect_count = 0.00000;
local float magnitude = 0.00000;
   if ( ((((other.flags & FL_MONSTER) || (other.flags & FL_CLIENT)) || !other) || (other == self)) ) {

      return ;

   }
   if ( (other.safe_time > time) ) {

      return ;

   }
   dir = normalize (other.velocity);
   magnitude = vlen (other.velocity);
   org = other.origin;
   vec = (org + (dir * 100.00000));
   traceline (org, vec, FALSE, other);
   if ( (trace_ent != self.owner) ) {

      return ;

   }
   sound (self, CHAN_AUTO, "mezzo/reflect.wav", 1.00000, ATTN_NORM);
   makevectors (trace_ent.angles);
   dir += (2.00000 * v_forward);
   dir = normalize (dir);
   self.owner.last_attack = time;
   other.safe_time = (time + (100.00000 / magnitude));
   other.velocity = (dir * magnitude);
   other.angles = vectoangles (other.velocity);
   if ( !other.controller ) {

      other.controller = other.owner;

   }
   other.owner = world;
};


void  ()reflect_think =  {
   makevectors (self.owner.angles);
   setorigin (self, ((self.owner.origin + (v_forward * 48.00000)) + '0.00000 0.00000 40.00000'));
   self.think = reflect_think;
   self.nextthink = (time + 0.05000);
};


void  ()mezzo_spawn_reflect =  {
local entity trigger;
   makevectors (self.angles);
   trigger = spawn ();
   trigger.movetype = MOVETYPE_NOCLIP;
   trigger.solid = SOLID_TRIGGER;
   self.movechain = trigger;
   trigger.owner = self;
   trigger.touch = mezzo_reflect_trig_touch;
   trigger.classname = "mezzo_reflect";
   setsize (trigger, '-32.00000 -32.00000 -10.00000', '32.00000 32.00000 30.00000');
   setorigin (trigger, ((self.origin + (v_forward * 48.00000)) + '0.00000 0.00000 40.00000'));
   trigger.think = reflect_think;
   trigger.nextthink = time;
};


void  ()mezzo_clobber =  {
   AdvanceFrame( 31.00000, 46.00000);
   ai_charge (1.00000);
   if ( (self.frame == 37.00000) ) {

      makevectors (self.angles);
      traceline ((self.origin + '0.00000 0.00000 30.00000'), ((self.origin + '0.00000 0.00000 30.00000') + (v_forward * 36.00000)), FALSE, self);
      if ( (trace_fraction == 1.00000) ) {

         return ;

      }
      sound (self, CHAN_VOICE, "mezzo/slam.wav", 1.00000, ATTN_NORM);
      if ( (trace_ent.movetype && (trace_ent.movetype != MOVETYPE_PUSH)) ) {

         trace_ent.velocity += (((v_forward * 200.00000) - (v_right * 100.00000)) + '0.00000 0.00000 100.00000');

      }
      if ( trace_ent.takedamage ) {

         T_Damage (trace_ent, self, self, (10.00000 * (self.aflag + 1.00000)));

      }
      if ( (trace_ent.classname == "player") ) {

         if ( infront_of_ent (self, trace_ent) ) {

            trace_ent.punchangle_y = 4.00000;

         }

      }
   } else {

      if ( cycle_wrapped ) {

         self.attack_finished = (time + 0.50000);
         self.nextthink = time;
         self.think = self.th_run;
      } else {

         if ( (self.frame == 31.00000) ) {

            self.last_attack = time;

         }

      }

   }
};


void  ()mezzo_sword =  {
local float ofs = 0.00000;
local vector dir = '0.00000 0.00000 0.00000';
   AdvanceFrame( 173.00000, 185.00000);
   ai_face ();
   ai_charge (3.00000);
   if ( cycle_wrapped ) {

      self.attack_finished = (time + 0.30000);
      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 173.00000) ) {

         self.last_attack = time;
         sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 1.00000, ATTN_NORM);
      } else {

         if ( ((self.frame >= 178.00000) && (self.frame <= 182.00000)) ) {

            makevectors (self.angles);
            ofs = ((182.00000 - self.frame) * 4.00000);
            dir_z = (ofs - 8.00000);
            dir += ((v_right * (ofs - 8.00000)) + (v_forward * (48.00000 - fabs ((16.00000 - ofs)))));
            dir = normalize (dir);
            traceline ((self.origin + '0.00000 0.00000 37.00000'), ((self.origin + '0.00000 0.00000 37.00000') + (dir * 48.00000)), FALSE, self);
            spawntestmarker (trace_endpos);
            if ( (trace_fraction == 1.00000) ) {

               return ;

            }
            if ( (self.t_width < time) ) {

               MetalHitSound (trace_ent.thingtype);
               self.t_width = (time + 1.00000);

            }
            if ( trace_ent.takedamage ) {

               T_Damage (trace_ent, self, self, (3.00000 * (self.aflag + 1.00000)));

            }
            SpawnPuff (trace_endpos, '0.00000 0.00000 0.00000', 3.00000, trace_ent);

         }

      }

   }
};


void  ()mezzo_melee =  {
   if ( (random () < 0.30000) ) {

      self.think = mezzo_clobber;
   } else {

      self.think = mezzo_sword;

   }
   self.nextthink = time;
};

void  ()mezzo_charge;

void  ()mezzo_missile =  {
   if ( ((vlen ((self.enemy.origin - self.origin)) < 84.00000) && lineofsight (self.enemy, self)) ) {

      self.think = mezzo_charge;
   } else {

      self.think = self.th_run;

   }
   self.nextthink = time;
};


void  ()mezzo_die =  {
   AdvanceFrame( 47.00000, 62.00000);
   if ( self.movechain ) {

      remove (self.movechain);

   }
   if ( (self.health < -40.00000) ) {

      chunk_death ();
      return ;

   }
   if ( (self.frame == 47.00000) ) {

      sound (self, CHAN_VOICE, "mezzo/die.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.frame == 58.00000) ) {

         sound (self, CHAN_BODY, "player/land.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.frame == 62.00000) ) {

            MakeSolidCorpse ("remove");

         }

      }

   }
   self.nextthink = (time + 0.10000);
};


void  ()mezzo_pain_seq =  {
   AdvanceFrame( 86.00000, 92.00000);
   ai_back (1.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      if ( !(self.flags & FL_ONGROUND) ) {

         self.think = mezzo_in_air;
      } else {

         self.think = self.th_run;

      }

   }
};


void  (entity attacker,float damage)mezzo_pain =  {
   if ( ((random () * self.health) > damage) ) {

      return ;

   }
   self.monster_awake = TRUE;
   if ( self.movechain ) {

      remove (self.movechain);

   }
   if ( ((self.pain_finished > time) || (self.health <= 100.00000)) ) {

      self.th_pain = SUB_Null;
      if ( (self.health <= 100.00000) ) {

         if ( (random () < 0.50000) ) {

            self.oldthink = self.th_run;
            self.think = mezzo_roar;
            self.speed = 15.00000;
            self.yaw_speed = 20.00000;
            self.aflag = TRUE;
         } else {

            if ( !(self.flags & FL_ONGROUND) ) {

               self.think = mezzo_in_air;
            } else {

               self.think = self.th_run;

            }

         }
      } else {

         if ( !(self.flags & FL_ONGROUND) ) {

            self.think = mezzo_in_air;
         } else {

            self.think = mezzo_block;

         }

      }
   } else {

      sound (self, CHAN_VOICE, "mezzo/pain.wav", 1.00000, ATTN_NORM);
      self.pain_finished = (time + 1.70000);
      self.think = mezzo_pain_seq;

   }
   self.nextthink = time;
};


void  ()mezzo_land =  {
   AdvanceFrame( 75.00000, 84.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 75.00000) ) {

         sound (self, CHAN_BODY, "player/land.wav", 1.00000, ATTN_NORM);

      }

   }
};


void  ()mezzo_in_air =  {
   self.frame = 74.00000;
   if ( (self.flags & FL_ONGROUND) ) {

      self.nextthink = time;
      self.think = mezzo_land;
   } else {

      self.think = mezzo_in_air;
      self.nextthink = (time + 0.05000);

   }
};


void  ()mezzo_jump =  {
   AdvanceFrame( 63.00000, 73.00000);
   if ( (self.flags & FL_ONGROUND) ) {

      self.nextthink = time;
      self.think = mezzo_land;
   } else {

      if ( (self.frame == 73.00000) ) {

         self.nextthink = (time + 0.05000);
         self.think = mezzo_in_air;

      }

   }
};


void  ()mezzo_charge_stop =  {
   AdvanceFrame( 20.00000, 30.00000);
   if ( cycle_wrapped ) {

      self.touch = obj_push;
      self.nextthink = time;
      self.think = self.th_run;

   }
   if ( !walkmove (self.angles_y, (30.00000 - self.frame), FALSE) ) {

      if ( !self.ltime ) {

         self.think = mezzo_pain_seq;
      } else {

         self.think = self.th_run;

      }
      self.nextthink = time;

   }
};


void  ()mezzo_charge_leap =  {
   AdvanceFrame( 14.00000, 19.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = mezzo_charge_stop;
   } else {

      if ( (self.frame == 14.00000) ) {

         makevectors (self.angles);
         traceline ((self.origin + '0.00000 0.00000 25.00000'), ((self.origin + '0.00000 0.00000 25.00000') + (v_forward * 400.00000)), FALSE, self);
         traceline (trace_endpos, (trace_endpos - '0.00000 0.00000 300.00000'), TRUE, self);
         if ( ((pointcontents (trace_endpos) != CONTENT_EMPTY) || (trace_fraction == 1.00000)) ) {

            self.think = mezzo_skid;
            self.nextthink = time;
         } else {

            if ( (self.flags & FL_ONGROUND) ) {

               self.velocity = ((v_forward * 700.00000) + '0.00000 0.00000 133.00000');
               self.flags -= FL_ONGROUND;
            } else {

               self.think = mezzo_in_air;
               self.nextthink = time;

            }

         }

      }

   }
};


void  ()mezzo_charge =  {
   AdvanceFrame( 6.00000, 13.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = mezzo_charge_leap;
   } else {

      if ( (self.frame == 6.00000) ) {

         self.last_attack = time;
         self.ltime = 0.00000;
         self.touch = mezzo_slam;
         self.attack_finished = (time + 1.25000);

      }

   }
   walkmove (self.angles_y, 15.00000, FALSE);
};


void  ()mezzo_block_return =  {
local float r = 0.00000;
   AdvanceFrame( 5.00000, 0.00000);
   if ( cycle_wrapped ) {

      if ( self.movechain ) {

         remove (self.movechain);

      }
      r = vlen ((self.enemy.origin - self.origin));
      if ( (infront (self.enemy) && (r < 100.00000)) ) {

         self.nextthink = time;
         self.think = self.th_melee;
      } else {

         self.nextthink = time;
         self.think = self.th_run;

      }

   }
};


void  ()mezzo_block_wait =  {
   if ( (self.t_width < time) ) {

      self.nextthink = time;
      self.think = mezzo_block_return;
   } else {

      self.frame = 5.00000;
      ai_face ();
      self.think = mezzo_block_wait;
      self.nextthink = (time + 0.05000);

   }
   mezzo_check_defense ();
   if ( (range (self.enemy) == RANGE_MELEE) ) {

      if ( CheckAnyAttack () ) {

         return ;

      }

   }
};


void  ()mezzo_block =  {
   AdvanceFrame( 0.00000, 5.00000);
   walkmove (self.angles_y, -1.00000, FALSE);
   if ( cycle_wrapped ) {

      if ( ((self.th_pain == SUB_Null) && (self.health > 77.00000)) ) {

         self.th_pain = mezzo_pain;

      }
      self.t_width = (time + 1.70000);
      self.nextthink = time;
      self.think = mezzo_block_wait;
   } else {

      if ( (self.frame == 0.00000) ) {

         mezzo_spawn_reflect ();

      }

   }
};


void  ()mezzo_skid =  {
local float skidspeed = 0.00000;
local float anim_stretch = 0.00000;
   AdvanceFrame( 0.00000, 5.00000);
   anim_stretch = 3.00000;
   skidspeed = (((5.00000 - self.frame) + anim_stretch) - self.level);
   if ( walkmove (self.angles_y, (skidspeed * 2.00000), FALSE) ) {

      particle (self.origin, ('0.00000 0.00000 20.00000' * skidspeed), 344.00000, skidspeed);
      if ( (random () < 0.20000) ) {

         CreateWhiteSmoke (self.origin);

      }
   } else {

      self.nextthink = time;
      self.think = mezzo_block_return;
      return ;

   }
   if ( cycle_wrapped ) {

      self.attack_finished = (time + 3.00000);
      self.nextthink = time;
      self.think = mezzo_block_return;
   } else {

      if ( (self.frame == 0.00000) ) {

         mezzo_spawn_reflect ();
         sound (self, CHAN_AUTO, "mezzo/skid.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.level < anim_stretch) ) {

            self.frame -= 1.00000;
            self.level += 1.00000;
         } else {

            self.level = 0.00000;

         }

      }

   }
};


void  ()mezzo_roar =  {
   AdvanceFrame( 93.00000, 122.00000);
   self.health += 1.10000;
   mezzo_check_defense ();
   if ( (self.frame == 122.00000) ) {

      if ( !self.aflag ) {

         self.th_pain = mezzo_pain;

      }
      if ( !self.takedamage ) {

         self.takedamage = DAMAGE_YES;

      }
      self.last_attack = (time + 3.00000);
      self.nextthink = time;
      self.think = self.oldthink;
   } else {

      if ( (self.frame == 93.00000) ) {

         self.monster_awake = TRUE;
         if ( (self.health < 100.00000) ) {

            self.takedamage = DAMAGE_NO;

         }
         sound (self, CHAN_VOICE, "mezzo/roar.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.frame == 111.00000) ) {

            self.nextthink = (time + 2.00000);

         }

      }

   }
};


void  ()mezzo_run_think =  {
local float dist = 0.00000;
   mezzo_check_defense ();
   if ( (!(self.enemy.flags2 & FL_ALIVE) && (self.enemy != world)) ) {

      self.monster_awake = FALSE;
      visible (self.enemy);
      if ( (infront (self.enemy) && infront (self.enemy)) ) {

         self.oldthink = self.th_stand;
         self.think = mezzo_roar;
      } else {

         self.think = self.th_stand;

      }
      if ( (self.oldenemy.flags2 & FL_ALIVE) ) {

         self.enemy = self.oldenemy;
         self.oldenemy = world;
         self.think = self.th_run;
      } else {

         self.enemy = world;

      }
      self.nextthink = time;
   } else {

      if ( (self.enemy != world) ) {

         if ( visible (self.enemy) ) {

            dist = vlen ((self.enemy.origin - self.origin));
            if ( ((dist < 177.00000) && (dist > 33.00000)) ) {

               if ( ((random () < 0.50000) && lineofsight (self.enemy, self)) ) {

                  self.nextthink = time;
                  self.think = mezzo_charge;
               } else {

                  if ( (((dist > 84.00000) && (self.last_attack < time)) && infront (self.enemy)) ) {

                     self.nextthink = time;
                     self.think = mezzo_skid;

                  }

               }
            } else {

               if ( !infront (self.enemy) ) {

                  if ( (self.last_attack < time) ) {

                     if ( !self.aflag ) {

                        self.yaw_speed = 10.00000;

                     }
                     self.last_attack = (time + 3.00000);
                     self.nextthink = time;
                     self.think = mezzo_skid;
                  } else {

                     self.yaw_speed = 20.00000;

                  }
               } else {

                  if ( !self.aflag ) {

                     self.yaw_speed = 10.00000;

                  }

               }

            }
         } else {

            self.yaw_speed = 10.00000;

         }
         ai_run (self.speed);
      } else {

         self.think = self.th_stand;
         self.nextthink = time;

      }

   }
};


void  ()mezzo_run_loop =  {
   AdvanceFrame( 141.00000, 162.00000);
   mezzo_run_think ();
};


void  ()mezzo_run =  {
   AdvanceFrame( 146.00000, 162.00000);
   mezzo_check_defense ();
   self.last_attack = (time + 0.10000);
   if ( !self.monster_awake ) {

      if ( ((range (self.enemy) > RANGE_NEAR) && (random () > 0.30000)) ) {

         self.oldthink = self.th_run;
         self.think = mezzo_roar;
         self.nextthink = time;
         return ;
      } else {

         self.monster_awake = TRUE;

      }

   }
   if ( cycle_wrapped ) {

      self.think = mezzo_run_loop;
      self.nextthink = time;
   } else {

      mezzo_run_think ();

   }
};


void  ()mezzo_walk =  {
   AdvanceFrame( 196.00000, 225.00000);
   if ( ((self.frame == 165.00000) && (random () < 0.10000)) ) {

      mezzo_idle_sound ();

   }
   mezzo_check_defense ();
   ai_walk (3.00000);
   if ( self.enemy ) {

      if ( CheckAnyAttack () ) {

         return ;

      }

   }
};

void  ()mezzo_stand;

void  ()mezzo_twirl =  {
   AdvanceFrame( 186.00000, 195.00000);
   mezzo_check_defense ();
   if ( cycle_wrapped ) {

      self.think = mezzo_stand;
      self.nextthink = time;
   } else {

      if ( (self.frame == 186.00000) ) {

         sound (self, CHAN_WEAPON, "weapons/vorpswng.wav", 0.70000, ATTN_NORM);
         if ( (random () < 0.50000) ) {

            mezzo_idle_sound ();

         }

      }

   }
   ai_stand ();
};


void  ()mezzo_stand2 =  {
   AdvanceFrame( 172.00000, 163.00000);
   mezzo_check_defense ();
   if ( ((self.level < 3.00000) && (self.frame < 172.00000)) ) {

      self.level += 1.00000;
      self.frame += 1.00000;
   } else {

      self.level = 0.00000;

   }
   if ( (self.frame == 163.00000) ) {

      if ( ((random () < 0.10000) || (self.monster_awake && (random () < 0.50000))) ) {

         self.think = mezzo_twirl;
      } else {

         self.think = mezzo_stand;

      }
      self.nextthink = time;
      return ;
   } else {

      if ( ((self.frame == 172.00000) && (random () < 0.10000)) ) {

         mezzo_idle_sound ();

      }

   }
   ai_stand ();
};


void  ()mezzo_stand =  {
   AdvanceFrame( 163.00000, 172.00000);
   mezzo_check_defense ();
   if ( ((!(self.enemy.flags2 & FL_ALIVE) && (self.enemy != world)) || (self.enemy == world)) ) {

      self.monster_awake = FALSE;
      if ( (self.oldenemy.flags2 & FL_ALIVE) ) {

         self.enemy = self.oldenemy;
         self.oldenemy = world;
      } else {

         self.enemy = world;

      }

   }
   if ( ((self.level < 3.00000) && (self.frame > 163.00000)) ) {

      self.level += 1.00000;
      self.frame -= 1.00000;
   } else {

      self.level = 0.00000;

   }
   if ( (self.frame == 172.00000) ) {

      self.think = mezzo_stand2;
      self.nextthink = time;
      return ;
   } else {

      if ( ((self.frame == 163.00000) && (random () < 0.10000)) ) {

         mezzo_idle_sound ();

      }

   }
   ai_stand ();
};


void  ()monster_werejaguar =  {
   if ( !(self.flags2 & FL_SUMMONED) ) {

      precache_model2 ("models/mezzoman.mdl");
      precache_sound ("mezzo/skid.wav");
      precache_sound ("mezzo/roar.wav");
      precache_sound ("mezzo/reflect.wav");
      precache_sound ("mezzo/slam.wav");
      precache_sound ("mezzo/pain.wav");
      precache_sound ("mezzo/die.wav");
      precache_sound ("mezzo/growl.wav");
      precache_sound ("mezzo/snort.wav");

   }
   self.solid = SOLID_SLIDEBOX;
   self.takedamage = DAMAGE_YES;
   self.thingtype = THINGTYPE_FLESH;
   self.movetype = MOVETYPE_STEP;
   self.view_ofs = '0.00000 0.00000 53.00000';
   self.speed = 10.00000;
   self.yaw_speed = 10.00000;
   self.health = 400.00000;
   self.mass = 10.00000;
   self.mintel = 15.00000;
   if ( (self.classname == "monster_werepanther") ) {

      self.skin = 1.00000;

   }
   self.classname = "monster_mezzoman";
   self.th_stand = mezzo_stand;
   self.th_walk = mezzo_walk;
   self.th_run = mezzo_run;
   self.th_pain = mezzo_pain;
   self.th_melee = mezzo_melee;
   self.th_missile = mezzo_missile;
   self.th_jump = mezzo_jump;
   self.th_die = mezzo_die;
   self.th_possum = mezzo_playdead;
   self.th_possum_up = mezzo_possum_up;
   setmodel (self, "models/mezzoman.mdl");
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
   self.frame = 163.00000;
   walkmonster_start ();
};


void  ()monster_mezzoman =  {
   monster_werejaguar ();
};


void  ()monster_werepanther =  {
   monster_werejaguar ();
};


void  ()leaves_blow =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   self.use = SUB_Null;
   if ( !other ) {

      self.velocity_x += ((random () * 120.00000) - 60.00000);
      self.velocity_y += ((random () * 120.00000) - 60.00000);
      self.avelocity_x += ((random () * 300.00000) - 150.00000);
      self.avelocity_y += ((random () * 300.00000) - 150.00000);
      self.avelocity_z += ((random () * 300.00000) - 150.00000);
   } else {

      self.velocity_x = ((self.velocity_x + other.velocity_x) * 0.50000);
      self.velocity_y = ((self.velocity_y + other.velocity_y) * 0.50000);
      self.pain_finished = (time + 1.00000);

   }
   self.think = leaves_blow;
   self.nextthink = ((time + random ()) + 0.30000);
};


void  (float leaf_cnt)spawnleaves =  {
local entity last_ent;
local float r = 0.00000;
   last_ent = self;
   while ( leaf_cnt ) {

      leaf_cnt -= 1.00000;
      newmis = spawn ();
      newmis.solid = SOLID_NOT;
      newmis.movetype = MOVETYPE_NOCLIP;
      r = random ();
      if ( (r < 0.33000) ) {

         setmodel (newmis, "models/leafchk1.mdl");
      } else {

         if ( (r < 0.66000) ) {

            setmodel (newmis, "models/leafchk2.mdl");
         } else {

            setmodel (newmis, "models/leafchk3.mdl");

         }

      }
      setorigin (newmis, self.origin);
      newmis.origin_x += ((random () * 20.00000) - 40.00000);
      newmis.origin_y += ((random () * 20.00000) - 40.00000);
      newmis.angles_y = (random () * 360.00000);
      last_ent.movechain = newmis;
      newmis.flags += FL_MOVECHAIN_ANGLE;
      last_ent = newmis;

   }
};


void  ()obj_pile_of_leaves =  {
   if ( !self.cnt ) {

      self.cnt = 10.00000;

   }
   spawnleaves (self.cnt);
   setmodel (self, "models/test.mdl");
   self.effects = EF_NODRAW;
   self.use = leaves_blow;
   self.touch = leaves_blow;
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NOCLIP;
};

