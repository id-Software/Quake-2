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
** RW_X11.C
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

#include <ctype.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <X11/extensions/XShm.h>
#include <X11/extensions/xf86dga.h>

#include "../ref_soft/r_local.h"
#include "../client/keys.h"
#include "../linux/rw_linux.h"

/*****************************************************************************/

static qboolean			doShm;
static Display			*dpy;
static Colormap			x_cmap;
static Window			win;
static GC				x_gc;
static Visual			*x_vis;
static XVisualInfo		*x_visinfo;
static int win_x, win_y;

#define KEY_MASK (KeyPressMask | KeyReleaseMask)
#define MOUSE_MASK (ButtonPressMask | ButtonReleaseMask | \
		    PointerMotionMask | ButtonMotionMask )
#define X_MASK (KEY_MASK | MOUSE_MASK | VisibilityChangeMask | StructureNotifyMask | ExposureMask )

static int				x_shmeventtype;
//static XShmSegmentInfo	x_shminfo;

static qboolean			oktodraw = false;
static qboolean			ignorefirst = false;
static qboolean			exposureflag = false;
static qboolean			X11_active = false;

int XShmQueryExtension(Display *);
int XShmGetEventBase(Display *);

int current_framebuffer;
static XImage			*x_framebuffer[2] = { 0, 0 };
static XShmSegmentInfo	x_shminfo[2];

int config_notify=0;
int config_notify_width;
int config_notify_height;
						      
typedef unsigned short PIXEL16;
typedef unsigned long PIXEL24;
static PIXEL16 st2d_8to16table[256];
static PIXEL24 st2d_8to24table[256];
static int shiftmask_fl=0;
static long r_shift,g_shift,b_shift;
static unsigned long r_mask,g_mask,b_mask;

void shiftmask_init(void)
{
    unsigned int x;
    r_mask=x_vis->red_mask;
    g_mask=x_vis->green_mask;
    b_mask=x_vis->blue_mask;
    for(r_shift=-8,x=1;x<r_mask;x=x<<1)r_shift++;
    for(g_shift=-8,x=1;x<g_mask;x=x<<1)g_shift++;
    for(b_shift=-8,x=1;x<b_mask;x=x<<1)b_shift++;
    shiftmask_fl=1;
}

PIXEL16 xlib_rgb16(int r,int g,int b)
{
    PIXEL16 p;
    if(shiftmask_fl==0) shiftmask_init();
    p=0;

    if(r_shift>0) {
        p=(r<<(r_shift))&r_mask;
    } else if(r_shift<0) {
        p=(r>>(-r_shift))&r_mask;
    } else p|=(r&r_mask);

    if(g_shift>0) {
        p|=(g<<(g_shift))&g_mask;
    } else if(g_shift<0) {
        p|=(g>>(-g_shift))&g_mask;
    } else p|=(g&g_mask);

    if(b_shift>0) {
        p|=(b<<(b_shift))&b_mask;
    } else if(b_shift<0) {
        p|=(b>>(-b_shift))&b_mask;
    } else p|=(b&b_mask);

    return p;
}

PIXEL24 xlib_rgb24(int r,int g,int b)
{
    PIXEL24 p;
    if(shiftmask_fl==0) shiftmask_init();
    p=0;

    if(r_shift>0) {
        p=(r<<(r_shift))&r_mask;
    } else if(r_shift<0) {
        p=(r>>(-r_shift))&r_mask;
    } else p|=(r&r_mask);

    if(g_shift>0) {
        p|=(g<<(g_shift))&g_mask;
    } else if(g_shift<0) {
        p|=(g>>(-g_shift))&g_mask;
    } else p|=(g&g_mask);

    if(b_shift>0) {
        p|=(b<<(b_shift))&b_mask;
    } else if(b_shift<0) {
        p|=(b>>(-b_shift))&b_mask;
    } else p|=(b&b_mask);

    return p;
}


void st2_fixup( XImage *framebuf, int x, int y, int width, int height)
{
	int xi,yi;
	unsigned char *src;
	PIXEL16 *dest;
	register int count, n;

	if( (x<0)||(y<0) )return;

	for (yi = y; yi < (y+height); yi++) {
		src = &framebuf->data [yi * framebuf->bytes_per_line];

		// Duff's Device
		count = width;
		n = (count + 7) / 8;
		dest = ((PIXEL16 *)src) + x+width - 1;
		src += x+width - 1;

		switch (count % 8) {
		case 0:	do {	*dest-- = st2d_8to16table[*src--];
		case 7:			*dest-- = st2d_8to16table[*src--];
		case 6:			*dest-- = st2d_8to16table[*src--];
		case 5:			*dest-- = st2d_8to16table[*src--];
		case 4:			*dest-- = st2d_8to16table[*src--];
		case 3:			*dest-- = st2d_8to16table[*src--];
		case 2:			*dest-- = st2d_8to16table[*src--];
		case 1:			*dest-- = st2d_8to16table[*src--];
				} while (--n > 0);
		}

//		for(xi = (x+width-1); xi >= x; xi--) {
//			dest[xi] = st2d_8to16table[src[xi]];
//		}
	}
}

void st3_fixup( XImage *framebuf, int x, int y, int width, int height)
{
	int xi,yi;
	unsigned char *src;
	PIXEL24 *dest;
	register int count, n;

	if( (x<0)||(y<0) )return;

	for (yi = y; yi < (y+height); yi++) {
		src = &framebuf->data [yi * framebuf->bytes_per_line];

		// Duff's Device
		count = width;
		n = (count + 7) / 8;
		dest = ((PIXEL24 *)src) + x+width - 1;
		src += x+width - 1;

		switch (count % 8) {
		case 0:	do {	*dest-- = st2d_8to24table[*src--];
		case 7:			*dest-- = st2d_8to24table[*src--];
		case 6:			*dest-- = st2d_8to24table[*src--];
		case 5:			*dest-- = st2d_8to24table[*src--];
		case 4:			*dest-- = st2d_8to24table[*src--];
		case 3:			*dest-- = st2d_8to24table[*src--];
		case 2:			*dest-- = st2d_8to24table[*src--];
		case 1:			*dest-- = st2d_8to24table[*src--];
				} while (--n > 0);
		}

//		for(xi = (x+width-1); xi >= x; xi--) {
//			dest[xi] = st2d_8to16table[src[xi]];
//		}
	}
}



// Console variables that we need to access from this module

/*****************************************************************************/
/* MOUSE                                                                     */
/*****************************************************************************/

// this is inside the renderer shared lib, so these are called from vid_so

static qboolean	mouse_avail;
static int		mouse_buttonstate;
static int		mouse_oldbuttonstate;
static int		old_mouse_x, old_mouse_y;
static int		mx, my;

static qboolean mouse_active = false;
static qboolean dgamouse = false;

static cvar_t	*m_filter;
static cvar_t	*in_mouse;
static cvar_t	*in_dgamouse;

static cvar_t	*vid_xpos;			// X coordinate of window position
static cvar_t	*vid_ypos;			// Y coordinate of window position

static qboolean	mlooking;

// state struct passed in Init
static in_state_t	*in_state;

static cvar_t *sensitivity;
static cvar_t *lookstrafe;
static cvar_t *m_side;
static cvar_t *m_yaw;
static cvar_t *m_pitch;
static cvar_t *m_forward;
static cvar_t *freelook;

static void Force_CenterView_f (void)
{
	in_state->viewangles[PITCH] = 0;
}

static void RW_IN_MLookDown (void) 
{ 
	mlooking = true; 
}

static void RW_IN_MLookUp (void) 
{
	mlooking = false;
	in_state->IN_CenterView_fp ();
}

void RW_IN_Init(in_state_t *in_state_p)
{
	int mtype;
	int i;

	in_state = in_state_p;

	// mouse variables
	m_filter = ri.Cvar_Get ("m_filter", "0", 0);
    in_mouse = ri.Cvar_Get ("in_mouse", "0", CVAR_ARCHIVE);
    in_dgamouse = ri.Cvar_Get ("in_dgamouse", "1", CVAR_ARCHIVE);
	freelook = ri.Cvar_Get( "freelook", "0", 0 );
	lookstrafe = ri.Cvar_Get ("lookstrafe", "0", 0);
	sensitivity = ri.Cvar_Get ("sensitivity", "3", 0);
	m_pitch = ri.Cvar_Get ("m_pitch", "0.022", 0);
	m_yaw = ri.Cvar_Get ("m_yaw", "0.022", 0);
	m_forward = ri.Cvar_Get ("m_forward", "1", 0);
	m_side = ri.Cvar_Get ("m_side", "0.8", 0);

	ri.Cmd_AddCommand ("+mlook", RW_IN_MLookDown);
	ri.Cmd_AddCommand ("-mlook", RW_IN_MLookUp);

	ri.Cmd_AddCommand ("force_centerview", Force_CenterView_f);

	mouse_avail = true;
}

void RW_IN_Shutdown(void)
{
	mouse_avail = false;
}

/*
===========
IN_Commands
===========
*/
void RW_IN_Commands (void)
{
	int i;
   
	if (!mouse_avail) 
		return;
   
	for (i=0 ; i<3 ; i++) {
		if ( (mouse_buttonstate & (1<<i)) && !(mouse_oldbuttonstate & (1<<i)) )
			in_state->Key_Event_fp (K_MOUSE1 + i, true);

		if ( !(mouse_buttonstate & (1<<i)) && (mouse_oldbuttonstate & (1<<i)) )
			in_state->Key_Event_fp (K_MOUSE1 + i, false);
	}
	mouse_oldbuttonstate = mouse_buttonstate;
}

/*
===========
IN_Move
===========
*/
void RW_IN_Move (usercmd_t *cmd)
{
	if (!mouse_avail)
		return;
   
	if (m_filter->value)
	{
		mx = (mx + old_mouse_x) * 0.5;
		my = (my + old_mouse_y) * 0.5;
	}

	old_mouse_x = mx;
	old_mouse_y = my;

	mx *= sensitivity->value;
	my *= sensitivity->value;

// add mouse X/Y movement to cmd
	if ( (*in_state->in_strafe_state & 1) || 
		(lookstrafe->value && mlooking ))
		cmd->sidemove += m_side->value * mx;
	else
		in_state->viewangles[YAW] -= m_yaw->value * mx;

	if ( (mlooking || freelook->value) && 
		!(*in_state->in_strafe_state & 1))
	{
		in_state->viewangles[PITCH] += m_pitch->value * my;
	}
	else
	{
		cmd->forwardmove -= m_forward->value * my;
	}
	mx = my = 0;
}

// ========================================================================
// makes a null cursor
// ========================================================================

static Cursor CreateNullCursor(Display *display, Window root)
{
    Pixmap cursormask; 
    XGCValues xgc;
    GC gc;
    XColor dummycolour;
    Cursor cursor;

    cursormask = XCreatePixmap(display, root, 1, 1, 1/*depth*/);
    xgc.function = GXclear;
    gc =  XCreateGC(display, cursormask, GCFunction, &xgc);
    XFillRectangle(display, cursormask, gc, 0, 0, 1, 1);
    dummycolour.pixel = 0;
    dummycolour.red = 0;
    dummycolour.flags = 04;
    cursor = XCreatePixmapCursor(display, cursormask, cursormask,
          &dummycolour,&dummycolour, 0,0);
    XFreePixmap(display,cursormask);
    XFreeGC(display,gc);
    return cursor;
}

static void install_grabs(void)
{

// inviso cursor
	XDefineCursor(dpy, win, CreateNullCursor(dpy, win));

	XGrabPointer(dpy, win,
				 True,
				 0,
				 GrabModeAsync, GrabModeAsync,
				 win,
				 None,
				 CurrentTime);

	if (in_dgamouse->value) {
		int MajorVersion, MinorVersion;

		if (!XF86DGAQueryVersion(dpy, &MajorVersion, &MinorVersion)) { 
			// unable to query, probalby not supported
			ri.Con_Printf( PRINT_ALL, "Failed to detect XF86DGA Mouse\n" );
			ri.Cvar_Set( "in_dgamouse", "0" );
		} else {
			dgamouse = true;
			XF86DGADirectVideo(dpy, DefaultScreen(dpy), XF86DGADirectMouse);
			XWarpPointer(dpy, None, win, 0, 0, 0, 0, 0, 0);
		}
	} else
		XWarpPointer(dpy, None, win, 0, 0, 0, 0, vid.width / 2, vid.height / 2);

	XGrabKeyboard(dpy, win,
				  False,
				  GrabModeAsync, GrabModeAsync,
				  CurrentTime);

	mouse_active = true;

	ignorefirst = true;

//	XSync(dpy, True);
}

static void uninstall_grabs(void)
{
	if (!dpy || !win)
		return;

	if (dgamouse) {
		dgamouse = false;
		XF86DGADirectVideo(dpy, DefaultScreen(dpy), 0);
	}

	XUngrabPointer(dpy, CurrentTime);
	XUngrabKeyboard(dpy, CurrentTime);

// inviso cursor
	XUndefineCursor(dpy, win);

	mouse_active = false;
}

static void IN_DeactivateMouse( void ) 
{
	if (!mouse_avail || !dpy || !win)
		return;

	if (mouse_active) {
		uninstall_grabs();
		mouse_active = false;
	}
}

static void IN_ActivateMouse( void ) 
{
	if (!mouse_avail || !dpy || !win)
		return;

	if (!mouse_active) {
		mx = my = 0; // don't spazz
		install_grabs();
		mouse_active = true;
	}
}

void RW_IN_Frame (void)
{
}

void RW_IN_Activate(qboolean active)
{
	if (active)
		IN_ActivateMouse();
	else
		IN_DeactivateMouse ();
}

/*****************************************************************************/

void ResetFrameBuffer(void)
{
	int mem;
	int pwidth;

	if (x_framebuffer[0])
	{
		free(x_framebuffer[0]->data);
		free(x_framebuffer[0]);
	}

// alloc an extra line in case we want to wrap, and allocate the z-buffer
	pwidth = x_visinfo->depth / 8;
	if (pwidth == 3) pwidth = 4;
	mem = ((vid.width*pwidth+7)&~7) * vid.height;

	x_framebuffer[0] = XCreateImage(dpy,
		x_vis,
		x_visinfo->depth,
		ZPixmap,
		0,
		malloc(mem),
		vid.width, vid.height,
		32,
		0);

	if (!x_framebuffer[0])
		Sys_Error("VID: XCreateImage failed\n");

	vid.buffer = (byte*) (x_framebuffer[0]);
}

void ResetSharedFrameBuffers(void)
{
	int size;
	int key;
	int minsize = getpagesize();
	int frm;

	for (frm=0 ; frm<2 ; frm++)
	{
	// free up old frame buffer memory
		if (x_framebuffer[frm])
		{
			XShmDetach(dpy, &x_shminfo[frm]);
			free(x_framebuffer[frm]);
			shmdt(x_shminfo[frm].shmaddr);
		}

	// create the image
		x_framebuffer[frm] = XShmCreateImage(	dpy,
						x_vis,
						x_visinfo->depth,
						ZPixmap,
						0,
						&x_shminfo[frm],
						vid.width,
						vid.height );

	// grab shared memory

		size = x_framebuffer[frm]->bytes_per_line
			* x_framebuffer[frm]->height;
		if (size < minsize)
			Sys_Error("VID: Window must use at least %d bytes\n", minsize);

		key = random();
		x_shminfo[frm].shmid = shmget((key_t)key, size, IPC_CREAT|0777);
		if (x_shminfo[frm].shmid==-1)
			Sys_Error("VID: Could not get any shared memory\n");

		// attach to the shared memory segment
		x_shminfo[frm].shmaddr =
			(void *) shmat(x_shminfo[frm].shmid, 0, 0);

		ri.Con_Printf(PRINT_DEVELOPER, "MITSHM shared memory (id=%d, addr=0x%lx)\n", 
			x_shminfo[frm].shmid, (long) x_shminfo[frm].shmaddr);

		x_framebuffer[frm]->data = x_shminfo[frm].shmaddr;

	// get the X server to attach to it

		if (!XShmAttach(dpy, &x_shminfo[frm]))
			Sys_Error("VID: XShmAttach() failed\n");
		XSync(dpy, 0);
		shmctl(x_shminfo[frm].shmid, IPC_RMID, 0);
	}

}

// ========================================================================
// Tragic death handler
// ========================================================================

void TragicDeath(int signal_num)
{
//	XAutoRepeatOn(dpy);
	XCloseDisplay(dpy);
	Sys_Error("This death brought to you by the number %d\n", signal_num);
}

int XLateKey(XKeyEvent *ev)
{

	int key;
	char buf[64];
	KeySym keysym;

	key = 0;

	XLookupString(ev, buf, sizeof buf, &keysym, 0);

	switch(keysym)
	{
		case XK_KP_Page_Up:	 key = K_KP_PGUP; break;
		case XK_Page_Up:	 key = K_PGUP; break;

		case XK_KP_Page_Down: key = K_KP_PGDN; break;
		case XK_Page_Down:	 key = K_PGDN; break;

		case XK_KP_Home: key = K_KP_HOME; break;
		case XK_Home:	 key = K_HOME; break;

		case XK_KP_End:  key = K_KP_END; break;
		case XK_End:	 key = K_END; break;

		case XK_KP_Left: key = K_KP_LEFTARROW; break;
		case XK_Left:	 key = K_LEFTARROW; break;

		case XK_KP_Right: key = K_KP_RIGHTARROW; break;
		case XK_Right:	key = K_RIGHTARROW;		break;

		case XK_KP_Down: key = K_KP_DOWNARROW; break;
		case XK_Down:	 key = K_DOWNARROW; break;

		case XK_KP_Up:   key = K_KP_UPARROW; break;
		case XK_Up:		 key = K_UPARROW;	 break;

		case XK_Escape: key = K_ESCAPE;		break;

		case XK_KP_Enter: key = K_KP_ENTER;	break;
		case XK_Return: key = K_ENTER;		 break;

		case XK_Tab:		key = K_TAB;			 break;

		case XK_F1:		 key = K_F1;				break;

		case XK_F2:		 key = K_F2;				break;

		case XK_F3:		 key = K_F3;				break;

		case XK_F4:		 key = K_F4;				break;

		case XK_F5:		 key = K_F5;				break;

		case XK_F6:		 key = K_F6;				break;

		case XK_F7:		 key = K_F7;				break;

		case XK_F8:		 key = K_F8;				break;

		case XK_F9:		 key = K_F9;				break;

		case XK_F10:		key = K_F10;			 break;

		case XK_F11:		key = K_F11;			 break;

		case XK_F12:		key = K_F12;			 break;

		case XK_BackSpace: key = K_BACKSPACE; break;

		case XK_KP_Delete: key = K_KP_DEL; break;
		case XK_Delete: key = K_DEL; break;

		case XK_Pause:	key = K_PAUSE;		 break;

		case XK_Shift_L:
		case XK_Shift_R:	key = K_SHIFT;		break;

		case XK_Execute: 
		case XK_Control_L: 
		case XK_Control_R:	key = K_CTRL;		 break;

		case XK_Alt_L:	
		case XK_Meta_L: 
		case XK_Alt_R:	
		case XK_Meta_R: key = K_ALT;			break;

		case XK_KP_Begin: key = K_KP_5;	break;

		case XK_Insert:key = K_INS; break;
		case XK_KP_Insert: key = K_KP_INS; break;

		case XK_KP_Multiply: key = '*'; break;
		case XK_KP_Add:  key = K_KP_PLUS; break;
		case XK_KP_Subtract: key = K_KP_MINUS; break;
		case XK_KP_Divide: key = K_KP_SLASH; break;

#if 0
		case 0x021: key = '1';break;/* [!] */
		case 0x040: key = '2';break;/* [@] */
		case 0x023: key = '3';break;/* [#] */
		case 0x024: key = '4';break;/* [$] */
		case 0x025: key = '5';break;/* [%] */
		case 0x05e: key = '6';break;/* [^] */
		case 0x026: key = '7';break;/* [&] */
		case 0x02a: key = '8';break;/* [*] */
		case 0x028: key = '9';;break;/* [(] */
		case 0x029: key = '0';break;/* [)] */
		case 0x05f: key = '-';break;/* [_] */
		case 0x02b: key = '=';break;/* [+] */
		case 0x07c: key = '\'';break;/* [|] */
		case 0x07d: key = '[';break;/* [}] */
		case 0x07b: key = ']';break;/* [{] */
		case 0x022: key = '\'';break;/* ["] */
		case 0x03a: key = ';';break;/* [:] */
		case 0x03f: key = '/';break;/* [?] */
		case 0x03e: key = '.';break;/* [>] */
		case 0x03c: key = ',';break;/* [<] */
#endif

		default:
			key = *(unsigned char*)buf;
			if (key >= 'A' && key <= 'Z')
				key = key - 'A' + 'a';
			break;
	} 

	return key;
}

void HandleEvents(void)
{
	XEvent event;
	int b;
	qboolean dowarp = false;
	int mwx = vid.width/2;
	int mwy = vid.height/2;
   
	while (XPending(dpy)) {

		XNextEvent(dpy, &event);

		switch(event.type) {
		case KeyPress:
		case KeyRelease:
			if (in_state && in_state->Key_Event_fp)
				in_state->Key_Event_fp (XLateKey(&event.xkey), event.type == KeyPress);
			break;

		case MotionNotify:
			if (ignorefirst) {
				ignorefirst = false;
				break;
			}

			if (mouse_active) {
				if (dgamouse) {
					mx += (event.xmotion.x + win_x) * 2;
					my += (event.xmotion.y + win_y) * 2;
				} 
				else 
				{
					mx += ((int)event.xmotion.x - mwx) * 2;
					my += ((int)event.xmotion.y - mwy) * 2;
					mwx = event.xmotion.x;
					mwy = event.xmotion.y;

					if (mx || my)
						dowarp = true;
				}
			}
			break;


			break;

		case ButtonPress:
			b=-1;
			if (event.xbutton.button == 1)
				b = 0;
			else if (event.xbutton.button == 2)
				b = 2;
			else if (event.xbutton.button == 3)
				b = 1;
			if (b>=0)
				mouse_buttonstate |= 1<<b;
			break;

		case ButtonRelease:
			b=-1;
			if (event.xbutton.button == 1)
				b = 0;
			else if (event.xbutton.button == 2)
				b = 2;
			else if (event.xbutton.button == 3)
				b = 1;
			if (b>=0)
				mouse_buttonstate &= ~(1<<b);
			break;
		
		case CreateNotify :
			ri.Cvar_Set( "vid_xpos", va("%d", event.xcreatewindow.x));
			ri.Cvar_Set( "vid_ypos", va("%d", event.xcreatewindow.y));
			vid_xpos->modified = false;
			vid_ypos->modified = false;
			win_x = event.xcreatewindow.x;
			win_y = event.xcreatewindow.y;
			break;

		case ConfigureNotify :
			ri.Cvar_Set( "vid_xpos", va("%d", event.xcreatewindow.x));
			ri.Cvar_Set( "vid_ypos", va("%d", event.xcreatewindow.y));
			vid_xpos->modified = false;
			vid_ypos->modified = false;
			win_x = event.xconfigure.x;
			win_y = event.xconfigure.y;
			config_notify_width = event.xconfigure.width;
			config_notify_height = event.xconfigure.height;
			if (config_notify_width != vid.width ||
				config_notify_height != vid.height)
				XMoveResizeWindow(dpy, win, win_x, win_y, vid.width, vid.height);
			config_notify = 1;
			break;

		default:
			if (doShm && event.type == x_shmeventtype)
				oktodraw = true;
			if (event.type == Expose && !event.xexpose.count)
				exposureflag = true;
		}
	}
	   
	if (dowarp) {
		/* move the mouse to the window center again */
		XWarpPointer(dpy,None,win,0,0,0,0, vid.width/2,vid.height/2);
	}
}

/*****************************************************************************/

/*
** SWimp_Init
**
** This routine is responsible for initializing the implementation
** specific stuff in a software rendering subsystem.
*/
int SWimp_Init( void *hInstance, void *wndProc )
{

	vid_xpos = ri.Cvar_Get ("vid_xpos", "3", CVAR_ARCHIVE);
	vid_ypos = ri.Cvar_Get ("vid_ypos", "22", CVAR_ARCHIVE);

// open the display
	dpy = XOpenDisplay(0);
	if (!dpy)
	{
		if (getenv("DISPLAY"))
			Sys_Error("VID: Could not open display [%s]\n",
				getenv("DISPLAY"));
		else
			Sys_Error("VID: Could not open local display\n");
	}

// catch signals so i can turn on auto-repeat

	{
		struct sigaction sa;
		sigaction(SIGINT, 0, &sa);
		sa.sa_handler = TragicDeath;
		sigaction(SIGINT, &sa, 0);
		sigaction(SIGTERM, &sa, 0);
	}

	return true;
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
	int pnum, i;
	XVisualInfo template;
	int num_visuals;
	int template_mask;
	Window root;

	srandom(getpid());

	// free resources in use
	SWimp_Shutdown ();

	// let the sound and input subsystems know about the new window
	ri.Vid_NewWindow (vid.width, vid.height);

//	XAutoRepeatOff(dpy);

// for debugging only
	XSynchronize(dpy, True);

// check for command-line window size
	template_mask = 0;

#if 0
// specify a visual id
	if ((pnum=COM_CheckParm("-visualid")))
	{
		if (pnum >= com_argc-1)
			Sys_Error("VID: -visualid <id#>\n");
		template.visualid = Q_atoi(com_argv[pnum+1]);
		template_mask = VisualIDMask;
	}

// If not specified, use default visual
	else
#endif
	{
		int screen;
		screen = XDefaultScreen(dpy);
		template.visualid =
			XVisualIDFromVisual(XDefaultVisual(dpy, screen));
		template_mask = VisualIDMask;
	}

// pick a visual- warn if more than one was available
	x_visinfo = XGetVisualInfo(dpy, template_mask, &template, &num_visuals);
	if (num_visuals > 1)
	{
		printf("Found more than one visual id at depth %d:\n", template.depth);
		for (i=0 ; i<num_visuals ; i++)
			printf("	-visualid %d\n", (int)(x_visinfo[i].visualid));
	}
	else if (num_visuals == 0)
	{
		if (template_mask == VisualIDMask)
			Sys_Error("VID: Bad visual id %d\n", template.visualid);
		else
			Sys_Error("VID: No visuals at depth %d\n", template.depth);
	}

#if 0
	printf("Using visualid %d:\n", (int)(x_visinfo->visualid));
	printf("	screen %d\n", x_visinfo->screen);
	printf("	red_mask 0x%x\n", (int)(x_visinfo->red_mask));
	printf("	green_mask 0x%x\n", (int)(x_visinfo->green_mask));
	printf("	blue_mask 0x%x\n", (int)(x_visinfo->blue_mask));
	printf("	colormap_size %d\n", x_visinfo->colormap_size);
	printf("	bits_per_rgb %d\n", x_visinfo->bits_per_rgb);
#endif

	x_vis = x_visinfo->visual;
	root = XRootWindow(dpy, x_visinfo->screen);

// setup attributes for main window
	{
	   int attribmask = CWEventMask  | CWColormap | CWBorderPixel;
	   XSetWindowAttributes attribs;
	   Colormap tmpcmap;
	   
	   tmpcmap = XCreateColormap(dpy, root, x_vis, AllocNone);
	   
	   attribs.event_mask = X_MASK;
	   attribs.border_pixel = 0;
	   attribs.colormap = tmpcmap;

// create the main window
		win = XCreateWindow(dpy, root, (int)vid_xpos->value, (int)vid_ypos->value, 
			vid.width, vid.height, 0, x_visinfo->depth, InputOutput, x_vis, 
			attribmask, &attribs );
		XStoreName(dpy, win, "Quake II");

		if (x_visinfo->class != TrueColor)
			XFreeColormap(dpy, tmpcmap);
	}

	if (x_visinfo->depth == 8)
	{
	// create and upload the palette
		if (x_visinfo->class == PseudoColor)
		{
			x_cmap = XCreateColormap(dpy, win, x_vis, AllocAll);
			XSetWindowColormap(dpy, win, x_cmap);
		}

	}

// create the GC
	{
		XGCValues xgcvalues;
		int valuemask = GCGraphicsExposures;
		xgcvalues.graphics_exposures = False;
		x_gc = XCreateGC(dpy, win, valuemask, &xgcvalues );
	}

	XMapWindow(dpy, win);
	XMoveWindow(dpy, win, (int)vid_xpos->value, (int)vid_ypos->value);

// wait for first exposure event
	{
		XEvent event;
		exposureflag = false;
		do
		{
			HandleEvents();
		} while (!exposureflag);
	}
// now safe to draw

// even if MITSHM is available, make sure it's a local connection
	if (XShmQueryExtension(dpy))
	{
		char *displayname;
		doShm = true;
		displayname = (char *) getenv("DISPLAY");
		if (displayname)
		{
			char *d = displayname;
			while (*d && (*d != ':')) d++;
			if (*d) *d = 0;
			if (!(!strcasecmp(displayname, "unix") || !*displayname))
				doShm = false;
		}
	}

	if (doShm)
	{
		x_shmeventtype = XShmGetEventBase(dpy) + ShmCompletion;
		ResetSharedFrameBuffers();
	}
	else
		ResetFrameBuffer();

	current_framebuffer = 0;
	vid.rowbytes = x_framebuffer[0]->bytes_per_line;
	vid.buffer = x_framebuffer[0]->data;

//	XSynchronize(dpy, False);

	X11_active = true;

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
// if the window changes dimension, skip this frame
#if 0
	if (config_notify)
	{
		fprintf(stderr, "config notify\n");
		config_notify = 0;
		vid.width = config_notify_width & ~7;
		vid.height = config_notify_height;
		if (doShm)
			ResetSharedFrameBuffers();
		else
			ResetFrameBuffer();
		vid.rowbytes = x_framebuffer[0]->bytes_per_line;
		vid.buffer = x_framebuffer[current_framebuffer]->data;
		vid.recalc_refdef = 1;				// force a surface cache flush
		Con_CheckResize();
		Con_Clear_f();
		return;
	}
#endif

	if (doShm)
	{
		if (x_visinfo->depth == 16)
			st2_fixup( x_framebuffer[current_framebuffer], 0, 0, vid.width, vid.height);
		else if (x_visinfo->depth == 24)
			st3_fixup( x_framebuffer[current_framebuffer], 0, 0, vid.width, vid.height);
		if (!XShmPutImage(dpy, win, x_gc,
			x_framebuffer[current_framebuffer], 0, 0, 0, 0, vid.width, vid.height, True))
			Sys_Error("VID_Update: XShmPutImage failed\n");
		oktodraw = false;
		while (!oktodraw) 
			HandleEvents();
		current_framebuffer = !current_framebuffer;
		vid.buffer = x_framebuffer[current_framebuffer]->data;
		XSync(dpy, False);
	}
	else
	{
		if (x_visinfo->depth == 16)
			st2_fixup( x_framebuffer[current_framebuffer], 0, 0, vid.width, vid.height);
		else if (x_visinfo->depth == 24)
			st3_fixup( x_framebuffer[current_framebuffer], 0, 0, vid.width, vid.height);
		XPutImage(dpy, win, x_gc, x_framebuffer[0], 0, 0, 0, 0, vid.width, vid.height);
		XSync(dpy, False);
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
	int i;
	XColor colors[256];

	if (!X11_active)
		return;

    if ( !palette )
        palette = ( const unsigned char * ) sw_state.currentpalette;
 
	for(i=0;i<256;i++) {
		st2d_8to16table[i]= xlib_rgb16(palette[i*4], palette[i*4+1],palette[i*4+2]);
		st2d_8to24table[i]= xlib_rgb24(palette[i*4], palette[i*4+1],palette[i*4+2]);
	}

	if (x_visinfo->class == PseudoColor && x_visinfo->depth == 8)
	{
		for (i=0 ; i<256 ; i++)
		{
			colors[i].pixel = i;
			colors[i].flags = DoRed|DoGreen|DoBlue;
			colors[i].red = palette[i*4] * 257;
			colors[i].green = palette[i*4+1] * 257;
			colors[i].blue = palette[i*4+2] * 257;
		}
		XStoreColors(dpy, x_cmap, colors, 256);
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
	int i;

	if (!X11_active)
		return;

	if (doShm) {
		for (i = 0; i < 2; i++)
			if (x_framebuffer[i]) {
				XShmDetach(dpy, &x_shminfo[i]);
				free(x_framebuffer[i]);
				shmdt(x_shminfo[i].shmaddr);
				x_framebuffer[i] = NULL;
			}
	} else if (x_framebuffer[0]) {
		free(x_framebuffer[0]->data);
		free(x_framebuffer[0]);
		x_framebuffer[0] = NULL;
	}

	XDestroyWindow(	dpy, win );

//	XAutoRepeatOn(dpy);
//	XCloseDisplay(dpy);

	X11_active = false;
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

/*****************************************************************************/
/* KEYBOARD                                                                  */
/*****************************************************************************/

Key_Event_fp_t Key_Event_fp;

void KBD_Init(Key_Event_fp_t fp)
{
	Key_Event_fp = fp;
}

void KBD_Update(void)
{
// get events from x server
	HandleEvents();
}

void KBD_Close(void)
{
}


