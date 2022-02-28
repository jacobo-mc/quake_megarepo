#
# Set CFLAGS, LDFLAGS, and CPPFLAGS with +=, instead of =,
# so that we concatenate to values that are read in from the 
# environment/command-line.
# This makes it easier to compile on Windows because it allows
# the user to set the include path and library path for png and 
# zlib.
#
CPPFLAGS += -Icommon
CFLAGS   += -g -O2 -Wall
#CFLAGS  += -g -Wall -pg
#CFLAGS  += -O2 -fomit-frame-pointer -Wall
#LDFLAGS += -static
OUTDIR=./bin/


all: map_utils model_utils other_utils

map_utils: qbsp light vis bspinfo
model_utils: texmake modelgen skinless
other_utils: qcc qfiles qlumpy sprgen


# common stuff
COMMON=common/common.a

# map utilities
QBSP=brush.o csg4.o map.o merge.o nodraw.o outside.o portals.o qbsp.o region.o solidbsp.o surfaces.o tjunc.o writebsp.o
VIS=flow.o soundpvs.o vis.o
LIGHT=entities.o light.o ltface.o threads.o trace.o
BSPINFO=bspinfo.o

# other utilities
MODELGEN=modelgen.o
SKINLESS=skinless.o
QCC=pr_comp.o pr_lex.o qcc.o
QFILES=qfiles.o
QLUMPY=qlumpy.o quakegrb.o
SPRGEN=sprgen.o
TEXMAKE=texmake.o

COMMON_OBJ=cmdlib.o qmalloc.o

ALL_OBJECTS=$(addprefix qcc/,$(QCC))\
	$(addprefix common/,$(COMMON_OBJ))

# Seth Galbraith disabled dependency checking because in Windows it spawns you into
# layered DOS prompts and you have to type "exit" four times to finish compiling.
# Should be safe to enable this stuff for other platforms.  This needs to be fixed.
#
#ifneq ($(MAKECMDGOALS),clean)
#include $(ALL_OBJECTS:.o=.d)
#endif
#
#$(ALL_OBJECTS:.o=.d): %.d: %.c
#	$(SHELL) -ec '$(CC) -MM $(CPPFLAGS)	$<	\
#		| sed '\''s:\($(notdir $*)\)\.o[ \:]*:$(basename $*).o $@ \: :g'\'' > $@; \
#		[ -s $@ ] || rm -f $@'


clean:
	rm -f $(addprefix $(OUTDIR),qbsp vis light bspinfo modelgen skinless qcc qfiles qlumpy sprgen texmake pcx2lmp)
	rm -f $(addsuffix /*.o,common qbsp vis light bspinfo modelgen qcc qfiles qlumpy sprgen texmake pcx2lmp)
	rm -f $(addsuffix /*.d,common qbsp vis light bspinfo modelgen qcc qfiles qlumpy sprgen texmake pcx2lmp)
	rm -f $(COMMON)


# rule for making any .o files needed from .c files
%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<


qbsp: $(OUTDIR)qbsp
$(OUTDIR)qbsp: $(addprefix qbsp/,$(QBSP)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

light: $(OUTDIR)light
$(OUTDIR)light: $(addprefix light/,$(LIGHT)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

vis: $(OUTDIR)vis
$(OUTDIR)vis: $(addprefix vis/,$(VIS)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

bspinfo: $(OUTDIR)bspinfo
$(OUTDIR)bspinfo: $(addprefix bspinfo/,$(BSPINFO)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

modelgen: $(OUTDIR)modelgen
$(OUTDIR)modelgen: $(addprefix modelgen/,$(MODELGEN)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lpng -lz -lm

skinless: $(OUTDIR)skinless
$(OUTDIR)skinless: $(addprefix modelgen/,$(SKINLESS)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

qcc: $(OUTDIR)qcc
$(OUTDIR)qcc: $(addprefix qcc/,$(QCC)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

qfiles: $(OUTDIR)qfiles
$(OUTDIR)qfiles: $(addprefix qfiles/,$(QFILES)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm

qlumpy: $(OUTDIR)qlumpy
$(OUTDIR)qlumpy: $(addprefix qlumpy/,$(QLUMPY)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lpng -lz -lm

sprgen: $(OUTDIR)sprgen
$(OUTDIR)sprgen: $(addprefix sprgen/,$(SPRGEN)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lpng -lz -lm

texmake: $(OUTDIR)texmake
$(OUTDIR)texmake: $(addprefix texmake/,$(TEXMAKE)) $(COMMON)
	$(CC) $(LDFLAGS) -o $@ $^ -lm


COMMON_OBJ=bspfile.o cadlib.o cmdlib.o lbmlib.o mathlib.o polylib.o qmalloc.o scriplib.o threads.o trilib.o wadlib.o work.o

common/common.a: $(addprefix common/,$(COMMON_OBJ))
	$(AR) rcus common/common.a $^

