void  ()SUB_regen;
void  ()StartItem;

void  ()artifact_touch =  {
local entity stemp;
local float amount = 0.00000;
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
   if ( self.artifact_respawn ) {

      self.mdl = self.model;
      self.nextthink = (time + 60.00000);
      self.think = SUB_regen;

   }
   sound (other, CHAN_VOICE, "items/artpkup.wav", 1.00000, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   self.model = string_null;
   if ( (self.netname == STR_TORCH) ) {

      other.cnt_torch += 1.00000;
   } else {

      if ( (self.netname == STR_HEALTHBOOST) ) {

         other.cnt_h_boost += 1.00000;
      } else {

         if ( (self.netname == STR_SUPERHEALTHBOOST) ) {

            other.cnt_sh_boost += 1.00000;
         } else {

            if ( (self.netname == STR_MANABOOST) ) {

               other.cnt_mana_boost += 1.00000;
            } else {

               if ( (self.netname == STR_TELEPORT) ) {

                  other.cnt_teleport += 1.00000;
               } else {

                  if ( (self.netname == STR_TOME) ) {

                     other.cnt_tome += 1.00000;
                  } else {

                     if ( (self.netname == STR_SUMMON) ) {

                        other.cnt_summon += 1.00000;
                     } else {

                        if ( (self.netname == STR_LANDMINE) ) {

                           other.cnt_mine += 1.00000;
                        } else {

                           if ( (self.netname == STR_GLYPH) ) {

                              other.cnt_glyph += 1.00000;
                           } else {

                              if ( (self.netname == STR_HASTE) ) {

                                 other.cnt_haste += 1.00000;
                              } else {

                                 if ( (self.netname == STR_BLAST) ) {

                                    other.cnt_blast += 1.00000;
                                 } else {

                                    if ( (self.netname == STR_POLYMORPH) ) {

                                       other.cnt_polymorph += 1.00000;
                                    } else {

                                       if ( (self.netname == STR_MIRROR) ) {

                                          other.cnt_mirror += 1.00000;
                                       } else {

                                          if ( (self.netname == STR_CUBEOFFORCE) ) {

                                             other.cnt_cubeofforce += 1.00000;
                                          } else {

                                             if ( (self.netname == STR_INVINCIBILITY) ) {

                                                other.cnt_invincibility += 1.00000;
                                             } else {

                                                if ( (self.classname == "art_sword_and_crown") ) {

                                                   centerprint (other, "You are victorious!\n");
                                                   bprint (other.netname);
                                                   bprint (" has captured the Crown!\n");

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
   activator = other;
   SUB_UseTargets ();
   if ( !self.artifact_respawn ) {

      remove (self);

   }
};


void  ()Artifact_Cheat =  {
   self.cnt_haste = 20.00000;
   self.cnt_mana_boost = 20.00000;
   self.cnt_sh_boost = 20.00000;
   self.cnt_h_boost = 20.00000;
   self.cnt_teleport = 20.00000;
   self.cnt_tome = 20.00000;
   self.cnt_torch = 20.00000;
};


void  (string modelname,string art_name,float respawnflag)GenerateArtifactModel =  {
   if ( respawnflag ) {

      self.artifact_respawn = deathmatch;

   }
   setmodel (self, modelname);
   self.netname = art_name;
   if ( (modelname != "models/a_xray.mdl") ) {

      self.touch = artifact_touch;

   }
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   StartItem ();
};


void  (float artifact,float respawnflag)spawn_artifact =  {
   if ( (artifact == ARTIFACT_XRAY) ) {

      GenerateArtifactModel ("models/a_xray.mdl", STR_XRAY, respawnflag);
   } else {

      if ( (artifact == ARTIFACT_HASTE) ) {

         GenerateArtifactModel ("models/a_haste.mdl", STR_HASTE, respawnflag);
      } else {

         if ( (artifact == ARTIFACT_POLYMORPH) ) {

            GenerateArtifactModel ("models/a_poly.mdl", STR_POLYMORPH, respawnflag);
         } else {

            if ( (artifact == ARTIFACT_GLYPH) ) {

               GenerateArtifactModel ("models/a_glyph.mdl", STR_GLYPH, respawnflag);
            } else {

               if ( (artifact == ARTIFACT_INVISIBILITY) ) {

                  GenerateArtifactModel ("models/a_invis.mdl", STR_INVISIBILITY, respawnflag);
               } else {

                  if ( (artifact == ARTIFACT_GROWTH) ) {

                     GenerateArtifactModel ("models/a_growth.mdl", STR_GROWTH, respawnflag);
                  } else {

                     if ( (artifact == ARTIFACT_INVINCIBILITY) ) {

                        GenerateArtifactModel ("models/a_invinc.mdl", STR_INVINCIBILITY, respawnflag);
                     } else {

                        if ( (artifact == ARTIFACT_CUBEOFFORCE) ) {

                           GenerateArtifactModel ("models/a_cube.mdl", STR_CUBEOFFORCE, respawnflag);
                        } else {

                           if ( (artifact == ARTIFACT_MIRROR) ) {

                              GenerateArtifactModel ("models/a_mirror.mdl", STR_MIRROR, respawnflag);
                           } else {

                              if ( (artifact == ARTIFACT_MINE) ) {

                                 GenerateArtifactModel ("models/a_mine.mdl", STR_LANDMINE, respawnflag);
                              } else {

                                 if ( (artifact == ARTIFACT_SUMMON) ) {

                                    GenerateArtifactModel ("models/a_summon.mdl", STR_SUMMON, respawnflag);
                                 } else {

                                    if ( (artifact == ARTIFACT_TOME) ) {

                                       GenerateArtifactModel ("models/a_tome.mdl", STR_TOME, respawnflag);
                                    } else {

                                       if ( (artifact == ARTIFACT_TELEPORT) ) {

                                          GenerateArtifactModel ("models/a_telprt.mdl", STR_TELEPORT, respawnflag);
                                       } else {

                                          if ( (artifact == ARTIFACT_MANA_BOOST) ) {

                                             GenerateArtifactModel ("models/a_mboost.mdl", STR_MANABOOST, respawnflag);
                                          } else {

                                             if ( (artifact == ARTIFACT_BLAST) ) {

                                                GenerateArtifactModel ("models/a_blast.mdl", STR_BLAST, respawnflag);
                                             } else {

                                                if ( (artifact == ARTIFACT_TORCH) ) {

                                                   GenerateArtifactModel ("models/a_torch.mdl", STR_TORCH, respawnflag);
                                                } else {

                                                   if ( (artifact == ARTIFACT_HP_BOOST) ) {

                                                      GenerateArtifactModel ("models/a_hboost.mdl", STR_HEALTHBOOST, respawnflag);
                                                   } else {

                                                      if ( (artifact == ARTIFACT_SUPER_HP_BOOST) ) {

                                                         GenerateArtifactModel ("models/a_shbost.mdl", STR_SUPERHEALTHBOOST, respawnflag);

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

   }
};


void  ()DecrementSuperHealth =  {
local float wait_time = 0.00000;
local float over = 0.00000;
local float decr_health = 0.00000;
   if ( (self.health > self.max_health) ) {

      if ( (self.health < 200.00000) ) {

         wait_time = 1.00000;
         decr_health = 1.00000;
      } else {

         if ( (self.health < 400.00000) ) {

            decr_health = 1.00000;
            over = (200.00000 - (self.health - 200.00000));
            wait_time = (over / 200.00000);
            if ( (wait_time < 0.05000) ) {

               wait_time = 0.05000;

            }
         } else {

            wait_time = 0.05000;
            over = (self.health - 400.00000);
            decr_health = (over * 0.01600);
            decr_health = ceil (decr_health);
            if ( (decr_health < 2.00000) ) {

               decr_health = 2.00000;

            }

         }

      }
      self.health = (self.health - decr_health);
      self.healthtime = (time + wait_time);
   } else {

      self.artifact_flags = (self.artifact_flags - AFL_SUPERHEALTH);

   }
};


void  ()use_super_healthboost =  {
   self.healthtime = (time + 0.05000);
   if ( (self.health < 1000.00000) ) {

      self.health = (self.health + 100.00000);

   }
   if ( (self.health > 999.00000) ) {

      self.health = 999.00000;

   }
   self.cnt_sh_boost -= 1.00000;
   self.artifact_flags = (self.artifact_flags | AFL_SUPERHEALTH);
};


void  ()art_SuperHBoost =  {
   spawn_artifact (ARTIFACT_SUPER_HP_BOOST, RESPAWN);
};


void  ()use_healthboost =  {
   if ( (self.health >= self.max_health) ) {

      return ;

   }
   self.cnt_h_boost -= 1.00000;
   self.health += 25.00000;
   if ( (self.health > self.max_health) ) {

      self.health = self.max_health;

   }
};


void  ()art_HealthBoost =  {
   spawn_artifact (ARTIFACT_HP_BOOST, RESPAWN);
};


void  ()art_torch =  {
   spawn_artifact (ARTIFACT_TORCH, RESPAWN);
};


void  ()KillTorch =  {
   self.effects = 0.00000;
   if ( (self.artifact_flags & AFL_TORCH) ) {

      self.artifact_flags = (self.artifact_flags - AFL_TORCH);

   }
};


void  ()DimTorch =  {
   sound (self, CHAN_BODY, "raven/kiltorch.wav", 1.00000, ATTN_IDLE);
   self.effects = EF_DIMLIGHT;
   self.torchtime = (time + 3.00000);
   self.torchthink = KillTorch;
};


void  ()FullTorch =  {
   sound (self, CHAN_BODY, "raven/fire1.wav", 1.00000, ATTN_NORM);
   self.effects = EF_TORCHLIGHT;
   self.torchtime = (time + 8.00000);
   self.torchthink = DimTorch;
};


void  ()UseTorch =  {
   if ( ((self.effects != EF_DIMLIGHT) && (self.effects != EF_BRIGHTLIGHT)) ) {

      sound (self, CHAN_WEAPON, "raven/littorch.wav", 1.00000, ATTN_NORM);
      self.effects = EF_DIMLIGHT;
      self.torchtime = (time + 1.00000);
      self.torchthink = FullTorch;
      self.artifact_flags = (self.artifact_flags | AFL_TORCH);
      self.cnt_torch -= 1.00000;
   } else {

      KillTorch ();

   }
};


void  ()art_blastradius =  {
   spawn_artifact (ARTIFACT_BLAST, RESPAWN);
};


void  ()UseManaBoost =  {
   if ( ((self.bluemana >= 200.00000) && (self.greenmana >= 200.00000)) ) {

      return ;

   }
   self.bluemana = 200.00000;
   self.greenmana = 200.00000;
   if ( (self.bluemana > 200.00000) ) {

      self.bluemana = 200.00000;

   }
   if ( (self.greenmana > 200.00000) ) {

      self.greenmana = 200.00000;

   }
   self.cnt_mana_boost -= 1.00000;
};


void  ()art_manaboost =  {
   spawn_artifact (ARTIFACT_MANA_BOOST, RESPAWN);
};


void  ()art_teleport =  {
   spawn_artifact (ARTIFACT_TELEPORT, RESPAWN);
};


void  ()art_tomeofpower =  {
   spawn_artifact (ARTIFACT_TOME, RESPAWN);
};


void  ()art_summon =  {
   spawn_artifact (ARTIFACT_SUMMON, RESPAWN);
};


void  ()art_mine =  {
   spawn_artifact (ARTIFACT_MINE, RESPAWN);
};


void  ()art_glyph =  {
   spawn_artifact (ARTIFACT_GLYPH, RESPAWN);
};


void  ()art_haste =  {
   spawn_artifact (ARTIFACT_HASTE, RESPAWN);
};


void  ()art_polymorph =  {
   spawn_artifact (ARTIFACT_POLYMORPH, RESPAWN);
};


void  ()art_mirror =  {
   spawn_artifact (ARTIFACT_MIRROR, RESPAWN);
};


void  ()art_cubeofforce =  {
   spawn_artifact (ARTIFACT_CUBEOFFORCE, RESPAWN);
};


void  ()art_invincibility =  {
   spawn_artifact (ARTIFACT_INVINCIBILITY, RESPAWN);
};


void  ()art_growth =  {
   spawn_artifact (ARTIFACT_GROWTH, RESPAWN);
};


void  ()art_invisibility =  {
   spawn_artifact (ARTIFACT_INVISIBILITY, RESPAWN);
};


void  ()art_xray =  {
   spawn_artifact (ARTIFACT_XRAY, RESPAWN);
};


void  ()spawn_art_sword_and_crown =  {
   setmodel (self, "models/xcalibur.mdl");
   self.netname = "Sword";
   self.touch = artifact_touch;
   setsize (self, '-8.00000 -8.00000 -44.00000', '8.00000 8.00000 20.00000');
   StartItem ();
};


void  ()art_sword_and_crown =  {
   precache_model ("models/xcalibur.mdl");
   self.artifact_respawn = deathmatch;
   spawn_art_sword_and_crown ();
};


void  ()item_spawner_use =  {
   DropBackpack ();
};


void  ()item_spawner =  {
   setmodel (self, self.model);
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   self.modelindex = 0.00000;
   self.model = "";
   self.effects = EF_NODRAW;
   self.use = item_spawner_use;
};

