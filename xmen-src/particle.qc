/* Begin Xmen
Particle Throwers revision 2
-cl2-

Additions:
r2: Cleaned up the code

Files involved:
particle.qc (this file)

How to implement in a .map file:
Stick a 'misc_particles' wherever you want the particles to come from.
set "angles" to whatever VECTOR you want the particles to shoot at, and
"count" to how many particles to shoot. (for density)
Another neat thing I figured I'd add (why not?) was you can also specify
"wait" if you want there to be a wait in between 'particle spurts'. If no
wait is specified, it will be a continuous stream.

"style" is the color index # of the particles thrown.

If anyone has a need for a random "wait" period (maybe for electrical
sparks or something?) let me know and I can throw it in very easily.
Same goes for toggle-able particle throwers. Just say the werd.

Remember self.angles is actually a VECTOR, which means "180 0 0" shoots
particles at 180 units/sec to the right.
Vector axes are x,y,z, in that order. If the player's yaw is 90 degrees,
x is left/right, y is forward/back, z is up/down.
*/

// Throw some particles around

void() particle_throw =
{
particle(self.origin, self.angles, self.style, self.count);
self.nextthink = time + self.wait;
};

// particle init.. duh.

void() misc_particles =
{
if (!self.wait) self.wait = 0.1;
if (!self.style) self.style = 1;
if (!self.count) self.count = 50; // nice round default number.
self.think = particle_throw;
self.nextthink = time + self.wait;
};

// End Xmen
