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
** RW_SVGALBI.C
**
** This file contains ALL Linux specific stuff having to do with the
** software refresh.  When a port is being made the following functions
** must be implemented by the port:
**
** SWimp_EndFrame
** SWimp_Init
** SWimp_InitGraphics
** SWimp_SetPalette
** SWimp_Shutdown
** SWimp_SwitchFullscreen
*/

#include <termios.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/vt.h>
#include <stdarg.h>
#include <stdio.h>
#include <signal.h>
#include <sys/mman.h>

#include <asm/io.h>

#include "vga.h"
#include "vgakeyboard.h"
#include "vgamouse.h"

#include "../ref_soft/r_local.h"
#include "../client/keys.h"
#include "../linux/rw_linux.h"

/*****************************************************************************/

int		VGA_width, VGA_height, VGA_rowbytes, VGA_bufferrowbytes, VGA_planar;
byte	*VGA_pagebase;
char	*framebuffer_ptr;

void VGA_UpdatePlanarScreen (void *srcbuffer);

int num_modes;
vga_modeinfo *modes;
int current_mode;

// Console variables that we need to access from this module

/*****************************************************************************/

void VID_InitModes(void)
{

int i;

	// get complete information on all modes

	num_modes = vga_lastmodenumber()+1;
	modes = malloc(num_modes * sizeof(vga_modeinfo));
	for (i=0 ; i<num_modes ; i++)
	{
		if (vga_hasmode(i))
			memcpy(&modes[i], vga_getmodeinfo(i), sizeof (vga_modeinfo));
		else
			modes[i].width = 0; // means not available
	}

	// filter for modes i don't support

	for (i=0 ; i<num_modes ; i++)
	{
		if (modes[i].bytesperpixel != 1 && modes[i].colors != 256) 
			modes[i].width = 0;
	}

	for (i = 0; i < num_modes; i++)
		if (modes[i].width)
			ri.Con_Printf(PRINT_ALL, "mode %d: %d %d\n", modes[i].width, modes[i].height);

}

/*
** SWimp_Init
**
** This routine is responsible for initializing the implementation
** specific stuff in a software rendering subsystem.
*/
int SWimp_Init( void *hInstance, void *wndProc )
{
	vga_init();

	VID_InitModes();

	return true;
}

int get_mode(int width, int height)
{

	int i;
	int ok, match;

	for (i=0 ; i<num_modes ; i++)
		if (modes[i].width &&
			modes[i].width == width && modes[i].height == height)
				break;
	if (i==num_modes)
		return -1; // not found

	return i;
}

/*
** SWimp_InitGraphics
**
** This initializes the software refresh's implementation specific
** graphics subsystem.  In the case of Windows it creates DIB or
** DDRAW surfaces.
**
** The necessary width and height parameters are grabbed from
** vid.width and vid.height.
*/
static qboolean SWimp_InitGraphics( qboolean fullscreen )
{
	int bsize, zsize, tsize;

	SWimp_Shutdown();

	current_mode = get_mode(vid.width, vid.height);

	if (current_mode < 0) {
		ri.Con_Printf (PRINT_ALL, "Mode %d %d not found\n", vid.width, vid.height);
		return false; // mode not found
	}

	// let the sound and input subsystems know about the new window
	ri.Vid_NewWindow (vid.width, vid.height);

	ri.Con_Printf (PRINT_ALL, "Setting VGAMode: %d\n", current_mode );

//	Cvar_SetValue ("vid_mode", (float)modenum);
	
	VGA_width = modes[current_mode].width;
	VGA_height = modes[current_mode].height;
	VGA_planar = modes[current_mode].bytesperpixel == 0;
	VGA_rowbytes = modes[current_mode].linewidth;

	vid.rowbytes = modes[current_mode].linewidth;

	if (VGA_planar) {
		VGA_bufferrowbytes = modes[current_mode].linewidth * 4;
		vid.rowbytes = modes[current_mode].linewidth*4;
	}

// get goin'

	vga_setmode(current_mode);

	VGA_pagebase = framebuffer_ptr = (char *) vga_getgraphmem();
//		if (vga_setlinearaddressing()>0)
//			framebuffer_ptr = (char *) vga_getgraphmem();
	if (!framebuffer_ptr)
		Sys_Error("This mode isn't hapnin'\n");

	vga_setpage(0);

	vid.buffer = malloc(vid.rowbytes * vid.height);
	if (!vid.buffer)
		Sys_Error("Unabled to alloc vid.buffer!\n");

	return true;
}

/*
** SWimp_EndFrame
**
** This does an implementation specific copy from the backbuffer to the
** front buffer.  In the Win32 case it uses BitBlt or BltFast depending
** on whether we're using DIB sections/GDI or DDRAW.
*/
void SWimp_EndFrame (void)
{
	if (!vga_oktowrite())
		return; // can't update screen if it's not active

//	if (vid_waitforrefresh.value)
//		vga_waitretrace();

	if (VGA_planar)
		VGA_UpdatePlanarScreen (vid.buffer);

	else {
		int total = vid.rowbytes * vid.height;
		int offset;

		for (offset=0;offset<total;offset+=0x10000) {
			vga_setpage(offset/0x10000);
			memcpy(framebuffer_ptr,
					vid.buffer + offset,
					((total-offset>0x10000)?0x10000:(total-offset)));
		}
	} 
}

/*
** SWimp_SetMode
*/
rserr_t SWimp_SetMode( int *pwidth, int *pheight, int mode, qboolean fullscreen )
{
	rserr_t retval = rserr_ok;

	ri.Con_Printf (PRINT_ALL, "setting mode %d:", mode );

	if ( !ri.Vid_GetModeInfo( pwidth, pheight, mode ) )
	{
		ri.Con_Printf( PRINT_ALL, " invalid mode\n" );
		return rserr_invalid_mode;
	}

	ri.Con_Printf( PRINT_ALL, " %d %d\n", *pwidth, *pheight);

	if ( !SWimp_InitGraphics( false ) ) {
		// failed to set a valid mode in windowed mode
		return rserr_invalid_mode;
	}

	R_GammaCorrectAndSetPalette( ( const unsigned char * ) d_8to24table );

	return retval;
}

/*
** SWimp_SetPalette
**
** System specific palette setting routine.  A NULL palette means
** to use the existing palette.  The palette is expected to be in
** a padded 4-byte xRGB format.
*/
void SWimp_SetPalette( const unsigned char *palette )
{
	static int tmppal[256*3];
	const unsigned char *pal;
	int *tp;
	int i;

    if ( !palette )
        palette = ( const unsigned char * ) sw_state.currentpalette;
 
	if (vga_getcolors() == 256)
	{
		tp = tmppal;
		pal = palette;

		for (i=0 ; i < 256 ; i++, pal += 4, tp += 3) {
			tp[0] = pal[0] >> 2;
			tp[1] = pal[1] >> 2;
			tp[2] = pal[2] >> 2;
		}

		if (vga_oktowrite())
			vga_setpalvec(0, 256, tmppal);
	}
}

/*
** SWimp_Shutdown
**
** System specific graphics subsystem shutdown routine.  Destroys
** DIBs or DDRAW surfaces as appropriate.
*/
void SWimp_Shutdown( void )
{
	if (vid.buffer) {
		free(vid.buffer);
		vid.buffer = NULL;
	}
	vga_setmode(TEXT);
}

/*
** SWimp_AppActivate
*/
void SWimp_AppActivate( qboolean active )
{
}

//===============================================================================

/*
================
Sys_MakeCodeWriteable
================
*/
void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{

	int r;
	unsigned long addr;
	int psize = getpagesize();

	addr = (startaddr & ~(psize-1)) - psize;

//	fprintf(stderr, "writable code %lx(%lx)-%lx, length=%lx\n", startaddr,
//			addr, startaddr+length, length);

	r = mprotect((char*)addr, length + startaddr - addr + psize, 7);

	if (r < 0)
    		Sys_Error("Protection change failed\n");
}

