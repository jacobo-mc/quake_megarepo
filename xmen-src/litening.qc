/* Begin Xmen
Lightning revision 2
-cl2-

Revisions:
2: Added some safeguards to make lightning work right
   Fixed error messages

Files involved:

litening.qc    (this file)

How to implement in a map file:

Place a info_lightning somewhere. Give it a style.
Place other lightning_waypoints all with the same style as startpoint.
String 'em together via 'target' and 'targetname' and voila... lightning. I hope.

"style" : light style it affects (12-31)
"waitmin" : min. time between flashes (default = 3)
"waitmax" : max. time between flashes (default = 10)
"spawnflags" : if 1, bolt will randomly fork off at junctions (default = 0)
"distance" : how long the forks can be (default = 64)
  Does looking at other people's code give you a headache, too? ;)
*/

void() lightning_trigger;

float(entity e1, entity e2, float dam) DoABolt =
{

//   traceline(e1.origin, e2.origin, FALSE, world);

   FillBetweenPoints(e1.origin, e2.origin, "progs/bolt3.mdl", '0 0 0', 0.2);

   if (trace_fraction < 1) {
      if (world.model == "maps/x1end.bsp") {
         T_RadiusDamage(e2, self, dam, world);
      }
      else if (trace_ent.classname == "player")
         T_Damage(trace_ent, self, self, dam);

      return FALSE;
   }

   return TRUE;
/*
local entity bolt;

bolt = spawn();
WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
WriteEntity (MSG_BROADCAST, bolt);
WriteCoord (MSG_BROADCAST, e1.origin_x);
WriteCoord (MSG_BROADCAST, e1.origin_y);
WriteCoord (MSG_BROADCAST, e1.origin_z);
WriteCoord (MSG_BROADCAST, e2.origin_x);
WriteCoord (MSG_BROADCAST, e2.origin_y);
WriteCoord (MSG_BROADCAST, e2.origin_z);
bolt.think = SUB_Remove;
bolt.nextthink = time + 0.2;
*/
};

// randomly create a fork

void(entity e) forkbolt =
{
local entity bolt;
local vector vec,org;

if (random() * 10 < 4) return;

bolt = spawn();   // spawn the bolt
vec = normalize(e.owner.origin - e.origin);
bolt.angles = vectoangles(vec);
makevectors(bolt.angles);
// do some complicated stuff to make sure the fork goes roughly the right
// direction, and doesnt look 'fake' (random in a controlled way?)
org = e.origin + v_forward*(random()*self.distance);
org = org + v_right*(random()*(self.distance*2)-self.distance);
org = org + v_up*(random()*(self.distance*2)-self.distance);
traceline(e.origin, org, TRUE, self);
WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);  // make some lightning
WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
WriteEntity (MSG_BROADCAST, bolt);
WriteCoord (MSG_BROADCAST, e.origin_x);
WriteCoord (MSG_BROADCAST, e.origin_y);
WriteCoord (MSG_BROADCAST, e.origin_z);
WriteCoord (MSG_BROADCAST, trace_endpos_x);
WriteCoord (MSG_BROADCAST, trace_endpos_y);
WriteCoord (MSG_BROADCAST, trace_endpos_z);
bolt.think = SUB_Remove;
bolt.nextthink = time + 0.5;
};

// O.k. enough freakin' lightning, already.
void() lightning_finish =
{
if (self.style >= 12)
   lightstyle(self.style, "a");

self.think = lightning_trigger;
if (self.targetname == "")
   self.nextthink = time + self.waitmin + random() * (self.waitmax - self.waitmin);
};

float(entity parent, float lcount) randomRecursive =
{
   local float    dist, rnd, longbolt, newcount, dosecond;
   local vector   dir;
   local entity   newchild;

   if (lcount > 4)
      return lcount;
   else
      newcount = lcount + 1;

   dosecond = TRUE;
   if (newcount == 1)      // don't fork on first bolt
      dosecond = FALSE;

   // create a left hand branch
   rnd = random();
   dist = 128 * floor(1 + rnd * 4);

   dir = '0 0 -1';
   dir_x = (random() * 1) - 0.5;
   dir_y = (random() * 1) - 0.5;
   dir = normalize(dir);

   traceline(parent.origin, parent.origin + (dir * dist), FALSE, world);

   // create the new endpoint entity
   newchild = spawn();
   newchild.classname = "lightning_bolt";
   newchild.owner = parent;
   newchild.origin = trace_endpos;
   newchild.think = SUB_Remove;
   newchild.nextthink = time + 0.1;

   // draw the lightning bolt
   DoABolt(parent, newchild, self.dmg);

   if (trace_fraction == 1) {    // no intersection, do another bolt from the new child
      newcount = randomRecursive(newchild, newcount);
   }

   if (!dosecond)
      return newcount;

   longbolt = FALSE;
   if (random() < 0.3)
      longbolt = TRUE;

   // do right hand branch
   rnd = random();
   dist = 128 * floor(1 + (3 * longbolt) + rnd * 4);

   dir = '0 0 -1';
   dir_x = (random() * 1) - 0.5;
   dir_y = (random() * 1) - 0.5;
   dir = normalize(dir);

   traceline(parent.origin, parent.origin + (dir * dist), FALSE, world);

   // create the new endpoint entity
   newchild = spawn();
   newchild.classname = "lightning_bolt";
   newchild.owner = parent;
   newchild.origin = trace_endpos;
   newchild.think = SUB_Remove;
   newchild.nextthink = time + 0.1;

   // draw the lightning bolt
   DoABolt(parent, newchild, self.dmg);

   if ((trace_fraction == 1) && (longbolt)) {    // no intersection, do another bolt from the new child
      newcount = randomRecursive(newchild, newcount);
   }

   return newcount;
};

// Lets see some action, dammit!
void() lightning_trigger =
{
local entity lpos;
local float  done;

   // Sound should go here!
   if (self.x_flags == 1)
      sound (self, CHAN_AUTO, "ambience/elect.wav", 1, ATTN_NORM);
   else
      sound (self, CHAN_AUTO, "ambience/thunder1.wav", 0.7, ATTN_NORM);

//return;

if (!self.target) {
   // randomize the lightning bolts
   randomRecursive(self, 0);
}
else {
   done = FALSE;

   traceline(self.origin, self.owner.origin, FALSE, world);
   DoABolt(self,self.owner, self.dmg);
   // inefficient, but since find() can only match string fields... <sigh>
   lpos = find(world, classname, "lightning_waypoint");
   while ((lpos != world) && !(done))
   {
   if (lpos.style == self.style)
   if (lpos.owner != world)
   {
      if (self.spawnflags & 1) forkbolt(lpos);

      traceline(lpos.origin, lpos.owner.origin, FALSE, world);
      if (!DoABolt(lpos, lpos.owner, self.dmg))
         done = TRUE;
   }

      lpos = find(lpos, classname, "lightning_waypoint");

   }
}

if (self.style >= 12)
   lightstyle(self.style, "z");
self.think = lightning_finish;
self.nextthink = time + 0.3;
};

// Lightning endpoint spawn

void() lightning_ep_start =
{
local entity shnook;

if (self.target)
	{
	shnook = world;
	do
	{
	shnook = find(shnook, targetname, self.target);
	} while (shnook.classname != "lightning_waypoint");
	self.owner = shnook;
	}
else self.owner = world;
};

void() lightning_waypoint =
{
self.think = lightning_ep_start;
self.nextthink = time + 0.2;
};

// Lightning startpoint spawn

void() lightning_sp_start =
{
local entity shnook;

if (self.target) {
   shnook = world;
   do
   {
   shnook = find(shnook, targetname, self.target);
   } while (shnook.classname != "lightning_waypoint");
   // Safety measure in case map designer assigns lights target too...
}

self.owner = shnook;
self.think = self.use = lightning_trigger;
if (self.targetname == "")
   self.nextthink = time + self.waitmin + random() * (self.waitmax - self.waitmin);
};

void() info_lightning =
{
if (deathmatch) {
   remove(self);
   return;
}

//if (!self.style)
//	objerror("info_lightning has no style");
if (self.style && (self.style < 12))
	objerror("info_lightning has invalid style");

// Ridah: target no longer required, but used if present
//if (!self.target)
//	objerror("info_lightning has no target");

if (!self.waitmin)   self.waitmin = 3;
if (!self.waitmax)   self.waitmax = 10;
if (!self.distance)  self.distance = 64;
if (!self.dmg)       self.dmg = 50;

if (self.style >= 12)
   lightstyle(self.style, "a");

if (self.x_flags == 1)
   precache_sound ("ambience/elect.wav");
else
   precache_sound ("ambience/thunder1.wav");

self.think = lightning_sp_start; // wait for all our buddies to spawn
self.nextthink = time + 0.2;
};

// End Xmen
