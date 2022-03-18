# makefile to build hexen2 mapping tools for Win32 using Open Watcom:
#   wmake -f Makefile.wat

# PATH SETTINGS:
!ifndef __UNIX__
PATH_SEP=\
UHEXEN2_TOP=..\..
UTILS_TOP=..
COMMONDIR=$(UTILS_TOP)\common
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

# Names of the binaries
QBSP=qbsp.exe

# Compiler flags
CFLAGS = -zq -wx -bm -bt=nt -5s -sg -otexan -fp5 -fpi87 -ei -j -zp8
# newer OpenWatcom versions enable W303 by default
CFLAGS+= -wcd=303
!ifdef DEBUG
CFLAGS+= -d2
!else
CFLAGS+= -DNDEBUG=1
!endif
CFLAGS+= -DDOUBLEVEC_T
CFLAGS+= -DWIN32_LEAN_AND_MEAN

INCLUDES= -I. -I$(COMMONDIR) -I$(UHEXEN2_SHARED)

#############################################################

.c: $(COMMONDIR);$(UHEXEN2_SHARED)

.c.obj:
	wcc386 $(INCLUDES) $(CFLAGS) -fo=$^@ $<

# Objects
OBJ_COMMON= qsnprint.obj &
	strlcat.obj &
	strlcpy.obj &
	cmdlib.obj &
	q_endian.obj &
	byteordr.obj &
	util_io.obj &
	pathutil.obj &
	mathlib.obj &
	bspfile.obj

OBJ_QBSP= brush.obj &
	csg4.obj &
	map.obj &
	merge.obj &
	nodraw.obj &
	outside.obj &
	portals.obj &
	qbsp.obj &
	region.obj &
	solidbsp.obj &
	surfaces.obj &
	tjunc.obj &
	writebsp.obj

all: $(QBSP)

# 1 MB stack.
$(QBSP): $(OBJ_COMMON) $(OBJ_QBSP)
	wlink N $@ SYS NT OPTION q OPTION STACK=0x100000 F {$(OBJ_COMMON) $(OBJ_QBSP)}

INCLUDES+= -I"$(OSLIBS)/windows/misc/include"
clean: .symbolic
	rm -f *.obj *.res
distclean: clean .symbolic
	rm -f $(QBSP)
