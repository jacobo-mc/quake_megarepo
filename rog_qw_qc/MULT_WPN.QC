// multi_weapons.qc
// pmack
// sept 96

//=============================================================================
// Multi Grenade Code
//=============================================================================
void() MultiGrenadeTouch;

//================================
//================================
void() MiniGrenadeExplode =
{
	if (self.voided) {
		return;
	}
	self.voided = 1;

	if ( self.owner.classname == "player")
		T_RadiusDamage (self, self.owner, 90, world, "multirocket");
	else
		T_RadiusDamage (self, self.owner, 60, world, "multirocket");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);

	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	
	remove(self);
};

//================================
//================================
void(float offsetAngle) MiniGrenadeLaunch =
{
	local	float	tempRand;
	
	newmis = spawn ();
	newmis.voided = 0;
	newmis.owner = self.owner;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "MiniGrenade";
		
// set missile speed	
	newmis.v_angle = self.v_angle;
	newmis.v_angle_y = newmis.v_angle_y + offsetAngle;
	makevectors (newmis.v_angle);
		
		newmis.velocity = v_forward*100 + v_up*400;
		tempRand = (crandom()*60) - 30;
		newmis.velocity = newmis.velocity + tempRand * v_forward;
		tempRand = (crandom()*40) - 20;
		newmis.velocity = newmis.velocity + tempRand * v_right;
		tempRand = (crandom()*60) - 30;
		newmis.velocity = newmis.velocity + tempRand * v_up;

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = MultiGrenadeTouch;
	
	setmodel (newmis, "progs/mervup.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);

// set missile duration
	newmis.nextthink = time + 1 + (crandom() * 0.5);
	newmis.think = MiniGrenadeExplode;
};

//================================
//================================
void() MultiGrenadeExplode =
{
	MiniGrenadeLaunch(0);
	MiniGrenadeLaunch(72);
	MiniGrenadeLaunch(144);
	MiniGrenadeLaunch(216);
	MiniGrenadeLaunch(288);

	remove (self);
};

//================================
//================================
void() MultiGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		if (self.classname == "MiniGrenade")
			MiniGrenadeExplode();
		else
		{
			if (self.owner.classname == "player")
				GrenadeExplode();
			else
				MiniGrenadeExplode();
		}
		return;
	}
	// bounce sound
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

//================================
//================================
void() W_FireMultiGrenade =
{
	if (deathmatch != 4)
	self.currentammo = self.ammo_multi_rockets = self.ammo_multi_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "MultiGrenade";
		
// set missile speed	
	makevectors (self.v_angle);
	if (self.v_angle_x)
		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = MultiGrenadeTouch;
	
// set missile duration
	newmis.nextthink = time + 1;
	newmis.think = MultiGrenadeExplode;

	setmodel (newmis, "progs/mervup.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);
};

//=============================================================================
// Multi Rocket Code
//=============================================================================

//================================
//================================
void() MultiRocketExplode = 
{
	local float	damg;

//	Stock Single Rocket Damage...
//	damg = 100 + random()*20;

	damg = 60 + random()*15;

	if (other.health)
	{
		other.deathtype = "multirocket";
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
//	Stock single rocket damage.
//	T_RadiusDamage (self, self.owner, 120, other, "multirocket");

	T_RadiusDamage (self, self.owner, 75, other, "multirocket");

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	remove(self);
};

//================================
//================================
void() MultiRocketTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	MultiRocketExplode ();
};


//================================
//================================
void() HomingMissileThink =
{
	local vector	dir;

	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}

	dir = normalize(self.enemy.origin - self.origin);
	self.velocity = dir * 1000;
	self.nextthink = time + 0.1;
	self.think = HomingMissileThink;	
};


//================================
//================================
void() HomingMissileAcquire =
{
	local vector	oldVelocity;
	local vector	aimangle;

	if ( self.delay < time )
	{
		MultiRocketExplode ();
		return;
	}

	oldVelocity = self.velocity;
	makevectors (self.v_angle);
	self.velocity = aim (self, 1000);
	self.velocity = self.velocity * 1000;

	aimangle = self.origin + self.velocity;	
	traceline ( self.origin, aimangle, FALSE, self );
	if (trace_fraction < 1)
	{
		if (trace_ent.flags & FL_MONSTER)
		{
			self.enemy = trace_ent;
			HomingMissileThink();
			return;
		}
	}
	
	self.velocity = oldVelocity;
	self.v_angle = vectoangles ( self.velocity );
	self.angles = self.v_angle;
	self.think = HomingMissileAcquire;
	self.nextthink = time + 0.2;
};

//================================
//================================
void(float offset, float frameNum) MultiRocketLaunch = 
{
	local vector	aimangle;
	
	newmis = spawn ();
	newmis.voided = 0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "MultiRocket";
	newmis.delay = time + 4;
	newmis.frame = frameNum;
	newmis.touch = MultiRocketTouch;

	setmodel (newmis, "progs/rockup_d.mdl");

	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
	
	aimangle = self.v_angle;
	aimangle_y = aimangle_y + (offset * 0.66);
	makevectors (aimangle);
	newmis.velocity = aim(self, 1000);
	newmis.velocity = newmis.velocity * 1000;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.think = MultiRocketExplode;
	newmis.nextthink = time + 4;
};

//================================
//================================
void() W_FireMultiRocket =
{
	if (deathmatch != 4)
	self.currentammo = self.ammo_multi_rockets = self.ammo_multi_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
	
	MultiRocketLaunch ( -10, 2 );
	MultiRocketLaunch ( -5, 3 );
	MultiRocketLaunch ( 5, 0 );
	MultiRocketLaunch ( 10, 1 );
};

//=============================================================================
// Plasma Gun Code
//=============================================================================
void(vector p1, vector p2, entity from, float damage) PlasmaDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		LightningHit (from, damage);
		trace_ent.deathtype = "plasma";
		T_Damage (trace_ent, from, from.owner, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
		trace_ent.deathtype = "plasma";
		T_Damage (trace_ent, from, from.owner, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
		trace_ent.deathtype = "plasma";
		T_Damage (trace_ent, from, from.owner, damage);
	}
};

//================================
//================================
void(entity current, float doDamage) PlasmaDischarge =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	WriteEntity (MSG_MULTICAST, current);
	WriteCoord (MSG_MULTICAST, current.origin_x);
	WriteCoord (MSG_MULTICAST, current.origin_y);
	WriteCoord (MSG_MULTICAST, current.origin_z);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	sound (self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
	if (doDamage == 1)
        PlasmaDamage (self.origin, current.origin, self, 50);
};

//================================
//================================
void() PlasmaGroundOut = 
{
	local entity 	current, start;
	local float		monstersHit;
	
	monstersHit = 0;
	current = findradius ( self.origin, 320 );
	start = current;
	while ( monstersHit < 5 )
	{
		if ( current.flags & FL_MONSTER || current.classname == "player")
		{
			if ( current != self.owner )
			{
				traceline ( self.origin, current.origin, TRUE, world );
				if (trace_fraction == 1)
				{
					monstersHit = monstersHit + 1;
					PlasmaDischarge ( current, 1 );
				}
			}
		}
		current = current.chain;
		if (start == current || !current)
			return;
	}
};

//================================
//================================
void() PlasmaTouch = 
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 80 + random()*20;
	sound (self, CHAN_WEAPON, "plasma/explode.wav", 1, ATTN_NORM);
	
	if (other.health)
	{
		other.deathtype = "plasma";
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 70, other, "plasma");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	PlasmaGroundOut();
	remove (self);
};

//================================
//================================
void() PlasmaLaunch =
{
	self.velocity = normalize(self.velocity);
	self.velocity = self.velocity * 1250;

	self.nextthink = time + 5;
	self.think = SUB_Remove;
};

void(vector org, vector dir) launch_plasma =
{
	newmis = spawn ();
	newmis.voided = 0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "plasma";
	
// set missile speed	
	newmis.velocity = dir * 0.01;
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = PlasmaTouch;
	
	setmodel (newmis, "progs/plasma.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, org);

	sound (newmis, CHAN_WEAPON, "plasma/flight.wav", 1, ATTN_NORM);
	
// set missile duration
	newmis.think = PlasmaLaunch;
	newmis.nextthink = time + 0.1;
};

//================================
//================================
void() W_FirePlasma = 
{
	local float		cells;
	local vector 	dir;
	
	if (self.ammo_plasma < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_plasma;
		self.ammo_plasma = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world, "plasma");
		return;
	}
	if (deathmatch != 4)
	self.currentammo = self.ammo_plasma = self.ammo_plasma - 1;
	sound (self, CHAN_WEAPON, "plasma/fire.wav", 0.5, ATTN_NORM);
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	makevectors (self.v_angle);
	dir = aim ( self, 1000 );
	launch_plasma (self.origin + v_forward*24 + '0 0 16', dir);
};

