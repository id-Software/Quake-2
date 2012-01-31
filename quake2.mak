# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101
# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=ref_soft - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to ref_soft - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "quake2 - Win32 Release" && "$(CFG)" != "quake2 - Win32 Debug"\
 && "$(CFG)" != "ref_soft - Win32 Release" && "$(CFG)" !=\
 "ref_soft - Win32 Debug" && "$(CFG)" != "ref_gl - Win32 Release" && "$(CFG)" !=\
 "ref_gl - Win32 Debug" && "$(CFG)" != "game - Win32 Release" && "$(CFG)" !=\
 "game - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "quake2.mak" CFG="ref_soft - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "quake2 - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "quake2 - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "ref_soft - Win32 Release" (based on\
 "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_soft - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_gl - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_gl - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "game - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "game - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
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
# PROP Target_Last_Scanned "ref_soft - Win32 Debug"

!IF  "$(CFG)" == "quake2 - Win32 Release"

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

ALL : "$(OUTDIR)\quake2.exe"

CLEAN : 
	-@erase "$(INTDIR)\cd_win.obj"
	-@erase "$(INTDIR)\cl_demo.obj"
	-@erase "$(INTDIR)\cl_ents.obj"
	-@erase "$(INTDIR)\cl_fx.obj"
	-@erase "$(INTDIR)\cl_input.obj"
	-@erase "$(INTDIR)\cl_main.obj"
	-@erase "$(INTDIR)\cl_parse.obj"
	-@erase "$(INTDIR)\cl_tent.obj"
	-@erase "$(INTDIR)\cmd.obj"
	-@erase "$(INTDIR)\cmodel.obj"
	-@erase "$(INTDIR)\common.obj"
	-@erase "$(INTDIR)\console.obj"
	-@erase "$(INTDIR)\crc.obj"
	-@erase "$(INTDIR)\cvar.obj"
	-@erase "$(INTDIR)\files.obj"
	-@erase "$(INTDIR)\in_win.obj"
	-@erase "$(INTDIR)\keys.obj"
	-@erase "$(INTDIR)\menu.obj"
	-@erase "$(INTDIR)\net_chan.obj"
	-@erase "$(INTDIR)\net_wins.obj"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\sbar2.obj"
	-@erase "$(INTDIR)\scr_cin.obj"
	-@erase "$(INTDIR)\screen.obj"
	-@erase "$(INTDIR)\snd_dma.obj"
	-@erase "$(INTDIR)\snd_mem.obj"
	-@erase "$(INTDIR)\snd_mix.obj"
	-@erase "$(INTDIR)\snd_win.obj"
	-@erase "$(INTDIR)\sv_ccmds.obj"
	-@erase "$(INTDIR)\sv_ents.obj"
	-@erase "$(INTDIR)\sv_game.obj"
	-@erase "$(INTDIR)\sv_init.obj"
	-@erase "$(INTDIR)\sv_main.obj"
	-@erase "$(INTDIR)\sv_move.obj"
	-@erase "$(INTDIR)\sv_phys.obj"
	-@erase "$(INTDIR)\sv_send.obj"
	-@erase "$(INTDIR)\sv_user.obj"
	-@erase "$(INTDIR)\sv_world.obj"
	-@erase "$(INTDIR)\sys_win.obj"
	-@erase "$(INTDIR)\vid_dll.obj"
	-@erase "$(INTDIR)\view.obj"
	-@erase "$(OUTDIR)\quake2.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /G5 /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/quake2.pch" /YX /Fo"$(INTDIR)/" /c 
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/quake2.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 winmm.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# SUBTRACT LINK32 /incremental:yes /nodefaultlib
LINK32_FLAGS=winmm.lib wsock32.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)/quake2.pdb" /machine:I386 /out:"$(OUTDIR)/quake2.exe" 
LINK32_OBJS= \
	"$(INTDIR)\cd_win.obj" \
	"$(INTDIR)\cl_demo.obj" \
	"$(INTDIR)\cl_ents.obj" \
	"$(INTDIR)\cl_fx.obj" \
	"$(INTDIR)\cl_input.obj" \
	"$(INTDIR)\cl_main.obj" \
	"$(INTDIR)\cl_parse.obj" \
	"$(INTDIR)\cl_tent.obj" \
	"$(INTDIR)\cmd.obj" \
	"$(INTDIR)\cmodel.obj" \
	"$(INTDIR)\common.obj" \
	"$(INTDIR)\console.obj" \
	"$(INTDIR)\crc.obj" \
	"$(INTDIR)\cvar.obj" \
	"$(INTDIR)\files.obj" \
	"$(INTDIR)\in_win.obj" \
	"$(INTDIR)\keys.obj" \
	"$(INTDIR)\menu.obj" \
	"$(INTDIR)\net_chan.obj" \
	"$(INTDIR)\net_wins.obj" \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\sbar2.obj" \
	"$(INTDIR)\scr_cin.obj" \
	"$(INTDIR)\screen.obj" \
	"$(INTDIR)\snd_dma.obj" \
	"$(INTDIR)\snd_mem.obj" \
	"$(INTDIR)\snd_mix.obj" \
	"$(INTDIR)\snd_win.obj" \
	"$(INTDIR)\sv_ccmds.obj" \
	"$(INTDIR)\sv_ents.obj" \
	"$(INTDIR)\sv_game.obj" \
	"$(INTDIR)\sv_init.obj" \
	"$(INTDIR)\sv_main.obj" \
	"$(INTDIR)\sv_move.obj" \
	"$(INTDIR)\sv_phys.obj" \
	"$(INTDIR)\sv_send.obj" \
	"$(INTDIR)\sv_user.obj" \
	"$(INTDIR)\sv_world.obj" \
	"$(INTDIR)\sys_win.obj" \
	"$(INTDIR)\vid_dll.obj" \
	"$(INTDIR)\view.obj"

"$(OUTDIR)\quake2.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

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

ALL : "$(OUTDIR)\quake2.exe" "$(OUTDIR)\quake2.bsc"

CLEAN : 
	-@erase "$(INTDIR)\cd_win.obj"
	-@erase "$(INTDIR)\cd_win.sbr"
	-@erase "$(INTDIR)\cl_demo.obj"
	-@erase "$(INTDIR)\cl_demo.sbr"
	-@erase "$(INTDIR)\cl_ents.obj"
	-@erase "$(INTDIR)\cl_ents.sbr"
	-@erase "$(INTDIR)\cl_fx.obj"
	-@erase "$(INTDIR)\cl_fx.sbr"
	-@erase "$(INTDIR)\cl_input.obj"
	-@erase "$(INTDIR)\cl_input.sbr"
	-@erase "$(INTDIR)\cl_main.obj"
	-@erase "$(INTDIR)\cl_main.sbr"
	-@erase "$(INTDIR)\cl_parse.obj"
	-@erase "$(INTDIR)\cl_parse.sbr"
	-@erase "$(INTDIR)\cl_tent.obj"
	-@erase "$(INTDIR)\cl_tent.sbr"
	-@erase "$(INTDIR)\cmd.obj"
	-@erase "$(INTDIR)\cmd.sbr"
	-@erase "$(INTDIR)\cmodel.obj"
	-@erase "$(INTDIR)\cmodel.sbr"
	-@erase "$(INTDIR)\common.obj"
	-@erase "$(INTDIR)\common.sbr"
	-@erase "$(INTDIR)\console.obj"
	-@erase "$(INTDIR)\console.sbr"
	-@erase "$(INTDIR)\crc.obj"
	-@erase "$(INTDIR)\crc.sbr"
	-@erase "$(INTDIR)\cvar.obj"
	-@erase "$(INTDIR)\cvar.sbr"
	-@erase "$(INTDIR)\files.obj"
	-@erase "$(INTDIR)\files.sbr"
	-@erase "$(INTDIR)\in_win.obj"
	-@erase "$(INTDIR)\in_win.sbr"
	-@erase "$(INTDIR)\keys.obj"
	-@erase "$(INTDIR)\keys.sbr"
	-@erase "$(INTDIR)\menu.obj"
	-@erase "$(INTDIR)\menu.sbr"
	-@erase "$(INTDIR)\net_chan.obj"
	-@erase "$(INTDIR)\net_chan.sbr"
	-@erase "$(INTDIR)\net_wins.obj"
	-@erase "$(INTDIR)\net_wins.sbr"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\q_shared.sbr"
	-@erase "$(INTDIR)\sbar2.obj"
	-@erase "$(INTDIR)\sbar2.sbr"
	-@erase "$(INTDIR)\scr_cin.obj"
	-@erase "$(INTDIR)\scr_cin.sbr"
	-@erase "$(INTDIR)\screen.obj"
	-@erase "$(INTDIR)\screen.sbr"
	-@erase "$(INTDIR)\snd_dma.obj"
	-@erase "$(INTDIR)\snd_dma.sbr"
	-@erase "$(INTDIR)\snd_mem.obj"
	-@erase "$(INTDIR)\snd_mem.sbr"
	-@erase "$(INTDIR)\snd_mix.obj"
	-@erase "$(INTDIR)\snd_mix.sbr"
	-@erase "$(INTDIR)\snd_win.obj"
	-@erase "$(INTDIR)\snd_win.sbr"
	-@erase "$(INTDIR)\sv_ccmds.obj"
	-@erase "$(INTDIR)\sv_ccmds.sbr"
	-@erase "$(INTDIR)\sv_ents.obj"
	-@erase "$(INTDIR)\sv_ents.sbr"
	-@erase "$(INTDIR)\sv_game.obj"
	-@erase "$(INTDIR)\sv_game.sbr"
	-@erase "$(INTDIR)\sv_init.obj"
	-@erase "$(INTDIR)\sv_init.sbr"
	-@erase "$(INTDIR)\sv_main.obj"
	-@erase "$(INTDIR)\sv_main.sbr"
	-@erase "$(INTDIR)\sv_move.obj"
	-@erase "$(INTDIR)\sv_move.sbr"
	-@erase "$(INTDIR)\sv_phys.obj"
	-@erase "$(INTDIR)\sv_phys.sbr"
	-@erase "$(INTDIR)\sv_send.obj"
	-@erase "$(INTDIR)\sv_send.sbr"
	-@erase "$(INTDIR)\sv_user.obj"
	-@erase "$(INTDIR)\sv_user.sbr"
	-@erase "$(INTDIR)\sv_world.obj"
	-@erase "$(INTDIR)\sv_world.sbr"
	-@erase "$(INTDIR)\sys_win.obj"
	-@erase "$(INTDIR)\sys_win.sbr"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\vid_dll.obj"
	-@erase "$(INTDIR)\vid_dll.sbr"
	-@erase "$(INTDIR)\view.obj"
	-@erase "$(INTDIR)\view.sbr"
	-@erase "$(OUTDIR)\quake2.bsc"
	-@erase "$(OUTDIR)\quake2.exe"
	-@erase "$(OUTDIR)\quake2.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /c
# SUBTRACT CPP /Gy
CPP_PROJ=/nologo /G5 /MLd /W3 /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /FR"$(INTDIR)/" /Fp"$(INTDIR)/quake2.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/"\
 /c 
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/quake2.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\cd_win.sbr" \
	"$(INTDIR)\cl_demo.sbr" \
	"$(INTDIR)\cl_ents.sbr" \
	"$(INTDIR)\cl_fx.sbr" \
	"$(INTDIR)\cl_input.sbr" \
	"$(INTDIR)\cl_main.sbr" \
	"$(INTDIR)\cl_parse.sbr" \
	"$(INTDIR)\cl_tent.sbr" \
	"$(INTDIR)\cmd.sbr" \
	"$(INTDIR)\cmodel.sbr" \
	"$(INTDIR)\common.sbr" \
	"$(INTDIR)\console.sbr" \
	"$(INTDIR)\crc.sbr" \
	"$(INTDIR)\cvar.sbr" \
	"$(INTDIR)\files.sbr" \
	"$(INTDIR)\in_win.sbr" \
	"$(INTDIR)\keys.sbr" \
	"$(INTDIR)\menu.sbr" \
	"$(INTDIR)\net_chan.sbr" \
	"$(INTDIR)\net_wins.sbr" \
	"$(INTDIR)\q_shared.sbr" \
	"$(INTDIR)\sbar2.sbr" \
	"$(INTDIR)\scr_cin.sbr" \
	"$(INTDIR)\screen.sbr" \
	"$(INTDIR)\snd_dma.sbr" \
	"$(INTDIR)\snd_mem.sbr" \
	"$(INTDIR)\snd_mix.sbr" \
	"$(INTDIR)\snd_win.sbr" \
	"$(INTDIR)\sv_ccmds.sbr" \
	"$(INTDIR)\sv_ents.sbr" \
	"$(INTDIR)\sv_game.sbr" \
	"$(INTDIR)\sv_init.sbr" \
	"$(INTDIR)\sv_main.sbr" \
	"$(INTDIR)\sv_move.sbr" \
	"$(INTDIR)\sv_phys.sbr" \
	"$(INTDIR)\sv_send.sbr" \
	"$(INTDIR)\sv_user.sbr" \
	"$(INTDIR)\sv_world.sbr" \
	"$(INTDIR)\sys_win.sbr" \
	"$(INTDIR)\vid_dll.sbr" \
	"$(INTDIR)\view.sbr"

"$(OUTDIR)\quake2.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 winmm.lib wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /incremental:no /debug /machine:I386
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=winmm.lib wsock32.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)/quake2.pdb" /debug /machine:I386 /out:"$(OUTDIR)/quake2.exe" 
LINK32_OBJS= \
	"$(INTDIR)\cd_win.obj" \
	"$(INTDIR)\cl_demo.obj" \
	"$(INTDIR)\cl_ents.obj" \
	"$(INTDIR)\cl_fx.obj" \
	"$(INTDIR)\cl_input.obj" \
	"$(INTDIR)\cl_main.obj" \
	"$(INTDIR)\cl_parse.obj" \
	"$(INTDIR)\cl_tent.obj" \
	"$(INTDIR)\cmd.obj" \
	"$(INTDIR)\cmodel.obj" \
	"$(INTDIR)\common.obj" \
	"$(INTDIR)\console.obj" \
	"$(INTDIR)\crc.obj" \
	"$(INTDIR)\cvar.obj" \
	"$(INTDIR)\files.obj" \
	"$(INTDIR)\in_win.obj" \
	"$(INTDIR)\keys.obj" \
	"$(INTDIR)\menu.obj" \
	"$(INTDIR)\net_chan.obj" \
	"$(INTDIR)\net_wins.obj" \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\sbar2.obj" \
	"$(INTDIR)\scr_cin.obj" \
	"$(INTDIR)\screen.obj" \
	"$(INTDIR)\snd_dma.obj" \
	"$(INTDIR)\snd_mem.obj" \
	"$(INTDIR)\snd_mix.obj" \
	"$(INTDIR)\snd_win.obj" \
	"$(INTDIR)\sv_ccmds.obj" \
	"$(INTDIR)\sv_ents.obj" \
	"$(INTDIR)\sv_game.obj" \
	"$(INTDIR)\sv_init.obj" \
	"$(INTDIR)\sv_main.obj" \
	"$(INTDIR)\sv_move.obj" \
	"$(INTDIR)\sv_phys.obj" \
	"$(INTDIR)\sv_send.obj" \
	"$(INTDIR)\sv_user.obj" \
	"$(INTDIR)\sv_world.obj" \
	"$(INTDIR)\sys_win.obj" \
	"$(INTDIR)\vid_dll.obj" \
	"$(INTDIR)\view.obj"

"$(OUTDIR)\quake2.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ref_soft\ref_soft"
# PROP BASE Intermediate_Dir "ref_soft\ref_soft"
# PROP BASE Target_Dir "ref_soft"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "ref_soft\Release"
# PROP Target_Dir "ref_soft"
OUTDIR=.\Release
INTDIR=.\ref_soft\Release

ALL : "$(OUTDIR)\ref_soft.dll"

CLEAN : 
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\r_aclip.obj"
	-@erase "$(INTDIR)\r_alias.obj"
	-@erase "$(INTDIR)\r_bsp.obj"
	-@erase "$(INTDIR)\r_draw.obj"
	-@erase "$(INTDIR)\r_edge.obj"
	-@erase "$(INTDIR)\r_image.obj"
	-@erase "$(INTDIR)\r_inter.obj"
	-@erase "$(INTDIR)\r_light.obj"
	-@erase "$(INTDIR)\r_main.obj"
	-@erase "$(INTDIR)\r_misc.obj"
	-@erase "$(INTDIR)\r_model.obj"
	-@erase "$(INTDIR)\r_part.obj"
	-@erase "$(INTDIR)\r_poly.obj"
	-@erase "$(INTDIR)\r_polyse.obj"
	-@erase "$(INTDIR)\r_rast.obj"
	-@erase "$(INTDIR)\r_scan.obj"
	-@erase "$(INTDIR)\r_sprite.obj"
	-@erase "$(INTDIR)\r_surf.obj"
	-@erase "$(INTDIR)\rw_ddraw.obj"
	-@erase "$(INTDIR)\rw_dib.obj"
	-@erase "$(INTDIR)\rw_imp.obj"
	-@erase "$(OUTDIR)\ref_soft.dll"
	-@erase "$(OUTDIR)\ref_soft.exp"
	-@erase "$(OUTDIR)\ref_soft.lib"
	-@erase ".\Release\r_aclipa.obj"
	-@erase ".\Release\r_draw16.obj"
	-@erase ".\Release\r_drawa.obj"
	-@erase ".\Release\r_edgea.obj"
	-@erase ".\Release\r_scana.obj"
	-@erase ".\Release\r_spr8.obj"
	-@erase ".\Release\r_surf8.obj"
	-@erase ".\Release\r_varsa.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/ref_soft.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\ref_soft\Release/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/ref_soft.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386 /nodefaultlib:"libc"
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib\
 comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib\
 odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/ref_soft.pdb" /machine:I386 /nodefaultlib:"libc"\
 /def:".\ref_soft\ref_soft.def" /out:"$(OUTDIR)/ref_soft.dll"\
 /implib:"$(OUTDIR)/ref_soft.lib" 
DEF_FILE= \
	".\ref_soft\ref_soft.def"
LINK32_OBJS= \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\r_aclip.obj" \
	"$(INTDIR)\r_alias.obj" \
	"$(INTDIR)\r_bsp.obj" \
	"$(INTDIR)\r_draw.obj" \
	"$(INTDIR)\r_edge.obj" \
	"$(INTDIR)\r_image.obj" \
	"$(INTDIR)\r_inter.obj" \
	"$(INTDIR)\r_light.obj" \
	"$(INTDIR)\r_main.obj" \
	"$(INTDIR)\r_misc.obj" \
	"$(INTDIR)\r_model.obj" \
	"$(INTDIR)\r_part.obj" \
	"$(INTDIR)\r_poly.obj" \
	"$(INTDIR)\r_polyse.obj" \
	"$(INTDIR)\r_rast.obj" \
	"$(INTDIR)\r_scan.obj" \
	"$(INTDIR)\r_sprite.obj" \
	"$(INTDIR)\r_surf.obj" \
	"$(INTDIR)\rw_ddraw.obj" \
	"$(INTDIR)\rw_dib.obj" \
	"$(INTDIR)\rw_imp.obj" \
	".\Release\r_aclipa.obj" \
	".\Release\r_draw16.obj" \
	".\Release\r_drawa.obj" \
	".\Release\r_edgea.obj" \
	".\Release\r_scana.obj" \
	".\Release\r_spr8.obj" \
	".\Release\r_surf8.obj" \
	".\Release\r_varsa.obj"

"$(OUTDIR)\ref_soft.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ref_soft\ref_soft"
# PROP BASE Intermediate_Dir "ref_soft\ref_soft"
# PROP BASE Target_Dir "ref_soft"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "ref_soft\Debug"
# PROP Target_Dir "ref_soft"
OUTDIR=.\Debug
INTDIR=.\ref_soft\Debug

ALL : "$(OUTDIR)\ref_soft.dll"

CLEAN : 
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\r_aclip.obj"
	-@erase "$(INTDIR)\r_alias.obj"
	-@erase "$(INTDIR)\r_bsp.obj"
	-@erase "$(INTDIR)\r_draw.obj"
	-@erase "$(INTDIR)\r_edge.obj"
	-@erase "$(INTDIR)\r_image.obj"
	-@erase "$(INTDIR)\r_inter.obj"
	-@erase "$(INTDIR)\r_light.obj"
	-@erase "$(INTDIR)\r_main.obj"
	-@erase "$(INTDIR)\r_misc.obj"
	-@erase "$(INTDIR)\r_model.obj"
	-@erase "$(INTDIR)\r_part.obj"
	-@erase "$(INTDIR)\r_poly.obj"
	-@erase "$(INTDIR)\r_polyse.obj"
	-@erase "$(INTDIR)\r_rast.obj"
	-@erase "$(INTDIR)\r_scan.obj"
	-@erase "$(INTDIR)\r_sprite.obj"
	-@erase "$(INTDIR)\r_surf.obj"
	-@erase "$(INTDIR)\rw_ddraw.obj"
	-@erase "$(INTDIR)\rw_dib.obj"
	-@erase "$(INTDIR)\rw_imp.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\ref_soft.dll"
	-@erase "$(OUTDIR)\ref_soft.exp"
	-@erase "$(OUTDIR)\ref_soft.lib"
	-@erase "$(OUTDIR)\ref_soft.pdb"
	-@erase ".\Debug\r_aclipa.obj"
	-@erase ".\Debug\r_draw16.obj"
	-@erase ".\Debug\r_drawa.obj"
	-@erase ".\Debug\r_edgea.obj"
	-@erase ".\Debug\r_scana.obj"
	-@erase ".\Debug\r_spr8.obj"
	-@erase ".\Debug\r_surf8.obj"
	-@erase ".\Debug\r_varsa.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /Fp"$(INTDIR)/ref_soft.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\ref_soft\Debug/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/ref_soft.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:no /debug /machine:I386 /nodefaultlib:"libc"
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib\
 comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib\
 odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/ref_soft.pdb" /debug /machine:I386 /nodefaultlib:"libc"\
 /def:".\ref_soft\ref_soft.def" /out:"$(OUTDIR)/ref_soft.dll"\
 /implib:"$(OUTDIR)/ref_soft.lib" 
DEF_FILE= \
	".\ref_soft\ref_soft.def"
LINK32_OBJS= \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\r_aclip.obj" \
	"$(INTDIR)\r_alias.obj" \
	"$(INTDIR)\r_bsp.obj" \
	"$(INTDIR)\r_draw.obj" \
	"$(INTDIR)\r_edge.obj" \
	"$(INTDIR)\r_image.obj" \
	"$(INTDIR)\r_inter.obj" \
	"$(INTDIR)\r_light.obj" \
	"$(INTDIR)\r_main.obj" \
	"$(INTDIR)\r_misc.obj" \
	"$(INTDIR)\r_model.obj" \
	"$(INTDIR)\r_part.obj" \
	"$(INTDIR)\r_poly.obj" \
	"$(INTDIR)\r_polyse.obj" \
	"$(INTDIR)\r_rast.obj" \
	"$(INTDIR)\r_scan.obj" \
	"$(INTDIR)\r_sprite.obj" \
	"$(INTDIR)\r_surf.obj" \
	"$(INTDIR)\rw_ddraw.obj" \
	"$(INTDIR)\rw_dib.obj" \
	"$(INTDIR)\rw_imp.obj" \
	".\Debug\r_aclipa.obj" \
	".\Debug\r_draw16.obj" \
	".\Debug\r_drawa.obj" \
	".\Debug\r_edgea.obj" \
	".\Debug\r_scana.obj" \
	".\Debug\r_spr8.obj" \
	".\Debug\r_surf8.obj" \
	".\Debug\r_varsa.obj"

"$(OUTDIR)\ref_soft.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ref_gl\ref_gl__"
# PROP BASE Intermediate_Dir "ref_gl\ref_gl__"
# PROP BASE Target_Dir "ref_gl"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "ref_gl\Release"
# PROP Target_Dir "ref_gl"
OUTDIR=.\Release
INTDIR=.\ref_gl\Release

ALL : "$(OUTDIR)\ref_gl.dll"

CLEAN : 
	-@erase "$(INTDIR)\gl_draw.obj"
	-@erase "$(INTDIR)\gl_inter.obj"
	-@erase "$(INTDIR)\gl_light.obj"
	-@erase "$(INTDIR)\gl_mesh.obj"
	-@erase "$(INTDIR)\gl_model.obj"
	-@erase "$(INTDIR)\gl_rmain.obj"
	-@erase "$(INTDIR)\gl_rmisc.obj"
	-@erase "$(INTDIR)\gl_rsurf.obj"
	-@erase "$(INTDIR)\gl_textr.obj"
	-@erase "$(INTDIR)\gl_warp.obj"
	-@erase "$(INTDIR)\glw_imp.obj"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\qgl_win.obj"
	-@erase "$(OUTDIR)\ref_gl.dll"
	-@erase "$(OUTDIR)\ref_gl.exp"
	-@erase "$(OUTDIR)\ref_gl.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /G5 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/ref_gl.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\ref_gl\Release/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/ref_gl.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 winmm.lib opengl32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
LINK32_FLAGS=winmm.lib opengl32.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll\
 /incremental:no /pdb:"$(OUTDIR)/ref_gl.pdb" /machine:I386\
 /def:".\ref_gl\ref_gl.def" /out:"$(OUTDIR)/ref_gl.dll"\
 /implib:"$(OUTDIR)/ref_gl.lib" 
DEF_FILE= \
	".\ref_gl\ref_gl.def"
LINK32_OBJS= \
	"$(INTDIR)\gl_draw.obj" \
	"$(INTDIR)\gl_inter.obj" \
	"$(INTDIR)\gl_light.obj" \
	"$(INTDIR)\gl_mesh.obj" \
	"$(INTDIR)\gl_model.obj" \
	"$(INTDIR)\gl_rmain.obj" \
	"$(INTDIR)\gl_rmisc.obj" \
	"$(INTDIR)\gl_rsurf.obj" \
	"$(INTDIR)\gl_textr.obj" \
	"$(INTDIR)\gl_warp.obj" \
	"$(INTDIR)\glw_imp.obj" \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\qgl_win.obj"

"$(OUTDIR)\ref_gl.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ref_gl\ref_gl__"
# PROP BASE Intermediate_Dir "ref_gl\ref_gl__"
# PROP BASE Target_Dir "ref_gl"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "ref_gl\Debug"
# PROP Target_Dir "ref_gl"
OUTDIR=.\Debug
INTDIR=.\ref_gl\Debug

ALL : "$(OUTDIR)\ref_gl.dll"

CLEAN : 
	-@erase "$(INTDIR)\gl_draw.obj"
	-@erase "$(INTDIR)\gl_inter.obj"
	-@erase "$(INTDIR)\gl_light.obj"
	-@erase "$(INTDIR)\gl_mesh.obj"
	-@erase "$(INTDIR)\gl_model.obj"
	-@erase "$(INTDIR)\gl_rmain.obj"
	-@erase "$(INTDIR)\gl_rmisc.obj"
	-@erase "$(INTDIR)\gl_rsurf.obj"
	-@erase "$(INTDIR)\gl_textr.obj"
	-@erase "$(INTDIR)\gl_warp.obj"
	-@erase "$(INTDIR)\glw_imp.obj"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\qgl_win.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\ref_gl.dll"
	-@erase "$(OUTDIR)\ref_gl.exp"
	-@erase "$(OUTDIR)\ref_gl.lib"
	-@erase "$(OUTDIR)\ref_gl.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /Fp"$(INTDIR)/ref_gl.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\ref_gl\Debug/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/ref_gl.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 winmm.lib opengl32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:no /debug /machine:I386
LINK32_FLAGS=winmm.lib opengl32.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll\
 /incremental:no /pdb:"$(OUTDIR)/ref_gl.pdb" /debug /machine:I386\
 /def:".\ref_gl\ref_gl.def" /out:"$(OUTDIR)/ref_gl.dll"\
 /implib:"$(OUTDIR)/ref_gl.lib" 
DEF_FILE= \
	".\ref_gl\ref_gl.def"
LINK32_OBJS= \
	"$(INTDIR)\gl_draw.obj" \
	"$(INTDIR)\gl_inter.obj" \
	"$(INTDIR)\gl_light.obj" \
	"$(INTDIR)\gl_mesh.obj" \
	"$(INTDIR)\gl_model.obj" \
	"$(INTDIR)\gl_rmain.obj" \
	"$(INTDIR)\gl_rmisc.obj" \
	"$(INTDIR)\gl_rsurf.obj" \
	"$(INTDIR)\gl_textr.obj" \
	"$(INTDIR)\gl_warp.obj" \
	"$(INTDIR)\glw_imp.obj" \
	"$(INTDIR)\q_shared.obj" \
	"$(INTDIR)\qgl_win.obj"

"$(OUTDIR)\ref_gl.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "game - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "game\Release"
# PROP BASE Intermediate_Dir "game\Release"
# PROP BASE Target_Dir "game"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "game\Release"
# PROP Target_Dir "game"
OUTDIR=.\Release
INTDIR=.\game\Release

ALL : "$(OUTDIR)\game.dll"

CLEAN : 
	-@erase "$(INTDIR)\g_ai.obj"
	-@erase "$(INTDIR)\g_bersrk.obj"
	-@erase "$(INTDIR)\g_brain.obj"
	-@erase "$(INTDIR)\g_chick.obj"
	-@erase "$(INTDIR)\g_client.obj"
	-@erase "$(INTDIR)\g_cmds.obj"
	-@erase "$(INTDIR)\g_combat.obj"
	-@erase "$(INTDIR)\g_flipper.obj"
	-@erase "$(INTDIR)\g_float.obj"
	-@erase "$(INTDIR)\g_flyer.obj"
	-@erase "$(INTDIR)\g_func.obj"
	-@erase "$(INTDIR)\g_gladtr.obj"
	-@erase "$(INTDIR)\g_gunner.obj"
	-@erase "$(INTDIR)\g_hover.obj"
	-@erase "$(INTDIR)\g_inftry.obj"
	-@erase "$(INTDIR)\g_items.obj"
	-@erase "$(INTDIR)\g_main.obj"
	-@erase "$(INTDIR)\g_medic.obj"
	-@erase "$(INTDIR)\g_misc.obj"
	-@erase "$(INTDIR)\g_monster.obj"
	-@erase "$(INTDIR)\g_parasite.obj"
	-@erase "$(INTDIR)\g_player.obj"
	-@erase "$(INTDIR)\g_pmove.obj"
	-@erase "$(INTDIR)\g_ptrail.obj"
	-@erase "$(INTDIR)\g_pview.obj"
	-@erase "$(INTDIR)\g_pweapon.obj"
	-@erase "$(INTDIR)\g_soldier.obj"
	-@erase "$(INTDIR)\g_tank.obj"
	-@erase "$(INTDIR)\g_target.obj"
	-@erase "$(INTDIR)\g_trigger.obj"
	-@erase "$(INTDIR)\g_utils.obj"
	-@erase "$(INTDIR)\g_weapon.obj"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(OUTDIR)\game.dll"
	-@erase "$(OUTDIR)\game.exp"
	-@erase "$(OUTDIR)\game.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/game.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\game\Release/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/game.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /base:0x20000000 /subsystem:windows /dll /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /base:0x20000000 /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/game.pdb" /machine:I386 /def:".\game\game.def"\
 /out:"$(OUTDIR)/game.dll" /implib:"$(OUTDIR)/game.lib" 
DEF_FILE= \
	".\game\game.def"
LINK32_OBJS= \
	"$(INTDIR)\g_ai.obj" \
	"$(INTDIR)\g_bersrk.obj" \
	"$(INTDIR)\g_brain.obj" \
	"$(INTDIR)\g_chick.obj" \
	"$(INTDIR)\g_client.obj" \
	"$(INTDIR)\g_cmds.obj" \
	"$(INTDIR)\g_combat.obj" \
	"$(INTDIR)\g_flipper.obj" \
	"$(INTDIR)\g_float.obj" \
	"$(INTDIR)\g_flyer.obj" \
	"$(INTDIR)\g_func.obj" \
	"$(INTDIR)\g_gladtr.obj" \
	"$(INTDIR)\g_gunner.obj" \
	"$(INTDIR)\g_hover.obj" \
	"$(INTDIR)\g_inftry.obj" \
	"$(INTDIR)\g_items.obj" \
	"$(INTDIR)\g_main.obj" \
	"$(INTDIR)\g_medic.obj" \
	"$(INTDIR)\g_misc.obj" \
	"$(INTDIR)\g_monster.obj" \
	"$(INTDIR)\g_parasite.obj" \
	"$(INTDIR)\g_player.obj" \
	"$(INTDIR)\g_pmove.obj" \
	"$(INTDIR)\g_ptrail.obj" \
	"$(INTDIR)\g_pview.obj" \
	"$(INTDIR)\g_pweapon.obj" \
	"$(INTDIR)\g_soldier.obj" \
	"$(INTDIR)\g_tank.obj" \
	"$(INTDIR)\g_target.obj" \
	"$(INTDIR)\g_trigger.obj" \
	"$(INTDIR)\g_utils.obj" \
	"$(INTDIR)\g_weapon.obj" \
	"$(INTDIR)\q_shared.obj"

"$(OUTDIR)\game.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "game\Debug"
# PROP BASE Intermediate_Dir "game\Debug"
# PROP BASE Target_Dir "game"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "game\Debug"
# PROP Target_Dir "game"
OUTDIR=.\Debug
INTDIR=.\game\Debug

ALL : "$(OUTDIR)\game.dll"

CLEAN : 
	-@erase "$(INTDIR)\g_ai.obj"
	-@erase "$(INTDIR)\g_bersrk.obj"
	-@erase "$(INTDIR)\g_brain.obj"
	-@erase "$(INTDIR)\g_chick.obj"
	-@erase "$(INTDIR)\g_client.obj"
	-@erase "$(INTDIR)\g_cmds.obj"
	-@erase "$(INTDIR)\g_combat.obj"
	-@erase "$(INTDIR)\g_flipper.obj"
	-@erase "$(INTDIR)\g_float.obj"
	-@erase "$(INTDIR)\g_flyer.obj"
	-@erase "$(INTDIR)\g_func.obj"
	-@erase "$(INTDIR)\g_gladtr.obj"
	-@erase "$(INTDIR)\g_gunner.obj"
	-@erase "$(INTDIR)\g_hover.obj"
	-@erase "$(INTDIR)\g_inftry.obj"
	-@erase "$(INTDIR)\g_items.obj"
	-@erase "$(INTDIR)\g_main.obj"
	-@erase "$(INTDIR)\g_medic.obj"
	-@erase "$(INTDIR)\g_misc.obj"
	-@erase "$(INTDIR)\g_monster.obj"
	-@erase "$(INTDIR)\g_parasite.obj"
	-@erase "$(INTDIR)\g_player.obj"
	-@erase "$(INTDIR)\g_pmove.obj"
	-@erase "$(INTDIR)\g_ptrail.obj"
	-@erase "$(INTDIR)\g_pview.obj"
	-@erase "$(INTDIR)\g_pweapon.obj"
	-@erase "$(INTDIR)\g_soldier.obj"
	-@erase "$(INTDIR)\g_tank.obj"
	-@erase "$(INTDIR)\g_target.obj"
	-@erase "$(INTDIR)\g_trigger.obj"
	-@erase "$(INTDIR)\g_utils.obj"
	-@erase "$(INTDIR)\g_weapon.obj"
	-@erase "$(INTDIR)\q_shared.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\game.dll"
	-@erase "$(OUTDIR)\game.exp"
	-@erase "$(OUTDIR)\game.lib"
	-@erase "$(OUTDIR)\game.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP=cl.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/game.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\game\Debug/
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

MTL=mktyplib.exe
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
RSC=rc.exe
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/game.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /base:0x20000000 /subsystem:windows /dll /incremental:no /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /base:0x20000000 /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/game.pdb" /debug /machine:I386 /def:".\game\game.def"\
 /out:"$(OUTDIR)/game.dll" /implib:"$(OUTDIR)/game.lib" 
DEF_FILE= \
	".\game\game.def"
LINK32_OBJS= \
	"$(INTDIR)\g_ai.obj" \
	"$(INTDIR)\g_bersrk.obj" \
	"$(INTDIR)\g_brain.obj" \
	"$(INTDIR)\g_chick.obj" \
	"$(INTDIR)\g_client.obj" \
	"$(INTDIR)\g_cmds.obj" \
	"$(INTDIR)\g_combat.obj" \
	"$(INTDIR)\g_flipper.obj" \
	"$(INTDIR)\g_float.obj" \
	"$(INTDIR)\g_flyer.obj" \
	"$(INTDIR)\g_func.obj" \
	"$(INTDIR)\g_gladtr.obj" \
	"$(INTDIR)\g_gunner.obj" \
	"$(INTDIR)\g_hover.obj" \
	"$(INTDIR)\g_inftry.obj" \
	"$(INTDIR)\g_items.obj" \
	"$(INTDIR)\g_main.obj" \
	"$(INTDIR)\g_medic.obj" \
	"$(INTDIR)\g_misc.obj" \
	"$(INTDIR)\g_monster.obj" \
	"$(INTDIR)\g_parasite.obj" \
	"$(INTDIR)\g_player.obj" \
	"$(INTDIR)\g_pmove.obj" \
	"$(INTDIR)\g_ptrail.obj" \
	"$(INTDIR)\g_pview.obj" \
	"$(INTDIR)\g_pweapon.obj" \
	"$(INTDIR)\g_soldier.obj" \
	"$(INTDIR)\g_tank.obj" \
	"$(INTDIR)\g_target.obj" \
	"$(INTDIR)\g_trigger.obj" \
	"$(INTDIR)\g_utils.obj" \
	"$(INTDIR)\g_weapon.obj" \
	"$(INTDIR)\q_shared.obj"

"$(OUTDIR)\game.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

################################################################################
# Begin Target

# Name "quake2 - Win32 Release"
# Name "quake2 - Win32 Debug"

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\qcommon\cmodel.c
DEP_CPP_CMODE=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cmodel.obj" : $(SOURCE) $(DEP_CPP_CMODE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cmodel.obj" : $(SOURCE) $(DEP_CPP_CMODE) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cmodel.sbr" : $(SOURCE) $(DEP_CPP_CMODE) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\common.c
DEP_CPP_COMMO=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\common.obj" : $(SOURCE) $(DEP_CPP_COMMO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\common.obj" : $(SOURCE) $(DEP_CPP_COMMO) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\common.sbr" : $(SOURCE) $(DEP_CPP_COMMO) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\cvar.c
DEP_CPP_CVAR_=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cvar.obj" : $(SOURCE) $(DEP_CPP_CVAR_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cvar.obj" : $(SOURCE) $(DEP_CPP_CVAR_) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cvar.sbr" : $(SOURCE) $(DEP_CPP_CVAR_) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\files.c
DEP_CPP_FILES=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\files.obj" : $(SOURCE) $(DEP_CPP_FILES) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\files.obj" : $(SOURCE) $(DEP_CPP_FILES) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\files.sbr" : $(SOURCE) $(DEP_CPP_FILES) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\net_chan.c
DEP_CPP_NET_C=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\net_chan.obj" : $(SOURCE) $(DEP_CPP_NET_C) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\net_chan.obj" : $(SOURCE) $(DEP_CPP_NET_C) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\net_chan.sbr" : $(SOURCE) $(DEP_CPP_NET_C) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\cmd.c
DEP_CPP_CMD_C=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cmd.obj" : $(SOURCE) $(DEP_CPP_CMD_C) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cmd.obj" : $(SOURCE) $(DEP_CPP_CMD_C) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cmd.sbr" : $(SOURCE) $(DEP_CPP_CMD_C) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\view.c
DEP_CPP_VIEW_=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\view.obj" : $(SOURCE) $(DEP_CPP_VIEW_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\view.obj" : $(SOURCE) $(DEP_CPP_VIEW_) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\view.sbr" : $(SOURCE) $(DEP_CPP_VIEW_) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_demo.c
DEP_CPP_CL_DE=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_demo.obj" : $(SOURCE) $(DEP_CPP_CL_DE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_demo.obj" : $(SOURCE) $(DEP_CPP_CL_DE) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_demo.sbr" : $(SOURCE) $(DEP_CPP_CL_DE) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_ents.c
DEP_CPP_CL_EN=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_ents.obj" : $(SOURCE) $(DEP_CPP_CL_EN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_ents.obj" : $(SOURCE) $(DEP_CPP_CL_EN) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_ents.sbr" : $(SOURCE) $(DEP_CPP_CL_EN) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_input.c
DEP_CPP_CL_IN=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_input.obj" : $(SOURCE) $(DEP_CPP_CL_IN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_input.obj" : $(SOURCE) $(DEP_CPP_CL_IN) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_input.sbr" : $(SOURCE) $(DEP_CPP_CL_IN) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_main.c
DEP_CPP_CL_MA=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_main.obj" : $(SOURCE) $(DEP_CPP_CL_MA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_main.obj" : $(SOURCE) $(DEP_CPP_CL_MA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_main.sbr" : $(SOURCE) $(DEP_CPP_CL_MA) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_parse.c
DEP_CPP_CL_PA=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_parse.obj" : $(SOURCE) $(DEP_CPP_CL_PA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_parse.obj" : $(SOURCE) $(DEP_CPP_CL_PA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_parse.sbr" : $(SOURCE) $(DEP_CPP_CL_PA) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_tent.c
DEP_CPP_CL_TE=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_tent.obj" : $(SOURCE) $(DEP_CPP_CL_TE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_tent.obj" : $(SOURCE) $(DEP_CPP_CL_TE) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_tent.sbr" : $(SOURCE) $(DEP_CPP_CL_TE) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\console.c
DEP_CPP_CONSO=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\console.obj" : $(SOURCE) $(DEP_CPP_CONSO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\console.obj" : $(SOURCE) $(DEP_CPP_CONSO) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\console.sbr" : $(SOURCE) $(DEP_CPP_CONSO) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\keys.c
DEP_CPP_KEYS_=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\keys.obj" : $(SOURCE) $(DEP_CPP_KEYS_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\keys.obj" : $(SOURCE) $(DEP_CPP_KEYS_) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\keys.sbr" : $(SOURCE) $(DEP_CPP_KEYS_) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\menu.c
DEP_CPP_MENU_=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\menu.obj" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\menu.obj" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\menu.sbr" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\screen.c
DEP_CPP_SCREE=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\screen.obj" : $(SOURCE) $(DEP_CPP_SCREE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\screen.obj" : $(SOURCE) $(DEP_CPP_SCREE) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\screen.sbr" : $(SOURCE) $(DEP_CPP_SCREE) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\snd_dma.c
DEP_CPP_SND_D=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\snd_loc.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\snd_dma.obj" : $(SOURCE) $(DEP_CPP_SND_D) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\snd_dma.obj" : $(SOURCE) $(DEP_CPP_SND_D) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\snd_dma.sbr" : $(SOURCE) $(DEP_CPP_SND_D) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\snd_mem.c
DEP_CPP_SND_M=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\snd_loc.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\snd_mem.obj" : $(SOURCE) $(DEP_CPP_SND_M) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\snd_mem.obj" : $(SOURCE) $(DEP_CPP_SND_M) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\snd_mem.sbr" : $(SOURCE) $(DEP_CPP_SND_M) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\snd_mix.c
DEP_CPP_SND_MI=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\snd_loc.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\snd_mix.obj" : $(SOURCE) $(DEP_CPP_SND_MI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\snd_mix.obj" : $(SOURCE) $(DEP_CPP_SND_MI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\snd_mix.sbr" : $(SOURCE) $(DEP_CPP_SND_MI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_ccmds.c
DEP_CPP_SV_CC=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_ccmds.obj" : $(SOURCE) $(DEP_CPP_SV_CC) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_ccmds.obj" : $(SOURCE) $(DEP_CPP_SV_CC) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_ccmds.sbr" : $(SOURCE) $(DEP_CPP_SV_CC) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_ents.c
DEP_CPP_SV_EN=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_ents.obj" : $(SOURCE) $(DEP_CPP_SV_EN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_ents.obj" : $(SOURCE) $(DEP_CPP_SV_EN) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_ents.sbr" : $(SOURCE) $(DEP_CPP_SV_EN) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_init.c
DEP_CPP_SV_IN=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_init.obj" : $(SOURCE) $(DEP_CPP_SV_IN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_init.obj" : $(SOURCE) $(DEP_CPP_SV_IN) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_init.sbr" : $(SOURCE) $(DEP_CPP_SV_IN) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_main.c
DEP_CPP_SV_MA=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_main.obj" : $(SOURCE) $(DEP_CPP_SV_MA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_main.obj" : $(SOURCE) $(DEP_CPP_SV_MA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_main.sbr" : $(SOURCE) $(DEP_CPP_SV_MA) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_phys.c
DEP_CPP_SV_PH=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_phys.obj" : $(SOURCE) $(DEP_CPP_SV_PH) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_phys.obj" : $(SOURCE) $(DEP_CPP_SV_PH) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_phys.sbr" : $(SOURCE) $(DEP_CPP_SV_PH) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_send.c
DEP_CPP_SV_SE=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_send.obj" : $(SOURCE) $(DEP_CPP_SV_SE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_send.obj" : $(SOURCE) $(DEP_CPP_SV_SE) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_send.sbr" : $(SOURCE) $(DEP_CPP_SV_SE) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_user.c
DEP_CPP_SV_US=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_user.obj" : $(SOURCE) $(DEP_CPP_SV_US) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_user.obj" : $(SOURCE) $(DEP_CPP_SV_US) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_user.sbr" : $(SOURCE) $(DEP_CPP_SV_US) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\qcommon.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\client.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\server.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\vid_dll.c
DEP_CPP_VID_D=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\vid_dll.obj" : $(SOURCE) $(DEP_CPP_VID_D) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\vid_dll.obj" : $(SOURCE) $(DEP_CPP_VID_D) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\vid_dll.sbr" : $(SOURCE) $(DEP_CPP_VID_D) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\in_win.c
DEP_CPP_IN_WI=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\in_win.obj" : $(SOURCE) $(DEP_CPP_IN_WI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\in_win.obj" : $(SOURCE) $(DEP_CPP_IN_WI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\in_win.sbr" : $(SOURCE) $(DEP_CPP_IN_WI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\net_wins.c
DEP_CPP_NET_W=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\net_wins.obj" : $(SOURCE) $(DEP_CPP_NET_W) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\net_wins.obj" : $(SOURCE) $(DEP_CPP_NET_W) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\net_wins.sbr" : $(SOURCE) $(DEP_CPP_NET_W) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\snd_win.c
DEP_CPP_SND_W=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\snd_loc.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\snd_win.obj" : $(SOURCE) $(DEP_CPP_SND_W) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\snd_win.obj" : $(SOURCE) $(DEP_CPP_SND_W) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\snd_win.sbr" : $(SOURCE) $(DEP_CPP_SND_W) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\sys_win.c
DEP_CPP_SYS_W=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\winquake.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sys_win.obj" : $(SOURCE) $(DEP_CPP_SYS_W) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sys_win.obj" : $(SOURCE) $(DEP_CPP_SYS_W) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sys_win.sbr" : $(SOURCE) $(DEP_CPP_SYS_W) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\cd_win.c
DEP_CPP_CD_WI=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cd_win.obj" : $(SOURCE) $(DEP_CPP_CD_WI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cd_win.obj" : $(SOURCE) $(DEP_CPP_CD_WI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cd_win.sbr" : $(SOURCE) $(DEP_CPP_CD_WI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\bspfile.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\sbar2.c
DEP_CPP_SBAR2=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sbar2.obj" : $(SOURCE) $(DEP_CPP_SBAR2) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sbar2.obj" : $(SOURCE) $(DEP_CPP_SBAR2) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sbar2.sbr" : $(SOURCE) $(DEP_CPP_SBAR2) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\ref.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_game.c
DEP_CPP_SV_GA=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_game.obj" : $(SOURCE) $(DEP_CPP_SV_GA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_game.obj" : $(SOURCE) $(DEP_CPP_SV_GA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_game.sbr" : $(SOURCE) $(DEP_CPP_SV_GA) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\snd_loc.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_move.c
DEP_CPP_SV_MO=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_move.obj" : $(SOURCE) $(DEP_CPP_SV_MO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_move.obj" : $(SOURCE) $(DEP_CPP_SV_MO) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_move.sbr" : $(SOURCE) $(DEP_CPP_SV_MO) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\crc.c
DEP_CPP_CRC_C=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\crc.obj" : $(SOURCE) $(DEP_CPP_CRC_C) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\crc.obj" : $(SOURCE) $(DEP_CPP_CRC_C) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\crc.sbr" : $(SOURCE) $(DEP_CPP_CRC_C) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\cl_fx.c
DEP_CPP_CL_FX=\
	".\client\anorms.h"\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\cl_fx.obj" : $(SOURCE) $(DEP_CPP_CL_FX) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cl_fx.obj" : $(SOURCE) $(DEP_CPP_CL_FX) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cl_fx.sbr" : $(SOURCE) $(DEP_CPP_CL_FX) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\client\scr_cin.c
DEP_CPP_SCR_C=\
	".\client\cdaudio.h"\
	".\client\console.h"\
	".\client\input.h"\
	".\client\keys.h"\
	".\client\ref.h"\
	".\client\sbar.h"\
	".\client\screen.h"\
	".\client\sound.h"\
	".\client\vid.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\win32\..\client\client.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\scr_cin.obj" : $(SOURCE) $(DEP_CPP_SCR_C) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\scr_cin.obj" : $(SOURCE) $(DEP_CPP_SCR_C) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\scr_cin.sbr" : $(SOURCE) $(DEP_CPP_SCR_C) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\qfiles.h

!IF  "$(CFG)" == "quake2 - Win32 Release"

!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\server\sv_world.c
DEP_CPP_SV_WO=\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\sv_world.obj" : $(SOURCE) $(DEP_CPP_SV_WO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\sv_world.obj" : $(SOURCE) $(DEP_CPP_SV_WO) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\sv_world.sbr" : $(SOURCE) $(DEP_CPP_SV_WO) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\q_shared.c
DEP_CPP_Q_SHA=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

!IF  "$(CFG)" == "quake2 - Win32 Release"


"$(INTDIR)\q_shared.obj" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "quake2 - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\q_shared.obj" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\q_shared.sbr" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
# End Target
################################################################################
# Begin Target

# Name "ref_soft - Win32 Release"
# Name "ref_soft - Win32 Debug"

!IF  "$(CFG)" == "ref_soft - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_aclip.c
DEP_CPP_R_ACL=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_aclip.obj" : $(SOURCE) $(DEP_CPP_R_ACL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_alias.c
DEP_CPP_R_ALI=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\anorms.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_alias.obj" : $(SOURCE) $(DEP_CPP_R_ALI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_bsp.c
DEP_CPP_R_BSP=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_bsp.obj" : $(SOURCE) $(DEP_CPP_R_BSP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_draw.c
DEP_CPP_R_DRA=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_draw.obj" : $(SOURCE) $(DEP_CPP_R_DRA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_edge.c
DEP_CPP_R_EDG=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_edge.obj" : $(SOURCE) $(DEP_CPP_R_EDG) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_inter.c
DEP_CPP_R_INT=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_inter.obj" : $(SOURCE) $(DEP_CPP_R_INT) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_light.c
DEP_CPP_R_LIG=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_light.obj" : $(SOURCE) $(DEP_CPP_R_LIG) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_main.c
DEP_CPP_R_MAI=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_main.obj" : $(SOURCE) $(DEP_CPP_R_MAI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_misc.c
DEP_CPP_R_MIS=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_misc.obj" : $(SOURCE) $(DEP_CPP_R_MIS) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_part.c
DEP_CPP_R_PAR=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_part.obj" : $(SOURCE) $(DEP_CPP_R_PAR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_sprite.c
DEP_CPP_R_SPR=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_sprite.obj" : $(SOURCE) $(DEP_CPP_R_SPR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_surf.c
DEP_CPP_R_SUR=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_surf.obj" : $(SOURCE) $(DEP_CPP_R_SUR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_aclipa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_aclipa.asm
InputName=r_aclipa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_aclipa.asm
InputName=r_aclipa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_drawa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_drawa.asm
InputName=r_drawa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_drawa.asm
InputName=r_drawa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_edgea.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_edgea.asm
InputName=r_edgea

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_edgea.asm
InputName=r_edgea

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_varsa.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_varsa.asm
InputName=r_varsa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_varsa.asm
InputName=r_varsa

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\ref_soft.def

!IF  "$(CFG)" == "ref_soft - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_local.h

!IF  "$(CFG)" == "ref_soft - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_image.c
DEP_CPP_R_IMA=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_image.obj" : $(SOURCE) $(DEP_CPP_R_IMA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_poly.c
DEP_CPP_R_POL=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_poly.obj" : $(SOURCE) $(DEP_CPP_R_POL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_polyse.c
DEP_CPP_R_POLY=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\adivtab.h"\
	".\ref_soft\r_model.h"\
	".\ref_soft\rand1k.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_polyse.obj" : $(SOURCE) $(DEP_CPP_R_POLY) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_model.c
DEP_CPP_R_MOD=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_model.obj" : $(SOURCE) $(DEP_CPP_R_MOD) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_rast.c
DEP_CPP_R_RAS=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_rast.obj" : $(SOURCE) $(DEP_CPP_R_RAS) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_surf8.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_surf8.asm
InputName=r_surf8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_surf8.asm
InputName=r_surf8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_spr8.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_spr8.asm
InputName=r_spr8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_spr8.asm
InputName=r_spr8

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_scana.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_scana.asm
InputName=r_scana

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_scana.asm
InputName=r_scana

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_scan.c
DEP_CPP_R_SCA=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	

"$(INTDIR)\r_scan.obj" : $(SOURCE) $(DEP_CPP_R_SCA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_soft\r_draw16.asm

!IF  "$(CFG)" == "ref_soft - Win32 Release"

# Begin Custom Build
OutDir=.\Release
InputPath=.\ref_soft\r_draw16.asm
InputName=r_draw16

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ELSEIF  "$(CFG)" == "ref_soft - Win32 Debug"

# Begin Custom Build
OutDir=.\Debug
InputPath=.\ref_soft\r_draw16.asm
InputName=r_draw16

"$(OUTDIR)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   ml /c /Cp /coff /Fo$(OUTDIR)\$(InputName).obj /Zm /Zi $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\rw_dib.c
DEP_CPP_RW_DI=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	".\win32\rw_win.h"\
	

"$(INTDIR)\rw_dib.obj" : $(SOURCE) $(DEP_CPP_RW_DI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\rw_imp.c
DEP_CPP_RW_IM=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	".\win32\rw_win.h"\
	

"$(INTDIR)\rw_imp.obj" : $(SOURCE) $(DEP_CPP_RW_IM) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\q_shared.c
DEP_CPP_Q_SHA=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

"$(INTDIR)\q_shared.obj" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\rw_ddraw.c
DEP_CPP_RW_DD=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_soft\r_model.h"\
	".\win32\..\ref_soft\r_local.h"\
	".\win32\rw_win.h"\
	

"$(INTDIR)\rw_ddraw.obj" : $(SOURCE) $(DEP_CPP_RW_DD) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
################################################################################
# Begin Target

# Name "ref_gl - Win32 Release"
# Name "ref_gl - Win32 Debug"

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_inter.c
DEP_CPP_GL_IN=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_inter.obj" : $(SOURCE) $(DEP_CPP_GL_IN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_light.c
DEP_CPP_GL_LI=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_light.obj" : $(SOURCE) $(DEP_CPP_GL_LI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_mesh.c
DEP_CPP_GL_ME=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\anorms.h"\
	".\ref_gl\anormtab.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_mesh.obj" : $(SOURCE) $(DEP_CPP_GL_ME) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_model.c
DEP_CPP_GL_MO=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_model.obj" : $(SOURCE) $(DEP_CPP_GL_MO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_rmain.c
DEP_CPP_GL_RM=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_rmain.obj" : $(SOURCE) $(DEP_CPP_GL_RM) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_rmisc.c
DEP_CPP_GL_RMI=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_rmisc.obj" : $(SOURCE) $(DEP_CPP_GL_RMI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_rsurf.c
DEP_CPP_GL_RS=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_rsurf.obj" : $(SOURCE) $(DEP_CPP_GL_RS) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_textr.c
DEP_CPP_GL_TE=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_textr.obj" : $(SOURCE) $(DEP_CPP_GL_TE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_warp.c
DEP_CPP_GL_WA=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	".\ref_gl\warpsin.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_warp.obj" : $(SOURCE) $(DEP_CPP_GL_WA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_draw.c
DEP_CPP_GL_DR=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\gl_draw.obj" : $(SOURCE) $(DEP_CPP_GL_DR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\ref_gl.def

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\ref_gl.h

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\gl_model.h

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ref_gl\qgl.h

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\qgl_win.c
DEP_CPP_QGL_W=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	".\win32\glw_win.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\qgl_win.obj" : $(SOURCE) $(DEP_CPP_QGL_W) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\win32\glw_imp.c
DEP_CPP_GLW_I=\
	".\client\ref.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\ref_gl\gl_local.h"\
	".\ref_gl\gl_model.h"\
	".\ref_gl\qgl.h"\
	".\win32\glw_win.h"\
	".\win32\winquake.h"\
	{$(INCLUDE)}"\gl\gl.h"\
	

"$(INTDIR)\glw_imp.obj" : $(SOURCE) $(DEP_CPP_GLW_I) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\q_shared.c
DEP_CPP_Q_SHA=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

"$(INTDIR)\q_shared.obj" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
################################################################################
# Begin Target

# Name "game - Win32 Release"
# Name "game - Win32 Debug"

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\game\g_ai.c
DEP_CPP_G_AI_=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_ai.obj" : $(SOURCE) $(DEP_CPP_G_AI_) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_bersrk.c
DEP_CPP_G_BER=\
	".\game\g_bersrk.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_bersrk.obj" : $(SOURCE) $(DEP_CPP_G_BER) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_bersrk.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_client.c
DEP_CPP_G_CLI=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_client.obj" : $(SOURCE) $(DEP_CPP_G_CLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_combat.c
DEP_CPP_G_COM=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_combat.obj" : $(SOURCE) $(DEP_CPP_G_COM) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_func.c
DEP_CPP_G_FUN=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_func.obj" : $(SOURCE) $(DEP_CPP_G_FUN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_gladtr.c
DEP_CPP_G_GLA=\
	".\game\g_gladtr.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_gladtr.obj" : $(SOURCE) $(DEP_CPP_G_GLA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_gladtr.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_gunner.c
DEP_CPP_G_GUN=\
	".\game\g_gunner.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_gunner.obj" : $(SOURCE) $(DEP_CPP_G_GUN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_gunner.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_inftry.c
DEP_CPP_G_INF=\
	".\game\g_inftry.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_inftry.obj" : $(SOURCE) $(DEP_CPP_G_INF) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_inftry.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_items.c
DEP_CPP_G_ITE=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_items.obj" : $(SOURCE) $(DEP_CPP_G_ITE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_local.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_main.c
DEP_CPP_G_MAI=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_main.obj" : $(SOURCE) $(DEP_CPP_G_MAI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_misc.c
DEP_CPP_G_MIS=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_misc.obj" : $(SOURCE) $(DEP_CPP_G_MIS) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_monster.c
DEP_CPP_G_MON=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_monster.obj" : $(SOURCE) $(DEP_CPP_G_MON) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_pmove.c
DEP_CPP_G_PMO=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_pmove.obj" : $(SOURCE) $(DEP_CPP_G_PMO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_pweapon.c
DEP_CPP_G_PWE=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_pweapon.obj" : $(SOURCE) $(DEP_CPP_G_PWE) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_soldier.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_utils.c
DEP_CPP_G_UTI=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_utils.obj" : $(SOURCE) $(DEP_CPP_G_UTI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_weapon.c
DEP_CPP_G_WEA=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_weapon.obj" : $(SOURCE) $(DEP_CPP_G_WEA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_target.c
DEP_CPP_G_TAR=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_target.obj" : $(SOURCE) $(DEP_CPP_G_TAR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_trigger.c
DEP_CPP_G_TRI=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_trigger.obj" : $(SOURCE) $(DEP_CPP_G_TRI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_tank.c
DEP_CPP_G_TAN=\
	".\game\g_local.h"\
	".\game\g_tank.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_tank.obj" : $(SOURCE) $(DEP_CPP_G_TAN) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_soldier.c
DEP_CPP_G_SOL=\
	".\game\g_local.h"\
	".\game\g_soldier.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_soldier.obj" : $(SOURCE) $(DEP_CPP_G_SOL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\game.def

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\game.h

!IF  "$(CFG)" == "game - Win32 Release"

!ELSEIF  "$(CFG)" == "game - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_medic.c
DEP_CPP_G_MED=\
	".\game\g_local.h"\
	".\game\g_medic.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_medic.obj" : $(SOURCE) $(DEP_CPP_G_MED) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_flipper.c
DEP_CPP_G_FLI=\
	".\game\g_flipper.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_flipper.obj" : $(SOURCE) $(DEP_CPP_G_FLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_chick.c
DEP_CPP_G_CHI=\
	".\game\g_chick.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_chick.obj" : $(SOURCE) $(DEP_CPP_G_CHI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_parasite.c
DEP_CPP_G_PAR=\
	".\game\g_local.h"\
	".\game\g_parasite.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_parasite.obj" : $(SOURCE) $(DEP_CPP_G_PAR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_flyer.c
DEP_CPP_G_FLY=\
	".\game\g_flyer.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_flyer.obj" : $(SOURCE) $(DEP_CPP_G_FLY) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_ptrail.c
DEP_CPP_G_PTR=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_ptrail.obj" : $(SOURCE) $(DEP_CPP_G_PTR) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_hover.c
DEP_CPP_G_HOV=\
	".\game\g_hover.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_hover.obj" : $(SOURCE) $(DEP_CPP_G_HOV) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_float.c
DEP_CPP_G_FLO=\
	".\game\g_float.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_float.obj" : $(SOURCE) $(DEP_CPP_G_FLO) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_brain.c
DEP_CPP_G_BRA=\
	".\game\g_brain.h"\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_brain.obj" : $(SOURCE) $(DEP_CPP_G_BRA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_cmds.c
DEP_CPP_G_CMD=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_cmds.obj" : $(SOURCE) $(DEP_CPP_G_CMD) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_player.c
DEP_CPP_G_PLA=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_player.obj" : $(SOURCE) $(DEP_CPP_G_PLA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\game\g_pview.c
DEP_CPP_G_PVI=\
	".\game\g_local.h"\
	".\game\game.h"\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	".\server\server.h"\
	

"$(INTDIR)\g_pview.obj" : $(SOURCE) $(DEP_CPP_G_PVI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcommon\q_shared.c
DEP_CPP_Q_SHA=\
	".\qcommon\qcommon.h"\
	".\qcommon\qfiles.h"\
	

"$(INTDIR)\q_shared.obj" : $(SOURCE) $(DEP_CPP_Q_SHA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################
