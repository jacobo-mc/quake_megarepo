# makefile to build h2patch.exe for Win32 using OpenWatcom:
# wmake -f Makefile.wat

!ifdef __UNIX__
PATH_SEP=/
UHEXEN2_TOP=..
UHEXEN2_SHARED=$(UHEXEN2_TOP)/common
LIBS_DIR=$(UHEXEN2_TOP)/libs
OSLIBS=$(UHEXEN2_TOP)/oslibs
XDELTA_DIR= $(LIBS_DIR)/xdelta3
!else
PATH_SEP=\
UHEXEN2_TOP=..
UHEXEN2_SHARED=$(UHEXEN2_TOP)\common
LIBS_DIR=$(UHEXEN2_TOP)\libs
OSLIBS=$(UHEXEN2_TOP)\oslibs
XDELTA_DIR= $(LIBS_DIR)\xdelta3
!endif

CFLAGS  = -zq -bm -bt=nt -5s -fp5 -fpi87 -sg -otexan -wx -ei -j -zp8
# newer OpenWatcom versions enable W303 by default
CFLAGS+= -wcd=303
CFLAGS += -DWIN32_LEAN_AND_MEAN
!ifndef DEBUG
CFLAGS += -DNDEBUG=1
!else
CFLAGS += -d2
!endif
CFLAGS += -I. -I$(XDELTA_DIR) -I$(UHEXEN2_SHARED)
RCFLAGS = -bt=nt
RC_DEFS = -DWIN32_LEAN_AND_MEAN

XDFLAGS= -DXD3_DEBUG=0
# when XD3_USE_LARGEFILE64 is not defined, xdelta3 defaults
# to 64 bit xoff_t.
# using 32 bit xoff_t is necessary for compatibility
# with old windows versions, i.e. win9x or nt4.
XDFLAGS+= -DXD3_USE_LARGEFILE64=0
# make xdelta3 to use windows api for file i/o:
XDFLAGS+= -DXD3_WIN32=1

# Targets
BINARY=h2patch.exe
all: $(BINARY)

OBJECTS=xdelta3.obj qsnprint.obj h2patch3.obj
XD3DEPS=xdelta3-decode.h xdelta3-list.h xdelta3-main.h xdelta3-blkcache.h xdelta3.c xdelta3.h

.EXTENSIONS: .res .rc

.c: $(UHEXEN2_SHARED);$(XDELTA_DIR)
.h: $(UHEXEN2_SHARED);$(XDELTA_DIR)

.c.obj:
	wcc386 $(CFLAGS) -fo=$^@ $<
.rc.res:
	wrc -q -r $(RCFLAGS) $(RC_DEFS) -fo=$^@ $<

xdelta3.obj: $(XD3DEPS)
	wcc386 $(CFLAGS) $(XDFLAGS) -fo=$^@ $(XDELTA_DIR)$(PATH_SEP)xdelta3.c

h2patch.res: h2patch3.rc
	wrc -q -r $(RCFLAGS) $(RC_DEFS) -fo=$^@ $<

h2patch.exe: $(OBJECTS) h2patch.res
	wlink N $@ SYS NT OP q OP RESOURCE=$^*.res F {$(OBJECTS)}

clean: .symbolic
	rm -f *.obj *.res *.err
distclean: clean .symbolic
	rm -f $(BINARY)
