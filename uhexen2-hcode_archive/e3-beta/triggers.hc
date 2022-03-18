void  ()multi_touch;
float SPAWNFLAG_DODAMAGE   =  1.00000;
float SPAWNFLAG_QMULT   =  2.00000;
float COUNTER_ORDERED   =  2.00000;
entity stemp;
entity otemp;
entity s;
entity old;

void  ()trigger_reactivate =  {
   self.solid = SOLID_TRIGGER;
};

float SPAWNFLAG_NOMESSAGE   =  1.00000;
float SPAWNFLAG_NOTOUCH   =  1.00000;
float SPAWNFLAG_MTOUCH   =  2.00000;
float SPAWNFLAG_PUSHTOUCH   =  4.00000;
float SPAWNFLAG_ACTIVATED   =  8.00000;
float SPAWNFLAG_REMOVE_PP   =  16.00000;
float SPAWNFLAG_NO_PP   =  32.00000;

void  ()multi_wait =  {
   if ( self.max_health ) {

      self.health = self.max_health;
      self.takedamage = DAMAGE_NO_GRENADE;
      self.solid = SOLID_BBOX;

   }
};


void  ()multi_trigger =  {
   if ( (self.nextthink > time) ) {

      return ;

   }
   if ( (self.classname == "trigger_secret") ) {

      if ( (self.enemy.classname != "player") ) {

         return ;

      }
      found_secrets = (found_secrets + 1.00000);
      WriteByte (MSG_ALL, SVC_FOUNDSECRET);

   }
   if ( self.noise ) {

      sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);

   }
   self.takedamage = DAMAGE_NO;
   activator = self.enemy;
   if ( self.experience_value ) {

      AwardExperience (activator, self, 0.00000);

   }
   SUB_UseTargets ();
   if ( (self.wait > 0.00000) ) {

      self.think = multi_wait;
      self.nextthink = (time + self.wait);
   } else {

      self.touch = SUB_Null;
      self.nextthink = (time + 0.10000);
      self.think = SUB_Remove;

   }
};


void  ()multi_killed =  {
   self.enemy = damage_attacker;
   multi_trigger ();
};


float  (entity client,string piece)client_has_piece =  {
   if ( ((((((((client.puzzle_inv_1 == piece) || (client.puzzle_inv_2 == piece)) || (client.puzzle_inv_3 == piece)) || (client.puzzle_inv_4 == piece)) || (client.puzzle_inv_5 == piece)) || (client.puzzle_inv_6 == piece)) || (client.puzzle_inv_7 == piece)) || (client.puzzle_inv_8 == piece)) ) {

      return ( 1.00000 );

   }
   return ( 0.00000 );
};


void  (entity client,string piece)client_remove_piece =  {
   if ( !piece ) {

      return ;

   }
   if ( (client.puzzle_inv_1 == piece) ) {

      client.puzzle_inv_1 = string_null;
   } else {

      if ( (client.puzzle_inv_2 == piece) ) {

         client.puzzle_inv_2 = string_null;
      } else {

         if ( (client.puzzle_inv_3 == piece) ) {

            client.puzzle_inv_3 = string_null;
         } else {

            if ( (client.puzzle_inv_4 == piece) ) {

               client.puzzle_inv_4 = string_null;
            } else {

               if ( (client.puzzle_inv_5 == piece) ) {

                  client.puzzle_inv_5 = string_null;
               } else {

                  if ( (client.puzzle_inv_6 == piece) ) {

                     client.puzzle_inv_6 = string_null;
                  } else {

                     if ( (client.puzzle_inv_7 == piece) ) {

                        client.puzzle_inv_7 = string_null;
                     } else {

                        if ( (client.puzzle_inv_8 == piece) ) {

                           client.puzzle_inv_8 = string_null;

                        }

                     }

                  }

               }

            }

         }

      }

   }
};


float  (entity client,float remove_pieces)check_puzzle_pieces =  {
   if ( self.puzzle_piece_1 ) {

      if ( !client_has_piece (client, self.puzzle_piece_1) ) {

         return ( 0.00000 );

      }

   }
   if ( self.puzzle_piece_2 ) {

      if ( !client_has_piece (client, self.puzzle_piece_2) ) {

         return ( 0.00000 );

      }

   }
   if ( self.puzzle_piece_3 ) {

      if ( !client_has_piece (client, self.puzzle_piece_3) ) {

         return ( 0.00000 );

      }

   }
   if ( self.puzzle_piece_4 ) {

      if ( !client_has_piece (client, self.puzzle_piece_4) ) {

         return ( 0.00000 );

      }

   }
   if ( remove_pieces ) {

      client_remove_piece (client, self.puzzle_piece_1);
      client_remove_piece (client, self.puzzle_piece_2);
      client_remove_piece (client, self.puzzle_piece_3);
      client_remove_piece (client, self.puzzle_piece_4);

   }
   return ( 1.00000 );
};


void  ()multi_use =  {
   if ( (time < self.attack_finished) ) {

      return ;

   }
   if ( (self.spawnflags & SPAWNFLAG_ACTIVATED) ) {

      self.touch = multi_touch;
      return ;

   }
   if ( (self.spawnflags & SPAWNFLAG_NO_PP) ) {

      if ( check_puzzle_pieces (other, (self.spawnflags & SPAWNFLAG_REMOVE_PP)) ) {

         if ( self.no_puzzle_msg ) {

            centerprint (other, self.no_puzzle_msg);
            self.attack_finished = (time + 2.00000);

         }
         return ;

      }
   } else {

      if ( !check_puzzle_pieces (other, (self.spawnflags & SPAWNFLAG_REMOVE_PP)) ) {

         if ( self.no_puzzle_msg ) {

            centerprint (other, self.no_puzzle_msg);
            self.attack_finished = (time + 2.00000);

         }
         return ;

      }

   }
   self.enemy = activator;
   multi_trigger ();
};


void  ()multi_touch =  {
   if ( (time < self.attack_finished) ) {

      return ;

   }
   if ( (self.spawnflags & SPAWNFLAG_MTOUCH) ) {

      if ( !(other.flags & FL_MONSTER) ) {

         return ;

      }
   } else {

      if ( (self.spawnflags & SPAWNFLAG_PUSHTOUCH) ) {

         if ( !(other.flags & FL_PUSH) ) {

            return ;

         }
      } else {

         if ( (other.classname != "player") ) {

            return ;

         }

      }

   }
   if ( (self.movedir != '0.00000 0.00000 0.00000') ) {

      makevectors (other.angles);
      if ( ((v_forward * self.movedir) < 0.00000) ) {

         return ;

      }

   }
   if ( (self.spawnflags & SPAWNFLAG_NO_PP) ) {

      if ( check_puzzle_pieces (other, (self.spawnflags & SPAWNFLAG_REMOVE_PP)) ) {

         if ( self.no_puzzle_msg ) {

            centerprint (other, self.no_puzzle_msg);
            self.attack_finished = (time + 2.00000);

         }
         return ;

      }
   } else {

      if ( !check_puzzle_pieces (other, (self.spawnflags & SPAWNFLAG_REMOVE_PP)) ) {

         if ( self.no_puzzle_msg ) {

            centerprint (other, self.no_puzzle_msg);
            self.attack_finished = (time + 2.00000);

         }
         return ;

      }

   }
   self.enemy = other;
   multi_trigger ();
};


void  ()trigger_multiple =  {
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("misc/secret.wav");
      self.noise = "misc/secret.wav";
   } else {

      if ( (self.soundtype == 2.00000) ) {

         precache_sound ("misc/comm.wav");
         self.noise = "misc/comm.wav";
      } else {

         if ( (self.soundtype == 3.00000) ) {

            precache_sound ("misc/trigger1.wav");
            self.noise = "misc/trigger1.wav";

         }

      }

   }
   if ( !self.wait ) {

      self.wait = 0.20000;

   }
   self.use = multi_use;
   InitTrigger ();
   if ( self.health ) {

      if ( (self.spawnflags & SPAWNFLAG_NOTOUCH) ) {

         objerror ("health and notouch don't make sense\n");

      }
      self.max_health = self.health;
      self.th_die = multi_killed;
      self.takedamage = DAMAGE_NO_GRENADE;
      self.solid = SOLID_BBOX;
      setorigin (self, self.origin);
   } else {

      if ( (!(self.spawnflags & SPAWNFLAG_NOTOUCH) && !(self.spawnflags & SPAWNFLAG_ACTIVATED)) ) {

         self.touch = multi_touch;

      }

   }
};


void  ()trigger_once =  {
   self.wait = -1.00000;
   trigger_multiple ();
};


void  ()trigger_activate =  {
   if ( (self.spawnflags & 1.00000) ) {

      trigger_once ();
   } else {

      if ( (self.spawnflags & 2.00000) ) {

         self.use = SUB_UseTargets;
      } else {

         trigger_multiple ();

      }

   }
};


void  ()trigger_deactivate =  {
   if ( (self.spawnflags & 1.00000) ) {

      trigger_once ();
   } else {

      if ( (self.spawnflags & 2.00000) ) {

         self.use = SUB_UseTargets;
      } else {

         trigger_multiple ();

      }

   }
};


void  ()interval_use =  {
   SUB_UseTargets ();
   self.think = interval_use;
   self.nextthink = (time + self.wait);
};


void  ()trigger_interval =  {
   if ( !self.wait ) {

      self.wait = 5.00000;

   }
   self.use = interval_use;
   self.think = interval_use;
   if ( !self.targetname ) {

      self.nextthink = (time + 0.10000);

   }
};


void  ()trigger_relay_use =  {
   SUB_UseTargets ();
};


void  ()trigger_relay =  {
   self.use = trigger_relay_use;
};


void  ()trigger_secret =  {
   total_secrets = (total_secrets + 1.00000);
   self.wait = -1.00000;
   if ( !self.message ) {

      self.message = "You found a secret area!";

   }
   if ( !self.soundtype ) {

      self.soundtype = 1.00000;

   }
   if ( (self.soundtype == 1.00000) ) {

      precache_sound ("misc/secret.wav");
      self.noise = "misc/secret.wav";
   } else {

      if ( (self.soundtype == 2.00000) ) {

         precache_sound ("misc/comm.wav");
         self.noise = "misc/comm.wav";

      }

   }
   trigger_multiple ();
};


void  ()counter_find_linked =  {
local entity starte;
local entity t;
   starte = self;
   t = nextent (world);
   if ( (self.netname == "") ) {

      objerror ("Ordered counter without a netname\n");

   }
   self.think = SUB_Null;
   while ( (t != world) ) {

      self.owner = starte;
      t = find (t, netname, starte.netname);
      if ( ((t != world) && (t != starte)) ) {

         self.chain = t;
         self = t;

      }

   }
   self = starte;
};


void  ()counter_use_ordered =  {
local entity t;
local string oldtarg;
local string oldmsg;
   if ( (other.flags != self.cnt) ) {

      self.items = 1.00000;

   }
   self.cnt += 1.00000;
   self.count -= 1.00000;
   if ( !self.items ) {

      if ( (self.count < 0.00000) ) {

         if ( ((activator.classname == "player") && ((self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0.00000)) ) {

            centerprint (activator, "Sequence completed!");

         }
         self.enemy = activator;
         multi_trigger ();

      }
   } else {

      if ( (self.count < 0.00000) ) {

         if ( self.msg2 ) {

            if ( (activator.classname == "player") ) {

               centerprint (activator, self.msg2);

            }
         } else {

            if ( (activator.classname == "player") ) {

               centerprint (activator, "Nothing seemed to happen");

            }

         }
         oldtarg = self.target;
         self.target = self.puzzle_id;
         oldmsg = self.message;
         self.message = "";
         SUB_UseTargets ();
         self.message = oldmsg;
         self.target = oldtarg;
         self.cnt = 1.00000;
         self.count = self.frags;
         self.items = 0.00000;
         t = self.chain;
         while ( t ) {

            if ( (t.classname == "button") ) {

               t.think = button_return;
               t.nextthink = (t.ltime + 1.00000);

            }
            t = t.chain;

         }

      }

   }
};


void  ()counter_use =  {
local string junk;
   self.count -= 1.00000;
   if ( (self.count < 0.00000) ) {

      return ;

   }
   if ( (self.count != 0.00000) ) {

      if ( ((activator.classname == "player") && ((self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0.00000)) ) {

         if ( (self.count >= 4.00000) ) {

            centerprint (activator, "There are more to go...");
         } else {

            if ( (self.count == 3.00000) ) {

               centerprint (activator, "Only 3 more to go...");
            } else {

               if ( (self.count == 2.00000) ) {

                  centerprint (activator, "Only 2 more to go...");
               } else {

                  centerprint (activator, "Only 1 more to go...");

               }

            }

         }

      }
      return ;

   }
   if ( ((activator.classname == "player") && ((self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0.00000)) ) {

      centerprint (activator, "Sequence completed!");

   }
   self.enemy = activator;
   multi_trigger ();
};


void  ()trigger_counter =  {
   self.wait = -1.00000;
   if ( !self.count ) {

      self.count = 2.00000;

   }
   self.items = 0.00000;
   self.cnt = 1.00000;
   self.frags = self.count;
   if ( (self.spawnflags & COUNTER_ORDERED) ) {

      self.use = counter_use_ordered;
      self.nextthink = (time + 0.10000);
      self.think = counter_find_linked;
   } else {

      self.use = counter_use;

   }
};


void  ()check_find_linked =  {
local entity starte;
local entity t;
   starte = self;
   t = nextent (world);
   if ( (self.netname == "") ) {

      objerror ("Check trigger without a netname\n");

   }
   self.think = SUB_Null;
   while ( (t != world) ) {

      self.owner = starte;
      t = find (t, netname, starte.netname);
      if ( ((t != world) && (t != starte)) ) {

         self.chain = t;
         self = t;

      }

   }
   self = starte;
};


void  ()check_use =  {
local entity t;
local float failed = 0.00000;
   t = self.chain;
   while ( t ) {

      if ( !t.aflag ) {

         failed = 1.00000;

      }
      t = t.chain;

   }
   if ( (!failed && !self.cnt) ) {

      self.cnt = 1.00000;
      SUB_UseTargets ();
   } else {

      if ( (failed && self.cnt) ) {

         SUB_UseTargets ();
         self.cnt = 0.00000;

      }

   }
};


void  ()trigger_check =  {
   self.cnt = 0.00000;
   self.use = check_use;
   self.nextthink = (time + 0.10000);
   self.think = check_find_linked;
};


void  ()quake_shake_next =  {
local entity player;
   if ( (self.spawnflags & SPAWNFLAG_DODAMAGE) ) {

      T_Damage (self.enemy, self, self, self.dmg);

   }
   player = world;
   player = find (world, classname, "player");
   if ( !player ) {

      dprint ("player not found!\n");
      return ;

   }
   player.punchangle_x = ((random () * 10.00000) - 5.00000);
   player.punchangle_y = ((random () * 8.00000) - 4.00000);
   player.punchangle_z = ((random () * 8.00000) - 4.00000);
   if ( (player.flags & FL_ONGROUND) ) {

      player.velocity_z += ((random () * 100.00000) + 100.00000);
      player.velocity_y += ((random () * 50.00000) - 25.00000);
      player.velocity_x += ((random () * 50.00000) - 25.00000);
      player.flags = (player.flags - FL_ONGROUND);

   }
   self.think = quake_shake_next;
   self.nextthink = 0.10000;
   if ( ((self.ltime + self.lifespan) < time) ) {

      self.nextthink = -1.00000;
      self.wait = -1.00000;
   } else {

      self.nextthink = (self.ltime + 0.10000);

   }
};


void  ()quake_shake =  {
   self.ltime = time;
   self.think = quake_shake_next;
   self.nextthink = (self.ltime + 0.10000);
   SUB_UseTargets ();
   if ( !(self.spawnflags & SPAWNFLAG_QMULT) ) {

      self.wait = -1.00000;

   }
};


void  ()quake_use =  {
   if ( (self.nextthink >= time) ) {

      return ;

   }
   self.think = quake_shake;
   self.nextthink = (time + self.wait);
};


void  ()trigger_quake =  {
   self.use = quake_use;
   if ( !self.wait ) {

      self.wait = 1.00000;

   }
   if ( !self.dmg ) {

      self.dmg = 5.00000;

   }
   if ( !self.lifespan ) {

      self.lifespan = 2.00000;

   }
   InitTrigger ();
   self.touch = SUB_Null;
};

float PLAYER_ONLY   =  1.00000;
float SILENT   =  2.00000;

void  ()play_teleport =  {
local float v = 0.00000;
local string tmpstr;
   v = (random () * 5.00000);
   if ( (v < 1.00000) ) {

      tmpstr = "misc/teleprt1.wav";
   } else {

      if ( (v < 2.00000) ) {

         tmpstr = "misc/teleprt2.wav";
      } else {

         if ( (v < 3.00000) ) {

            tmpstr = "misc/teleprt3.wav";
         } else {

            if ( (v < 4.00000) ) {

               tmpstr = "misc/teleprt4.wav";
            } else {

               tmpstr = "misc/teleprt5.wav";

            }

         }

      }

   }
   sound (self, CHAN_VOICE, tmpstr, 1.00000, ATTN_NORM);
   remove (self);
};


void  (vector org)spawn_tfog =  {
   s = spawn ();
   s.origin = org;
   s.nextthink = (time + 0.05000);
   s.think = play_teleport;
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_TELEPORT);
   WriteCoord (MSG_BROADCAST, org_x);
   WriteCoord (MSG_BROADCAST, org_y);
   WriteCoord (MSG_BROADCAST, org_z);
};


void  ()tdeath_touch =  {
   if ( (other == self.owner) ) {

      return ;

   }
   if ( (other.classname == "player") ) {

      if ( (other.invincible_finished > time) ) {

         self.classname = "teledeath2";

      }
      if ( (self.owner.classname != "player") ) {

         T_Damage (self.owner, self, self, 50000.00000);
         return ;

      }

   }
   if ( other.health ) {

      T_Damage (other, self, self, 50000.00000);

   }
};


void  (vector org,entity death_owner)spawn_tdeath =  {
local entity death;
   death = spawn ();
   death.classname = "teledeath";
   death.movetype = MOVETYPE_NONE;
   death.solid = SOLID_TRIGGER;
   death.angles = '0.00000 0.00000 0.00000';
   setsize (death, (death_owner.mins - '1.00000 1.00000 1.00000'), (death_owner.maxs + '1.00000 1.00000 1.00000'));
   setorigin (death, org);
   death.touch = tdeath_touch;
   death.nextthink = (time + 0.20000);
   death.think = SUB_Remove;
   death.owner = death_owner;
   force_retouch = 2.00000;
};


void  ()teleport_touch =  {
local entity t;
local vector org = '0.00000 0.00000 0.00000';
   if ( !self.active ) {

      return ;

   }
   if ( (self.spawnflags & PLAYER_ONLY) ) {

      if ( (other.classname != "player") ) {

         return ;

      }

   }
   if ( ((other.health <= 0.00000) || (other.solid != SOLID_SLIDEBOX)) ) {

      return ;

   }
   SUB_UseTargets ();
   if ( !(self.spawnflags & SILENT) ) {

      spawn_tfog (other.origin);

   }
   if ( (self.classname != "teleportcoin") ) {

      t = find (world, targetname, self.target);
      if ( !t ) {

         objerror ("couldn't find target");

      }
   } else {

      t = self.goalentity;

   }
   makevectors (t.mangle);
   org = (t.origin + (32.00000 * v_forward));
   if ( !(self.spawnflags & SILENT) ) {

      spawn_tfog (org);

   }
   spawn_tdeath (t.origin, other);
   if ( !other.health ) {

      other.origin = t.origin;
      other.velocity = ((v_forward * other.velocity_x) + (v_forward * other.velocity_y));
      return ;

   }
   setorigin (other, t.origin);
   other.angles = t.mangle;
   if ( (other.classname == "player") ) {

      other.fixangle = 1.00000;
      other.teleport_time = (time + 0.70000);
      if ( (other.flags & FL_ONGROUND) ) {

         other.flags = (other.flags - FL_ONGROUND);

      }
      other.velocity = (v_forward * 300.00000);

   }
   if ( (other.flags & FL_ONGROUND) ) {

      other.flags -= FL_ONGROUND;

   }
};


void  ()info_teleport_destination =  {
   self.mangle = self.angles;
   self.angles = '0.00000 0.00000 0.00000';
   self.model = "";
   self.origin = (self.origin + '0.00000 0.00000 27.00000');
   if ( !self.targetname ) {

      objerror ("no targetname");

   }
};


void  ()teleport_use =  {
   if ( (other.classname == "trigger_activate") ) {

      if ( !self.active ) {

         self.active = 1.00000;
      } else {

         self.active = 0.00000;

      }
   } else {

      if ( (other.classname == "trigger_deactivate") ) {

         self.active = 0.00000;

      }

   }
   if ( !self.active ) {

      return ;

   }
   self.nextthink = (time + 0.20000);
   force_retouch = 2.00000;
   self.think = SUB_Null;
};


void  ()trigger_teleport =  {
local vector o = '0.00000 0.00000 0.00000';
   InitTrigger ();
   self.touch = teleport_touch;
   if ( !self.target ) {

      objerror ("no target");

   }
   self.use = teleport_use;
   if ( !(self.spawnflags & SILENT) ) {

      precache_sound ("ambience/hum1.wav");
      o = ((self.mins + self.maxs) * 0.50000);
      ambientsound (o, "ambience/hum1.wav", 0.50000, ATTN_STATIC);

   }
   if ( (self.spawnflags & 4.00000) ) {

      self.active = 0.00000;
   } else {

      self.active = 1.00000;

   }
};


void  ()teleport_newmap_touch =  {
   if ( (((other.classname != "player") || (other.health <= 0.00000)) || (other.solid != SOLID_SLIDEBOX)) ) {

      return ;

   }
   stuffcmd (self, self.target);
};


void  ()trigger_teleport_newmap =  {
   InitTrigger ();
   if ( !self.target ) {

      objerror ("no target map");

   }
   self.touch = teleport_newmap_touch;
};


void  ()trigger_skill_touch =  {
   if ( (other.classname != "player") ) {

      return ;

   }
   cvar_set ("skill", self.message);
};


void  ()trigger_setskill =  {
   InitTrigger ();
   self.touch = trigger_skill_touch;
};


void  ()trigger_onlyregistered_touch =  {
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (self.attack_finished > time) ) {

      return ;

   }
   self.attack_finished = (time + 2.00000);
   if ( cvar ("registered") ) {

      self.message = "";
      SUB_UseTargets ();
      remove (self);
   } else {

      if ( (self.message != "") ) {

         centerprint (other, self.message);
         sound (other, CHAN_BODY, "misc/comm.wav", 1.00000, ATTN_NORM);

      }

   }
};


void  ()trigger_onlyregistered =  {
   precache_sound ("misc/comm.wav");
   InitTrigger ();
   self.touch = trigger_onlyregistered_touch;
};


void  ()hurt_on =  {
   self.solid = SOLID_TRIGGER;
   self.nextthink = -1.00000;
};


void  ()hurt_touch =  {
   if ( other.takedamage ) {

      self.solid = SOLID_NOT;
      T_Damage (other, self, self, self.dmg);
      self.think = hurt_on;
      self.nextthink = (time + 1.00000);

   }
   return ;
};


void  ()trigger_hurt =  {
   InitTrigger ();
   self.touch = hurt_touch;
   if ( !self.dmg ) {

      self.dmg = 1000.00000;

   }
};


void  ()trigger_wind_touch =  {
   if ( (other.fly_sound < time) ) {

      other.fly_sound = (time + 1.50000);
      sound (other, CHAN_AUTO, "ambience/windfly.wav", 1.00000, ATTN_NORM);

   }
   if ( (other.movetype != MOVETYPE_NONE) ) {

      other.velocity = (other.velocity + (self.speed * self.movedir));

   }
};


void  ()trigger_wind_gust =  {
   if ( (self.cnt < 0.00000) ) {

      if ( (self.speed < self.armortype) ) {

         self.cnt = (0.05000 * self.count);
         self.armortype = ((self.count * 1.40000) + (self.count * (random () - 0.50000)));

      }
   } else {

      if ( (self.speed > self.armortype) ) {

         self.cnt = (-0.05000 * self.count);
         self.armortype = ((self.count * 0.60000) + (self.count * (random () - 0.50000)));

      }

   }
   self.speed = (self.speed + self.cnt);
   self.nextthink = (time + 0.10000);
};


void  ()trigger_wind =  {
   InitTrigger ();
   precache_sound ("ambience/windfly.wav");
   self.touch = trigger_wind_touch;
   if ( self.spawnflags ) {

      if ( !self.speed ) {

         self.count = 35.00000;
         self.speed = 35.00000;
      } else {

         self.count = self.speed;

      }
      self.armortype = (self.count * 0.60000);
      self.cnt = (-0.05000 * self.count);
      self.nextthink = (time + 0.10000);
      self.think = trigger_wind_gust;
   } else {

      if ( !self.speed ) {

         self.speed = 35.00000;

      }

   }
};

float PUSH_ONCE   =  1.00000;

void  ()trigger_push_touch =  {
   if ( (other.classname == "grenade") ) {

      other.velocity = ((self.speed * self.movedir) * 10.00000);
   } else {

      if ( (other.health > 0.00000) ) {

         other.velocity = ((self.speed * self.movedir) * 10.00000);
         if ( (other.classname == "player") ) {

            if ( (other.fly_sound < time) ) {

               other.fly_sound = (time + 1.50000);
               sound (other, CHAN_AUTO, "ambience/windfly.wav", 1.00000, ATTN_NORM);

            }

         }

      }

   }
   if ( (self.spawnflags & PUSH_ONCE) ) {

      remove (self);

   }
};


void  ()trigger_push =  {
   InitTrigger ();
   precache_sound ("ambience/windfly.wav");
   self.touch = trigger_push_touch;
   if ( !self.speed ) {

      self.speed = 1000.00000;

   }
};


void  ()trigger_monsterjump_touch =  {
   if ( ((other.flags & ((FL_MONSTER | FL_FLY) | FL_SWIM)) != FL_MONSTER) ) {

      return ;

   }
   other.velocity_x = (self.movedir_x * self.speed);
   other.velocity_y = (self.movedir_y * self.speed);
   if ( !(other.flags & FL_ONGROUND) ) {

      return ;

   }
   other.flags = (other.flags - FL_ONGROUND);
   other.velocity_z = self.height;
};


void  ()trigger_monsterjump =  {
   if ( !self.speed ) {

      self.speed = 200.00000;

   }
   if ( !self.height ) {

      self.height = 200.00000;

   }
   if ( (self.angles == '0.00000 0.00000 0.00000') ) {

      self.angles = '0.00000 360.00000 0.00000';

   }
   InitTrigger ();
   self.touch = trigger_monsterjump_touch;
};


void  ()trigger_magicfield_touch =  {
   if ( (other.classname == "grenade") ) {

      other.velocity = ((self.speed * self.movedir) * 10.00000);
   } else {

      if ( (other.health > 0.00000) ) {

         if ( (other.artifact_active & ART_TOMEOFPOWER) ) {

            return ;
         } else {

            other.velocity = ((self.speed * self.movedir) * 10.00000);

         }
         if ( (other.classname == "player") ) {

            makevectors (other.angles);
            SpawnPuff ((other.origin + (((v_forward * 16.00000) * random ()) * 10.00000)), '0.00000 0.00000 -10.00000', 101.00000, other);
            SpawnPuff ((other.origin + (((v_forward * 16.00000) * random ()) * 10.00000)), '5.00000 5.00000 0.00000', 101.00000, other);
            SpawnPuff ((other.origin + (((v_forward * 16.00000) * random ()) * 10.00000)), '0.00000 0.00000 10.00000', 101.00000, other);
            centerprint (other, "You must have the Tome of Power\n");

         }

      }

   }
   if ( (self.spawnflags & PUSH_ONCE) ) {

      remove (self);

   }
};


void  ()trigger_magicfield =  {
   InitTrigger ();
   self.touch = trigger_magicfield_touch;
   if ( !self.speed ) {

      self.speed = 100.00000;

   }
};


void  ()trigger_crosslevel_use =  {
   if ( (self.spawnflags & 1.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_1);

   }
   if ( (self.spawnflags & 2.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_2);

   }
   if ( (self.spawnflags & 4.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_3);

   }
   if ( (self.spawnflags & 8.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_4);

   }
   if ( (self.spawnflags & 16.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_5);

   }
   if ( (self.spawnflags & 32.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_6);

   }
   if ( (self.spawnflags & 64.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_7);

   }
   if ( (self.spawnflags & 128.00000) ) {

      serverflags = (serverflags | SFL_CROSS_TRIGGER_8);

   }
   SUB_UseTargets ();
   self.solid = SOLID_NOT;
};


void  ()trigger_crosslevel_touch =  {
   if ( (other.classname != "player") ) {

      return ;

   }
   activator = other;
   trigger_crosslevel_use ();
};


void  ()trigger_crosslevel =  {
   if ( (((((((((self.spawnflags & 1.00000) && (serverflags & SFL_CROSS_TRIGGER_1)) || ((self.spawnflags & 2.00000) && (serverflags & SFL_CROSS_TRIGGER_2))) || ((self.spawnflags & 4.00000) && (serverflags & SFL_CROSS_TRIGGER_3))) || ((self.spawnflags & 8.00000) && (serverflags & SFL_CROSS_TRIGGER_4))) || ((self.spawnflags & 16.00000) && (serverflags & SFL_CROSS_TRIGGER_5))) || ((self.spawnflags & 32.00000) && (serverflags & SFL_CROSS_TRIGGER_6))) || ((self.spawnflags & 64.00000) && (serverflags & SFL_CROSS_TRIGGER_7))) || ((self.spawnflags & 128.00000) && (serverflags & SFL_CROSS_TRIGGER_8))) ) {

      self.solid = SOLID_NOT;
      self.flags = (self.flags + FL_ARCHIVE_OVERRIDE);
      return ;

   }
   InitTrigger ();
   self.touch = trigger_crosslevel_touch;
   self.use = trigger_crosslevel_use;
};


void  ()trigger_crosslevel_target_think =  {
   if ( (((((((((self.spawnflags & 1.00000) && (serverflags & SFL_CROSS_TRIGGER_1)) || ((self.spawnflags & 2.00000) && (serverflags & SFL_CROSS_TRIGGER_2))) || ((self.spawnflags & 4.00000) && (serverflags & SFL_CROSS_TRIGGER_3))) || ((self.spawnflags & 8.00000) && (serverflags & SFL_CROSS_TRIGGER_4))) || ((self.spawnflags & 16.00000) && (serverflags & SFL_CROSS_TRIGGER_5))) || ((self.spawnflags & 32.00000) && (serverflags & SFL_CROSS_TRIGGER_6))) || ((self.spawnflags & 64.00000) && (serverflags & SFL_CROSS_TRIGGER_7))) || ((self.spawnflags & 128.00000) && (serverflags & SFL_CROSS_TRIGGER_8))) ) {

      activator = world;
      SUB_UseTargets ();

   }
};


void  ()trigger_crosslevel_target =  {
   self.think = trigger_crosslevel_target_think;
   self.nextthink = (time + 0.50000);
   self.solid = SOLID_NOT;
   self.flags = (self.flags + FL_ARCHIVE_OVERRIDE);
};


void  ()trigger_deathtouch_touch =  {
   if ( (other.targetname != self.target) ) {

      return ;

   }
   other.targetname = "";
   if ( self.th_die ) {

      other.think = self.th_die;
   } else {

      if ( other.th_die ) {

         other.think = other.th_die;
      } else {

         if ( other.health ) {

            other.think = chunk_death;
         } else {

            other.think = SUB_Remove;

         }

      }

   }
   other.nextthink = (time + 0.05000);
};


void  ()trigger_deathtouch =  {
   InitTrigger ();
   self.touch = trigger_deathtouch_touch;
};


void  ()puzzle_touch =  {
local float amount = 0.00000;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (other.health <= 0.00000) ) {

      return ;

   }
   amount = random ();
   if ( (amount < 0.50000) ) {

      sprint (other, STR_YOUPOSSESS);
      sprint (other, self.netname);
   } else {

      sprint (other, STR_THE);
      sprint (other, self.netname);
      sprint (other, STR_ISYOURS);

   }
   sprint (other, "\n");
   if ( !other.puzzle_inv_1 ) {

      other.puzzle_inv_1 = self.puzzle_id;
   } else {

      if ( !other.puzzle_inv_2 ) {

         other.puzzle_inv_2 = self.puzzle_id;
      } else {

         if ( !other.puzzle_inv_3 ) {

            other.puzzle_inv_3 = self.puzzle_id;
         } else {

            if ( !other.puzzle_inv_4 ) {

               other.puzzle_inv_4 = self.puzzle_id;
            } else {

               if ( !other.puzzle_inv_5 ) {

                  other.puzzle_inv_5 = self.puzzle_id;
               } else {

                  if ( !other.puzzle_inv_6 ) {

                     other.puzzle_inv_6 = self.puzzle_id;
                  } else {

                     if ( !other.puzzle_inv_7 ) {

                        other.puzzle_inv_7 = self.puzzle_id;
                     } else {

                        if ( other.puzzle_inv_8 ) {

                           other.puzzle_inv_8 = self.puzzle_id;
                        } else {

                           dprint ("No room for puzzle piece!\n");

                        }

                     }

                  }

               }

            }

         }

      }

   }
   sound (other, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   self.model = string_null;
   activator = other;
   SUB_UseTargets ();
};


void  ()puzzle_use =  {
   self.effects -= EF_NODRAW;
   self.solid = SOLID_TRIGGER;
   self.use = SUB_Null;
   self.touch = puzzle_touch;
   setorigin (self, self.origin);
   StartItem ();
};


void  ()puzzle_piece =  {
   precache_sound ("items/artpkup.wav");
   setpuzzlemodel (self, self.puzzle_id);
   self.noise = "items/artpkup.wav";
   setsize (self, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 16.00000');
   if ( (self.spawnflags & 1.00000) ) {

      self.spawnflags -= 1.00000;
      self.solid = SOLID_NOT;
      self.effects = (self.effects | EF_NODRAW);
      self.use = puzzle_use;
   } else {

      self.touch = puzzle_touch;
      self.think = StartItem;
      self.nextthink = time;

   }
   if ( (self.spawnflags & 2.00000) ) {

      self.spawnflags = 1.00000;

   }
};


void  ()puzzle_static_use =  {
   setpuzzlemodel (self, self.puzzle_id);
   SUB_UseTargets ();
};


void  ()puzzle_static_piece =  {
   setmodel (self, self.model);
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   setsize (self, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   self.use = puzzle_static_use;
};


void  ()reset_mangle =  {
   SUB_CalcAngleMove (self.mangle, 10.00000, SUB_Null);
};


void  ()control_return =  {
   if ( (self.goalentity.classname != "catapult") ) {

      self.goalentity.oldthink = SUB_Null;
      self.goalentity.think = reset_mangle;
      self.goalentity.nextthink = time;

   }
   if ( self.aflag ) {

      self.enemy.oldweapon = 0.00000;
      self.enemy.th_weapon = W_SetCurrentAmmo;
      self.aflag = 0.00000;
      self.enemy = world;

   }
};

void  ()catapult_ready;

void  ()control_touch =  {
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local float fire_range = 0.00000;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( ((self.goalentity.health <= 0.00000) && self.goalentity.takedamage) ) {

      self.think = SUB_Remove;
      self.nextthink = time;
      return ;

   }
   other.attack_finished = (time + 0.10000);
   if (other.weaponmodel != "models/xhair.mdl") ;
   {
       other.weaponmodel = "models/xhair.mdl";
       other.weaponframe = 0.00000;
       other.th_weapon = SUB_Null;
       self.aflag = 1.00000;
   }
   if ( (self.enemy != other) ) {

      centerprint (other, "You're in control!\n");

   }
   self.enemy = other;
   self.goalentity.enemy = self;
   makevectors (self.enemy.v_angle);
   if ( (self.goalentity.classname == "catapult") ) {

      if ( ((self.enemy.angles_y < (self.goalentity.angles_y + 5.00000)) && (self.enemy.angles_y > (self.goalentity.angles_y - 5.00000))) ) {

         self.goalentity.angles_y = self.enemy.angles_y;

      }
      if ( (self.goalentity.think == catapult_ready) ) {

         if ( self.enemy.button0 ) {

            self.goalentity.think = self.goalentity.th_weapon;
            self.goalentity.nextthink = time;

         }

      }
   } else {

      org = (self.enemy.origin + self.enemy.proj_ofs);
      dir = normalize (v_forward);
      traceline (org, (org + (dir * 10000.00000)), FALSE, self.enemy);
      org = (self.goalentity.origin + self.goalentity.proj_ofs);
      fire_range = vlen ((org - trace_endpos));
      if ( (fire_range > 256.00000) ) {

         dir = normalize ((trace_endpos - org));
         if ( (trace_ent.health && (trace_ent.origin != '0.00000 0.00000 0.00000')) ) {

            self.goalentity.goalentity = trace_ent;
         } else {

            self.goalentity.goalentity = world;

         }
         self.goalentity.view_ofs = trace_endpos;
         dir = vectoangles (dir);
         self.goalentity.angles = dir;
         self.goalentity.angles_z = (dir_z / 10.00000);
         if ( (self.goalentity.think != self.goalentity.th_weapon) ) {

            if ( (self.enemy.button0 && (self.goalentity.th_weapon != SUB_Null)) ) {

               self.goalentity.think = self.goalentity.th_weapon;
               self.goalentity.nextthink = time;

            }

         }

      }

   }
   self.think = control_return;
   self.nextthink = (time + 0.10000);
};


void  ()trigger_control_find_target =  {
   if ( !self.target ) {

      objerror ("Nothing to control!\n");

   }
   self.goalentity = find (world, targetname, self.target);
   if ( !self.goalentity ) {

      objerror ("Could not find target\n");
   } else {

      if ( ((self.goalentity.classname == "catapult") || (self.goalentity.classname == "obj_catapult2")) ) {

         self.goalentity.movechain = self;
         self.flags += FL_MOVECHAIN_ANGLE;
         self.movetype = MOVETYPE_NOCLIP;
      } else {

         self.goalentity.mangle = self.goalentity.angles;

      }

   }
};


void  ()trigger_control =  {
   self.touch = control_touch;
   self.ltime = time;
   InitTrigger ();
   self.think = trigger_control_find_target;
   self.nextthink = (time + 1.00000);
};


void  ()trigger_no_fric_touch =  {
   if ( (other.flags & FL_ONGROUND) ) {

      other.flags -= FL_ONGROUND;

   }
};


void  ()trigger_no_friction =  {
   InitTrigger ();
   self.touch = trigger_no_fric_touch;
};


void  ()trigger_attack_touch =  {
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( ((other.last_attack + 0.30000) >= time) ) {

      SUB_UseTargets ();
      remove (self);

   }
};


void  ()trigger_attack =  {
   InitTrigger ();
   self.touch = trigger_attack_touch;
};

