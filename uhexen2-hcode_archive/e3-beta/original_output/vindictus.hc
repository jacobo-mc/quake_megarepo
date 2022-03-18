
void  ()DrawLinks =  {
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_STREAM_CHAIN);
   WriteByte (MSG_BROADCAST, (1.00000 + STREAM_ATTACHED));
   WriteByte (MSG_BROADCAST, 4.00000);
   WriteEntity (MSG_BROADCAST, self);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
   WriteCoord (MSG_BROADCAST, self.view_ofs_x);
   WriteCoord (MSG_BROADCAST, self.view_ofs_y);
   WriteCoord (MSG_BROADCAST, self.view_ofs_z);
};


void  ()DeactivateGhook =  {
   self.aflag = FALSE;
   sound (self.owner, CHAN_ITEM, "assassin/clink.wav", 1.00000, ATTN_NORM);
   self.think = SUB_Remove;
   self.nextthink = time;
};


void  ()PullBack =  {
   if ( (self.enemy.flags2 & FL_ALIVE) ) {

      self.enemy.movetype = self.enemy.oldmovetype;

   }
   self.movetype = MOVETYPE_NOCLIP;
   self.solid = SOLID_NOT;
   self.velocity = (normalize ((self.view_ofs - self.origin)) * (200.00000 + (500.00000 * self.hasted)));
   if ( (self.cnt == TRUE) ) {

      DrawLinks ();
      self.cnt = FALSE;
   } else {

      self.cnt = TRUE;

   }
   if ( ((vlen ((self.origin - self.view_ofs)) < 36.00000) || (self.lifetime < time)) ) {

      self.think = DeactivateGhook;
   } else {

      self.think = PullBack;

   }
   self.nextthink = (time + 0.10000);
};


void  ()Yank =  {
local float dist = 0.00000;
local vector dir = '0.00000 0.00000 0.00000';
   setorigin (self, ((self.enemy.origin + self.enemy.mins) + (self.enemy.size * 0.50000)));
   self.velocity = '0.00000 0.00000 0.00000';
   if ( (self.enemy.v_angle != self.o_angle) ) {

      self.enemy.v_angle = self.o_angle;

   }
   if ( ((random () < 0.20000) && (random () < 0.20000)) ) {

      SpawnPuff (self.origin, self.velocity, 10.00000, other);
      sound (other, CHAN_BODY, "assassin/chntear.wav", 1.00000, ATTN_NORM);
      self.enemy.effects = EF_MUZZLEFLASH;

   }
   if ( ((self.enemy.health <= 7.00000) && self.frags) ) {

      T_Damage (self.enemy, self, self.owner, 5000.00000);
      self.lifetime = (time + 2.00000);
      self.think = PullBack;
      PullBack ();
   } else {

      T_Damage (self.enemy, self, self.owner, self.dmg);

   }
   if ( (self.cnt == TRUE) ) {

      DrawLinks ();
      self.cnt = FALSE;
   } else {

      self.cnt = TRUE;

   }
   if ( (self.enemy.nextthink < (time + 0.15000)) ) {

      self.enemy.nextthink = (time + 0.15000);

   }
   if ( (self.enemy.attack_finished < (time + 0.15000)) ) {

      self.enemy.attack_finished = (time + 0.15000);

   }
   if ( (self.enemy.pausetime < (time + 0.15000)) ) {

      self.enemy.pausetime = (time + 0.15000);

   }
   if ( (self.wait <= time) ) {

      dir = normalize ((self.view_ofs - self.origin));
      dist = vlen ((self.origin - self.view_ofs));
      if ( (dist <= 100.00000) ) {

         dir = ((dir * dist) * 10.00000);

      }
      if ( (dist > 100.00000) ) {

         dir = (dir * 100.00000);

      }
      if ( (self.enemy.flags & FL_ONGROUND) ) {

         self.enemy.flags = (self.enemy.flags - FL_ONGROUND);
         self.enemy.velocity_z = 100.00000;

      }
      self.enemy.velocity = ((self.enemy.velocity + dir) * 0.50000);
   } else {

      self.enemy.velocity = '0.00000 0.00000 0.00000';

   }
   if ( (((!self.frags || !(self.owner.flags2 & FL_ALIVE)) || !self.enemy.health) || (self.enemy.health <= (self.health - 100.00000))) ) {

      self.lifetime = (time + 2.00000);
      self.think = PullBack;
      self.nextthink = time;
   } else {

      self.think = Yank;
      self.nextthink = (time + 0.10000);

   }
};


void  (entity bound)Grab =  {
   sound (self, CHAN_AUTO, "assassin/chn2flsh.wav", 1.00000, ATTN_NORM);
   setorigin (self, bound.origin);
   T_Damage (other, self, self.owner, 3.00000);
   SpawnPuff (self.origin, self.velocity, 10.00000, other);
   if ( !self.frags ) {

      self.lifetime = (time + 1.00000);
   } else {

      self.wait = (time + 0.50000);

   }
   if ( self.hasted ) {

      self.owner.punchangle_x = 6.00000;

   }
   self.velocity = '0.00000 0.00000 0.00000';
   self.avelocity = '0.00000 0.00000 0.00000';
   self.origin = bound.origin;
   self.movedir = normalize ((self.origin - self.view_ofs));
   self.enemy = bound;
   bound.oldmovetype = bound.movetype;
   bound.movetype = MOVETYPE_BOUNCE;
   self.o_angle = bound.v_angle;
   self.health = bound.health;
   self.think = Yank;
   self.nextthink = time;
};


void  ()HookHit =  {
   if ( ((other != self.enemy) && (self.enemy.flags2 & FL_ALIVE)) ) {

      return ;

   }
   if ( ((other != world) && !other.takedamage) ) {

      return ;

   }
   self.touch = SUB_Null;
   if ( other.takedamage ) {

      Grab (other);
   } else {

      sound (self, CHAN_AUTO, "assassin/clink.wav", 1.00000, ATTN_NORM);
      self.lifetime = (time + 2.00000);
      self.think = PullBack;
      self.nextthink = time;

   }
};


void  ()HookHome =  {
local vector destiny = '0.00000 0.00000 0.00000';
   if ( (self.enemy != world) ) {

      destiny = self.enemy.origin;
      destiny_z = (self.enemy.origin_z + (0.50000 * self.enemy.maxs_z));
      self.velocity = (normalize ((destiny - self.origin)) * 350.00000);

   }
   if ( (self.pain_finished < time) ) {

      sound (self, CHAN_BODY, "assassin/chain.wav", 1.00000, ATTN_NORM);
      self.pain_finished = (time + 0.50000);

   }
   if ( (self.cnt == TRUE) ) {

      DrawLinks ();
      self.cnt = FALSE;
   } else {

      self.cnt = TRUE;

   }
   if ( (((self.lifetime < time) && !self.frags) || (!self.enemy.health && (self.enemy != world))) ) {

      self.lifetime = (time + 2.00000);
      self.think = PullBack;
      self.nextthink = time;
   } else {

      self.think = HookHome;
      self.nextthink = (time + 0.10000);

   }
};


void  (vector startpos,vector endpos,entity loser,entity winner,float gibhook)Hook =  {
local entity ghook;
   ghook = spawn ();
   sound (self, CHAN_AUTO, "misc/whoosh.wav", 1.00000, ATTN_NORM);
   ghook.movetype = MOVETYPE_FLYMISSILE;
   ghook.solid = SOLID_BBOX;
   ghook.touch = HookHit;
   ghook.classname = "hook";
   ghook.speed = 8.00000;
   ghook.owner = winner;
   ghook.enemy = loser;
   ghook.aflag = TRUE;
   ghook.view_ofs = startpos;
   ghook.frags = gibhook;
   if ( !gibhook ) {

      ghook.lifetime = (time + 3.00000);
      ghook.dmg = 20.00000;
   } else {

      ghook.dmg = 0.25000;

   }
   ghook.scale = 0.30000;
   ghook.movedir = normalize ((endpos - startpos));
   ghook.velocity = (ghook.movedir * 500.00000);
   ghook.angles = vectoangles (ghook.velocity);
   ghook.think = HookHome;
   ghook.nextthink = time;
   setmodel (ghook, "models/hook.mdl");
   setorigin (ghook, (startpos - (ghook.movedir * 6.00000)));
   setsize (ghook, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
};


void  ()CubeStopAndChain =  {
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
   self.enemy.velocity = '0.00000 0.00000 0.00000';
   self.enemy.oldmovetype = self.enemy.movetype;
   self.enemy.movetype = MOVETYPE_NONE;
   makevectors (self.enemy.angles);
   org = self.enemy.origin;
   org_z += (0.50000 * self.enemy.maxs_z);
   dir = org;
   dir += (v_right * (random () * 300.00000));
   dir_z += (random () * 300.00000);
   traceline (self.enemy.origin, dir, TRUE, self);
   dir = trace_endpos;
   Hook (dir, org, self.enemy, self.owner, TRUE);
   dir = org;
   dir -= (v_right * (random () * 300.00000));
   dir_z += (random () * 300.00000);
   traceline (self.enemy.origin, dir, TRUE, self);
   dir = trace_endpos;
   Hook (dir, org, self.enemy, self.owner, TRUE);
   dir = org;
   dir += (v_right * (random () * 300.00000));
   dir_z += ((random () * 100.00000) - 20.00000);
   traceline (self.enemy.origin, dir, TRUE, self);
   dir = trace_endpos;
   Hook (dir, org, self.enemy, self.owner, TRUE);
   dir = org;
   dir -= (v_right * (random () * 300.00000));
   dir_z += ((random () * 100.00000) - 20.00000);
   traceline (self.enemy.origin, dir, TRUE, self);
   dir = trace_endpos;
   Hook (dir, org, self.enemy, self.owner, TRUE);
   remove (self);
};


void  ()CubeFindEnemy =  {
local vector org = '0.00000 0.00000 0.00000';
local entity loser;
   loser = findradius (self.origin, 5000.00000);
   self.enemy = world;
   self.lifetime = 5001.00000;
   while ( loser ) {

      if ( (((((((loser.flags2 & FL_ALIVE) && loser.takedamage) && visible (loser)) && loser.health) && (loser != world)) && (loser != self)) && (loser != self.owner)) ) {

         if ( (teamplay && (loser.team == self.owner.team)) ) {

            bprint ("");
         } else {

            if ( (vlen ((self.origin - loser.origin)) < self.lifetime) ) {

               self.enemy = loser;
               self.lifetime = vlen ((self.origin - loser.origin));

            }

         }

      }
      loser = loser.chain;

   }
   if ( (self.enemy == world) ) {

      MultiExplode ();
   } else {

      org = ((self.enemy.absmin + self.enemy.absmax) * 0.50000);
      Hook (org, self.origin, self.enemy, self.owner, FALSE);

   }
   remove (self);
};


void  ()LatchOn =  {
   self.touch = SUB_Null;
   self.velocity = '0.00000 0.00000 0.00000';
   if ( (((other.takedamage && other.movetype) && other.health) && (other.solid != SOLID_BSP)) ) {

      self.enemy = other;
      CubeStopAndChain ();
   } else {

      CubeFindEnemy ();

   }
};


void  ()FireCube =  {
   self.attack_finished = (time + 1.00000);
   makevectors (self.v_angle);
   self.punchangle_x = -10.00000;
   newmis = spawn ();
   newmis.owner = self;
   newmis.classname = "chainball";
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.dmg = 25.00000;
   newmis.velocity = (normalize (v_forward) * 350.00000);
   newmis.avelocity_x = ((random () * 720.00000) - 360.00000);
   newmis.avelocity_y = ((random () * 720.00000) - 360.00000);
   newmis.avelocity_z = ((random () * 720.00000) - 360.00000);
   newmis.touch = LatchOn;
   newmis.homerate = 0.50000;
   newmis.veer = 0.00000;
   newmis.think = HomeThink;
   setmodel (newmis, "models/ballchn.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 16.00000)));
};

void  ()Ass_Vind_Fire;
void  ()vindictus_select;

void  ()HookWait =  {
   DrawLinks ();
   self.cnt += 1.00000;
   if ( (self.cnt > 2.00000) ) {

      self.think = SUB_Remove;

   }
   self.nextthink = (time + 0.20000);
};


void  ()ThrowChain =  {
local entity chook;
   chook = spawn ();
   chook.movetype = MOVETYPE_BOUNCE;
   chook.solid = SOLID_NOT;
   chook.classname = "hook";
   chook.owner = self.owner;
   chook.view_ofs = self.origin;
   chook.scale = 0.30000;
   chook.movedir_x = ((random () * 2.00000) - 1.00000);
   chook.movedir_y = ((random () * 2.00000) - 1.00000);
   chook.movedir_z = ((random () * 2.00000) - 1.00000);
   chook.speed = ((random () * 500.00000) + 350.00000);
   chook.velocity = (normalize (chook.movedir) * chook.speed);
   chook.angles = vectoangles (chook.velocity);
   chook.think = HookWait;
   chook.nextthink = time;
   setmodel (chook, "models/hook.mdl");
   setorigin (chook, self.origin);
   setsize (chook, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
};


void  ()BallExplode =  {
   sound (self, CHAN_AUTO, "weapons/explode.wav", 0.50000, ATTN_NORM);
   sound (self, CHAN_AUTO, "player/megagib.wav", 0.50000, ATTN_NORM);
   self.effects = EF_MUZZLEFLASH;
   if ( (self.enemy.health && (self.enemy != world)) ) {

      T_Damage (self.enemy, self, self.owner, 50.00000);
      MeatChunks (((self.enemy.absmin + self.enemy.absmax) * 0.50000), 5.00000);
   } else {

      T_RadiusDamage (self, self.owner, 75.00000, self);

   }
   particleexplosion (self.origin, ((11.00000 * 16.00000) + 8.00000), 50.00000, 20.00000);
   ThrowChain ();
   ThrowChain ();
   ThrowChain ();
   if ( (random () < 0.50000) ) {

      ThrowChain ();

   }
   if ( (random () < 0.50000) ) {

      ThrowChain ();

   }
   setmodel (self, "models/null.spr");
   BecomeExplosion (CE_LG_EXPLOSION);
};


void  ()BallHit =  {
local vector org1 = '0.00000 0.00000 0.00000';
local vector org2 = '0.00000 0.00000 0.00000';
local float part_color = 0.00000;
   if ( ((other.classname == "hook") || (other.classname == "chainball")) ) {

      return ;

   }
   self.aflag = FALSE;
   self.touch = SUB_Null;
   self.velocity = '0.00000 0.00000 0.00000';
   self.avelocity = '0.00000 0.00000 0.00000';
   self.enemy = world;
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NOCLIP;
   if ( other.takedamage ) {

      if ( ((other.thingtype == THINGTYPE_FLESH) && (self.classname != "mummy")) ) {

         part_color = ((8.00000 * 16.00000) + 9.00000);
      } else {

         if ( ((other.thingtype == THINGTYPE_GREYSTONE) || (other.thingtype == THINGTYPE_BROWNSTONE)) ) {

            part_color = (256.00000 + (1.00000 * 16.00000));
         } else {

            if ( (other.thingtype == THINGTYPE_METAL) ) {

               part_color = (256.00000 + (8.00000 * 15.00000));
            } else {

               if ( (other.thingtype == THINGTYPE_WOOD) ) {

                  part_color = (256.00000 + (5.00000 * 16.00000));
               } else {

                  part_color = ((256.00000 + (3.00000 * 16.00000)) + 4.00000);

               }

            }

         }

      }
      org1 = (normalize (self.o_angle) * 100.00000);
      org2 = (normalize (self.o_angle) * -100.00000);
      particle2 (self.origin, self.origin, org1, part_color, 5.00000, 10.00000);
      particle2 (self.origin, org2, self.origin, part_color, 6.00000, 30.00000);

   }
   if ( (((other.flags2 & FL_ALIVE) || (other.classname == "head")) || (other.classname == "corpse")) ) {

      sound (self, CHAN_AUTO, "assassin/chn2flsh.wav", 1.00000, ATTN_NORM);
      self.enemy = other;
      org1 = ((other.absmin + other.absmax) * 0.50000);
      setorigin (self, org1);

   }
   BallExplode ();
};


void  ()HooksThink =  {
   if ( !self.owner.aflag ) {

      remove (self);
   } else {

      self.think = HooksThink;
      self.nextthink = (time + 0.10000);

   }
};


void  ()TheOldBallAndChain =  {
local entity lastlink;
local float hookcounter = 0.00000;
local entity hooks;
   self.attack_finished = (time + 0.30000);
   makevectors (self.v_angle);
   self.punchangle_x = -6.00000;
   self.effects += EF_MUZZLEFLASH;
   newmis = spawn ();
   newmis.owner = self;
   newmis.classname = "chainball";
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.drawflags = MLS_ABSLIGHT;
   newmis.abslight = 0.50000;
   newmis.aflag = TRUE;
   newmis.velocity = (normalize (v_forward) * 1000.00000);
   newmis.o_angle = (normalize (v_forward) * 1000.00000);
   newmis.avelocity_x = ((random () * 720.00000) - 360.00000);
   newmis.avelocity_y = ((random () * 720.00000) - 360.00000);
   newmis.avelocity_z = ((random () * 720.00000) - 360.00000);
   newmis.touch = BallHit;
   setmodel (newmis, "models/ballchn.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 12.00000)));
   lastlink = newmis;
   while ( (hookcounter < 3.00000) ) {

      hookcounter += 1.00000;
      hooks = spawn ();
      hooks.owner = newmis;
      hooks.movetype = MOVETYPE_NOCLIP;
      hooks.solid = SOLID_NOT;
      hooks.drawflags = MLS_ABSLIGHT;
      hooks.abslight = 0.50000;
      hooks.angles_x = (random () * 360.00000);
      hooks.angles_y = (random () * 360.00000);
      hooks.angles_z = (random () * 360.00000);
      hooks.think = HooksThink;
      hooks.nextthink = time;
      lastlink.movechain = hooks;
      hooks.flags = FL_MOVECHAIN_ANGLE;
      lastlink = hooks;
      setmodel (hooks, "models/hook.mdl");
      setsize (hooks, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      setorigin (hooks, newmis.origin);

   }
};


void  ()ChainsOfLove =  {
   FireCube ();
};


void  ()vindictus_idle =  {
   self.weaponframe = 13.00000;
   self.th_weapon = vindictus_idle;
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Ass_Vind_Fire ();

   }
};


void  ()vindictus_shoot =  {
   self.wfs = advanceweaponframe (24.00000, 34.00000);
   self.th_weapon = vindictus_shoot;
   if ( (self.weaponframe == 26.00000) ) {

      TheOldBallAndChain ();

   }
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      vindictus_idle ();

   }
};


void  ()vindictus_power =  {
   self.wfs = advanceweaponframe (1.00000, 12.00000);
   self.th_weapon = vindictus_power;
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      vindictus_idle ();
   } else {

      if ( (self.weaponframe == 1.00000) ) {

         ChainsOfLove ();

      }

   }
};


void  ()Ass_Vind_Fire =  {
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = player_assassin_attack;
   } else {

      self.think = player_assassin_crouch_attack;

   }
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      self.th_weapon = vindictus_power;
   } else {

      self.th_weapon = vindictus_shoot;

   }
   self.nextthink = time;
};


void  ()vindictus_select =  {
   self.th_weapon = vindictus_select;
   self.wfs = advanceweaponframe (23.00000, 14.00000);
   self.weaponmodel = "models/vindictus.mdl";
   if ( (self.weaponframe == 14.00000) ) {

      self.attack_finished = (time - 1.00000);
      vindictus_idle ();

   }
};


void  ()vindictus_deselect =  {
   self.th_weapon = vindictus_deselect;
   self.wfs = advanceweaponframe (14.00000, 23.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      W_SetCurrentAmmo ();

   }
};

