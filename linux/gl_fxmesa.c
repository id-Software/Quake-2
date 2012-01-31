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

#include <GL/fxmesa.h>

/*****************************************************************************/

static qboolean GLimp_SwitchFullscreen( int width, int height );
qboolean GLimp_InitGL (void);

extern cvar_t *vid_fullscreen;
extern cvar_t *vid_ref;

static fxMesaContext fc = NULL;

#define NUM_RESOLUTIONS 3

static resolutions[NUM_RESOLUTIONS][3]={ 
  { 512, 384, GR_RESOLUTION_512x384 },
  { 640, 400, GR_RESOLUTION_640x400 },
  { 640, 480, GR_RESOLUTION_640x480 }
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

	fc = fxMesaCreateContext(0, findres(&width, &height), GR_REFRESH_75Hz, 
		attribs);
	if (!fc)
		return rserr_invalid_mode;

	*pwidth = width;
	*pheight = height;

	// let the sound and input subsystems know about the new window
	ri.Vid_NewWindow (width, height);

	fxMesaMakeCurrent(fc);

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
		fxMesaDestroyContext(fc);
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
	glFlush();
	fxMesaSwapBuffers();
}

/*
** GLimp_AppActivate
*/
void GLimp_AppActivate( qboolean active )
{
}

extern void gl3DfxSetPaletteEXT(GLuint *pal);

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
	gl3DfxSetPaletteEXT((GLuint *)temptable);
}


