
void  ()ChunkRemove =  {
   chunk_cnt -= 1.00000;
   SUB_Remove ();
};


vector  ()ChunkVelocity =  {
local vector v = '0.00000 0.00000 0.00000';
   v_x = (300.00000 * crandom ());
   v_y = (300.00000 * crandom ());
   v_z = (300.00000 + (100.00000 * random ()));
   v = (v * 0.70000);
   return ( v );
};


void  (string chunkname,vector location,float life_time)ThrowSingleChunk =  {
local entity chunk;
   if ( (chunk_cnt < CHUNK_MAX) ) {

      chunk = spawn ();
      setmodel (chunk, chunkname);
      chunk.frame = 0.00000;
      setsize (chunk, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      chunk.movetype = MOVETYPE_BOUNCE;
      chunk.solid = SOLID_NOT;
      chunk.takedamage = DAMAGE_NO;
      chunk.velocity = ChunkVelocity ();
      chunk.think = ChunkRemove;
      chunk.flags = (chunk.flags - (chunk.flags & FL_ONGROUND));
      chunk.origin = location;
      chunk.avelocity_x = (random () * 10.00000);
      chunk.avelocity_y = (random () * 10.00000);
      chunk.avelocity_z = (random () * 10.00000);
      chunk.ltime = time;
      chunk.nextthink = (time + life_time);
      chunk_cnt += 1.00000;

   }
};


void  (vector space)CreateSpriteChunks =  {
local entity sprite;
   sprite = spawn ();
   space_x = (space_x * random ());
   space_y = (space_y * random ());
   space_z = (space_z * random ());
   setorigin (sprite, (self.absmin + space));
   if ( (self.thingtype == THINGTYPE_GLASS) ) {

      setmodel (sprite, "gfx/glass.spr");
   } else {

      setmodel (sprite, "gfx/stone.spr");

   }
   setsize (sprite, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   sprite.movetype = MOVETYPE_BOUNCE;
   sprite.solid = SOLID_NOT;
   sprite.velocity = ChunkVelocity ();
   sprite.think = SUB_Remove;
   sprite.ltime = time;
   sprite.nextthink = ((time + 1.00000) + (random () * 1.00000));
};


void  (vector org,float chunk_count)MeatChunks =  {
local float final = 0.00000;
local entity chunk;
   while ( chunk_count ) {

      chunk = spawn ();
      chunk_count -= 1.00000;
      final = random ();
      if ( (final < 0.33000) ) {

         setmodel (chunk, "models/flesh1.mdl");
      } else {

         if ( (final < 0.66000) ) {

            setmodel (chunk, "models/flesh2.mdl");
         } else {

            setmodel (chunk, "models/flesh3.mdl");

         }

      }
      setsize (chunk, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
      chunk.movetype = MOVETYPE_BOUNCE;
      chunk.solid = SOLID_NOT;
      chunk.velocity = ChunkVelocity ();
      chunk.think = ChunkRemove;
      chunk.avelocity_x = (random () * 1200.00000);
      chunk.avelocity_y = (random () * 1200.00000);
      chunk.avelocity_z = (random () * 1200.00000);
      chunk.ltime = time;
      chunk.nextthink = ((time + 1.00000) + random ());
      setorigin (chunk, org);

   }
};


void  (vector space,float scalemod)CreateModelChunks =  {
local entity chunk;
local float final = 0.00000;
   chunk = spawn ();
   space_x = (space_x * random ());
   space_y = (space_y * random ());
   space_z = (space_z * random ());
   setorigin (chunk, (self.absmin + space));
   final = random ();
   if ( (self.thingtype == THINGTYPE_GLASS) ) {

      if ( (final < 0.20000) ) {

         setmodel (chunk, "models/shard1.mdl");
      } else {

         if ( (final < 0.40000) ) {

            setmodel (chunk, "models/shard2.mdl");
         } else {

            if ( (final < 0.60000) ) {

               setmodel (chunk, "models/shard3.mdl");
            } else {

               if ( (final < 0.80000) ) {

                  setmodel (chunk, "models/shard4.mdl");
               } else {

                  setmodel (chunk, "models/shard5.mdl");

               }

            }

         }

      }
   } else {

      if ( (self.thingtype == THINGTYPE_WOOD) ) {

         if ( (final < 0.25000) ) {

            setmodel (chunk, "models/splnter1.mdl");
         } else {

            if ( (final < 0.50000) ) {

               setmodel (chunk, "models/splnter2.mdl");
            } else {

               if ( (final < 0.75000) ) {

                  setmodel (chunk, "models/splnter3.mdl");
               } else {

                  setmodel (chunk, "models/splnter4.mdl");

               }

            }

         }
      } else {

         if ( (self.thingtype == THINGTYPE_METAL) ) {

            if ( (final < 0.25000) ) {

               setmodel (chunk, "models/metlchk1.mdl");
            } else {

               if ( (final < 0.50000) ) {

                  setmodel (chunk, "models/metlchk2.mdl");
               } else {

                  if ( (final < 0.75000) ) {

                     setmodel (chunk, "models/metlchk3.mdl");
                  } else {

                     setmodel (chunk, "models/metlchk4.mdl");

                  }

               }

            }
         } else {

            if ( (self.thingtype == THINGTYPE_FLESH) ) {

               if ( (final < 0.33000) ) {

                  setmodel (chunk, "models/flesh1.mdl");
               } else {

                  if ( (final < 0.66000) ) {

                     setmodel (chunk, "models/flesh2.mdl");
                  } else {

                     setmodel (chunk, "models/flesh3.mdl");

                  }

               }
            } else {

               if ( (self.thingtype == THINGTYPE_GREYSTONE) ) {

                  if ( (final < 0.25000) ) {

                     setmodel (chunk, "models/schunk1.mdl");
                  } else {

                     if ( (final < 0.50000) ) {

                        setmodel (chunk, "models/schunk2.mdl");
                     } else {

                        if ( (final < 0.75000) ) {

                           setmodel (chunk, "models/schunk3.mdl");
                        } else {

                           setmodel (chunk, "models/schunk4.mdl");

                        }

                     }

                  }
                  chunk.skin = 0.00000;
               } else {

                  if ( (self.thingtype == THINGTYPE_BROWNSTONE) ) {

                     if ( (final < 0.25000) ) {

                        setmodel (chunk, "models/schunk1.mdl");
                     } else {

                        if ( (final < 0.50000) ) {

                           setmodel (chunk, "models/schunk2.mdl");
                        } else {

                           if ( (final < 0.75000) ) {

                              setmodel (chunk, "models/schunk3.mdl");
                           } else {

                              setmodel (chunk, "models/schunk4.mdl");

                           }

                        }

                     }
                     chunk.skin = 1.00000;
                  } else {

                     if ( (self.thingtype == THINGTYPE_CLAY) ) {

                        if ( (final < 0.25000) ) {

                           setmodel (chunk, "models/clshard1.mdl");
                        } else {

                           if ( (final < 0.50000) ) {

                              setmodel (chunk, "models/clshard2.mdl");
                           } else {

                              if ( (final < 0.75000) ) {

                                 setmodel (chunk, "models/clshard3.mdl");
                              } else {

                                 setmodel (chunk, "models/clshard4.mdl");

                              }

                           }

                        }
                     } else {

                        if ( (self.thingtype == THINGTYPE_LEAVES) ) {

                           if ( (final < 0.33000) ) {

                              setmodel (chunk, "models/leafchk1.mdl");
                           } else {

                              if ( (final < 0.66000) ) {

                                 setmodel (chunk, "models/leafchk2.mdl");
                              } else {

                                 setmodel (chunk, "models/leafchk3.mdl");

                              }

                           }
                        } else {

                           if ( (self.thingtype == THINGTYPE_HAY) ) {

                              if ( (final < 0.33000) ) {

                                 setmodel (chunk, "models/hay1.mdl");
                              } else {

                                 if ( (final < 0.66000) ) {

                                    setmodel (chunk, "models/hay2.mdl");
                                 } else {

                                    setmodel (chunk, "models/hay3.mdl");

                                 }

                              }
                           } else {

                              if ( (self.thingtype == THINGTYPE_CLOTH) ) {

                                 if ( (final < 0.33000) ) {

                                    setmodel (chunk, "models/clthchk1.mdl");
                                 } else {

                                    if ( (final < 0.66000) ) {

                                       setmodel (chunk, "models/clthchk2.mdl");
                                    } else {

                                       setmodel (chunk, "models/clthchk3.mdl");

                                    }

                                 }
                              } else {

                                 if ( (self.thingtype == THINGTYPE_WOOD_LEAF) ) {

                                    if ( (final < 0.14000) ) {

                                       setmodel (chunk, "models/splnter1.mdl");
                                    } else {

                                       if ( (final < 0.28000) ) {

                                          setmodel (chunk, "models/leafchk1.mdl");
                                       } else {

                                          if ( (final < 0.42000) ) {

                                             setmodel (chunk, "models/splnter2.mdl");
                                          } else {

                                             if ( (final < 0.56000) ) {

                                                setmodel (chunk, "models/leafchk2.mdl");
                                             } else {

                                                if ( (final < 0.70000) ) {

                                                   setmodel (chunk, "models/splnter3.mdl");
                                                } else {

                                                   if ( (final < 0.84000) ) {

                                                      setmodel (chunk, "models/leafchk3.mdl");
                                                   } else {

                                                      setmodel (chunk, "models/splnter4.mdl");

                                                   }

                                                }

                                             }

                                          }

                                       }

                                    }
                                 } else {

                                    if ( (self.thingtype == THINGTYPE_WOOD_METAL) ) {

                                       if ( (final < 0.12500) ) {

                                          setmodel (chunk, "models/splnter1.mdl");
                                       } else {

                                          if ( (final < 0.25000) ) {

                                             setmodel (chunk, "models/metlchk1.mdl");
                                          } else {

                                             if ( (final < 0.37500) ) {

                                                setmodel (chunk, "models/splnter2.mdl");
                                             } else {

                                                if ( (final < 0.50000) ) {

                                                   setmodel (chunk, "models/metlchk2.mdl");
                                                } else {

                                                   if ( (final < 0.62500) ) {

                                                      setmodel (chunk, "models/splnter3.mdl");
                                                   } else {

                                                      if ( (final < 0.75000) ) {

                                                         setmodel (chunk, "models/metlchk3.mdl");
                                                      } else {

                                                         if ( (final < 0.87500) ) {

                                                            setmodel (chunk, "models/splnter4.mdl");
                                                         } else {

                                                            setmodel (chunk, "models/metlchk4.mdl");

                                                         }

                                                      }

                                                   }

                                                }

                                             }

                                          }

                                       }
                                    } else {

                                       if ( (self.thingtype == THINGTYPE_WOOD_STONE) ) {

                                          if ( (final < 0.12500) ) {

                                             setmodel (chunk, "models/splnter1.mdl");
                                          } else {

                                             if ( (final < 0.25000) ) {

                                                setmodel (chunk, "models/schunk1.mdl");
                                             } else {

                                                if ( (final < 0.37500) ) {

                                                   setmodel (chunk, "models/splnter2.mdl");
                                                } else {

                                                   if ( (final < 0.50000) ) {

                                                      setmodel (chunk, "models/schunk2.mdl");
                                                   } else {

                                                      if ( (final < 0.62500) ) {

                                                         setmodel (chunk, "models/splnter3.mdl");
                                                      } else {

                                                         if ( (final < 0.75000) ) {

                                                            setmodel (chunk, "models/schunk3.mdl");
                                                         } else {

                                                            if ( (final < 0.87500) ) {

                                                               setmodel (chunk, "models/splnter4.mdl");
                                                            } else {

                                                               setmodel (chunk, "models/schunk4.mdl");

                                                            }

                                                         }

                                                      }

                                                   }

                                                }

                                             }

                                          }
                                       } else {

                                          if ( (self.thingtype == THINGTYPE_METAL_STONE) ) {

                                             if ( (final < 0.12500) ) {

                                                setmodel (chunk, "models/metlchk1.mdl");
                                             } else {

                                                if ( (final < 0.25000) ) {

                                                   setmodel (chunk, "models/schunk1.mdl");
                                                } else {

                                                   if ( (final < 0.37500) ) {

                                                      setmodel (chunk, "models/metlchk2.mdl");
                                                   } else {

                                                      if ( (final < 0.50000) ) {

                                                         setmodel (chunk, "models/schunk2.mdl");
                                                      } else {

                                                         if ( (final < 0.62500) ) {

                                                            setmodel (chunk, "models/metlchk3.mdl");
                                                         } else {

                                                            if ( (final < 0.75000) ) {

                                                               setmodel (chunk, "models/schunk3.mdl");
                                                            } else {

                                                               if ( (final < 0.87500) ) {

                                                                  setmodel (chunk, "models/metlchk4.mdl");
                                                               } else {

                                                                  setmodel (chunk, "models/schunk4.mdl");

                                                               }

                                                            }

                                                         }

                                                      }

                                                   }

                                                }

                                             }
                                          } else {

                                             if ( (self.thingtype == THINGTYPE_METAL_CLOTH) ) {

                                                if ( (final < 0.14000) ) {

                                                   setmodel (chunk, "models/metlchk1.mdl");
                                                } else {

                                                   if ( (final < 0.28000) ) {

                                                      setmodel (chunk, "models/clthchk1.mdl");
                                                   } else {

                                                      if ( (final < 0.42000) ) {

                                                         setmodel (chunk, "models/metlchk2.mdl");
                                                      } else {

                                                         if ( (final < 0.56000) ) {

                                                            setmodel (chunk, "models/clthchk2.mdl");
                                                         } else {

                                                            if ( (final < 0.70000) ) {

                                                               setmodel (chunk, "models/metlchk3.mdl");
                                                            } else {

                                                               if ( (final < 0.84000) ) {

                                                                  setmodel (chunk, "models/clthchk3.mdl");
                                                               } else {

                                                                  setmodel (chunk, "models/metlchk4.mdl");

                                                               }

                                                            }

                                                         }

                                                      }

                                                   }

                                                }
                                             } else {

                                                setmodel (chunk, "models/flesh1.mdl");

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
   setsize (chunk, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   chunk.movetype = MOVETYPE_BOUNCE;
   chunk.solid = SOLID_NOT;
   chunk.velocity = ChunkVelocity ();
   chunk.think = ChunkRemove;
   chunk.avelocity_x = (random () * 1200.00000);
   chunk.avelocity_y = (random () * 1200.00000);
   chunk.avelocity_z = (random () * 1200.00000);
   chunk.scale = ((random () * scalemod) + 1.00000);
   chunk.ltime = time;
   chunk.nextthink = ((time + 1.00000) + random ());
};

void  ()DropBackpack;

void  ()chunk_death =  {
local vector space = '0.00000 0.00000 0.00000';
local float spacecube = 0.00000;
local float spritecount = 0.00000;
local float model_cnt = 0.00000;
local float scalemod = 0.00000;
local float r = 0.00000;
local string deathsound;
   DropBackpack ();
   space = (self.absmax - self.absmin);
   spacecube = ((space_x * space_y) * space_z);
   model_cnt = (spacecube / 8192.00000);
   if ( (self.thingtype == THINGTYPE_GLASS) ) {

      sound (self, CHAN_VOICE, "fx/glassbrk.wav", 1.00000, ATTN_NORM);
   } else {

      if ( ((self.thingtype == THINGTYPE_WOOD) || (self.thingtype == THINGTYPE_WOOD_METAL)) ) {

         sound (self, CHAN_VOICE, "fx/woodbrk.wav", 1.00000, ATTN_NORM);
      } else {

         if ( ((((self.thingtype == THINGTYPE_GREYSTONE) || (self.thingtype == THINGTYPE_BROWNSTONE)) || (self.thingtype == THINGTYPE_WOOD_STONE)) || (self.thingtype == THINGTYPE_METAL_STONE)) ) {

            sound (self, CHAN_VOICE, "fx/wallbrk.wav", 1.00000, ATTN_NORM);
         } else {

            if ( ((self.thingtype == THINGTYPE_METAL) || (self.thingtype == THINGTYPE_METAL_CLOTH)) ) {

               sound (self, CHAN_VOICE, "fx/metalbrk.wav", 1.00000, ATTN_NORM);
            } else {

               if ( (self.thingtype == THINGTYPE_CLOTH) ) {

                  sound (self, CHAN_VOICE, "fx/clothbrk.wav", 1.00000, ATTN_NORM);
               } else {

                  if ( (self.thingtype == THINGTYPE_FLESH) ) {

                     if ( (self.classname == "monster_archer") ) {

                        ThrowSingleChunk (self.headmodel, self.origin, 50.00000);

                     }
                     if ( (self.health < -100.00000) ) {

                        deathsound = "player/megagib.wav";
                     } else {

                        deathsound = "player/gib1.wav";

                     }
                     sound (self, CHAN_AUTO, deathsound, 1.00000, ATTN_NORM);
                  } else {

                     if ( (self.thingtype == THINGTYPE_CLAY) ) {

                        sound (self, CHAN_VOICE, "fx/claybrk.wav", 1.00000, ATTN_NORM);
                     } else {

                        if ( ((self.thingtype == THINGTYPE_LEAVES) || (self.thingtype == THINGTYPE_WOOD_LEAF)) ) {

                           sound (self, CHAN_VOICE, "fx/leafbrk.wav", 1.00000, ATTN_NORM);
                        } else {

                           sound (self, CHAN_VOICE, "fx/wallbrk.wav", 1.00000, ATTN_NORM);

                        }

                     }

                  }

               }

            }

         }

      }

   }
   if ( (spacecube < 50000.00000) ) {

      scalemod = 1.00000;
      model_cnt = (model_cnt * 3.00000);
   } else {

      if ( (spacecube < 500000.00000) ) {

         scalemod = 2.00000;
      } else {

         if ( (spacecube < 1000000.00000) ) {

            scalemod = 16.00000;
         } else {

            scalemod = 64.00000;

         }

      }

   }
   if ( (model_cnt > CHUNK_MAX) ) {

      model_cnt = CHUNK_MAX;

   }
   while ( (model_cnt > 0.00000) ) {

      if ( (chunk_cnt < CHUNK_MAX) ) {

         CreateModelChunks (space, scalemod);
         chunk_cnt += 1.00000;

      }
      model_cnt -= 1.00000;

   }
   SUB_UseTargets ();
   remove (self);
};

