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
// r_alias.c: routines for setting up to draw alias models

/*
** use a real variable to control lerping
*/
#include "r_local.h"

#define LIGHT_MIN	5		// lowest light value we'll allow, to avoid the
							//  need for inner-loop light clamping

//PGM
extern byte iractive;
//PGM

int				r_amodels_drawn;

affinetridesc_t	r_affinetridesc;

vec3_t			r_plightvec;
vec3_t          r_lerped[1024];
vec3_t          r_lerp_frontv, r_lerp_backv, r_lerp_move;

int				r_ambientlight;
int				r_aliasblendcolor;
float			r_shadelight;


daliasframe_t	*r_thisframe, *r_lastframe;
dmdl_t			*s_pmdl;

float	aliastransform[3][4];
float   aliasworldtransform[3][4];
float   aliasoldworldtransform[3][4];

static float	s_ziscale;
static vec3_t	s_alias_forward, s_alias_right, s_alias_up;


#define NUMVERTEXNORMALS	162

float	r_avertexnormals[NUMVERTEXNORMALS][3] = {
#include "anorms.h"
};


void R_AliasSetUpLerpData( dmdl_t *pmdl, float backlerp );
void R_AliasSetUpTransform (void);
void R_AliasTransformVector (vec3_t in, vec3_t out, float m[3][4] );
void R_AliasProjectAndClipTestFinalVert (finalvert_t *fv);

void R_AliasTransformFinalVerts( int numpoints, finalvert_t *fv, dtrivertx_t *oldv, dtrivertx_t *newv );

void R_AliasLerpFrames( dmdl_t *paliashdr, float backlerp );

/*
================
R_AliasCheckBBox
================
*/
typedef struct {
	int	index0;
	int	index1;
} aedge_t;

static aedge_t	aedges[12] = {
{0, 1}, {1, 2}, {2, 3}, {3, 0},
{4, 5}, {5, 6}, {6, 7}, {7, 4},
{0, 5}, {1, 4}, {2, 7}, {3, 6}
};

#define BBOX_TRIVIAL_ACCEPT 0
#define BBOX_MUST_CLIP_XY   1
#define BBOX_MUST_CLIP_Z    2
#define BBOX_TRIVIAL_REJECT 8

/*
** R_AliasCheckFrameBBox
**
** Checks a specific alias frame bounding box
*/
unsigned long R_AliasCheckFrameBBox( daliasframe_t *frame, float worldxf[3][4] )
{
	unsigned long aggregate_and_clipcode = ~0U, 
		          aggregate_or_clipcode = 0;
	int           i;
	vec3_t        mins, maxs;
	vec3_t        transformed_min, transformed_max;
	qboolean      zclipped = false, zfullyclipped = true;
	float         minz = 9999.0F;

	/*
	** get the exact frame bounding box
	*/
	for (i=0 ; i<3 ; i++)
	{
		mins[i] = frame->translate[i];
		maxs[i] = mins[i] + frame->scale[i]*255;
	}

	/*
	** transform the min and max values into view space
	*/
	R_AliasTransformVector( mins, transformed_min, aliastransform );
	R_AliasTransformVector( maxs, transformed_max, aliastransform );

	if ( transformed_min[2] >= ALIAS_Z_CLIP_PLANE )
		zfullyclipped = false;
	if ( transformed_max[2] >= ALIAS_Z_CLIP_PLANE )
		zfullyclipped = false;

	if ( zfullyclipped )
	{
		return BBOX_TRIVIAL_REJECT;
	}
	if ( zclipped )
	{
		return ( BBOX_MUST_CLIP_XY | BBOX_MUST_CLIP_Z );
	}

	/*
	** build a transformed bounding box from the given min and max
	*/
	for ( i = 0; i < 8; i++ )
	{
		int      j;
		vec3_t   tmp, transformed;
		unsigned long clipcode = 0;

		if ( i & 1 )
			tmp[0] = mins[0];
		else
			tmp[0] = maxs[0];

		if ( i & 2 )
			tmp[1] = mins[1];
		else
			tmp[1] = maxs[1];

		if ( i & 4 )
			tmp[2] = mins[2];
		else
			tmp[2] = maxs[2];

		R_AliasTransformVector( tmp, transformed, worldxf );

		for ( j = 0; j < 4; j++ )
		{
			float dp = DotProduct( transformed, view_clipplanes[j].normal );

			if ( ( dp - view_clipplanes[j].dist ) < 0.0F )
				clipcode |= 1 << j;
		}

		aggregate_and_clipcode &= clipcode;
		aggregate_or_clipcode  |= clipcode;
	}

	if ( aggregate_and_clipcode )
	{
		return BBOX_TRIVIAL_REJECT;
	}
	if ( !aggregate_or_clipcode )
	{
		return BBOX_TRIVIAL_ACCEPT;
	}

	return BBOX_MUST_CLIP_XY;
}

qboolean R_AliasCheckBBox (void)
{
	unsigned long ccodes[2] = { 0, 0 };

	ccodes[0] = R_AliasCheckFrameBBox( r_thisframe, aliasworldtransform );

	/*
	** non-lerping model
	*/
	if ( currententity->backlerp == 0 )
	{
		if ( ccodes[0] == BBOX_TRIVIAL_ACCEPT )
			return BBOX_TRIVIAL_ACCEPT;
		else if ( ccodes[0] & BBOX_TRIVIAL_REJECT )
			return BBOX_TRIVIAL_REJECT;
		else
			return ( ccodes[0] & ~BBOX_TRIVIAL_REJECT );
	}

	ccodes[1] = R_AliasCheckFrameBBox( r_lastframe, aliasoldworldtransform );

	if ( ( ccodes[0] | ccodes[1] ) == BBOX_TRIVIAL_ACCEPT )
		return BBOX_TRIVIAL_ACCEPT;
	else if ( ( ccodes[0] & ccodes[1] ) & BBOX_TRIVIAL_REJECT )
		return BBOX_TRIVIAL_REJECT;
	else
		return ( ccodes[0] | ccodes[1] ) & ~BBOX_TRIVIAL_REJECT;
}


/*
================
R_AliasTransformVector
================
*/
void R_AliasTransformVector(vec3_t in, vec3_t out, float xf[3][4] )
{
	out[0] = DotProduct(in, xf[0]) + xf[0][3];
	out[1] = DotProduct(in, xf[1]) + xf[1][3];
	out[2] = DotProduct(in, xf[2]) + xf[2][3];
}


/*
================
R_AliasPreparePoints

General clipped case
================
*/
typedef struct
{
	int          num_points;
	dtrivertx_t *last_verts;   // verts from the last frame
	dtrivertx_t *this_verts;   // verts from this frame
	finalvert_t *dest_verts;   // destination for transformed verts
} aliasbatchedtransformdata_t;

aliasbatchedtransformdata_t aliasbatchedtransformdata;

void R_AliasPreparePoints (void)
{
	int			i;
	dstvert_t	*pstverts;
	dtriangle_t	*ptri;
	finalvert_t	*pfv[3];
	finalvert_t	finalverts[MAXALIASVERTS +
						((CACHE_SIZE - 1) / sizeof(finalvert_t)) + 3];
	finalvert_t	*pfinalverts;

//PGM
	iractive = (r_newrefdef.rdflags & RDF_IRGOGGLES && currententity->flags & RF_IR_VISIBLE);
//	iractive = 0;
//	if(r_newrefdef.rdflags & RDF_IRGOGGLES && currententity->flags & RF_IR_VISIBLE)
//		iractive = 1;
//PGM

	// put work vertexes on stack, cache aligned
	pfinalverts = (finalvert_t *)
			(((long)&finalverts[0] + CACHE_SIZE - 1) & ~(CACHE_SIZE - 1));

	aliasbatchedtransformdata.num_points = s_pmdl->num_xyz;
	aliasbatchedtransformdata.last_verts = r_lastframe->verts;
	aliasbatchedtransformdata.this_verts = r_thisframe->verts;
	aliasbatchedtransformdata.dest_verts = pfinalverts;

	R_AliasTransformFinalVerts( aliasbatchedtransformdata.num_points,
		                        aliasbatchedtransformdata.dest_verts,
								aliasbatchedtransformdata.last_verts,
								aliasbatchedtransformdata.this_verts );

// clip and draw all triangles
//
	pstverts = (dstvert_t *)((byte *)s_pmdl + s_pmdl->ofs_st);
	ptri = (dtriangle_t *)((byte *)s_pmdl + s_pmdl->ofs_tris);

	if ( ( currententity->flags & RF_WEAPONMODEL ) && ( r_lefthand->value == 1.0F ) )
	{
		for (i=0 ; i<s_pmdl->num_tris ; i++, ptri++)
		{
			pfv[0] = &pfinalverts[ptri->index_xyz[0]];
			pfv[1] = &pfinalverts[ptri->index_xyz[1]];
			pfv[2] = &pfinalverts[ptri->index_xyz[2]];

			if ( pfv[0]->flags & pfv[1]->flags & pfv[2]->flags )
				continue;		// completely clipped

			// insert s/t coordinates
			pfv[0]->s = pstverts[ptri->index_st[0]].s << 16;
			pfv[0]->t = pstverts[ptri->index_st[0]].t << 16;

			pfv[1]->s = pstverts[ptri->index_st[1]].s << 16;
			pfv[1]->t = pstverts[ptri->index_st[1]].t << 16;

			pfv[2]->s = pstverts[ptri->index_st[2]].s << 16;
			pfv[2]->t = pstverts[ptri->index_st[2]].t << 16;

			if ( ! (pfv[0]->flags | pfv[1]->flags | pfv[2]->flags) )
			{	// totally unclipped
				aliastriangleparms.a = pfv[2];
				aliastriangleparms.b = pfv[1];
				aliastriangleparms.c = pfv[0];

				R_DrawTriangle();
			}
			else
			{
				R_AliasClipTriangle (pfv[2], pfv[1], pfv[0]);
			}
		}
	}
	else
	{
		for (i=0 ; i<s_pmdl->num_tris ; i++, ptri++)
		{
			pfv[0] = &pfinalverts[ptri->index_xyz[0]];
			pfv[1] = &pfinalverts[ptri->index_xyz[1]];
			pfv[2] = &pfinalverts[ptri->index_xyz[2]];

			if ( pfv[0]->flags & pfv[1]->flags & pfv[2]->flags )
				continue;		// completely clipped

			// insert s/t coordinates
			pfv[0]->s = pstverts[ptri->index_st[0]].s << 16;
			pfv[0]->t = pstverts[ptri->index_st[0]].t << 16;

			pfv[1]->s = pstverts[ptri->index_st[1]].s << 16;
			pfv[1]->t = pstverts[ptri->index_st[1]].t << 16;

			pfv[2]->s = pstverts[ptri->index_st[2]].s << 16;
			pfv[2]->t = pstverts[ptri->index_st[2]].t << 16;

			if ( ! (pfv[0]->flags | pfv[1]->flags | pfv[2]->flags) )
			{	// totally unclipped
				aliastriangleparms.a = pfv[0];
				aliastriangleparms.b = pfv[1];
				aliastriangleparms.c = pfv[2];

				R_DrawTriangle();
			}
			else		
			{	// partially clipped
				R_AliasClipTriangle (pfv[0], pfv[1], pfv[2]);
			}
		}
	}
}


/*
================
R_AliasSetUpTransform
================
*/
void R_AliasSetUpTransform (void)
{
	int				i;
	static float	viewmatrix[3][4];
	vec3_t			angles;

// TODO: should really be stored with the entity instead of being reconstructed
// TODO: should use a look-up table
// TODO: could cache lazily, stored in the entity
// 
	angles[ROLL] = currententity->angles[ROLL];
	angles[PITCH] = currententity->angles[PITCH];
	angles[YAW] = currententity->angles[YAW];
	AngleVectors( angles, s_alias_forward, s_alias_right, s_alias_up );

// TODO: can do this with simple matrix rearrangement

	memset( aliasworldtransform, 0, sizeof( aliasworldtransform ) );
	memset( aliasoldworldtransform, 0, sizeof( aliasworldtransform ) );

	for (i=0 ; i<3 ; i++)
	{
		aliasoldworldtransform[i][0] = aliasworldtransform[i][0] =  s_alias_forward[i];
		aliasoldworldtransform[i][0] = aliasworldtransform[i][1] = -s_alias_right[i];
		aliasoldworldtransform[i][0] = aliasworldtransform[i][2] =  s_alias_up[i];
	}

	aliasworldtransform[0][3] = currententity->origin[0]-r_origin[0];
	aliasworldtransform[1][3] = currententity->origin[1]-r_origin[1];
	aliasworldtransform[2][3] = currententity->origin[2]-r_origin[2];

	aliasoldworldtransform[0][3] = currententity->oldorigin[0]-r_origin[0];
	aliasoldworldtransform[1][3] = currententity->oldorigin[1]-r_origin[1];
	aliasoldworldtransform[2][3] = currententity->oldorigin[2]-r_origin[2];

// FIXME: can do more efficiently than full concatenation
//	memcpy( rotationmatrix, t2matrix, sizeof( rotationmatrix ) );

//	R_ConcatTransforms (t2matrix, tmatrix, rotationmatrix);

// TODO: should be global, set when vright, etc., set
	VectorCopy (vright, viewmatrix[0]);
	VectorCopy (vup, viewmatrix[1]);
	VectorInverse (viewmatrix[1]);
	VectorCopy (vpn, viewmatrix[2]);

	viewmatrix[0][3] = 0;
	viewmatrix[1][3] = 0;
	viewmatrix[2][3] = 0;

//	memcpy( aliasworldtransform, rotationmatrix, sizeof( aliastransform ) );

	R_ConcatTransforms (viewmatrix, aliasworldtransform, aliastransform);

	aliasworldtransform[0][3] = currententity->origin[0];
	aliasworldtransform[1][3] = currententity->origin[1];
	aliasworldtransform[2][3] = currententity->origin[2];

	aliasoldworldtransform[0][3] = currententity->oldorigin[0];
	aliasoldworldtransform[1][3] = currententity->oldorigin[1];
	aliasoldworldtransform[2][3] = currententity->oldorigin[2];
}


/*
================
R_AliasTransformFinalVerts
================
*/
#if id386 && !defined __linux__
void R_AliasTransformFinalVerts( int numpoints, finalvert_t *fv, dtrivertx_t *oldv, dtrivertx_t *newv )
{
	float  lightcos;
	float	lerped_vert[3];
	int    byte_to_dword_ptr_var;
	int    tmpint;

	float  one = 1.0F;
	float  zi;

	static float  FALIAS_Z_CLIP_PLANE = ALIAS_Z_CLIP_PLANE;
	static float  PS_SCALE = POWERSUIT_SCALE;

	__asm mov ecx, numpoints

	/*
	lerped_vert[0] = r_lerp_move[0] + oldv->v[0]*r_lerp_backv[0] + newv->v[0]*r_lerp_frontv[0];
	lerped_vert[1] = r_lerp_move[1] + oldv->v[1]*r_lerp_backv[1] + newv->v[1]*r_lerp_frontv[1];
	lerped_vert[2] = r_lerp_move[2] + oldv->v[2]*r_lerp_backv[2] + newv->v[2]*r_lerp_frontv[2];
	*/
top_of_loop:

	__asm mov esi, oldv
	__asm mov edi, newv

	__asm xor ebx, ebx

	__asm mov bl, byte ptr [esi+DTRIVERTX_V0]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var      
	__asm fmul dword ptr [r_lerp_backv+0]                  ; oldv[0]*rlb[0]

	__asm mov bl, byte ptr [esi+DTRIVERTX_V1]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var
	__asm fmul dword ptr [r_lerp_backv+4]                  ; oldv[1]*rlb[1] | oldv[0]*rlb[0]

	__asm mov bl, byte ptr [esi+DTRIVERTX_V2]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var
	__asm fmul dword ptr [r_lerp_backv+8]                  ; oldv[2]*rlb[2] | oldv[1]*rlb[1] | oldv[0]*rlb[0]

	__asm mov bl, byte ptr [edi+DTRIVERTX_V0]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var      
	__asm fmul dword ptr [r_lerp_frontv+0]                 ; newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] | oldv[0]*rlb[0]

	__asm mov bl, byte ptr [edi+DTRIVERTX_V1]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var
	__asm fmul dword ptr [r_lerp_frontv+4]                 ; newv[1]*rlf[1] | newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] | oldv[0]*rlb[0]

	__asm mov bl, byte ptr [edi+DTRIVERTX_V2]
	__asm mov byte_to_dword_ptr_var, ebx
	__asm fild dword ptr byte_to_dword_ptr_var
	__asm fmul dword ptr [r_lerp_frontv+8]                 ; newv[2]*rlf[2] | newv[1]*rlf[1] | newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] | oldv[0]*rlb[0]

	__asm fxch st(5)                     ; oldv[0]*rlb[0] | newv[1]*rlf[1] | newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] | newv[2]*rlf[2]
	__asm faddp st(2), st                ; newv[1]*rlf[1] | oldv[0]*rlb[0] + newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] | newv[2]*rlf[2]
	__asm faddp st(3), st                ; oldv[0]*rlb[0] + newv[0]*rlf[0] | oldv[2]*rlb[2] | oldv[1]*rlb[1] + newv[1]*rlf[1] | newv[2]*rlf[2]
	__asm fxch st(1)                     ; oldv[2]*rlb[2] | oldv[0]*rlb[0] + newv[0]*rlf[0] | oldv[1]*rlb[1] + newv[1]*rlf[1] | newv[2]*rlf[2]
	__asm faddp st(3), st                ; oldv[0]*rlb[0] + newv[0]*rlf[0] | oldv[1]*rlb[1] + newv[1]*rlf[1] | oldv[2]*rlb[2] + newv[2]*rlf[2]
	__asm fadd dword ptr [r_lerp_move+0] ; lv0 | oldv[1]*rlb[1] + newv[1]*rlf[1] | oldv[2]*rlb[2] + newv[2]*rlf[2]
	__asm fxch st(1)                     ; oldv[1]*rlb[1] + newv[1]*rlf[1] | lv0 | oldv[2]*rlb[2] + newv[2]*rlf[2]
	__asm fadd dword ptr [r_lerp_move+4] ; lv1 | lv0 | oldv[2]*rlb[2] + newv[2]*rlf[2]
	__asm fxch st(2)                     ; oldv[2]*rlb[2] + newv[2]*rlf[2] | lv0 | lv1
	__asm fadd dword ptr [r_lerp_move+8] ; lv2 | lv0 | lv1
	__asm fxch st(1)                     ; lv0 | lv2 | lv1
	__asm fstp dword ptr [lerped_vert+0] ; lv2 | lv1
	__asm fstp dword ptr [lerped_vert+8] ; lv2
	__asm fstp dword ptr [lerped_vert+4] ; (empty)

	__asm mov  eax, currententity
	__asm mov  eax, dword ptr [eax+ENTITY_FLAGS]
	__asm mov  ebx, RF_SHELL_RED | RF_SHELL_GREEN | RF_SHELL_BLUE | RF_SHELL_DOUBLE | RF_SHELL_HALF_DAM
	__asm and  eax, ebx
	__asm jz   not_powersuit

	/*
	**    lerped_vert[0] += lightnormal[0] * POWERSUIT_SCALE
	**    lerped_vert[1] += lightnormal[1] * POWERSUIT_SCALE
	**    lerped_vert[2] += lightnormal[2] * POWERSUIT_SCALE
	*/

	__asm xor ebx, ebx
	__asm mov bl,  byte ptr [edi+DTRIVERTX_LNI]
	__asm mov eax, 12
	__asm mul ebx
	__asm lea eax, [r_avertexnormals+eax]

	__asm fld  dword ptr [eax+0]				; n[0]
	__asm fmul PS_SCALE							; n[0] * PS
	__asm fld  dword ptr [eax+4]				; n[1] | n[0] * PS
	__asm fmul PS_SCALE							; n[1] * PS | n[0] * PS
	__asm fld  dword ptr [eax+8]				; n[2] | n[1] * PS | n[0] * PS
	__asm fmul PS_SCALE							; n[2] * PS | n[1] * PS | n[0] * PS
	__asm fld  dword ptr [lerped_vert+0]		; lv0 | n[2] * PS | n[1] * PS | n[0] * PS
	__asm faddp st(3), st						; n[2] * PS | n[1] * PS | n[0] * PS + lv0
	__asm fld  dword ptr [lerped_vert+4]		; lv1 | n[2] * PS | n[1] * PS | n[0] * PS + lv0
	__asm faddp st(2), st						; n[2] * PS | n[1] * PS + lv1 | n[0] * PS + lv0
	__asm fadd dword ptr [lerped_vert+8]		; n[2] * PS + lv2 | n[1] * PS + lv1 | n[0] * PS + lv0
	__asm fxch st(2)							; LV0 | LV1 | LV2
	__asm fstp dword ptr [lerped_vert+0]		; LV1 | LV2
	__asm fstp dword ptr [lerped_vert+4]		; LV2
	__asm fstp dword ptr [lerped_vert+8]		; (empty)

not_powersuit:

	/*
	fv->flags = 0;

	fv->xyz[0] = DotProduct(lerped_vert, aliastransform[0]) + aliastransform[0][3];
	fv->xyz[1] = DotProduct(lerped_vert, aliastransform[1]) + aliastransform[1][3];
	fv->xyz[2] = DotProduct(lerped_vert, aliastransform[2]) + aliastransform[2][3];
	*/
	__asm mov  eax, fv
	__asm mov  dword ptr [eax+FINALVERT_FLAGS], 0

	__asm fld  dword ptr [lerped_vert+0]           ; lv0
	__asm fmul dword ptr [aliastransform+0]        ; lv0*at[0][0]
	__asm fld  dword ptr [lerped_vert+4]           ; lv1 | lv0*at[0][0]
	__asm fmul dword ptr [aliastransform+4]        ; lv1*at[0][1] | lv0*at[0][0]
	__asm fld  dword ptr [lerped_vert+8]           ; lv2 | lv1*at[0][1] | lv0*at[0][0]
	__asm fmul dword ptr [aliastransform+8]        ; lv2*at[0][2] | lv1*at[0][1] | lv0*at[0][0]
	__asm fxch st(2)                               ; lv0*at[0][0] | lv1*at[0][1] | lv2*at[0][2]
	__asm faddp st(1), st                          ; lv0*at[0][0] + lv1*at[0][1] | lv2*at[0][2]
	__asm faddp st(1), st                          ; lv0*at[0][0] + lv1*at[0][1] + lv2*at[0][2]
	__asm fadd  dword ptr [aliastransform+12]      ; FV.X

	__asm fld  dword ptr [lerped_vert+0]           ; lv0
	__asm fmul dword ptr [aliastransform+16]       ; lv0*at[1][0]
	__asm fld  dword ptr [lerped_vert+4]           ; lv1 | lv0*at[1][0]
	__asm fmul dword ptr [aliastransform+20]       ; lv1*at[1][1] | lv0*at[1][0]
	__asm fld  dword ptr [lerped_vert+8]           ; lv2 | lv1*at[1][1] | lv0*at[1][0]
	__asm fmul dword ptr [aliastransform+24]       ; lv2*at[1][2] | lv1*at[1][1] | lv0*at[1][0]
	__asm fxch st(2)                               ; lv0*at[1][0] | lv1*at[1][1] | lv2*at[1][2]
	__asm faddp st(1), st                          ; lv0*at[1][0] + lv1*at[1][1] | lv2*at[1][2]
	__asm faddp st(1), st                          ; lv0*at[1][0] + lv1*at[1][1] + lv2*at[1][2]
	__asm fadd dword ptr [aliastransform+28]       ; FV.Y | FV.X
	__asm fxch st(1)                               ; FV.X | FV.Y
	__asm fstp  dword ptr [eax+FINALVERT_X]        ; FV.Y
	
	__asm fld  dword ptr [lerped_vert+0]           ; lv0
	__asm fmul dword ptr [aliastransform+32]       ; lv0*at[2][0]
	__asm fld  dword ptr [lerped_vert+4]           ; lv1 | lv0*at[2][0]
	__asm fmul dword ptr [aliastransform+36]       ; lv1*at[2][1] | lv0*at[2][0]
	__asm fld  dword ptr [lerped_vert+8]           ; lv2 | lv1*at[2][1] | lv0*at[2][0]
	__asm fmul dword ptr [aliastransform+40]       ; lv2*at[2][2] | lv1*at[2][1] | lv0*at[2][0]
	__asm fxch st(2)                               ; lv0*at[2][0] | lv1*at[2][1] | lv2*at[2][2]
	__asm faddp st(1), st                          ; lv0*at[2][0] + lv1*at[2][1] | lv2*at[2][2]
	__asm faddp st(1), st                          ; lv0*at[2][0] + lv1*at[2][1] + lv2*at[2][2]
	__asm fadd dword ptr [aliastransform+44]       ; FV.Z | FV.Y
	__asm fxch st(1)                               ; FV.Y | FV.Z
	__asm fstp dword ptr [eax+FINALVERT_Y]         ; FV.Z
	__asm fstp dword ptr [eax+FINALVERT_Z]         ; (empty)

	/*
	**  lighting
	**
	**  plightnormal = r_avertexnormals[newv->lightnormalindex];
	**	lightcos = DotProduct (plightnormal, r_plightvec);
	**	temp = r_ambientlight;
	*/
	__asm xor ebx, ebx
	__asm mov bl,  byte ptr [edi+DTRIVERTX_LNI]
	__asm mov eax, 12
	__asm mul ebx
	__asm lea eax, [r_avertexnormals+eax]
	__asm lea ebx, r_plightvec

	__asm fld  dword ptr [eax+0]
	__asm fmul dword ptr [ebx+0]
	__asm fld  dword ptr [eax+4]
	__asm fmul dword ptr [ebx+4]
	__asm fld  dword ptr [eax+8]
	__asm fmul dword ptr [ebx+8]
	__asm fxch st(2)
	__asm faddp st(1), st
	__asm faddp st(1), st
	__asm fstp dword ptr lightcos
	__asm mov eax, lightcos
	__asm mov ebx, r_ambientlight

	/*
	if (lightcos < 0)
	{
		temp += (int)(r_shadelight * lightcos);

		// clamp; because we limited the minimum ambient and shading light, we
		// don't have to clamp low light, just bright
		if (temp < 0)
			temp = 0;
	}

	fv->v[4] = temp;
	*/
	__asm or  eax, eax
	__asm jns store_fv4

	__asm fld   dword ptr r_shadelight
	__asm fmul  dword ptr lightcos
	__asm fistp dword ptr tmpint
	__asm add   ebx, tmpint

	__asm or    ebx, ebx
	__asm jns   store_fv4
	__asm mov   ebx, 0

store_fv4:
	__asm mov edi, fv
	__asm mov dword ptr [edi+FINALVERT_V4], ebx

	__asm mov edx, dword ptr [edi+FINALVERT_FLAGS]

	/*
	** do clip testing and projection here
	*/
	/*
	if ( dest_vert->xyz[2] < ALIAS_Z_CLIP_PLANE )
	{
		dest_vert->flags |= ALIAS_Z_CLIP;
	}
	else
	{
		R_AliasProjectAndClipTestFinalVert( dest_vert );
	}
	*/
	__asm mov eax, dword ptr [edi+FINALVERT_Z]
	__asm and eax, eax
	__asm js  alias_z_clip
	__asm cmp eax, FALIAS_Z_CLIP_PLANE
	__asm jl  alias_z_clip

	/*
	This is the code to R_AliasProjectAndClipTestFinalVert

	float	zi;
	float	x, y, z;

	x = fv->xyz[0];
	y = fv->xyz[1];
	z = fv->xyz[2];
	zi = 1.0 / z;

	fv->v[5] = zi * s_ziscale;

	fv->v[0] = (x * aliasxscale * zi) + aliasxcenter;
	fv->v[1] = (y * aliasyscale * zi) + aliasycenter;
	*/
	__asm fld   one                             ; 1
	__asm fdiv  dword ptr [edi+FINALVERT_Z]     ; zi

	__asm mov   eax, dword ptr [edi+32]
	__asm mov   eax, dword ptr [edi+64]

	__asm fst   zi                              ; zi
	__asm fmul  s_ziscale                       ; fv5
	__asm fld   dword ptr [edi+FINALVERT_X]     ; x | fv5
	__asm fmul  aliasxscale                     ; x * aliasxscale | fv5
	__asm fld   dword ptr [edi+FINALVERT_Y]     ; y | x * aliasxscale | fv5
	__asm fmul  aliasyscale                     ; y * aliasyscale | x * aliasxscale | fv5
	__asm fxch  st(1)                           ; x * aliasxscale | y * aliasyscale | fv5
	__asm fmul  zi                              ; x * asx * zi | y * asy | fv5
	__asm fadd  aliasxcenter                    ; fv0 | y * asy | fv5
	__asm fxch  st(1)                           ; y * asy | fv0 | fv5
	__asm fmul  zi                              ; y * asy * zi | fv0 | fv5
	__asm fadd  aliasycenter                    ; fv1 | fv0 | fv5
	__asm fxch  st(2)                           ; fv5 | fv0 | fv1
	__asm fistp dword ptr [edi+FINALVERT_V5]    ; fv0 | fv1
	__asm fistp dword ptr [edi+FINALVERT_V0]    ; fv1
	__asm fistp dword ptr [edi+FINALVERT_V1]    ; (empty)

	/*
	if (fv->v[0] < r_refdef.aliasvrect.x)
		fv->flags |= ALIAS_LEFT_CLIP;
	if (fv->v[1] < r_refdef.aliasvrect.y)
		fv->flags |= ALIAS_TOP_CLIP;
	if (fv->v[0] > r_refdef.aliasvrectright)
		fv->flags |= ALIAS_RIGHT_CLIP;
	if (fv->v[1] > r_refdef.aliasvrectbottom)
		fv->flags |= ALIAS_BOTTOM_CLIP;
	*/
	__asm mov eax, dword ptr [edi+FINALVERT_V0]
	__asm mov ebx, dword ptr [edi+FINALVERT_V1]

	__asm cmp eax, r_refdef.aliasvrect.x
	__asm jge ct_alias_top
	__asm or  edx, ALIAS_LEFT_CLIP
ct_alias_top:
	__asm cmp ebx, r_refdef.aliasvrect.y
	__asm jge ct_alias_right
	__asm or edx, ALIAS_TOP_CLIP
ct_alias_right:
	__asm cmp eax, r_refdef.aliasvrectright
	__asm jle ct_alias_bottom
	__asm or edx, ALIAS_RIGHT_CLIP
ct_alias_bottom:
	__asm cmp ebx, r_refdef.aliasvrectbottom
	__asm jle end_of_loop
	__asm or  edx, ALIAS_BOTTOM_CLIP

	__asm jmp end_of_loop

alias_z_clip:
	__asm or  edx, ALIAS_Z_CLIP

end_of_loop:

	__asm mov dword ptr [edi+FINALVERT_FLAGS], edx
	__asm add oldv, DTRIVERTX_SIZE
	__asm add newv, DTRIVERTX_SIZE
	__asm add fv, FINALVERT_SIZE

	__asm dec ecx
	__asm jnz top_of_loop
}
#else
void R_AliasTransformFinalVerts( int numpoints, finalvert_t *fv, dtrivertx_t *oldv, dtrivertx_t *newv )
{
	int i;

	for ( i = 0; i < numpoints; i++, fv++, oldv++, newv++ )
	{
		int		temp;
		float	lightcos, *plightnormal;
		vec3_t  lerped_vert;

		lerped_vert[0] = r_lerp_move[0] + oldv->v[0]*r_lerp_backv[0] + newv->v[0]*r_lerp_frontv[0];
		lerped_vert[1] = r_lerp_move[1] + oldv->v[1]*r_lerp_backv[1] + newv->v[1]*r_lerp_frontv[1];
		lerped_vert[2] = r_lerp_move[2] + oldv->v[2]*r_lerp_backv[2] + newv->v[2]*r_lerp_frontv[2];

		plightnormal = r_avertexnormals[newv->lightnormalindex];

		// PMM - added double damage shell
		if ( currententity->flags & ( RF_SHELL_RED | RF_SHELL_GREEN | RF_SHELL_BLUE | RF_SHELL_DOUBLE | RF_SHELL_HALF_DAM) )
		{
			lerped_vert[0] += plightnormal[0] * POWERSUIT_SCALE;
			lerped_vert[1] += plightnormal[1] * POWERSUIT_SCALE;
			lerped_vert[2] += plightnormal[2] * POWERSUIT_SCALE;
		}

		fv->xyz[0] = DotProduct(lerped_vert, aliastransform[0]) + aliastransform[0][3];
		fv->xyz[1] = DotProduct(lerped_vert, aliastransform[1]) + aliastransform[1][3];
		fv->xyz[2] = DotProduct(lerped_vert, aliastransform[2]) + aliastransform[2][3];

		fv->flags = 0;

		// lighting
		lightcos = DotProduct (plightnormal, r_plightvec);
		temp = r_ambientlight;

		if (lightcos < 0)
		{
			temp += (int)(r_shadelight * lightcos);

			// clamp; because we limited the minimum ambient and shading light, we
			// don't have to clamp low light, just bright
			if (temp < 0)
				temp = 0;
		}

		fv->l = temp;

		if ( fv->xyz[2] < ALIAS_Z_CLIP_PLANE )
		{
			fv->flags |= ALIAS_Z_CLIP;
		}
		else
		{
			R_AliasProjectAndClipTestFinalVert( fv );
		}
	}
}

#endif

/*
================
R_AliasProjectAndClipTestFinalVert
================
*/
void R_AliasProjectAndClipTestFinalVert( finalvert_t *fv )
{
	float	zi;
	float	x, y, z;

	// project points
	x = fv->xyz[0];
	y = fv->xyz[1];
	z = fv->xyz[2];
	zi = 1.0 / z;

	fv->zi = zi * s_ziscale;

	fv->u = (x * aliasxscale * zi) + aliasxcenter;
	fv->v = (y * aliasyscale * zi) + aliasycenter;

	if (fv->u < r_refdef.aliasvrect.x)
		fv->flags |= ALIAS_LEFT_CLIP;
	if (fv->v < r_refdef.aliasvrect.y)
		fv->flags |= ALIAS_TOP_CLIP;
	if (fv->u > r_refdef.aliasvrectright)
		fv->flags |= ALIAS_RIGHT_CLIP;
	if (fv->v > r_refdef.aliasvrectbottom)
		fv->flags |= ALIAS_BOTTOM_CLIP;	
}

/*
===============
R_AliasSetupSkin
===============
*/
static qboolean R_AliasSetupSkin (void)
{
	int				skinnum;
	image_t			*pskindesc;

	if (currententity->skin)
		pskindesc = currententity->skin;
	else
	{
		skinnum = currententity->skinnum;
		if ((skinnum >= s_pmdl->num_skins) || (skinnum < 0))
		{
			ri.Con_Printf (PRINT_ALL, "R_AliasSetupSkin %s: no such skin # %d\n", 
				currentmodel->name, skinnum);
			skinnum = 0;
		}

		pskindesc = currentmodel->skins[skinnum];
	}

	if ( !pskindesc )
		return false;

	r_affinetridesc.pskin = pskindesc->pixels[0];
	r_affinetridesc.skinwidth = pskindesc->width;
	r_affinetridesc.skinheight = pskindesc->height;

	R_PolysetUpdateTables ();		// FIXME: precalc edge lookups

	return true;
}


/*
================
R_AliasSetupLighting

  FIXME: put lighting into tables
================
*/
void R_AliasSetupLighting (void)
{
	alight_t		lighting;
	float			lightvec[3] = {-1, 0, 0};
	vec3_t			light;
	int				i, j;

	// all components of light should be identical in software
	if ( currententity->flags & RF_FULLBRIGHT )
	{
		for (i=0 ; i<3 ; i++)
			light[i] = 1.0;
	}
	else
	{
		R_LightPoint (currententity->origin, light);
	}

	// save off light value for server to look at (BIG HACK!)
	if ( currententity->flags & RF_WEAPONMODEL )
		r_lightlevel->value = 150.0 * light[0];


	if ( currententity->flags & RF_MINLIGHT )
	{
		for (i=0 ; i<3 ; i++)
			if (light[i] < 0.1)
				light[i] = 0.1;
	}

	if ( currententity->flags & RF_GLOW )
	{	// bonus items will pulse with time
		float	scale;
		float	min;

		scale = 0.1 * sin(r_newrefdef.time*7);
		for (i=0 ; i<3 ; i++)
		{
			min = light[i] * 0.8;
			light[i] += scale;
			if (light[i] < min)
				light[i] = min;
		}
	}

	j = (light[0] + light[1] + light[2])*0.3333*255;

	lighting.ambientlight = j;
	lighting.shadelight = j;

	lighting.plightvec = lightvec;

// clamp lighting so it doesn't overbright as much
	if (lighting.ambientlight > 128)
		lighting.ambientlight = 128;
	if (lighting.ambientlight + lighting.shadelight > 192)
		lighting.shadelight = 192 - lighting.ambientlight;

// guarantee that no vertex will ever be lit below LIGHT_MIN, so we don't have
// to clamp off the bottom
	r_ambientlight = lighting.ambientlight;

	if (r_ambientlight < LIGHT_MIN)
		r_ambientlight = LIGHT_MIN;

	r_ambientlight = (255 - r_ambientlight) << VID_CBITS;

	if (r_ambientlight < LIGHT_MIN)
		r_ambientlight = LIGHT_MIN;

	r_shadelight = lighting.shadelight;

	if (r_shadelight < 0)
		r_shadelight = 0;

	r_shadelight *= VID_GRADES;

// rotate the lighting vector into the model's frame of reference
	r_plightvec[0] =  DotProduct( lighting.plightvec, s_alias_forward );
	r_plightvec[1] = -DotProduct( lighting.plightvec, s_alias_right );
	r_plightvec[2] =  DotProduct( lighting.plightvec, s_alias_up );
}


/*
=================
R_AliasSetupFrames

=================
*/
void R_AliasSetupFrames( dmdl_t *pmdl )
{
	int thisframe = currententity->frame;
	int lastframe = currententity->oldframe;

	if ( ( thisframe >= pmdl->num_frames ) || ( thisframe < 0 ) )
	{
		ri.Con_Printf (PRINT_ALL, "R_AliasSetupFrames %s: no such thisframe %d\n", 
			currentmodel->name, thisframe);
		thisframe = 0;
	}
	if ( ( lastframe >= pmdl->num_frames ) || ( lastframe < 0 ) )
	{
		ri.Con_Printf (PRINT_ALL, "R_AliasSetupFrames %s: no such lastframe %d\n", 
			currentmodel->name, lastframe);
		lastframe = 0;
	}

	r_thisframe = (daliasframe_t *)((byte *)pmdl + pmdl->ofs_frames 
		+ thisframe * pmdl->framesize);

	r_lastframe = (daliasframe_t *)((byte *)pmdl + pmdl->ofs_frames 
		+ lastframe * pmdl->framesize);
}

/*
** R_AliasSetUpLerpData
**
** Precomputes lerp coefficients used for the whole frame.
*/
void R_AliasSetUpLerpData( dmdl_t *pmdl, float backlerp )
{
	float	frontlerp;
	vec3_t	translation, vectors[3];
	int		i;

	frontlerp = 1.0F - backlerp;

	/*
	** convert entity's angles into discrete vectors for R, U, and F
	*/
	AngleVectors (currententity->angles, vectors[0], vectors[1], vectors[2]);

	/*
	** translation is the vector from last position to this position
	*/
	VectorSubtract (currententity->oldorigin, currententity->origin, translation);

	/*
	** move should be the delta back to the previous frame * backlerp
	*/
	r_lerp_move[0] =  DotProduct(translation, vectors[0]);	// forward
	r_lerp_move[1] = -DotProduct(translation, vectors[1]);	// left
	r_lerp_move[2] =  DotProduct(translation, vectors[2]);	// up

	VectorAdd( r_lerp_move, r_lastframe->translate, r_lerp_move );

	for (i=0 ; i<3 ; i++)
	{
		r_lerp_move[i] = backlerp*r_lerp_move[i] + frontlerp * r_thisframe->translate[i];
	}

	for (i=0 ; i<3 ; i++)
	{
		r_lerp_frontv[i] = frontlerp * r_thisframe->scale[i];
		r_lerp_backv[i]  = backlerp  * r_lastframe->scale[i];
	}
}

/*
================
R_AliasDrawModel
================
*/
void R_AliasDrawModel (void)
{
	extern void	(*d_pdrawspans)(void *);
	extern void R_PolysetDrawSpans8_Opaque( void * );
	extern void R_PolysetDrawSpans8_33( void * );
	extern void R_PolysetDrawSpans8_66( void * );
	extern void R_PolysetDrawSpansConstant8_33( void * );
	extern void R_PolysetDrawSpansConstant8_66( void * );

	s_pmdl = (dmdl_t *)currentmodel->extradata;

	if ( r_lerpmodels->value == 0 )
		currententity->backlerp = 0;

	if ( currententity->flags & RF_WEAPONMODEL )
	{
		if ( r_lefthand->value == 1.0F )
			aliasxscale = -aliasxscale;
		else if ( r_lefthand->value == 2.0F )
			return;
	}

	/*
	** we have to set our frame pointers and transformations before
	** doing any real work
	*/
	R_AliasSetupFrames( s_pmdl );
	R_AliasSetUpTransform();

	// see if the bounding box lets us trivially reject, also sets
	// trivial accept status
	if ( R_AliasCheckBBox() == BBOX_TRIVIAL_REJECT )
	{
		if ( ( currententity->flags & RF_WEAPONMODEL ) && ( r_lefthand->value == 1.0F ) )
		{
			aliasxscale = -aliasxscale;
		}
		return;
	}

	// set up the skin and verify it exists
	if ( !R_AliasSetupSkin () )
	{
		ri.Con_Printf( PRINT_ALL, "R_AliasDrawModel %s: NULL skin found\n",
			currentmodel->name);
		return;
	}

	r_amodels_drawn++;
	R_AliasSetupLighting ();

	/*
	** select the proper span routine based on translucency
	*/
	// PMM - added double damage shell
	// PMM - reordered to handle blending
	if ( currententity->flags & ( RF_SHELL_RED | RF_SHELL_GREEN | RF_SHELL_BLUE | RF_SHELL_DOUBLE | RF_SHELL_HALF_DAM) )
	{
		int		color;

		// PMM - added double
		color = currententity->flags & ( RF_SHELL_RED | RF_SHELL_GREEN | RF_SHELL_BLUE | RF_SHELL_DOUBLE | RF_SHELL_HALF_DAM);
		// PMM - reordered, new shells after old shells (so they get overriden)

		if ( color == RF_SHELL_RED )
			r_aliasblendcolor = SHELL_RED_COLOR;
		else if ( color == RF_SHELL_GREEN )
			r_aliasblendcolor = SHELL_GREEN_COLOR;
		else if ( color == RF_SHELL_BLUE )
			r_aliasblendcolor = SHELL_BLUE_COLOR;
		else if ( color == (RF_SHELL_RED | RF_SHELL_GREEN) )
			r_aliasblendcolor = SHELL_RG_COLOR;
		else if ( color == (RF_SHELL_RED | RF_SHELL_BLUE) )
			r_aliasblendcolor = SHELL_RB_COLOR;
		else if ( color == (RF_SHELL_BLUE | RF_SHELL_GREEN) )
			r_aliasblendcolor = SHELL_BG_COLOR;
		// PMM - added this .. it's yellowish
		else if ( color == (RF_SHELL_DOUBLE) )
			r_aliasblendcolor = SHELL_DOUBLE_COLOR;
		else if ( color == (RF_SHELL_HALF_DAM) )
			r_aliasblendcolor = SHELL_HALF_DAM_COLOR;
		// pmm
		else
			r_aliasblendcolor = SHELL_WHITE_COLOR;
/*		if ( color & RF_SHELL_RED )
		{
			if ( ( color & RF_SHELL_BLUE) && ( color & RF_SHELL_GREEN) )
				r_aliasblendcolor = SHELL_WHITE_COLOR;
			else if ( color & (RF_SHELL_BLUE | RF_SHELL_DOUBLE))
				r_aliasblendcolor = SHELL_RB_COLOR;
			else
				r_aliasblendcolor = SHELL_RED_COLOR;
		}
		else if ( color & RF_SHELL_BLUE)
		{
			if ( color & RF_SHELL_DOUBLE )
				r_aliasblendcolor = SHELL_CYAN_COLOR;
			else
				r_aliasblendcolor = SHELL_BLUE_COLOR;
		}
		else if ( color & (RF_SHELL_DOUBLE) )
			r_aliasblendcolor = SHELL_DOUBLE_COLOR;
		else if ( color & (RF_SHELL_HALF_DAM) )
			r_aliasblendcolor = SHELL_HALF_DAM_COLOR;
		else if ( color & RF_SHELL_GREEN )
			r_aliasblendcolor = SHELL_GREEN_COLOR;
		else
			r_aliasblendcolor = SHELL_WHITE_COLOR;
*/

		if ( currententity->alpha > 0.33 )
			d_pdrawspans = R_PolysetDrawSpansConstant8_66;
		else
			d_pdrawspans = R_PolysetDrawSpansConstant8_33;
	}
	else if ( currententity->flags & RF_TRANSLUCENT )
	{
		if ( currententity->alpha > 0.66 )
			d_pdrawspans = R_PolysetDrawSpans8_Opaque;
		else if ( currententity->alpha > 0.33 )
			d_pdrawspans = R_PolysetDrawSpans8_66;
		else
			d_pdrawspans = R_PolysetDrawSpans8_33;
	}
	else
	{
		d_pdrawspans = R_PolysetDrawSpans8_Opaque;
	}

	/*
	** compute this_frame and old_frame addresses
	*/
	R_AliasSetUpLerpData( s_pmdl, currententity->backlerp );

	if (currententity->flags & RF_DEPTHHACK)
		s_ziscale = (float)0x8000 * (float)0x10000 * 3.0;
	else
		s_ziscale = (float)0x8000 * (float)0x10000;

	R_AliasPreparePoints ();

	if ( ( currententity->flags & RF_WEAPONMODEL ) && ( r_lefthand->value == 1.0F ) )
	{
		aliasxscale = -aliasxscale;
	}
}



