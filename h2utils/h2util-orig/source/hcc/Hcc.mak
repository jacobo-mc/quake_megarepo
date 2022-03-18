# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=hcc - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to hcc - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "hcc - Win32 Release" && "$(CFG)" != "hcc - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Hcc.mak" CFG="hcc - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "hcc - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "hcc - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "hcc - Win32 Debug"
RSC=rc.exe
CPP=cl.exe

!IF  "$(CFG)" == "hcc - Win32 Release"

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

ALL : "$(OUTDIR)\Hcc.exe"

CLEAN : 
	-@erase "$(INTDIR)\CMDLIB.OBJ"
	-@erase "$(INTDIR)\expr.obj"
	-@erase "$(INTDIR)\hcc.obj"
	-@erase "$(INTDIR)\pr_comp.obj"
	-@erase "$(INTDIR)\pr_lex.obj"
	-@erase "$(INTDIR)\stmt.obj"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Hcc.exe"
	-@erase "$(OUTDIR)\Hcc.map"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /Zi /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /Zi /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/Hcc.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Hcc.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /profile /map /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /profile /map:"$(INTDIR)/Hcc.map"\
 /machine:I386 /out:"$(OUTDIR)/Hcc.exe" 
LINK32_OBJS= \
	"$(INTDIR)\CMDLIB.OBJ" \
	"$(INTDIR)\expr.obj" \
	"$(INTDIR)\hcc.obj" \
	"$(INTDIR)\pr_comp.obj" \
	"$(INTDIR)\pr_lex.obj" \
	"$(INTDIR)\stmt.obj"

"$(OUTDIR)\Hcc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"

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

ALL : "$(OUTDIR)\Hcc.exe" "$(OUTDIR)\Hcc.bsc"

CLEAN : 
	-@erase "$(INTDIR)\CMDLIB.OBJ"
	-@erase "$(INTDIR)\CMDLIB.SBR"
	-@erase "$(INTDIR)\expr.obj"
	-@erase "$(INTDIR)\expr.sbr"
	-@erase "$(INTDIR)\hcc.obj"
	-@erase "$(INTDIR)\hcc.sbr"
	-@erase "$(INTDIR)\pr_comp.obj"
	-@erase "$(INTDIR)\pr_comp.sbr"
	-@erase "$(INTDIR)\pr_lex.obj"
	-@erase "$(INTDIR)\pr_lex.sbr"
	-@erase "$(INTDIR)\stmt.obj"
	-@erase "$(INTDIR)\stmt.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Hcc.bsc"
	-@erase "$(OUTDIR)\Hcc.exe"
	-@erase "$(OUTDIR)\Hcc.map"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/Hcc.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Hcc.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\CMDLIB.SBR" \
	"$(INTDIR)\expr.sbr" \
	"$(INTDIR)\hcc.sbr" \
	"$(INTDIR)\pr_comp.sbr" \
	"$(INTDIR)\pr_lex.sbr" \
	"$(INTDIR)\stmt.sbr"

"$(OUTDIR)\Hcc.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /profile /map /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /profile /map:"$(INTDIR)/Hcc.map"\
 /debug /machine:I386 /out:"$(OUTDIR)/Hcc.exe" 
LINK32_OBJS= \
	"$(INTDIR)\CMDLIB.OBJ" \
	"$(INTDIR)\expr.obj" \
	"$(INTDIR)\hcc.obj" \
	"$(INTDIR)\pr_comp.obj" \
	"$(INTDIR)\pr_lex.obj" \
	"$(INTDIR)\stmt.obj"

"$(OUTDIR)\Hcc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "hcc - Win32 Release"
# Name "hcc - Win32 Debug"

!IF  "$(CFG)" == "hcc - Win32 Release"

!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\pr_comp.c
DEP_CPP_PR_CO=\
	".\hcc.H"\
	".\Pr_comp.h"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\pr_comp.obj" : $(SOURCE) $(DEP_CPP_PR_CO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\pr_comp.obj" : $(SOURCE) $(DEP_CPP_PR_CO) "$(INTDIR)"

"$(INTDIR)\pr_comp.sbr" : $(SOURCE) $(DEP_CPP_PR_CO) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\pr_lex.c
DEP_CPP_PR_LE=\
	".\hcc.H"\
	".\Pr_comp.h"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\pr_lex.obj" : $(SOURCE) $(DEP_CPP_PR_LE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\pr_lex.obj" : $(SOURCE) $(DEP_CPP_PR_LE) "$(INTDIR)"

"$(INTDIR)\pr_lex.sbr" : $(SOURCE) $(DEP_CPP_PR_LE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hcc.C
DEP_CPP_HCC_C=\
	".\hcc.H"\
	".\Pr_comp.h"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\hcc.obj" : $(SOURCE) $(DEP_CPP_HCC_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\hcc.obj" : $(SOURCE) $(DEP_CPP_HCC_C) "$(INTDIR)"

"$(INTDIR)\hcc.sbr" : $(SOURCE) $(DEP_CPP_HCC_C) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\CMDLIB.C
DEP_CPP_CMDLI=\
	".\hcc.H"\
	".\Pr_comp.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\CMDLIB.OBJ" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\CMDLIB.OBJ" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"

"$(INTDIR)\CMDLIB.SBR" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\stmt.c
DEP_CPP_STMT_=\
	".\hcc.H"\
	".\Pr_comp.h"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\stmt.obj" : $(SOURCE) $(DEP_CPP_STMT_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\stmt.obj" : $(SOURCE) $(DEP_CPP_STMT_) "$(INTDIR)"

"$(INTDIR)\stmt.sbr" : $(SOURCE) $(DEP_CPP_STMT_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\expr.c
DEP_CPP_EXPR_=\
	".\hcc.H"\
	".\Pr_comp.h"\
	

!IF  "$(CFG)" == "hcc - Win32 Release"


"$(INTDIR)\expr.obj" : $(SOURCE) $(DEP_CPP_EXPR_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "hcc - Win32 Debug"


"$(INTDIR)\expr.obj" : $(SOURCE) $(DEP_CPP_EXPR_) "$(INTDIR)"

"$(INTDIR)\expr.sbr" : $(SOURCE) $(DEP_CPP_EXPR_) "$(INTDIR)"


!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
