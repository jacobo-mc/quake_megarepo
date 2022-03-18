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

