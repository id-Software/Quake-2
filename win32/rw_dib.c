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
** RW_DIB.C
**
** This handles DIB section management under Windows.
**
*/
#include "..\ref_soft\r_local.h"
#include "rw_win.h"

#ifndef _WIN32
#  error You should not be trying to compile this file on this platform
#endif

static qboolean s_systemcolors_saved;

static HGDIOBJ previously_selected_GDI_obj;

static int s_syspalindices[] = 
{
  COLOR_ACTIVEBORDER,
  COLOR_ACTIVECAPTION,
  COLOR_APPWORKSPACE,
  COLOR_BACKGROUND,
  COLOR_BTNFACE,
  COLOR_BTNSHADOW,
  COLOR_BTNTEXT,
  COLOR_CAPTIONTEXT,
  COLOR_GRAYTEXT,
  COLOR_HIGHLIGHT,
  COLOR_HIGHLIGHTTEXT,
  COLOR_INACTIVEBORDER,

  COLOR_INACTIVECAPTION,
  COLOR_MENU,
  COLOR_MENUTEXT,
  COLOR_SCROLLBAR,
  COLOR_WINDOW,
  COLOR_WINDOWFRAME,
  COLOR_WINDOWTEXT
};

#define NUM_SYS_COLORS ( sizeof( s_syspalindices ) / sizeof( int ) )

static int s_oldsyscolors[NUM_SYS_COLORS];

typedef struct dibinfo
{
	BITMAPINFOHEADER	header;
	RGBQUAD				acolors[256];
} dibinfo_t;

typedef struct
{
	WORD palVersion;
	WORD palNumEntries;
	PALETTEENTRY palEntries[256];
} identitypalette_t;

static identitypalette_t s_ipal;

static void DIB_SaveSystemColors( void );
static void DIB_RestoreSystemColors( void );

/*
** DIB_Init
**
** Builds our DIB section
*/
qboolean DIB_Init( unsigned char **ppbuffer, int *ppitch )
{
	dibinfo_t   dibheader;
	BITMAPINFO *pbmiDIB = ( BITMAPINFO * ) &dibheader;
	int i;

	memset( &dibheader, 0, sizeof( dibheader ) );

	/*
	** grab a DC
	*/
	if ( !sww_state.hDC )
	{
		if ( ( sww_state.hDC = GetDC( sww_state.hWnd ) ) == NULL )
			return false;
	}

	/*
	** figure out if we're running in an 8-bit display mode
	*/
 	if ( GetDeviceCaps( sww_state.hDC, RASTERCAPS ) & RC_PALETTE )
	{
		sww_state.palettized = true;

		// save system colors
		if ( !s_systemcolors_saved )
		{
			DIB_SaveSystemColors();
			s_systemcolors_saved = true;
		}
	}
	else
	{
		sww_state.palettized = false;
	}

	/*
	** fill in the BITMAPINFO struct
	*/
	pbmiDIB->bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
	pbmiDIB->bmiHeader.biWidth         = vid.width;
	pbmiDIB->bmiHeader.biHeight        = vid.height;
	pbmiDIB->bmiHeader.biPlanes        = 1;
	pbmiDIB->bmiHeader.biBitCount      = 8;
	pbmiDIB->bmiHeader.biCompression   = BI_RGB;
	pbmiDIB->bmiHeader.biSizeImage     = 0;
	pbmiDIB->bmiHeader.biXPelsPerMeter = 0;
	pbmiDIB->bmiHeader.biYPelsPerMeter = 0;
	pbmiDIB->bmiHeader.biClrUsed       = 256;
	pbmiDIB->bmiHeader.biClrImportant  = 256;

	/*
	** fill in the palette
	*/
	for ( i = 0; i < 256; i++ )
	{
		dibheader.acolors[i].rgbRed   = ( d_8to24table[i] >> 0 )  & 0xff;
		dibheader.acolors[i].rgbGreen = ( d_8to24table[i] >> 8 )  & 0xff;
		dibheader.acolors[i].rgbBlue  = ( d_8to24table[i] >> 16 ) & 0xff;
	}

	/*
	** create the DIB section
	*/
	sww_state.hDIBSection = CreateDIBSection( sww_state.hDC,
		                                     pbmiDIB,
											 DIB_RGB_COLORS,
											 &sww_state.pDIBBase,
											 NULL,
											 0 );

	if ( sww_state.hDIBSection == NULL )
	{
		ri.Con_Printf( PRINT_ALL, "DIB_Init() - CreateDIBSection failed\n" );
		goto fail;
	}

	if ( pbmiDIB->bmiHeader.biHeight > 0 )
    {
		// bottom up
		*ppbuffer	= sww_state.pDIBBase + ( vid.height - 1 ) * vid.width;
		*ppitch		= -vid.width;
    }
    else
    {
		// top down
		*ppbuffer	= sww_state.pDIBBase;
		*ppitch		= vid.width;
    }

	/*
	** clear the DIB memory buffer
	*/
	memset( sww_state.pDIBBase, 0xff, vid.width * vid.height );

	if ( ( sww_state.hdcDIBSection = CreateCompatibleDC( sww_state.hDC ) ) == NULL )
	{
		ri.Con_Printf( PRINT_ALL, "DIB_Init() - CreateCompatibleDC failed\n" );
		goto fail;
	}
	if ( ( previously_selected_GDI_obj = SelectObject( sww_state.hdcDIBSection, sww_state.hDIBSection ) ) == NULL )
	{
		ri.Con_Printf( PRINT_ALL, "DIB_Init() - SelectObject failed\n" );
		goto fail;
	}

	return true;

fail:
	DIB_Shutdown();
	return false;
	
}

/*
** DIB_SetPalette
**
** Sets the color table in our DIB section, and also sets the system palette
** into an identity mode if we're running in an 8-bit palettized display mode.
**
** The palette is expected to be 1024 bytes, in the format:
**
** R = offset 0
** G = offset 1
** B = offset 2
** A = offset 3
*/
void DIB_SetPalette( const unsigned char *_pal )
{
	const unsigned char *pal = _pal;
  	LOGPALETTE		*pLogPal = ( LOGPALETTE * ) &s_ipal;
	RGBQUAD			colors[256];
	int				i;
	int				ret;
	HDC				hDC = sww_state.hDC;

	/*
	** set the DIB color table
	*/
	if ( sww_state.hdcDIBSection )
	{
		for ( i = 0; i < 256; i++, pal += 4 )
		{
			colors[i].rgbRed   = pal[0];
			colors[i].rgbGreen = pal[1];
			colors[i].rgbBlue  = pal[2];
			colors[i].rgbReserved = 0;
		}

		colors[0].rgbRed = 0;
		colors[0].rgbGreen = 0;
		colors[0].rgbBlue = 0;

		colors[255].rgbRed = 0xff;
		colors[255].rgbGreen = 0xff;
		colors[255].rgbBlue = 0xff;

		if ( SetDIBColorTable( sww_state.hdcDIBSection, 0, 256, colors ) == 0 )
		{
			ri.Con_Printf( PRINT_ALL, "DIB_SetPalette() - SetDIBColorTable failed\n" );
		}
	}

	/*
	** for 8-bit color desktop modes we set up the palette for maximum
	** speed by going into an identity palette mode.
	*/
	if ( sww_state.palettized )
	{
		int i;
		HPALETTE hpalOld;

		if ( SetSystemPaletteUse( hDC, SYSPAL_NOSTATIC ) == SYSPAL_ERROR )
		{
			ri.Sys_Error( ERR_FATAL, "DIB_SetPalette() - SetSystemPaletteUse() failed\n" );
		}

		/*
		** destroy our old palette
		*/
		if ( sww_state.hPal )
		{
			DeleteObject( sww_state.hPal );
			sww_state.hPal = 0;
		}

		/*
		** take up all physical palette entries to flush out anything that's currently
		** in the palette
		*/
		pLogPal->palVersion		= 0x300;
		pLogPal->palNumEntries	= 256;

		for ( i = 0, pal = _pal; i < 256; i++, pal += 4 )
		{
			pLogPal->palPalEntry[i].peRed	= pal[0];
			pLogPal->palPalEntry[i].peGreen	= pal[1];
			pLogPal->palPalEntry[i].peBlue	= pal[2];
			pLogPal->palPalEntry[i].peFlags	= PC_RESERVED | PC_NOCOLLAPSE;
		}
		pLogPal->palPalEntry[0].peRed		= 0;
		pLogPal->palPalEntry[0].peGreen		= 0;
		pLogPal->palPalEntry[0].peBlue		= 0;
		pLogPal->palPalEntry[0].peFlags		= 0;
		pLogPal->palPalEntry[255].peRed		= 0xff;
		pLogPal->palPalEntry[255].peGreen	= 0xff;
		pLogPal->palPalEntry[255].peBlue	= 0xff;
		pLogPal->palPalEntry[255].peFlags	= 0;

		if ( ( sww_state.hPal = CreatePalette( pLogPal ) ) == NULL )
		{
			ri.Sys_Error( ERR_FATAL, "DIB_SetPalette() - CreatePalette failed(%x)\n", GetLastError() );
		}

		if ( ( hpalOld = SelectPalette( hDC, sww_state.hPal, FALSE ) ) == NULL )
		{
			ri.Sys_Error( ERR_FATAL, "DIB_SetPalette() - SelectPalette failed(%x)\n",GetLastError() );
		}

		if ( sww_state.hpalOld == NULL )
			sww_state.hpalOld = hpalOld;

		if ( ( ret = RealizePalette( hDC ) ) != pLogPal->palNumEntries ) 
		{
			ri.Sys_Error( ERR_FATAL, "DIB_SetPalette() - RealizePalette set %d entries\n", ret );
		}
	}
}

/*
** DIB_Shutdown
*/
void DIB_Shutdown( void )
{
	if ( sww_state.palettized && s_systemcolors_saved )
		DIB_RestoreSystemColors();

	if ( sww_state.hPal )
	{
		DeleteObject( sww_state.hPal );
		sww_state.hPal = 0;
	}

	if ( sww_state.hpalOld )
	{
		SelectPalette( sww_state.hDC, sww_state.hpalOld, FALSE );
		RealizePalette( sww_state.hDC );
		sww_state.hpalOld = NULL;
	}

	if ( sww_state.hdcDIBSection )
	{
		SelectObject( sww_state.hdcDIBSection, previously_selected_GDI_obj );
		DeleteDC( sww_state.hdcDIBSection );
		sww_state.hdcDIBSection = NULL;
	}

	if ( sww_state.hDIBSection )
	{
		DeleteObject( sww_state.hDIBSection );
		sww_state.hDIBSection = NULL;
		sww_state.pDIBBase = NULL;
	}

	if ( sww_state.hDC )
	{
		ReleaseDC( sww_state.hWnd, sww_state.hDC );
		sww_state.hDC = 0;
	}
}


/*
** DIB_Save/RestoreSystemColors
*/
static void DIB_RestoreSystemColors( void )
{
    SetSystemPaletteUse( sww_state.hDC, SYSPAL_STATIC );
    SetSysColors( NUM_SYS_COLORS, s_syspalindices, s_oldsyscolors );
}

static void DIB_SaveSystemColors( void )
{
	int i;

	for ( i = 0; i < NUM_SYS_COLORS; i++ )
		s_oldsyscolors[i] = GetSysColor( s_syspalindices[i] );
}
