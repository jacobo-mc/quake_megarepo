/*
 * $Header: /HexenWorld/Siege/Weapons.hc 22    6/16/98 12:00p Ggribb $
 */
/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage,entity victim) SpawnPuff;

void() UseInventoryItem;
void() ImpulseCommands;

//============================================================================

vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*random(-0.5,0.5) + v_right*random(-0.5,0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};

/*
================
spawn_touchpuff
================
*/
void(float damage,entity victim) spawn_touchpuff =
{
vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnPuff (self.origin + vel*0.01, vel, damage,victim);
};

void BecomeExplosion (float explodetype)
{
	if (explodetype)
	{
		if(explodetype==CE_FLOOR_EXPLOSION)
			starteffect(CE_FLOOR_EXPLOSION , self.origin+'0 0 64');
		else
			starteffect(explodetype , self.origin);
	}
	else
	{
		if(self.classname=="acidblob")
			starteffect(CE_ACID_EXPL,self.origin - self.movedir*8,'0 0 0',HX_FRAME_TIME*2);
		else if (self.flags2&FL_SMALL)
			starteffect(CE_SM_EXPLOSION , self.origin);
		else if(self.flags&FL_ONGROUND)
			starteffect(CE_FLOOR_EXPLOSION , self.origin+'0 0 64');
		else
			starteffect(CE_LG_EXPLOSION , self.origin);
	}

	if(self.classname=="multigrenade")
	{//Let sounds play here
		self.effects=EF_NODRAW;
		self.velocity='0 0 0';
		self.movetype=MOVETYPE_NONE;
		self.think=SUB_Remove;
		thinktime self : 3;
	}
	else
		remove(self);
}

void() T_MissileTouch =
{
	float	damg;
//	vector delta;  // Quantis never crashes

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = random(100,120);
	if(self.classname=="dragonspike")
		damg=damg * 0.25;
	else if(self.classname=="dragonball")
		damg=damg * 0.5;
	else if (self.classname == "mummymissile")
		damg = random(5,15);
	
	if (other.health)
	{
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	if(self.classname=="dragonspike")
		T_RadiusDamage (self, self.owner, 60, other);
	else if ((self.classname=="mummymissile") || (self.classname=="green_arrow") || (self.classname=="red_arrow"))
		damg = damg;  // No radius damage
	else
		T_RadiusDamage (self, self.owner, 120, other);


//	sound (self, CHAN_WEAPON, "weapons/explode.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (FALSE);
};

//=============================================================================

//=============================================================================

void() spike_touch;
//void() superspike_touch;


/*
===============
launch_spike
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "models/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};



void() spike_touch =
{
//float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchpuff (9,other);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchpuff (18,other);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};*/

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/
void() Nec_Change_Weapon;
void() Pal_Change_Weapon;
void() Cru_Change_Weapon;
void() Ass_Change_Weapon;
void() Suc_Change_Weapon;
void() Dwf_Change_Weapon;

void W_SetCurrentAmmo (void)
{
	if(self.sheep_time>time)
		return;

	wp_deselect = 0;

	self.button0=FALSE;
//	attck_cnt=0;

	if (self.oldweapon==self.weapon)		// Until we get multi skinned weapons
		return;

	if(self.attack_finished<time)
		self.attack_finished=time;

	switch (self.weapon)
	{
	case IT_WEAPON1:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_DWARF:
			warhammer_select();
			break;
		case CLASS_PALADIN:
			vorpal_select();
			break;
		case CLASS_CRUSADER:
			warhammer_select();
			break;
		case CLASS_NECROMANCER:
			sickle_select();
			break;
		case CLASS_SUCCUBUS:
			bloodrain_select();
			break;
		default:	//CLASS_ASSASSIN
			punchdagger_select();
			break;
		}
		break;
	case IT_WEAPON2:
		self.weaponmodel="";
		self.weaponframe = 0;
	
		switch(self.playerclass)
		{
		case CLASS_DWARF:
			axe_select();
			break;
		case CLASS_PALADIN:
			axe_select();
			break;
		case CLASS_CRUSADER:
			centerprint(self,"Heal (5)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			crossbow_select();
			break;
		case CLASS_SUCCUBUS:
			vorpal_select();
			break;
		default:	//CLASS_ASSASSIN
			crossbow_select();
			break;
		}
		break;
	case IT_WEAPON3:
		self.weaponmodel="";
		self.weaponframe = 0;
		switch(self.playerclass)
		{
		case CLASS_PALADIN:
			crossbow_select();
			break;
		case CLASS_CRUSADER:
			centerprint(self,"Enchant Hammer (10)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Magic Missiles (2)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			crossbow_select();
			break;
		default:	//CLASS_ASSASSIN
			crossbow_select();
			break;
		}
	break;
	case IT_WEAPON4:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_CRUSADER:
			centerprint(self,"Turn Undead (15)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Poison (15)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			grenade_select();
			break;
		default:	//CLASS_ASSASSIN
			grenade_select();
			break;
		}
	break;
	case IT_WEAPON5:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_CRUSADER:
			centerprint(self,"Mercurial Speed (20)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Polymorph (30)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			centerprint(self,"Repulsion (10)\n");
			flameorb_select();
			break;
		}
	break;
	case IT_WEAPON6:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_CRUSADER:
			centerprint(self,"Berzerker (30)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Delayed Fireball (40)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			centerprint(self,"Unused spell (?)\n");
			flameorb_select();
			break;
		}
	break;
	case IT_WEAPON7:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_CRUSADER:
			centerprint(self,"Cloak of Perseus (40)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Summon Imp (60)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			centerprint(self,"Unused spell (?)\n");
			flameorb_select();
			break;
		}
	break;
	case IT_WEAPON8:
		self.weaponmodel="";
		self.weaponframe = 0;

		switch(self.playerclass)
		{
		case CLASS_CRUSADER:
			centerprint(self,"Wrath of God (Sacrifice)\n");
			icestaff_select();
			break;
		case CLASS_NECROMANCER:
			centerprint(self,"Become Beast (100)\n");
			magicmis_select();
			break;
		case CLASS_SUCCUBUS:
			centerprint(self,"Flight spell (100)\n");
			flameorb_select();
			break;
		}
	break;
	}

//All players will have to do this eventually, to reset
//the stand, pain, run & fly functions for the different weapons

	//if(self.weapon!=self.oldweapon)
//	{
		switch (self.playerclass)
		{
		case CLASS_DWARF:
			Dwf_Change_Weapon();
			break;
		case CLASS_PALADIN:
			Pal_Change_Weapon();
			break;
		case CLASS_CRUSADER:
			Cru_Change_Weapon();
			break;
		case CLASS_NECROMANCER:
			Nec_Change_Weapon();
			break;
		case CLASS_SUCCUBUS:
			Suc_Change_Weapon();
			break;
		default: //CLASS_ASSASSIN:
			Ass_Change_Weapon();
			break;
		}
		if(self.hull!=HULL_CROUCH||self.playerclass==CLASS_DWARF)
			self.act_state=ACT_STAND;
//	}

/*	if (self.flags2&FL_CAMERA_VIEW)
	{  // FIXME - couldn't this use oldweapon??? rather than lastweapon
		self.lastweapon=self.weaponmodel;
		self.weaponmodel="";
	}
*/

	if(self.flags2&FL_SUMMONED&&self.weapon!=IT_WEAPON3)
	{
		self.flags2(-)FL_SUMMONED;
		self.effects(-)EF_DARKLIGHT;
	}
//	if (self.deselect_time < time)
		self.oldweapon=self.weapon;	
}

float W_CheckNoAmmo (float check_weapon)
{
	if (check_weapon == IT_WEAPON1)
		return TRUE;
	
	switch (self.playerclass)
	{
	case CLASS_ASSASSIN:
		switch (check_weapon)
		{
		case IT_WEAPON4:
			if(self.cnt_glyph >= 1)//glyphs
				return TRUE;
		break;
		case IT_WEAPON3:
		case IT_WEAPON2:
			if(self.cnt_arrows >= 1)
				return TRUE;
		break;
		}
	break;
	case CLASS_DWARF:
		switch (check_weapon)
		{
		case IT_WEAPON1:
		case IT_WEAPON2:
			return TRUE;
			break;
		default:
			return FALSE;
			break;
		}
	break;
	case CLASS_SUCCUBUS:
		switch (check_weapon)
		{
		case IT_WEAPON8:
			if(self.greenmana >= 100)
					return TRUE;
		break;
		case IT_WEAPON7:
			if(self.greenmana >= 60)
					return TRUE;
		break;
		case IT_WEAPON6:
			if(self.greenmana >= 30)
					return TRUE;
		break;
		case IT_WEAPON5:
			if(self.greenmana >= 10)
					return TRUE;
		break;
		case IT_WEAPON4:
			if(self.cnt_grenades >= 1)
				return TRUE;
		break;
		case IT_WEAPON3:
			if(self.cnt_arrows >= 1)
				return TRUE;
		break;
		default://weapon 1 or 2
			return TRUE;
		break;
		}
	break;
	case CLASS_CRUSADER:
		switch (check_weapon)
		{
		case IT_WEAPON8:
			if(self.bluemana >= self.max_mana)
				return TRUE;
		break;
		case IT_WEAPON7:
			if(self.bluemana >= 60)
				return TRUE;
		break;
		case IT_WEAPON6:
			if(self.bluemana >= 50)
				return TRUE;
		break;
		case IT_WEAPON5:
			if(self.bluemana >= 30)
				return TRUE;
		break;
		case IT_WEAPON4:
			if(self.bluemana >= 20)
				return TRUE;
		break;
		case IT_WEAPON3:
			if(self.bluemana >= 10)
				return TRUE;
		break;
		case IT_WEAPON2:
			if(self.bluemana >= 5)
				return TRUE;
		break;
		}
	break;
	case CLASS_NECROMANCER:
		switch (check_weapon)
		{
		case IT_WEAPON8:
			if(self.greenmana >= 100)
				return TRUE;
		break;
		case IT_WEAPON7:
			if(self.greenmana >= 60)
				return TRUE;
		break;
		case IT_WEAPON6:
			if(self.greenmana >= 40)
				return TRUE;
		break;
		case IT_WEAPON5:
			if(self.greenmana >= 30)
				return TRUE;
		break;
		case IT_WEAPON4:
			if(self.greenmana >= 15)
				return TRUE;
		break;
		case IT_WEAPON3:
			if(self.greenmana >= 2)
				return TRUE;
		break;
		case IT_WEAPON2:
			if(self.cnt_arrows >= 1)
				return TRUE;
		break;
		}
	break;
	case CLASS_PALADIN:
		switch (check_weapon)
		{
		case IT_WEAPON3:
			if(self.cnt_arrows >= 1)
				return TRUE;
		break;
		case IT_WEAPON2:
			return TRUE;
		default:
			return FALSE;
		break;
		}
	break;
	default:
		dprintf("Unknown class: %s!\n",self.playerclass);
	break;
	}
	return FALSE;
}

//=========================
// W_BestWeapon : choose the most powerful weapon the player has ammo for
//=========================
void() W_BestWeapon =
{
	if (W_CheckNoAmmo (IT_WEAPON8) && (self.items & IT_WEAPON8))
		self.weapon = IT_WEAPON8;
	else if (W_CheckNoAmmo (IT_WEAPON7) && (self.items & IT_WEAPON7))
		self.weapon = IT_WEAPON7;
	else if (W_CheckNoAmmo (IT_WEAPON6) && (self.items & IT_WEAPON6))
		self.weapon = IT_WEAPON6;
	else if (W_CheckNoAmmo (IT_WEAPON5) && (self.items & IT_WEAPON5))
		self.weapon = IT_WEAPON5;
	else if (W_CheckNoAmmo (IT_WEAPON4) && (self.items & IT_WEAPON4))
		self.weapon = IT_WEAPON4;
	else if (W_CheckNoAmmo (IT_WEAPON3) && (self.items & IT_WEAPON3))
		self.weapon = IT_WEAPON3;
	else if (W_CheckNoAmmo (IT_WEAPON2) && (self.items & IT_WEAPON2))
		self.weapon = IT_WEAPON2;
	else
		self.weapon = IT_WEAPON1;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()player_sheep_baa;
void() W_Attack =
{
	if (!W_CheckNoAmmo (self.weapon))
	{
		W_BestWeapon ();
		W_SetCurrentWeapon ();
		return;
	}
	
	if(self.attack_finished>time)
		return;

	if(self.sheep_time>time)
	{
		player_sheep_baa();
		return;
	}

	if(self.climbing)
		return;

	if(self.viewentity!=self&&self.viewentity.classname!="chasecam")
		return;

	self.show_hostile = time + 1;	// wake monsters up
	self.last_attack=time;			//In attack state

	if(self.hull==HULL_PLAYER||self.playerclass==CLASS_DWARF)
		self.act_state=ACT_ATTACK;
	else
		self.act_state=ACT_CROUCH_MOVE;

	switch (self.weapon) 
	{
	case IT_WEAPON1:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
			pal_vorpal_fire();
			break;
		case CLASS_NECROMANCER:
			sickle_decide_attack();
			break;
		case CLASS_ASSASSIN:
			Ass_Pdgr_Fire();
			break;
		case CLASS_CRUSADER:
		case CLASS_DWARF:
			Cru_Wham_Fire();
			break;
		case CLASS_SUCCUBUS:
			Suc_Blrn_Fire();
			break;
		}
	break;
	case IT_WEAPON2:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_DWARF:
			pal_axe_fire();
		break;
		case CLASS_ASSASSIN:
			if(self.cnt_arrows<1)
				centerprint(self,"You have no arrows!\n");
			else
				crossbow_fire();
		break;
		case CLASS_SUCCUBUS:
			self.attack_finished=time+0.5;
			pal_vorpal_fire();
		break;
		case CLASS_CRUSADER:
			self.attack_finished=time+0.5;
			heal();
		break;
		case CLASS_NECROMANCER:
			if(self.cnt_arrows<1)
				centerprint(self,"You have no arrows!\n");
			else
				crossbow_fire();
		break;
		}
	break;
	case IT_WEAPON3:
		switch (self.playerclass)
		{
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_PALADIN:
			if(self.cnt_arrows<1)
				centerprint(self,"You have no arrows!\n");
			else
				crossbow_fire();
		break;
		case CLASS_ASSASSIN:
			if(!self.velocity_x&&!self.velocity_y&&!self.velocity_z)
			{
				if(self.cnt_arrows<1)
					centerprint(self,"You have no arrows!\n");
				else
					crossbow_fire();
			}
			else
			{
				centerprint(self,"Hold still!\n");
				return;
			}
		break;
		case CLASS_SUCCUBUS:
			if(self.cnt_arrows<1)
				centerprint(self,"You have no arrows!\n");
			else
				crossbow_fire();
		break;
		case CLASS_CRUSADER:
			if(self.bluemana<10)
				centerprint(self,"Not enough mana (10)\n");
			else
			{
				self.cnt_tome+=1;
				Use_TomeofPower();		
				self.flags (+) FL_ARTIFACTUSED;
				Cru_Wham_Fire();
				self.bluemana-=10;
			}
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<2)
				centerprint(self,"Not enough mana (2)\n");
			else
				Nec_Mis_Attack();
		break;
		}
	break;
	case IT_WEAPON4:
		switch (self.playerclass)
		{
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_PALADIN:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_ASSASSIN:
			if(self.cnt_glyph<1)
				centerprint(self,"You have no tripwires!\n");
			else
			{
				self.attack_finished=time+0.5;
				Use_Tripwire();
				self.cnt_glyph-=1;
			}
		break;
		case CLASS_CRUSADER:
			if(self.bluemana<15)
				centerprint(self,"Not enough mana (15)\n");
			else
				centerprint(self, "Not Implemented\n");
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<15)
				centerprint(self,"Not enough mana (15)\n");
			else
				poison();
		break;
		case CLASS_SUCCUBUS:
			if(self.cnt_grenades<1)
				centerprint(self,"You have no grenades!\n");
			else
				grenade_throw();
		break;
		}
	break;
	case IT_WEAPON5:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_ASSASSIN:
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_CRUSADER:
			if(self.bluemana<20)
				centerprint(self,"Not enough mana (20)\n");
			else
			{
				self.attack_finished=time+0.5;
				mercury_speed();
			}
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<30)
				centerprint(self,"Not enough mana (30)\n");
			else
			{
				self.attack_finished=time+0.5;
				self.cnt_polymorph+=1;
				Use_Polymorph();
				self.greenmana-=30;
			}
		break;
		case CLASS_SUCCUBUS:
			if(self.greenmana<10)
				centerprint(self,"You need 10 mana for this spell!\n");
			else
			{
				self.attack_finished=time+0.5;
				self.cnt_blast+=1;
				UseBlast();
				self.greenmana-=10;
			}
		break;
		}
	break;
	case IT_WEAPON6:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_ASSASSIN:
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_CRUSADER:
			if(self.bluemana<30)
				centerprint(self,"Not enough mana (30)\n");
			else
			{
				self.attack_finished=time+0.5;
				berzerker();
			}
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<40)
				centerprint(self,"Not enough mana (40)\n");
			else
			{
				self.attack_finished=time+0.5;
				Use_Fireball();
				self.greenmana-=40;
			}
		break;
		case CLASS_SUCCUBUS:
			if(self.greenmana<40)
				centerprint(self,"You need 40 mana for this spell!\n");
			else
			{
				centerprint(self,"not implemented!\n");
//				self.greenmana-=40;
			}
		break;
		}
	break;
	case IT_WEAPON7:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_ASSASSIN:
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_CRUSADER:
			self.attack_finished=time+0.5;
			Invisibility();
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<60)
				centerprint(self,"Not enough mana (60)\n");
			else
			{
				self.attack_finished=time+0.5;
				self.cnt_summon+=1;
				Use_Summoner();
				self.greenmana-=60;
			}
		break;
		case CLASS_SUCCUBUS:
			if(self.greenmana<60)
				centerprint(self,"You need 60 mana for this spell!\n");
			else
			{
				centerprint(self,"not implemented!\n");
//				self.greenmana-=60;
			}
		break;
		}
	break;
	case IT_WEAPON8:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_ASSASSIN:
		case CLASS_DWARF:
			centerprint(self,"You don't have that weapon!\n");
			return;
		break;
		case CLASS_CRUSADER:
			self.attack_finished=time+0.5;
			Wrath_Of_God();
		break;
		case CLASS_NECROMANCER:
			if(self.greenmana<100)
				centerprint(self,"Not enough mana (100)\n");
			else
			{
				self.attack_finished=time+0.5;
				BecomeBeast();
			}
		break;
		case CLASS_SUCCUBUS:
			if(self.greenmana<100)
				centerprint(self,"You need 100 mana for this spell!\n");
			else
			{
				self.attack_finished=time+0.5;
				self.cnt_flight+=1;
				Use_RingFlight();
				self.greenmana-=100;
			}
		break;
		}
	break;
	}
};


void W_DeselectWeapon (void)
{
	wp_deselect = 1;

	switch (self.oldweapon)
	{
	case IT_WEAPON1:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
			vorpal_deselect();
		break;
		case CLASS_CRUSADER:
		case CLASS_DWARF:
			warhammer_deselect();
		break;
		case CLASS_ASSASSIN:
			punchdagger_deselect();
		break;
		case CLASS_SUCCUBUS:
			bloodrain_deselect();
		break;
		case CLASS_NECROMANCER:
			sickle_deselect();
		break;
		}
	break;
	case IT_WEAPON2:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
		case CLASS_DWARF:
			axe_deselect();
		break;
		case CLASS_CRUSADER:
			icestaff_deselect();
		break;
		case CLASS_ASSASSIN:
			crossbow_deselect();
		break;
		case CLASS_SUCCUBUS:
			vorpal_deselect();
		break;
		case CLASS_NECROMANCER:
			crossbow_deselect();
		break;
		}
	break;
	case IT_WEAPON3:
		switch (self.playerclass)
		{
		case CLASS_PALADIN:
			crossbow_deselect();
		break;
		case CLASS_CRUSADER:
			icestaff_deselect();
		break;
		case CLASS_ASSASSIN:
			crossbow_deselect();
		break;
		case CLASS_NECROMANCER:
			magicmis_deselect();
		break;
		case CLASS_SUCCUBUS:
			grenade_deselect();
		break;
		}
	break;
	case IT_WEAPON4:
		switch (self.playerclass)
		{
		case CLASS_CRUSADER:
			icestaff_deselect();
		break;
		case CLASS_ASSASSIN:
			grenade_deselect();
		break;
		case CLASS_NECROMANCER:
			magicmis_deselect();
		break;
		case CLASS_SUCCUBUS:
			flameorb_deselect();
		break;
		}
	break;
	case IT_WEAPON5 .. IT_WEAPON8:
		switch (self.playerclass)
		{
		case CLASS_CRUSADER:
			icestaff_deselect();
		break;
		case CLASS_NECROMANCER:
			magicmis_deselect();
		break;
		case CLASS_SUCCUBUS:
			flameorb_deselect();
		break;
		}
	break;
	default:
		W_SetCurrentAmmo();
	break;
	}
}

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	if(self.weapon==IT_WEAPON1&&self.flags2&FL2_EXCALIBUR)
		return;

	if(self.sheep_time>time)
	{
		return;
	}

	if(self.viewentity!=self&&self.viewentity.classname!="chasecam")
	{
		return;
	}

	if(self.attack_finished>time)
	{
		return;
	}

float	it, am, fl;
	
	it = self.items;
	am = 0;
	
	switch (self.impulse)
	{
	case 1:
		fl = IT_WEAPON1;
	break;
	case 2:
		fl = IT_WEAPON2;
	break;
	case 3:
		fl = IT_WEAPON3;
	break;
	case 4:
		fl = IT_WEAPON4;
	break;
	case 5:
		fl = IT_WEAPON5;
	break;
	case 6:
		fl = IT_WEAPON6;
	break;
	case 7:
		fl = IT_WEAPON7;
	break;
	case 8:
		fl = IT_WEAPON8;
	break;
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{
		sprinti (self, PRINT_MEDIUM,STR_NOCARRYWEAPON);
		return;
	}

	if(!W_CheckNoAmmo(fl))
	{
		sprinti (self, PRINT_MEDIUM,STR_NOTENOUGHMANA);
		return;
	}

//
// set weapon, set ammo
//
	self.oldweapon=self.weapon;//for deselection animation
	self.weapon = fl;		
	W_SetCurrentWeapon ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if(deathmatch||coop||skill>2)
		return;

	self.items(+)IT_WEAPON1|IT_WEAPON2|IT_WEAPON3|IT_WEAPON4|IT_WEAPON4_1|IT_WEAPON4_2;
	self.items(+)IT_WEAPON5|IT_WEAPON6|IT_WEAPON7|IT_WEAPON8;

	self.bluemana = self.max_mana;
	self.greenmana = self.max_mana;
	self.cnt_grenades=15;
	self.cnt_arrows=50;

	self.impulse = 0;

/*
	if(self.attack_finished<time)
	{
		self.oldweapon = self.weapon;
		self.weapon = IT_WEAPON4;
		W_SetCurrentWeapon ();
	}
*/
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
float	it, am;

	if(self.attack_finished>time)
		return;

	self.impulse = 0;

	self.items (+) IT_WEAPON1;
	it = self.items;

	while (1)
	{
		am = 0;

		switch (self.weapon)
		{
		case IT_WEAPON8:
			self.weapon = IT_WEAPON5;
		break;
		case IT_WEAPON7:
			switch (self.playerclass)
			{
			case CLASS_PALADIN:
			case CLASS_ASSASSIN:
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON8;
				break;
			}
		break;
		case IT_WEAPON6:
			switch (self.playerclass)
			{
			case CLASS_PALADIN:
			case CLASS_ASSASSIN:
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON7;
				break;
			}
		break;
		case IT_WEAPON5:
			switch (self.playerclass)
			{
			case CLASS_PALADIN:
			case CLASS_ASSASSIN:
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON6;
				break;
			}
		break;
		case IT_WEAPON4:
			switch (self.playerclass)
			{
			case CLASS_PALADIN:
			case CLASS_ASSASSIN:
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON5;
				break;
			}
		break;
		case IT_WEAPON1:
			self.weapon = IT_WEAPON2;
		break;
		case IT_WEAPON2:
			switch (self.playerclass)
			{
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON3;
				break;
			}
		break;
		case IT_WEAPON3:
			switch (self.playerclass)
			{
			case CLASS_PALADIN:
			case CLASS_DWARF:
				self.weapon = IT_WEAPON1;
				break;
			default:
				self.weapon = IT_WEAPON4;
				break;
			}
		break;
		}
	
		am = W_CheckNoAmmo(self.weapon);
		if ((it & self.weapon) && am)
		{
			W_SetCurrentWeapon ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
//	local	float	it, am;
	//not supported anymore	
	return;
	/*
	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		switch (self.weapon)
		{
		case IT_WEAPON4:
			self.weapon = IT_WEAPON3;
			if (self.greenmana < 1)
				am = 1;
		break;
		case IT_WEAPON3:
			self.weapon = IT_WEAPON2;
		break;
		case IT_WEAPON2:
			self.weapon = IT_WEAPON1;
		break;
		case IT_WEAPON1:
			self.weapon = IT_WEAPON4;
			if ((self.bluemana < 1) && (self.greenmana<1))
				am = 1;
		break;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentWeapon ();
			return;
		}
	}
*/

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};


/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	ImpulseCommands ();

	if (time < self.attack_finished)
		return;

// check for attack
	if (self.button0)
	{
		W_Attack ();
	}
};

/*
========
	ClassChangeWeapon - Player is changing class so change weapon model to match. Called from C code
========
*/
void ClassChangeWeapon(void)
{
	self.drawflags(-)MLS_ABSLIGHT|DRF_TRANSLUCENT;

	if(self.sheep_time>time)
		return;

	self.weaponframe = 0;
	if (self.playerclass==CLASS_PALADIN)
	{
		switch (self.weapon)
		{
		case  IT_WEAPON1:
			self.th_weapon=vorpal_select;
			if(self.flags2&FL2_EXCALIBUR)
				self.weaponmodel = "models/v_excal.mdl";
			else
				self.weaponmodel = "models/vorpal.mdl";
		break;
		case IT_WEAPON2:
			self.th_weapon=axe_select;
			self.weaponmodel = "models/axe.mdl";
		break;
		case IT_WEAPON3:
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/xbow2.mdl";
		break;
		}
	}
	else if (self.playerclass==CLASS_DWARF)
	{
		switch (self.weapon)
		{
		case IT_WEAPON1:
			self.th_weapon=warhammer_select;
			self.weaponmodel = "models/warhamer.mdl";
		break;
		case IT_WEAPON2:
			self.th_weapon=axe_select;
			self.weaponmodel = "models/axe.mdl";
		break;
		}
	}
	else if (self.playerclass==CLASS_CRUSADER)
	{
		switch (self.weapon)
		{
		case IT_WEAPON1:
			self.th_weapon=warhammer_select;
			self.weaponmodel = "models/warhamer.mdl";
		break;
		default:
			self.th_weapon=icestaff_select;
			self.weaponmodel = "models/icestaff.mdl";
		break;
		}
	}
	else if (self.playerclass==CLASS_NECROMANCER)
	{
		switch (self.weapon)
		{
		case IT_WEAPON1:
			self.th_weapon=sickle_select;
			self.weaponmodel = "models/sickle.mdl";
		break;
		case IT_WEAPON2:
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/xbow2.mdl";  // FIXME: still need these models
		break;
		case IT_WEAPON3:
			self.th_weapon=magicmis_select;
			self.weaponmodel = "models/spllbook.mdl";
		break;
		}
	}
	else if (self.playerclass==CLASS_ASSASSIN)
	{
		switch (self.weapon)
		{
		case IT_WEAPON1:
			self.th_weapon=punchdagger_select;
			self.weaponmodel = "models/punchdgr.mdl";
		break;
		case IT_WEAPON2:
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/xbow2.mdl";
		break;
		case IT_WEAPON3:
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/xbow2.mdl";
		break;
		default:
			self.th_weapon=grenade_select;
			self.weaponmodel = "models/v_assgr.mdl";
		break;
		}
	}
	else if (self.playerclass==CLASS_SUCCUBUS)
	{
		switch (self.weapon)
		{
		case IT_WEAPON1:
			self.th_weapon=bloodrain_select;
			self.weaponmodel = "models/sucwp1.mdl";
		break;
		case IT_WEAPON2:
			self.th_weapon=vorpal_select;
			self.weaponmodel = "models/vorpal.mdl";
		break;
		case IT_WEAPON3:
			self.th_weapon=grenade_select;
			self.weaponmodel = "models/v_assgr.mdl";
		break;
		case IT_WEAPON4:
			self.th_weapon=crossbow_select;
			self.weaponmodel = "models/xbow2.mdl";
		break;
		default:
			self.th_weapon=flameorb_select;
			self.weaponmodel = "models/sucwp3.mdl";
		break;
		}
	}
//FIXME: take off all timed effects, lighting tinting, drawflags,
//	power-ups, etc.  Reset max health, abilities, etc.
	SetModelAndThinks();
	self.act_state=ACT_STAND;
}


void W_SetCurrentWeapon (void) 
{
	if(self.attack_finished>time)
	{
		return;
	}

	if(self.sheep_time>time)
	{
		return;
	}

	self.button0=FALSE;
//	attck_cnt=0;

	if (self.oldweapon==self.weapon)		// Until we get multi skinned weapons
	{
		if(tomeMode == 1)
		{
			if(self.artifact_active & ART_TOMEOFPOWER)
			{
				self.artifact_active(-)ART_TOMEOFPOWER;
				self.tome_time = 0;
			}
			else
			{
				self.artifact_active(+)ART_TOMEOFPOWER;
				self.tome_time = time + 1200000; // arbitrary fairly large number
			}
		}
		if(tomeMode == 2)
		{
			if(self.poweredFlags & self.weapon)
			{
				if(self.artifact_active & ART_TOMEOFPOWER)
				{
					self.artifact_active(-)ART_TOMEOFPOWER;
					self.tome_time = 0;
				}
				else
				{
					self.artifact_active(+)ART_TOMEOFPOWER;
					self.tome_time = time + 1200000; // arbitrary fairly large number
				}				
			}
		}
		return;
	}

	if(tomeMode == 2)
	{
		self.artifact_active(-)ART_TOMEOFPOWER;
		self.tome_time = 0;
	}

	self.attack_finished=time + 999;
	W_DeselectWeapon ();
}

