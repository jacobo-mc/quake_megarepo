float war_start [3]   = { 15.00000,
    27.00000,    43.00000};
float war_end [3]   = { 26.00000,
    42.00000,    62.00000};
float war_speed [3]   = { 12.00000,
    10.00000,    6.00000};
float WarRiderFrames [23]   = { 63.00000,
    75.00000,    91.00000,    151.00000,    111.00000,
    167.00000,    0.00000,    7.00000,    8.00000,
    149.00000,    48.00000,    56.00000,    57.00000,
    60.00000,    12.00000,    21.00000,    23.00000,
    24.00000,    28.00000,    39.00000,    40.00000,
    41.00000,    42.00000};
float WH_STAGE_NORMAL   =  0.00000;
float WH_STAGE_BEGIN_REAR   =  1.00000;
float WH_STAGE_MIDDLE_REAR   =  2.00000;
float WH_STAGE_END_REAR   =  3.00000;
float WH_STAGE_ATTACK   =  4.00000;
float WH_STAGE_STANDING   =  5.00000;

void  ()waraxe_touch =  {
   if ( other.health ) {

      T_Damage (other, self, self, (15.00000 + (random () * 5.00000)));

   }
   remove (self);
};


void  ()waraxe_move =  {
local vector vec = '0.00000 0.00000 0.00000';
local vector v2 = '0.00000 0.00000 0.00000';
local vector v3 = '0.00000 0.00000 0.00000';
local float neg_offset = 0.00000;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.lifetime < time) ) {

      self.velocity_z -= 20.00000;
      return ;

   }
   if ( (self.enemy.health > 0.00000) ) {

      neg_offset = (0.00000 - self.waraxe_offset);
      vec = ((self.enemy.origin - self.origin) + self.enemy.proj_ofs);
      vec = normalize (vec);
      vec_x *= self.count;
      v2 = self.velocity;
      v3 = (vec - v2);
      if ( (v3_x < neg_offset) ) {

         v3_x = neg_offset;

      }
      if ( (v3_x > self.waraxe_offset) ) {

         v3_x = self.waraxe_offset;

      }
      if ( (v3_y < neg_offset) ) {

         v3_y = neg_offset;

      }
      if ( (v3_y > self.waraxe_offset) ) {

         v3_y = self.waraxe_offset;

      }
      if ( (v3_z < neg_offset) ) {

         v3_z = neg_offset;

      }
      if ( (v3_z > self.waraxe_offset) ) {

         v3_z = self.waraxe_offset;

      }
      if ( (self.count < 380.00000) ) {

         v3_z = (self.waraxe_max_height + random ());

      }
      self.velocity = (v2 + v3);
      self.count += 20.00000;
      if ( (self.count > self.waraxe_max_speed) ) {

         self.count = self.waraxe_max_speed;

      }
      if ( (self.waraxe_offset < self.waraxe_track_limit) ) {

         self.waraxe_offset += self.waraxe_track_inc;

      }
      vec = vectoangles (self.velocity);
      if ( self.waraxe_horizontal ) {

         self.angles_y = (vec_y + 40.00000);
         self.angles_x = (vec_x + self.cnt);
      } else {

         self.angles_y = (vec_y + self.cnt);

      }

   }
};


void  (entity new_target,vector offset,float horizontal)waraxe =  {
local entity axe;
local entity cube;
local vector vec = '0.00000 0.00000 0.00000';
   axe = spawn ();
   axe.movetype = MOVETYPE_FLYMISSILE;
   axe.solid = SOLID_BBOX;
   setmodel (axe, "models/boss/waraxe.mdl");
   axe.skin = 0.00000;
   setsize (axe, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   axe.enemy = new_target;
   axe.goalentity = new_target;
   axe.owner = self;
   makevectors (self.angles);
   setorigin (axe, (((self.origin + (offset_x * v_right)) + (offset_y * v_forward)) + (offset_z * v_up)));
   axe.count = 200.00000;
   axe.waraxe_offset = 0.00000;
   axe.waraxe_horizontal = horizontal;
   vec = ((offset_x * v_right) + (offset_y * v_forward));
   vec = normalize (vec);
   axe.velocity = (vec * (390.00000 + (random () * 50.00000)));
   axe.angles = vectoangles (axe.velocity);
   if ( axe.waraxe_horizontal ) {

      axe.angles_y += 40.00000;
      if ( (random () < 0.50000) ) {

         axe.cnt = (65.00000 + (random () * 15.00000));
      } else {

         axe.cnt = (100.00000 + (random () * 15.00000));

      }
      axe.angles_x += axe.cnt;
      axe.avelocity = '0.00000 0.00000 800.00000';
      axe.waraxe_track_inc = (0.70000 + (random () / 5.00000));
      axe.waraxe_track_limit = (13.00000 + (random () * 3.00000));
      axe.waraxe_max_speed = (900.00000 + (random () * 400.00000));
      axe.waraxe_max_height = (7.00000 + random ());
      axe.skin = 0.00000;
   } else {

      axe.angles_x = ((random () * 20.00000) - 10.00000);
      if ( (random () < 0.50000) ) {

         axe.cnt = (70.00000 + (random () * 10.00000));
      } else {

         axe.cnt = (100.00000 + (random () * 10.00000));

      }
      axe.angles_y += axe.cnt;
      axe.angles_z = -90.00000;
      axe.avelocity = '0.00000 0.00000 800.00000';
      axe.waraxe_track_inc = (0.50000 + (random () / 2.00000));
      axe.waraxe_track_limit = (17.00000 + (random () * 6.00000));
      axe.waraxe_max_speed = (1200.00000 + (random () * 800.00000));
      axe.waraxe_max_height = (7.00000 + (random () * 3.00000));
      axe.skin = 1.00000;

   }
   axe.drawflags = MLS_ABSLIGHT;
   axe.abslight = 0.50000;
   axe.think = waraxe_move;
   axe.touch = waraxe_touch;
   axe.nextthink = (time + HX_FRAME_TIME);
   axe.lifetime = (time + 5.00000);
};


void  (entity horse)create_warrider =  {
local entity rider;
   rider = spawn ();
   rider.solid = SOLID_NOT;
   rider.movetype = MOVETYPE_NONE;
   rider.origin = horse.origin;
   rider.angles = self.angles;
   setmodel (rider, "models/boss/warrider.mdl");
   rider.skin = 0.00000;
   horse.movechain = rider;
   rider.flags = (rider.flags | FL_MOVECHAIN_ANGLE);
};

void  ()warhorse_move;

void  ()warhorse_rear =  {
local float retval = 0.00000;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.monster_stage == WH_STAGE_BEGIN_REAR) ) {

      self.speed = (self.speed / 1.20000);
      riderpath_move (self.speed);
      retval = AdvanceFrame (103.00000, 118.00000);
      if ( (retval == AF_END) ) {

         self.monster_stage = WH_STAGE_MIDDLE_REAR;

      }
      self.movechain.frame = ((WarRiderFrames->3.00000) + (self.frame - 103.00000));
   } else {

      if ( (self.monster_stage == WH_STAGE_MIDDLE_REAR) ) {

         retval = AdvanceFrame (63.00000, 102.00000);
         if ( (retval == AF_END) ) {

            if ( ((self.enemy != world) && (random () < 0.70000)) ) {

               self.monster_stage = WH_STAGE_STANDING;
            } else {

               self.monster_stage = WH_STAGE_END_REAR;

            }

         }
         self.movechain.frame = ((WarRiderFrames->4.00000) + (self.frame - 63.00000));
         if ( (self.movechain.frame == (WarRiderFrames->9.00000)) ) {

            if ( !self.enemy ) {

               LocateTarget ();

            }
            if ( self.enemy ) {

               waraxe (self.enemy, '1.00000 2.00000 70.00000', 0.00000);

            }

         }
      } else {

         if ( (self.monster_stage == WH_STAGE_STANDING) ) {

            retval = AdvanceFrame (0.00000, 14.00000);
            if ( (retval == AF_END) ) {

               if ( (random () < 0.50000) ) {

                  self.monster_stage = WH_STAGE_END_REAR;

               }

            }
            self.movechain.frame = ((WarRiderFrames->10.00000) + (self.frame - 0.00000));
            if ( !self.enemy ) {

               LocateTarget ();

            }
            if ( self.enemy ) {

               if ( (self.movechain.frame == (WarRiderFrames->11.00000)) ) {

                  waraxe (self.enemy, '3.00000 3.00000 82.00000', 1.00000);
               } else {

                  if ( (self.movechain.frame == (WarRiderFrames->12.00000)) ) {

                     waraxe (self.enemy, '-3.00000 3.00000 70.00000', 1.00000);
                  } else {

                     if ( (self.movechain.frame == (WarRiderFrames->13.00000)) ) {

                        waraxe (self.enemy, '-1.00000 3.00000 75.00000', 1.00000);

                     }

                  }

               }

            }
         } else {

            if ( (self.monster_stage == WH_STAGE_END_REAR) ) {

               retval = AdvanceFrame (119.00000, 130.00000);
               if ( (retval == AF_END) ) {

                  self.think = warhorse_move;
                  self.monster_stage = WH_STAGE_NORMAL;
                  self.speed = (war_speed->self.rider_gallop_mode);
               } else {

                  self.speed = (self.speed * 1.30000);

               }
               riderpath_move (self.speed);
               self.movechain.frame = ((WarRiderFrames->5.00000) + (self.frame - 119.00000));

            }

         }

      }

   }
};


void  ()warhorse_move =  {
local float retval = 0.00000;
   self.think = warhorse_move;
   self.nextthink = (time + HX_FRAME_TIME);
   retval = AdvanceFrame ((war_start->self.rider_gallop_mode), (war_end->self.rider_gallop_mode));
   if ( !self.path_current ) {

      riderpath_init ();

   }
   riderpath_move (self.speed);
   if ( (retval == AF_BEGINNING) ) {

      retval = fabs (self.rider_y_change);
      if ( (retval >= 15.00000) ) {

         if ( (self.rider_gallop_mode >= 1.00000) ) {

            self.rider_gallop_mode = 2.00000;
         } else {

            self.rider_gallop_mode = 1.00000;

         }
      } else {

         if ( (self.rider_gallop_mode <= 1.00000) ) {

            self.rider_gallop_mode = 0.00000;
         } else {

            self.rider_gallop_mode = 1.00000;

         }

      }
      self.frame = (war_start->self.rider_gallop_mode);
      if ( ((retval < 1.00000) && (random () < 0.10000)) ) {

         self.think = warhorse_rear;
         self.monster_stage = WH_STAGE_BEGIN_REAR;
      } else {

         if ( (self.rider_gallop_mode == 0.00000) ) {

            if ( !self.enemy ) {

               LocateTarget ();

            }
            if ( self.enemy ) {

               self.monster_stage = WH_STAGE_ATTACK;

            }
         } else {

            if ( (self.rider_gallop_mode == 1.00000) ) {

               if ( !self.enemy ) {

                  LocateTarget ();

               }
               if ( self.enemy ) {

                  self.monster_stage = WH_STAGE_ATTACK;

               }
            } else {

               if ( (self.rider_gallop_mode == 2.00000) ) {

                  if ( !self.enemy ) {

                     LocateTarget ();

                  }
                  if ( self.enemy ) {

                     self.monster_stage = WH_STAGE_ATTACK;

                  }

               }

            }

         }

      }

   }
   if ( (self.monster_stage == WH_STAGE_ATTACK) ) {

      if ( (self.rider_gallop_mode == 0.00000) ) {

         self.movechain.frame = ((WarRiderFrames->6.00000) + (self.frame - (war_start->self.rider_gallop_mode)));
         if ( (self.movechain.frame == (WarRiderFrames->7.00000)) ) {

            waraxe (self.enemy, '3.00000 3.00000 82.00000', 1.00000);
         } else {

            if ( (self.movechain.frame == (WarRiderFrames->8.00000)) ) {

               waraxe (self.enemy, '-3.00000 3.00000 70.00000', 1.00000);

            }

         }
      } else {

         if ( (self.rider_gallop_mode == 1.00000) ) {

            self.movechain.frame = ((WarRiderFrames->14.00000) + (self.frame - (war_start->self.rider_gallop_mode)));
            if ( (self.movechain.frame == (WarRiderFrames->15.00000)) ) {

               waraxe (self.enemy, '3.00000 3.00000 82.00000', 1.00000);
            } else {

               if ( (self.movechain.frame == (WarRiderFrames->16.00000)) ) {

                  waraxe (self.enemy, '-3.00000 3.00000 70.00000', 1.00000);
               } else {

                  if ( (self.movechain.frame == (WarRiderFrames->17.00000)) ) {

                     waraxe (self.enemy, '0.00000 3.00000 70.00000', 1.00000);

                  }

               }

            }
         } else {

            if ( (self.rider_gallop_mode == 2.00000) ) {

               self.movechain.frame = ((WarRiderFrames->18.00000) + (self.frame - (war_start->self.rider_gallop_mode)));
               if ( (self.movechain.frame == (WarRiderFrames->19.00000)) ) {

                  waraxe (self.enemy, '3.00000 3.00000 82.00000', 1.00000);
               } else {

                  if ( (self.movechain.frame == (WarRiderFrames->20.00000)) ) {

                     waraxe (self.enemy, '2.00000 3.00000 78.00000', 1.00000);
                  } else {

                     if ( (self.movechain.frame == (WarRiderFrames->21.00000)) ) {

                        waraxe (self.enemy, '0.00000 3.00000 74.00000', 1.00000);
                     } else {

                        if ( (self.movechain.frame == (WarRiderFrames->22.00000)) ) {

                           waraxe (self.enemy, '-3.00000 3.00000 70.00000', 1.00000);

                        }

                     }

                  }

               }

            }

         }

      }
   } else {

      self.movechain.frame = ((WarRiderFrames->self.rider_gallop_mode) + (self.frame - (war_start->self.rider_gallop_mode)));

   }
   if ( (retval == AF_END) ) {

      self.monster_stage = WH_STAGE_NORMAL;

   }
   if ( (fabs (((war_speed->self.rider_gallop_mode) - self.speed)) < 0.20000) ) {

      self.speed = (war_speed->self.rider_gallop_mode);
   } else {

      if ( ((war_speed->self.rider_gallop_mode) > self.speed) ) {

         self.speed += 0.20000;
      } else {

         self.speed -= 0.20000;

      }

   }
};


void  ()rider_war =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/boss/warhorse.mdl");
   precache_model2 ("models/boss/warrider.mdl");
   precache_model2 ("models/boss/waraxe.mdl");
   precache_model2 ("models/boss/shaft.mdl");
   precache_model2 ("models/boss/circle.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.yaw_speed = 2.00000;
   setmodel (self, "models/boss/warhorse.mdl");
   self.skin = 0.00000;
   setsize (self, '-55.00000 -55.00000 0.00000', '55.00000 55.00000 100.00000');
   self.health = 1.00000;
   self.takedamage = DAMAGE_YES;
   self.rider_gallop_mode = 2.00000;
   self.speed = (war_speed->self.rider_gallop_mode);
   self.rider_path_distance = 200.00000;
   self.monster_stage = WH_STAGE_NORMAL;
   self.mass = 30000.00000;
   create_warrider (self);
   self.th_die = rider_die;
   self.think = warhorse_move;
   self.nextthink = (time + 0.20000);
};


void  ()rick_test2 =  {
   self.nextthink = (time + 0.50000);
};


void  ()rick_test =  {
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.velocity = '10.00000 10.00000 10.00000';
   self.avelocity = '10.00000 10.00000 10.00000';
   self.think = rick_test2;
   self.nextthink = (time + 0.50000);
};


void  ()rider_quake_touch =  {
   if ( (other.flags & FL_ONGROUND) ) {

      other.flags -= FL_ONGROUND;

   }
   other.adjust_velocity_z = (80.00000 + (random () * 150.00000));
   other.punchangle_x = ((random () * 8.00000) - 4.00000);
   other.punchangle_y = ((random () * 8.00000) - 4.00000);
   other.punchangle_z = ((random () * 8.00000) - 4.00000);
};


void  ()rider_quake_think =  {
   if ( (self.wrq_count <= 0.00000) ) {

      self.touch = SUB_Null;
      self.think = SUB_Null;
      return ;

   }
   self.nextthink = (time + HX_FRAME_TIME);
   self.ltime = time;
   self.velocity_z = ((random () * 60.00000) - 30.00000);
   if ( ((self.origin_z - self.oldorigin_z) > 5.00000) ) {

      self.velocity_z = (0.00000 - ((random () * 5.00000) + 10.00000));
   } else {

      if ( ((self.origin_z - self.oldorigin_z) < -5.00000) ) {

         self.velocity_z = ((random () * 5.00000) + 10.00000);

      }

   }
};


void  ()rider_quake =  {
   self.solid = SOLID_BSP;
   self.movetype = MOVETYPE_PUSH;
   setorigin (self, self.origin);
   setmodel (self, self.model);
   self.oldorigin = self.origin;
   self.wrq_count = 0.00000;
};


void  ()rider_quake_center_think =  {
local entity item;
   endeffect (MSG_ALL, self.wrq_effect_id);
   item = findradius (self.origin, self.wrq_radius);
   while ( item ) {

      if ( (item.classname == "rider_quake") ) {

         item.wrq_count -= 1.00000;

      }
      item = item.chain;

   }
   self.think = SUB_Null;
};


void  ()rider_quake_center_use =  {
local entity item;
local vector real_origin = '0.00000 0.00000 0.00000';
   if ( (self.think != SUB_Null) ) {

      return ;

   }
   self.think = rider_quake_center_think;
   self.nextthink = ((time + 7.00000) + (15.00000 * random ()));
   self.wrq_radius = 500.00000;
   real_origin = self.origin;
   self.wrq_effect_id = starteffect (CE_QUAKE, real_origin, (self.wrq_radius / 3.00000));
   item = findradius (self.origin, self.wrq_radius);
   while ( item ) {

      if ( (item.classname == "rider_quake") ) {

         item.think = rider_quake_think;
         item.nextthink = (time + HX_FRAME_TIME);
         item.ltime = time;
         item.touch = rider_quake_touch;
         item.wrq_count += 1.00000;

      }
      item = item.chain;

   }
};


void  ()rider_quake_center =  {
   setorigin (self, self.origin);
   setmodel (self, "models/null.spr");
   self.use = rider_quake_center_use;
   self.think = SUB_Null;
};

