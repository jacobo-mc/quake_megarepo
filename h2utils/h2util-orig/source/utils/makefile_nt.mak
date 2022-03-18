# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103
# TARGTYPE "Win32 (x86) External Target" 0x0106
# TARGTYPE "Win32 (ALPHA) Console Application" 0x0603

!IF "$(CFG)" == ""
CFG=light - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to light - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "makefile_nt - Win32 Release" && "$(CFG)" !=\
 "makefile_nt - Win32 Debug" && "$(CFG)" != "qbsp - Win32 Release" && "$(CFG)"\
 != "qbsp - Win32 Debug" && "$(CFG)" != "vis - Win32 Release" && "$(CFG)" !=\
 "vis - Win32 Debug" && "$(CFG)" != "vis - Win32 (ALPHA) Debug" && "$(CFG)" !=\
 "vis - Win32 (ALPHA) Release" && "$(CFG)" != "qbsp - Win32 (ALPHA) Debug" &&\
 "$(CFG)" != "qbsp - Win32 (ALPHA) Release" && "$(CFG)" !=\
 "light - Win32 Release" && "$(CFG)" != "light - Win32 Debug" && "$(CFG)" !=\
 "light - Win32 (ALPHA) Release"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "makefile_nt.mak" CFG="light - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "makefile_nt - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "makefile_nt - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE "qbsp - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qbsp - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "vis - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "vis - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "vis - Win32 (ALPHA) Debug" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE "vis - Win32 (ALPHA) Release" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE "qbsp - Win32 (ALPHA) Debug" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE "qbsp - Win32 (ALPHA) Release" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE "light - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 (ALPHA) Release" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "qbsp - Win32 (ALPHA) Debug"

!IF  "$(CFG)" == "makefile_nt - Win32 Release"

# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP BASE Cmd_Line "NMAKE /f makefile_nt.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "makefile_nt.exe"
# PROP BASE Bsc_Name "makefile_nt.bsc"
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# PROP Cmd_Line "NMAKE /f makefile_nt.mak"
# PROP Rebuild_Opt "/a"
# PROP Bsc_Name "makefile_nt.bsc"
OUTDIR=.\Release
INTDIR=.\Release

ALL : 

CLEAN : 
	-@erase 

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

!ELSEIF  "$(CFG)" == "makefile_nt - Win32 Debug"

# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP BASE Cmd_Line "NMAKE /f makefile_nt.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "makefile_nt.exe"
# PROP BASE Bsc_Name "makefile_nt.bsc"
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# PROP Cmd_Line "NMAKE /f makefile_nt.mak"
# PROP Rebuild_Opt "/a"
# PROP Bsc_Name "makefile_nt.bsc"
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : 

CLEAN : 
	-@erase 

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "qbsp\Release"
# PROP BASE Intermediate_Dir "qbsp\Release"
# PROP BASE Target_Dir "qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir "qbsp"
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\qbsp.exe" "$(OUTDIR)\qbsp.bsc"

CLEAN : 
	-@erase "$(INTDIR)\brush.obj"
	-@erase "$(INTDIR)\brush.sbr"
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\csg4.obj"
	-@erase "$(INTDIR)\csg4.sbr"
	-@erase "$(INTDIR)\map.obj"
	-@erase "$(INTDIR)\map.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\merge.sbr"
	-@erase "$(INTDIR)\nodraw.obj"
	-@erase "$(INTDIR)\nodraw.sbr"
	-@erase "$(INTDIR)\outside.obj"
	-@erase "$(INTDIR)\outside.sbr"
	-@erase "$(INTDIR)\portals.obj"
	-@erase "$(INTDIR)\portals.sbr"
	-@erase "$(INTDIR)\qbsp.obj"
	-@erase "$(INTDIR)\qbsp.sbr"
	-@erase "$(INTDIR)\region.obj"
	-@erase "$(INTDIR)\region.sbr"
	-@erase "$(INTDIR)\solidbsp.obj"
	-@erase "$(INTDIR)\solidbsp.sbr"
	-@erase "$(INTDIR)\surfaces.obj"
	-@erase "$(INTDIR)\surfaces.sbr"
	-@erase "$(INTDIR)\tjunc.obj"
	-@erase "$(INTDIR)\tjunc.sbr"
	-@erase "$(INTDIR)\writebsp.obj"
	-@erase "$(INTDIR)\writebsp.sbr"
	-@erase "$(OUTDIR)\qbsp.bsc"
	-@erase "$(OUTDIR)\qbsp.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /w /W0 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /G5 /MT /w /W0 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /FR"$(INTDIR)/" /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\Release/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\brush.sbr" \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\csg4.sbr" \
	"$(INTDIR)\map.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\merge.sbr" \
	"$(INTDIR)\nodraw.sbr" \
	"$(INTDIR)\outside.sbr" \
	"$(INTDIR)\portals.sbr" \
	"$(INTDIR)\qbsp.sbr" \
	"$(INTDIR)\region.sbr" \
	"$(INTDIR)\solidbsp.sbr" \
	"$(INTDIR)\surfaces.sbr" \
	"$(INTDIR)\tjunc.sbr" \
	"$(INTDIR)\writebsp.sbr"

"$(OUTDIR)\qbsp.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/qbsp.pdb" /machine:I386 /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\csg4.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\nodraw.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\region.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "qbsp\Debug"
# PROP BASE Intermediate_Dir "qbsp\Debug"
# PROP BASE Target_Dir "qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir "qbsp"
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\qbsp.exe" "$(OUTDIR)\qbsp.bsc"

CLEAN : 
	-@erase "$(INTDIR)\brush.obj"
	-@erase "$(INTDIR)\brush.sbr"
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\csg4.obj"
	-@erase "$(INTDIR)\csg4.sbr"
	-@erase "$(INTDIR)\map.obj"
	-@erase "$(INTDIR)\map.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\merge.sbr"
	-@erase "$(INTDIR)\nodraw.obj"
	-@erase "$(INTDIR)\nodraw.sbr"
	-@erase "$(INTDIR)\outside.obj"
	-@erase "$(INTDIR)\outside.sbr"
	-@erase "$(INTDIR)\portals.obj"
	-@erase "$(INTDIR)\portals.sbr"
	-@erase "$(INTDIR)\qbsp.obj"
	-@erase "$(INTDIR)\qbsp.sbr"
	-@erase "$(INTDIR)\region.obj"
	-@erase "$(INTDIR)\region.sbr"
	-@erase "$(INTDIR)\solidbsp.obj"
	-@erase "$(INTDIR)\solidbsp.sbr"
	-@erase "$(INTDIR)\surfaces.obj"
	-@erase "$(INTDIR)\surfaces.sbr"
	-@erase "$(INTDIR)\tjunc.obj"
	-@erase "$(INTDIR)\tjunc.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\writebsp.obj"
	-@erase "$(INTDIR)\writebsp.sbr"
	-@erase "$(OUTDIR)\qbsp.bsc"
	-@erase "$(OUTDIR)\qbsp.exe"
	-@erase "$(OUTDIR)\qbsp.ilk"
	-@erase "$(OUTDIR)\qbsp.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MTd /w /W0 /Gm /Gi /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /G5 /MTd /w /W0 /Gm /Gi /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\brush.sbr" \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\csg4.sbr" \
	"$(INTDIR)\map.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\merge.sbr" \
	"$(INTDIR)\nodraw.sbr" \
	"$(INTDIR)\outside.sbr" \
	"$(INTDIR)\portals.sbr" \
	"$(INTDIR)\qbsp.sbr" \
	"$(INTDIR)\region.sbr" \
	"$(INTDIR)\solidbsp.sbr" \
	"$(INTDIR)\surfaces.sbr" \
	"$(INTDIR)\tjunc.sbr" \
	"$(INTDIR)\writebsp.sbr"

"$(OUTDIR)\qbsp.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/qbsp.pdb" /debug /machine:I386 /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\csg4.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\nodraw.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\region.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "vis\Release"
# PROP BASE Intermediate_Dir "vis\Release"
# PROP BASE Target_Dir "vis"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir "vis"
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\vis.exe" "$(OUTDIR)\vis.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\flow.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\soundpvs.obj"
	-@erase "$(INTDIR)\soundpvs.sbr"
	-@erase "$(INTDIR)\vis.obj"
	-@erase "$(INTDIR)\vis.sbr"
	-@erase "$(OUTDIR)\vis.bsc"
	-@erase "$(OUTDIR)\vis.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /O2 /Ob2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "__alpha" /FR /YX /c
CPP_PROJ=/nologo /G5 /MT /W3 /GX /O2 /Ob2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE"\
 /D "__alpha" /FR"$(INTDIR)/" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\Release/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\flow.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\soundpvs.sbr" \
	"$(INTDIR)\vis.sbr"

"$(OUTDIR)\vis.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /profile /machine:I386
# SUBTRACT LINK32 /verbose
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /profile /machine:I386 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "vis\Debug"
# PROP BASE Intermediate_Dir "vis\Debug"
# PROP BASE Target_Dir "vis"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir "vis"
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\vis.exe" "$(OUTDIR)\vis.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\flow.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\soundpvs.obj"
	-@erase "$(INTDIR)\soundpvs.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\vis.obj"
	-@erase "$(INTDIR)\vis.sbr"
	-@erase "$(OUTDIR)\vis.bsc"
	-@erase "$(OUTDIR)\vis.exe"
	-@erase "$(OUTDIR)\vis.ilk"
	-@erase "$(OUTDIR)\vis.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\flow.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\soundpvs.sbr" \
	"$(INTDIR)\vis.sbr"

"$(OUTDIR)\vis.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib uuid.lib /nologo /subsystem:console\
 /incremental:yes /pdb:"$(OUTDIR)/vis.pdb" /debug /machine:I386\
 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "vis\AlphaDbg"
# PROP BASE Intermediate_Dir "vis\AlphaDbg"
# PROP BASE Target_Dir "vis"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "AlphaDbg"
# PROP Intermediate_Dir "AlphaDbg"
# PROP Target_Dir "vis"
OUTDIR=.\AlphaDbg
INTDIR=.\AlphaDbg

ALL :  "$(OUTDIR)\vis.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MTd /Gt0 /W2 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MTd /Gt0 /W2 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\AlphaDbg/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:ALPHA
# SUBTRACT BASE LINK32 /incremental:no
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:ALPHA
# SUBTRACT LINK32 /incremental:no /nodefaultlib
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/vis.pdb" /debug /machine:ALPHA /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "vis\AlphaRel"
# PROP BASE Intermediate_Dir "vis\AlphaRel"
# PROP BASE Target_Dir "vis"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "AlphaRel"
# PROP Intermediate_Dir "AlphaRel"
# PROP Target_Dir "vis"
OUTDIR=.\AlphaRel
INTDIR=.\AlphaRel

ALL :  "$(OUTDIR)\vis.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\AlphaRel/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /profile /machine:ALPHA
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /profile /machine:ALPHA\
 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "qbsp\AlphaDbg"
# PROP BASE Intermediate_Dir "qbsp\AlphaDbg"
# PROP BASE Target_Dir "qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "AlphaDbg"
# PROP Intermediate_Dir "AlphaDbg"
# PROP Target_Dir "qbsp"
OUTDIR=.\AlphaDbg
INTDIR=.\AlphaDbg

ALL :  "$(OUTDIR)\qbsp.exe" "$(OUTDIR)\qbsp.bsc"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W2 /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /FR /YX /c
# SUBTRACT CPP /X /u
CPP_PROJ=/nologo /MLd /Gt0 /W2 /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE"\
 /FR"$(INTDIR)/" /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\AlphaDbg/
CPP_SBRS=.\AlphaDbg/

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\brush.sbr" \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\csg4.sbr" \
	"$(INTDIR)\map.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\merge.sbr" \
	"$(INTDIR)\nodraw.sbr" \
	"$(INTDIR)\outside.sbr" \
	"$(INTDIR)\portals.sbr" \
	"$(INTDIR)\qbsp.sbr" \
	"$(INTDIR)\region.sbr" \
	"$(INTDIR)\solidbsp.sbr" \
	"$(INTDIR)\surfaces.sbr" \
	"$(INTDIR)\tjunc.sbr" \
	"$(INTDIR)\writebsp.sbr"

"$(OUTDIR)\qbsp.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:ALPHA
# SUBTRACT BASE LINK32 /incremental:no
# ADD LINK32 /subsystem:console /debug /machine:ALPHA
# SUBTRACT LINK32 /nologo /verbose /incremental:no /nodefaultlib
LINK32_FLAGS=/subsystem:console /incremental:yes /pdb:"$(OUTDIR)/qbsp.pdb"\
 /debug /machine:ALPHA /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\csg4.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\nodraw.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\region.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "qbsp\AlphaRel"
# PROP BASE Intermediate_Dir "qbsp\AlphaRel"
# PROP BASE Target_Dir "qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "AlphaRel"
# PROP Intermediate_Dir "AlphaRel"
# PROP Target_Dir "qbsp"
OUTDIR=.\AlphaRel
INTDIR=.\AlphaRel

ALL :  "$(OUTDIR)\qbsp.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W2 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /YX /c
# SUBTRACT CPP /X /u
CPP_PROJ=/nologo /ML /Gt0 /W2 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE"\
 /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\AlphaRel/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
# ADD LINK32 /subsystem:console /machine:ALPHA
# SUBTRACT LINK32 /nologo /verbose /nodefaultlib
LINK32_FLAGS=/subsystem:console /incremental:no /pdb:"$(OUTDIR)/qbsp.pdb"\
 /machine:ALPHA /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\csg4.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\nodraw.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\region.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "light - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "light\Release"
# PROP BASE Intermediate_Dir "light\Release"
# PROP BASE Target_Dir "light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir "light"
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\light.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\entities.obj"
	-@erase "$(INTDIR)\light.obj"
	-@erase "$(INTDIR)\ltface.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(OUTDIR)\light.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/light.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/light.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:no /pdb:"$(OUTDIR)/light.pdb" /machine:I386\
 /out:"$(OUTDIR)/light.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\entities.obj" \
	"$(INTDIR)\light.obj" \
	"$(INTDIR)\ltface.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\trace.obj"

"$(OUTDIR)\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "light\Debug"
# PROP BASE Intermediate_Dir "light\Debug"
# PROP BASE Target_Dir "light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir "light"
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\light.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\entities.obj"
	-@erase "$(INTDIR)\light.obj"
	-@erase "$(INTDIR)\ltface.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\light.exe"
	-@erase "$(OUTDIR)\light.ilk"
	-@erase "$(OUTDIR)\light.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/light.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/light.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:yes /pdb:"$(OUTDIR)/light.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/light.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\entities.obj" \
	"$(INTDIR)\light.obj" \
	"$(INTDIR)\ltface.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\trace.obj"

"$(OUTDIR)\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "light\AlphaRel"
# PROP BASE Intermediate_Dir "light\AlphaRel"
# PROP BASE Target_Dir "light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "light\AlphaRel"
# PROP Intermediate_Dir "light\AlphaRel"
# PROP Target_Dir "light"
OUTDIR=.\light\AlphaRel
INTDIR=.\light\AlphaRel

ALL :  "$(OUTDIR)\light.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/light.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\light\AlphaRel/
CPP_SBRS=.\.

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/light.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/light.pdb" /machine:ALPHA /out:"$(OUTDIR)/light.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\entities.obj" \
	"$(INTDIR)\light.obj" \
	"$(INTDIR)\ltface.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\trace.obj"

"$(OUTDIR)\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

################################################################################
# Begin Target

# Name "makefile_nt - Win32 Release"
# Name "makefile_nt - Win32 Debug"

!IF  "$(CFG)" == "makefile_nt - Win32 Release"

".\makefile_nt.exe" : 
   CD F:\quake\utils\qbsp
   NMAKE /f makefile_nt.mak

!ELSEIF  "$(CFG)" == "makefile_nt - Win32 Debug"

".\makefile_nt.exe" : 
   CD F:\quake\utils\qbsp
   NMAKE /f makefile_nt.mak

!ENDIF 

# End Target
################################################################################
# Begin Target

# Name "qbsp - Win32 Release"
# Name "qbsp - Win32 Debug"
# Name "qbsp - Win32 (ALPHA) Debug"
# Name "qbsp - Win32 (ALPHA) Release"

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\writebsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

"$(INTDIR)\writebsp.sbr" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

"$(INTDIR)\writebsp.sbr" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

"$(INTDIR)\writebsp.sbr" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\bspfile.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\cmdlib.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\csg4.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\csg4.obj" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"

"$(INTDIR)\csg4.sbr" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\csg4.obj" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"

"$(INTDIR)\csg4.sbr" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\csg4.obj" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"

"$(INTDIR)\csg4.sbr" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\csg4.obj" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\map.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

"$(INTDIR)\map.sbr" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

"$(INTDIR)\map.sbr" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

"$(INTDIR)\map.sbr" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\mathlib.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\merge.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"

"$(INTDIR)\merge.sbr" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"

"$(INTDIR)\merge.sbr" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"

"$(INTDIR)\merge.sbr" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\nodraw.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\nodraw.obj" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"

"$(INTDIR)\nodraw.sbr" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\nodraw.obj" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"

"$(INTDIR)\nodraw.sbr" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\nodraw.obj" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"

"$(INTDIR)\nodraw.sbr" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\nodraw.obj" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\outside.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"

"$(INTDIR)\outside.sbr" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"

"$(INTDIR)\outside.sbr" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"

"$(INTDIR)\outside.sbr" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\portals.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"

"$(INTDIR)\portals.sbr" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"

"$(INTDIR)\portals.sbr" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"

"$(INTDIR)\portals.sbr" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qbsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"

"$(INTDIR)\qbsp.sbr" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"

"$(INTDIR)\qbsp.sbr" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"

"$(INTDIR)\qbsp.sbr" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\region.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\region.obj" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"

"$(INTDIR)\region.sbr" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\region.obj" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"

"$(INTDIR)\region.sbr" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\region.obj" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"

"$(INTDIR)\region.sbr" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\region.obj" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\solidbsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"

"$(INTDIR)\solidbsp.sbr" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"

"$(INTDIR)\solidbsp.sbr" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"

"$(INTDIR)\solidbsp.sbr" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\surfaces.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"

"$(INTDIR)\surfaces.sbr" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"

"$(INTDIR)\surfaces.sbr" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"

"$(INTDIR)\surfaces.sbr" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\tjunc.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"

"$(INTDIR)\tjunc.sbr" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"

"$(INTDIR)\tjunc.sbr" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"

"$(INTDIR)\tjunc.sbr" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\brush.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

"$(INTDIR)\brush.sbr" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

"$(INTDIR)\brush.sbr" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

"$(INTDIR)\brush.sbr" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

!ENDIF 

# End Source File
# End Target
################################################################################
# Begin Target

# Name "vis - Win32 Release"
# Name "vis - Win32 Debug"
# Name "vis - Win32 (ALPHA) Debug"
# Name "vis - Win32 (ALPHA) Release"

!IF  "$(CFG)" == "vis - Win32 Release"

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\vis.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_VIS_C=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"

"$(INTDIR)\vis.sbr" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_VIS_C=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"

"$(INTDIR)\vis.sbr" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_VIS_C=\
	".\vis.h"\
	

"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_VIS_C=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\soundpvs.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_SOUND=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"

"$(INTDIR)\soundpvs.sbr" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_SOUND=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"

"$(INTDIR)\soundpvs.sbr" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_SOUND=\
	".\vis.h"\
	

"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_SOUND=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\mathlib.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_MATHL=\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_MATHL=\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_MATHL=\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_MATHL=\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\flow.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_FLOW_=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"

"$(INTDIR)\flow.sbr" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_FLOW_=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"

"$(INTDIR)\flow.sbr" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_FLOW_=\
	".\vis.h"\
	

"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_FLOW_=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	".\vis.h"\
	

"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\cmdlib.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_CMDLI=\
	".\..\..\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_CMDLI=\
	".\..\..\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_CMDLI=\
	".\..\..\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_CMDLI=\
	".\..\..\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\bspfile.c

!IF  "$(CFG)" == "vis - Win32 Release"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	
# ADD CPP /GB

BuildCmds= \
	$(CPP) /nologo /GB /MT /W3 /GX /O2 /Ob2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE"\
 /D "__alpha" /FR"$(INTDIR)/" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /c\
 $(SOURCE) \
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

BuildCmds= \
	$(CPP) /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Debug"

DEP_CPP_BSPFI=\
	".\..\..\bspfile.h"\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

!ELSEIF  "$(CFG)" == "vis - Win32 (ALPHA) Release"

DEP_CPP_BSPFI=\
	".\..\..\bspfile.h"\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"

!ENDIF 

# End Source File
# End Target
################################################################################
# Begin Target

# Name "light - Win32 Release"
# Name "light - Win32 Debug"
# Name "light - Win32 (ALPHA) Release"

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\cmdlib.c

!IF  "$(CFG)" == "light - Win32 Release"


"$(INTDIR)\cmdlib.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_CMDLI=\
	".\..\..\cmdlib.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

"$(INTDIR)\cmdlib.obj" : $(SOURCE) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\entities.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_ENTIT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_ENTIT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_ENTIT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\light.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LIGHT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LIGHT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_LIGHT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ltface.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LTFAC=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LTFAC=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_LTFAC=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\threads.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_THREA=\
	".\cmdlib.h"\
	".\threads.h"\
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_THREA=\
	".\cmdlib.h"\
	".\threads.h"\
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_THREA=\
	".\cmdlib.h"\
	".\threads.h"\
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\trace.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_TRACE=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_TRACE=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_TRACE=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\bspfile.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

"$(INTDIR)\bspfile.obj" : $(SOURCE) "$(INTDIR)"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\mathlib.c

!IF  "$(CFG)" == "light - Win32 Release"


"$(INTDIR)\mathlib.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_MATHL=\
	".\..\..\cmdlib.h"\
	".\..\..\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

"$(INTDIR)\mathlib.obj" : $(SOURCE) "$(INTDIR)"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
