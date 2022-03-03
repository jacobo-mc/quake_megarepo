/*
*/
void () player_run;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("player/charge.wav");
	precache_sound ("player/switch.wav");
};

float() crandom =
{
	return 2*(random() - 0.5);
};

//============================================================================


vector() wall_velocity =
{
	local vector	vel;

	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	return vel;
};


/*
===============================================================================

LIGHTNING

===============================================================================
*/


void() W_FireLightning =
{
	if (self.t_width == 0)
	{
		sound (self, CHAN_WEAPON, "player/charge.wav", 1, ATTN_NORM);
		self.t_width = 1;
		self.charge = time;
	}
};


//=============================================================================



/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	
	if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};



/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_light1;


void() W_Attack =
{
	local	float	r;


	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_LIGHTNING && self.slung == 0)
	{
		player_light1();
		self.attack_finished = time + 0.005;
		//sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
};

void() Switch =
{
	if (!(self.flags & FL_ONGROUND) && !(self.switched))
	{
		makevectors (self.v_angle);
		self.velocity = vlen(self.velocity) * v_forward * 1.001; //add a small speed boost while jumpswitching
		self.switched = 1;
		sound (self, 6, "player/switch.wav", 1, ATTN_NORM);
	}
};


/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse == 30)
		Switch ();
	
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;
	
	if (self.impulse)
		ImpulseCommands ();
	
	if ((!self.button0) && self.charge > 0)
	{
		makevectors(self.v_angle);
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		
		local	float realcharge;
		
		realcharge = (time - self.charge);
		
		if (realcharge > 0.8)
			realcharge = 0.8;
		
		self.velocity = v_forward * (realcharge * 1250);
		self.charge = 0;
		self.t_width = 0;
		sound (self, CHAN_WEAPON, "player/charge.wav", 0, ATTN_NONE);
		self.slung = 1;
	}

// check for attack
	if (self.button0)
	{
		W_Attack ();
	}
};



