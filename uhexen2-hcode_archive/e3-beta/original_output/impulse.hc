void  (float NewLevel)PlayerAdvanceLevel;

void  ()player_level =  {
   self.experience = (((self.playerclass - 1.00000) * (MAX_LEVELS + 1.00000)) + (self.level - 1.00000));
   PlayerAdvanceLevel ((self.level + 1.00000));
};


void  ()gravityup =  {
   self.gravity += 0.01000;
   if ( (self.gravity == 10.00000) ) {

      self.gravity = 0.00000;

   }
   dprint ("Gravity: ");
   dprint (ftos (self.gravity));
   dprint ("\n");
};


void  ()gravitydown =  {
   self.gravity -= 0.01000;
   if ( (self.gravity == -10.00000) ) {

      self.gravity = 0.00000;

   }
   dprint ("Gravity: ");
   dprint (ftos (self.gravity));
   dprint ("\n");
};

void  ()Grow;

void  ()effect_test =  {
   if ( !self.effects ) {

      self.effects = 16.00000;
   } else {

      if ( (self.effects == 16.00000) ) {

         self.effects = 32.00000;
      } else {

         if ( (self.effects == 32.00000) ) {

            self.effects = 64.00000;
         } else {

            if ( (self.effects == 64.00000) ) {

               self.effects = 128.00000;
            } else {

               if ( (self.effects == 128.00000) ) {

                  self.effects = 0.00000;

               }

            }

         }

      }

   }
};


void  ()remove_doors =  {
local entity found;
   found = world;
   found = nextent (found);
   while ( (found != world) ) {

      if ( (found.classname == "door") ) {

         bprint ("found door\n");
         remove (found);

      }
      found = find (found, classname, "door");

   }
   bprint ("done\n");
};


void  ()player_fly =  {
   if ( (self.movetype != MOVETYPE_FLY) ) {

      self.movetype = MOVETYPE_FLY;
      sprint (self, "flymode ON\n");
      self.velocity_z = 100.00000;
      self.hoverz = 0.40000;
      self.idealpitch = cvar ("sv_flypitch");
      self.idealpitch = 20.00000;
   } else {

      self.movetype = MOVETYPE_WALK;
      sprint (self, "flymode OFF\n");
      self.idealpitch = cvar ("sv_walkpitch");

   }
};


void  ()ImpulseCommands =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local string printnum;
local entity search;
local float total = 0.00000;
local string s2;
   if ( ((self.impulse >= 1.00000) && (self.impulse <= 4.00000)) ) {

      W_ChangeWeapon ();

   }
   if ( (self.impulse == 9.00000) ) {

      CheatCommand ();

   }
   if ( (self.impulse == 10.00000) ) {

      CycleWeaponCommand ();

   }
   if ( (self.impulse == 11.00000) ) {

      ServerflagsCommand ();

   }
   if ( (self.impulse == 12.00000) ) {

      CycleWeaponReverseCommand ();

   }
   if ( (self.impulse == 13.00000) ) {

      HeaveHo ();

   }
   if ( (self.impulse == 20.00000) ) {

      makevectors (self.v_angle);
      spot1 = ((self.origin + self.proj_ofs) + (v_up * 4.00000));
      spot2 = (spot1 + (v_forward * 25.00000));
      traceline (spot1, spot2, FALSE, self);
   } else {

      if ( (self.impulse == 21.00000) ) {

         UseTorch ();
      } else {

         if ( (self.impulse == 22.00000) ) {

            PlayerCrouch ();
         } else {

            if ( (self.impulse == 23.00000) ) {

               UseInventoryItem ();
            } else {

               if ( (self.impulse == 24.00000) ) {

                  if ( (self.playerclass == CLASS_ASSASSIN) ) {

                     SetLaser ();
                  } else {

                     if ( (self.playerclass == CLASS_PALADIN) ) {

                        Use_StickMine ();

                     }

                  }
               } else {

                  if ( (self.impulse == 25.00000) ) {

                     Use_TomeofPower ();
                  } else {

                     if ( (self.impulse == 26.00000) ) {

                        MakeForceField ();
                     } else {

                        if ( (self.impulse == 27.00000) ) {

                           MakeCamera ();
                        } else {

                           if ( (self.impulse == 30.00000) ) {

                              gravityup ();
                           } else {

                              if ( (self.impulse == 31.00000) ) {

                                 gravitydown ();
                              } else {

                                 if ( (self.impulse == 33.00000) ) {

                                    if ( (self.flags2 & FL_LEDGEHOLD) ) {

                                       sprint (self, "Ledge holding disallowed\n");
                                       self.flags2 -= FL_LEDGEHOLD;
                                    } else {

                                       sprint (self, "Ledge holding allowed\n");
                                       self.flags2 += FL_LEDGEHOLD;

                                    }
                                 } else {

                                    if ( (self.impulse == 34.00000) ) {

                                       sprint (self, "Puzzle Inventory: [ ");
                                       if ( self.puzzle_inv_1 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_1);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_2 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_2);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_3 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_3);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_4 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_4);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_5 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_5);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_6 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_6);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_7 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_7);
                                          sprint (self, ")");

                                       }
                                       if ( self.puzzle_inv_8 ) {

                                          sprint (self, "(");
                                          sprint (self, self.puzzle_inv_8);
                                          sprint (self, ")");

                                       }
                                       sprint (self, " ] \n");
                                    } else {

                                       if ( (self.impulse == 35.00000) ) {

                                          search = nextent (world);
                                          total = 0.00000;
                                          while ( (search != world) ) {

                                             if ( (search.flags & FL_MONSTER) ) {

                                                total += 1.00000;
                                                remove (search);

                                             }
                                             search = nextent (search);

                                          }
                                          dprintf ("Removed %s monsters\n", total);
                                       } else {

                                          if ( (self.impulse == 36.00000) ) {

                                             search = nextent (world);
                                             total = 0.00000;
                                             while ( (search != world) ) {

                                                if ( (search.flags & FL_MONSTER) ) {

                                                   total += 1.00000;
                                                   search.nextthink = (time + 99999.00000);

                                                }
                                                search = nextent (search);

                                             }
                                             dprintf ("Froze %s monsters\n", total);
                                          } else {

                                             if ( (self.impulse == 37.00000) ) {

                                                search = nextent (world);
                                                total = 0.00000;
                                                while ( (search != world) ) {

                                                   if ( (search.flags & FL_MONSTER) ) {

                                                      total += 1.00000;
                                                      search.nextthink = (time + HX_FRAME_TIME);

                                                   }
                                                   search = nextent (search);

                                                }
                                                dprintf ("UnFroze %s monsters\n", total);
                                             } else {

                                                if ( (self.impulse == 38.00000) ) {

                                                   sprint (self, "Class: ");
                                                   s2 = ftos (self.playerclass);
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                   sprint (self, "   Hit Points: ");
                                                   s2 = ftos (self.health);
                                                   sprint (self, s2);
                                                   s2 = ftos (self.max_health);
                                                   sprint (self, "/");
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                   sprint (self, "   Strength: ");
                                                   s2 = ftos (self.strength);
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                   sprint (self, "   Intelligence: ");
                                                   s2 = ftos (self.intelligence);
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                   sprint (self, "   Wisdom: ");
                                                   s2 = ftos (self.wisdom);
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                   sprint (self, "   Dexterity: ");
                                                   s2 = ftos (self.dexterity);
                                                   sprint (self, s2);
                                                   sprint (self, "\n");
                                                } else {

                                                   if ( (self.impulse == 39.00000) ) {

                                                      player_fly ();
                                                   } else {

                                                      if ( (self.impulse == 40.00000) ) {

                                                         player_level ();

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
   if ( (self.impulse == 69.00000) ) {

      Supes ();

   }
   if ( (self.impulse == 70.00000) ) {

      Grow ();

   }
   if ( (self.impulse == 71.00000) ) {

      effect_test ();

   }
   if ( (self.impulse == 72.00000) ) {

      test_traceline ();

   }
   if ( (self.impulse == 73.00000) ) {

      remove_doors ();

   }
   if ( (self.impulse == 74.00000) ) {

      if ( (self.weaponmodel == "models/icestff2.mdl") ) {

         self.weaponmodel = "models/icestaff.mdl";
      } else {

         if ( (self.weaponmodel == "models/icestaff.mdl") ) {

            self.weaponmodel = "models/icestff2.mdl";

         }

      }

   }
   self.impulse = 0.00000;
};

