# Notes on compiling and current state
Sling is cross platform for Windows and Linux-based systems. It is garunteed to work on Debian, as that's what I developed this on. MacOSX is also avaliable, but I have not tested it and am not looking to support it. It uses C, so `make`, `cc`, and standard compiling libraries are required automatically. Right now, I know that you are able to compile working Linux and Windows binaries on Linux, however I have not tried to compile on Windows.

# Compiling Requirements

## Linux compiling requirements
Your system will need SDL2 development files and libraries, as well as standard c compiling packages, applications, and libraries.

In Debian 9, SDL2 development libraries can be installed by executing the following as root:
`apt install libsdl2-dev`

# Compiling on Linux based systems

To compile sling:

1. `cd slingsource/Quake`
2. `make`, or `make sling`
3. You should be done! The `sling` binary will have been automatically copied to the root sling directory next to `slingbase/`, and will have been placed in the source directory as well.
4. To reduce disk usage or if you are not developing, running `make clean` will delete all of the object files as well as `sling` in the source directory.
