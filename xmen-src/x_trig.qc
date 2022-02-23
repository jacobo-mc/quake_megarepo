/* Begin Xmen
triggers revision 1
-cl2-

Files involved:

x_trig.qc    (this file)
*/

// trigger_constant
// triggers all is targets, waits for self.wait, repeats until triggered
// spawnflags:
// 1 : Starts off

void() tc_go =
{
activator = world;
SUB_UseTargets();
self.nextthink = time + self.wait;
};

void() tc_use =
{
self.state = 1 - self.state;
if (self.state)
	{
	self.think = tc_go;
	self.nextthink = time + self.wait;
	}
else self.nextthink = time + 9999999;
};

void() trigger_constant =
{
self.use = tc_use;
if (!self.wait) self.wait = 0.2;
if (self.spawnflags & 1) self.state = 0; else self.state = 1;
if (self.state)
	{
	self.think = tc_go;
	self.nextthink = time + 0.2;
	}
};
