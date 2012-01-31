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
  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdarg.h>

#include "../client/ref.h"

#define REF_VERSION     "SOFT 0.01"

// up / down
#define PITCH   0

// left / right
#define YAW             1

// fall over
#define ROLL    2


/*

  skins will be outline flood filled and mip mapped
  pics and sprites with alpha will be outline flood filled
  pic won't be mip mapped

  model skin
  sprite frame
  wall texture
  pic

*/

typedef enum 
{
	it_skin,
	it_sprite,
	it_wall,
	it_pic,
	it_sky
} imagetype_t;

typedef struct image_s
{
	char    name[MAX_QPATH];        // game path, including extension
	imagetype_t     type;
	int             width, height;
	qboolean        transparent;    // true if any 255 pixels in image
	int             registration_sequence;  // 0 = free
	byte		*pixels[4];				// mip levels
} image_t;


//===================================================================

typedef unsigned char pixel_t;

typedef struct vrect_s
{
	int                             x,y,width,height;
	struct vrect_s  *pnext;
} vrect_t;

typedef struct
{
	pixel_t                 *buffer;                // invisible buffer
	pixel_t                 *colormap;              // 256 * VID_GRADES size
	pixel_t                 *alphamap;              // 256 * 256 translucency map
	int                             rowbytes;               // may be > width if displayed in a window
									// can be negative for stupid dibs
	int						width;          
	int						height;
} viddef_t;

typedef enum
{
	rserr_ok,

	rserr_invalid_fullscreen,
	rserr_invalid_mode,

	rserr_unknown
} rserr_t;

extern viddef_t vid;

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct
{
	vrect_t         vrect;                          // subwindow in video for refresh
									// FIXME: not need vrect next field here?
	vrect_t         aliasvrect;                     // scaled Alias version
	int                     vrectright, vrectbottom;        // right & bottom screen coords
	int                     aliasvrectright, aliasvrectbottom;      // scaled Alias versions
	float           vrectrightedge;                 // rightmost right edge we care about,
										//  for use in edge list
	float           fvrectx, fvrecty;               // for floating-point compares
	float           fvrectx_adj, fvrecty_adj; // left and top edges, for clamping
	int                     vrect_x_adj_shift20;    // (vrect.x + 0.5 - epsilon) << 20
	int                     vrectright_adj_shift20; // (vrectright + 0.5 - epsilon) << 20
	float           fvrectright_adj, fvrectbottom_adj;
										// right and bottom edges, for clamping
	float           fvrectright;                    // rightmost edge, for Alias clamping
	float           fvrectbottom;                   // bottommost edge, for Alias clamping
	float           horizontalFieldOfView;  // at Z = 1.0, this many X is visible 
										// 2.0 = 90 degrees
	float           xOrigin;                        // should probably always be 0.5
	float           yOrigin;                        // between be around 0.3 to 0.5

	vec3_t          vieworg;
	vec3_t          viewangles;
	
	int                     ambientlight;
} oldrefdef_t;

extern oldrefdef_t      r_refdef;

#include "r_model.h"

#define CACHE_SIZE      32

/*
====================================================

  CONSTANTS

====================================================
*/

#define VID_CBITS       6
#define VID_GRADES      (1 << VID_CBITS)


// r_shared.h: general refresh-related stuff shared between the refresh and the
// driver


#define MAXVERTS        64              // max points in a surface polygon
#define MAXWORKINGVERTS (MAXVERTS+4)    // max points in an intermediate
										//  polygon (while processing)
// !!! if this is changed, it must be changed in d_ifacea.h too !!!
#define MAXHEIGHT       1200
#define MAXWIDTH        1600

#define INFINITE_DISTANCE       0x10000         // distance that's always guaranteed to
										//  be farther away than anything in
										//  the scene


// d_iface.h: interface header file for rasterization driver modules

#define WARP_WIDTH              320
#define WARP_HEIGHT             240

#define MAX_LBM_HEIGHT  480


#define PARTICLE_Z_CLIP 8.0

// !!! must be kept the same as in quakeasm.h !!!
#define TRANSPARENT_COLOR       0xFF


// !!! if this is changed, it must be changed in d_ifacea.h too !!!
#define TURB_TEX_SIZE   64              // base turbulent texture size

// !!! if this is changed, it must be changed in d_ifacea.h too !!!
#define CYCLE                   128             // turbulent cycle size

#define SCANBUFFERPAD           0x1000

#define DS_SPAN_LIST_END        -128

#define NUMSTACKEDGES           2000
#define MINEDGES                        NUMSTACKEDGES
#define NUMSTACKSURFACES        1000
#define MINSURFACES                     NUMSTACKSURFACES
#define MAXSPANS                        3000

// flags in finalvert_t.flags
#define ALIAS_LEFT_CLIP                         0x0001
#define ALIAS_TOP_CLIP                          0x0002
#define ALIAS_RIGHT_CLIP                        0x0004
#define ALIAS_BOTTOM_CLIP                       0x0008
#define ALIAS_Z_CLIP                            0x0010
#define ALIAS_XY_CLIP_MASK                      0x000F

#define SURFCACHE_SIZE_AT_320X240    1024*768

#define BMODEL_FULLY_CLIPPED    0x10 // value returned by R_BmodelCheckBBox ()
									 //  if bbox is trivially rejected

#define XCENTERING      (1.0 / 2.0)
#define YCENTERING      (1.0 / 2.0)

#define CLIP_EPSILON            0.001

#define BACKFACE_EPSILON        0.01

// !!! if this is changed, it must be changed in asm_draw.h too !!!
#define NEAR_CLIP       0.01


#define MAXALIASVERTS           2000    // TODO: tune this
#define ALIAS_Z_CLIP_PLANE      4

// turbulence stuff

#define AMP             8*0x10000
#define AMP2    3
#define SPEED   20


/*
====================================================

TYPES

====================================================
*/

typedef struct
{
	float   u, v;
	float   s, t;
	float   zi;
} emitpoint_t;

/*
** if you change this structure be sure to change the #defines
** listed after it!
*/
#define SMALL_FINALVERT 0

#if SMALL_FINALVERT

typedef struct finalvert_s {
	short           u, v, s, t;
	int             l;
	int             zi;
	int             flags;
	float   xyz[3];         // eye space
} finalvert_t;

#define FINALVERT_V0     0
#define FINALVERT_V1     2
#define FINALVERT_V2     4
#define FINALVERT_V3     6
#define FINALVERT_V4     8
#define FINALVERT_V5    12
#define FINALVERT_FLAGS 16
#define FINALVERT_X     20
#define FINALVERT_Y     24
#define FINALVERT_Z     28
#define FINALVERT_SIZE  32

#else

typedef struct finalvert_s {
	int             u, v, s, t;
	int             l;
	int             zi;
	int             flags;
	float   xyz[3];         // eye space
} finalvert_t;

#define FINALVERT_V0     0
#define FINALVERT_V1     4
#define FINALVERT_V2     8
#define FINALVERT_V3    12
#define FINALVERT_V4    16
#define FINALVERT_V5    20
#define FINALVERT_FLAGS 24
#define FINALVERT_X     28
#define FINALVERT_Y     32
#define FINALVERT_Z     36
#define FINALVERT_SIZE  40

#endif

typedef struct
{
	void                            *pskin;
	int                                     pskindesc;
	int                                     skinwidth;
	int                                     skinheight;
	dtriangle_t                     *ptriangles;
	finalvert_t                     *pfinalverts;
	int                                     numtriangles;
	int                                     drawtype;
	int                                     seamfixupX16;
	qboolean                        do_vis_thresh;
	int                                     vis_thresh;
} affinetridesc_t;

typedef struct
{
	byte            *surfdat;       // destination for generated surface
	int                     rowbytes;       // destination logical width in bytes
	msurface_t      *surf;          // description for surface to generate
	fixed8_t        lightadj[MAXLIGHTMAPS];
							// adjust for lightmap levels for dynamic lighting
	image_t			*image;
	int                     surfmip;        // mipmapped ratio of surface texels / world pixels
	int                     surfwidth;      // in mipmapped texels
	int                     surfheight;     // in mipmapped texels
} drawsurf_t;



typedef struct {
	int                     ambientlight;
	int                     shadelight;
	float           *plightvec;
} alight_t;

// clipped bmodel edges

typedef struct bedge_s
{
	mvertex_t               *v[2];
	struct bedge_s  *pnext;
} bedge_t;


// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct clipplane_s
{
	vec3_t          normal;
	float           dist;
	struct          clipplane_s     *next;
	byte            leftedge;
	byte            rightedge;
	byte            reserved[2];
} clipplane_t;


typedef struct surfcache_s
{
	struct surfcache_s      *next;
	struct surfcache_s      **owner;                // NULL is an empty chunk of memory
	int                                     lightadj[MAXLIGHTMAPS]; // checked for strobe flush
	int                                     dlight;
	int                                     size;           // including header
	unsigned                        width;
	unsigned                        height;         // DEBUG only needed for debug
	float                           mipscale;
	image_t							*image;
	byte                            data[4];        // width*height elements
} surfcache_t;

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct espan_s
{
	int                             u, v, count;
	struct espan_s  *pnext;
} espan_t;

// used by the polygon drawer (R_POLY.C) and sprite setup code (R_SPRITE.C)
typedef struct
{
	int                     nump;
	emitpoint_t     *pverts;
	byte            *pixels;                        // image
	int                     pixel_width;            // image width
	int         pixel_height;       // image height
	vec3_t          vup, vright, vpn;       // in worldspace, for plane eq
	float       dist;
	float       s_offset, t_offset;
	float       viewer_position[3];
	void       (*drawspanlet)( void );
	int         stipple_parity;
} polydesc_t;

// FIXME: compress, make a union if that will help
// insubmodel is only 1, flags is fewer than 32, spanstate could be a byte
typedef struct surf_s
{
	struct surf_s   *next;                  // active surface stack in r_edge.c
	struct surf_s   *prev;                  // used in r_edge.c for active surf stack
	struct espan_s  *spans;                 // pointer to linked list of spans to draw
	int                     key;                            // sorting key (BSP order)
	int                     last_u;                         // set during tracing
	int                     spanstate;                      // 0 = not in span
									// 1 = in span
									// -1 = in inverted span (end before
									//  start)
	int                     flags;                          // currentface flags
	msurface_t      *msurf;
	entity_t        *entity;
	float           nearzi;                         // nearest 1/z on surface, for mipmapping
	qboolean        insubmodel;
	float           d_ziorigin, d_zistepu, d_zistepv;

	int                     pad[2];                         // to 64 bytes
} surf_t;

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct edge_s
{
	fixed16_t               u;
	fixed16_t               u_step;
	struct edge_s   *prev, *next;
	unsigned short  surfs[2];
	struct edge_s   *nextremove;
	float                   nearzi;
	medge_t                 *owner;
} edge_t;


/*
====================================================

VARS

====================================================
*/

extern int              d_spanpixcount;
extern int              r_framecount;           // sequence # of current frame since Quake
									//  started
extern float    r_aliasuvscale;         // scale-up factor for screen u and v
									//  on Alias vertices passed to driver
extern qboolean r_dowarp;

extern affinetridesc_t  r_affinetridesc;

extern vec3_t   r_pright, r_pup, r_ppn;

void D_DrawSurfaces (void);
void R_DrawParticle( void );
void D_ViewChanged (void);
void D_WarpScreen (void);
void R_PolysetUpdateTables (void);

extern void *acolormap; // FIXME: should go away

//=======================================================================//

// callbacks to Quake

extern drawsurf_t       r_drawsurf;

void R_DrawSurface (void);

extern int              c_surf;

extern byte             r_warpbuffer[WARP_WIDTH * WARP_HEIGHT];




extern float    scale_for_mip;

extern qboolean         d_roverwrapped;
extern surfcache_t      *sc_rover;
extern surfcache_t      *d_initial_rover;

extern float    d_sdivzstepu, d_tdivzstepu, d_zistepu;
extern float    d_sdivzstepv, d_tdivzstepv, d_zistepv;
extern float    d_sdivzorigin, d_tdivzorigin, d_ziorigin;

extern  fixed16_t       sadjust, tadjust;
extern  fixed16_t       bbextents, bbextentt;


void D_DrawSpans16 (espan_t *pspans);
void D_DrawZSpans (espan_t *pspans);
void Turbulent8 (espan_t *pspan);
void NonTurbulent8 (espan_t *pspan);	//PGM

surfcache_t     *D_CacheSurface (msurface_t *surface, int miplevel);

extern int      d_vrectx, d_vrecty, d_vrectright_particle, d_vrectbottom_particle;

extern int      d_pix_min, d_pix_max, d_pix_shift;

extern pixel_t  *d_viewbuffer;
extern short *d_pzbuffer;
extern unsigned int d_zrowbytes, d_zwidth;
extern short    *zspantable[MAXHEIGHT];
extern int      d_scantable[MAXHEIGHT];

extern int              d_minmip;
extern float    d_scalemip[3];

//===================================================================

extern int              cachewidth;
extern pixel_t  *cacheblock;
extern int              r_screenwidth;

extern int              r_drawnpolycount;

extern int      sintable[1280];
extern int      intsintable[1280];
extern int		blanktable[1280];		// PGM

extern  vec3_t  vup, base_vup;
extern  vec3_t  vpn, base_vpn;
extern  vec3_t  vright, base_vright;

extern  surf_t  *surfaces, *surface_p, *surf_max;

// surfaces are generated in back to front order by the bsp, so if a surf
// pointer is greater than another one, it should be drawn in front
// surfaces[1] is the background, and is used as the active surface stack.
// surfaces[0] is a dummy, because index 0 is used to indicate no surface
//  attached to an edge_t

//===================================================================

extern vec3_t   sxformaxis[4];  // s axis transformed into viewspace
extern vec3_t   txformaxis[4];  // t axis transformed into viewspac

extern  float   xcenter, ycenter;
extern  float   xscale, yscale;
extern  float   xscaleinv, yscaleinv;
extern  float   xscaleshrink, yscaleshrink;

extern void TransformVector (vec3_t in, vec3_t out);
extern void SetUpForLineScan(fixed8_t startvertu, fixed8_t startvertv,
	fixed8_t endvertu, fixed8_t endvertv);

extern int      ubasestep, errorterm, erroradjustup, erroradjustdown;

//===========================================================================

extern cvar_t   *sw_aliasstats;
extern cvar_t   *sw_clearcolor;
extern cvar_t   *sw_drawflat;
extern cvar_t   *sw_draworder;
extern cvar_t   *sw_maxedges;
extern cvar_t   *sw_maxsurfs;
extern cvar_t   *sw_mipcap;
extern cvar_t   *sw_mipscale;
extern cvar_t   *sw_mode;
extern cvar_t   *sw_reportsurfout;
extern cvar_t   *sw_reportedgeout;
extern cvar_t   *sw_stipplealpha;
extern cvar_t   *sw_surfcacheoverride;
extern cvar_t   *sw_waterwarp;

extern cvar_t   *r_fullbright;
extern cvar_t	*r_lefthand;
extern cvar_t   *r_drawentities;
extern cvar_t   *r_drawworld;
extern cvar_t   *r_dspeeds;
extern cvar_t   *r_lerpmodels;

extern cvar_t   *r_speeds;

extern cvar_t   *r_lightlevel;  //FIXME HACK

extern cvar_t	*vid_fullscreen;
extern	cvar_t	*vid_gamma;


extern  clipplane_t     view_clipplanes[4];
extern int              *pfrustum_indexes[4];


//=============================================================================

void R_RenderWorld (void);

//=============================================================================

extern  mplane_t        screenedge[4];

extern  vec3_t  r_origin;

extern	entity_t	r_worldentity;
extern  model_t         *currentmodel;
extern  entity_t                *currententity;
extern  vec3_t  modelorg;
extern  vec3_t  r_entorigin;

extern  float   verticalFieldOfView;
extern  float   xOrigin, yOrigin;

extern  int             r_visframecount;

extern msurface_t *r_alpha_surfaces;

//=============================================================================

void R_ClearPolyList (void);
void R_DrawPolyList (void);

//
// current entity info
//
extern  qboolean                insubmodel;

void R_DrawAlphaSurfaces( void );

void R_DrawSprite (void);
void R_DrawBeam( entity_t *e );

void R_RenderFace (msurface_t *fa, int clipflags);
void R_RenderBmodelFace (bedge_t *pedges, msurface_t *psurf);
void R_TransformPlane (mplane_t *p, float *normal, float *dist);
void R_TransformFrustum (void);
void R_DrawSurfaceBlock16 (void);
void R_DrawSurfaceBlock8 (void);

#if     id386

void R_DrawSurfaceBlock8_mip0 (void);
void R_DrawSurfaceBlock8_mip1 (void);
void R_DrawSurfaceBlock8_mip2 (void);
void R_DrawSurfaceBlock8_mip3 (void);

#endif

void R_GenSkyTile (void *pdest);
void R_GenSkyTile16 (void *pdest);
void R_Surf8Patch (void);
void R_Surf16Patch (void);
void R_DrawSubmodelPolygons (model_t *pmodel, int clipflags, mnode_t *topnode);
void R_DrawSolidClippedSubmodelPolygons (model_t *pmodel, mnode_t *topnode);

void R_AddPolygonEdges (emitpoint_t *pverts, int numverts, int miplevel);
surf_t *R_GetSurf (void);
void R_AliasDrawModel (void);
void R_BeginEdgeFrame (void);
void R_ScanEdges (void);
void D_DrawSurfaces (void);
void R_InsertNewEdges (edge_t *edgestoadd, edge_t *edgelist);
void R_StepActiveU (edge_t *pedge);
void R_RemoveEdges (edge_t *pedge);
void R_PushDlights (model_t *model);

extern void R_Surf8Start (void);
extern void R_Surf8End (void);
extern void R_Surf16Start (void);
extern void R_Surf16End (void);
extern void R_EdgeCodeStart (void);
extern void R_EdgeCodeEnd (void);

extern void R_RotateBmodel (void);

extern int      c_faceclip;
extern int      r_polycount;
extern int      r_wholepolycount;

extern int                      ubasestep, errorterm, erroradjustup, erroradjustdown;

extern fixed16_t        sadjust, tadjust;
extern fixed16_t        bbextents, bbextentt;

extern mvertex_t        *r_ptverts, *r_ptvertsmax;

extern float                    entity_rotation[3][3];

extern int              r_currentkey;
extern int              r_currentbkey;

void    R_InitTurb (void);

void R_DrawParticles (void);
void R_SurfacePatch (void);

extern int              r_amodels_drawn;
extern edge_t   *auxedges;
extern int              r_numallocatededges;
extern edge_t   *r_edges, *edge_p, *edge_max;

extern  edge_t  *newedges[MAXHEIGHT];
extern  edge_t  *removeedges[MAXHEIGHT];

// FIXME: make stack vars when debugging done
extern  edge_t  edge_head;
extern  edge_t  edge_tail;
extern  edge_t  edge_aftertail;

extern	int	r_aliasblendcolor;

extern float    aliasxscale, aliasyscale, aliasxcenter, aliasycenter;

extern int              r_outofsurfaces;
extern int              r_outofedges;

extern mvertex_t        *r_pcurrentvertbase;
extern int                      r_maxvalidedgeoffset;

typedef struct
{
	finalvert_t *a, *b, *c;
} aliastriangleparms_t;

extern aliastriangleparms_t aliastriangleparms;

void R_DrawTriangle( void );
//void R_DrawTriangle (finalvert_t *index0, finalvert_t *index1, finalvert_t *index2);
void R_AliasClipTriangle (finalvert_t *index0, finalvert_t *index1, finalvert_t *index2);


extern float    r_time1;
extern float	da_time1, da_time2;
extern float	dp_time1, dp_time2, db_time1, db_time2, rw_time1, rw_time2;
extern float	se_time1, se_time2, de_time1, de_time2, dv_time1, dv_time2;
extern int              r_frustum_indexes[4*6];
extern int              r_maxsurfsseen, r_maxedgesseen, r_cnumsurfs;
extern qboolean r_surfsonstack;

extern	mleaf_t		*r_viewleaf;
extern	int			r_viewcluster, r_oldviewcluster;

extern int              r_clipflags;
extern int              r_dlightframecount;
extern qboolean r_fov_greater_than_90;

extern  image_t         *r_notexture_mip;
extern  model_t         *r_worldmodel;

void R_PrintAliasStats (void);
void R_PrintTimes (void);
void R_PrintDSpeeds (void);
void R_AnimateLight (void);
void R_LightPoint (vec3_t p, vec3_t color);
void R_SetupFrame (void);
void R_cshift_f (void);
void R_EmitEdge (mvertex_t *pv0, mvertex_t *pv1);
void R_ClipEdge (mvertex_t *pv0, mvertex_t *pv1, clipplane_t *clip);
void R_SplitEntityOnNode2 (mnode_t *node);

extern  refdef_t        r_newrefdef;

extern  surfcache_t     *sc_rover, *sc_base;

extern  void            *colormap;

//====================================================================

float R_DLightPoint (vec3_t p);

void R_NewMap (void);
void R_Register (void);
void R_UnRegister (void);
void Draw_InitLocal (void);
qboolean R_Init( void *hInstance, void *wndProc );
void R_Shutdown (void);
void R_InitCaches (void);
void D_FlushCaches (void);

void	R_ScreenShot_f( void );
void    R_BeginRegistration (char *map);
struct model_s  *R_RegisterModel (char *name);
void    R_EndRegistration (void);

void    R_RenderFrame (refdef_t *fd);

struct image_s  *Draw_FindPic (char *name);

void    Draw_GetPicSize (int *w, int *h, char *name);
void    Draw_Pic (int x, int y, char *name);
void    Draw_StretchPic (int x, int y, int w, int h, char *name);
void    Draw_StretchRaw (int x, int y, int w, int h, int cols, int rows, byte *data);
void    Draw_Char (int x, int y, int c);
void    Draw_TileClear (int x, int y, int w, int h, char *name);
void    Draw_Fill (int x, int y, int w, int h, int c);
void    Draw_FadeScreen (void);

void    Draw_GetPalette (void);

void	 R_BeginFrame( float camera_separation );

void	R_CinematicSetPalette( const unsigned char *palette );

extern unsigned d_8to24table[256]; // base

void    Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length);
void    Sys_SetFPCW (void);

void LoadPCX (char *filename, byte **pic, byte **palette, int *width, int *height);

void    R_InitImages (void);
void	R_ShutdownImages (void);
image_t *R_FindImage (char *name, imagetype_t type);
void    R_FreeUnusedImages (void);

void	R_GammaCorrectAndSetPalette( const unsigned char *pal );

extern mtexinfo_t  *sky_texinfo[6];

void R_InitSkyBox (void);

typedef struct swstate_s
{
	qboolean fullscreen;
	int      prev_mode;				// last valid SW mode

	byte		gammatable[256];
	byte		currentpalette[1024];

} swstate_t;

void R_IMFlatShadedQuad( vec3_t a, vec3_t b, vec3_t c, vec3_t d, int color, float alpha );

extern swstate_t sw_state;

/*
====================================================================

IMPORTED FUNCTIONS

====================================================================
*/

extern  refimport_t     ri;

/*
====================================================================

IMPLEMENTATION FUNCTIONS

====================================================================
*/

void		SWimp_BeginFrame( float camera_separation );
void		SWimp_EndFrame (void);
int			SWimp_Init( void *hInstance, void *wndProc );
void		SWimp_SetPalette( const unsigned char *palette);
void		SWimp_Shutdown( void );
rserr_t		SWimp_SetMode( int *pwidth, int *pheight, int mode, qboolean fullscreen );
void		SWimp_AppActivate( qboolean active );

