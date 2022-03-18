void  ()W_SetCurrentAmmo;
void  ()W_SetCurrentWeapon;

void  ()SUB_regen =  {
   self.model = self.mdl;
   self.solid = SOLID_TRIGGER;
   sound (self, CHAN_VOICE, "items/itmspawn.wav", 1.00000, ATTN_NORM);
   setorigin (self, self.origin);
};


void  ()noclass =  {
   dprint ("noclass spawned at");
   dprint (vtos (self.origin));
   dprint ("\n");
   remove (self);
};


void  ()PlaceItem =  {
local float oldz = 0.00000;
   self.mdl = self.model;
   self.flags = (self.flags | FL_ITEM);
   self.solid = SOLID_TRIGGER;
   self.movetype = MOVETYPE_TOSS;
   self.velocity = '0.00000 0.00000 0.00000';
   self.origin_z = (self.origin_z + 6.00000);
   oldz = self.origin_z;
   self.movetype = MOVETYPE_NONE;
};


void  ()StartItem =  {
   if ( self.owner ) {

      return ;

   }
   self.nextthink = (time + 0.20000);
   self.think = PlaceItem;
};


float  (entity e,float healamount,float ignore)T_Heal =  {
   if ( (e.health <= 0.00000) ) {

      return ( 0.00000 );

   }
   if ( (!ignore && (e.health >= other.max_health)) ) {

      return ( 0.00000 );

   }
   healamount = ceil (healamount);
   e.health = (e.health + healamount);
   if ( (!ignore && (e.health >= other.max_health)) ) {

      e.health = other.max_health;

   }
   if ( (e.health > 250.00000) ) {

      e.health = 250.00000;

   }
   return ( 1.00000 );
};

float H_ROTTEN   =  1.00000;
float H_MEGA   =  2.00000;
.float healamount;
.float healtype;
void  ()health_touch;
void  ()item_megahealth_rot;

void  ()item_megahealth =  {
   self.touch = health_touch;
   self.noise = "items/r_item2.wav";
   self.healamount = 100.00000;
   self.healtype = 2.00000;
   setsize (self, '0.00000 0.00000 0.00000', '32.00000 32.00000 56.00000');
   StartItem ();
};


void  ()health_touch =  {
local float amount = 0.00000;
local string s;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (self.healtype == 2.00000) ) {

      if ( (other.health >= 250.00000) ) {

         return ;

      }
      if ( !T_Heal (other, self.healamount, 1.00000) ) {

         return ;

      }
   } else {

      if ( !T_Heal (other, self.healamount, 0.00000) ) {

         return ;

      }

   }
   sprint (other, "You receive ");
   s = ftos (self.healamount);
   sprint (other, s);
   sprint (other, " health\n");
   sound (other, CHAN_ITEM, self.noise, 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.model = string_null;
   self.solid = SOLID_NOT;
   if ( (self.healtype == 2.00000) ) {

      other.items = (other.items | IT_SUPERHEALTH);
      self.nextthink = (time + 5.00000);
      self.think = item_megahealth_rot;
      self.owner = other;
   } else {

      if ( (deathmatch != 2.00000) ) {

         if ( deathmatch ) {

            self.nextthink = (time + 20.00000);

         }
         self.think = SUB_regen;

      }

   }
   activator = other;
   SUB_UseTargets ();
};


void  ()item_megahealth_rot =  {
   other = self.owner;
   if ( (other.health > other.max_health) ) {

      other.health = (other.health - 1.00000);
      self.nextthink = (time + 1.00000);
      return ;

   }
   other.items = (other.items - (other.items & IT_SUPERHEALTH));
   if ( (deathmatch == 1.00000) ) {

      self.nextthink = (time + 20.00000);
      self.think = SUB_regen;

   }
};

float MAX_INV   =  25.00000;

void  (entity AddTo,entity AddFrom)max_ammo2 =  {
   if ( ((AddTo.cnt_torch + AddFrom.cnt_torch) > MAX_INV) ) {

      AddFrom.cnt_torch = (MAX_INV - AddTo.cnt_torch);

   }
   if ( ((AddTo.cnt_h_boost + AddFrom.cnt_h_boost) > MAX_INV) ) {

      AddFrom.cnt_h_boost = (MAX_INV - AddTo.cnt_h_boost);

   }
   if ( ((AddTo.cnt_sh_boost + AddFrom.cnt_sh_boost) > MAX_INV) ) {

      AddFrom.cnt_sh_boost = (MAX_INV - AddTo.cnt_sh_boost);

   }
   if ( ((AddTo.cnt_mana_boost + AddFrom.cnt_mana_boost) > MAX_INV) ) {

      AddFrom.cnt_mana_boost = (MAX_INV - AddTo.cnt_mana_boost);

   }
   if ( ((AddTo.cnt_teleport + AddFrom.cnt_teleport) > MAX_INV) ) {

      AddFrom.cnt_teleport = (MAX_INV - AddTo.cnt_teleport);

   }
   if ( ((AddTo.cnt_tome + AddFrom.cnt_tome) > MAX_INV) ) {

      AddFrom.cnt_tome = (MAX_INV - AddTo.cnt_tome);

   }
   if ( ((AddTo.cnt_summon + AddFrom.cnt_summon) > MAX_INV) ) {

      AddFrom.cnt_summon = (MAX_INV - AddTo.cnt_summon);

   }
   if ( ((AddTo.cnt_mine + AddFrom.cnt_mine) > MAX_INV) ) {

      AddFrom.cnt_mine = (MAX_INV - AddTo.cnt_mine);

   }
   if ( ((AddTo.cnt_glyph + AddFrom.cnt_glyph) > MAX_INV) ) {

      AddFrom.cnt_glyph = (MAX_INV - AddTo.cnt_glyph);

   }
   if ( ((AddTo.cnt_haste + AddFrom.cnt_haste) > MAX_INV) ) {

      AddFrom.cnt_haste = (MAX_INV - AddTo.cnt_haste);

   }
   if ( ((AddTo.cnt_blast + AddFrom.cnt_blast) > MAX_INV) ) {

      AddFrom.cnt_blast = (MAX_INV - AddTo.cnt_blast);

   }
   if ( ((AddTo.cnt_polymorph + AddFrom.cnt_polymorph) > MAX_INV) ) {

      AddFrom.cnt_polymorph = (MAX_INV - AddTo.cnt_polymorph);

   }
   if ( ((AddTo.cnt_mirror + AddFrom.cnt_mirror) > MAX_INV) ) {

      AddFrom.cnt_mirror = (MAX_INV - AddTo.cnt_mirror);

   }
   if ( ((AddTo.cnt_cubeofforce + AddFrom.cnt_cubeofforce) > MAX_INV) ) {

      AddFrom.cnt_cubeofforce = (MAX_INV - AddTo.cnt_cubeofforce);

   }
   if ( ((AddTo.cnt_invincibility + AddFrom.cnt_invincibility) > MAX_INV) ) {

      AddFrom.cnt_invincibility = (MAX_INV - AddTo.cnt_invincibility);

   }
   if ( ((AddTo.bluemana + AddFrom.bluemana) > 200.00000) ) {

      AddFrom.bluemana = (200.00000 - AddTo.bluemana);

   }
   if ( ((AddTo.greenmana + AddFrom.greenmana) > 200.00000) ) {

      AddFrom.greenmana = (200.00000 - AddTo.greenmana);

   }
};


void  ()max_mana =  {
   if ( (other.bluemana > 200.00000) ) {

      other.bluemana = 200.00000;

   }
   if ( (other.greenmana > 200.00000) ) {

      other.greenmana = 200.00000;

   }
};


float  (float w)RankForWeapon =  {
   if ( (w == IT_LIGHTNING) ) {

      return ( 1.00000 );

   }
   if ( (w == IT_ROCKET_LAUNCHER) ) {

      return ( 2.00000 );

   }
   if ( (w == IT_SUPER_NAILGUN) ) {

      return ( 3.00000 );

   }
   if ( (w == IT_GRENADE_LAUNCHER) ) {

      return ( 4.00000 );

   }
   if ( (w == IT_SUPER_SHOTGUN) ) {

      return ( 5.00000 );

   }
   if ( (w == IT_NAILGUN) ) {

      return ( 6.00000 );

   }
   return ( 7.00000 );
};


void  (float old,float new)Deathmatch_Weapon =  {
local float or = 0.00000;
local float nr = 0.00000;
   or = RankForWeapon (self.weapon);
   nr = RankForWeapon (new);
   if ( (nr < or) ) {

      self.weapon = new;

   }
};

float  ()W_BestWeapon;

void  ()weapon_touch =  {
local float new = 0.00000;
local float old = 0.00000;
local entity stemp;
local float leave = 0.00000;
   if ( !(other.flags & FL_CLIENT) ) {

      return ;

   }
   if ( ((deathmatch == 2.00000) || coop) ) {

      leave = 1.00000;
   } else {

      leave = 0.00000;

   }
   other.oldweapon = other.weapon;
   if ( (self.classname == "wp_weapon2") ) {

      if ( (other.playerclass == CLASS_PALADIN) ) {

         self.netname = STR_VORPAL;
      } else {

         if ( (other.playerclass == CLASS_CRUSADER) ) {

            self.netname = STR_ICESTAFF;
         } else {

            if ( (other.playerclass == CLASS_NECROMANCER) ) {

               self.netname = STR_MAGICMISSILE;
            } else {

               if ( (other.playerclass == CLASS_ASSASSIN) ) {

                  self.netname = STR_GRENADES;

               }

            }

         }

      }
      new = IT_WEAPON2;
      other.bluemana += 25.00000;
   } else {

      if ( (self.classname == "wp_weapon3") ) {

         if ( (other.playerclass == CLASS_PALADIN) ) {

            self.netname = STR_AXE;
         } else {

            if ( (other.playerclass == CLASS_CRUSADER) ) {

               self.netname = STR_METEORSTAFF;
            } else {

               if ( (other.playerclass == CLASS_NECROMANCER) ) {

                  self.netname = STR_BONESHARD;
               } else {

                  if ( (other.playerclass == CLASS_ASSASSIN) ) {

                     self.netname = STR_CROSSBOW;

                  }

               }

            }

         }
         new = IT_WEAPON3;
         other.greenmana += 25.00000;
      } else {

         if ( (self.classname == "wp_weapon4_head") ) {

            if ( (other.playerclass == CLASS_PALADIN) ) {

               self.netname = STR_PURIFIER1;
            } else {

               if ( (other.playerclass == CLASS_CRUSADER) ) {

                  self.netname = STR_SUN1;
               } else {

                  if ( (other.playerclass == CLASS_NECROMANCER) ) {

                     self.netname = STR_SET1;
                  } else {

                     if ( (other.playerclass == CLASS_ASSASSIN) ) {

                        self.netname = STR_VINDICTUS1;

                     }

                  }

               }

            }
            new = IT_WEAPON4_1;
            other.bluemana += 25.00000;
            other.greenmana += 25.00000;
            if ( (other.items & IT_WEAPON4_2) ) {

               new += IT_WEAPON4;

            }
         } else {

            if ( (self.classname == "wp_weapon4_staff") ) {

               if ( (other.playerclass == CLASS_PALADIN) ) {

                  self.netname = STR_PURIFIER2;
               } else {

                  if ( (other.playerclass == CLASS_CRUSADER) ) {

                     self.netname = STR_SUN2;
                  } else {

                     if ( (other.playerclass == CLASS_NECROMANCER) ) {

                        self.netname = STR_SET2;
                     } else {

                        if ( (other.playerclass == CLASS_ASSASSIN) ) {

                           self.netname = STR_VINDICTUS2;

                        }

                     }

                  }

               }
               new = IT_WEAPON4_2;
               other.bluemana += 25.00000;
               other.greenmana += 25.00000;
               if ( (other.items & IT_WEAPON4_1) ) {

                  new += IT_WEAPON4;

               }
            } else {

               objerror ("weapon_touch: unknown classname");

            }

         }

      }

   }
   sprint (other, STR_YOUGOTTHE);
   sprint (other, self.netname);
   sprint (other, "\n");
   sound (other, CHAN_ITEM, "weapons/weappkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   max_mana ();
   old = other.items;
   other.items = (other.items | new);
   stemp = self;
   self = other;
   if ( !deathmatch ) {

      self.weapon = W_BestWeapon ();
   } else {

      Deathmatch_Weapon (old, new);

   }
   W_SetCurrentWeapon ();
   self = stemp;
   if ( leave ) {

      return ;

   }
   self.model = string_null;
   self.solid = SOLID_NOT;
   if ( (deathmatch == 1.00000) ) {

      self.nextthink = (time + 30.00000);

   }
   self.think = SUB_regen;
   activator = other;
   SUB_UseTargets ();
};


void  ()powerup_touch =  {
local entity stemp;
local float best = 0.00000;
   if ( ((other.health <= 0.00000) || (other.classname != "player")) ) {

      return ;

   }
   sprint (other, "You got the ");
   sprint (other, self.netname);
   sprint (other, "\n");
   if ( deathmatch ) {

      self.mdl = self.model;
      if ( ((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility")) ) {

         self.nextthink = (time + (60.00000 * 5.00000));
      } else {

         self.nextthink = (time + 60.00000);

      }
      self.think = SUB_regen;

   }
   sound (other, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   other.items = (other.items | self.items);
   self.model = string_null;
   if ( (self.classname == "item_artifact_invulnerability") ) {

      other.invincible_time = 1.00000;
      other.invincible_finished = (time + 30.00000);

   }
   if ( (self.classname == "item_artifact_invisibility") ) {

      other.invisible_time = 1.00000;
      other.invisible_finished = (time + 30.00000);

   }
   activator = other;
   SUB_UseTargets ();
};


void  ()ihealth_touch =  {
   if ( ((other.classname != "player") || (other.health < 1.00000)) ) {

      return ;

   }
   if ( (other.health < 200.00000) ) {

      sound (other, CHAN_VOICE, "items/itempkup.wav", 1.00000, ATTN_NORM);
      other.health += 10.00000;
      self.model = string_null;
      self.solid = SOLID_NOT;
      if ( (deathmatch == 1.00000) ) {

         self.nextthink = (time + RESPAWN_TIME);

      }
      self.think = SUB_regen;
      activator = other;
      SUB_UseTargets ();

   }
};


void  ()item_health =  {
   self.touch = ihealth_touch;
   precache_model ("models/i_hboost.mdl");
   setmodel (self, "models/i_hboost.mdl");
   precache_sound ("items/itempkup.wav");
   setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 32.00000');
   StartItem ();
};


void  ()mana_touch =  {
   if ( ((other.classname != "player") || (other.health < 1.00000)) ) {

      return ;

   }
   if ( ((self.owner == other) && (self.artifact_ignore_owner_time > time)) ) {

      return ;

   }
   if ( (self.artifact_ignore_time > time) ) {

      return ;

   }
   if ( ((self.classname == "item_mana_green") && (other.greenmana >= 200.00000)) ) {

      return ;

   }
   if ( ((self.classname == "item_mana_blue") && (other.bluemana >= 200.00000)) ) {

      return ;

   }
   if ( (((self.classname == "item_mana_both") && (other.bluemana >= 200.00000)) && (other.greenmana >= 200.00000)) ) {

      return ;

   }
   sound (other, CHAN_VOICE, "items/itempkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   if ( (self.classname == "item_mana_green") ) {

      other.greenmana += self.count;
   } else {

      if ( (self.classname == "item_mana_blue") ) {

         other.bluemana += self.count;
      } else {

         other.greenmana += self.count;
         other.bluemana += self.count;

      }

   }
   max_mana ();
   self.model = string_null;
   self.solid = SOLID_NOT;
   if ( (deathmatch == 1.00000) ) {

      self.nextthink = (time + RESPAWN_TIME);

   }
   self.think = SUB_regen;
   activator = other;
   SUB_UseTargets ();
};


void  (float amount)spawn_item_mana_green =  {
   setmodel (self, "models/i_gmana.mdl");
   self.touch = mana_touch;
   setsize (self, '-16.00000 -16.00000 -45.00000', '16.00000 16.00000 20.00000');
   self.classname = "item_mana_green";
   self.count = amount;
   StartItem ();
};


void  ()item_mana_green =  {
   spawn_item_mana_green (10.00000);
};


void  (float amount)spawn_item_mana_blue =  {
   self.touch = mana_touch;
   setmodel (self, "models/i_bmana.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.classname = "item_mana_blue";
   self.count = amount;
   StartItem ();
};


void  ()item_mana_blue =  {
   spawn_item_mana_blue (10.00000);
};


void  ()item_mana_both =  {
   self.touch = mana_touch;
   setmodel (self, "models/i_btmana.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.classname = "item_mana_both";
   self.count = 10.00000;
   StartItem ();
};


void  ()armor_touch =  {
local float type = 0.00000;
local float value = 0.00000;
local float bit = 0.00000;
   if ( ((other.classname != "player") || (other.health <= 0.00000)) ) {

      return ;

   }
   if ( (self.classname == "item_armor_amulet") ) {

      other.armor_amulet = 20.00000;
   } else {

      if ( (self.classname == "item_armor_bracer") ) {

         other.armor_bracer = 20.00000;
      } else {

         if ( (self.classname == "item_armor_breastplate") ) {

            other.armor_breastplate = 20.00000;
         } else {

            if ( (self.classname == "item_armor_helmet") ) {

               other.armor_helmet = 20.00000;

            }

         }

      }

   }
   self.solid = SOLID_NOT;
   self.model = string_null;
   if ( (deathmatch == 1.00000) ) {

      self.nextthink = (time + RESPAWN_TIME);

   }
   self.think = SUB_regen;
   sprint (other, STR_YOUHAVETHE);
   sprint (other, self.netname);
   sprint (other, "\n");
   sound (other, CHAN_ITEM, "items/armrpkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   activator = other;
   SUB_UseTargets ();
};


void  ()spawn_item_armor_helmet =  {
   setmodel (self, "models/i_helmet.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.touch = armor_touch;
   self.netname = STR_HELMET;
   StartItem ();
};


void  ()item_armor_helmet =  {
   spawn_item_armor_helmet ();
};


void  ()spawn_item_armor_breastplate =  {
   setmodel (self, "models/i_bplate.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.touch = armor_touch;
   self.netname = STR_BREASTPLATE;
   StartItem ();
};


void  ()item_armor_breastplate =  {
   spawn_item_armor_breastplate ();
};


void  ()spawn_item_armor_bracer =  {
   setmodel (self, "models/i_bracer.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.touch = armor_touch;
   self.netname = STR_BRACER;
   StartItem ();
};


void  ()item_armor_bracer =  {
   spawn_item_armor_bracer ();
};


void  ()spawn_item_armor_amulet =  {
   setmodel (self, "models/i_amulet.mdl");
   setsize (self, '-8.00000 -8.00000 -45.00000', '8.00000 8.00000 20.00000');
   self.touch = armor_touch;
   self.netname = STR_AMULETOFPROTECT;
   StartItem ();
};


void  ()item_armor_amulet =  {
   spawn_item_armor_amulet ();
};


void  ()BackpackTouch =  {
local string s;
local float best = 0.00000;
local float old = 0.00000;
local float new = 0.00000;
local entity stemp;
local float ItemCount = 0.00000;
   if ( (other.classname != "player") ) {

      return ;

   }
   if ( (other.health <= 0.00000) ) {

      return ;

   }
   if ( ((self.owner == other) && (self.artifact_ignore_owner_time > time)) ) {

      return ;

   }
   if ( (self.artifact_ignore_time > time) ) {

      return ;

   }
   ItemCount = 0.00000;
   sprint (other, "You get ");
   max_ammo2 (other, self);
   if ( (self.cnt_torch > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_torch += self.cnt_torch;
      s = ftos (self.cnt_torch);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_TORCH);

   }
   if ( (self.cnt_h_boost > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_h_boost += self.cnt_h_boost;
      s = ftos (self.cnt_h_boost);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_HEALTHBOOST);

   }
   if ( (self.cnt_sh_boost > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_sh_boost += self.cnt_sh_boost;
      s = ftos (self.cnt_sh_boost);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_SUPERHEALTHBOOST);

   }
   if ( (self.cnt_mana_boost > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_mana_boost += self.cnt_mana_boost;
      s = ftos (self.cnt_mana_boost);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_MANABOOST);

   }
   if ( (self.cnt_teleport > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_teleport += self.cnt_teleport;
      s = ftos (self.cnt_teleport);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_TELEPORT);

   }
   if ( (self.cnt_tome > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_tome += self.cnt_tome;
      s = ftos (self.cnt_tome);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_TOME);

   }
   if ( (self.cnt_summon > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_summon += self.cnt_summon;
      s = ftos (self.cnt_summon);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_SUMMON);

   }
   if ( (self.cnt_mine > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_mine += self.cnt_mine;
      s = ftos (self.cnt_mine);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_LANDMINE);

   }
   if ( (self.cnt_glyph > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_glyph += self.cnt_glyph;
      s = ftos (self.cnt_glyph);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_GLYPH);

   }
   if ( (self.cnt_haste > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_haste += self.cnt_haste;
      s = ftos (self.cnt_haste);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_HASTE);

   }
   if ( (self.cnt_blast > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_blast += self.cnt_blast;
      s = ftos (self.cnt_blast);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_BLAST);

   }
   if ( (self.cnt_polymorph > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_polymorph += self.cnt_polymorph;
      s = ftos (self.cnt_polymorph);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_POLYMORPH);

   }
   if ( (self.cnt_mirror > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_mirror += self.cnt_mirror;
      s = ftos (self.cnt_mirror);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_MIRROR);

   }
   if ( (self.cnt_cubeofforce > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_cubeofforce += self.cnt_cubeofforce;
      s = ftos (self.cnt_cubeofforce);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_CUBEOFFORCE);

   }
   if ( (self.cnt_invincibility > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.cnt_invincibility += self.cnt_invincibility;
      s = ftos (self.cnt_invincibility);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_INVINCIBILITY);

   }
   if ( (self.bluemana > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.bluemana += self.bluemana;
      s = ftos (self.bluemana);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_BLUEMANA);

   }
   if ( (self.greenmana > 0.00000) ) {

      if ( ItemCount ) {

         sprint (other, ", ");

      }
      ItemCount += 1.00000;
      other.greenmana += self.greenmana;
      s = ftos (self.greenmana);
      sprint (other, s);
      sprint (other, " ");
      sprint (other, STR_GREENMANA);

   }
   if ( !ItemCount ) {

      sprint (other, "...Nothing!");

   }
   stemp = self;
   self = other;
   best = W_BestWeapon ();
   self = stemp;
   sprint (other, "\n");
   sound (other, CHAN_ITEM, "weapons/ammopkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   remove (self);
   self = other;
   if ( !deathmatch ) {

      self.weapon = new;
   } else {

      Deathmatch_Weapon (old, new);

   }
   W_SetCurrentWeapon ();
};


void  ()DropBackpack =  {
local entity item;
local entity old_self;
local float total = 0.00000;
   item = spawn ();
   total = 0.00000;
   item.cnt_torch = self.cnt_torch;
   total += self.cnt_torch;
   item.cnt_h_boost = self.cnt_h_boost;
   total += self.cnt_h_boost;
   item.cnt_sh_boost = self.cnt_sh_boost;
   total += self.cnt_sh_boost;
   item.cnt_mana_boost = self.cnt_mana_boost;
   total += self.cnt_mana_boost;
   item.cnt_teleport = self.cnt_teleport;
   total += self.cnt_teleport;
   item.cnt_tome = self.cnt_tome;
   total += self.cnt_tome;
   item.cnt_summon = self.cnt_summon;
   total += self.cnt_summon;
   item.cnt_mine = self.cnt_mine;
   total += self.cnt_mine;
   item.cnt_glyph = self.cnt_glyph;
   total += self.cnt_glyph;
   item.cnt_haste = self.cnt_haste;
   total += self.cnt_haste;
   item.cnt_blast = self.cnt_blast;
   total += self.cnt_blast;
   item.cnt_polymorph = self.cnt_polymorph;
   total += self.cnt_polymorph;
   item.cnt_mirror = self.cnt_mirror;
   total += self.cnt_mirror;
   item.cnt_cubeofforce = self.cnt_cubeofforce;
   total += self.cnt_cubeofforce;
   item.cnt_invincibility = self.cnt_invincibility;
   total += self.cnt_invincibility;
   item.bluemana = self.bluemana;
   item.greenmana = self.greenmana;
   if ( ((!total && !item.bluemana) && !item.greenmana) ) {

      remove (item);
      return ;

   }
   item.origin = (self.origin - '0.00000 0.00000 24.00000');
   item.flags = FL_ITEM;
   item.solid = SOLID_TRIGGER;
   item.movetype = MOVETYPE_TOSS;
   item.owner = self;
   item.artifact_ignore_owner_time = (time + 2.00000);
   item.artifact_ignore_time = (time + 1.00000);
   if ( (((((total == 1.00000) && !item.bluemana) && !item.greenmana) || (((total == 0.00000) && item.bluemana) && !item.greenmana)) || (((total == 0.00000) && !item.bluemana) && item.greenmana)) ) {

      item.velocity_z = 400.00000;
      item.velocity_x = (-20.00000 + (random () * 40.00000));
      item.velocity_y = (-20.00000 + (random () * 40.00000));
      old_self = self;
      self = item;
      self.artifact_respawn = deathmatch;
      if ( item.cnt_torch ) {

         spawn_artifact (ARTIFACT_TORCH, NO_RESPAWN);
      } else {

         if ( item.cnt_h_boost ) {

            spawn_artifact (ARTIFACT_HP_BOOST, NO_RESPAWN);
         } else {

            if ( item.cnt_sh_boost ) {

               spawn_artifact (ARTIFACT_SUPER_HP_BOOST, NO_RESPAWN);
            } else {

               if ( item.cnt_mana_boost ) {

                  spawn_artifact (ARTIFACT_MANA_BOOST, NO_RESPAWN);
               } else {

                  if ( item.cnt_teleport ) {

                     spawn_artifact (ARTIFACT_TELEPORT, NO_RESPAWN);
                  } else {

                     if ( item.cnt_tome ) {

                        spawn_artifact (ARTIFACT_TOME, NO_RESPAWN);
                     } else {

                        if ( item.cnt_summon ) {

                           spawn_artifact (ARTIFACT_SUMMON, NO_RESPAWN);
                        } else {

                           if ( item.cnt_mine ) {

                              spawn_artifact (ARTIFACT_MINE, NO_RESPAWN);
                           } else {

                              if ( item.cnt_glyph ) {

                                 spawn_artifact (ARTIFACT_GLYPH, NO_RESPAWN);
                              } else {

                                 if ( item.cnt_haste ) {

                                    spawn_artifact (ARTIFACT_HASTE, NO_RESPAWN);
                                 } else {

                                    if ( item.cnt_blast ) {

                                       spawn_artifact (ARTIFACT_BLAST, NO_RESPAWN);
                                    } else {

                                       if ( item.cnt_polymorph ) {

                                          spawn_artifact (ARTIFACT_POLYMORPH, NO_RESPAWN);
                                       } else {

                                          if ( item.cnt_mirror ) {

                                             spawn_artifact (ARTIFACT_MIRROR, NO_RESPAWN);
                                          } else {

                                             if ( item.cnt_cubeofforce ) {

                                                spawn_artifact (ARTIFACT_CUBEOFFORCE, NO_RESPAWN);
                                             } else {

                                                if ( item.cnt_invincibility ) {

                                                   spawn_artifact (ARTIFACT_INVINCIBILITY, NO_RESPAWN);
                                                } else {

                                                   if ( item.bluemana ) {

                                                      spawn_item_mana_blue (self.bluemana);
                                                   } else {

                                                      if ( item.greenmana ) {

                                                         spawn_item_mana_green (self.greenmana);
                                                      } else {

                                                         dprint ("Bad backpack!");
                                                         remove (item);
                                                         self = old_self;
                                                         return ;

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

               }

            }

         }

      }
      self = old_self;
   } else {

      item.velocity_z = 300.00000;
      item.velocity_x = (-40.00000 + (random () * 80.00000));
      item.velocity_y = (-40.00000 + (random () * 80.00000));
      setmodel (item, "models/backpack.mdl");
      setsize (item, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
      item.touch = BackpackTouch;
      item.nextthink = (time + 120.00000);
      item.think = SUB_Remove;

   }
};

