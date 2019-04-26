# Microsoft Developer Studio Project File - Name="ref_soft" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
# TARGTYPE "Win32 (ALPHA) Dynamic-Link Library" 0x0602

CFG=ref_soft - Win32 Debug Alpha
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ref_soft.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ref_soft.mak" CFG="ref_soft - Win32 Debug Alpha"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ref_soft - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_soft - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_soft - Win32 Debug Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE "ref_soft - Win32 Release Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\ref_soft"
# PROP BASE Intermediate_Dir ".\ref_soft"
# PROP BASE Target_Dir "."
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\release"
# PROP Intermediate_Dir ".\release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir "."
CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W4 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
MTL=midl.exe
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /machine:I386
# SUBTRACT LINK32 /debug

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\ref_soft"
# PROP BASE Intermediate_Dir ".\ref_soft"
# PROP BASE Target_Dir "."
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\debug"
# PROP Intermediate_Dir ".\debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir "."
CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /ZI /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /FR /YX /FD /c
MTL=midl.exe
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libc"
# SUBTRACT LINK32 /profile /nodefaultlib

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug Alpha"
# PROP BASE Intermediate_Dir "Debug Alpha"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\DebugAxp"
# PROP Intermediate_Dir ".\DebugAxp"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MTd /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /QA21164 /MTd /Gt0 /W3 /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "C_ONLY" /YX /FD /QAieee1 /c
MTL=midl.exe
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /debug /machine:ALPHA /nodefaultlib:"libc"
# SUBTRACT BASE LINK32 /nodefaultlib
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /debug /machine:ALPHA /nodefaultlib:"libc"
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ref_soft"
# PROP BASE Intermediate_Dir "ref_soft"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\ReleaseAXP"
# PROP Intermediate_Dir ".\ReleaseAXP"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /QA21164 /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "C_ONLY" /YX /FD /QAieee1 /c
# SUBTRACT CPP /Z<none> /Fr
MTL=midl.exe
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /machine:ALPHA
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /machine:ALPHA
# SUBTRACT LINK32 /debug

!ENDIF 

# Begin Target

# Name "ref_soft - Win32 Release"
# Name "ref_soft - Win32 Debug"
# Name "ref_soft - Win32 Debug Alpha"
# Name "ref_soft - Win32 Release Alpha"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=..\game\q_shared.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_Q_SHA=\
	"..\game\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_Q_SHA=\
	"..\game\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_Q_SHA=\
	"..\game\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\q_shwin.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_Q_SHW=\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\winquake.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_Q_SHW=\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\winquake.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_Q_SHW=\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\winquake.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_aclip.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_ACL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_ACL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_ACL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_aclipa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_aclipa.asm
InputName=r_aclipa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_aclipa.asm
InputName=r_aclipa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_alias.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_ALI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\anorms.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_ALI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\anorms.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_ALI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\anorms.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_bsp.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_BSP=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_BSP=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_BSP=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_draw.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_DRA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_DRA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_DRA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_draw16.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_draw16.asm
InputName=r_draw16

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_draw16.asm
InputName=r_draw16

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_drawa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_drawa.asm
InputName=r_drawa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_drawa.asm
InputName=r_drawa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_edge.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_EDG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_EDG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_EDG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_edgea.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_edgea.asm
InputName=r_edgea

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_edgea.asm
InputName=r_edgea

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_image.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_IMA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_IMA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_IMA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_light.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_LIG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_LIG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_LIG=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_main.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_MAI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_MAI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_MAI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_misc.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_MIS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_MIS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_MIS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_model.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_MOD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_MOD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_MOD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_part.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_PAR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_PAR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_PAR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_poly.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_POL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_POL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_POL=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_polysa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_polysa.asm
InputName=r_polysa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_polysa.asm
InputName=r_polysa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_polyse.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_POLY=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\adivtab.h"\
	".\r_local.h"\
	".\r_model.h"\
	".\rand1k.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_POLY=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\adivtab.h"\
	".\r_local.h"\
	".\r_model.h"\
	".\rand1k.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_POLY=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\adivtab.h"\
	".\r_local.h"\
	".\r_model.h"\
	".\rand1k.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_rast.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_RAS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_RAS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_RAS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_scan.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_SCA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_SCA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_SCA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_scana.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_scana.asm
InputName=r_scana

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_scana.asm
InputName=r_scana

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_spr8.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_spr8.asm
InputName=r_spr8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_spr8.asm
InputName=r_spr8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_sprite.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_SPR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_SPR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_SPR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_surf.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_R_SUR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_R_SUR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_R_SUR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_surf8.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_surf8.asm
InputName=r_surf8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_surf8.asm
InputName=r_surf8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\r_varsa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\..\release
InputPath=.\r_varsa.asm
InputName=r_varsa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\..\debug
InputPath=.\r_varsa.asm
InputName=r_varsa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\rw_ddraw.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_RW_DD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_RW_DD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_RW_DD=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\rw_dib.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_RW_DI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_RW_DI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_RW_DI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\rw_imp.c

!IF  "$(CFG)" == "ref_soft - Win32 Release"

DEP_CPP_RW_IM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	"..\win32\winquake.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug Alpha"

DEP_CPP_RW_IM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	"..\win32\winquake.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release Alpha"

DEP_CPP_RW_IM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\rw_win.h"\
	"..\win32\winquake.h"\
	".\r_local.h"\
	".\r_model.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\adivtab.h
# End Source File
# Begin Source File

SOURCE=.\anorms.h
# End Source File
# Begin Source File

SOURCE=..\game\q_shared.h
# End Source File
# Begin Source File

SOURCE=..\qcommon\qcommon.h
# End Source File
# Begin Source File

SOURCE=..\qcommon\qfiles.h
# End Source File
# Begin Source File

SOURCE=.\r_local.h
# End Source File
# Begin Source File

SOURCE=.\r_model.h
# End Source File
# Begin Source File

SOURCE=.\rand1k.h
# End Source File
# Begin Source File

SOURCE=..\client\ref.h
# End Source File
# Begin Source File

SOURCE=..\win32\rw_win.h
# End Source File
# Begin Source File

SOURCE=..\win32\winquake.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\ref_soft.def
# End Source File
# End Group
# End Target
# End Project
