string(float char) GetCharacterString =
{
   if (char == CHAR_WOLVERINE)
      return "Wolverine";
   if (char == CHAR_STORM)
      return "Storm";
   if (char == CHAR_CYCLOPS)
      return "Cyclops";
   if (char == CHAR_PSYLOCKE)
      return "Psylocke";
   if (char == CHAR_ANGEL)
      return "Angel";
   if (char == CHAR_BEAST)
      return "Beast";
   if (char == CHAR_GAMBIT)
      return "Gambit";
   if (char == CHAR_ICEMAN)
      return "Iceman";
   if (char == CHAR_BISHOP)
      return "Bishop";
   if (char == CHAR_ROGUE)
      return "Rogue";
   if (char == CHAR_CANNONBALL)
      return "Cannonball";
   if (char == CHAR_PHOENIX)
      return "Phoenix";
   // 20060704 LordHavoc: hushed a compiler warning by adding this fallback
   return "Unknown";
};

// This is an adaption of the Wizard missile prediction code
vector(float mspeed, vector target_offset) ProjectVelocity =
{
   local vector   vec, move;
   local float fly;

   makevectors (self.angles);

// set missile speed
   vec = self.enemy.origin - self.origin + target_offset;

// calc aproximate time for missile to reach vec
   fly = vlen (vec) / mspeed;

// get the entities xy velocity
   move = self.enemy.velocity;
   move_z = 0;

// project the target forward in time
   vec = vec + move * (fly * 0.75);

   vec = normalize(vec);

   return (vec * mspeed);
};

//==========================================================================

void() xmen_post =
{
   if (self.style == 1) {
      precache_model ("progs/posta.spr");
      setmodel(self, "progs/posta.spr");
   }
   else if (self.style == 2) {
      precache_model ("progs/postb.spr");
      setmodel(self, "progs/postb.spr");
   }
   else if (self.style == 3) {
      precache_model ("progs/postc.spr");
      setmodel(self, "progs/postc.spr");
   }
   else if (self.style == 4) {
      precache_model ("progs/postd.spr");
      setmodel(self, "progs/postd.spr");
   }
};

//==========================================================================
// Special Weapon stuff

void() MagnetoThink =
{
   local vector   ang;

   makevectors(self.owner.v_angle);

   setorigin(self, self.owner.origin + v_forward * 70 + '0 0 22');

   ang = self.owner.v_angle; //vectoangles(v_forward * 1);

   if (executable == "glQuake")     // fixes upside-down magneto sprite
      ang_z = 180;

//   ang_x = -1 * ang_x;
   self.angles = ang;

   if (random() < 0.5)
      self.frame = rint(random() * 7);

   self.nextthink = time + 0.01;
};

void() WeaponMessage =
{
   local entity magneto;

   if (/*(self.last_flame < (time - 24)) ||*/ ((self.last_flame < (time - 3)) && (self.owner.button2))) {
      magneto = find(world, classname, "magneto_sprite");
      if (magneto != world)
         remove(magneto);

      centerprint(self.owner, "");
      remove(self);
      return;
   }

   if (self.speed)
      centerprint(self.owner, self.noise1);
   else
      centerprint(self.owner, self.noise);

   self.nextthink = time + 0.1;
};

void(float newwpn) SetNewWeapon;
void() ImpulseCommands;
void() weapon_piece_touch =
{
   local entity magneto, oself;

   if (other.classname != "player")
      return;

   self.owner = other;

   other.weapon_parts = other.weapon_parts + 1;

   sound (other, CHAN_ITEM, "items/protect.wav", 1, ATTN_NORM);
   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   self.model = string_null;
   self.classname = "";            // so rune doors won't find it

   serverflags = serverflags | self.items;

   if ((world.model == "maps/x1end.bsp") || (world.model == "maps/x2end.bsp")) // must be the final weapon component, so activate the Mega-Weapon!
   {

      // make sure they have all the components
      if (serverflags & 15) {

         other.items = other.items | IT_SPECIAL_WEAPON;

         oself = self;
         self = other;

         self.ammo_special = 255;
//         SetNewWeapon(IT_SPECIAL_WEAPON);
         self.impulse = 13;
         ImpulseCommands();
         self.currentammo = self.ammo_special;

         self = oself;

      }

   }

//   centerprint(other, self.noise);
   if (self.speed == other.weapon_parts)
      self.speed = 0;

   self.last_flame = time;
   self.think = WeaponMessage;
   self.nextthink = time + 0.1;

   // spawn magneto sprite thinker
   magneto = spawn();
   magneto.classname = "magneto_sprite";
   magneto.owner = other;
   setmodel(magneto, "progs/magneto.spr");
   magneto.think = MagnetoThink;
   magneto.nextthink = time + 0.01;
};

void() StartItem;
void() xmen_weapon_part =
{
   if (deathmatch) {
      remove(self);
      return;
   }

   if (world.model == "maps/x1m1.bsp") {
      precache_model("progs/comp1_1.mdl");
      setmodel(self, "progs/comp1_1.mdl");
      self.items = 1;
      self.noise = "Well done. You have found the\nfirst part of the only weapon\nable to defeat Apocalypse.\n\nYou will find other components\nthat have been seperated and\nhidden by Apocalypse. If you\nare unsuccessful the age of\nApocalypse will be unavoidable...\n\nGood luck.\n\n(press JUMP when ready)";
/*
Well done. You have found the
first part of the only weapon
able to defeat Apocalypse.\n
You will find other components
that have\nbeen seperated and
hidden by Apocalypse. If you
are unsuccessful the age of
Apocalypse will be unavoidable...\n
Good luck.\n\n(press JUMP when ready)
*/
   }
   else if (world.model == "maps/x1m2.bsp") {
      precache_model("progs/comp1_2.mdl");
      setmodel(self, "progs/comp1_2.mdl");
      self.items = 2;
      self.noise = "You have done well. your quest\nbecomes more important by the\nhour. Even as I speak Apocalypses\nclones are taking over every\nworld power. You are earth's\nonly hope for survival.\n\n(press JUMP when ready)";
/*
You have done well. your quest\n
becomes more important by the\n
hour. Even as I speak Apocalypses\n
clones are taking over every\n
world power. You are earth's\n
only hope for survival.\n\n(press JUMP when ready)
*/
   }
   else if (world.model == "maps/x1m3.bsp") {
      precache_model("progs/comp1_3.mdl");
      setmodel(self, "progs/comp1_3.mdl");
      self.items = 4;
      self.noise = "By destroying the cloning\ncomputer you have successfully\nstopped the production of this\nevil army of clones. You have\ngreatly threatened Apocalypses\nplans, but you must still rid\nthe world of the remaining\nclones and ensure that Apocalypse\ncan never attempt this again.\n\n(press JUMP when ready)";

/*
By destroying the cloning\n
computer you have successfully\n
stopped the production of this\n
evil army of clones. You have\n
greatly threatened Apocalypses\n
plans, but you must still rid\n
the world of the remaining\n
clones and ensure that Apocalypse\n
can never attempt this again.\n\n(press JUMP when ready)
*/
   }
   else if (world.model == "maps/x1m4.bsp") {
      precache_model("progs/comp1_4.mdl");
      setmodel(self, "progs/comp1_4.mdl");
      self.items = 8;
      self.speed = 4;
      self.noise = "You are getting closer to\nApocalypses sanctuary. You now\nhave all the weapon components.\nAll you need now is enough power\nto activate it. Step carefully.\nApocalypse is bound to have many\ndefences surrounding his lair.\n\n(press JUMP when ready)";
/*
You are getting closer to\n
Apocalypses sanctuary. You now\n
have all the weapon components.\n
All you need now is enough power\n
to activate it. Step carefully.\n
Apocalypse is bound to have many\n
defences surrounding his lair.\n\n(press JUMP when ready)
*/

      self.noise1 = "You are getting closer to\nApocalypse's sanctuary. You\nhave the final weapon component,\nbut you will need to get all the\nothers to defeat Apocalypse. Step\ncarefully. Apocalypse is bound to\nhave many defenses surrounding\nhis lair.\n\n(press JUMP when ready)";
/*
You are getting closer to\n
Apocalypse's sanctuary. You\n
have the final weapon component,\n
but you will need to get all the\n
others to defeat Apocalypse. Step\n
carefully. Apocalypse is bound to\n
have many defenses surrounding\n
his lair.\n
*/
   }
   else if (world.model == "maps/x1end.bsp") {
      precache_model("progs/comp1_5.mdl");
      setmodel(self, "progs/comp1_5.mdl");
      self.speed = 5;
      self.noise = "You have found a power pack\ncapable of activating the\nweapon for a short time. Use it\nwisely.\n\n(press JUMP when ready)";

      self.noise1 = "You have found a power pack\ncapable of activating the\nweapon for a short time.\n\nUnfortunately you have not\ngot all the weapon components.\n\nYou will need to go back to\nget them before being able to\ndefeat Apocalypse.\n\n(press JUMP when ready)";
/*
You have found a power pack\n
capable of activating the\n
weapon for a short time.\n
Unfortunately you have not\n
got all the weapon components.\n
You will need to go back to\n
get them before being able to\n
defeat Apocalypse.
*/
   }

   else if (world.model == "maps/x2m1.bsp") {
      precache_model("progs/comp2_1.mdl");
      setmodel(self, "progs/comp2_1.mdl");
      self.items = 1;
      self.noise = "Now that you have defeated\nApocalypse you must find the\nother 3 components of the weapon\nthat must be used to defeat\nApocalypses sinister accomplice.\n\n(press JUMP when ready)";
/*
Now that you have defeated\n
Apocalypse you must find the\n
other 3 components of the weapon\n
that must be used to defeat\n
Apocalypses sinister accomplis.\n\n(press JUMP when ready)
*/

   }
   else if (world.model == "maps/x2m2.bsp") {
      precache_model("progs/comp2_2.mdl");
      setmodel(self, "progs/comp2_2.mdl");
      self.items = 2;
      self.speed = 2;
      self.noise = "You are doing well. There are\nonly 2 more components to be\nfound. Keep an eye out for clues\nalong your journey.\n\n(press JUMP when ready)";
/*
You are doing well. There are\n
only 2 more components to be\n
found. Keep an eye out for clues\n
along your journey.\n\n(press JUMP when ready)
*/

      self.noise1 = "You are doing well. You have\nmissed one of the weapon\ncomponents, you will need\nto have it before completing\nyour quest. Keep an eye out\nfor clues along the way.\n\n(press JUMP when ready)";
/*
You are doing well. You have\n
missed one of the weapon\n
components, you will need\n
to have it before completing\n
your quest. Keep an eye out\n
for clues along the way.
*/
   }
   else if (world.model == "maps/x2m3.bsp") {
      precache_model("progs/comp2_3.mdl");
      setmodel(self, "progs/comp2_3.mdl");
      self.items = 4;
      self.noise = "The weapon components were\nscattered farther than I had\nhoped. This is a minor set back.\nYou are getting closer to\nfinding Apocalypses evil\npartner.\n\n(press JUMP when ready)";
/*
The weapon components were\n
scattered farther than I had\n
hoped. This is a minor set back.\n
You are getting closer to\n
finding Apocalypses evil\n
partner.\n\n(press JUMP when ready)
*/
   }
   else if (world.model == "maps/x2m4.bsp") {
      precache_model("progs/comp2_4.mdl");
      setmodel(self, "progs/comp2_4.mdl");
      self.items = 8;
      self.speed = 4;
      self.noise = "You are very close now I feel.\nNow that you have found the 4\nparts to the weapon, you must\nagain\nfind sufficient power to\nactivate it.\n\n(press JUMP when ready)";
/*
You are very close now I feel.\n
Now that you have found the 4\n
parts to the weapon, you must\n
again\nfind sufficient power to\n
activate it.\n\n(press JUMP when ready)";
*/
      self.noise1 = "You are very close now, I feel,\nbut you have not got all 4\nparts to the weapon. Once you\nhave, you must again find\nsufficient power to activate it.\n\n(press JUMP when ready)";
/*
You are very close now, I feel,\n
but you have not got all 4\n
parts to the weapon. Once you\n
have, you must again find\n
sufficient power to activate it.
*/
   }
   else if (world.model == "maps/x2end.bsp") {
      precache_model("progs/comp2_5.mdl");
      setmodel(self, "progs/comp2_5.mdl");
      self.speed = 5;
      self.noise = "The weapon is now functional.\n\nUse it well.\n\n(press JUMP when ready)";
      self.noise1 = "You have the power pack,\nbut not all of the weapon\ncomponents. You must find\nthese before defeating Mr\nSinister.\n\n(press JUMP when ready)";
/*
You have the power pack,\n
but not all of the weapon\n
components. You must find\n
these before defeating Mr\n
Sinister.
*/
   }
   else {
      precache_model("progs/comp1_1.mdl");
      setmodel(self, "progs/comp1_1.mdl");
      self.noise = "Special Weapon: unknown level name";
   }

   precache_model("progs/magneto.spr");

   self.touch = weapon_piece_touch;
   setsize (self, '-8 -8 0', '8 8 32');
   StartItem ();
};

//==========================================================================
void(entity ent) SetDamageSkin =
{
   if (deathmatch)
      return;

   if (ent.classname == "player")
      return;

   if (ent.classname == "xmen_techdude")
      return;

   if (((ent.classname == "xmen_sinister") || (ent.classname == "apocalypse_small")) && !(ent.x_flags & X_MEGA_HIT))
      return;

   if (show_damage) {
      bprint(ftos((ent.health * 100) / ent.start_health));
      bprint("% damage\n");
   }

   // set damage skin
   if ((ent.health / ent.start_health) < 0.33)
      ent.skin = 2;
   else if ((ent.health / ent.start_health) < 0.66)
      ent.skin = 1;
   else
      ent.skin = 0;
};

//==========================================================================

void() item_furniture =
{
   precache_model(self.model);
   setmodel(self, self.model);
};

//==========================================================================
void() SUB_regen;
void() RapidTouch =
{
   if (other.classname != "player")
      return;

   if (other.health <= 0)
      return;

   sprint(other, "You got the Rapid Fire!\n");

   sound(other, CHAN_ITEM, "misc/rapid.wav", 1, ATTN_NORM);

   other.rapid_time = time + 25;
   other.x_flags = other.x_flags | X_RAPID_FIRE;
//   other.items = other.items | IT_INVISIBILITY;

   stuffcmd (other, "bf\n");
   self.solid = SOLID_NOT;
   self.mdl = self.model;
   self.model = string_null;

   if (deathmatch) {
      self.nextthink = time + 40;
      self.think = SUB_regen;
   }

};

void() item_rapid_fire =
{
   precache_model("progs/rapid.mdl");

   precache_sound("misc/rapid.wav");
   precache_sound("misc/rapidout.wav");

   setmodel(self, "progs/rapid.mdl");

   setsize (self, '-16 -16 -24', '16 16 32');

   self.touch = RapidTouch;

   StartItem();
};

void(entity client, string s) centerprint =
{
   client.last_centerprint = s;
   do_centerprint(client, s);
};