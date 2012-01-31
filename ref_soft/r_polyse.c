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
// d_polyset.c: routines for drawing sets of polygons sharing the same
// texture (used for Alias models)

#include "r_local.h"

int	rand1k[] = {
#include "rand1k.h"
};

#define MASK_1K	0x3FF

int		rand1k_index = 0;

// TODO: put in span spilling to shrink list size
// !!! if this is changed, it must be changed in d_polysa.s too !!!
#define DPS_MAXSPANS			MAXHEIGHT+1	
									// 1 extra for spanpackage that marks end

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct {
	void			*pdest;
	short			*pz;
	int				count;
	byte			*ptex;
	int				sfrac, tfrac, light, zi;
} spanpackage_t;

typedef struct {
	int		isflattop;
	int		numleftedges;
	int		*pleftedgevert0;
	int		*pleftedgevert1;
	int		*pleftedgevert2;
	int		numrightedges;
	int		*prightedgevert0;
	int		*prightedgevert1;
	int		*prightedgevert2;
} edgetable;

aliastriangleparms_t aliastriangleparms;

int	r_p0[6], r_p1[6], r_p2[6];

byte		*d_pcolormap;

int			d_aflatcolor;
int			d_xdenom;

edgetable	*pedgetable;

edgetable	edgetables[12] = {
	{0, 1, r_p0, r_p2, NULL, 2, r_p0, r_p1, r_p2 },
	{0, 2, r_p1, r_p0, r_p2,   1, r_p1, r_p2, NULL},
	{1, 1, r_p0, r_p2, NULL, 1, r_p1, r_p2, NULL},
	{0, 1, r_p1, r_p0, NULL, 2, r_p1, r_p2, r_p0 },
	{0, 2, r_p0, r_p2, r_p1,   1, r_p0, r_p1, NULL},
	{0, 1, r_p2, r_p1, NULL, 1, r_p2, r_p0, NULL},
	{0, 1, r_p2, r_p1, NULL, 2, r_p2, r_p0, r_p1 },
	{0, 2, r_p2, r_p1, r_p0,   1, r_p2, r_p0, NULL},
	{0, 1, r_p1, r_p0, NULL, 1, r_p1, r_p2, NULL},
	{1, 1, r_p2, r_p1, NULL, 1, r_p0, r_p1, NULL},
	{1, 1, r_p1, r_p0, NULL, 1, r_p2, r_p0, NULL},
	{0, 1, r_p0, r_p2, NULL, 1, r_p0, r_p1, NULL},
};

// FIXME: some of these can become statics
int				a_sstepxfrac, a_tstepxfrac, r_lstepx, a_ststepxwhole;
int				r_sstepx, r_tstepx, r_lstepy, r_sstepy, r_tstepy;
int				r_zistepx, r_zistepy;
int				d_aspancount, d_countextrastep;

spanpackage_t			*a_spans;
spanpackage_t			*d_pedgespanpackage;
static int				ystart;
byte					*d_pdest, *d_ptex;
short					*d_pz;
int						d_sfrac, d_tfrac, d_light, d_zi;
int						d_ptexextrastep, d_sfracextrastep;
int						d_tfracextrastep, d_lightextrastep, d_pdestextrastep;
int						d_lightbasestep, d_pdestbasestep, d_ptexbasestep;
int						d_sfracbasestep, d_tfracbasestep;
int						d_ziextrastep, d_zibasestep;
int						d_pzextrastep, d_pzbasestep;

typedef struct {
	int		quotient;
	int		remainder;
} adivtab_t;

static adivtab_t	adivtab[32*32] = {
#include "adivtab.h"
};

byte	*skintable[MAX_LBM_HEIGHT];
int		skinwidth;
byte	*skinstart;

void	(*d_pdrawspans)(spanpackage_t *pspanpackage);

void R_PolysetDrawSpans8_33 (spanpackage_t *pspanpackage);
void R_PolysetDrawSpans8_66 (spanpackage_t *pspanpackage);
void R_PolysetDrawSpans8_Opaque (spanpackage_t *pspanpackage);

void R_PolysetDrawThreshSpans8 (spanpackage_t *pspanpackage);
void R_PolysetCalcGradients (int skinwidth);
void R_DrawNonSubdiv (void);
void R_PolysetSetEdgeTable (void);
void R_RasterizeAliasPolySmooth (void);
void R_PolysetScanLeftEdge(int height);
void R_PolysetScanLeftEdge_C(int height);

// ======================
// PGM
// 64 65 66 67 68 69 70 71   72 73 74 75 76 77 78 79
byte iractive = 0;
byte irtable[256] = { 79, 78, 77, 76, 75, 74, 73, 72,		// black/white
					  71, 70, 69, 68, 67, 66, 65, 64,
					  64, 65, 66, 67, 68, 69, 70, 71,		// dark taupe
					  72, 73, 74, 75, 76, 77, 78, 79,

					  64, 65, 66, 67, 68, 69, 70, 71,		// slate grey
					  72, 73, 74, 75, 76, 77, 78, 79,
					  208, 208, 208, 208, 208, 208, 208, 208,	// unused?'
					  64, 66, 68, 70, 72, 74, 76, 78,		// dark yellow
					  
					  64, 65, 66, 67, 68, 69, 70, 71,		// dark red
					  72, 73, 74, 75, 76, 77, 78, 79,
					  64, 65, 66, 67, 68, 69, 70, 71,		// grey/tan
					  72, 73, 74, 75, 76, 77, 78, 79,

					  64, 66, 68, 70, 72, 74, 76, 78,		// chocolate
					  68, 67, 66, 65, 64, 65, 66, 67,		// mauve / teal
					  68, 69, 70, 71, 72, 73, 74, 75,
					  76, 76, 77, 77, 78, 78, 79, 79,		

					  64, 65, 66, 67, 68, 69, 70, 71,		// more mauve
					  72, 73, 74, 75, 76, 77, 78, 79,
					  64, 65, 66, 67, 68, 69, 70, 71,		// olive
					  72, 73, 74, 75, 76, 77, 78, 79,

					  64, 65, 66, 67, 68, 69, 70, 71,		// maroon
					  72, 73, 74, 75, 76, 77, 78, 79,
					  64, 65, 66, 67, 68, 69, 70, 71,		// sky blue
					  72, 73, 74, 75, 76, 77, 78, 79,
					  
					  64, 65, 66, 67, 68, 69, 70, 71,		// olive again
					  72, 73, 74, 75, 76, 77, 78, 79,
					  64, 65, 66, 67, 68, 69, 70, 71,		// nuclear green
					  64, 65, 66, 67, 68, 69, 70, 71,		// bright yellow

					  64, 65, 66, 67, 68, 69, 70, 71,		// fire colors
					  72, 73, 74, 75, 76, 77, 78, 79,
					  208, 208, 64, 64, 70, 71, 72, 64,		// mishmash1
					  66, 68, 70, 64, 65, 66, 67, 68};		// mishmash2
// PGM
// ======================

/*
================
R_PolysetUpdateTables
================
*/
void R_PolysetUpdateTables (void)
{
	int		i;
	byte	*s;
	
	if (r_affinetridesc.skinwidth != skinwidth ||
		r_affinetridesc.pskin != skinstart)
	{
		skinwidth = r_affinetridesc.skinwidth;
		skinstart = r_affinetridesc.pskin;
		s = skinstart;
		for (i=0 ; i<MAX_LBM_HEIGHT ; i++, s+=skinwidth)
			skintable[i] = s;
	}
}


/*
================
R_DrawTriangle
================
*/
void R_DrawTriangle( void )
{
	spanpackage_t spans[DPS_MAXSPANS];

	int dv1_ab, dv0_ac;
	int dv0_ab, dv1_ac;

	/*
	d_xdenom = ( aliastriangleparms.a->v[1] - aliastriangleparms.b->v[1] ) * ( aliastriangleparms.a->v[0] - aliastriangleparms.c->v[0] ) -
			   ( aliastriangleparms.a->v[0] - aliastriangleparms.b->v[0] ) * ( aliastriangleparms.a->v[1] - aliastriangleparms.c->v[1] );
	*/

	dv0_ab = aliastriangleparms.a->u - aliastriangleparms.b->u;
	dv1_ab = aliastriangleparms.a->v - aliastriangleparms.b->v;

	if ( !( dv0_ab | dv1_ab ) )
		return;

	dv0_ac = aliastriangleparms.a->u - aliastriangleparms.c->u;
	dv1_ac = aliastriangleparms.a->v - aliastriangleparms.c->v;

	if ( !( dv0_ac | dv1_ac ) )
		return;

	d_xdenom = ( dv0_ac * dv1_ab ) - ( dv0_ab * dv1_ac );

	if ( d_xdenom < 0 )
	{
		a_spans = spans;

		r_p0[0] = aliastriangleparms.a->u;		// u
		r_p0[1] = aliastriangleparms.a->v;		// v
		r_p0[2] = aliastriangleparms.a->s;		// s
		r_p0[3] = aliastriangleparms.a->t;		// t
		r_p0[4] = aliastriangleparms.a->l;		// light
		r_p0[5] = aliastriangleparms.a->zi;		// iz

		r_p1[0] = aliastriangleparms.b->u;
		r_p1[1] = aliastriangleparms.b->v;
		r_p1[2] = aliastriangleparms.b->s;
		r_p1[3] = aliastriangleparms.b->t;
		r_p1[4] = aliastriangleparms.b->l;
		r_p1[5] = aliastriangleparms.b->zi;

		r_p2[0] = aliastriangleparms.c->u;
		r_p2[1] = aliastriangleparms.c->v;
		r_p2[2] = aliastriangleparms.c->s;
		r_p2[3] = aliastriangleparms.c->t;
		r_p2[4] = aliastriangleparms.c->l;
		r_p2[5] = aliastriangleparms.c->zi;

		R_PolysetSetEdgeTable ();
		R_RasterizeAliasPolySmooth ();
	}
}


/*
===================
R_PolysetScanLeftEdge_C
====================
*/
void R_PolysetScanLeftEdge_C(int height)
{
	do
	{
		d_pedgespanpackage->pdest = d_pdest;
		d_pedgespanpackage->pz = d_pz;
		d_pedgespanpackage->count = d_aspancount;
		d_pedgespanpackage->ptex = d_ptex;

		d_pedgespanpackage->sfrac = d_sfrac;
		d_pedgespanpackage->tfrac = d_tfrac;

	// FIXME: need to clamp l, s, t, at both ends?
		d_pedgespanpackage->light = d_light;
		d_pedgespanpackage->zi = d_zi;

		d_pedgespanpackage++;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_pdest += d_pdestextrastep;
			d_pz += d_pzextrastep;
			d_aspancount += d_countextrastep;
			d_ptex += d_ptexextrastep;
			d_sfrac += d_sfracextrastep;
			d_ptex += d_sfrac >> 16;

			d_sfrac &= 0xFFFF;
			d_tfrac += d_tfracextrastep;
			if (d_tfrac & 0x10000)
			{
				d_ptex += r_affinetridesc.skinwidth;
				d_tfrac &= 0xFFFF;
			}
			d_light += d_lightextrastep;
			d_zi += d_ziextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_pdest += d_pdestbasestep;
			d_pz += d_pzbasestep;
			d_aspancount += ubasestep;
			d_ptex += d_ptexbasestep;
			d_sfrac += d_sfracbasestep;
			d_ptex += d_sfrac >> 16;
			d_sfrac &= 0xFFFF;
			d_tfrac += d_tfracbasestep;
			if (d_tfrac & 0x10000)
			{
				d_ptex += r_affinetridesc.skinwidth;
				d_tfrac &= 0xFFFF;
			}
			d_light += d_lightbasestep;
			d_zi += d_zibasestep;
		}
	} while (--height);
}

/*
===================
FloorDivMod

Returns mathematically correct (floor-based) quotient and remainder for
numer and denom, both of which should contain no fractional part. The
quotient must fit in 32 bits.
FIXME: GET RID OF THIS! (FloorDivMod)
====================
*/
void FloorDivMod (float numer, float denom, int *quotient,
		int *rem)
{
	int		q, r;
	float	x;

	if (numer >= 0.0)
	{

		x = floor(numer / denom);
		q = (int)x;
		r = (int)floor(numer - (x * denom));
	}
	else
	{
	//
	// perform operations with positive values, and fix mod to make floor-based
	//
		x = floor(-numer / denom);
		q = -(int)x;
		r = (int)floor(-numer - (x * denom));
		if (r != 0)
		{
			q--;
			r = (int)denom - r;
		}
	}

	*quotient = q;
	*rem = r;
}


/*
===================
R_PolysetSetUpForLineScan
====================
*/
void R_PolysetSetUpForLineScan(fixed8_t startvertu, fixed8_t startvertv,
		fixed8_t endvertu, fixed8_t endvertv)
{
	float		dm, dn;
	int			tm, tn;
	adivtab_t	*ptemp;

// TODO: implement x86 version

	errorterm = -1;

	tm = endvertu - startvertu;
	tn = endvertv - startvertv;

	if (((tm <= 16) && (tm >= -15)) &&
		((tn <= 16) && (tn >= -15)))
	{
		ptemp = &adivtab[((tm+15) << 5) + (tn+15)];
		ubasestep = ptemp->quotient;
		erroradjustup = ptemp->remainder;
		erroradjustdown = tn;
	}
	else
	{
		dm = tm;
		dn = tn;

		FloorDivMod (dm, dn, &ubasestep, &erroradjustup);

		erroradjustdown = dn;
	}
}



/*
================
R_PolysetCalcGradients
================
*/
#if id386 && !defined __linux__
void R_PolysetCalcGradients( int skinwidth )
{
	static float xstepdenominv, ystepdenominv, t0, t1;
	static float p01_minus_p21, p11_minus_p21, p00_minus_p20, p10_minus_p20;
	static float one = 1.0F, negative_one = -1.0F;
	static unsigned long t0_int, t1_int;

	extern unsigned long fpu_sp24_ceil_cw, fpu_ceil_cw, fpu_chop_cw;

	/*
	p00_minus_p20 = r_p0[0] - r_p2[0];
	p01_minus_p21 = r_p0[1] - r_p2[1];
	p10_minus_p20 = r_p1[0] - r_p2[0];
	p11_minus_p21 = r_p1[1] - r_p2[1];
	*/

	__asm mov eax, dword ptr [r_p0+0]
	__asm mov ebx, dword ptr [r_p0+4]
	__asm sub eax, dword ptr [r_p2+0]
	__asm sub ebx, dword ptr [r_p2+4]
	__asm mov p00_minus_p20, eax
	__asm mov p01_minus_p21, ebx
	__asm fild dword ptr p00_minus_p20
	__asm fild dword ptr p01_minus_p21
	__asm mov eax, dword ptr [r_p1+0]
	__asm mov ebx, dword ptr [r_p1+4]
	__asm sub eax, dword ptr [r_p2+0]
	__asm sub ebx, dword ptr [r_p2+4]
	__asm fstp p01_minus_p21
	__asm fstp p00_minus_p20
	__asm mov p10_minus_p20, eax
	__asm mov p11_minus_p21, ebx
	__asm fild dword ptr p10_minus_p20
	__asm fild dword ptr p11_minus_p21
	__asm fstp p11_minus_p21
	__asm fstp p10_minus_p20

	/*
	xstepdenominv = 1.0 / (float)d_xdenom;

	ystepdenominv = -xstepdenominv;
	*/

	/*
	** put FPU in single precision ceil mode
	*/
	__asm fldcw word ptr [fpu_sp24_ceil_cw]
//	__asm fldcw word ptr [fpu_ceil_cw]

	__asm fild  dword ptr d_xdenom    ; d_xdenom
	__asm fdivr one                   ; 1 / d_xdenom
	__asm fst   xstepdenominv         ; 
	__asm fmul  negative_one          ; -( 1 / d_xdenom )

// ceil () for light so positive steps are exaggerated, negative steps
// diminished,  pushing us away from underflow toward overflow. Underflow is
// very visible, overflow is very unlikely, because of ambient lighting
	/*
	t0 = r_p0[4] - r_p2[4];
	t1 = r_p1[4] - r_p2[4];
	r_lstepx = (int)
			ceil((t1 * p01_minus_p21 - t0 * p11_minus_p21) * xstepdenominv);
	r_lstepy = (int)
			ceil((t1 * p00_minus_p20 - t0 * p10_minus_p20) * ystepdenominv);
	*/
	__asm mov   eax, dword ptr [r_p0+16]
	__asm mov   ebx, dword ptr [r_p1+16]
	__asm sub   eax, dword ptr [r_p2+16]
	__asm sub   ebx, dword ptr [r_p2+16]

	__asm fstp  ystepdenominv       ; (empty)

	__asm mov   t0_int, eax
	__asm mov   t1_int, ebx
	__asm fild  t0_int              ; t0
	__asm fild  t1_int              ; t1 | t0
	__asm fxch  st(1)               ; t0 | t1
	__asm fstp  t0                  ; t1
	__asm fst   t1                  ; t1
	__asm fmul  p01_minus_p21       ; t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p01_minus_p21
	__asm fmul  p11_minus_p21       ; t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t1                  ; t1 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p00_minus_p20       ; t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p10_minus_p20       ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fxch  st(2)               ; t0 * p11_minus_p21 | t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21
	__asm fsubp st(3), st           ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fsubrp st(1), st          ; t1 * p00_minus_p20 - t0 * p10_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fxch  st(1)               ; t1 * p01_minus_p21 - t0 * p11_minus_p21 | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fmul  xstepdenominv       ; r_lstepx | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fxch  st(1)
	__asm fmul  ystepdenominv       ; r_lstepy | r_lstepx
	__asm fxch  st(1)               ; r_lstepx | r_lstepy
	__asm fistp dword ptr [r_lstepx]
	__asm fistp dword ptr [r_lstepy]

	/*
	** put FPU back into extended precision chop mode
	*/
	__asm fldcw word ptr [fpu_chop_cw]

	/*
	t0 = r_p0[2] - r_p2[2];
	t1 = r_p1[2] - r_p2[2];
	r_sstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_sstepy = (int)((t1 * p00_minus_p20 - t0* p10_minus_p20) *
			ystepdenominv);
	*/
	__asm mov eax, dword ptr [r_p0+8]
	__asm mov ebx, dword ptr [r_p1+8]
	__asm sub eax, dword ptr [r_p2+8]
	__asm sub ebx, dword ptr [r_p2+8]
	__asm mov   t0_int, eax
	__asm mov   t1_int, ebx
	__asm fild  t0_int              ; t0
	__asm fild  t1_int              ; t1 | t0
	__asm fxch  st(1)               ; t0 | t1
	__asm fstp  t0                  ; t1
	__asm fst   t1                  ; (empty)

	__asm fmul  p01_minus_p21       ; t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p01_minus_p21
	__asm fmul  p11_minus_p21       ; t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t1                  ; t1 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p00_minus_p20       ; t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p10_minus_p20       ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fxch  st(2)               ; t0 * p11_minus_p21 | t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21
	__asm fsubp st(3), st           ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fsubrp st(1), st           ; t1 * p00_minus_p20 - t0 * p10_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fxch  st(1)               ; t1 * p01_minus_p21 - t0 * p11_minus_p21 | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fmul  xstepdenominv       ; r_lstepx | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fxch  st(1)
	__asm fmul  ystepdenominv       ; r_lstepy | r_lstepx
	__asm fxch  st(1)               ; r_lstepx | r_lstepy
	__asm fistp dword ptr [r_sstepx]
	__asm fistp dword ptr [r_sstepy]

	/*
	t0 = r_p0[3] - r_p2[3];
	t1 = r_p1[3] - r_p2[3];
	r_tstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_tstepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
			ystepdenominv);
	*/
	__asm mov eax, dword ptr [r_p0+12]
	__asm mov ebx, dword ptr [r_p1+12]
	__asm sub eax, dword ptr [r_p2+12]
	__asm sub ebx, dword ptr [r_p2+12]

	__asm mov   t0_int, eax
	__asm mov   t1_int, ebx
	__asm fild  t0_int              ; t0
	__asm fild  t1_int              ; t1 | t0
	__asm fxch  st(1)               ; t0 | t1
	__asm fstp  t0                  ; t1
	__asm fst   t1                  ; (empty)

	__asm fmul  p01_minus_p21       ; t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p01_minus_p21
	__asm fmul  p11_minus_p21       ; t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t1                  ; t1 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p00_minus_p20       ; t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p10_minus_p20       ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fxch  st(2)               ; t0 * p11_minus_p21 | t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21
	__asm fsubp st(3), st           ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fsubrp st(1), st           ; t1 * p00_minus_p20 - t0 * p10_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fxch  st(1)               ; t1 * p01_minus_p21 - t0 * p11_minus_p21 | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fmul  xstepdenominv       ; r_lstepx | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fxch  st(1)
	__asm fmul  ystepdenominv       ; r_lstepy | r_lstepx
	__asm fxch  st(1)               ; r_lstepx | r_lstepy
	__asm fistp dword ptr [r_tstepx]
	__asm fistp dword ptr [r_tstepy]

	/*
	t0 = r_p0[5] - r_p2[5];
	t1 = r_p1[5] - r_p2[5];
	r_zistepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_zistepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
			ystepdenominv);
	*/
	__asm mov eax, dword ptr [r_p0+20]
	__asm mov ebx, dword ptr [r_p1+20]
	__asm sub eax, dword ptr [r_p2+20]
	__asm sub ebx, dword ptr [r_p2+20]

	__asm mov   t0_int, eax
	__asm mov   t1_int, ebx
	__asm fild  t0_int              ; t0
	__asm fild  t1_int              ; t1 | t0
	__asm fxch  st(1)               ; t0 | t1
	__asm fstp  t0                  ; t1
	__asm fst   t1                  ; (empty)

	__asm fmul  p01_minus_p21       ; t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p01_minus_p21
	__asm fmul  p11_minus_p21       ; t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t1                  ; t1 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p00_minus_p20       ; t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fld   t0                  ; t0 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fmul  p10_minus_p20       ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t0 * p11_minus_p21 | t1 * p01_minus_p21
	__asm fxch  st(2)               ; t0 * p11_minus_p21 | t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21
	__asm fsubp st(3), st           ; t0 * p10_minus_p20 | t1 * p00_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fsubrp st(1), st           ; t1 * p00_minus_p20 - t0 * p10_minus_p20 | t1 * p01_minus_p21 - t0 * p11_minus_p21
	__asm fxch  st(1)               ; t1 * p01_minus_p21 - t0 * p11_minus_p21 | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fmul  xstepdenominv       ; r_lstepx | t1 * p00_minus_p20 - t0 * p10_minus_p20
	__asm fxch  st(1)
	__asm fmul  ystepdenominv       ; r_lstepy | r_lstepx
	__asm fxch  st(1)               ; r_lstepx | r_lstepy
	__asm fistp dword ptr [r_zistepx]
	__asm fistp dword ptr [r_zistepy]

	/*
#if	id386ALIAS
	a_sstepxfrac = r_sstepx << 16;
	a_tstepxfrac = r_tstepx << 16;
#else
	a_sstepxfrac = r_sstepx & 0xFFFF;
	a_tstepxfrac = r_tstepx & 0xFFFF;
#endif
	*/
	__asm mov eax, d_pdrawspans
	__asm cmp eax, offset R_PolysetDrawSpans8_Opaque
	__asm mov eax, r_sstepx
	__asm mov ebx, r_tstepx
	__asm jne translucent
//#if id386ALIAS
	__asm shl eax, 16
	__asm shl ebx, 16
	__asm jmp done_with_steps
//#else
translucent:
	__asm and eax, 0ffffh
	__asm and ebx, 0ffffh
//#endif
done_with_steps:
	__asm mov a_sstepxfrac, eax
	__asm mov a_tstepxfrac, ebx

	/*
	a_ststepxwhole = skinwidth * (r_tstepx >> 16) + (r_sstepx >> 16);
	*/
	__asm mov ebx, r_tstepx
	__asm mov ecx, r_sstepx
	__asm sar ebx, 16
	__asm mov eax, skinwidth
	__asm mul ebx
	__asm sar ecx, 16
	__asm add eax, ecx
	__asm mov a_ststepxwhole, eax
}
#else
void R_PolysetCalcGradients (int skinwidth)
{
	float	xstepdenominv, ystepdenominv, t0, t1;
	float	p01_minus_p21, p11_minus_p21, p00_minus_p20, p10_minus_p20;

	p00_minus_p20 = r_p0[0] - r_p2[0];
	p01_minus_p21 = r_p0[1] - r_p2[1];
	p10_minus_p20 = r_p1[0] - r_p2[0];
	p11_minus_p21 = r_p1[1] - r_p2[1];

	xstepdenominv = 1.0 / (float)d_xdenom;

	ystepdenominv = -xstepdenominv;

// ceil () for light so positive steps are exaggerated, negative steps
// diminished,  pushing us away from underflow toward overflow. Underflow is
// very visible, overflow is very unlikely, because of ambient lighting
	t0 = r_p0[4] - r_p2[4];
	t1 = r_p1[4] - r_p2[4];
	r_lstepx = (int)
			ceil((t1 * p01_minus_p21 - t0 * p11_minus_p21) * xstepdenominv);
	r_lstepy = (int)
			ceil((t1 * p00_minus_p20 - t0 * p10_minus_p20) * ystepdenominv);

	t0 = r_p0[2] - r_p2[2];
	t1 = r_p1[2] - r_p2[2];
	r_sstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_sstepy = (int)((t1 * p00_minus_p20 - t0* p10_minus_p20) *
			ystepdenominv);

	t0 = r_p0[3] - r_p2[3];
	t1 = r_p1[3] - r_p2[3];
	r_tstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_tstepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
			ystepdenominv);

	t0 = r_p0[5] - r_p2[5];
	t1 = r_p1[5] - r_p2[5];
	r_zistepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
			xstepdenominv);
	r_zistepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
			ystepdenominv);

//#if	id386ALIAS
#if id386
	if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
	{
		a_sstepxfrac = r_sstepx << 16;
		a_tstepxfrac = r_tstepx << 16;
	}
	else
#endif
	{
//#else
		a_sstepxfrac = r_sstepx & 0xFFFF;
		a_tstepxfrac = r_tstepx & 0xFFFF;
	}
//#endif

	a_ststepxwhole = skinwidth * (r_tstepx >> 16) + (r_sstepx >> 16);
}
#endif

/*
================
R_PolysetDrawThreshSpans8

Random fizzle fade rasterizer
================
*/
void R_PolysetDrawThreshSpans8 (spanpackage_t *pspanpackage)
{
	int		lcount;
	byte	*lpdest;
	byte	*lptex;
	int		lsfrac, ltfrac;
	int		llight;
	int		lzi;
	short	*lpz;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			lpdest = pspanpackage->pdest;
			lptex = pspanpackage->ptex;
			lpz = pspanpackage->pz;
			lsfrac = pspanpackage->sfrac;
			ltfrac = pspanpackage->tfrac;
			llight = pspanpackage->light;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
					rand1k_index = (rand1k_index + 1) & MASK_1K;

					if (rand1k[rand1k_index] <= r_affinetridesc.vis_thresh)
					{
						*lpdest = ((byte *)vid.colormap)[*lptex + (llight & 0xFF00)];
						*lpz = lzi >> 16;
					}
				}

				lpdest++;
				lzi += r_zistepx;
				lpz++;
				llight += r_lstepx;
				lptex += a_ststepxwhole;
				lsfrac += a_sstepxfrac;
				lptex += lsfrac >> 16;
				lsfrac &= 0xFFFF;
				ltfrac += a_tstepxfrac;
				if (ltfrac & 0x10000)
				{
					lptex += r_affinetridesc.skinwidth;
					ltfrac &= 0xFFFF;
				}
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}


/*
================
R_PolysetDrawSpans8
================
*/
void R_PolysetDrawSpans8_33( spanpackage_t *pspanpackage)
{
	int		lcount;
	byte	*lpdest;
	byte	*lptex;
	int		lsfrac, ltfrac;
	int		llight;
	int		lzi;
	short	*lpz;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			lpdest = pspanpackage->pdest;
			lptex = pspanpackage->ptex;
			lpz = pspanpackage->pz;
			lsfrac = pspanpackage->sfrac;
			ltfrac = pspanpackage->tfrac;
			llight = pspanpackage->light;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
					int temp = vid.colormap[*lptex + ( llight & 0xFF00 )];

					*lpdest = vid.alphamap[temp+ *lpdest*256];
				}
				lpdest++;
				lzi += r_zistepx;
				lpz++;
				llight += r_lstepx;
				lptex += a_ststepxwhole;
				lsfrac += a_sstepxfrac;
				lptex += lsfrac >> 16;
				lsfrac &= 0xFFFF;
				ltfrac += a_tstepxfrac;
				if (ltfrac & 0x10000)
				{
					lptex += r_affinetridesc.skinwidth;
					ltfrac &= 0xFFFF;
				}
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}

void R_PolysetDrawSpansConstant8_33( spanpackage_t *pspanpackage)
{
	int		lcount;
	byte	*lpdest;
	int		lzi;
	short	*lpz;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			lpdest = pspanpackage->pdest;
			lpz = pspanpackage->pz;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
					*lpdest = vid.alphamap[r_aliasblendcolor + *lpdest*256];
				}
				lpdest++;
				lzi += r_zistepx;
				lpz++;
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}

void R_PolysetDrawSpans8_66(spanpackage_t *pspanpackage)
{
	int		lcount;
	byte	*lpdest;
	byte	*lptex;
	int		lsfrac, ltfrac;
	int		llight;
	int		lzi;
	short	*lpz;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			lpdest = pspanpackage->pdest;
			lptex = pspanpackage->ptex;
			lpz = pspanpackage->pz;
			lsfrac = pspanpackage->sfrac;
			ltfrac = pspanpackage->tfrac;
			llight = pspanpackage->light;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
					int temp = vid.colormap[*lptex + ( llight & 0xFF00 )];

					*lpdest = vid.alphamap[temp*256 + *lpdest];
					*lpz = lzi >> 16;
				}
				lpdest++;
				lzi += r_zistepx;
				lpz++;
				llight += r_lstepx;
				lptex += a_ststepxwhole;
				lsfrac += a_sstepxfrac;
				lptex += lsfrac >> 16;
				lsfrac &= 0xFFFF;
				ltfrac += a_tstepxfrac;
				if (ltfrac & 0x10000)
				{
					lptex += r_affinetridesc.skinwidth;
					ltfrac &= 0xFFFF;
				}
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}

void R_PolysetDrawSpansConstant8_66( spanpackage_t *pspanpackage)
{
	int		lcount;
	byte	*lpdest;
	int		lzi;
	short	*lpz;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			lpdest = pspanpackage->pdest;
			lpz = pspanpackage->pz;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
					*lpdest = vid.alphamap[r_aliasblendcolor*256 + *lpdest];
				}
				lpdest++;
				lzi += r_zistepx;
				lpz++;
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}

#if !id386
void R_PolysetDrawSpans8_Opaque (spanpackage_t *pspanpackage)
{
	int		lcount;

	do
	{
		lcount = d_aspancount - pspanpackage->count;

		errorterm += erroradjustup;
		if (errorterm >= 0)
		{
			d_aspancount += d_countextrastep;
			errorterm -= erroradjustdown;
		}
		else
		{
			d_aspancount += ubasestep;
		}

		if (lcount)
		{
			int		lsfrac, ltfrac;
			byte	*lpdest;
			byte	*lptex;
			int		llight;
			int		lzi;
			short	*lpz;

			lpdest = pspanpackage->pdest;
			lptex = pspanpackage->ptex;
			lpz = pspanpackage->pz;
			lsfrac = pspanpackage->sfrac;
			ltfrac = pspanpackage->tfrac;
			llight = pspanpackage->light;
			lzi = pspanpackage->zi;

			do
			{
				if ((lzi >> 16) >= *lpz)
				{
//PGM
					if(r_newrefdef.rdflags & RDF_IRGOGGLES && currententity->flags & RF_IR_VISIBLE)
						*lpdest = ((byte *)vid.colormap)[irtable[*lptex]];
					else
					*lpdest = ((byte *)vid.colormap)[*lptex + (llight & 0xFF00)];
//PGM
					*lpz = lzi >> 16;
				}
				lpdest++;
				lzi += r_zistepx;
				lpz++;
				llight += r_lstepx;
				lptex += a_ststepxwhole;
				lsfrac += a_sstepxfrac;
				lptex += lsfrac >> 16;
				lsfrac &= 0xFFFF;
				ltfrac += a_tstepxfrac;
				if (ltfrac & 0x10000)
				{
					lptex += r_affinetridesc.skinwidth;
					ltfrac &= 0xFFFF;
				}
			} while (--lcount);
		}

		pspanpackage++;
	} while (pspanpackage->count != -999999);
}
#endif


/*
================
R_PolysetFillSpans8
================
*/
void R_PolysetFillSpans8 (spanpackage_t *pspanpackage)
{
	int				color;

// FIXME: do z buffering

	color = d_aflatcolor++;

	while (1)
	{
		int		lcount;
		byte	*lpdest;

		lcount = pspanpackage->count;

		if (lcount == -1)
			return;

		if (lcount)
		{
			lpdest = pspanpackage->pdest;

			do
			{
				*lpdest++ = color;
			} while (--lcount);
		}

		pspanpackage++;
	}
}

/*
================
R_RasterizeAliasPolySmooth
================
*/
void R_RasterizeAliasPolySmooth (void)
{
	int				initialleftheight, initialrightheight;
	int				*plefttop, *prighttop, *pleftbottom, *prightbottom;
	int				working_lstepx, originalcount;

	plefttop = pedgetable->pleftedgevert0;
	prighttop = pedgetable->prightedgevert0;

	pleftbottom = pedgetable->pleftedgevert1;
	prightbottom = pedgetable->prightedgevert1;

	initialleftheight = pleftbottom[1] - plefttop[1];
	initialrightheight = prightbottom[1] - prighttop[1];

//
// set the s, t, and light gradients, which are consistent across the triangle
// because being a triangle, things are affine
//
	R_PolysetCalcGradients (r_affinetridesc.skinwidth);
//
// rasterize the polygon
//

//
// scan out the top (and possibly only) part of the left edge
//
	d_pedgespanpackage = a_spans;

	ystart = plefttop[1];
	d_aspancount = plefttop[0] - prighttop[0];

	d_ptex = (byte *)r_affinetridesc.pskin + (plefttop[2] >> 16) +
			(plefttop[3] >> 16) * r_affinetridesc.skinwidth;
//#if	id386ALIAS
#if id386
	if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
	{
		d_sfrac = (plefttop[2] & 0xFFFF) << 16;
		d_tfrac = (plefttop[3] & 0xFFFF) << 16;
	}
//#else
	else
#endif
	{
		d_sfrac = plefttop[2] & 0xFFFF;
		d_tfrac = plefttop[3] & 0xFFFF;
	}
//#endif
	d_light = plefttop[4];
	d_zi = plefttop[5];

	d_pdest = (byte *)d_viewbuffer +
			ystart * r_screenwidth + plefttop[0];
	d_pz = d_pzbuffer + ystart * d_zwidth + plefttop[0];

	if (initialleftheight == 1)
	{
		d_pedgespanpackage->pdest = d_pdest;
		d_pedgespanpackage->pz = d_pz;
		d_pedgespanpackage->count = d_aspancount;
		d_pedgespanpackage->ptex = d_ptex;

		d_pedgespanpackage->sfrac = d_sfrac;
		d_pedgespanpackage->tfrac = d_tfrac;

	// FIXME: need to clamp l, s, t, at both ends?
		d_pedgespanpackage->light = d_light;
		d_pedgespanpackage->zi = d_zi;

		d_pedgespanpackage++;
	}
	else
	{
		R_PolysetSetUpForLineScan(plefttop[0], plefttop[1],
							  pleftbottom[0], pleftbottom[1]);

//#if	id386ALIAS
#if id386
		if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
		{
			d_pzbasestep = (d_zwidth + ubasestep) << 1;
			d_pzextrastep = d_pzbasestep + 2;
		}
//#else
		else
#endif
		{
			d_pzbasestep = d_zwidth + ubasestep;
			d_pzextrastep = d_pzbasestep + 1;
		}
//#endif

		d_pdestbasestep = r_screenwidth + ubasestep;
		d_pdestextrastep = d_pdestbasestep + 1;

	// TODO: can reuse partial expressions here

	// for negative steps in x along left edge, bias toward overflow rather than
	// underflow (sort of turning the floor () we did in the gradient calcs into
	// ceil (), but plus a little bit)
		if (ubasestep < 0)
			working_lstepx = r_lstepx - 1;
		else
			working_lstepx = r_lstepx;

		d_countextrastep = ubasestep + 1;
		d_ptexbasestep = ((r_sstepy + r_sstepx * ubasestep) >> 16) +
				((r_tstepy + r_tstepx * ubasestep) >> 16) *
				r_affinetridesc.skinwidth;
//#if	id386ALIAS
#if id386
		if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
		{
			d_sfracbasestep = (r_sstepy + r_sstepx * ubasestep) << 16;
			d_tfracbasestep = (r_tstepy + r_tstepx * ubasestep) << 16;
		}
		else
#endif
		{
//#else
			d_sfracbasestep = (r_sstepy + r_sstepx * ubasestep) & 0xFFFF;
			d_tfracbasestep = (r_tstepy + r_tstepx * ubasestep) & 0xFFFF;
		}
//#endif
		d_lightbasestep = r_lstepy + working_lstepx * ubasestep;
		d_zibasestep = r_zistepy + r_zistepx * ubasestep;

		d_ptexextrastep = ((r_sstepy + r_sstepx * d_countextrastep) >> 16) +
				((r_tstepy + r_tstepx * d_countextrastep) >> 16) *
				r_affinetridesc.skinwidth;
//#if	id386ALIAS
#if id386
		if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
		{
			d_sfracextrastep = (r_sstepy + r_sstepx*d_countextrastep) << 16;
			d_tfracextrastep = (r_tstepy + r_tstepx*d_countextrastep) << 16;
		}
		else
#endif
		{
//#else
			d_sfracextrastep = (r_sstepy + r_sstepx*d_countextrastep) & 0xFFFF;
			d_tfracextrastep = (r_tstepy + r_tstepx*d_countextrastep) & 0xFFFF;
		}
//#endif
		d_lightextrastep = d_lightbasestep + working_lstepx;
		d_ziextrastep = d_zibasestep + r_zistepx;

#if id386
		if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
		{
			R_PolysetScanLeftEdge (initialleftheight);
		}
		else
#endif
		{
			R_PolysetScanLeftEdge_C(initialleftheight);
		}
	}

//
// scan out the bottom part of the left edge, if it exists
//
	if (pedgetable->numleftedges == 2)
	{
		int		height;

		plefttop = pleftbottom;
		pleftbottom = pedgetable->pleftedgevert2;

		height = pleftbottom[1] - plefttop[1];

// TODO: make this a function; modularize this function in general

		ystart = plefttop[1];
		d_aspancount = plefttop[0] - prighttop[0];
		d_ptex = (byte *)r_affinetridesc.pskin + (plefttop[2] >> 16) +
				(plefttop[3] >> 16) * r_affinetridesc.skinwidth;
		d_sfrac = 0;
		d_tfrac = 0;
		d_light = plefttop[4];
		d_zi = plefttop[5];

		d_pdest = (byte *)d_viewbuffer + ystart * r_screenwidth + plefttop[0];
		d_pz = d_pzbuffer + ystart * d_zwidth + plefttop[0];

		if (height == 1)
		{
			d_pedgespanpackage->pdest = d_pdest;
			d_pedgespanpackage->pz = d_pz;
			d_pedgespanpackage->count = d_aspancount;
			d_pedgespanpackage->ptex = d_ptex;

			d_pedgespanpackage->sfrac = d_sfrac;
			d_pedgespanpackage->tfrac = d_tfrac;

		// FIXME: need to clamp l, s, t, at both ends?
			d_pedgespanpackage->light = d_light;
			d_pedgespanpackage->zi = d_zi;

			d_pedgespanpackage++;
		}
		else
		{
			R_PolysetSetUpForLineScan(plefttop[0], plefttop[1],
								  pleftbottom[0], pleftbottom[1]);

			d_pdestbasestep = r_screenwidth + ubasestep;
			d_pdestextrastep = d_pdestbasestep + 1;

//#if	id386ALIAS
#if id386
			if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
			{
				d_pzbasestep = (d_zwidth + ubasestep) << 1;
				d_pzextrastep = d_pzbasestep + 2;
			}
//#else
			else
#endif
			{
				d_pzbasestep = d_zwidth + ubasestep;
				d_pzextrastep = d_pzbasestep + 1;
			}
//#endif

			if (ubasestep < 0)
				working_lstepx = r_lstepx - 1;
			else
				working_lstepx = r_lstepx;

			d_countextrastep = ubasestep + 1;
			d_ptexbasestep = ((r_sstepy + r_sstepx * ubasestep) >> 16) +
					((r_tstepy + r_tstepx * ubasestep) >> 16) *
					r_affinetridesc.skinwidth;
//#if	id386ALIAS
#if id386
			if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
			{
				d_sfracbasestep = (r_sstepy + r_sstepx * ubasestep) << 16;
				d_tfracbasestep = (r_tstepy + r_tstepx * ubasestep) << 16;
			}
//#else
			else
#endif
			{
				d_sfracbasestep = (r_sstepy + r_sstepx * ubasestep) & 0xFFFF;
				d_tfracbasestep = (r_tstepy + r_tstepx * ubasestep) & 0xFFFF;
			}
//#endif
			d_lightbasestep = r_lstepy + working_lstepx * ubasestep;
			d_zibasestep = r_zistepy + r_zistepx * ubasestep;

			d_ptexextrastep = ((r_sstepy + r_sstepx * d_countextrastep) >> 16) +
					((r_tstepy + r_tstepx * d_countextrastep) >> 16) *
					r_affinetridesc.skinwidth;
//#if	id386ALIAS
#if id386
			if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
			{
				d_sfracextrastep = ((r_sstepy+r_sstepx*d_countextrastep) & 0xFFFF)<<16;
				d_tfracextrastep = ((r_tstepy+r_tstepx*d_countextrastep) & 0xFFFF)<<16;
			}
			else
#endif
//#endif
			{
				d_sfracextrastep = (r_sstepy+r_sstepx*d_countextrastep) & 0xFFFF;
				d_tfracextrastep = (r_tstepy+r_tstepx*d_countextrastep) & 0xFFFF;
			}
//#endif
			d_lightextrastep = d_lightbasestep + working_lstepx;
			d_ziextrastep = d_zibasestep + r_zistepx;

#if id386
			if ( d_pdrawspans == R_PolysetDrawSpans8_Opaque )
			{
				R_PolysetScanLeftEdge (height);
			}
			else
#endif
			{
				R_PolysetScanLeftEdge_C(height);
			}
		}
	}

// scan out the top (and possibly only) part of the right edge, updating the
// count field
	d_pedgespanpackage = a_spans;

	R_PolysetSetUpForLineScan(prighttop[0], prighttop[1],
						  prightbottom[0], prightbottom[1]);
	d_aspancount = 0;
	d_countextrastep = ubasestep + 1;
	originalcount = a_spans[initialrightheight].count;
	a_spans[initialrightheight].count = -999999; // mark end of the spanpackages
	(*d_pdrawspans) (a_spans);

// scan out the bottom part of the right edge, if it exists
	if (pedgetable->numrightedges == 2)
	{
		int				height;
		spanpackage_t	*pstart;

		pstart = a_spans + initialrightheight;
		pstart->count = originalcount;

		d_aspancount = prightbottom[0] - prighttop[0];

		prighttop = prightbottom;
		prightbottom = pedgetable->prightedgevert2;

		height = prightbottom[1] - prighttop[1];

		R_PolysetSetUpForLineScan(prighttop[0], prighttop[1],
							  prightbottom[0], prightbottom[1]);

		d_countextrastep = ubasestep + 1;
		a_spans[initialrightheight + height].count = -999999;
											// mark end of the spanpackages
		(*d_pdrawspans) (pstart);
	}
}


/*
================
R_PolysetSetEdgeTable
================
*/
void R_PolysetSetEdgeTable (void)
{
	int			edgetableindex;

	edgetableindex = 0;	// assume the vertices are already in
						//  top to bottom order

//
// determine which edges are right & left, and the order in which
// to rasterize them
//
	if (r_p0[1] >= r_p1[1])
	{
		if (r_p0[1] == r_p1[1])
		{
			if (r_p0[1] < r_p2[1])
				pedgetable = &edgetables[2];
			else
				pedgetable = &edgetables[5];

			return;
		}
		else
		{
			edgetableindex = 1;
		}
	}

	if (r_p0[1] == r_p2[1])
	{
		if (edgetableindex)
			pedgetable = &edgetables[8];
		else
			pedgetable = &edgetables[9];

		return;
	}
	else if (r_p1[1] == r_p2[1])
	{
		if (edgetableindex)
			pedgetable = &edgetables[10];
		else
			pedgetable = &edgetables[11];

		return;
	}

	if (r_p0[1] > r_p2[1])
		edgetableindex += 2;

	if (r_p1[1] > r_p2[1])
		edgetableindex += 4;

	pedgetable = &edgetables[edgetableindex];
}


