/*
 * $Header: /HexenWorld/HCode/meteor.hc 32    4/10/98 10:58a Nalbury $
 */

/*
==============================================================================

Q:\art\models\weapons\meteor\final\meteor.hc

==============================================================================
*/
// For building the model
$cd Q:\art\models\weapons\meteor\final
$origin 0 0 0
$base BASE skin
$skin skin
$flags 0

//
$frame idle

//
$frame Select1      Select2      Select3      Select4      Select5      
$frame Select6      Select7      Select8      Select9      Select10     
$frame Select11     Select12     Select13     Select14     Select15     
$frame Select16     Select17     Select18     

//
$frame fire1     fire2     fire3     fire4     fire5     
$frame fire6     fire7     fire8     fire9     


void MeteoriteFizzle (void)
{
	CreateWhiteSmoke(self.origin,'0 0 8',HX_FRAME_TIME * 2);
	remove(self);
}

void ByeByeMeteor(void)
{
	remove(self);
}

void MeteorExplode(void)
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_METEORHIT);
	WriteCoord (MSG_MULTICAST, self.origin_x - self.movedir_x * 8);
	WriteCoord (MSG_MULTICAST, self.origin_y - self.movedir_y * 8);
	WriteCoord (MSG_MULTICAST, self.origin_z - self.movedir_z * 8);
	multicast(self.origin,MULTICAST_PHS_R);

	T_RadiusDamage (self, self.owner, 40.0, world);

	remove(self);
}

void MeteorThink (void)
{
	if(self.lifetime<time)
		if(self.dmg==3)
			MeteoriteFizzle();
		else
			MeteorExplode();

	self.think=MeteorThink;
	thinktime self : 0.3;
}

void MeteorTouch (void)
{
	if(other.controller==self.owner)
		return;

	if(self.dmg==3)
	{
		if(other==world)
		{
			if(!self.pain_finished&&random()<0.3)
			{
				sound(self.controller,CHAN_BODY,"misc/rubble.wav",1,ATTN_NORM);
				self.pain_finished=TRUE;
			}
			return;
		}
		else if(other.classname=="meteor")
			return;
	}

	if(other.takedamage&&other.health)
	{
		T_Damage(other,self,self.owner,self.dmg);
		if(self.dmg>3)
		{
			if((other.flags&FL_CLIENT||other.flags&FL_MONSTER)&&other.mass<200)
			{
			vector hitdir;
				hitdir=self.o_angle*300;
				hitdir_z+=150;
				if(hitdir_z<0)
					hitdir_z=0;
				other.velocity=hitdir;
				other.flags(-)FL_ONGROUND;
			}
			self.dmg/=2;
		}
	}
	else if(self.dmg>3)
		self.dmg=100;

	if(self.dmg>3)
		MeteorExplode();
	else
		MeteoriteFizzle();
}

void FireMeteor (string type)
{
vector org;
entity meteor;
	meteor=spawn();
	setmodel(meteor,"models/tempmetr.mdl");
	if(type=="minimeteor")
	{
		meteor.classname="minimeteor";
		meteor.velocity=RandomVector('200 200 0');
		meteor.velocity_z=random(200,400);
		meteor.lifetime=time + 1.5;
		meteor.dmg=3;
		meteor.scale=random(0.15,0.45);
		meteor.movetype=MOVETYPE_BOUNCE;
		org=self.origin;
		setsize(meteor,'0 0 0', '0 0 0');
	}
	else
	{
		meteor.th_die=MultiExplode;
		if(self.classname=="player")
		{
			self.greenmana-=5;
			self.velocity+=normalize(v_forward)*-300;//include mass
			self.flags(-)FL_ONGROUND;
		}
		meteor.classname="meteor";
		self.punchangle_x = -6;
		weapon_sound(self, "crusader/metfire.wav");
		self.attack_finished=time + 0.7;
		self.effects(+)EF_MUZZLEFLASH;
		makevectors(self.v_angle);
		meteor.speed=1000;
		meteor.o_angle=normalize(v_forward);		
		meteor.velocity=meteor.o_angle*meteor.speed;
		meteor.veer=30;
		meteor.lifetime=time + 5;
		meteor.dmg=30;
		meteor.movetype=MOVETYPE_FLYMISSILE;
		org=self.origin+self.proj_ofs+v_forward*12;
		setsize(meteor,'0 0 0', '0 0 0');
		meteor.movedir = normalize(meteor.velocity);
		meteor.effects (+) EF_METEOR_EFFECT;
	}
//	meteor.abslight = 0.5;
	meteor.drawflags(+)MLS_FIREFLICKER;//|MLS_ABSLIGHT;

	if(self.classname=="tornato")
		meteor.owner=self.controller;
	else if(self.classname=="meteor")
		meteor.owner=self.owner;
	else
		meteor.owner=self;
	meteor.controller=self;

	meteor.solid=SOLID_BBOX;
	meteor.touch=MeteorTouch;

	meteor.think=MeteorThink;
	thinktime meteor : 0.1;

	setorigin(meteor,org);
}

void() tornato_touch =
{
};

void() tornato_think =
{
entity	targ;
float	seekspeed;
float	dist, minZVel, t_stren;
float	do_nothing;
vector	throwDir;
float	frac1, frac2;

	makevectors(self.angles);
	traceline(self.origin, self.origin + v_forward*100, FALSE, self);
	frac1 = trace_fraction;
	traceline(self.origin + '0 0 32', self.origin + '0 0 32' + v_forward*100, FALSE, self);
	frac2 = trace_fraction;
	if (frac2 > frac1)
	{
		self.velocity_z += 12;
	}
	else
	{
		traceline(self.origin, self.origin - '0 0 12', FALSE, self);
		if (trace_fraction < 1)
			self.velocity_z += 7;
		else	self.velocity_z -= 7;
	}
	if (self.frame < 24)
	{
		t_stren = 1;
	}
	else
	{
		if (self.frame < 47)
			t_stren = 1 - (self.frame - 24)/24;
		else	t_stren =     (self.frame - 48)/25;
	}

	do_nothing = 0;
	targ = findradius(self.origin, 400);
	while (targ)
	{
		if (targ.takedamage && targ.health && targ != self.owner && targ.mass < 5000 && visible(targ))
		{
			if (targ.movetype && targ.movetype != MOVETYPE_PUSH)
			{
				dist =	sqrt (  ((targ.origin_x - self.origin_x) * (targ.origin_x - self.origin_x)) +
						((targ.origin_y - self.origin_y) * (targ.origin_y - self.origin_y)) );
				if (vlen(targ.velocity) > 400)
				{
					do_nothing = 1;
				}
				else
				{
					if (dist < 64)
					{
						throwDir_x = random(-4,4);
						throwDir_y = random(-4,4);
						throwDir_z = 0;
						targ.velocity = normalize(throwDir) * 2000 * t_stren;
						targ.velocity_z = 800 * t_stren;
						if (targ.classname == "player")
							T_Damage(targ, self, self.owner, 20);
					}
					else
					{
						seekspeed = (400 - dist) * 0.14 * t_stren;
						if (!(targ.flags & FL_ONGROUND))
							seekspeed *= 2.5;
						targ.velocity = normalize(self.origin - targ.origin) * seekspeed;
						minZVel = 120 - (dist * 120)/300 + cos(time * 5)*40;
						minZVel = minZVel * (1 - (targ.origin_z - self.origin_z)/180);
						if (minZVel > 0)
						{
							if (targ.velocity_z < minZVel)
								targ.velocity_z = minZVel;
						}
					}
				}
				if (do_nothing == 0)
				{
					targ.flags (-) FL_ONGROUND;
					if (targ.classname == "player")
						targ.adjust_velocity = targ.velocity;
				}
			}
		}
		targ = targ.chain;
	}
};

void() tornato_die = [++24 .. 47]
{
	if (cycle_wrapped)
	{
		sound(self, CHAN_VOICE, "misc/null.wav", 0.3, ATTN_NORM);
		remove (self);
	}
	tornato_think();
};

void() tornato_spin = [++0 .. 23]
{
	if (time > self.lifetime)
	{
		self.think = tornato_die;
		thinktime self : 0;
	}
	tornato_think();
};

void() tornato_grow = [++48 .. 72]
{
	if (cycle_wrapped)
	{
		self.think = tornato_spin;
		thinktime self : 0;
	}
	tornato_think();
};

void FireMeteorTornado (void)
{
entity tornato;
vector org;

	self.attack_finished = time + 2.5;
	makevectors(self.v_angle);
	weapon_sound(self,"crusader/torngo.wav");
	if (self.classname == "player")
	{
		self.greenmana -= 12;
		self.velocity += normalize(v_forward) * -100;
	}

	self.punchangle_x = -2;
	makevectors(self.v_angle);
	org=self.origin+normalize(v_forward)*16;
	org_z=self.origin_z+12;
		
	tornato=spawn();
	setmodel(tornato,"models/tornato.mdl");
	tornato.classname="tornato";
	tornato.o_angle=normalize(v_forward);
	tornato.velocity=normalize(v_forward) * 150 + '0 0 20';
	tornato.velocity_z=0;
	tornato.movetype=MOVETYPE_FLY;
	setsize(tornato, '-24 -24 0', '24 24 16');
	tornato.hull=HULL_IMPLICIT;
	tornato.movedir=normalize(tornato.velocity);
	tornato.angles=vectoangles(tornato.movedir);
	tornato.scale=175;
	tornato.frame=48;
	tornato.solid=SOLID_NOT;
	tornato.think=tornato_grow;
	thinktime tornato : 0;
	tornato.lifetime=time + 5;
	tornato.owner=self;
	setorigin(tornato, org);
	tornato.effects (+) EF_TORNADO_EFFECT;
	tornato.touch=tornato_touch;
}

void()meteor_ready_loop;
void() Cru_Met_Attack;

void meteor_power_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_power_fire;
	if(self.weaponframe==$fire2 && self.attack_finished<=time)
	{
		FireMeteorTornado();
	}

	if(self.wfs==WF_CYCLE_WRAPPED)
	{
			self.last_attack=time;
			meteor_ready_loop();
	}
}

void meteor_fire (void)
{
	self.wfs = advanceweaponframe($fire1,$fire9);
	self.th_weapon=meteor_fire;

	if((!self.button0||self.attack_finished>time)&&self.wfs==WF_CYCLE_WRAPPED)
	{
		self.last_attack=time;
		meteor_ready_loop();
	}
	else if(self.weaponframe==$fire1 &&self.attack_finished<=time)
			FireMeteor("meteor");
}

void() Cru_Met_Attack =
{
	if(self.artifact_active&ART_TOMEOFPOWER)
		self.th_weapon=meteor_power_fire;
	else
		self.th_weapon=meteor_fire;
	thinktime self : 0;
};

void meteor_ready_loop (void)
{
	self.weaponframe = $idle;
	self.th_weapon=meteor_ready_loop;
}

void meteor_select (void)
{
//go to ready loop, not relaxed?
	self.wfs = advanceweaponframe($Select1,$Select16);
	self.weaponmodel = "models/meteor.mdl";
	self.th_weapon=meteor_select;
	self.last_attack=time;
	if(self.wfs==WF_CYCLE_WRAPPED)
	{
		self.attack_finished = time - 1;
		meteor_ready_loop();
	}
}

void meteor_deselect (void)
{
	self.wfs = advanceweaponframe($Select16,$Select1);
	self.th_weapon=meteor_deselect;

	if(self.wfs==WF_CYCLE_WRAPPED)
		W_SetCurrentAmmo();
}

