entity  ()SelectSpawnPoint;
void  ()teleport_touch;

void  ()teleport_coin_run =  {
   other = self.enemy;
   teleport_touch ();
   self.think = SUB_Remove;
   self.nextthink = (time + HX_FRAME_TIME);
};


void  ()Use_TeleportCoin =  {
local entity teleport_ent;
   teleport_ent = spawn ();
   teleport_ent.goalentity = SelectSpawnPoint ();
   teleport_ent.classname = "teleportcoin";
   teleport_ent.active = 1.00000;
   teleport_ent.think = teleport_coin_run;
   teleport_ent.nextthink = (time + 0.01000);
   teleport_ent.spawnflags = 0.00000;
   teleport_ent.enemy = self;
   self.cnt_teleport -= 1.00000;
};


void  ()wedge_run =  {
   if ( (((self.owner.velocity_x == 0.00000) && (self.owner.velocity_y == 0.00000)) && (self.owner.velocity_z == 0.00000)) ) {

      self.effects = (self.effects | EF_NODRAW);
   } else {

      if ( (self.effects & EF_NODRAW) ) {

         self.effects -= EF_NODRAW;

      }

   }
   self.angles = vectoangles (self.owner.velocity);
   self.origin = self.owner.origin;
   self.think = wedge_run;
   self.nextthink = (time + 0.04000);
   if ( ((self.owner.health <= 0.00000) || !(self.owner.artifact_active & ART_HASTE)) ) {

      remove (self);

   }
};


void  ()launch_hastewedge =  {
local entity tail;
   tail = spawn ();
   tail.movetype = MOVETYPE_NOCLIP;
   tail.solid = SOLID_NOT;
   tail.classname = "haste_wedge";
   setmodel (tail, "models/wedge.mdl");
   setsize (tail, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   tail.drawflags = (tail.drawflags | DRF_TRANSLUCENT);
   tail.owner = self;
   tail.origin = tail.owner.origin;
   tail.velocity = tail.owner.velocity;
   tail.angles = tail.owner.angles;
   tail.think = wedge_run;
   tail.nextthink = (time + HX_FRAME_TIME);
};


void  ()Use_TomeofPower =  {
local string s;
   self.artifact_active = (self.artifact_active | ART_TOMEOFPOWER);
   self.tome_time = (time + TOME_TIME);
   self.cnt_tome -= 1.00000;
};


void  ()Use_Haste =  {
   self.artifact_active = (self.artifact_active | ART_HASTE);
   self.haste_time = (time + TOME_TIME);
   if ( (self.playerclass == CLASS_PALADIN) ) {

      self.hasted = 3.00000;
   } else {

      if ( (self.playerclass == CLASS_ASSASSIN) ) {

         self.hasted = 3.00000;
      } else {

         if ( (self.playerclass == CLASS_CRUSADER) ) {

            self.hasted = 3.00000;
         } else {

            if ( (self.playerclass == CLASS_NECROMANCER) ) {

               self.hasted = 3.00000;

            }

         }

      }

   }
   self.cnt_haste -= 1.00000;
};


void  ()UseBlast =  {
local vector source = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local entity victim;
local float v_length = 0.00000;
local float push = 0.00000;
local float percent = 0.00000;
local float points = 0.00000;
   victim = findradius (self.origin, BLAST_RADIUS);
   while ( victim ) {

      if ( (victim.health && (victim != self)) ) {

         if ( CanDamage (victim, self) ) {

            sound (self, CHAN_WEAPON, "raven/blast.wav", 1.00000, ATTN_NORM);
            dir = (victim.origin - self.origin);
            if ( (victim.movetype != MOVETYPE_FLYMISSILE) ) {

               v_length = vlen (dir);
               percent = (BLAST_RADIUS / v_length);
               percent = (BLAST_RADIUS / v_length);
               push = (percent + 1.00000);
               victim.velocity = (dir * push);
               if ( (victim.flags & FL_ONGROUND) ) {

                  victim.flags = (victim.flags - FL_ONGROUND);

               }
               percent = (BLAST_RADIUS / v_length);
               push = ((percent * 100.00000) + 100.00000);
               victim.velocity_z = push;
            } else {

               victim.owner = self;
               victim.velocity = (victim.velocity * -1.00000);

            }
            CreateBlueFlash (victim.origin);
            points = (percent * BLASTDAMAGE);
            T_Damage (victim, self, self, points);

         }

      }
      victim = victim.chain;

   }
};


void  ()UseInvincibility =  {
   self.artifact_active = (self.artifact_active | ART_INVINCIBILITY);
   self.invincible_time = (time + TOME_TIME);
   if ( (self.artifact_low & ART_INVINCIBILITY) ) {

      self.artifact_low = (self.artifact_low - (self.artifact_low & ART_INVINCIBILITY));

   }
   self.skin = 105.00000;
   self.effects = EF_BRIGHTLIGHT;
};

void  ()SetLaser;
void  ()Use_StickMine;
void  ()MakeForceField;

void  ()UseInventoryItem =  {
   if ( ((self.inventory == INV_TORCH) && self.cnt_torch) ) {

      UseTorch ();

   }
   if ( ((self.inventory == INV_TELEPORT) && self.cnt_teleport) ) {

      Use_TeleportCoin ();
   } else {

      if ( ((self.inventory == INV_HP_BOOST) && self.cnt_h_boost) ) {

         use_healthboost ();
      } else {

         if ( ((self.inventory == INV_SUPER_HP_BOOST) && self.cnt_sh_boost) ) {

            use_super_healthboost ();
         } else {

            if ( ((self.inventory == INV_MANA_BOOST) && self.cnt_mana_boost) ) {

               UseManaBoost ();
            } else {

               if ( ((self.inventory == INV_GLYPH) && self.cnt_glyph) ) {

                  dprint ("GLYPH\n");
                  self.cnt_glyph = (self.cnt_glyph - 1.00000);
                  if ( (self.playerclass == CLASS_ASSASSIN) ) {

                     SetLaser ();
                  } else {

                     if ( (self.playerclass == CLASS_CRUSADER) ) {

                        Use_Glyph ();
                     } else {

                        if ( (self.playerclass == CLASS_PALADIN) ) {

                           Use_StickMine ();

                        }

                     }

                  }
               } else {

                  if ( ((self.inventory == INV_HASTE) && self.cnt_haste) ) {

                     Use_Haste ();
                  } else {

                     if ( (self.inventory == INV_BLAST) ) {

                        UseBlast ();
                     } else {

                        if ( ((self.inventory == INV_CUBEOFFORCE) && self.cnt_cubeofforce) ) {

                           UseCubeOfForce ();
                        } else {

                           if ( (self.inventory == INV_INVINCIBILITY) ) {

                              UseInvincibility ();
                           } else {

                              if ( ((self.inventory == INV_TOME) && self.cnt_tome) ) {

                                 Use_TomeofPower ();

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
};

