/*
   Begin Xmen - cl2
   Exploding Brushes
 */

void () fe_boom =
{
    local float num, r, mass;
    local vector neworgs, vect;
    // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
    //local entity targ, oself;

    vect = self.absmax - self.absmin;
    mass = (vect_x / 10) * (vect_y / 10) * (vect_z / 10);

    self.solid = SOLID_NOT;
    neworgs = self.absmax - self.absmin;
    self.origin_x = self.absmin_x + neworgs_x * random();
    self.origin_y = self.absmin_y + neworgs_y * random();
    self.origin_z = self.absmin_z + neworgs_z * random();

    num = floor(mass / 100) + 5;
    if (num > 12)
      num = 12;

    while (num >= 0) {
      r = random ();
      if (r < 0.2) {
          ThrowGib ("progs/rubble1.mdl", random () * -50);
      } else if (r < 0.4) {
          ThrowGib ("progs/rubble2.mdl", random () * -50);
      } else if (r < 0.6) {
          ThrowGib ("progs/rubble3.mdl", random () * -50);
      } else if (r < 0.8) {
          ThrowGib ("progs/rubble4.mdl", random () * -50);
      } else {
          ThrowGib ("progs/rubble5.mdl", random () * -50);
      }
      num = num - 1;
    }
    T_RadiusDamage (self, self, 100, world);
    sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
    BecomeExplosion ();

    SUB_UseTargets();
};

void () fe_touch =
{
   local entity oself;

    if ((other.classname != "guided_rocket") &&
        (other.classname != "orb"))
   	return;

    if (self.targetname != "")
      return;

    if (other.classname == "orb") {
      oself = self;
      self = other;
      GrenadeExplode();
      self = oself;
    }

    fe_boom ();
};

void () fe_use =
{
    self.think = fe_boom;
    self.nextthink = time + 0.1;
};

void () func_explode =
{
if (deathmatch) {
   remove(self);
   return;
}

    if (!self.state)
   	self.state = 1;		// FIXME

    precache_model ("progs/rubble1.mdl");
    precache_model ("progs/rubble2.mdl");
    precache_model ("progs/rubble3.mdl");
    precache_model ("progs/rubble4.mdl");
    precache_model ("progs/rubble5.mdl");
   self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    setmodel (self, self.model);
    self.use = fe_use;
    self.touch = fe_touch;
    self.health = 0;
    self.takedamage = DAMAGE_NO;

    // set speed (skin) according to "mdl" field
    if (self.mdl == "computer1")
      self.speed = 0;
    else if (self.mdl == "ewall")
      self.speed = 1;
    else if (self.mdl == "grass")
      self.speed = 2;
    else if (self.mdl == "bb016")
      self.speed = 3;
    else if (self.mdl == "steel")
      self.speed = 4;
    else if (self.mdl == "metal")
      self.speed = 5;
    else if (self.mdl == "redpan")
      self.speed = 6;
    else if (self.mdl == "conpanel")
      self.speed = 7;
    else if (self.mdl == "egyptwall")
      self.speed = 8;

};
