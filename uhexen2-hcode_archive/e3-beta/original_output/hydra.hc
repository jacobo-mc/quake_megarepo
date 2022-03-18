float HYDRA_STAGE_WAIT   =  0.00000;
float HYDRA_STAGE_SWIM   =  1.00000;
float HYDRA_STAGE_FLOAT   =  2.00000;
float HYDRA_STAGE_STRAIGHT   =  3.00000;
float HYDRA_STAGE_REVERSE   =  4.00000;
float HYDRA_STAGE_ATTACK   =  10.00000;

void  ()hydra_init =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   self.nextthink = ((time + (random () / 2.00000)) + 0.10000);
   self.count = 0.00000;
   self.monster_stage = HYDRA_STAGE_SWIM;
   self.hydra_FloatTo = 0.00000;
   self.monster_duration = 0.00000;
   self.goalentity = self.enemy;
   self.monster_awake = TRUE;
};


void  ()hydra_wait =  {
   if ( LocateTarget () ) {

      hydra_init ();

   }
};

void  ()hydra_BigLeft;
void  ()hydra_BigRight;
void  ()hydra_ShortLeft;
void  ()hydra_ShortRight;
void  ()hydra_OpenFrames;
void  ()hydra_TentFrames;
void  ()hydra_SpitFrames;

float  (float Length)hydra_turn =  {
local float retval = 0.00000;
   retval = ChangeYaw ();
   if ( (((retval < -10.00000) || (retval > 10.00000)) && (Length > 100.00000)) ) {

      self.count = self.angles_y;
      if ( (retval > 45.00000) ) {

         self.th_save = self.think;
         hydra_BigLeft ();
      } else {

         if ( (retval > 0.00000) ) {

            self.th_save = self.think;
            hydra_ShortLeft ();
         } else {

            if ( (retval < -45.00000) ) {

               self.th_save = self.think;
               hydra_BigRight ();
            } else {

               self.th_save = self.think;
               hydra_ShortRight ();

            }

         }

      }
      return ( 1.00000 );

   }
   return ( 0.00000 );
};


void  (float thrust)hydra_swim =  {
local float retval = 0.00000;
local float dist = 0.00000;
local float Length = 0.00000;
local float temp = 0.00000;
   Length = vhlen ((self.origin - self.enemy.origin));
   dist = (4.00000 + (thrust * 6.00000));
   if ( (Length > 200.00000) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
      if ( hydra_turn (Length) ) {

         return ;

      }

   }
   retval = walkmove (self.angles_y, dist, FALSE);
   if ( (retval == 0.00000) ) {

      self.monster_stage = HYDRA_STAGE_REVERSE;
      self.monster_duration = (40.00000 + (random () * 30.00000));
      return ;

   }
   if ( (self.hydra_FloatTo == 0.00000) ) {

      dist = (self.enemy.origin_z - self.origin_z);
      if ( (dist < -50.00000) ) {

         self.hydra_FloatTo = (dist - (random () * 80.00000));
      } else {

         if ( (dist > 50.00000) ) {

            self.hydra_FloatTo = (dist + (random () * 80.00000));

         }

      }

   }
   if ( (self.hydra_FloatTo < -10.00000) ) {

      temp = (-0.50000 - random ());
      movestep (0.00000, 0.00000, temp, FALSE);
      self.hydra_FloatTo -= temp;
   } else {

      if ( (self.hydra_FloatTo > 10.00000) ) {

         temp = (0.50000 + random ());
         movestep (0.00000, 0.00000, temp, FALSE);
         self.hydra_FloatTo -= temp;
      } else {

         self.hydra_FloatTo = 0.00000;

      }

   }
   if ( (Length > 300.00000) ) {

      self.monster_stage = HYDRA_STAGE_FLOAT;
   } else {

      if ( (self.frame == 184.00000) ) {

         self.th_save = self.think;
         enemy_range = range (self.enemy);
         retval = CheckMonsterAttack (MA_MELEE, 3.00000);

      }

   }
};


void  (float thrust)hydra_straight =  {
local float retval = 0.00000;
local float dist = 0.00000;
   self.monster_duration = (self.monster_duration - 1.00000);
   dist = (4.00000 + (thrust * 6.00000));
   retval = walkmove (self.angles_y, dist, FALSE);
   if ( ((retval == 0.00000) || (self.monster_duration <= 0.00000)) ) {

      self.monster_stage = HYDRA_STAGE_FLOAT;
      return ;

   }
   if ( (self.frame == 184.00000) ) {

      self.th_save = self.think;
      enemy_range = range (self.enemy);
      retval = CheckMonsterAttack (MA_MELEE, 3.00000);

   }
};


void  ()hydra_float =  {
local float Length = 0.00000;
local float retval = 0.00000;
   Length = vhlen ((self.origin - self.enemy.origin));
   if ( (Length < 300.00000) ) {

      self.monster_stage = HYDRA_STAGE_SWIM;
      self.hydra_FloatTo = 0.00000;
      return ;

   }
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   if ( (self.frame == 184.00000) ) {

      self.th_save = self.think;
      enemy_range = range (self.enemy);
      retval = CheckMonsterAttack (MA_MISSILE, 3.00000);

   }
};


void  ()hydra_reverse =  {
local float Length = 0.00000;
local float retval = 0.00000;
local float dist = 0.00000;
   self.monster_duration = (self.monster_duration - 1.00000);
   dist = 4.00000;
   retval = walkmove ((self.angles_y + 180.00000), dist, FALSE);
   if ( ((retval == 0.00000) && (self.monster_duration > 0.00000)) ) {

      self.ideal_yaw = FindDir ();
      self.monster_duration = (40.00000 + (random () * 30.00000));
      self.monster_stage = HYDRA_STAGE_STRAIGHT;
      hydra_turn (200.00000);
      return ;

   }
   if ( (self.monster_duration <= 0.00000) ) {

      self.monster_stage = HYDRA_STAGE_FLOAT;

   }
};


void  (float thrust)hydra_move =  {
   movestep (0.00000, 0.00000, thrust, FALSE);
   if ( (self.monster_stage == HYDRA_STAGE_WAIT) ) {

      hydra_wait ();
      return ;

   }
   if ( (self.monster_stage == HYDRA_STAGE_SWIM) ) {

      hydra_swim (thrust);
      return ;
   } else {

      if ( (self.monster_stage == HYDRA_STAGE_FLOAT) ) {

         hydra_float ();
         return ;
      } else {

         if ( (self.monster_stage == HYDRA_STAGE_REVERSE) ) {

            hydra_reverse ();
            return ;
         } else {

            if ( (self.monster_stage == HYDRA_STAGE_STRAIGHT) ) {

               hydra_straight ();
               return ;

            }

         }

      }

   }
};


void  ()hydra_attack =  {
   if ( self.monster_check ) {

      hydra_SpitFrames ();
   } else {

      hydra_TentFrames ();

   }
};


void  ()hydra_fire =  {
   sound (self, CHAN_WEAPON, "hydra/spit.wav", 1.00000, ATTN_NORM);
   do_spit ('0.00000 0.00000 0.00000');
};


void  (float TryHit)hydra_tent =  {
local float damg = 0.00000;
   self.angles_y = vectoyaw ((self.enemy.origin - self.origin));
   if ( TryHit ) {

      enemy_range = range (self.enemy);
      sound (self, CHAN_WEAPON, "hydra/tent.wav", 1.00000, ATTN_NORM);
      if ( (enemy_range == RANGE_MELEE) ) {

         if ( !CanDamage (self.enemy, self) ) {

            return ;

         }
         damg = ((random () * 5.00000) + 2.00000);
         T_Damage (self.enemy, self, self, damg);

      }

   }
};


void  (float TurnAmount)hydra_turn_right =  {
local float diff = 0.00000;
local float dist = 0.00000;
   if ( (self.monster_stage != HYDRA_STAGE_STRAIGHT) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));

   }
   diff = (self.ideal_yaw - self.count);
   if ( (diff >= 180.00000) ) {

      diff = (diff - 360.00000);
   } else {

      if ( (diff <= -180.00000) ) {

         diff = (diff + 360.00000);

      }

   }
   if ( (diff > 0.00000) ) {

      diff = (diff - 360.00000);

   }
   self.angles_y = (self.count + (diff * TurnAmount));
   dist = (4.00000 * TurnAmount);
   walkmove (self.angles_y, dist, FALSE);
};


void  (float TurnAmount)hydra_turn_left =  {
local float diff = 0.00000;
local float dist = 0.00000;
   if ( (self.monster_stage != HYDRA_STAGE_STRAIGHT) ) {

      self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));

   }
   diff = (self.ideal_yaw - self.count);
   if ( (diff >= 180.00000) ) {

      diff = (diff - 360.00000);
   } else {

      if ( (diff <= -180.00000) ) {

         diff = (diff + 360.00000);

      }

   }
   if ( (diff < 0.00000) ) {

      diff = (diff + 360.00000);

   }
   self.angles_y = (self.count + (diff * TurnAmount));
   dist = (4.00000 * TurnAmount);
   walkmove (self.angles_y, dist, FALSE);
};


void  ()hydra_open =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
};


void  ()hydra_bob =  {
local float rnd1 = 0.00000;
local float rnd2 = 0.00000;
local float rnd3 = 0.00000;
local vector vtmp1 = '0.00000 0.00000 0.00000';
local vector modi = '0.00000 0.00000 0.00000';
   rnd1 = (self.velocity_x + (-10.00000 + (random () * 20.00000)));
   rnd2 = (self.velocity_y + (-10.00000 + (random () * 20.00000)));
   rnd3 = (self.velocity_z + (random () * 10.00000));
   if ( (rnd1 > 10.00000) ) {

      rnd1 = 10.00000;

   }
   if ( (rnd1 < -10.00000) ) {

      rnd1 = -10.00000;

   }
   if ( (rnd2 > 10.00000) ) {

      rnd2 = 10.00000;

   }
   if ( (rnd2 < -10.00000) ) {

      rnd2 = -10.00000;

   }
   if ( (rnd3 > 55.00000) ) {

      rnd3 = 50.00000;

   }
   self.velocity_x = rnd1;
   self.velocity_y = rnd2;
   self.velocity_z = rnd3;
};

float hydra_BigTurn [30]   = { 0.00500,
    0.01500,    0.03000,    0.05000,    0.07500,
    0.10500,    0.14000,    0.18000,    0.22500,
    0.27500,    0.32500,    0.37500,    0.42500,
    0.47500,    0.52500,    0.57500,    0.62500,
    0.67500,    0.72500,    0.77500,    0.82000,
    0.86000,    0.89500,    0.92500,    0.95000,
    0.97000,    0.98500,    0.99500,    1.00000,
    1.00000};
float hydra_ShortTurn [19]   = { 0.01000,
    0.03000,    0.06000,    0.10000,    0.15000,
    0.21000,    0.28000,    0.36000,    0.45000,
    0.55000,    0.64000,    0.72000,    0.79000,
    0.85000,    0.90000,    0.94000,    0.97000,
    0.99000,    1.00000};
float hydra_Swim [20]   = { -0.20000,
    -0.10000,    0.00000,    0.10000,    0.20000,
    0.30000,    0.40000,    0.50000,    0.40000,
    0.30000,    0.20000,    0.10000,    0.00000,
    -0.10000,    -0.20000,    -0.30000,    -0.40000,
    -0.50000,    -0.40000,    -0.30000};
float hydra_TentAttacks [24]   = { 0.00000,
    0.00000,    0.00000,    0.00000,    1.00000,
    0.00000,    3.00000,    0.00000,    4.00000,
    0.00000,    0.00000,    5.00000,    0.00000,
    0.00000,    0.00000,    2.00000,    0.00000,
    0.00000,    0.00000,    4.00000,    3.00000,
    1.00000,    0.00000,    0.00000};

void  ()hydra_AttackDieFrames =  {
   self.think = hydra_AttackDieFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.frame != 35.00000) ) {

      AdvanceFrame (0.00000, 35.00000);

   }
   if ( (self.frame == 34.00000) ) {

      self.solid = SOLID_NOT;
      MakeSolidCorpse ("remove");

   }
   if ( (self.frame >= 12.00000) ) {

      hydra_bob ();

   }
   if ( (self.health < -40.00000) ) {

      chunk_death ();

   }
};


void  ()hydra_AttackPainFrames =  {
   self.think = hydra_AttackPainFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (36.00000, 45.00000) == AF_END) ) {

      dprint ("Done");

   }
};


void  ()hydra_SwimDieFrames =  {
   self.think = hydra_SwimDieFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (self.frame != 149.00000) ) {

      AdvanceFrame (114.00000, 149.00000);

   }
   if ( (self.frame == 148.00000) ) {

      self.solid = SOLID_NOT;
      MakeSolidCorpse ("remove");

   }
   if ( (self.frame >= 121.00000) ) {

      hydra_bob ();

   }
   if ( (self.health < -40.00000) ) {

      chunk_death ();

   }
};


void  ()hydra_SwimPainFrames =  {
   self.think = hydra_SwimPainFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (150.00000, 159.00000) == AF_END) ) {

      dprint ("Done");

   }
};


void  ()hydra_OpenFrames =  {
   self.think = hydra_OpenFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   hydra_open ();
   if ( (AdvanceFrame (76.00000, 83.00000) == AF_END) ) {

      hydra_attack ();

   }
};


void  ()hydra_CloseFrames =  {
   self.think = hydra_CloseFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (RewindFrame (83.00000, 76.00000) == AF_END) ) {

      self.monster_stage = (self.monster_stage - HYDRA_STAGE_ATTACK);
      self.think = self.th_save;

   }
};


void  ()hydra_SpitFrames =  {
local vector vecA = '0.00000 0.00000 0.00000';
local vector vecB = '0.00000 0.00000 0.00000';
   self.think = hydra_SpitFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   self.angles_y = vectoyaw ((self.enemy.origin - self.origin));
   if ( (AdvanceFrame (160.00000, 171.00000) == AF_END) ) {

      self.think = hydra_CloseFrames;
   } else {

      if ( (self.frame == 166.00000) ) {

         vecA = ((self.enemy.origin - self.origin) + self.enemy.proj_ofs);
         vecA = vectoangles (vecA);
         makevectors (vecA);
         v_forward_z = (0.00000 - v_forward_z);
         vecA = (((v_forward * 300.00000) - (v_up * 20.00000)) - (v_right * 20.00000));
         vecB = (((v_forward * 400.00000) + (v_up * 20.00000)) + (v_right * 20.00000));
         particle2 ((self.origin + (v_forward * 20.00000)), vecA, vecB, 256.00000, 12.00000, 200.00000);
      } else {

         if ( (self.frame == 167.00000) ) {

            hydra_fire ();

         }

      }

   }
};


void  ()hydra_TentFrames =  {
   self.think = hydra_TentFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (192.00000, 215.00000) == AF_END) ) {

      self.think = hydra_CloseFrames;
   } else {

      hydra_tent ((hydra_TentAttacks->(self.frame - 192.00000)));

   }
};


void  ()hydra_SwimFrames =  {
   self.think = hydra_SwimFrames;
   self.nextthink = (time + HX_FRAME_TIME);
   AdvanceFrame (172.00000, 191.00000);
   if ( (self.frame == 172.00000) ) {

      sound (self, CHAN_WEAPON, "hydra/swim.wav", 1.00000, ATTN_NORM);

   }
   hydra_move ((hydra_Swim->(self.frame - 172.00000)));
};


void  ()hydra_BigLeft =  {
   self.think = hydra_BigLeft;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (46.00000, 75.00000) == AF_END) ) {

      self.think = self.th_save;

   }
   if ( (self.frame == 46.00000) ) {

      sound (self, CHAN_WEAPON, "hydra/turn-b.wav", 1.00000, ATTN_NORM);

   }
   hydra_turn_left ((hydra_BigTurn->(self.frame - 46.00000)));
};


void  ()hydra_ShortLeft =  {
   self.think = hydra_ShortLeft;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (46.00000, 75.00000) == AF_END) ) {

      self.think = self.th_save;

   }
   if ( (self.frame == 46.00000) ) {

      sound (self, CHAN_WEAPON, "hydra/turn-s.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.frame == 57.00000) ) {

      self.frame = 68.00000;

   }
   if ( (self.frame <= 56.00000) ) {

      hydra_turn_left ((hydra_ShortTurn->(self.frame - 46.00000)));
   } else {

      hydra_turn_left ((hydra_ShortTurn->((self.frame - 46.00000) - 11.00000)));

   }
};


void  ()hydra_BigRight =  {
   self.think = hydra_BigRight;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (84.00000, 113.00000) == AF_END) ) {

      self.think = self.th_save;

   }
   if ( (self.frame == 84.00000) ) {

      sound (self, CHAN_WEAPON, "hydra/turn-b.wav", 1.00000, ATTN_NORM);

   }
   hydra_turn_right ((hydra_BigTurn->(self.frame - 84.00000)));
};


void  ()hydra_ShortRight =  {
   self.think = hydra_ShortRight;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (84.00000, 113.00000) == AF_END) ) {

      self.think = self.th_save;

   }
   if ( (self.frame == 84.00000) ) {

      sound (self, CHAN_WEAPON, "hydra/turn-s.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.frame == 95.00000) ) {

      self.frame = 106.00000;

   }
   if ( (self.frame <= 94.00000) ) {

      hydra_turn_right ((hydra_ShortTurn->(self.frame - 84.00000)));
   } else {

      hydra_turn_right ((hydra_ShortTurn->((self.frame - 84.00000) - 11.00000)));

   }
};


void  ()misc_fountain =  {
   starteffect (CE_FOUNTAIN, self.origin, self.angles, self.movedir, self.color, self.cnt);
};


void  ()hydra_start_go =  {
   self.takedamage = DAMAGE_YES;
   self.flags2 += FL_ALIVE;
   self.ideal_yaw = (self.angles * '0.00000 1.00000 0.00000');
   if ( !self.yaw_speed ) {

      self.yaw_speed = 3.00000;

   }
   self.view_ofs = '0.00000 0.00000 0.00000';
   self.use = monster_use;
   self.flags = (self.flags | FL_SWIM);
   self.flags = (self.flags | FL_MONSTER);
   self.pausetime = 100000000.00000;
   self.th_stand ();
};


void  ()hydra_start =  {
   self.nextthink = (self.nextthink + (random () * 0.50000));
   self.think = hydra_start_go;
   total_monsters = (total_monsters + 1.00000);
};


void  ()do_hydra_spit =  {
   self.monster_check = 1.00000;
   self.monster_stage = (self.monster_stage + HYDRA_STAGE_ATTACK);
   sound (self, CHAN_WEAPON, "hydra/open.wav", 1.00000, ATTN_NORM);
   hydra_OpenFrames ();
};


void  ()do_hydra_tent =  {
   self.monster_check = 0.00000;
   self.monster_stage = (self.monster_stage + HYDRA_STAGE_ATTACK);
   sound (self, CHAN_WEAPON, "hydra/open.wav", 1.00000, ATTN_NORM);
   hydra_OpenFrames ();
};


void  ()do_hydra_die =  {
   self.flags = (self.flags | FL_SWIM);
   sound (self, CHAN_WEAPON, "hydra/die.wav", 1.00000, ATTN_NORM);
   if ( (self.monster_stage >= HYDRA_STAGE_ATTACK) ) {

      hydra_AttackDieFrames ();
   } else {

      hydra_SwimDieFrames ();

   }
};


void  (entity attacker,float damage)hydra_pain =  {
   sound (self, CHAN_WEAPON, "hydra/pain.wav", 1.00000, ATTN_NORM);
};


void  ()init_hydra =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   self.monster_stage = HYDRA_STAGE_WAIT;
   precache_model2 ("models/hydra.mdl");
   precache_model2 ("models/spit.mdl");
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_FLY;
   self.thingtype = THINGTYPE_FLESH;
   self.classname = "hydra";
   self.mass = 7.00000;
   setmodel (self, "models/hydra.mdl");
   self.skin = 0.00000;
   setsize (self, '-28.00000 -28.00000 -24.00000', '28.00000 28.00000 24.00000');
   self.hull = HULL_HYDRA;
   self.health = 100.00000;
   self.experience_value = 500.00000;
   self.th_stand = hydra_SwimFrames;
   self.th_walk = hydra_SwimFrames;
   self.th_run = hydra_SwimFrames;
   self.th_pain = hydra_pain;
   self.th_die = do_hydra_die;
   self.th_missile = do_hydra_spit;
   self.th_melee = do_hydra_tent;
   hydra_start ();
};


void  ()monster_hydra =  {
   init_hydra ();
   precache_sound2 ("hydra/pain.wav");
   precache_sound2 ("hydra/die.wav");
   precache_sound2 ("hydra/open.wav");
   precache_sound2 ("hydra/turn-s.wav");
   precache_sound2 ("hydra/turn-b.wav");
   precache_sound2 ("hydra/swim.wav");
   precache_sound2 ("hydra/tent.wav");
   precache_sound2 ("hydra/spit.wav");
};

