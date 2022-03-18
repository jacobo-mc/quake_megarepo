# Microsoft Developer Studio Project File - Name="qbsp" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103
# TARGTYPE "Win32 (ALPHA) Console Application" 0x0603

CFG=qbsp - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "qbsp.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "qbsp.mak" CFG="qbsp - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qbsp - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qbsp - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "qbsp - Win32 (ALPHA) Debug" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE "qbsp - Win32 (ALPHA) Release" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""$/H2 Mission Pack/Tools/utils", BOEAAAAA"
# PROP Scc_LocalPath "."

!IF  "$(CFG)" == "qbsp - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\qbsp\Release"
# PROP BASE Intermediate_Dir ".\qbsp\Release"
# PROP BASE Target_Dir ".\qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Target_Dir ".\qbsp"
CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /GX /O2 /D "__alpha" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /FR /YX /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\qbsp\Debug"
# PROP BASE Intermediate_Dir ".\qbsp\Debug"
# PROP BASE Target_Dir ".\qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Target_Dir ".\qbsp"
CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MTd /w /W0 /Gm /Gi /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib /nologo /subsystem:console /debug /machine:I386

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\qbsp\AlphaDbg"
# PROP BASE Intermediate_Dir ".\qbsp\AlphaDbg"
# PROP BASE Target_Dir ".\qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\AlphaDbg"
# PROP Intermediate_Dir ".\AlphaDbg"
# PROP Target_Dir ".\qbsp"
CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W2 /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /FR /YX /FD /c
# SUBTRACT CPP /X /u
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:ALPHA
# ADD LINK32 /subsystem:console /debug /machine:ALPHA
# SUBTRACT LINK32 /nologo /verbose /nodefaultlib

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\qbsp\AlphaRel"
# PROP BASE Intermediate_Dir ".\qbsp\AlphaRel"
# PROP BASE Target_Dir ".\qbsp"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\AlphaRel"
# PROP Intermediate_Dir ".\AlphaRel"
# PROP Target_Dir ".\qbsp"
CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W2 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /YX /FD /c
# SUBTRACT CPP /X /u
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
# ADD LINK32 /subsystem:console /machine:ALPHA
# SUBTRACT LINK32 /nologo /verbose /nodefaultlib

!ENDIF 

# Begin Target

# Name "qbsp - Win32 Release"
# Name "qbsp - Win32 Debug"
# Name "qbsp - Win32 (ALPHA) Debug"
# Name "qbsp - Win32 (ALPHA) Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\brush.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\bspfile.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_BSPFI=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\cmdlib.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_CMDLI=\
	".\cmdlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\csg4.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\map.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mathlib.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MATHL=\
	".\cmdlib.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\merge.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\nodraw.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\outside.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\portals.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\qbsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\region.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\solidbsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\surfaces.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\tjunc.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\writebsp.c

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Debug"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ELSEIF  "$(CFG)" == "qbsp - Win32 (ALPHA) Release"

DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\map.h"\
	".\mathlib.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\bsp5.h
# End Source File
# Begin Source File

SOURCE=.\bspfile.h
# End Source File
# Begin Source File

SOURCE=.\cmdlib.h
# End Source File
# Begin Source File

SOURCE=.\map.h
# End Source File
# Begin Source File

SOURCE=.\mathlib.h
# End Source File
# End Group
# End Target
# End Project
