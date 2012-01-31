 .386P
 .model FLAT
;
; r_aliasa.s
; x86 assembly-language Alias model transform and project code.
;

include qasm.inc
include d_if.inc

if id386

_DATA SEGMENT	
Ltemp0 dd 0	
Ltemp1 dd 0	

_DATA ENDS
_TEXT SEGMENT	

pfv0		equ		8+4
pfv1		equ		8+8
outparm			equ		8+12

 public _R_Alias_clip_bottom	
_R_Alias_clip_bottom:	
 push esi	
 push edi	

 mov esi,ds:dword ptr[pfv0+esp]	
 mov edi,ds:dword ptr[pfv1+esp]	

 mov eax,ds:dword ptr[_r_refdef+rd_aliasvrectbottom]	

LDoForwardOrBackward:	

 mov edx,ds:dword ptr[fv_v+4+esi]	
 mov ecx,ds:dword ptr[fv_v+4+edi]	

 cmp edx,ecx	
 jl LDoForward	

 mov ecx,ds:dword ptr[fv_v+4+esi]	
 mov edx,ds:dword ptr[fv_v+4+edi]	
 mov edi,ds:dword ptr[pfv0+esp]	
 mov esi,ds:dword ptr[pfv1+esp]	

LDoForward:	

 sub ecx,edx	
 sub eax,edx	
 mov ds:dword ptr[Ltemp1],ecx	
 mov ds:dword ptr[Ltemp0],eax	
 fild ds:dword ptr[Ltemp1]	
 fild ds:dword ptr[Ltemp0]	
 mov edx,ds:dword ptr[outparm+esp]	
 mov eax,2	

 fdivrp st(1),st(0)	; scale

LDo3Forward:	
 fild ds:dword ptr[fv_v+0+esi]	; fv0v0 | scale
 fild ds:dword ptr[fv_v+0+edi]	; fv1v0 | fv0v0 | scale
 fild ds:dword ptr[fv_v+4+esi]	; fv0v1 | fv1v0 | fv0v0 | scale
 fild ds:dword ptr[fv_v+4+edi]	; fv1v1 | fv0v1 | fv1v0 | fv0v0 | scale
 fild ds:dword ptr[fv_v+8+esi]	; fv0v2 | fv1v1 | fv0v1 | fv1v0 | fv0v0 | scale
 fild ds:dword ptr[fv_v+8+edi]	; fv1v2 | fv0v2 | fv1v1 | fv0v1 | fv1v0 | fv0v0 |
;  scale
 fxch st(5)	; fv0v0 | fv0v2 | fv1v1 | fv0v1 | fv1v0 | fv1v2 |
;  scale
 fsub st(4),st(0)	; fv0v0 | fv0v2 | fv1v1 | fv0v1 | fv1v0-fv0v0 |
;  fv1v2 | scale
 fxch st(3)	; fv0v1 | fv0v2 | fv1v1 | fv0v0 | fv1v0-fv0v0 |
;  fv1v2 | scale
 fsub st(2),st(0)	; fv0v1 | fv0v2 | fv1v1-fv0v1 | fv0v0 |
;  fv1v0-fv0v0 | fv1v2 | scale
 fxch st(1)	; fv0v2 | fv0v1 | fv1v1-fv0v1 | fv0v0 |
;  fv1v0-fv0v0 | fv1v2 | scale
 fsub st(5),st(0)	; fv0v2 | fv0v1 | fv1v1-fv0v1 | fv0v0 |
;  fv1v0-fv0v0 | fv1v2-fv0v2 | scale
 fxch st(6)	; scale | fv0v1 | fv1v1-fv0v1 | fv0v0 |
;  fv1v0-fv0v0 | fv1v2-fv0v2 | fv0v2
 fmul st(4),st(0)	; scale | fv0v1 | fv1v1-fv0v1 | fv0v0 |
;  (fv1v0-fv0v0)*scale | fv1v2-fv0v2 | fv0v2
 add edi,12	
 fmul st(2),st(0)	; scale | fv0v1 | (fv1v1-fv0v1)*scale | fv0v0 |
;  (fv1v0-fv0v0)*scale | fv1v2-fv0v2 | fv0v2
 add esi,12	
 add edx,12	
 fmul st(5),st(0)	; scale | fv0v1 | (fv1v1-fv0v1)*scale | fv0v0 |
;  (fv1v0-fv0v0)*scale | (fv1v2-fv0v2)*scale |
;  fv0v2
 fxch st(3)	; fv0v0 | fv0v1 | (fv1v1-fv0v1)*scale | scale |
;  (fv1v0-fv0v0)*scale | (fv1v2-fv0v2)*scale |
;  fv0v2
 faddp st(4),st(0)	; fv0v1 | (fv1v1-fv0v1)*scale | scale |
;  fv0v0+(fv1v0-fv0v0)*scale |
;  (fv1v2-fv0v2)*scale | fv0v2
 faddp st(1),st(0)	; fv0v1+(fv1v1-fv0v1)*scale | scale |
;  fv0v0+(fv1v0-fv0v0)*scale |
;  (fv1v2-fv0v2)*scale | fv0v2
 fxch st(4)	; fv0v2 | scale | fv0v0+(fv1v0-fv0v0)*scale |
;  (fv1v2-fv0v2)*scale | fv0v1+(fv1v1-fv0v1)*scale
 faddp st(3),st(0)	; scale | fv0v0+(fv1v0-fv0v0)*scale |
;  fv0v2+(fv1v2-fv0v2)*scale |
;  fv0v1+(fv1v1-fv0v1)*scale
 fxch st(1)	; fv0v0+(fv1v0-fv0v0)*scale | scale | 
;  fv0v2+(fv1v2-fv0v2)*scale |
;  fv0v1+(fv1v1-fv0v1)*scale
 fadd ds:dword ptr[float_point5]	
 fxch st(3)	; fv0v1+(fv1v1-fv0v1)*scale | scale | 
;  fv0v2+(fv1v2-fv0v2)*scale |
;  fv0v0+(fv1v0-fv0v0)*scale
 fadd ds:dword ptr[float_point5]	
 fxch st(2)	; fv0v2+(fv1v2-fv0v2)*scale | scale | 
;  fv0v1+(fv1v1-fv0v1)*scale |
;  fv0v0+(fv1v0-fv0v0)*scale
 fadd ds:dword ptr[float_point5]	
 fxch st(3)	; fv0v0+(fv1v0-fv0v0)*scale | scale | 
;  fv0v1+(fv1v1-fv0v1)*scale |
;  fv0v2+(fv1v2-fv0v2)*scale
 fistp ds:dword ptr[fv_v+0-12+edx]	; scale | fv0v1+(fv1v1-fv0v1)*scale |
;  fv0v2+(fv1v2-fv0v2)*scale
 fxch st(1)	; fv0v1+(fv1v1-fv0v1)*scale | scale |
;  fv0v2+(fv1v2-fv0v2)*scale | scale
 fistp ds:dword ptr[fv_v+4-12+edx]	; scale | fv0v2+(fv1v2-fv0v2)*scale
 fxch st(1)	; fv0v2+(fv1v2-fv0v2)*sc | scale
 fistp ds:dword ptr[fv_v+8-12+edx]	; scale

 dec eax	
 jnz LDo3Forward	

 fstp st(0)	

 pop edi	
 pop esi	

 ret	


 public _R_Alias_clip_top	
_R_Alias_clip_top:	
 push esi	
 push edi	

 mov esi,ds:dword ptr[pfv0+esp]	
 mov edi,ds:dword ptr[pfv1+esp]	

 mov eax,ds:dword ptr[_r_refdef+rd_aliasvrect+4]	
 jmp LDoForwardOrBackward	



 public _R_Alias_clip_right	
_R_Alias_clip_right:	
 push esi	
 push edi	

 mov esi,ds:dword ptr[pfv0+esp]	
 mov edi,ds:dword ptr[pfv1+esp]	

 mov eax,ds:dword ptr[_r_refdef+rd_aliasvrectright]	

LRightLeftEntry:	


 mov edx,ds:dword ptr[fv_v+4+esi]	
 mov ecx,ds:dword ptr[fv_v+4+edi]	

 cmp edx,ecx	
 mov edx,ds:dword ptr[fv_v+0+esi]	

 mov ecx,ds:dword ptr[fv_v+0+edi]	
 jl LDoForward2	

 mov ecx,ds:dword ptr[fv_v+0+esi]	
 mov edx,ds:dword ptr[fv_v+0+edi]	
 mov edi,ds:dword ptr[pfv0+esp]	
 mov esi,ds:dword ptr[pfv1+esp]	

LDoForward2:	

 jmp LDoForward	


 public _R_Alias_clip_left	
_R_Alias_clip_left:	
 push esi	
 push edi	

 mov esi,ds:dword ptr[pfv0+esp]	
 mov edi,ds:dword ptr[pfv1+esp]	

 mov eax,ds:dword ptr[_r_refdef+rd_aliasvrect+0]	
 jmp LRightLeftEntry	



_TEXT ENDS
endif	;id386
 END
