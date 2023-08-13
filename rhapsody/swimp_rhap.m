#import <AppKit/AppKit.h>
#import <Interceptor/NSDirectScreen.h>
#import <AppKit/NSColor.h>
#include "../ref_soft/r_local.h"

@interface QuakeView : NSView
@end

NSWindow	*vid_window_i;
QuakeView	*vid_view_i;
NSDirectScreen *vid_screen;
byte		*vid_buffer;		// real framebuffer
int			vid_rowbytes;		// framebuffer rowbytes

unsigned	*buffernative;		// 24 bit off-screen back buffer for window
unsigned	swimp_palette[256];

typedef enum {
    rhap_shutdown,
    rhap_windowed,
    rhap_fullscreen
} rhapMode_t;

rhapMode_t	rhap_mode;

/*
=======================================================================

FULLSCREEN

=======================================================================
*/

/*
** InitFullscreen
*/
rserr_t InitFullscreen (int width, int height)
{
    NSDictionary *mode, *bestMode;
    int			modeWidth, bestWidth;
    int			modeHeight, bestHeight;
	NSArray		*modes;
    int			i;
	NSString	*string;

    
    vid_screen = [[NSDirectScreen alloc] initWithScreen:[NSScreen mainScreen]];

    // search for an apropriate mode
    modes = [vid_screen availableDisplayModes];
    bestMode = NULL;
    bestWidth = 99999;
    bestHeight = 99999;
   	for (i=0 ; i<[modes count] ; i++) {
        mode = [modes objectAtIndex: i];
        string = [mode objectForKey: @"NSDirectScreenPixelEncoding"];
        if ( ![string isEqualToString: @"PPPPPPPP"] )
            continue;	// only look at paletted modes
        modeWidth = [[mode objectForKey: @"NSDirectScreenWidth"] intValue];
        modeHeight = [[mode objectForKey: @"NSDirectScreenHeight"] intValue];
        if (modeWidth < width || modeHeight < height)
            continue;
        if (modeWidth < bestWidth) {
            bestWidth = modeWidth;
            bestHeight = modeHeight;
            bestMode = mode;
        }
    } 

    // if there wasn't any paletted mode of that res or greater, fail
    if (!bestMode)
        return rserr_invalid_fullscreen;

	ri.Con_Printf (PRINT_ALL, "SheildDisplay\n");
    [vid_screen shieldDisplay];

    // hide the cursor in all fullscreen modes
    [NSCursor hide];
    
    vid_window_i = [vid_screen shieldingWindow];

    ri.Con_Printf (PRINT_ALL, "switchToDisplayMode\n");
    [vid_screen switchToDisplayMode:bestMode];
//    [vid_screen fadeDisplayOutToColor:[NSColor blackColor]];
//    [vid_screen fadeDisplayInFromColor:[NSColor blackColor]];

	vid_buffer = [vid_screen data];
	vid_rowbytes = [vid_screen bytesPerRow];

    return rserr_ok;
}

void ShutdownFullscreen (void)
{
	[vid_screen dealloc];
	[NSCursor unhide];
}

void SetPaletteFullscreen (const unsigned char *palette) {
#if 0
    byte	*p;
    int		i;
	NSDirectPalette		*pal;

    pal = [NSDirectPalette init];
    for (i=0 ; i<256 ; i++)
        [pal setRed: palette[0]*(1.0/255)
              green:  palette[1]*(1.0/255)
               blue:  palette[2]*(1.0/255)
            atIndex: i];
	[vid_screen setPalette: pal];
    [pal release];
#endif
}



void BlitFullscreen (void)
{
	int		i, j;
	int		w;
	int		*dest, *source;

	w = vid.width>>2;

    source = (int *)vid.buffer;		// off-screen buffer
    dest = (int *)vid_buffer;		// directly on screen
    for (j=0 ; j<vid.height ; j++
         , source += (vid.rowbytes>>2), dest += (vid_rowbytes>>2)  ) {
        for (i=0 ; i<w ; i++ ) {
            dest[i] = source[i];            
        }
 	}
}

/*
=======================================================================

WINDOWED

=======================================================================
*/

/*
** InitWindowed
*/
rserr_t InitWindowed (int width, int height)
{
    rserr_t retval = rserr_ok;
    NSRect	content;
    cvar_t	*vid_xpos;
    cvar_t	*vid_ypos;

    //
    // open a window
    //
    vid_xpos = ri.Cvar_Get ("vid_xpos", "0", 0);
    vid_ypos = ri.Cvar_Get ("vid_ypos", "0", 0);

    content = NSMakeRect (vid_xpos->value,vid_ypos->value, width, height);
    vid_window_i = [[NSWindow alloc]
                initWithContentRect:	content
                            styleMask:	NSTitledWindowMask
                            backing:	NSBackingStoreRetained
                            defer:	NO
    ];

//    [vid_window_i addToEventMask: NS_FLAGSCHANGEDMASK];
    [vid_window_i setTitle: @"Quake2"];

    buffernative = malloc(width * height * 4);

    return retval;
}

void ShutdownWindowed (void)
{
    if (vid_window_i)
    {
        [vid_window_i release];
        vid_window_i = NULL;
    }
    if (buffernative)
    {
        free (buffernative);
        buffernative = NULL;
    }
}

void SetPaletteWindowed (const unsigned char *palette) {
    byte	*p;
    int		i;

    p = (byte *)swimp_palette;
    for (i=0 ; i<256 ; i++, p+=4, palette+=4)
    {
        p[0] = palette[0];
       	p[1] = palette[1];
        p[2] = palette[2];
        p[3] = 0xff;
    }
}


void BlitWindowed (void)
{
    int		i, c;
    int		bps, spp, bpp, bpr;
    unsigned char	*planes[5];
    NSRect			bounds;

    if (!vid_view_i)
        return;

    // translate to 24 bit color
    c = vid.width*vid.height;
    for (i=0 ; i<c ; i++)
        buffernative[i] = swimp_palette[vid.buffer[i]];

     bps = 8;
     spp = 3;
     bpp = 32;
     bpr = vid.width * 4;
     planes[0] = (unsigned char *)buffernative;

    bounds = [vid_view_i bounds];

    [vid_view_i lockFocus];

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

    [vid_view_i unlockFocus];
	PSWait ();
}


//======================================================================

/*
** RW_IMP.C
**
** This file contains ALL Win32 specific stuff having to do with the
** software refresh.  When a port is being made the following functions
** must be implemented by the port:
**
** SWimp_EndFrame
** SWimp_Init
** SWimp_SetPalette
** SWimp_Shutdown
*/


/*
** SWimp_Init
**
** This routine is responsible for initializing the implementation
** specific stuff in a software rendering subsystem.
*/
int SWimp_Init( void *hInstance, void *wndProc )
{
    if (!NSApp)
    {
        [NSApplication sharedApplication];
        [NSApp finishLaunching];
    }

    return true;
}


/*
** SWimp_SetMode
*/
rserr_t SWimp_SetMode( int *pwidth, int *pheight, int mode, qboolean fullscreen)
{
    const char 	*win_fs[] = { "W", "FS" };
    NSRect		content;
	rserr_t		ret;
    
    // free resources in use
    SWimp_Shutdown ();

    ri.Con_Printf (PRINT_ALL, "setting mode %d:", mode );

    if ( !ri.Vid_GetModeInfo( pwidth, pheight, mode ) )
    {
        ri.Con_Printf( PRINT_ALL, " invalid mode\n" );
        return rserr_invalid_mode;
    }

    ri.Con_Printf( PRINT_ALL, " %d %d %s\n", *pwidth, *pheight, win_fs[fullscreen] );

    vid.buffer = malloc(*pwidth * *pheight);
	vid.rowbytes = *pwidth;

    if (fullscreen) {
        rhap_mode = rhap_fullscreen;
        ret = InitFullscreen (*pwidth, *pheight);        
    } else {
        rhap_mode = rhap_windowed;
        ret = InitWindowed (*pwidth, *pheight);
    }

    if (ret != rserr_ok) {
        SWimp_Shutdown ();
        return ret;       
    }
    
    /*
     ** the view is identical in windowed and fullscreen modes
     */
    content.origin.x = content.origin.y = 0;
    content.size.width = *pwidth;
    content.size.height = *pheight;
    vid_view_i = [[QuakeView alloc] initWithFrame: content];
    [vid_window_i setContentView: vid_view_i];
    [vid_window_i makeFirstResponder: vid_view_i];
    [vid_window_i setDelegate: vid_view_i];

    [NSApp activateIgnoringOtherApps: YES];
    [vid_window_i makeKeyAndOrderFront: nil];
    [vid_window_i display];

	return ret;
}

/*
** SWimp_Shutdown
**
** System specific graphics subsystem shutdown routine
*/
void SWimp_Shutdown( void )
{
    if (rhap_mode == rhap_windowed)
        ShutdownWindowed ();
    else if (rhap_mode == rhap_fullscreen)
        ShutdownFullscreen ();

    rhap_mode = rhap_shutdown;

    if (vid.buffer)
    {
        free (vid.buffer);
        vid.buffer = NULL;
    }
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
    if (rhap_mode == rhap_windowed)
        SetPaletteWindowed (palette);
    else if (rhap_mode == rhap_fullscreen)
        SetPaletteFullscreen (palette);
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
    if (rhap_mode == rhap_windowed)
        BlitWindowed ();
    else if (rhap_mode == rhap_fullscreen)
        BlitFullscreen ();
}


/*
** SWimp_AppActivate
*/
void SWimp_AppActivate( qboolean active )
{
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
    ri.Cmd_ExecuteText (EXEC_NOW, va("vid_xpos %i", (int)r.origin.x+1));
    ri.Cmd_ExecuteText (EXEC_NOW, va("vid_ypos %i", (int)r.origin.y+1));
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
    {0xf703, K_RIGHTARROW},
	{0xf702, K_LEFTARROW},
	{0xf700, K_UPARROW},
	{0xf701, K_DOWNARROW},

	{0xf704, K_F1},
	{0xf705, K_F2},
	{0xf706, K_F3},
	{0xf707, K_F4},
	{0xf708, K_F5},
	{0xf709, K_F6},
	{0xf70a, K_F7},
	{0xf70b, K_F8},
	{0xf70c, K_F9},
	{0xf70d, K_F10},
	{0xf70e, K_F11},
	{0xf70f, K_F12},

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
    Key_Event (K_MOUSE1, true, 0);
}
- (void)mouseUp:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE1, false, 0);
}
- (void)rightMouseDown:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE2, true, 0);
}
- (void)rightMouseUp:(NSEvent *)theEvent
{
    Key_Event (K_MOUSE2, false, 0);
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

    ch = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
// check for non-ascii first
   for (km=keymaps;km->source!=-1;km++)
       if (ch == km->source)
       {
           Key_Event (km->dest, true, 0);
           return;
       }

    if (ch >= 'A' && ch <= 'Z')
        ch += 'a' - 'A';
    if (ch>=256)
        return;

    Key_Event (ch, true, 0);
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
                    Key_Event (km->dest, true, 0);
                else
                    Key_Event (km->dest, false, 0);
            }

    }

        oldflags = newflags;
}


- (void)keyUp:(NSEvent *)theEvent
{
    int	ch;
    keymap_t	*km;

    ch = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

	// check for non-ascii first
   for (km=keymaps;km->source!=-1;km++)
      if (ch == km->source)
      {
          Key_Event (km->dest, false, 0);
          return;
      }

    if (ch >= 'A' && ch <= 'Z')
        ch += 'a' - 'A';
    if (ch>=256)
        return;
    Key_Event (ch, false, 0);
}

@end


