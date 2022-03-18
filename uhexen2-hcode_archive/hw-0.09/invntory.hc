/*
 * $Header: /HexenWorld/HCode/invntory.hc 39    5/04/98 8:49p Mgummelt $
 */

entity SelectSpawnPoint(void);
void teleport_touch (void);
void PlayerSpeed_Calc (void);
void player_fly(void);
void player_stopfly(void);
void XbowBoltTurn(entity bolt);
void PolyTurn(entity bolt);
void DrillaTurn(entity bolt);

void Use_RingFlight()
{
	if(self.rings&RING_FLIGHT)
	{//Toggle off, but don't get leftovers!
		self.ring_flight=self.ring_flight_time=0;
		self.rings(-)RING_FLIGHT;
		self.rings_low (-) RING_FLIGHT;
		player_stopfly();
		self.cnt_flight -= 1;
	}
	else
	{
		self.rings(+)RING_FLIGHT;
		self.ring_flight = 100;
		self.ring_flight_time = time + 1;
		player_fly();
		self.rings_low (-) RING_FLIGHT;
	}
}

void()monster_imp_lord;
void BecomeImp ()
{
float move_cnt;
	if(other.solid!=SOLID_BSP)
		return;

	self.solid=SOLID_NOT;
	setorigin(self,self.origin+'0 0 42');
	setsize(self,'-40 -40 -42','40 40 42');
	self.hull=HULL_HYDRA;
	newmis=spawn();
	setorigin(newmis,self.origin);
	tracearea(self.origin,self.origin+'0 0 1',self.mins,self.maxs,FALSE,newmis);
	while((trace_fraction<1||trace_allsolid)&&move_cnt<36)
	{
		setorigin(newmis,newmis.origin+'0 0 1');
		tracearea(newmis.origin,newmis.origin+'0 0 1',self.mins,self.maxs,FALSE,newmis);
		move_cnt+=1;
	}
	if(trace_fraction==1&&!trace_allsolid)
	{
		self.touch=SUB_Null;

		newmis.flags2(+)FL_SUMMONED;
		newmis.controller=self.owner;
		newmis.team=self.owner.team;
		newmis.classname="monster_imp_lord";
		newmis.lifetime=time+30;
		if(self.owner.enemy!=world&&self.owner.enemy.flags2&FL_ALIVE&&visible2ent(self.owner.enemy,self))
		{
			newmis.enemy=newmis.goalentity=self.owner.enemy;
			newmis.monster_awake=TRUE;
		}
		else
		{
			newmis.enemy=newmis.goalentity=self.owner;
			newmis.monster_awake=TRUE;
		}
		self.owner.imp_count+=1;
		newmis.imp_count=self.owner.imp_count;
		newmis.think=monster_imp_lord;
		thinktime newmis : 0;

		sound (newmis, CHAN_AUTO, "weapons/expsmall.wav", 1, ATTN_NORM);
		sound (newmis, CHAN_VOICE, "imp/upbig.wav", 1, ATTN_NORM);
		setorigin(self,self.origin-'0 0 42');
		BecomeExplosion(CE_FLOOR_EXPLOSION);
		newmis.hull = HULL_HYDRA;
		newmis.solid = SOLID_SLIDEBOX;
	}
	else
	{
	entity oself;
		setorigin(self,self.origin-'0 0 42'-self.movedir*8);
		traceline(self.origin+'0 0 10',self.origin-'0 0 100',TRUE,self);
		sound (newmis, CHAN_BODY, "items/itmspawn.wav", 1, ATTN_NORM);	// play respawn sound
		newmis.classname="art_summon";
		setorigin(newmis,trace_endpos+'0 0 40');
		CreateWhiteFlash(newmis.origin);
		oself=self;
		oself.think=SUB_Remove;
		thinktime oself : 0;
		self=newmis;
		spawn_artifact(ARTIFACT_SUMMON,FALSE);
	}
}

void Use_Summoner ()
{
	self.attack_finished=time + 0.1;//So you can't have a ton of them
	makevectors(self.v_angle);
//sound
entity missile;
    missile=spawn();
    missile.owner=self;
    missile.classname="summon";
    missile.movetype=MOVETYPE_BOUNCE;
    missile.solid=SOLID_BBOX;
	missile.touch=BecomeImp;
	missile.effects=EF_DIMLIGHT;
	missile.drawflags=MLS_POWERMODE;

	missile.movedir=normalize(v_forward);
	missile.velocity=normalize(v_forward)*300 +v_up*100;
	missile.avelocity=RandomVector('300 300 300');

	setmodel (missile, "models/a_summon.mdl");
	setsize(missile,'0 0 0','0 0 0');
	setorigin(missile,self.origin+self.proj_ofs+v_forward*16);
	missile.think=BecomeImp;
	thinktime missile : 1;
	self.cnt_summon-=1;
}

/*
	teleport_coin_run - The entity "teleportcoin" is created when teleport artifact is used 
*/
void teleport_coin_run (void)
{
	//added this for chaos device hangin-around
	self.touch = teleport_touch;
	self.think = SUB_Remove;
	self.nextthink = time + 3.0;//!shorter time, por favor!

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT_LINGER);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 3.0);

	//this part was here b4
	other = self.enemy;
	teleport_touch();
}

/*
   Use_teleportCoin - generates an entity that acts like a teleporter trigger which places the
                      player in his startspot or in deathmatch at a random start spot
*/
void () Use_TeleportCoin =
{
entity teleport_ent;

	self.flags2(+)FL_TORNATO_SAFE;
	teleport_ent = spawn();

	teleport_ent.goalentity = SelectSpawnPoint ();

	teleport_ent.classname = "teleportcoin";
	teleport_ent.inactive = FALSE;
	teleport_ent.think = teleport_coin_run;
	teleport_ent.nextthink = time + .01;
	teleport_ent.spawnflags = 0;

	self.cnt_teleport -= 1;
	teleport_ent.enemy = self;

	//added this for chaos device hangin-around
	setorigin (teleport_ent, self.origin);
	teleport_ent.movetype = MOVETYPE_NONE;
	teleport_ent.solid = SOLID_TRIGGER;
	teleport_ent.takedamage = DAMAGE_NO;
    setsize(teleport_ent,'-16 -16 0','16 16 56');
//	setmodel (teleport_ent, "models/sheep.mdl");//uncomment if tempent not working to see where teleport is supposed to be


};

void wedge_run(void)
{
    if ((self.owner.velocity_x == 0) && (self.owner.velocity_y == 0) && (self.owner.velocity_z == 0))
		self.effects(+)EF_NODRAW;	// All stop
    else if (self.effects & EF_NODRAW) 
		self.effects(-)EF_NODRAW;

	self.angles = vectoangles(self.owner.velocity);

	self.origin = self.owner.origin;
	self.think = wedge_run;
//self.nextthink = time + HX_FRAME_TIME;
	self.nextthink = time + .04;    // This faster time is because it would lag behind every once in a while

	if ((self.owner.health<=0) || !(self.owner.artifact_active & ART_HASTE))
		remove(self);

}

/*
void launch_hastewedge (void)
{
	local entity tail;

	tail = spawn ();
	tail.movetype = MOVETYPE_NOCLIP;
	tail.solid = SOLID_NOT;
	tail.classname = "haste_wedge";
	setmodel (tail, "models/wedge.mdl");
	setsize (tail, '0 0 0', '0 0 0');		
	tail.drawflags(+)DRF_TRANSLUCENT;

	tail.owner = self;
	tail.origin = tail.owner.origin;
	tail.velocity = tail.owner.velocity;
    tail.angles = tail.owner.angles;

	tail.think = wedge_run;
	tail.nextthink = time + HX_FRAME_TIME;

}
*/

void Use_TomeofPower (void)
{
	if(self.model=="models/sheep.mdl")
		self.sheep_time=0;
	else
	{
		if((tomeMode == 1)||(tomeMode == 2))
		{	// does nothing but sheep stuff...
			return;
		}
		self.artifact_active = self.artifact_active | ART_TOMEOFPOWER;
		self.tome_time = time + TOME_TIME;
	}
	self.cnt_tome -= 1;
}


void () Use_Haste =
{
	self.artifact_active = self.artifact_active | ART_HASTE;
	self.haste_time = time + TOME_TIME;

//	launch_hastewedge ();

	self.effects(+)EF_DARKFIELD;
	PlayerSpeed_Calc();

	self.cnt_haste -= 1;
};

/*
============
Use_ProximityMine
============
*/

void proximity_think ()
{
float okay;
	thinktime self : 0.1;
	if(self.lifetime<time)
	{
		self.think=MultiExplode;
		thinktime self : 0;
		return;
	}
	if(!visible(self.enemy)&&!self.enemy.effects&EF_NODRAW)
		self.enemy=world;
	if(self.enemy)
	{
	float dist;
	vector org;
		org=(self.enemy.absmin+self.enemy.absmax)*0.5;
		dist=vlen(org-self.origin);
		if(dist<100)
		{
			sound(self,CHAN_AUTO,"misc/warning.wav",1,ATTN_NORM);
			self.think=MultiExplode;
			thinktime self : 0.3;
		}
		else
			self.velocity=normalize(org-self.origin)*150;
	}
	else
	{
		if(random()<0.5)
		{
		float bestdist,lastdist;
		entity found;
			bestdist=1001;
			found=findradius(self.origin,1000);
			while(found)
			{
				if(found.health&&found.flags2&FL_ALIVE&&!found.effects&EF_NODRAW&&found!=self.owner&&found!=self&&found.controller!=self.owner)
				{
					if(coop&&found.classname=="player")
						okay=FALSE;
					if(teamplay&&found.team==self.owner.team)
						okay=FALSE;
					else
						okay=TRUE;
					if(okay)
					{
						lastdist=vlen(found.origin-self.origin);
						if(lastdist<bestdist)
						{
							self.enemy=found;
								bestdist=lastdist;
						}
					}
				}
				found=found.chain;
			}
		}
	}
}

void Use_Proximity_Mine ()
{
	newmis=spawn();
	newmis.owner=self;
	newmis.classname="proximity";
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.solid=SOLID_BBOX;
	newmis.dmg=50+self.level*10;
	if(newmis.dmg>120)
		newmis.dmg=120;
	newmis.health=10;
	newmis.takedamage=DAMAGE_YES;
	newmis.touch=newmis.th_die=MultiExplode;
	newmis.angles_x=90;
	newmis.avelocity_y=100;
	newmis.skin=1;
	newmis.drawflags(+)MLS_POWERMODE;
	setmodel (newmis, "models/glyphwir.mdl");
	setsize(newmis,'-3 -3 -3','3 3 3');
	newmis.hull=HULL_POINT;
	setorigin(newmis,self.origin+self.proj_ofs);
	newmis.lifetime=time+30;
	newmis.think=proximity_think;
	thinktime newmis : 0;
}

/*
============
UseTimebomb
============
*/

void TimeBombExplode()
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_TIME_BOMB);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast(self.origin,MULTICAST_PHS_R);

	T_RadiusDamage(self, self.owner, 100.0, self.owner);

	remove(self);
}

void TimeBombTouch()
{
	if((other == self.owner)||(other == world)||(!(other.takedamage)))
	{
		return;
	}

	TimeBombExplode();
}

void TimeBombThink()
{
	float dist;
	float vel;
	// move around and stay close to the owner.
	dist = vlen(self.owner.origin - self.origin);

	if(dist > 160)
	{	// teleport into place
		self.origin = self.owner.origin + normalize(self.origin - self.owner.origin)*120 + '0 0 20';
	}
	else if(dist > 80)
	{
		vel = vlen(self.owner.velocity);
		self.velocity = normalize(self.owner.origin + '0 0 20' - self.origin)*vel;
	}
	else
	{
		self.velocity_x = 0;
		self.velocity_y = 0;
		self.velocity_z = 0;
	}

	// run out if too long
	if(time > self.health + 6.0)
	{
		TimeBombExplode();
	}
	thinktime self : 0.05;
}


void Use_TimeBomb()
{
	newmis=spawn();
	newmis.owner=self;
	newmis.enemy=world;
	newmis.classname="timebomb";
	newmis.solid=SOLID_BBOX;
	newmis.dmg=50;
	newmis.touch=TimeBombTouch;
	newmis.angles_x=90;
	newmis.avelocity_y=100;
	newmis.skin=1;
	newmis.drawflags(+)MLS_ABSLIGHT;
	newmis.abslight=0.5;
	setmodel (newmis, "models/glyphwir.mdl");
	setsize(newmis,'0 0 0','0 0 0');
	setorigin(newmis,self.origin+self.proj_ofs);
	newmis.movetype=MOVETYPE_FLYMISSILE;
	newmis.think=TimeBombThink;
	thinktime newmis : 0.05;
	newmis.health = time;
}

/*
============
	Anything which can change a velocity of a client effect missile
	must call this function
============
*/

void UpdateMissileVelocity(entity missile)
{
	
	if((missile.flags & EF_NODRAW)||(missile.model == ""))
	{	//if nodraw, it is probably a client effect and needs updating
		if((missile.classname == "magic missile")||
		(missile.classname == "bone_powered")||
		(missile.classname == "bone_shrapnel")||
		(missile.classname == "bone_normal"))
		{
			turneffect(missile.wrq_effect_id, missile.origin, missile.velocity);
		}
		else if ((missile.classname == "bird_missile")||
		(missile.classname == "set_missile"))
		{
			turneffect(missile.raven_effect_id, missile.origin, missile.velocity);
		}
		else if ((missile.classname == "flaming arrow")||
		(missile.classname == "bolt"))
		{
			XbowBoltTurn(missile);
		}
		else if (missile.classname == "polyblob")
		{
			PolyTurn(missile);
		}
		else if (missile.classname == "pincer")
		{
			DrillaTurn(missile);
		}
	}
}

/*
============
UseBlast
============
*/
void UseBlast (void)
{
	vector  dir,holdpos;
	entity  victim;
	float v_length,push,percent,points,inertia;
	
	self.cnt_blast -= 1;//moved this up here--doing damage to other things can
	//trigger an explosion and kill me, so if i decriment count after that, i might end up with -1 discs.

	victim = findradius( self.origin, BLAST_RADIUS*2);
	self.safe_time=time+7;

	while(victim)
	{
		if (victim.classname!="hook"&&victim.owner.classname != "circfire" && victim.classname != "cube_of_force"&&victim.monsterclass<CLASS_BOSS)
		{
//			dprint(victim.classname);
//			dprint(" blasted\n");
			if (((victim.health) && (victim!=self) ) ||
				(victim.movetype == MOVETYPE_FLYMISSILE) || (victim.movetype == MOVETYPE_BOUNCEMISSILE) && (victim.owner != self))
			{
				traceline(self.origin,victim.origin,TRUE,self);

				if (trace_fraction == 1)  // No walls in the way
				{
					sound (self, CHAN_WEAPON, "raven/blast.wav", 1, ATTN_NORM);

					if (((victim.movetype != MOVETYPE_FLYMISSILE) && (victim.movetype != MOVETYPE_BOUNCEMISSILE)) || (victim.classname =="chain_head" ))
					{	
						dir =  victim.origin - self.origin;
						v_length = vlen (dir);

						// For missile entities can only be moved within blast radius
						if  (v_length < BLAST_RADIUS)
						{
							// The further away, the less the push
							percent = BLAST_RADIUS / v_length;
								
							if (percent > 3)
								percent = 3;

							if (victim.mass>20)
								inertia = victim.mass/20;
							else
								inertia = 1;

							push = (percent + 1)/inertia;
							victim.velocity = dir * push;
							victim.flags(-)FL_ONGROUND;

							push = ((percent * 100) + 100)/inertia;
							victim.velocity_z = push;
							UpdateMissileVelocity(victim);
						}
					}
					else
					{
						victim.frags=2;
						//if(victim.classname=="pincer")
						//	victim.enemy=victim.owner;
						victim.enemy=victim.owner;
						victim.owner = self;
						if (victim.classname!="tornato")
						{
							victim.velocity = victim.velocity * -1;
							victim.angles = vectoangles(victim.velocity);
							UpdateMissileVelocity(victim);
						}
					}

					holdpos = victim.origin;
					holdpos_z += (victim.maxs_z - victim.mins_z)/2;
					traceline(self.origin,holdpos,FALSE,self);
					CreateBlueFlash(trace_endpos);

					points = percent * BLASTDAMAGE;  // Minimum blast damage
					if (points > 10)
						points = 10;

					T_Damage (victim, self, self, points);
				}
			}
		}

		if (victim.classname=="tornato" && victim.enemy.flags2&FL_ALIVE)
			victim.enemy.flags2(+)FL_TORNATO_SAFE;
		if(victim.classname=="swarm")
		{
			victim.think=hive_die;
			thinktime victim : 0;
		} 


		victim = victim.chain;
   }

	if(self.v_angle_x > 30)
	{
		if(self.artifact_active & ART_TOMEOFPOWER)
		{
			self.velocity_z += 500 * sin(self.v_angle_x);
		}
		else
		{
			self.velocity_z += 300 * sin(self.v_angle_x);
		}
	}

}

void UseInvincibility (void)
{
	self.artifact_active = self.artifact_active | ART_INVINCIBILITY;
	if(deathmatch)
		self.invincible_time = time + TOME_TIME;
	else
		self.invincible_time = time + 10;
	if (self.artifact_low & ART_INVINCIBILITY)
		self.artifact_low = self.artifact_low - (self.artifact_low & ART_INVINCIBILITY);

//Temp invincibility effects
	if(self.playerclass==CLASS_CRUSADER)
		self.skin = GLOBAL_SKIN_STONE;
	else if(self.playerclass==CLASS_PALADIN)
		self.effects(+)EF_BRIGHTLIGHT; 
	else if(self.playerclass==CLASS_ASSASSIN)
		self.colormap=140;
	else if(self.playerclass==CLASS_NECROMANCER)
		self.effects(+)EF_DARKLIGHT;

	self.cnt_invincibility -= 1;
}

void UseInvisibility (void)
{
	centerprint(self,"You are Invisible!\n");
	self.artifact_active = self.artifact_active | ART_INVISIBILITY;
	self.invisible_time = time + TOME_TIME;
	if (self.artifact_low & ART_INVISIBILITY)
		self.artifact_low = self.artifact_low - (self.artifact_low & ART_INVISIBILITY);

	msg_entity=self;
	WriteByte(MSG_ONE, SVC_SET_VIEW_FLAGS);
	WriteByte(MSG_ONE,DRF_TRANSLUCENT);
	self.effects(+)EF_NODRAW|EF_LIGHT; 
	self.cnt_invisibility -= 1;
}

void()Use_Polymorph;
void()Use_Tripwire;
void()Use_Fireball;

void BreakChainsForEnt(entity ent)
{
	if(!ent.flags2&FL_CHAINED)
		return;

	ent.flags2(-)FL_CHAINED;
	if (ent.classname == "player")
	{
		if(!(ent.rings&RING_FLIGHT))
			ent.movetype=MOVETYPE_WALK;
	}
	else
	{
		ent.movetype = ent.oldmovetype;
	}
}

void BreakChains()
{
	if(!self.flags2&FL_CHAINED)
		return;

	self.flags2(-)FL_CHAINED;
	if(!self.rings&RING_FLIGHT)
		self.movetype=MOVETYPE_WALK;
}

void UseInventoryItem (void)
{

	if (self.health <= 0)
		return;

	if(self.artifact_active&ARTFLAG_FROZEN&&self.inventory!=INV_TORCH)
		return;

	// Is it in the inventory
	if ((self.inventory == INV_TORCH) && (self.cnt_torch))
	{
		if (self.torchtime < (time + 5))
		{
			UseTorch ();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_TELEPORT) && (self.cnt_teleport))
	{
		Use_TeleportCoin ();
		BreakChains();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_HP_BOOST) && (self.cnt_h_boost))
	{
		use_healthboost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_SUPER_HP_BOOST) && (self.cnt_sh_boost))
	{
		use_super_healthboost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_MANA_BOOST) && (self.cnt_mana_boost))
	{
		UseManaBoost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_GLYPH) && (self.cnt_glyph))
	{
		self.cnt_glyph-=1;
		if(self.playerclass==CLASS_ASSASSIN)
			Use_Tripwire();
		else if(self.playerclass==CLASS_CRUSADER)
			Use_TimeBomb ();
		else if(self.playerclass==CLASS_PALADIN)
			Use_Fireball();
		else if(self.playerclass==CLASS_NECROMANCER)
			Use_Proximity_Mine();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_HASTE) && (self.cnt_haste))
	{
		if (self.haste_time < (time + 5))
		{
			Use_Haste();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_BLAST) && (self.cnt_blast))
	{
		UseBlast();		
		BreakChains();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_CUBEOFFORCE) && (self.cnt_cubeofforce))
	{
		if ((!self.artifact_flags & AFL_CUBE_LEFT) ||
			(!self.artifact_flags & AFL_CUBE_RIGHT))
		{
			UseCubeOfForce();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_INVINCIBILITY) && (self.cnt_invincibility))
	{
		if (self.invincible_time < (time + 5))
		{
			UseInvincibility();		
			BreakChains();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_INVISIBILITY) && (self.cnt_invisibility))
	{
		if (self.invisible_time < (time + 5))
		{
			UseInvisibility();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_TOME) && (self.cnt_tome))
	{
		if (self.tome_time < (time + 5))
		{
			Use_TomeofPower();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	else if ((self.inventory == INV_POLYMORPH) && (self.cnt_polymorph))
	{
		Use_Polymorph();		
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_SUMMON) && (self.cnt_summon))
	{
		Use_Summoner();		
		self.flags (+) FL_ARTIFACTUSED;
	}
	else if ((self.inventory == INV_FLIGHT) && (self.cnt_flight))
	{
		Use_RingFlight();
		self.flags (+) FL_ARTIFACTUSED;
	}
	else
	{	// Can't even try to use flight in non-deathmatch
		if ((!deathmatch) && (self.inventory == INV_FLIGHT))
			time = time;
		else
		{
			sprinti(self, PRINT_MEDIUM, STR_DONOTPOSSESS);
		}
	}

}

void PanicButton ()
{

	if (self.health <= 0)
		return;

//	if(self.flags2&FL_CHAINED)
//		return;

	if (self.cnt_torch)
	{
		if (self.torchtime < (time + 5))
		{
			UseTorch ();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_teleport)
	{
		Use_TeleportCoin ();
		BreakChains();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_h_boost)
	{
		use_healthboost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_sh_boost)
	{
		use_super_healthboost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_mana_boost)
	{
		UseManaBoost ();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_glyph)
	{
		self.cnt_glyph=self.cnt_glyph - 1;
		if(self.playerclass==CLASS_ASSASSIN)
			Use_Tripwire();
		else if(self.playerclass==CLASS_CRUSADER)
			Use_TimeBomb ();
		else if(self.playerclass==CLASS_PALADIN)
			Use_Fireball();
		else if(self.playerclass==CLASS_NECROMANCER)
			Use_Proximity_Mine();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_haste)
	{
		if (self.haste_time < (time + 5))
		{
			Use_Haste();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_blast)
	{
		UseBlast();		
		BreakChains();
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_cubeofforce)
	{
		if ((!self.artifact_flags & AFL_CUBE_LEFT) ||
			(!self.artifact_flags & AFL_CUBE_RIGHT))
		{
			UseCubeOfForce();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_invincibility)
	{
		if (self.invincible_time < (time + 5))
		{
			UseInvincibility();		
			BreakChains();
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_invisibility)
	{
		if (self.invisible_time < (time + 5))
		{
			UseInvisibility();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_tome)
	{
		if (self.tome_time < (time + 5))
		{
			Use_TomeofPower();		
			self.flags (+) FL_ARTIFACTUSED;
		}
	}
	if (self.cnt_polymorph)
	{
		Use_Polymorph();		
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_summon)
	{
		Use_Summoner();		
		self.flags (+) FL_ARTIFACTUSED;
	}
	if (self.cnt_flight)
	{
		Use_RingFlight();
		self.flags (+) FL_ARTIFACTUSED;
	}
}

void  DropInventoryItem (void)
{
	entity item,holdent;
	float throwflag;

	makevectors(self.v_angle);
	traceline(self.origin + self.proj_ofs,self.origin + self.proj_ofs + v_forward * 60,FALSE,self);

	if (trace_fraction < 1)
	{
		remove(item);
		centerprint(self,"Not enough room to throw");
		return;
	}

	item = spawn();



	item.flags(+)FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	item.owner = self;
	item.artifact_ignore_owner_time = time + 2;
	item.artifact_ignore_time = time + 0.1;

	setsize (item, '-8 -8 -38', '8 8 24');
	holdent=self;
	self = item;
	throwflag = 0;

	// Is it in the inventory
	if ((holdent.inventory == INV_TORCH) && (holdent.cnt_torch))
	{
		spawn_artifact(ARTIFACT_TORCH,NO_RESPAWN);
		holdent.cnt_torch -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_HP_BOOST) && (holdent.cnt_h_boost))
	{
		spawn_artifact(ARTIFACT_HP_BOOST,NO_RESPAWN);
		holdent.cnt_h_boost -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_SUPER_HP_BOOST) && (holdent.cnt_sh_boost))
	{
		spawn_artifact(ARTIFACT_SUPER_HP_BOOST,NO_RESPAWN);
		holdent.cnt_sh_boost -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_MANA_BOOST) && (holdent.cnt_mana_boost))
	{
		spawn_artifact(ARTIFACT_MANA_BOOST,NO_RESPAWN);
		holdent.cnt_mana_boost -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_TELEPORT) && (holdent.cnt_teleport))
	{
		spawn_artifact(ARTIFACT_TELEPORT,NO_RESPAWN);
		holdent.cnt_teleport -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_TOME) && (holdent.cnt_tome))
	{
		spawn_artifact(ARTIFACT_TOME,NO_RESPAWN);
		holdent.cnt_tome -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_SUMMON) && (holdent.cnt_summon))
	{
		spawn_artifact(ARTIFACT_SUMMON,NO_RESPAWN);
		holdent.cnt_summon -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_INVISIBILITY) && (holdent.cnt_invisibility))
	{
		spawn_artifact(ARTIFACT_INVISIBILITY,NO_RESPAWN);
		holdent.cnt_invisibility -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_GLYPH) && ((holdent.cnt_glyph&&holdent.playerclass!=CLASS_CRUSADER)||holdent.cnt_glyph>=5))
	{
		spawn_artifact(ARTIFACT_GLYPH,NO_RESPAWN);
		if(holdent.playerclass==CLASS_CRUSADER)
			holdent.cnt_glyph -=5;
		else
			holdent.cnt_glyph -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_HASTE) && (holdent.cnt_haste))
	{
		spawn_artifact(ARTIFACT_HASTE,NO_RESPAWN);
		holdent.cnt_haste -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_BLAST) && (holdent.cnt_blast))
	{
		spawn_artifact(ARTIFACT_BLAST,NO_RESPAWN);
		holdent.cnt_blast -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_POLYMORPH) && (holdent.cnt_polymorph))
	{
		spawn_artifact(ARTIFACT_POLYMORPH,NO_RESPAWN);
		holdent.cnt_polymorph -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_FLIGHT) && 
					((holdent.cnt_flight > 0 && !(holdent.rings&RING_FLIGHT))||//if we have just 1 left, and it's in use, don't drop it
					(holdent.cnt_flight > 1)))
	{
		spawn_artifact(ARTIFACT_FLIGHT,NO_RESPAWN);
		holdent.cnt_flight -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_CUBEOFFORCE) && (holdent.cnt_cubeofforce))
	{
		spawn_artifact(ARTIFACT_CUBEOFFORCE,NO_RESPAWN);
		holdent.cnt_cubeofforce -=1;
		throwflag = 1;
	}
	else if ((holdent.inventory == INV_INVINCIBILITY) && (holdent.cnt_invincibility))
	{
		spawn_artifact(ARTIFACT_INVINCIBILITY,NO_RESPAWN);
		holdent.cnt_invincibility -=1;
		throwflag = 1;
	}

	self = holdent;

	if (throwflag)  // Something could be thrown
	{
		// Throw it
		item.velocity = normalize (v_forward);
		item.velocity = item.velocity * 200;
		item.velocity_x += random(-20,20);	// So they don't land on top if each other if player is 
		item.velocity_y += random(-20,20);	// standing in one place and throwing multiple items
		item.velocity_z = 200;
		makevectors(self.v_angle);
		setorigin(item,self.origin + self.proj_ofs + v_up * 10 + v_forward * 40 + v_right * 8);
		
		sound(self,CHAN_BODY,"misc/whoosh.wav",1,ATTN_NORM);
	}
	else
		remove(item);

}

void Inventory_Quick(float which)
{
	float old_inv;

	old_inv = self.inventory;
	self.inventory = which;
	UseInventoryItem();
	self.inventory = old_inv;
}

