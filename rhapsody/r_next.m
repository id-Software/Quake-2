
#import <AppKit/AppKit.h>
#include "../ref_soft/r_local.h"

/*
====================================================================

 OPENSTEP specific stuff

====================================================================
*/

@interface QuakeView : NSView
@end

NSWindow	*vid_window_i;
QuakeView	*vid_view_i;

unsigned	*buffernative;

//===========================================================


int Draw_SetResolution (void);

#define	TYPE_FULLSCREEN	0
#define	TYPE_WINDOWED	1
#define	TYPE_STRETCHED	2

#define	NUM_RESOLUTIONS		7
int	resolutions[NUM_RESOLUTIONS][2] = { 
	{320,200}, {320,240}, {400,300}, {512,384}, {640,480}, {800,600}, {1024,768} };

qboolean	available[NUM_RESOLUTIONS][3];
int			mode_res = 0, mode_type = TYPE_WINDOWED;

byte		gammatable[256];	// palette is sent through this
unsigned       	current_palette[256];
unsigned       	gamma_palette[256];

int			cursor_res, cursor_type;

cvar_t		*vid_x;
cvar_t		*vid_y;
cvar_t		*vid_mode;
cvar_t		*vid_stretched;
cvar_t		*vid_fullscreen;
cvar_t		*draw_gamma;

void Draw_BuildGammaTable (void);

/*
====================================================================

MENU INTERACTION

====================================================================
*/

void FindModes (void)
{
	if (mode_res < 0 || mode_res >= NUM_RESOLUTIONS)
		mode_res = 0;
	if (mode_type < 0 || mode_type > 3)
		mode_type = 1;

}

void RM_Print (int x, int y, char *s)
{
	while (*s)
	{
		Draw_Char (x, y, (*s)+128);
		s++;
		x += 8;
	}
}

/*
================
Draw_MenuDraw
================
*/
void Draw_MenuDraw (void)
{
	int		i, j;
	int		y;
	char	string[32];

	Draw_Pic ( 4, 4, "vidmodes");

	RM_Print (80, 32, "fullscreen windowed stretched");
	RM_Print (80, 40, "---------- -------- ---------");
	y = 50;

	// draw background behind selected mode
	Draw_Fill ( (mode_type+1)*80, y+(mode_res)*10, 40,10, 8);

	// draw available grid
	for (i=0 ; i<NUM_RESOLUTIONS ; i++, y+= 10)
	{
		sprintf (string, "%ix%i", resolutions[i][0], resolutions[i][1]);
		RM_Print (0, y, string);
		for (j=0 ; j<3 ; j++)
			if (available[i][j])
				RM_Print ( 80 + j*80, y, "*");
	}

	// draw the cursor
	Draw_Char (80 + cursor_type*80, 50 + cursor_res*10, 128 + 12+((int)(r_newrefdef.time*4)&1));
}


#define	K_TAB			9
#define	K_ENTER			13
#define	K_ESCAPE		27
#define	K_SPACE			32

// normal keys should be passed as lowercased ascii

#define	K_BACKSPACE		127
#define	K_UPARROW		128
#define	K_DOWNARROW		129
#define	K_LEFTARROW		130
#define	K_RIGHTARROW	131

/*
================
Draw_MenuKey
================
*/
void Draw_MenuKey (int key)
{
	switch (key)
	{
	case K_LEFTARROW:
		cursor_type--;
		if (cursor_type < 0)
			cursor_type = 2;
		break;

	case K_RIGHTARROW:
		cursor_type++;
		if (cursor_type > 2)
			cursor_type = 0;
		break;

	case K_UPARROW:
		cursor_res--;
		if (cursor_res < 0)
			cursor_res = NUM_RESOLUTIONS-1;
		break;

	case K_DOWNARROW:
		cursor_res++;
		if (cursor_res >= NUM_RESOLUTIONS)
			cursor_res = 0;
		break;

	case K_ENTER:
		ri.Cmd_ExecuteText (EXEC_NOW, va("vid_mode %i", cursor_res));
		switch (cursor_type)
                {
                    case TYPE_FULLSCREEN:
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_fullscreen 1");
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_stretched 0");
                        break;
                    case TYPE_WINDOWED:
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_fullscreen 0");
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_stretched 0");
                        break;
                    case TYPE_STRETCHED:
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_fullscreen 0");
                        ri.Cmd_ExecuteText (EXEC_NOW, "vid_stretched 1");
                        break;
		}
                    
		mode_res = cursor_res;
		mode_type = cursor_type;
		Draw_SetResolution ();
		break;

	default:
		break;
	}
}

//===========================================================


/*
================
Draw_SetResolution

The vid structure will be filled in on return
Also allocates the z buffer and surface cache
================
*/
int Draw_SetResolution (void)
{
    NSRect	content;
    
	if (vid_mode->value < 0)
		ri.Cmd_ExecuteText (EXEC_NOW, "vid_mode 0");
	if (vid_mode->value >= NUM_RESOLUTIONS)
		ri.Cmd_ExecuteText (EXEC_NOW, va("vid_mode %i", NUM_RESOLUTIONS-1));

	vid_mode->modified = false;
        vid_fullscreen->modified = false;
        vid_stretched->modified = false;

        // free nativebuffer
        if (buffernative)
        {
            free (buffernative);
            buffernative = NULL;
        }
        
	// free z buffer
	if (d_pzbuffer)
	{
		free (d_pzbuffer);
		d_pzbuffer = NULL;
	}
	// free surface cache
	if (sc_base)
	{
		D_FlushCaches ();
		free (sc_base);
		sc_base = NULL;
	}

        vid.width = resolutions[(int)(vid_mode->value)][0];
	vid.height = resolutions[(int)(vid_mode->value)][1];

	vid.win_width = vid.width;
	vid.win_height = vid.height;
	if (vid_stretched->value)
	{
		vid.win_width <<= 1;
		vid.win_height <<= 1;
	}

	vid.aspect = 1;
	vid.buffer = malloc (vid.width*vid.height);
	vid.rowbytes = vid.width;
        d_pzbuffer = malloc(vid.width*vid.height*2);
        buffernative = malloc(vid.width*vid.height*4);

	D_InitCaches ();

	Sys_SetPalette ((byte *)d_8to24table);

        if (vid_view_i)
            [vid_view_i unlockFocus];
        if (vid_window_i)
            [vid_window_i close];
//
// open a window
//
        content = NSMakeRect (vid_x->value,vid_y->value,vid.win_width, vid.win_height);
   vid_window_i = [[NSWindow alloc]
                       initWithContentRect:	content
                                 styleMask:	NSTitledWindowMask
                                   backing:	NSBackingStoreRetained
                            	defer:	NO
       ];

   [vid_window_i setDelegate: vid_window_i];
   [vid_window_i display];
   [NSApp activateIgnoringOtherApps: YES];
   [vid_window_i makeKeyAndOrderFront: nil];

//   NSPing ();

   content.origin.x = content.origin.y = 0;
   vid_view_i = [[QuakeView alloc] initWithFrame: content];
   [vid_window_i setContentView: vid_view_i];
   [vid_window_i makeFirstResponder: vid_view_i];
   [vid_window_i setDelegate: vid_view_i];

//   [vid_window_i addToEventMask: NS_FLAGSCHANGEDMASK];
   [vid_window_i setTitle: @"Bitmap Quake Console"];
 	[vid_window_i makeKeyAndOrderFront: nil];
        
   // leave focus locked forever
   [vid_view_i lockFocus];
   
	ri.VID_SetSize (vid.width, vid.height);

	return 0;
}

/*
@@@@@@@@@@@@@@@@@@@@@
Draw_Init

@@@@@@@@@@@@@@@@@@@@@
*/
int Draw_Init (void *window)
{
    [NSApplication sharedApplication];
	[NSApp finishLaunching];
  
	ri.Con_Printf (PRINT_ALL, "refresh version: "REF_VERSION"\n");

	vid_x = ri.Cvar_Get ("vid_x", "0", CVAR_ARCHIVE);
	vid_y = ri.Cvar_Get ("vid_y", "0", CVAR_ARCHIVE);
	vid_mode = ri.Cvar_Get ("vid_mode", "0", CVAR_ARCHIVE);
        vid_fullscreen = ri.Cvar_Get ("vid_fullscreen", "0", CVAR_ARCHIVE);
        vid_stretched = ri.Cvar_Get ("vid_stretched", "0", CVAR_ARCHIVE);
	draw_gamma = ri.Cvar_Get ("gamma", "1", CVAR_ARCHIVE);

        Draw_GetPalette ();

	Draw_BuildGammaTable ();

	// get the lighting colormap
	ri.FS_LoadFile ("gfx/colormap.lmp", (void **)&vid.colormap);
	if (!vid.colormap)
	{
		ri.Con_Printf (PRINT_ALL, "ERROR: Couldn't load gfx/colormap.lmp");
		return -1;
	}

	Draw_SetResolution ();

	R_Init ();

	return 0;
}


/*
@@@@@@@@@@@@@@@@@@@@@
Draw_Shutdown

@@@@@@@@@@@@@@@@@@@@@
*/
void Draw_Shutdown (void)
{
   R_Shutdown ();
}


/*
@@@@@@@@@@@@@@@@@@@@@
Draw_BuildGammaTable

@@@@@@@@@@@@@@@@@@@@@
*/
void Draw_BuildGammaTable (void)
{
	int		i, inf;
	float	g;

	draw_gamma->modified = false;
	g = draw_gamma->value;

	if (g == 1.0)
	{
		for (i=0 ; i<256 ; i++)
			gammatable[i] = i;
		return;
	}
	
	for (i=0 ; i<256 ; i++)
	{
		inf = 255 * pow ( (i+0.5)/255.5 , g ) + 0.5;
		if (inf < 0)
			inf = 0;
		if (inf > 255)
			inf = 255;
		gammatable[i] = inf;
	}
}


/*
@@@@@@@@@@@@@@@@@@@@@
Draw_BeginFram

@@@@@@@@@@@@@@@@@@@@@
*/
void Draw_BeginFrame (void)
{
	if (vid_mode->modified || vid_fullscreen->modified
     	|| vid_stretched->modified)
		Draw_SetResolution ();

	if (draw_gamma->modified)
	{
		Draw_BuildGammaTable ();
		Sys_SetPalette ((byte *)current_palette);
	}

//	MGL_beginDirectAccess();
//	vid.buffer = mgldc->surface;
//	vid.rowbytes = mgldc->mi.bytesPerLine;
}


/*
@@@@@@@@@@@@@@@@@@@@@
Draw_EndFrame

@@@@@@@@@@@@@@@@@@@@@
*/
void Draw_EndFrame (void)
{
	int		i, c;
	int		bps, spp, bpp, bpr;
        unsigned char	*planes[5];
        NSRect			bounds;

	// translate to 24 bit color
        c = vid.width*vid.height;
	for (i=0 ; i<c ; i++)
		buffernative[i] = gamma_palette[vid.buffer[i]];
        
     bps = 8;
     spp = 3;
     bpp = 32;
     bpr = vid.width * 4;
     planes[0] = (unsigned char *)buffernative;

    bounds = [vid_view_i bounds];

    NSDrawBitmap(
                bounds,
                vid.width,
                vid.height,
                bps,
                spp,
                bpp,
                bpr,
                NO,
                NO,
                 @"NSDeviceRGBColorSpace",
                planes
                );
}


//===============================================================================

#define	HUNK_MAGIC	0xffaffaff
typedef struct
{
    int		magic;
    int		length;
    int		pad[6];
} hunkheader_t;

hunkheader_t	*membase;
int		maxsize;
int		cursize;

void *Hunk_Begin (void)
{
    kern_return_t	r;

// reserve a huge chunk of memory, but don't commit any yet
    maxsize = 16*1024*1024;
    cursize = 0;
    membase = NULL;
    r = vm_allocate(task_self(), (vm_address_t *)&membase, maxsize, 1);
    if (!membase || r != KERN_SUCCESS)
            ri.Sys_Error (ERR_FATAL,"vm_allocate failed");
    membase->magic = HUNK_MAGIC;
    membase->length = maxsize;
    cursize = 32;
    return (void *)((byte *)membase + cursize);
}

void *Hunk_Alloc (int size)
{
	// round to cacheline
	size = (size+31)&~31;
	
	cursize += size;

        if (cursize > maxsize)
            ri.Sys_Error (ERR_DROP, "Hunk_Alloc overflow");

        memset ((byte *)membase+cursize-size,0,size);

        return (void *)((byte *)membase+cursize-size);
}

int Hunk_End (void)
{
    kern_return_t	r;
    
    // round to pagesize
    cursize = (cursize+vm_page_size)&~(vm_page_size-1);
    membase->length = cursize;
    r = vm_deallocate(task_self(),
                  (vm_address_t)((byte *)membase + cursize),
                  maxsize - cursize);
    if ( r != KERN_SUCCESS )
        ri.Sys_Error (ERR_DROP, "vm_deallocate failed");
    return cursize;
}

void Hunk_Free (void *base)
{
    hunkheader_t	*h;
    kern_return_t	r;
    
    h = ((hunkheader_t *)base) - 1;
    if (h->magic != HUNK_MAGIC)
        ri.Sys_Error (ERR_FATAL, "Hunk_Free: bad magic");

    r = vm_deallocate(task_self(), (vm_address_t)h, h->length);
    if ( r != KERN_SUCCESS )
        ri.Sys_Error (ERR_DROP, "vm_deallocate failed");
}


/*
================
Sys_MakeCodeWriteable
================
*/
void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{
}


/*
================
Sys_SetPalette
================
*/
void Sys_SetPalette (byte *palette)
{
	byte	*p;
	int		i;

        memcpy (current_palette, palette, sizeof(current_palette));
        p = (byte *)gamma_palette;
	// gamma correct and byte swap
	for (i=0 ; i<256 ; i++, p+=4, palette+=4)
	{
		p[0] = gammatable[palette[0]];
		p[1] = gammatable[palette[1]];
		p[2] = gammatable[palette[2]];
                p[3] = 0xff;
	}

}


/*
 ==========================================================================

 NEXTSTEP VIEW CLASS

 ==========================================================================
 */
#include "../client/keys.h"

void IN_ActivateMouse (void);
void IN_DeactivateMouse (void);

@implementation QuakeView

-(BOOL) acceptsFirstResponder
{
    return YES;
}

- (void)windowDidMove: (NSNotification *)note
{
    NSRect	r;

    r = [vid_window_i frame];
    ri.Cmd_ExecuteText (EXEC_NOW, va("vid_x %i", (int)r.origin.x+1));
    ri.Cmd_ExecuteText (EXEC_NOW, va("vid_y %i", (int)r.origin.y+1));    
}

- (void)becomeKeyWindow
{
    IN_ActivateMouse ();
}

- (void)resignKeyWindow
{
    IN_DeactivateMouse ();
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
    {NSShiftKeyMask, K_SHIFT},
    {NSControlKeyMask, K_CTRL},
    {NSAlternateKeyMask, K_ALT},
    {NSCommandKeyMask, K_ALT},

    {-1,-1}
};

- (void)mouseDown:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE1, true);
}
- (void)mouseUp:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE1, false);
}
- (void)rightMouseDown:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE2, true);
}
- (void)rightMouseUp:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE2, false);
}


/*
 ===================
 keyboard methods
 ===================
 */
- (void)keyDown:(NSEvent *)theEvent
{
    int	ch;
    keymap_t	*km;

//    PSobscurecursor ();

// check for non-ascii first
    ch = [theEvent keyCode];
    for (km=keymaps;km->source!=-1;km++)
        if (ch == km->source)
        {
            Key_Event (km->dest, true);
            return;
        }

            ch = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (ch >= 'A' && ch <= 'Z')
        ch += 'a' - 'A';
    if (ch>=256)
        return;

    Key_Event (ch, true);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    static int	oldflags;
    int		newflags;
    int		delta;
    keymap_t	*km;
    int		i;

//    PSobscurecursor ();
    newflags = [theEvent modifierFlags];
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
}


- (void)keyUp:(NSEvent *)theEvent
{
    int	ch;
    keymap_t	*km;

 // check for non-ascii first
    ch = [theEvent keyCode];
    for (km=keymaps;km->source!=-1;km++)
        if (ch == km->source)
        {
            Key_Event (km->dest, false);
            return;
        }

            ch = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (ch >= 'A' && ch <= 'Z')
        ch += 'a' - 'A';
    if (ch>=256)
        return;
    Key_Event (ch, false);
}

@end


