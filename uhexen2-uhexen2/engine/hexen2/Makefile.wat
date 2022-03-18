# makefile to build h2.exe for Windows using Open Watcom:
#    wmake -f Makefile.wat
#
# to build opengl version (glh2.exe) :
#    wmake -f Makefile.wat BUILDGL=1

# PATH SETTINGS:
!ifndef __UNIX__
PATH_SEP=\
UHEXEN2_TOP=..\..
ENGINE_TOP=..
COMMONDIR=$(ENGINE_TOP)\h2shared
UHEXEN2_SHARED=$(UHEXEN2_TOP)\common
LIBS_DIR=$(UHEXEN2_TOP)\libs
OSLIBS=$(UHEXEN2_TOP)\oslibs
!else
PATH_SEP=/
UHEXEN2_TOP=../..
ENGINE_TOP=..
COMMONDIR=$(ENGINE_TOP)/h2shared
UHEXEN2_SHARED=$(UHEXEN2_TOP)/common
LIBS_DIR=$(UHEXEN2_TOP)/libs
OSLIBS=$(UHEXEN2_TOP)/oslibs
!endif

# GENERAL OPTIONS (customize as required)

# link to the opengl libraries at compile time? (defaults
# to no, so the binaries will dynamically load the necessary
# libraries and functions at runtime.)
LINK_GL_LIBS=no

# use fast x86 assembly on ia32 machines? (auto-disabled for
# any other cpu.)
USE_X86_ASM=yes

# enable sound support?
USE_SOUND=yes

# include target's MIDI driver if available?
USE_MIDI=yes

# CDAudio support?
USE_CDAUDIO=yes

# link to the directx libraries at compile time? (otherwise, load
# the necessary DLLs and functions dynamically at runtime, which
# ensures our exe to function on ancient windows versions without
# a directx installation.)
LINK_DIRECTX=no

# enable startup splash screens? (windows)
WITH_SPLASHES=yes

# use WinSock2 instead of WinSock-1.1? (disabled for w32 for compat.
# with old Win95 machines.) (enabled for Win64 in the win64 section.)
USE_WINSOCK2=no

# Enable/disable codecs for streaming music support:
USE_CODEC_WAVE=yes
USE_CODEC_FLAC=no
USE_CODEC_MP3=yes
USE_CODEC_VORBIS=yes
USE_CODEC_OPUS=no
# either mikmod or xmp
USE_CODEC_MIKMOD=no
USE_CODEC_XMP=no
USE_CODEC_UMX=no
# either timidity (preferred) or wildmidi (both possible
# but not needed nor meaningful)
USE_CODEC_TIMIDITY=no
USE_CODEC_WILDMIDI=no
# which library to use for mp3 decoding: mad or mpg123
MP3LIB=mad
# which library to use for ogg decoding: vorbis or tremor
VORBISLIB=tremor

# Names of the binaries
SW_NAME=h2
GL_NAME=glh2
SW_BINARY=$(SW_NAME).exe
GL_BINARY=$(GL_NAME).exe

#############################################################
# Compiler flags
#############################################################

CFLAGS = -zq -wx -bm -bt=nt -5s -sg -otexan -fp5 -fpi87 -ei -j -zp8
# newer OpenWatcom versions enable W303 by default
CFLAGS+= -wcd=303

# compiler includes
INCLUDES= -I. -I$(COMMONDIR) -I$(UHEXEN2_SHARED)
# nasm includes: the trailing directory separator matters
NASM_INC= -I.$(PATH_SEP) -I$(COMMONDIR)$(PATH_SEP)
# windows resource compiler includes
RC_INC  = -I. -I$(COMMONDIR)

# end of compiler flags
#############################################################


#############################################################
# Other build flags
#############################################################

!ifdef DEMO
CPPFLAGS+= -DDEMOBUILD
!endif

!ifdef DEBUG
CFLAGS  += -d2
# This activates some extra code in hexen2/hexenworld C source
CPPFLAGS+= -DDEBUG=1 -DDEBUG_BUILD=1
!endif


#############################################################
# OpenGL settings
#############################################################
GL_DEFS = -DGLQUAKE
GL_LIBS =

#############################################################
# streaming music initial setup
#############################################################
!ifneq USE_SOUND yes
USE_CODEC_WAVE=no
USE_CODEC_FLAC=no
USE_CODEC_TIMIDITY=no
USE_CODEC_WILDMIDI=no
USE_CODEC_MIKMOD=no
USE_CODEC_XMP=no
USE_CODEC_UMX=no
USE_CODEC_MP3=no
USE_CODEC_VORBIS=no
USE_CODEC_OPUS=no
!endif

#############################################################
# Win32 flags/settings and overrides:
#############################################################

RC_DEFS=$(CPPFLAGS)
RCFLAGS=-bt=nt
NASMFLAGS=-f win32 -d_NO_PREFIX

!ifndef __UNIX__
INCLUDES+= -I$(OSLIBS)\windows\dxsdk\include
INCLUDES+= -I$(OSLIBS)\windows\misc\include
INCLUDES+= -I$(OSLIBS)\windows\codecs\include
DXLIBS   =  $(OSLIBS)\windows\dxsdk\x86\
CODECLIBS=  $(OSLIBS)\windows\codecs\x86-watcom\
!else
INCLUDES+= -I$(OSLIBS)/windows/dxsdk/include
INCLUDES+= -I$(OSLIBS)/windows/misc/include
INCLUDES+= -I$(OSLIBS)/windows/codecs/include
DXLIBS   =  $(OSLIBS)/windows/dxsdk/x86/
CODECLIBS=  $(OSLIBS)/windows/codecs/x86-watcom/
!endif

GL_LINK=opengl32.lib

!ifeq USE_WINSOCK2 yes
CPPFLAGS+=-D_USE_WINSOCK2
LIBWINSOCK=ws2_32.lib
!else
LIBWINSOCK=wsock32.lib
!endif

CPPFLAGS+= -DWIN32_LEAN_AND_MEAN
LIBS += $(LIBWINSOCK) winmm.lib

!ifneq LINK_DIRECTX yes
CPPFLAGS+= -DDX_DLSYM
!else
LIBS += $(DXLIBS)dsound.lib $(DXLIBS)dinput.lib $(DXLIBS)dxguid.lib
!endif

!ifneq WITH_SPLASHES yes
CPPFLAGS+= -DNO_SPLASHES
!endif


#############################################################
# Streaming music settings
#############################################################
!ifeq MP3LIB mad
mp3_obj=snd_mp3
lib_mp3dec=$(CODECLIBS)mad.lib
!endif
!ifeq MP3LIB mpg123
mp3_obj=snd_mpg123
lib_mp3dec=$(CODECLIBS)mpg123.lib
!endif
!ifeq VORBISLIB vorbis
cpp_vorbisdec=
lib_vorbisdec=$(CODECLIBS)vorbisfile.lib $(CODECLIBS)vorbis.lib $(CODECLIBS)ogg.lib
!endif
!ifeq VORBISLIB tremor
cpp_vorbisdec=-DVORBIS_USE_TREMOR
lib_vorbisdec=$(CODECLIBS)vorbisidec.lib $(CODECLIBS)ogg.lib
!endif

!ifeq USE_CODEC_FLAC yes
CPPFLAGS+= -DUSE_CODEC_FLAC
# for static linkage
CPPFLAGS+= -DFLAC__NO_DLL
LIBS    += $(CODECLIBS)FLAC.lib
!endif
!ifeq USE_CODEC_WAVE yes
CPPFLAGS+= -DUSE_CODEC_WAVE
!endif
!ifeq USE_CODEC_OPUS yes
CPPFLAGS+= -DUSE_CODEC_OPUS
LIBS    += $(CODECLIBS)opusfile.lib $(CODECLIBS)opus.lib
!ifneq USE_CODEC_VORBIS yes
LIBS    += $(CODECLIBS)ogg.lib
!endif
!endif
!ifeq USE_CODEC_VORBIS yes
CPPFLAGS+= -DUSE_CODEC_VORBIS $(cpp_vorbisdec)
LIBS    += $(lib_vorbisdec)
!endif
!ifeq USE_CODEC_MP3 yes
CPPFLAGS+= -DUSE_CODEC_MP3
LIBS    += $(lib_mp3dec)
!endif
!ifeq USE_CODEC_MIKMOD yes
CPPFLAGS+= -DUSE_CODEC_MIKMOD
# for static linkage
CPPFLAGS+= -DMIKMOD_STATIC
LIBS    += $(CODECLIBS)mikmod.lib
!endif
!ifeq USE_CODEC_XMP yes
CPPFLAGS+= -DUSE_CODEC_XMP
# for static linkage
CPPFLAGS+= -DXMP_NO_DLL
LIBS    += $(CODECLIBS)libxmp.lib
!endif
!ifeq USE_CODEC_UMX yes
CPPFLAGS+= -DUSE_CODEC_UMX
!endif
!ifeq USE_CODEC_TIMIDITY yes
CPPFLAGS+= -DUSE_CODEC_TIMIDITY
LIBS    += $(CODECLIBS)timidity.lib
!endif
!ifeq USE_CODEC_WILDMIDI yes
CPPFLAGS+= -DUSE_CODEC_WILDMIDI
LIBS    += $(CODECLIBS)WildMidi.lib
!endif

# End of streaming music settings
#############################################################

#############################################################
# Finalize things after the system specific overrides:
#############################################################

!ifeq USE_X86_ASM yes
CPPFLAGS+= -DUSE_INTEL_ASM
!endif

!ifneq LINK_GL_LIBS yes
GL_DEFS+= -DGL_DLSYM
!else
GL_LIBS+= $(GL_LINK)
!endif

!ifndef BUILDGL
TARGET_NAME=$(SW_NAME)
BUILD_TARGET=$(SW_BINARY)
!else
CPPFLAGS+= $(GL_DEFS)
TARGET_NAME=$(GL_NAME)
BUILD_TARGET=$(GL_BINARY)
!endif
#
#############################################################

.EXTENSIONS: .res .rc

.c: $(COMMONDIR);$(UHEXEN2_SHARED)
.asm: $(COMMONDIR)
.rc: $(COMMONDIR)

.c.obj:
	wcc386 $(INCLUDES) $(CPPFLAGS) $(CFLAGS) -fo=$^@ $<
.asm.obj:
	nasm $(NASM_INC) $(NASMFLAGS) -o $^@ $<
.rc.res:
	wrc -q -r $(RCFLAGS) $(RC_DEFS) $(RC_INC) -fo=$^@ $<

# Objects

# Intel asm objects
!ifeq USE_X86_ASM yes
COMMON_ASM= math.obj &
	sys_ia32.obj

SOFT_ASM = &
	d_draw.obj &
	d_draw16.obj &
	d_draw16t.obj &
	d_parta.obj &
	d_partb.obj &
	d_polysa.obj &
	d_polysa2.obj &
	d_polysa3.obj &
	d_polysa4.obj &
	d_polysa5.obj &
	d_scana.obj &
	d_spr8.obj &
	d_spr8t.obj &
	d_spr8t2.obj &
	d_varsa.obj &
	r_aclipa.obj &
	r_aliasa.obj &
	r_drawa.obj &
	r_edgea.obj &
	r_edgeb.obj &
	r_varsa.obj &
	surf8.obj &
	surf16.obj

SOUND_ASM = snd_mixa.obj
WORLD_ASM = worlda.obj

!else

SOFT_ASM =
COMMON_ASM =
SOUND_ASM =
WORLD_ASM =

!endif

# Sound objects
!ifneq USE_SOUND yes
MUSIC_OBJS= bgmnull.obj
SOUND_ASM =
CPPFLAGS += -D_NO_SOUND
SYSOBJ_SND =
COMOBJ_SND = snd_null.obj $(MUSIC_OBJS)
!else
MUSIC_OBJS= bgmusic.obj &
	snd_codec.obj &
	snd_flac.obj &
	snd_wave.obj &
	snd_vorbis.obj &
	snd_opus.obj &
	$(mp3_obj).obj &
	snd_mp3tag.obj &
	snd_mikmod.obj &
	snd_xmp.obj &
	snd_umx.obj &
	snd_timidity.obj &
	snd_wildmidi.obj
COMOBJ_SND = snd_sys.obj snd_dma.obj snd_mix.obj $(SOUND_ASM) snd_mem.obj $(MUSIC_OBJS)
SYSOBJ_SND = snd_win.obj snd_dsound.obj
!endif

!ifneq USE_MIDI yes
SYSOBJ_MIDI= midi_nul.obj
CPPFLAGS += -D_NO_MIDIDRV
!else
SYSOBJ_MIDI= midi_win.obj mid2strm.obj
!endif

# CDAudio objects
!ifneq USE_CDAUDIO yes
SYSOBJ_CDA= cd_null.obj
CPPFLAGS += -D_NO_CDAUDIO
!else
SYSOBJ_CDA = cd_win.obj
!endif

SYSOBJ_INPUT = in_win.obj
SYSOBJ_GL_VID= gl_vidnt.obj
SYSOBJ_SOFT_VID= vid_win.obj
SYSOBJ_NET = net_win.obj net_wins.obj net_wipx.obj
SYSOBJ_SYS = sys_win.obj
SYSOBJ_RES = $(TARGET_NAME).res

# Final list of objects
SOFTOBJS = &
	d_edge.obj &
	d_fill.obj &
	d_init.obj &
	d_modech.obj &
	d_part.obj &
	d_polyse.obj &
	d_scan.obj &
	d_sky.obj &
	d_sprite.obj &
	d_surf.obj &
	d_vars.obj &
	d_zpoint.obj &
	r_aclip.obj &
	r_alias.obj &
	r_bsp.obj &
	r_draw.obj &
	r_edge.obj &
	r_efrag.obj &
	r_light.obj &
	r_main.obj &
	r_misc.obj &
	r_part.obj &
	r_sky.obj &
	r_sprite.obj &
	r_surf.obj &
	r_vars.obj &
	screen.obj &
	$(SYSOBJ_SOFT_VID) &
	draw.obj &
	model.obj

GLOBJS = &
	gl_refrag.obj &
	gl_rlight.obj &
	gl_rmain.obj &
	gl_rmisc.obj &
	r_part.obj &
	gl_rsurf.obj &
	gl_screen.obj &
	gl_warp.obj &
	$(SYSOBJ_GL_VID) &
	gl_draw.obj &
	gl_mesh.obj &
	gl_model.obj

COMMONOBJS = &
	$(SYSOBJ_INPUT) &
	$(COMOBJ_SND) &
	$(SYSOBJ_SND) &
	$(SYSOBJ_CDA) &
	$(SYSOBJ_MIDI) &
	$(SYSOBJ_NET) &
	net_dgrm.obj &
	net_loop.obj &
	net_main.obj &
	chase.obj &
	cl_demo.obj &
	cl_effect.obj &
	cl_inlude.obj &
	cl_input.obj &
	cl_main.obj &
	cl_parse.obj &
	cl_string.obj &
	cl_tent.obj &
	cl_cmd.obj &
	console.obj &
	keys.obj &
	menu.obj &
	sbar.obj &
	view.obj &
	wad.obj &
	cmd.obj &
	q_endian.obj &
	link_ops.obj &
	sizebuf.obj &
	strlcat.obj &
	strlcpy.obj &
	qsnprint.obj &
	msg_io.obj &
	common.obj &
	debuglog.obj &
	quakefs.obj &
	crc.obj &
	cvar.obj &
	cfgfile.obj &
	host.obj &
	host_cmd.obj &
	host_string.obj &
	mathlib.obj &
	pr_cmds.obj &
	pr_edict.obj &
	pr_exec.obj &
	sv_effect.obj &
	sv_main.obj &
	sv_move.obj &
	sv_phys.obj &
	sv_user.obj &
	$(WORLD_ASM) &
	world.obj &
	zone.obj &
	$(SYSOBJ_SYS)

all: $(BUILD_TARGET)

$(TARGET_NAME).res: win32res.rc
	wrc -q -r $(RCFLAGS) $(RC_DEFS) $(RC_INC) -fo=$^@ $<

snd_timidity.obj: $(COMMONDIR)/snd_timidity.c
	wcc386 $(INCLUDES) -I$(LIBS_DIR)/timidity $(CPPFLAGS) $(CFLAGS) -DTIMIDITY_STATIC=1 -fo=$^@ $<

# 1 MB stack size.
$(SW_BINARY): $(SOFT_ASM) $(SOFTOBJS) $(COMMON_ASM) $(COMMONOBJS) $(SYSOBJ_RES)
	wlink N $@ SYS NT_WIN OPTION q OPTION STACK=0x100000 OPTION RESOURCE=$^*.res LIBR {$(LIBS)} F {$(SOFT_ASM) $(SOFTOBJS) $(COMMON_ASM) $(COMMONOBJS)}

# 1 MB stack size.
$(GL_BINARY): $(GLOBJS) $(COMMON_ASM) $(COMMONOBJS) $(SYSOBJ_RES)
	wlink N $@ SYS NT_WIN OPTION q OPTION STACK=0x100000 OPTION RESOURCE=$^*.res LIBR {$(LIBS) $(GL_LIBS)} F {$(GLOBJS) $(COMMON_ASM) $(COMMONOBJS)}

clean: .symbolic
	rm -f *.obj *.res *.err
distclean: clean .symbolic
	rm -f $(SW_BINARY) $(GL_BINARY)
