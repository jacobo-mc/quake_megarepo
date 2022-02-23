// -------------------------------------------------------
//   Special Weapon code (Deathmatch only)
//
//   The main procedure is at the end, this is called every
//   frame during a special attack.
// -------------------------------------------------------

void() SpecialWeaponChange =
{
   if (self.character == CHAR_WOLVERINE) {
      if (!self.special_weapon)
         sprint(self, "Claw Attack selected.\n");
      else
         sprint(self, "Jump Attack selected.\n");
   }
   else if (self.character == CHAR_STORM) {
      if (!self.special_weapon)
         sprint(self, "Wind Attack selected.\n");
      else
         sprint(self, "Lightning Attack selected.\n");
   }
   else if (self.character == CHAR_CYCLOPS) {
      if (!self.special_weapon)
         sprint(self, "Fast Laser selected.\n");
      else
         sprint(self, "Mega-Laser selected.\n");
   }
   else if (self.character == CHAR_PSYLOCKE) {
      if (!self.special_weapon)
         sprint(self, "Sword Attack selected.\n");
      else
         sprint(self, "Psychic Paralyze selected.\n");
   }
   else if (self.character == CHAR_ANGEL) {
      if (!self.special_weapon)
         sprint(self, "Dart Spray selected.\n");
      else
         sprint(self, "Wing Defense selected.\n");
   }
   else if (self.character == CHAR_BEAST) {
      if (!self.special_weapon)
         sprint(self, "Triple Punch selected.\n");
      else
         sprint(self, "Floor Pound selected.\n");
   }
   else if (self.character == CHAR_GAMBIT) {
      if (!self.special_weapon)
         sprint(self, "Staff Attack selected.\n");
      else
         sprint(self, "Throwing Cards selected.\n");
   }
   else if (self.character == CHAR_ICEMAN) {
      if (!self.special_weapon)
         sprint(self, "Shard Attack selected.\n");
      else
         sprint(self, "Freeze Blast selected.\n");
   }
   else if (self.character == CHAR_BISHOP) {
      if (!self.special_weapon)
         sprint(self, "Gun Attack selected.\n");
      else
         sprint(self, "Energy Blast selected.\n");
   }
   else if (self.character == CHAR_ROGUE) {
      if (!self.special_weapon)
         sprint(self, "Single Punch selected.\n");
      else
         sprint(self, "Super Punch selected.\n");
   }
   else if (self.character == CHAR_CANNONBALL) {
      if (!self.special_weapon)
         sprint(self, "Punch Attack selected.\n");
      else
         sprint(self, "Flying Punch selected.\n");
   }
   else if (self.character == CHAR_PHOENIX) {
      if (!self.special_weapon)
         sprint(self, "Tractor Beam selected.\n");
      else
         sprint(self, "Homing Blast selected.\n");
   }
};

void(float side)  Wolvy_Melee =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   other;

   makevectors (self.angles);
   traceline(self.origin, self.origin + v_forward  * 48, FALSE, self);

   if ((trace_ent != world) && (trace_ent.takedamage != DAMAGE_NO))
      other = trace_ent;
   else
      return;

   sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
   T_Damage (other, self, self, 15);

   SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void()   Wolvy_JumpThink =
{
   local float ldmg;
    local vector    dir;

   if (self.health <= 0)
      return;

    // check for enemy getting hit
    makevectors(self.v_angle);
    dir = v_forward;
    traceline(self.origin, self.origin + dir * 128, FALSE, self);
   if ((trace_ent != world) && (trace_ent.takedamage != DAMAGE_NO))
   {
        ldmg = 8 + 5*random();
        T_Damage (trace_ent, self, self, ldmg);
        trace_ent.punchangle_x = -10;

        sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
    }
};

void() Wolvy_Jump =
{
   if (!(self.flags & FL_ONGROUND))
      return;

   makevectors (self.v_angle);

   self.origin_z = self.origin_z + 1;
   self.velocity = v_forward * 700 + '0 0 210';
   if (self.velocity_z > 350)
      self.velocity_z = 350;

   sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

   if (self.flags & FL_ONGROUND)
      self.flags = self.flags - FL_ONGROUND;
};

void() Storm_Lightning =
{
   local vector   dir;

   self.effects = self.effects | EF_MUZZLEFLASH;

   makevectors(self.v_angle);
   dir = v_forward;

   traceline (self.origin + '0 0 16', self.origin + dir*600 + '0 0 16', TRUE, self);

   msg_entity = self;

   WriteByte (MSG_ONE, SVC_TEMPENTITY);
   WriteByte (MSG_ONE, TE_LIGHTNING1);
   WriteEntity (MSG_ONE, self);
   WriteCoord (MSG_ONE, self.origin_x);
   WriteCoord (MSG_ONE, self.origin_y);
   WriteCoord (MSG_ONE, self.origin_z + 8);
   WriteCoord (MSG_ONE, trace_endpos_x);
   WriteCoord (MSG_ONE, trace_endpos_y);
   WriteCoord (MSG_ONE, trace_endpos_z);

   // show lightning differently for others

   msg_entity = find(msg_entity, classname, "player");
   if (msg_entity == world)
      msg_entity = find(msg_entity, classname, "player");

   while (msg_entity != self) {
      WriteByte (MSG_ONE, SVC_TEMPENTITY);
      WriteByte (MSG_ONE, TE_LIGHTNING1);
      WriteEntity (MSG_ONE, self);
      WriteCoord (MSG_ONE, self.origin_x);
      WriteCoord (MSG_ONE, self.origin_y);
      WriteCoord (MSG_ONE, self.origin_z + 20);
      WriteCoord (MSG_ONE, trace_endpos_x);
      WriteCoord (MSG_ONE, trace_endpos_y);
      WriteCoord (MSG_ONE, trace_endpos_z);

      msg_entity = find(msg_entity, classname, "player");
      if (msg_entity == world)
         msg_entity = find(msg_entity, classname, "player");
   }


   LightningDamage (self.origin + '0 0 16', trace_endpos, self, 15);
};

void() Storm_Wind =
{
   local entity   trav;
   local float    strength, dist;
   local vector   vect, vect_angle;

   sound (self, CHAN_WEAPON, "storm/w_attack.wav", 1, ATTN_NORM);

   trav = findradius(self.origin, 256);
   while (trav != world) {

      // check that the object is damage-able and is infront of self
      vect = normalize(trav.origin - self.origin);
      vect_angle = vectoangles(vect);

      if ((trav != self) &&
          ((trav.takedamage) && (trav.movetype)) &&
          (fabs( angle_diff( vect_angle_y, self.angles_y)) < 35)) {    // give em some wind

         strength = 200;
         dist = vlen(trav.origin - self.origin);
         if (dist > 128) {    // reduce strength of blast
            strength = ((dist - 128) / 128) * strength;
         }

         // blast now
         trav.flags = trav.flags - (trav.flags & FL_ONGROUND);
         trav.velocity = (trav.velocity * 0.5) + (vect * 600);
         trav.velocity_z = 300;

         trav.angles = trav.v_angle = self.angles;
         trav.punchangle_x = -20;
         trav.fixangle = TRUE;

      }

      trav = trav.chain;
   }

   self.last_wind = time;
};

void() LaserTouch;
void() DM_Cyclops_Fast_Laser =
{
   local entity   missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;

   self.effects = self.effects | EF_MUZZLEFLASH;
   stuffcmd(self, "rf\n");    // flash screen red

   sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
   missile.classname = "laser";

   makevectors(self.v_angle);
   missile.velocity = v_forward * 1700;

   missile.angles = vectoangles(missile.velocity);
   missile.old_velocity = missile.velocity;

   missile.touch = LaserTouch;

   missile.last_touch = 0;
   missile.oldorigin = missile.origin;
   missile.nextthink = time + 2;
   // 20060705 LordHavoc: added missile.cnt = time + 0.2; for enhanced laser stuckness check
   missile.cnt = time + 0.2;
   missile.think = SUB_Remove;

   setmodel (missile, "progs/claser1.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, self.origin + v_forward * 16 + '0 0 22');
};

void() DM_Big_Laser_Touch =
{
   if (other == self.owner)
      return;

   if (other.takedamage == DAMAGE_AIM)
   {
      spawn_touchblood (20);
      T_Damage(other, self, self.owner, 30);
      remove(self);
      return;
   }

   self.last_touch = time;

   sound (self, CHAN_WEAPON, "doors/airdoor2.wav", 1, ATTN_NORM);
   if (self.velocity == '0 0 0')
          remove(self);

};

void() DM_Cyclops_Big_Laser =
{
   local entity   missile;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;

   self.effects = self.effects | EF_MUZZLEFLASH;
   stuffcmd(self, "rf\n");    // flash screen red

   sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_BOUNCE;
   missile.solid = SOLID_BBOX;
   missile.classname = "laser";

   makevectors(self.v_angle);
   missile.velocity = v_forward * 1200;

   missile.angles = vectoangles(missile.velocity);
   missile.old_velocity = missile.velocity;

   missile.touch = DM_Big_Laser_Touch;

   missile.last_touch = 0;
   missile.oldorigin = missile.origin;
   missile.nextthink = time + 2;
   // 20060705 LordHavoc: added missile.cnt = time + 0.2; for enhanced laser stuckness check
   missile.cnt = time + 0.2;
   missile.think = SUB_Remove;

   setmodel (missile, "progs/claser1.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, self.origin + v_forward * 16 + '0 0 22');
};

void() DM_Psylocke_Sword =
{
   local entity   plyr;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   delta;
   local float    ldmg;

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*55, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
      plyr = trace_ent;
   else
      return;

//   if ((plyr = FindSightEnemy(self.origin, v_forward, 60, 40, "player", self)) == world)
//      return;
/*
   delta = plyr.origin - self.origin;

   if (vlen(delta) > 70)
      return;
*/
   ldmg = 15 + random() * 5;
   T_Damage (plyr, self, self, ldmg);
};


void() DM_Psylocke_Parallize =
{
   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*48, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
   {
      // got 'em
      sound(self, CHAN_WEAPON, "player/what_1.wav", 1, ATTN_NORM);

      trace_ent.parallize_time = time + 3;
      trace_ent.x_flags = trace_ent.x_flags | X_PARALLIZED;
      trace_ent.parallized_velocity = '0 0 0';
      centerprint(trace_ent, "You have been paralyzed");
      stuffcmd(trace_ent, "pl\n");
   }
};

void(float  heading_ofs)   DM_AngelFeather =
{
   local vector   newangle;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   targ_vect;
   //local entity   missile;

   newangle = self.v_angle;
   newangle_y = anglemod(newangle_y + heading_ofs);

   newangle_x = newangle_x + (random() * 10) - 5;

   makevectors(newangle);

   launch_spike (self.origin + '0 0 16' + v_forward*14, v_forward);
   newmis.classname = "angel_dart";
   setmodel (newmis, "progs/dart.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void() DM_BeastPunch =
{
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//local vector   delta;
local float    ldmg;
local entity   plyr;

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*55, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
      plyr = trace_ent;
   else
      return;

   ldmg = 9 + random() * 3;
   T_Damage (plyr, self, self, ldmg);

   if (random() < 0.5)
      sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
   else
      sound(self, CHAN_WEAPON, "generic/punch3.wav", 1, ATTN_NORM);
};

void() BeastPowTouch;
void() BeastPowThink;
void() DM_BeastPound =
{
   local entity   trav, plyr;
   local entity   missile;
   local vector   vec;

   missile = spawn();
   missile.classname = "beast_power";
   missile.owner = self;
   missile.solid = SOLID_TRIGGER;
   missile.movetype = MOVETYPE_FLY;

   setsize(missile, '0 0 0', '0 0 0');
   setmodel(missile, "progs/pow.mdl");

   makevectors(self.angles);

   if ((plyr = FindSightEnemy(self.origin, v_forward, 256, 20, "player", self)) != world)
      missile.velocity = normalize(plyr.origin - self.origin + plyr.velocity * 0.5) * 750;
   else {
      missile.velocity = v_forward * 750;
   }
   missile.velocity_z = 0;

   setorigin(missile, self.origin + v_forward * 16);

   vec = missile.velocity;
   traceline(missile.origin + vec*frametime*2 + '0 0 32', missile.origin + vec*frametime*2 - '0 0 48', TRUE, world);
   if (trace_fraction <= 1) {
      missile.velocity = normalize(trace_endpos + '0 0 24' - missile.origin) * 750;

      traceline(missile.origin + '0 0 32', missile.origin - '0 0 48', TRUE, world);
      setorigin(missile, trace_endpos + '0 0 24');
   }

   missile.touch = BeastPowTouch;
   missile.think = BeastPowThink;
   missile.nextthink = time + 0.05;
   missile.spawn_time = time;

   sound (self, CHAN_BODY, "weapons/r_exp3.wav", 0.4, ATTN_NORM);
   sound (self, CHAN_WEAPON, "doors/stndr1.wav", 1, ATTN_NORM);

   // send players airbourne
   trav = find(world, classname, "player");
   while (trav != world) {
      if ((trav.flags & FL_ONGROUND) && (vlen(trav.origin - self.origin) < 256))
         trav.velocity_z = 200;

      trav = find(trav, classname, "player");
   }
};

void() DM_Gambit_Strike =
{
   local entity   plyr;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;
   local float    damg;

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*55, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
      plyr = trace_ent;
   else
      return;

   damg = 20 + random() * 5;
   T_Damage (plyr, self, self, damg);
};

void(float  heading_ofs, float zofs) DM_GambitCard =
{
   local vector   newangle, targ_vect, ofs;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   makevectors(self.v_angle);
   targ_vect = v_forward;
   newangle  = vectoangles(targ_vect);
   newangle_x = -1 * newangle_x;
   newangle_y = anglemod(newangle_y + heading_ofs);

   makevectors(newangle);

   ofs = '0 0 0';
   ofs_z = zofs;
   launch_spike (self.origin + ofs + v_forward*14, v_forward);
   newmis.classname = "gambit_card";
   setmodel (newmis, "progs/card.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void(vector org, vector dir) spawn_shard;
void(float offs) DM_Iceman_Shard =
{
   local vector org, vect, ang;

   ang = self.v_angle;
   ang_y = anglemod(ang_y + offs);

   makevectors (ang);
   vect = v_forward;

   org = self.origin + '0 0 12';

   spawn_shard(org, vect);
};

void(vector org, vector dir) spawn_iceball;
void() DM_Iceman_Iceball =
{
   local vector org;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector o2;

   makevectors (self.v_angle);

   org = self.origin + v_forward * 12 + '0 0 16';

   spawn_iceball(org, v_forward);
};


void(float  r_ofs) DM_Bishop_Shoot =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local vector   vect;
   //local entity   missile;

   self.effects = self.effects | EF_MUZZLEFLASH;

   makevectors(self.v_angle);

   sound (self, CHAN_WEAPON, "doors/airdoor2.wav", 1, ATTN_NORM);

   launch_spike (self.origin + '0 0 10' + v_forward*14 + v_right * r_ofs, v_forward);
   newmis.dmg = 15 + random() * 5;
   newmis.classname = "bishop_laser";
   newmis.velocity = v_forward * 2000;
   setmodel (newmis, "progs/laser.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void() BishopSpecialTouch;
void() DM_Bishop_Special =
{
   local vector   vect;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local entity   missile;

   self.effects = self.effects | EF_MUZZLEFLASH;

   sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);

   makevectors(self.v_angle);

   vect = v_forward;

   launch_spike (self.origin + '0 0 12' + v_forward*14, vect);
   newmis.velocity = newmis.velocity * 0.75;
   newmis.classname = "bishop_special";
   newmis.touch = BishopSpecialTouch;
   newmis.avelocity_z = 300;
   setmodel (newmis, "progs/bisblast.mdl");
   setsize(newmis, '0 0 0', '0 0 0');
};

void(float damage) DM_Rogue_Punch =
{
   local entity   plyr;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local float    damg;

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*55, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
      plyr = trace_ent;
   else
      return;

   // hurt enemy
   T_Damage(plyr, self, self, damage);

   sound(self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
};

void() DM_Rogue_Fly =
{
   local float    vspeed, maxspeed;

   makevectors(self.v_angle);

   vspeed = vlen(self.velocity);
   maxspeed = cvar("sv_maxspeed");

   if (vspeed < maxspeed) {
      self.velocity = self.old_velocity + v_forward * 2000 * frametime;
      if (vlen(self.velocity) > (maxspeed + 100))
         self.velocity = normalize(self.velocity) * (maxspeed + 50);
   }
   else {
      self.velocity = v_forward * (maxspeed + 50);
   }

   self.old_velocity = self.velocity;

   // check for punch
   traceline(self.origin + '0 0 24', self.origin + '0 0 24' + v_forward*64, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM) {
      T_Damage(trace_ent, self, self, 40 + random()*8);
      sound(self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
   }
};

void(float damage) DM_Cannon_Punch =
{
   local entity   plyr;
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
   //local float    damg;

   sound (self, CHAN_ITEM, "generic/swing1.wav", 1, ATTN_NORM);

   makevectors(self.v_angle);
   traceline(self.origin, self.origin + v_forward*55, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM)
      plyr = trace_ent;
   else
      return;

   // hurt enemy
   T_Damage(plyr, self, self, damage);

   if (random() < 0.5)
      sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
   else
      sound(self, CHAN_WEAPON, "generic/punch3.wav", 1, ATTN_NORM);
};

void() DM_Cannon_Fly =
{
   local float    vspeed, maxspeed;

   makevectors(self.v_angle);

   vspeed = vlen(self.velocity);
   maxspeed = cvar("sv_maxspeed");

   if (vspeed < maxspeed) {
      self.velocity = self.old_velocity + v_forward * 2000 * frametime;
      if (vlen(self.velocity) > (maxspeed + 100))
         self.velocity = normalize(self.velocity) * (maxspeed + 150);
   }
   else {
      self.velocity = v_forward * (maxspeed + 150);
   }

   if (self.last_flame_sound < (time - 0.75)) {
      if (self.last_weapon_channel != CHAN_ITEM) {
        sound (self, CHAN_ITEM, "cannon/flyloop.wav", 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_ITEM;
      } else {
        sound (self, CHAN_VOICE, "cannon/flyloop.wav", 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_VOICE;
      }

      self.last_flame_sound = time;
   }

   self.old_velocity = self.velocity;

   // check for punch
   traceline(self.origin + '0 0 24', self.origin + '0 0 24' + v_forward*64, FALSE, self);

   if (trace_ent.takedamage == DAMAGE_AIM) {
      T_Damage(trace_ent, self, self, 40 + random()*8);
      sound (self, CHAN_BODY, "generic/swing1.wav", 1, ATTN_NORM);

      if (random() < 0.5)
         sound(self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);
      else
         sound(self, CHAN_WEAPON, "generic/punch3.wav", 1, ATTN_NORM);
   }

   if (trace_fraction < 1) {
      self.weaponframe = 14;  // abort fly
   }
};


void() BeamPlayerTouch =
{
   local float    vspeed, damg;

   if (self.last_wall_hit > (time - 1))
      return;

   if (other != world)
      return;

   if (self.enemy.enemy != self) {
      self.enemy = world;
      self.touch = SUB_Null;
      return;
   }

   vspeed = vlen(self.velocity);

   if (vspeed < 100)
      return;

   // make sure player is travelling somewhat sideways
   if (fabs(self.velocity_z) > 40)
      return;

   // find out which wall was likely to have been hit
   traceline(self.origin, self.origin + self.velocity * 2, TRUE, self);
   if (trace_fraction == 1)
      return;

   if (fabs(trace_plane_normal_z) > 0.3)
      return;

//bprint(ftos(vspeed));
//bprint("\n");

   damg = vspeed / 200;
   if (damg > 25)
      damg = 25;

   // wall damage
   T_Damage(self, self.enemy, self.enemy, damg);
   self.last_wall_hit = time;
};

void() DM_TractorThink =
{
   local vector   ideal_pos;

   makevectors(self.owner.v_angle);

   ideal_pos = self.owner.origin + v_forward * self.owner.tractor_dist;

   if (vlen(ideal_pos - self.owner.enemy.origin) > 8)
      self.owner.enemy.velocity = self.owner.enemy.tractor_vel = (ideal_pos - self.owner.enemy.origin) * 4;
   else
      self.owner.enemy.velocity = self.owner.enemy.tractor_vel = '0 0 0';

   self.owner.enemy.flags = self.owner.enemy.flags - (self.owner.enemy.flags & FL_ONGROUND);

   self.nextthink = time + 0.05;
};

void() TractorParticleThink;
void() DM_PhoenixStartBeam =
{
   // if player is already in a beam, abort attack
   if ((self.enemy.x_flags & X_TRACTOR_BEAM_HOLD) && (self.enemy.flags & FL_GODMODE)) {
      self.enemy = world;
      return;
   }

   sound(self.enemy, CHAN_WEAPON, "items/damage3.wav", 1, ATTN_NORM);

   self.flags = self.flags | FL_GODMODE;
   self.last_special = time;
   self.start_attack_health = self.health;

   self.tractor_dist = vlen(self.enemy.origin - self.origin);

   self.enemy.enemy = self;
   self.enemy.touch = BeamPlayerTouch;

   self.enemy.x_flags = self.enemy.x_flags | X_TRACTOR_BEAM_HOLD;
   self.enemy.velocity = self.enemy.tractor_vel = '0 0 100';
   setorigin(self.enemy, self.enemy.origin + '0 0 1');
   self.enemy.flags = self.enemy.flags - (self.enemy.flags & FL_ONGROUND);

   self.start_tractor_time = time;
   self.enemy.start_tractor_time = time;

   self.move_ent = spawn();
   self.move_ent.owner = self;

   self = self.move_ent;

   self.flame_ent1 = spawn();
   self.flame_ent2 = spawn();
   self.flame_ent3 = spawn();

   setmodel(self.flame_ent1, "progs/beampart.mdl");
   setmodel(self.flame_ent2, "progs/beampart.mdl");
   setmodel(self.flame_ent3, "progs/beampart.mdl");

   setorigin(self.flame_ent1, self.origin);
   setorigin(self.flame_ent2, self.origin);
   setorigin(self.flame_ent3, self.origin);

   self.flame_ent1.nextthink = time + 0.05;
   self.flame_ent2.nextthink = time + 0.05;
   self.flame_ent3.nextthink = time + 0.05;

   // speed to travel
   self.flame_ent1.speed = 800;
   self.flame_ent2.speed = 400;
   self.flame_ent3.speed = 200;

   // distance from Phoenix
   self.flame_ent1.t_length = 0;
   self.flame_ent2.t_length = 0;
   self.flame_ent3.t_length = 0;

   // distance from center of tractor beam
   self.flame_ent1.z_ofs = 10;
   self.flame_ent2.z_ofs = 5;
   self.flame_ent3.z_ofs = 0;

   // 1 = travelling away from center, -1 = travelling towards center
   self.flame_ent1.z_ofs_vel = -2;
   self.flame_ent2.z_ofs_vel =  2.5;
   self.flame_ent3.z_ofs_vel =  1;

   self.flame_ent1.think = TractorParticleThink;
   self.flame_ent2.think = TractorParticleThink;
   self.flame_ent3.think = TractorParticleThink;

   self.flame_ent1.owner = self.owner;
   self.flame_ent2.owner = self.owner;
   self.flame_ent3.owner = self.owner;

   self.think = DM_TractorThink;
   self.nextthink = time + 0.05;

   self = self.owner;
};

void() DM_PhoenixBeamEnd =
{
   if (self.enemy != world) {
      self.enemy.x_flags = self.enemy.x_flags - (self.enemy.x_flags & X_TRACTOR_BEAM_HOLD);
      self.enemy.velocity = normalize(self.enemy.origin - self.origin) * 250 + '0 0 100';

      // hurt enemy
// damage is now inflicted by smashing them against a wall
      T_Damage(self.enemy, self, self, 10);
      self.enemy.touch = SUB_Null;

      self.enemy.punchangle_x = -8;

      self.enemy = world;
   }

   if (self.move_ent != world) {
      remove(self.move_ent.flame_ent1);
      remove(self.move_ent.flame_ent2);
      remove(self.move_ent.flame_ent3);
      remove(self.move_ent);

      self.move_ent = world;
   }
};

void() DM_PhoenixFireHoming =
{
    local entity    missile;
    // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
    //local entity    missile_enemy;
    local vector    dir;

   missile = spawn ();
   missile.classname = "dm_phoenix_blast";
   missile.attack_finished = time + 3;
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;

   missile.think = GuidedRocketThink;
   missile.last_guided_search = time;
   missile.nextthink = time + 0.05;

   // set missile speed
   makevectors(self.v_angle);

   missile.velocity = v_forward;
   missile.velocity = missile.velocity * 800;
   missile.angles = vectoangles(missile.velocity);
   missile.angles_x = -1 * missile.angles_x;

   missile.touch = T_GuidedMissileTouch;

   missile.avelocity_z = 300;

   setmodel (missile, "progs/psyblast.mdl");
   setsize (missile, '0 0 0', '0 0 0');
   setorigin (missile, self.origin + dir*8 + '0 0 12');

   sound(self, CHAN_WEAPON, "cannon/takeoff.wav", 1, ATTN_NORM);
};

// **************************************************************************

void() DoSpecialWeaponStuff =
{
   local float    frame_num;

   frame_num = self.weaponframe - 6;

   if (self.character == CHAR_WOLVERINE) {
      if (!self.special_weapon) {
         if (frame_num == 5)
            Wolvy_Melee(200);
         else if (frame_num == 9)
            Wolvy_Melee(-200);
      }
      else {
         if (frame_num == 1)     // jump now
            Wolvy_Jump();
         else if ((frame_num >= 7) && (frame_num <= 10))
            Wolvy_JumpThink ();
      }
   }
   else if (self.character == CHAR_STORM) {
      if (!self.special_weapon) {
         if (frame_num == 5)
            Storm_Wind();
      }
      else {
         if ((frame_num >= 7) && (frame_num <= 10))
            Storm_Lightning();
         if (frame_num == 7)
            sound (self, CHAN_WEAPON, "storm/l_attack.wav", 1, ATTN_NORM);
      }
   }
   else if (self.character == CHAR_CYCLOPS) {
      if (!self.special_weapon) {    // Fast Laser
         if ((frame_num == 2) || (frame_num == 7))
            DM_Cyclops_Fast_Laser();
      }
      else {                        // Big Laser Blast
         if (frame_num == 8)
            DM_Cyclops_Big_Laser();
      }
   }
   else if (self.character == CHAR_PSYLOCKE) {
      if (!self.special_weapon) {    // Sword Attack
         if ((frame_num == 2) || (frame_num == 7))
            DM_Psylocke_Sword();
      }
      else {                         // Parallize Attack
         if (frame_num == 8)
            DM_Psylocke_Parallize();
      }
   }
   else if (self.character == CHAR_ANGEL) {
      if (!self.special_weapon) {    // Throw Darts
         if ((frame_num >= 3) && (frame_num <= 9)) {
            DM_AngelFeather( (frame_num - 6) * 5 );
         }
      }
      else {                         // Wing Defense
         if (frame_num == 5) {
            self.x_flags = self.x_flags | X_ANGEL_DEFENSE;
            self.flags = self.flags | FL_GODMODE;
         }
         else if ((frame_num == 10) && (self.button0))   // stay at this frame while button down
            self.weaponframe = self.weaponframe - 1;
         else if (frame_num == 11) {
            self.x_flags = self.x_flags - (self.x_flags & X_ANGEL_DEFENSE);
            self.flags = self.flags - (self.flags & FL_GODMODE);
         }
      }
   }
   else if (self.character == CHAR_BEAST) {
      if (!self.special_weapon) {    // Double Punch
         if ((frame_num == 4) ||
             (frame_num == 7) ||
             (frame_num == 10)) {
            DM_BeastPunch();
         }
      }
      else {                         // Floor Pound
         if (frame_num == 4) {   // give some jump
            if (self.flags & FL_ONGROUND)
               self.velocity_z = 190;
         }
         else if (frame_num == 11) {
            DM_BeastPound();
         }
      }
   }
   else if (self.character == CHAR_GAMBIT) {
      if (!self.special_weapon) {    // Staff Attack
         if (frame_num == 7)
            DM_Gambit_Strike();
         else if (frame_num == 3)
            sound (self, CHAN_WEAPON, "generic/swing1.wav", 1, ATTN_NORM);
      }
      else {                         // Throw Cards
         if ((frame_num >= 5) && (frame_num <= 7)) {
            DM_GambitCard( (frame_num - 6) * -5, 12 );
         }
         if (frame_num == 4)
            sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);
      }
   }
   else if (self.character == CHAR_ICEMAN) {
      if (!self.special_weapon) {    // Small Shards
         if ((frame_num >= 3) && (frame_num <= 8)) {
            DM_Iceman_Shard( (frame_num - 6) * 4 );
         }
      }
      else {                         // Big Freeze
         if (frame_num == 10)
            DM_Iceman_Iceball();
      }
   }
   else if (self.character == CHAR_BISHOP) {
      if (!self.special_weapon) {    // Dual Guns
         if (frame_num == 2)
            DM_Bishop_Shoot(6);
         else if (frame_num == 7)
            DM_Bishop_Shoot(-6);
      }
      else {
         if (frame_num == 5)
            DM_Bishop_Special();
      }
   }
   else if (self.character == CHAR_ROGUE) {
      if (!self.special_weapon) {    // Dual Punch
         if ((frame_num == 4) ||
             (frame_num == 10))
            DM_Rogue_Punch(10);
      }
      else {                         // Flying Punch
         if (frame_num == 2) {
            self.last_special = time;
         }
         else if (frame_num == 3) {
            if (self.button0) {
               self.x_flags = self.x_flags | X_FLYING;
               self.flags = self.flags | FL_ONGROUND;

               DM_Rogue_Fly();

               if (self.last_special > (time - 5) && (trace_ent.classname != "player"))
                  self.weaponframe = self.weaponframe - 1;
            }
         }
         else if (frame_num == 6) {
            self.x_flags = self.x_flags - (self.x_flags & X_FLYING);
         }
      }
   }
   else if (self.character == CHAR_CANNONBALL) {
      if (!self.special_weapon) {    // Punch
         if (frame_num == 6)
            DM_Cannon_Punch(10);
      }
      else {                         // Flying Punch
         if (frame_num == 1) {
            sound(self, CHAN_ITEM, "cannon/takeoff.wav", 1, ATTN_NORM);
         }

         if (frame_num < 6) {
            self.last_special = time;
            self.x_flags = self.x_flags | X_FLYING;
            self.effects = self.effects | EF_DIMLIGHT;
            self.velocity_z = self.old_velocity_z = 100;
         }
         else if (frame_num < 9) {
            self.flags = self.flags | FL_ONGROUND;
            DM_Cannon_Fly();

            if ((self.button0) && (trace_fraction == 1) && (frame_num == 8) && (self.last_special > (time - 5))) {
               self.weaponframe = self.weaponframe - 3;
            }
         }
         else if (frame_num == 9) {
            self.last_special2 = time;
            self.attack_finished = time + 2;
            self.effects = self.effects - (self.effects & EF_DIMLIGHT);
//            DM_Cannon_Punch(30 + random()*15);
            self.x_flags = self.x_flags - (self.x_flags & X_FLYING);
         }
      }
   }
   else if (self.character == CHAR_PHOENIX) {
      if (!self.special_weapon) {    // Tractor Beam
         if (frame_num == 1)
            self.enemy = world;
         else if (frame_num < 6) {
            if (self.enemy == world) {
               makevectors(self.v_angle);
               traceline(self.origin + '0 0 16', self.origin + '0 0 16' + v_forward * 512, FALSE, self);

               if (((trace_ent.touch == ammo_touch) ||
                    (trace_ent.classname == "guided_rocket") ||
                    (trace_ent.classname == "orb") ||
                    (trace_ent.flags & FL_MONSTER) ||
                    (trace_ent.classname == "player")) && (trace_ent != self))
                  self.enemy = trace_ent;
               else
                  self.enemy = world;
            }
         }
         else if (frame_num == 6) {
            if (self.enemy != world) {
               DM_PhoenixStartBeam();
            }
         }
         else if (frame_num == 8) {
            if ((self.enemy != world) && (self.start_attack_health <= self.health) && (self.start_tractor_time > (time - 4)) && (self.button0) && (self.flags & FL_GODMODE)) {
               traceline(self.origin, self.enemy.origin, TRUE, world);
               if (trace_fraction == 1)
                  self.weaponframe = self.weaponframe - 1;
            }
         }
         else if (frame_num == 9) {
            DM_PhoenixBeamEnd();
            self.flags = self.flags - (self.flags & FL_GODMODE);
            self.enemy = world;
         }
      }
      else {                        // Homing missile
         if (frame_num == 4)
            DM_PhoenixFireHoming();
      }
   }
};
