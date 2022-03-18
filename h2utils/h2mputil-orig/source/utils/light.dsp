# Microsoft Developer Studio Project File - Name="light" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103
# TARGTYPE "Win32 (ALPHA) Console Application" 0x0603

CFG=light - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "light.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "light.mak" CFG="light - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "light - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 (ALPHA) Release" (based on\
 "Win32 (ALPHA) Console Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""$/H2 Mission Pack/Tools/utils", BOEAAAAA"
# PROP Scc_LocalPath "."

!IF  "$(CFG)" == "light - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\light\Release"
# PROP BASE Intermediate_Dir ".\light\Release"
# PROP BASE Target_Dir ".\light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Target_Dir ".\light"
CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /O2 /D "__alpha" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\light\Debug"
# PROP BASE Intermediate_Dir ".\light\Debug"
# PROP BASE Target_Dir ".\light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Target_Dir ".\light"
CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "__alpha" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\light\AlphaRel"
# PROP BASE Intermediate_Dir ".\light\AlphaRel"
# PROP BASE Target_Dir ".\light"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\light\AlphaRel"
# PROP Intermediate_Dir ".\light\AlphaRel"
# PROP Target_Dir ".\light"
CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /FD /c
RSC=rc.exe
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:ALPHA

!ENDIF 

# Begin Target

# Name "light - Win32 Release"
# Name "light - Win32 Debug"
# Name "light - Win32 (ALPHA) Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\bspfile.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\cmdlib.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\entities.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_ENTIT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\light.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_LIGHT=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\ltface.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_LTFAC=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mathlib.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\threads.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_THREA=\
	".\cmdlib.h"\
	".\threads.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\trace.c

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ELSEIF  "$(CFG)" == "light - Win32 (ALPHA) Release"

DEP_CPP_TRACE=\
	".\bspfile.h"\
	".\cmdlib.h"\
	".\entities.h"\
	".\light.h"\
	".\mathlib.h"\
	".\threads.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\bspfile.h
# End Source File
# Begin Source File

SOURCE=.\cmdlib.h
# End Source File
# Begin Source File

SOURCE=.\entities.h
# End Source File
# Begin Source File

SOURCE=.\light.h
# End Source File
# Begin Source File

SOURCE=.\mathlib.h
# End Source File
# Begin Source File

SOURCE=.\threads.h
# End Source File
# End Group
# End Target
# End Project
