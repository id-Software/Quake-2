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
#define REF_OPENGL	1
#define REF_3DFX	2
#define REF_POWERVR	3
#define REF_VERITE	4

extern cvar_t *vid_ref;
extern cvar_t *vid_gamma;
static cvar_t *gl_driver;
//extern cvar_t *vid_fullscreen;
//extern cvar_t *scr_viewsize;
//static cvar_t *gl_mode;
//static cvar_t *gl_picmip;
//static cvar_t *gl_ext_palettedtexture;
//static cvar_t *gl_swapinterval;

static cvar_t *sw_mode;
static cvar_t *sw_stipplealpha;

extern void M_ForceMenuOff( void );
const char *Default_MenuKey( menuframework_s *m, int key );

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

static menulist_s		s_ref_list[2];
static menulist_s		s_mode_list[2];
static menulist_s  		s_fs_box[2];
static menuslider_s		s_screensize_slider[2];
static menuslider_s		s_brightness_slider[2];
static menulist_s  		s_stipple_box;
static menuslider_s		s_tq_slider;
static menulist_s  		s_paletted_texture_box;
static menulist_s  		s_npot_mipmap_box;	// Knightmare- non-power-of-2 texture option
static menulist_s		s_texfilter_box;
static menulist_s		s_aniso_box;
static menulist_s  		s_vsync_box;
static menulist_s		s_refresh_box;	// Knightmare- refresh rate option
//static menuaction_s	s_cancel_action[2];
static menuaction_s		s_apply_action[2];
static menuaction_s		s_defaults_action[2];

static void RefreshCallback( void *unused )
{
	s_ref_list[!s_current_menu_index].curvalue = s_ref_list[s_current_menu_index].curvalue;

	if ( s_ref_list[s_current_menu_index].curvalue == 0 )
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
	menuslider_s	*slider = ( menuslider_s * ) s;
	float			gamma;

	if ( s_current_menu_index == SOFTWARE_MENU )
		s_brightness_slider[1].curvalue = s_brightness_slider[0].curvalue;
	else
		s_brightness_slider[0].curvalue = s_brightness_slider[1].curvalue;

//	gamma = (0.8 - (slider->curvalue/10.0 - 0.5)) + 0.5;
	gamma = 1.3 - (slider->curvalue/20.0);
	Cvar_SetValue( "vid_gamma", gamma );
}

// Knightmare- callback for texture mode
static void TexFilterCallback( void *s )
{
	if (s_texfilter_box.curvalue == 1)
		Cvar_Set ("r_texturemode", "GL_LINEAR_MIPMAP_LINEAR");
	else // (s_texfilter_box.curvalue == 0)
		Cvar_Set ("r_texturemode", "GL_LINEAR_MIPMAP_NEAREST");
}

// Knightmare- anisotropic filtering
static void AnisoCallback( void *s )
{
	switch ((int)s_aniso_box.curvalue)
	{
		case 1: Cvar_SetValue ("gl_anisotropic", 2.0); break;
		case 2: Cvar_SetValue ("gl_anisotropic", 4.0); break;
		case 3: Cvar_SetValue ("gl_anisotropic", 8.0); break;
		case 4: Cvar_SetValue ("gl_anisotropic", 16.0); break;
		default:
		case 0: Cvar_SetValue ("gl_anisotropic", 0.0); break;
	}
}

// Knightmare- added callback for this
static void VSyncCallback( void *s )
{
	Cvar_SetValue ("gl_swapinterval", s_vsync_box.curvalue);
}

static void ResetDefaults( void *unused )
{
	VID_MenuInit();
}

static void ApplyChanges( void *unused )
{
	float	gamma;
	int		temp;

	/*
	** make values consistent
	*/
	s_fs_box[!s_current_menu_index].curvalue = s_fs_box[s_current_menu_index].curvalue;
	s_brightness_slider[!s_current_menu_index].curvalue = s_brightness_slider[s_current_menu_index].curvalue;
	s_ref_list[!s_current_menu_index].curvalue = s_ref_list[s_current_menu_index].curvalue;

	/*
	** invert sense so greater = brighter, and scale to a range of 0.5 to 1.3
	*/
//	gamma = (0.8 - (s_brightness_slider[s_current_menu_index].curvalue/10.0 - 0.5)) + 0.5;
	gamma = (1.3 - (s_brightness_slider[s_current_menu_index].curvalue/20.0));

	Cvar_SetValue ("vid_gamma", gamma);
	Cvar_SetValue ("sw_stipplealpha", s_stipple_box.curvalue);
	Cvar_SetValue ("vid_fullscreen", s_fs_box[s_current_menu_index].curvalue);
	Cvar_SetValue ("gl_picmip", 3 - s_tq_slider.curvalue);
	Cvar_SetValue ("gl_ext_palettedtexture", s_paletted_texture_box.curvalue);
	Cvar_SetValue ("gl_nonpoweroftwo_mipmaps", s_npot_mipmap_box.curvalue);	// Knightmare- non-power-of-2 texture option

	Cvar_SetValue ("gl_swapinterval", s_vsync_box.curvalue);

	temp = s_mode_list[SOFTWARE_MENU].curvalue;
	Cvar_SetValue ("sw_mode", (temp == 0) ? -1 : temp + 2);	// Knightmare- use offset of 2 because of hidden modes
	temp = s_mode_list[OPENGL_MENU].curvalue;
	Cvar_SetValue ("gl_mode", (temp == 0) ? -1 : temp + 2);	// Knightmare- use offset of 2 because of hidden modes

	// Knightmare- refesh rate option
	switch (s_refresh_box.curvalue)
	{
	case 9:
		Cvar_SetValue ("r_displayrefresh", 150);
		break;
	case 8:
		Cvar_SetValue ("r_displayrefresh", 120);
		break;
	case 7:
		Cvar_SetValue ("r_displayrefresh", 110);
		break;
	case 6:
		Cvar_SetValue ("r_displayrefresh", 100);
		break;
	case 5:
		Cvar_SetValue ("r_displayrefresh", 85);
		break;
	case 4:
		Cvar_SetValue ("r_displayrefresh", 75);
		break;
	case 3:
		Cvar_SetValue ("r_displayrefresh", 72);
		break;
	case 2:
		Cvar_SetValue ("r_displayrefresh", 70);
		break;
	case 1:
		Cvar_SetValue ("r_displayrefresh", 60);
		break;
	case 0:
	default:
		Cvar_SetValue ("r_displayrefresh", 0);
		break;
	}

	// Knightmare- texture filter mode
	if (s_texfilter_box.curvalue == 1)
		Cvar_Set ("r_texturemode", "GL_LINEAR_MIPMAP_LINEAR");
	else // (s_texfilter_box.curvalue == 0)
		Cvar_Set ("r_texturemode", "GL_LINEAR_MIPMAP_NEAREST");

	// Knightmare- anisotropic filtering
	switch ((int)s_aniso_box.curvalue)
	{
		case 1: Cvar_SetValue ("gl_anisotropic", 2.0); break;
		case 2: Cvar_SetValue ("gl_anisotropic", 4.0); break;
		case 3: Cvar_SetValue ("gl_anisotropic", 8.0); break;
		case 4: Cvar_SetValue ("gl_anisotropic", 16.0); break;
		default:
		case 0: Cvar_SetValue ("gl_anisotropic", 0.0); break;
	}

	switch ( s_ref_list[s_current_menu_index].curvalue )
	{
	case REF_SOFT:
		Cvar_Set( "vid_ref", "soft" );
		break;
	case REF_OPENGL:
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "opengl32" );
		break;
	case REF_3DFX:
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "3dfxgl" );
		break;
	case REF_POWERVR:
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "pvrgl" );
		break;
	case REF_VERITE:
		Cvar_Set( "vid_ref", "gl" );
		Cvar_Set( "gl_driver", "veritegl" );
		break;
	}

	/*
	** update appropriate stuff if we're running OpenGL and gamma
	** has been modified
	*/
	if ( stricmp( Cvar_VariableString("vid_ref"), "gl" ) == 0 )
	{
		if ( vid_gamma->modified )
		{
			vid_ref->modified = true;
			if ( stricmp( Cvar_VariableString("gl_driver"), "3dfxgl" ) == 0 )
			{
				char envbuffer[1024];
				float g;

				vid_ref->modified = true;

				g = 2.00 * ( 0.8 - ( Cvar_VariableValue("vid_gamma") - 0.5 ) ) + 1.0F;
				Com_sprintf( envbuffer, sizeof(envbuffer), "SSTV2_GAMMA=%f", g );
				putenv( envbuffer );
				Com_sprintf( envbuffer, sizeof(envbuffer), "SST_GAMMA=%f", g );
				putenv( envbuffer );

				vid_gamma->modified = false;
			}
		}

		if ( gl_driver->modified )
			vid_ref->modified = true;
	}

	M_ForceMenuOff();
}

// Knightmare- texture filter mode
int texfilter_box_setval (void)
{
	char *texmode = Cvar_VariableString ("r_texturemode");
	if (!Q_strcasecmp(texmode, "GL_LINEAR_MIPMAP_NEAREST"))
		return 0;
	else
		return 1;
}

// Knightmare- refresh rate option
int refresh_box_setval (void)
{
	int refreshVar = (int)Cvar_VariableValue ("r_displayrefresh");

	if (refreshVar == 150)
		return 9;
	else if (refreshVar == 120)
		return 8;
	else if (refreshVar == 110)
		return 7;
	else if (refreshVar == 100)
		return 6;
	else if (refreshVar == 85)
		return 5;
	else if (refreshVar == 75)
		return 4;
	else if (refreshVar == 72)
		return 3;
	else if (refreshVar == 70)
		return 2;
	else if (refreshVar == 60)
		return 1;
	else
		return 0;
}

// Knightmare- anisotropic filtering
static const char *aniso0_names[] =
{
	"not supported",
	0
};

static const char *aniso2_names[] =
{
	"off",
	"2x",
	0
};

static const char *aniso4_names[] =
{
	"off",
	"2x",
	"4x",
	0
};

static const char *aniso8_names[] =
{
	"off",
	"2x",
	"4x",
	"8x",
	0
};

static const char *aniso16_names[] =
{
	"off",
	"2x",
	"4x",
	"8x",
	"16x",
	0
};

static const char **GetAnisoNames ()
{
	float aniso_avail = Cvar_VariableValue("gl_anisotropic_avail");
	if (aniso_avail < 2.0)
		return aniso0_names;
	else if (aniso_avail < 4.0)
		return aniso2_names;
	else if (aniso_avail < 8.0)
		return aniso4_names;
	else if (aniso_avail < 16.0)
		return aniso8_names;
	else // >= 16.0
		return aniso16_names;
}

float GetAnisoCurValue ()
{
	float aniso_avail = Cvar_VariableValue("gl_anisotropic_avail");
	float anisoValue = ClampCvar (0, aniso_avail, Cvar_VariableValue("gl_anisotropic"));
	if (aniso_avail == 0) // not available
		return 0;
	if (anisoValue < 2.0)
		return 0;
	else if (anisoValue < 4.0)
		return 1;
	else if (anisoValue < 8.0)
		return 2;
	else if (anisoValue < 16.0)
		return 3;
	else // >= 16.0
		return 4;
}
// end Knightmare

/*
** VID_MenuInit
*/
void VID_MenuInit( void )
{
	static const char *yesno_names[] =
	{
		"no",
		"yes",
		0
	};
	static const char *refs[] =
	{
		"[software      ]",
		"[default OpenGL]",
		"[3Dfx OpenGL   ]",
		"[PowerVR OpenGL]",
//		"[Rendition OpenGL]",
		0
	};
	static const char *resolutions[] = 
	{
#include "../qcommon/vid_resolutions.h"
	};
	static const char *refreshrate_names[] = 
	{
		"[default]",
		"[60Hz   ]",
		"[70Hz   ]",
		"[72Hz   ]",
		"[75Hz   ]",
		"[85Hz   ]",
		"[100Hz  ]",
		"[110Hz  ]",
		"[120Hz  ]",
		"[150Hz  ]",
		0
	};
	static const char *filter_names[] =
	{
		"bilinear",
		"trilinear",
		0
	};

	int		i;
	float	temp;

	if ( !gl_driver )
		gl_driver = Cvar_Get( "gl_driver", "opengl32", 0 );
//	if ( !gl_picmip )
//		gl_picmip = Cvar_Get( "gl_picmip", "0", 0 );
//	if ( !gl_mode )
//		gl_mode = Cvar_Get( "gl_mode", "3", 0 );
//	if ( !sw_mode )
//		sw_mode = Cvar_Get( "sw_mode", "3", 0 );
//	if ( !gl_ext_palettedtexture )
//		gl_ext_palettedtexture = Cvar_Get( "gl_ext_palettedtexture", "1", CVAR_ARCHIVE );
//	if ( !gl_swapinterval )
//		gl_swapinterval = Cvar_Get( "gl_swapinterval", "0", CVAR_ARCHIVE );
//	if ( !sw_stipplealpha )
//		sw_stipplealpha = Cvar_Get( "sw_stipplealpha", "0", CVAR_ARCHIVE );

	temp = Cvar_VariableValue("sw_mode");
	s_mode_list[SOFTWARE_MENU].curvalue = (temp == -1) ? 0 : max(temp - 2, 1);	// Knightmare- use offset of 2 because of hidden modes
	temp = Cvar_VariableValue("gl_mode");
	s_mode_list[OPENGL_MENU].curvalue = (temp == -1) ? 0 : max(temp - 2, 1);	// Knightmare- use offset of 2 because of hidden modes

	if ( !scr_viewsize )
		scr_viewsize = Cvar_Get ("viewsize", "100", CVAR_ARCHIVE);

	s_screensize_slider[SOFTWARE_MENU].curvalue = Cvar_VariableValue("viewsize")/10;
	s_screensize_slider[OPENGL_MENU].curvalue = Cvar_VariableValue("viewsize")/10;

	if ( strcmp( Cvar_VariableString("vid_ref"), "soft" ) == 0 )
	{
		s_current_menu_index = SOFTWARE_MENU;
		s_ref_list[0].curvalue = s_ref_list[1].curvalue = REF_SOFT;
	}
	else if ( strcmp( Cvar_VariableString("vid_ref"), "gl" ) == 0 )
	{
		s_current_menu_index = OPENGL_MENU;
		if ( strcmp( Cvar_VariableString("gl_driver"), "3dfxgl" ) == 0 )
			s_ref_list[s_current_menu_index].curvalue = REF_3DFX;
		else if ( strcmp( Cvar_VariableString("gl_driver"), "pvrgl" ) == 0 )
			s_ref_list[s_current_menu_index].curvalue = REF_POWERVR;
		else if ( strcmp( Cvar_VariableString("gl_driver"), "opengl32" ) == 0 )
			s_ref_list[s_current_menu_index].curvalue = REF_OPENGL;
		else
//			s_ref_list[s_current_menu_index].curvalue = REF_VERITE;
			s_ref_list[s_current_menu_index].curvalue = REF_OPENGL;
	}

	s_software_menu.x = viddef.width * 0.50;
	s_software_menu.y = viddef.height * 0.50 - 58;
	s_software_menu.nitems = 0;
	s_opengl_menu.x = viddef.width * 0.50;
	s_opengl_menu.y = viddef.height * 0.50 - 58;
	s_opengl_menu.nitems = 0;

	for ( i = 0; i < 2; i++ )
	{
		s_ref_list[i].generic.type		= MTYPE_SPINCONTROL;
		s_ref_list[i].generic.name		= "graphics renderer";
		s_ref_list[i].generic.x			= 0;
		s_ref_list[i].generic.y			= 0;
		s_ref_list[i].generic.callback	= RefreshCallback;
		s_ref_list[i].itemnames			= refs;
		s_ref_list[i].generic.statusbar	= "changes video refresh";

		s_mode_list[i].generic.type			= MTYPE_SPINCONTROL;
		s_mode_list[i].generic.name			= "video mode";
		s_mode_list[i].generic.x			= 0;
		s_mode_list[i].generic.y			= 10;
		s_mode_list[i].itemnames			= resolutions;
		s_mode_list[i].generic.statusbar	= "changes screen resolution";

		s_fs_box[i].generic.type		= MTYPE_SPINCONTROL;
		s_fs_box[i].generic.x			= 0;
		s_fs_box[i].generic.y			= 20;
		s_fs_box[i].generic.name		= "fullscreen";
		s_fs_box[i].itemnames			= yesno_names;
		s_fs_box[i].curvalue			= Cvar_VariableValue("vid_fullscreen");
		s_fs_box[i].generic.statusbar	= "changes bettween fullscreen and windowed display";

		s_screensize_slider[i].generic.type		= MTYPE_SLIDER;
		s_screensize_slider[i].generic.x		= 0;
		s_screensize_slider[i].generic.y		= 30;
		s_screensize_slider[i].generic.name		= "screen size";
		s_screensize_slider[i].minvalue			= 3;
		s_screensize_slider[i].maxvalue			= 10;
		s_screensize_slider[i].generic.callback	= ScreenSizeCallback;
		s_screensize_slider[i].generic.statusbar = "changes visible screen size";

		s_brightness_slider[i].generic.type			= MTYPE_SLIDER;
		s_brightness_slider[i].generic.x			= 0;
		s_brightness_slider[i].generic.y			= 40;
		s_brightness_slider[i].generic.name			= "brightness";
		s_brightness_slider[i].generic.callback		= BrightnessCallback;
		s_brightness_slider[i].minvalue				= 0;	// 5
		s_brightness_slider[i].maxvalue				= 20;	// 13
	//	s_brightness_slider[i].curvalue				= (1.3 - Cvar_VariableValue("vid_gamma") + 0.5) * 10;
		s_brightness_slider[i].curvalue				= (1.3 - Cvar_VariableValue("vid_gamma")) * 20;
		s_brightness_slider[i].generic.statusbar	= "changes display brightness";

		s_defaults_action[i].generic.type		= MTYPE_ACTION;
		s_defaults_action[i].generic.name		= "reset to defaults";
		s_defaults_action[i].generic.x			= 0;
		s_defaults_action[i].generic.y			= 140;
		s_defaults_action[i].generic.callback	= ResetDefaults;
		s_defaults_action[i].generic.statusbar	= "resets all video settings to internal defaults";

		s_apply_action[i].generic.type		= MTYPE_ACTION;
		s_apply_action[i].generic.name		= "apply changes";
		s_apply_action[i].generic.x			= 0;
		s_apply_action[i].generic.y			= 150;
		s_apply_action[i].generic.callback	= ApplyChanges;
	}

	s_stipple_box.generic.type	= MTYPE_SPINCONTROL;
	s_stipple_box.generic.x		= 0;
	s_stipple_box.generic.y		= 60;
	s_stipple_box.generic.name	= "stipple alpha";
	s_stipple_box.curvalue		= Cvar_VariableValue("sw_stipplealpha");
	s_stipple_box.itemnames		= yesno_names;
	s_stipple_box.generic.statusbar	= "enables stipple drawing of trans surfaces";

	s_tq_slider.generic.type			= MTYPE_SLIDER;
	s_tq_slider.generic.x				= 0;
	s_tq_slider.generic.y				= 60;
	s_tq_slider.generic.name			= "texture quality";
	s_tq_slider.minvalue				= 0;
	s_tq_slider.maxvalue				= 3;
	s_tq_slider.curvalue				= 3-Cvar_VariableValue("gl_picmip");
	s_tq_slider.generic.statusbar		= "changes detail level of textures";

	s_paletted_texture_box.generic.type			= MTYPE_SPINCONTROL;
	s_paletted_texture_box.generic.x			= 0;
	s_paletted_texture_box.generic.y			= 70;
	s_paletted_texture_box.generic.name			= "8-bit textures";
	s_paletted_texture_box.itemnames			= yesno_names;
	s_paletted_texture_box.curvalue				= Cvar_VariableValue("gl_ext_palettedtexture");
	s_paletted_texture_box.generic.statusbar	= "enables rendering of textures in 8-bit form";

	// Knightmare- non-power-of-2 texture option
	s_npot_mipmap_box.generic.type		= MTYPE_SPINCONTROL;
	s_npot_mipmap_box.generic.x			= 0;
	s_npot_mipmap_box.generic.y			= 80;
	s_npot_mipmap_box.generic.name		= "non-power-of-2 mipmaps";
	s_npot_mipmap_box.itemnames			= yesno_names;
	s_npot_mipmap_box.curvalue			= Cvar_VariableValue("gl_nonpoweroftwo_mipmaps");
	s_npot_mipmap_box.generic.statusbar	= "enables non-power-of-2 mipmapped textures (requires driver support)";

	s_texfilter_box.generic.type		= MTYPE_SPINCONTROL;
	s_texfilter_box.generic.x			= 0;
	s_texfilter_box.generic.y			= 90;
	s_texfilter_box.generic.name		= "texture filter";
	s_texfilter_box.curvalue			= texfilter_box_setval();
	s_texfilter_box.itemnames			= filter_names;
	s_texfilter_box.generic.statusbar	= "changes texture filtering mode";
	s_texfilter_box.generic.callback	= TexFilterCallback;

	s_aniso_box.generic.type		= MTYPE_SPINCONTROL;
	s_aniso_box.generic.x			= 0;
	s_aniso_box.generic.y			= 100;
	s_aniso_box.generic.name		= "anisotropic filter";
	s_aniso_box.curvalue			= GetAnisoCurValue();
	s_aniso_box.itemnames			= GetAnisoNames();
	s_aniso_box.generic.statusbar	= "changes level of anisotropic mipmap filtering";
	s_aniso_box.generic.callback	= AnisoCallback;

	s_vsync_box.generic.type		= MTYPE_SPINCONTROL;
	s_vsync_box.generic.x			= 0;
	s_vsync_box.generic.y			= 110;
	s_vsync_box.generic.name		= "video sync";
	s_vsync_box.curvalue			= Cvar_VariableValue("gl_swapinterval");
	s_vsync_box.itemnames			= yesno_names;
	s_vsync_box.generic.statusbar	= "sync framerate with monitor refresh";
	s_vsync_box.generic.callback	= VSyncCallback;

	// Knightmare- refresh rate option
	s_refresh_box.generic.type			= MTYPE_SPINCONTROL;
	s_refresh_box.generic.x				= 0;
	s_refresh_box.generic.y				= 120;
	s_refresh_box.generic.name			= "refresh rate";
	s_refresh_box.curvalue				= refresh_box_setval();
	s_refresh_box.itemnames				= refreshrate_names;
	s_refresh_box.generic.statusbar		= "sets refresh rate for fullscreen modes";

	Menu_AddItem( &s_software_menu, ( void * ) &s_ref_list[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_mode_list[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_fs_box[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_screensize_slider[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_brightness_slider[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_stipple_box );

	Menu_AddItem( &s_opengl_menu, ( void * ) &s_ref_list[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_mode_list[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_fs_box[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_screensize_slider[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_brightness_slider[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_tq_slider );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_paletted_texture_box );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_npot_mipmap_box );	// Knightmare- non-power-of-2 texture option
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_texfilter_box );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_aniso_box );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_vsync_box );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_refresh_box );

	Menu_AddItem( &s_software_menu, ( void * ) &s_defaults_action[SOFTWARE_MENU] );
	Menu_AddItem( &s_software_menu, ( void * ) &s_apply_action[SOFTWARE_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_defaults_action[OPENGL_MENU] );
	Menu_AddItem( &s_opengl_menu, ( void * ) &s_apply_action[OPENGL_MENU] );

//	Menu_Center( &s_software_menu );
//	Menu_Center( &s_opengl_menu );
//	s_opengl_menu.x -= 8;
//	s_software_menu.x -= 8;
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
	return Default_MenuKey (s_current_menu, key);
}


