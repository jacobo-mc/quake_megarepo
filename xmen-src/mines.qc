/* Begin Xmen
Mines revision 1
-cl2-

Files involved:

mines.qc    (this file)
client.qc   (obituaries)
tripwire.qc (explosion function)

How to implement in a .map file:
Stick a 'mine' wherever you want a mine. Just like any other object or monster,
it should be placed just above the floor.

Some optional fields are "dmg", the maximum damage the mine inflicts,
and "distance", the distance the mine scans. For a normal mine, just omit them.
*/

// Just waitin' for someone to start with us... ;)

void() mine_scan =
{
local entity shnook;

shnook = findradius(self.origin, self.distance);
while(shnook)
	{
	if(shnook.health)  // Should this only trip off for players?
		{
		self.think = BlowMeUp;
		self.nextthink = time + 0.1;
		return;
		}
	shnook = shnook.chain;
	}
self.nextthink = time + 0.1;
};

// Mine start (mine has to start after world)

void() mine_start =
{
self.velocity = '0 0 0';
self.movetype = MOVETYPE_TOSS;
if (!droptofloor())
	{
    dprint ("Mine fell out of level at ");
    dprint (vtos(self.origin));
    dprint ("\n");
    remove(self);
    return;
    }

   self.health = 1;
   self.th_die = BlowMeUp;
   self.takedamage = DAMAGE_YES;

self.think = mine_scan;
self.nextthink = time + 0.1;
};

// Mine spawn

void() mine =
{
if (deathmatch) {
   remove(self);
   return;
}

if (!self.distance) self.distance = 64;
if (!self.dmg) self.dmg = 120;
precache_model("progs/mine.mdl");
setmodel(self, "progs/mine.mdl");
setsize(self, '-4 -4 0', '4 4 4');
self.think = mine_start;
self.nextthink = time + 0.2; // Put it in after world spawns (droptofloor)
};

// End Xmen
