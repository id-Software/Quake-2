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
// r_edge.c

#include "r_local.h"

#ifndef id386
void R_SurfacePatch (void)
{
}

void R_EdgeCodeStart (void)
{
}

void R_EdgeCodeEnd (void)
{
}
#endif


#if 0
the complex cases add new polys on most lines, so dont optimize for keeping them the same
have multiple free span lists to try to get better coherence?
low depth complexity -- 1 to 3 or so

have a sentinal at both ends?
#endif


edge_t	*auxedges;
edge_t	*r_edges, *edge_p, *edge_max;

surf_t	*surfaces, *surface_p, *surf_max;

// surfaces are generated in back to front order by the bsp, so if a surf
// pointer is greater than another one, it should be drawn in front
// surfaces[1] is the background, and is used as the active surface stack

edge_t	*newedges[MAXHEIGHT];
edge_t	*removeedges[MAXHEIGHT];

espan_t	*span_p, *max_span_p;

int		r_currentkey;

int	current_iv;

int	edge_head_u_shift20, edge_tail_u_shift20;

static void (*pdrawfunc)(void);

edge_t	edge_head;
edge_t	edge_tail;
edge_t	edge_aftertail;
edge_t	edge_sentinel;

float	fv;

static int	miplevel;

float		scale_for_mip;
int			ubasestep, errorterm, erroradjustup, erroradjustdown;

// FIXME: should go away
extern void			R_RotateBmodel (void);
extern void			R_TransformFrustum (void);



void R_GenerateSpans (void);
void R_GenerateSpansBackward (void);

void R_LeadingEdge (edge_t *edge);
void R_LeadingEdgeBackwards (edge_t *edge);
void R_TrailingEdge (surf_t *surf, edge_t *edge);


/*
===============================================================================

EDGE SCANNING

===============================================================================
*/

/*
==============
R_BeginEdgeFrame
==============
*/
void R_BeginEdgeFrame (void)
{
	int		v;

	edge_p = r_edges;
	edge_max = &r_edges[r_numallocatededges];

	surface_p = &surfaces[2];	// background is surface 1,
								//  surface 0 is a dummy
	surfaces[1].spans = NULL;	// no background spans yet
	surfaces[1].flags = SURF_DRAWBACKGROUND;

// put the background behind everything in the world
	if (sw_draworder->value)
	{
		pdrawfunc = R_GenerateSpansBackward;
		surfaces[1].key = 0;
		r_currentkey = 1;
	}
	else
	{
		pdrawfunc = R_GenerateSpans;
		surfaces[1].key = 0x7FFfFFFF;
		r_currentkey = 0;
	}

// FIXME: set with memset
	for (v=r_refdef.vrect.y ; v<r_refdef.vrectbottom ; v++)
	{
		newedges[v] = removeedges[v] = NULL;
	}
}


#if	!id386

/*
==============
R_InsertNewEdges

Adds the edges in the linked list edgestoadd, adding them to the edges in the
linked list edgelist.  edgestoadd is assumed to be sorted on u, and non-empty (this is actually newedges[v]).  edgelist is assumed to be sorted on u, with a
sentinel at the end (actually, this is the active edge table starting at
edge_head.next).
==============
*/
void R_InsertNewEdges (edge_t *edgestoadd, edge_t *edgelist)
{
	edge_t	*next_edge;

	do
	{
		next_edge = edgestoadd->next;
edgesearch:
		if (edgelist->u >= edgestoadd->u)
			goto addedge;
		edgelist=edgelist->next;
		if (edgelist->u >= edgestoadd->u)
			goto addedge;
		edgelist=edgelist->next;
		if (edgelist->u >= edgestoadd->u)
			goto addedge;
		edgelist=edgelist->next;
		if (edgelist->u >= edgestoadd->u)
			goto addedge;
		edgelist=edgelist->next;
		goto edgesearch;

	// insert edgestoadd before edgelist
addedge:
		edgestoadd->next = edgelist;
		edgestoadd->prev = edgelist->prev;
		edgelist->prev->next = edgestoadd;
		edgelist->prev = edgestoadd;
	} while ((edgestoadd = next_edge) != NULL);
}

#endif	// !id386
	

#if	!id386

/*
==============
R_RemoveEdges
==============
*/
void R_RemoveEdges (edge_t *pedge)
{

	do
	{
		pedge->next->prev = pedge->prev;
		pedge->prev->next = pedge->next;
	} while ((pedge = pedge->nextremove) != NULL);
}

#endif	// !id386


#if	!id386

/*
==============
R_StepActiveU
==============
*/
void R_StepActiveU (edge_t *pedge)
{
	edge_t		*pnext_edge, *pwedge;

	while (1)
	{
nextedge:
		pedge->u += pedge->u_step;
		if (pedge->u < pedge->prev->u)
			goto pushback;
		pedge = pedge->next;
			
		pedge->u += pedge->u_step;
		if (pedge->u < pedge->prev->u)
			goto pushback;
		pedge = pedge->next;
			
		pedge->u += pedge->u_step;
		if (pedge->u < pedge->prev->u)
			goto pushback;
		pedge = pedge->next;
			
		pedge->u += pedge->u_step;
		if (pedge->u < pedge->prev->u)
			goto pushback;
		pedge = pedge->next;
			
		goto nextedge;		
		
pushback:
		if (pedge == &edge_aftertail)
			return;
			
	// push it back to keep it sorted		
		pnext_edge = pedge->next;

	// pull the edge out of the edge list
		pedge->next->prev = pedge->prev;
		pedge->prev->next = pedge->next;

	// find out where the edge goes in the edge list
		pwedge = pedge->prev->prev;

		while (pwedge->u > pedge->u)
		{
			pwedge = pwedge->prev;
		}

	// put the edge back into the edge list
		pedge->next = pwedge->next;
		pedge->prev = pwedge;
		pedge->next->prev = pedge;
		pwedge->next = pedge;

		pedge = pnext_edge;
		if (pedge == &edge_tail)
			return;
	}
}

#endif	// !id386


/*
==============
R_CleanupSpan
==============
*/
void R_CleanupSpan (void)
{
	surf_t	*surf;
	int		iu;
	espan_t	*span;

// now that we've reached the right edge of the screen, we're done with any
// unfinished surfaces, so emit a span for whatever's on top
	surf = surfaces[1].next;
	iu = edge_tail_u_shift20;
	if (iu > surf->last_u)
	{
		span = span_p++;
		span->u = surf->last_u;
		span->count = iu - span->u;
		span->v = current_iv;
		span->pnext = surf->spans;
		surf->spans = span;
	}

// reset spanstate for all surfaces in the surface stack
	do
	{
		surf->spanstate = 0;
		surf = surf->next;
	} while (surf != &surfaces[1]);
}


/*
==============
R_LeadingEdgeBackwards
==============
*/
void R_LeadingEdgeBackwards (edge_t *edge)
{
	espan_t			*span;
	surf_t			*surf, *surf2;
	int				iu;

// it's adding a new surface in, so find the correct place
	surf = &surfaces[edge->surfs[1]];

// don't start a span if this is an inverted span, with the end
// edge preceding the start edge (that is, we've already seen the
// end edge)
	if (++surf->spanstate == 1)
	{
		surf2 = surfaces[1].next;

		if (surf->key > surf2->key)
			goto newtop;

	// if it's two surfaces on the same plane, the one that's already
	// active is in front, so keep going unless it's a bmodel
		if (surf->insubmodel && (surf->key == surf2->key))
		{
		// must be two bmodels in the same leaf; don't care, because they'll
		// never be farthest anyway
			goto newtop;
		}

continue_search:

		do
		{
			surf2 = surf2->next;
		} while (surf->key < surf2->key);

		if (surf->key == surf2->key)
		{
		// if it's two surfaces on the same plane, the one that's already
		// active is in front, so keep going unless it's a bmodel
			if (!surf->insubmodel)
				goto continue_search;

		// must be two bmodels in the same leaf; don't care which is really
		// in front, because they'll never be farthest anyway
		}

		goto gotposition;

newtop:
	// emit a span (obscures current top)
		iu = edge->u >> 20;

		if (iu > surf2->last_u)
		{
			span = span_p++;
			span->u = surf2->last_u;
			span->count = iu - span->u;
			span->v = current_iv;
			span->pnext = surf2->spans;
			surf2->spans = span;
		}

		// set last_u on the new span
		surf->last_u = iu;
				
gotposition:
	// insert before surf2
		surf->next = surf2;
		surf->prev = surf2->prev;
		surf2->prev->next = surf;
		surf2->prev = surf;
	}
}


/*
==============
R_TrailingEdge
==============
*/
void R_TrailingEdge (surf_t *surf, edge_t *edge)
{
	espan_t			*span;
	int				iu;

// don't generate a span if this is an inverted span, with the end
// edge preceding the start edge (that is, we haven't seen the
// start edge yet)
	if (--surf->spanstate == 0)
	{
		if (surf == surfaces[1].next)
		{
		// emit a span (current top going away)
			iu = edge->u >> 20;
			if (iu > surf->last_u)
			{
				span = span_p++;
				span->u = surf->last_u;
				span->count = iu - span->u;
				span->v = current_iv;
				span->pnext = surf->spans;
				surf->spans = span;
			}

		// set last_u on the surface below
			surf->next->last_u = iu;
		}

		surf->prev->next = surf->next;
		surf->next->prev = surf->prev;
	}
}


#if	!id386

/*
==============
R_LeadingEdge
==============
*/
void R_LeadingEdge (edge_t *edge)
{
	espan_t			*span;
	surf_t			*surf, *surf2;
	int				iu;
	float			fu, newzi, testzi, newzitop, newzibottom;

	if (edge->surfs[1])
	{
	// it's adding a new surface in, so find the correct place
		surf = &surfaces[edge->surfs[1]];

	// don't start a span if this is an inverted span, with the end
	// edge preceding the start edge (that is, we've already seen the
	// end edge)
		if (++surf->spanstate == 1)
		{
			surf2 = surfaces[1].next;

			if (surf->key < surf2->key)
				goto newtop;

		// if it's two surfaces on the same plane, the one that's already
		// active is in front, so keep going unless it's a bmodel
			if (surf->insubmodel && (surf->key == surf2->key))
			{
			// must be two bmodels in the same leaf; sort on 1/z
				fu = (float)(edge->u - 0xFFFFF) * (1.0 / 0x100000);
				newzi = surf->d_ziorigin + fv*surf->d_zistepv +
						fu*surf->d_zistepu;
				newzibottom = newzi * 0.99;

				testzi = surf2->d_ziorigin + fv*surf2->d_zistepv +
						fu*surf2->d_zistepu;

				if (newzibottom >= testzi)
				{
					goto newtop;
				}

				newzitop = newzi * 1.01;
				if (newzitop >= testzi)
				{
					if (surf->d_zistepu >= surf2->d_zistepu)
					{
						goto newtop;
					}
				}
			}

continue_search:

			do
			{
				surf2 = surf2->next;
			} while (surf->key > surf2->key);

			if (surf->key == surf2->key)
			{
			// if it's two surfaces on the same plane, the one that's already
			// active is in front, so keep going unless it's a bmodel
				if (!surf->insubmodel)
					goto continue_search;

			// must be two bmodels in the same leaf; sort on 1/z
				fu = (float)(edge->u - 0xFFFFF) * (1.0 / 0x100000);
				newzi = surf->d_ziorigin + fv*surf->d_zistepv +
						fu*surf->d_zistepu;
				newzibottom = newzi * 0.99;

				testzi = surf2->d_ziorigin + fv*surf2->d_zistepv +
						fu*surf2->d_zistepu;

				if (newzibottom >= testzi)
				{
					goto gotposition;
				}

				newzitop = newzi * 1.01;
				if (newzitop >= testzi)
				{
					if (surf->d_zistepu >= surf2->d_zistepu)
					{
						goto gotposition;
					}
				}

				goto continue_search;
			}

			goto gotposition;

newtop:
		// emit a span (obscures current top)
			iu = edge->u >> 20;

			if (iu > surf2->last_u)
			{
				span = span_p++;
				span->u = surf2->last_u;
				span->count = iu - span->u;
				span->v = current_iv;
				span->pnext = surf2->spans;
				surf2->spans = span;
			}

			// set last_u on the new span
			surf->last_u = iu;
				
gotposition:
		// insert before surf2
			surf->next = surf2;
			surf->prev = surf2->prev;
			surf2->prev->next = surf;
			surf2->prev = surf;
		}
	}
}


/*
==============
R_GenerateSpans
==============
*/
void R_GenerateSpans (void)
{
	edge_t			*edge;
	surf_t			*surf;

// clear active surfaces to just the background surface
	surfaces[1].next = surfaces[1].prev = &surfaces[1];
	surfaces[1].last_u = edge_head_u_shift20;

// generate spans
	for (edge=edge_head.next ; edge != &edge_tail; edge=edge->next)
	{			
		if (edge->surfs[0])
		{
		// it has a left surface, so a surface is going away for this span
			surf = &surfaces[edge->surfs[0]];

			R_TrailingEdge (surf, edge);

			if (!edge->surfs[1])
				continue;
		}

		R_LeadingEdge (edge);
	}

	R_CleanupSpan ();
}

#endif	// !id386


/*
==============
R_GenerateSpansBackward
==============
*/
void R_GenerateSpansBackward (void)
{
	edge_t			*edge;

// clear active surfaces to just the background surface
	surfaces[1].next = surfaces[1].prev = &surfaces[1];
	surfaces[1].last_u = edge_head_u_shift20;

// generate spans
	for (edge=edge_head.next ; edge != &edge_tail; edge=edge->next)
	{			
		if (edge->surfs[0])
			R_TrailingEdge (&surfaces[edge->surfs[0]], edge);

		if (edge->surfs[1])
			R_LeadingEdgeBackwards (edge);
	}

	R_CleanupSpan ();
}


/*
==============
R_ScanEdges

Input: 
newedges[] array
	this has links to edges, which have links to surfaces

Output:
Each surface has a linked list of its visible spans
==============
*/
void R_ScanEdges (void)
{
	int		iv, bottom;
	byte	basespans[MAXSPANS*sizeof(espan_t)+CACHE_SIZE];
	espan_t	*basespan_p;
	surf_t	*s;

	basespan_p = (espan_t *)
			((long)(basespans + CACHE_SIZE - 1) & ~(CACHE_SIZE - 1));
	max_span_p = &basespan_p[MAXSPANS - r_refdef.vrect.width];

	span_p = basespan_p;

// clear active edges to just the background edges around the whole screen
// FIXME: most of this only needs to be set up once
	edge_head.u = r_refdef.vrect.x << 20;
	edge_head_u_shift20 = edge_head.u >> 20;
	edge_head.u_step = 0;
	edge_head.prev = NULL;
	edge_head.next = &edge_tail;
	edge_head.surfs[0] = 0;
	edge_head.surfs[1] = 1;
	
	edge_tail.u = (r_refdef.vrectright << 20) + 0xFFFFF;
	edge_tail_u_shift20 = edge_tail.u >> 20;
	edge_tail.u_step = 0;
	edge_tail.prev = &edge_head;
	edge_tail.next = &edge_aftertail;
	edge_tail.surfs[0] = 1;
	edge_tail.surfs[1] = 0;
	
	edge_aftertail.u = -1;		// force a move
	edge_aftertail.u_step = 0;
	edge_aftertail.next = &edge_sentinel;
	edge_aftertail.prev = &edge_tail;

// FIXME: do we need this now that we clamp x in r_draw.c?
	edge_sentinel.u = 2000 << 24;		// make sure nothing sorts past this
	edge_sentinel.prev = &edge_aftertail;

//	
// process all scan lines
//
	bottom = r_refdef.vrectbottom - 1;

	for (iv=r_refdef.vrect.y ; iv<bottom ; iv++)
	{
		current_iv = iv;
		fv = (float)iv;

	// mark that the head (background start) span is pre-included
		surfaces[1].spanstate = 1;

		if (newedges[iv])
		{
			R_InsertNewEdges (newedges[iv], edge_head.next);
		}

		(*pdrawfunc) ();

	// flush the span list if we can't be sure we have enough spans left for
	// the next scan
		if (span_p > max_span_p)
		{
			D_DrawSurfaces ();

		// clear the surface span pointers
			for (s = &surfaces[1] ; s<surface_p ; s++)
				s->spans = NULL;

			span_p = basespan_p;
		}

		if (removeedges[iv])
			R_RemoveEdges (removeedges[iv]);

		if (edge_head.next != &edge_tail)
			R_StepActiveU (edge_head.next);
	}

// do the last scan (no need to step or sort or remove on the last scan)

	current_iv = iv;
	fv = (float)iv;

// mark that the head (background start) span is pre-included
	surfaces[1].spanstate = 1;

	if (newedges[iv])
		R_InsertNewEdges (newedges[iv], edge_head.next);

	(*pdrawfunc) ();

// draw whatever's left in the span list
	D_DrawSurfaces ();
}


/*
=========================================================================

SURFACE FILLING

=========================================================================
*/

msurface_t		*pface;
surfcache_t		*pcurrentcache;
vec3_t			transformed_modelorg;
vec3_t			world_transformed_modelorg;
vec3_t			local_modelorg;

/*
=============
D_MipLevelForScale
=============
*/
int D_MipLevelForScale (float scale)
{
	int		lmiplevel;

	if (scale >= d_scalemip[0] )
		lmiplevel = 0;
	else if (scale >= d_scalemip[1] )
		lmiplevel = 1;
	else if (scale >= d_scalemip[2] )
		lmiplevel = 2;
	else
		lmiplevel = 3;

	if (lmiplevel < d_minmip)
		lmiplevel = d_minmip;

	return lmiplevel;
}


/*
==============
D_FlatFillSurface

Simple single color fill with no texture mapping
==============
*/
void D_FlatFillSurface (surf_t *surf, int color)
{
	espan_t	*span;
	byte	*pdest;
	int		u, u2;
	
	for (span=surf->spans ; span ; span=span->pnext)
	{
		pdest = (byte *)d_viewbuffer + r_screenwidth*span->v;
		u = span->u;
		u2 = span->u + span->count - 1;
		for ( ; u <= u2 ; u++)
			pdest[u] = color;
	}
}


/*
==============
D_CalcGradients
==============
*/
void D_CalcGradients (msurface_t *pface)
{
	mplane_t	*pplane;
	float		mipscale;
	vec3_t		p_temp1;
	vec3_t		p_saxis, p_taxis;
	float		t;

	pplane = pface->plane;

	mipscale = 1.0 / (float)(1 << miplevel);

	TransformVector (pface->texinfo->vecs[0], p_saxis);
	TransformVector (pface->texinfo->vecs[1], p_taxis);

	t = xscaleinv * mipscale;
	d_sdivzstepu = p_saxis[0] * t;
	d_tdivzstepu = p_taxis[0] * t;

	t = yscaleinv * mipscale;
	d_sdivzstepv = -p_saxis[1] * t;
	d_tdivzstepv = -p_taxis[1] * t;

	d_sdivzorigin = p_saxis[2] * mipscale - xcenter * d_sdivzstepu -
			ycenter * d_sdivzstepv;
	d_tdivzorigin = p_taxis[2] * mipscale - xcenter * d_tdivzstepu -
			ycenter * d_tdivzstepv;

	VectorScale (transformed_modelorg, mipscale, p_temp1);

	t = 0x10000*mipscale;
	sadjust = ((fixed16_t)(DotProduct (p_temp1, p_saxis) * 0x10000 + 0.5)) -
			((pface->texturemins[0] << 16) >> miplevel)
			+ pface->texinfo->vecs[0][3]*t;
	tadjust = ((fixed16_t)(DotProduct (p_temp1, p_taxis) * 0x10000 + 0.5)) -
			((pface->texturemins[1] << 16) >> miplevel)
			+ pface->texinfo->vecs[1][3]*t;

	// PGM - changing flow speed for non-warping textures.
	if (pface->texinfo->flags & SURF_FLOWING)
	{
		if(pface->texinfo->flags & SURF_WARP)
			sadjust += 0x10000 * (-128 * ( (r_newrefdef.time * 0.25) - (int)(r_newrefdef.time * 0.25) ));
		else
			sadjust += 0x10000 * (-128 * ( (r_newrefdef.time * 0.77) - (int)(r_newrefdef.time * 0.77) ));
	}
	// PGM

//
// -1 (-epsilon) so we never wander off the edge of the texture
//
	bbextents = ((pface->extents[0] << 16) >> miplevel) - 1;
	bbextentt = ((pface->extents[1] << 16) >> miplevel) - 1;
}


/*
==============
D_BackgroundSurf

The grey background filler seen when there is a hole in the map
==============
*/
void D_BackgroundSurf (surf_t *s)
{
// set up a gradient for the background surface that places it
// effectively at infinity distance from the viewpoint
	d_zistepu = 0;
	d_zistepv = 0;
	d_ziorigin = -0.9;

	D_FlatFillSurface (s, (int)sw_clearcolor->value & 0xFF);
	D_DrawZSpans (s->spans);
}

/*
=================
D_TurbulentSurf
=================
*/
void D_TurbulentSurf (surf_t *s)
{
	d_zistepu = s->d_zistepu;
	d_zistepv = s->d_zistepv;
	d_ziorigin = s->d_ziorigin;

	pface = s->msurf;
	miplevel = 0;
	cacheblock = pface->texinfo->image->pixels[0];
	cachewidth = 64;

	if (s->insubmodel)
	{
	// FIXME: we don't want to do all this for every polygon!
	// TODO: store once at start of frame
		currententity = s->entity;	//FIXME: make this passed in to
									// R_RotateBmodel ()
		VectorSubtract (r_origin, currententity->origin,
				local_modelorg);
		TransformVector (local_modelorg, transformed_modelorg);

		R_RotateBmodel ();	// FIXME: don't mess with the frustum,
							// make entity passed in
	}

	D_CalcGradients (pface);

//============
//PGM
	// textures that aren't warping are just flowing. Use NonTurbulent8 instead
	if(!(pface->texinfo->flags & SURF_WARP))
		NonTurbulent8 (s->spans);
	else
		Turbulent8 (s->spans);
//PGM
//============

	D_DrawZSpans (s->spans);

	if (s->insubmodel)
	{
	//
	// restore the old drawing state
	// FIXME: we don't want to do this every time!
	// TODO: speed up
	//
		currententity = NULL;	// &r_worldentity;
		VectorCopy (world_transformed_modelorg,
					transformed_modelorg);
		VectorCopy (base_vpn, vpn);
		VectorCopy (base_vup, vup);
		VectorCopy (base_vright, vright);
		R_TransformFrustum ();
	}
}

/*
==============
D_SkySurf
==============
*/
void D_SkySurf (surf_t *s)
{
	pface = s->msurf;
	miplevel = 0;
	if (!pface->texinfo->image)
		return;
	cacheblock = pface->texinfo->image->pixels[0];
	cachewidth = 256;

	d_zistepu = s->d_zistepu;
	d_zistepv = s->d_zistepv;
	d_ziorigin = s->d_ziorigin;

	D_CalcGradients (pface);

	D_DrawSpans16 (s->spans);

// set up a gradient for the background surface that places it
// effectively at infinity distance from the viewpoint
	d_zistepu = 0;
	d_zistepv = 0;
	d_ziorigin = -0.9;

	D_DrawZSpans (s->spans);
}

/*
==============
D_SolidSurf

Normal surface cached, texture mapped surface
==============
*/
void D_SolidSurf (surf_t *s)
{
	d_zistepu = s->d_zistepu;
	d_zistepv = s->d_zistepv;
	d_ziorigin = s->d_ziorigin;

	if (s->insubmodel)
	{
	// FIXME: we don't want to do all this for every polygon!
	// TODO: store once at start of frame
		currententity = s->entity;	//FIXME: make this passed in to
									// R_RotateBmodel ()
		VectorSubtract (r_origin, currententity->origin, local_modelorg);
		TransformVector (local_modelorg, transformed_modelorg);

		R_RotateBmodel ();	// FIXME: don't mess with the frustum,
							// make entity passed in
	}
	else
		currententity = &r_worldentity;

	pface = s->msurf;
#if 1
	miplevel = D_MipLevelForScale(s->nearzi * scale_for_mip * pface->texinfo->mipadjust);
#else
	{
		float dot;
		float normal[3];

		if ( s->insubmodel )
		{
			VectorCopy( pface->plane->normal, normal );
//			TransformVector( pface->plane->normal, normal);
			dot = DotProduct( normal, vpn );
		}
		else
		{
			VectorCopy( pface->plane->normal, normal );
			dot = DotProduct( normal, vpn );
		}

		if ( pface->flags & SURF_PLANEBACK )
			dot = -dot;

		if ( dot > 0 )
			printf( "blah" );

		miplevel = D_MipLevelForScale(s->nearzi * scale_for_mip * pface->texinfo->mipadjust);
	}
#endif

// FIXME: make this passed in to D_CacheSurface
	pcurrentcache = D_CacheSurface (pface, miplevel);

	cacheblock = (pixel_t *)pcurrentcache->data;
	cachewidth = pcurrentcache->width;

	D_CalcGradients (pface);

	D_DrawSpans16 (s->spans);

	D_DrawZSpans (s->spans);

	if (s->insubmodel)
	{
	//
	// restore the old drawing state
	// FIXME: we don't want to do this every time!
	// TODO: speed up
	//
		VectorCopy (world_transformed_modelorg,
					transformed_modelorg);
		VectorCopy (base_vpn, vpn);
		VectorCopy (base_vup, vup);
		VectorCopy (base_vright, vright);
		R_TransformFrustum ();
		currententity = NULL;	//&r_worldentity;
	}
}

/*
=============
D_DrawflatSurfaces

To allow developers to see the polygon carving of the world
=============
*/
void D_DrawflatSurfaces (void)
{
	surf_t			*s;

	for (s = &surfaces[1] ; s<surface_p ; s++)
	{
		if (!s->spans)
			continue;

		d_zistepu = s->d_zistepu;
		d_zistepv = s->d_zistepv;
		d_ziorigin = s->d_ziorigin;

		// make a stable color for each surface by taking the low
		// bits of the msurface pointer
		D_FlatFillSurface (s, (int)s->msurf & 0xFF);
		D_DrawZSpans (s->spans);
	}
}

/*
==============
D_DrawSurfaces

Rasterize all the span lists.  Guaranteed zero overdraw.
May be called more than once a frame if the surf list overflows (higher res)
==============
*/
void D_DrawSurfaces (void)
{
	surf_t			*s;

//	currententity = NULL;	//&r_worldentity;
	VectorSubtract (r_origin, vec3_origin, modelorg);
	TransformVector (modelorg, transformed_modelorg);
	VectorCopy (transformed_modelorg, world_transformed_modelorg);

	if (!sw_drawflat->value)
	{
		for (s = &surfaces[1] ; s<surface_p ; s++)
		{
			if (!s->spans)
				continue;

			r_drawnpolycount++;

			if (! (s->flags & (SURF_DRAWSKYBOX|SURF_DRAWBACKGROUND|SURF_DRAWTURB) ) )
				D_SolidSurf (s);
			else if (s->flags & SURF_DRAWSKYBOX)
				D_SkySurf (s);
			else if (s->flags & SURF_DRAWBACKGROUND)
				D_BackgroundSurf (s);
			else if (s->flags & SURF_DRAWTURB)
				D_TurbulentSurf (s);
		}
	}
	else
		D_DrawflatSurfaces ();

	currententity = NULL;	//&r_worldentity;
	VectorSubtract (r_origin, vec3_origin, modelorg);
	R_TransformFrustum ();
}

