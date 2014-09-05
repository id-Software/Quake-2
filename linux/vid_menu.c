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
#include "../client/client.h"
#include "../client/qmenu.h"

#define REF_SOFT	0
#define REF_SOFTX11	1
#define REF_MESA3D  2
#define REF_3DFXGL 3
#define REF_OPENGLX	4
#define REF_MESA3DGLX 5

extern cvar_t *vid_ref;
extern cvar_t *vid_fullscreen;
extern cvar_t *vid_gamma;
extern cvar_t *scr_viewsize;

static cvar_t *gl_mode;
static cvar_t *gl_driver;
static cvar_t *gl_picmip;
static cvar_t *gl_ext_palettedtexture;

static cvar_t *sw_mode;
static cvar_t *sw_stipplealpha;

static cvar_t *_windowed_mouse;

extern void M_ForceMenuOff( void );

/*
====================================================================

MENU INTERACTION

====================================================================
*/
#define SOFTWARE_MENU 0
#define OPENGL_MENU   1

static menuframework_s  s_software_menu;
static menuframework_s	s_opengl_menu;
static menuframework_s *s_current_menu;
static int				s_current_menu_index;

static menulist_s		s_mode_list[2];
static menulist_s		s_ref_list[2];
static menuslider_s		s_tq_slider;
static menuslider_s		s_screensize_slider[2];
static menuslider_s		s_brightness_slider[2];
static menulist_s  		s_fs_box[2];
static menulist_s  		s_stipple_box;
static menulist_s  		s_paletted_texture_box;
static menulist_s  		s_windowed_mouse;
static menuaction_s		s_apply_action[2];
static menuaction_s		s_defaults_action[2];

static void DriverCallback( void *unused )
{
	s_ref_list[!s_current_menu_index].curvalue = s_ref_list[s_current_menu_index].curvalue;

	if ( s_ref_list[s_current_menu_index].curvalue < 2 )
	{
		s_current_menu = &s_software_menu;
		s_current_menu_index = 0;
	}
	else
	{
		s_current_menu = &s_opengl_menu;
		s_current_menu_index = 1;
	}

}

static void ScreenSizeCallback( void *s )
{
	menuslider_s *slider = ( menuslider_s * ) s;

	Cvar_SetValue( "viewsize", slider->curvalue * 10 );
}

static void BrightnessCallback( void *s )
{
	menuslider_s *slider = ( menuslider_s * ) s;

	if ( s_current_menu_index == 0)
		s_brightness_slider[1].curvalue = s_brightness_slider[0].curvalue;
	else
		s_brightness_slider[0].curvalue = s_brightness_slider[1].curvalue;

	if ( stricmp( vid_ref->string, "soft" ) == 0 ||
		 stricmp( vid_ref->string, "softx" ) == 0 )
	{
		float gamma = ( 0.8 - ( slider->curvalue/10.0 - 0.5 ) ) + 0.5;

		Cvar_SetValue( "vid_gamma", gamma );
	}
}

static void ResetDefaults( void *unused )
{
	VID_MenuInit();
}

static void ApplyChanges( void *unused )
{
	float gamma;

	/*
	** make values consistent
	*/
	s_fs_box[!s_current_menu_index].curvalue = s_fs_box[s_current_menu_index].curvalue;
	s_brightness_slider[!s_current_menu_index].curvalue = s_brightness_slider[s_current_menu_index].curvalue;
	s_ref_list[!s_current_menu_index].curvalue = s_ref_list[s_current_menu_index].curvalue;

	/*
	** invert sense so greater = brighter, and scale to a range of 0.5 to 1.3
	*/
	gamma = ( 0.8 - ( s_brightness_slider[s_current_menu_index].curvalue/10.0 - 0.5 ) ) + 0.5;

	Cvar_SetValue( "vid_gamma", gamma );
	Cvar_SetValue( "sw_stipplealpha", s_stipple_box.curvalue );
	Cvar_SetValue( "gl_picmip", 3 - s_tq_slider.curvalue );
	Cvar_SetValue( "vid_fullscreen", s_fs_box[s_current_menu_index].curvalue );
	Cvar_SetValue( "gl_ext_palettedtexture", s_paletted_texture_box.curvalue );
	Cvar_SetValue( "sw_mode", s_mode_list[SOFTWARE_MENU].curvalue );
	Cvar_SetValue( "gl_mode", s_mode_list[OPENGL_MENU].curvalue );
	Cvar_SetValue( "_windowed_mouse", s_windowed_mouse.curvalue);

	switch ( s_ref_list[s_current_menu_index].curvalue )
	{
	case REF_SOFT:
		Cvar_Set( "vid_ref", "soft" );
		break;
	case REF_SOFTX11:
		Cvar_Set( "vid_ref", "softx" );
		break;

	case REF_MESA3D :
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "libMesaGL.so.2" );
		if (gl_driver->modified)
			vid_ref->modified = true;
		break;

	case REF_OPENGLX :
		Cvar_Set( "vid_ref", "glx" );
		Cvar_Set( "gl_driver", "libGL.so" );
		if (gl_driver->modified)
			vid_ref->modified = true;
		break;

	case REF_MESA3DGLX :
		Cvar_Set( "vid_ref", "glx" );
		Cvar_Set( "gl_driver", "libMesaGL.so.2" );
		if (gl_driver->modified)
			vid_ref->modified = true;
		break;

	case REF_3DFXGL :
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "lib3dfxgl.so" );
		if (gl_driver->modified)
			vid_ref->modified = true;
		break;
	}

#if 0
	/*
	** update appropriate stuff if we're running OpenGL and gamma
	** has been modified
	*/
	if ( stricmp( vid_ref->string, "gl" ) == 0 )
	{
		if ( vid_gamma->modified )
		{
			vid_ref->modified = true;
			if ( stricmp( gl_driver->string, "3dfxgl" ) == 0 )
			{
				char envbuffer[1024];
				float g;

				vid_ref->modified = true;

				g = 2.00 * ( 0.8 - ( vid_gamma->value - 0.5 ) ) + 1.0F;
				Com_sprintf( envbuffer, sizeof(envbuffer), "SST_GAMMA=%f", g );
				putenv( envbuffer );

				vid_gamma->modified = false;
			}
		}
	}
#endif

	M_ForceMenuOff();
}

/*
** VID_MenuInit
*/
void VID_MenuInit( void )
{
	static const char *resolutions[] = 
	{
		"[320 240  ]",
		"[400 300  ]",
		"[512 384  ]",
		"[640 480  ]",
		"[800 600  ]",
		"[960 720  ]",
		"[1024 768 ]",
		"[1152 864 ]",
		"[1280 1024]",
		"[1600 1200]",
		"[2048 1536]",
		0
	};
	static const char *refs[] =
	{
		"[software       ]",
		"[software X11   ]",
		"[Mesa 3-D 3DFX  ]",
		"[3DFXGL Miniport]",
		"[OpenGL glX     ]",
		"[Mesa 3-D glX   ]",
		0
	};
	static const char *yesno_names[] =
	{
		"no",
		"yes",
		0
	};
	int i;

	if ( !gl_driver )
		gl_driver = Cvar_Get( "gl_driver", "libMesaGL.so.2", 0 );
	if ( !gl_picmip )
		gl_picmip = Cvar_Get( "gl_picmip", "0", 0 );
	if ( !gl_mode )
		gl_mode = Cvar_Get( "gl_mode", "3", 0 );
	if ( !sw_mode )
		sw_mode = Cvar_Get( "sw_mode", "0", 0 );
	if ( !gl_ext_palettedtexture )
		gl_ext_palettedtexture = Cvar_Get( "gl_ext_palettedtexture", "1", CVAR_ARCHIVE );

	if ( !sw_stipplealpha )
		sw_stipplealpha = Cvar_Get( "sw_stipplealpha", "0", CVAR_ARCHIVE );

	if ( !_windowed_mouse)
        _windowed_mouse = Cvar_Get( "_windowed_mouse", "0", CVAR_ARCHIVE );

	s_mode_list[SOFTWARE_MENU].curvalue = sw_mode->value;
	s_mode_list[OPENGL_MENU].curvalue = gl_mode->value;

	if ( !scr_viewsize )
		scr_viewsize = Cvar_Get ("viewsize", "100", CVAR_ARCHIVE);

	s_screensize_slider[SOFTWARE_MENU].curvalue = scr_viewsize->value/10;
	s_screensize_slider[OPENGL_MENU].curvalue = scr_viewsize->value/10;

	if ( strcmp( vid_ref->string, "soft" ) == 0)
	{
		s_current_menu_index = SOFTWARE_MENU;
		s_ref_list[0].curvalue = s_ref_list[1].curvalue = REF_SOFT;
	}
	else if (strcmp( vid_ref->string, "softx" ) == 0 ) 
	{
		s_current_menu_index = SOFTWARE_MENU;
		s_ref_list[0].curvalue = s_ref_list[1].curvalue = REF_SOFTX11;
	}
	else if ( strcmp( vid_ref->string, "gl" ) == 0 )
	{
		s_current_menu_index = OPENGL_MENU;
		if ( strcmp( gl_driver->string, "lib3dfxgl.so" ) == 0 )
			s_ref_list[s_current_menu_index].curvalue = REF_3DFXGL;
		else
			s_ref_list[s_current_menu_index].curvalue = REF_MESA3D;
	}
	else if ( strcmp( vid_ref->string, "glx" ) == 0 )
	{
		s_current_menu_index = OPENGL_MENU;
		if ( strcmp( gl_driver->string, "libMesaGL.so.2" ) == 0 )
			s_ref_list[s_current_menu_index].curvalue = REF_MESA3DGLX;
		else
			s_ref_list[s_current_menu_index].curvalue = REF_OPENGLX;
	}

	s_software_menu.x = viddef.width * 0.50;
	s_software_menu.nitems = 0;
	s_opengl_menu.x = viddef.width * 0.50;
	s_opengl_menu.nitems = 0;

	for ( i = 0; i < 2; i++ )
	{
		s_ref_list[i].generic.type = MTYPE_SPINCONTROL;
		s_ref_list[i].generic.name = "driver";
		s_ref_list[i].generic.x = 0;
		s_ref_list[i].generic.y = 0;
		s_ref_list[i].generic.callback = DriverCallback;
		s_ref_list[i].itemnames = refs;

		s_mode_list[i].generic.type = MTYPE_SPINCONTROL;
		s_mode_list[i].generic.name = "video mode";
		s_mode_list[i].generic.x = 0;
		s_mode_list[i].generic.y = 10;
		s_mode_list[i].itemnames = resolutions;

		s_screensize_slider[i].generic.type	= MTYPE_SLIDER;
		s_screensize_slider[i].generic.x		= 0;
		s_screensize_slider[i].generic.y		= 20;
		s_screensize_slider[i].generic.name	= "screen size";
		s_screensize_slider[i].minvalue = 3;
		s_screensize_slider[i].maxvalue = 12;
		s_screensize_slider[i].generic.callback = ScreenSizeCallback;

		s_brightness_slider[i].generic.type	= MTYPE_SLIDER;
		s_brightness_slider[i].generic.x	= 0;
		s_brightness_slider[i].generic.y	= 30;
		s_brightness_slider[i].generic.name	= "brightness";
		s_brightness_slider[i].generic.callback = BrightnessCallback;
		s_brightness_slider[i].minvalue = 5;
		s_brightness_slider[i].maxvalue = 13;
		s_brightness_slider[i].curvalue = ( 1.3 - vid_gamma->value + 0.5 ) * 10;

		s_fs_box[i].generic.type = MTYPE_SPINCONTROL;
		s_fs_box[i].generic.x	= 0;
		s_fs_box[i].generic.y	= 40;
		s_fs_box[i].generic.name	= "fullscreen";
		s_fs_box[i].itemnames = yesno_names;
		s_fs_box[i].curvalue = vid_fullscreen->value;

		s_defaults_action[i].generic.type = MTYPE_ACTION;
		s_defaults_action[i].generic.name = "reset to default";
		s_defaults_action[i].generic.x    = 0;
		s_defaults_action[i].generic.y    = 90;
		s_defaults_action[i].generic.callback = ResetDefaults;

		s_apply_action[i].generic.type = MTYPE_ACTION;
		s_apply_action[i].generic.name = "apply";
		s_apply_action[i].generic.x    = 0;
		s_apply_action[i].generic.y    = 100;
		s_apply_action[i].generic.callback = ApplyChanges;
	}

	s_stipple_box.generic.type = MTYPE_SPINCONTROL;
	s_stipple_box.generic.x	= 0;
	s_stipple_box.generic.y	= 60;
	s_stipple_box.generic.name	= "stipple alpha";
	s_stipple_box.curvalue = sw_stipplealpha->value;
	s_stipple_box.itemnames = yesno_names;

	s_windowed_mouse.generic.type = MTYPE_SPINCONTROL;
	s_windowed_mouse.generic.x  = 0;
	s_windowed_mouse.generic.y  = 72;
	s_windowed_mouse.generic.name   = "windowed mouse";
	s_windowed_mouse.curvalue = _windowed_mouse->value;
	s_windowed_mouse.itemnames = yesno_names;

	s_tq_slider.generic.type	= MTYPE_SLIDER;
	s_tq_slider.generic.x		= 0;
	s_tq_slider.generic.y		= 60;
	s_tq_slider.generic.name	= "texture quality";
	s_tq_slider.minvalue = 0;
	s_tq_slider.maxvalue = 3;
	s_tq_slider.curvalue = 3-gl_picmip->value;

	s_paletted_texture_box.generic.type = MTYPE_SPINCONTROL;
	s_paletted_texture_box.generic.x	= 0;
	s_paletted_texture_box.generic.y	= 70;
	s_paletted_texture_box.generic.name	= "8-bit textures";
	s_paletted_texture_box.itemnames = yesno_names;
	s_paletted_texture_box.curvalue = gl_ext_palettedtexture->value;

	Menu_AddItem( &s_software_menu, ( void * ) &s_ref_list[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_mode_list[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_screensize_slider[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_brightness_slider[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_fs_box[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_stipple_box );
	Menu_AddItem( &s_software_menu, ( void * ) &s_windowed_mouse );

	Menu_AddItem( &s_opengl_menu, ( void * ) &s_ref_list[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_mode_list[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_screensize_slider[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_brightness_slider[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_fs_box[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_tq_slider );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_paletted_texture_box );

	Menu_AddItem( &s_software_menu, ( void * ) &s_defaults_action[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_apply_action[SOFTWARE_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_defaults_action[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_apply_action[OPENGL_MENU] );

	Menu_Center( &s_software_menu );
	Menu_Center( &s_opengl_menu );
	s_opengl_menu.x -= 8;
	s_software_menu.x -= 8;
}

/*
================
VID_MenuDraw
================
*/
void VID_MenuDraw (void)
{
	int w, h;

	if ( s_current_menu_index == 0 )
		s_current_menu = &s_software_menu;
	else
		s_current_menu = &s_opengl_menu;

	/*
	** draw the banner
	*/
	re.DrawGetPicSize( &w, &h, "m_banner_video" );
	re.DrawPic( viddef.width / 2 - w / 2, viddef.height /2 - 110, "m_banner_video" );

	/*
	** move cursor to a reasonable starting position
	*/
	Menu_AdjustCursor( s_current_menu, 1 );

	/*
	** draw the menu
	*/
	Menu_Draw( s_current_menu );
}

/*
================
VID_MenuKey
================
*/
const char *VID_MenuKey( int key )
{
	extern void M_PopMenu( void );

	menuframework_s *m = s_current_menu;
	static const char *sound = "misc/menu1.wav";

	switch ( key )
	{
	case K_ESCAPE:
		M_PopMenu();
		return NULL;
	case K_UPARROW:
		m->cursor--;
		Menu_AdjustCursor( m, -1 );
		break;
	case K_DOWNARROW:
		m->cursor++;
		Menu_AdjustCursor( m, 1 );
		break;
	case K_LEFTARROW:
		Menu_SlideItem( m, -1 );
		break;
	case K_RIGHTARROW:
		Menu_SlideItem( m, 1 );
		break;
	case K_ENTER:
		Menu_SelectItem( m );
		break;
	}

	return sound;
}


