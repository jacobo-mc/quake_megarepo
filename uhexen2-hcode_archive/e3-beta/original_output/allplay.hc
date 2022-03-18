void  ()bubble_bob;

vector  (float dm)VelocityForDamage =  {
local vector v = '0.00000 0.00000 0.00000';
   v_x = (100.00000 * crandom ());
   v_y = (100.00000 * crandom ());
   v_z = (200.00000 + (100.00000 * random ()));
   if ( (dm > -50.00000) ) {

      v = (v * 0.70000);
   } else {

      if ( (dm > -200.00000) ) {

         v = (v * 2.00000);
      } else {

         v = (v * 10.00000);

      }

   }
   return ( v );
};


void  ()ReadySolid =  {
   MakeSolidCorpse ("models/flesh1.mdl");
};


void  ()PainSound =  {
   if ( (self.health < 0.00000) ) {

      return ;

   }
   if ( (damage_attacker.classname == "teledeath") ) {

      sound (self, CHAN_VOICE, "player/telefrag.wav", 1.00000, ATTN_NONE);
      return ;

   }
   if ( (self.pain_finished > time) ) {

      return ;

   }
   if ( ((self.watertype == CONTENT_WATER) && (self.waterlevel == 3.00000)) ) {

      sound (self, CHAN_VOICE, "player/paldrown.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.watertype == CONTENT_SLIME) ) {

         if ( (random () > 0.50000) ) {

            sound (self, CHAN_VOICE, "player/palpain1.wav", 1.00000, ATTN_NORM);
         } else {

            sound (self, CHAN_VOICE, "player/palpain2.wav", 1.00000, ATTN_NORM);

         }
      } else {

         if ( (self.watertype == CONTENT_LAVA) ) {

            if ( (random () > 0.50000) ) {

               sound (self, CHAN_VOICE, "player/palpain1.wav", 1.00000, ATTN_NORM);
            } else {

               sound (self, CHAN_VOICE, "player/palpain2.wav", 1.00000, ATTN_NORM);

            }
         } else {

            if ( (random () > 0.50000) ) {

               sound (self, CHAN_VOICE, "player/palpain1.wav", 1.00000, ATTN_NORM);
            } else {

               sound (self, CHAN_VOICE, "player/palpain2.wav", 1.00000, ATTN_NORM);

            }

         }

      }

   }
   self.pain_finished = (time + 0.50000);
   return ;
};


void  ()player_pain =  {
   if ( self.weaponframe ) {

      return ;

   }
   if ( (self.invisible_finished > time) ) {

      return ;

   }
   PainSound ();
   self.weaponframe = 0.00000;
   self.hull = HULL_NORMAL;
   if ( HULL_NORMAL ) {

      self.th_pain ();
   } else {

      self.hull = HULL_CROUCH;
      if ( HULL_CROUCH ) {

         self.th_walk ();

      }

   }
};


void  ()DeathBubblesSpawn =  {
local entity bubble;
local float waterornot = 0.00000;
   waterornot = pointcontents (self.origin);
   if ( ((waterornot != CONTENT_WATER) && (waterornot != CONTENT_SLIME)) ) {

      return ;

   }
   bubble = spawn ();
   setmodel (bubble, "models/s_bubble.spr");
   if ( self.owner.health ) {

      setorigin (bubble, (self.owner.origin + '0.00000 0.00000 24.00000'));
   } else {

      setorigin (bubble, ((self.origin + self.proj_ofs) + '0.00000 0.00000 24.00000'));

   }
   bubble.movetype = MOVETYPE_NOCLIP;
   bubble.solid = SOLID_NOT;
   bubble.velocity = '0.00000 0.00000 15.00000';
   bubble.nextthink = (time + 0.50000);
   bubble.think = bubble_bob;
   bubble.classname = "bubble";
   bubble.frame = 0.00000;
   bubble.cnt = 0.00000;
   bubble.abslight = 0.50000;
   bubble.drawflags += (DRF_TRANSLUCENT + MLS_ABSLIGHT);
   setsize (bubble, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
   self.nextthink = (time + 0.10000);
   self.think = DeathBubblesSpawn;
   self.air_finished = (self.air_finished + 1.00000);
   if ( (self.air_finished >= self.bubble_count) ) {

      remove (self);

   }
};


void  (float num_bubbles)DeathBubbles =  {
local entity bubble_spawner;
   bubble_spawner = spawn ();
   setorigin (bubble_spawner, self.origin);
   bubble_spawner.movetype = MOVETYPE_NONE;
   bubble_spawner.solid = SOLID_NOT;
   bubble_spawner.nextthink = (time + 0.10000);
   bubble_spawner.think = DeathBubblesSpawn;
   bubble_spawner.air_finished = 0.00000;
   bubble_spawner.owner = self;
   bubble_spawner.bubble_count = num_bubbles;
   return ;
};


void  ()DeathSound =  {
   if ( (self.waterlevel == 3.00000) ) {

      DeathBubbles (20.00000);
      sound (self, CHAN_VOICE, "player/paldieh2.wav", 1.00000, ATTN_NONE);
      return ;

   }
   if ( (random () > 0.50000) ) {

      sound (self, CHAN_VOICE, "player/paldie1.wav", 1.00000, ATTN_NONE);
   } else {

      sound (self, CHAN_VOICE, "player/paldie2.wav", 1.00000, ATTN_NONE);

   }
   return ;
};


void  ()PlayerDead =  {
   self.nextthink = -1.00000;
   self.deadflag = DEAD_DEAD;
};


void  (string gibname,float dm)ThrowGib =  {
local entity new;
   new = spawn ();
   new.origin = self.origin;
   setmodel (new, gibname);
   setsize (new, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   new.velocity = VelocityForDamage (dm);
   new.movetype = MOVETYPE_BOUNCE;
   new.solid = SOLID_NOT;
   new.avelocity_x = (random () * 600.00000);
   new.avelocity_y = (random () * 600.00000);
   new.avelocity_z = (random () * 600.00000);
   new.think = SUB_Remove;
   new.ltime = time;
   new.nextthink = ((time + 10.00000) + (random () * 10.00000));
   new.scale = ((random () * 1.50000) + 1.00000);
   new.frame = 0.00000;
   new.flags = 0.00000;
};


void  (string gibname,float dm)ThrowHead =  {
local vector org = '0.00000 0.00000 0.00000';
   setmodel (self, gibname);
   self.frame = 0.00000;
   self.nextthink = -1.00000;
   self.movetype = MOVETYPE_BOUNCE;
   self.takedamage = DAMAGE_NO;
   self.solid = SOLID_BBOX;
   self.mass = 1.00000;
   if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

      self.view_ofs = '0.00000 0.00000 8.00000';

   }
   self.proj_ofs = '0.00000 0.00000 2.00000';
   setsize (self, '-4.00000 -4.00000 -4.00000', '4.00000 4.00000 4.00000');
   org = self.origin;
   org_z = (self.absmax_z + 4.00000);
   setorigin (self, org);
   self.velocity = VelocityForDamage (dm);
   self.flags = (self.flags - (self.flags & FL_ONGROUND));
   self.avelocity = (crandom () * '0.00000 600.00000 0.00000');
};


void  ()PlayerUnCrouching =  {
   if ( (self.scale == 1.00000) ) {

      tracearea (self.origin, (self.origin + '0.00000 0.00000 0.10000'), '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000', FALSE, self);
      if ( (trace_fraction < 1.00000) ) {

         centerprint (self, "No room to stand up here!\n");
         return ;

      }
      self.hull = HULL_NORMAL;
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
      if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

         self.view_ofs = '0.00000 0.00000 50.00000';

      }
      self.proj_ofs = '0.00000 0.00000 44.00000';
   } else {

      if ( (self.scale == 1.70000) ) {

         tracearea (self.origin, (self.origin + '0.00000 0.00000 96.00000'), '-32.00000 -32.00000 0.00000', '32.00000 32.00000 0.00000', FALSE, self);
         if ( (trace_fraction < 1.00000) ) {

            centerprint (self, "No room to stand up while you're a giant!\n");
            return ;

         }
         self.hull = HULL_BIG;
         setsize (self, '-32.00000 -32.00000 0.00000', '32.00000 32.00000 96.00000');
         if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

            self.view_ofs = '0.00000 0.00000 86.00000';

         }
         self.proj_ofs = '0.00000 0.00000 80.00000';

      }

   }
   if ( (self.velocity_x || self.velocity_y) ) {

      self.th_run ();
   } else {

      self.th_stand ();

   }
};


void  ()PlayerCrouching =  {
   if ( (self.scale == 1.00000) ) {

      self.hull = HULL_CROUCH;
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 32.00000');
      if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

         self.view_ofs = '0.00000 0.00000 28.00000';

      }
      self.proj_ofs = '0.00000 0.00000 22.00000';
   } else {

      if ( (self.scale == 1.70000) ) {

         self.hull = HULL_NORMAL;
         setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
         if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

            self.view_ofs = '0.00000 0.00000 50.00000';

         }
         self.proj_ofs = '0.00000 0.00000 44.00000';

      }

   }
   self.absorb_time = (time + 0.30000);
   self.th_walk ();
};


void  ()PlayerCrouch =  {
   self.nextthink = (time + 0.01000);
   if ( (((self.hull == HULL_NORMAL) && (self.scale == 1.00000)) || (self.hull == HULL_BIG)) ) {

      self.think = PlayerCrouching;
   } else {

      if ( (((self.hull == HULL_NORMAL) && (self.scale == 1.70000)) || (self.hull == HULL_CROUCH)) ) {

         self.think = PlayerUnCrouching;

      }

   }
};


void  ()Scale =  {
local string printnum;
   self.scale += self.scalerate;
   if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

      self.view_ofs += (('0.00000 0.00000 5.00000' * self.scalerate) * 10.00000);

   }
   self.proj_ofs += (('0.00000 0.00000 5.00000' * self.scalerate) * 10.00000);
   if ( (((self.scale >= self.target_scale) && (self.scalerate > 0.00000)) || ((self.scale <= self.target_scale) && (self.scalerate < 0.00000))) ) {

      if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

         self.view_ofs = self.o_angle;

      }
      self.proj_ofs = (self.o_angle - '0.00000 0.00000 6.00000');
      self.scale = self.target_scale;
      self.think = self.oldthink;
      self.nextthink = time;
   } else {

      self.think = Scale;
      self.nextthink = (time + 0.10000);

   }
};


void  ()Grow =  {
   if ( (self.scale == 1.70000) ) {

      if ( (self.drawflags & SCALE_ORIGIN_BOTTOM) ) {

         self.drawflags -= SCALE_ORIGIN_BOTTOM;

      }
      if ( (self.hull == HULL_NORMAL) ) {

         self.hull = HULL_CROUCH;
         setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 12.00000');
         self.o_angle = '0.00000 0.00000 10.00000';
         self.oldthink = self.th_walk;
      } else {

         self.hull = HULL_NORMAL;
         setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
         self.o_angle = '0.00000 0.00000 50.00000';
         self.oldthink = self.th_stand;

      }
      self.scalerate = -0.10000;
      self.target_scale = 1.00000;
      self.health = (self.health / 1.70000);
      self.mass = (self.mass / 1.70000);
      self.strength = (self.strength / 1.70000);
      Scale ();
   } else {

      if ( (self.hull == HULL_CROUCH) ) {

         tracearea (self.origin, (self.origin + '0.00000 0.00000 1.00000'), '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000', FALSE, self);
         if ( (trace_fraction < 1.00000) ) {

            centerprint (self, "Not enough room to grow here...\n");
            return ;

         }
         if ( !(self.drawflags & SCALE_ORIGIN_BOTTOM) ) {

            self.drawflags += SCALE_ORIGIN_BOTTOM;

         }
         self.hull = HULL_NORMAL;
         setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');
         self.o_angle = '0.00000 0.00000 50.00000';
         self.oldthink = self.th_walk;
      } else {

         tracearea (self.origin, (self.origin + '0.00000 0.00000 1.00000'), '-32.00000 -32.00000 0.00000', '32.00000 32.00000 96.00000', FALSE, self);
         if ( (trace_fraction < 1.00000) ) {

            centerprint (self, "Not enough room to grow here...\n");
            return ;

         }
         if ( !(self.drawflags & SCALE_ORIGIN_BOTTOM) ) {

            self.drawflags += SCALE_ORIGIN_BOTTOM;

         }
         setsize (self, '-32.00000 -32.00000 0.00000', '32.00000 32.00000 96.00000');
         self.hull = HULL_BIG;
         self.o_angle = '0.00000 0.00000 86.00000';
         self.oldthink = self.th_stand;

      }
      self.scalerate = 0.10000;
      self.target_scale = 1.70000;
      self.health = (self.health * 1.70000);
      self.mass = (self.mass * 1.70000);
      self.strength = (self.strength * 1.70000);
      Scale ();

   }
};


void  ()GibPlayer =  {
   ThrowHead (self.headmodel, self.health);
   ThrowGib ("models/flesh1.mdl", self.health);
   ThrowGib ("models/flesh2.mdl", self.health);
   ThrowGib ("models/flesh3.mdl", self.health);
   self.deadflag = DEAD_DEAD;
   if ( (damage_attacker.classname == "teledeath") ) {

      sound (self, CHAN_VOICE, "player/telefrag.wav", 1.00000, ATTN_NONE);
      return ;

   }
   if ( (damage_attacker.classname == "teledeath2") ) {

      sound (self, CHAN_VOICE, "player/telefrag.wav", 1.00000, ATTN_NONE);
      return ;

   }
   if ( (random () < 0.50000) ) {

      sound (self, CHAN_VOICE, "player/gib1.wav", 1.00000, ATTN_NONE);
   } else {

      sound (self, CHAN_VOICE, "player/gib2.wav", 1.00000, ATTN_NONE);

   }
};


void  ()DecapPlayer =  {
local entity headless;
   headless = spawn ();
   headless.classname = "headless";
   headless.decap = TRUE;
   headless.movetype = MOVETYPE_STEP;
   headless.solid = SOLID_PHASE;
   headless.frame = 50.00000;
   headless.skin = self.skin;
   headless.thingtype = self.thingtype;
   setmodel (headless, self.model);
   setsize (headless, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 36.00000');
   headless.angles_y = self.angles_y;
   setorigin (headless, self.origin);
   headless.think = self.th_goredeath;
   headless.nextthink = time;
   self.health = (self.health * 4.00000);
   if ( (self.health > -30.00000) ) {

      self.health = -30.00000;
   } else {

      if ( (self.health < -99.00000) ) {

         self.health = -99.00000;

      }

   }
   if ( (self.decap == 2.00000) ) {

      ThrowHead ("models/flesh1.mdl", self.health);
   } else {

      ThrowHead (self.headmodel, self.health);

   }
   ThrowGib ("models/flesh1.mdl", self.health);
   ThrowGib ("models/flesh2.mdl", self.health);
   ThrowGib ("models/flesh3.mdl", self.health);
   self.deadflag = DEAD_DEAD;
   if ( (random () < 0.50000) ) {

      sound (self, CHAN_VOICE, "player/gib1.wav", 1.00000, ATTN_NONE);
   } else {

      sound (self, CHAN_VOICE, "player/gib2.wav", 1.00000, ATTN_NONE);

   }
};


void  ()PlayerDie =  {
local float i = 0.00000;
   self.items = (self.items - (self.items & IT_INVISIBILITY));
   self.invisible_finished = 0.00000;
   self.invincible_finished = 0.00000;
   self.modelindex = self.init_modelindex;
   if ( (deathmatch || coop) ) {

      DropBackpack ();

   }
   self.weaponmodel = "";
   if ( !(self.flags2 & FL_CAMERA_VIEW) ) {

      self.view_ofs = '0.00000 0.00000 6.00000';

   }
   self.deadflag = DEAD_DYING;
   self.solid = SOLID_NOT;
   self.flags = (self.flags - (self.flags & FL_ONGROUND));
   self.movetype = MOVETYPE_TOSS;
   if ( (self.velocity_z < 10.00000) ) {

      self.velocity_z = (self.velocity_z + (random () * 300.00000));

   }
   if ( (((self.deathtype == "ice shatter") || (self.deathtype == "stone crumble")) || (self.deathtype == "burnt crumble")) ) {

      shatter ();
      ThrowHead ("models/null.spr", self.health);
      return ;
   } else {

      if ( self.decap ) {

         DecapPlayer ();
         return ;
      } else {

         if ( (self.health < -40.00000) ) {

            GibPlayer ();
            return ;

         }

      }

   }
   DeathSound ();
   self.angles_x = 0.00000;
   self.angles_z = 0.00000;
   i = cvar ("temp1");
   if ( !i ) {

      i = (1.00000 + floor ((random () * 6.00000)));

   }
   if ( (self.bloodloss == 666.00000) ) {

      DecapPlayer ();
   } else {

      if ( (random () < 0.50000) ) {

         self.th_die1 ();
      } else {

         self.th_die2 ();

      }

   }
};


void  ()set_suicide_frame =  {
   if ( (self.model != self.init_model) ) {

      return ;

   }
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_TOSS;
   self.deadflag = DEAD_DEAD;
   self.nextthink = -1.00000;
};


void  ()Head =  {
   ThrowSolidHead (self.model, 0.00000);
};


void  ()Corpse =  {
   MakeSolidCorpse (self.headmodel);
};


void  ()SolidPlayer =  {
local entity corpse;
   corpse = spawn ();
   if ( ((self.angles_x > 15.00000) || (self.angles_x < -15.00000)) ) {

      self.angles_x = 0.00000;

   }
   if ( ((self.angles_z > 15.00000) || (self.angles_z < -15.00000)) ) {

      self.angles_z = 0.00000;

   }
   corpse.angles = self.angles;
   corpse.model = self.model;
   corpse.modelindex = self.modelindex;
   corpse.frame = self.frame;
   corpse.colormap = self.colormap;
   corpse.movetype = self.movetype;
   corpse.velocity = self.velocity;
   corpse.flags = 0.00000;
   corpse.effects = 0.00000;
   corpse.skin = self.skin;
   corpse.controller = self;
   corpse.thingtype = self.thingtype;
   setorigin (corpse, self.origin);
   if ( (self.model == self.headmodel) ) {

      corpse.think = Head;
   } else {

      corpse.think = Corpse;

   }
   corpse.nextthink = time;
};


void  ()player_behead =  {
   self.frame = (self.level + self.cnt);
   self.cnt += 1.00000;
   makevectors (self.angles);
   if ( (self.frame == (self.level + 1.00000)) ) {

      SpawnPuff ((self.origin + (v_forward * 8.00000)), '0.00000 0.00000 48.00000', 30.00000, self);
      sound (self, CHAN_AUTO, "misc/decomp.wav", 1.00000, ATTN_NORM);
   } else {

      if ( (self.frame == (self.level + 3.00000)) ) {

         SpawnPuff ((self.origin + (v_forward * 16.00000)), ('0.00000 0.00000 36.00000' + (v_forward * 16.00000)), 20.00000, self);
         sound (self, CHAN_AUTO, "misc/decomp.wav", 1.00000, ATTN_NORM);
      } else {

         if ( (self.frame == (self.level + 5.00000)) ) {

            SpawnPuff ((self.origin + (v_forward * 28.00000)), ('0.00000 0.00000 20.00000' + (v_forward * 32.00000)), 15.00000, self);
            sound (self, CHAN_AUTO, "misc/decomp.wav", 0.80000, ATTN_NORM);
         } else {

            if ( (self.frame == (self.level + 8.00000)) ) {

               SpawnPuff ((self.origin + (v_forward * 40.00000)), ('0.00000 0.00000 10.00000' + (v_forward * 40.00000)), 10.00000, self);
               sound (self, CHAN_AUTO, "misc/decomp.wav", 0.60000, ATTN_NORM);

            }

         }

      }

   }
   if ( (self.frame == self.dmg) ) {

      SpawnPuff ((self.origin + (v_forward * 56.00000)), ('0.00000 0.00000 -5.00000' + (v_forward * 40.00000)), 5.00000, self);
      sound (self, CHAN_AUTO, "misc/decomp.wav", 0.40000, ATTN_NORM);
      ReadySolid ();
   } else {

      self.think = player_behead;
      self.nextthink = (time + 0.20000);

   }
};

