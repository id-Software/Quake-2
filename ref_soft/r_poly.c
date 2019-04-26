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
#include <assert.h>
#include "r_local.h"

#define AFFINE_SPANLET_SIZE      16
#define AFFINE_SPANLET_SIZE_BITS 4

typedef struct
{
	byte     *pbase, *pdest;
	short	 *pz;
	fixed16_t s, t;
	fixed16_t sstep, tstep;
	int       izi, izistep, izistep_times_2;
	int       spancount;
	unsigned  u, v;
} spanletvars_t;

spanletvars_t s_spanletvars;

static int r_polyblendcolor;

static espan_t	*s_polygon_spans;

polydesc_t	r_polydesc;

msurface_t *r_alpha_surfaces;

extern int *r_turb_turb;

static int		clip_current;
vec5_t	r_clip_verts[2][MAXWORKINGVERTS+2];

static int		s_minindex, s_maxindex;

static void R_DrawPoly( int iswater );

/*
** R_DrawSpanletOpaque
*/
void R_DrawSpanletOpaque( void )
{
	unsigned btemp;

	do
	{
		unsigned ts, tt;

		ts = s_spanletvars.s >> 16;
		tt = s_spanletvars.t >> 16;

		btemp = *(s_spanletvars.pbase + (ts) + (tt) * cachewidth);
		if (btemp != 255)
		{
			if (*s_spanletvars.pz <= (s_spanletvars.izi >> 16))
			{
				*s_spanletvars.pz    = s_spanletvars.izi >> 16;
				*s_spanletvars.pdest = btemp;
			}
		}

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
		s_spanletvars.s += s_spanletvars.sstep;
		s_spanletvars.t += s_spanletvars.tstep;
	} while (--s_spanletvars.spancount > 0);
}

/*
** R_DrawSpanletTurbulentStipple33
*/
void R_DrawSpanletTurbulentStipple33( void )
{
	unsigned btemp;
	int	     sturb, tturb;
	byte    *pdest = s_spanletvars.pdest;
	short   *pz    = s_spanletvars.pz;
	int      izi   = s_spanletvars.izi;
	
	if ( s_spanletvars.v & 1 )
	{
		s_spanletvars.pdest += s_spanletvars.spancount;
		s_spanletvars.pz    += s_spanletvars.spancount;

		if ( s_spanletvars.spancount == AFFINE_SPANLET_SIZE )
			s_spanletvars.izi += s_spanletvars.izistep << AFFINE_SPANLET_SIZE_BITS;
		else
			s_spanletvars.izi += s_spanletvars.izistep * s_spanletvars.izistep;
		
		if ( s_spanletvars.u & 1 )
		{
			izi += s_spanletvars.izistep;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;

			pdest++;
			pz++;
			s_spanletvars.spancount--;
		}

		s_spanletvars.sstep   *= 2;
		s_spanletvars.tstep   *= 2;

		while ( s_spanletvars.spancount > 0 )
		{
			sturb = ((s_spanletvars.s + r_turb_turb[(s_spanletvars.t>>16)&(CYCLE-1)])>>16)&63;
			tturb = ((s_spanletvars.t + r_turb_turb[(s_spanletvars.s>>16)&(CYCLE-1)])>>16)&63;
			
			btemp = *( s_spanletvars.pbase + ( sturb ) + ( tturb << 6 ) );
			
			if ( *pz <= ( izi >> 16 ) )
				*pdest = btemp;
			
			izi               += s_spanletvars.izistep_times_2;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;
			
			pdest += 2;
			pz    += 2;
			
			s_spanletvars.spancount -= 2;
		}
	}
}

/*
** R_DrawSpanletTurbulentStipple66
*/
void R_DrawSpanletTurbulentStipple66( void )
{
	unsigned btemp;
	int	     sturb, tturb;
	byte    *pdest = s_spanletvars.pdest;
	short   *pz    = s_spanletvars.pz;
	int      izi   = s_spanletvars.izi;
	
	if ( !( s_spanletvars.v & 1 ) )
	{
		s_spanletvars.pdest += s_spanletvars.spancount;
		s_spanletvars.pz    += s_spanletvars.spancount;

		if ( s_spanletvars.spancount == AFFINE_SPANLET_SIZE )
			s_spanletvars.izi += s_spanletvars.izistep << AFFINE_SPANLET_SIZE_BITS;
		else
			s_spanletvars.izi += s_spanletvars.izistep * s_spanletvars.izistep;
		
		if ( s_spanletvars.u & 1 )
		{
			izi += s_spanletvars.izistep;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;

			pdest++;
			pz++;
			s_spanletvars.spancount--;
		}

		s_spanletvars.sstep   *= 2;
		s_spanletvars.tstep   *= 2;

		while ( s_spanletvars.spancount > 0 )
		{
			sturb = ((s_spanletvars.s + r_turb_turb[(s_spanletvars.t>>16)&(CYCLE-1)])>>16)&63;
			tturb = ((s_spanletvars.t + r_turb_turb[(s_spanletvars.s>>16)&(CYCLE-1)])>>16)&63;
			
			btemp = *( s_spanletvars.pbase + ( sturb ) + ( tturb << 6 ) );
			
			if ( *pz <= ( izi >> 16 ) )
				*pdest = btemp;
			
			izi               += s_spanletvars.izistep_times_2;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;
			
			pdest += 2;
			pz    += 2;
			
			s_spanletvars.spancount -= 2;
		}
	}
	else
	{
		s_spanletvars.pdest += s_spanletvars.spancount;
		s_spanletvars.pz    += s_spanletvars.spancount;

		if ( s_spanletvars.spancount == AFFINE_SPANLET_SIZE )
			s_spanletvars.izi += s_spanletvars.izistep << AFFINE_SPANLET_SIZE_BITS;
		else
			s_spanletvars.izi += s_spanletvars.izistep * s_spanletvars.izistep;
		
		while ( s_spanletvars.spancount > 0 )
		{
			sturb = ((s_spanletvars.s + r_turb_turb[(s_spanletvars.t>>16)&(CYCLE-1)])>>16)&63;
			tturb = ((s_spanletvars.t + r_turb_turb[(s_spanletvars.s>>16)&(CYCLE-1)])>>16)&63;
			
			btemp = *( s_spanletvars.pbase + ( sturb ) + ( tturb << 6 ) );
			
			if ( *pz <= ( izi >> 16 ) )
				*pdest = btemp;
			
			izi               += s_spanletvars.izistep;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;
			
			pdest++;
			pz++;
			
			s_spanletvars.spancount--;
		}
	}
}

/*
** R_DrawSpanletTurbulentBlended
*/
void R_DrawSpanletTurbulentBlended66( void )
{
	unsigned btemp;
	int	     sturb, tturb;

	do
	{
		sturb = ((s_spanletvars.s + r_turb_turb[(s_spanletvars.t>>16)&(CYCLE-1)])>>16)&63;
		tturb = ((s_spanletvars.t + r_turb_turb[(s_spanletvars.s>>16)&(CYCLE-1)])>>16)&63;

		btemp = *( s_spanletvars.pbase + ( sturb ) + ( tturb << 6 ) );

		if ( *s_spanletvars.pz <= ( s_spanletvars.izi >> 16 ) )
			*s_spanletvars.pdest = vid.alphamap[btemp*256+*s_spanletvars.pdest];

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
		s_spanletvars.s += s_spanletvars.sstep;
		s_spanletvars.t += s_spanletvars.tstep;

	} while ( --s_spanletvars.spancount > 0 );
}

void R_DrawSpanletTurbulentBlended33( void )
{
	unsigned btemp;
	int	     sturb, tturb;

	do
	{
		sturb = ((s_spanletvars.s + r_turb_turb[(s_spanletvars.t>>16)&(CYCLE-1)])>>16)&63;
		tturb = ((s_spanletvars.t + r_turb_turb[(s_spanletvars.s>>16)&(CYCLE-1)])>>16)&63;

		btemp = *( s_spanletvars.pbase + ( sturb ) + ( tturb << 6 ) );

		if ( *s_spanletvars.pz <= ( s_spanletvars.izi >> 16 ) )
			*s_spanletvars.pdest = vid.alphamap[btemp+*s_spanletvars.pdest*256];

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
		s_spanletvars.s += s_spanletvars.sstep;
		s_spanletvars.t += s_spanletvars.tstep;

	} while ( --s_spanletvars.spancount > 0 );
}

/*
** R_DrawSpanlet33
*/
void R_DrawSpanlet33( void )
{
	unsigned btemp;

	do
	{
		unsigned ts, tt;

		ts = s_spanletvars.s >> 16;
		tt = s_spanletvars.t >> 16;

		btemp = *(s_spanletvars.pbase + (ts) + (tt) * cachewidth);

		if ( btemp != 255 )
		{
			if (*s_spanletvars.pz <= (s_spanletvars.izi >> 16))
			{
				*s_spanletvars.pdest = vid.alphamap[btemp+*s_spanletvars.pdest*256];
			}
		}

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
		s_spanletvars.s += s_spanletvars.sstep;
		s_spanletvars.t += s_spanletvars.tstep;
	} while (--s_spanletvars.spancount > 0);
}

void R_DrawSpanletConstant33( void )
{
	do
	{
		if (*s_spanletvars.pz <= (s_spanletvars.izi >> 16))
		{
			*s_spanletvars.pdest = vid.alphamap[r_polyblendcolor+*s_spanletvars.pdest*256];
		}

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
	} while (--s_spanletvars.spancount > 0);
}

/*
** R_DrawSpanlet66
*/
void R_DrawSpanlet66( void )
{
	unsigned btemp;

	do
	{
		unsigned ts, tt;

		ts = s_spanletvars.s >> 16;
		tt = s_spanletvars.t >> 16;

		btemp = *(s_spanletvars.pbase + (ts) + (tt) * cachewidth);

		if ( btemp != 255 )
		{
			if (*s_spanletvars.pz <= (s_spanletvars.izi >> 16))
			{
				*s_spanletvars.pdest = vid.alphamap[btemp*256+*s_spanletvars.pdest];
			}
		}

		s_spanletvars.izi += s_spanletvars.izistep;
		s_spanletvars.pdest++;
		s_spanletvars.pz++;
		s_spanletvars.s += s_spanletvars.sstep;
		s_spanletvars.t += s_spanletvars.tstep;
	} while (--s_spanletvars.spancount > 0);
}

/*
** R_DrawSpanlet33Stipple
*/
void R_DrawSpanlet33Stipple( void )
{
	unsigned btemp;
	byte    *pdest = s_spanletvars.pdest;
	short   *pz    = s_spanletvars.pz;
	int      izi   = s_spanletvars.izi;
	
	if ( r_polydesc.stipple_parity ^ ( s_spanletvars.v & 1 ) )
	{
		s_spanletvars.pdest += s_spanletvars.spancount;
		s_spanletvars.pz    += s_spanletvars.spancount;

		if ( s_spanletvars.spancount == AFFINE_SPANLET_SIZE )
			s_spanletvars.izi += s_spanletvars.izistep << AFFINE_SPANLET_SIZE_BITS;
		else
			s_spanletvars.izi += s_spanletvars.izistep * s_spanletvars.izistep;
		
		if ( r_polydesc.stipple_parity ^ ( s_spanletvars.u & 1 ) )
		{
			izi += s_spanletvars.izistep;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;

			pdest++;
			pz++;
			s_spanletvars.spancount--;
		}

		s_spanletvars.sstep *= 2;
		s_spanletvars.tstep *= 2;

		while ( s_spanletvars.spancount > 0 )
		{
			unsigned s = s_spanletvars.s >> 16;
			unsigned t = s_spanletvars.t >> 16;

			btemp = *( s_spanletvars.pbase + ( s ) + ( t * cachewidth ) );
			
			if ( btemp != 255 )
			{
				if ( *pz <= ( izi >> 16 ) )
					*pdest = btemp;
			}
			
			izi               += s_spanletvars.izistep_times_2;
			s_spanletvars.s   += s_spanletvars.sstep;
			s_spanletvars.t   += s_spanletvars.tstep;
			
			pdest += 2;
			pz    += 2;
			
			s_spanletvars.spancount -= 2;
		}
	}
}

/*
** R_DrawSpanlet66Stipple
*/
void R_DrawSpanlet66Stipple( void )
{
	unsigned btemp;
	byte    *pdest = s_spanletvars.pdest;
	short   *pz    = s_spanletvars.pz;
	int      izi   = s_spanletvars.izi;

	s_spanletvars.pdest += s_spanletvars.spancount;
	s_spanletvars.pz    += s_spanletvars.spancount;

	if ( s_spanletvars.spancount == AFFINE_SPANLET_SIZE )
		s_spanletvars.izi += s_spanletvars.izistep << AFFINE_SPANLET_SIZE_BITS;
	else
		s_spanletvars.izi += s_spanletvars.izistep * s_spanletvars.izistep;

	if ( r_polydesc.stipple_parity ^ ( s_spanletvars.v & 1 ) )
	{
		if ( r_polydesc.stipple_parity ^ ( s_spanletvars.u & 1 ) )
		{
			izi += s_spanletvars.izistep;
			s_spanletvars.s += s_spanletvars.sstep;
			s_spanletvars.t += s_spanletvars.tstep;

			pdest++;
			pz++;
			s_spanletvars.spancount--;
		}

		s_spanletvars.sstep *= 2;
		s_spanletvars.tstep *= 2;

		while ( s_spanletvars.spancount > 0 )
		{
			unsigned s = s_spanletvars.s >> 16;
			unsigned t = s_spanletvars.t >> 16;
			
			btemp = *( s_spanletvars.pbase + ( s ) + ( t * cachewidth ) );

			if ( btemp != 255 )
			{
				if ( *pz <= ( izi >> 16 ) )
					*pdest = btemp;
			}
			
			izi             += s_spanletvars.izistep_times_2;
			s_spanletvars.s += s_spanletvars.sstep;
			s_spanletvars.t += s_spanletvars.tstep;
			
			pdest += 2;
			pz    += 2;
			
			s_spanletvars.spancount -= 2;
		}
	}
	else
	{
		while ( s_spanletvars.spancount > 0 )
		{
			unsigned s = s_spanletvars.s >> 16;
			unsigned t = s_spanletvars.t >> 16;
			
			btemp = *( s_spanletvars.pbase + ( s ) + ( t * cachewidth ) );
			
			if ( btemp != 255 )
			{
				if ( *pz <= ( izi >> 16 ) )
					*pdest = btemp;
			}
			
			izi             += s_spanletvars.izistep;
			s_spanletvars.s += s_spanletvars.sstep;
			s_spanletvars.t += s_spanletvars.tstep;
			
			pdest++;
			pz++;
			
			s_spanletvars.spancount--;
		}
	}
}

/*
** R_ClipPolyFace
**
** Clips the winding at clip_verts[clip_current] and changes clip_current
** Throws out the back side
*/
int R_ClipPolyFace (int nump, clipplane_t *pclipplane)
{
	int		i, outcount;
	float	dists[MAXWORKINGVERTS+3];
	float	frac, clipdist, *pclipnormal;
	float	*in, *instep, *outstep, *vert2;

	clipdist = pclipplane->dist;
	pclipnormal = pclipplane->normal;
	
// calc dists
	if (clip_current)
	{
		in = r_clip_verts[1][0];
		outstep = r_clip_verts[0][0];
		clip_current = 0;
	}
	else
	{
		in = r_clip_verts[0][0];
		outstep = r_clip_verts[1][0];
		clip_current = 1;
	}
	
	instep = in;
	for (i=0 ; i<nump ; i++, instep += sizeof (vec5_t) / sizeof (float))
	{
		dists[i] = DotProduct (instep, pclipnormal) - clipdist;
	}
	
// handle wraparound case
	dists[nump] = dists[0];
	memcpy (instep, in, sizeof (vec5_t));


// clip the winding
	instep = in;
	outcount = 0;

	for (i=0 ; i<nump ; i++, instep += sizeof (vec5_t) / sizeof (float))
	{
		if (dists[i] >= 0)
		{
			memcpy (outstep, instep, sizeof (vec5_t));
			outstep += sizeof (vec5_t) / sizeof (float);
			outcount++;
		}

		if (dists[i] == 0 || dists[i+1] == 0)
			continue;

		if ( (dists[i] > 0) == (dists[i+1] > 0) )
			continue;
			
	// split it into a new vertex
		frac = dists[i] / (dists[i] - dists[i+1]);
			
		vert2 = instep + sizeof (vec5_t) / sizeof (float);
		
		outstep[0] = instep[0] + frac*(vert2[0] - instep[0]);
		outstep[1] = instep[1] + frac*(vert2[1] - instep[1]);
		outstep[2] = instep[2] + frac*(vert2[2] - instep[2]);
		outstep[3] = instep[3] + frac*(vert2[3] - instep[3]);
		outstep[4] = instep[4] + frac*(vert2[4] - instep[4]);

		outstep += sizeof (vec5_t) / sizeof (float);
		outcount++;
	}	
	
	return outcount;
}

/*
** R_PolygonDrawSpans
*/
// PGM - iswater was qboolean. changed to allow passing more flags
void R_PolygonDrawSpans(espan_t *pspan, int iswater )
{
	int			count;
	fixed16_t	snext, tnext;
	float		sdivz, tdivz, zi, z, du, dv, spancountminus1;
	float		sdivzspanletstepu, tdivzspanletstepu, zispanletstepu;

	s_spanletvars.pbase = cacheblock;

//PGM
	if ( iswater & SURF_WARP)
		r_turb_turb = sintable + ((int)(r_newrefdef.time*SPEED)&(CYCLE-1));
	else if (iswater & SURF_FLOWING)
		r_turb_turb = blanktable;
//PGM

	sdivzspanletstepu = d_sdivzstepu * AFFINE_SPANLET_SIZE;
	tdivzspanletstepu = d_tdivzstepu * AFFINE_SPANLET_SIZE;
	zispanletstepu = d_zistepu * AFFINE_SPANLET_SIZE;

// we count on FP exceptions being turned off to avoid range problems
	s_spanletvars.izistep = (int)(d_zistepu * 0x8000 * 0x10000);
	s_spanletvars.izistep_times_2 = s_spanletvars.izistep * 2;

	s_spanletvars.pz = 0;

	do
	{
		s_spanletvars.pdest   = (byte *)d_viewbuffer + ( d_scantable[pspan->v] /*r_screenwidth * pspan->v*/) + pspan->u;
		s_spanletvars.pz      = d_pzbuffer + (d_zwidth * pspan->v) + pspan->u;
		s_spanletvars.u       = pspan->u;
		s_spanletvars.v       = pspan->v;

		count = pspan->count;

		if (count <= 0)
			goto NextSpan;

	// calculate the initial s/z, t/z, 1/z, s, and t and clamp
		du = (float)pspan->u;
		dv = (float)pspan->v;

		sdivz = d_sdivzorigin + dv*d_sdivzstepv + du*d_sdivzstepu;
		tdivz = d_tdivzorigin + dv*d_tdivzstepv + du*d_tdivzstepu;

		zi = d_ziorigin + dv*d_zistepv + du*d_zistepu;
		z = (float)0x10000 / zi;	// prescale to 16.16 fixed-point
	// we count on FP exceptions being turned off to avoid range problems
		s_spanletvars.izi = (int)(zi * 0x8000 * 0x10000);

		s_spanletvars.s = (int)(sdivz * z) + sadjust;
		s_spanletvars.t = (int)(tdivz * z) + tadjust;

		if ( !iswater )
		{
			if (s_spanletvars.s > bbextents)
				s_spanletvars.s = bbextents;
			else if (s_spanletvars.s < 0)
				s_spanletvars.s = 0;

			if (s_spanletvars.t > bbextentt)
				s_spanletvars.t = bbextentt;
			else if (s_spanletvars.t < 0)
				s_spanletvars.t = 0;
		}

		do
		{
		// calculate s and t at the far end of the span
			if (count >= AFFINE_SPANLET_SIZE )
				s_spanletvars.spancount = AFFINE_SPANLET_SIZE;
			else
				s_spanletvars.spancount = count;

			count -= s_spanletvars.spancount;

			if (count)
			{
			// calculate s/z, t/z, zi->fixed s and t at far end of span,
			// calculate s and t steps across span by shifting
				sdivz += sdivzspanletstepu;
				tdivz += tdivzspanletstepu;
				zi += zispanletstepu;
				z = (float)0x10000 / zi;	// prescale to 16.16 fixed-point

				snext = (int)(sdivz * z) + sadjust;
				tnext = (int)(tdivz * z) + tadjust;

				if ( !iswater )
				{
					if (snext > bbextents)
						snext = bbextents;
					else if (snext < AFFINE_SPANLET_SIZE)
						snext = AFFINE_SPANLET_SIZE;	// prevent round-off error on <0 steps from
									//  from causing overstepping & running off the
									//  edge of the texture

					if (tnext > bbextentt)
						tnext = bbextentt;
					else if (tnext < AFFINE_SPANLET_SIZE)
						tnext = AFFINE_SPANLET_SIZE;	// guard against round-off error on <0 steps
				}

				s_spanletvars.sstep = (snext - s_spanletvars.s) >> AFFINE_SPANLET_SIZE_BITS;
				s_spanletvars.tstep = (tnext - s_spanletvars.t) >> AFFINE_SPANLET_SIZE_BITS;
			}
			else
			{
			// calculate s/z, t/z, zi->fixed s and t at last pixel in span (so
			// can't step off polygon), clamp, calculate s and t steps across
			// span by division, biasing steps low so we don't run off the
			// texture
				spancountminus1 = (float)(s_spanletvars.spancount - 1);
				sdivz += d_sdivzstepu * spancountminus1;
				tdivz += d_tdivzstepu * spancountminus1;
				zi += d_zistepu * spancountminus1;
				z = (float)0x10000 / zi;	// prescale to 16.16 fixed-point
				snext = (int)(sdivz * z) + sadjust;
				tnext = (int)(tdivz * z) + tadjust;

				if ( !iswater )
				{
					if (snext > bbextents)
						snext = bbextents;
					else if (snext < AFFINE_SPANLET_SIZE)
						snext = AFFINE_SPANLET_SIZE;	// prevent round-off error on <0 steps from
									//  from causing overstepping & running off the
									//  edge of the texture

					if (tnext > bbextentt)
						tnext = bbextentt;
					else if (tnext < AFFINE_SPANLET_SIZE)
						tnext = AFFINE_SPANLET_SIZE;	// guard against round-off error on <0 steps
				}

				if (s_spanletvars.spancount > 1)
				{
					s_spanletvars.sstep = (snext - s_spanletvars.s) / (s_spanletvars.spancount - 1);
					s_spanletvars.tstep = (tnext - s_spanletvars.t) / (s_spanletvars.spancount - 1);
				}
			}

			if ( iswater )
			{
				s_spanletvars.s = s_spanletvars.s & ((CYCLE<<16)-1);
				s_spanletvars.t = s_spanletvars.t & ((CYCLE<<16)-1);
			}

			r_polydesc.drawspanlet();

			s_spanletvars.s = snext;
			s_spanletvars.t = tnext;

		} while (count > 0);

NextSpan:
		pspan++;

	} while (pspan->count != DS_SPAN_LIST_END);
}

/*
**
** R_PolygonScanLeftEdge
**
** Goes through the polygon and scans the left edge, filling in 
** screen coordinate data for the spans
*/
void R_PolygonScanLeftEdge (void)
{
	int			i, v, itop, ibottom, lmaxindex;
	emitpoint_t	*pvert, *pnext;
	espan_t		*pspan;
	float		du, dv, vtop, vbottom, slope;
	fixed16_t	u, u_step;

	pspan = s_polygon_spans;
	i = s_minindex;
	if (i == 0)
		i = r_polydesc.nump;

	lmaxindex = s_maxindex;
	if (lmaxindex == 0)
		lmaxindex = r_polydesc.nump;

	vtop = ceil (r_polydesc.pverts[i].v);

	do
	{
		pvert = &r_polydesc.pverts[i];
		pnext = pvert - 1;

		vbottom = ceil (pnext->v);

		if (vtop < vbottom)
		{
			du = pnext->u - pvert->u;
			dv = pnext->v - pvert->v;

			slope = du / dv;
			u_step = (int)(slope * 0x10000);
		// adjust u to ceil the integer portion
			u = (int)((pvert->u + (slope * (vtop - pvert->v))) * 0x10000) +
					(0x10000 - 1);
			itop = (int)vtop;
			ibottom = (int)vbottom;

			for (v=itop ; v<ibottom ; v++)
			{
				pspan->u = u >> 16;
				pspan->v = v;
				u += u_step;
				pspan++;
			}
		}

		vtop = vbottom;

		i--;
		if (i == 0)
			i = r_polydesc.nump;

	} while (i != lmaxindex);
}

/*
** R_PolygonScanRightEdge
**
** Goes through the polygon and scans the right edge, filling in
** count values.
*/
void R_PolygonScanRightEdge (void)
{
	int			i, v, itop, ibottom;
	emitpoint_t	*pvert, *pnext;
	espan_t		*pspan;
	float		du, dv, vtop, vbottom, slope, uvert, unext, vvert, vnext;
	fixed16_t	u, u_step;

	pspan = s_polygon_spans;
	i = s_minindex;

	vvert = r_polydesc.pverts[i].v;
	if (vvert < r_refdef.fvrecty_adj)
		vvert = r_refdef.fvrecty_adj;
	if (vvert > r_refdef.fvrectbottom_adj)
		vvert = r_refdef.fvrectbottom_adj;

	vtop = ceil (vvert);

	do
	{
		pvert = &r_polydesc.pverts[i];
		pnext = pvert + 1;

		vnext = pnext->v;
		if (vnext < r_refdef.fvrecty_adj)
			vnext = r_refdef.fvrecty_adj;
		if (vnext > r_refdef.fvrectbottom_adj)
			vnext = r_refdef.fvrectbottom_adj;

		vbottom = ceil (vnext);

		if (vtop < vbottom)
		{
			uvert = pvert->u;
			if (uvert < r_refdef.fvrectx_adj)
				uvert = r_refdef.fvrectx_adj;
			if (uvert > r_refdef.fvrectright_adj)
				uvert = r_refdef.fvrectright_adj;

			unext = pnext->u;
			if (unext < r_refdef.fvrectx_adj)
				unext = r_refdef.fvrectx_adj;
			if (unext > r_refdef.fvrectright_adj)
				unext = r_refdef.fvrectright_adj;

			du = unext - uvert;
			dv = vnext - vvert;
			slope = du / dv;
			u_step = (int)(slope * 0x10000);
		// adjust u to ceil the integer portion
			u = (int)((uvert + (slope * (vtop - vvert))) * 0x10000) +
					(0x10000 - 1);
			itop = (int)vtop;
			ibottom = (int)vbottom;

			for (v=itop ; v<ibottom ; v++)
			{
				pspan->count = (u >> 16) - pspan->u;
				u += u_step;
				pspan++;
			}
		}

		vtop = vbottom;
		vvert = vnext;

		i++;
		if (i == r_polydesc.nump)
			i = 0;

	} while (i != s_maxindex);

	pspan->count = DS_SPAN_LIST_END;	// mark the end of the span list 
}

/*
** R_ClipAndDrawPoly
*/
// PGM - isturbulent was qboolean. changed to int to allow passing more flags
void R_ClipAndDrawPoly ( float alpha, int isturbulent, qboolean textured )
{
	emitpoint_t	outverts[MAXWORKINGVERTS+3], *pout;
	float		*pv;
	int			i, nump;
	float		scale;
	vec3_t		transformed, local;

	if ( !textured )
	{
		r_polydesc.drawspanlet = R_DrawSpanletConstant33;
	}
	else
	{

		/*
		** choose the correct spanlet routine based on alpha
		*/
		if ( alpha == 1 )
		{
			// isturbulent is ignored because we know that turbulent surfaces
			// can't be opaque
			r_polydesc.drawspanlet = R_DrawSpanletOpaque;
		}
		else
		{
			if ( sw_stipplealpha->value )
			{
				if ( isturbulent )
				{
					if ( alpha > 0.33 )
						r_polydesc.drawspanlet = R_DrawSpanletTurbulentStipple66;
					else 
						r_polydesc.drawspanlet = R_DrawSpanletTurbulentStipple33;
				}
				else
				{
					if ( alpha > 0.33 )
						r_polydesc.drawspanlet = R_DrawSpanlet66Stipple;
					else 
						r_polydesc.drawspanlet = R_DrawSpanlet33Stipple;
				}
			}
			else
			{
				if ( isturbulent )
				{
					if ( alpha > 0.33 )
						r_polydesc.drawspanlet = R_DrawSpanletTurbulentBlended66;
					else
						r_polydesc.drawspanlet = R_DrawSpanletTurbulentBlended33;
				}
				else
				{
					if ( alpha > 0.33 )
						r_polydesc.drawspanlet = R_DrawSpanlet66;
					else 
						r_polydesc.drawspanlet = R_DrawSpanlet33;
				}
			}
		}
	}

	// clip to the frustum in worldspace
	nump = r_polydesc.nump;
	clip_current = 0;

	for (i=0 ; i<4 ; i++)
	{
		nump = R_ClipPolyFace (nump, &view_clipplanes[i]);
		if (nump < 3)
			return;
		if (nump > MAXWORKINGVERTS)
			ri.Sys_Error(ERR_DROP, "R_ClipAndDrawPoly: too many points: %d", nump );
	}

// transform vertices into viewspace and project
	pv = &r_clip_verts[clip_current][0][0];

	for (i=0 ; i<nump ; i++)
	{
		VectorSubtract (pv, r_origin, local);
		TransformVector (local, transformed);

		if (transformed[2] < NEAR_CLIP)
			transformed[2] = NEAR_CLIP;

		pout = &outverts[i];
		pout->zi = 1.0 / transformed[2];

		pout->s = pv[3];
		pout->t = pv[4];
		
		scale = xscale * pout->zi;
		pout->u = (xcenter + scale * transformed[0]);

		scale = yscale * pout->zi;
		pout->v = (ycenter - scale * transformed[1]);

		pv += sizeof (vec5_t) / sizeof (pv);
	}

// draw it
	r_polydesc.nump = nump;
	r_polydesc.pverts = outverts;

	R_DrawPoly( isturbulent );
}

/*
** R_BuildPolygonFromSurface
*/
void R_BuildPolygonFromSurface(msurface_t *fa)
{
	int			i, lindex, lnumverts;
	medge_t		*pedges, *r_pedge;
	int			vertpage;
	float		*vec;
	vec5_t     *pverts;
	float       tmins[2] = { 0, 0 };

	r_polydesc.nump = 0;

	// reconstruct the polygon
	pedges = currentmodel->edges;
	lnumverts = fa->numedges;
	vertpage = 0;

	pverts = r_clip_verts[0];

	for (i=0 ; i<lnumverts ; i++)
	{
		lindex = currentmodel->surfedges[fa->firstedge + i];

		if (lindex > 0)
		{
			r_pedge = &pedges[lindex];
			vec = currentmodel->vertexes[r_pedge->v[0]].position;
		}
		else
		{
			r_pedge = &pedges[-lindex];
			vec = currentmodel->vertexes[r_pedge->v[1]].position;
		}

		VectorCopy (vec, pverts[i] );
	}

	VectorCopy( fa->texinfo->vecs[0], r_polydesc.vright );
	VectorCopy( fa->texinfo->vecs[1], r_polydesc.vup );
	VectorCopy( fa->plane->normal, r_polydesc.vpn );
	VectorCopy( r_origin, r_polydesc.viewer_position );

	if ( fa->flags & SURF_PLANEBACK )
	{
		VectorSubtract( vec3_origin, r_polydesc.vpn, r_polydesc.vpn );
	}

// PGM 09/16/98
	if ( fa->texinfo->flags & (SURF_WARP|SURF_FLOWING) )
	{
		r_polydesc.pixels       = fa->texinfo->image->pixels[0];
		r_polydesc.pixel_width  = fa->texinfo->image->width;
		r_polydesc.pixel_height = fa->texinfo->image->height;
	}
// PGM 09/16/98
	else
	{
		surfcache_t *scache;

		scache = D_CacheSurface( fa, 0 );

		r_polydesc.pixels       = scache->data;
		r_polydesc.pixel_width  = scache->width;
		r_polydesc.pixel_height = scache->height;

		tmins[0] = fa->texturemins[0];
		tmins[1] = fa->texturemins[1];
	}

	r_polydesc.dist = DotProduct( r_polydesc.vpn, pverts[0] );

	r_polydesc.s_offset = fa->texinfo->vecs[0][3] - tmins[0];
	r_polydesc.t_offset = fa->texinfo->vecs[1][3] - tmins[1];

	// scrolling texture addition
	if (fa->texinfo->flags & SURF_FLOWING)
	{
		r_polydesc.s_offset += -128 * ( (r_newrefdef.time*0.25) - (int)(r_newrefdef.time*0.25) );
	}

	r_polydesc.nump = lnumverts;
}

/*
** R_PolygonCalculateGradients
*/
void R_PolygonCalculateGradients (void)
{
	vec3_t		p_normal, p_saxis, p_taxis;
	float		distinv;

	TransformVector (r_polydesc.vpn, p_normal);
	TransformVector (r_polydesc.vright, p_saxis);
	TransformVector (r_polydesc.vup, p_taxis);

	distinv = 1.0 / (-(DotProduct (r_polydesc.viewer_position, r_polydesc.vpn)) + r_polydesc.dist );

	d_sdivzstepu  =  p_saxis[0] * xscaleinv;
	d_sdivzstepv  = -p_saxis[1] * yscaleinv;
	d_sdivzorigin =  p_saxis[2] - xcenter * d_sdivzstepu - ycenter * d_sdivzstepv;

	d_tdivzstepu  =  p_taxis[0] * xscaleinv;
	d_tdivzstepv  = -p_taxis[1] * yscaleinv;
	d_tdivzorigin =  p_taxis[2] - xcenter * d_tdivzstepu - ycenter * d_tdivzstepv;

	d_zistepu =   p_normal[0] * xscaleinv * distinv;
	d_zistepv =  -p_normal[1] * yscaleinv * distinv;
	d_ziorigin =  p_normal[2] * distinv - xcenter * d_zistepu - ycenter * d_zistepv;

	sadjust = (fixed16_t) ( ( DotProduct( r_polydesc.viewer_position, r_polydesc.vright) + r_polydesc.s_offset ) * 0x10000 );
	tadjust = (fixed16_t) ( ( DotProduct( r_polydesc.viewer_position, r_polydesc.vup   ) + r_polydesc.t_offset ) * 0x10000 );

// -1 (-epsilon) so we never wander off the edge of the texture
	bbextents = (r_polydesc.pixel_width << 16) - 1;
	bbextentt = (r_polydesc.pixel_height << 16) - 1;
}

/*
** R_DrawPoly
**
** Polygon drawing function.  Uses the polygon described in r_polydesc
** to calculate edges and gradients, then renders the resultant spans.
**
** This should NOT be called externally since it doesn't do clipping!
*/
// PGM - iswater was qboolean. changed to support passing more flags
static void R_DrawPoly( int iswater )
{
	int			i, nump;
	float		ymin, ymax;
	emitpoint_t	*pverts;
	espan_t	spans[MAXHEIGHT+1];

	s_polygon_spans = spans;

// find the top and bottom vertices, and make sure there's at least one scan to
// draw
	ymin = 999999.9;
	ymax = -999999.9;
	pverts = r_polydesc.pverts;

	for (i=0 ; i<r_polydesc.nump ; i++)
	{
		if (pverts->v < ymin)
		{
			ymin = pverts->v;
			s_minindex = i;
		}

		if (pverts->v > ymax)
		{
			ymax = pverts->v;
			s_maxindex = i;
		}

		pverts++;
	}

	ymin = ceil (ymin);
	ymax = ceil (ymax);

	if (ymin >= ymax)
		return;		// doesn't cross any scans at all

	cachewidth = r_polydesc.pixel_width;
	cacheblock = r_polydesc.pixels;

// copy the first vertex to the last vertex, so we don't have to deal with
// wrapping
	nump = r_polydesc.nump;
	pverts = r_polydesc.pverts;
	pverts[nump] = pverts[0];

	R_PolygonCalculateGradients ();
	R_PolygonScanLeftEdge ();
	R_PolygonScanRightEdge ();

	R_PolygonDrawSpans( s_polygon_spans, iswater );
}

/*
** R_DrawAlphaSurfaces
*/
void R_DrawAlphaSurfaces( void )
{
	msurface_t *s = r_alpha_surfaces;

	currentmodel = r_worldmodel;

	modelorg[0] = -r_origin[0];
	modelorg[1] = -r_origin[1];
	modelorg[2] = -r_origin[2];

	while ( s )
	{
		R_BuildPolygonFromSurface( s );

//=======
//PGM
//		if (s->texinfo->flags & SURF_TRANS66)
//			R_ClipAndDrawPoly( 0.60f, ( s->texinfo->flags & SURF_WARP) != 0, true );
//		else
//			R_ClipAndDrawPoly( 0.30f, ( s->texinfo->flags & SURF_WARP) != 0, true );

		// PGM - pass down all the texinfo flags, not just SURF_WARP.
		if (s->texinfo->flags & SURF_TRANS66)
			R_ClipAndDrawPoly( 0.60f, (s->texinfo->flags & SURF_WARP|SURF_FLOWING), true );
		else
			R_ClipAndDrawPoly( 0.30f, (s->texinfo->flags & SURF_WARP|SURF_FLOWING), true );
//PGM
//=======

		s = s->nextalphasurface;
	}
	
	r_alpha_surfaces = NULL;
}

/*
** R_IMFlatShadedQuad
*/
void R_IMFlatShadedQuad( vec3_t a, vec3_t b, vec3_t c, vec3_t d, int color, float alpha )
{
	vec3_t s0, s1;

	r_polydesc.nump = 4;
	VectorCopy( r_origin, r_polydesc.viewer_position );

	VectorCopy( a, r_clip_verts[0][0] );
	VectorCopy( b, r_clip_verts[0][1] );
	VectorCopy( c, r_clip_verts[0][2] );
	VectorCopy( d, r_clip_verts[0][3] );

	r_clip_verts[0][0][3] = 0;
	r_clip_verts[0][1][3] = 0;
	r_clip_verts[0][2][3] = 0;
	r_clip_verts[0][3][3] = 0;

	r_clip_verts[0][0][4] = 0;
	r_clip_verts[0][1][4] = 0;
	r_clip_verts[0][2][4] = 0;
	r_clip_verts[0][3][4] = 0;

	VectorSubtract( d, c, s0 );
	VectorSubtract( c, b, s1 );
	CrossProduct( s0, s1, r_polydesc.vpn );
	VectorNormalize( r_polydesc.vpn );

	r_polydesc.dist = DotProduct( r_polydesc.vpn, r_clip_verts[0][0] );

	r_polyblendcolor = color;

	R_ClipAndDrawPoly( alpha, false, false );
}

