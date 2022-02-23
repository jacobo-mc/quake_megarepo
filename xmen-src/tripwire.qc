/* Begin Xmen
Laser Tripwire code revision 2
-cl2-

Additions:
r2:
	Cleaned up the code
	Changed BlowMeUp() to use self.dmg and to call BecomeExplosion()

Files involved:
tripwire.qc (this file)
client.qc   (obituaries)

How to implement in a .map file:
There are two entities that make up a trip wire:
"tripwire_startpoint" and "tripwire_endpoint".
tripwire_startpoint should have a "target" field equal to it's respective
tripwire_endpoint's "targetname" field. (i.e. the endpoint is targeted by the startpoint)

Just stick the two entities near walls (within 64 units). Although it is not *essential*,
the two entities should have an unobstructed view of each other, otherwise the 'laser beam'
effect will not be too believable ;)
*/

void () BlowMeUp =
{
// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//local entity oldself;

if (self.deadflag)
   return;

self.deadflag = DEAD_DEAD;

T_RadiusDamage (self, self, self.dmg, self);
WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
WriteByte (MSG_BROADCAST, TE_EXPLOSION);
WriteCoord (MSG_BROADCAST, self.origin_x);
WriteCoord (MSG_BROADCAST, self.origin_y);
WriteCoord (MSG_BROADCAST, self.origin_z);
BecomeExplosion();
};

// Tripwire scan - watch for some dummy to cross the line.
void () tripwire_scan =
{
traceline(self.origin, self.owner.origin, FALSE, self);
if (trace_fraction != 1)
	{
	self.owner.think = BlowMeUp;
	self.owner.nextthink = time + 0.1;
	self.think = BlowMeUp;
	self.nextthink = time + 0.1;
	return;
	}
self.nextthink = time + 0.1;
};

// Tripwire init
void () tripwire_kickit =
{
local entity endpoint;
local vector vec,org;
local vector norm;

endpoint = find(world, targetname, self.target);
// Im using self.owner to knock out a find() in tripwire_scan...
self.owner = endpoint;
vec = normalize(endpoint.origin - self.origin);

traceline(self.origin, self.origin - vec * 64, TRUE, self);
norm = trace_plane_normal;
org = trace_endpos;
self.angles = vectoangles(norm);
makevectors(self.angles);
setorigin(self, org);

self.health = 1;
self.th_die = BlowMeUp;
self.takedamage = DAMAGE_YES;
self.solid = SOLID_BBOX;
setsize(self, '-8 -8 -8', '8 8 8');


traceline(endpoint.origin, endpoint.origin + vec * 64, TRUE, self);
norm = trace_plane_normal;
org = trace_endpos;
endpoint.angles = vectoangles(norm);
makevectors(endpoint.angles);
setorigin(endpoint, org);

endpoint.health = 1;
endpoint.th_die = BlowMeUp;
endpoint.takedamage = DAMAGE_YES;
endpoint.solid = SOLID_BBOX;
setsize(endpoint, '-8 -8 -8', '8 8 8');

self.nextthink = time + 0.1;
self.think = tripwire_scan;
};

// Tripwire endpoint spawn

void () tripwire_endpoint =
{
if (deathmatch) {
   remove(self);
   return;
}

if (!self.dmg) self.dmg = 120;
if (!self.targetname)
	{
	objerror("Tripwire_endpoint has no targetname.\n");
	}

precache_model("progs/tripwire.mdl");
setmodel(self, "progs/tripwire.mdl");
};

// Tripwire startpoint spawn

void () tripwire_startpoint =
{
if (deathmatch) {
   remove(self);
   return;
}

if (!self.dmg) self.dmg = 120;
if (!self.target)
	{
	objerror("Tripwire_startpoint has no target.\n");
	}

precache_model("progs/tripwire.mdl");
setmodel(self, "progs/tripwire.mdl");

self.skin = 1;

self.nextthink = time + 0.1;
self.think = tripwire_kickit;   // Give tripwire_endpoint a chance to spawn
};

// End Xmen

