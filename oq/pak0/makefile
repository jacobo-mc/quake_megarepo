#
# Change QUTILSDIR and UTILSDIR to match your setup
#

QUTILSDIR = ../utils/qutils/bin
UTILSDIR  = ../utils/bin
GAMEDIR   = ../openquartz/id1

QBSP     = $(QUTILSDIR)/qbsp
VIS      = $(QUTILSDIR)/vis
LIGHT    = $(QUTILSDIR)/light
QCC      = $(QUTILSDIR)/qcc
MODELGEN = $(QUTILSDIR)/modelgen
SPRGEN   = $(QUTILSDIR)/sprgen
QLUMPY   = $(QUTILSDIR)/qlumpy
QFILES   = $(QUTILSDIR)/qfiles

PAR      = $(UTILSDIR)/par
TYRLITE  = $(UTILSDIR)/tyrlite

# top-level targets
ALLPAKS  = pak0.pak pak1.pak pak2.pak pak3.pak pak4.pak

all: $(ALLPAKS)

# installs the compiled files into the game directory
install : all
	mkdir --parents $(GAMEDIR)
	cp $(ALLPAKS) $(GAMEDIR)
	cp default.cfg $(GAMEDIR)
	mkdir --parents $(GAMEDIR)/gfx
	cp gfx/*.tga $(GAMEDIR)/gfx
	mkdir --parents $(GAMEDIR)/gfx/env
	cp gfx/env/*.tga $(GAMEDIR)/gfx/env
	mkdir --parents $(GAMEDIR)/maps
	cp maps/*.rtlights $(GAMEDIR)/maps


extra-maps : \
    maps/dm2ish.bsp maps/dm3ish.bsp maps/dm4ish.bsp     \
    maps/e1m2ish.bsp maps/q3dm6ish.bsp \
    maps/ukpak4.bsp


# be careful, don't erase anything we can't generate
clean:
	$(RM) $(ALLPAKS)
	$(RM) progs.dat qwprogs.dat qwdefs.h progdefs.h
	$(RM) tyrlite.log
	$(RM) gfx/*.lmp gfx.wad
	$(RM) maps/*.h1 maps/*.h2 maps/*.pts maps/*.prt
	$(RM) $(addprefix maps/,b_batt0.bsp b_batt1.bsp)
	$(RM) $(addprefix maps/,b_bh10.bsp b_bh25.bsp b_bh100.bsp)
	$(RM) $(addprefix maps/,b_explob.bsp b_exbox2.bsp)
	$(RM) $(addprefix maps/,b_nail0.bsp b_nail1.bsp)
	$(RM) $(addprefix maps/,b_rock0.bsp b_rock1.bsp)
	$(RM) $(addprefix maps/,b_shell0.bsp b_shell1.bsp)
	$(RM) $(addprefix maps/,void4.bsp void5.bsp void6.bsp)
	$(RM) $(addprefix maps/,vtest.bsp box.bsp am1.bsp)
	$(RM) $(addprefix maps/,bunkers.bsp house.bsp nsa.bsp)
	$(RM) $(addprefix maps/,office.bsp start.bsp q3dm6ish.bsp)
	$(RM) $(addprefix maps/,elbow.bsp devourer.bsp rpgdm1.bsp)
	$(RM) $(addprefix maps/,d1.bsp d2.bsp d3.bsp d4.bsp)
	$(RM) $(addprefix maps/,d5.bsp d6.bsp d7.bsp d8.bsp)
	$(RM) $(addprefix maps/,q1start.bsp)
	$(RM) $(addprefix maps/,e1m1.bsp e1m2.bsp e1m3.bsp e1m4.bsp)
	$(RM) $(addprefix maps/,e1m5.bsp e1m6.bsp e1m7.bsp e1m8.bsp)
	$(RM) $(addprefix maps/,e2m1.bsp e2m2.bsp e2m3.bsp e2m4.bsp)
	$(RM) $(addprefix maps/,e2m5.bsp e2m6.bsp e2m7.bsp)
	$(RM) $(addprefix maps/,e3m1.bsp e3m2.bsp e3m3.bsp e3m4.bsp)
	$(RM) $(addprefix maps/,e3m5.bsp e3m6.bsp e3m7.bsp)
	$(RM) $(addprefix maps/,e4m1.bsp e4m2.bsp e4m3.bsp e4m4.bsp)
	$(RM) $(addprefix maps/,e4m5.bsp e4m6.bsp e4m7.bsp e4m8.bsp)
	$(RM) $(addprefix maps/,end.bsp)
	$(RM) $(addprefix maps/,e2m10.bsp)
	$(RM) $(addprefix progs/,b_g_key.mdl m_g_key.mdl w_g_key.mdl)
	$(RM) $(addprefix progs/,b_s_key.mdl m_s_key.mdl w_s_key.mdl)
	$(RM) $(addprefix progs/,end1.mdl end2.mdl end3.mdl end4.mdl)
	$(RM) $(addprefix progs/,gib1.mdl gib2.mdl gib3.mdl zom_gib.mdl)
	$(RM) $(addprefix progs/,eyes.mdl flame.mdl flame2.mdl lavaball.mdl)
	$(RM) $(addprefix progs/,laser.mdl armor.mdl backpack.mdl teleport.mdl)
	$(RM) $(addprefix progs/,quaddama.mdl invisibl.mdl invulner.mdl suit.mdl)
	$(RM) $(addprefix progs/,g_light.mdl bolt.mdl bolt2.mdl bolt3.mdl)
	$(RM) $(addprefix progs/,g_nail.mdl g_nail2.mdl s_spike.mdl spike.mdl)
	$(RM) $(addprefix progs/,g_rock.mdl g_rock2.mdl grenade.mdl missile.mdl)
	$(RM) $(addprefix progs/,g_shot.mdl)
	$(RM) $(addprefix progs/,h_player.mdl)
	$(RM) $(addprefix progs/,h_dog.mdl h_guard.mdl h_knight.mdl h_zombie.mdl)
	$(RM) $(addprefix progs/,wizard.mdl h_wizard.mdl)
	$(RM) $(addprefix progs/,s_bubble.spr s_explod.spr s_light.spr)

#
# PAK0_CONTENTS is what goes into pak0.pak
#
# It contains the "core" content--content that is shared between single-player
# and multi-player versions of the game
#
PAK0_CONTENTS += default.cfg
PAK0_CONTENTS += end.bin
PAK0_CONTENTS += end2.bin
PAK0_CONTENTS += gfx.wad
PAK0_CONTENTS += gfx/bigbox.lmp
PAK0_CONTENTS += gfx/box_bl.lmp
PAK0_CONTENTS += gfx/box_bm.lmp
PAK0_CONTENTS += gfx/box_br.lmp
PAK0_CONTENTS += gfx/box_ml.lmp
PAK0_CONTENTS += gfx/box_mm.lmp
PAK0_CONTENTS += gfx/box_mm2.lmp
PAK0_CONTENTS += gfx/box_mr.lmp
PAK0_CONTENTS += gfx/box_tl.lmp
PAK0_CONTENTS += gfx/box_tm.lmp
PAK0_CONTENTS += gfx/box_tr.lmp
PAK0_CONTENTS += gfx/colormap.lmp
PAK0_CONTENTS += gfx/complete.lmp
PAK0_CONTENTS += gfx/conback.lmp
PAK0_CONTENTS += gfx/dim_drct.lmp
PAK0_CONTENTS += gfx/dim_ipx.lmp
PAK0_CONTENTS += gfx/dim_modm.lmp
PAK0_CONTENTS += gfx/dim_mult.lmp
PAK0_CONTENTS += gfx/dim_tcp.lmp
PAK0_CONTENTS += gfx/finale.lmp
PAK0_CONTENTS += gfx/help0.lmp
PAK0_CONTENTS += gfx/help1.lmp
PAK0_CONTENTS += gfx/help2.lmp
PAK0_CONTENTS += gfx/help3.lmp
PAK0_CONTENTS += gfx/help4.lmp
PAK0_CONTENTS += gfx/help5.lmp
PAK0_CONTENTS += gfx/inter.lmp
PAK0_CONTENTS += gfx/loading.lmp
PAK0_CONTENTS += gfx/mainmenu.lmp
PAK0_CONTENTS += gfx/menudot1.lmp
PAK0_CONTENTS += gfx/menudot2.lmp
PAK0_CONTENTS += gfx/menudot3.lmp
PAK0_CONTENTS += gfx/menudot4.lmp
PAK0_CONTENTS += gfx/menudot5.lmp
PAK0_CONTENTS += gfx/menudot6.lmp
PAK0_CONTENTS += gfx/menuplyr.lmp
PAK0_CONTENTS += gfx/mp_menu.lmp
PAK0_CONTENTS += gfx/netmen1.lmp
PAK0_CONTENTS += gfx/netmen2.lmp
PAK0_CONTENTS += gfx/netmen3.lmp
PAK0_CONTENTS += gfx/netmen4.lmp
PAK0_CONTENTS += gfx/netmen5.lmp
PAK0_CONTENTS += gfx/p_load.lmp
PAK0_CONTENTS += gfx/p_multi.lmp
PAK0_CONTENTS += gfx/p_option.lmp
PAK0_CONTENTS += gfx/p_save.lmp
PAK0_CONTENTS += gfx/palette.lmp
PAK0_CONTENTS += gfx/pause.lmp
PAK0_CONTENTS += gfx/pop.lmp
PAK0_CONTENTS += gfx/qplaque.lmp
PAK0_CONTENTS += gfx/ranking.lmp
PAK0_CONTENTS += gfx/sell.lmp
PAK0_CONTENTS += gfx/sp_menu.lmp
PAK0_CONTENTS += gfx/ttl_cstm.lmp
PAK0_CONTENTS += gfx/ttl_main.lmp
PAK0_CONTENTS += gfx/ttl_sgl.lmp
PAK0_CONTENTS += gfx/vidmodes.lmp
PAK0_CONTENTS += maps/b_batt0.bsp
PAK0_CONTENTS += maps/b_batt1.bsp
PAK0_CONTENTS += maps/b_bh10.bsp
PAK0_CONTENTS += maps/b_bh100.bsp
PAK0_CONTENTS += maps/b_bh25.bsp
PAK0_CONTENTS += maps/b_exbox2.bsp
PAK0_CONTENTS += maps/b_explob.bsp
PAK0_CONTENTS += maps/b_nail0.bsp
PAK0_CONTENTS += maps/b_nail1.bsp
PAK0_CONTENTS += maps/b_rock0.bsp
PAK0_CONTENTS += maps/b_rock1.bsp
PAK0_CONTENTS += maps/b_shell0.bsp
PAK0_CONTENTS += maps/b_shell1.bsp
PAK0_CONTENTS += progs.dat
PAK0_CONTENTS += progs/armor.mdl
PAK0_CONTENTS += progs/b_g_key.mdl
PAK0_CONTENTS += progs/b_s_key.mdl
PAK0_CONTENTS += progs/backpack.mdl
PAK0_CONTENTS += progs/bolt.mdl
PAK0_CONTENTS += progs/bolt2.mdl
PAK0_CONTENTS += progs/bolt3.mdl
PAK0_CONTENTS += progs/end1.mdl
PAK0_CONTENTS += progs/end2.mdl
PAK0_CONTENTS += progs/end3.mdl
PAK0_CONTENTS += progs/end4.mdl
PAK0_CONTENTS += progs/eyes.mdl
PAK0_CONTENTS += progs/flame.mdl
PAK0_CONTENTS += progs/flame2.mdl
PAK0_CONTENTS += progs/g_light.mdl
PAK0_CONTENTS += progs/g_nail.mdl
PAK0_CONTENTS += progs/g_nail2.mdl
PAK0_CONTENTS += progs/g_rock.mdl
PAK0_CONTENTS += progs/g_rock2.mdl
PAK0_CONTENTS += progs/g_shot.mdl
PAK0_CONTENTS += progs/gib1.mdl
PAK0_CONTENTS += progs/gib2.mdl
PAK0_CONTENTS += progs/gib3.mdl
PAK0_CONTENTS += progs/grenade.mdl
PAK0_CONTENTS += progs/h_player.mdl
PAK0_CONTENTS += progs/h_zombie.mdl
PAK0_CONTENTS += progs/invisibl.mdl
PAK0_CONTENTS += progs/invulner.mdl
PAK0_CONTENTS += progs/laser.mdl
PAK0_CONTENTS += progs/lavaball.mdl
PAK0_CONTENTS += progs/m_g_key.mdl
PAK0_CONTENTS += progs/m_s_key.mdl
PAK0_CONTENTS += progs/missile.mdl
PAK0_CONTENTS += progs/player.mdl
PAK0_CONTENTS += progs/quaddama.mdl
PAK0_CONTENTS += progs/s_bubble.spr
PAK0_CONTENTS += progs/s_explod.spr
PAK0_CONTENTS += progs/s_invis.spr
PAK0_CONTENTS += progs/s_light.spr
PAK0_CONTENTS += progs/s_spike.mdl
PAK0_CONTENTS += progs/spike.mdl
PAK0_CONTENTS += progs/suit.mdl
PAK0_CONTENTS += progs/teleport.mdl
PAK0_CONTENTS += progs/v_axe.mdl
PAK0_CONTENTS += progs/v_light.mdl
PAK0_CONTENTS += progs/v_nail.mdl
PAK0_CONTENTS += progs/v_nail2.mdl
PAK0_CONTENTS += progs/v_rock.mdl
PAK0_CONTENTS += progs/v_rock2.mdl
PAK0_CONTENTS += progs/v_shot.mdl
PAK0_CONTENTS += progs/v_shot2.mdl
PAK0_CONTENTS += progs/w_g_key.mdl
PAK0_CONTENTS += progs/w_s_key.mdl
PAK0_CONTENTS += progs/zom_gib.mdl
PAK0_CONTENTS += progs/zombie.mdl
PAK0_CONTENTS += quake.rc
PAK0_CONTENTS += qwprogs.dat


#
# PAK1_CONTENTS is what goes into pak1.pak
#
# It contains models for the multiplayer game.
#
PAK1_CONTENTS += progs/demon.mdl
PAK1_CONTENTS += progs/dog.mdl
PAK1_CONTENTS += progs/enforcer.mdl
PAK1_CONTENTS += progs/fish.mdl
PAK1_CONTENTS += progs/h_demon.mdl
PAK1_CONTENTS += progs/h_dog.mdl
PAK1_CONTENTS += progs/h_guard.mdl
PAK1_CONTENTS += progs/h_hellkn.mdl
PAK1_CONTENTS += progs/h_knight.mdl
PAK1_CONTENTS += progs/h_mega.mdl
PAK1_CONTENTS += progs/h_player.mdl
PAK1_CONTENTS += progs/h_shal.mdl
PAK1_CONTENTS += progs/h_shams.mdl
PAK1_CONTENTS += progs/h_wizard.mdl
PAK1_CONTENTS += progs/hknight.mdl
PAK1_CONTENTS += progs/k_spike.mdl
PAK1_CONTENTS += progs/knight.mdl
PAK1_CONTENTS += progs/s_light.mdl
PAK1_CONTENTS += progs/s_spike.mdl
PAK1_CONTENTS += progs/shalrath.mdl
PAK1_CONTENTS += progs/shambler.mdl
PAK1_CONTENTS += progs/soldier.mdl
PAK1_CONTENTS += progs/tarbaby.mdl
PAK1_CONTENTS += progs/v_spike.mdl
PAK1_CONTENTS += progs/w_spike.mdl
PAK1_CONTENTS += progs/wizard.mdl


#
# PAK2_CONTENTS is what goes into pak2.pak
#
# It contains sounds.
#
PAK2_CONTENTS += sound/ambience/comp1.wav
PAK2_CONTENTS += sound/ambience/drip1.wav
PAK2_CONTENTS += sound/ambience/drone6.wav
PAK2_CONTENTS += sound/ambience/water1.wav
PAK2_CONTENTS += sound/ambience/wind2.wav
PAK2_CONTENTS += sound/ambience/windfly.wav
PAK2_CONTENTS += sound/buttons/airbut1.wav
PAK2_CONTENTS += sound/buttons/switch02.wav
PAK2_CONTENTS += sound/buttons/switch04.wav
PAK2_CONTENTS += sound/buttons/switch21.wav
PAK2_CONTENTS += sound/demon/ddeath.wav
PAK2_CONTENTS += sound/demon/dhit2.wav
PAK2_CONTENTS += sound/demon/djump.wav
PAK2_CONTENTS += sound/demon/dland2.wav
PAK2_CONTENTS += sound/demon/dpain1.wav
PAK2_CONTENTS += sound/demon/idle1.wav
PAK2_CONTENTS += sound/demon/sight2.wav
PAK2_CONTENTS += sound/doors/basetry.wav
PAK2_CONTENTS += sound/doors/baseuse.wav
PAK2_CONTENTS += sound/doors/ddoor2.wav
PAK2_CONTENTS += sound/doors/doormv1.wav
PAK2_CONTENTS += sound/doors/drclos4.wav
PAK2_CONTENTS += sound/doors/hydro1.wav
PAK2_CONTENTS += sound/doors/hydro2.wav
PAK2_CONTENTS += sound/doors/medtry.wav
PAK2_CONTENTS += sound/doors/meduse.wav
PAK2_CONTENTS += sound/doors/runetry.wav
PAK2_CONTENTS += sound/doors/runeuse.wav
PAK2_CONTENTS += sound/doors/stndr1.wav
PAK2_CONTENTS += sound/doors/stndr2.wav
PAK2_CONTENTS += sound/enforcer/death1.wav
PAK2_CONTENTS += sound/enforcer/enfire.wav
PAK2_CONTENTS += sound/enforcer/enfstop.wav
PAK2_CONTENTS += sound/enforcer/idle1.wav
PAK2_CONTENTS += sound/enforcer/idle3.wav
PAK2_CONTENTS += sound/enforcer/pain1.wav
PAK2_CONTENTS += sound/enforcer/pain2.wav
PAK2_CONTENTS += sound/enforcer/sight1.wav
PAK2_CONTENTS += sound/enforcer/sight2.wav
PAK2_CONTENTS += sound/enforcer/sight3.wav
PAK2_CONTENTS += sound/enforcer/sight4.wav
PAK2_CONTENTS += sound/hknight/hit.wav
PAK2_CONTENTS += sound/items/armor1.wav
PAK2_CONTENTS += sound/items/damage.wav
PAK2_CONTENTS += sound/items/damage2.wav
PAK2_CONTENTS += sound/items/damage3.wav
PAK2_CONTENTS += sound/items/health1.wav
PAK2_CONTENTS += sound/items/inv1.wav
PAK2_CONTENTS += sound/items/inv2.wav
PAK2_CONTENTS += sound/items/inv3.wav
PAK2_CONTENTS += sound/items/itembk2.wav
PAK2_CONTENTS += sound/items/protect.wav
PAK2_CONTENTS += sound/items/protect2.wav
PAK2_CONTENTS += sound/items/protect3.wav
PAK2_CONTENTS += sound/items/r_item1.wav
PAK2_CONTENTS += sound/items/r_item2.wav
PAK2_CONTENTS += sound/items/suit.wav
PAK2_CONTENTS += sound/items/suit2.wav
PAK2_CONTENTS += sound/misc/basekey.wav
PAK2_CONTENTS += sound/misc/h2ohit1.wav
PAK2_CONTENTS += sound/misc/medkey.wav
PAK2_CONTENTS += sound/misc/menu1.wav
PAK2_CONTENTS += sound/misc/menu2.wav
PAK2_CONTENTS += sound/misc/menu3.wav
PAK2_CONTENTS += sound/misc/null.wav
PAK2_CONTENTS += sound/misc/outwater.wav
PAK2_CONTENTS += sound/misc/power.wav
PAK2_CONTENTS += sound/misc/r_tele1.wav
PAK2_CONTENTS += sound/misc/r_tele2.wav
PAK2_CONTENTS += sound/misc/r_tele3.wav
PAK2_CONTENTS += sound/misc/r_tele4.wav
PAK2_CONTENTS += sound/misc/r_tele5.wav
PAK2_CONTENTS += sound/misc/runekey.wav
PAK2_CONTENTS += sound/misc/secret.wav
PAK2_CONTENTS += sound/misc/talk.wav
PAK2_CONTENTS += sound/misc/trigger1.wav
PAK2_CONTENTS += sound/misc/water1.wav
PAK2_CONTENTS += sound/misc/water2.wav
PAK2_CONTENTS += sound/plats/medplat1.wav
PAK2_CONTENTS += sound/plats/medplat2.wav
PAK2_CONTENTS += sound/plats/plat1.wav
PAK2_CONTENTS += sound/plats/plat2.wav
PAK2_CONTENTS += sound/player/axhit1.wav
PAK2_CONTENTS += sound/player/axhit2.wav
PAK2_CONTENTS += sound/player/death1.wav
PAK2_CONTENTS += sound/player/death2.wav
PAK2_CONTENTS += sound/player/death3.wav
PAK2_CONTENTS += sound/player/death4.wav
PAK2_CONTENTS += sound/player/death5.wav
PAK2_CONTENTS += sound/player/drown1.wav
PAK2_CONTENTS += sound/player/drown2.wav
PAK2_CONTENTS += sound/player/gasp1.wav
PAK2_CONTENTS += sound/player/gasp2.wav
PAK2_CONTENTS += sound/player/gib.wav
PAK2_CONTENTS += sound/player/h2odeath.wav
PAK2_CONTENTS += sound/player/h2ojump.wav
PAK2_CONTENTS += sound/player/inh2o.wav
PAK2_CONTENTS += sound/player/inlava.wav
PAK2_CONTENTS += sound/player/land.wav
PAK2_CONTENTS += sound/player/land2.wav
PAK2_CONTENTS += sound/player/lburn1.wav
PAK2_CONTENTS += sound/player/lburn2.wav
PAK2_CONTENTS += sound/player/pain1.wav
PAK2_CONTENTS += sound/player/pain2.wav
PAK2_CONTENTS += sound/player/pain3.wav
PAK2_CONTENTS += sound/player/pain4.wav
PAK2_CONTENTS += sound/player/pain5.wav
PAK2_CONTENTS += sound/player/pain6.wav
PAK2_CONTENTS += sound/player/plyrjmp8.wav
PAK2_CONTENTS += sound/player/slimbrn2.wav
PAK2_CONTENTS += sound/player/teledth1.wav
PAK2_CONTENTS += sound/player/tornoff2.wav
PAK2_CONTENTS += sound/player/udeath.wav
PAK2_CONTENTS += sound/soldier/sattck1.wav
PAK2_CONTENTS += sound/weapons/ax1.wav
PAK2_CONTENTS += sound/weapons/bounce.wav
PAK2_CONTENTS += sound/weapons/grenade.wav
PAK2_CONTENTS += sound/weapons/guncock.wav
PAK2_CONTENTS += sound/weapons/lhit.wav
PAK2_CONTENTS += sound/weapons/lock4.wav
PAK2_CONTENTS += sound/weapons/lstart.wav
PAK2_CONTENTS += sound/weapons/pkup.wav
PAK2_CONTENTS += sound/weapons/r_exp3.wav
PAK2_CONTENTS += sound/weapons/ric1.wav
PAK2_CONTENTS += sound/weapons/ric2.wav
PAK2_CONTENTS += sound/weapons/ric3.wav
PAK2_CONTENTS += sound/weapons/rocket1i.wav
PAK2_CONTENTS += sound/weapons/sgun1.wav
PAK2_CONTENTS += sound/weapons/shotgn2.wav
PAK2_CONTENTS += sound/weapons/spike2.wav
PAK2_CONTENTS += sound/weapons/tink1.wav
PAK2_CONTENTS += sound/wizard/hit.wav
PAK2_CONTENTS += sound/zombie/idle_w2.wav
PAK2_CONTENTS += sound/zombie/z_fall.wav
PAK2_CONTENTS += sound/zombie/z_gib.wav
PAK2_CONTENTS += sound/zombie/z_hit.wav
PAK2_CONTENTS += sound/zombie/z_idle.wav
PAK2_CONTENTS += sound/zombie/z_idle1.wav
PAK2_CONTENTS += sound/zombie/z_miss.wav
PAK2_CONTENTS += sound/zombie/z_pain.wav
PAK2_CONTENTS += sound/zombie/z_pain1.wav
PAK2_CONTENTS += sound/zombie/z_shot1.wav


#
# PAK3_CONTENTS is what goes into pak3.pak
#
# It contains multiplayer maps.
#
PAK3_CONTENTS += maps/elbow.bsp
PAK3_CONTENTS += maps/rpgdm1.bsp
PAK3_CONTENTS += maps/am1.bsp
PAK3_CONTENTS += maps/box.bsp
PAK3_CONTENTS += maps/bunkers.bsp
PAK3_CONTENTS += maps/house.bsp
PAK3_CONTENTS += maps/nsa.bsp
PAK3_CONTENTS += maps/office.bsp
PAK3_CONTENTS += maps/start.bsp
PAK3_CONTENTS += maps/void1.bsp
PAK3_CONTENTS += maps/void1.way
PAK3_CONTENTS += maps/void2.bsp
PAK3_CONTENTS += maps/void3.bsp
PAK3_CONTENTS += maps/void3.way
PAK3_CONTENTS += maps/void4.bsp
PAK3_CONTENTS += maps/void4.way
PAK3_CONTENTS += maps/void5.bsp
PAK3_CONTENTS += maps/void6.bsp
PAK3_CONTENTS += maps/vtest.bsp
PAK3_CONTENTS += maps/q3dm6ish.bsp
PAK3_CONTENTS += maps/devourer.bsp
PAK3_CONTENTS += maps/dm1.bsp
PAK3_CONTENTS += maps/dm2.bsp
PAK3_CONTENTS += maps/dm3.bsp
PAK3_CONTENTS += maps/dm4.bsp
PAK3_CONTENTS += maps/dm5.bsp
PAK3_CONTENTS += maps/dm6.bsp
PAK3_CONTENTS += maps/dm7.bsp
PAK3_CONTENTS += maps/dm8.bsp


#
# PAK4_CONTENTS is what goes into pak4.pak
#
# It contains single-player maps, most of which are
# the original Quake maps written by John Romero.
#
PAK4_CONTENTS += maps/q1start.bsp
PAK4_CONTENTS += maps/e1m1.bsp
PAK4_CONTENTS += maps/e1m2.bsp
PAK4_CONTENTS += maps/e1m3.bsp
PAK4_CONTENTS += maps/e1m4.bsp
PAK4_CONTENTS += maps/e1m5.bsp
PAK4_CONTENTS += maps/e1m6.bsp
PAK4_CONTENTS += maps/e1m7.bsp
PAK4_CONTENTS += maps/e1m8.bsp
PAK4_CONTENTS += maps/e2m1.bsp
PAK4_CONTENTS += maps/e2m2.bsp
PAK4_CONTENTS += maps/e2m3.bsp
PAK4_CONTENTS += maps/e2m4.bsp
PAK4_CONTENTS += maps/e2m5.bsp
PAK4_CONTENTS += maps/e2m6.bsp
PAK4_CONTENTS += maps/e2m7.bsp
PAK4_CONTENTS += maps/e3m1.bsp
PAK4_CONTENTS += maps/e3m2.bsp
PAK4_CONTENTS += maps/e3m3.bsp
PAK4_CONTENTS += maps/e3m4.bsp
PAK4_CONTENTS += maps/e3m5.bsp
PAK4_CONTENTS += maps/e3m6.bsp
PAK4_CONTENTS += maps/e3m7.bsp
PAK4_CONTENTS += maps/e4m1.bsp
PAK4_CONTENTS += maps/e4m2.bsp
PAK4_CONTENTS += maps/e4m3.bsp
PAK4_CONTENTS += maps/e4m4.bsp
PAK4_CONTENTS += maps/e4m5.bsp
PAK4_CONTENTS += maps/e4m6.bsp
PAK4_CONTENTS += maps/e4m7.bsp
PAK4_CONTENTS += maps/e4m8.bsp
PAK4_CONTENTS += maps/end.bsp
PAK4_CONTENTS += maps/e2m10.bsp


#
# make targets
#

pak0.pak: $(PAK0_CONTENTS) makefile
	$(PAR) -c $@ $(PAK0_CONTENTS)

pak1.pak: $(PAK1_CONTENTS) makefile
	$(PAR) -c $@ $(PAK1_CONTENTS)

pak2.pak: $(PAK2_CONTENTS) makefile
	$(PAR) -c $@ $(PAK2_CONTENTS)

pak3.pak: $(PAK3_CONTENTS) makefile
	$(PAR) -c $@ $(PAK3_CONTENTS)

pak4.pak: $(PAK4_CONTENTS) makefile
	$(PAR) -c $@ $(PAK4_CONTENTS)

qwprogs.dat:
	$(QCC) -o qwprogs.dat -p qwdefs.h qc_merge/qw.qc

progs.dat:
	$(QCC) -o progs.dat -p progdefs.h qc_merge/quake.qc

gfx.wad :
	$(QLUMPY) gfx_wad.ls

%.lmp : gfx_lmp.ls
	$(QLUMPY) gfx_lmp.ls

%.mdl : %.qc
	$(MODELGEN) $<

%.spr : %.qc %.png
	$(SPRGEN) $<

#
# The next target builds static models (not maps).  
# Static models are models that don't move during the game, so the 
# can be represented by a .bsp instead of a .mdl (which is easier to render).
# Unlike regular .map files, $(VIS) cannot be run on them
# because they are inherently leaky.  Therefore, we have to add
# a target to that matches them specially.  This MUST come before the
# normal rules for building maps so that it will match first.
#
maps/b_%.bsp : maps/b_%.map
	$(QBSP) $<
	$(LIGHT) $@

# some maps need special programs and switches - these maps need to be
# built before the others...
maps/elbow.bsp : maps/elbow.map
	$(QBSP) $<
	$(VIS) $@
	$(TYRLITE) -extra $@

maps/rpgdm1.bsp : maps/rpgdm1.map
	$(QBSP) $<
	$(VIS) $@
	$(TYRLITE) -extra $@


%.bsp : %.map
	$(QBSP) $<
	$(VIS) $@
	$(LIGHT) $@

# 
# Not all .mdl files can be built from source by our tools.
# For each file that we cannot generate, we add a special case that 
# tells make to skip the file.
#

progs/s_light.mdl : ;
