# Microsoft Developer Studio Project File - Name="qwcl" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=qwcl - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "qwcl.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "qwcl.mak" CFG="qwcl - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qwcl - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "qwcl - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "qwcl - Win32 GLDebug" (based on "Win32 (x86) Application")
!MESSAGE "qwcl - Win32 GLRelease" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""$/HexenWorld/Client", TDFAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /GX /Zi /O2 /Ob2 /I "..\dxsdk\sdk\inc" /I "..\scitech\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "MGNET" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 ..\scitech\lib\win32\vc\mgllt.lib ..\dxsdk\sdk\lib\dxguid.lib opengl32.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /incremental:yes /debug /machine:I386
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\Debug"
# PROP BASE Intermediate_Dir ".\Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /ML /Gm /GX /Zi /Od /I "..\dxsdk\sdk\inc" /I "..\scitech\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 ..\scitech\lib\win32\vc\mgllt.lib ..\dxsdk\sdk\lib\dxguid.lib opengl32.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /debug /machine:I386
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\qwcl___0"
# PROP BASE Intermediate_Dir ".\qwcl___0"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\GLDebug"
# PROP Intermediate_Dir ".\GLDebug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /ML /Gm /GX /Zi /Od /I "e:\msdev\projects\dxsdk\sdk\inc" /I "e:\msdev\projects\scitech\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /c
# ADD CPP /nologo /G5 /ML /GX /Zi /Od /I "..\dxsdk\sdk\inc" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "GLQUAKE" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 opengl32.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib e:\msdev\projects\scitech\lib\win32\vc\mgllt.lib /nologo /subsystem:windows /debug /machine:I386
# SUBTRACT BASE LINK32 /nodefaultlib
# ADD LINK32 ..\dxsdk\sdk\lib\dxguid.lib comctl32.lib glu32.lib opengl32.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /incremental:no /debug /machine:I386 /out:".\GLDebug\glqwcl.exe"
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\qwcl___W"
# PROP BASE Intermediate_Dir ".\qwcl___W"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\GLRelease"
# PROP Intermediate_Dir ".\GLRelease"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /G5 /ML /GX /Zi /Od /I "e:\msdev\projects\dxsdk\sdk\inc" /I "e:\msdev\projects\scitech\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "GLQUAKE" /FR /YX /c
# ADD CPP /nologo /G5 /ML /GX /Zi /O2 /Ob2 /I "..\dxsdk\sdk\inc" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "GLQUAKE" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 e:\msdev\projects\winquake\dxsdk\sdk\lib\dxguid.lib winmm.lib wsock32.lib opengl32.lib glu32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /out:"GLDebug/glqwcl.exe"
# SUBTRACT BASE LINK32 /nodefaultlib
# ADD LINK32 ..\dxsdk\sdk\lib\dxguid.lib comctl32.lib glu32.lib opengl32.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /incremental:no /debug /machine:I386 /out:".\GLRelease\glqwcl.exe"
# SUBTRACT LINK32 /nodefaultlib

!ENDIF 

# Begin Target

# Name "qwcl - Win32 Release"
# Name "qwcl - Win32 Debug"
# Name "qwcl - Win32 GLDebug"
# Name "qwcl - Win32 GLRelease"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\cd_win.c
# End Source File
# Begin Source File

SOURCE=.\cl_cam.c
# End Source File
# Begin Source File

SOURCE=.\cl_demo.c
# End Source File
# Begin Source File

SOURCE=.\cl_effect.c
# End Source File
# Begin Source File

SOURCE=.\cl_ents.c
# End Source File
# Begin Source File

SOURCE=.\cl_input.c
# End Source File
# Begin Source File

SOURCE=.\cl_main.c
# End Source File
# Begin Source File

SOURCE=.\cl_parse.c
# End Source File
# Begin Source File

SOURCE=.\cl_pred.c
# End Source File
# Begin Source File

SOURCE=.\cl_tent.c
# End Source File
# Begin Source File

SOURCE=.\cmd.c
# End Source File
# Begin Source File

SOURCE=.\common.c
# End Source File
# Begin Source File

SOURCE=.\console.c
# End Source File
# Begin Source File

SOURCE=.\crc.c
# End Source File
# Begin Source File

SOURCE=.\cvar.c
# End Source File
# Begin Source File

SOURCE=.\d_draw.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_draw.asm
InputName=d_draw

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_draw.asm
InputName=d_draw

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_draw16.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_draw16.asm
InputName=d_draw16

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_draw16.asm
InputName=d_draw16

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_draw16t.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_draw16t.asm
InputName=d_draw16t

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_draw16t.asm
InputName=d_draw16t

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_edge.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_fill.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_init.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_modech.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_part.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_parta.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_parta.asm
InputName=d_parta

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_parta.asm
InputName=d_parta

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polysa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_polysa.asm
InputName=d_polysa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_polysa.asm
InputName=d_polysa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polysa2.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_polysa2.asm
InputName=d_polysa2

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_polysa2.asm
InputName=d_polysa2

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polysa3.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_polysa3.asm
InputName=d_polysa3

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_polysa3.asm
InputName=d_polysa3

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polysa4.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_polysa4.asm
InputName=d_polysa4

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_polysa4.asm
InputName=d_polysa4

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polysa5.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_polysa5.asm
InputName=d_polysa5

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_polysa5.asm
InputName=d_polysa5

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_polyse.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_scan.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_scana.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_scana.asm
InputName=d_scana

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_scana.asm
InputName=d_scana

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_sky.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_spr8.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_spr8.asm
InputName=d_spr8

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_spr8.asm
InputName=d_spr8

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_spr8t.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_spr8t.asm
InputName=d_spr8t

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_spr8t.asm
InputName=d_spr8t

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_spr8t2.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_spr8t2.asm
InputName=d_spr8t2

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_spr8t2.asm
InputName=d_spr8t2

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_sprite.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_surf.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_vars.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_varsa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\d_varsa.asm
InputName=d_varsa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\d_varsa.asm
InputName=d_varsa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_zpoint.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\draw.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_draw.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_mesh.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_model.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_ngraph.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_refrag.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rlight.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rmain.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rmisc.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rsurf.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_screen.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_test.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_vidnt.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_warp.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\in_win.c
# End Source File
# Begin Source File

SOURCE=.\keys.c
# End Source File
# Begin Source File

SOURCE=.\math.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\math.asm
InputName=math

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\math.asm
InputName=math

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# Begin Custom Build
TargetDir=.\GLDebug
InputPath=.\math.asm
InputName=math

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# Begin Custom Build
TargetDir=.\GLRelease
InputPath=.\math.asm
InputName=math

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mathlib.c
# End Source File
# Begin Source File

SOURCE=.\menu.c
# End Source File
# Begin Source File

SOURCE=.\midi.c
# End Source File
# Begin Source File

SOURCE=.\model.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mstrconv.c
# End Source File
# Begin Source File

SOURCE=.\net_chan.c
# End Source File
# Begin Source File

SOURCE=.\net_wins.c
# End Source File
# Begin Source File

SOURCE=.\nonintel.c
# End Source File
# Begin Source File

SOURCE=.\pmove.c
# End Source File
# Begin Source File

SOURCE=.\pmovetst.c
# End Source File
# Begin Source File

SOURCE=.\r_aclip.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_aclipa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_aclipa.asm
InputName=r_aclipa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_aclipa.asm
InputName=r_aclipa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_alias.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_aliasa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_aliasa.asm
InputName=r_aliasa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_aliasa.asm
InputName=r_aliasa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_bsp.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_draw.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_drawa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_drawa.asm
InputName=r_drawa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_drawa.asm
InputName=r_drawa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_edge.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_edgea.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_edgea.asm
InputName=r_edgea

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_edgea.asm
InputName=r_edgea

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_edgeb.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_edgeb.asm
InputName=r_edgeb

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_edgeb.asm
InputName=r_edgeb

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_efrag.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_light.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_main.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_misc.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_part.c
# End Source File
# Begin Source File

SOURCE=.\r_sky.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_sprite.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_surf.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_vars.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_varsa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\r_varsa.asm
InputName=r_varsa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\r_varsa.asm
InputName=r_varsa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\sbar.c
# End Source File
# Begin Source File

SOURCE=.\sbar.h
# End Source File
# Begin Source File

SOURCE=.\screen.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\skin.c
# End Source File
# Begin Source File

SOURCE=.\snd_dma.c
# End Source File
# Begin Source File

SOURCE=.\snd_mem.c
# End Source File
# Begin Source File

SOURCE=.\snd_mix.c
# End Source File
# Begin Source File

SOURCE=.\snd_mixa.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\snd_mixa.asm
InputName=snd_mixa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\snd_mixa.asm
InputName=snd_mixa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# Begin Custom Build
TargetDir=.\GLDebug
InputPath=.\snd_mixa.asm
InputName=snd_mixa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# Begin Custom Build
TargetDir=.\GLRelease
InputPath=.\snd_mixa.asm
InputName=snd_mixa

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\snd_win.c
# End Source File
# Begin Source File

SOURCE=.\strings.c
# End Source File
# Begin Source File

SOURCE=.\surf16.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\surf16.asm
InputName=surf16

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\surf16.asm
InputName=surf16

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\surf8.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\surf8.asm
InputName=surf8

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\surf8.asm
InputName=surf8

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\sys_win.c
# End Source File
# Begin Source File

SOURCE=.\sys_wina.asm

!IF  "$(CFG)" == "qwcl - Win32 Release"

# Begin Custom Build
TargetDir=.\Release
InputPath=.\sys_wina.asm
InputName=sys_wina

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

# Begin Custom Build
TargetDir=.\Debug
InputPath=.\sys_wina.asm
InputName=sys_wina

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# Begin Custom Build
TargetDir=.\GLDebug
InputPath=.\sys_wina.asm
InputName=sys_wina

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# Begin Custom Build
TargetDir=.\GLRelease
InputPath=.\sys_wina.asm
InputName=sys_wina

"$(TargetDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo $(TargetDir)\$(InputName).obj /Zi /Zm $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\vid_win.c

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\view.c
# End Source File
# Begin Source File

SOURCE=.\wad.c
# End Source File
# Begin Source File

SOURCE=.\wad.h
# End Source File
# Begin Source File

SOURCE=.\winquake.rc
# End Source File
# Begin Source File

SOURCE=.\zone.c
# End Source File
# Begin Source File

SOURCE=.\zone.h
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\adivtab.h
# End Source File
# Begin Source File

SOURCE=.\anorm_dots.h
# End Source File
# Begin Source File

SOURCE=.\anorms.h
# End Source File
# Begin Source File

SOURCE=.\bothdefs.h
# End Source File
# Begin Source File

SOURCE=.\bspfile.h
# End Source File
# Begin Source File

SOURCE=.\cdaudio.h
# End Source File
# Begin Source File

SOURCE=.\cl_effect.h
# End Source File
# Begin Source File

SOURCE=.\client.h
# End Source File
# Begin Source File

SOURCE=.\cmd.h
# End Source File
# Begin Source File

SOURCE=.\common.h
# End Source File
# Begin Source File

SOURCE=.\console.h
# End Source File
# Begin Source File

SOURCE=.\crc.h
# End Source File
# Begin Source File

SOURCE=.\cvar.h
# End Source File
# Begin Source File

SOURCE=.\d_iface.h

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_ifacea.h

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\d_local.h

!IF  "$(CFG)" == "qwcl - Win32 Release"

!ELSEIF  "$(CFG)" == "qwcl - Win32 Debug"

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLDebug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "qwcl - Win32 GLRelease"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\draw.h
# End Source File
# Begin Source File

SOURCE=.\gl_model.h
# End Source File
# Begin Source File

SOURCE=.\gl_warp_sin.h
# End Source File
# Begin Source File

SOURCE=.\glquake.h
# End Source File
# Begin Source File

SOURCE=.\input.h
# End Source File
# Begin Source File

SOURCE=.\keys.h
# End Source File
# Begin Source File

SOURCE=.\mathlib.h
# End Source File
# Begin Source File

SOURCE=.\menu.h
# End Source File
# Begin Source File

SOURCE=.\midi.h
# End Source File
# Begin Source File

SOURCE=.\mididef.h
# End Source File
# Begin Source File

SOURCE=.\midstuff.h
# End Source File
# Begin Source File

SOURCE=.\model.h
# End Source File
# Begin Source File

SOURCE=.\modelgen.h
# End Source File
# Begin Source File

SOURCE=.\net.h
# End Source File
# Begin Source File

SOURCE=.\pmove.h
# End Source File
# Begin Source File

SOURCE=..\Server\pr_comp.h
# End Source File
# Begin Source File

SOURCE=.\protocol.h
# End Source File
# Begin Source File

SOURCE=.\quakedef.h
# End Source File
# Begin Source File

SOURCE=.\r_local.h
# End Source File
# Begin Source File

SOURCE=.\r_shared.h
# End Source File
# Begin Source File

SOURCE=.\render.h
# End Source File
# Begin Source File

SOURCE=.\screen.h
# End Source File
# Begin Source File

SOURCE=.\sound.h
# End Source File
# Begin Source File

SOURCE=.\spritegn.h
# End Source File
# Begin Source File

SOURCE=.\strings.h
# End Source File
# Begin Source File

SOURCE=.\sys.h
# End Source File
# Begin Source File

SOURCE=.\vid.h
# End Source File
# Begin Source File

SOURCE=.\view.h
# End Source File
# Begin Source File

SOURCE=.\winquake.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\qe3.ico
# End Source File
# Begin Source File

SOURCE=.\quakeworld.bmp
# End Source File
# Begin Source File

SOURCE=.\qwcl2.ico
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# End Group
# End Target
# End Project
