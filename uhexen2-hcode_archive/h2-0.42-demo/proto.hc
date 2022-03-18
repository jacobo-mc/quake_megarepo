
//**************************************************************************
//**
//** proto.hc
//**
//** $Header: /H3/game/hcode/proto.hc 35    9/10/97 11:39p Mgummelt $
//**
//**************************************************************************

// combat.hc

void T_Damage(entity targ, entity inflictor, entity attacker, float damage);
//float T_Heal(entity e, float healamount, float ignore);
float CanDamage(entity targ, entity inflictor);

// subs.hc

void SUB_CalcMove(vector tdest, float tspeed, void() func);
void SUB_CalcAngleMove(vector destangle, float tspeed, void() func);
void SUB_CalcMoveDone(void);
void SUB_CalcAngleMoveDone(void);
void SUB_Null(void);
void SUB_UseTargets(void);
void SUB_Remove(void);

void AwardExperience(entity ToEnt, entity FromEnt, float Amount);

void() SetModelAndThinks;
void stats_NewPlayer(entity e);

void()shock_think;
void(vector org)spawnshockball;
void(entity light_targ)lightstyle_change;
void(entity targ, entity attacker,entity inflictor) Killed;

//void()player_paladin_gauntlet_attack;
//void()player_paladin_swaxe_attack;
//void()player_paladin_staff_attack;
//void()player_paladin_crouch_move;

//void()player_assassin_hands_attack;
//void()player_assassin_xbow_attack;
//void()player_assassin_staff_attack;
//void()player_assassin_crouch_move;

// quake.hc

void(float richter) MonsterQuake;
void() MultiExplode;
void(entity targ, entity attacker, entity inflictor) ClientObituary;
void(entity loser,float number)drop_level;
void()DarkExplosion;

float()FindMonsterTarget;
void()MonsterCheckContents;
float visibility_good (entity targ);
float()CheckJump;
void()W_SetCurrentWeapon;
void(float explodetype)BecomeExplosion; 
void()player_frames;
void Create_Missile (entity spawner,entity victim,vector spot,string missilemodel, 
	string missilename,float missileskin,float missilespeed,void() touchfunct);

