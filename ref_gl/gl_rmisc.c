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
// r_misc.c

#include "gl_local.h"

/*
==================
R_InitParticleTexture
==================
*/
byte	dottexture[8][8] =
{
	{0,0,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0},
	{0,1,1,1,1,0,0,0},
	{0,1,1,1,1,0,0,0},
	{0,0,1,1,0,0,0,0},
	{0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0},
};

void R_InitParticleTexture (void)
{
	int		x,y;
	byte	data[8][8][4];

	//
	// particle texture
	//
	for (x=0 ; x<8 ; x++)
	{
		for (y=0 ; y<8 ; y++)
		{
			data[y][x][0] = 255;
			data[y][x][1] = 255;
			data[y][x][2] = 255;
			data[y][x][3] = dottexture[x][y]*255;
		}
	}
	r_particletexture = GL_LoadPic ("***particle***", (byte *)data, 8, 8, it_sprite, 32);

	//
	// also use this for bad textures, but without alpha
	//
	for (x=0 ; x<8 ; x++)
	{
		for (y=0 ; y<8 ; y++)
		{
			data[y][x][0] = dottexture[x&3][y&3]*255;
			data[y][x][1] = 0; // dottexture[x&3][y&3]*255;
			data[y][x][2] = 0; //dottexture[x&3][y&3]*255;
			data[y][x][3] = 255;
		}
	}
	r_notexture = GL_LoadPic ("***r_notexture***", (byte *)data, 8, 8, it_wall, 32);
}


/* 
============================================================================== 
 
						SCREEN SHOTS 
 
============================================================================== 
*/ 

typedef struct _TargaHeader {
	unsigned char 	id_length, colormap_type, image_type;
	unsigned short	colormap_index, colormap_length;
	unsigned char	colormap_size;
	unsigned short	x_origin, y_origin, width, height;
	unsigned char	pixel_size, attributes;
} TargaHeader;


/* 
================== 
GL_ScreenShot_TGA
================== 
*/  
void GL_ScreenShot_TGA (qboolean silent) 
{
	byte		*buffer;
	char		picname[80]; 
	char		checkname[MAX_OSPATH];
	int			i, c, temp;
	FILE		*f;

	// create the scrnshots directory if it doesn't exist
	Com_sprintf (checkname, sizeof(checkname), "%s/scrnshot", ri.FS_Gamedir());
	Sys_Mkdir (checkname);

// 
// find a file name to save it to 
// 

	// Knightmare- changed screenshot filenames, up to 100 screenies
//	strcpy(picname,"quake00.tga");

	for (i=0; i<=999; i++) 
	{ 
	//	picname[5] = i/10 + '0'; 
	//	picname[6] = i%10 + '0'; 
		int ones, tens, hundreds;

		hundreds = i*0.01;
		tens = (i - hundreds*100)*0.1;
		ones = i - hundreds*100 - tens*10;
		Com_sprintf (picname, sizeof(picname), "quake2_%i%i%i.tga", hundreds, tens, ones);
		// end Knightmare
		Com_sprintf (checkname, sizeof(checkname), "%s/scrnshot/%s", ri.FS_Gamedir(), picname);
		f = fopen (checkname, "rb");
		if (!f)
			break;	// file doesn't exist
		fclose (f);
	} 
	if (i==1000) 
	{
		ri.Con_Printf (PRINT_ALL, "GL_ScreenShot_f: Couldn't create a file\n"); 
		return;
 	}


	buffer = malloc(vid.width*vid.height*3 + 18);
	memset (buffer, 0, 18);
	buffer[2] = 2;		// uncompressed type
	buffer[12] = vid.width&255;
	buffer[13] = vid.width>>8;
	buffer[14] = vid.height&255;
	buffer[15] = vid.height>>8;
	buffer[16] = 24;	// pixel size

	qglReadPixels (0, 0, vid.width, vid.height, GL_RGB, GL_UNSIGNED_BYTE, buffer+18 ); 

	// swap rgb to bgr
	c = 18+vid.width*vid.height*3;
	for (i=18 ; i<c ; i+=3)
	{
		temp = buffer[i];
		buffer[i] = buffer[i+2];
		buffer[i+2] = temp;
	}

	f = fopen (checkname, "wb");
	fwrite (buffer, 1, c, f);
	fclose (f);

	free (buffer);
	if (!silent)
		ri.Con_Printf (PRINT_ALL, "Wrote %s\n", picname);
} 


/* 
================== 
GL_ScreenShot_f
================== 
*/  
void GL_ScreenShot_f (void) 
{
	GL_ScreenShot_TGA (false);
}


/* 
================== 
GL_ScreenShot_Silent_f
================== 
*/  
void GL_ScreenShot_Silent_f (void) 
{
	GL_ScreenShot_TGA (true);
}


/*
** GL_Strings_f
*/
void GL_Strings_f( void )
{
	char		*extString, *extTok;
	unsigned	line = 0;

	ri.Con_Printf (PRINT_ALL, "GL_VENDOR: %s\n", gl_config.vendor_string );
	ri.Con_Printf (PRINT_ALL, "GL_RENDERER: %s\n", gl_config.renderer_string );
	ri.Con_Printf (PRINT_ALL, "GL_VERSION: %s\n", gl_config.version_string );
	ri.Con_Printf (PRINT_ALL, "GL_MAX_TEXTURE_SIZE: %i\n", gl_config.max_texsize );
//	ri.Con_Printf (PRINT_ALL, "GL_EXTENSIONS: %s\n", gl_config.extensions_string );
	// Knightmare- print extensions 2 to a line
	ri.Con_Printf (PRINT_ALL, "GL_EXTENSIONS: " );
	extString = (char *)gl_config.extensions_string;
	while (1)
	{
		extTok = COM_Parse(&extString);
		if (!extTok[0])
			break;
		line++;
		if ((line % 2) == 0)
			ri.Con_Printf (PRINT_ALL, "%s\n", extTok );
		else
			ri.Con_Printf (PRINT_ALL, "%s ", extTok );
	}
	if ((line % 2) != 0)
		ri.Con_Printf (PRINT_ALL, "\n" );
	// end Knightmare
}

/*
** GL_SetDefaultState
*/
void GL_SetDefaultState (void)
{
	qglClearColor (1,0, 0.5 , 0.5);
	qglCullFace(GL_FRONT);
	qglEnable(GL_TEXTURE_2D);

	qglEnable(GL_ALPHA_TEST);
	qglAlphaFunc(GL_GREATER, 0.666);

	qglDisable (GL_DEPTH_TEST);
	qglDisable (GL_CULL_FACE);
	qglDisable (GL_BLEND);

	qglColor4f (1,1,1,1);

	qglPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	qglShadeModel (GL_FLAT);

	GL_TextureMode (gl_texturemode->string);
//	GL_TextureAlphaMode (gl_texturealphamode->string);
//	GL_TextureSolidMode (gl_texturesolidmode->string);

	qglTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_filter_min);
	qglTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_filter_max);

	qglTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	qglTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	qglBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	GL_TexEnv( GL_REPLACE );

	if ( qglPointParameterfEXT )
	{
		float attenuations[3];

		attenuations[0] = gl_particle_att_a->value;
		attenuations[1] = gl_particle_att_b->value;
		attenuations[2] = gl_particle_att_c->value;

		qglEnable( GL_POINT_SMOOTH );
		qglPointParameterfEXT( GL_POINT_SIZE_MIN_EXT, gl_particle_min_size->value );
		qglPointParameterfEXT( GL_POINT_SIZE_MAX_EXT, gl_particle_max_size->value );
		qglPointParameterfvEXT( GL_DISTANCE_ATTENUATION_EXT, attenuations );
	}

	if ( qglColorTableEXT && gl_ext_palettedtexture->value )
	{
		qglEnable( GL_SHARED_TEXTURE_PALETTE_EXT );

		GL_SetTexturePalette( d_8to24table );
	}

	GL_UpdateSwapInterval();
}

void GL_UpdateSwapInterval( void )
{
	static qboolean registering;	// Knightmare added

	// Knightmare- don't swap interval if loading a map
	if (registering != registration_active)
		gl_swapinterval->modified = true;

	if ( gl_swapinterval->modified )
	{
		gl_swapinterval->modified = false;	// Knightmare added

		registering = registration_active;

		if ( !gl_state.stereo_enabled ) 
		{
#ifdef _WIN32
			if ( qwglSwapIntervalEXT )
				qwglSwapIntervalEXT( (registration_active) ? 0 : gl_swapinterval->value );	// Knightmare changed
			//	qwglSwapIntervalEXT( gl_swapinterval->value );
#endif
		}
	}
}

// Knightmare added
/*
=================
GL_PrintError
=================
*/
void GL_PrintError (int errorCode, char *funcName)
{
	switch (errorCode)
	{
	case GL_INVALID_ENUM:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_INVALID_ENUM\n", funcName);
		break;
	case GL_INVALID_VALUE:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_INVALID_VALUE\n", funcName);
		break;
	case GL_INVALID_OPERATION:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_INVALID_OPERATION\n", funcName);
		break;
	case GL_STACK_OVERFLOW:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_STACK_OVERFLOW\n", funcName);
		break;
	case GL_STACK_UNDERFLOW:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_STACK_UNDERFLOW\n", funcName);
		break;
	case GL_OUT_OF_MEMORY:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_OUT_OF_MEMORY\n", funcName);
		break;
	case GL_TABLE_TOO_LARGE:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL_TABLE_TOO_LARGE\n", funcName);
		break;
#ifdef GL_INVALID_FRAMEBUFFER_OPERATION_EXT
	case GL_INVALID_FRAMEBUFFER_OPERATION_EXT:
		VID_Printf (PRINT_DEVELOPER, "GL_INVALID_FRAMEBUFFER_OPERATION_EXT\n", funcName);
		break;
#endif
	default:
		ri.Con_Printf (PRINT_DEVELOPER, "%s: GL ERROR UNKNOWN (%i)\n", funcName, errorCode);
		break;
	}
}
// end Knightmare
