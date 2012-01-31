# Microsoft Developer Studio Project File - Name="game" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
# TARGTYPE "Win32 (ALPHA) Dynamic-Link Library" 0x0602

CFG=game - Win32 Debug Alpha
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "game.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "game.mak" CFG="game - Win32 Debug Alpha"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "game - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "game - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "game - Win32 Debug Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE "game - Win32 Release Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "game - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir "."
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\release"
# PROP Intermediate_Dir ".\release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir "."
CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W4 /GX /Zd /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
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
# ADD LINK32 kernel32.lib user32.lib winmm.lib /nologo /base:"0x20000000" /subsystem:windows /dll /machine:I386 /out:"..\release\gamex86.dll"
# SUBTRACT LINK32 /incremental:yes /debug

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\Debug"
# PROP BASE Intermediate_Dir ".\Debug"
# PROP BASE Target_Dir "."
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\debug"
# PROP Intermediate_Dir ".\debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir "."
CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "BUILDING_REF_GL" /FR /YX /FD /c
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
# ADD LINK32 kernel32.lib user32.lib winmm.lib /nologo /base:"0x20000000" /subsystem:windows /dll /incremental:no /map /debug /machine:I386 /out:"..\debug\gamex86.dll"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

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
# ADD CPP /nologo /QA21164 /MTd /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "C_ONLY" /YX /FD /c
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
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /base:"0x20000000" /subsystem:windows /dll /debug /machine:ALPHA
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /base:"0x20000000" /subsystem:windows /dll /debug /machine:ALPHA /out:"..\DebugAxp/gameaxp.dll"

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "game___W"
# PROP BASE Intermediate_Dir "game___W"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\ReleaseAXP"
# PROP Intermediate_Dir ".\ReleaseAXP"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MT /Gt0 /W3 /GX /Zd /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /QA21164 /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "C_ONLY" /YX /FD /c
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
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /base:"0x20000000" /subsystem:windows /dll /machine:ALPHA /out:"..\Release/gamex86.dll"
# ADD LINK32 kernel32.lib user32.lib gdi32.lib /nologo /base:"0x20000000" /subsystem:windows /dll /machine:ALPHA /out:"..\ReleaseAXP/gameaxp.dll"
# SUBTRACT LINK32 /debug

!ENDIF 

# Begin Target

# Name "game - Win32 Release"
# Name "game - Win32 Debug"
# Name "game - Win32 Debug Alpha"
# Name "game - Win32 Release Alpha"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\g_ai.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_AI_=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_AI_=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_chase.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_CHA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_CHA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_cmds.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_CMD=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_CMD=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_combat.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_COM=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_COM=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_func.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_FUN=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_FUN=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_items.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_ITE=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_ITE=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_main.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_MAI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_MAI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_misc.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_MIS=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_MIS=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_monster.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_MON=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_MON=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_phys.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_PHY=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_PHY=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_save.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_SAV=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_SAV=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_spawn.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_SPA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_SPA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_svcmds.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_SVC=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_SVC=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_target.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_TAR=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_TAR=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_trigger.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_TRI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_TRI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_turret.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_TUR=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_TUR=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_utils.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_UTI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_UTI=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_weapon.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_G_WEA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_G_WEA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_actor.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_ACT=\
	".\g_local.h"\
	".\game.h"\
	".\m_actor.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_ACT=\
	".\g_local.h"\
	".\game.h"\
	".\m_actor.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_berserk.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BER=\
	".\g_local.h"\
	".\game.h"\
	".\m_berserk.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BER=\
	".\g_local.h"\
	".\game.h"\
	".\m_berserk.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_boss2.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BOS=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss2.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BOS=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss2.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_boss3.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BOSS=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss32.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BOSS=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss32.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_boss31.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BOSS3=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss31.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BOSS3=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss31.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_boss32.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BOSS32=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss32.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BOSS32=\
	".\g_local.h"\
	".\game.h"\
	".\m_boss32.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_brain.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_BRA=\
	".\g_local.h"\
	".\game.h"\
	".\m_brain.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_BRA=\
	".\g_local.h"\
	".\game.h"\
	".\m_brain.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_chick.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_CHI=\
	".\g_local.h"\
	".\game.h"\
	".\m_chick.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_CHI=\
	".\g_local.h"\
	".\game.h"\
	".\m_chick.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_flash.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_FLA=\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_FLA=\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_flipper.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_FLI=\
	".\g_local.h"\
	".\game.h"\
	".\m_flipper.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_FLI=\
	".\g_local.h"\
	".\game.h"\
	".\m_flipper.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_float.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_FLO=\
	".\g_local.h"\
	".\game.h"\
	".\m_float.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_FLO=\
	".\g_local.h"\
	".\game.h"\
	".\m_float.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_flyer.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_FLY=\
	".\g_local.h"\
	".\game.h"\
	".\m_flyer.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_FLY=\
	".\g_local.h"\
	".\game.h"\
	".\m_flyer.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_gladiator.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_GLA=\
	".\g_local.h"\
	".\game.h"\
	".\m_gladiator.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_GLA=\
	".\g_local.h"\
	".\game.h"\
	".\m_gladiator.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_gunner.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_GUN=\
	".\g_local.h"\
	".\game.h"\
	".\m_gunner.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_GUN=\
	".\g_local.h"\
	".\game.h"\
	".\m_gunner.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_hover.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_HOV=\
	".\g_local.h"\
	".\game.h"\
	".\m_hover.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_HOV=\
	".\g_local.h"\
	".\game.h"\
	".\m_hover.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_infantry.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_INF=\
	".\g_local.h"\
	".\game.h"\
	".\m_infantry.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_INF=\
	".\g_local.h"\
	".\game.h"\
	".\m_infantry.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_insane.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_INS=\
	".\g_local.h"\
	".\game.h"\
	".\m_insane.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_INS=\
	".\g_local.h"\
	".\game.h"\
	".\m_insane.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_medic.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_MED=\
	".\g_local.h"\
	".\game.h"\
	".\m_medic.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_MED=\
	".\g_local.h"\
	".\game.h"\
	".\m_medic.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_move.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_MOV=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_MOV=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_mutant.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_MUT=\
	".\g_local.h"\
	".\game.h"\
	".\m_mutant.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_MUT=\
	".\g_local.h"\
	".\game.h"\
	".\m_mutant.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_parasite.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_PAR=\
	".\g_local.h"\
	".\game.h"\
	".\m_parasite.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_PAR=\
	".\g_local.h"\
	".\game.h"\
	".\m_parasite.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_soldier.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_SOL=\
	".\g_local.h"\
	".\game.h"\
	".\m_soldier.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_SOL=\
	".\g_local.h"\
	".\game.h"\
	".\m_soldier.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_supertank.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_SUP=\
	".\g_local.h"\
	".\game.h"\
	".\m_supertank.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_SUP=\
	".\g_local.h"\
	".\game.h"\
	".\m_supertank.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_tank.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_M_TAN=\
	".\g_local.h"\
	".\game.h"\
	".\m_tank.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_M_TAN=\
	".\g_local.h"\
	".\game.h"\
	".\m_tank.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_client.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_P_CLI=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_P_CLI=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_hud.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_P_HUD=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_P_HUD=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_trail.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_P_TRA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_P_TRA=\
	".\g_local.h"\
	".\game.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_view.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_P_VIE=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_P_VIE=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_weapon.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_P_WEA=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_P_WEA=\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\q_shared.c

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ELSEIF  "$(CFG)" == "game - Win32 Debug Alpha"

DEP_CPP_Q_SHA=\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "game - Win32 Release Alpha"

DEP_CPP_Q_SHA=\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\g_local.h
# End Source File
# Begin Source File

SOURCE=.\game.h
# End Source File
# Begin Source File

SOURCE=.\m_actor.h
# End Source File
# Begin Source File

SOURCE=.\m_berserk.h
# End Source File
# Begin Source File

SOURCE=.\m_boss2.h
# End Source File
# Begin Source File

SOURCE=.\m_boss31.h
# End Source File
# Begin Source File

SOURCE=.\m_boss32.h
# End Source File
# Begin Source File

SOURCE=.\m_brain.h
# End Source File
# Begin Source File

SOURCE=.\m_chick.h
# End Source File
# Begin Source File

SOURCE=.\m_flipper.h
# End Source File
# Begin Source File

SOURCE=.\m_float.h
# End Source File
# Begin Source File

SOURCE=.\m_flyer.h
# End Source File
# Begin Source File

SOURCE=.\m_gladiator.h
# End Source File
# Begin Source File

SOURCE=.\m_gunner.h
# End Source File
# Begin Source File

SOURCE=.\m_hover.h
# End Source File
# Begin Source File

SOURCE=.\m_infantry.h
# End Source File
# Begin Source File

SOURCE=.\m_insane.h
# End Source File
# Begin Source File

SOURCE=.\m_medic.h
# End Source File
# Begin Source File

SOURCE=.\m_mutant.h
# End Source File
# Begin Source File

SOURCE=.\m_parasite.h
# End Source File
# Begin Source File

SOURCE=.\m_player.h
# End Source File
# Begin Source File

SOURCE=.\m_soldier.h
# End Source File
# Begin Source File

SOURCE=.\m_supertank.h
# End Source File
# Begin Source File

SOURCE=.\m_tank.h
# End Source File
# Begin Source File

SOURCE=.\q_shared.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\game.def
# End Source File
# End Group
# End Target
# End Project
