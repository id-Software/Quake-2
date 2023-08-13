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
// r_rast.c

#include <assert.h>

#include "r_local.h"

#define MAXLEFTCLIPEDGES		100

// !!! if these are changed, they must be changed in asm_draw.h too !!!
#define FULLY_CLIPPED_CACHED	0x80000000
#define FRAMECOUNT_MASK			0x7FFFFFFF

unsigned int	cacheoffset;

int			c_faceclip;					// number of faces clipped


clipplane_t	*entity_clipplanes;
clipplane_t	view_clipplanes[4];
clipplane_t	world_clipplanes[16];

medge_t			*r_pedge;

qboolean		r_leftclipped, r_rightclipped;
static qboolean	makeleftedge, makerightedge;
qboolean		r_nearzionly;

int		sintable[1280];
int		intsintable[1280];
int		blanktable[1280];		// PGM

mvertex_t	r_leftenter, r_leftexit;
mvertex_t	r_rightenter, r_rightexit;

typedef struct
{
	float	u,v;
	int		ceilv;
} evert_t;

int				r_emitted;
float			r_nearzi;
float			r_u1, r_v1, r_lzi1;
int				r_ceilv1;

qboolean		r_lastvertvalid;
int				r_skyframe;

msurface_t		*r_skyfaces;
mplane_t		r_skyplanes[6];
mtexinfo_t		r_skytexinfo[6];
mvertex_t		*r_skyverts;
medge_t			*r_skyedges;
int				*r_skysurfedges;

// I just copied this data from a box map...
int skybox_planes[12] = {2,-128, 0,-128, 2,128, 1,128, 0,128, 1,-128};

int box_surfedges[24] = { 1,2,3,4,  -1,5,6,7,  8,9,-6,10,  -2,-7,-9,11,
  12,-3,-11,-8,  -12,-10,-5,-4};
int box_edges[24] = { 1,2, 2,3, 3,4, 4,1, 1,5, 5,6, 6,2, 7,8, 8,6, 5,7, 8,3, 7,4};

int	box_faces[6] = {0,0,2,2,2,0};

vec3_t	box_vecs[6][2] = {
	{	{0,-1,0}, {-1,0,0} },
	{ {0,1,0}, {0,0,-1} },
	{	{0,-1,0}, {1,0,0} },
	{ {1,0,0}, {0,0,-1} },
	{ {0,-1,0}, {0,0,-1} },
	{ {-1,0,0}, {0,0,-1} }
};

float	box_verts[8][3] = {
	{-1,-1,-1},
	{-1,1,-1},
	{1,1,-1},
	{1,-1,-1},
	{-1,-1,1},
	{-1,1,1},
	{1,-1,1},
	{1,1,1}
};

// down, west, up, north, east, south
// {"rt", "bk", "lf", "ft", "up", "dn"};

/*
================
R_InitSkyBox

================
*/
void R_InitSkyBox (void)
{
	int		i;
	extern model_t *loadmodel;

	r_skyfaces = loadmodel->surfaces + loadmodel->numsurfaces;
	loadmodel->numsurfaces += 6;
	r_skyverts = loadmodel->vertexes + loadmodel->numvertexes;
	loadmodel->numvertexes += 8;
	r_skyedges = loadmodel->edges + loadmodel->numedges;
	loadmodel->numedges += 12;
	r_skysurfedges = loadmodel->surfedges + loadmodel->numsurfedges;
	loadmodel->numsurfedges += 24;
	if (loadmodel->numsurfaces > MAX_MAP_FACES
		|| loadmodel->numvertexes > MAX_MAP_VERTS
		|| loadmodel->numedges > MAX_MAP_EDGES)
		ri.Sys_Error (ERR_DROP, "InitSkyBox: map overflow");

	memset (r_skyfaces, 0, 6*sizeof(*r_skyfaces));
	for (i=0 ; i<6 ; i++)
	{
		r_skyplanes[i].normal[skybox_planes[i*2]] = 1;
		r_skyplanes[i].dist = skybox_planes[i*2+1];

		VectorCopy (box_vecs[i][0], r_skytexinfo[i].vecs[0]);
		VectorCopy (box_vecs[i][1], r_skytexinfo[i].vecs[1]);

		r_skyfaces[i].plane = &r_skyplanes[i];
		r_skyfaces[i].numedges = 4;
		r_skyfaces[i].flags = box_faces[i] | SURF_DRAWSKYBOX;
		r_skyfaces[i].firstedge = loadmodel->numsurfedges-24+i*4;
		r_skyfaces[i].texinfo = &r_skytexinfo[i];
		r_skyfaces[i].texturemins[0] = -128;
		r_skyfaces[i].texturemins[1] = -128;
		r_skyfaces[i].extents[0] = 256;
		r_skyfaces[i].extents[1] = 256;
	}

	for (i=0 ; i<24 ; i++)
		if (box_surfedges[i] > 0)
			r_skysurfedges[i] = loadmodel->numedges-13 + box_surfedges[i];
		else
			r_skysurfedges[i] = - (loadmodel->numedges-13 + -box_surfedges[i]);

	for(i=0 ; i<12 ; i++)
	{
		r_skyedges[i].v[0] = loadmodel->numvertexes-9+box_edges[i*2+0];
		r_skyedges[i].v[1] = loadmodel->numvertexes-9+box_edges[i*2+1];
		r_skyedges[i].cachededgeoffset = 0;
	}
}

/*
================
R_EmitSkyBox
================
*/
void R_EmitSkyBox (void)
{
	int		i, j;
	int		oldkey;

	if (insubmodel)
		return;		// submodels should never have skies
	if (r_skyframe == r_framecount)
		return;		// already set this frame

	r_skyframe = r_framecount;

	// set the eight fake vertexes
	for (i=0 ; i<8 ; i++)
		for (j=0 ; j<3 ; j++)
			r_skyverts[i].position[j] = r_origin[j] + box_verts[i][j]*128;

	// set the six fake planes
	for (i=0 ; i<6 ; i++)
		if (skybox_planes[i*2+1] > 0)
			r_skyplanes[i].dist = r_origin[skybox_planes[i*2]]+128;
		else
			r_skyplanes[i].dist = r_origin[skybox_planes[i*2]]-128;

	// fix texture offseets
	for (i=0 ; i<6 ; i++)
	{
		r_skytexinfo[i].vecs[0][3] = -DotProduct (r_origin, r_skytexinfo[i].vecs[0]);
		r_skytexinfo[i].vecs[1][3] = -DotProduct (r_origin, r_skytexinfo[i].vecs[1]);
	}

	// emit the six faces
	oldkey = r_currentkey;
	r_currentkey = 0x7ffffff0;
 	for (i=0 ; i<6 ; i++)
	{
		R_RenderFace (r_skyfaces + i, 15);
	}
	r_currentkey = oldkey;		// bsp sorting order
}


#if	!id386

/*
================
R_EmitEdge
================
*/
void R_EmitEdge (mvertex_t *pv0, mvertex_t *pv1)
{
	edge_t	*edge, *pcheck;
	int		u_check;
	float	u, u_step;
	vec3_t	local, transformed;
	float	*world;
	int		v, v2, ceilv0;
	float	scale, lzi0, u0, v0;
	int		side;

	if (r_lastvertvalid)
	{
		u0 = r_u1;
		v0 = r_v1;
		lzi0 = r_lzi1;
		ceilv0 = r_ceilv1;
	}
	else
	{
		world = &pv0->position[0];
	
	// transform and project
		VectorSubtract (world, modelorg, local);
		TransformVector (local, transformed);
	
		if (transformed[2] < NEAR_CLIP)
			transformed[2] = NEAR_CLIP;
	
		lzi0 = 1.0 / transformed[2];
	
	// FIXME: build x/yscale into transform?
		scale = xscale * lzi0;
		u0 = (xcenter + scale*transformed[0]);
		if (u0 < r_refdef.fvrectx_adj)
			u0 = r_refdef.fvrectx_adj;
		if (u0 > r_refdef.fvrectright_adj)
			u0 = r_refdef.fvrectright_adj;
	
		scale = yscale * lzi0;
		v0 = (ycenter - scale*transformed[1]);
		if (v0 < r_refdef.fvrecty_adj)
			v0 = r_refdef.fvrecty_adj;
		if (v0 > r_refdef.fvrectbottom_adj)
			v0 = r_refdef.fvrectbottom_adj;
	
		ceilv0 = (int) ceil(v0);
	}

	world = &pv1->position[0];

// transform and project
	VectorSubtract (world, modelorg, local);
	TransformVector (local, transformed);

	if (transformed[2] < NEAR_CLIP)
		transformed[2] = NEAR_CLIP;

	r_lzi1 = 1.0 / transformed[2];

	scale = xscale * r_lzi1;
	r_u1 = (xcenter + scale*transformed[0]);
	if (r_u1 < r_refdef.fvrectx_adj)
		r_u1 = r_refdef.fvrectx_adj;
	if (r_u1 > r_refdef.fvrectright_adj)
		r_u1 = r_refdef.fvrectright_adj;

	scale = yscale * r_lzi1;
	r_v1 = (ycenter - scale*transformed[1]);
	if (r_v1 < r_refdef.fvrecty_adj)
		r_v1 = r_refdef.fvrecty_adj;
	if (r_v1 > r_refdef.fvrectbottom_adj)
		r_v1 = r_refdef.fvrectbottom_adj;

	if (r_lzi1 > lzi0)
		lzi0 = r_lzi1;

	if (lzi0 > r_nearzi)	// for mipmap finding
		r_nearzi = lzi0;

// for right edges, all we want is the effect on 1/z
	if (r_nearzionly)
		return;

	r_emitted = 1;

	r_ceilv1 = (int) ceil(r_v1);


// create the edge
	if (ceilv0 == r_ceilv1)
	{
	// we cache unclipped horizontal edges as fully clipped
		if (cacheoffset != 0x7FFFFFFF)
		{
			cacheoffset = FULLY_CLIPPED_CACHED |
					(r_framecount & FRAMECOUNT_MASK);
		}

		return;		// horizontal edge
	}

	side = ceilv0 > r_ceilv1;

	edge = edge_p++;

	edge->owner = r_pedge;

	edge->nearzi = lzi0;

	if (side == 0)
	{
	// trailing edge (go from p1 to p2)
		v = ceilv0;
		v2 = r_ceilv1 - 1;

		edge->surfs[0] = surface_p - surfaces;
		edge->surfs[1] = 0;

		u_step = ((r_u1 - u0) / (r_v1 - v0));
		u = u0 + ((float)v - v0) * u_step;
	}
	else
	{
	// leading edge (go from p2 to p1)
		v2 = ceilv0 - 1;
		v = r_ceilv1;

		edge->surfs[0] = 0;
		edge->surfs[1] = surface_p - surfaces;

		u_step = ((u0 - r_u1) / (v0 - r_v1));
		u = r_u1 + ((float)v - r_v1) * u_step;
	}

	edge->u_step = u_step*0x100000;
	edge->u = u*0x100000 + 0xFFFFF;

// we need to do this to avoid stepping off the edges if a very nearly
// horizontal edge is less than epsilon above a scan, and numeric error causes
// it to incorrectly extend to the scan, and the extension of the line goes off
// the edge of the screen
// FIXME: is this actually needed?
	if (edge->u < r_refdef.vrect_x_adj_shift20)
		edge->u = r_refdef.vrect_x_adj_shift20;
	if (edge->u > r_refdef.vrectright_adj_shift20)
		edge->u = r_refdef.vrectright_adj_shift20;

//
// sort the edge in normally
//
	u_check = edge->u;
	if (edge->surfs[0])
		u_check++;	// sort trailers after leaders

	if (!newedges[v] || newedges[v]->u >= u_check)
	{
		edge->next = newedges[v];
		newedges[v] = edge;
	}
	else
	{
		pcheck = newedges[v];
		while (pcheck->next && pcheck->next->u < u_check)
			pcheck = pcheck->next;
		edge->next = pcheck->next;
		pcheck->next = edge;
	}

	edge->nextremove = removeedges[v2];
	removeedges[v2] = edge;
}


/*
================
R_ClipEdge
================
*/
void R_ClipEdge (mvertex_t *pv0, mvertex_t *pv1, clipplane_t *clip)
{
	float		d0, d1, f;
	mvertex_t	clipvert;

	if (clip)
	{
		do
		{
			d0 = DotProduct (pv0->position, clip->normal) - clip->dist;
			d1 = DotProduct (pv1->position, clip->normal) - clip->dist;

			if (d0 >= 0)
			{
			// point 0 is unclipped
				if (d1 >= 0)
				{
				// both points are unclipped
					continue;
				}

			// only point 1 is clipped

			// we don't cache clipped edges
				cacheoffset = 0x7FFFFFFF;

				f = d0 / (d0 - d1);
				clipvert.position[0] = pv0->position[0] +
						f * (pv1->position[0] - pv0->position[0]);
				clipvert.position[1] = pv0->position[1] +
						f * (pv1->position[1] - pv0->position[1]);
				clipvert.position[2] = pv0->position[2] +
						f * (pv1->position[2] - pv0->position[2]);

				if (clip->leftedge)
				{
					r_leftclipped = true;
					r_leftexit = clipvert;
				}
				else if (clip->rightedge)
				{
					r_rightclipped = true;
					r_rightexit = clipvert;
				}

				R_ClipEdge (pv0, &clipvert, clip->next);
				return;
			}
			else
			{
			// point 0 is clipped
				if (d1 < 0)
				{
				// both points are clipped
				// we do cache fully clipped edges
					if (!r_leftclipped)
						cacheoffset = FULLY_CLIPPED_CACHED |
								(r_framecount & FRAMECOUNT_MASK);
					return;
				}

			// only point 0 is clipped
				r_lastvertvalid = false;

			// we don't cache partially clipped edges
				cacheoffset = 0x7FFFFFFF;

				f = d0 / (d0 - d1);
				clipvert.position[0] = pv0->position[0] +
						f * (pv1->position[0] - pv0->position[0]);
				clipvert.position[1] = pv0->position[1] +
						f * (pv1->position[1] - pv0->position[1]);
				clipvert.position[2] = pv0->position[2] +
						f * (pv1->position[2] - pv0->position[2]);

				if (clip->leftedge)
				{
					r_leftclipped = true;
					r_leftenter = clipvert;
				}
				else if (clip->rightedge)
				{
					r_rightclipped = true;
					r_rightenter = clipvert;
				}

				R_ClipEdge (&clipvert, pv1, clip->next);
				return;
			}
		} while ((clip = clip->next) != NULL);
	}

// add the edge
	R_EmitEdge (pv0, pv1);
}

#endif	// !id386


/*
================
R_EmitCachedEdge
================
*/
void R_EmitCachedEdge (void)
{
	edge_t		*pedge_t;

	pedge_t = (edge_t *)((unsigned long)r_edges + r_pedge->cachededgeoffset);

	if (!pedge_t->surfs[0])
		pedge_t->surfs[0] = surface_p - surfaces;
	else
		pedge_t->surfs[1] = surface_p - surfaces;

	if (pedge_t->nearzi > r_nearzi)	// for mipmap finding
		r_nearzi = pedge_t->nearzi;

	r_emitted = 1;
}


/*
================
R_RenderFace
================
*/
void R_RenderFace (msurface_t *fa, int clipflags)
{
	int			i, lindex;
	unsigned	mask;
	mplane_t	*pplane;
	float		distinv;
	vec3_t		p_normal;
	medge_t		*pedges, tedge;
	clipplane_t	*pclip;

	// translucent surfaces are not drawn by the edge renderer
	if (fa->texinfo->flags & (SURF_TRANS33|SURF_TRANS66))
	{
		fa->nextalphasurface = r_alpha_surfaces;
		r_alpha_surfaces = fa;
		return;
	}

	// sky surfaces encountered in the world will cause the
	// environment box surfaces to be emited
	if ( fa->texinfo->flags & SURF_SKY )
	{
		R_EmitSkyBox ();	
		return;
	}

// skip out if no more surfs
	if ((surface_p) >= surf_max)
	{
		r_outofsurfaces++;
		return;
	}

// ditto if not enough edges left, or switch to auxedges if possible
	if ((edge_p + fa->numedges + 4) >= edge_max)
	{
		r_outofedges += fa->numedges;
		return;
	}

	c_faceclip++;

// set up clip planes
	pclip = NULL;

	for (i=3, mask = 0x08 ; i>=0 ; i--, mask >>= 1)
	{
		if (clipflags & mask)
		{
			view_clipplanes[i].next = pclip;
			pclip = &view_clipplanes[i];
		}
	}

// push the edges through
	r_emitted = 0;
	r_nearzi = 0;
	r_nearzionly = false;
	makeleftedge = makerightedge = false;
	pedges = currentmodel->edges;
	r_lastvertvalid = false;

	for (i=0 ; i<fa->numedges ; i++)
	{
		lindex = currentmodel->surfedges[fa->firstedge + i];

		if (lindex > 0)
		{
			r_pedge = &pedges[lindex];

		// if the edge is cached, we can just reuse the edge
			if (!insubmodel)
			{
				if (r_pedge->cachededgeoffset & FULLY_CLIPPED_CACHED)
				{
					if ((r_pedge->cachededgeoffset & FRAMECOUNT_MASK) ==
						r_framecount)
					{
						r_lastvertvalid = false;
						continue;
					}
				}
				else
				{
					if ((((unsigned long)edge_p - (unsigned long)r_edges) >
						 r_pedge->cachededgeoffset) &&
						(((edge_t *)((unsigned long)r_edges +
						 r_pedge->cachededgeoffset))->owner == r_pedge))
					{
						R_EmitCachedEdge ();
						r_lastvertvalid = false;
						continue;
					}
				}
			}

		// assume it's cacheable
			cacheoffset = (byte *)edge_p - (byte *)r_edges;
			r_leftclipped = r_rightclipped = false;
			R_ClipEdge (&r_pcurrentvertbase[r_pedge->v[0]],
						&r_pcurrentvertbase[r_pedge->v[1]],
						pclip);
			r_pedge->cachededgeoffset = cacheoffset;

			if (r_leftclipped)
				makeleftedge = true;
			if (r_rightclipped)
				makerightedge = true;
			r_lastvertvalid = true;
		}
		else
		{
			lindex = -lindex;
			r_pedge = &pedges[lindex];
		// if the edge is cached, we can just reuse the edge
			if (!insubmodel)
			{
				if (r_pedge->cachededgeoffset & FULLY_CLIPPED_CACHED)
				{
					if ((r_pedge->cachededgeoffset & FRAMECOUNT_MASK) ==
						r_framecount)
					{
						r_lastvertvalid = false;
						continue;
					}
				}
				else
				{
				// it's cached if the cached edge is valid and is owned
				// by this medge_t
					if ((((unsigned long)edge_p - (unsigned long)r_edges) >
						 r_pedge->cachededgeoffset) &&
						(((edge_t *)((unsigned long)r_edges +
						 r_pedge->cachededgeoffset))->owner == r_pedge))
					{
						R_EmitCachedEdge ();
						r_lastvertvalid = false;
						continue;
					}
				}
			}

		// assume it's cacheable
			cacheoffset = (byte *)edge_p - (byte *)r_edges;
			r_leftclipped = r_rightclipped = false;
			R_ClipEdge (&r_pcurrentvertbase[r_pedge->v[1]],
						&r_pcurrentvertbase[r_pedge->v[0]],
						pclip);
			r_pedge->cachededgeoffset = cacheoffset;

			if (r_leftclipped)
				makeleftedge = true;
			if (r_rightclipped)
				makerightedge = true;
			r_lastvertvalid = true;
		}
	}

// if there was a clip off the left edge, add that edge too
// FIXME: faster to do in screen space?
// FIXME: share clipped edges?
	if (makeleftedge)
	{
		r_pedge = &tedge;
		r_lastvertvalid = false;
		R_ClipEdge (&r_leftexit, &r_leftenter, pclip->next);
	}

// if there was a clip off the right edge, get the right r_nearzi
	if (makerightedge)
	{
		r_pedge = &tedge;
		r_lastvertvalid = false;
		r_nearzionly = true;
		R_ClipEdge (&r_rightexit, &r_rightenter, view_clipplanes[1].next);
	}

// if no edges made it out, return without posting the surface
	if (!r_emitted)
		return;

	r_polycount++;

	surface_p->msurf = fa;
	surface_p->nearzi = r_nearzi;
	surface_p->flags = fa->flags;
	surface_p->insubmodel = insubmodel;
	surface_p->spanstate = 0;
	surface_p->entity = currententity;
	surface_p->key = r_currentkey++;
	surface_p->spans = NULL;

	pplane = fa->plane;
// FIXME: cache this?
	TransformVector (pplane->normal, p_normal);
// FIXME: cache this?
	distinv = 1.0 / (pplane->dist - DotProduct (modelorg, pplane->normal));

	surface_p->d_zistepu = p_normal[0] * xscaleinv * distinv;
	surface_p->d_zistepv = -p_normal[1] * yscaleinv * distinv;
	surface_p->d_ziorigin = p_normal[2] * distinv -
			xcenter * surface_p->d_zistepu -
			ycenter * surface_p->d_zistepv;

	surface_p++;
}


/*
================
R_RenderBmodelFace
================
*/
void R_RenderBmodelFace (bedge_t *pedges, msurface_t *psurf)
{
	int			i;
	unsigned	mask;
	mplane_t	*pplane;
	float		distinv;
	vec3_t		p_normal;
	medge_t		tedge;
	clipplane_t	*pclip;

	if (psurf->texinfo->flags & (SURF_TRANS33|SURF_TRANS66))
	{
		psurf->nextalphasurface = r_alpha_surfaces;
		r_alpha_surfaces = psurf;
		return;
	}

// skip out if no more surfs
	if (surface_p >= surf_max)
	{
		r_outofsurfaces++;
		return;
	}

// ditto if not enough edges left, or switch to auxedges if possible
	if ((edge_p + psurf->numedges + 4) >= edge_max)
	{
		r_outofedges += psurf->numedges;
		return;
	}

	c_faceclip++;

// this is a dummy to give the caching mechanism someplace to write to
	r_pedge = &tedge;

// set up clip planes
	pclip = NULL;

	for (i=3, mask = 0x08 ; i>=0 ; i--, mask >>= 1)
	{
		if (r_clipflags & mask)
		{
			view_clipplanes[i].next = pclip;
			pclip = &view_clipplanes[i];
		}
	}

// push the edges through
	r_emitted = 0;
	r_nearzi = 0;
	r_nearzionly = false;
	makeleftedge = makerightedge = false;
// FIXME: keep clipped bmodel edges in clockwise order so last vertex caching
// can be used?
	r_lastvertvalid = false;

	for ( ; pedges ; pedges = pedges->pnext)
	{
		r_leftclipped = r_rightclipped = false;
		R_ClipEdge (pedges->v[0], pedges->v[1], pclip);

		if (r_leftclipped)
			makeleftedge = true;
		if (r_rightclipped)
			makerightedge = true;
	}

// if there was a clip off the left edge, add that edge too
// FIXME: faster to do in screen space?
// FIXME: share clipped edges?
	if (makeleftedge)
	{
		r_pedge = &tedge;
		R_ClipEdge (&r_leftexit, &r_leftenter, pclip->next);
	}

// if there was a clip off the right edge, get the right r_nearzi
	if (makerightedge)
	{
		r_pedge = &tedge;
		r_nearzionly = true;
		R_ClipEdge (&r_rightexit, &r_rightenter, view_clipplanes[1].next);
	}

// if no edges made it out, return without posting the surface
	if (!r_emitted)
		return;

	r_polycount++;

	surface_p->msurf = psurf;
	surface_p->nearzi = r_nearzi;
	surface_p->flags = psurf->flags;
	surface_p->insubmodel = true;
	surface_p->spanstate = 0;
	surface_p->entity = currententity;
	surface_p->key = r_currentbkey;
	surface_p->spans = NULL;

	pplane = psurf->plane;
// FIXME: cache this?
	TransformVector (pplane->normal, p_normal);
// FIXME: cache this?
	distinv = 1.0 / (pplane->dist - DotProduct (modelorg, pplane->normal));

	surface_p->d_zistepu = p_normal[0] * xscaleinv * distinv;
	surface_p->d_zistepv = -p_normal[1] * yscaleinv * distinv;
	surface_p->d_ziorigin = p_normal[2] * distinv -
			xcenter * surface_p->d_zistepu -
			ycenter * surface_p->d_zistepv;

	surface_p++;
}

