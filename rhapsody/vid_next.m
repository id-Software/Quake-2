// vid_next.m -- NEXTSTEP video driver

#define	INTERCEPTOR

#import <appkit/appkit.h>
#import <string.h>
#import "intercep.h"
#include "quakedef.h"
#include "d_local.h"

int	BASEWIDTH = 320;
int BASEHEIGHT = 200;

void SetupBitmap (void);
void SetupFramebuffer (void);
void UpdateBitmap (void);
void UpdateFramebuffer (vrect_t *vrect);
void SetVideoEncoding (char *encoding);
void Update8_1 (pixel_t *src, byte *dest, int width,
		int height, int destrowbytes);
void Update16_1 (pixel_t *src, unsigned short *dest, int width,
		int height, int destrowbytes);
void Update32_1 (pixel_t *src, unsigned *dest, int width,
		int height, int destrowbytes);


@interface QuakeView : View
@end

@interface FrameWindow:Window
@end

unsigned short	d_8to16table[256];	// not used in 8 bpp mode
unsigned	d_8to24table[256];	// not used in 8 bpp mode


/*
==========================================================================

						API FUNCTIONS

==========================================================================
*/

typedef enum {disp_bitmap, disp_framebuffer}	display_t;

pixel_t		*vid_buffer;
pixel_t		*buffernative;
unsigned	pcolormap[4][256];	// map from quake pixels to native pixels
unsigned	pixbytesnative;
unsigned	rowbytesnative;
int			dither;

int			drawdirect = 0;

int			d_con_indirect = 0;

display_t		vid_display;

byte			vid_palette[768];	// saved for restarting vid system

id				vid_window_i;
id				vid_view_i;
#ifdef INTERCEPTOR
NXDirectBitmap	*vid_dbitmap_i;
NXFramebuffer	*vid_framebuffer_i;
#endif

NXRect   		screenBounds;		// only valid in framebuffer mode

int				vid_scale;

char			*vid_encodingstring;

int				vid_fullscreen;
int				vid_screen;

int				vid_high_hunk_mark;

typedef enum
{
	enc_24_rgba,
	enc_24_0rgb,
	enc_24_rgb0,
	enc_12_rgba,
	enc_12_rgb0,
	enc_15_0rgb,
	enc_564,
	enc_8_gray,
	enc_8_rgb
} vid_encoding_t;

typedef struct
{
	char			*string;
	int				pixelbytes;
	void			(*colormap) (void);
	vid_encoding_t	name;
} vidtype_t;

vid_encoding_t	vid_encoding;
 
void	Table8 (void);
void	Table15 (void);
void	Table12 (void);
void	Table12Swap (void);
void	Table24 (void);
void	Table24Swap (void);

vidtype_t vid_encodingtable[]=
{
{"RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA",4, Table24Swap, enc_24_rgba},
{"--------RRRRRRRRGGGGGGGGBBBBBBBB",4, Table24, enc_24_0rgb},
{"RRRRRRRRGGGGGGGGBBBBBBBB--------",4, Table24Swap, enc_24_rgb0},
{"RRRRGGGGBBBBAAAA",2, Table12Swap, enc_12_rgba},
{"RRRRGGGGBBBB----",2, Table12, enc_12_rgb0},
{"-RRRRRGGGGGBBBBB",2, Table15, enc_15_0rgb},
{"WWWWWWWW",1, Table8, enc_8_gray},
{"PPPPPPPP",1, Table8, enc_8_rgb},
{NULL,0, 0, 0}
};

vidtype_t	*vid_type;
void	InitNS8Bit (void);

/*
================
D_BeginDirectRect
================
*/
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
// direct drawing of the "accessing disk" icon isn't supported under Nextstep
}


/*
================
D_EndDirectRect
================
*/
void D_EndDirectRect (int x, int y, int width, int height)
{
// direct drawing of the "accessing disk" icon isn't supported under Nextstep
}


/*
==============
VID_Restart

internal call only
===============
*/
void VID_Restart (display_t mode, int scale)
{
	vid_display = mode;
	vid_scale = scale;

	[NXApp activateSelf:YES];

	if (vid_display == disp_framebuffer)
		SetupFramebuffer ();
	else
		SetupBitmap ();

	vid.recalc_refdef = 1;
}


/*
=================
VID_Scale_f

Keybinding command
=================
*/
void VID_Scale_f (void)
{
	int		scale;
	
	if (Cmd_Argc () != 2)
		return;
		
	scale = atoi (Cmd_Argv(1));
	if (scale != 1 && scale != 2)
	{
		Con_Printf ("scale must be 1 or 2\n");
		return;
	}
	VID_Shutdown ();
	VID_Restart (vid_display, scale);
}

/*
=================
VID_Mode_f

Keybinding command
=================
*/
void VID_Mode_f (void)
{
	int		mode;

	if (Cmd_Argc () != 2)
		return;

	mode = atoi (Cmd_Argv(1));

	VID_Shutdown ();
	if (mode == 0)
	{
		drawdirect = 0;
		VID_Restart (disp_bitmap, vid_scale);
	}
	else if (mode == 1)
	{
		drawdirect = 0;
		VID_Restart (disp_framebuffer, vid_scale);
	}
	else
	{
		drawdirect = 1;
		VID_Restart (disp_framebuffer, vid_scale);
	}
}

/*
=================
VID_Size_f

Keybinding command
=================
*/
void VID_Size_f (void)
{	
	if (Cmd_Argc () != 3)
		return;

	VID_Shutdown ();

	BASEWIDTH = atoi (Cmd_Argv(1));
	BASEHEIGHT = atoi (Cmd_Argv(2));

	VID_Restart (vid_display, vid_scale);
}

/*
================
VID_Init
================
*/
void	VID_Init (unsigned char *palette)
{
	InitNS8Bit ();			// fixed palette lookups
	
	Q_memcpy (vid_palette, palette, sizeof(vid_palette));

	if (COM_CheckParm ("-bitmap"))
		vid_display = disp_bitmap;
	else
		vid_display = disp_framebuffer;

	if (COM_CheckParm ("-screen2"))
		vid_screen = 1;
	else
		vid_screen = 0;

	if (COM_CheckParm ("-direct"))
		drawdirect = 1;
	
	Cmd_AddCommand ("vid_scale", VID_Scale_f);
	Cmd_AddCommand ("vid_mode", VID_Mode_f);
	Cmd_AddCommand ("vid_size", VID_Size_f);

	vid.width = BASEWIDTH;
	vid.height = BASEHEIGHT;
	vid.aspect = 1.0;
	vid.numpages = 1;
	vid.colormap = host_colormap;
	vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
	vid.maxwarpwidth = WARP_WIDTH;
	vid.maxwarpheight = WARP_HEIGHT;

	if (COM_CheckParm ("-scale2"))
		vid_scale = 2;
	else
		vid_scale = 1;
		
    [Application new];

	VID_Restart (vid_display, vid_scale);
}


/*
================
VID_Shutdown
================
*/
void VID_Shutdown (void)
{
#ifdef INTERCEPTOR
	if (vid_dbitmap_i)
	{
		[vid_dbitmap_i free];
		vid_dbitmap_i = 0;
	}
	if (vid_framebuffer_i)
	{
		[vid_framebuffer_i free];
		vid_framebuffer_i = 0;
	}
#endif
	[vid_window_i close];
	[vid_window_i free];
}


/*
================
VID_Update
================
*/
void	VID_Update (vrect_t *rects)
{
	if (drawdirect)
		return;

	while (rects)
	{
		UpdateFramebuffer (rects);
		rects = rects->pnext;
	}

	if (vid_display == disp_bitmap)
		UpdateBitmap ();
}


/*
================
VID_SetPalette
================
*/
void	VID_SetPalette (unsigned char *palette)
{
	Q_memcpy (vid_palette, palette, sizeof(vid_palette));
	vid_type->colormap ();
}


/*
================
VID_ShiftPalette
================
*/
void    VID_ShiftPalette (unsigned char *palette)
{

	VID_SetPalette (palette);
}


/*
==========================================================================

						NS STUFF

==========================================================================
*/


/*
=================
SetVideoEncoding
=================
*/
void SetVideoEncoding (char *encoding)
{
	vidtype_t			*type;

	Sys_Printf ("SetVideoEncoding: %s\n",encoding);
	vid_encodingstring = encoding;
	
	for (type = vid_encodingtable ; type->string ; type++)
	{
		if (strcmp(type->string, encoding) == 0)
		{
			pixbytesnative = type->pixelbytes;
			vid_encoding = type->name;
			type->colormap ();
			vid_type = type;
			return;
		}
	}
	
	Sys_Error ("Unsupported video encoding: %s\n",encoding);
}

/*
=================
AllocBuffers
=================
*/
void AllocBuffers (qboolean withnative)
{
	int		surfcachesize;
	void	*surfcache;
	int		pixels;
	int		pixbytes;
	int		vid_buffersize;

	if (vid_buffer)
	{
		D_FlushCaches ();
		Hunk_FreeToHighMark (vid_high_hunk_mark);
		vid_high_hunk_mark = 0;
		vid_buffer = NULL;
	}

	pixels = vid.width * vid.height;

	pixbytes = 1 +sizeof (*d_pzbuffer);
	if (withnative)
		pixbytes += pixbytesnative;
		
	surfcachesize = D_SurfaceCacheForRes (vid.width, vid.height);
	vid_buffersize = pixels * pixbytes + surfcachesize;

	vid_high_hunk_mark = Hunk_HighMark ();
	vid_buffer = Hunk_HighAllocName (vid_buffersize, "video");
	if (!vid_buffer)
		Sys_Error ("Couldn't alloc video buffers");

	vid.buffer = vid_buffer;

	d_pzbuffer = (unsigned short *)((byte *)vid_buffer + pixels);
	surfcache = (byte *)d_pzbuffer + pixels * sizeof (*d_pzbuffer);
	if (withnative)
		buffernative = (byte *)surfcache + surfcachesize;

	D_InitCaches (surfcache, surfcachesize);
}

/*
=================
SetupFramebuffer
=================
*/
void SetupFramebuffer (void)
{
#ifdef INTERCEPTOR
    int			windowNum;
	NXRect		cont;
	NXScreen	const *screens;
	int			screencount;

//
// get the screen list
//
	[NXApp getScreens:&screens count:&screencount];

//
// create vid_framebuffer_i
//
    vid_framebuffer_i = [[NXFramebuffer alloc]
		   initFromScreen:screens[vid_screen].screenNumber andMapIfPossible:YES];
    [vid_framebuffer_i screenBounds:&screenBounds];

	SetVideoEncoding ([vid_framebuffer_i pixelEncoding]);

	buffernative = [vid_framebuffer_i data];
	rowbytesnative = [vid_framebuffer_i bytesPerRow];

//
// create window
//
	if (vid_fullscreen)
	{
		vid.height = screenBounds.size.height / vid_scale;
		vid.width = screenBounds.size.width / vid_scale;
		cont.origin.x = 0;
		cont.origin.y = 0;
		cont.size.width = screenBounds.size.width;
		cont.size.height = screenBounds.size.height;
	}
	else
	{
		buffernative = (unsigned char *)buffernative + 8 * rowbytesnative +
				8 * pixbytesnative;
		vid.width = BASEWIDTH;
		vid.height = BASEHEIGHT;
		cont.origin.x = 8;
		cont.origin.y = screenBounds.size.height - (vid.height*vid_scale) - 8;
		cont.size.width = vid.width * vid_scale;
		cont.size.height = vid.height * vid_scale;
	}

    vid_window_i = [[FrameWindow alloc]
		 initContent:		&cont
		 style:				NX_PLAINSTYLE
		 backing:			NX_NONRETAINED
		 buttonMask:		0
		 defer:				NO
		 screen:			screens+vid_screen];
    windowNum = [vid_window_i windowNum];
    PSsetwindowlevel(40, windowNum);
    PSsetautofill(YES, windowNum);
    PSgsave();
    PSwindowdeviceround(windowNum);
    PSsetgray(NX_BLACK);
    PSsetexposurecolor();
    PSgrestore();

//
// create view
//
	vid_view_i = [[QuakeView alloc] initFrame: &screenBounds];
	[[vid_window_i setContentView: vid_view_i] free];
	[vid_window_i makeFirstResponder: vid_view_i];
	[vid_window_i setDelegate: vid_view_i];	
	[vid_window_i display];
	[vid_window_i makeKeyAndOrderFront: nil];
	NXPing ();

	AllocBuffers (false);	// no native buffer

	if (drawdirect)
	{	// the direct drawing mode to NeXT colorspace
		vid.buffer = buffernative;
		vid.rowbytes = rowbytesnative;
	}
	else
		vid.rowbytes = vid.width;

	vid.conbuffer = vid.buffer;
	vid.conrowbytes = vid.rowbytes;
	vid.conwidth = vid.width;
	vid.conheight = vid.height;
#endif
}

/*
=================
SetupBitmap
=================
*/
void SetupBitmap (void)
{
	int		depth;
	NXRect	content;

//
// open a window
//
	NXSetRect (&content, 8,136, vid.width*vid_scale, vid.height*vid_scale);
	vid_window_i = [[Window alloc]
			initContent:	&content
			style:			NX_RESIZEBARSTYLE
			backing:		NX_RETAINED
			buttonMask:		0
			defer:			NO
		];
	[vid_window_i display];
	[vid_window_i makeKeyAndOrderFront: nil];

	NXPing ();

	content.origin.x = content.origin.y = 0;
	vid_view_i = [[QuakeView alloc] initFrame: &content];
	[[vid_window_i setContentView: vid_view_i] free];
	[vid_window_i makeFirstResponder: vid_view_i];
	[vid_window_i setDelegate: vid_view_i];

	[vid_window_i addToEventMask: NX_FLAGSCHANGEDMASK];

//
// find video info
//
    depth = [Window defaultDepthLimit];
    switch (depth) {
	case NX_EightBitGrayDepth:
		SetVideoEncoding ("WWWWWWWW");
	    break;
	case NX_TwelveBitRGBDepth:
		SetVideoEncoding ("RRRRGGGGBBBBAAAA");
	    break;
	default:
	case NX_TwentyFourBitRGBDepth:
		SetVideoEncoding ("RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA");
	    break;
//	default:	// 8 bit color shows up as an unknown...
		Sys_Error ("Unsupported window depth");
    }

	[vid_window_i setTitle: "Bitmap Quake Console"];

//
// allocate memory for the back and translation buffers
//
	vid.rowbytes = vid.width;
	rowbytesnative = vid.width * pixbytesnative;
	
	AllocBuffers (true);
	
	vid.conbuffer = vid.buffer;
	vid.conrowbytes = vid.rowbytes;
	vid.conwidth = vid.width;
	vid.conheight = vid.height;
}


/*
=================
UpdateFramebuffer
=================
*/
void UpdateFramebuffer (vrect_t *vrect)
{
	byte		*psourcebase;
	byte		*pdestbase;
	int			scale;
	
	psourcebase = vid.buffer + vrect->x + vrect->y * vid.rowbytes;

	if (vid_display == disp_bitmap)
		scale = 1;		// let NS do the scaling
	else
		scale = vid_scale;
		
	pdestbase = buffernative + scale *
			(vrect->x * pixbytesnative + vrect->y * rowbytesnative);

//
// translate from ideal to native (except 8 bpp direct) and copy to screen
//

	if (pixbytesnative == 1)
		Update8_1 (psourcebase, pdestbase, vrect->width, vrect->height,
				rowbytesnative);
	else if (pixbytesnative == 2)
		Update16_1 (psourcebase, (unsigned short *)pdestbase, vrect->width, vrect->height,
				rowbytesnative);
	else
		Update32_1 (psourcebase, (unsigned *)pdestbase, vrect->width, vrect->height,
				rowbytesnative);
}


/*
=================
UpdateBitmap
=================
*/
void UpdateBitmap (void)
{
	unsigned char	*planes[5];
	NXRect			bounds;
	int				bpp, spp, bps, bpr, colorspace;

//
// flush the screen with an image call
// 
	if (pixbytesnative == 1)
	{
		bps = 8;
		spp = 1;
		bpp = 8;
		bpr = vid.width;
		colorspace = NX_OneIsWhiteColorSpace;
		planes[0] = vid.buffer;
	}
	else if (pixbytesnative == 2)
	{
		bps = 4;
		spp = 3;
		bpp = 16;
		bpr = vid.width * 2;
		colorspace = NX_RGBColorSpace;
		planes[0] = buffernative;
	}
	else
	{
		bps = 8;
		spp = 3;
		bpp = 32;
		bpr = vid.width * 4;
		colorspace = NX_RGBColorSpace;
		planes[0] = buffernative;
	}

	[vid_view_i getBounds: &bounds];
	[vid_view_i lockFocus];

	NXDrawBitmap(
		&bounds,  
		vid.width, 
		vid.height,
		bps,
		spp,
		bpp,
		bpr,
		NO,
		NO,
		colorspace,
		planes
	);
	
	[vid_view_i unlockFocus];
    NXPing ();	
}



/*
==========================================================================

					TRANSLATION TABLE BUILDING

==========================================================================
*/

int	redramp[] = {0, 19, 59, 113, 178, 255, 300};
int greenramp[] = {0, 11, 34,  66, 104, 149, 199, 255, 300};
int blueramp[] = {0, 28, 84, 161, 255, 300};
int greyramp[] = { 0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204,
				   221, 238, 255, 300};

byte	greytable[256];
byte	redtable[256];
byte	greentable[256];
byte	bluetable[256];

void FillTable (byte *table, int *ramp, int base)
{
	int		i, j, o;
	
	o = 0;
	for (i=0 ; i<16 && o < 256; i++)
	{
		j = ramp[i];
		for ( ; o<=j ; o++)
			table[o] = base + i;
	}
}

void	InitNS8Bit (void)
{
	FillTable (greytable, greyramp, 240);
	FillTable (redtable, redramp, 0);
	FillTable (greentable, greenramp, 0);
	FillTable (bluetable, blueramp, 0);
}


byte ns8trans[256] =	// FIXME: dynamically calc this so palettes work
{
0,241,242,243,244,244,245,246,247,248,249,250,251,252,253,254,
45,241,241,242,91,91,91,96,96,136,136,136,141,141,141,141,
241,46,242,243,243,97,97,97,245,246,143,143,143,143,148,148,
0,5,45,45,50,50,90,90,95,95,95,95,95,140,140,141,
0,40,40,40,40,80,80,80,80,80,120,120,120,120,120,120,
45,50,50,90,90,95,95,135,135,135,136,141,141,181,181,181,
45,90,91,91,131,131,136,136,136,176,181,181,186,226,231,236,
45,45,91,91,96,96,136,136,137,142,182,182,187,188,188,233,
188,249,248,247,246,137,137,137,244,243,243,91,242,241,241,45,
183,183,183,247,137,137,137,137,137,244,91,91,91,241,241,45,
252,251,188,188,248,248,142,142,142,244,244,243,91,242,241,45,
247,247,246,246,245,245,244,244,243,243,242,242,51,241,241,5,
236,231,231,191,186,185,185,140,140,135,135,95,90,90,45,45,
4,49,49,53,53,93,93,93,93,92,92,92,243,242,46,241,
239,239,239,239,239,239,239,239,239,239,239,239,239,239,239,239,
239,239,239,239,239,239,239,239,239,239,239,239,239,239,239,182
};

/*
===================
Table8
===================
*/
void	Table8 (void)
{
	byte	*pal;
	int		r,g,b,v;
	int		i;
	byte	*table;
	
	pal = vid_palette;
	table = (byte *)pcolormap[0];
	
	for (i=0 ; i<256 ; i++)
	{
		r = pal[0];
		g = pal[1];
		b = pal[2];
		pal += 3;
		
// use the grey ramp if all indexes are close

		if (r-g < 16 && r-g > -16 && r-b < 16 && r-b > -16)
		{
			v = (r+g+b)/3;
			*table++ = greytable[v];
			continue;
		}
		
		r = redtable[r];
		g = greentable[g];
		b = bluetable[b];
		
// otherwise use the color cube
		*table++ = r*(8*5) + g*5 + b;
	}
}

/*
===================
Table24
===================
*/
void	Table24 (void)
{
	byte	*pal;
	int		r,g,b,v;
	int		i;
	unsigned	*table;
	
	
//
// 8 8 8 encoding
//
	pal = vid_palette;
	table = (unsigned *)pcolormap[0];
	
	for (i=0 ; i<256 ; i++)
	{
		r = pal[0];
		g = pal[1];
		b = pal[2];
		pal += 3;
		
		v = (r<<16) + (g<<8) + b;
		*table++ = v;
	}
}

/*
===================
Table24Swap
===================
*/
void	Table24Swap (void)
{
	byte	*pal;
	int		r,g,b,v;
	int		i;
	unsigned	*table;

//
// 8 8 8 encoding
//
	pal = vid_palette;
	table = (unsigned *)pcolormap[0];
	
	for (i=0 ; i<256 ; i++)
	{
		r = pal[0];
		g = pal[1];
		b = pal[2];
		pal += 3;
		
		v = (r<<24) + (g<<16) + (b<<8) /*+ 255*/;
		v = NXSwapBigLongToHost (v);
		*table++ = v;
	}
}


/*
===================
Table15
===================
*/
void	Table15 (void)
{
	byte			*pal;
	int				r,g,b,v;
	int				i, k;
	unsigned char	*palette;
	unsigned short	*table;
	int				dadj;
	int		ditheradjust[4] = {(1 << 9) * 3 / 8,
									(1 << 9) * 5 / 8,
									(1 << 9) * 7 / 8,
									(1 << 9) * 1 / 8};
	
	palette = vid_palette;
	table = (unsigned short *)pcolormap;
	
//
// 5 5 5 encoding
//
	for (k=0 ; k<4 ; k++)
	{
		dadj = ditheradjust[k];

		pal = vid_palette;

		for (i=0 ; i<256 ; i++)
		{
		// shift 6 bits to get back to 0-255, & 3 more for 5 bit color
		// FIXME: scale intensity levels properly
			r = (pal[0] + dadj) >> 3;
			g = (pal[1] + dadj) >> 3;
			b = (pal[2] + dadj) >> 3;
			pal += 3;

			v = (r<<10) + (g<<5) + b;

			*table++ = v;
		}
	}
}

/*
===================
Table12
===================
*/
void	Table12 (void)
{
	byte			*pal;
	int				r,g,b,v;
	int				i, k;
	unsigned short	*table;
	int				dadj;
	static int		ditheradjust[4] = {(1 << 9) * 3 / 8,
									   (1 << 9) * 5 / 8,
									   (1 << 9) * 7 / 8,
									   (1 << 9) * 1 / 8};

	table = (unsigned short *)pcolormap;
		
//
// 4 4 4 encoding
//
	for (k=0 ; k<4 ; k++)
	{
		dadj = ditheradjust[k];

		pal = vid_palette;

		for (i=0 ; i<256 ; i++)
		{
		// shift 5 bits to get back to 0-255, & 4 more for 4 bit color
		// FIXME: scale intensity levels properly
			r = (pal[0] + dadj) >> 4;
			g = (pal[1] + dadj) >> 4;
			b = (pal[2] + dadj) >> 4;
			pal += 3;

			v = ((r<<12) + (g<<8) + (b<<4) /*+ 15*/);

			*table++ = v;
		}
	}
}

/*
===================
Table12Swap
===================
*/
void	Table12Swap (void)
{
	byte			*pal;
	int				r,g,b,v;
	int				i, k;
	unsigned short	*table;
	int				dadj;
	static int		ditheradjust[4] = {(1 << 9) * 3 / 8,
									   (1 << 9) * 5 / 8,
									   (1 << 9) * 7 / 8,
									   (1 << 9) * 1 / 8};

	table = (unsigned short *)pcolormap;
		
//
// 4 4 4 encoding
//
	for (k=0 ; k<4 ; k++)
	{
		dadj = ditheradjust[k];

		pal = vid_palette;

		for (i=0 ; i<256 ; i++)
		{
		// shift 5 bits to get back to 0-255, & 4 more for 4 bit color
		// FIXME: scale intensity levels properly
			r = (pal[0] + dadj) >> 4;
			g = (pal[1] + dadj) >> 4;
			b = (pal[2] + dadj) >> 4;
			pal += 3;

			v = ((r<<12) + (g<<8) + (b<<4) /*+ 15*/);
			v = NXSwapBigShortToHost (v);

			*table++ = v;
		}
	}
}


/*
==========================================================================

					GENERIC IMAGING FUNCTIONS

==========================================================================
*/

/*
===================
Update8_1
===================
*/
void Update8_1 (pixel_t *src, byte *dest, int width, int height,
		int destrowbytes)
{
	int				x,y;
	unsigned		rowdelta, srcdelta;
	unsigned		xcount;
	byte			*pdest;
	int				xwidth;

	pdest = dest;
	
	xcount = width >> 3;
	srcdelta = vid.width - width;

	xwidth = width - (xcount << 3);
	if (xwidth)
		Sys_Error ("Width not multiple of 8");

	if ((vid_display == disp_framebuffer) && (vid_scale == 2))
	{
		int		nextrow = destrowbytes;

	    rowdelta = destrowbytes - (width << 1)  + destrowbytes;

		if (dither)
		{
			unsigned short	*psrc;

			psrc = (unsigned short *)src;

			for (y = height ; y ; y--)
			{
		    	for (x = xcount ; x ;x--)
			    {
					unsigned	temp;

					temp = psrc[0];
					pdest[0] = ((byte *)pcolormap[0])[temp];
					pdest[1] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 1] = ((byte *)pcolormap[3])[temp];
					temp = psrc[1];
					pdest[2] = ((byte *)pcolormap[0])[temp];
					pdest[3] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 2] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 3] = ((byte *)pcolormap[3])[temp];
					temp = psrc[2];
					pdest[4] = ((byte *)pcolormap[0])[temp];
					pdest[5] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 4] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 5] = ((byte *)pcolormap[3])[temp];
					temp = psrc[3];
					pdest[6] = ((byte *)pcolormap[0])[temp];
					pdest[7] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 6] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 7] = ((byte *)pcolormap[3])[temp];
					temp = psrc[4];
					pdest[8] = ((byte *)pcolormap[0])[temp];
					pdest[9] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 8] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 9] = ((byte *)pcolormap[3])[temp];
					temp = psrc[5];
					pdest[10] = ((byte *)pcolormap[0])[temp];
					pdest[11] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 10] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 11] = ((byte *)pcolormap[3])[temp];
					temp = psrc[6];
					pdest[12] = ((byte *)pcolormap[0])[temp];
					pdest[13] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 12] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 13] = ((byte *)pcolormap[3])[temp];
					temp = psrc[7];
					pdest[14] = ((byte *)pcolormap[0])[temp];
					pdest[15] = ((byte *)pcolormap[1])[temp];
					pdest[nextrow + 14] = ((byte *)pcolormap[2])[temp];
					pdest[nextrow + 15] = ((byte *)pcolormap[3])[temp];
					pdest += 16; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
		}
		else
		{
			byte	*psrc;

			psrc = (byte *)src;

			for (y = height ; y ; y--)
			{
				for (x = xcount ; x ;x--)
		    	{
					pdest[0] = pdest[1] = pdest[nextrow] =
						pdest[nextrow + 1] = ((byte *)pcolormap[0])[psrc[0]];
					pdest[2] = pdest[3] = pdest[nextrow + 2] =
						pdest[nextrow + 3] = ((byte *)pcolormap[0])[psrc[1]];
					pdest[4] = pdest[5] = pdest[nextrow + 4] =
						pdest[nextrow + 5] = ((byte *)pcolormap[0])[psrc[2]];
					pdest[6] = pdest[7] = pdest[nextrow + 6] =
						pdest[nextrow + 7] = ((byte *)pcolormap[0])[psrc[3]];
					pdest[8] = pdest[9] = pdest[nextrow + 8] =
						pdest[nextrow + 9] = ((byte *)pcolormap[0])[psrc[4]];
					pdest[10] = pdest[11] = pdest[nextrow + 10] =
						pdest[nextrow + 11] = ((byte *)pcolormap[0])[psrc[5]];
					pdest[12] = pdest[13] = pdest[nextrow + 12] =
						pdest[nextrow + 13] = ((byte *)pcolormap[0])[psrc[6]];
					pdest[14] = pdest[15] = pdest[nextrow + 14] =
						pdest[nextrow + 15] = ((byte *)pcolormap[0])[psrc[7]];
					pdest += 16; psrc += 8;
		    	}

				psrc += srcdelta;
			    pdest += rowdelta;
			}
		}
    }
	else
	{
	    rowdelta = destrowbytes - width;

		if (dither)
		{
			unsigned short	*psrc;

			psrc = (unsigned short *)src;

			for (y = height ; y>0 ; y -= 2)
			{
		    	for (x = xcount ; x ;x--)
			    {
					pdest[0] = ((byte *)pcolormap[0])[psrc[0]];
					pdest[1] = ((byte *)pcolormap[1])[psrc[1]];
					pdest[2] = ((byte *)pcolormap[0])[psrc[2]];
					pdest[3] = ((byte *)pcolormap[1])[psrc[3]];
					pdest[4] = ((byte *)pcolormap[0])[psrc[4]];
					pdest[5] = ((byte *)pcolormap[1])[psrc[5]];
					pdest[6] = ((byte *)pcolormap[0])[psrc[6]];
					pdest[7] = ((byte *)pcolormap[1])[psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;

		    	for (x = xcount ; x ;x--)
			    {
					pdest[0] = ((byte *)pcolormap[2])[psrc[0]];
					pdest[1] = ((byte *)pcolormap[3])[psrc[1]];
					pdest[2] = ((byte *)pcolormap[2])[psrc[2]];
					pdest[3] = ((byte *)pcolormap[3])[psrc[3]];
					pdest[4] = ((byte *)pcolormap[2])[psrc[4]];
					pdest[5] = ((byte *)pcolormap[3])[psrc[5]];
					pdest[6] = ((byte *)pcolormap[2])[psrc[6]];
					pdest[7] = ((byte *)pcolormap[3])[psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
		}
		else
		{
			byte	*psrc;

			psrc = (byte *)src;
//			srcdelta += width;
//			rowdelta += width;

			for (y = height ; y ; y--)
			{
		    	for (x = xcount ; x ;x--)
			    {
					pdest[0] = ((byte *)pcolormap[0])[psrc[0]];
					pdest[1] = ((byte *)pcolormap[0])[psrc[1]];
					pdest[2] = ((byte *)pcolormap[0])[psrc[2]];
					pdest[3] = ((byte *)pcolormap[0])[psrc[3]];
					pdest[4] = ((byte *)pcolormap[0])[psrc[4]];
					pdest[5] = ((byte *)pcolormap[0])[psrc[5]];
					pdest[6] = ((byte *)pcolormap[0])[psrc[6]];
					pdest[7] = ((byte *)pcolormap[0])[psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
		    }
		}
    }
}


/*
===================
Update16_1
===================
*/
void Update16_1 (pixel_t *src, unsigned short *dest, int width,
		int height, int destrowbytes)
{
	int				x,y;
	unsigned		rowdelta, srcdelta;
	unsigned		xcount;
	pixel_t			*psrc;
	unsigned short	*pdest;
	int				xwidth;


	psrc = src;
	pdest = dest;
	
	xcount = width >> 3;
	srcdelta = vid.width - width;

	xwidth = width - (xcount << 3);
	if (xwidth)
		Sys_Error ("Width not multiple of 8");

	if ((vid_display == disp_framebuffer) && (vid_scale == 2))
	{
		int		nextrow = destrowbytes >> 1;

	    rowdelta = (destrowbytes - ((width << 1) << 1) + destrowbytes) >> 1;

		if (dither)
		{
			for (y = height ; y ; y--)
			{
		    	for (x = xcount ; x ;x--)
			    {
					unsigned	temp;

					temp = psrc[0];
					pdest[0] = ((unsigned short *)pcolormap[0])[temp];
					pdest[1] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 1] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[1];
					pdest[2] = ((unsigned short *)pcolormap[0])[temp];
					pdest[3] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 2] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 3] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[2];
					pdest[4] = ((unsigned short *)pcolormap[0])[temp];
					pdest[5] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 4] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 5] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[3];
					pdest[6] = ((unsigned short *)pcolormap[0])[temp];
					pdest[7] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 6] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 7] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[4];
					pdest[8] = ((unsigned short *)pcolormap[0])[temp];
					pdest[9] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 8] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 9] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[5];
					pdest[10] = ((unsigned short *)pcolormap[0])[temp];
					pdest[11] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 10] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 11] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[6];
					pdest[12] = ((unsigned short *)pcolormap[0])[temp];
					pdest[13] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 12] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 13] = ((unsigned short *)pcolormap[3])[temp];
					temp = psrc[7];
					pdest[14] = ((unsigned short *)pcolormap[0])[temp];
					pdest[15] = ((unsigned short *)pcolormap[1])[temp];
					pdest[nextrow + 14] = ((unsigned short *)pcolormap[2])[temp];
					pdest[nextrow + 15] = ((unsigned short *)pcolormap[3])[temp];
					pdest += 16; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
		}
		else
		{
			for (y = height ; y ; y--)
			{
			for (x = xcount ; x ;x--)
			    {
					pdest[0] = pdest[1] = pdest[nextrow] =
							pdest[nextrow + 1] = pcolormap[0][psrc[0]];
					pdest[2] = pdest[3] = pdest[nextrow + 2] =
							pdest[nextrow + 3] = pcolormap[0][psrc[1]];
					pdest[4] = pdest[5] = pdest[nextrow + 4] =
							pdest[nextrow + 5] = pcolormap[0][psrc[2]];
					pdest[6] = pdest[7] = pdest[nextrow + 6] =
							pdest[nextrow + 7] = pcolormap[0][psrc[3]];
					pdest[8] = pdest[9] = pdest[nextrow + 8] =
							pdest[nextrow + 9] = pcolormap[0][psrc[4]];
					pdest[10] = pdest[11] = pdest[nextrow + 10] =
							pdest[nextrow + 11] = pcolormap[0][psrc[5]];
					pdest[12] = pdest[13] = pdest[nextrow + 12] =
							pdest[nextrow + 13] = pcolormap[0][psrc[6]];
					pdest[14] = pdest[15] = pdest[nextrow + 14] =
							pdest[nextrow + 15] = pcolormap[0][psrc[7]];
					pdest += 16; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
    	}
	}
	else
	{
	    rowdelta = (destrowbytes - (width<<1))>>1;

		if (dither)
		{
			for (y = height ; y>0 ; y -= 2)
			{
		    	for (x = xcount ; x ;x--)
			    {
					pdest[0] = ((unsigned short *)pcolormap[0])[psrc[0]];
					pdest[1] = ((unsigned short *)pcolormap[1])[psrc[1]];
					pdest[2] = ((unsigned short *)pcolormap[0])[psrc[2]];
					pdest[3] = ((unsigned short *)pcolormap[1])[psrc[3]];
					pdest[4] = ((unsigned short *)pcolormap[0])[psrc[4]];
					pdest[5] = ((unsigned short *)pcolormap[1])[psrc[5]];
					pdest[6] = ((unsigned short *)pcolormap[0])[psrc[6]];
					pdest[7] = ((unsigned short *)pcolormap[1])[psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;

		    	for (x = xcount ; x ;x--)
			    {
					pdest[0] = ((unsigned short *)pcolormap[2])[psrc[0]];
					pdest[1] = ((unsigned short *)pcolormap[3])[psrc[1]];
					pdest[2] = ((unsigned short *)pcolormap[2])[psrc[2]];
					pdest[3] = ((unsigned short *)pcolormap[3])[psrc[3]];
					pdest[4] = ((unsigned short *)pcolormap[2])[psrc[4]];
					pdest[5] = ((unsigned short *)pcolormap[3])[psrc[5]];
					pdest[6] = ((unsigned short *)pcolormap[2])[psrc[6]];
					pdest[7] = ((unsigned short *)pcolormap[3])[psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
		}
		else
		{
			for (y = height ; y ; y--)
			{
			for (x = xcount ; x ;x--)
			    {
					pdest[0] = pcolormap[0][psrc[0]];
					pdest[1] = pcolormap[0][psrc[1]];
					pdest[2] = pcolormap[0][psrc[2]];
					pdest[3] = pcolormap[0][psrc[3]];
					pdest[4] = pcolormap[0][psrc[4]];
					pdest[5] = pcolormap[0][psrc[5]];
					pdest[6] = pcolormap[0][psrc[6]];
					pdest[7] = pcolormap[0][psrc[7]];
					pdest += 8; psrc += 8;
			    }

				psrc += srcdelta;
			    pdest += rowdelta;
			}
    	}
	}
}


/*
===================
Update32_1
===================
*/
void Update32_1 (pixel_t *src, unsigned *dest, int width, int height,
		int destrowbytes)
{
	int				x,y;
	unsigned		rowdelta, srcdelta;
	unsigned		xcount;
	pixel_t			*psrc;
	unsigned		*pdest;
	int				xwidth;

	psrc = src;
	pdest = dest;

	xcount = width >> 3;
	srcdelta = vid.width - width;

	xwidth = width - (xcount << 3);
	if (xwidth)
		Sys_Error ("Width not multiple of 8");

	if ((vid_display == disp_framebuffer) && (vid_scale == 2))
	{
		int		nextrow = destrowbytes >> 2;

	    rowdelta = ((destrowbytes - ((width << 1) << 2)) >> 2)  +
				(destrowbytes >> 2);

		for (y = height ; y ; y--)
		{
			for (x = xcount ; x ;x--)
		    {
				pdest[0] = pdest[1] = pdest[nextrow] =
						pdest[nextrow + 1] = pcolormap[0][psrc[0]];
				pdest[2] = pdest[3] = pdest[nextrow + 2] =
						pdest[nextrow + 3] = pcolormap[0][psrc[1]];
				pdest[4] = pdest[5] = pdest[nextrow + 4] =
						pdest[nextrow + 5] = pcolormap[0][psrc[2]];
				pdest[6] = pdest[7] = pdest[nextrow + 6] =
						pdest[nextrow + 7] = pcolormap[0][psrc[3]];
				pdest[8] = pdest[9] = pdest[nextrow + 8] =
						pdest[nextrow + 9] = pcolormap[0][psrc[4]];
				pdest[10] = pdest[11] = pdest[nextrow + 10] =
						pdest[nextrow + 11] = pcolormap[0][psrc[5]];
				pdest[12] = pdest[13] = pdest[nextrow + 12] =
						pdest[nextrow + 13] = pcolormap[0][psrc[6]];
				pdest[14] = pdest[15] = pdest[nextrow + 14] =
						pdest[nextrow + 15] = pcolormap[0][psrc[7]];
				pdest += 16; psrc += 8;
		    }

			psrc += srcdelta;
		    pdest += rowdelta;
		}
    }
	else
	{
	    rowdelta = (destrowbytes - (width<<2))>>2;

		for (y = height ; y ; y--)
		{
			for (x = xcount ; x ;x--)
		    {
				pdest[0] = pcolormap[0][psrc[0]];
				pdest[1] = pcolormap[0][psrc[1]];
				pdest[2] = pcolormap[0][psrc[2]];
				pdest[3] = pcolormap[0][psrc[3]];
				pdest[4] = pcolormap[0][psrc[4]];
				pdest[5] = pcolormap[0][psrc[5]];
				pdest[6] = pcolormap[0][psrc[6]];
				pdest[7] = pcolormap[0][psrc[7]];
				pdest += 8; psrc += 8;
		    }

			psrc += srcdelta;
		    pdest += rowdelta;
		}
	}
}


/*
==========================================================================

						NEXTSTEP VIEW CLASS

==========================================================================
*/


@implementation QuakeView

/*
=================
windowDidMove

=================
*/
- windowDidMove:sender
{
    NXPoint	aPoint;
    NXRect	winframe;

    aPoint.x = aPoint.y = 0;
    [self convertPoint:&aPoint toView:nil];
    [window convertBaseToScreen: &aPoint];
    [window getFrame: &winframe];

    if ((int)aPoint.x & 7)
    {
	[window moveTo:winframe.origin.x - ((int)aPoint.x&7) 
			:winframe.origin.y];
	[window getFrame: &winframe];
    }
    return self;
}

- windowWillResize:sender toSize:(NXSize *)frameSize
{
	NXRect		fr, cont;
	
	fr.origin.x = fr.origin.y = 0;
	fr.size = *frameSize;
	
	[Window getContentRect:&cont forFrameRect: &fr style:[window style]];

	cont.size.width = (int)cont.size.width & ~15;
	if (cont.size.width < 128)
		cont.size.width = 128;
	cont.size.height = (int)cont.size.height & ~3;
	if (cont.size.height < 32)
		cont.size.height = 32;

	[Window getFrameRect:&fr forContentRect: &cont style:[window style]];

	*frameSize = fr.size;
	
	return self;
}

- windowDidResize:sender
{
	if (vid_display == disp_framebuffer)
		Sys_Error ("How the heck are you resizing a framebuffer window?!?");

	vid.width = bounds.size.width/vid_scale;
	vid.height = bounds.size.height/vid_scale;

//
// allocate memory for the back and translation buffers
//
	vid.rowbytes = vid.width;
	rowbytesnative = vid.width * pixbytesnative;
	
	AllocBuffers (true);

	vid.conbuffer = vid.buffer;
	vid.conrowbytes = vid.rowbytes;
	vid.conwidth = vid.width;
	vid.conheight = vid.height;

	vid.recalc_refdef = 1;

	return self;
}

-(BOOL) acceptsFirstResponder
{
    return YES;
}


typedef struct
{
	int		source, dest;
} keymap_t;

keymap_t keymaps[] =
{
	{103, K_RIGHTARROW},
	{102, K_LEFTARROW},
	{100, K_UPARROW},
	{101, K_DOWNARROW},
	{111, K_PAUSE},

	{59, K_F1},
	{60, K_F2},
	{61, K_F3},
	{62, K_F4},
	{63, K_F5},
	{64, K_F6},
	{65, K_F7},
	{66, K_F8},
	{67, K_F9},
	{68, K_F10},
	{87, K_F11},
	{88, K_F12},
	
	{-1,-1}
};

keymap_t flagmaps[] =
{
	{NX_SHIFTMASK, K_SHIFT},
	{NX_CONTROLMASK, K_CTRL},
	{NX_ALTERNATEMASK, K_ALT},
	{NX_COMMANDMASK, K_ALT},
	
	{-1,-1}
};

/*
===================
keyboard methods
===================
*/
- keyDown:(NXEvent *)theEvent
{
    int	ch;
	keymap_t	*km;
	
	PSobscurecursor ();

// check for non-ascii first
	ch = theEvent->data.key.keyCode;
	for (km=keymaps;km->source!=-1;km++)
		if (ch == km->source)
		{
			Key_Event (km->dest, true);
			return self;
		}

    ch = theEvent->data.key.charCode;
	if (ch >= 'A' && ch <= 'Z')
		ch += 'a' - 'A';
    if (ch>=256)
		return self;
		
	Key_Event (ch, true);
    return self;
}

- flagsChanged:(NXEvent *)theEvent
{
	static int	oldflags;
    int		newflags;
	int		delta;
	keymap_t	*km;
	int		i;
	
	PSobscurecursor ();
    newflags = theEvent->flags;
	delta = newflags ^ oldflags;
	for (i=0 ; i<32 ; i++)
	{
		if ( !(delta & (1<<i)))
			continue;
	// changed
		for (km=flagmaps;km->source!=-1;km++)
			if ( (1<<i) == km->source)
			{
				if (newflags & (1<<i))
					Key_Event (km->dest, true);
				else
					Key_Event (km->dest, false);
			}

	}
	
	oldflags = newflags;
		
    return self;
}


- keyUp:(NXEvent *)theEvent
{
    int	ch;
 	keymap_t	*km;
  
 // check for non-ascii first
	ch = theEvent->data.key.keyCode;
	for (km=keymaps;km->source!=-1;km++)
		if (ch == km->source)
		{
			Key_Event (km->dest, false);
			return self;
		}

   ch = theEvent->data.key.charCode;
	if (ch >= 'A' && ch <= 'Z')
		ch += 'a' - 'A';
    if (ch>=256)
		return self;
	Key_Event (ch, false);
    return self;
}


- tiffShot
{
	id			imagerep, image;
	NXRect		r;
	NXStream	*stream;
	int			fd;
	int    		i; 
	char		tiffname[80]; 
	
	[vid_window_i getFrame: &r];
	r.origin.x = r.origin.y = 0;
	image = [[NXImage alloc] initSize: &r.size];
	imagerep = [[NXCachedImageRep alloc] initFromWindow:vid_window_i rect:&r];
	
	[image lockFocus];
	[imagerep draw];
	[image unlockFocus];
	
// 
// find a file name to save it to 
// 
	strcpy(tiffname,"quake00.tif");
		
	for (i=0 ; i<=99 ; i++) 
	{ 
		tiffname[5] = i/10 + '0'; 
		tiffname[6] = i%10 + '0'; 
		if (Sys_FileTime(tiffname) == -1)
			break;	// file doesn't exist
	} 
	if (i==100) 
		Sys_Error ("SCR_ScreenShot_f: Couldn't create a tiff"); 

	fd = open (tiffname, O_RDWR|O_CREAT|O_TRUNC, 0666);
	stream = NXOpenFile (fd, NX_READWRITE);
	[image writeTIFF: stream];
	NXClose (stream);
	close (fd);
	printf ("wrote %s\n", tiffname);

	[image free];
	[imagerep free];
	return self;
	
}

- screenShot: sender
{
	return [self tiffShot];
}

- setScaleFullScreen: sender
{
	VID_Shutdown ();
	if (vid_fullscreen)
	{
		vid_fullscreen = 0;
		VID_Restart (vid_display, vid_scale);
	}
	else
	{
		vid_fullscreen = 1;
		VID_Restart (vid_display, vid_scale);
	}
	return self;
}

@end

//============================================================================

@implementation FrameWindow

- windowExposed:(NXEvent *)theEvent
{
	return self;
}

@end


