A Quake mapping devkit by dumptruck_ds and iw
Version 2.0.0
www.quakemapping.com
lango.lan.party@gmail.com
2020-12-30

******************************************************
******************************************************

REPORT ANY BUGS ON GITHUB HERE:
https://github.com/dumptruckDS/progs_dump_qc/issues

OR ON THE QUAKE MAPPING DISCORD HERE:
https://discordapp.com/invite/j5xh8QT

******************************************************
******************************************************

ALWAYS START A NEW FOLDER WHEN USING THIS MOD. 
DO NOT COPY THESE FILES OVER AN EXISTING VERSION
OF THE MOD.

******************************************************
******************************************************

NOTE: If you use this DevKit, your project should be 
released as a stand-alone mod and installed into its
own folder in the Quake directory.

DO NOT include any sample maps in your mod.

You may not use ANY content in this DevKit for
commercial purposes. All derivative works must
remain free of charge.

******************************************************
******************************************************

***Please read the PDF manual for detailed information.***

INSTALLATION:

Unzip this archive into your Quake directory.
This should create a folder called pd_200
Run Quake with the following command line:

-game pd_200 +map start

or run Quake as usual and type

game pd_200

in the console and hit enter. Then use the menu to start a new game.

If you are using Darkplaces or FTEQW the command is:

gamedir pd_200

or use Simple Quake launcher to launch Quake with pd_200 as the selected
mod. https://github.com/m-x-d/Simple-Quake-Launcher-2/releases

Take a tour and play the included sample maps. The sources are included for
your reference. pd_200.wad contains all textures from the sample maps.

Use the included FGD files with TrenchBroom or JACK or the DEF file.
A special FGD titled pd_200_TB_custom_mdls will allow you to see
custom models in the 3D view in TrenchBroom but the models will not appear
in the entity browser.

==============================================================================

This is a compilation of QuakeC code from various sources. Use at your own risk. 
PLEASE contact me if you use progs_dump for a project, I'd love to see your work!

                                                              -dumptruck_ds

The source for this mod is included and can be found on Github:
https://github.com/dumptruckDS/progs_dump_qc

==============================================================================
progs_dump requires a modern Quake engine and was developed with Quakespasm.
==============================================================================

Recommended Quake Source Ports:

Quakespasm (0.93.2 and above)
http://quakespasm.sourceforge.net/download.htm

Mark V (1099 release 4 or above)
http://quakeone.com/markv/

vkQuake (1.05.1 or above)
https://github.com/Novum/vkQuake/releases

Quakespasm-Spiked (0.93.2 and above)
http://triptohell.info/moodles/qss/

FTEQW (5790 or above)
http://fte.triptohell.info/index.php?p=downloads

Other source ports:

Darkplaces (tested version is August 29, 2017 Build)
*** DarkPlaces is not recommended for use with progs_dump ***
http://icculus.org/twilight/darkplaces/files/?C=M;O=D

==============================================================================
Known issues:

Currently this devkit is untested and unsupported in COOP

Cutscene viewport will stutter when mouse is moved in Quakespasm-Spiked,
FTEQW and vkQuake. Quakespasm and Mark V are the best choices for cutscenes.

in Quakespasm-Spiked, Sleeping Zombies in pd_zombies spawn incorrectly 
but will not effect game play. As a workaround do not cover sleeping zombies with 
any brushes if they are touching the monster.

Rendering issues in certain FTEQW presets. We recommend using "Spasm, Vanilla"
or "Normal" Graphics Presets in the Option menu.

targeted func_fall entities do not work properly in DarkPlaces
movedir in some particle entities does not work properly in DarkPlaces

targeted func_fall2 entities may have unpredictable physics in FTEQW

prefab_spawner.map is not listed in the sample maps section of the manual

==============================================================================

Distribution / Copyright / Permissions (verbiage courtesy of Arcane Dimensions)
------------------------------------------------------------------------------

Please do not use any of these assets in ANY COMMERCIAL PROJECT.
and remember to give credit if you use any of these assets.

The QC files in this MOD are based on 1.06 source files by ID Software.
These files are released under the terms of GNU General Public License v2 or
later. You may use the source files as a base to build your own MODs as long
as you release them under the same license and make the source available.
Please also give proper credit. Check http://www.gnu.org for details.

Quake I is a registered trademark of id Software, Inc.

All of these resources may be electronically distributed only at
NO CHARGE to the recipient in its current state and MUST include this
readme.txt file.

===========================================================================
