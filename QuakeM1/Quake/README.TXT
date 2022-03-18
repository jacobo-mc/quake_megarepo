Welcome to Quake!

This file details how to get Quake running on your system and what to do
if you have problems.  We would like to thank Gandalf Technologies, Inc and
MPath Interactive for the use of their technology.  We would also like to
thank Trent Reznor and Nine Inch Nails for their tremendous contributions
to Quake's entire audio portion.

The NIN logo is a Registered Trademark licensed to Nothing Interactive, Inc.
All Rights Reserved.


Quake System Requirements
-------------------------
IBM PC and Compatibles
Pentium processor or better (absolutely must have a Math CoProcessor!)
VGA Compatible Display or better
DOS Operation:  8MB RAM minimum, 16MB recommended
Windows 95 Operation:  16MB RAM minimum, 24MB+ recommended
CD-ROM drive Required
MS-DOS 5.0 or better, or Windows 95 (does NOT run under Windows NT)
Hard Drive Space Needed:  80 MB


*** IMPORTANT!:  Quake requires a floating point unit (math coprocessor).
Systems that do not have an FPU installed will not run Quake -- at all.  This
includes the now infamous "Pentium class performance, for less money" knock-
off chip.  If you have one of these babies, you know which one we're talking
about.

*** IMPORTANT Video Adapter Note! ***
On some ATI Mach32 cards, Quake can come up with a garbled video display.
This is due to a problem with the card in which 320x200 mode isn't
initialized correctly.  Workarounds include:

1) If running from Windows, start Quake from an icon, or from a windowed
(not fullscreen) MS-DOS prompt.  If Quake is already running and has
the garbled screen, press Alt-Enter twice to switch to the desktop and
back to fullscreen, and the screen will display properly.

2) If running from DOS, either put the line

vid_mode 1

in \quake\id1\autoexec.cfg, or, typing blind, press tilde ('~') to bring
down the console, type

vid_mode 1<enter>

and the screen will display properly.

=============================================================================
Here are the text files included with the registered version of Quake and
what they are:

README.TXT              This file
TECHINFO.TXT            Technical information on Quake's subsystems and
			their advanced use.
MANUAL.TXT              Text version of the printed game manual
LICINFO.TXT             Info on the various license files included with Quake
RLICNSE.TXT             Registered Quake end-user license
COMEXP.TXT              Commercial exploitation agreement
ORDER.TXT               How to order id Softwae games, delivered to your door
HELP.TXT                How to get help with Quake

=============================================================================

Running Quake
-------------
DOS:  To launch Quake from the DOS Prompt, go to the Quake directory and
simply type "QUAKE" <ENTER>. (no quotes)

Windows 95:  To launch Quake in single player mode, double click on the file
QUAKE.EXE From Windows Explorer.  To run Quake in Multi-Player mode using
the TCP/IP protocol, first check your network settings to ensure the
protocol is installed, then double click on the Q95.BAT file to launch the
game.  In this version (v1.06) there is a minor bug that could cause the
Q95.BAT file to exit the first time you run it, without running Quake.
Merely double-click on that file again and it should work.

Audio Setup
-----------
When using a Sound Card with Quake, there are a few setup steps which must
be taken.  First, the "BLASTER" environment variable setting must be in your
AUTOEXEC.BAT (or you can type it in manually from the MS-DOS command prompt).
Running the Sound Blaster utility DIAGNOSE.EXE will automatically configure
your sound card and put this statement in your AUTOEXEC.BAT file for you.
A typical blaster setting looks like this (although yours may vary):

SET BLASTER=A220 I5 D1 H5 P330 T6

If you want to play the audio track from the CD-ROM while playing Quake,
you must ensure that the audio cable from the CD-ROM is connected to the
sound card.

If you think your sound card is setup properly and it STILL doesn't work,
check to make sure that your BLASTER environment variable contains the
high DMA setting (H5 in the above example).

If you don't get sound while trying to play the audio track, check to see
if a small cable goes from the back of your CD-ROM player directly to your
sound card.  If the CD-ROM audio cable is connected to your sound board (or
the motherboard in some cases) and you STILL don't hear CD Audio coming from
your speakers, make sure the MIXER program has the CD volume turned up.
You will also need to run the CD-ROM driver MSCDEX.EXE.  Here is an example
of the files you should see (yours probably will vary) listed in your
CONFIG.SYS and AUTOEXEC.BAT (explanation is in parentheses):

CONFIG.SYS:

DEVICE=C:\PROSCSI\CDROM.SYS /D:PROCD01 (CD-ROM driver)

AUTOEXEC.BAT:

SET BLASTER=A220 I5 D1 H5 P330 T6 (sound environment variable setting)
C:\WINDOWS\COMMAND\MSCDEX.EXE  /D:PROCD01 /L:D (CD-ROM driver)


===================================================
UltraSound MAX and UltraSound PnP Support for Quake
===================================================

Before running Quake, make sure that your sound card works and your
environment variables are set correctly.

Other UltraSound Cards (ACE & Classic)
--------------------------------------
These drivers are not for the UltraSound ACE or UltraSound Classic
sound cards.  We have heard mixed reports that MegaEm or SBOS
have a chance of working with the UltraSound Classic but there is a
short sound F/X delay.

UltraSound PnP and PnP Pro
--------------------------
You must make sure that you do NOT have IWSBOS or MegaEm loaded. 

Setup
-----
Quake will automatically detect that the UltraSound Max or PnP
are installed. It does this by looking at the SET INTERWAVE (PnP)
and SET ULTRA16 (Max) environment variables.

Quake will use the settings found on the SET ULTRASND/ULTRA16 (Max)
and in the IW.INI (PnP) file to determine what port settings to use.

Troubleshooting Windows 95 (DOS Box)
------------------------------------
We recommend that you restart your computer in MS-DOS Mode.  DOS Box 
may or may not work, so use at your own risk.  

CD Audio Input
--------------
If you have not already enabled CD audio output by default you will
need to enable it.  For the UltraSound MAX you can run "ULTRINIT -EC".
For the UltraSound PnP you will need to enable the CD audio output
in Win 95 and then restart your computer into MS-DOS.

===================================================

Mouse Setup
-----------
If you are going to use a mouse when playing Quake, you will need to load
your mouse driver.  This should go in the AUTOEXEC.BAT file as well.  Here
is an example:

C:\LOGITECH\MOUSE\MOUSE.EXE (mouse driver)


Booting Clean
-------------
If you are going to be running Quake with only 8 megabytes of RAM, it is best
to boot clean.  You eliminate unwanted utilities or applications from taking
up valuable memory, without having to alter your regular AUTOEXEC.BAT and
CONFIG.SYS. Booting clean can be done in one of two ways. If you have
MS-DOS version 6.xx, booting clean is as simple a pressing the shift key
when you see the words "Starting MS-DOS". If you have MS-DOS ver 5.xx you
will need to make a system disk.

To make a boot disk, insert a new floppy in your A: drive.  Then type the
following from the MS-DOS command prompt:

FORMAT A: /S

1. Make sure that this is a disk you wish to erase.
2. This disk absolutely HAS to be formatted in the A: drive.

To use the system disk, place the disk in the A: drive and reset the
computer.

NOTE: If your sound card requires a driver to be loaded, you will be using
a mouse, or you will be using Quake's CD audio feature, the system disk will
need to have a CONFIG.SYS and AUTOEXEC.BAT that load the appropriate drivers.
You can copy these files from C:\ to A:\ and then edit the files on the A:
drive, leaving only the drivers you must have.

Creating a Quake Shortcut
-------------------------
As an alternative to making a Boot Disk, Windows 95 users can create a
Quake Shortcut.  By double clicking on this shortcut, Windows 95 will reboot
in MS-DOS mode and install only the desired drivers, giving you the same
results as using a Boot Disk.  To create a Quake Shortcut, do the following:

1.  Using Explorer, right click and drag the file QUAKE.EXE, from the Quake
    directory, to your desktop.  Windows will pop up a menu, choose "Create
    Shortcut(s) Here", and Windows will make an MS-DOS Icon titled "Shortcut
    to quake".
2.  Right click on the new icon, and from the menu that pops up, choose
    "Properties".  Then choose the "Program" tab at the top.
3.  Now click on the "Advanced..." button near the bottom.  The "Advanced
    Program Settings" window should appear.
4.  Select the "MS-DOS mode" check box and the "Specify a new MS-DOS
    configuration" option button.
5.  Now simply fill in the "CONFIG.SYS for MS-DOS mode:" and "AUTOEXEC.BAT
    for MS-DOS mode:" boxes with the same sound, CD-ROM and mouse settings as
    mentioned above in the Boot Disks section.
6.  Click on "OK" when you are finished.  If you wish, you can change your
    Quake Shortcut Icon to something a little more exciting by clicking on
    "Change Icon...".
7.  To finish, click on "OK" again.
8.  You can rename your Quake Shortcut by right clicking on the shortcut
    icon, choosing "Rename" and typing in the new name.


======================================================
==                  Known Problems                  ==
======================================================

Problem: Zombies sometime get stuck on the ground and connot get back up.
(You can still hear them, but you cannot kill them. This bug makes it
impossible to get 100% kills on whatever level it occurs on.)
Solution:  There is no workaround for this bug.

Problem:  It is sometimes possible for the player to get stuck in a room or
in a wall.
Solution: If you get stuck, use the 'kill' console command.  It is a good
idea to save your game often.

Problem:  View centering problems.  Sometimes during a game, the view will
not center properly.  The end result is the player view looking up torwards
the ceiling while walking.
Solution:  Exit to the next level or use the 'kill' console command.


======================================================
==                 Troubleshooting                  ==
======================================================

If Quake fails to start up, or has problems not addressed elsewhere in the
documentation, try the -safe command line switch, which disables a number
of parts of Quake that can be problems if there are hardware or configuration
problems.  The -safe command line switch is equivalent to -stdvid, -nosound,
-nonet, and -nocdaudio together.  Those four switches do the following:

-stdvid:  disables VESA video modes.

-nosound:  disables sound card support.

-nonet:  disables network card support.

-nocdaudio:  disables CD audio support.

If -safe makes the problem go away, try using each of the switches
individually to isolate the area in which you're experiencing the problem,
then either correct the configuration or hardware problem or play Quake with
that functionality disabled.

If you still have problems, try booting clean in conjunction with
the -safe command line parameter.  For information on booting clean, refer
to the "Booting Clean" section above.

If you experience page faults while running Quarterdeck's QDPMI DPMI server,
this is caused by a bug in QDPMI.   Workarounds:  Remove QDPMI from
CONFIG.SYS, issue the command QDPMI OFF before running QUAKE, or get the
update patch for QDPMI from Quarterdeck.  You may be running QDPMI without
knowing it if you have QEMM installed, because it can be installed as part
of the QEMM installation.


Technical Support
-----------------
Please refer to the file HELP.TXT for an explination on all the Technical
Support options available.


======================================================
==                 Version History                  ==
======================================================
v1.06 -- Bugs fixed
----------------------------------------------------------------------------
The following general problems were fixed in v1.06:
* Increased the number of edges, so walls don't vanish in E1M8 when viewing
  the walls from certain angles in high resolutions.
* Locking the NULL pointer protection page should no longer prevent Quake
  from running under CWSDPMI r3 and 386MAX.
* Video mode corruption was reported and Quake would exit if
  '_vid_default_mode' in config.cfg was not a valid video mode.  Quake now
  defaults to 320x200 if an invalid default video mode is listed.  (This was
  usually the result of switching from UniVBE 5.2 to 5.3, which supports
  fewer modes than 5.2).
* 'Working_size' was not being pre-adjusted up by 64K in the memory
  allocation loop.  This may provide 64K more memory on some systems.
* The crosshair variable is now saved in config.cfg.
* If you already have cell ammo of 100, you can't pick up more cell ammo.
* If you discharged the thunderbolt in the water your cells are no longer
  dropped with your backpack.  (Reason:  By discharging in the water, your
  cells should be fully depleted.)  Only wussies do this as a paniced, last
  ditch effort anyway, unless they have the Pentagram of Protection, so this
  really shouldn't affect you anyway :)
* Added support for input devices (i.e. Wingman Warrior, Spaceball, and Assassin).
* Crosshair is drawn at the correct location if you are underwater in high
  resolution video modes.
* Spaces were being added to key bindings when reading in the config.cfg,
  and where then written back out to the config.cfg.  This caused the
  bindings to keep growing until it eventually caused a crash.
* Binding to ";" is now written to config.cfg properly.
* Unbound keys are no longer written to config.cfg.
* Fixed the axe's aiming.  It wasn't always correct causing false hits and
  misses.
* Added cycle weapon backwards (impulse 12).
* Picking up a weapon in a backpack uses the same rules as picking up a
  weapon any other time.
* Fixed a lot of the obituaries.  Many deaths were getting inappropraite
  messages.  There are still a few errors that can occur when reporting
  projectile obituaries.
* The lightning gun is never considered your best weapon when you are
  underwater.
* You can now bind the semicolon from the menu.
* CD audio volume acts oddly with certain drives.
* Timedemo was not showing the timings at the end.
* Made not being able to write a PCX file a warning instead of a sys_error.
* Notify what weapon picked up in backpack in addition to ammo.
* New GUS code:  supports GUS Classic & fixed playback rate.
* Made the size of the zone a command line parameter.  You specify -zone
  followed by a size in KB.  The default is 48.
* Corrected a problem where discharging the lightning gun in water would
  sometimes leave you in a 'zombie' state.  You would be dead, but unable to
  respawn or restart.

Well, just two lonely single player fixes in v1.06:
* You no longer can kill Shub the wrong way, which would cause Quake to
  crash.
* No longer prints "player exited the level" in single player.

The following multi-player and server problems were fixed in v1.06:
* Player-names with spaces were listed as "unconnected" on the server.
* 'Mod_NumForName: <something> not found' when connecting to a server.
* The server was getting stuck on the Start Level when the 'noexit 1' was
  set.  The following changes/additions have been made: 
      a.  Now, 'timelimit' and/or 'fraglimit' must be set, when 'noexit' is
      set to '1', or there is no way to exit the level.  The server will run
      through all four episodes (shareware will only play episode 1).  The
      End Level is not included, since it's not a very good Deathmatch level.
      b.  There is now 'noexit 2'.  This WILL allow any player to exit the
      Start level, but no one can exit any other level.  You must have 
      'fraglimit' and/or 'timelimit' set to use 'noexit 2' also.  Essentially
      this allows the players to choose an episode, but once the first level
      of that episode starts, they can't exit levels until the 'fraglimit' or
      'timelimit' is reached.

* End Level in Deathmatch will now advance to Start Level, once the
  'timelimit' or 'fraglimit' is reached.
* If a player is dead during a level change, they no longer keep their
  weapons/ammo, when the next level is started, they start with nothing.
* Having a percent sign in a chat message will no longer page fault the
  server you are connected to.
* Player's cell ammo is not carried over to the Start Level.
* It is no longer possible to 'kill' secret doors.  Previously this would
  cause the server to crash with a 'host_error'.
* Added IPX support to Winded (Win32 Dedicated Server).
* Ranking screen is centered in high resolution modes now.
* Game drops to console, instead of crashing, when a net game fails to load.
  These failures are generally due to trying to connect to a server running
  a level you do not have.
* Added teamplay 2.  It differs from teamplay 1 in two ways.  You can hurt
  teammates (and yourself) and you lose 1 frag for killing a teammate.
* Fixed a hole where a fake client was able to change cvars and execute
  Quake console commands on remote servers.
* 'Showscores' works in total full screen now (no menu bar at all).
* Doing 'restart' or 'edict' when a server isn't running does not crash.
* Fixed a lockup when multiplayer was selected, but there were no
  communications available
* Spawn and respawn telefrags:
       a.  When spawning (or respawning) it will now search and find any open
       start spot, not just blindly go to the next one.
       b.  You will only telefrag somebody if every single spot is occupied,
       in which case the last person in gets whacked.  This keeps you from
       getting right back into the rolling telefrags at the start of a level
       and gives the first players in a chance to get off of the spots.
       c.  Teleporter telefrags have not been changed.
* Added 'kick' by number (similar to painting by number, only much more fun)
  so people with "funny" names can be removed from the server easily.
  (Bane inadvertently assisted in testing this one ;-)
  Usage:  "kick   #   <number>", get <number> by using the 'status'command.
* After selecting a game in the 'Search for local games' list, that is full,
  Quake no longer drops back to the console, it remains on the local games
  list screen.
* The modem code as been tweaked, so modem to modem play should work better.
* 'Port number' works now, without having to run 'Quake -udpport #'.
       a.  'Port number' box on the multiplayer/join game menu works.
       b.   In the multiplayer/join game menu 'connect to' box, you can type
       in the IP address followed by the port, separated by a colon.
       i.e. '127.0.0.1:26010' (no quotes)
       c.  From the console you can type "connect 127.0.0.1:26010", WITH THE
       QUOTES (otherwise the parser would pick up the colon as a seperator).
----------------------------------------------------------------------------
v1.02 -- Bugs fixed
----------------------------------------------------------------------------
* Had to remove one ambient track from CD for retail
* Rewrote "please register" text on start.map
----------------------------------------------------------------------------
v1.01 -- Bugs fixed
----------------------------------------------------------------------------
* Fixed modem code
* Fixed fraglimit & timelimit
* Added NOEXIT cvar (so no one can exit a level)
----------------------------------------------------------------------------
v1.00 -- Bugs fixed
----------------------------------------------------------------------------
* Gravis Ultrasound audio support (still has bugs)
* More deathmatch start spots on E1M6 and END
* Print server version and PROG CRC on connect
* -dedicated starts start.map if nothing else specified
* fixed lookspring function during net game
* fixed rare crash during long running dedicated server
----------------------------------------------------------------------------
v0.94 -- Bugs fixed / Features added -- LIMITED BETA VERSION
----------------------------------------------------------------------------
* Totally rewritten menus
* New lighting model with overbrighting
* Parsed lowercase BLASTER parms
* Better Sound Blaster shutdown code
* Rewrote BLASTER initialization
* Fixed DMA channel 0 bugs
* Added SBPro 8 stereo setup
* Fix delayed sound on 8 bit Sound Blasters
* Fixed speed key affecting angle-turning from keyboard
* Fixed "no such Alias frame" bugs
* Fixed Zombie not getting up bug
* Checked for very high joystick values, signalling a failed read
* Unstuck jumping Fiends and Spawn
* Fixed large BModels blinking out in complex areas
* Fixed s_localsound with no sound started
* Saved spawn parms in savegame
* Fixed screenshot save location
* Bind with no arguments no longer clears value
* Allow console in intermission / finale
* Fixed false gib messages
* Full-screen TAB scoreboard in DeathMatch
* Fixed "+playdemo <demo>" from command line
* Trapped overflow in sizebuf messages
* Moveup / movedown in water!
* Fixed-up Talk command
* Added unsupported crosshair option ("crosshair 1" from console)
* Colored chat messages with notify sound
* Fixed "connect during intermission" bug
* Changelevel while demos running no longer crashes
* Fixed changelevel with no map left up loading screen
* Fixed long names entered from the console causing crash
* Stopped demos changing while in the menus
* Fixed modem initialization from menu
* Fixed serial reliable stream getting stalled
* Serial/modem code fixes
	16550a lost transmit buffer empty interrupts
	fixed sometimes processing interrupts from com1 when using com2
	added com3/com4 support from menus
	fixed first character of modem init not getting sent
	saved serial/modem settings in config.cfg
* Fixed name and colors not always sent to server at startup
* Fixed "stopdemo" crashing the system when there wasn't a demo playing
* Added server's TCP/IP and IPX addresses (if available) to status command

* In 0.92, an additional check for a usable VESA video mode was added;
the numpages field was verified to be greater than 0, and no mode was
supported that had numpages set to 0 (which indicates that there's not
enough video memory for that mode).  ATI's VESA driver, m64vbe,
reports 0 for numpages, so VESA video modes that were available in 0.91
were no longer available in 0.92.  This extra numpages check has
been removed.

----------------------------------------------------------------------------
v0.93 -- Never officially released; internal testing only.
----------------------------------------------------------------------------
v0.92 -- Bugs fixed
----------------------------------------------------------------------------
* Typing long strings in the hostname or modem init field in the menus caused
  crashes.
* Under Win95 IPX was detected but not functional, resulting in the game
  exiting to DOS.
* If -nosound, got "S_LocalSound: can't cache" on every keypress in the menu.
* When vid_nopageflip was set to 1 in VESA modes, going underwater resulted in
  only the upper left corner of the drawing area being updated.
* The single player scoreboard (tab) printed text incorrectly in all modes
  greater than 320 pixels wide.
* On network connections that dropped packets, the reliable message stream
  could get stopped up, resulting in frag counts and talk messages no longer
  being delivered, although game movement continued.
* The com port settings from the menu were getting saved & restored but
  not used.
* Direct serial connections did not work with slist.
* Quake now checks the vesa information for hardware incabable of page-flipping.
* Menu sound sometimes didn't play.
* Q95 (qlaunch.exe) frequently failed to execute on the first attempt.
* Q95 (quakeudp.dll) was running out of buffers when running a server.
* Teams were not being set according to pants colors.
----------------------------------------------------------------------------
Joystick notes
--------------
Your joystick must be plugged in when Quake is launched.

If you have a joystick plugged in, but don't want to use it in Quake
(it slows the game down a few percent), or you have weird hardware that
doesn't like being tested as a joystick add "-nojoy" to your Quake
command line.

You can turn off joystick reading during the game by typing "joystick 0" at
the Quake command console.

You MUST configure your buttons from the configure keys menu before they will
work.  There is no default configuration. 

If your joystick or interface card improperly sets the third or fourth
joystick buttons, type "joybuttons 2" at the quake console or in your
.CFG file.

The "mlook" button command now lets the joystick as well as the mouse control
pitch angles.

The "sidestep" buttom command works on joysticks as with mice and keyboard
movement.

The "invert mouse up/down" menu option also inverts the joystick pitch
direction.
