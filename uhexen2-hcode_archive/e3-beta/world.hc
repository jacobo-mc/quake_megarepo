void  ()InitBodyQue;

void  ()main =  {
   dprint ("main function\n");
   precache_file ("progs.dat");
   precache_file ("gfx.wad");
   precache_file ("quake.rc");
   precache_file ("default.cfg");
   precache_file ("end1.bin");
   precache_file2 ("end2.bin");
   Precache_lmp ();
   precache_sound ("raven/menu1.wav");
   precache_sound ("raven/menu2.wav");
   precache_sound ("raven/menu3.wav");
   precache_sound ("misc/barmovup.wav");
   precache_sound ("misc/barmovdn.wav");
   precache_sound ("misc/invmove.wav");
   precache_sound ("misc/invuse.wav");
   precache_sound ("ambience/water1.wav");
   precache_sound ("ambience/wind2.wav");
   precache_file2 ("gfx/pop.lmp");
};

entity lastspawn;

void  ()worldspawn =  {
   lastspawn = world;
   InitBodyQue ();
   W_Precache ();
   Precache_wav ();
   Precache_Id_mdl ();
   Precache_mdl ();
   precache_model ("models/schunk1.mdl");
   precache_model ("models/schunk2.mdl");
   precache_model ("models/schunk3.mdl");
   precache_model ("models/schunk4.mdl");
   Precache_spr ();
   lightstyle (0.00000, "m");
   lightstyle (1.00000, "mmnmmommommnonmmonqnmmo");
   lightstyle (2.00000, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
   lightstyle (3.00000, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
   lightstyle (4.00000, "zzzzzzzzzzzz");
   lightstyle (5.00000, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");
   lightstyle (EF_TORCHLIGHT, "knmonqnmolm");
   lightstyle (7.00000, "mmmaaaabcdefgmmmmaaaammmaamm");
   lightstyle (8.00000, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
   lightstyle (9.00000, "aaaaaaaazzzzzzzz");
   lightstyle (10.00000, "mmamammmmammamamaaamammma");
   lightstyle (11.00000, "abcdefghijklmnopqrrqponmlkjihgfedcba");
   lightstyle (25.00000, "z");
   lightstyle (26.00000, "2jklmnooppqqrrrrqqppoonmlkj");
   lightstyle (27.00000, "wvtwyzxvtxwyzwv");
   lightstyle (28.00000, "jilghmnohjljhfpjnjgpohkjhioomh");
   lightstyle (63.00000, "a");
   StringsInit ();
};


void  ()StartFrame =  {
   teamplay = cvar ("teamplay");
   skill = cvar ("skill");
   framecount = (framecount + 1.00000);
};

entity bodyque_head;

void  ()bodyque =  {
};


void  ()InitBodyQue =  {
local entity e;
   bodyque_head = spawn ();
   bodyque_head.classname = "bodyque";
   bodyque_head.owner = spawn ();
   bodyque_head.owner.classname = "bodyque";
   bodyque_head.owner.owner = spawn ();
   bodyque_head.owner.owner.classname = "bodyque";
   bodyque_head.owner.owner.owner = spawn ();
   bodyque_head.owner.owner.owner.classname = "bodyque";
   bodyque_head.owner.owner.owner.owner = bodyque_head;
};


void  (entity ent)CopyToBodyQue =  {
   bodyque_head.angles = ent.angles;
   bodyque_head.model = ent.model;
   bodyque_head.modelindex = ent.modelindex;
   bodyque_head.frame = ent.frame;
   bodyque_head.colormap = ent.colormap;
   bodyque_head.movetype = ent.movetype;
   bodyque_head.velocity = ent.velocity;
   bodyque_head.flags = 0.00000;
   setorigin (bodyque_head, ent.origin);
   setsize (bodyque_head, ent.mins, ent.maxs);
   bodyque_head = bodyque_head.owner;
};

