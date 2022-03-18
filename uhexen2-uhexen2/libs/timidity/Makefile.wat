# Makefile for Win32 using Watcom compiler.
# wmake -f Makefile.wat

INCLUDES=-I.
CPPFLAGS=-DTIMIDITY_BUILD -DTIMIDITY_STATIC
# to enable loud debug messages:
#CPPFLAGS+= -DTIMIDITY_DEBUG

CFLAGS = -zq -bt=nt -bm -fp5 -fpi87 -mf -oeatxh -w4 -ei -j -zp8
# -5s  :  Pentium stack calling conventions.
# -5r  :  Pentium register calling conventions.
CFLAGS+= -5s

.SUFFIXES:
.SUFFIXES: .obj .c

LIBSTATIC=timidity.lib

COMPILE=wcc386 $(CFLAGS) $(CPPFLAGS) $(INCLUDES)

OBJ=common.obj instrum.obj mix.obj output.obj playmidi.obj readmidi.obj resample.obj stream.obj tables.obj timidity.obj

all: $(LIBSTATIC)

$(LIBSTATIC): $(OBJ)
	wlib -q -b -n -c -pa -s -t -zld -ii -io $@ $(OBJ)

.c.obj:
	$(COMPILE) -fo=$^@ $<

distclean: clean .symbolic
	rm -f $(LIBSTATIC)
clean: .symbolic
	rm -f *.obj *.err
