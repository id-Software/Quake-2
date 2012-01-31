 .386P
 .model FLAT
;
; d_scana.s
; x86 assembly-language turbulent texture mapping code
;

include qasm.inc
include d_if.inc

if id386

_DATA SEGMENT	

_DATA ENDS
_TEXT SEGMENT	

;----------------------------------------------------------------------
; turbulent texture mapping code
;----------------------------------------------------------------------

 align 4	
 public _D_DrawTurbulent8Span	
_D_DrawTurbulent8Span:	
 push ebp	; preserve caller's stack frame pointer
 push esi	; preserve register variables
 push edi	
 push ebx	

 mov esi,ds:dword ptr[_r_turb_s]	
 mov ecx,ds:dword ptr[_r_turb_t]	
 mov edi,ds:dword ptr[_r_turb_pdest]	
 mov ebx,ds:dword ptr[_r_turb_spancount]	

Llp:	
 mov eax,ecx	
 mov edx,esi	
 sar eax,16	
 mov ebp,ds:dword ptr[_r_turb_turb]	
 sar edx,16	
 and eax,offset CYCLE-1	
 and edx,offset CYCLE-1	
 mov eax,ds:dword ptr[ebp+eax*4]	
 mov edx,ds:dword ptr[ebp+edx*4]	
 add eax,esi	
 sar eax,16	
 add edx,ecx	
 sar edx,16	
 and eax,offset TURB_TEX_SIZE-1	
 and edx,offset TURB_TEX_SIZE-1	
 shl edx,6	
 mov ebp,ds:dword ptr[_r_turb_pbase]	
 add edx,eax	
 inc edi	
 add esi,ds:dword ptr[_r_turb_sstep]	
 add ecx,ds:dword ptr[_r_turb_tstep]	
 mov dl,ds:byte ptr[ebp+edx*1]	
 dec ebx	
 mov ds:byte ptr[-1+edi],dl	
 jnz Llp	

 mov ds:dword ptr[_r_turb_pdest],edi	

 pop ebx	; restore register variables
 pop edi	
 pop esi	
 pop ebp	; restore caller's stack frame pointer
 ret	


_TEXT ENDS
endif	;id386
 END
