
void  ()IceCubeThink =  {
   if ( ((self.maxs_z - self.mins_z) > 5.00000) ) {

      if ( ((pointcontents ((self.origin - '0.00000 0.00000 23.00000')) == CONTENT_LAVA) || (self.frozen <= 0.00000)) ) {

         if ( ((self.maxs_z - self.mins_z) < 25.00000) ) {

            if ( !(self.flags2 & FL_SMALL) ) {

               self.flags2 += FL_SMALL;

            }

         }
         self.frozen = FALSE;
         self.think = self.oldthink;
         self.nextthink = time;
         self.skin = self.oldskin;
         self.touch = self.oldtouch;
         self.movetype = self.oldmovetype;
         self.drawflags -= DRF_TRANSLUCENT;
         return ;

      }

   }
   if ( ((pointcontents (self.origin) == CONTENT_WATER) || (pointcontents (self.origin) == CONTENT_SLIME)) ) {

      self.frozen = (self.frozen - 1.00000);
      self.scale -= 0.01000;

   }
   if ( (!(self.flags & FL_ONGROUND) && (pointcontents ((self.origin + '0.00000 0.00000 -24.00000')) != CONTENT_SOLID)) ) {

      self.frags = TRUE;

   }
   if ( (self.frags && (self.flags & FL_ONGROUND)) ) {

      T_Damage (self, world, self.enemy, (self.frags * 10.00000));

   }
   self.frozen = (self.frozen - 0.20000);
   if ( (random () < 0.20000) ) {

      sound (self, CHAN_BODY, "misc/drip.wav", 1.00000, ATTN_NORM);

   }
   if ( (self.wait <= time) ) {

      self.scale -= 0.00700;
      self.mins = (self.o_angle * (self.scale / self.lifetime));
      self.maxs = (self.v_angle * (self.scale / self.lifetime));
      setsize (self, self.mins, self.maxs);
      droptofloor ();

   }
   if ( (((self.maxs_z - self.mins_z) <= 5.00000) || (self.scale <= 0.07000)) ) {

      AwardExperience (self.enemy, self, 0.00000);
      remove (self);

   }
   self.think = IceCubeThink;
   self.nextthink = (time + 0.10000);
};


void  (entity loser,entity forwhom)SnowJob =  {
   sound (loser, CHAN_AUTO, "crusader/frozen.wav", 1.00000, ATTN_NORM);
   loser.frozen = 50.00000;
   loser.oldskin = loser.skin;
   loser.skin = 105.00000;
   if ( (loser.classname != "player") ) {

      if ( (loser.scale == 0.00000) ) {

         loser.scale = 1.00000;

      }
      loser.lifetime = loser.scale;
      loser.o_angle = loser.mins;
      loser.v_angle = loser.maxs;
      loser.enemy = forwhom;
      loser.oldthink = loser.think;
      loser.think = IceCubeThink;
      loser.nextthink = time;
      loser.touch = SUB_Null;
      loser.wait = (time + 10.00000);
      if ( ((loser.angles_x == 0.00000) && (loser.angles_z == 0.00000)) ) {

         if ( !(loser.drawflags & SCALE_ORIGIN_BOTTOM) ) {

            loser.drawflags += SCALE_ORIGIN_BOTTOM;

         }

      }
      loser.oldmovetype = loser.movetype;
      loser.movetype = MOVETYPE_PUSHPULL;
      loser.health = 1.00000;
   } else {

      loser.o_angle = loser.v_angle;
      loser.pausetime = (time + 20.00000);
      loser.attack_finished = (time + 20.00000);
      loser.items += IT_QUAD;
      loser.health = 1.00000;
      loser.nextthink = (time + 20.00000);

   }
   if ( (loser.flags & FL_FLY) ) {

      loser.flags = (loser.flags - FL_FLY);

   }
   if ( (loser.flags & FL_SWIM) ) {

      loser.flags = (loser.flags - FL_SWIM);

   }
   if ( (loser.flags & FL_ONGROUND) ) {

      loser.flags = (loser.flags - FL_ONGROUND);

   }
   loser.oldtouch = loser.touch;
   loser.touch = obj_push;
   if ( !(loser.drawflags & DRF_TRANSLUCENT) ) {

      loser.drawflags += DRF_TRANSLUCENT;

   }
};


void  ()FreezeDie =  {
   particleexplosion (self.origin, 14.00000, 20.00000, 5.00000);
   particle2 (self.origin, '-10.00000 -10.00000 -10.00000', '10.00000 10.00000 10.00000', 145.00000, 14.00000, 5.00000);
   remove (self);
};


void  ()FreezeTouch =  {
   if ( (other == self.owner) ) {

      return ;

   }
   if ( ((((other.takedamage && other.health) && !(other.flags & FL_COLDRESIST)) && !(other.flags & FL_COLDHEAL)) && !other.frozen) ) {

      if ( (((random () < 0.50000) && (other.health <= 10.00000)) && (other.solid != SOLID_BSP)) ) {

         SnowJob (other, self.owner);
      } else {

         T_Damage (other, self, self.owner, 10.00000);

      }
      self.think = FreezeDie;
      self.nextthink = time;
   } else {

      if ( (other.flags & FL_COLDHEAL) ) {

         other.health = (other.health + 5.00000);
         self.think = FreezeDie;
         self.nextthink = time;
      } else {

         if ( !other.frozen ) {

            T_RadiusDamage (self, self.owner, 30.00000, self.owner);
            self.touch = SUB_Null;
            shatter ();
         } else {

            sound (self, CHAN_VOICE, "misc/tink.wav", 1.00000, ATTN_NORM);

         }

      }

   }
};


void  ()FreezeThink =  {
   if ( (((((pointcontents (self.origin) == CONTENT_WATER) && (random () < 0.30000)) || (pointcontents (self.origin) == CONTENT_LAVA)) || ((pointcontents (self.origin) == CONTENT_SLIME) && (random () < 0.50000))) || (self.wait < time)) ) {

      if ( (pointcontents (self.origin) == CONTENT_LAVA) ) {

         sound (self, CHAN_WEAPON, "misc/fout.wav", 1.00000, ATTN_NORM);

      }
      remove (self);

   }
   self.think = FreezeThink;
   self.nextthink = (time + 0.50000);
};


void  ()FireFreeze =  {
local vector dir = '0.00000 0.00000 0.00000';
   self.attack_finished = (time + 0.20000);
   self.punchangle_x = -1.00000;
   makevectors (self.v_angle);
   dir = normalize (v_forward);
   sound (self, CHAN_WEAPON, "crusader/icefire.wav", 1.00000, ATTN_NORM);
   newmis = spawn ();
   newmis.owner = self;
   newmis.movetype = MOVETYPE_BOUNCEMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.takedamage = DAMAGE_YES;
   newmis.health = 3.00000;
   self.deathtype = "ice shatter";
   newmis.th_die = shatter;
   newmis.angles = vectoangles (dir);
   newmis.touch = FreezeTouch;
   newmis.classname = "snowball";
   newmis.think = SUB_Remove;
   newmis.nextthink = (time + 6.00000);
   newmis.speed = 1200.00000;
   setmodel (newmis, "models/iceshot.mdl");
   newmis.avelocity = '-200.00000 200.00000 -200.00000';
   newmis.think = FreezeThink;
   newmis.nextthink = (time + 0.50000);
   newmis.wait = (time + 3.00000);
   setsize (newmis, '-2.00000 -2.00000 -2.00000', '2.00000 2.00000 2.00000');
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 8.00000)));
   newmis.velocity = (dir * newmis.speed);
};


void  ()shard_hit =  {
   if ( (other.classname == "blizzard shard") ) {

      return ;

   }
   if ( ((other.takedamage && other.health) && (other != self.owner)) ) {

      T_Damage (other, self, self.owner, (50.00000 * self.scale));

   }
   sound (self, CHAN_AUTO, "misc/fshatter.wav", 0.10000, ATTN_NORM);
   particleexplosion (self.origin, 14.00000, 20.00000, 5.00000);
   remove (self);
};


void  ()FireShard =  {
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
   newmis = spawn ();
   newmis.movetype = MOVETYPE_BOUNCE;
   newmis.solid = SOLID_TRIGGER;
   newmis.owner = self.owner;
   dir_x = ((random () * 50.00000) + 100.00000);
   dir_y = ((random () * 50.00000) + 100.00000);
   dir_z = ((random () * 70.00000) - 250.00000);
   org_x = ((random () * 76.00000) - 84.00000);
   org_y = ((random () * 76.00000) - 84.00000);
   if ( (org_x < 64.00000) ) {

      org_z = (64.00000 + org_x);
   } else {

      if ( (org_y < 64.00000) ) {

         org_z = (64.00000 + org_y);

      }

   }
   org_x += self.origin_x;
   org_y += self.origin_y;
   org_z += (self.origin_z + 64.00000);
   traceline (self.origin, org, TRUE, self);
   org = trace_endpos;
   newmis.velocity = dir;
   newmis.angles = (vectoangles (newmis.velocity) + '90.00000 0.00000 0.00000');
   newmis.scale = ((random () * 0.50000) + 0.05000);
   newmis.skin = 0.00000;
   newmis.frame = 0.00000;
   newmis.touch = shard_hit;
   setmodel (newmis, "models/shard.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, org);
};


void  ()blizzard_think =  {
local entity loser;
local vector dir = '0.00000 0.00000 0.00000';
   if ( ((self.lifetime < time) || (self.blizzcount < (self.owner.blizzcount - 2.00000))) ) {

      remove (self);

   }
   self.color = (random () * 16.00000);
   self.color = ((rint (self.color) + 16.00000) + 256.00000);
   dir_x = ((random () * 100.00000) + 100.00000);
   dir_y = ((random () * 100.00000) + 100.00000);
   rain_go ((self.origin + '-64.00000 -64.00000 -64.00000'), (self.origin + '64.00000 64.00000 64.00000'), '128.00000 128.00000 128.00000', dir, self.color, 77.00000);
   if ( (self.pain_finished < time) ) {

      sound (self, CHAN_WEAPON, "crusader/blizzard.wav", 1.00000, ATTN_NORM);
      self.pain_finished = (time + 0.70000);

   }
   FireShard ();
   FireShard ();
   FireShard ();
   loser = findradius (self.origin, 128.00000);
   while ( loser ) {

      if ( ((((loser.takedamage && loser.health) && !loser.frozen) && !(loser.flags & FL_COLDRESIST)) && (loser != self.owner)) ) {

         if ( (loser.flags & FL_COLDHEAL) ) {

            loser.health += 3.00000;
         } else {

            T_Damage (loser, self, self.owner, 3.00000);
            if ( ((((random () < 0.10000) && (random () < 0.50000)) || (loser.health < 6.00000)) && (loser.classname != "mjolnir")) ) {

               SnowJob (loser, self.owner);

            }

         }

      }
      loser = loser.chain;

   }
   self.nextthink = (time + 0.10000);
};


void  ()make_blizzard =  {
   if ( other.takedamage ) {

      setorigin (self, other.origin);

   }
   self.velocity = '0.00000 0.00000 0.00000';
   self.movetype = MOVETYPE_NOCLIP;
   self.solid = SOLID_NOT;
   self.classname = "blizzard";
   self.lifetime = (time + 10.00000);
   self.think = blizzard_think;
   self.nextthink = time;
   traceline (self.origin, (self.origin + '0.00000 0.00000 -64.00000'), TRUE, self);
   setorigin (self, (trace_endpos + '0.00000 0.00000 64.00000'));
};


void  ()sparkle =  {
   particleexplosion (self.origin, 14.00000, 20.00000, 10.00000);
   self.think = sparkle;
   self.nextthink = (time + 0.01000);
};


void  ()FireBlizzard =  {
   self.attack_finished = (time + 1.00000);
   sound (self, CHAN_WEAPON, "crusader/blizfire.wav", 1.00000, ATTN_NORM);
   newmis = spawn ();
   newmis.owner = self;
   self.blizzcount += 1.00000;
   newmis.blizzcount = self.blizzcount;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.touch = make_blizzard;
   newmis.velocity = (normalize (v_forward) * 1000.00000);
   newmis.effects = EF_MUZZLEFLASH;
   newmis.think = sparkle;
   newmis.nextthink = time;
   setmodel (newmis, "models/null.spr");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, ((self.origin + self.proj_ofs) + (v_forward * 16.00000)));
};


float  ()melee_range =  {
local vector source = '0.00000 0.00000 0.00000';
   makevectors (self.v_angle);
   source = (self.origin + self.proj_ofs);
   traceline (source, (source + (v_forward * 64.00000)), FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ( FALSE );
   } else {

      return ( TRUE );

   }
};


float  ()icestaff_hit =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local vector dir = '0.00000 0.00000 0.00000';
local float damg = 0.00000;
local float chance = 0.00000;
   makevectors (self.v_angle);
   source = (self.origin + self.proj_ofs);
   traceline (source, (source + (v_forward * 64.00000)), FALSE, self);
   org = (trace_endpos + (v_forward * 4.00000));
   if ( trace_ent.takedamage ) {

      SpawnPuff (org, '0.00000 0.00000 0.00000', 20.00000, trace_ent);
      damg = (30.00000 + (random () * 20.00000));
      if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

         damg = (damg * 3.00000);
         chance = 0.50000;
      } else {

         chance = 0.10000;

      }
      org = (trace_endpos + (v_forward * -1.00000));
      if ( (trace_ent.thingtype == THINGTYPE_FLESH) ) {

         sound (self, CHAN_WEAPON, "weapons/met2flsh.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (trace_ent.thingtype == THINGTYPE_WOOD) ) {

            sound (self, CHAN_WEAPON, "weapons/met2wd.wav", 1.00000, ATTN_NORM);
         } else {

            sound (self, CHAN_WEAPON, "weapons/met2stn.wav", 1.00000, ATTN_NORM);

         }

      }
      dir = ((normalize ((trace_ent.origin - self.origin)) * damg) * 2.00000);
      trace_ent.velocity = dir;
      if ( (trace_ent.flags & FL_ONGROUND) ) {

         trace_ent.flags = (trace_ent.flags - FL_ONGROUND);

      }
      trace_ent.velocity_z = 150.00000;
      T_Damage (trace_ent, self, self, damg);
      if ( ((((random () < chance) && !trace_ent.frozen) && !(trace_ent.flags & FL_COLDRESIST)) && !(trace_ent.flags & FL_COLDHEAL)) ) {

         SnowJob (trace_ent, self);

      }
      return ( TRUE );
   } else {

      return ( FALSE );

   }
};

void  ()Cru_Ice_Fire;

void  ()icestaff_idle =  {
   self.th_weapon = icestaff_idle;
   self.wfs = advanceweaponframe (15.00000, 30.00000);
   if ( (self.button0 && (self.attack_finished <= time)) ) {

      Cru_Ice_Fire ();

   }
};


void  ()icestaff_select =  {
   self.th_weapon = icestaff_select;
   self.wfs = advanceweaponframe (41.00000, 50.00000);
   self.weaponmodel = "models/icestaff.mdl";
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      self.attack_finished = (time - 1.00000);
      icestaff_idle ();

   }
};


void  ()icestaff_deselect =  {
   self.wfs = advanceweaponframe (50.00000, 41.00000);
   self.th_weapon = icestaff_deselect;
   if ( (self.wfs == WF_LAST_FRAME) ) {

      W_SetCurrentAmmo ();

   }
};

void  ()icestaff_shard;

void  ()icestaff_blizzard =  {
   self.th_weapon = icestaff_blizzard;
   self.wfs = advanceweaponframe (32.00000, 40.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      icestaff_idle ();
   } else {

      if ( (self.weaponframe == 32.00000) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            FireBlizzard ();
         } else {

            icestaff_shard ();

         }

      }

   }
};


void  ()icestaff_f1 =  {
   self.th_weapon = icestaff_f1;
   self.wfs = advanceweaponframe (0.00000, 2.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( !self.button0 ) {

         icestaff_idle ();
      } else {

         icestaff_shard ();

      }
   } else {

      if ( ((self.attack_finished <= time) && (self.weaponframe == 0.00000)) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            icestaff_blizzard ();
         } else {

            FireFreeze ();

         }

      }

   }
};


void  ()icestaff_f2 =  {
   self.th_weapon = icestaff_f2;
   self.wfs = advanceweaponframe (3.00000, 5.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( !self.button0 ) {

         icestaff_idle ();
      } else {

         icestaff_shard ();

      }
   } else {

      if ( ((self.attack_finished <= time) && (self.weaponframe == 3.00000)) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            icestaff_blizzard ();
         } else {

            FireFreeze ();

         }

      }

   }
};


void  ()icestaff_f3 =  {
   self.th_weapon = icestaff_f3;
   self.wfs = advanceweaponframe (6.00000, 8.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( !self.button0 ) {

         icestaff_idle ();
      } else {

         icestaff_shard ();

      }
   } else {

      if ( ((self.attack_finished <= time) && (self.weaponframe == 6.00000)) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            icestaff_blizzard ();
         } else {

            FireFreeze ();

         }

      }

   }
};


void  ()icestaff_f4 =  {
   self.th_weapon = icestaff_f4;
   self.wfs = advanceweaponframe (9.00000, 11.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( !self.button0 ) {

         icestaff_idle ();
      } else {

         icestaff_shard ();

      }
   } else {

      if ( ((self.attack_finished <= time) && (self.weaponframe == 9.00000)) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            icestaff_blizzard ();
         } else {

            FireFreeze ();

         }

      }

   }
};


void  ()icestaff_f5 =  {
   self.th_weapon = icestaff_f5;
   self.wfs = advanceweaponframe (12.00000, 14.00000);
   if ( (self.wfs == WF_CYCLE_WRAPPED) ) {

      if ( !self.button0 ) {

         icestaff_idle ();
      } else {

         icestaff_shard ();

      }
   } else {

      if ( ((self.attack_finished <= time) && (self.weaponframe == 12.00000)) ) {

         if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

            icestaff_blizzard ();
         } else {

            FireFreeze ();

         }

      }

   }
};


void  ()icestaff_shard =  {
local float r = 0.00000;
   r = (rint ((random () * 4.00000)) + 1.00000);
   if ( (r == 1.00000) ) {

      icestaff_f1 ();
   } else {

      if ( (r == 2.00000) ) {

         icestaff_f2 ();
      } else {

         if ( (r == 3.00000) ) {

            icestaff_f3 ();
         } else {

            if ( (r == 4.00000) ) {

               icestaff_f4 ();
            } else {

               icestaff_f5 ();

            }

         }

      }

   }
};


void  ()Cru_Ice_Fire =  {
local float r = 0.00000;
   if ( (self.hull == HULL_NORMAL) ) {

      self.think = self.th_missile;
   } else {

      self.think = player_crusader_crouch_move;

   }
   if ( (self.artifact_active & ART_TOMEOFPOWER) ) {

      icestaff_blizzard ();
   } else {

      icestaff_shard ();

   }
};

