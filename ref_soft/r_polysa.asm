 .386P
 .model FLAT
;
; d_polysa.s
; x86 assembly-language polygon model drawing code
;

include qasm.inc
include d_if.inc

if	id386

; !!! if this is changed, it must be changed in d_polyse.c too !!!
;DPS_MAXSPANS			equ		(MAXHEIGHT+1)
; 1 extra for spanpackage that marks end

;SPAN_SIZE	equ		(((DPS_MAXSPANS + 1 + ((CACHE_SIZE - 1) / spanpackage_t_size)) + 1) * spanpackage_t_size)

MASK_1K	equ		03FFh

_DATA SEGMENT	

 align 4	
;p10_minus_p20 dd 0
;p01_minus_p21 dd 0
;temp0 dd 0
;temp1 dd 0
;Ltemp dd 0

aff8entryvec_table dd LDraw8, LDraw7, LDraw6, LDraw5
 dd LDraw4, LDraw3, LDraw2, LDraw1, LDraw8IR, LDraw7IR, LDraw6IR, LDraw5IR, LDraw4IR, LDraw3IR, LDraw2IR, LDraw1IR

lzistepx dd 0	

 externdef _rand1k:dword	
 externdef _rand1k_index:dword	
 externdef _alias_colormap:dword

;PGM
 externdef _irtable:dword
 externdef _iractive:byte
;PGM

_DATA ENDS
_TEXT SEGMENT	


;----------------------------------------------------------------------
; 8-bpp horizontal span drawing code for affine polygons, with smooth
; shading and no transparency
;----------------------------------------------------------------------

;===================================
;===================================

pspans	equ		4+8

 public _D_PolysetAff8Start	
_D_PolysetAff8Start:	

 public _R_PolysetDrawSpans8_Opaque 
_R_PolysetDrawSpans8_Opaque:

 push esi	; preserve register variables
 push ebx	

 mov esi,ds:dword ptr[pspans+esp]	; point to the first span descriptor
 mov ecx,ds:dword ptr[_r_zistepx]	

 push ebp	; preserve caller's stack frame
 push edi	

 ror ecx,16	; put high 16 bits of 1/z step in low word
 mov edx,ds:dword ptr[spanpackage_t_count+esi]	

 mov ds:dword ptr[lzistepx],ecx	

LSpanLoop:	

;		lcount = d_aspancount - pspanpackage->count;
;
;		errorterm += erroradjustup;
;		if (errorterm >= 0)
;		{
;			d_aspancount += d_countextrastep;
;			errorterm -= erroradjustdown;
;		}
;		else
;		{
;			d_aspancount += ubasestep;
;		}

 mov eax,ds:dword ptr[_d_aspancount]
 sub eax,edx

 mov edx,ds:dword ptr[_erroradjustup]	
 mov ebx,ds:dword ptr[_errorterm]	
 add ebx,edx	
 js LNoTurnover	

 mov edx,ds:dword ptr[_erroradjustdown]	
 mov edi,ds:dword ptr[_d_countextrastep]	
 sub ebx,edx	
 mov ebp,ds:dword ptr[_d_aspancount]	
 mov ds:dword ptr[_errorterm],ebx	
 add ebp,edi	
 mov ds:dword ptr[_d_aspancount],ebp	
 jmp LRightEdgeStepped	

LNoTurnover:	
 mov edi,ds:dword ptr[_d_aspancount]	
 mov edx,ds:dword ptr[_ubasestep]	
 mov ds:dword ptr[_errorterm],ebx	
 add edi,edx	
 mov ds:dword ptr[_d_aspancount],edi	

LRightEdgeStepped:	
 cmp eax,1	

 jl LNextSpan	
 jz LExactlyOneLong	

;
; set up advancetable
;
 mov ecx,ds:dword ptr[_a_ststepxwhole]	
 mov edx,ds:dword ptr[_r_affinetridesc+atd_skinwidth]	

 mov ds:dword ptr[advancetable+4],ecx	; advance base in t
 add ecx,edx	

 mov ds:dword ptr[advancetable],ecx	; advance extra in t
 mov ecx,ds:dword ptr[_a_tstepxfrac]	

 mov cx,ds:word ptr[_r_lstepx]	
 mov edx,eax	; count

 mov ds:dword ptr[tstep],ecx
 add edx,7	

 shr edx,3	; count of full and partial loops
 mov ebx,ds:dword ptr[spanpackage_t_sfrac+esi]	

 mov bx,dx	
 mov ecx,ds:dword ptr[spanpackage_t_pz+esi]	

 neg eax	

 mov edi,ds:dword ptr[spanpackage_t_pdest+esi]	
 and eax,7	; 0->0, 1->7, 2->6, ... , 7->1

 sub edi,eax	; compensate for hardwired offsets
 sub ecx,eax	

 sub ecx,eax	
 mov edx,ds:dword ptr[spanpackage_t_tfrac+esi]	

 mov dx,ds:word ptr[spanpackage_t_light+esi]	
 mov ebp,ds:dword ptr[spanpackage_t_zi+esi]	

 ror ebp,16	; put high 16 bits of 1/z in low word
 push esi	

 push eax
 mov al, [_iractive]
 cmp al, 0
 pop eax
 jne IRInsert
 
 mov esi,ds:dword ptr[spanpackage_t_ptex+esi]	
 jmp dword ptr[aff8entryvec_table+eax*4]	

IRInsert:
 mov esi,ds:dword ptr[spanpackage_t_ptex+esi]
 add eax, 8
 jmp dword ptr[aff8entryvec_table+eax*4]	

; %bx = count of full and partial loops
; %ebx high word = sfrac
; %ecx = pz
; %dx = light
; %edx high word = tfrac
; %esi = ptex
; %edi = pdest
; %ebp = 1/z
; tstep low word = C(r_lstepx)
; tstep high word = C(a_tstepxfrac)
; C(a_sstepxfrac) low word = 0
; C(a_sstepxfrac) high word = C(a_sstepxfrac)

;===
;Standard Draw Loop
;===
LDrawLoop:	

 mov al,[_iractive]
 cmp al,0
 jne LDrawLoopIR

; FIXME: do we need to clamp light? We may need at least a buffer bit to
; keep it from poking into tfrac and causing problems

LDraw8:	
 cmp bp,ds:word ptr[ecx]	
 jl Lp1	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch8:	
 mov ds:byte ptr[edi],al	
Lp1:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw7:	
 cmp bp,ds:word ptr[2+ecx]	
 jl Lp2	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[2+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch7:	
 mov ds:byte ptr[1+edi],al	
Lp2:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw6:	
 cmp bp,ds:word ptr[4+ecx]	
 jl Lp3	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[4+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch6:	
 mov ds:byte ptr[2+edi],al	
Lp3:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw5:	
 cmp bp,ds:word ptr[6+ecx]	
 jl Lp4	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[6+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch5:	
 mov ds:byte ptr[3+edi],al	
Lp4:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw4:	
 cmp bp,ds:word ptr[8+ecx]	
 jl Lp5	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[8+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch4:	
 mov ds:byte ptr[4+edi],al	
Lp5:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw3:	
 cmp bp,ds:word ptr[10+ecx]	
 jl Lp6	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[10+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch3:	
 mov ds:byte ptr[5+edi],al	
Lp6:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw2:	
 cmp bp,ds:word ptr[12+ecx]	
 jl Lp7	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[12+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch2:	
 mov ds:byte ptr[6+edi],al	
Lp7:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw1:	
 cmp bp,ds:word ptr[14+ecx]	
 jl Lp8	
 xor eax,eax	
 mov ah,dh	
 mov al,ds:byte ptr[esi]	
 mov ds:word ptr[14+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch1:	
 mov ds:byte ptr[7+edi],al	
Lp8:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 add edi,8	
 add ecx,16	

 dec bx	
 jnz LDrawLoop	

 pop esi	; restore spans pointer
LNextSpan:	
 add esi,offset spanpackage_t_size	; point to next span
LNextSpanESISet:	
 mov edx,ds:dword ptr[spanpackage_t_count+esi]	
 cmp edx,offset -999999	; any more spans?
 jnz LSpanLoop	; yes

 pop edi	
 pop ebp	; restore the caller's stack frame
 pop ebx	; restore register variables
 pop esi	
 ret	

;=======
; IR active draw loop
;=======
LDrawLoopIR:	

; FIXME: do we need to clamp light? We may need at least a buffer bit to
; keep it from poking into tfrac and causing problems

LDraw8IR:	
 cmp bp,ds:word ptr[ecx]	
 jl Lp1IR
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch8IR:	
 mov ds:byte ptr[edi],al	
Lp1IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw7IR:	
 cmp bp,ds:word ptr[2+ecx]	
 jl Lp2IR	
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[2+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch7IR:	
 mov ds:byte ptr[1+edi],al	
Lp2IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw6IR:	
 cmp bp,ds:word ptr[4+ecx]	
 jl Lp3IR	
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[4+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch6IR:	
 mov ds:byte ptr[2+edi],al	
Lp3IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw5IR:	
 cmp bp,ds:word ptr[6+ecx]	
 jl Lp4IR
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[6+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch5IR:	
 mov ds:byte ptr[3+edi],al	
Lp4IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw4IR:	
 cmp bp,ds:word ptr[8+ecx]	
 jl Lp5IR
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[8+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch4IR:	
 mov ds:byte ptr[4+edi],al	
Lp5IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw3IR:	
 cmp bp,ds:word ptr[10+ecx]	
 jl Lp6IR	
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[10+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch3IR:	
 mov ds:byte ptr[5+edi],al	
Lp6IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw2IR:	
 cmp bp,ds:word ptr[12+ecx]	
 jl Lp7IR
 xor eax,eax	
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[12+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch2IR:	
 mov ds:byte ptr[6+edi],al	
Lp7IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

LDraw1IR:	
 cmp bp,ds:word ptr[14+ecx]	
 jl Lp8IR
 xor eax,eax
 mov al,ds:byte ptr[esi]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[14+ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch1IR:	
 mov ds:byte ptr[7+edi],al	
Lp8IR:	
 add edx,ds:dword ptr[tstep]	
 sbb eax,eax	
 add ebp,ds:dword ptr[lzistepx]	
 adc ebp,0	
 add ebx,ds:dword ptr[_a_sstepxfrac]	
 adc esi,ds:dword ptr[advancetable+4+eax*4]	

 add edi,8	
 add ecx,16	

 dec bx	
 jnz LDrawLoopIR	

 pop esi	; restore spans pointer
LNextSpanIR:	
 add esi,offset spanpackage_t_size	; point to next span
LNextSpanESISetIR:	
 mov edx,ds:dword ptr[spanpackage_t_count+esi]	
 cmp edx,offset -999999	; any more spans?
 jnz LSpanLoop	; yes

 pop edi	
 pop ebp	; restore the caller's stack frame
 pop ebx	; restore register variables
 pop esi	
 ret	

;=======
; Standard One-Long Draw
;=======
; draw a one-long span

LExactlyOneLong:	
 mov al,[_iractive]
 cmp al,0
 jne LExactlyOneLongIR

 mov ecx,ds:dword ptr[spanpackage_t_pz+esi]	
 mov ebp,ds:dword ptr[spanpackage_t_zi+esi]	

 ror ebp,16	; put high 16 bits of 1/z in low word
 mov ebx,ds:dword ptr[spanpackage_t_ptex+esi]	

 cmp bp,ds:word ptr[ecx]	
 jl LNextSpan	
 xor eax,eax	
 mov edi,ds:dword ptr[spanpackage_t_pdest+esi]	
 mov ah,ds:byte ptr[spanpackage_t_light+1+esi]	
 add esi,offset spanpackage_t_size	; point to next span
 mov al,ds:byte ptr[ebx]	
 mov ds:word ptr[ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch9:	
 mov ds:byte ptr[edi],al	

 jmp LNextSpanESISet	


;========
;========
; draw a one-long span

LExactlyOneLongIR:	

 mov ecx,ds:dword ptr[spanpackage_t_pz+esi]	
 mov ebp,ds:dword ptr[spanpackage_t_zi+esi]	

 ror ebp,16	; put high 16 bits of 1/z in low word
 mov ebx,ds:dword ptr[spanpackage_t_ptex+esi]	

 cmp bp,ds:word ptr[ecx]	
 jl LNextSpanIR
 xor eax,eax	
 mov edi,ds:dword ptr[spanpackage_t_pdest+esi]	
 add esi,offset spanpackage_t_size	; point to next span
 mov al,ds:byte ptr[ebx]	
 mov al,ds:byte ptr[_irtable+eax]
 mov ds:word ptr[ecx],bp	
 mov al,ds:byte ptr[12345678h+eax]	
LPatch9IR:	
 mov ds:byte ptr[edi],al	

 jmp LNextSpanESISetIR

;===================================
;===================================
 public _D_Aff8Patch	
_D_Aff8Patch:	
 mov eax,[_alias_colormap]
 mov ds:dword ptr[LPatch1-4],eax	
 mov ds:dword ptr[LPatch2-4],eax	
 mov ds:dword ptr[LPatch3-4],eax	
 mov ds:dword ptr[LPatch4-4],eax	
 mov ds:dword ptr[LPatch5-4],eax	
 mov ds:dword ptr[LPatch6-4],eax	
 mov ds:dword ptr[LPatch7-4],eax	
 mov ds:dword ptr[LPatch8-4],eax	
 mov ds:dword ptr[LPatch9-4],eax	
 mov ds:dword ptr[LPatch1IR-4],eax	
 mov ds:dword ptr[LPatch2IR-4],eax	
 mov ds:dword ptr[LPatch3IR-4],eax	
 mov ds:dword ptr[LPatch4IR-4],eax	
 mov ds:dword ptr[LPatch5IR-4],eax	
 mov ds:dword ptr[LPatch6IR-4],eax	
 mov ds:dword ptr[LPatch7IR-4],eax	
 mov ds:dword ptr[LPatch8IR-4],eax	
 mov ds:dword ptr[LPatch9IR-4],eax	

 ret	



;===================================
;===================================

height	equ		4+16

 public _R_PolysetScanLeftEdge	
_R_PolysetScanLeftEdge:	
 push ebp	; preserve caller stack frame pointer
 push esi	; preserve register variables
 push edi	
 push ebx	

 mov eax,ds:dword ptr[height+esp]	
 mov ecx,ds:dword ptr[_d_sfrac]

 and eax,0FFFFh	
 mov ebx,ds:dword ptr[_d_ptex]	
 or ecx,eax	
 mov esi,ds:dword ptr[_d_pedgespanpackage]	
 mov edx,ds:dword ptr[_d_tfrac]	
 mov edi,ds:dword ptr[_d_light]	
 mov ebp,ds:dword ptr[_d_zi]	

; %eax: scratch
; %ebx: d_ptex
; %ecx: d_sfrac in high word, count in low word
; %edx: d_tfrac
; %esi: d_pedgespanpackage, errorterm, scratch alternately
; %edi: d_light
; %ebp: d_zi

;	do
;	{

LScanLoop:	

;		d_pedgespanpackage->ptex = ptex;
;		d_pedgespanpackage->pdest = d_pdest;
;		d_pedgespanpackage->pz = d_pz;
;		d_pedgespanpackage->count = d_aspancount;
;		d_pedgespanpackage->light = d_light;
;		d_pedgespanpackage->zi = d_zi;
;		d_pedgespanpackage->sfrac = d_sfrac << 16;
;		d_pedgespanpackage->tfrac = d_tfrac << 16;
 mov ds:dword ptr[spanpackage_t_ptex+esi],ebx	
 mov eax,ds:dword ptr[_d_pdest]	
 mov ds:dword ptr[spanpackage_t_pdest+esi],eax	
 mov eax,ds:dword ptr[_d_pz]	
 mov ds:dword ptr[spanpackage_t_pz+esi],eax	
 mov eax,ds:dword ptr[_d_aspancount]	
 mov ds:dword ptr[spanpackage_t_count+esi],eax	
 mov ds:dword ptr[spanpackage_t_light+esi],edi	
 mov ds:dword ptr[spanpackage_t_zi+esi],ebp	
 mov ds:dword ptr[spanpackage_t_sfrac+esi],ecx	
 mov ds:dword ptr[spanpackage_t_tfrac+esi],edx	

; pretouch the next cache line
 mov al,ds:byte ptr[spanpackage_t_size+esi]	

;		d_pedgespanpackage++;
 add esi,offset spanpackage_t_size	
 mov eax,ds:dword ptr[_erroradjustup]	
 mov ds:dword ptr[_d_pedgespanpackage],esi	

;		errorterm += erroradjustup;
 mov esi,ds:dword ptr[_errorterm]	
 add esi,eax	
 mov eax,ds:dword ptr[_d_pdest]	

;		if (errorterm >= 0)
;		{
 js LNoLeftEdgeTurnover	

;			errorterm -= erroradjustdown;
;			d_pdest += d_pdestextrastep;
 sub esi,ds:dword ptr[_erroradjustdown]	
 add eax,ds:dword ptr[_d_pdestextrastep]	
 mov ds:dword ptr[_errorterm],esi	
 mov ds:dword ptr[_d_pdest],eax	

;			d_pz += d_pzextrastep;
;			d_aspancount += d_countextrastep;
;			d_ptex += d_ptexextrastep;
;			d_sfrac += d_sfracextrastep;
;			d_ptex += d_sfrac >> 16;
;			d_sfrac &= 0xFFFF;
;			d_tfrac += d_tfracextrastep;
 mov eax,ds:dword ptr[_d_pz]	
 mov esi,ds:dword ptr[_d_aspancount]	
 add eax,ds:dword ptr[_d_pzextrastep]	
 add ecx,ds:dword ptr[_d_sfracextrastep]	
 adc ebx,ds:dword ptr[_d_ptexextrastep]	
 add esi,ds:dword ptr[_d_countextrastep]	
 mov ds:dword ptr[_d_pz],eax	
 mov eax,ds:dword ptr[_d_tfracextrastep]	
 mov ds:dword ptr[_d_aspancount],esi	
 add edx,eax	

;			if (d_tfrac & 0x10000)
;			{
 jnc LSkip1	

;				d_ptex += r_affinetridesc.skinwidth;
;				d_tfrac &= 0xFFFF;
 add ebx,ds:dword ptr[_r_affinetridesc+atd_skinwidth]	

;			}

LSkip1:	

;			d_light += d_lightextrastep;
;			d_zi += d_ziextrastep;
 add edi,ds:dword ptr[_d_lightextrastep]	
 add ebp,ds:dword ptr[_d_ziextrastep]	

;		}
 mov esi,ds:dword ptr[_d_pedgespanpackage]	
 dec ecx	
 test ecx,0FFFFh	
 jnz LScanLoop	

 pop ebx	
 pop edi	
 pop esi	
 pop ebp	
 ret	

;		else
;		{

LNoLeftEdgeTurnover:	
 mov ds:dword ptr[_errorterm],esi	

;			d_pdest += d_pdestbasestep;
 add eax,ds:dword ptr[_d_pdestbasestep]	
 mov ds:dword ptr[_d_pdest],eax	

;			d_pz += d_pzbasestep;
;			d_aspancount += ubasestep;
;			d_ptex += d_ptexbasestep;
;			d_sfrac += d_sfracbasestep;
;			d_ptex += d_sfrac >> 16;
;			d_sfrac &= 0xFFFF;
 mov eax,ds:dword ptr[_d_pz]	
 mov esi,ds:dword ptr[_d_aspancount]	
 add eax,ds:dword ptr[_d_pzbasestep]	
 add ecx,ds:dword ptr[_d_sfracbasestep]	
 adc ebx,ds:dword ptr[_d_ptexbasestep]	
 add esi,ds:dword ptr[_ubasestep]	
 mov ds:dword ptr[_d_pz],eax	
 mov ds:dword ptr[_d_aspancount],esi	

;			d_tfrac += d_tfracbasestep;
 mov esi,ds:dword ptr[_d_tfracbasestep]	
 add edx,esi	

;			if (d_tfrac & 0x10000)
;			{
 jnc LSkip2	

;				d_ptex += r_affinetridesc.skinwidth;
;				d_tfrac &= 0xFFFF;
 add ebx,ds:dword ptr[_r_affinetridesc+atd_skinwidth]	

;			}

LSkip2:	

;			d_light += d_lightbasestep;
;			d_zi += d_zibasestep;
 add edi,ds:dword ptr[_d_lightbasestep]	
 add ebp,ds:dword ptr[_d_zibasestep]	

;		}
;	} while (--height);
 mov esi,ds:dword ptr[_d_pedgespanpackage]	
 dec ecx	
 test ecx,0FFFFh	
 jnz LScanLoop	

 pop ebx	
 pop edi	
 pop esi	
 pop ebp	
 ret	

_TEXT ENDS
endif	;id386
 END
