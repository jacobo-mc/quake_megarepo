
void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame stgun1 stgun2 stgun3 stgun4 stgun5 stgun6 stgun7 stgun8 stgun9
$frame stgun10 stgun11 stgun12 stgun13

$frame run1 run2 run3 run4 run5 run6

$frame rungun1 rungun2 rungun3 rungun4 rungun5 rungun6

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame pgun1 pgun2 pgun3 pgun4 pgun5 pgun6

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8 deatha9
$frame deatha10 deatha11 deatha12

$frame dguna1 dguna2 dguna3 dguna4 dguna5 dguna6 dguna7 dguna8 dguna9
$frame dguna10 dguna11 dguna12

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8 deathb9
$frame deathb10 deathb11 deathb12

$frame dgunb1 dgunb2 dgunb3 dgunb4 dgunb5 dgunb6 dgunb7 dgunb8 dgunb9
$frame dgunb10 dgunb11 dgunb12

$frame shot1 shot2 shot3 shot4 shot5 shot6 shot7 shot8 shot9
$frame shot10 shot11 shot12 shot13 shot14 shot15 shot16 shot17 shot18

$frame rock1 rock2 rock3 rock4 rock5 rock6 rock7 rock8 rock9
$frame rock10 rock11 rock12 rock13 rock14 rock15 rock16 rock17 rock18

$frame chain1 chain2 chain3 chain4 chain5 chain6

$frame bolt1 bolt2 bolt3 bolt4 bolt5 bolt6

$frame xatta1 xatta2 xatta3 xatta4 xatta5 xatta6 xatta7 xatta8 xatta9 xatta10
$frame xatta11 xatta12

$frame xattb1 xattb2 xattb3 xattb4 xattb5 xattb6 xattb7 xattb8
$frame xattb9 xattb10 xattb11 xattb12

$frame swim1 swim2 swim3 swim4 swim5 swim6

$frame jump1 jump2 jump3 jump4 jump5 jump6

/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

void()	player_stand1 =[	$stand1,	player_stand1	]
{
   local float    oldframe;

	if (self.velocity_x || self.velocity_y || self.velocity_z)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	if ((self.weapon == IT_AXE) || ((self.modelindex == index_skeleton) && (self.x_flags & X_STGUN)))
	{
		if (self.walkframe >= 13)
			self.walkframe = 0;

      if ((self.waterlevel >= 2) && !deathmatch && !coop)
		   self.frame = $swim1 + self.walkframe;
      else
         self.frame = $stand1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 13)
			self.walkframe = 0;

      if ((self.waterlevel >= 2) && !deathmatch && !coop)
         self.frame = $swim1 + self.walkframe;
      else
         self.frame = $stgun1 + self.walkframe;
	}
   self.walkframe = self.walkframe + 1;

   self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);

   if (self.change_weapon_status == CW_DONE) {
      if (self.weapon == IT_SUPER_NAILGUN) {
         if ((!self.change_weapon_status) && (self.weaponframe < 16))
            self.weaponframe = 18;

         if ((self.weaponframe >= 16) && (self.weaponframe <= 18)) {
            self.weaponframe = self.weaponframe + 1;
            if (self.weaponframe > 18)
               self.weaponframe = 16;
         }
      }
      else if (!deathmatch && !coop && (self.weapon == IT_AXE)) {
//         if ((!self.change_weapon_status) && (self.weaponframe < 23)) {
//            self.weaponframe = 23;
//         }

         oldframe = self.weaponframe;
         while (self.weaponframe == oldframe)
            self.weaponframe = 23 + rint(random() * 6);  //self.weaponframe + 1;
//         if (self.weaponframe > 29)
//            self.weaponframe = 23;
      }
      else {
         self.weaponframe=self.weapon_idleframe;
      }
   }
};

void()	player_run =[	$run1,	player_run	]
{
   local float    oldframe;

	if (!self.velocity_x && !self.velocity_y && !self.velocity_z)
	{
      if (self.modelindex == index_skeleton) {
         // use stgun or stand frames?
         if (random() < 0.5)
            self.x_flags = self.x_flags | X_STGUN;
         else
            self.x_flags = self.x_flags - (self.x_flags & X_STGUN);
      }

		self.walkframe=0;
		player_stand1();
		return;
	}

   if (self.x_flags & X_JUMP_PRESSED) {
      if ((self.last_jump > (time - 0.2)) && (self.waterlevel < 2)) {
         self.frame = $jump1;
         self.walkframe = self.frame - 1;
      }

      self.x_flags = self.x_flags - X_JUMP_PRESSED;
   }
   else {
      if (self.walkframe >= $jump1 ) {
         if (!(self.flags & FL_ONGROUND)) {     // still in the air
            self.frame = self.walkframe + 1;

            if (self.walkframe >= $jump5 )
               self.walkframe = $jump4;
         }
         else {   // landed
            self.frame = self.walkframe;
            if (self.walkframe >= $jump6 )
               self.walkframe = 0;
         }
      }
      else if (self.weapon == IT_AXE)
      {
         if (self.walkframe >= 6)
            self.walkframe = 0;

         if ((self.waterlevel >= 2) && !deathmatch && !coop)
            self.frame = $swim1 + self.walkframe;
         else
            self.frame = $run1 + self.walkframe;
      }
      else
      {
         if (self.walkframe >= 6)
            self.walkframe = 0;

         if ((self.waterlevel >= 2) && !deathmatch && !coop)
            self.frame = $swim1 + self.walkframe;
         else
            self.frame = $rungun1 + self.walkframe;
      }
   }
   self.walkframe = self.walkframe + 1;

   self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);

   if (self.change_weapon_status == CW_DONE) {
      if (self.weapon == IT_SUPER_NAILGUN) {
         if ((!self.change_weapon_status) && (self.weaponframe < 16)) {
            self.weaponframe = 18;
         }

         if ((self.weaponframe >= 16) && (self.weaponframe <= 18)) {
            self.weaponframe = self.weaponframe + 1;
            if (self.weaponframe > 18)
               self.weaponframe = 16;
         }
      }
      else if (!deathmatch && !coop && (self.weapon == IT_AXE)) {
//         if ((!self.change_weapon_status) && (self.weaponframe < 23)) {
//            self.weaponframe = 23;
//         }

         oldframe = self.weaponframe;
         while (self.weaponframe == oldframe)
            self.weaponframe = 23 + rint(random() * 6);  //self.weaponframe + 1;
//         if (self.weaponframe > 29)
//            self.weaponframe = 23;
      }
      else {
         self.weaponframe=self.weapon_idleframe;
      }
   }

};

//============================================================================

void() PlayerPunch =
{
local vector   delta;
local float    ldmg;
local entity   plyr;

   makevectors(self.v_angle);
   if ((plyr = FindSightEnemy(self.origin, v_forward, 60, 40, "all", self)) == world) {
      traceline(self.origin + '0 0 16', self.origin + '0 0 16' + v_forward * 48, TRUE, self);

      if (trace_fraction < 1) {
         sound(self, CHAN_WEAPON, "generic/punch1.wav", 1, ATTN_NORM);

         WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
         WriteByte (MSG_BROADCAST, TE_GUNSHOT);
         WriteCoord (MSG_BROADCAST, trace_endpos_x);
         WriteCoord (MSG_BROADCAST, trace_endpos_y);
         WriteCoord (MSG_BROADCAST, trace_endpos_z);
      }

      return;
   }

   delta = plyr.origin - self.origin;

   if (vlen(delta) > 60)
      return;

   if (plyr.classname == "xmen_iceman")
      IcemanShardGib(plyr, 3);
   else if ((plyr.classname != "xmen_sinister") || (plyr.x_flags & X_MEGA_HIT))
      SpawnBlood(self.origin + v_forward * 16 + '0 0 16', '0 0 0', 9);

   ldmg = 9 + random() * 3;
   T_Damage (plyr, self, self, ldmg);

   if ((plyr.flags & FL_MONSTER) &&
       (plyr.classname != "xmen_sinister") &&
       (plyr.classname != "apocalypse_small")) {
      plyr.velocity = normalize(plyr.origin - self.origin) * 150 + '0 0 100';
      plyr.flags = plyr.flags - (plyr.flags & FL_ONGROUND);
      setorigin(plyr, plyr.origin + '0 0 1');
   }

   if (random() < 0.5)
      sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
   else
      sound(self, CHAN_WEAPON, "generic/punch3.wav", 1, ATTN_NORM);
};

void()   player_fist  =
{
   self.weapon_flags = self.weapon_flags | W_RELOADING;

   if (self.weaponframe >= 15) {
      self.weaponframe = self.weapon_idleframe;
   }

   self.weaponframe = self.weaponframe + 1;

   self.frame = $xatta1 + (self.weaponframe - 5);

   self.think = player_fist;

   if (self.weaponframe == 8) {
      SuperDamageSound();
      PlayerPunch();
   }

   if ((self.weaponframe >= 14) && ((!self.button0) || (self.remember_impulse))) {
      self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);
      self.think = player_run;
      self.weaponframe = self.weapon_idleframe;
   }

   self.nextthink = time + 0.05;
};

//============================================================================

void() DoSpecialWeaponStuff;
void()   player_att1  =
{
   self.weapon_flags = self.weapon_flags | W_RELOADING;

   if (self.weaponframe > 18)
      self.weaponframe = self.weaponframe - 12;

   if (self.weaponframe >= 18) { // still holding down fire
      if (!((self.character == CHAR_CANNONBALL) && (self.special_weapon) && (self.last_special2 > (time - 2)) ))
         self.weaponframe = 6;
   }

   self.weaponframe = self.weaponframe + 1;

   self.think = player_att1;

   DoSpecialWeaponStuff();

   if ((self.weaponframe >= 18) && ((!self.button0) || (self.remember_impulse))) {
      self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);
      self.think = player_run;
      self.weaponframe = 6;
   }

   if ((!self.special_weapon && self.character != CHAR_WOLVERINE) ||
	   (self.special_weapon && self.character == CHAR_WOLVERINE))
      self.frame = $xatta1 + (self.weaponframe - 7);
   else {
      self.frame = $xattb1 + (self.weaponframe - 7);
      self.weaponframe = self.weaponframe + 12;
   }

   if (self.x_flags & X_RAPID_FIRE) {
      if ((self.character == CHAR_BISHOP) && (!self.special_weapon)) {
         // skip frames to go faster

         if ((self.weaponframe == 11) ||
             (self.weaponframe == 16)) {
            self.weaponframe = self.weaponframe + 1;
         }
      }

      self.nextthink = time + 0.05;
   }
   else if ((self.character == CHAR_BISHOP) && (!self.special_weapon)) {
      self.nextthink = time + 0.05;
   }
   else {
      self.nextthink = time + 0.1;
   }

};

//============================================================================

void() player_laser1   =[$bolt1, player_laser1  ]
{
   self.effects = self.effects | EF_MUZZLEFLASH;

   if ((!self.button0) || (!W_CheckNoAmmo ()) || (self.change_weapon_status))
   {
      self.weaponframe = 5;
      player_run ();
      return;
   }

   if ((self.w_pausetime < time) || (self.x_flags & X_RAPID_FIRE)) {

      self.weaponframe = self.weaponframe + 1;
      if (self.weaponframe > 14)
         self.weaponframe = 6;

      self.walkframe = self.walkframe + 1;
      if (self.walkframe > 5)
         self.walkframe = 0;

      self.fire_reload_frames = self.fire_reload_frames - 1;

      if ((self.last_fire_laser > (time - 0.4)) && (self.weaponframe == 6) && !(self.x_flags & X_RAPID_FIRE)) {
         self.w_pausetime = time + 0.5;
         self.consecutive_count = 0;
         self.weaponframe = 5;

         self.walkframe = 1;
      }
      else {

         if (self.fire_reload_frames <= 0) {
            if (self.waterlevel < 3) {      // can't fire while underwater
               SuperDamageSound();
               W_FireFlameball (8);
            }

            self.last_fire_laser = time;
            self.attack_finished = time + 0.2;

            self.fire_reload_frames = 3;
         }
         else {
            self.nextthink = time + 0.05;
         }
      }

   }

   self.frame = self.frame + self.walkframe;

};

void() player_shotgun1  = [$shot1, player_shotgun1  ]
{
   if (self.weaponframe == 5) {

      if ((!(self.weapon_flags & W_RELOADING)) &&
          ((self.change_weapon_status) ||
           (!self.button0) ||
           (!W_CheckNoAmmo()))) {

         player_run ();
         return;
      }

      self.effects = self.effects | EF_MUZZLEFLASH;
      self.walkframe = -1;
      W_FireSuperShotgun();

      self.weapon_flags = self.weapon_flags | W_RELOADING;
   }

   if (self.change_weapon_status)
      return;

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 17)
      self.walkframe = 17;
   self.frame = self.frame + self.walkframe;

   self.weaponframe = self.weaponframe + 1;

   if ((self.weaponframe > 22) || ((self.weaponframe > 8) && !(self.weapon_flags & W_SHOTRELOAD))) {
      self.weaponframe = 5;

      if (!(self.weapon_flags & W_SHOTRELOAD) && !(self.x_flags & X_RAPID_FIRE))
         self.weapon_flags = self.weapon_flags | W_SHOTRELOAD;
      else
         self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_SHOTRELOAD);

      self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);
   }
   else if (self.weaponframe == 10) {
      sound (self ,CHAN_ITEM, "weapons/reload.wav", 1, ATTN_NORM);
   }
   else if (self.weaponframe > 8)
      self.nextthink = time + 0.05;

};

// 20060704 LordHavoc: hushed a compiler warning by making this take no parameters
void() W_FireSuperSpikes;

void() player_chain1   = [$chain1, player_chain1  ]
{
   if (self.change_weapon_status) {
      self.weaponframe = 5;
      player_run ();
      return;
   }

//   self.nextthink = time + 0.05;

   if ((!self.button0) || (!W_CheckNoAmmo ())) {
      self.weaponframe = 5;
      player_run ();
      return;
   }

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 5)
      self.walkframe = 0;
   self.frame = self.frame + self.walkframe;

   if ((self.w_pausetime < time) || (self.x_flags & X_RAPID_FIRE)) {

      self.weaponframe = self.weaponframe + 1;
      if (self.weaponframe > 11)
         self.weaponframe = 6;

      self.effects = self.effects | EF_MUZZLEFLASH;

      SuperDamageSound();
      // 20060704 LordHavoc: hushed a compiler warning by making W_FireSuperSpikes take no parameters
      W_FireSuperSpikes ();

      self.consecutive_count = self.consecutive_count + 1;

      if (self.consecutive_count >= 15) {     // let gun cool down
         self.w_pausetime = time + 0.5;
/*
         self.w_pausetime = time + self.last_pausetime + 0.5;
         self.last_pausetime = self.last_pausetime + 0.2;
         if (self.last_pausetime > 1.5)
            self.last_pausetime = 1.5;
*/

         self.consecutive_count = 0;
         self.weaponframe = 5;
      }

   }

   self.attack_finished = time + 0.2;
};

/**************** NOT USED ****************************
void() player_nail1   =[$nailatt1, player_nail2  ]
{
   self.effects = self.effects | EF_MUZZLEFLASH;

   if (!self.button0)
      {player_run ();return;}
   self.weaponframe = self.weaponframe + 1;
   if (self.weaponframe == 9)
      self.weaponframe = 1;
   SuperDamageSound();
   W_FireSpikes (4);
   self.attack_finished = time + 0.2;
};
void() player_nail2   =[$nailatt2, player_nail1  ]
{
   self.effects = self.effects | EF_MUZZLEFLASH;

   if (!self.button0)
      {player_run ();return;}
   self.weaponframe = self.weaponframe + 1;
   if (self.weaponframe == 9)
      self.weaponframe = 1;
   SuperDamageSound();
   W_FireSpikes (-4);
   self.attack_finished = time + 0.2;
};
********************************************************/

//============================================================================

void() player_mega   =[$chain1, player_mega  ]
{
// self.effects = self.effects | EF_MUZZLEFLASH;

   if ((!self.button0) || (!W_CheckNoAmmo ()) || (self.change_weapon_status)) {
      player_run ();
      return;
   }

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 5)
      self.walkframe = 0;
   self.frame = self.frame + self.walkframe;

   self.weaponframe = self.weaponframe + 1;
   if (self.weaponframe > 17)
      self.weaponframe = 12;

   if ((self.weaponframe == 12) && (random() < 0.4))
      sound (self, CHAN_AUTO, "weapons/mega.wav", 1, ATTN_NONE);

   W_FireLightning();
   self.attack_finished = time + 0.2;
};

void() player_prox1   =[$chain1, player_prox1  ]
{
// self.effects = self.effects | EF_MUZZLEFLASH;
//bprint("player_prox\n");

   if (((!self.button0) || (self.change_weapon_status)) && (self.weaponframe < 11) && (self.weaponframe > 5)) {
      SuperDamageSound();
      W_FireProximity();

      self.weaponframe = 11;

      self.think = player_run;
      W_CheckNoAmmo();

      return;
   }

   if (self.weaponframe == 5) {
//      if (self.prox_ent == world) {
         self.prox_power = 0;
         StartProximity();
//      }
   }

   if (self.weaponframe < 10) {
      self.weaponframe = self.weaponframe + 1;
   }
   else if (self.weaponframe >= 11) {
      self.weaponframe = self.weaponframe + 1;

      if (self.weaponframe > 15) {
         player_run();
         return;
      }
   }

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 5)
      self.walkframe = 0;
   self.frame = self.frame + self.walkframe;

   self.attack_finished = time + 0.2;
   self.last_prox_think = time;
};

void() player_flame1   =[$bolt1, player_flame1  ]
{
//	self.effects = self.effects | EF_MUZZLEFLASH;

   if ((!self.button0) || (!W_CheckNoAmmo ()) || (self.change_weapon_status)) {
      player_run ();
      self.flags = self.flags - (self.flags & FL_FLAMEON);
      return;
   }

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 5)
      self.walkframe = 0;
   self.frame = self.frame + self.walkframe;

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe > 8)
		self.weaponframe = 6;

	SuperDamageSound();
//	W_FireLightning();
   W_FireFlameThrower();
	self.attack_finished = time + 0.2;
};

void() player_orb   =[$rock1, player_orb  ]
{
// self.effects = self.effects | EF_MUZZLEFLASH;
   if ((((self.weaponframe == 5) || (self.weaponframe == 11)) && (!self.button0)) ||
       (!W_CheckNoAmmo ()) || (self.change_weapon_status)) {
      self.weaponframe = 5;
      player_run ();
      return;
   }

   self.walkframe = self.walkframe + 1;
   if (self.walkframe > 12)
      self.walkframe = 0;
   self.frame = self.frame + self.walkframe;

   self.weaponframe = self.weaponframe + 1;
   if (self.weaponframe > 17) {
      self.weaponframe = 5;
   }

   if ((self.weaponframe == 6) || (self.weaponframe == 12)) {
      SuperDamageSound();
      W_FireGrenade();
      self.attack_finished = time + 0.7;
   }
   else if ((self.weaponframe > 12) && (!(self.x_flags & X_RAPID_FIRE))) {
      self.nextthink = time + 0.15;
   }
   else
      self.nextthink = time + 0.05;

};

//============================================================================

void() player_rocket16;

void() player_rocket1   =[$rock1, player_rocket2  ] {self.weaponframe=6;
self.effects = self.effects | EF_MUZZLEFLASH;
self.weapon_flags = self.weapon_flags | W_RELOADING;};
void() player_rocket2   =[$rock2, player_rocket3  ] {self.weaponframe=7;};
void() player_rocket3   =[$rock3, player_rocket4  ] {self.weaponframe=8;};
void() player_rocket4   =[$rock4, player_rocket5  ] {self.weaponframe=9;};
void() player_rocket5   =[$rock5, player_rocket6  ] {self.weaponframe=10;};
void() player_rocket6   =[$rock6, player_rocket7  ]
{
   self.weaponframe=11;

   if (self.x_flags & X_RAPID_FIRE)
      self.think = player_rocket16;
};
void() player_rocket7   =[$rock7, player_rocket8  ] {self.weaponframe=12; self.nextthink = time + 0.05;};
void() player_rocket8   =[$rock8, player_rocket9  ] {self.weaponframe=13; self.nextthink = time + 0.05;};
void() player_rocket9   =[$rock9, player_rocket10 ] {self.weaponframe=14; self.nextthink = time + 0.05;};
void() player_rocket10  =[$rock10, player_rocket11 ] {self.weaponframe=15; self.nextthink = time + 0.05;};
void() player_rocket11  =[$rock11, player_rocket12 ] {self.weaponframe=16; self.nextthink = time + 0.05;};
void() player_rocket12  =[$rock12, player_rocket13 ] {self.weaponframe=1; self.nextthink = time + 0.05;};
void() player_rocket13  =[$rock13, player_rocket14 ] {self.weaponframe=2; self.nextthink = time + 0.05;};
void() player_rocket14  =[$rock14, player_rocket15 ] {self.weaponframe=3; self.nextthink = time + 0.05;};
void() player_rocket15  =[$rock15, player_rocket16 ] {self.weaponframe=4; self.nextthink = time + 0.05;};
void() player_rocket16  =[$rock16, player_run      ] {self.weaponframe=5;
self.weapon_flags = self.weapon_flags - (self.weapon_flags & W_RELOADING);
self.attack_finished = time;
};
void(float num_bubbles) DeathBubbles;

void() PainSound =
{
local float		rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

   if (!deathmatch && !coop) {
   // water pain sounds
      if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
      {
         DeathBubbles(1);
         if (random() > 0.5)
            sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
         else
            sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
         return;
      }

      if (self.watertype == CONTENT_LAVA)
      {
         if (random() > 0.5)
            sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
         else
            sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
         return;
      }
   }

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

   if (deathmatch || coop) {
      if (self.char_type == CT_FEMALE)
         FemalePainSound();
      else
         MalePainSound(self.char_type);
   }
   else {
      rs = random() * 4;

      if (rs < 1)
         sound(self, CHAN_VOICE, "player/pain1.wav", 1, ATTN_NORM);
      else if (rs < 2)
         sound(self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_NORM);
      else if (rs < 3)
         sound(self, CHAN_VOICE, "player/pain3.wav", 1, ATTN_NORM);
      else
         sound(self, CHAN_VOICE, "player/pain4.wav", 1, ATTN_NORM);
   }

};

void()	player_pain1 =	[	$pgun1,	player_pain2	] {};
void()	player_pain2 =	[	$pgun2,	player_pain3	] {};
void()	player_pain3 =	[	$pgun3,	player_pain4	] {};
void()	player_pain4 =	[	$pgun4,	player_pain5	] {};
void()	player_pain5 =	[	$pgun5,	player_pain6	] {};
void()	player_pain6 =	[	$pgun6,	player_run	] {};

void()	player_painaxe1 =	[	$pain1,	player_painaxe2	] {};
void()	player_painaxe2 =	[	$pain2,	player_painaxe3	] {};
void()	player_painaxe3 =	[	$pain3,	player_painaxe4	] {};
void()	player_painaxe4 =	[	$pain4,	player_painaxe5	] {};
void()	player_painaxe5 =	[	$pain5,	player_painaxe6	] {};
void()	player_painaxe6 =	[	$pain6,	player_run	] {};

void() player_pain =
{
	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

   PainSound();

   if (self.weaponframe != self.weapon_idleframe)
      return;

   if (self.prox_ent != world)
      return;

	if (self.weapon == IT_AXE)
		player_painaxe1 ();
	else
		player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_dguna1;
void() player_dgunb1;

void() DeathBubblesSpawn =
{
local entity	bubble;
	if (self.owner.waterlevel != 3)
		return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;

	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() DeathSound =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local float		rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}

   if (deathmatch || coop) {
      if (self.char_type == CT_FEMALE)
         FemaleDeathSound();
      else
         MaleDeathSound(self.char_type);
   }
//   else
//      MaleDeathSound(1);

	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

vector(float dm) VelocityForDamage =
{
   local vector v;

   if (damage_attacker.classname == "player")
   {
      if (vlen(damage_inflictor.velocity) > 0)
         v = 0.5 * damage_inflictor.velocity;
      v = v + (400 * normalize(self.origin-damage_attacker.origin));
      v = v * random();
      v_z = 100 + 240 * random();
      v_x = v_x + (100 * crandom());
      v_y = v_y + (100 * crandom());
//bprint ("Velocity gib\n");
   }
   else
   {
      v_x = 100 * crandom();
      v_y = 100 * crandom();
      v_z = 200 + 100 * random();
   }

// v_x = 200 * crandom();
// v_y = 200 * crandom();
// v_z = 400 + 100 * random();

   if (dm > -30)
   {
//    dprint ("level 1\n");
      v = v * 1;
   }
   else if (dm > -80)
   {
//    dprint ("level 3\n");
      v = v * 1.5;
   }
   else
      v = v * 3;

   return v;
};

void() GibThink =
{
   if ((self.angles_x != 0) && (self.velocity == '0 0 0')) {
      self.angles_x = 0;
      self.angles_z = 0;
      self.avelocity = '0 0 0';
      self.movetype = MOVETYPE_NONE;

      if (self.model == "progs/gib01.mdl")
         setorigin(self, self.origin + '0 0 4');

      self.think = SUB_Remove;
      self.nextthink = time + 5 + random()*5;

      return;
   }

   self.nextthink = time + 0.1;

   if (self.ltime < time)
      remove(self);

};

void(string gibname, float dm) ThrowGib =
{
	local	entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_TRIGGER;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = GibThink;
	new.ltime = time + 10 + random() * 5;
	new.nextthink = time + 0.1;
	new.frame = 0;
	new.flags = 0;

   if (self.classname == "func_explode")
      new.skin = self.speed;
};

void(string gibname, float dm) ThrowBodyPart =
{
   local entity new;

   new = spawn();
   new.origin = self.origin;
   setmodel (new, gibname);
   setsize (new, '-4 -4 -4', '4 4 4');
   new.velocity = VelocityForDamage (dm);
   new.movetype = MOVETYPE_BOUNCE;
   self.solid = SOLID_NOT;
   new.avelocity_x = random()*600;
   new.avelocity_y = random()*600;
   new.avelocity_z = random()*600;
   new.think = SUB_Remove;
   new.ltime = time + 5 + random() * 5;
   new.nextthink = time + 10 + random()*10;
   new.frame = 0;
   new.flags = 0;

   new.think = GibThink;
   new.nextthink = time + 0.2;
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_TRIGGER;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 -8', VEC_HULL_MAX);
	self.velocity = VelocityForDamage (dm * 2);
//	self.origin_z = self.origin_z + ;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '200 600 200';

//   self.think = GibThink;
//   self.nextthink = time + 0.2;
};


void() GibPlayer =
{
	ThrowHead ("progs/gib01.mdl", self.health);
	ThrowGib ("progs/gib02.mdl", self.health);
   ThrowGib ("progs/gib02.mdl", self.health);
   ThrowGib ("progs/gib02.mdl", self.health);
	ThrowGib ("progs/gib03.mdl", self.health);
   ThrowGib ("progs/gib03.mdl", self.health);
   ThrowGib ("progs/gib03.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

   sound(self, CHAN_BODY, "skeleton/crunch.wav", 1, ATTN_NORM);
};

void() PlayerDie =
{
	local	float	i;
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local string str;

	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;

   if (self.modelindex != index_skeleton)
    self.modelindex = self.modelindex_player;    // don't use eyes

	if (deathmatch && (deathmatch != DM_SPECIAL_POWERS) && (self.modelindex != index_skeleton))
		DropBackpack();

	self.weaponmodel="";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
   self.flags = self.flags - (self.flags & FL_FLAMEON);

   self.x_flags = self.x_flags - (self.x_flags & X_FLYING);
   self.x_flags = self.x_flags - (self.x_flags & X_RAPID_FIRE);
   self.x_flags = self.x_flags - (self.x_flags & X_PARALLIZED);

   self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.modelindex == index_skeleton)
	{
		GibPlayer ();
		return;
	}

	DeathSound();

	self.angles_x = 0;
	self.angles_z = 0;

   i = 1 + floor(random()*2);

	if (self.weapon == IT_AXE)
	{
      if (i == 1)
         player_diea1();
      else if (i == 2)
         player_dieb1();

		return;
	}

	if (i == 1)
		player_dguna1();
	else if (i == 2)
		player_dgunb1();

};

void() set_suicide_frame =
{	// used by klill command and diconnect command
	if (self.deadflag == DEAD_DEAD)
		return;	// allready gibbed

   self.flags = self.flags - (self.flags & FL_FLAMEON);

   self.x_flags = self.x_flags - (self.x_flags & X_FLYING);
   self.x_flags = self.x_flags - (self.x_flags & X_RAPID_FIRE);
   self.x_flags = self.x_flags - (self.x_flags & X_PARALLIZED);

	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()   player_diea11  =  [  $deatha11,  player_diea12  ] {};
void()	player_diea12	=	[	$deatha12,	player_diea12 ] {PlayerDead();};

void()   player_dieb1   =  [  $deathb1,   player_dieb2   ] {};
void()   player_dieb2   =  [  $deathb2,   player_dieb3   ] {};
void()   player_dieb3   =  [  $deathb3,   player_dieb4   ] {};
void()   player_dieb4   =  [  $deathb4,   player_dieb5   ] {};
void()   player_dieb5   =  [  $deathb5,   player_dieb6   ] {};
void()   player_dieb6   =  [  $deathb6,   player_dieb7   ] {};
void()   player_dieb7   =  [  $deathb7,   player_dieb8   ] {};
void()   player_dieb8   =  [  $deathb8,   player_dieb9   ] {};
void()   player_dieb9   =  [  $deathb9,   player_dieb10  ] {};
void()   player_dieb10  =  [  $deathb10,  player_dieb11  ] {};
void()   player_dieb11  =  [  $deathb11,  player_dieb12  ] {};
void()   player_dieb12  =  [  $deathb12,  player_dieb12 ] {PlayerDead();};

void()   player_dguna1   =  [  $dguna1,   player_dguna2   ] {};
void()   player_dguna2   =  [  $dguna2,   player_dguna3   ] {};
void()   player_dguna3   =  [  $dguna3,   player_dguna4   ] {};
void()   player_dguna4   =  [  $dguna4,   player_dguna5   ] {};
void()   player_dguna5   =  [  $dguna5,   player_dguna6   ] {};
void()   player_dguna6   =  [  $dguna6,   player_dguna7   ] {};
void()   player_dguna7   =  [  $dguna7,   player_dguna8   ] {};
void()   player_dguna8   =  [  $dguna8,   player_dguna9   ] {};
void()   player_dguna9   =  [  $dguna9,   player_dguna10  ] {};
void()   player_dguna10  =  [  $dguna10,  player_dguna11  ] {};
void()   player_dguna11  =  [  $dguna11,  player_dguna12  ] {};
void()   player_dguna12  =  [  $dguna12,  player_dguna12 ] {PlayerDead();};

void()   player_dgunb1   =  [  $dgunb1,   player_dgunb2   ] {};
void()   player_dgunb2   =  [  $dgunb2,   player_dgunb3   ] {};
void()   player_dgunb3   =  [  $dgunb3,   player_dgunb4   ] {};
void()   player_dgunb4   =  [  $dgunb4,   player_dgunb5   ] {};
void()   player_dgunb5   =  [  $dgunb5,   player_dgunb6   ] {};
void()   player_dgunb6   =  [  $dgunb6,   player_dgunb7   ] {};
void()   player_dgunb7   =  [  $dgunb7,   player_dgunb8   ] {};
void()   player_dgunb8   =  [  $dgunb8,   player_dgunb9   ] {};
void()   player_dgunb9   =  [  $dgunb9,   player_dgunb10  ] {};
void()   player_dgunb10  =  [  $dgunb10,  player_dgunb11  ] {};
void()   player_dgunb11  =  [  $dgunb11,  player_dgunb12  ] {};
void()   player_dgunb12  =  [  $dgunb12,  player_dgunb12 ] {PlayerDead();};

