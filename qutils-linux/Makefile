INCLUDES = -Icommon
BINDIR = bin
CFLAGS = -O1
LDFLAGS = -lm

ifdef DEBUG
	CFLAGS += -g -ggdb
endif

all: prepare_ bspinfo_ light_ modelgen_ qbsp_ qcc_ qfiles_ qlumpy_ sprgen_ texmake_ vis_

prepare_:
	mkdir -p $(BINDIR)

bspinfo_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/bspinfo common/bspfile.c bspinfo/bspinfo.c common/cmdlib.c $(LDFLAGS) 

light_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/light common/trilib.c light/threads.c common/mathlib.c light/light.c light/entities.c common/bspfile.c light/ltface.c common/cmdlib.c light/trace.c $(LDFLAGS) 

modelgen_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/modelgen common/mathlib.c common/cmdlib.c common/lbmlib.c common/trilib.c common/scriplib.c modelgen/modelgen.c $(LDFLAGS) 

qbsp_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/qbsp common/mathlib.c qbsp/solidbsp.c qbsp/portals.c qbsp/surfaces.c qbsp/nodraw.c common/cmdlib.c qbsp/csg4.c qbsp/brush.c qbsp/merge.c qbsp/map.c qbsp/region.c common/bspfile.c qbsp/writebsp.c qbsp/outside.c qbsp/qbsp.c qbsp/tjunc.c $(LDFLAGS)

qcc_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/qcc qcc/pr_lex.c qcc/qcc.c common/cmdlib.c qcc/pr_comp.c $(LDFLAGS)

qfiles_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/qfiles qfiles/qfiles.c common/cmdlib.c $(LDFLAGS)

qlumpy_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/qlumpy qlumpy/quakegrb.c qlumpy/qlumpy.c common/wadlib.c common/scriplib.c common/cmdlib.c common/lbmlib.c $(LDFLAGS)

sprgen_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/sprgen common/scriplib.c sprgen/sprgen.c common/cmdlib.c common/lbmlib.c $(LDFLAGS) 

texmake_:
	$(CC) $(CFLAGS) $(INCLUDES) -o $(BINDIR)/texmake common/mathlib.c common/cmdlib.c common/lbmlib.c common/trilib.c texmake/texmake.c $(LDFLAGS) 

vis_:
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) -o $(BINDIR)/vis vis/soundpvs.c vis/vis.c common/bspfile.c vis/flow.c common/cmdlib.c common/mathlib.c $(LDFLAGS) 

clean:
	rm -rf $(BINDIR)
