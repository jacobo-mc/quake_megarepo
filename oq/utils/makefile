
# Define all the project (directories) to build
PROJECTS += mdl2map
PROJECTS += mesh2map 
PROJECTS += mkwad
PROJECTS += par
PROJECTS += pcx2lmp
PROJECTS += lmp2pcx
PROJECTS += qutils 
PROJECTS += toon
PROJECTS += tri2map
PROJECTS += tyrlite

.PHONY : $(PROJECTS)

all : $(PROJECTS)

#
# for each project, run "make" in the directory by that name
#
$(PROJECTS) : bin
	$(MAKE) -C $@

#
# Make the "bin" directory at the top-level so that each project
# doesn't have to create the directory in a platform-specific way
# (with either ../bin or ..\bin).
#
bin :
	mkdir $@

#
# For each project, define a "project.clean" target the cleans
# that directory.
#
CLEANTARGETS = $(addsuffix .clean, $(PROJECTS))

clean : $(CLEANTARGETS) ;

%.clean :
	$(MAKE) -C $* clean

