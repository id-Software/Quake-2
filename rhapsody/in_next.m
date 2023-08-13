// in_next.m

#import <AppKit/AppKit.h>
#import <drivers/event_status_driver.h>
#include "../client/client.h"

float	mousex, mousey;

float	mouse_center_x = 160;
float	mouse_center_y = 100;

void PSsetmouse (float x, float y);
void PSshowcursor (void);
void PShidecursor (void);
void PScurrentmouse (int win, float *x, float *y);

extern	NSView	*vid_view_i;
extern	NSWindow	*vid_window_i;

qboolean	mlooking;
qboolean	mouseinitialized;
int		mouse_buttons;
int		mouse_oldbuttonstate;
int		mouseactive;
int		mousereset;
int		mx_accum, my_accum;
int		window_center_x, window_center_y;
int		old_mouse_x, old_mouse_y;

cvar_t	in_mouse = {"in_mouse", "0", CVAR_ARCHIVE};
cvar_t	m_filter = {"m_filter", "0", CVAR_ARCHIVE};
cvar_t	freelook = {"in_freelook", "0", CVAR_ARCHIVE};


/*
===========
IN_ActivateMouse

Called when the window gains focus or changes in some way
===========
*/
void IN_ActivateMouse (void)
{
    NSRect	r;
  
        if (!mouseinitialized)
                return;
        if (!in_mouse.value)
                return;

        r = [vid_window_i frame];
        window_center_x = r.size.width / 2;
        window_center_y = r.size.height / 2;

        if (!mouseactive)
            PShidecursor ();
 
        mouseactive = true;
        mousereset = true;
}


/*
===========
IN_DeactivateMouse

Called when the window loses focus
===========
*/
void IN_DeactivateMouse (void)
{
        if (!mouseinitialized)
                return;

    if (mouseactive)
        PSshowcursor ();

    mouseactive = false;
}


/*
===========
IN_StartupMouse
===========
*/
void IN_StartupMouse (void)
{
        if ( COM_CheckParm ("-nomouse") ) 
                return; 

        mouseinitialized = true;

        mouse_buttons = 3;

        IN_ActivateMouse ();
}

/*
===========
IN_MouseEvent
===========
*/
void IN_MouseEvent (int mstate)
{
        int		i;

        if (!mouseactive)
                return;

// perform button actions
        for (i=0 ; i<mouse_buttons ; i++)
        {
                if ( (mstate & (1<<i)) &&
                        !(mouse_oldbuttonstate & (1<<i)) )
                {
                        Key_Event (K_MOUSE1 + i, true);
                }

                if ( !(mstate & (1<<i)) &&
                        (mouse_oldbuttonstate & (1<<i)) )
                {
                                Key_Event (K_MOUSE1 + i, false);
                }
        }	

        mouse_oldbuttonstate = mstate;
}



/*
===========
IN_Accumulate
===========
*/
void IN_Accumulate (void)
{
        int		dx, dy;
        static int		old_x, old_y;

        if (!mouseinitialized)
                return;

        if (in_mouse.modified)
        {
            in_mouse.modified = false;
            IN_DeactivateMouse ();
            IN_ActivateMouse ();
        }

        if (!mouseactive)
                return;

//       [vid_view_i lockFocus];

        if (mousereset)
        {	// we haven't centered cursor yet
                mousereset = false;
        }
        else
        {
	 NSPoint	p;

            PScurrentmouse ([vid_window_i windowNumber], &mousex, &mousey);

		p.x = mousex;
		p.y = mousey;
		p = [vid_view_i convertPoint:p fromView: nil];

            mousex = p.x;
            mousey = p.y;
            
            dx = mousex - old_x;
            dy = old_y - mousey;

                if (!dx && !dy)
                        return;
                mx_accum += dx;
                my_accum += dy;
        }

        // force the mouse to the center, so there's room to move
        PSsetmouse (window_center_x, window_center_y);
        PScurrentmouse ([vid_window_i windowNumber], &mousex, &mousey);
//        PSsetmouse (window_center_x, window_center_y);
        old_x = window_center_x;
        old_y = window_center_y;

//        [vid_view_i unlockFocus];
}


/*
===========
IN_MouseMove
===========
*/
void IN_MouseMove (usercmd_t *cmd)
{
        int		mx, my;
	int		mouse_x, mouse_y;
       
        IN_Accumulate ();

        mx = mx_accum;
        my = my_accum;

        mx_accum = 0;
        my_accum = 0;

        if (m_filter.value)
        {
                mouse_x = (mx + old_mouse_x) * 0.5;
                mouse_y = (my + old_mouse_y) * 0.5;
        }
        else
        {
                mouse_x = mx;
                mouse_y = my;
        }

        old_mouse_x = mx;
        old_mouse_y = my;

        if (!mx && !my)
                return;

        if (!mouseactive)
                return;

        mouse_x *= sensitivity.value;
        mouse_y *= sensitivity.value;

// add mouse X/Y movement to cmd
        if ( (in_strafe.state & 1) || (lookstrafe.value && mlooking ))
                cmd->sidemove += m_side.value * mouse_x;
        else
                cl.viewangles[YAW] -= m_yaw.value * mouse_x;

        if ( (mlooking || freelook.value) && !(in_strafe.state & 1))
        {
                cl.viewangles[PITCH] += m_pitch.value * mouse_y;
                if (cl.viewangles[PITCH] > 80)
                        cl.viewangles[PITCH] = 80;
                if (cl.viewangles[PITCH] < -70)
                        cl.viewangles[PITCH] = -70;
        }
        else
        {
                cmd->forwardmove -= m_forward.value * mouse_y;
        }

}

void IN_ShowMouse (void)
{
    PSshowcursor ();
}

void IN_HideMouse (void)
{
    PShidecursor ();
}

NXEventHandle	eventhandle;
NXMouseScaling	oldscaling, newscaling;
NXMouseButton	oldbutton;

/*
 =============
 IN_Init
 =============
 */
void IN_Init (void)
{
    Cvar_RegisterVariable (&in_mouse);
    Cvar_RegisterVariable (&m_filter);
    Cvar_RegisterVariable (&freelook);

    Cmd_AddCommand ("showmouse", IN_ShowMouse);
    Cmd_AddCommand ("hidemouse", IN_HideMouse);
    
    IN_StartupMouse ();

    // open the event status driver
    eventhandle = NXOpenEventStatus();
    NXGetMouseScaling (eventhandle, &oldscaling);
    NXSetMouseScaling (eventhandle, &newscaling);
    oldbutton = NXMouseButtonEnabled (eventhandle);
    NXEnableMouseButton (eventhandle, 2);
}

/*
 =============
 IN_Shutdown
 =============
 */
void IN_Shutdown (void)
{
    IN_DeactivateMouse ();

    // put mouse scaling back the way it was
    NXSetMouseScaling (eventhandle, &oldscaling);
    NXEnableMouseButton (eventhandle, oldbutton);
    NXCloseEventStatus (eventhandle);
}

void IN_Move (usercmd_t *cmd)
{
    IN_MouseMove (cmd);
}

void IN_Commands (void)
{
}


/*
=========================================================================

VIEW CENTERING

=========================================================================
*/

void V_StopPitchDrift (void)
{
	cl.laststop = cl.time;
	cl.nodrift = true;
	cl.pitchvel = 0;
}
