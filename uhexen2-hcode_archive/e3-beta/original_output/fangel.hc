void  ()fangel_blockframes;
float fangel_attack_speed   =  11.00000;
float fangel_move_speed   =  3.00000;

float  ()fangel_check_incoming =  {
local entity item;
local vector vec = '0.00000 0.00000 0.00000';
local vector realVec = '0.00000 0.00000 0.00000';
local float diff = 0.00000;
   item = findradius (self.origin, 500.00000);
   while ( item ) {

      if ( ((((item.classname == "rocket") || (item.classname == "grenade")) || (item.classname == "javprojectile")) || (item.classname == "missile")) ) {

         if ( (item.owner != self) ) {

            vec = ((self.origin - item.origin) + self.view_ofs);
            vec = normalize (vec);
            realVec = normalize (item.velocity);
            fabs ((vec_x - realVec_x));
            diff = ((fabs ((vec_y - realVec_y)) + fabs ((vec_y - realVec_y))) + fabs ((vec_z - realVec_z)));
            if ( (diff <= 0.40000) ) {

               self.th_save = self.think;
               self.fangel_Count = 0.00000;
               fangel_blockframes ();
               return ( TRUE );

            }

         }

      }
      item = item.chain;

   }
   return ( FALSE );
};


void  ()fangel_deflect =  {
local entity item;
local vector vec = '0.00000 0.00000 0.00000';
local vector realVec = '0.00000 0.00000 0.00000';
local float diff = 0.00000;
local float DidDeflect = 0.00000;
   DidDeflect = 0.00000;
   item = findradius (self.origin, 200.00000);
   while ( item ) {

      if ( ((((item.classname == "rocket") || (item.classname == "grenade")) || (item.classname == "javprojectile")) || (item.classname == "missile")) ) {

         if ( (item.owner != self) ) {

            vec = ((self.origin - item.origin) + self.view_ofs);
            vec = normalize (vec);
            realVec = normalize (item.velocity);
            fabs ((vec_x - realVec_x));
            diff = ((fabs ((vec_y - realVec_y)) + fabs ((vec_y - realVec_y))) + fabs ((vec_z - realVec_z)));
            if ( (diff <= 0.40000) ) {

               diff = vlen (item.velocity);
               diff = (diff / (1.50000 + random ()));
               vec = ('0.00000 0.00000 0.00000' - item.velocity);
               vec = normalize (vec);
               vec_x += (random () - 0.50000);
               vec_y += (random () - 0.50000);
               vec_z += (random () - 0.50000);
               vec = normalize (vec);
               vec = (vec * diff);
               item.velocity = vec;
               item.angles = vectoangles (item.velocity);
               item.owner = self;
               DidDeflect = 1.00000;

            }

         }

      }
      item = item.chain;

   }
   if ( DidDeflect ) {

      sound (self, CHAN_WEAPON, "fangel/deflect.wav", 1.00000, ATTN_NORM);

   }
};

float FANGEL_STAGE_WAIT   =  0.00000;
float FANGEL_STAGE_FLY   =  1.00000;
float FANGEL_STAGE_FLOAT   =  2.00000;

void  ()fangel_check_wing =  {
local float retval = 0.00000;
   enemy_infront = visible (self.enemy);
   if ( ((self.monster_stage == FANGEL_STAGE_FLY) && (random () < 0.50000)) ) {

      enemy_infront = 0.00000;

   }
   if ( enemy_infront ) {

      self.th_save = self.think;
      enemy_range = range (self.enemy);
      if ( (random () < 0.50000) ) {

         retval = CheckMonsterAttack (MA_FAR_MELEE, 1.00000);
      } else {

         retval = CheckMonsterAttack (MA_MISSILE, 1.00000);

      }
   } else {

      retval = MA_NOATTACK;

   }
   if ( (retval != MA_SUCCESSFUL) ) {

      fangel_check_incoming ();
   } else {

      self.yaw_speed = fangel_attack_speed;

   }
};


void  ()fangel_find_spot =  {
local float crj = 0.00000;
local float radius = 0.00000;
local vector vec = '0.00000 0.00000 0.00000';
   crj = 0.00000;
   while ( (crj < 50.00000) ) {

      radius = ((random () * 200.00000) + 200.00000);
      vec = '0.00000 0.00000 0.00000';
      vec_x = ((random () * 100.00000) - 50.00000);
      vec_y = ((random () * 100.00000) - 50.00000);
      vec = normalize (vec);
      vec = (self.enemy.origin + (vec * radius));
      vec_z = (((vec_z + (random () * 50.00000)) - 5.00000) + self.enemy.view_ofs_z);
      tracearea (self.origin, vec, self.mins, self.maxs, FALSE, self);
      if ( (trace_fraction == 1.00000) ) {

         self.monster_last_seen = vec;
         return ;

      }
      crj = (crj + 1.00000);

   }
   self.monster_stage = FANGEL_STAGE_FLOAT;
   self.monster_duration = ((random () * 20.00000) + 20.00000);
};


void  ()fangel_init =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   self.nextthink = ((time + (random () / 2.00000)) + 0.10000);
   self.count = 0.00000;
   self.monster_stage = FANGEL_STAGE_FLY;
   self.monster_duration = 0.00000;
   self.goalentity = self.enemy;
   self.monster_awake = TRUE;
   fangel_find_spot ();
};


void  ()fangel_wait =  {
   if ( LocateTarget () ) {

      fangel_init ();

   }
};


void  (float thrust)fangel_fly =  {
local float retval = 0.00000;
local float dist = 0.00000;
local float Length = 0.00000;
   Length = vhlen ((self.origin - self.monster_last_seen));
   self.ideal_yaw = vectoyaw ((self.monster_last_seen - self.origin));
   ChangeYaw ();
   dist = (2.00000 + (thrust * 0.50000));
   if ( (Length < 20.00000) ) {

      if ( (random () < 0.10000) ) {

         fangel_find_spot ();
      } else {

         self.monster_stage = FANGEL_STAGE_FLOAT;
         self.monster_duration = ((random () * 100.00000) + 100.00000);

      }
      return ;

   }
   retval = walkmove (self.angles_y, dist, FALSE);
   if ( !retval ) {

      fangel_find_spot ();
      return ;

   }
   dist = (self.origin_z - self.monster_last_seen_z);
   if ( ((dist < -2.00000) && (thrust > 0.00000)) ) {

      movestep (0.00000, 0.00000, (thrust + random ()), FALSE);

   }
   if ( ((dist > 2.00000) && (thrust < 0.00000)) ) {

      movestep (0.00000, 0.00000, (thrust - random ()), FALSE);

   }
};


void  ()fangel_float =  {
   self.monster_duration = (self.monster_duration - 1.00000);
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
   if ( (self.monster_duration <= 0.00000) ) {

      self.monster_stage = FANGEL_STAGE_FLY;
      fangel_find_spot ();

   }
};


void  (float thrust)fangel_move =  {
   movestep (0.00000, 0.00000, (thrust / 2.00000), FALSE);
   if ( (self.monster_stage == FANGEL_STAGE_WAIT) ) {

      fangel_wait ();
      return ;
   } else {

      if ( (self.monster_stage == FANGEL_STAGE_FLY) ) {

         fangel_fly (thrust);
         return ;
      } else {

         if ( (self.monster_stage == FANGEL_STAGE_FLOAT) ) {

            fangel_float ();
            return ;

         }

      }

   }
};


void  ()fangel_prepare_attack =  {
   self.ideal_yaw = vectoyaw ((self.enemy.origin - self.origin));
   ChangeYaw ();
};


void  ()fangel_hand_fire =  {
   fangel_prepare_attack ();
   sound (self, CHAN_WEAPON, "fangel/hand.wav", 1.00000, ATTN_NORM);
   do_faSpell ('10.00000 -4.00000 8.00000', 400.00000);
   do_faSpell ('10.00000 -4.00000 8.00000', 300.00000);
};


void  ()fangel_wing_fire =  {
   fangel_prepare_attack ();
   sound (self, CHAN_WEAPON, "fangel/wing.wav", 1.00000, ATTN_NORM);
   makevectors (self.angles);
   do_faBlade ('8.00000 6.00000 4.00000', 360.00000, (v_right * 2.00000));
   do_faBlade ('-8.00000 6.00000 4.00000', 360.00000, (v_right * -2.00000));
};

float fangel_fly_offsets [40]   = { -0.20000,
    -0.10000,    -0.10000,    0.10000,    0.10000,
    0.20000,    0.20000,    0.30000,    0.30000,
    0.40000,    0.40000,    0.50000,    0.50000,
    0.60000,    0.60000,    0.70000,    0.70000,
    0.80000,    0.80000,    0.60000,    0.60000,
    0.30000,    0.30000,    0.00000,    -0.10000,
    -0.20000,    -0.30000,    -0.40000,    -0.50000,
    -0.60000,    -0.70000,    -0.80000,    -0.90000,
    -1.00000,    -0.80000,    -0.70000,    -0.60000,
    -0.50000,    -0.30000,    -0.20000};

void  ()fangel_blockframes =  {
local float RetVal = 0.00000;
   self.think = fangel_blockframes;
   self.nextthink = (time + HX_FRAME_TIME);
   fangel_deflect ();
   if ( self.fangel_Count ) {

      self.fangel_Count -= 1.00000;
      RetVal = 3.00000;
   } else {

      RetVal = AdvanceFrame (0.00000, 20.00000);

   }
   if ( (RetVal == AF_END) ) {

      self.takedamage = DAMAGE_YES;
      self.think = self.th_save;
   } else {

      if ( (RetVal == AF_NORMAL) ) {

         if ( (self.frame == 12.00000) ) {

            self.fangel_Count = 40.00000;

         }

      }

   }
   if ( (self.frame == 0.00000) ) {

      self.takedamage = DAMAGE_NO;

   }
};


void  ()fangel_deathframes =  {
   self.think = fangel_deathframes;
   self.nextthink = (time + HX_FRAME_TIME);
   particle2 ((self.origin - '0.00000 0.00000 80.00000'), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 384.00000, PARTICLETYPE_SPELL, 80.00000);
   if ( (AdvanceFrame (21.00000, 60.00000) == AF_BEGINNING) ) {

      remove (self);

   }
   if ( (self.frame == 21.00000) ) {

      sound (self, CHAN_WEAPON, "fangel/death.wav", 1.00000, ATTN_NORM);

   }
};


void  ()fangel_flyframes =  {
   self.think = fangel_flyframes;
   self.nextthink = (time + HX_FRAME_TIME);
   AdvanceFrame (61.00000, 100.00000);
   fangel_move ((fangel_fly_offsets->(self.frame - 61.00000)));
   if ( (self.frame == 61.00000) ) {

      sound (self, CHAN_WEAPON, "fangel/fly.wav", 1.00000, ATTN_NORM);

   }
   if ( (((self.frame >= 71.00000) && (self.frame <= 73.00000)) || ((self.frame >= 86.00000) && (self.frame <= 88.00000))) ) {

      self.fangel_SaveFrame = self.frame;
      fangel_check_wing ();

   }
};


void  ()fangel_handframes =  {
   self.think = fangel_handframes;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (101.00000, 122.00000) == AF_END) ) {

      fangel_prepare_attack ();
      self.think = self.th_save;
      self.frame = self.fangel_SaveFrame;
      self.yaw_speed = fangel_move_speed;
   } else {

      if ( (self.frame == 112.00000) ) {

         fangel_hand_fire ();
      } else {

         fangel_prepare_attack ();

      }

   }
};


void  ()fangel_painframes =  {
   self.think = fangel_painframes;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (123.00000, 134.00000) == AF_END) ) {

      self.think = self.th_save;
      self.frame = self.fangel_SaveFrame;

   }
};


void  ()fangel_wingframes =  {
   self.think = fangel_wingframes;
   self.nextthink = (time + HX_FRAME_TIME);
   if ( (AdvanceFrame (135.00000, 164.00000) == AF_END) ) {

      fangel_prepare_attack ();
      self.think = self.th_save;
      self.frame = self.fangel_SaveFrame;
      self.yaw_speed = fangel_move_speed;
   } else {

      if ( (self.frame == 155.00000) ) {

         fangel_wing_fire ();
      } else {

         fangel_prepare_attack ();

      }

   }
};


void  (entity attacker,float damage)fangel_pain =  {
   if ( (((self.frame >= 71.00000) && (self.frame <= 73.00000)) || ((self.frame >= 86.00000) && (self.frame <= 88.00000))) ) {

      sound (self, CHAN_WEAPON, "fangel/pain.wav", 1.00000, ATTN_NORM);
      self.fangel_SaveFrame = self.frame;
      self.th_save = fangel_flyframes;
      fangel_painframes ();
      dprint ("Pain!\n");

   }
};


void  ()init_fangel =  {
   if ( deathmatch ) {

      remove (self);
      return ;

   }
   self.monster_stage = FANGEL_STAGE_WAIT;
   precache_model2 ("models/fangel.mdl");
   precache_model2 ("models/faspell.mdl");
   precache_model2 ("models/fablade.mdl");
   CreateEntity (self, "models/fangel.mdl", '-14.00000 -14.00000 -41.00000', '14.00000 14.00000 23.00000', SOLID_SLIDEBOX, MOVETYPE_FLY, 0.00000, DAMAGE_YES);
   self.skin = 0.00000;
   self.hull = HULL_BIG;
   self.health = 100.00000;
   self.experience_value = 500.00000;
   self.th_stand = fangel_flyframes;
   self.th_walk = fangel_flyframes;
   self.th_run = fangel_flyframes;
   self.th_pain = fangel_pain;
   self.th_die = fangel_deathframes;
   self.th_missile = fangel_handframes;
   self.th_melee = fangel_wingframes;
   total_monsters = (total_monsters + 1.00000);
   self.ideal_yaw = (self.angles * '0.00000 1.00000 0.00000');
   self.yaw_speed = fangel_move_speed;
   self.view_ofs = '0.00000 0.00000 0.00000';
   self.use = monster_use;
   self.mintel = 3.00000;
   self.flags = (self.flags | FL_FLY);
   self.flags = (self.flags | FL_MONSTER);
   self.drawflags = (self.drawflags | DRF_TRANSLUCENT);
   self.pausetime = 100000000.00000;
   self.th_stand ();
};


void  ()monster_fallen_angel =  {
   init_fangel ();
   precache_sound2 ("fangel/deflect.wav");
   precache_sound2 ("fangel/hand.wav");
   precache_sound2 ("fangel/wing.wav");
   precache_sound2 ("fangel/death.wav");
   precache_sound2 ("fangel/fly.wav");
   precache_sound2 ("fangel/pain.wav");
};

