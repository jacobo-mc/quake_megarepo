# sling
A cross-platform momentum based first-person speedrunning/puzzle game made in the quakespasm engine. May or may not hurt your eyes. Proudly developed on Debian.

# About
Sling was a Quake mod that I made around 2015. The game revolves around controlling your momentum to get through a level as fast as possible. I thought it was an interesting idea, and could be a great game if given enough polish. Over a few years, I learned the ins and outs of the Quake engine, and then got started on making assets, levels, and code. The engine is derived from QuakeSpasm version 0.92, and I have made minor changes to work better with Sling, such as removing the client's ability to connect to external servers. I made it in QuakeSpasm because I am too lazy to learn a new engine, and I thouroughly enjoy the physics in Quake and how it controls. It is also really easy to port to different systems. In theory, this client is Quake compatible, but that is not it's intention and I strongly reccomend not using Sling as a Quake or QuakeSpasm replacement. I am making this game open source under the GPLv2.0 licence, so you are free to modify the game to your heart's content and publish it, just please give me credit (Quentin Jankosky). I hope you have fun playing it when it is at an acceptable state.

# Thanks
I would like to give thanks to Ericw, as he is the one who has made a majority of the tools as well as the engine used for making this game. I would also like to thank all of my friends that put up with my shit to try Sling out and tell me what they thought. I would like to thank John Carmack, John Romero, and the entirety of the original id team for making such amazing games and technologies. I would like to thank the community of QuakeOne.com, as they awnsered many of the questions I have had learning how to manipulate Quake. I would also like to thank Cobalt for teaching me QuakeC, as without him, this would have never have been made.

# Credits
Anyone who contributes may have their name edited into the credits.

Credits:
- Quentin Jankosky/SpecialBomb: Textures, Maps, Code, Concept

More to come?

___

# Directories

## slingbase
`slingbase/` is the directory that contains the gamefiles. It is functionally similar to `id1/` in Quake. It contains the source game files that are open to edit. It also contains the map source files, which are editable in a Quake map editor, such as trenchbroom or netradiant. The textures are also in there, as well as a wad for editing and making maps. The QuakeC source is also there for compiling the game progs.

## slingsource
`slingsource/` is the directory that contains the engine files for compiling (for more on compiling, read COMPILING.md). the `Quake/` directory contains all of the code for compiling. `Windows/` contains all of the files needed to run the game on windows, including DLLs. `Misc/` contains files derived from QuakeSpasm, and aren't used.

# Tools Used
I used many tools to make Sling:
- **TrenchBroom** (Quake map editor.)
- **GIMP** (Image editor.)
- **qpakman** (Used for making `.pak` and `.wad` files. Available on github.)
- **Geany** (IDE and text editor.)
- **ericw tyrutils** (Used for compiling Quake maps for Sling. Available on github.)
- **Image Magick** (Used for mass image conversion.)
- **TexMex** (used for `.wad` editing)
- **Fimg** (used for editing all of quake's weird image formats)

If you are looking to modify/develop Sling or make levels, I highly reccomend getting these tools and learning to use them. Almost all of them are cross platform, besides qpakman, which is for Linux systems. However, Windows has a much better selection when it comes to `.pak` and `.wad` editors, so you shouldn't be hindered if you use Windows.

# Required Linux Packages/Libraries
Your system will need libraries for SDL2.

In Debian 9, SDL2 libraries can be obtained by executing the following as root:
`apt install libsdl2-2.0-0`

# Required Windows DLLs
All of the needed Windows DLLs are included in `slingsource/Windows/`

Copy or move the following DLLs next to your `sling.exe` executable. Replace (x64/x86) to match your processor architechure:

- slingsource/Windows/SDL2/(lib/lib64)/SDL2.dll

