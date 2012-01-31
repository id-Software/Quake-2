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
// r_aclip.c: clip routines for drawing Alias models directly to the screen

#include "r_local.h"

static finalvert_t		fv[2][8];

void R_AliasProjectAndClipTestFinalVert (finalvert_t *fv);
void R_Alias_clip_top (finalvert_t *pfv0, finalvert_t *pfv1,
	finalvert_t *out);
void R_Alias_clip_bottom (finalvert_t *pfv0, finalvert_t *pfv1,
	finalvert_t *out);
void R_Alias_clip_left (finalvert_t *pfv0, finalvert_t *pfv1,
	finalvert_t *out);
void R_Alias_clip_right (finalvert_t *pfv0, finalvert_t *pfv1,
	finalvert_t *out);


/*
================
R_Alias_clip_z

pfv0 is the unclipped vertex, pfv1 is the z-clipped vertex
================
*/
void R_Alias_clip_z (finalvert_t *pfv0, finalvert_t *pfv1, finalvert_t *out)
{
	float		scale;

	scale = (ALIAS_Z_CLIP_PLANE - pfv0->xyz[2]) /
			(pfv1->xyz[2] - pfv0->xyz[2]);

	out->xyz[0] = pfv0->xyz[0] + (pfv1->xyz[0] - pfv0->xyz[0]) * scale;
	out->xyz[1] = pfv0->xyz[1] + (pfv1->xyz[1] - pfv0->xyz[1]) * scale;
	out->xyz[2] = ALIAS_Z_CLIP_PLANE;

	out->s =	pfv0->s + (pfv1->s - pfv0->s) * scale;
	out->t =	pfv0->t + (pfv1->t - pfv0->t) * scale;
	out->l =	pfv0->l + (pfv1->l - pfv0->l) * scale;

	R_AliasProjectAndClipTestFinalVert (out);
}


#if	!id386

void R_Alias_clip_left (finalvert_t *pfv0, finalvert_t *pfv1, finalvert_t *out)
{
	float		scale;

	if (pfv0->v >= pfv1->v )
	{
		scale = (float)(r_refdef.aliasvrect.x - pfv0->u) /
				(pfv1->u - pfv0->u);
		out->u  = pfv0->u  + ( pfv1->u  - pfv0->u ) * scale + 0.5;
		out->v  = pfv0->v  + ( pfv1->v  - pfv0->v ) * scale + 0.5;
		out->s  = pfv0->s  + ( pfv1->s  - pfv0->s ) * scale + 0.5;
		out->t  = pfv0->t  + ( pfv1->t  - pfv0->t ) * scale + 0.5;
		out->l  = pfv0->l  + ( pfv1->l  - pfv0->l ) * scale + 0.5;
		out->zi = pfv0->zi + ( pfv1->zi - pfv0->zi) * scale + 0.5;
	}
	else
	{
		scale = (float)(r_refdef.aliasvrect.x - pfv1->u) /
				(pfv0->u - pfv1->u);
		out->u  = pfv1->u  + ( pfv0->u  - pfv1->u ) * scale + 0.5;
		out->v  = pfv1->v  + ( pfv0->v  - pfv1->v ) * scale + 0.5;
		out->s  = pfv1->s  + ( pfv0->s  - pfv1->s ) * scale + 0.5;
		out->t  = pfv1->t  + ( pfv0->t  - pfv1->t ) * scale + 0.5;
		out->l  = pfv1->l  + ( pfv0->l  - pfv1->l ) * scale + 0.5;
		out->zi = pfv1->zi + ( pfv0->zi - pfv1->zi) * scale + 0.5;
	}
}


void R_Alias_clip_right (finalvert_t *pfv0, finalvert_t *pfv1, finalvert_t *out)
{
	float		scale;

	if ( pfv0->v >= pfv1->v )
	{
		scale = (float)(r_refdef.aliasvrectright - pfv0->u ) /
				(pfv1->u - pfv0->u );
		out->u  = pfv0->u  + ( pfv1->u  - pfv0->u ) * scale + 0.5;
		out->v  = pfv0->v  + ( pfv1->v  - pfv0->v ) * scale + 0.5;
		out->s  = pfv0->s  + ( pfv1->s  - pfv0->s ) * scale + 0.5;
		out->t  = pfv0->t  + ( pfv1->t  - pfv0->t ) * scale + 0.5;
		out->l  = pfv0->l  + ( pfv1->l  - pfv0->l ) * scale + 0.5;
		out->zi = pfv0->zi + ( pfv1->zi - pfv0->zi) * scale + 0.5;
	}
	else
	{
		scale = (float)(r_refdef.aliasvrectright - pfv1->u ) /
				(pfv0->u - pfv1->u );
		out->u  = pfv1->u  + ( pfv0->u  - pfv1->u ) * scale + 0.5;
		out->v  = pfv1->v  + ( pfv0->v  - pfv1->v ) * scale + 0.5;
		out->s  = pfv1->s  + ( pfv0->s  - pfv1->s ) * scale + 0.5;
		out->t  = pfv1->t  + ( pfv0->t  - pfv1->t ) * scale + 0.5;
		out->l  = pfv1->l  + ( pfv0->l  - pfv1->l ) * scale + 0.5;
		out->zi = pfv1->zi + ( pfv0->zi - pfv1->zi) * scale + 0.5;
	}
}


void R_Alias_clip_top (finalvert_t *pfv0, finalvert_t *pfv1, finalvert_t *out)
{
	float		scale;

	if (pfv0->v >= pfv1->v)
	{
		scale = (float)(r_refdef.aliasvrect.y - pfv0->v) /
				(pfv1->v - pfv0->v);
		out->u  = pfv0->u  + ( pfv1->u  - pfv0->u ) * scale + 0.5;
		out->v  = pfv0->v  + ( pfv1->v  - pfv0->v ) * scale + 0.5;
		out->s  = pfv0->s  + ( pfv1->s  - pfv0->s ) * scale + 0.5;
		out->t  = pfv0->t  + ( pfv1->t  - pfv0->t ) * scale + 0.5;
		out->l  = pfv0->l  + ( pfv1->l  - pfv0->l ) * scale + 0.5;
		out->zi = pfv0->zi + ( pfv1->zi - pfv0->zi) * scale + 0.5;
	}
	else
	{
		scale = (float)(r_refdef.aliasvrect.y - pfv1->v) /
				(pfv0->v - pfv1->v);
		out->u  = pfv1->u  + ( pfv0->u  - pfv1->u ) * scale + 0.5;
		out->v  = pfv1->v  + ( pfv0->v  - pfv1->v ) * scale + 0.5;
		out->s  = pfv1->s  + ( pfv0->s  - pfv1->s ) * scale + 0.5;
		out->t  = pfv1->t  + ( pfv0->t  - pfv1->t ) * scale + 0.5;
		out->l  = pfv1->l  + ( pfv0->l  - pfv1->l ) * scale + 0.5;
		out->zi = pfv1->zi + ( pfv0->zi - pfv1->zi) * scale + 0.5;
	}
}


void R_Alias_clip_bottom (finalvert_t *pfv0, finalvert_t *pfv1,
	finalvert_t *out)
{
	float		scale;

	if (pfv0->v >= pfv1->v)
	{
		scale = (float)(r_refdef.aliasvrectbottom - pfv0->v) /
				(pfv1->v - pfv0->v);

		out->u  = pfv0->u  + ( pfv1->u  - pfv0->u ) * scale + 0.5;
		out->v  = pfv0->v  + ( pfv1->v  - pfv0->v ) * scale + 0.5;
		out->s  = pfv0->s  + ( pfv1->s  - pfv0->s ) * scale + 0.5;
		out->t  = pfv0->t  + ( pfv1->t  - pfv0->t ) * scale + 0.5;
		out->l  = pfv0->l  + ( pfv1->l  - pfv0->l ) * scale + 0.5;
		out->zi = pfv0->zi + ( pfv1->zi - pfv0->zi) * scale + 0.5;
	}
	else
	{
		scale = (float)(r_refdef.aliasvrectbottom - pfv1->v) /
				(pfv0->v - pfv1->v);

		out->u  = pfv1->u  + ( pfv0->u  - pfv1->u ) * scale + 0.5;
		out->v  = pfv1->v  + ( pfv0->v  - pfv1->v ) * scale + 0.5;
		out->s  = pfv1->s  + ( pfv0->s  - pfv1->s ) * scale + 0.5;
		out->t  = pfv1->t  + ( pfv0->t  - pfv1->t ) * scale + 0.5;
		out->l  = pfv1->l  + ( pfv0->l  - pfv1->l ) * scale + 0.5;
		out->zi = pfv1->zi + ( pfv0->zi - pfv1->zi) * scale + 0.5;
	}
}

#endif


int R_AliasClip (finalvert_t *in, finalvert_t *out, int flag, int count,
	void(*clip)(finalvert_t *pfv0, finalvert_t *pfv1, finalvert_t *out) )
{
	int			i,j,k;
	int			flags, oldflags;
	
	j = count-1;
	k = 0;
	for (i=0 ; i<count ; j = i, i++)
	{
		oldflags = in[j].flags & flag;
		flags = in[i].flags & flag;

		if (flags && oldflags)
			continue;
		if (oldflags ^ flags)
		{
			clip (&in[j], &in[i], &out[k]);
			out[k].flags = 0;
			if (out[k].u < r_refdef.aliasvrect.x)
				out[k].flags |= ALIAS_LEFT_CLIP;
			if (out[k].v < r_refdef.aliasvrect.y)
				out[k].flags |= ALIAS_TOP_CLIP;
			if (out[k].u > r_refdef.aliasvrectright)
				out[k].flags |= ALIAS_RIGHT_CLIP;
			if (out[k].v > r_refdef.aliasvrectbottom)
				out[k].flags |= ALIAS_BOTTOM_CLIP;	
			k++;
		}
		if (!flags)
		{
			out[k] = in[i];
			k++;
		}
	}
	
	return k;
}


/*
================
R_AliasClipTriangle
================
*/
void R_AliasClipTriangle (finalvert_t *index0, finalvert_t *index1, finalvert_t *index2)
{
	int				i, k, pingpong;
	unsigned		clipflags;

// copy vertexes and fix seam texture coordinates
	fv[0][0] = *index0;
	fv[0][1] = *index1;
	fv[0][2] = *index2;

// clip
	clipflags = fv[0][0].flags | fv[0][1].flags | fv[0][2].flags;

	if (clipflags & ALIAS_Z_CLIP)
	{
		k = R_AliasClip (fv[0], fv[1], ALIAS_Z_CLIP, 3, R_Alias_clip_z);
		if (k == 0)
			return;

		pingpong = 1;
		clipflags = fv[1][0].flags | fv[1][1].flags | fv[1][2].flags;
	}
	else
	{
		pingpong = 0;
		k = 3;
	}

	if (clipflags & ALIAS_LEFT_CLIP)
	{
		k = R_AliasClip (fv[pingpong], fv[pingpong ^ 1],
							ALIAS_LEFT_CLIP, k, R_Alias_clip_left);
		if (k == 0)
			return;

		pingpong ^= 1;
	}

	if (clipflags & ALIAS_RIGHT_CLIP)
	{
		k = R_AliasClip (fv[pingpong], fv[pingpong ^ 1],
							ALIAS_RIGHT_CLIP, k, R_Alias_clip_right);
		if (k == 0)
			return;

		pingpong ^= 1;
	}

	if (clipflags & ALIAS_BOTTOM_CLIP)
	{
		k = R_AliasClip (fv[pingpong], fv[pingpong ^ 1],
							ALIAS_BOTTOM_CLIP, k, R_Alias_clip_bottom);
		if (k == 0)
			return;

		pingpong ^= 1;
	}

	if (clipflags & ALIAS_TOP_CLIP)
	{
		k = R_AliasClip (fv[pingpong], fv[pingpong ^ 1],
							ALIAS_TOP_CLIP, k, R_Alias_clip_top);
		if (k == 0)
			return;

		pingpong ^= 1;
	}

	for (i=0 ; i<k ; i++)
	{
		if (fv[pingpong][i].u < r_refdef.aliasvrect.x)
			fv[pingpong][i].u = r_refdef.aliasvrect.x;
		else if (fv[pingpong][i].u > r_refdef.aliasvrectright)
			fv[pingpong][i].u = r_refdef.aliasvrectright;

		if (fv[pingpong][i].v < r_refdef.aliasvrect.y)
			fv[pingpong][i].v = r_refdef.aliasvrect.y;
		else if (fv[pingpong][i].v > r_refdef.aliasvrectbottom)
			fv[pingpong][i].v = r_refdef.aliasvrectbottom;

		fv[pingpong][i].flags = 0;
	}

// draw triangles
	for (i=1 ; i<k-1 ; i++)
	{
		aliastriangleparms.a = &fv[pingpong][0];
		aliastriangleparms.b = &fv[pingpong][i];
		aliastriangleparms.c = &fv[pingpong][i+1];
		R_DrawTriangle();
	}
}

