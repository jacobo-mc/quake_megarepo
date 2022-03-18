
void  ()rider_path =  {
};


void  ()riderpath_init =  {
local entity search;
local entity found;
   found = world;
   search = find (world, classname, "rider_path");
   while ( ((search != world) && (found == world)) ) {

      if ( (search.path_id == 1.00000) ) {

         found = search;
      } else {

         search = find (search, classname, "rider_path");

      }

   }
   self.path_current = found;
   if ( !found ) {

      dprint ("No starting point for rider\n");
      remove (self);

   }
};


void  ()riderpath_findnext =  {
local entity search;
local entity found;
local float next = 0.00000;
local float num_points = 0.00000;
local float position = 0.00000;
   num_points = 0.00000;
   if ( self.path_current.next_path_1 ) {

      num_points += 1.00000;

   }
   if ( self.path_current.next_path_2 ) {

      num_points += 1.00000;

   }
   if ( self.path_current.next_path_3 ) {

      num_points += 1.00000;

   }
   if ( self.path_current.next_path_4 ) {

      num_points += 1.00000;

   }
   if ( !num_points ) {

      dprintf ("rider path %s has no next points\n", self.path_id);
      remove (self);
      return ;

   }
   position = (random () * num_points);
   next = 0.00000;
   num_points = 0.00000;
   if ( self.path_current.next_path_1 ) {

      num_points += 1.00000;
      if ( ((position <= num_points) && !next) ) {

         next = self.path_current.next_path_1;

      }

   }
   if ( self.path_current.next_path_2 ) {

      num_points += 1.00000;
      if ( ((position <= num_points) && !next) ) {

         next = self.path_current.next_path_2;

      }

   }
   if ( self.path_current.next_path_3 ) {

      num_points += 1.00000;
      if ( ((position <= num_points) && !next) ) {

         next = self.path_current.next_path_3;

      }

   }
   if ( self.path_current.next_path_4 ) {

      num_points += 1.00000;
      if ( ((position <= num_points) && !next) ) {

         next = self.path_current.next_path_4;

      }

   }
   if ( !next ) {

      dprint ("Internal error for rider path\n");
      dprintf ("   Next is %s\n", next);
      dprintf ("   Num_points is %s\n", num_points);
      dprintf ("   position is %s\n", position);
      return ;

   }
   found = world;
   search = find (world, classname, "rider_path");
   while ( ((search != world) && (found == world)) ) {

      if ( (search.path_id == next) ) {

         found = search;
      } else {

         search = find (search, classname, "rider_path");

      }

   }
   self.path_current = found;
   if ( !found ) {

      dprintf ("Could not find rider path %s\n", next);
      remove (self);
      return ;

   }
};


void  (float move_speed)riderpath_move =  {
local float distance = 0.00000;
local float altitude = 0.00000;
local float temp = 0.00000;
local vector displace = '0.00000 0.00000 0.00000';
   self.ideal_yaw = vectoyaw ((self.path_current.origin - self.origin));
   self.rider_last_y_change = self.rider_y_change;
   self.rider_y_change = ChangeYaw ();
   if ( (self.movetype == MOVETYPE_FLY) ) {

      distance = vhlen ((self.origin - self.path_current.origin));
      altitude = (self.path_current.origin_z - self.origin_z);
      if ( (distance < 400.00000) ) {

         temp = ((distance - self.rider_path_distance) / (400.00000 - self.rider_path_distance));
         temp = (1.00000 - temp);
         temp = (temp / 6.00000);
         if ( (altitude > 30.00000) ) {

            self.angles_x = (temp * 200.00000);
            self.rider_move_adjustment -= 0.10000;
         } else {

            if ( (altitude < -30.00000) ) {

               self.angles_x = (0.00000 - (temp * 200.00000));
               self.rider_move_adjustment += 0.15000;

            }

         }
         if ( (altitude > 60.00000) ) {

            self.rider_move_adjustment -= 0.10000;
         } else {

            if ( (altitude < -60.00000) ) {

               self.rider_move_adjustment += 0.15000;

            }

         }
         altitude *= temp;
      } else {

         altitude = 0.00000;
         self.angles_x -= (self.angles_x / 10.00000);
         self.rider_move_adjustment -= (self.rider_move_adjustment / 15.00000);

      }
      self.origin_z += altitude;

   }
   move_speed += self.rider_move_adjustment;
   walkmove (self.angles_y, move_speed, TRUE);
   if ( trace_ent ) {

      displace = normalize ((trace_ent.origin - self.origin));
      if ( infront (trace_ent) ) {

         trace_ent.velocity += (displace * (1000.00000 + (random () * 600.00000)));
         T_Damage (trace_ent, self, self, (25.00000 + (random () * 10.00000)));
         trace_ent.punchangle_x = (-9.00000 - (random () * 8.00000));
         trace_ent.punchangle_y = ((20.00000 * random ()) - 10.00000);
         trace_ent.punchangle_z = ((20.00000 * random ()) - 10.00000);
      } else {

         trace_ent.velocity += (displace * (700.00000 + (random () * 200.00000)));
         T_Damage (trace_ent, self, self, (15.00000 + (random () * 5.00000)));
         trace_ent.punchangle_x = (-3.00000 - (random () * 5.00000));
         trace_ent.punchangle_y = ((10.00000 * random ()) - 5.00000);
         trace_ent.punchangle_z = ((10.00000 * random ()) - 5.00000);

      }

   }
   distance = vhlen ((self.origin - self.path_current.origin));
   if ( (distance < self.rider_path_distance) ) {

      riderpath_findnext ();

   }
};


void  ()rider_multi_wait =  {
   if ( self.max_health ) {

      self.health = self.max_health;
      self.takedamage = DAMAGE_NO_GRENADE;
      self.solid = SOLID_BBOX;

   }
};


void  ()rider_multi_trigger =  {
   if ( (self.nextthink > time) ) {

      return ;

   }
   if ( (self.enemy.classname != "rider_war") ) {

      return ;

   }
   if ( (random () <= self.rt_chance) ) {

      if ( self.noise ) {

         sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);

      }
      self.takedamage = DAMAGE_NO;
      activator = self.enemy;
      SUB_UseTargets ();

   }
   if ( (self.wait > 0.00000) ) {

      self.think = rider_multi_wait;
      self.nextthink = (time + self.wait);
   } else {

      self.touch = SUB_Null;
      self.nextthink = (time + 0.10000);
      self.think = SUB_Remove;

   }
};


void  ()rider_multi_use =  {
   if ( (time < self.attack_finished) ) {

      return ;

   }
   self.enemy = activator;
   rider_multi_trigger ();
};


void  ()rider_multi_touch =  {
   if ( (time < self.attack_finished) ) {

      return ;

   }
   if ( (self.movedir != '0.00000 0.00000 0.00000') ) {

      makevectors (other.angles);
      if ( ((v_forward * self.movedir) < 0.00000) ) {

         return ;

      }

   }
   self.enemy = other;
   rider_multi_trigger ();
};


void  ()rider_trigger_multiple =  {
   if ( !self.wait ) {

      self.wait = 0.20000;

   }
   self.use = rider_multi_use;
   InitTrigger ();
   if ( self.health ) {

      self.max_health = self.health;
      self.th_die = multi_killed;
      self.takedamage = DAMAGE_NO_GRENADE;
      self.solid = SOLID_BBOX;
      setorigin (self, self.origin);
   } else {

      self.touch = rider_multi_touch;

   }
};


void  ()rider_trigger_once =  {
   self.wait = -1.00000;
   rider_trigger_multiple ();
};


void  ()beam_move =  {
local float amount = 0.00000;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.scale < self.beam_max_scale) ) {

      self.scale += 0.60000;
   } else {

      self.scale = self.beam_max_scale;

   }
   if ( self.beam_direction ) {

      self.beam_angle_a += self.beam_speed;
      if ( (self.beam_angle_a >= 360.00000) ) {

         self.beam_angle_a -= 360.00000;

      }
   } else {

      self.beam_angle_a -= self.beam_speed;
      if ( (self.beam_angle_a < 0.00000) ) {

         self.beam_angle_a += 360.00000;

      }

   }
   self.angles_x = (cos (self.beam_angle_a) * self.beam_angle_b);
   self.angles_z = (sin (self.beam_angle_a) * self.beam_angle_b);
};


void  ()circle_think =  {
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.monster_stage == 0.00000) ) {

      self.scale += 0.02000;
      if ( (self.scale >= 2.50000) ) {

         self.monster_stage = 1.00000;
         self.scale = 2.50000;

      }
   } else {

      if ( (self.monster_stage == 1.00000) ) {

         self.scale -= (random () / 10.00000);
         if ( ((self.scale < 1.50000) || (random () < 0.10000)) ) {

            self.monster_stage = 2.00000;

         }
      } else {

         if ( (self.monster_stage == 2.00000) ) {

            self.scale += (random () / 10.00000);
            if ( (self.scale >= 2.50000) ) {

               self.monster_stage = 1.00000;
               self.scale = 2.50000;
            } else {

               if ( (random () < 0.10000) ) {

                  self.monster_stage = 1.00000;

               }

            }

         }

      }

   }
};


void  ()rider_die =  {
local entity beam;
local entity save;
local vector new_origin = '0.00000 0.00000 0.00000';
   if ( (self.think != rider_die) ) {

      self.think = rider_die;
      self.count = 0.00000;
      self.nextthink = (time + HX_FRAME_TIME);
      self.rider_death_speed = 0.20000;
      return ;

   }
   if ( (self.count == 0.00000) ) {

      self.drawflags = (self.drawflags | MLS_ABSLIGHT);
      self.abslight = 3.00000;

   }
   self.nextthink = (time + self.rider_death_speed);
   self.rider_death_speed += 0.10000;
   if ( (self.count >= 12.00000) ) {

      if ( (self.count == 3.00000) ) {

         beam = spawn ();
         new_origin = (self.origin + '0.00000 0.00000 50.00000');
         setmodel (beam, "models/boss/circle.mdl");
         setorigin (beam, new_origin);
         setsize (beam, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
         beam.owner = self;
         beam.movetype = MOVETYPE_FLYMISSILE;
         beam.solid = SOLID_NOT;
         beam.drawflags = SCALE_TYPE_UNIFORM;
         beam.scale = 0.10000;
         beam.skin = 0.00000;
         beam.avelocity = '0.00000 0.00000 300.00000';
         beam.think = circle_think;
         beam.nextthink = (time + HX_FRAME_TIME);
         self.count = 13.00000;

      }
      return ;
   } else {

      self.effects = EF_BRIGHTLIGHT;
      if ( (self.count == 3.00000) ) {

         beam = spawn ();
         new_origin = (self.origin + '0.00000 0.00000 50.00000');
         setmodel (beam, "models/boss/circle.mdl");
         setorigin (beam, new_origin);
         setsize (beam, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
         beam.owner = self;
         beam.movetype = MOVETYPE_FLYMISSILE;
         beam.solid = SOLID_NOT;
         beam.drawflags = SCALE_TYPE_UNIFORM;
         beam.scale = 0.10000;
         beam.skin = 0.00000;
         beam.avelocity = '0.00000 0.00000 300.00000';
         beam.think = circle_think;
         beam.nextthink = (time + HX_FRAME_TIME);
      } else {

         if ( (self.count == 7.00000) ) {

            starteffect (18.00000, (self.origin + '0.00000 0.00000 40.00000'));

         }

      }

   }
   self.count += 1.00000;
   beam = spawn ();
   makevectors (self.angles);
   new_origin = ((((v_up * (45.00000 + (random () * 5.00000))) + (v_right * ((6.00000 * random ()) - 3.00000))) + (v_forward * ((50.00000 * random ()) - 25.00000))) + self.origin);
   new_origin = (self.origin + '0.00000 0.00000 50.00000');
   setmodel (beam, "models/boss/shaft.mdl");
   setorigin (beam, new_origin);
   setsize (beam, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   beam.owner = self;
   beam.drawflags = (SCALE_ORIGIN_BOTTOM | SCALE_TYPE_XYONLY);
   beam.movetype = MOVETYPE_FLYMISSILE;
   beam.solid = SOLID_NOT;
   beam.think = beam_move;
   beam.angles = '0.00000 0.00000 0.00000';
   beam.angles_x = ((100.00000 * random ()) - 50.00000);
   beam.angles_z = ((100.00000 * random ()) - 50.00000);
   beam.beam_angle_a = (360.00000 * random ());
   beam.beam_angle_b = ((110.00000 * random ()) + 20.00000);
   beam.scale = 0.10000;
   beam.beam_max_scale = ((random () * 1.00000) + 0.50000);
   if ( (random () > 0.50000) ) {

      beam.beam_direction = 1.00000;

   }
   beam.beam_speed = (2.00000 + (random () * 2.50000));
   save = self;
   self = beam;
   beam_move ();
   self = save;
};

