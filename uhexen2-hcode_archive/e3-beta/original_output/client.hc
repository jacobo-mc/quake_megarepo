float modelindex_eyes   =  0.00000;
float modelindex_assassin   =  0.00000;
float modelindex_crusader   =  0.00000;
float modelindex_paladin   =  0.00000;
float modelindex_necromancer   =  0.00000;
float intermission_running   =  0.00000;
float intermission_exittime   =  0.00000;

void  ()info_intermission =  {
};


void  ()SetChangeParms =  {
   if ( (self.health <= 0.00000) ) {

      SetNewParms ();
      return ;

   }
};


void  ()SetNewParms =  {
};


void  ()DecodeLevelParms =  {
   if ( serverflags ) {

      if ( (world.model == "maps/start.bsp") ) {

         SetNewParms ();

      }

   }
   self.items = parm1;
};


entity  ()FindIntermission =  {
local entity spot;
local float cyc = 0.00000;
   spot = find (world, classname, "info_intermission");
   if ( spot ) {

      cyc = (random () * 4.00000);
      while ( (cyc > 1.00000) ) {

         spot = find (spot, classname, "info_intermission");
         if ( !spot ) {

            spot = find (spot, classname, "info_intermission");

         }
         cyc = (cyc - 1.00000);

      }
      return ( spot );

   }
   spot = find (world, classname, "info_player_start");
   if ( spot ) {

      return ( spot );

   }
   spot = find (world, classname, "testplayerstart");
   if ( spot ) {

      return ( spot );

   }
   objerror ("FindIntermission: no spot");
};

string nextmap   =  "";
string nextstartspot   =  "";

void  ()GotoNextMap =  {
   if ( cvar ("samelevel") ) {

      changelevel (mapname, startspot);
   } else {

      changelevel (nextmap, nextstartspot);

   }
};


void  ()ExitIntermission =  {
   if ( deathmatch ) {

      GotoNextMap ();
      return ;

   }
   intermission_exittime = (time + 1.00000);
   intermission_running = (intermission_running + 1.00000);
   if ( (intermission_running == 2.00000) ) {

      if ( (world.model == "maps/e1m7.bsp") ) {

         WriteByte (MSG_ALL, SVC_CDTRACK);
         WriteByte (MSG_ALL, 2.00000);
         WriteByte (MSG_ALL, 3.00000);
         if ( !cvar ("registered") ) {

            WriteByte (MSG_ALL, SVC_FINALE);
            WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back int...");
         } else {

            WriteByte (MSG_ALL, SVC_FINALE);
            WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back int...");

         }
         return ;
      } else {

         if ( (world.model == "maps/e2m6.bsp") ) {

            WriteByte (MSG_ALL, SVC_CDTRACK);
            WriteByte (MSG_ALL, 2.00000);
            WriteByte (MSG_ALL, 3.00000);
            WriteByte (MSG_ALL, SVC_FINALE);
            WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whis...");
            return ;
         } else {

            if ( (world.model == "maps/e3m6.bsp") ) {

               WriteByte (MSG_ALL, SVC_CDTRACK);
               WriteByte (MSG_ALL, 2.00000);
               WriteByte (MSG_ALL, 3.00000);
               WriteByte (MSG_ALL, SVC_FINALE);
               WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as...");
               return ;
            } else {

               if ( (world.model == "maps/e4m7.bsp") ) {

                  WriteByte (MSG_ALL, SVC_CDTRACK);
                  WriteByte (MSG_ALL, 2.00000);
                  WriteByte (MSG_ALL, 3.00000);
                  WriteByte (MSG_ALL, SVC_FINALE);
                  WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achiev...");
                  return ;

               }

            }

         }

      }
      GotoNextMap ();

   }
   if ( (intermission_running == 3.00000) ) {

      if ( !cvar ("registered") ) {

         WriteByte (MSG_ALL, SVC_SELLSCREEN);
         return ;

      }
      if ( ((serverflags & (((SFL_EPISODE_1 + SFL_EPISODE_2) + SFL_EPISODE_3) + SFL_EPISODE_4)) == (((SFL_EPISODE_1 + SFL_EPISODE_2) + SFL_EPISODE_3) + SFL_EPISODE_4)) ) {

         WriteByte (MSG_ALL, SVC_FINALE);
         WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisibl...");
         return ;

      }

   }
   GotoNextMap ();
};


void  ()IntermissionThink =  {
   if ( (time < intermission_exittime) ) {

      return ;

   }
   if ( ((!self.button0 && !self.button1) && !self.button2) ) {

      return ;

   }
   ExitIntermission ();
};


void  ()execute_changelevel =  {
local entity pos;
   intermission_running = 1.00000;
   if ( deathmatch ) {

      intermission_exittime = (time + 5.00000);
   } else {

      intermission_exittime = (time + 2.00000);

   }
   WriteByte (MSG_ALL, SVC_CDTRACK);
   WriteByte (MSG_ALL, 3.00000);
   WriteByte (MSG_ALL, 3.00000);
   pos = FindIntermission ();
   other = find (world, classname, "player");
   while ( (other != world) ) {

      if ( (other.flags2 & FL_CAMERA_VIEW) ) {

         other.flags2 -= FL_CAMERA_VIEW;

      }
      other.view_ofs = '0.00000 0.00000 0.00000';
      other.v_angle = pos.mangle;
      other.angles = pos.mangle;
      other.fixangle = TRUE;
      other.nextthink = (time + 0.50000);
      other.takedamage = DAMAGE_NO;
      other.solid = SOLID_NOT;
      other.movetype = MOVETYPE_NONE;
      other.flags = (other.flags | FL_NOTARGET);
      other.modelindex = 0.00000;
      setorigin (other, pos.origin);
      other = find (other, classname, "player");

   }
   WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void  ()changelevel_touch =  {
local entity pos;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( ((cvar ("noexit") == 1.00000) || ((cvar ("noexit") == 2.00000) && (mapname != "start"))) ) {

      T_Damage (other, self, self, 50000.00000);
      return ;

   }
   if ( (coop || deathmatch) ) {

      bprint (other.netname);
      bprint (" exited the level\n");

   }
   nextmap = self.map;
   nextstartspot = self.target;
   SUB_UseTargets ();
   if ( (self.spawnflags & 2.00000) ) {

      serverflags = (serverflags | SFL_NEW_UNIT);
      serverflags = (serverflags - (serverflags & SFL_CROSS_TRIGGERS));
   } else {

      serverflags = (serverflags - (serverflags & SFL_NEW_UNIT));

   }
   if ( (self.spawnflags & 4.00000) ) {

      serverflags = (serverflags | SFL_NEW_EPISODE);
      serverflags = (serverflags - (serverflags & SFL_CROSS_TRIGGERS));
   } else {

      serverflags = (serverflags - (serverflags & SFL_NEW_EPISODE));

   }
   if ( (deathmatch == 0.00000) ) {

      GotoNextMap ();
      return ;

   }
   self.touch = SUB_Null;
   self.think = execute_changelevel;
   self.nextthink = (time + 0.10000);
};


void  ()changelevel_use =  {
local entity saveOther;
   saveOther = other;
   other = activator;
   changelevel_touch ();
   other = saveOther;
};


void  ()trigger_changelevel =  {
   if ( !self.map ) {

      objerror ("changelevel trigger doesn't have map");

   }
   InitTrigger ();
   self.touch = changelevel_touch;
   self.use = changelevel_use;
};


void  ()respawn =  {
   if ( coop ) {

      if ( (self.flags2 & FL_CAMERA_VIEW) ) {

         MakeCamera ();

      }
      SolidPlayer ();
      setspawnparms (self);
      PutClientInServer ();
   } else {

      if ( deathmatch ) {

         if ( (self.flags2 & FL_CAMERA_VIEW) ) {

            MakeCamera ();

         }
         SolidPlayer ();
         SetNewParms ();
         PutClientInServer ();
      } else {

         localcmd ("restart\n");

      }

   }
};


void  ()ClientKill =  {
   bprint (self.netname);
   bprint (" suicides\n");
   set_suicide_frame ();
   self.modelindex = self.init_modelindex;
   self.frags = (self.frags - 2.00000);
   respawn ();
};


float  (vector v)CheckSpawnPoint =  {
   return ( FALSE );
};


entity  ()SelectSpawnPoint =  {
local entity spot;
local entity thing;
local float pcount = 0.00000;
   spot = find (world, classname, "testplayerstart");
   if ( spot ) {

      return ( spot );

   }
   if ( coop ) {

      lastspawn = find (lastspawn, classname, "info_player_coop");
      if ( (lastspawn == world) ) {

         lastspawn = find (lastspawn, classname, "info_player_start");

      }
      if ( (lastspawn != world) ) {

         return ( lastspawn );

      }
   } else {

      if ( deathmatch ) {

         spot = lastspawn;
         while ( 1.00000 ) {

            spot = find (spot, classname, "info_player_deathmatch");
            if ( (spot != world) ) {

               if ( (spot == lastspawn) ) {

                  return ( lastspawn );

               }
               pcount = 0.00000;
               thing = findradius (spot.origin, 64.00000);
               while ( thing ) {

                  if ( (thing.classname == "player") ) {

                     pcount = (pcount + 1.00000);

                  }
                  thing = thing.chain;

               }
               if ( (pcount == 0.00000) ) {

                  lastspawn = spot;
                  return ( spot );

               }

            }

         }

      }

   }
   if ( startspot ) {

      spot = world;
      pcount = 1.00000;
      while ( pcount ) {

         spot = find (spot, classname, "info_player_start");
         if ( !spot ) {

            pcount = 0.00000;
         } else {

            if ( (spot.targetname == startspot) ) {

               pcount = 0.00000;

            }

         }

      }

   }
   if ( !spot ) {

      spot = find (world, classname, "info_player_start");
      if ( !spot ) {

         error ("PutClientInServer: no info_player_start on level");

      }

   }
   return ( spot );
};

void  ()SetModelAndThinks;

void  ()PutClientInServer =  {
local entity spot;
   spot = SelectSpawnPoint ();
   self.classname = "player";
   self.takedamage = DAMAGE_YES;
   self.solid = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_WALK;
   self.show_hostile = 0.00000;
   self.scale = 1.00000;
   self.skin = 0.00000;
   self.drawflags = 0.00000;
   self.onfire = 0.00000;
   self.flags = FL_CLIENT;
   self.flags2 = FL_ALIVE;
   self.air_finished = (time + 12.00000);
   self.dmg = 2.00000;
   self.invisible_finished = 0.00000;
   self.invincible_finished = 0.00000;
   self.effects = 0.00000;
   self.invincible_time = 0.00000;
   self.thingtype = THINGTYPE_FLESH;
   self.adjust_velocity = '-999.00000 -999.00000 -999.00000';
   self.splash_time = 0.00000;
   if ( !self.stats_restored ) {

      if ( (self.playerclass == CLASS_NONE) ) {

         setclass (self, CLASS_PALADIN);

      }
      stats_NewPlayer (self);
      self.health = self.max_health;
   } else {

      self.stats_restored = FALSE;

   }
   self.plaqueflg = 0.00000;
   DecodeLevelParms ();
   W_SetCurrentAmmo ();
   self.attack_finished = time;
   self.deadflag = DEAD_NO;
   self.pausetime = 0.00000;
   self.origin = (spot.origin + '0.00000 0.00000 1.00000');
   self.angles = spot.angles;
   self.fixangle = TRUE;
   setmodel (self, "models/eyes.mdl");
   modelindex_eyes = self.modelindex;
   if ( !self.weapon ) {

      self.items = IT_WEAPON1;
      self.weapon = IT_WEAPON1;
      self.oldweapon = IT_WEAPON1;

   }
   SetModelAndThinks ();
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
   self.view_ofs = '0.00000 0.00000 50.00000';
   self.proj_ofs = '0.00000 0.00000 44.00000';
   self.hull = HULL_NORMAL;
   self.th_stand ();
   if ( (deathmatch || coop) ) {

      makevectors (self.angles);
      spawn_tfog ((self.origin + (v_forward * 20.00000)));

   }
   spawn_tdeath (self.origin, self);
   comamode = FALSE;
};


void  ()info_player_start =  {
};


void  ()info_player_start2 =  {
};


void  ()testplayerstart =  {
};


void  ()info_player_deathmatch =  {
   if ( !deathmatch ) {

      remove (self);

   }
};


void  ()info_player_coop =  {
};


void  ()NextLevel =  {
local entity o;
   if ( (mapname == "start") ) {

      if ( !cvar ("registered") ) {

         mapname = "e1m1";
      } else {

         if ( !(serverflags & 1.00000) ) {

            mapname = "e1m1";
            serverflags = (serverflags | 1.00000);
         } else {

            if ( !(serverflags & 2.00000) ) {

               mapname = "e2m1";
               serverflags = (serverflags | 2.00000);
            } else {

               if ( !(serverflags & 4.00000) ) {

                  mapname = "e3m1";
                  serverflags = (serverflags | 4.00000);
               } else {

                  if ( !(serverflags & 8.00000) ) {

                     mapname = "e4m1";
                     serverflags = (serverflags - 7.00000);

                  }

               }

            }

         }

      }
      o = spawn ();
      o.map = mapname;
   } else {

      o = find (world, classname, "trigger_changelevel");
      if ( !o ) {

         mapname = "start";
         o = spawn ();
         o.map = mapname;

      }

   }
   nextmap = o.map;
   gameover = TRUE;
   if ( (o.nextthink < time) ) {

      o.think = execute_changelevel;
      o.nextthink = (time + 0.10000);

   }
};


void  ()CheckRules =  {
local float timelimit = 0.00000;
local float fraglimit = 0.00000;
   if ( gameover ) {

      return ;

   }
   timelimit = (cvar ("timelimit") * 60.00000);
   fraglimit = cvar ("fraglimit");
   if ( (timelimit && (time >= timelimit)) ) {

      NextLevel ();
      return ;

   }
   if ( (fraglimit && (self.frags >= fraglimit)) ) {

      NextLevel ();
      return ;

   }
};


void  ()PlayerDeathThink =  {
local entity old_self;
local float forward = 0.00000;
   if ( (self.flags & FL_ONGROUND) ) {

      forward = vlen (self.velocity);
      forward = (forward - 20.00000);
      if ( (forward <= 0.00000) ) {

         self.velocity = '0.00000 0.00000 0.00000';
      } else {

         self.velocity = (forward * normalize (self.velocity));

      }

   }
   if ( (self.deadflag == DEAD_DEAD) ) {

      if ( ((self.button2 || self.button1) || self.button0) ) {

         return ;

      }
      self.deadflag = DEAD_RESPAWNABLE;
      return ;

   }
   if ( ((!self.button2 && !self.button1) && !self.button0) ) {

      return ;

   }
   self.button0 = 0.00000;
   self.button1 = 0.00000;
   self.button2 = 0.00000;
   respawn ();
};


void  ()CheckCliffHold =  {
local vector start = '0.00000 0.00000 0.00000';
local vector end = '0.00000 0.00000 0.00000';
local float liftspeed = 0.00000;
   makevectors (self.angles);
   start = self.origin;
   v_forward_z = 0.00000;
   normalize (v_forward);
   end = (start + (v_forward * 24.00000));
   tracearea (start, end, self.mins, self.maxs, TRUE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   start_z = self.absmax_z;
   end = (start + ('0.00000 0.00000 8.00000' * self.scale));
   tracearea (start, end, self.mins, self.maxs, FALSE, self);
   if ( (trace_fraction < 1.00000) ) {

      return ;

   }
   start = end;
   end = (start + (v_forward * 24.00000));
   tracearea (start, end, self.mins, self.maxs, TRUE, self);
   if ( (trace_fraction < 1.00000) ) {

      return ;

   }
   liftspeed = (self.strength / self.mass);
   self.velocity_z += (7.00000 * liftspeed);
   if ( (self.velocity_z < (37.00000 * liftspeed)) ) {

      self.velocity_z = (37.00000 * liftspeed);
   } else {

      if ( (self.velocity_z >= (177.00000 * liftspeed)) ) {

         self.velocity_z = (177.00000 * liftspeed);

      }

   }
};


void  ()CheckWaterJump =  {
local vector start = '0.00000 0.00000 0.00000';
local vector end = '0.00000 0.00000 0.00000';
   makevectors (self.angles);
   start = ((self.origin + self.proj_ofs) - '0.00000 0.00000 8.00000');
   v_forward_z = 0.00000;
   normalize (v_forward);
   end = (start + (v_forward * 24.00000));
   traceline (start, end, TRUE, self);
   if ( (trace_fraction < 1.00000) ) {

      start_z = (self.origin_z + self.view_ofs_z);
      end = (start + (v_forward * 24.00000));
      self.movedir = (trace_plane_normal * -50.00000);
      traceline (start, end, TRUE, self);
      if ( (trace_fraction == 1.00000) ) {

         self.flags = (self.flags | FL_WATERJUMP);
         self.velocity_z = 225.00000;
         self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
         self.teleport_time = (time + 2.00000);
         return ;

      }

   }
};


void  ()PlayerJump =  {
local vector start = '0.00000 0.00000 0.00000';
local vector end = '0.00000 0.00000 0.00000';
   if ( (self.flags & FL_WATERJUMP) ) {

      return ;

   }
   if ( (self.movetype == MOVETYPE_FLY) ) {

      return ;

   }
   if ( (self.waterlevel >= 2.00000) ) {

      if ( (self.watertype == CONTENT_WATER) ) {

         self.velocity_z = (100.00000 * self.scale);
      } else {

         if ( (self.watertype == CONTENT_SLIME) ) {

            self.velocity_z = (80.00000 * self.scale);
         } else {

            self.velocity_z = (50.00000 * self.scale);

         }

      }
      if ( (self.swim_flag < time) ) {

         self.swim_flag = (time + 1.00000);
         if ( (random () < 0.50000) ) {

            sound (self, CHAN_BODY, "player/swim1.wav", 1.00000, ATTN_NORM);
         } else {

            sound (self, CHAN_BODY, "player/swim2.wav", 1.00000, ATTN_NORM);

         }

      }
      return ;

   }
   if ( !(self.flags & FL_ONGROUND) ) {

      if ( ((self.flags2 & FL_LEDGEHOLD) && (self.health >= (self.max_health * 0.75000))) ) {

         CheckCliffHold ();

      }
      return ;

   }
   if ( !(self.flags & FL_JUMPRELEASED) ) {

      return ;

   }
   if ( self.th_jump ) {

      self.th_jump ();

   }
   self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
   self.flags = (self.flags - FL_ONGROUND);
   self.button2 = 0.00000;
   sound (self, CHAN_BODY, "player/paljmp.wav", 1.00000, ATTN_NORM);
   self.velocity_z = (self.velocity_z + (270.00000 * self.scale));
};


void  ()EntryBubblesSpawn =  {
local entity bubble;
local vector offset = '0.00000 0.00000 0.00000';
local float test = 0.00000;
   offset_x = (random () * 10.00000);
   offset_y = (random () * 10.00000);
   if ( (self.owner.waterlevel < 3.00000) ) {

      remove (self);
      return ;

   }
   bubble = spawn ();
   setmodel (bubble, "models/s_bubble.spr");
   setorigin (bubble, (self.owner.origin - ('0.00000 0.00000 16.00000' + offset)));
   bubble.movetype = MOVETYPE_NOCLIP;
   bubble.solid = SOLID_NOT;
   bubble.velocity = '0.00000 0.00000 20.00000';
   bubble.nextthink = (time + 0.50000);
   bubble.think = bubble_bob;
   bubble.classname = "bubble";
   bubble.frame = 0.00000;
   bubble.cnt = 0.00000;
   setsize (bubble, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
   self.nextthink = (time + 0.10000);
   self.think = DeathBubblesSpawn;
   self.air_finished = (self.air_finished + 1.00000);
   if ( (self.air_finished >= self.bubble_count) ) {

      remove (self);

   }
};


void  ()EntryBubbles =  {
local entity bubble_spawner;
   bubble_spawner = spawn ();
   setorigin (bubble_spawner, self.origin);
   bubble_spawner.movetype = MOVETYPE_NONE;
   bubble_spawner.solid = SOLID_NOT;
   bubble_spawner.nextthink = (time + 0.10000);
   bubble_spawner.think = EntryBubblesSpawn;
   bubble_spawner.air_finished = 0.00000;
   bubble_spawner.owner = self;
   bubble_spawner.bubble_count = (10.00000 + (random () * 10.00000));
   return ;
};

.float dmgtime;

void  ()WaterMove =  {
local string text;
   if ( (self.movetype == MOVETYPE_NOCLIP) ) {

      return ;

   }
   if ( (self.health < 0.00000) ) {

      return ;

   }
   if ( ((((self.flags & FL_INWATER) && (self.watertype == CONTENT_WATER)) && (self.waterlevel == 3.00000)) && !self.lefty) ) {

      EntryBubbles ();
      self.lefty = 1.00000;

   }
   if ( ((self.rings & RING_WATER) && ((self.air_finished - 10.00000) < time)) ) {

      self.rings_low = (self.rings_low | RING_WATER);

   }
   if ( ((self.flags & FL_INWATER) && (self.splash_time < time)) ) {

      if ( ((self.velocity_x || self.velocity_y) || self.velocity_z) ) {

         if ( (self.waterlevel == 1.00000) ) {

            CreateWaterSplash ((self.origin + '0.00000 0.00000 10.00000'));
         } else {

            if ( (self.waterlevel == 2.00000) ) {

               CreateWaterSplash ((self.origin + '0.00000 0.00000 20.00000'));

            }

         }

      }
      self.splash_time = ((time + HX_FRAME_TIME) + (random () * 0.05000));

   }
   if ( (self.waterlevel != 3.00000) ) {

      if ( (self.air_finished < time) ) {

         sound (self, CHAN_VOICE, "player/palgasp1.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.air_finished < (time + 9.00000)) ) {

            sound (self, CHAN_VOICE, "player/palgasp2.wav", 1.00000, ATTN_NORM);

         }

      }
      self.air_finished = (time + 12.00000);
      self.dmg = 2.00000;
   } else {

      if ( (self.air_finished < time) ) {

         if ( (self.rings & RING_WATER) ) {

            self.rings_active = (self.rings_active - (self.rings_active & RING_WATER));
            self.rings = (self.rings - (self.rings & RING_WATER));
            self.air_finished = (time + 12.00000);
         } else {

            if ( (self.pain_finished < time) ) {

               self.dmg = (self.dmg + 2.00000);
               if ( (self.dmg > 15.00000) ) {

                  self.dmg = 10.00000;

               }
               T_Damage (self, world, world, self.dmg);
               self.pain_finished = (time + 1.00000);

            }

         }

      }

   }
   if ( !self.waterlevel ) {

      if ( (self.flags & FL_INWATER) ) {

         sound (self, CHAN_BODY, "raven/outwater.wav", 1.00000, ATTN_NORM);
         self.flags = (self.flags - FL_INWATER);
         self.lefty = 0.00000;
         if ( (self.rings & RING_WATER) ) {

            self.rings_active = (self.rings_active - (self.rings_active & RING_WATER));
            self.water_time = (self.water_time - (time - self.water_start));

         }

      }
      return ;

   }
   if ( (self.watertype == CONTENT_LAVA) ) {

      if ( (self.dmgtime < time) ) {

         self.dmgtime = (time + 0.50000);
         if ( (other.flags & FL_FIREHEAL) ) {

            other.health = (other.health + (5.00000 * self.waterlevel));
         } else {

            if ( !(other.flags & FL_FIRERESIST) ) {

               T_Damage (self, world, world, (5.00000 * self.waterlevel));

            }

         }

      }
   } else {

      if ( (self.watertype == CONTENT_SLIME) ) {

         if ( (self.dmgtime < time) ) {

            self.dmgtime = (time + 1.00000);
            T_Damage (self, world, world, (4.00000 * self.waterlevel));

         }

      }

   }
   if ( !(self.flags & FL_INWATER) ) {

      self.splash_time = (time + 0.05000);
      if ( (self.watertype == CONTENT_LAVA) ) {

         sound (self, CHAN_BODY, "raven/inlava.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.watertype == CONTENT_WATER) ) {

            sound (self, CHAN_BODY, "raven/inh2o.wav", 1.00000, ATTN_NORM);
         } else {

            if ( (self.watertype == CONTENT_SLIME) ) {

               sound (self, CHAN_BODY, "player/slimbrn1.wav", 1.00000, ATTN_NORM);

            }

         }

      }
      self.flags = (self.flags + FL_INWATER);
      self.dmgtime = 0.00000;
      if ( ((self.rings & RING_WATER) && (self.watertype == CONTENT_WATER)) ) {

         self.air_finished = (time + self.water_time);
         self.water_start = time;
         self.rings_active = (self.rings_active | RING_WATER);

      }

   }
   if ( !(self.flags & FL_WATERJUMP) ) {

      self.velocity = (self.velocity - (((0.80000 * self.waterlevel) * frametime) * self.velocity));

   }
};


void  ()PlayerPreThink =  {
local float mspeed = 0.00000;
local float aspeed = 0.00000;
local float r = 0.00000;
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
   if ( !(self.flags & FL_INWATER) ) {

      self.aflag = 0.00000;

   }
   if ( intermission_running ) {

      IntermissionThink ();
      return ;

   }
   if ( ((self.view_ofs == '0.00000 0.00000 0.00000') && !(self.flags2 & FL_CAMERA_VIEW)) ) {

      return ;

   }
   if ( (self.adjust_velocity_x != -999.00000) ) {

      self.velocity_x = self.adjust_velocity_x;

   }
   if ( (self.adjust_velocity_y != -999.00000) ) {

      self.velocity_y = self.adjust_velocity_y;

   }
   if ( (self.adjust_velocity_z != -999.00000) ) {

      self.velocity_z = self.adjust_velocity_z;

   }
   self.adjust_velocity = '-999.00000 -999.00000 -999.00000';
   if ( ((self.skin >= 100.00000) && (self.skin < 111.00000)) ) {

      if ( (self.pausetime < time) ) {

         self.skin = self.oldskin;
         if ( self.frozen ) {

            self.frozen = FALSE;
            self.items -= IT_QUAD;

         }
      } else {

         msg_entity = self;
         WriteByte (MSG_ONE, 10.00000);
         WriteAngle (MSG_ONE, self.o_angle_x);
         WriteAngle (MSG_ONE, self.o_angle_y);
         WriteAngle (MSG_ONE, self.o_angle_z);
         if ( (self.flags & FL_ONGROUND) ) {

            self.velocity = '0.00000 0.00000 0.00000';

         }
         self.button0 = 0.00000;
         self.button2 = 0.00000;

      }

   }
   makevectors (self.v_angle);
   self.friction = 0.00000;
   if ( (self.flags & FL_COMAMODE) ) {

      comamode = TRUE;
   } else {

      comamode = FALSE;

   }
   CheckRules ();
   WaterMove ();
   if ( (self.waterlevel == 2.00000) ) {

      CheckWaterJump ();

   }
   if ( (self.deadflag >= DEAD_DEAD) ) {

      PlayerDeathThink ();
      return ;

   }
   if ( self.plaqueflg ) {

      if ( (((self.velocity_x || self.velocity_y) || self.velocity_z) || (self.plaqueangle != self.v_angle)) ) {

         makevectors (self.v_angle);
         spot1 = ((self.origin + self.proj_ofs) + (v_up * 4.00000));
         spot2 = (spot1 + (v_forward * 25.00000));
         traceline (spot1, spot2, FALSE, self);
         if ( !trace_ent ) {

            self.plaqueflg = 0.00000;
            plaque_draw (string_null);
         } else {

            if ( !(trace_ent.classname == "plaque") ) {

               self.plaqueflg = 0.00000;
               plaque_draw (string_null);
            } else {

               self.plaqueangle = self.v_angle;

            }

         }

      }

   }
   if ( ((!self.velocity_x && !self.velocity_y) && !self.velocity_z) ) {

      if ( ((self.camptime + 600.00000) < time) ) {

         if ( (self.playerclass == CLASS_PALADIN) ) {

            if ( (self.weapon == IT_WEAPON1) ) {

               gauntlet_twitch ();
            } else {

               if ( (self.weapon == IT_WEAPON2) ) {

                  vorpal_twitch ();

               }

            }
            self.camptime = ((time + (random () * 420.00000)) + 420.00000);

         }

      }
   } else {

      self.camptime = ((time + (random () * 420.00000)) + 420.00000);

   }
   if ( (self.deadflag == DEAD_DYING) ) {

      return ;

   }
   if ( self.button2 ) {

      PlayerJump ();
   } else {

      self.flags = (self.flags | FL_JUMPRELEASED);

   }
   if ( (time < self.pausetime) ) {

      self.velocity = '0.00000 0.00000 0.00000';

   }
   if ( ((time > self.attack_finished) && (self.weapon != IT_WEAPON1)) ) {

      if ( (((self.weapon == IT_WEAPON3) && (self.greenmana < 1.00000)) || (((self.weapon == IT_WEAPON4) && (self.bluemana < 1.00000)) && (self.greenmana < 1.00000))) ) {

         self.weapon = W_BestWeapon ();
         W_SetCurrentWeapon ();

      }

   }
};


void  ()CheckPowerups =  {
   if ( (self.health <= 0.00000) ) {

      return ;

   }
   if ( (self.artifact_active & ART_HASTE) ) {

      if ( (self.haste_time < time) ) {

         self.artifact_low = (self.artifact_low - (self.artifact_low & ART_HASTE));
         self.artifact_active = (self.artifact_active - (self.artifact_active & ART_HASTE));
         self.hasted = 0.00000;
         self.haste_time = 0.00000;
         self.air_finished = (time + 12.00000);
      } else {

         if ( ((self.haste_time - 10.00000) < time) ) {

            self.artifact_low = (self.artifact_low | ART_HASTE);

         }

      }

   }
   if ( (self.artifact_active & ART_INVINCIBILITY) ) {

      if ( (self.invincible_time < time) ) {

         self.artifact_low = (self.artifact_low - (self.artifact_low & ART_INVINCIBILITY));
         self.artifact_active = (self.artifact_active - (self.artifact_active & ART_INVINCIBILITY));
         self.invincible_time = 0.00000;
         self.air_finished = (time + 12.00000);
      } else {

         if ( ((self.invincible_time - 10.00000) < time) ) {

            self.artifact_low = (self.artifact_low | ART_INVINCIBILITY);

         }

      }

   }
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      if ( ((self.drawflags & MLS_MASKIN) != MLS_POWERMODE) ) {

         self.drawflags = ((self.drawflags & MLS_MASKOUT) | MLS_POWERMODE);

      }
      if ( (self.tome_time < time) ) {

         self.artifact_low = (self.artifact_low - (self.artifact_low & ART_TOMEOFPOWER));
         self.artifact_active = (self.artifact_active - (self.artifact_active & ART_TOMEOFPOWER));
         self.tome_time = 0.00000;
         self.drawflags = ((self.drawflags & MLS_MASKOUT) | 0.00000);
      } else {

         if ( ((self.tome_time - 10.00000) < time) ) {

            self.artifact_low = (self.artifact_low | ART_TOMEOFPOWER);

         }

      }

   }
   if ( self.invisible_finished ) {

      if ( (self.invisible_sound < time) ) {

         sound (self, CHAN_AUTO, "items/inv3.wav", 0.50000, ATTN_IDLE);
         self.invisible_sound = (time + ((random () * 3.00000) + 1.00000));

      }
      if ( (self.invisible_finished < (time + 3.00000)) ) {

         if ( (self.invisible_time == 1.00000) ) {

            sprint (self, "Ring of Shadows magic is fading\n");
            stuffcmd (self, "bf\n");
            sound (self, CHAN_AUTO, "items/inv2.wav", 1.00000, ATTN_NORM);
            self.invisible_time = (time + 1.00000);

         }
         if ( (self.invisible_time < time) ) {

            self.invisible_time = (time + 1.00000);
            stuffcmd (self, "bf\n");

         }

      }
      if ( (self.invisible_finished < time) ) {

         self.items = (self.items - IT_INVISIBILITY);
         self.invisible_finished = 0.00000;
         self.invisible_time = 0.00000;

      }
      self.frame = 0.00000;
      self.modelindex = modelindex_eyes;
   } else {

      self.modelindex = self.init_modelindex;

   }
   if ( ((self.camera_time < time) && self.cameramode) ) {

      CameraReturn ();

   }
};


void  ()PlayerTouch =  {
   if ( ((other.dmg == 666.00000) && ((other.velocity != '0.00000 0.00000 0.00000') || (other.avelocity != '0.00000 0.00000 0.00000'))) ) {

      self.decap = TRUE;
      T_Damage (self, other, other, (self.health + 300.00000));
      return ;

   }
   if ( (((((vlen (self.velocity) * (self.mass / 10.00000)) >= 100.00000) && ((self.last_onground + 0.30000) < time)) || (other.thingtype == THINGTYPE_GLASS)) && ((self.last_impact + 0.10000) <= time)) ) {

      obj_fly_hurt (other);

   }
   if ( (other == world) ) {

      return ;

   }
   if ( (((((other.flags2 & FL_SMALL) && !(self.flags2 & FL_SMALL)) && other.health) && other.takedamage) && (other.flags & FL_ONGROUND)) ) {

      other.velocity_z = 100.00000;
      other.flags -= FL_ONGROUND;
      T_Damage (other, self, self, 5000.00000);
      sound (other, CHAN_AUTO, "misc/squish.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (((((self.flags2 & FL_SMALL) && !(other.flags2 & FL_SMALL)) && other.movetype) && (other.velocity != '0.00000 0.00000 0.00000')) && (self.flags & FL_ONGROUND)) ) {

         if ( (other.classname != "player") ) {

            self.velocity_z = 100.00000;
            self.flags -= FL_ONGROUND;
            T_Damage (self, other, other, 5000.00000);
            sound (self, CHAN_AUTO, "misc/squish.wav", 1.00000, ATTN_NORM);

         }
      } else {

         if ( (self.flags & FL_ONGROUND) ) {

            return ;
         } else {

            if ( (((((other.classname == "player") || (other.flags & FL_ONGROUND)) || other.health) && (self.origin_z >= ((other.absmin_z + other.absmax_z) * 0.50000))) && (self.velocity_z < 10.00000)) ) {

               self.flags += FL_ONGROUND;

            }

         }

      }

   }
};


void  ()PlayerPostThink =  {
local float mspeed = 0.00000;
local float aspeed = 0.00000;
local float r = 0.00000;
   if ( ((self.view_ofs == '0.00000 0.00000 0.00000') && !(self.flags2 & FL_CAMERA_VIEW)) ) {

      return ;

   }
   if ( self.deadflag ) {

      return ;

   }
   if ( self.pullflag ) {

      obj_pull ();

   }
   W_WeaponFrame ();
   if ( ((((self.jump_flag * (self.mass / 10.00000)) < -300.00000) && (self.flags & FL_ONGROUND)) && (self.health > 0.00000)) ) {

      if ( (self.absorb_time >= time) ) {

         self.jump_flag /= 2.00000;

      }
      if ( (self.watertype == CONTENT_WATER) ) {

         sound (self, CHAN_BODY, "player/h2ojmp.wav", 1.00000, ATTN_NORM);
      } else {

         if ( ((self.jump_flag * (self.mass / 10.00000)) < -500.00000) ) {

            sound (self, CHAN_VOICE, "player/pallnd.wav", 1.00000, ATTN_NORM);
            self.deathtype = "falling";
         } else {

            sound (self, CHAN_VOICE, "player/land.wav", 1.00000, ATTN_NORM);

         }

      }
      if ( ((self.scale > 1.00000) && ((self.jump_flag * (self.mass / 10.00000)) < -500.00000)) ) {

         MonsterQuake (((self.mass / 10.00000) * self.jump_flag));

      }
      self.jump_flag = 0.00000;

   }
   if ( !(self.flags & FL_ONGROUND) ) {

      self.jump_flag = self.velocity_z;
   } else {

      self.last_onground = time;

   }
   CheckPowerups ();
   if ( ((self.artifact_flags & AFL_TORCH) && (self.torchtime < time)) ) {

      self.torchthink ();

   }
   if ( ((self.artifact_flags & AFL_SUPERHEALTH) && (self.healthtime < time)) ) {

      DecrementSuperHealth ();

   }
};


void  ()ClientConnect =  {
   bprint (self.netname);
   bprint (STR_JOINEDTHEGAME);
   if ( intermission_running ) {

      ExitIntermission ();

   }
};


void  ()ClientDisconnect =  {
   if ( gameover ) {

      return ;

   }
   bprint (self.netname);
   bprint (STR_LEFTTHEGAMEWITH);
   bprint (ftos (self.frags));
   bprint (STR_FRAGS);
   sound (self, CHAN_BODY, "player/leave.wav", 1.00000, ATTN_NONE);
   set_suicide_frame ();
};


void  (entity targ,entity attacker)ClientObituary =  {
local float rnum = 0.00000;
local string deathstring;
local string deathstring2;
   if ( (targ.classname != "player") ) {

      return ;

   }
   rnum = random ();
   if ( (attacker.classname == "teledeath") ) {

      bprint (targ.netname);
      bprint (STR_WASTELEFRAGGEDBY);
      bprint (attacker.owner.netname);
      bprint ("\n");
      attacker.owner.frags = (attacker.owner.frags + 1.00000);
      return ;

   }
   if ( (attacker.classname == "teledeath2") ) {

      bprint ("Satan's power deflects ");
      bprint (targ.netname);
      bprint ("'s telefrag\n");
      targ.frags = (targ.frags - 1.00000);
      return ;

   }
   if ( (attacker.classname == "player") ) {

      if ( (targ == attacker) ) {

         attacker.frags = (attacker.frags - 1.00000);
         bprint (targ.netname);
         if ( ((targ.weapon == 64.00000) && (targ.waterlevel > 1.00000)) ) {

            bprint (" discharges into the water.\n");
            return ;

         }
         if ( (targ.weapon == IT_GRENADE_LAUNCHER) ) {

            bprint (" tries to put the pin back in\n");
         } else {

            bprint (" becomes bored with life\n");

         }
         return ;
      } else {

         if ( (((teamplay == 2.00000) && (targ.team > 0.00000)) && (targ.team == attacker.team)) ) {

            if ( (rnum < 0.25000) ) {

               deathstring = " mows down a teammate\n";
            } else {

               if ( (rnum < 0.50000) ) {

                  deathstring = " checks his glasses\n";
               } else {

                  if ( (rnum < 0.75000) ) {

                     deathstring = " gets a frag for the other team\n";
                  } else {

                     deathstring = " loses another friend\n";

                  }

               }

            }
            bprint (attacker.netname);
            bprint (deathstring);
            attacker.frags = (attacker.frags - 1.00000);
            return ;
         } else {

            attacker.frags = (attacker.frags + 1.00000);
            rnum = attacker.weapon;
            if ( (targ.decap == 1.00000) ) {

               if ( (attacker.playerclass == CLASS_ASSASSIN) ) {

                  deathstring = " got good head from ";
                  if ( (targ.playerclass == CLASS_ASSASSIN) ) {

                     deathstring2 = "... her own!\n";
                  } else {

                     deathstring2 = "... his own!\n";

                  }
               } else {

                  if ( (targ.playerclass == CLASS_ASSASSIN) ) {

                     deathstring = " lost her head over ";
                  } else {

                     deathstring = "lost his head over ";

                  }
                  deathstring2 = "!\n";

               }
            } else {

               if ( (targ.decap == 2.00000) ) {

                  if ( (targ.playerclass == CLASS_ASSASSIN) ) {

                     deathstring = " got her head blown off by ";
                     deathstring2 = "!\n";
                  } else {

                     deathstring = " got his head blown off by ";
                     deathstring2 = "!\n";

                  }
               } else {

                  if ( (targ.deathtype == "hammercrush") ) {

                     deathstring = " was crushed by the righteous might of ";
                     deathstring2 = "'s Hammer!\n";
                  } else {

                     if ( (targ.deathtype == "zap") ) {

                        deathstring = " was fried by the holy lightning of ";
                        deathstring2 = "'s Mjolnir!\n";
                     } else {

                        if ( (rnum == IT_WEAPON1) ) {

                           deathstring = " was ax-murdered by ";
                           deathstring2 = "\n";
                        } else {

                           if ( (rnum == IT_SHOTGUN) ) {

                              deathstring = " chewed on ";
                              deathstring2 = "'s boomstick\n";
                           } else {

                              if ( (rnum == IT_SUPER_SHOTGUN) ) {

                                 deathstring = " ate 2 loads of ";
                                 deathstring2 = "'s buckshot\n";
                              } else {

                                 if ( (rnum == IT_NAILGUN) ) {

                                    deathstring = " was nailed by ";
                                    deathstring2 = "\n";
                                 } else {

                                    if ( (rnum == IT_SUPER_NAILGUN) ) {

                                       deathstring = " was punctured by ";
                                       deathstring2 = "\n";
                                    } else {

                                       if ( (rnum == IT_GRENADE_LAUNCHER) ) {

                                          deathstring = " eats ";
                                          deathstring2 = "'s pineapple\n";
                                          if ( (targ.health < -40.00000) ) {

                                             deathstring = " was gibbed by ";
                                             deathstring2 = "'s grenade\n";

                                          }
                                       } else {

                                          if ( (rnum == IT_ROCKET_LAUNCHER) ) {

                                             deathstring = " rides ";
                                             deathstring2 = "'s rocket\n";
                                             if ( (targ.health < -40.00000) ) {

                                                deathstring = " was gibbed by ";
                                                deathstring2 = "'s rocket\n";

                                             }
                                          } else {

                                             if ( (rnum == IT_LIGHTNING) ) {

                                                deathstring = " accepts ";
                                                if ( (attacker.waterlevel > 1.00000) ) {

                                                   deathstring2 = "'s discharge\n";
                                                } else {

                                                   deathstring2 = "'s shaft\n";

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

                  }

               }

            }
            bprint (targ.netname);
            bprint (deathstring);
            bprint (attacker.netname);
            bprint (deathstring2);

         }

      }
      return ;
   } else {

      targ.frags = (targ.frags - 1.00000);
      bprint (targ.netname);
      if ( (attacker.flags & FL_MONSTER) ) {

         if ( (attacker.classname == "monster_archer") ) {

            bprint (" was skewered by an Archer!\n");

         }
         if ( (attacker.classname == "monster_fallen_angel") ) {

            bprint (" was felled by the Fallen Angel\n");

         }
         if ( (attacker.classname == "monster_imp_fire") ) {

            bprint (" was got roasted by a Fire Imp!\n");

         }
         if ( (attacker.classname == "monster_golem_bronze") ) {

            bprint (" was squished like an insect by a Bronze Golem!\n");

         }
         if ( (attacker.classname == "monster_golem_iron") ) {

            bprint (" was crushed by the Iron Golem's fist!\n");

         }
         if ( (attacker.classname == "monster_golem_stone") ) {

            bprint (" was squished by a Stone Golem!\n");

         }
         if ( (attacker.classname == "monster_hydra") ) {

            bprint (" becomes food for the Hydra!\n");

         }
         if ( (attacker.classname == "monster_imp_ice") ) {

            bprint (" chills out with the Ice Imps!\n");

         }
         if ( (attacker.classname == "monster_medusa") ) {

            bprint (" is helpless in the face of the Medusa's beauty!\n");

         }
         if ( (attacker.classname == "monster_mezzoman") ) {

            bprint (" is no match for the MezzoMan!\n");

         }
         if ( (attacker.classname == "monster_mummy") ) {

            bprint (" got mummified!\n");

         }
         if ( (attacker.classname == "monster_scorpion_black") ) {

            bprint (" submits to the sting of the Black Scorpion!\n");

         }
         if ( (attacker.classname == "monster_scorpion_yellow") ) {

            bprint (" was poisoned by the fatal Golden Scorpion!\n");

         }
         if ( (attacker.classname == "monster_skull_wizard") ) {

            bprint (" succumbed to the Skull Wizard's magic!\n");

         }
         if ( (attacker.classname == "monster_snake") ) {

            bprint (" was bitten by the lethal Cobra!\n");

         }
         if ( (attacker.classname == "monster_spider_red_large") ) {

            bprint (" was overcome by the Crimson Spiders!\n");

         }
         if ( (attacker.classname == "monster_spider_red_small") ) {

            bprint (" was eaten alive by the spiders!\n");

         }
         if ( (attacker.classname == "monster_spider_yellow_large") ) {

            bprint (" was overwhelmed by the Golden Spiders!\n");

         }
         if ( (attacker.classname == "monster_spider_yellow_small") ) {

            bprint (" is a meal for the spiders!\n");

         }
         return ;

      }
      if ( (targ.decap == 1.00000) ) {

         if ( (targ.playerclass == CLASS_ASSASSIN) ) {

            bprint (" lost her head!\n");
         } else {

            bprint (" lost his head!\n");

         }
         return ;

      }
      if ( (targ.decap == 2.00000) ) {

         if ( (targ.playerclass == CLASS_ASSASSIN) ) {

            bprint (" got her head blown off!\n");
         } else {

            bprint (" got his head blown off!\n");

         }
         return ;

      }
      if ( (attacker.classname == "light_thunderstorm") ) {

         bprint (" shouldn't mess with Mother Nature!\n");
         return ;

      }
      if ( (targ.deathtype == "zap") ) {

         bprint (" was electrocuted!\n");
         return ;

      }
      if ( (targ.deathtype == "chopped") ) {

         bprint (" was sliced AND diced!\n");
         return ;

      }
      if ( ((attacker.solid == SOLID_BSP) && (attacker != world)) ) {

         bprint (" was squished\n");
         return ;

      }
      if ( ((attacker.classname == "trap_shooter") || (attacker.classname == "trap_spikeshooter")) ) {

         bprint (" was spiked");
         if ( ((attacker.enemy.classname == "player") && (attacker.enemy != targ)) ) {

            bprint (" by ");
            bprint (attacker.enemy.netname);
            attacker.enemy.frags += 1.00000;

         }
         bprint ("\n");
         return ;

      }
      if ( (attacker.classname == "fireball") ) {

         bprint (" ate a lavaball\n");
         return ;

      }
      if ( (attacker.classname == "trigger_changelevel") ) {

         bprint (" tried to leave\n");
         return ;

      }
      rnum = targ.watertype;
      if ( (rnum == -3.00000) ) {

         if ( (random () < 0.50000) ) {

            bprint (" takes a nice, deep breath of H2O!\n");
         } else {

            bprint (" needed gills\n");

         }
         return ;
      } else {

         if ( (rnum == -4.00000) ) {

            if ( (random () < 0.50000) ) {

               bprint (" gulped a load of slime\n");
            } else {

               bprint (" can't exist on slime alone\n");

            }
            return ;
         } else {

            if ( (rnum == -5.00000) ) {

               if ( (targ.health < -15.00000) ) {

                  bprint (" needs to be hosed down\n");
                  return ;

               }
               if ( (random () < 0.50000) ) {

                  bprint ("'s fillings has melted\n");
               } else {

                  bprint (" smells like burnt hair\n");

               }
               return ;

            }

         }

      }
      if ( (targ.deathtype == "falling") ) {

         targ.deathtype = "";
         bprint (STR_CHUNKYSALSA);
         return ;

      }
      bprint (STR_CEASEDTOFUNCTION);

   }
};

