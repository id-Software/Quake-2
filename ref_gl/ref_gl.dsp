# Microsoft Developer Studio Project File - Name="ref_gl" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102
# TARGTYPE "Win32 (ALPHA) Dynamic-Link Library" 0x0602

CFG=ref_gl - Win32 Debug Alpha
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ref_gl.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ref_gl.mak" CFG="ref_gl - Win32 Debug Alpha"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ref_gl - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_gl - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ref_gl - Win32 Debug Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE "ref_gl - Win32 Release Alpha" (based on "Win32 (ALPHA) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "ref_gl - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\ref_gl__"
# PROP BASE Intermediate_Dir ".\ref_gl__"
# PROP BASE Target_Dir "."
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\release"
# PROP Intermediate_Dir ".\release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir "."
CPP=cl.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W4 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /YX /FD /c
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
# SUBTRACT LINK32 /incremental:yes /debug

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\ref_gl__"
# PROP BASE Intermediate_Dir ".\ref_gl__"
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
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /incremental:no /map /debug /machine:I386
# SUBTRACT LINK32 /profile

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

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
# ADD BASE LINK32 winmm.lib opengl32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /debug /machine:ALPHA
# ADD LINK32 opengl32.lib kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /debug /machine:ALPHA

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ref_gl__"
# PROP BASE Intermediate_Dir "ref_gl__"
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
# SUBTRACT BASE LINK32 /debug
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winmm.lib /nologo /subsystem:windows /dll /machine:ALPHA
# SUBTRACT LINK32 /debug

!ENDIF 

# Begin Target

# Name "ref_gl - Win32 Release"
# Name "ref_gl - Win32 Debug"
# Name "ref_gl - Win32 Debug Alpha"
# Name "ref_gl - Win32 Release Alpha"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\gl_draw.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_DR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_DR=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_DR=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_DR=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_image.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_IM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_IM=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_IM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_IM=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_light.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_LI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_LI=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_LI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_LI=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_mesh.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_ME=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\anorms.h"\
	".\anormtab.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_ME=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_ME=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\anorms.h"\
	".\anormtab.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_ME=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_model.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_MO=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_MO=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_MO=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_MO=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rmain.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_RM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RM=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_RM=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RM=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rmisc.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_RMI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RMI=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_RMI=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RMI=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_rsurf.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_RS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RS=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_RS=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GL_RS=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gl_warp.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GL_WA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	".\warpsin.h"\
	
NODEP_CPP_GL_WA=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GL_WA=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	".\warpsin.h"\
	
NODEP_CPP_GL_WA=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\glw_imp.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_GLW_I=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\glw_win.h"\
	"..\win32\winquake.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GLW_I=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_GLW_I=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\glw_win.h"\
	"..\win32\winquake.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_GLW_I=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\game\q_shared.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_Q_SHA=\
	"..\game\q_shared.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_Q_SHA=\
	"..\game\q_shared.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\q_shwin.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_Q_SHW=\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\winquake.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_Q_SHW=\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\winquake.h"\
	

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\win32\qgl_win.c

!IF  "$(CFG)" == "ref_gl - Win32 Release"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug"

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Debug Alpha"

DEP_CPP_QGL_W=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\glw_win.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_QGL_W=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ELSEIF  "$(CFG)" == "ref_gl - Win32 Release Alpha"

DEP_CPP_QGL_W=\
	"..\client\ref.h"\
	"..\game\q_shared.h"\
	"..\qcommon\qcommon.h"\
	"..\qcommon\qfiles.h"\
	"..\win32\glw_win.h"\
	".\gl_local.h"\
	".\gl_model.h"\
	".\qgl.h"\
	
NODEP_CPP_QGL_W=\
	".\L\gl.h"\
	".\L\glu.h"\
	

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\anorms.h
# End Source File
# Begin Source File

SOURCE=.\anormtab.h
# End Source File
# Begin Source File

SOURCE=.\gl_local.h
# End Source File
# Begin Source File

SOURCE=.\gl_model.h
# End Source File
# Begin Source File

SOURCE=..\win32\glw_win.h
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

SOURCE=.\qgl.h
# End Source File
# Begin Source File

SOURCE=.\qmenu.h
# End Source File
# Begin Source File

SOURCE=..\client\ref.h
# End Source File
# Begin Source File

SOURCE=.\ref_gl.h
# End Source File
# Begin Source File

SOURCE=.\warpsin.h
# End Source File
# Begin Source File

SOURCE=..\win32\winquake.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\ref_gl.def
# End Source File
# End Group
# End Target
# End Project
