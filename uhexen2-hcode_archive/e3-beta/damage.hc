void  ()T_MissileTouch;
void  ()info_player_start;
void  (entity targ,entity attacker)ClientObituary;
void  ()spawnsoul_sphere;
void  ()monster_death_use;
void  ()player_pain;
void  ()PlayerDie;
float ClassArmorProtection [16]   = { 0.05000,
    0.10000,    0.25000,    0.15000,    0.15000,
    0.05000,    0.10000,    0.25000,    0.25000,
    0.15000,    0.05000,    0.10000,    0.10000,
    0.15000,    0.25000,    0.05000};

float  (entity targ,entity inflictor)CanDamage =  {
local vector inflictor_org = '0.00000 0.00000 0.00000';
   inflictor_org = ((inflictor.absmin + inflictor.absmin) * 0.50000);
   if ( (targ.movetype == MOVETYPE_PUSH) ) {

      traceline (inflictor_org, (0.50000 * (targ.absmin + targ.absmax)), TRUE, self);
      if ( (trace_fraction == 1.00000) ) {

         return ( TRUE );

      }
      if ( (trace_ent == targ) ) {

         return ( TRUE );

      }
      return ( FALSE );

   }
   traceline (inflictor_org, targ.origin, TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   traceline (inflictor_org, (targ.origin + '15.00000 15.00000 0.00000'), TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   traceline (inflictor_org, (targ.origin + '-15.00000 -15.00000 0.00000'), TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   traceline (inflictor_org, (targ.origin + '-15.00000 15.00000 0.00000'), TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   traceline (inflictor_org, (targ.origin + '15.00000 -15.00000 0.00000'), TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


void  (entity targ,entity attacker)Killed =  {
local entity oself;
   oself = self;
   self = targ;
   if ( (self.flags2 & FL_ALIVE) ) {

      self.flags2 -= FL_ALIVE;

   }
   if ( (self.health < -99.00000) ) {

      self.health = -99.00000;

   }
   AwardExperience (attacker, self, 0.00000);
   if ( ((self.movetype == MOVETYPE_PUSH) || (self.movetype == MOVETYPE_NONE)) ) {

      if ( self.th_die ) {

         self.th_die ();

      }
      self = oself;
      return ;

   }
   if ( ((attacker.classname == "player") && (attacker.playerclass == CLASS_NECROMANCER)) ) {

      if ( (targ.flags & MOVETYPE_WALK) ) {

         spawnsoul_sphere ();

      }

   }
   if ( (attacker.classname == "player") ) {

      if ( ((((attacker.playerclass == CLASS_ASSASSIN) && (attacker.weapon == IT_WEAPON1)) || ((attacker.playerclass == CLASS_PALADIN) && ((attacker.weapon == IT_WEAPON2) || (attacker.weapon == IT_WEAPON3)))) || ((attacker.playerclass == CLASS_NECROMANCER) && (attacker.weapon == IT_WEAPON1))) ) {

         self.decap = TRUE;

      }

   }
   if ( (self.skin >= 100.00000) ) {

      if ( (self.classname != "player") ) {

         self.th_die = shatter;
      } else {

         if ( (self.skin < 111.00000) ) {

            self.nextthink = time;
            self.attack_finished = time;
            self.pausetime = time;

         }

      }
      if ( (self.skin == 105.00000) ) {

         self.deathtype = "ice shatter";
      } else {

         if ( (self.skin == 106.00000) ) {

            self.deathtype = "stone crumble";
         } else {

            if ( (self.skin > 110.00000) ) {

               self.deathtype = "burnt crumble";

            }

         }

      }

   }
   self.enemy = attacker;
   if ( (self.flags & FL_MONSTER) ) {

      killed_monsters = (killed_monsters + 1.00000);
      WriteByte (MSG_ALL, SVC_KILLEDMONSTER);

   }
   if ( (self.classname == "player") ) {

      ClientObituary (self, attacker);

   }
   if ( (self.ai_poss_states | AI_DEAD_GIB) ) {

      self.ai_duration = (time - 1.00000);

   }
   self.touch = SUB_Null;
   monster_death_use ();
   self.ai_duration = (time - 1.00000);
   if ( self.target ) {

      SUB_UseTargets ();

   }
   if ( (oself != targ) ) {

      if ( (self.classname == "player") ) {

         PlayerDie ();
      } else {

         if ( self.th_die ) {

            self.th_die ();

         }

      }
      self = oself;
   } else {

      self.th_missile = SUB_Null;
      self.th_melee = SUB_Null;
      self.think = SUB_Null;
      self.oldthink = SUB_Null;
      self.th_pain = SUB_Null;
      self.th_run = SUB_Null;
      self.th_walk = SUB_Null;
      self.th_stand = SUB_Null;
      if ( (self.classname == "player") ) {

         self.think = PlayerDie;
      } else {

         if ( self.th_die ) {

            self.think = self.th_die;

         }

      }
      self.nextthink = time;

   }
};


void  (entity attacker)monster_pissed =  {
   if ( (self.enemy.classname == "player") ) {

      self.oldenemy = self.enemy;

   }
   self.enemy = attacker;
   self.goalentity = self.enemy;
   if ( self.th_walk ) {

      FoundTarget ();

   }
};


float  (entity victim)armor_inv =  {
local float armor_cnt = 0.00000;
   armor_cnt = 0.00000;
   if ( victim.armor_amulet ) {

      armor_cnt += 1.00000;

   }
   if ( victim.armor_bracer ) {

      armor_cnt += 1.00000;

   }
   if ( victim.armor_breastplate ) {

      armor_cnt += 1.00000;

   }
   if ( victim.armor_helmet ) {

      armor_cnt += 1.00000;

   }
   return ( armor_cnt );
};


float  (entity targ,float damage)armor_calc =  {
local float total_armor_protection = 0.00000;
local float armor_cnt = 0.00000;
local float armor_damage = 0.00000;
local float perpiece = 0.00000;
local float curr_damage = 0.00000;
   total_armor_protection = 0.00000;
   if ( targ.armor_amulet ) {

      total_armor_protection += ClassArmorProtection[targ.playerclass - 1];

   }
   if ( targ.armor_bracer ) {

      total_armor_protection += ClassArmorProtection[(targ.playerclass - 1) + 1];

   }
   if ( targ.armor_breastplate ) {

      total_armor_protection += ClassArmorProtection[(targ.playerclass - 1) + 2];

   }
   if ( targ.armor_helmet ) {

      total_armor_protection += ClassArmorProtection[(targ.playerclass - 1) + 3];

   }
   total_armor_protection += (targ.level * 0.00100);
   armor_cnt = armor_inv (targ);
   if ( armor_cnt ) {

      armor_damage = (total_armor_protection * damage);
      if ( (armor_damage > (((targ.armor_amulet + targ.armor_bracer) + targ.armor_breastplate) + targ.armor_helmet)) ) {

         targ.armor_amulet = 0.00000;
         targ.armor_bracer = 0.00000;
         targ.armor_breastplate = 0.00000;
         targ.armor_helmet = 0.00000;
      } else {

         curr_damage = armor_damage;
         armor_cnt = armor_inv (targ);
         perpiece = (curr_damage / armor_cnt);
         if ( (targ.armor_amulet && curr_damage) ) {

            targ.armor_amulet -= perpiece;
            curr_damage -= perpiece;
            if ( (targ.armor_amulet < 0.00000) ) {

               curr_damage -= targ.armor_amulet;
               targ.armor_amulet = 0.00000;

            }
            if ( (targ.armor_amulet < 1.00000) ) {

               targ.armor_amulet = 0.00000;

            }

         }
         if ( (targ.armor_bracer && curr_damage) ) {

            targ.armor_bracer -= perpiece;
            curr_damage -= perpiece;
            if ( (targ.armor_bracer < 0.00000) ) {

               curr_damage -= targ.armor_bracer;
               targ.armor_bracer = 0.00000;

            }
            if ( (targ.armor_bracer < 1.00000) ) {

               targ.armor_bracer = 0.00000;

            }

         }
         if ( (targ.armor_breastplate && curr_damage) ) {

            targ.armor_breastplate -= perpiece;
            curr_damage -= perpiece;
            if ( (targ.armor_breastplate < 0.00000) ) {

               curr_damage -= targ.armor_breastplate;
               targ.armor_breastplate = 0.00000;

            }
            if ( (targ.armor_breastplate < 1.00000) ) {

               targ.armor_breastplate = 0.00000;

            }

         }
         if ( (targ.armor_helmet && curr_damage) ) {

            targ.armor_helmet -= perpiece;
            curr_damage -= perpiece;
            if ( (targ.armor_helmet < 0.00000) ) {

               curr_damage -= targ.armor_helmet;
               targ.armor_helmet = 0.00000;

            }
            if ( (targ.armor_helmet < 1.00000) ) {

               targ.armor_helmet = 0.00000;

            }

         }

      }
   } else {

      armor_damage = 0.00000;

   }
   return ( armor_damage );
};


void  (entity targ,entity inflictor,entity attacker,float damage)T_Damage =  {
local vector dir = '0.00000 0.00000 0.00000';
local entity oldself;
local float save = 0.00000;
local float total_damage = 0.00000;
local string printnum;
local float armor_damage = 0.00000;
   if ( (!targ.takedamage || targ.invincible_time) ) {

      return ;

   }
   if ( (targ.classname == "mezzoman") ) {

      if ( (targ.movechain.classname == "mezzo reflect") ) {

         if ( infront_of_ent (inflictor, targ) ) {

            return ;

         }

      }

   }
   if ( (targ.health <= 0.00000) ) {

      targ.health = (targ.health - damage);
      return ;

   }
   if ( (targ.flags2 & FL_SHIELDED) ) {

      targ = targ.shield;

   }
   if ( (targ.flags2 & FL_SMALL) ) {

      damage = (damage * 10.00000);

   }
   if ( ((inflictor.flags2 & FL_SMALL) || (attacker.flags2 & FL_SMALL)) ) {

      damage = (damage * 0.10000);

   }
   damage_attacker = attacker;
   if ( (targ.classname == "player") ) {

      armor_damage = armor_calc (targ, damage);
      total_damage = (damage - armor_damage);
   } else {

      total_damage = damage;

   }
   if ( (targ.flags & FL_CLIENT) ) {

      targ.dmg_take = (targ.dmg_take + total_damage);
      targ.dmg_save = (targ.dmg_save + save);
      targ.dmg_inflictor = inflictor;

   }
   if ( ((inflictor != world) && (targ.movetype == MOVETYPE_WALK)) ) {

      dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * 0.50000));
      dir = normalize (dir);
      targ.velocity = (targ.velocity + ((dir * damage) * 8.00000));

   }
   if ( (targ.flags & FL_GODMODE) ) {

      return ;

   }
   if ( (targ.invincible_finished >= time) ) {

      if ( (self.invincible_sound < time) ) {

         sound (targ, CHAN_ITEM, "raven/invulner.wav", 1.00000, ATTN_NORM);
         self.invincible_sound = (time + 2.00000);

      }
      return ;

   }
   if ( (((teamplay == 1.00000) && (targ.team > 0.00000)) && (targ.team == attacker.team)) ) {

      return ;

   }
   targ.health = (targ.health - total_damage);
   if ( (targ.health <= 0.00000) ) {

      targ.th_pain = SUB_Null;
      Killed (targ, attacker);
      return ;

   }
   oldself = self;
   self = targ;
   if ( (self.classname == "barrel") ) {

      self.enemy = inflictor;
      self.count = damage;
   } else {

      if ( (self.classname == "catapult") ) {

         self.enemy = inflictor;

      }

   }
   if ( (((self.flags & FL_MONSTER) && (attacker != world)) && !(attacker.flags & FL_NOTARGET)) ) {

      if ( ((self != attacker) && (attacker != self.enemy)) ) {

         if ( (self.classname != attacker.classname) ) {

            if ( ((self.spiderType && attacker.spiderType) || (self.scorpionType && attacker.scorpionType)) ) {

               if ( (random () < 0.30000) ) {

                  monster_pissed (attacker);

               }
            } else {

               monster_pissed (attacker);

            }

         }

      }

   }
   self.just_hurt = TRUE;
   self.ai_duration = (time - 1.00000);
   if ( self.th_pain ) {

      if ( (self.classname == "player") ) {

         player_pain ();
      } else {

         self.th_pain (attacker, total_damage);

      }
      if ( (skill == 3.00000) ) {

         self.pain_finished = (time + 5.00000);

      }

   }
   self = oldself;
};

void  (entity loser)SpawnFlameOn;

void  (entity inflictor,entity attacker,float damage,entity ignore)T_RadiusDamage =  {
local float points = 0.00000;
local float inertia = 0.00000;
local entity head;
local vector inflictor_org = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
   inflictor_org = ((inflictor.absmin + inflictor.absmax) * 0.50000);
   head = findradius (inflictor_org, (damage + 40.00000));
   while ( head ) {

      if ( ((head != ignore) && (head != inflictor)) ) {

         if ( head.takedamage ) {

            org = ((head.absmax + head.absmin) * 0.50000);
            points = (0.50000 * vlen ((inflictor_org - org)));
            if ( ((points < 0.00000) || ((inflictor.classname == "snowball") && (head.flags & FL_COLDRESIST))) ) {

               points = 0.00000;

            }
            points = (damage - points);
            if ( (head == attacker) ) {

               points = (points * 0.50000);

            }
            if ( (((head.owner == inflictor.owner) && (head.classname == inflictor.classname)) && ((head.classname == "stickmine") || (head.classname == "tripmine"))) ) {

               points = 0.00000;

            }
            if ( (points > 0.00000) ) {

               if ( CanDamage (head, inflictor) ) {

                  if ( (head.mass <= 10.00000) ) {

                     inertia = 1.00000;
                  } else {

                     if ( (head.mass <= 100.00000) ) {

                        inertia = (head.mass / 10.00000);
                     } else {

                        inertia = head.mass;

                     }

                  }
                  head.velocity = (head.velocity + (normalize ((org - inflictor_org)) * ((points * 10.00000) / inertia)));
                  if ( (head.flags & FL_ONGROUND) ) {

                     head.flags = (head.flags - FL_ONGROUND);

                  }
                  if ( (inflictor.classname == "fireballblast") ) {

                     if ( (points > 10.00000) ) {

                        points = 10.00000;

                     }
                     SpawnFlameOn (head);
                     points = 5.00000;
                     if ( (other.flags & FL_FIREHEAL) ) {

                        other.health = (other.health + points);
                     } else {

                        if ( !(other.flags & FL_FIRERESIST) ) {

                           T_Damage (head, inflictor, attacker, points);

                        }

                     }
                  } else {

                     T_Damage (head, inflictor, attacker, points);

                  }

               }

            }

         }

      }
      head = head.chain;

   }
};


void  (entity inflictor,entity attacker,float dam,entity ignore)T_RadiusDamageWater =  {
local float points = 0.00000;
local entity head;
local vector org = '0.00000 0.00000 0.00000';
   head = findradius (inflictor.origin, dam);
   while ( head ) {

      if ( (head != ignore) ) {

         if ( head.takedamage ) {

            if ( ((pointcontents (head.origin) == CONTENT_WATER) || (pointcontents (head.origin) == CONTENT_SLIME)) ) {

               if ( ((head.classname == "player") && (head != attacker)) ) {

                  head.enemy = attacker;

               }
               org = (head.origin + ((head.mins + head.maxs) * 0.50000));
               points = (0.25000 * vlen ((inflictor.origin - org)));
               if ( (points <= 64.00000) ) {

                  points = 1.00000;

               }
               points = (dam / points);
               if ( (((points < 1.00000) || ((self.classname == "mjolnir") && (head == self.controller))) || (head.classname == "hydra")) ) {

                  points = 0.00000;

               }
               if ( (points > 0.00000) ) {

                  head.deathtype = "zap";
                  spawnshockball (((head.absmax + head.absmin) * 0.50000));
                  T_Damage (head, inflictor, attacker, points);

               }

            }

         }

      }
      head = head.chain;

   }
};


void  (entity attacker,float damage)T_BeamDamage =  {
local float points = 0.00000;
local entity head;
   head = findradius (attacker.origin, (damage + 40.00000));
   while ( head ) {

      if ( head.takedamage ) {

         points = (0.50000 * vlen ((attacker.origin - head.origin)));
         if ( (points < 0.00000) ) {

            points = 0.00000;

         }
         points = (damage - points);
         if ( (head == attacker) ) {

            points = (points * 0.50000);

         }
         if ( (points > 0.00000) ) {

            if ( CanDamage (head, attacker) ) {

               T_Damage (head, attacker, attacker, points);

            }

         }

      }
      head = head.chain;

   }
};


void  (entity inflictor,entity attacker,float manadamage,entity ignore)T_RadiusManaDamage =  {
local float points = 0.00000;
local entity head;
local vector org = '0.00000 0.00000 0.00000';
   head = findradius (inflictor.origin, manadamage);
   while ( head ) {

      if ( (head != ignore) ) {

         if ( (head.takedamage && (head.classname == "player")) ) {

            org = (head.origin + ((head.mins + head.maxs) * 0.50000));
            points = (0.50000 * vlen ((inflictor.origin - org)));
            if ( (points < 0.00000) ) {

               points = 0.00000;

            }
            points = (manadamage - points);
            if ( (head == attacker) ) {

               points = (points * 0.50000);

            }
            if ( (points > 0.00000) ) {

               if ( CanDamage (head, inflictor) ) {

                  head.bluemana = (head.bluemana - points);
                  if ( (head.bluemana < 0.00000) ) {

                     head.bluemana = 0.00000;

                  }
                  head.greenmana = (head.greenmana - points);
                  if ( (head.greenmana < 0.00000) ) {

                     head.greenmana = 0.00000;

                  }

               }

            }

         }

      }
      head = head.chain;

   }
};

