
void  (vector org,float damage)Ricochet =  {
local float r = 0.00000;
   particle4 (org, 3.00000, 280.00000, PARTICLETYPE_GRAV, damage);
};

entity  multi_ent;
float   multi_damage;

void  ()ClearMultDamg =  {
   multi_ent = world;
   multi_damage = 0.00000;
};


void  ()ApplyMultDamg =  {
local float kicker = 0.00000;
local float inertia = 0.00000;
local entity loser;
local entity winner;
   if ( !multi_ent ) {

      return ;

   }
   winner = self;
   loser = multi_ent;
   kicker = ((multi_damage * 7.00000) - vlen ((winner.origin - loser.origin)));
   if ( (kicker > 0.00000) ) {

      if ( (loser.flags & FL_ONGROUND) ) {

         loser.flags = (loser.flags - FL_ONGROUND);
         loser.velocity_z = (loser.velocity_z + 150.00000);

      }
      if ( (loser.mass <= 10.00000) ) {

         inertia = 1.00000;
      } else {

         inertia = (loser.mass / 10.00000);

      }
      if ( (loser == self) ) {

         loser.velocity = (loser.velocity - (normalize (loser.v_angle) * (kicker / inertia)));
      } else {

         loser.velocity = (loser.velocity + (normalize (winner.v_angle) * (kicker / inertia)));

      }
      T_Damage (loser, winner, winner, multi_damage);

   }
};


void  (entity hit,float damage)AddMultDamg =  {
   if ( !hit ) {

      return ;

   }
   if ( (hit != multi_ent) ) {

      ApplyMultDamg ();
      multi_damage = damage;
      multi_ent = hit;
   } else {

      multi_damage = (multi_damage + damage);

   }
};


void  (float damage,vector dir)TraceHit =  {
local vector vel = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
   vel = normalize (((dir + (v_up * crandom ())) + (v_right * crandom ())));
   vel = (vel + (2.00000 * trace_plane_normal));
   vel = (vel * 200.00000);
   org = (trace_endpos - (dir * 4.00000));
   if ( trace_ent.takedamage ) {

      SpawnPuff (org, (vel * 0.10000), (damage * 0.25000), trace_ent);
      AddMultDamg (trace_ent, damage);
   } else {

      Ricochet (org, damage);

   }
};


void  (float shotcount,vector dir,vector spread)InstantDamage =  {
local vector direction = '0.00000 0.00000 0.00000';
local vector src = '0.00000 0.00000 0.00000';
local vector vec = '0.00000 0.00000 0.00000';
   makevectors (self.v_angle);
   src = (self.origin + (v_forward * 10.00000));
   src_z = (self.absmin_z + (self.size_z * 0.70000));
   ClearMultDamg ();
   while ( (shotcount > 0.00000) ) {

      direction = ((dir + ((crandom () * spread_x) * v_right)) + ((crandom () * spread_y) * v_up));
      traceline (src, (src + (direction * 2048.00000)), FALSE, self);
      if ( (trace_fraction != 1.00000) ) {

         TraceHit (4.00000, direction);

      }
      shotcount = (shotcount - 1.00000);

   }
   ApplyMultDamg ();
};


void  ()bone_power =  {
   self.attack_finished = (time + 7.00000);
};


void  ()bone_normal =  {
local vector dir = '0.00000 0.00000 0.00000';
   if ( !(self.effects & EF_MUZZLEFLASH) ) {

      self.effects += EF_MUZZLEFLASH;

   }
   makevectors (self.v_angle);
   dir = normalize (v_forward);
   InstantDamage (12.00000, dir, '0.10000 0.10000 0.10000');
   self.attack_finished = (time + 0.30000);
};

void  ()boneshard_ready_loop;
void  ()Nec_Bon_Attack;

void  ()boneshard_ready_fire_a =  {
   self.wfs = advanceweaponframe (12.00000, 23.00000);
   self.th_weapon = boneshard_ready_fire_a;
   self.last_attack = time;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      boneshard_ready_loop ();
   } else {

      if ( (self.weaponframe == 12.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            bone_power ();
         } else {

            bone_normal ();

         }

      }

   }
};


void  ()boneshard_ready_fire_b =  {
   self.wfs = advanceweaponframe (0.00000, 11.00000);
   self.th_weapon = boneshard_ready_fire_b;
   self.last_attack = time;
   self.wfs = WF_CYCLE_WRAPPED;
   if ( WF_CYCLE_WRAPPED ) {

      boneshard_ready_loop ();
   } else {

      if ( (self.weaponframe == 0.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            bone_power ();
         } else {

            bone_normal ();

         }

      }

   }
};


void  ()boneshard_relax_fire =  {
   self.wfs = advanceweaponframe (24.00000, 35.00000);
   self.th_weapon = boneshard_relax_fire;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      boneshard_ready_loop ();
   } else {

      if ( (self.weaponframe == 24.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            bone_power ();
         } else {

            bone_normal ();

         }

      }

   }
};


void  ()Nec_Bon_Attack =  {
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_necromancer_spell_attack;
   } else {

      self.think = player_necromancer_crouch_move;

   }
   if ( (self.th_weapon == boneshard_ready_loop) ) {

      if ( (random () < 0.50000) ) {

         boneshard_ready_fire_a ();
      } else {

         boneshard_ready_fire_b ();

      }
   } else {

      boneshard_relax_fire ();

   }
   self.nextthink = time;
};


void  ()boneshard_relax_loop =  {
   self.weaponframe = 38.00000;
   self.th_weapon = boneshard_relax_loop;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();

   }
};


void  ()boneshard_ready_to_relax =  {
   self.wfs = advanceweaponframe (88.00000, 96.00000);
   self.th_weapon = boneshard_ready_to_relax;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();
   } else {

      if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

         boneshard_relax_loop ();

      }

   }
};


void  ()boneshard_ready_loop =  {
   if ( ((self.last_attack + 4.00000) > time) ) {

      self.weaponframe = 37.00000;

   }
   self.th_weapon = boneshard_ready_loop;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();
   } else {

      if ( (self.last_attack < (time - 30.00000)) ) {

         boneshard_ready_to_relax ();

      }

   }
};


void  ()boneshard_select =  {
   self.wfs = advanceweaponframe (45.00000, 39.00000);
   self.weaponmodel = "models/boner.mdl";
   self.th_weapon = boneshard_select;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();
   } else {

      if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

         self.attack_finished = (time - 1.00000);
         boneshard_relax_loop ();

      }

   }
};


void  ()boneshard_deselect =  {
   self.wfs = advanceweaponframe (39.00000, 45.00000);
   self.th_weapon = boneshard_deselect;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};


void  ()boneshard_select_from_mmis_ready =  {
   self.wfs = advanceweaponframe (60.00000, 73.00000);
   self.weaponmodel = "models/boner.mdl";
   self.th_weapon = boneshard_select_from_mmis_ready;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();
   } else {

      if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

         self.attack_finished = (time - 1.00000);
         boneshard_relax_loop ();

      }

   }
};


void  ()boneshard_select_from_mmis_relax =  {
   self.wfs = advanceweaponframe (74.00000, 87.00000);
   self.weaponmodel = "models/boner.mdl";
   self.th_weapon = boneshard_select_from_mmis_relax;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Nec_Bon_Attack ();
   } else {

      if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

         self.attack_finished = (time - 1.00000);
         boneshard_relax_loop ();

      }

   }
};

