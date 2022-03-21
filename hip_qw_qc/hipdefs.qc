/* Level pack definitons
   Copyright (c)1996 Hipnotic Interactive, Inc.
   All rights reserved.
   Do not distribute.
*/

entity nullentity;
entity bulletholes;
entity lastbullet;
float numbulletholes;
float IT_MJOLNIR = 128;
float IT_LASER_CANNON = 8388608;
float IT_PROXIMITY_GUN = 65536;
float HIP_IT_WETSUIT = 2;
float HIP_IT_EMPATHY_SHIELDS = 4;

float visible_distance;
entity damage_inflictor;
float footsteps;


//MED 11/09/96 added new spawnflags
float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;
float SPAWNFLAG_LAVABALL = 4;
float SPAWNFLAG_ROCKET = 8;
float SPAWNFLAG_SILENT = 16;


.float wetsuit_finished;
.float wetsuit_time;
.float empathy_finished;
.float empathy_time;
.float empathy_sound;
.float color;

//
// Hipnotic entries
//
// have to use a new items flag because we ran out of bits in the original
.float      items2;
.entity     lastvictim;
// laser cannon
.vector     old_velocity;
//misc
.float      duration;
// used for linked list of entities
.entity     next_ent;
// Mjolnir
.float      struck_by_mjolnir;
// teleport invulnerability
.entity	spawnmaster;
.float	gorging;
.float	spawnsilent;
.float	huntingcharmer;
.string     spawnclassname;
.float      spawnmulti;
.void()     spawnfunction;

// Rotation
.vector neworigin;
.vector rotate;
.float  endtime;
.float  rotate_type;
.string path;
.string group;
.string event;

// Miscellaneous
.float gravity;

//MED 01/05/97 added discharge variable
float discharged;
//
// Hipnotic's Prototypes
//
void() StopEarthQuake;
void( float value ) EarthQuakeTime;
void() earthquake_postthink;
void() earthquake_prethink;
float( entity counter ) counter_GetCount;
vector ( vector ang ) SUB_NormalizeAngles;
//multi explosion
void( vector loc, float rad, float damage, float dur, float pause, float vol) multi_explosion;

void() RotateTargets;
void() RotateTargetsFinal;
void() SetTargetOrigin;
void() LinkRotateTargets;

float HIPQW_FOOTSTEPS = 1;
float HIPQW_BULLETHOLES = 2;
float sv_gravity;