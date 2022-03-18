entity self;
entity other;
entity world;
float time;
float frametime;
float force_retouch;
string mapname;
string startspot;
float deathmatch;
float coop;
float teamplay;
float serverflags;
float total_secrets;
float total_monsters;
float found_secrets;
float killed_monsters;
float chunk_cnt;
float done_precache;
float parm1;
float parm2;
float parm3;
float parm4;
float parm5;
float parm6;
float parm7;
float parm8;
float parm9;
float parm10;
float parm11;
float parm12;
float parm13;
float parm14;
float parm15;
float parm16;
vector v_forward;
vector v_up;
vector v_right;
float trace_allsolid;
float trace_startsolid;
float trace_fraction;
vector trace_endpos;
vector trace_plane_normal;
float trace_plane_dist;
entity trace_ent;
float trace_inopen;
float trace_inwater;
entity msg_entity;
float cycle_wrapped;
void  ()main;
void  ()StartFrame;
void  ()PlayerPreThink;
void  ()PlayerPostThink;
void  ()ClientKill;
void  ()ClientConnect;
void  ()PutClientInServer;
void  ()ClientDisconnect;
void  ()ClassChangeWeapon;
void  ()SetNewParms;
void  ()SetChangeParms;
void end_sys_globals;
float movedist;
float gameover;
string string_null;
entity newmis;
entity activator;
entity damage_attacker;
float framecount;
float skill;
float crouch_cnt;
float comamode;
.float modelindex;
.vector absmin;
.vector absmax;
.float ltime;
.float movetype;
.float solid;
.vector origin;
.vector oldorigin;
.vector velocity;
.vector angles;
.vector avelocity;
.vector punchangle;
.string classname;
.string model;
.float frame;
.float skin;
.float effects;
.float scale;
.float drawflags;
.float abslight;
.vector mins;
.vector maxs;
.vector size;
.float hull;
.void  () touch;
.void  () use;/* !! */
.void  () think;
.void  () blocked;
.float nextthink;
.entity groundentity;
.float stats_restored;
.float frags;
.float weapon;
.string weaponmodel;
.float weaponframe;
.float health;
.float max_health;
.float playerclass;
.float bluemana;
.float greenmana;
.float armor_amulet;
.float armor_bracer;
.float armor_breastplate;
.float armor_helmet;
.float level;
.float intelligence;
.float wisdom;
.float dexterity;
.float strength;
.float experience;
.float flight_time;
.float water_time;
.float absorption_time;
.float regen_time;
.float haste_time;
.float tome_time;
.string puzzle_inv_1;
.string puzzle_inv_2;
.string puzzle_inv_3;
.string puzzle_inv_4;
.string puzzle_inv_5;
.string puzzle_inv_6;
.string puzzle_inv_7;
.string puzzle_inv_8;
.float experience_value;
.float items;
.float takedamage;
.entity chain;
.float deadflag;
.vector view_ofs;
.float button0;
.float button1;
.float button2;
.float impulse;
.float fixangle;
.vector v_angle;
.float idealpitch;
.float idealroll;
.float hoverz;
.string netname;
.entity enemy;
.float flags;
.float artifact_flags;
.float colormap;
.float team;
.float teleport_time;
.float armortype;
.float armorvalue;
.float waterlevel;
.float watertype;
.float friction;
.float ideal_yaw;
.float yaw_speed;
.entity goalentity;
.float spawnflags;
.string target;
.string targetname;
.float dmg_take;
.float dmg_save;
.entity dmg_inflictor;
.entity owner;
.vector movedir;
.string message;
.float soundtype;
.string noise;
.string noise1;
.string noise2;
.string noise3;
.float rings;
.float rings_active;
.float rings_low;
.float artifacts;
.float artifact_active;
.float artifact_low;
.float hasted;
.float inventory;
.float cnt_torch;
.float cnt_h_boost;
.float cnt_sh_boost;
.float cnt_mana_boost;
.float cnt_teleport;
.float cnt_tome;
.float cnt_summon;
.float cnt_mine;
.float cnt_glyph;
.float cnt_haste;
.float cnt_blast;
.float cnt_polymorph;
.float cnt_mirror;
.float cnt_cubeofforce;
.float cnt_invincibility;
.float cameramode;
.entity movechain;
.void  () chainmoved;
void end_sys_fields;
.string wad;
.string map;
.float worldtype;
.string killtarget;
.float light_lev;
.float style;
.void  () th_stand;
.void  () th_walk;
.void  () th_run;
.void  () th_missile;
.void  () th_melee;
.void  (entity attacker,float damage) th_pain;
.void  () th_die;
.void  () th_save;
.entity oldenemy;
.float speed;
.float lefty;
.float search_time;
.float attack_state;
.float monster_stage;
.float monster_duration;
.float monster_awake;
.float monster_check;
.vector monster_last_seen;
.vector adjust_velocity;

.union
{ // Entity type specific stuff
	struct // player stuff
	{		
		float splash_time;	    // When to generate the next splash
		float camera_time;      //
		float cheatmode;
		float weaponframe_cnt;  //
		float attack_cnt;       // Shows which attack animation can be used
	};
	struct
	{ // Fallen Angel
		float fangel_SaveFrame;
		float fangel_Count;
	};
	struct
	{ // Fallen Angel's Spell
		float spell_angle;
	};
	struct
	{ // Hydra
		float hydra_FloatTo;
	};
	struct
	{ // Spider
		float spiderType;			// SPIDER_? types
		float spiderActiveCount;	// Tallies "activity"
		float spiderGoPause;		// Active/pause threshold
		float spiderPauseLength;	// Pause duration in frames
		float spiderPauseCount;		// Tallies paused frames
	};
	struct
	{ // Scorpion
		float scorpionType;			// SCORPION_? types
		float scorpionRest;			// Resting state counter
	};
	struct
	{ // Imp
		float impType;				// IMP_? types
	};
	struct
	{ // Mummy
		float parts_gone;
		float mummy_state;
		float mummy_state_time;
	};
	struct
	{ // Artifacts
		float artifact_respawn;		// Should respawn?
		float artifact_ignore_owner_time;
		float artifact_ignore_time;
	};
	struct
	{ // Rider path
		float next_path_1;
		float next_path_2;
		float next_path_3;
		float next_path_4;
		float path_id;
	};
	struct
	{ // Rider triggers
		float rt_chance;
	};
	struct
	{ // Rider data
		float rider_gallop_mode;
		float rider_last_y_change;
		float rider_y_change;
		float rider_death_speed;
		float rider_path_distance;
		float rider_move_adjustment;
	};
	struct
	{ // War rider axe
		float waraxe_offset;
		float waraxe_horizontal;
		float waraxe_track_inc;
		float waraxe_track_limit;
		float waraxe_max_speed;
		float waraxe_max_height;
	};
	struct
	{ // War rider's quake
		float wrq_effect_id;
		float wrq_radius;
		float wrq_count;
	};
	struct
	{ // Rider's beam
		float beam_angle_a;
		float beam_angle_b;
		float beam_max_scale;
		float beam_direction;
		float beam_speed;
	};
	struct	
	{	// Used by smoke generator
		float z_modifier;	
	};
	struct
	{
		float last_health; // Used by bell entity
	};
};

.float turn_time;
.string puzzle_piece_1;
.string puzzle_piece_2;
.string puzzle_piece_3;
.string puzzle_piece_4;
.string no_puzzle_msg;
.string puzzle_id;
.entity path_current;
.float ai_state;
.float ai_new_state;
.void  () ai_move_func;
.void  () ai_self_func;
.void  () ai_state_func;
.float ai_duration;
.float move_distance;
.float ai_poss_states;
.float ai_frame_time;
.float just_hurt;
.vector oldangles;
.string lastweapon;
.float lifetime;
.float lifespan;
.float holo_engaged;
float AS_STRAIGHT   =  1.00000;
float AS_SLIDING   =  2.00000;
float AS_MELEE   =  3.00000;
float AS_MISSILE   =  4.00000;
.float walkframe;
.float wfs;
.float attack_finished;
.float pain_finished;
.float invincible_finished;
.float invisible_finished;
.float water_start;
.float invincible_time;
.float invincible_sound;
.float invisible_time;
.float invisible_sound;
.float super_time;
.float super_sound;
.float fly_sound;
.float axhitme;
.float show_hostile;
.float jump_flag;
.float swim_flag;
.float air_finished;
.float bubble_count;
.string deathtype;
.string mdl;
.vector mangle;
.float t_length;
.float t_width;
.float color;
.float counter;
.float pullflag;
.float plaqueflg;
.vector plaqueangle;
.float camptime;
.vector dest;
.vector dest1;
.vector dest2;
.float wait;
.float delay;
.entity trigger_field;
.string noise4;
.float pausetime;
.entity pathentity;
.float aflag;
.float dmg;
.float cnt;
.float thingtype;
.float exploderadius;
.float torchtime;
.void  () torchthink;
.float healthtime;
.void  () healththink;
.void  () think1;
.vector finaldest;
.vector finalangle;
.float count;
.float lip;
.float state;
.vector pos1;
.vector pos2;
.float height;
.float waitmin;
.float waitmax;
.vector orgnl_mins;
.vector orgnl_maxs;
.entity pullobj;
.float veer;
.float homerate;
.float mass;
.float onfire;
.vector o_angle;
.float bloodloss;
.float oldweapon;
.entity controller;
.float init_modelindex;
.string init_model;
.void  () th_swim;
.void  () th_jump;
.void  () th_fly;
.void  () th_die1;
.void  () th_die2;
.void  () th_goredeath;
.void  () th_possum;
.void  () th_possum_up;
.float last_attack;
.entity shield;
float SVC_SETVIEWPORT   =  5.00000;
float SVC_SETVIEWANGLES   =  10.00000;
.float frozen;
.float oldskin;
.void  () oldthink;
.void  () th_weapon;
.float decap;
.string headmodel;
.void  () oldtouch;
.float oldmovetype;
.float target_scale;
.float scalerate;
.float blizzcount;
.vector proj_ofs;
void  (float richter)MonsterQuake;
.float flags2;
.string spawnername;
.entity catapulter;
.float catapult_time;
.float last_onground;
.vector pos_ofs;
.vector angle_ofs;
.float safe_time;
.float absorb_time;
.float mintel;
.vector wallspot;
.vector lastwaypointspot;
.entity lockentity;
.float last_impact;
.float active;
.string msg2;
.float gravity;
.float upside_down;
.float lightvalue1;
.float lightvalue2;
.float fadespeed;
.float point_seq;
void  ()shock_think;
void  (vector org)spawnshockball;
void  (entity light_targ)lightstyle_change;
void  (entity targ,entity attacker)Killed;
float FALSE   =  0.00000;
float TRUE   =  1.00000;
float HX_FRAME_TIME   =  0.05000;
float HX_FPS   =  20.00000;
float FL_FLY   =  1.00000;
float FL_SWIM   =  2.00000;
float FL_PUSH   =  4.00000;
float FL_CLIENT   =  8.00000;
float FL_INWATER   =  16.00000;
float FL_MONSTER   =  32.00000;
float FL_GODMODE   =  64.00000;
float FL_NOTARGET   =  128.00000;
float FL_ITEM   =  256.00000;
float FL_ONGROUND   =  512.00000;
float FL_PARTIALGROUND   =  1024.00000;
float FL_WATERJUMP   =  2048.00000;
float FL_JUMPRELEASED   =  4096.00000;
float FL_FLASHLIGHT   =  8192.00000;
float FL_COMAMODE   =  16384.00000;
float FL_MOVECHAIN_ANGLE   =  32768.00000;
float FL_FIRERESIST   =  65536.00000;
float FL_FIREHEAL   =  131072.00000;
float FL_COLDRESIST   =  262144.00000;
float FL_COLDHEAL   =  524288.00000;
float FL_ARCHIVE_OVERRIDE   =  1048576.00000;
float FL_CLASS_DEPENDENT   =  2097152.00000;
float FL_SHIELDED   =  1.00000;
float FL_CAMERA_VIEW   =  2.00000;
float FL_SMALL   =  4.00000;
float FL_ALIVE   =  8.00000;
float FL_FAKE_WATER   =  16.00000;
float FL_SUMMONED   =  32.00000;
float FL_LEDGEHOLD   =  64.00000;
float FL_STONED   =  128.00000;
float MLS_MASKIN   =  7.00000;
float MLS_MASKOUT   =  248.00000;
float MLS_NONE   =  0.00000;
float MLS_FULLBRIGHT   =  1.00000;
float MLS_POWERMODE   =  2.00000;
float MLS_TORCH   =  3.00000;
float MLS_FIREFLICKER   =  4.00000;
float MLS_ABSLIGHT   =  7.00000;
float SCALE_TYPE_MASKIN   =  24.00000;
float SCALE_TYPE_MASKOUT   =  231.00000;
float SCALE_TYPE_UNIFORM   =  0.00000;
float SCALE_TYPE_XYONLY   =  8.00000;
float SCALE_TYPE_ZONLY   =  16.00000;
float SCALE_ORIGIN_MASKIN   =  96.00000;
float SCALE_ORIGIN_MASKOUT   =  159.00000;
float SCALE_ORIGIN_CENTER   =  0.00000;
float SCALE_ORIGIN_BOTTOM   =  32.00000;
float SCALE_ORIGIN_TOP   =  64.00000;
float DRF_TRANSLUCENT   =  128.00000;
float AFL_CUBE_RIGHT   =  1.00000;
float AFL_CUBE_LEFT   =  2.00000;
float AFL_TORCH   =  4.00000;
float AFL_SUPERHEALTH   =  8.00000;
float MOVETYPE_NONE   =  0.00000;
float MOVETYPE_WALK   =  3.00000;
float MOVETYPE_STEP   =  4.00000;
float MOVETYPE_FLY   =  5.00000;
float MOVETYPE_TOSS   =  6.00000;
float MOVETYPE_PUSH   =  7.00000;
float MOVETYPE_NOCLIP   =  8.00000;
float MOVETYPE_FLYMISSILE   =  9.00000;
float MOVETYPE_BOUNCE   =  10.00000;
float MOVETYPE_BOUNCEMISSILE   =  11.00000;
float MOVETYPE_PUSHPULL   =  13.00000;
float PARTICLETYPE_STATIC   =  0.00000;
float PARTICLETYPE_GRAV   =  1.00000;
float PARTICLETYPE_FASTGRAV   =  2.00000;
float PARTICLETYPE_SLOWGRAV   =  3.00000;
float PARTICLETYPE_FIRE   =  4.00000;
float PARTICLETYPE_EXPLODE   =  5.00000;
float PARTICLETYPE_EXPLODE2   =  6.00000;
float PARTICLETYPE_BLOB   =  7.00000;
float PARTICLETYPE_BLOB2   =  8.00000;
float PARTICLETYPE_RAIN   =  9.00000;
float PARTICLETYPE_C_EXPLODE   =  10.00000;
float PARTICLETYPE_C_EXPLODE2   =  11.00000;
float PARTICLETYPE_SPIT   =  12.00000;
float PARTICLETYPE_FIREBALL   =  13.00000;
float PARTICLETYPE_ICE   =  14.00000;
float PARTICLETYPE_SPELL   =  15.00000;
float HULL_IMPLICIT   =  0.00000;
float HULL_POINT   =  1.00000;
float HULL_PLAYER   =  2.00000;
float HULL_SCORPION   =  3.00000;
float HULL_CROUCH   =  4.00000;
float HULL_HYDRA   =  5.00000;
float HULL_GOLEM   =  6.00000;
float HULL_OLD   =  0.00000;
float HULL_SMALL   =  1.00000;
float HULL_NORMAL   =  2.00000;
float HULL_BIG   =  3.00000;
float SOLID_NOT   =  0.00000;
float SOLID_TRIGGER   =  1.00000;
float SOLID_BBOX   =  2.00000;
float SOLID_SLIDEBOX   =  3.00000;
float SOLID_BSP   =  4.00000;
float SOLID_PHASE   =  5.00000;
float RANGE_MELEE   =  0.00000;
float RANGE_NEAR   =  1.00000;
float RANGE_MID   =  2.00000;
float RANGE_FAR   =  3.00000;
float DEAD_NO   =  0.00000;
float DEAD_DYING   =  1.00000;
float DEAD_DEAD   =  2.00000;
float DEAD_RESPAWNABLE   =  3.00000;
float DAMAGE_NO   =  0.00000;
float DAMAGE_YES   =  1.00000;
float DAMAGE_NO_GRENADE   =  2.00000;
float INV_NONE   =  0.00000;
float INV_TORCH   =  1.00000;
float INV_HP_BOOST   =  2.00000;
float INV_SUPER_HP_BOOST   =  3.00000;
float INV_MANA_BOOST   =  4.00000;
float INV_TELEPORT   =  5.00000;
float INV_TOME   =  6.00000;
float INV_SUMMON   =  7.00000;
float INV_MINE   =  8.00000;
float INV_GLYPH   =  9.00000;
float INV_HASTE   =  10.00000;
float INV_BLAST   =  11.00000;
float INV_POLYMORPH   =  12.00000;
float INV_MIRROR   =  13.00000;
float INV_CUBEOFFORCE   =  14.00000;
float INV_INVINCIBILITY   =  15.00000;
float RING_NONE   =  0.00000;
float RING_FLIGHT   =  1.00000;
float RING_WATER   =  2.00000;
float RING_ABSORPTION   =  4.00000;
float RING_REGENERATION   =  8.00000;
float RING_TURNING   =  16.00000;
float ART_NONE   =  0.00000;
float ART_HASTE   =  1.00000;
float ART_INVINCIBILITY   =  2.00000;
float ART_TOMEOFPOWER   =  4.00000;
float CLASS_NONE   =  0.00000;
float CLASS_PALADIN   =  1.00000;
float CLASS_CRUSADER   =  2.00000;
float CLASS_NECROMANCER   =  3.00000;
float CLASS_ASSASSIN   =  4.00000;
float MAX_HEALTH   =  200.00000;
float MODE_NORMAL   =  0.00000;
float MODE_CAMERA   =  1.00000;
float IT_WEAPON1   =  4096.00000;
float IT_WEAPON2   =  1.00000;
float IT_WEAPON3   =  2.00000;
float IT_WEAPON4   =  4.00000;
float IT_TESTWEAP   =  8.00000;
float IT_WEAPON4_1   =  16.00000;
float IT_WEAPON4_2   =  32.00000;
float IT_GAUNTLETS   =  4096.00000;
float IT_AXE   =  4096.00000;
float IT_SHOTGUN   =  1.00000;
float IT_SUPER_SHOTGUN   =  2.00000;
float IT_NAILGUN   =  4.00000;
float IT_SUPER_NAILGUN   =  8.00000;
float IT_GRENADE_LAUNCHER   =  16.00000;
float IT_ROCKET_LAUNCHER   =  32.00000;
float IT_LIGHTNING   =  64.00000;
float IT_EXTRA_WEAPON   =  128.00000;
float IT_ARMOR1   =  8192.00000;
float IT_ARMOR2   =  16384.00000;
float IT_ARMOR3   =  32768.00000;
float IT_SUPERHEALTH   =  65536.00000;
float IT_INVISIBILITY   =  524288.00000;
float IT_INVULNERABILITY   =  1048576.00000;
float IT_SUIT   =  2097152.00000;
float IT_QUAD   =  4194304.00000;
float FLIGHT_TIME   =  30.00000;
float WATER_TIME   =  30.00000;
float ABSORPTION_TIME   =  30.00000;
float REGEN_TIME   =  30.00000;
float TURNING_TIME   =  30.00000;
float HASTE_TIME   =  15.00000;
float TOME_TIME   =  30.00000;
float RESPAWN_TIME   =  30.00000;
float PUNCHDGR_DAMAGE   =  8.00000;
float PUNCHDGR_ADD_DAMAGE   =  2.00000;
float SICKLE_DAMAGE   =  8.00000;
float SICKLE_ADD_DAMAGE   =  2.00000;
float GLYPH_BASE_DAMAGE   =  100.00000;
float GLYPH_ADD_DAMAGE   =  20.00000;
float BLAST_RADIUS   =  150.00000;
float BLASTDAMAGE   =  4.00000;
float DMG_ARCHER_PUNCH   =  4.00000;
float DMG_MUMMY_PUNCH   =  8.00000;
float DMG_MUMMY_BITE   =  2.00000;
float THINGTYPE_GREYSTONE   =  1.00000;
float THINGTYPE_WOOD   =  2.00000;
float THINGTYPE_METAL   =  3.00000;
float THINGTYPE_FLESH   =  4.00000;
float THINGTYPE_FIRE   =  5.00000;
float THINGTYPE_CLAY   =  6.00000;
float THINGTYPE_LEAVES   =  7.00000;
float THINGTYPE_HAY   =  8.00000;
float THINGTYPE_BROWNSTONE   =  9.00000;
float THINGTYPE_CLOTH   =  10.00000;
float THINGTYPE_WOOD_LEAF   =  11.00000;
float THINGTYPE_WOOD_METAL   =  12.00000;
float THINGTYPE_WOOD_STONE   =  13.00000;
float THINGTYPE_METAL_STONE   =  14.00000;
float THINGTYPE_METAL_CLOTH   =  15.00000;
float THINGTYPE_WEBS   =  16.00000;
float THINGTYPE_GLASS   =  17.00000;
float CONTENT_EMPTY   =  -1.00000;
float CONTENT_SOLID   =  -2.00000;
float CONTENT_WATER   =  -3.00000;
float CONTENT_SLIME   =  -4.00000;
float CONTENT_LAVA   =  -5.00000;
float CONTENT_SKY   =  -6.00000;
float STATE_TOP   =  0.00000;
float STATE_BOTTOM   =  1.00000;
float STATE_UP   =  2.00000;
float STATE_DOWN   =  3.00000;
float STATE_MOVING   =  4.00000;
vector VEC_ORIGIN   =  '0.00000 0.00000 0.00000';
vector VEC_HULL_MIN   =  '-16.00000 -16.00000 -24.00000';
vector VEC_HULL_MAX   =  '16.00000 16.00000 32.00000';
vector VEC_HULL2_MIN   =  '-32.00000 -32.00000 -24.00000';
vector VEC_HULL2_MAX   =  '32.00000 32.00000 64.00000';
float SVC_TEMPENTITY   =  23.00000;
float SVC_KILLEDMONSTER   =  27.00000;
float SVC_FOUNDSECRET   =  28.00000;
float SVC_INTERMISSION   =  30.00000;
float SVC_FINALE   =  31.00000;
float SVC_CDTRACK   =  32.00000;
float SVC_SELLSCREEN   =  33.00000;
float SVC_SET_VIEW_FLAGS   =  40.00000;
float SVC_CLEAR_VIEW_FLAGS   =  41.00000;
float CE_RAIN   =  1.00000;
float CE_FOUNTAIN   =  2.00000;
float CE_QUAKE   =  3.00000;
float CE_WHITE_SMOKE   =  4.00000;
float CE_BLUESPARK   =  5.00000;
float CE_YELLOWSPARK   =  6.00000;
float CE_SM_CIRCLE_EXP   =  7.00000;
float CE_BG_CIRCLE_EXP   =  8.00000;
float CE_SM_WHITE_FLASH   =  9.00000;
float CE_WHITE_FLASH   =  10.00000;
float CE_YELLOWRED_FLASH   =  11.00000;
float CE_BLUE_FLASH   =  12.00000;
float CE_SM_BLUE_FLASH   =  13.00000;
float CE_RED_FLASH   =  14.00000;
float CE_SM_EXPLOSION   =  15.00000;
float CE_LG_EXPLOSION   =  16.00000;
float CE_FLOOR_EXPLOSION   =  17.00000;
float CE_RIDER_DEATH   =  18.00000;
float CE_BLUE_EXPLOSION   =  19.00000;
float CE_GREEN_SMOKE   =  20.00000;
float CE_GREY_SMOKE   =  21.00000;
float CE_RED_SMOKE   =  22.00000;
float CE_SLOW_WHITE_SMOKE   =  23.00000;
float CE_REDSPARK   =  24.00000;
float CE_GREENSPARK   =  25.00000;
float TE_SPIKE   =  0.00000;
float TE_SUPERSPIKE   =  1.00000;
float TE_GUNSHOT   =  2.00000;
float TE_EXPLOSION   =  3.00000;
float TE_TAREXPLOSION   =  4.00000;
float TE_LIGHTNING1   =  5.00000;
float TE_LIGHTNING2   =  6.00000;
float TE_WIZSPIKE   =  7.00000;
float TE_KNIGHTSPIKE   =  8.00000;
float TE_LIGHTNING3   =  9.00000;
float TE_LAVASPLASH   =  10.00000;
float TE_TELEPORT   =  11.00000;
float TE_STREAM_CHAIN   =  25.00000;
float TE_STREAM_SUNSTAFF1   =  26.00000;
float TE_STREAM_SUNSTAFF2   =  27.00000;
float TE_STREAM_LIGHTNING   =  28.00000;
float STREAM_ATTACHED   =  16.00000;
float STREAM_TRANSLUCENT   =  32.00000;
float CHAN_AUTO   =  0.00000;
float CHAN_WEAPON   =  1.00000;
float CHAN_VOICE   =  2.00000;
float CHAN_ITEM   =  3.00000;
float CHAN_BODY   =  4.00000;
float ATTN_NONE   =  0.00000;
float ATTN_NORM   =  1.00000;
float ATTN_IDLE   =  2.00000;
float ATTN_STATIC   =  3.00000;
float UPDATE_GENERAL   =  0.00000;
float UPDATE_STATIC   =  1.00000;
float UPDATE_BINARY   =  2.00000;
float UPDATE_TEMP   =  3.00000;
float EF_BRIGHTFIELD   =  1.00000;
float EF_MUZZLEFLASH   =  2.00000;
float EF_BRIGHTLIGHT   =  4.00000;
float EF_TORCHLIGHT   =  6.00000;
float EF_DIMLIGHT   =  8.00000;
float EF_DARKLIGHT   =  16.00000;
float EF_DARKFIELD   =  32.00000;
float EF_LIGHT   =  64.00000;
float EF_NODRAW   =  128.00000;
float MSG_BROADCAST   =  0.00000;
float MSG_ONE   =  1.00000;
float MSG_ALL   =  2.00000;
float MSG_INIT   =  3.00000;
float STEP_HEIGHT   =  18.00000;
float AI_DECIDE   =  0.00000;
float AI_STAND   =  1.00000;
float AI_WALK   =  2.00000;
float AI_CHARGE   =  4.00000;
float AI_WANDER   =  8.00000;
float AI_MELEE_ATTACK   =  16.00000;
float AI_MISSILE_ATTACK   =  32.00000;
float AI_MISSILE_REATTACK   =  64.00000;
float AI_PAIN   =  128.00000;
float AI_PAIN_CLOSE   =  256.00000;
float AI_PAIN_FAR   =  512.00000;
float AI_DEAD   =  1024.00000;
float AI_TURNLOOK   =  2048.00000;
float AI_DEAD_GIB   =  4096.00000;
float AI_DEAD_TWITCH   =  8192.00000;
float AF_NORMAL   =  0.00000;
float AF_BEGINNING   =  1.00000;
float AF_END   =  2.00000;
float CHUNK_MAX   =  30.00000;
float MAX_LEVELS   =  10.00000;
float SFL_EPISODE_1   =  1.00000;
float SFL_EPISODE_2   =  2.00000;
float SFL_EPISODE_3   =  4.00000;
float SFL_EPISODE_4   =  8.00000;
float SFL_NEW_UNIT   =  16.00000;
float SFL_NEW_EPISODE   =  32.00000;
float SFL_CROSS_TRIGGER_1   =  256.00000;
float SFL_CROSS_TRIGGER_2   =  512.00000;
float SFL_CROSS_TRIGGER_3   =  1024.00000;
float SFL_CROSS_TRIGGER_4   =  2048.00000;
float SFL_CROSS_TRIGGER_5   =  4096.00000;
float SFL_CROSS_TRIGGER_6   =  8192.00000;
float SFL_CROSS_TRIGGER_7   =  16384.00000;
float SFL_CROSS_TRIGGER_8   =  32768.00000;
float SFL_CROSS_TRIGGERS   =  65280.00000;
float attck_cnt   =  0.00000;
float WF_NORMAL_ADVANCE   =  0.00000;
float WF_CYCLE_STARTED   =  1.00000;
float WF_CYCLE_WRAPPED   =  2.00000;
float WF_LAST_FRAME   =  3.00000;
float WORLDTYPE_CASTLE   =  0.00000;
float WORLDTYPE_EGYPT   =  1.00000;
float WORLDTYPE_MESO   =  2.00000;
float WORLDTYPE_ROMAN   =  3.00000;
float IMP   =  1.00000;
float ARCHER   =  2.00000;
float WIZARD   =  4.00000;
float SCORPION   =  8.00000;
float SPIDER   =  16.00000;
float ONDEATH   =  32.00000;
float QUIET   =  64.00000;
float TRIGGERONLY   =  128.00000;
float NO_JUMP   =  4.00000;
float PLAY_DEAD   =  8.00000;
float NO_DROP   =  32.00000;
float FLOATING   =  1.00000;
float BARREL_DOWNHILL   =  1.00000;
float BARREL_NO_DROP   =  2.00000;
float ON_SIDE   =  4.00000;
float BARREL_SINK   =  8.00000;
float BARREL_UNBREAKABLE   =  16.00000;
float BARREL_NORMAL   =  32.00000;
float BARREL_EXPLODING   =  64.00000;
float BARREL_INDESTRUCTIBLE   =  128.00000;
float GRADUAL   =  32.00000;
float TOGGLE_REVERSE   =  64.00000;
float KEEP_START   =  128.00000;
float NO_RESPAWN   =  0.00000;
float RESPAWN   =  1.00000;
float ARTIFACT_TORCH   =  1.00000;
float ARTIFACT_HP_BOOST   =  2.00000;
float ARTIFACT_SUPER_HP_BOOST   =  3.00000;
float ARTIFACT_MANA_BOOST   =  4.00000;
float ARTIFACT_TELEPORT   =  5.00000;
float ARTIFACT_TOME   =  6.00000;
float ARTIFACT_SUMMON   =  7.00000;
float ARTIFACT_MINE   =  8.00000;
float ARTIFACT_GLYPH   =  9.00000;
float ARTIFACT_HASTE   =  10.00000;
float ARTIFACT_BLAST   =  11.00000;
float ARTIFACT_POLYMORPH   =  12.00000;
float ARTIFACT_MIRROR   =  13.00000;
float ARTIFACT_CUBEOFFORCE   =  14.00000;
float ARTIFACT_INVINCIBILITY   =  15.00000;
float ARTIFACT_XRAY   =  16.00000;
float ARTIFACT_INVISIBILITY   =  17.00000;
float ARTIFACT_GROWTH   =  18.00000;

void makevectors(vector a) : 1;

void setorigin(entity a, vector b) : 2;

void setmodel(entity a, string b) : 3;

void setsize(entity a, vector b, vector c) : 4;

void lightstylestatic(float a, float b) : 5;

void debugbreak() : 6;

float random() : 7;

void sound(entity a, float b, string c, float d, float e) : 8;

vector normalize(vector a) : 9;

void error(string a) : 10;

void objerror(string a) : 11;

float vlen(vector a) : 12;

float vectoyaw(vector a) : 13;

entity spawn() : 14;

void remove(entity a) : 15;

void traceline(vector a, vector b, float c, entity d) : 16;

entity checkclient() : 17;

entity find(entity a, .string b, string c) : 18;

string precache_sound(string a) : 19;

string precache_model(string a) : 20;

void stuffcmd(entity a, string b) : 21;

entity findradius(vector a, float b) : 22;

void bprint(string a) : 23;

void sprint(entity a, string b) : 24;

void dprint(string a) : 25;

string ftos(float a) : 26;

string vtos(vector a) : 27;

void coredump() : 28;

void traceon() : 29;

void traceoff() : 30;

void eprint(entity a) : 31;

float walkmove(float a, float b, float c) : 32;

void tracearea(vector a, vector b, vector c, vector d, float e, entity f) : 33;

float droptofloor() : 34;

void lightstyle(float a, string b) : 35;

float rint(float a) : 36;

float floor(float a) : 37;

float ceil(float a) : 38;

float checkbottom(entity a) : 40;

float pointcontents(vector a) : 41;

void particle2(vector a, vector b, vector c, float d, float e, float f) : 42;

float fabs(float a) : 43;

vector aim(entity a, vector b, float c) : 44;

float cvar(string a) : 45;

void localcmd(string a) : 46;

entity nextent(entity a) : 47;

void particle(vector a, vector b, float c, float d) : 48;

float ChangeYaw() : 49;

float vhlen(vector a) : 50;

vector vectoangles(vector a) : 51;

void WriteByte(float a, float b) : 52;

void WriteChar(float a, float b) : 53;

void WriteShort(float a, float b) : 54;

void WriteLong(float a, float b) : 55;

void WriteCoord(float a, float b) : 56;

void WriteAngle(float a, float b) : 57;

void WriteString(float a, string b) : 58;

void WriteEntity(float a, entity b) : 59;

void dprintf(string a, float b) : 60;

float cos(float a) : 61;

float sin(float a) : 62;

float AdvanceFrame(float a, float b) : 63;

void dprintv(string a, vector b) : 64;

float RewindFrame(float a, float b) : 65;

void setclass(entity a, float b) : 66;

void movetogoal(float a) : 67;

string precache_file(string a) : 68;

void makestatic(entity a) : 69;

void changelevel(string a, string b) : 70;

float lightstylevalue(float a) : 71;

void cvar_set(string a, string b) : 72;

void centerprint(entity a, string b) : 73;

void ambientsound(vector a, string b, float c, float d) : 74;

string precache_model2(string a) : 75;

string precache_sound2(string a) : 76;

string precache_file2(string a) : 77;

void setspawnparms(entity a) : 78;

void plaque_draw(string a) : 79;

void rain_go(vector a, vector b, vector c, vector d, float e, float f) : 80;

void particleexplosion(vector a, float b, float c, float d) : 81;

float movestep(float a, float b, float c, float d) : 82;

float advanceweaponframe(float a, float b) : 83;

float sqrt(float a) : 84;

void particle3(vector a, vector b, float c, float d, float e) : 85;

void particle4(vector a, float b, float c, float d, float e) : 86;

void setpuzzlemodel(entity a, string b) : 87;

float starteffect(...) : 88;

float endeffect(float a, float b) : 89;
