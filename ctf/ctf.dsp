# Microsoft Developer Studio Project File - Name="ctf" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
# TARGTYPE "Win32 (ALPHA) Dynamic-Link Library" 0x0602

CFG=ctf - Win32 Debug Alpha
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ctf.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ctf.mak" CFG="ctf - Win32 Debug Alpha"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ctf - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ctf - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ctf - Win32 Debug Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE "ctf - Win32 Release Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "ctf - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\release"
# PROP Intermediate_Dir ".\release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MT /W4 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
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
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib winmm.lib /nologo /subsystem:windows /dll /machine:I386 /out:".\release\gamex86.dll"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\debug"
# PROP Intermediate_Dir ".\debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
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
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib winmm.lib /nologo /subsystem:windows /dll /incremental:no /map /debug /machine:I386 /out:".\debug\gamex86.dll" /pdbtype:sept

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ctf___Wi"
# PROP BASE Intermediate_Dir "ctf___Wi"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "..\DebugAXP"
# PROP Intermediate_Dir ".\DebugAXP"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
CPP=cl.exe
# ADD BASE CPP /nologo /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /MTd /c
# ADD CPP /nologo /Gt0 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /MTd /c
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
# ADD BASE LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /map /debug /machine:ALPHA /out:".\debug\gamex86.dll" /pdbtype:sept
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /map /debug /machine:ALPHA /out:".\debugAXP\gameaxp.dll" /pdbtype:sept

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ctf___W0"
# PROP BASE Intermediate_Dir "ctf___W0"
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
# ADD CPP /nologo /MT /Gt0 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
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
# ADD BASE LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /machine:ALPHA /out:".\release\gamex86.dll"
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /machine:ALPHA /out:".\ReleaseAXP\gameaxp.dll"

!ENDIF 

# Begin Target

# Name "ctf - Win32 Release"
# Name "ctf - Win32 Debug"
# Name "ctf - Win32 Debug Alpha"
# Name "ctf - Win32 Release Alpha"
# Begin Group "Source Files"

# PROP Default_Filter "*.c"
# Begin Source File

SOURCE=.\g_ai.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_AI_=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_AI_=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_chase.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_CHA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_CHA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_cmds.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_CMD=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_CMD=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_combat.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_COM=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_COM=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_ctf.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_CTF=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_CTF=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_func.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_FUN=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_FUN=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_items.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_ITE=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_ITE=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_main.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_MAI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_MAI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_misc.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_MIS=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_MIS=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_monster.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_MON=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_MON=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_phys.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_PHY=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_PHY=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_save.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_SAV=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_SAV=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_spawn.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_SPA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_SPA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_svcmds.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_SVC=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_SVC=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_target.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_TAR=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_TAR=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_trigger.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_TRI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_TRI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_utils.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_UTI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_UTI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\g_weapon.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_G_WEA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_G_WEA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\m_move.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_M_MOV=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_M_MOV=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_client.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_CLI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_CLI=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_hud.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_HUD=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_HUD=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_menu.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_MEN=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_MEN=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_trail.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_TRA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_TRA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_view.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_VIE=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_VIE=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\p_weapon.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_P_WEA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_P_WEA=\
	".\g_ctf.h"\
	".\g_local.h"\
	".\game.h"\
	".\m_player.h"\
	".\p_menu.h"\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\q_shared.c

!IF  "$(CFG)" == "ctf - Win32 Release"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug"

!ELSEIF  "$(CFG)" == "ctf - Win32 Debug Alpha"

DEP_CPP_Q_SHA=\
	".\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ctf - Win32 Release Alpha"

DEP_CPP_Q_SHA=\
	".\q_shared.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "*.h"
# Begin Source File

SOURCE=.\g_ctf.h
# End Source File
# Begin Source File

SOURCE=.\g_local.h
# End Source File
# Begin Source File

SOURCE=.\game.h
# End Source File
# Begin Source File

SOURCE=.\m_player.h
# End Source File
# Begin Source File

SOURCE=.\p_menu.h
# End Source File
# Begin Source File

SOURCE=.\q_shared.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "*.def,*.res"
# Begin Source File

SOURCE=.\ctf.def
# End Source File
# End Group
# End Target
# End Project
