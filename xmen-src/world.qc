
void() InitBodyQue;


void() main =
{
	dprint ("main function\n");

// these are just commands the the prog compiler to copy these files

	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	precache_file ("demo1.dem");
	precache_file ("demo2.dem");
	precache_file ("demo3.dem");

//
// these are all of the lumps from the cached.ls files
//
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");

	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");

	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");

	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");

	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");

	precache_file ("gfx/mp_menu.lmp");

	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");

	precache_file ("gfx/sell.lmp");

	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

// sounds loaded by C code
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");

// shareware
	precache_file ("maps/start.bsp");

	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");

// registered
	precache_file2 ("gfx/pop.lmp");

	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
};


entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void() worldspawn =
{
	lastspawn = world;
	InitBodyQue ();

	num_clients = 0;

// custom map attributes
	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");

   deathmatch = cvar("deathmatch");

   executable = "dosQuake";
   if (cvar("temp1") & 1)
      executable = "glQuake";

// the area based ambient sounds MUST be the first precache_sounds

// player precaches
	W_Precache ();			// get weapon precaches

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land1.wav");			// player landing
   precache_sound ("player/land3.wav");      // player hurt landing
   precache_sound ("player/land4.wav");      // player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death
   precache_sound ("player/h2ojump.wav");
   precache_sound ("player/what_1.wav");     // parallize sound

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");
   precache_sound ("items/protect.wav");
   precache_sound ("cannon/takeoff.wav");

   precache_sound ("doors/airdoor2.wav");
   precache_sound ("items/inv1.wav");

	precache_sound ("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

// ax sounds
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming

// X-Men: id sounds used in weapons (soon to be replaced)
   precache_sound ("enforcer/enfire.wav");
   precache_sound ("enforcer/enfstop.wav");
// end

// X-Men sounds
   precache_sound ("generic/punch1.wav");
   precache_sound ("generic/punch2.wav");
   precache_sound ("generic/punch3.wav");

   precache_sound ("misc/snicker1.wav");     // GOD mode laugh

   if (cvar("deathmatch") || cvar("coop")) {
      precache_sound ("angel/flap1.wav");
      precache_sound ("angel/flap2.wav");
      precache_sound ("angel/flap3.wav");
      precache_sound ("angel/flap4.wav");
      precache_sound ("angel/flap5.wav");
      precache_sound ("angel/flap6.wav");

      precache_sound ("wizard/hit.wav");     // used by c code
      precache_sound ("hknight/slash1.wav");

      precache_sound ("doors/stndr1.wav");
      precache_sound ("boss1/throw.wav");
      precache_sound ("generic/swing1.wav");
      precache_sound ("generic/frozen1.wav");
      precache_sound ("zombie/z_hit.wav");
      precache_sound ("cannon/flyloop.wav");
      precache_sound ("cannon/takeoff.wav");
   }

    precache_sound ("weapons/guidfire.wav");         // guided missiles
    precache_sound ("weapons/chnfire5.wav");         // chaingun
    precache_sound ("weapons/shotfir6.wav");
    precache_sound ("weapons/flame.wav");
    precache_sound ("weapons/f_start.wav");
    precache_sound ("weapons/flamball.wav");
    precache_sound ("weapons/reload.wav");
    precache_sound ("weapons/prox1.wav");
    precache_sound ("weapons/prox2.wav");
    precache_sound ("weapons/mega.wav");
    precache_sound ("weapons/m_start.wav");

    // skeleton
    precache_sound ("zombie/idle_w2.wav");
    precache_sound ("skeleton/crunch.wav");

    // character sounds used during deathmatch
    precache_sound ("storm/w_attack.wav");
    precache_sound ("storm/l_attack.wav");

    // deathmatch sounds
    precache_sound ("demon/dhit2.wav");

    // character/deathmatch sounds
    precache_sound ("voice/male/pain1.wav");
    precache_sound ("voice/male/pain2.wav");
    precache_sound ("voice/male/pain3.wav");
    precache_sound ("voice/male/pain4.wav");
    precache_sound ("voice/male/pain5.wav");
    precache_sound ("voice/male/pain6.wav");
    precache_sound ("voice/male/pain7.wav");

    precache_sound ("voice/male/diescrm1.wav");
    precache_sound ("voice/male/diescrm2.wav");
    precache_sound ("voice/male/diescrm3.wav");
    precache_sound ("voice/male/diescrm4.wav");
    precache_sound ("voice/male/diescrm5.wav");
    precache_sound ("voice/male/diescrm6.wav");

    precache_sound ("voice/female/scream1.wav");
    precache_sound ("voice/female/scream2.wav");
    precache_sound ("voice/female/scream3.wav");
    precache_sound ("voice/female/scream4.wav");
    precache_sound ("voice/female/scream5.wav");
    precache_sound ("voice/female/no1.wav");

    precache_sound ("voice/female/diescrm1.wav");
    precache_sound ("voice/female/diescrm2.wav");
    precache_sound ("voice/female/diescrm3.wav");
    precache_sound ("voice/female/diescrm4.wav");
    precache_sound ("voice/female/diescrm5.wav");
/*
    precache_sound ("voice/female/hey.wav");
    precache_sound ("voice/female/hey_you.wav");
    precache_sound ("voice/female/stop.wav");
    precache_sound ("voice/female/wait.wav");

    precache_sound ("voice/male/growl.wav");
    precache_sound ("voice/male/grrr.wav");
    precache_sound ("voice/male/intruder.wav");
    precache_sound ("voice/male/stop01.wav");
    precache_sound ("voice/male/uh-a.wav");
    precache_sound ("voice/male/what.wav");
    precache_sound ("voice/male/what_the.wav");
    precache_sound ("voice/male/youthere.wav");
*/
// temp only, used for proximity weapon
precache_sound ("items/damage2.wav");
// end

   precache_model ("progs/player.mdl");
   precache_model ("progs/cyborg.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");

   // skeleton gibs
	precache_model ("progs/gib01.mdl");
	precache_model ("progs/gib02.mdl");
	precache_model ("progs/gib03.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion

   precache_model ("progs/spike.mdl");

// X-Men: deathmatch models
   if (cvar("deathmatch") || cvar("coop")) {

      // Characters
      precache_model ("progs/dmskel.mdl");
      precache_model ("progs/dmwolvy.mdl");
      precache_model ("progs/dmstorm2.mdl");
      precache_model ("progs/dmice.mdl");
      precache_model ("progs/dmcyclop.mdl");
      precache_model ("progs/dmpsy.mdl");
      precache_model ("progs/dmangel.mdl");
      precache_model ("progs/dmbeast.mdl");
      precache_model ("progs/dmgambit.mdl");
      precache_model ("progs/dmbishop.mdl");
      precache_model ("progs/dmrogue.mdl");
      precache_model ("progs/dmcannon.mdl");
      precache_model ("progs/dmphoen.mdl");

      // deathmatch special power weapons
      precache_model ("progs/v_wol.mdl");
      precache_model ("progs/v_sto.mdl");
      precache_model ("progs/v_cyc.mdl");
      precache_model ("progs/v_psy.mdl");
      precache_model ("progs/v_ang.mdl");
      precache_model ("progs/v_bea.mdl");
      precache_model ("progs/v_gam.mdl");
      precache_model ("progs/v_ice.mdl");
      precache_model ("progs/v_bis.mdl");
      precache_model ("progs/v_rog.mdl");
      precache_model ("progs/v_can.mdl");
      precache_model ("progs/v_pho.mdl");

      // Other Models
      precache_model ("progs/claser1.mdl");
      precache_model ("progs/dart.mdl");
      precache_model ("progs/pow.mdl");
      precache_model ("progs/card.mdl");
      precache_model ("progs/iceshard.mdl");
      precache_model ("progs/iceblast.mdl");
      precache_model ("progs/bisblast.mdl");
      precache_model ("progs/beampart.mdl");
      precache_model ("progs/psyblast.mdl");

   }
// end

// X-Men: id models used in weapons
   precache_model ("progs/laser.mdl");
// end

// X-Men view (weapon) models
   precache_model ("progs/v_xfire1.mdl");
   precache_model ("progs/v_xrock.mdl");
   precache_model ("progs/v_xshot1.mdl");
   precache_model ("progs/v_xchain.mdl");
   precache_model ("progs/v_xorb.mdl");
   precache_model ("progs/v_xflame.mdl");
   precache_model ("progs/v_xshock.mdl");

   if (!deathmatch && !coop) {
      precache_model ("progs/v_xfist.mdl");
   }
   precache_model ("progs/v_xmega.mdl");
// end view models

   precache_model ("progs/atom1.mdl");
   precache_model ("progs/atom2.mdl");
   precache_model ("progs/atom3.mdl");
   precache_model ("progs/atomshot.mdl");

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing

	precache_model ("progs/missile.mdl");

	precache_model ("progs/backpack.mdl");

// X-Men models
    precache_model ("progs/blood.mdl");
    precache_model ("progs/missmall.mdl");
    precache_model ("progs/fl_th1.mdl");
//    precache_model ("progs/flame_sm.mdl");
    precache_model ("progs/fl_th2.mdl");
//    precache_model ("progs/fl_th3.mdl");
    precache_model ("progs/fl_th5.mdl");
    precache_model ("progs/fl_th6.mdl");
    precache_model ("progs/flamball.mdl");
    precache_model ("progs/skel.mdl");
    precache_model ("progs/orb1.mdl");
    precache_model ("progs/null.spr");
// END

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	lightstyle(0, "m");

	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");
    lightstyle(255, "a");

};

// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
//float   last_explode;
void() StartFrame =
{
        local entity laser;
        local entity orb;
        local entity old_laser;
        // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
        //local entity trav;
        local vector vect;
        // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
        //local float  vspeed, cont;

        teamplay = cvar("teamplay");
        skill = cvar("skill");
        framecount = framecount + 1;

        // check all lasers
        laser = find(world, classname, "laser");
        while (laser != world) {

            // 20060705 LordHavoc: made this check for stuck lasers also check if the laser has existed long enough to be sure that it has gotten stuck, not simply failed to move on the first frame (this fixes a bug where cyclops lasers disappear instantly if the shot entity is lower numbered than the cyclops entity)
            //if (laser.origin == laser.oldorigin) {
            if (laser.origin == laser.oldorigin && time > laser.cnt) {
               old_laser = laser;
               laser = find(laser, classname, "laser");

               remove(old_laser);
            }
            else {
               if (laser.last_touch != 0) {
/*
                             vect = normalize(laser.old_velocity);
                             vspeed = vlen(laser.old_velocity);

                             traceline(laser.origin - (laser.old_velocity * 0.5), laser.origin + laser.old_velocity, TRUE, laser);

                             laser.velocity = (GetReflectionVect(trace_endpos, vect, trace_plane_normal) * vspeed);
*/
                             laser.old_velocity = laser.velocity;
                             vect = normalize(laser.old_velocity);

                             laser.angles = vectoangles(vect);
                             laser.last_touch = 0;

               }

               laser.velocity_z = laser.old_velocity_z + cvar("sv_gravity")*frametime;

               laser.oldorigin = laser.origin;

               laser = find(laser, classname, "laser");
            }

        }

        // check orb for bounce
        orb = world;
        while ((orb = find(orb, classname, "orb")) != world) {
            if ((orb.velocity_z > 0) && (orb.old_velocity_z <= 0)) {
               orb.velocity_z = 300;
            }

            orb.old_velocity = orb.velocity;
        }

        // Ice shards too!

       laser = find(world, classname, "shard");
       while (laser != world)
       {
           if (laser.state)
           {
               laser.velocity_z = laser.velocity_z + cvar("sv_gravity")*frametime;
           }
           laser = find(laser, classname, "shard");
       }

};

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void() bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

void() InitBodyQue =
{
	// 20060704 LordHavoc: hushed a compiler warning by commenting out this code
	//local entity	e;

	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};


// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};


