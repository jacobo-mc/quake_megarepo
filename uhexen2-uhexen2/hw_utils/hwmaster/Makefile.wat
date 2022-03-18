# makefile to build hexenworld master server for Win32 using Open Watcom:
# wmake -f Makefile.wat

# PATH SETTINGS:
!ifndef __UNIX__
PATH_SEP=\
UHEXEN2_TOP=..\..
UHEXEN2_SHARED=$(UHEXEN2_TOP)\common
LIBS_DIR=$(UHEXEN2_TOP)\libs
OSLIBS=$(UHEXEN2_TOP)\oslibs
!else
PATH_SEP=/
UHEXEN2_TOP=../..
UTILS_TOP=..
COMMONDIR=$(UTILS_TOP)/common
UHEXEN2_SHARED=$(UHEXEN2_TOP)/common
LIBS_DIR=$(UHEXEN2_TOP)/libs
OSLIBS=$(UHEXEN2_TOP)/oslibs
!endif

# use WinSock2 instead of WinSock-1.1? (disabled for w32 for compat.
# with old Win95 machines.)
USE_WINSOCK2=no

# Names of the binaries
BINARY=hwmaster.exe

# Compiler flags
CFLAGS = -zq -wx -bm -bt=nt -5s -sg -otexan -fp5 -fpi87 -ei -j -zp8
# newer OpenWatcom versions enable W303 by default
CFLAGS+= -wcd=303
!ifdef DEBUG
CFLAGS+= -d2
!else
CFLAGS+= -DNDEBUG=1
!endif
CPPFLAGS = -DWIN32_LEAN_AND_MEAN

INCLUDES= -I. -I$(UHEXEN2_SHARED)

!ifeq USE_WINSOCK2 yes
CPPFLAGS+=-D_USE_WINSOCK2
LIBWINSOCK=ws2_32.lib
!else
LIBWINSOCK=wsock32.lib
!endif

LIBS = $(LIBWINSOCK) winmm.lib

#############################################################

.c: $(COMMONDIR);$(UHEXEN2_SHARED)

.c.obj:
	wcc386 $(INCLUDES) $(CFLAGS) $(CPPFLAGS) -fo=$^@ $<

# Objects
OBJECTS = qsnprint.obj sizebuf.obj msg_io.obj cmds.obj common.obj net.obj master.obj sys_win.obj

all: $(BINARY)

$(BINARY): $(OBJECTS)
	wlink N $@ SYS NT OP q LIBR {$(LIBS)} F {$(OBJECTS)}

INCLUDES+= -I"$(OSLIBS)/windows/misc/include"
clean: .symbolic
	rm -f *.obj *.res *.err
distclean: clean .symbolic
	rm -f $(BINARY)
