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
#include "r_local.h"

vec3_t r_pright, r_pup, r_ppn;

#define PARTICLE_33     0
#define PARTICLE_66     1
#define PARTICLE_OPAQUE 2

typedef struct
{
	particle_t *particle;
	int         level;
	int         color;
} partparms_t;

static partparms_t partparms;

#if id386 && !defined __linux__

static unsigned s_prefetch_address;

/*
** BlendParticleXX
**
** Inputs:
** EAX = color
** EDI = pdest
**
** Scratch:
** EBX = scratch (dstcolor)
** EBP = scratch
**
** Outputs:
** none
*/
__declspec(naked) void BlendParticle33( void )
{
	//	return vid.alphamap[color + dstcolor*256];
	__asm mov ebp, vid.alphamap
	__asm xor ebx, ebx

	__asm mov bl,  byte ptr [edi]
	__asm shl ebx, 8

	__asm add ebp, ebx
	__asm add ebp, eax

	__asm mov al,  byte ptr [ebp]

	__asm mov byte ptr [edi], al

	__asm ret
}

__declspec(naked) void BlendParticle66( void )
{
	//	return vid.alphamap[pcolor*256 + dstcolor];
	__asm mov ebp, vid.alphamap
	__asm xor ebx, ebx

	__asm shl eax,  8
	__asm mov bl,   byte ptr [edi]

	__asm add ebp, ebx
	__asm add ebp, eax

	__asm mov al,  byte ptr [ebp]

	__asm mov byte ptr [edi], al

	__asm ret
}

__declspec(naked) void BlendParticle100( void )
{
	__asm mov byte ptr [edi], al
	__asm ret
}

/*
** R_DrawParticle (asm version)
**
** Since we use __declspec( naked ) we don't have a stack frame
** that we can use.  Since I want to reserve EBP anyway, I tossed
** all the important variables into statics.  This routine isn't
** meant to be re-entrant, so this shouldn't cause any problems
** other than a slightly higher global memory footprint.
**
*/
__declspec(naked) void R_DrawParticle( void )
{
	static vec3_t	local, transformed;
	static float	zi;
	static int      u, v, tmp;
	static short    izi;
	static int      ebpsave;

	static byte (*blendfunc)(void);

	/*
	** must be memvars since x86 can't load constants
	** directly.  I guess I could use fld1, but that
	** actually costs one more clock than fld [one]!
	*/
	static float    particle_z_clip    = PARTICLE_Z_CLIP;
	static float    one                = 1.0F;
	static float    point_five         = 0.5F;
	static float    eight_thousand_hex = 0x8000;

	/*
	** save trashed variables
	*/
	__asm mov  ebpsave, ebp
	__asm push esi
	__asm push edi

	/*
	** transform the particle
	*/
	// VectorSubtract (pparticle->origin, r_origin, local);
	__asm mov  esi, partparms.particle
	__asm fld  dword ptr [esi+0]          ; p_o.x
	__asm fsub dword ptr [r_origin+0]     ; p_o.x-r_o.x
	__asm fld  dword ptr [esi+4]          ; p_o.y | p_o.x-r_o.x
	__asm fsub dword ptr [r_origin+4]     ; p_o.y-r_o.y | p_o.x-r_o.x
	__asm fld  dword ptr [esi+8]          ; p_o.z | p_o.y-r_o.y | p_o.x-r_o.x
	__asm fsub dword ptr [r_origin+8]     ; p_o.z-r_o.z | p_o.y-r_o.y | p_o.x-r_o.x
	__asm fxch st(2)                      ; p_o.x-r_o.x | p_o.y-r_o.y | p_o.z-r_o.z
	__asm fstp dword ptr [local+0]        ; p_o.y-r_o.y | p_o.z-r_o.z
	__asm fstp dword ptr [local+4]        ; p_o.z-r_o.z
	__asm fstp dword ptr [local+8]        ; (empty)

	// transformed[0] = DotProduct(local, r_pright);
	// transformed[1] = DotProduct(local, r_pup);
	// transformed[2] = DotProduct(local, r_ppn);
	__asm fld  dword ptr [local+0]        ; l.x
	__asm fmul dword ptr [r_pright+0]     ; l.x*pr.x
	__asm fld  dword ptr [local+4]        ; l.y | l.x*pr.x
	__asm fmul dword ptr [r_pright+4]     ; l.y*pr.y | l.x*pr.x
	__asm fld  dword ptr [local+8]        ; l.z | l.y*pr.y | l.x*pr.x
	__asm fmul dword ptr [r_pright+8]     ; l.z*pr.z | l.y*pr.y | l.x*pr.x
	__asm fxch st(2)                      ; l.x*pr.x | l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y + l.z*pr.z
	__asm fstp  dword ptr [transformed+0] ; (empty)

	__asm fld  dword ptr [local+0]        ; l.x
	__asm fmul dword ptr [r_pup+0]        ; l.x*pr.x
	__asm fld  dword ptr [local+4]        ; l.y | l.x*pr.x
	__asm fmul dword ptr [r_pup+4]        ; l.y*pr.y | l.x*pr.x
	__asm fld  dword ptr [local+8]        ; l.z | l.y*pr.y | l.x*pr.x
	__asm fmul dword ptr [r_pup+8]        ; l.z*pr.z | l.y*pr.y | l.x*pr.x
	__asm fxch st(2)                      ; l.x*pr.x | l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y + l.z*pr.z
	__asm fstp  dword ptr [transformed+4] ; (empty)

	__asm fld  dword ptr [local+0]        ; l.x
	__asm fmul dword ptr [r_ppn+0]        ; l.x*pr.x
	__asm fld  dword ptr [local+4]        ; l.y | l.x*pr.x
	__asm fmul dword ptr [r_ppn+4]        ; l.y*pr.y | l.x*pr.x
	__asm fld  dword ptr [local+8]        ; l.z | l.y*pr.y | l.x*pr.x
	__asm fmul dword ptr [r_ppn+8]        ; l.z*pr.z | l.y*pr.y | l.x*pr.x
	__asm fxch st(2)                      ; l.x*pr.x | l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y | l.z*pr.z
	__asm faddp st(1), st                 ; l.x*pr.x + l.y*pr.y + l.z*pr.z
	__asm fstp  dword ptr [transformed+8] ; (empty)

	/*
	** make sure that the transformed particle is not in front of
	** the particle Z clip plane.  We can do the comparison in 
	** integer space since we know the sign of one of the inputs
	** and can figure out the sign of the other easily enough.
	*/
	//	if (transformed[2] < PARTICLE_Z_CLIP)
	//		return;

	__asm mov  eax, dword ptr [transformed+8]
	__asm and  eax, eax
	__asm js   end
	__asm cmp  eax, particle_z_clip
	__asm jl   end

	/*
	** project the point by initiating the 1/z calc
	*/
	//	zi = 1.0 / transformed[2];
	__asm fld   one
	__asm fdiv  dword ptr [transformed+8]

	/*
	** bind the blend function pointer to the appropriate blender
	** while we're dividing
	*/
	//if ( level == PARTICLE_33 )
	//	blendparticle = BlendParticle33;
	//else if ( level == PARTICLE_66 )
	//	blendparticle = BlendParticle66;
	//else 
	//	blendparticle = BlendParticle100;

	__asm cmp partparms.level, PARTICLE_66
	__asm je  blendfunc_66
	__asm jl  blendfunc_33
	__asm lea ebx, BlendParticle100
	__asm jmp done_selecting_blend_func
blendfunc_33:
	__asm lea ebx, BlendParticle33
	__asm jmp done_selecting_blend_func
blendfunc_66:
	__asm lea ebx, BlendParticle66
done_selecting_blend_func:
	__asm mov blendfunc, ebx

	// prefetch the next particle
	__asm mov ebp, s_prefetch_address
	__asm mov ebp, [ebp]

	// finish the above divide
	__asm fstp  zi

	// u = (int)(xcenter + zi * transformed[0] + 0.5);
	// v = (int)(ycenter - zi * transformed[1] + 0.5);
	__asm fld   zi                           ; zi
	__asm fmul  dword ptr [transformed+0]    ; zi * transformed[0]
	__asm fld   zi                           ; zi | zi * transformed[0]
	__asm fmul  dword ptr [transformed+4]    ; zi * transformed[1] | zi * transformed[0]
	__asm fxch  st(1)                        ; zi * transformed[0] | zi * transformed[1]
	__asm fadd  xcenter                      ; xcenter + zi * transformed[0] | zi * transformed[1]
	__asm fxch  st(1)                        ; zi * transformed[1] | xcenter + zi * transformed[0]
	__asm fld   ycenter                      ; ycenter | zi * transformed[1] | xcenter + zi * transformed[0]
    __asm fsubrp st(1), st(0)                ; ycenter - zi * transformed[1] | xcenter + zi * transformed[0]
  	__asm fxch  st(1)                        ; xcenter + zi * transformed[0] | ycenter + zi * transformed[1]
  	__asm fadd  point_five                   ; xcenter + zi * transformed[0] + 0.5 | ycenter - zi * transformed[1]
  	__asm fxch  st(1)                        ; ycenter - zi * transformed[1] | xcenter + zi * transformed[0] + 0.5 
  	__asm fadd  point_five                   ; ycenter - zi * transformed[1] + 0.5 | xcenter + zi * transformed[0] + 0.5 
  	__asm fxch  st(1)                        ; u | v
  	__asm fistp dword ptr [u]                ; v
  	__asm fistp dword ptr [v]                ; (empty)

	/*
	** clip out the particle
	*/

	//	if ((v > d_vrectbottom_particle) || 
	//		(u > d_vrectright_particle) ||
	//		(v < d_vrecty) ||
	//		(u < d_vrectx))
	//	{
	//		return;
	//	}

	__asm mov ebx, u
	__asm mov ecx, v
	__asm cmp ecx, d_vrectbottom_particle
	__asm jg  end
	__asm cmp ecx, d_vrecty
	__asm jl  end
	__asm cmp ebx, d_vrectright_particle
	__asm jg  end
	__asm cmp ebx, d_vrectx
	__asm jl  end

	/*
	** compute addresses of zbuffer, framebuffer, and 
	** compute the Z-buffer reference value.
	**
	** EBX      = U
	** ECX      = V
	**
	** Outputs:
	** ESI = Z-buffer address
	** EDI = framebuffer address
	*/
	// ESI = d_pzbuffer + (d_zwidth * v) + u;
	__asm mov esi, d_pzbuffer             ; esi = d_pzbuffer
	__asm mov eax, d_zwidth               ; eax = d_zwidth
	__asm mul ecx                         ; eax = d_zwidth*v
	__asm add eax, ebx                    ; eax = d_zwidth*v+u
	__asm shl eax, 1                      ; eax = 2*(d_zwidth*v+u)
	__asm add esi, eax                    ; esi = ( short * ) ( d_pzbuffer + ( d_zwidth * v ) + u )

	// initiate
	// izi = (int)(zi * 0x8000);
	__asm fld  zi
	__asm fmul eight_thousand_hex

	// EDI = pdest = d_viewbuffer + d_scantable[v] + u;
	__asm lea edi, [d_scantable+ecx*4]
	__asm mov edi, [edi]
	__asm add edi, d_viewbuffer
	__asm add edi, ebx

	// complete
	// izi = (int)(zi * 0x8000);
	__asm fistp tmp
	__asm mov   eax, tmp
	__asm mov   izi, ax

	/*
	** determine the screen area covered by the particle,
	** which also means clamping to a min and max
	*/
	//	pix = izi >> d_pix_shift;
	__asm xor edx, edx
	__asm mov dx, izi
	__asm mov ecx, d_pix_shift
	__asm shr dx, cl

	//	if (pix < d_pix_min)
	//		pix = d_pix_min;
	__asm cmp edx, d_pix_min
	__asm jge check_pix_max
	__asm mov edx, d_pix_min
	__asm jmp skip_pix_clamp

	//	else if (pix > d_pix_max)
	//		pix = d_pix_max;
check_pix_max:
	__asm cmp edx, d_pix_max
	__asm jle skip_pix_clamp
	__asm mov edx, d_pix_max

skip_pix_clamp:

	/*
	** render the appropriate pixels
	**
	** ECX = count (used for inner loop)
	** EDX = count (used for outer loop)
	** ESI = zbuffer
	** EDI = framebuffer
	*/
	__asm mov ecx, edx

	__asm cmp ecx, 1
	__asm ja  over

over:

	/*
	** at this point:
	**
	** ECX = count
	*/
	__asm push ecx
	__asm push edi
	__asm push esi

top_of_pix_vert_loop:

top_of_pix_horiz_loop:

	//	for ( ; count ; count--, pz += d_zwidth, pdest += screenwidth)
	//	{
	//		for (i=0 ; i<pix ; i++)
	//		{
	//			if (pz[i] <= izi)
	//			{
	//				pdest[i] = blendparticle( color, pdest[i] );
	//			}
	//		}
	//	}
	__asm xor   eax, eax

	__asm mov   ax, word ptr [esi]

	__asm cmp   ax, izi
	__asm jg    end_of_horiz_loop

#if ENABLE_ZWRITES_FOR_PARTICLES
  	__asm mov   bp, izi
  	__asm mov   word ptr [esi], bp
#endif

	__asm mov   eax, partparms.color

	__asm call  [blendfunc]

	__asm add   edi, 1
	__asm add   esi, 2

end_of_horiz_loop:

	__asm dec   ecx
	__asm jnz   top_of_pix_horiz_loop

	__asm pop   esi
	__asm pop   edi

	__asm mov   ebp, d_zwidth
	__asm shl   ebp, 1

	__asm add   esi, ebp
	__asm add   edi, [r_screenwidth]

	__asm pop   ecx
	__asm push  ecx

	__asm push  edi
	__asm push  esi

	__asm dec   edx
	__asm jnz   top_of_pix_vert_loop

	__asm pop   ecx
	__asm pop   ecx
	__asm pop   ecx

end:
	__asm pop edi
	__asm pop esi
	__asm mov ebp, ebpsave
	__asm ret
}

#else

static byte BlendParticle33( int pcolor, int dstcolor )
{
	return vid.alphamap[pcolor + dstcolor*256];
}

static byte BlendParticle66( int pcolor, int dstcolor )
{
	return vid.alphamap[pcolor*256+dstcolor];
}

static byte BlendParticle100( int pcolor, int dstcolor )
{
	dstcolor = dstcolor;
	return pcolor;
}

/*
** R_DrawParticle
**
** Yes, this is amazingly slow, but it's the C reference
** implementation and should be both robust and vaguely
** understandable.  The only time this path should be
** executed is if we're debugging on x86 or if we're
** recompiling and deploying on a non-x86 platform.
**
** To minimize error and improve readability I went the 
** function pointer route.  This exacts some overhead, but
** it pays off in clean and easy to understand code.
*/
void R_DrawParticle( void )
{
	particle_t *pparticle = partparms.particle;
	int         level     = partparms.level;
	vec3_t	local, transformed;
	float	zi;
	byte	*pdest;
	short	*pz;
	int      color = pparticle->color;
	int		i, izi, pix, count, u, v;
	byte  (*blendparticle)( int, int );

	/*
	** transform the particle
	*/
	VectorSubtract (pparticle->origin, r_origin, local);

	transformed[0] = DotProduct(local, r_pright);
	transformed[1] = DotProduct(local, r_pup);
	transformed[2] = DotProduct(local, r_ppn);		

	if (transformed[2] < PARTICLE_Z_CLIP)
		return;

	/*
	** bind the blend function pointer to the appropriate blender
	*/
	if ( level == PARTICLE_33 )
		blendparticle = BlendParticle33;
	else if ( level == PARTICLE_66 )
		blendparticle = BlendParticle66;
	else 
		blendparticle = BlendParticle100;

	/*
	** project the point
	*/
	// FIXME: preadjust xcenter and ycenter
	zi = 1.0 / transformed[2];
	u = (int)(xcenter + zi * transformed[0] + 0.5);
	v = (int)(ycenter - zi * transformed[1] + 0.5);

	if ((v > d_vrectbottom_particle) || 
		(u > d_vrectright_particle) ||
		(v < d_vrecty) ||
		(u < d_vrectx))
	{
		return;
	}

	/*
	** compute addresses of zbuffer, framebuffer, and 
	** compute the Z-buffer reference value.
	*/
	pz = d_pzbuffer + (d_zwidth * v) + u;
	pdest = d_viewbuffer + d_scantable[v] + u;
	izi = (int)(zi * 0x8000);

	/*
	** determine the screen area covered by the particle,
	** which also means clamping to a min and max
	*/
	pix = izi >> d_pix_shift;
	if (pix < d_pix_min)
		pix = d_pix_min;
	else if (pix > d_pix_max)
		pix = d_pix_max;

	/*
	** render the appropriate pixels
	*/
	count = pix;

    switch (level) {
    case PARTICLE_33 :
        for ( ; count ; count--, pz += d_zwidth, pdest += r_screenwidth)
        {
//FIXME--do it in blocks of 8?
            for (i=0 ; i<pix ; i++)
            {
                if (pz[i] <= izi)
                {
                    pz[i]    = izi;
                    pdest[i] = vid.alphamap[color + ((int)pdest[i]<<8)];
                }
            }
        }
        break;

    case PARTICLE_66 :
        for ( ; count ; count--, pz += d_zwidth, pdest += r_screenwidth)
        {
            for (i=0 ; i<pix ; i++)
            {
                if (pz[i] <= izi)
                {
                    pz[i]    = izi;
                    pdest[i] = vid.alphamap[(color<<8) + (int)pdest[i]];
                }
            }
        }
        break;

    default:  //100
        for ( ; count ; count--, pz += d_zwidth, pdest += r_screenwidth)
        {
            for (i=0 ; i<pix ; i++)
            {
                if (pz[i] <= izi)
                {
                    pz[i]    = izi;
                    pdest[i] = color;
                }
            }
        }
        break;
    }
}

#endif	// !id386

/*
** R_DrawParticles
**
** Responsible for drawing all of the particles in the particle list
** throughout the world.  Doesn't care if we're using the C path or
** if we're using the asm path, it simply assigns a function pointer
** and goes.
*/
void R_DrawParticles (void)
{
	particle_t *p;
	int         i;
	extern unsigned long fpu_sp24_cw, fpu_chop_cw;

	VectorScale( vright, xscaleshrink, r_pright );
	VectorScale( vup, yscaleshrink, r_pup );
	VectorCopy( vpn, r_ppn );

#if id386 && !defined __linux__
	__asm fldcw word ptr [fpu_sp24_cw]
#endif

	for (p=r_newrefdef.particles, i=0 ; i<r_newrefdef.num_particles ; i++,p++)
	{

		if ( p->alpha > 0.66 )
			partparms.level = PARTICLE_OPAQUE;
		else if ( p->alpha > 0.33 )
			partparms.level = PARTICLE_66;
		else
			partparms.level = PARTICLE_33;

		partparms.particle = p;
		partparms.color    = p->color;

#if id386 && !defined __linux__
		if ( i < r_newrefdef.num_particles-1 )
			s_prefetch_address = ( unsigned int ) ( p + 1 );
		else
			s_prefetch_address = ( unsigned int ) r_newrefdef.particles;
#endif

		R_DrawParticle();
	}

#if id386 && !defined __linux__
	__asm fldcw word ptr [fpu_chop_cw]
#endif

}

