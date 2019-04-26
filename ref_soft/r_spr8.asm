 .386P
 .model FLAT
;
; d_spr8.s
; x86 assembly-language horizontal 8-bpp transparent span-drawing code.
;

include qasm.inc
include d_if.inc

if id386

;----------------------------------------------------------------------
; 8-bpp horizontal span drawing code for polygons, with transparency.
;----------------------------------------------------------------------

_TEXT SEGMENT	

; out-of-line, rarely-needed clamping code

LClampHigh0:	
 mov esi,ds:dword ptr[_bbextents]	
 jmp LClampReentry0	
LClampHighOrLow0:	
 jg LClampHigh0	
 xor esi,esi	
 jmp LClampReentry0	

LClampHigh1:	
 mov edx,ds:dword ptr[_bbextentt]	
 jmp LClampReentry1	
LClampHighOrLow1:	
 jg LClampHigh1	
 xor edx,edx	
 jmp LClampReentry1	

LClampLow2:	
 mov ebp,2048	
 jmp LClampReentry2	
LClampHigh2:	
 mov ebp,ds:dword ptr[_bbextents]	
 jmp LClampReentry2	

LClampLow3:	
 mov ecx,2048	
 jmp LClampReentry3	
LClampHigh3:	
 mov ecx,ds:dword ptr[_bbextentt]	
 jmp LClampReentry3	

LClampLow4:	
 mov eax,2048	
 jmp LClampReentry4	
LClampHigh4:	
 mov eax,ds:dword ptr[_bbextents]	
 jmp LClampReentry4	

LClampLow5:	
 mov ebx,2048	
 jmp LClampReentry5	
LClampHigh5:	
 mov ebx,ds:dword ptr[_bbextentt]	
 jmp LClampReentry5	


pspans	equ		4+16

 align 4	
 public _D_SpriteDrawSpansXXX
_D_SpriteDrawSpansXXX:	
 push ebp	; preserve caller's stack frame
 push edi	
 push esi	; preserve register variables
 push ebx	

;
; set up scaled-by-8 steps, for 8-long segments; also set up cacheblock
; and span list pointers, and 1/z step in 0.32 fixed-point
;
; FIXME: any overlap from rearranging?
 fld ds:dword ptr[_d_sdivzstepu]	
 fmul ds:dword ptr[fp_8]	
 mov edx,ds:dword ptr[_cacheblock]	
 fld ds:dword ptr[_d_tdivzstepu]	
 fmul ds:dword ptr[fp_8]	
 mov ebx,ds:dword ptr[pspans+esp]	; point to the first span descriptor
 fld ds:dword ptr[_d_zistepu]	
 fmul ds:dword ptr[fp_8]	
 mov ds:dword ptr[pbase],edx	; pbase = cacheblock
 fld ds:dword ptr[_d_zistepu]	
 fmul ds:dword ptr[fp_64kx64k]	
 fxch st(3)	
 fstp ds:dword ptr[sdivz8stepu]	
 fstp ds:dword ptr[zi8stepu]	
 fstp ds:dword ptr[tdivz8stepu]	
 fistp ds:dword ptr[izistep]	
 mov eax,ds:dword ptr[izistep]	
 ror eax,16	; put upper 16 bits in low word
 mov ecx,ds:dword ptr[sspan_t_count+ebx]	
 mov ds:dword ptr[izistep],eax	

 cmp ecx,0	
 jle LNextSpan	

LSpanLoop:	

;
; set up the initial s/z, t/z, and 1/z on the FP stack, and generate the
; initial s and t values
;
; FIXME: pipeline FILD?
 fild ds:dword ptr[sspan_t_v+ebx]	
 fild ds:dword ptr[sspan_t_u+ebx]	

 fld st(1)	; dv | du | dv
 fmul ds:dword ptr[_d_sdivzstepv]	; dv*d_sdivzstepv | du | dv
 fld st(1)	; du | dv*d_sdivzstepv | du | dv
 fmul ds:dword ptr[_d_sdivzstepu]	; du*d_sdivzstepu | dv*d_sdivzstepv | du | dv
 fld st(2)	; du | du*d_sdivzstepu | dv*d_sdivzstepv | du | dv
 fmul ds:dword ptr[_d_tdivzstepu]	; du*d_tdivzstepu | du*d_sdivzstepu |
;  dv*d_sdivzstepv | du | dv
 fxch st(1)	; du*d_sdivzstepu | du*d_tdivzstepu |
;  dv*d_sdivzstepv | du | dv
 faddp st(2),st(0)	; du*d_tdivzstepu |
;  du*d_sdivzstepu + dv*d_sdivzstepv | du | dv
 fxch st(1)	; du*d_sdivzstepu + dv*d_sdivzstepv |
;  du*d_tdivzstepu | du | dv
 fld st(3)	; dv | du*d_sdivzstepu + dv*d_sdivzstepv |
;  du*d_tdivzstepu | du | dv
 fmul ds:dword ptr[_d_tdivzstepv]	; dv*d_tdivzstepv |
;  du*d_sdivzstepu + dv*d_sdivzstepv |
;  du*d_tdivzstepu | du | dv
 fxch st(1)	; du*d_sdivzstepu + dv*d_sdivzstepv |
;  dv*d_tdivzstepv | du*d_tdivzstepu | du | dv
 fadd ds:dword ptr[_d_sdivzorigin]	; sdivz = d_sdivzorigin + dv*d_sdivzstepv +
;  du*d_sdivzstepu; stays in %st(2) at end
 fxch st(4)	; dv | dv*d_tdivzstepv | du*d_tdivzstepu | du |
;  s/z
 fmul ds:dword ptr[_d_zistepv]	; dv*d_zistepv | dv*d_tdivzstepv |
;  du*d_tdivzstepu | du | s/z
 fxch st(1)	; dv*d_tdivzstepv |  dv*d_zistepv |
;  du*d_tdivzstepu | du | s/z
 faddp st(2),st(0)	; dv*d_zistepv |
;  dv*d_tdivzstepv + du*d_tdivzstepu | du | s/z
 fxch st(2)	; du | dv*d_tdivzstepv + du*d_tdivzstepu |
;  dv*d_zistepv | s/z
 fmul ds:dword ptr[_d_zistepu]	; du*d_zistepu |
;  dv*d_tdivzstepv + du*d_tdivzstepu |
;  dv*d_zistepv | s/z
 fxch st(1)	; dv*d_tdivzstepv + du*d_tdivzstepu |
;  du*d_zistepu | dv*d_zistepv | s/z
 fadd ds:dword ptr[_d_tdivzorigin]	; tdivz = d_tdivzorigin + dv*d_tdivzstepv +
;  du*d_tdivzstepu; stays in %st(1) at end
 fxch st(2)	; dv*d_zistepv | du*d_zistepu | t/z | s/z
 faddp st(1),st(0)	; dv*d_zistepv + du*d_zistepu | t/z | s/z

 fld ds:dword ptr[fp_64k]	; fp_64k | dv*d_zistepv + du*d_zistepu | t/z | s/z
 fxch st(1)	; dv*d_zistepv + du*d_zistepu | fp_64k | t/z | s/z
 fadd ds:dword ptr[_d_ziorigin]	; zi = d_ziorigin + dv*d_zistepv +
;  du*d_zistepu; stays in %st(0) at end
; 1/z | fp_64k | t/z | s/z

 fld st(0)	; FIXME: get rid of stall on FMUL?
 fmul ds:dword ptr[fp_64kx64k]	
 fxch st(1)	

;
; calculate and clamp s & t
;
 fdiv st(2),st(0)	; 1/z | z*64k | t/z | s/z
 fxch st(1)	

 fistp ds:dword ptr[izi]	; 0.32 fixed-point 1/z
 mov ebp,ds:dword ptr[izi]	

;
; set pz to point to the first z-buffer pixel in the span
;
 ror ebp,16	; put upper 16 bits in low word
 mov eax,ds:dword ptr[sspan_t_v+ebx]	
 mov ds:dword ptr[izi],ebp	
 mov ebp,ds:dword ptr[sspan_t_u+ebx]	
 imul ds:dword ptr[_d_zrowbytes]	
 shl ebp,1	; a word per pixel
 add eax,ds:dword ptr[_d_pzbuffer]	
 add eax,ebp	
 mov ds:dword ptr[pz],eax	

;
; point %edi to the first pixel in the span
;
 mov ebp,ds:dword ptr[_d_viewbuffer]	
 mov eax,ds:dword ptr[sspan_t_v+ebx]	
 push ebx	; preserve spans pointer
 mov edx,ds:dword ptr[_tadjust]	
 mov esi,ds:dword ptr[_sadjust]	
 mov edi,ds:dword ptr[_d_scantable+eax*4]	; v * screenwidth
 add edi,ebp	
 mov ebp,ds:dword ptr[sspan_t_u+ebx]	
 add edi,ebp	; pdest = &pdestspan[scans->u];

;
; now start the FDIV for the end of the span
;
 cmp ecx,8	
 ja LSetupNotLast1	

 dec ecx	
 jz LCleanup1	; if only one pixel, no need to start an FDIV
 mov ds:dword ptr[spancountminus1],ecx	

; finish up the s and t calcs
 fxch st(1)	; z*64k | 1/z | t/z | s/z

 fld st(0)	; z*64k | z*64k | 1/z | t/z | s/z
 fmul st(0),st(4)	; s | z*64k | 1/z | t/z | s/z
 fxch st(1)	; z*64k | s | 1/z | t/z | s/z
 fmul st(0),st(3)	; t | s | 1/z | t/z | s/z
 fxch st(1)	; s | t | 1/z | t/z | s/z
 fistp ds:dword ptr[s]	; 1/z | t | t/z | s/z
 fistp ds:dword ptr[t]	; 1/z | t/z | s/z

 fild ds:dword ptr[spancountminus1]	

 fld ds:dword ptr[_d_tdivzstepu]	; _d_tdivzstepu | spancountminus1
 fld ds:dword ptr[_d_zistepu]	; _d_zistepu | _d_tdivzstepu | spancountminus1
 fmul st(0),st(2)	; _d_zistepu*scm1 | _d_tdivzstepu | scm1
 fxch st(1)	; _d_tdivzstepu | _d_zistepu*scm1 | scm1
 fmul st(0),st(2)	; _d_tdivzstepu*scm1 | _d_zistepu*scm1 | scm1
 fxch st(2)	; scm1 | _d_zistepu*scm1 | _d_tdivzstepu*scm1
 fmul ds:dword ptr[_d_sdivzstepu]	; _d_sdivzstepu*scm1 | _d_zistepu*scm1 |
;  _d_tdivzstepu*scm1
 fxch st(1)	; _d_zistepu*scm1 | _d_sdivzstepu*scm1 |
;  _d_tdivzstepu*scm1
 faddp st(3),st(0)	; _d_sdivzstepu*scm1 | _d_tdivzstepu*scm1
 fxch st(1)	; _d_tdivzstepu*scm1 | _d_sdivzstepu*scm1
 faddp st(3),st(0)	; _d_sdivzstepu*scm1
 faddp st(3),st(0)	

 fld ds:dword ptr[fp_64k]	
 fdiv st(0),st(1)	; this is what we've gone to all this trouble to
;  overlap
 jmp LFDIVInFlight1	

LCleanup1:	
; finish up the s and t calcs
 fxch st(1)	; z*64k | 1/z | t/z | s/z

 fld st(0)	; z*64k | z*64k | 1/z | t/z | s/z
 fmul st(0),st(4)	; s | z*64k | 1/z | t/z | s/z
 fxch st(1)	; z*64k | s | 1/z | t/z | s/z
 fmul st(0),st(3)	; t | s | 1/z | t/z | s/z
 fxch st(1)	; s | t | 1/z | t/z | s/z
 fistp ds:dword ptr[s]	; 1/z | t | t/z | s/z
 fistp ds:dword ptr[t]	; 1/z | t/z | s/z
 jmp LFDIVInFlight1	

 align 4	
LSetupNotLast1:	
; finish up the s and t calcs
 fxch st(1)	; z*64k | 1/z | t/z | s/z

 fld st(0)	; z*64k | z*64k | 1/z | t/z | s/z
 fmul st(0),st(4)	; s | z*64k | 1/z | t/z | s/z
 fxch st(1)	; z*64k | s | 1/z | t/z | s/z
 fmul st(0),st(3)	; t | s | 1/z | t/z | s/z
 fxch st(1)	; s | t | 1/z | t/z | s/z
 fistp ds:dword ptr[s]	; 1/z | t | t/z | s/z
 fistp ds:dword ptr[t]	; 1/z | t/z | s/z

 fadd ds:dword ptr[zi8stepu]	
 fxch st(2)	
 fadd ds:dword ptr[sdivz8stepu]	
 fxch st(2)	
 fld ds:dword ptr[tdivz8stepu]	
 faddp st(2),st(0)	
 fld ds:dword ptr[fp_64k]	
 fdiv st(0),st(1)	; z = 1/1/z
; this is what we've gone to all this trouble to
;  overlap
LFDIVInFlight1:	

 add esi,ds:dword ptr[s]	
 add edx,ds:dword ptr[t]	
 mov ebx,ds:dword ptr[_bbextents]	
 mov ebp,ds:dword ptr[_bbextentt]	
 cmp esi,ebx	
 ja LClampHighOrLow0	
LClampReentry0:	
 mov ds:dword ptr[s],esi	
 mov ebx,ds:dword ptr[pbase]	
 shl esi,16	
 cmp edx,ebp	
 mov ds:dword ptr[sfracf],esi	
 ja LClampHighOrLow1	
LClampReentry1:	
 mov ds:dword ptr[t],edx	
 mov esi,ds:dword ptr[s]	; sfrac = scans->sfrac;
 shl edx,16	
 mov eax,ds:dword ptr[t]	; tfrac = scans->tfrac;
 sar esi,16	
 mov ds:dword ptr[tfracf],edx	

;
; calculate the texture starting address
;
 sar eax,16	
 add esi,ebx	
 imul eax,ds:dword ptr[_cachewidth]	; (tfrac >> 16) * cachewidth
 add esi,eax	; psource = pbase + (sfrac >> 16) +
;           ((tfrac >> 16) * cachewidth);

;
; determine whether last span or not
;
 cmp ecx,8	
 jna LLastSegment	

;
; not the last segment; do full 8-wide segment
;
LNotLastSegment:	

;
; advance s/z, t/z, and 1/z, and calculate s & t at end of span and steps to
; get there
;

; pick up after the FDIV that was left in flight previously

 fld st(0)	; duplicate it
 fmul st(0),st(4)	; s = s/z * z
 fxch st(1)	
 fmul st(0),st(3)	; t = t/z * z
 fxch st(1)	
 fistp ds:dword ptr[snext]	
 fistp ds:dword ptr[tnext]	
 mov eax,ds:dword ptr[snext]	
 mov edx,ds:dword ptr[tnext]	

 sub ecx,8	; count off this segments' pixels
 mov ebp,ds:dword ptr[_sadjust]	
 push ecx	; remember count of remaining pixels
 mov ecx,ds:dword ptr[_tadjust]	

 add ebp,eax	
 add ecx,edx	

 mov eax,ds:dword ptr[_bbextents]	
 mov edx,ds:dword ptr[_bbextentt]	

 cmp ebp,2048	
 jl LClampLow2	
 cmp ebp,eax	
 ja LClampHigh2	
LClampReentry2:	

 cmp ecx,2048	
 jl LClampLow3	
 cmp ecx,edx	
 ja LClampHigh3	
LClampReentry3:	

 mov ds:dword ptr[snext],ebp	
 mov ds:dword ptr[tnext],ecx	

 sub ebp,ds:dword ptr[s]	
 sub ecx,ds:dword ptr[t]	

;
; set up advancetable
;
 mov eax,ecx	
 mov edx,ebp	
 sar edx,19	; sstep >>= 16;
 mov ebx,ds:dword ptr[_cachewidth]	
 sar eax,19	; tstep >>= 16;
 jz LIsZero	
 imul eax,ebx	; (tstep >> 16) * cachewidth;
LIsZero:	
 add eax,edx	; add in sstep
; (tstep >> 16) * cachewidth + (sstep >> 16);
 mov edx,ds:dword ptr[tfracf]	
 mov ds:dword ptr[advancetable+4],eax	; advance base in t
 add eax,ebx	; ((tstep >> 16) + 1) * cachewidth +
;  (sstep >> 16);
 shl ebp,13	; left-justify sstep fractional part
 mov ds:dword ptr[sstep],ebp	
 mov ebx,ds:dword ptr[sfracf]	
 shl ecx,13	; left-justify tstep fractional part
 mov ds:dword ptr[advancetable],eax	; advance extra in t
 mov ds:dword ptr[tstep],ecx	

 mov ecx,ds:dword ptr[pz]	
 mov ebp,ds:dword ptr[izi]	

 cmp bp,ds:word ptr[ecx]	
 jl Lp1	
 mov al,ds:byte ptr[esi]	; get first source texel
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp1	
 mov ds:word ptr[ecx],bp	
 mov ds:byte ptr[edi],al	; store first dest pixel
Lp1:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	; advance tfrac fractional part by tstep frac

 sbb eax,eax	; turn tstep carry into -1 (0 if none)
 add ebx,ds:dword ptr[sstep]	; advance sfrac fractional part by sstep frac
 adc esi,ds:dword ptr[advancetable+4+eax*4]	; point to next source texel

 cmp bp,ds:word ptr[2+ecx]	
 jl Lp2	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp2	
 mov ds:word ptr[2+ecx],bp	
 mov ds:byte ptr[1+edi],al	
Lp2:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 cmp bp,ds:word ptr[4+ecx]	
 jl Lp3	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp3	
 mov ds:word ptr[4+ecx],bp	
 mov ds:byte ptr[2+edi],al	
Lp3:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 cmp bp,ds:word ptr[6+ecx]	
 jl Lp4	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp4	
 mov ds:word ptr[6+ecx],bp	
 mov ds:byte ptr[3+edi],al	
Lp4:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 cmp bp,ds:word ptr[8+ecx]	
 jl Lp5	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp5	
 mov ds:word ptr[8+ecx],bp	
 mov ds:byte ptr[4+edi],al	
Lp5:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

;
; start FDIV for end of next segment in flight, so it can overlap
;
 pop eax	
 cmp eax,8	; more than one segment after this?
 ja LSetupNotLast2	; yes

 dec eax	
 jz LFDIVInFlight2	; if only one pixel, no need to start an FDIV
 mov ds:dword ptr[spancountminus1],eax	
 fild ds:dword ptr[spancountminus1]	

 fld ds:dword ptr[_d_zistepu]	; _d_zistepu | spancountminus1
 fmul st(0),st(1)	; _d_zistepu*scm1 | scm1
 fld ds:dword ptr[_d_tdivzstepu]	; _d_tdivzstepu | _d_zistepu*scm1 | scm1
 fmul st(0),st(2)	; _d_tdivzstepu*scm1 | _d_zistepu*scm1 | scm1
 fxch st(1)	; _d_zistepu*scm1 | _d_tdivzstepu*scm1 | scm1
 faddp st(3),st(0)	; _d_tdivzstepu*scm1 | scm1
 fxch st(1)	; scm1 | _d_tdivzstepu*scm1
 fmul ds:dword ptr[_d_sdivzstepu]	; _d_sdivzstepu*scm1 | _d_tdivzstepu*scm1
 fxch st(1)	; _d_tdivzstepu*scm1 | _d_sdivzstepu*scm1
 faddp st(3),st(0)	; _d_sdivzstepu*scm1
 fld ds:dword ptr[fp_64k]	; 64k | _d_sdivzstepu*scm1
 fxch st(1)	; _d_sdivzstepu*scm1 | 64k
 faddp st(4),st(0)	; 64k

 fdiv st(0),st(1)	; this is what we've gone to all this trouble to
;  overlap
 jmp LFDIVInFlight2	

 align 4	
LSetupNotLast2:	
 fadd ds:dword ptr[zi8stepu]	
 fxch st(2)	
 fadd ds:dword ptr[sdivz8stepu]	
 fxch st(2)	
 fld ds:dword ptr[tdivz8stepu]	
 faddp st(2),st(0)	
 fld ds:dword ptr[fp_64k]	
 fdiv st(0),st(1)	; z = 1/1/z
; this is what we've gone to all this trouble to
;  overlap
LFDIVInFlight2:	
 push eax	

 cmp bp,ds:word ptr[10+ecx]	
 jl Lp6	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp6	
 mov ds:word ptr[10+ecx],bp	
 mov ds:byte ptr[5+edi],al	
Lp6:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 cmp bp,ds:word ptr[12+ecx]	
 jl Lp7	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp7	
 mov ds:word ptr[12+ecx],bp	
 mov ds:byte ptr[6+edi],al	
Lp7:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 cmp bp,ds:word ptr[14+ecx]	
 jl Lp8	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp8	
 mov ds:word ptr[14+ecx],bp	
 mov ds:byte ptr[7+edi],al	
Lp8:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 add edi,8	
 add ecx,16	
 mov ds:dword ptr[tfracf],edx	
 mov edx,ds:dword ptr[snext]	
 mov ds:dword ptr[sfracf],ebx	
 mov ebx,ds:dword ptr[tnext]	
 mov ds:dword ptr[s],edx	
 mov ds:dword ptr[t],ebx	

 mov ds:dword ptr[pz],ecx	
 mov ds:dword ptr[izi],ebp	

 pop ecx	; retrieve count

;
; determine whether last span or not
;
 cmp ecx,8	; are there multiple segments remaining?
 ja LNotLastSegment	; yes

;
; last segment of scan
;
LLastSegment:	

;
; advance s/z, t/z, and 1/z, and calculate s & t at end of span and steps to
; get there. The number of pixels left is variable, and we want to land on the
; last pixel, not step one past it, so we can't run into arithmetic problems
;
 test ecx,ecx	
 jz LNoSteps	; just draw the last pixel and we're done

; pick up after the FDIV that was left in flight previously


 fld st(0)	; duplicate it
 fmul st(0),st(4)	; s = s/z * z
 fxch st(1)	
 fmul st(0),st(3)	; t = t/z * z
 fxch st(1)	
 fistp ds:dword ptr[snext]	
 fistp ds:dword ptr[tnext]	

 mov ebx,ds:dword ptr[_tadjust]	
 mov eax,ds:dword ptr[_sadjust]	

 add eax,ds:dword ptr[snext]	
 add ebx,ds:dword ptr[tnext]	

 mov ebp,ds:dword ptr[_bbextents]	
 mov edx,ds:dword ptr[_bbextentt]	

 cmp eax,2048	
 jl LClampLow4	
 cmp eax,ebp	
 ja LClampHigh4	
LClampReentry4:	
 mov ds:dword ptr[snext],eax	

 cmp ebx,2048	
 jl LClampLow5	
 cmp ebx,edx	
 ja LClampHigh5	
LClampReentry5:	

 cmp ecx,1	; don't bother 
 je LOnlyOneStep	; if two pixels in segment, there's only one step,
;  of the segment length
 sub eax,ds:dword ptr[s]	
 sub ebx,ds:dword ptr[t]	

 add eax,eax	; convert to 15.17 format so multiply by 1.31
 add ebx,ebx	;  reciprocal yields 16.48
 imul ds:dword ptr[reciprocal_table-8+ecx*4]	; sstep = (snext - s) / (spancount-1)
 mov ebp,edx	

 mov eax,ebx	
 imul ds:dword ptr[reciprocal_table-8+ecx*4]	; tstep = (tnext - t) / (spancount-1)

LSetEntryvec:	
;
; set up advancetable
;
 mov ebx,ds:dword ptr[spr8entryvec_table+ecx*4]	
 mov eax,edx	
 push ebx	; entry point into code for RET later
 mov ecx,ebp	
 sar ecx,16	; sstep >>= 16;
 mov ebx,ds:dword ptr[_cachewidth]	
 sar edx,16	; tstep >>= 16;
 jz LIsZeroLast	
 imul edx,ebx	; (tstep >> 16) * cachewidth;
LIsZeroLast:	
 add edx,ecx	; add in sstep
; (tstep >> 16) * cachewidth + (sstep >> 16);
 mov ecx,ds:dword ptr[tfracf]	
 mov ds:dword ptr[advancetable+4],edx	; advance base in t
 add edx,ebx	; ((tstep >> 16) + 1) * cachewidth +
;  (sstep >> 16);
 shl ebp,16	; left-justify sstep fractional part
 mov ebx,ds:dword ptr[sfracf]	
 shl eax,16	; left-justify tstep fractional part
 mov ds:dword ptr[advancetable],edx	; advance extra in t

 mov ds:dword ptr[tstep],eax	
 mov ds:dword ptr[sstep],ebp	
 mov edx,ecx	

 mov ecx,ds:dword ptr[pz]	
 mov ebp,ds:dword ptr[izi]	

 ret	; jump to the number-of-pixels handler

;----------------------------------------

LNoSteps:	
 mov ecx,ds:dword ptr[pz]	
 sub edi,7	; adjust for hardwired offset
 sub ecx,14	
 jmp LEndSpan	


LOnlyOneStep:	
 sub eax,ds:dword ptr[s]	
 sub ebx,ds:dword ptr[t]	
 mov ebp,eax	
 mov edx,ebx	
 jmp LSetEntryvec	

;----------------------------------------

 public Spr8Entry2_8	
Spr8Entry2_8:	
 sub edi,6	; adjust for hardwired offsets
 sub ecx,12	
 mov al,ds:byte ptr[esi]	
 jmp LLEntry2_8	

;----------------------------------------

 public Spr8Entry3_8	
Spr8Entry3_8:	
 sub edi,5	; adjust for hardwired offsets
 sub ecx,10	
 jmp LLEntry3_8	

;----------------------------------------

 public Spr8Entry4_8	
Spr8Entry4_8:	
 sub edi,4	; adjust for hardwired offsets
 sub ecx,8	
 jmp LLEntry4_8	

;----------------------------------------

 public Spr8Entry5_8	
Spr8Entry5_8:	
 sub edi,3	; adjust for hardwired offsets
 sub ecx,6	
 jmp LLEntry5_8	

;----------------------------------------

 public Spr8Entry6_8	
Spr8Entry6_8:	
 sub edi,2	; adjust for hardwired offsets
 sub ecx,4	
 jmp LLEntry6_8	

;----------------------------------------

 public Spr8Entry7_8	
Spr8Entry7_8:	
 dec edi	; adjust for hardwired offsets
 sub ecx,2	
 jmp LLEntry7_8	

;----------------------------------------

 public Spr8Entry8_8	
Spr8Entry8_8:	
 cmp bp,ds:word ptr[ecx]	
 jl Lp9	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp9	
 mov ds:word ptr[ecx],bp	
 mov ds:byte ptr[edi],al	
Lp9:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry7_8:	
 cmp bp,ds:word ptr[2+ecx]	
 jl Lp10	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp10	
 mov ds:word ptr[2+ecx],bp	
 mov ds:byte ptr[1+edi],al	
Lp10:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry6_8:	
 cmp bp,ds:word ptr[4+ecx]	
 jl Lp11	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp11	
 mov ds:word ptr[4+ecx],bp	
 mov ds:byte ptr[2+edi],al	
Lp11:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry5_8:	
 cmp bp,ds:word ptr[6+ecx]	
 jl Lp12	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp12	
 mov ds:word ptr[6+ecx],bp	
 mov ds:byte ptr[3+edi],al	
Lp12:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry4_8:	
 cmp bp,ds:word ptr[8+ecx]	
 jl Lp13	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp13	
 mov ds:word ptr[8+ecx],bp	
 mov ds:byte ptr[4+edi],al	
Lp13:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry3_8:	
 cmp bp,ds:word ptr[10+ecx]	
 jl Lp14	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp14	
 mov ds:word ptr[10+ecx],bp	
 mov ds:byte ptr[5+edi],al	
Lp14:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	
LLEntry2_8:	
 cmp bp,ds:word ptr[12+ecx]	
 jl Lp15	
 mov al,ds:byte ptr[esi]	
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp15	
 mov ds:word ptr[12+ecx],bp	
 mov ds:byte ptr[6+edi],al	
Lp15:	
 add ebp,ds:dword ptr[izistep]	
 adc ebp,0	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebx,ds:dword ptr[sstep]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LEndSpan:	
 cmp bp,ds:word ptr[14+ecx]	
 jl Lp16	
 mov al,ds:byte ptr[esi]	; load first texel in segment
 cmp al,offset TRANSPARENT_COLOR	
 jz Lp16	
 mov ds:word ptr[14+ecx],bp	
 mov ds:byte ptr[7+edi],al	
Lp16:	

;
; clear s/z, t/z, 1/z from FP stack
;
 fstp st(0)	
 fstp st(0)	
 fstp st(0)	

 pop ebx	; restore spans pointer
LNextSpan:	
 add ebx,offset sspan_t_size	; point to next span
 mov ecx,ds:dword ptr[sspan_t_count+ebx]	
 cmp ecx,0	; any more spans?
 jg LSpanLoop	; yes
 jz LNextSpan	; yes, but this one's empty

 pop ebx	; restore register variables
 pop esi	
 pop edi	
 pop ebp	; restore the caller's stack frame
 ret	

_TEXT ENDS
endif	; id386
 END
