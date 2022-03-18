/*
==========================================================

Siege.hc

Totally new entities specifically for Siege

Mike Gummelt

==========================================================
*/

//New effects for players
void turn_undead () {return;}

float num_for_weap (float it_weap)
{
	if(it_weap==IT_WEAPON1)
		return 1;
	else if(it_weap==IT_WEAPON2)
		return 2;
	else if(it_weap==IT_WEAPON3)
		return 3;
	else if(it_weap==IT_WEAPON4)
		return 4;
	else if(it_weap==IT_WEAPON5)
		return 5;
	else if(it_weap==IT_WEAPON6)
		return 6;
	else if(it_weap==IT_WEAPON7)
		return 7;
	else if(it_weap==IT_WEAPON8)
		return 8;
	else
		return 0;
}

float melee_dmg_mod_for_strength (float str_value)
{
float mod_return;
	mod_return=(str_value - 10)/4;
	if(mod_return<0.3)
		mod_return=0.3;
	return mod_return;
}

/*
class 1 - 5
weapons 1 - 3
rate of fire - seconds between shots
accuracy - 0 to 1 * random vector
*/

float rate_and_acc_for_weap [36] =
{
	0.3,0,	0.2,0,	2,.33,	//paladin
	0.2,0,	0,0,	0,0,	//crusader
	0.3,0,	2.5,.2, 0,0,	//necro
	0.1,0,	1,0,	3,0,	//assassin
	0.1,0,	0.3,0,	1,0.1,	//succubus
	0.2,0,	0.1,0,	0,0		//dwarf
};

/*
class 1 - 6
*/

float player_swim_mod [6] =
{
	1,		//paladin- has free action - already ok
	.9,		//crusader
	.82,	//necro
	1.2,	//assassin
	.75,	//succubus
	1		//dwarf - fucked in C code already
};
/*
class 1 - 6
*/

float player_jump_mod [6] =
{
	1.2,//paladin
	0.9,//crusader
	0.8,//necro
	1.5,//assassin
	2,//succubus
	0.65//dwarf 
};

void WriteTeam (float svmsg,entity holder)
{
	entity found;
	found=find(world,classname,"player");
	while(found)
	{
		if(found.flags&FL_CLIENT)
		{
			msg_entity = found;
			switch(svmsg)
			{
			case SVC_HASKEY://send to all- in case need to clear out previous owner on any team
				WriteByte(MSG_ONE,svmsg);
				if(found.siege_team==other.siege_team)
					WriteEntity(MSG_ONE,holder);//tell team
				else
					WriteEntity(MSG_ONE,world);//clear opposite team
				break;
			case SVC_NONEHASKEY://just send to team of last holder
				if(found.siege_team==holder.siege_team)
					WriteByte(MSG_ONE,svmsg);
				break;
			case SVC_ISDOC://only send to def.
				if(found.siege_team==ST_DEFENDER)
				{
					WriteByte(MSG_ONE,svmsg);
					WriteEntity(MSG_ONE,holder);
				}
				break;
			case SVC_NODOC://only to def.
				if(found.siege_team==ST_DEFENDER)
					WriteByte(MSG_ONE,svmsg);
				break;
			}
		}
		found=find(found,classname,"player");
	}
}
 
//Teleport Triggers call this
void become_defender (entity defent)
{
	if(defent.classname!="player"||defent.siege_team==ST_DEFENDER)
		return;
	defent.siege_team=ST_DEFENDER;
	defent.skin=0;
	defent.last_time=time;
	defent.health=defent.max_health;
	setsiegeteam(defent,ST_DEFENDER);//update C and clients
	bprintname(PRINT_HIGH,defent);
	bprint(PRINT_HIGH," becomes a Defender!\n");
	self.target="defender";
}

void become_attacker (entity attent)
{
	if(attent.classname!="player"||attent.siege_team==ST_ATTACKER)
		return;
	attent.siege_team=ST_ATTACKER;
	attent.skin=1;
	attent.last_time=time;
	attent.health=attent.max_health;
	setsiegeteam(attent,ST_ATTACKER);//update C and clients
	bprintname(PRINT_HIGH,attent);
	bprint(PRINT_HIGH," becomes an Attacker!\n");
	self.target="attacker";
}

void become_either (entity eitherent)
{
entity found;
float num_att,num_def;
	num_att=num_def=0;
	found=find(world,classname,"player");
	while(found)
	{
		if(found.siege_team==ST_ATTACKER)
			num_att+=1;
		else if(found.siege_team==ST_DEFENDER)
			num_def+=1;
		found=find(found,classname,"player");
	}
	if(num_att>num_def)
		become_defender(eitherent);
	else if(num_def>num_att)
		become_attacker(eitherent);
	else if(random()<0.5)
		become_defender(eitherent);
	else
		become_attacker(eitherent);
}

