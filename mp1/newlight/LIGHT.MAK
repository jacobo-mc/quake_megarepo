# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=light - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to light - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "light - Win32 Release" && "$(CFG)" != "light - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Light.mak" CFG="light - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "light - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "light - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "light - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "..\..\light.exe"

CLEAN : 
	-@erase "$(INTDIR)\Bspfile.obj"
	-@erase "$(INTDIR)\Cmdlib.obj"
	-@erase "$(INTDIR)\entities.obj"
	-@erase "$(INTDIR)\light.obj"
	-@erase "$(INTDIR)\ltface.obj"
	-@erase "$(INTDIR)\Mathlib.obj"
	-@erase "$(INTDIR)\Threads.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "..\..\light.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /GX /O2 /Ob2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /G5 /MT /GX /O2 /Ob2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/Light.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Light.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386 /out:"o:\qutils\light.exe"
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/light.pdb" /machine:I386 /out:"o:\qutils\light.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Bspfile.obj" \
	"$(INTDIR)\Cmdlib.obj" \
	"$(INTDIR)\entities.obj" \
	"$(INTDIR)\light.obj" \
	"$(INTDIR)\ltface.obj" \
	"$(INTDIR)\Mathlib.obj" \
	"$(INTDIR)\Threads.obj" \
	"$(INTDIR)\trace.obj"

"..\..\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "..\..\light.exe"

CLEAN : 
	-@erase "$(INTDIR)\Bspfile.obj"
	-@erase "$(INTDIR)\Cmdlib.obj"
	-@erase "$(INTDIR)\entities.obj"
	-@erase "$(INTDIR)\light.obj"
	-@erase "$(INTDIR)\ltface.obj"
	-@erase "$(INTDIR)\Mathlib.obj"
	-@erase "$(INTDIR)\Threads.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\light.pdb"
	-@erase "..\..\light.exe"
	-@erase "..\..\light.ilk"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /G5 /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG"\
 /D "_CONSOLE" /Fp"$(INTDIR)/Light.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Light.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /out:"o:\qutils\light.exe"
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/light.pdb" /debug /machine:I386 /out:"o:\qutils\light.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Bspfile.obj" \
	"$(INTDIR)\Cmdlib.obj" \
	"$(INTDIR)\entities.obj" \
	"$(INTDIR)\light.obj" \
	"$(INTDIR)\ltface.obj" \
	"$(INTDIR)\Mathlib.obj" \
	"$(INTDIR)\Threads.obj" \
	"$(INTDIR)\trace.obj"

"..\..\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

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

################################################################################
# Begin Target

# Name "light - Win32 Release"
# Name "light - Win32 Debug"

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\trace.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_TRACE=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\ENTITIES.H"\
	".\LIGHT.H"\
	".\THREADS.H"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_TRACE=\
	".\LIGHT.H"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ltface.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LTFAC=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\ENTITIES.H"\
	".\LIGHT.H"\
	".\THREADS.H"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LTFAC=\
	".\LIGHT.H"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\light.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LIGHT=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\ENTITIES.H"\
	".\LIGHT.H"\
	".\THREADS.H"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LIGHT=\
	".\LIGHT.H"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\entities.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_ENTIT=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\ENTITIES.H"\
	".\LIGHT.H"\
	".\THREADS.H"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_ENTIT=\
	".\LIGHT.H"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\qutils\src\common\Cmdlib.c
DEP_CPP_CMDLI=\
	"..\common\cmdlib.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\Cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\qutils\src\common\Mathlib.c
DEP_CPP_MATHL=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	

"$(INTDIR)\Mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\qutils\src\common\Bspfile.c
DEP_CPP_BSPFI=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	

"$(INTDIR)\Bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\Threads.c
DEP_CPP_THREA=\
	"..\common\cmdlib.h"\
	".\THREADS.H"\
	

"$(INTDIR)\Threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"


# End Source File
# End Target
# End Project
################################################################################
