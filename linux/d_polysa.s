//
// d_polysa.s
// x86 assembly-language polygon model drawing code
//

#include "qasm.h"
#include "d_ifacea.h"

#if	id386

// !!! if this is changed, it must be changed in d_polyse.c too !!!
#define DPS_MAXSPANS			MAXHEIGHT+1	
									// 1 extra for spanpackage that marks end

//#define	SPAN_SIZE	(((DPS_MAXSPANS + 1 + ((CACHE_SIZE - 1) / spanpackage_t_size)) + 1) * spanpackage_t_size)
#define SPAN_SIZE (1024+1+1+1)*32



	.data

	.align	4
p10_minus_p20:	.single		0
p01_minus_p21:	.single		0
temp0:			.single		0
temp1:			.single		0
Ltemp:			.single		0

aff8entryvec_table:	.long	LDraw8, LDraw7, LDraw6, LDraw5
				.long	LDraw4, LDraw3, LDraw2, LDraw1

lzistepx:		.long	0


	.text

#ifndef NeXT
	.extern C(D_PolysetSetEdgeTable)
	.extern C(D_RasterizeAliasPolySmooth)
#endif

//----------------------------------------------------------------------
// affine triangle gradient calculation code
//----------------------------------------------------------------------

#if 0
#define skinwidth	4+0

.globl C(R_PolysetCalcGradients)
C(R_PolysetCalcGradients):

//	p00_minus_p20 = r_p0[0] - r_p2[0];
//	p01_minus_p21 = r_p0[1] - r_p2[1];
//	p10_minus_p20 = r_p1[0] - r_p2[0];
//	p11_minus_p21 = r_p1[1] - r_p2[1];
//
//	xstepdenominv = 1.0 / (p10_minus_p20 * p01_minus_p21 -
//			     p00_minus_p20 * p11_minus_p21);
//
//	ystepdenominv = -xstepdenominv;

	fildl	C(r_p0)+0		// r_p0[0]
	fildl	C(r_p2)+0		// r_p2[0] | r_p0[0]
	fildl	C(r_p0)+4		// r_p0[1] | r_p2[0] | r_p0[0]
	fildl	C(r_p2)+4		// r_p2[1] | r_p0[1] | r_p2[0] | r_p0[0]
	fildl	C(r_p1)+0		// r_p1[0] | r_p2[1] | r_p0[1] | r_p2[0] | r_p0[0]
	fildl	C(r_p1)+4		// r_p1[1] | r_p1[0] | r_p2[1] | r_p0[1] |
							//  r_p2[0] | r_p0[0]
	fxch	%st(3)			// r_p0[1] | r_p1[0] | r_p2[1] | r_p1[1] |
							//  r_p2[0] | r_p0[0]
	fsub	%st(2),%st(0)	// p01_minus_p21 | r_p1[0] | r_p2[1] | r_p1[1] |
							//  r_p2[0] | r_p0[0]
	fxch	%st(1)			// r_p1[0] | p01_minus_p21 | r_p2[1] | r_p1[1] |
							//  r_p2[0] | r_p0[0]
	fsub	%st(4),%st(0)	// p10_minus_p20 | p01_minus_p21 | r_p2[1] |
							//  r_p1[1] | r_p2[0] | r_p0[0]
	fxch	%st(5)			// r_p0[0] | p01_minus_p21 | r_p2[1] |
							//  r_p1[1] | r_p2[0] | p10_minus_p20
	fsubp	%st(0),%st(4)	// p01_minus_p21 | r_p2[1] | r_p1[1] |
							//  p00_minus_p20 | p10_minus_p20
	fxch	%st(2)			// r_p1[1] | r_p2[1] | p01_minus_p21 |
							//  p00_minus_p20 | p10_minus_p20
	fsubp	%st(0),%st(1)	// p11_minus_p21 | p01_minus_p21 |
							//  p00_minus_p20 | p10_minus_p20
	fxch	%st(1)			// p01_minus_p21 | p11_minus_p21 |
							//  p00_minus_p20 | p10_minus_p20
	flds	C(d_xdenom)		// d_xdenom | p01_minus_p21 | p11_minus_p21 |
							//  p00_minus_p20 | p10_minus_p20
	fxch	%st(4)			// p10_minus_p20 | p01_minus_p21 | p11_minus_p21 |
							//  p00_minus_p20 | d_xdenom
	fstps	p10_minus_p20	// p01_minus_p21 | p11_minus_p21 |
							//  p00_minus_p20 | d_xdenom
	fstps	p01_minus_p21	// p11_minus_p21 | p00_minus_p20 | xstepdenominv
	fxch	%st(2)			// xstepdenominv | p00_minus_p20 | p11_minus_p21

//// ceil () for light so positive steps are exaggerated, negative steps
//// diminished,  pushing us away from underflow toward overflow. Underflow is
//// very visible, overflow is very unlikely, because of ambient lighting
//	t0 = r_p0[4] - r_p2[4];
//	t1 = r_p1[4] - r_p2[4];

	fildl	C(r_p2)+16		// r_p2[4] | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fildl	C(r_p0)+16		// r_p0[4] | r_p2[4] | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fildl	C(r_p1)+16		// r_p1[4] | r_p0[4] | r_p2[4] | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// r_p2[4] | r_p0[4] | r_p1[4] | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// r_p2[4] | r_p2[4] | r_p0[4] | r_p1[4] |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(2)	// r_p2[4] | t0 | r_p1[4] | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(2)	// t0 | t1 | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21

//	r_lstepx = (int)
//			ceil((t1 * p01_minus_p21 - t0 * p11_minus_p21) * xstepdenominv);
//	r_lstepy = (int)
//			ceil((t1 * p00_minus_p20 - t0 * p10_minus_p20) * ystepdenominv);

	fld		%st(0)			// t0 | t0 | t1 | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmul	%st(5),%st(0)	// t0*p11_minus_p21 | t0 | t1 | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t1 | t0 | t0*p11_minus_p21 | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// t1 | t1 | t0 | t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmuls	p01_minus_p21	// t1*p01_minus_p21 | t1 | t0 | t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t0 | t1 | t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmuls	p10_minus_p20	// t0*p10_minus_p20 | t1 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// t1 | t0*p10_minus_p20 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fmul	%st(5),%st(0)	// t1*p00_minus_p20 | t0*p10_minus_p20 |
							//  t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t1*p01_minus_p21 | t0*p10_minus_p20 |
							//  t1*p00_minus_p20 | t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubp	%st(0),%st(3)	// t0*p10_minus_p20 | t1*p00_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(1)	// t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(2)			// xstepdenominv |
							//  t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmuls	float_minus_1	// ystepdenominv |
							//  t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmul	%st(3),%st(0)	// (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//   xstepdenominv |
							//  t1*p00_minus_p20 - t0*p10_minus_p20 |
							//   | ystepdenominv | xstepdenominv |
							//   p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//   xstepdenominv | ystepdenominv |
							//   xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmul	%st(2),%st(0)	// (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv |
							//  (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//  xstepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fldcw	ceil_cw
	fistpl	C(r_lstepy)		// r_lstepx | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fistpl	C(r_lstepx)		// ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fldcw	single_cw

//	t0 = r_p0[2] - r_p2[2];
//	t1 = r_p1[2] - r_p2[2];

	fildl	C(r_p2)+8		// r_p2[2] | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fildl	C(r_p0)+8		// r_p0[2] | r_p2[2] | ystepdenominv |
							//   xstepdenominv | p00_minus_p20 | p11_minus_p21
	fildl	C(r_p1)+8		// r_p1[2] | r_p0[2] | r_p2[2] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// r_p2[2] | r_p0[2] | r_p1[2] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// r_p2[2] | r_p2[2] | r_p0[2] | r_p1[2] |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubrp	%st(0),%st(2)	// r_p2[2] | t0 | r_p1[2] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(2)	// t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21

//	r_sstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
//			xstepdenominv);
//	r_sstepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
//			ystepdenominv);

	fld		%st(0)			// t0 | t0 | t1 | ystepdenominv | xstepdenominv
	fmul	%st(6),%st(0)	// t0*p11_minus_p21 | t0 | t1 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t1 | t0 | t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// t1 | t1 | t0 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmuls	p01_minus_p21	// t1*p01_minus_p21 | t1 | t0 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(2)			// t0 | t1 | t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmuls	p10_minus_p20	// t0*p10_minus_p20 | t1 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// t1 | t0*p10_minus_p20 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmul	%st(6),%st(0)	// t1*p00_minus_p20 | t0*p10_minus_p20 |
							//  t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(2)			// t1*p01_minus_p21 | t0*p10_minus_p20 |
							//  t1*p00_minus_p20 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubp	%st(0),%st(3)	// t0*p10_minus_p20 | t1*p00_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubrp	%st(0),%st(1)	// t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmul	%st(2),%st(0)	// (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//   ystepdenominv |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(1)			// t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//   ystepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmul	%st(3),%st(0)	// (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//  xstepdenominv |
							//  (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv |
							//  (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//  xstepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fistpl	C(r_sstepy)		// r_sstepx | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fistpl	C(r_sstepx)		// ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21

//	t0 = r_p0[3] - r_p2[3];
//	t1 = r_p1[3] - r_p2[3];

	fildl	C(r_p2)+12		// r_p2[3] | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fildl	C(r_p0)+12		// r_p0[3] | r_p2[3] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fildl	C(r_p1)+12		// r_p1[3] | r_p0[3] | r_p2[3] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// r_p2[3] | r_p0[3] | r_p1[3] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// r_p2[3] | r_p2[3] | r_p0[3] | r_p1[3] |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubrp	%st(0),%st(2)	// r_p2[3] | t0 | r_p1[3] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(2)	// t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21

//	r_tstepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
//			xstepdenominv);
//	r_tstepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
//			ystepdenominv);

	fld		%st(0)			// t0 | t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fmul	%st(6),%st(0)	// t0*p11_minus_p21 | t0 | t1 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// t1 | t0 | t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// t1 | t1 | t0 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmuls	p01_minus_p21	// t1*p01_minus_p21 | t1 | t0 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(2)			// t0 | t1 | t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmuls	p10_minus_p20	// t0*p10_minus_p20 | t1 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// t1 | t0*p10_minus_p20 | t1*p01_minus_p21 |
							//  t0*p11_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmul	%st(6),%st(0)	// t1*p00_minus_p20 | t0*p10_minus_p20 |
							//  t1*p01_minus_p21 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(2)			// t1*p01_minus_p21 | t0*p10_minus_p20 |
							//  t1*p00_minus_p20 | t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubp	%st(0),%st(3)	// t0*p10_minus_p20 | t1*p00_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubrp	%st(0),%st(1)	// t1*p00_minus_p20 - t0*p10_minus_p20 |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fmul	%st(2),%st(0)	// (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//   ystepdenominv |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fxch	%st(1)			// t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fmul	%st(3),%st(0)	// (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//  xstepdenominv |
							//  (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(1)			// (t1*p00_minus_p20 - t0*p10_minus_p20)*
							//  ystepdenominv |
							//  (t1*p01_minus_p21 - t0*p11_minus_p21)*
							//  xstepdenominv | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fistpl	C(r_tstepy)		// r_tstepx | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fistpl	C(r_tstepx)		// ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21

//	t0 = r_p0[5] - r_p2[5];
//	t1 = r_p1[5] - r_p2[5];

	fildl	C(r_p2)+20		// r_p2[5] | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fildl	C(r_p0)+20		// r_p0[5] | r_p2[5] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fildl	C(r_p1)+20		// r_p1[5] | r_p0[5] | r_p2[5] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fxch	%st(2)			// r_p2[5] | r_p0[5] | r_p1[5] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fld		%st(0)			// r_p2[5] | r_p2[5] | r_p0[5] | r_p1[5] |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  p11_minus_p21
	fsubrp	%st(0),%st(2)	// r_p2[5] | t0 | r_p1[5] | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 | p11_minus_p21
	fsubrp	%st(0),%st(2)	// t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21

//	r_zistepx = (int)((t1 * p01_minus_p21 - t0 * p11_minus_p21) *
//			xstepdenominv);
//	r_zistepy = (int)((t1 * p00_minus_p20 - t0 * p10_minus_p20) *
//			ystepdenominv);

	fld		%st(0)			// t0 | t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | p11_minus_p21
	fmulp	%st(0),%st(6)	// t0 | t1 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | t0*p11_minus_p21
	fxch	%st(1)			// t1 | t0 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | t0*p11_minus_p21
	fld		%st(0)			// t1 | t1 | t0 | ystepdenominv | xstepdenominv |
							//  p00_minus_p20 | t0*p11_minus_p21
	fmuls	p01_minus_p21	// t1*p01_minus_p21 | t1 | t0 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 |
							//  t0*p11_minus_p21
	fxch	%st(2)			// t0 | t1 | t1*p01_minus_p21 | ystepdenominv |
							//  xstepdenominv | p00_minus_p20 |
							//  t0*p11_minus_p21
	fmuls	p10_minus_p20	// t0*p10_minus_p20 | t1 | t1*p01_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  t0*p11_minus_p21
	fxch	%st(1)			// t1 | t0*p10_minus_p20 | t1*p01_minus_p21 |
							//  ystepdenominv | xstepdenominv | p00_minus_p20 |
							//  t0*p11_minus_p21
	fmulp	%st(0),%st(5)	// t0*p10_minus_p20 | t1*p01_minus_p21 |
							//  ystepdenominv | xstepdenominv |
							//  t1*p00_minus_p20 | t0*p11_minus_p21
	fxch	%st(5)			// t0*p11_minus_p21 | t1*p01_minus_p21 |
							//  ystepdenominv | xstepdenominv |
							//  t1*p00_minus_p20 | t0*p10_minus_p20
	fsubrp	%st(0),%st(1)	// t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  ystepdenominv | xstepdenominv |
							//  t1*p00_minus_p20 | t0*p10_minus_p20
	fxch	%st(3)			// t1*p00_minus_p20 | ystepdenominv |
							//  xstepdenominv |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  t0*p10_minus_p20
	fsubp	%st(0),%st(4)	// ystepdenominv | xstepdenominv |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  t1*p00_minus_p20 - t0*p10_minus_p20
	fxch	%st(1)			// xstepdenominv | ystepdenominv |
							//  t1*p01_minus_p21 - t0*p11_minus_p21 |
							//  t1*p00_minus_p20 - t0*p10_minus_p20
	fmulp	%st(0),%st(2)	// ystepdenominv |
							//  (t1*p01_minus_p21 - t0*p11_minus_p21) *
							//  xstepdenominv |
							//  t1*p00_minus_p20 - t0*p10_minus_p20
	fmulp	%st(0),%st(2)	// (t1*p01_minus_p21 - t0*p11_minus_p21) *
							//  xstepdenominv |
							//  (t1*p00_minus_p20 - t0*p10_minus_p20) *
							//  ystepdenominv
	fistpl	C(r_zistepx)	// (t1*p00_minus_p20 - t0*p10_minus_p20) *
							//  ystepdenominv
	fistpl	C(r_zistepy)

//	a_sstepxfrac = r_sstepx << 16;
//	a_tstepxfrac = r_tstepx << 16;
//
//	a_ststepxwhole = r_affinetridesc.skinwidth * (r_tstepx >> 16) +
//			(r_sstepx >> 16);

	movl	C(r_sstepx),%eax
	movl	C(r_tstepx),%edx
	shll	$16,%eax
	shll	$16,%edx
	movl	%eax,C(a_sstepxfrac)
	movl	%edx,C(a_tstepxfrac)

	movl	C(r_sstepx),%ecx
	movl	C(r_tstepx),%eax
	sarl	$16,%ecx
	sarl	$16,%eax
	imull	skinwidth(%esp)
	addl	%ecx,%eax
	movl	%eax,C(a_ststepxwhole)

	ret

#endif

//----------------------------------------------------------------------
// recursive subdivision affine triangle drawing code
//
// not C-callable because of stdcall return
//----------------------------------------------------------------------

#define lp1	4+16
#define lp2	8+16
#define lp3	12+16

.globl C(D_PolysetRecursiveTriangle)
C(D_PolysetRecursiveTriangle):
	pushl	%ebp				// preserve caller stack frame pointer
	pushl	%esi				// preserve register variables
	pushl	%edi
	pushl	%ebx

//	int		*temp;
//	int		d;
//	int		new[6];
//	int		i;
//	int		z;
//	short	*zbuf;
	movl	lp2(%esp),%esi
	movl	lp1(%esp),%ebx
	movl	lp3(%esp),%edi

//	d = lp2[0] - lp1[0];
//	if (d < -1 || d > 1)
//		goto split;
	movl	0(%esi),%eax

	movl	0(%ebx),%edx
	movl	4(%esi),%ebp

	subl	%edx,%eax
	movl	4(%ebx),%ecx

	subl	%ecx,%ebp
	incl	%eax

	cmpl	$2,%eax
	ja		LSplit

//	d = lp2[1] - lp1[1];
//	if (d < -1 || d > 1)
//		goto split;
	movl	0(%edi),%eax
	incl	%ebp

	cmpl	$2,%ebp
	ja		LSplit

//	d = lp3[0] - lp2[0];
//	if (d < -1 || d > 1)
//		goto split2;
	movl	0(%esi),%edx
	movl	4(%edi),%ebp

	subl	%edx,%eax
	movl	4(%esi),%ecx

	subl	%ecx,%ebp
	incl	%eax

	cmpl	$2,%eax
	ja		LSplit2

//	d = lp3[1] - lp2[1];
//	if (d < -1 || d > 1)
//		goto split2;
	movl	0(%ebx),%eax
	incl	%ebp

	cmpl	$2,%ebp
	ja		LSplit2

//	d = lp1[0] - lp3[0];
//	if (d < -1 || d > 1)
//		goto split3;
	movl	0(%edi),%edx
	movl	4(%ebx),%ebp

	subl	%edx,%eax
	movl	4(%edi),%ecx

	subl	%ecx,%ebp
	incl	%eax

	incl	%ebp
	movl	%ebx,%edx

	cmpl	$2,%eax
	ja		LSplit3

//	d = lp1[1] - lp3[1];
//	if (d < -1 || d > 1)
//	{
//split3:
//		temp = lp1;
//		lp3 = lp2;
//		lp1 = lp3;
//		lp2 = temp;
//		goto split;
//	}
//
//	return;			// entire tri is filled
//
	cmpl	$2,%ebp
	jna		LDone

LSplit3:
	movl	%edi,%ebx
	movl	%esi,%edi
	movl	%edx,%esi
	jmp		LSplit

//split2:
LSplit2:

//	temp = lp1;
//	lp1 = lp2;
//	lp2 = lp3;
//	lp3 = temp;
	movl	%ebx,%eax
	movl	%esi,%ebx
	movl	%edi,%esi
	movl	%eax,%edi

//split:
LSplit:

	subl	$24,%esp		// allocate space for a new vertex

//// split this edge
//	new[0] = (lp1[0] + lp2[0]) >> 1;
//	new[1] = (lp1[1] + lp2[1]) >> 1;
//	new[2] = (lp1[2] + lp2[2]) >> 1;
//	new[3] = (lp1[3] + lp2[3]) >> 1;
//	new[5] = (lp1[5] + lp2[5]) >> 1;
	movl	8(%ebx),%eax

	movl	8(%esi),%edx
	movl	12(%ebx),%ecx

	addl	%edx,%eax
	movl	12(%esi),%edx

	sarl	$1,%eax
	addl	%edx,%ecx

	movl	%eax,8(%esp)
	movl	20(%ebx),%eax

	sarl	$1,%ecx
	movl	20(%esi),%edx

	movl	%ecx,12(%esp)
	addl	%edx,%eax

	movl	0(%ebx),%ecx
	movl	0(%esi),%edx

	sarl	$1,%eax
	addl	%ecx,%edx

	movl	%eax,20(%esp)
	movl	4(%ebx),%eax

	sarl	$1,%edx
	movl	4(%esi),%ebp

	movl	%edx,0(%esp)
	addl	%eax,%ebp

	sarl	$1,%ebp
	movl	%ebp,4(%esp)

//// draw the point if splitting a leading edge
//	if (lp2[1] > lp1[1])
//		goto nodraw;
	cmpl	%eax,4(%esi)
	jg		LNoDraw

//	if ((lp2[1] == lp1[1]) && (lp2[0] < lp1[0]))
//		goto nodraw;
	movl	0(%esi),%edx
	jnz		LDraw

	cmpl	%ecx,%edx
	jl		LNoDraw

LDraw:

// z = new[5] >> 16;
	movl	20(%esp),%edx
	movl	4(%esp),%ecx

	sarl	$16,%edx
	movl	0(%esp),%ebp

//	zbuf = zspantable[new[1]] + new[0];
	movl	C(zspantable)(,%ecx,4),%eax

//	if (z >= *zbuf)
//	{
	cmpw	(%eax,%ebp,2),%dx
	jnge	LNoDraw

//		int		pix;
//		
//		*zbuf = z;
	movw	%dx,(%eax,%ebp,2)

//		pix = d_pcolormap[skintable[new[3]>>16][new[2]>>16]];
	movl	12(%esp),%eax

	sarl	$16,%eax
	movl	8(%esp),%edx

	sarl	$16,%edx
	subl	%ecx,%ecx

	movl	C(skintable)(,%eax,4),%eax
	movl	4(%esp),%ebp

	movb	(%eax,%edx,),%cl
	movl	C(d_pcolormap),%edx

	movb	(%edx,%ecx,),%dl
	movl	0(%esp),%ecx

//		d_viewbuffer[d_scantable[new[1]] + new[0]] = pix;
	movl	C(d_scantable)(,%ebp,4),%eax
	addl	%eax,%ecx
	movl	C(d_viewbuffer),%eax
	movb	%dl,(%eax,%ecx,1)

//	}
//
//nodraw:
LNoDraw:

//// recursively continue
//	D_PolysetRecursiveTriangle (lp3, lp1, new);
	pushl	%esp
	pushl	%ebx
	pushl	%edi
	call	C(D_PolysetRecursiveTriangle)

//	D_PolysetRecursiveTriangle (lp3, new, lp2);
	movl	%esp,%ebx
	pushl	%esi
	pushl	%ebx
	pushl	%edi
	call	C(D_PolysetRecursiveTriangle)
	addl	$24,%esp

LDone:
	popl	%ebx				// restore register variables
	popl	%edi
	popl	%esi
	popl	%ebp				// restore caller stack frame pointer
	ret		$12


//----------------------------------------------------------------------
// 8-bpp horizontal span drawing code for affine polygons, with smooth
// shading and no transparency
//----------------------------------------------------------------------

#define pspans	4+8

.globl C(D_PolysetAff8Start)
C(D_PolysetAff8Start):

.globl C(R_PolysetDrawSpans8_Opaque)
C(R_PolysetDrawSpans8_Opaque):
	pushl	%esi				// preserve register variables
	pushl	%ebx

	movl	pspans(%esp),%esi	// point to the first span descriptor
	movl	C(r_zistepx),%ecx

	pushl	%ebp				// preserve caller's stack frame
	pushl	%edi

	rorl	$16,%ecx			// put high 16 bits of 1/z step in low word
	movl	spanpackage_t_count(%esi),%edx

	movl	%ecx,lzistepx

LSpanLoop:

//		lcount = d_aspancount - pspanpackage->count;
//
//		errorterm += erroradjustup;
//		if (errorterm >= 0)
//		{
//			d_aspancount += d_countextrastep;
//			errorterm -= erroradjustdown;
//		}
//		else
//		{
//			d_aspancount += ubasestep;
//		}
	movl	C(d_aspancount),%eax
	subl	%edx,%eax

	movl	C(erroradjustup),%edx
	movl	C(errorterm),%ebx
	addl	%edx,%ebx
	js		LNoTurnover

	movl	C(erroradjustdown),%edx
	movl	C(d_countextrastep),%edi
	subl	%edx,%ebx
	movl	C(d_aspancount),%ebp
	movl	%ebx,C(errorterm)
	addl	%edi,%ebp
	movl	%ebp,C(d_aspancount)
	jmp		LRightEdgeStepped

LNoTurnover:
	movl	C(d_aspancount),%edi
	movl	C(ubasestep),%edx
	movl	%ebx,C(errorterm)
	addl	%edx,%edi
	movl	%edi,C(d_aspancount)

LRightEdgeStepped:
	cmpl	$1,%eax

	jl		LNextSpan
	jz		LExactlyOneLong

//
// set up advancetable
//
	movl	C(a_ststepxwhole),%ecx
	movl	C(r_affinetridesc)+atd_skinwidth,%edx

	movl	%ecx,advancetable+4	// advance base in t
	addl	%edx,%ecx

	movl	%ecx,advancetable	// advance extra in t
	movl	C(a_tstepxfrac),%ecx

	movw	C(r_lstepx),%cx
	movl	%eax,%edx			// count

	movl	%ecx,tstep
	addl	$7,%edx

	shrl	$3,%edx				// count of full and partial loops
	movl	spanpackage_t_sfrac(%esi),%ebx

	movw	%dx,%bx
	movl	spanpackage_t_pz(%esi),%ecx

	negl	%eax

	movl	spanpackage_t_pdest(%esi),%edi
	andl	$7,%eax		// 0->0, 1->7, 2->6, ... , 7->1

	subl	%eax,%edi	// compensate for hardwired offsets
	subl	%eax,%ecx

	subl	%eax,%ecx
	movl	spanpackage_t_tfrac(%esi),%edx

	movw	spanpackage_t_light(%esi),%dx
	movl	spanpackage_t_zi(%esi),%ebp

	rorl	$16,%ebp	// put high 16 bits of 1/z in low word
	pushl	%esi

	movl	spanpackage_t_ptex(%esi),%esi
	jmp		aff8entryvec_table(,%eax,4)

// %bx = count of full and partial loops
// %ebx high word = sfrac
// %ecx = pz
// %dx = light
// %edx high word = tfrac
// %esi = ptex
// %edi = pdest
// %ebp = 1/z
// tstep low word = C(r_lstepx)
// tstep high word = C(a_tstepxfrac)
// C(a_sstepxfrac) low word = 0
// C(a_sstepxfrac) high word = C(a_sstepxfrac)

LDrawLoop:

// FIXME: do we need to clamp light? We may need at least a buffer bit to
// keep it from poking into tfrac and causing problems

LDraw8:
	cmpw	(%ecx),%bp
	jl		Lp1
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,(%ecx)
	movb	0x12345678(%eax),%al
LPatch8:
	movb	%al,(%edi)
Lp1:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw7:
	cmpw	2(%ecx),%bp
	jl		Lp2
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,2(%ecx)
	movb	0x12345678(%eax),%al
LPatch7:
	movb	%al,1(%edi)
Lp2:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw6:
	cmpw	4(%ecx),%bp
	jl		Lp3
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,4(%ecx)
	movb	0x12345678(%eax),%al
LPatch6:
	movb	%al,2(%edi)
Lp3:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw5:
	cmpw	6(%ecx),%bp
	jl		Lp4
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,6(%ecx)
	movb	0x12345678(%eax),%al
LPatch5:
	movb	%al,3(%edi)
Lp4:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw4:
	cmpw	8(%ecx),%bp
	jl		Lp5
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,8(%ecx)
	movb	0x12345678(%eax),%al
LPatch4:
	movb	%al,4(%edi)
Lp5:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw3:
	cmpw	10(%ecx),%bp
	jl		Lp6
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,10(%ecx)
	movb	0x12345678(%eax),%al
LPatch3:
	movb	%al,5(%edi)
Lp6:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw2:
	cmpw	12(%ecx),%bp
	jl		Lp7
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,12(%ecx)
	movb	0x12345678(%eax),%al
LPatch2:
	movb	%al,6(%edi)
Lp7:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

LDraw1:
	cmpw	14(%ecx),%bp
	jl		Lp8
	xorl	%eax,%eax
	movb	%dh,%ah
	movb	(%esi),%al
	movw	%bp,14(%ecx)
	movb	0x12345678(%eax),%al
LPatch1:
	movb	%al,7(%edi)
Lp8:
	addl	tstep,%edx
	sbbl	%eax,%eax
	addl	lzistepx,%ebp
	adcl	$0,%ebp
	addl	C(a_sstepxfrac),%ebx
	adcl	advancetable+4(,%eax,4),%esi

	addl	$8,%edi
	addl	$16,%ecx

	decw	%bx
	jnz		LDrawLoop

	popl	%esi				// restore spans pointer
LNextSpan:
	addl	$(spanpackage_t_size),%esi	// point to next span
LNextSpanESISet:
	movl	spanpackage_t_count(%esi),%edx
	cmpl	$-999999,%edx		// any more spans?
	jnz		LSpanLoop			// yes

	popl	%edi
	popl	%ebp				// restore the caller's stack frame
	popl	%ebx				// restore register variables
	popl	%esi
	ret


// draw a one-long span

LExactlyOneLong:

	movl	spanpackage_t_pz(%esi),%ecx
	movl	spanpackage_t_zi(%esi),%ebp

	rorl	$16,%ebp	// put high 16 bits of 1/z in low word
	movl	spanpackage_t_ptex(%esi),%ebx

	cmpw	(%ecx),%bp
	jl		LNextSpan
	xorl	%eax,%eax
	movl	spanpackage_t_pdest(%esi),%edi
	movb	spanpackage_t_light+1(%esi),%ah
	addl	$(spanpackage_t_size),%esi	// point to next span
	movb	(%ebx),%al
	movw	%bp,(%ecx)
	movb	0x12345678(%eax),%al
LPatch9:
	movb	%al,(%edi)

	jmp		LNextSpanESISet

.globl C(D_PolysetAff8End)
C(D_PolysetAff8End):


.extern C(alias_colormap)
// #define pcolormap		4

.globl C(D_Aff8Patch)
C(D_Aff8Patch):
	movl	C(alias_colormap),%eax
	movl	%eax,LPatch1-4
	movl	%eax,LPatch2-4
	movl	%eax,LPatch3-4
	movl	%eax,LPatch4-4
	movl	%eax,LPatch5-4
	movl	%eax,LPatch6-4
	movl	%eax,LPatch7-4
	movl	%eax,LPatch8-4
	movl	%eax,LPatch9-4

	ret

//----------------------------------------------------------------------
// Alias model triangle left-edge scanning code
//----------------------------------------------------------------------

#define height	4+16

.globl C(R_PolysetScanLeftEdge)
C(R_PolysetScanLeftEdge):
	pushl	%ebp				// preserve caller stack frame pointer
	pushl	%esi				// preserve register variables
	pushl	%edi
	pushl	%ebx

	movl	height(%esp),%eax
	movl	C(d_sfrac),%ecx
	andl	$0xFFFF,%eax
	movl	C(d_ptex),%ebx
	orl		%eax,%ecx
	movl	C(d_pedgespanpackage),%esi
	movl	C(d_tfrac),%edx
	movl	C(d_light),%edi
	movl	C(d_zi),%ebp

// %eax: scratch
// %ebx: d_ptex
// %ecx: d_sfrac in high word, count in low word
// %edx: d_tfrac
// %esi: d_pedgespanpackage, errorterm, scratch alternately
// %edi: d_light
// %ebp: d_zi

//	do
//	{

LScanLoop:

//		d_pedgespanpackage->ptex = ptex;
//		d_pedgespanpackage->pdest = d_pdest;
//		d_pedgespanpackage->pz = d_pz;
//		d_pedgespanpackage->count = d_aspancount;
//		d_pedgespanpackage->light = d_light;
//		d_pedgespanpackage->zi = d_zi;
//		d_pedgespanpackage->sfrac = d_sfrac << 16;
//		d_pedgespanpackage->tfrac = d_tfrac << 16;
	movl	%ebx,spanpackage_t_ptex(%esi)
	movl	C(d_pdest),%eax
	movl	%eax,spanpackage_t_pdest(%esi)
	movl	C(d_pz),%eax
	movl	%eax,spanpackage_t_pz(%esi)
	movl	C(d_aspancount),%eax
	movl	%eax,spanpackage_t_count(%esi)
	movl	%edi,spanpackage_t_light(%esi)
	movl	%ebp,spanpackage_t_zi(%esi)
	movl	%ecx,spanpackage_t_sfrac(%esi)
	movl	%edx,spanpackage_t_tfrac(%esi)

// pretouch the next cache line
	movb	spanpackage_t_size(%esi),%al

//		d_pedgespanpackage++;
	addl	$(spanpackage_t_size),%esi
	movl	C(erroradjustup),%eax
	movl	%esi,C(d_pedgespanpackage)

//		errorterm += erroradjustup;
	movl	C(errorterm),%esi
	addl	%eax,%esi
	movl	C(d_pdest),%eax

//		if (errorterm >= 0)
//		{
	js		LNoLeftEdgeTurnover

//			errorterm -= erroradjustdown;
//			d_pdest += d_pdestextrastep;
	subl	C(erroradjustdown),%esi
	addl	C(d_pdestextrastep),%eax
	movl	%esi,C(errorterm)
	movl	%eax,C(d_pdest)

//			d_pz += d_pzextrastep;
//			d_aspancount += d_countextrastep;
//			d_ptex += d_ptexextrastep;
//			d_sfrac += d_sfracextrastep;
//			d_ptex += d_sfrac >> 16;
//			d_sfrac &= 0xFFFF;
//			d_tfrac += d_tfracextrastep;
	movl	C(d_pz),%eax
	movl	C(d_aspancount),%esi
	addl	C(d_pzextrastep),%eax
	addl	C(d_sfracextrastep),%ecx
	adcl	C(d_ptexextrastep),%ebx
	addl	C(d_countextrastep),%esi
	movl	%eax,C(d_pz)
	movl	C(d_tfracextrastep),%eax
	movl	%esi,C(d_aspancount)
	addl	%eax,%edx

//			if (d_tfrac & 0x10000)
//			{
	jnc		LSkip1

//				d_ptex += r_affinetridesc.skinwidth;
//				d_tfrac &= 0xFFFF;
	addl	C(r_affinetridesc)+atd_skinwidth,%ebx

//			}

LSkip1:

//			d_light += d_lightextrastep;
//			d_zi += d_ziextrastep;
	addl	C(d_lightextrastep),%edi
	addl	C(d_ziextrastep),%ebp

//		}
	movl	C(d_pedgespanpackage),%esi
	decl	%ecx
	testl	$0xFFFF,%ecx
	jnz		LScanLoop

	popl	%ebx
	popl	%edi
	popl	%esi
	popl	%ebp
	ret

//		else
//		{

LNoLeftEdgeTurnover:
	movl	%esi,C(errorterm)

//			d_pdest += d_pdestbasestep;
	addl	C(d_pdestbasestep),%eax
	movl	%eax,C(d_pdest)

//			d_pz += d_pzbasestep;
//			d_aspancount += ubasestep;
//			d_ptex += d_ptexbasestep;
//			d_sfrac += d_sfracbasestep;
//			d_ptex += d_sfrac >> 16;
//			d_sfrac &= 0xFFFF;
	movl	C(d_pz),%eax
	movl	C(d_aspancount),%esi
	addl	C(d_pzbasestep),%eax
	addl	C(d_sfracbasestep),%ecx
	adcl	C(d_ptexbasestep),%ebx
	addl	C(ubasestep),%esi
	movl	%eax,C(d_pz)
	movl	%esi,C(d_aspancount)

//			d_tfrac += d_tfracbasestep;
	movl	C(d_tfracbasestep),%esi
	addl	%esi,%edx

//			if (d_tfrac & 0x10000)
//			{
	jnc		LSkip2

//				d_ptex += r_affinetridesc.skinwidth;
//				d_tfrac &= 0xFFFF;
	addl	C(r_affinetridesc)+atd_skinwidth,%ebx

//			}

LSkip2:

//			d_light += d_lightbasestep;
//			d_zi += d_zibasestep;
	addl	C(d_lightbasestep),%edi
	addl	C(d_zibasestep),%ebp

//		}
//	} while (--height);
	movl	C(d_pedgespanpackage),%esi
	decl	%ecx
	testl	$0xFFFF,%ecx
	jnz		LScanLoop

	popl	%ebx
	popl	%edi
	popl	%esi
	popl	%ebp
	ret

#endif	// id386

