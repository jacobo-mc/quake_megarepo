
void  ()MedusaSelectRattle =  {
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   sound (self, CHAN_BODY, "medusa/rattle.wav", 1.00000, ATTN_NORM);
   if ( (self.angle_ofs_y < -45.00000) ) {

      self.nextthink = time;
      self.think = medusa_rattle_right;
   } else {

      if ( (self.angle_ofs_y > 45.00000) ) {

         self.nextthink = time;
         self.think = medusa_rattle_left;
      } else {

         self.nextthink = time;
         self.think = medusa_rattle;

      }

   }
};


float  ()MedusaLookAtEnemy =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
local float dot = 0.00000;
local float accept = 0.00000;
   makevectors ((self.angles + self.angle_ofs));
   spot1 = (self.origin + self.view_ofs);
   spot2 = (self.enemy.origin + self.enemy.view_ofs);
   accept = 0.30000;
   vec = normalize ((spot2 - spot1));
   dot = (vec * v_forward);
   if ( (dot > accept) ) {

      return ( TRUE );

   }
   dot = (vec * v_right);
   if ( (dot > accept) ) {

      self.oldthink = self.th_run;
      self.nextthink = time;
      self.think = medusa_look_right;
      return ( TRUE );/* !!! */

   }
   dot = (vec * (v_right * -1.00000));
   if ( (dot > accept) ) {

      self.oldthink = self.th_run;
      self.nextthink = time;
      self.think = medusa_look_left;
      return ( TRUE );/* !!! */

   }
};


float  (entity targ,entity from)lineofsight =  {
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
   if ( (from.classname == "player") ) {

      makevectors (from.v_angle);
   } else {

      if ( (from.classname == "monster_medusa") ) {

         makevectors ((from.angles + from.angle_ofs));
      } else {

         makevectors (from.angles);

      }

   }
   org = (from.origin + from.view_ofs);
   dir = normalize (v_forward);
   traceline (org, (org + (dir * 1000.00000)), FALSE, from);
   if ( (trace_ent != targ) ) {

      return ( FALSE );
   } else {

      return ( TRUE );

   }
};


void  ()SnakeHit =  {
   if ( ((other == self.owner) || ((other.owner == self.owner) && (other.classname == "snakearrow"))) ) {

      return ;

   }
   if ( other.takedamage ) {

      other.bloodloss = (other.bloodloss + 1.00000);
      SpawnPuff (other.origin, '0.00000 0.00000 0.00000', self.dmg, other);
      T_Damage (other, self, self.owner, self.dmg);

   }
   remove (self);
};


void  ()FireSnakeArrow =  {
local entity missile;
   self.last_attack = time;
   missile = spawn ();
   missile.classname = "snakearrow";
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.abslight = 0.50000;
   missile.drawflags = MLS_ABSLIGHT;
   if ( (self.classname == "monster_medusa") ) {

      missile.owner = self;
      missile.dmg = 50.00000;
      missile.aflag = TRUE;
      missile.o_angle = normalize (((self.enemy.origin + self.enemy.view_ofs) - (self.origin + self.view_ofs)));
      self.attack_finished = (time + 0.50000);
   } else {

      missile.o_angle = self.o_angle;

   }
   missile.touch = SnakeHit;
   missile.velocity = (missile.o_angle * (500.00000 + self.mass));
   setmodel (missile, "models/snakearr.mdl");
   setsize (missile, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   if ( (self.classname == "snakearrow") ) {

      missile.owner = self.owner;
      self.dmg = (self.dmg * 0.50000);
      missile.dmg = (self.dmg * 0.50000);
      setorigin (missile, self.origin);
      if ( self.aflag ) {

         missile.aflag = FALSE;
         self.aflag = FALSE;
         missile.velocity = (missile.velocity + (v_right * 30.00000));
         self.velocity = (self.velocity - (v_right * 30.00000));
      } else {

         missile.aflag = TRUE;
         self.aflag = TRUE;
         missile.velocity = (missile.velocity + (v_up * 30.00000));
         self.velocity = (self.velocity - (v_up * 30.00000));

      }
      if ( (self.mass > 10.00000) ) {

         self.think = FireSnakeArrow;
         self.nextthink = (time + 0.15000);
      } else {

         self.think = SUB_Remove;
         self.nextthink = (time + 5.00000);

      }
   } else {

      setorigin (missile, ((self.origin + self.view_ofs) + (v_forward * 8.00000)));

   }
   missile.angles = vectoangles (missile.velocity);
   if ( (missile.dmg > 2.50000) ) {

      missile.think = FireSnakeArrow;
      missile.nextthink = (time + 0.15000);
   } else {

      missile.think = SUB_Remove;
      missile.nextthink = (time + 5.00000);

   }
};


void  ()MedusaHeadButt =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local float damg = 0.00000;
   self.attack_finished = (time + 1.00000);
   makevectors ((self.angles + self.angle_ofs));
   source = (self.origin + self.view_ofs);
   traceline (source, (source + (v_forward * 48.00000)), FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   org = (trace_endpos + (v_forward * 4.00000));
   sound (self, CHAN_WEAPON, "weapons/gauntht1.wav", 1.00000, ATTN_NORM);
   if ( trace_ent.takedamage ) {

      damg = (10.00000 + (random () * 8.00000));
      SpawnPuff (org, '0.00000 0.00000 0.00000', 20.00000, trace_ent);
      T_Damage (trace_ent, self, self, damg);
   } else {

      SpawnPuff (trace_endpos, '0.00000 0.00000 0.00000', 20.00000, self);
      self.nextthink = time;
      self.think = medusa_pain;

   }
};


void  ()medusa_attack_left =  {
   AdvanceFrame( 29.00000, 49.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 32.00000) ) {

         MedusaHeadButt ();

      }

   }
};


void  ()medusa_attack_right =  {
   AdvanceFrame( 50.00000, 70.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 53.00000) ) {

         MedusaHeadButt ();

      }

   }
};


void  ()medusa_attack =  {
   AdvanceFrame( 71.00000, 99.00000);
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 74.00000) ) {

         MedusaHeadButt ();

      }

   }
};


void  ()medusa_run =  {
   AdvanceFrame( 0.00000, 28.00000);
   if ( (self.model != "models/medusa2.mdl") ) {

      setmodel (self, "models/medusa2.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( !self.monster_awake ) {

      sound (self, CHAN_VOICE, "medusa/sight.wav", 1.00000, ATTN_NORM);
      self.nextthink = time;
      self.think = MedusaSelectRattle;
      self.monster_awake = TRUE;
      return ;

   }
   enemy_vis = visible (self.enemy);
   enemy_infront = infront (self.enemy);
   if ( (!enemy_vis || !enemy_infront) ) {

      enemy_range = range (self.enemy);
      self.oldthink = self.th_run;
      if ( ((random () < 0.20000) && (enemy_range <= RANGE_MID)) ) {

         self.nextthink = time;
         self.think = MedusaSelectRattle;
      } else {

         if ( (random () < 0.50000) ) {

            self.nextthink = time;
            self.think = medusa_look_left;
         } else {

            self.nextthink = time;
            self.think = medusa_look_right;

         }

      }
   } else {

      if ( (random () < 0.10000) ) {

         sound (self, CHAN_VOICE, "medusa/hiss.wav", 1.00000, ATTN_NORM);
         self.nextthink = time;
         self.think = MedusaSelectRattle;

      }

   }
   ai_run (10.00000);
   if ( (random () < 0.20000) ) {

      sound (self, CHAN_VOICE, "medusa/hiss.wav", 1.00000, ATTN_NORM);

   }
};


void  ()medusa_walk =  {
   AdvanceFrame( 0.00000, 28.00000);
   if ( (self.model != "models/medusa2.mdl") ) {

      setmodel (self, "models/medusa2.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   self.monster_awake = FALSE;
   ai_walk (5.00000);
   if ( cycle_wrapped ) {

      if ( (random () < 0.30000) ) {

         self.oldthink = self.th_walk;
         if ( (random () < 0.50000) ) {

            self.nextthink = time;
            self.think = medusa_look_left;
         } else {

            self.nextthink = time;
            self.think = medusa_look_right;

         }

      }

   }
   MedusaCheckAttack ();
   if ( (random () < 0.10000) ) {

      sound (self, CHAN_VOICE, "medusa/hiss.wav", 1.00000, ATTN_NORM);

   }
};


void  ()medusa_stand =  {
   if ( (self.model != "models/medusa2.mdl") ) {

      setmodel (self, "models/medusa2.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   self.monster_awake = FALSE;
   self.frame = 1.00000;
   self.think = medusa_stand;
   self.nextthink = (time + 0.10000);
   ai_stand ();
   MedusaCheckAttack ();
   if ( (random () < 0.20000) ) {

      self.oldthink = self.th_stand;
      if ( (random () < 0.50000) ) {

         self.nextthink = time;
         self.think = medusa_look_left;
      } else {

         self.nextthink = time;
         self.think = medusa_look_right;

      }

   }
   if ( (random () < 0.10000) ) {

      sound (self, CHAN_VOICE, "medusa/hiss.wav", 1.00000, ATTN_NORM);

   }
};


void  ()MedusaHeadButtInit =  {
   self.last_attack = time;
   sound (self, CHAN_VOICE, "medusa/hiss.wav", 1.00000, ATTN_NORM);
   if ( (self.model != "models/medusa2.mdl") ) {

      setmodel (self, "models/medusa2.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( (self.angle_ofs_y < -45.00000) ) {

      self.nextthink = time;
      self.think = medusa_attack_right;
   } else {

      if ( (self.angle_ofs_y > 45.00000) ) {

         self.nextthink = time;
         self.think = medusa_attack_left;
      } else {

         self.nextthink = time;
         self.think = medusa_attack;

      }

   }
};

void  ()MedusaGazeLoop;

void  (vector org,vector destiny,entity loser)MedusaGaze =  {
   if ( (loser.flags2 & FL_STONED) ) {

      self.think = self.th_run;
      self.nextthink = time;

   }
   self.last_attack = time;
   sound (self, CHAN_WEAPON, "medusa/attack1.wav", 1.00000, ATTN_NORM);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, org_x);
   WriteCoord (MSG_BROADCAST, org_y);
   WriteCoord (MSG_BROADCAST, org_z);
   WriteCoord (MSG_BROADCAST, destiny_x);
   WriteCoord (MSG_BROADCAST, destiny_y);
   WriteCoord (MSG_BROADCAST, destiny_z);
   if ( (loser.health <= 10.00000) ) {

      sound (loser, CHAN_BODY, "medusa/stoned.wav", 1.00000, ATTN_NORM);
      loser.skin = 110.00000;
      loser.th_run = SUB_Null;
      loser.th_pain = SUB_Null;
      loser.think = SUB_Null;
      loser.pausetime = (time + 1410065408.00000);
      loser.teleport_time = (time + 1410065408.00000);
      loser.attack_finished = (time + 1410065408.00000);
      loser.nextthink = -1.00000;
      loser.th_die = chunk_death;
      loser.thingtype = THINGTYPE_GREYSTONE;
      loser.health = 30.00000;
      loser.touch = obj_push;
      if ( (loser.flags & FL_FLY) ) {

         loser.flags -= FL_FLY;

      }
      if ( (loser.flags & FL_SWIM) ) {

         loser.flags -= FL_SWIM;

      }
      if ( (loser.classname != "player") ) {

         loser.movetype = MOVETYPE_STEP;
      } else {

         loser.o_angle = loser.v_angle;

      }
      loser.solid = SOLID_BBOX;
      if ( !(loser.flags2 & FL_STONED) ) {

         loser.flags2 += FL_STONED;

      }
   } else {

      T_Damage (loser, self, self, 3.00000);

   }
   if ( lineofsight (self, loser) ) {

      self.goalentity = loser;
      self.think = MedusaGazeLoop;
      self.nextthink = (time + 0.10000);
   } else {

      self.think = self.th_run;
      self.nextthink = time;

   }
};


void  ()MedusaGazeLoop =  {
   MedusaGaze ((self.origin + self.view_ofs), (self.goalentity.origin + self.goalentity.view_ofs), self.goalentity);
};


void  (vector org,vector destiny)MedusaSnakes =  {
   self.last_attack = time;
   self.attack_finished = (time + 2.00000);
   sound (self, CHAN_WEAPON, "medusa/attack2.wav", 1.00000, ATTN_NORM);
   if ( (self.model != "models/medusa2.mdl") ) {

      setmodel (self, "models/medusa2.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( (self.angle_ofs_y < -45.00000) ) {

      self.nextthink = time;
      self.think = medusa_attack_right;
   } else {

      if ( (self.angle_ofs_y > 45.00000) ) {

         self.nextthink = time;
         self.think = medusa_attack_left;
      } else {

         self.nextthink = time;
         self.think = medusa_attack;

      }

   }
   FireSnakeArrow ();
};


float  ()MedusaCheckAttack =  {
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local vector destiny = '0.00000 0.00000 0.00000';
local float r = 0.00000;
local float loscheck1 = 0.00000;
local float loscheck2 = 0.00000;
   org = (self.origin + self.view_ofs);
   if ( (self.enemy != world) ) {

      if ( (time < self.attack_finished) ) {

         return ( FALSE );

      }
      if ( !enemy_vis ) {

         return ( FALSE );

      }
      if ( !enemy_infront ) {

         if ( ((self.think != medusa_look_right) && (self.think != medusa_look_left)) ) {

            MedusaLookAtEnemy ();

         }
         return ( FALSE );

      }
      if ( (enemy_range == RANGE_FAR) ) {

         if ( (self.attack_state != AS_STRAIGHT) ) {

            self.attack_state = AS_STRAIGHT;

         }
         return ( FALSE );

      }
      dir = (self.enemy.origin + self.enemy.view_ofs);
      traceline (org, dir, FALSE, self);
      if ( (trace_ent != self.enemy) ) {

         if ( (self.attack_state != AS_SLIDING) ) {
            self.attack_state == AS_SLIDING;
         }
         return ( FALSE );

      }
      destiny = (self.enemy.origin + self.enemy.view_ofs);
      loscheck1 = lineofsight (self.enemy, self);
      loscheck2 = lineofsight (self, self.enemy);
      r = random ();
      if ( (loscheck1 && (loscheck2 || ((r < 0.30000) && infront_of_ent (self, self.enemy)))) ) {

         MedusaGaze (org, destiny, self.enemy);
         return ( TRUE );

      }
      if ( (enemy_range == RANGE_MELEE) ) {

         MedusaHeadButtInit ();
         return ( TRUE );
      } else {

         if ( (enemy_range == RANGE_NEAR) ) {

            r = 0.20000;
         } else {

            if ( (enemy_range == RANGE_MID) ) {

               r = 0.10000;

            }

         }

      }
      if ( (random () < r) ) {

         MedusaSnakes (org, destiny);
         return ( TRUE );

      }
      return ( FALSE );
   } else {

      lineofsight (self, self);
      if ( ((((trace_fraction == 1.00000) || !(trace_ent.flags2 & FL_ALIVE)) || (trace_ent.health <= 0.00000)) || (trace_ent.thingtype != THINGTYPE_FLESH)) ) {

         return ( FALSE );

      }
      r = range (trace_ent);
      if ( (r == RANGE_MELEE) ) {

         MedusaHeadButtInit ();
         return ( TRUE );
      } else {

         if ( (r != RANGE_FAR) ) {

            destiny = (trace_ent.origin + trace_ent.view_ofs);
            if ( lineofsight (self, trace_ent) ) {

               if ( (self.model != "models/medusa2.mdl") ) {

                  setmodel (self, "models/medusa2.mdl");
                  setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

               }
               MedusaGaze (org, destiny, trace_ent);
               return ( TRUE );
            } else {

               if ( (self.model != "models/medusa.mdl") ) {

                  setmodel (self, "models/medusa.mdl");
                  setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

               }
               MedusaSnakes (org, destiny);
               return ( TRUE );

            }

         }

      }

   }
};


void  ()monster_medusa_green =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   precache_model2 ("models/medusa.mdl");
   precache_model2 ("models/medusa2.mdl");
   precache_model2 ("models/snakearr.mdl");
   precache_sound ("medusa/rattle.wav");
   precache_sound ("medusa/hiss.wav");
   precache_sound ("medusa/sight.wav");
   precache_sound ("medusa/attack1.wav");
   precache_sound ("medusa/attack2.wav");
   precache_sound ("medusa/pain.wav");
   precache_sound ("medusa/death.wav");
   self.classname = "monster_medusa";
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;
   self.takedamage = DAMAGE_YES;
   self.thingtype = THINGTYPE_FLESH;
   self.mintel = 20.00000;
   self.mass = 15.00000;
   self.view_ofs = '0.00000 0.00000 53.00000';
   self.yaw_speed = 5.00000;
   self.health = 400.00000;
   self.th_stand = medusa_stand;
   self.th_run = medusa_run;
   self.th_walk = medusa_walk;
   self.th_die = medusa_die;
   self.th_pain = medusa_pain;
   self.th_missile = medusa_rattle;
   self.th_melee = medusa_attack;
   self.th_possum = medusa_playdead;
   self.th_possum_up = medusa_possum_up;
   setmodel (self, "models/medusa2.mdl");
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
   walkmonster_start ();
};


void  ()monster_medusa =  {
   monster_medusa_green ();
};


void  ()monster_medusa_red =  {
   self.skin = 1.00000;
   monster_medusa_green ();
};

