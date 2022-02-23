// General variables
.float   last_special, last_special2;
.float   x_flags;
.float   start_health;
.float   parallize_time;
.vector  parallized_velocity;
.float   guard_flag;
.float   ammo_special;
.float   weapon_parts;
.float   char_type;              // uses CT_* constants (see below)
.float   tractor_dist;           // how far enemy is from Phoenix player
.float   last_clear;             // used to clear screen of colors every few seconds
.float   rapid_time;
.float   last_wall_hit;          // used for Phoenix Tractor beam smash into wall
.float   last_prox_think;

// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//.vector  respawn_point;

.float   prox_power;             // builds up before releasing button with proximity weapon
.entity  prox_ent;
.string  last_centerprint;

.void()  th_guard;

// this overrides the normal centerprint, so we can save each new centerprint
void(entity client, string s) centerprint;

float    X_PARALLIZED         = 1;
float    X_CANNONFLYABORT     = 2;
float    X_TRACTOR_BEAM_HOLD  = 4;
float    X_SINISTER_FINAL     = 8;
float    X_ANGEL_DEFENSE      = 16;
float    X_STGUN              = 32;
float    X_FLYING             = 64;

float    X_RAPID_FIRE         = 128;
float    X_RAPID_WARNING      = 512;

float    X_MEGA_HIT           = 1024;

float    X_AMMO_ANIMATE       = 2048;
float    X_GODCHEAT           = 4096;

float    X_JUMP_PRESSED       = 8192;

float    CT_MALE_NORMAL       = 1;
float    CT_MALE_LARGE        = 2;
float    CT_FEMALE            = 3;

// Globals
entity  damage_inflictor;
float index_skeleton;

string executable;                     // use temp1 to set executable before entering game
                                       // temp1: 0 = dos, 1 = glQuake, 2 = winQuake
float	num_clients;

// debugging toggles
float    show_damage;                  // used in SetDamageSkin(), gives % readout

// spawnflags
float    SPAWNFLAG_CLONE      = 8;

// deathmatch vars
.float   special_weapon;               // 0 or 1, toggles with subsequent IMPULSE 1 commands
.float   character;                    // one of CHAR_*, may only be set upon joining the game
                                       // if 0, then player can't move and must select a character
.float   last_jump_z;                  // Z value of origin when jump was pressed (used by Angel hovering)
.float   last_jump;                    // time of last jump press

float    CHAR_WOLVERINE    = 1;
float    CHAR_STORM        = 2;
float    CHAR_CYCLOPS      = 3;
float    CHAR_PSYLOCKE     = 4;
float    CHAR_ANGEL        = 5;
float    CHAR_BEAST        = 6;
float    CHAR_GAMBIT       = 7;
float    CHAR_ICEMAN       = 8;
float    CHAR_BISHOP       = 9;
float    CHAR_ROGUE        = 10;
float    CHAR_CANNONBALL   = 11;
float    CHAR_PHOENIX      = 12;

float    STORM_VOFS_Z      = 0;

float    DM_SPECIAL_POWERS = 10;       // set deathmatch = DM_SPECIAL_POWERS for no weapons

// weapon stuff
.float  nextweapon;
.float  change_weapon_status;
.float  fadeout_endframe;
.float  fadein_endframe;
.float   last_fade;
.float   weapon_flags;
.float   remember_impulse;             // stores a change weapon impulse while changing weapons
.float   weapon_idleframe;
.float   water_flame_flag;
.float   consecutive_count, w_pausetime, last_pausetime; // used to pause flame gun after 3 shots

float    W_RELOADING       = 1;
float    W_SHOTRELOAD      = 2;
float    DEATH_FLAG        = 4;

float   CW_DONE      = 0;
float   CW_FADEOUT   = 1;
float   CW_FADEIN    = 2;

// Flame thrower vars
float    FLAME_DIST        = 112;     // distance between each junction
float    FLAME_ENT_SPEED   = 650;     // speed of movement towards ideal position

float    SNDLEN_FLAME      = 0.2;

.entity  flame_ent1;     // trail of 3 flamethrower junction entities
.entity  flame_ent2;
.entity  flame_ent3;

.float   last_flame;
.float   last_flame_sound;

// Laser gun vars
.float   fire_reload_frames;
.float   last_fire_laser;
.float   spawn_time;

// Storm vars
float    MAX_Z_OFS         = 20;

.float   last_wind;
.float   z_ofs;
.float   z_ofs_vel;

// Cyclops
.float   start_attack_health;
.float   last_touch;
.vector  old_velocity;        // also used for Player as Angel in deathmatch for floating downwards

// tech dude
.float   start_frame, last_frame;
.float   tech_state;

float    TECH_IDLE      = 0;
float    TECH_WALKING   = 1;
float    TECH_HIDING    = 2;


// Pheonix
.entity  move_ent;
.float   start_tractor_time;
.vector  tractor_vel;

// Trap Flamethrower
.float   sway_range;

// Apocalypse
.entity  leg;           // main legs entity, displays appy1.mdl

// Cannonball
.float   last_rocket_hit;
