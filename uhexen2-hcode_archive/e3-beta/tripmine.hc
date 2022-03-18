
void  ()BoomCheck =  {
   self.goalentity.view_ofs = self.origin;
   if ( (self.bloodloss < 30.00000) ) {

      setmodel (self, "models/sm_expld.spr");

   }
   if ( ((pointcontents (self.origin) == CONTENT_SOLID) || (self.bloodloss <= 0.00000)) ) {

      remove (self.goalentity);
      remove (self);

   }
};


void  ()b_explode1 =  [  0.0, b_explode2] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode2 =  [  1.0, b_explode3] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode3 =  [  2.0, b_explode4] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode4 =  [  3.0, b_explode5] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode5 =  [  4.0, b_explode6] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode6 =  [  5.0, b_explode7] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode7 =  [  6.0, b_explode8] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode8 =  [  7.0, b_explode9] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode9 =  [  8.0, b_explode10] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode10 =  [  9.0, b_explode11] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode11 =  [ 10.0, b_explode12] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode12 =  [ 11.0, b_explode13] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()b_explode13 =  [ 12.0, ShaBoom] {
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   BoomCheck ();
};


void  ()ShaBoom =  {
   BoomCheck ();
   T_RadiusDamage (self, self.owner, self.bloodloss, world);
   self.bloodloss = (self.bloodloss - 1.00000);
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
   b_explode1 ();
};


void  ()FireExplosion =  {
local entity boommissile;
   boommissile = spawn ();
   boommissile.owner = self.controller;
   boommissile.movetype = MOVETYPE_NOCLIP;
   boommissile.solid = SOLID_NOT;
   boommissile.velocity = (self.v_angle * 3.00000);
   boommissile.think = ShaBoom;
   boommissile.nextthink = time;
   boommissile.goalentity = self.goalentity;
   boommissile.bloodloss = 100.00000;
   boommissile.classname = "tripmine";
   setorigin (boommissile, self.origin);
   setmodel (boommissile, "models/bg_expld.spr");
   MultiExplode ();
   remove (self);
};


void  ()LaserTripped =  {
   self.takedamage = DAMAGE_NO;
   sound (self, CHAN_AUTO, "weapons/lock.wav", 1.00000, ATTN_NORM);
   self.effects = EF_BRIGHTLIGHT;
   self.think = FireExplosion;
   self.nextthink = (time + 0.10000);
};


void  ()LaserThink =  {
local entity tripsight;
   if ( !self.aflag ) {

      sound (self, CHAN_BODY, "misc/comm.wav", 1.00000, ATTN_NORM);
      self.controller = self.owner;
      self.owner = self;
      self.skin = 1.00000;
      self.aflag = TRUE;

   }
   traceline ((self.origin + normalize ((self.v_angle * 8.00000))), self.goalentity.origin, FALSE, self.goalentity);
   if ( (trace_fraction < 1.00000) ) {

      if ( (((trace_ent.velocity != '0.00000 0.00000 0.00000') || (trace_ent.health > 0.00000)) || trace_ent.takedamage) ) {

         self.think = LaserTripped;

      }
   } else {

      self.think = LaserThink;

   }
   self.nextthink = time;
};


void  ()ChainTouch =  {
   if ( (other == self.owner) ) {

      return ;

   }
   self.touch = SUB_Null;
   if ( other.takedamage ) {

      self.owner.think = LaserTripped;
      self.owner.nextthink = time;
   } else {

      self.velocity = '0.00000 0.00000 0.00000';

   }
};


void  ()ChainThink =  {
   DrawLinks ();
   self.nextthink = (time + 0.20000);
};


void  ()FireChain =  {
local vector dir = '0.00000 0.00000 0.00000';
   dir = normalize (self.v_angle);
   newmis = spawn ();
   newmis.owner = self;
   self.goalentity = newmis;
   newmis.movetype = MOVETYPE_FLYMISSILE;
   newmis.solid = SOLID_BBOX;
   newmis.velocity = (dir * 350.00000);
   newmis.touch = ChainTouch;
   newmis.think = ChainThink;
   newmis.drawflags = MLS_POWERMODE;
   newmis.nextthink = time;
   newmis.view_ofs = self.origin;
   newmis.angles = vectoangles (newmis.velocity);
   setmodel (newmis, "models/twspike.mdl");
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, (self.origin + (dir * 8.00000)));
};


void  ()TripTouch =  {
   if ( (((other.takedamage && other.health) && ((other.classname == "player") || other.movetype)) && (other != self.owner)) ) {

      MultiExplode ();
   } else {

      sound (self, CHAN_WEAPON, "weapons/setlaser.wav", 1.00000, ATTN_NORM);
      self.v_angle = ('0.00000 0.00000 0.00000' - self.velocity);
      self.angles = vectoangles (self.v_angle);
      self.movetype = MOVETYPE_NONE;
      self.velocity = '0.00000 0.00000 0.00000';
      self.avelocity = '0.00000 0.00000 0.00000';
      setsize (self, '-3.00000 -3.00000 -6.00000', '3.00000 3.00000 6.00000');
      self.touch = SUB_Null;
      FireChain ();
      self.think = LaserThink;
      self.nextthink = time;

   }
};


void  ()TripDie =  {
   remove (self.goalentity);
   MultiExplode ();
};


void  ()SetLaser =  {
local entity missile;
   sound (self, CHAN_WEAPON, "misc/default.wav", 1.00000, ATTN_NORM);
   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
   missile.health = 25.00000;
   missile.takedamage = DAMAGE_YES;
   missile.th_die = TripDie;
   missile.classname = "tripmine";
   makevectors (self.v_angle);
   missile.touch = TripTouch;
   missile.think = SUB_Null;
   missile.nextthink = -1.00000;
   missile.velocity = (normalize (v_forward) * 250.00000);
   missile.angles = vectoangles (('0.00000 0.00000 0.00000' - missile.velocity));
   missile.angles_x = -90.00000;
   missile.avelocity_y = 300.00000;
   setmodel (missile, "models/a_glyph.mdl");
   setorigin (missile, ((self.origin + self.proj_ofs) + (v_forward * 4.00000)));
   setsize (missile, VEC_ORIGIN, VEC_ORIGIN);
   self.attack_finished = (time + 0.50000);
};

