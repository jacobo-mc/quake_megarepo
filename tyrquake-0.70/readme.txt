-----------
 Tyr-Quake
-----------

Date:		2022-02-19
Version: 	0.70
Author:		Kevin Shanahan (aka. Tyrann)
Webpage:	http://disenchant.net
email:		kevin@shanahan.id.au

Why?
----
I want this to be a version of Quake that basically looks like the
Quake of old, but one that works on current operating systems.  Some
graphical enhancements may be added, as long as they don't completely
change the look and feel of the original game.

Building:
---------
All you should need to do to get a regular build for your system is type
'make'. This should build all five executable targets and place them in a
./bin subdirectory.

Windows builds can be done using MinGW64 and Msys2 on a Windows host, or by
cross compiling with a suitable MinGW cross compiler.  The build also relies
on groff to process the documentation and imagemagick to generate the
icons. As long as your cross compiler is in your path somewhere, "make
TARGET_OS=WIN32" (or WIN64) should be all you need.  Parallel builds work well
too, e.g. "make -j8"

If you're in a hurry and only want to build one target, you can type 'make
bin/<target>' - where <target> is the name of the executable you want to
build.

To build a debug version or one without the intel assembly, there are options
you can select by setting Makefile variables:
  e.g. make DEBUG=Y bin/tyr-glquake
    or make USE_X86_ASM=N bin/tyr-qwcl

On OSX, you will need XCode and the SDL2 framework installed to build.
Install the SDL2 framework to /Library/Frameworks/, then in the tyrquake
directory simply type "make bundles".  The OSX bundles will be output to
dist/osx/.  The OSX launcher needs a little more polish, but the main thing
remember is to add '-basedir /path/to/Quake' to the command line parameters in
the Launcher.

History:
--------
See changelog.txt for the summary of changes in each release version.
For full details, see: https://disenchant.net/git/tyrquake.git/
