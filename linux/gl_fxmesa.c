/*
Copyright (C) 1997-2001 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
/*
** GLW_IMP.C
**
** This file contains ALL Linux specific stuff having to do with the
** OpenGL refresh.  When a port is being made the following functions
** must be implemented by the port:
**
** GLimp_EndFrame
** GLimp_Init
** GLimp_Shutdown
** GLimp_SwitchFullscreen
**
*/

#include <termios.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/vt.h>
#include <stdarg.h>
#include <stdio.h>
#include <signal.h>

#include "../ref_gl/gl_local.h"
#include "../client/keys.h"
#include "../linux/rw_linux.h"

#include "../linux/glw_linux.h"

#include <GL/fxmesa.h>

/*****************************************************************************/

glwstate_t glw_state;

static qboolean GLimp_SwitchFullscreen( int width, int height );
qboolean GLimp_InitGL (void);

extern cvar_t *vid_fullscreen;
extern cvar_t *vid_ref;

static fxMesaContext fc = NULL;

#define NUM_RESOLUTIONS 16

static resolutions[NUM_RESOLUTIONS][3]={ 
	{ 320,200,  GR_RESOLUTION_320x200 },
	{ 320,240,  GR_RESOLUTION_320x240 },
	{ 400,256,  GR_RESOLUTION_400x256 },
	{ 400,300,  GR_RESOLUTION_400x300 },
	{ 512,384,  GR_RESOLUTION_512x384 },
	{ 640,200,  GR_RESOLUTION_640x200 },
	{ 640,350,  GR_RESOLUTION_640x350 },
	{ 640,400,  GR_RESOLUTION_640x400 },
	{ 640,480,  GR_RESOLUTION_640x480 },
	{ 800,600,  GR_RESOLUTION_800x600 },
	{ 960,720,  GR_RESOLUTION_960x720 },
	{ 856,480,  GR_RESOLUTION_856x480 },
	{ 512,256,  GR_RESOLUTION_512x256 },
	{ 1024,768, GR_RESOLUTION_1024x768 },
	{ 1280,1024,GR_RESOLUTION_1280x1024 },
	{ 1600,1200,GR_RESOLUTION_1600x1200 }
};

static int findres(int *width, int *height)
{
	int i;

	for(i=0;i<NUM_RESOLUTIONS;i++)
		if((*width<=resolutions[i][0]) && (*height<=resolutions[i][1])) {
			*width = resolutions[i][0];
			*height = resolutions[i][1];
			return resolutions[i][2];
		}
        
	*width = 640;
	*height = 480;
	return GR_RESOLUTION_640x480;
}

static void signal_handler(int sig)
{
	printf("Received signal %d, exiting...\n", sig);
	GLimp_Shutdown();
	_exit(0);
}

static void InitSig(void)
{
	signal(SIGHUP, signal_handler);
	signal(SIGQUIT, signal_handler);
	signal(SIGILL, signal_handler);
	signal(SIGTRAP, signal_handler);
	signal(SIGIOT, signal_handler);
	signal(SIGBUS, signal_handler);
	signal(SIGFPE, signal_handler);
	signal(SIGSEGV, signal_handler);
	signal(SIGTERM, signal_handler);
}

/*
** GLimp_SetMode
*/
int GLimp_SetMode( int *pwidth, int *pheight, int mode, qboolean fullscreen )
{
	int width, height;
	GLint attribs[32];

	ri.Con_Printf( PRINT_ALL, "Initializing OpenGL display\n");

	ri.Con_Printf (PRINT_ALL, "...setting mode %d:", mode );

	if ( !ri.Vid_GetModeInfo( &width, &height, mode ) )
	{
		ri.Con_Printf( PRINT_ALL, " invalid mode\n" );
		return rserr_invalid_mode;
	}

	ri.Con_Printf( PRINT_ALL, " %d %d\n", width, height );

	// destroy the existing window
	GLimp_Shutdown ();

	// set fx attribs
	attribs[0] = FXMESA_DOUBLEBUFFER;
	attribs[1] = FXMESA_ALPHA_SIZE;
	attribs[2] = 1;
	attribs[3] = FXMESA_DEPTH_SIZE;
	attribs[4] = 1;
	attribs[5] = FXMESA_NONE;

	fc = qfxMesaCreateContext(0, findres(&width, &height), GR_REFRESH_75Hz, 
		attribs);
	if (!fc)
		return rserr_invalid_mode;

	*pwidth = width;
	*pheight = height;

	// let the sound and input subsystems know about the new window
	ri.Vid_NewWindow (width, height);

	qfxMesaMakeCurrent(fc);

	return rserr_ok;
}

/*
** GLimp_Shutdown
**
** This routine does all OS specific shutdown procedures for the OpenGL
** subsystem.  Under OpenGL this means NULLing out the current DC and
** HGLRC, deleting the rendering context, and releasing the DC acquired
** for the window.  The state structure is also nulled out.
**
*/
void GLimp_Shutdown( void )
{
	if (fc) {
		qfxMesaDestroyContext(fc);
		fc = NULL;
	}
}

/*
** GLimp_Init
**
** This routine is responsible for initializing the OS specific portions
** of OpenGL.  
*/
int GLimp_Init( void *hinstance, void *wndproc )
{
	InitSig();

	return true;
}

/*
** GLimp_BeginFrame
*/
void GLimp_BeginFrame( float camera_seperation )
{
}

/*
** GLimp_EndFrame
** 
** Responsible for doing a swapbuffers and possibly for other stuff
** as yet to be determined.  Probably better not to make this a GLimp
** function and instead do a call to GLimp_SwapBuffers.
*/
void GLimp_EndFrame (void)
{
	qglFlush();
	qfxMesaSwapBuffers();
}

/*
** GLimp_AppActivate
*/
void GLimp_AppActivate( qboolean active )
{
}

void Fake_glColorTableEXT( GLenum target, GLenum internalformat,
                             GLsizei width, GLenum format, GLenum type,
                             const GLvoid *table )
{
	byte temptable[256][4];
	byte *intbl;
	int i;

	for (intbl = (byte *)table, i = 0; i < 256; i++) {
		temptable[i][2] = *intbl++;
		temptable[i][1] = *intbl++;
		temptable[i][0] = *intbl++;
		temptable[i][3] = 255;
	}
	qglEnable( GL_SHARED_TEXTURE_PALETTE_EXT );
	qgl3DfxSetPaletteEXT((GLuint *)temptable);
}

