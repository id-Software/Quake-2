 .386P
 .model FLAT
;
; r_edgea.s
; x86 assembly-language edge-processing code.
;

include qasm.inc

if	id386

_DATA SEGMENT	
Ltemp dd 0	
float_1_div_0100000h dd 035800000h	; 1.0/(float)0x100000
float_point_999 dd 0.999	
float_1_point_001 dd 1.001	

_DATA ENDS
_TEXT SEGMENT	

;--------------------------------------------------------------------

edgestoadd	equ		4+8		; note odd stack offsets because of interleaving
edgelist	equ		8+12	; with pushes

 public _R_EdgeCodeStart	
_R_EdgeCodeStart:	

 public _R_InsertNewEdges	
_R_InsertNewEdges:	
 push edi	
 push esi	; preserve register variables
 mov edx,ds:dword ptr[edgestoadd+esp]	
 push ebx	
 mov ecx,ds:dword ptr[edgelist+esp]	

LDoNextEdge:	
 mov eax,ds:dword ptr[et_u+edx]	
 mov edi,edx	

LContinueSearch:	
 mov ebx,ds:dword ptr[et_u+ecx]	
 mov esi,ds:dword ptr[et_next+ecx]	
 cmp eax,ebx	
 jle LAddedge	
 mov ebx,ds:dword ptr[et_u+esi]	
 mov ecx,ds:dword ptr[et_next+esi]	
 cmp eax,ebx	
 jle LAddedge2	
 mov ebx,ds:dword ptr[et_u+ecx]	
 mov esi,ds:dword ptr[et_next+ecx]	
 cmp eax,ebx	
 jle LAddedge	
 mov ebx,ds:dword ptr[et_u+esi]	
 mov ecx,ds:dword ptr[et_next+esi]	
 cmp eax,ebx	
 jg LContinueSearch	

LAddedge2:	
 mov edx,ds:dword ptr[et_next+edx]	
 mov ebx,ds:dword ptr[et_prev+esi]	
 mov ds:dword ptr[et_next+edi],esi	
 mov ds:dword ptr[et_prev+edi],ebx	
 mov ds:dword ptr[et_next+ebx],edi	
 mov ds:dword ptr[et_prev+esi],edi	
 mov ecx,esi	

 cmp edx,0	
 jnz LDoNextEdge	
 jmp LDone	

 align 4	
LAddedge:	
 mov edx,ds:dword ptr[et_next+edx]	
 mov ebx,ds:dword ptr[et_prev+ecx]	
 mov ds:dword ptr[et_next+edi],ecx	
 mov ds:dword ptr[et_prev+edi],ebx	
 mov ds:dword ptr[et_next+ebx],edi	
 mov ds:dword ptr[et_prev+ecx],edi	

 cmp edx,0	
 jnz LDoNextEdge	

LDone:	
 pop ebx	; restore register variables
 pop esi	
 pop edi	

 ret	

;--------------------------------------------------------------------

predge	equ		4+4

 public _R_RemoveEdges	
_R_RemoveEdges:	
 push ebx	
 mov eax,ds:dword ptr[predge+esp]	

Lre_loop:	
 mov ecx,ds:dword ptr[et_next+eax]	
 mov ebx,ds:dword ptr[et_nextremove+eax]	
 mov edx,ds:dword ptr[et_prev+eax]	
 test ebx,ebx	
 mov ds:dword ptr[et_prev+ecx],edx	
 jz Lre_done	
 mov ds:dword ptr[et_next+edx],ecx	

 mov ecx,ds:dword ptr[et_next+ebx]	
 mov edx,ds:dword ptr[et_prev+ebx]	
 mov eax,ds:dword ptr[et_nextremove+ebx]	
 mov ds:dword ptr[et_prev+ecx],edx	
 test eax,eax	
 mov ds:dword ptr[et_next+edx],ecx	
 jnz Lre_loop	

 pop ebx	
 ret	

Lre_done:	
 mov ds:dword ptr[et_next+edx],ecx	
 pop ebx	

 ret	

;--------------------------------------------------------------------

pedgelist	equ		4+4		; note odd stack offset because of interleaving
							; with pushes

 public _R_StepActiveU	
_R_StepActiveU:	
 push edi	
 mov edx,ds:dword ptr[pedgelist+esp]	
 push esi	; preserve register variables
 push ebx	

 mov esi,ds:dword ptr[et_prev+edx]	

LNewEdge:	
 mov edi,ds:dword ptr[et_u+esi]	

LNextEdge:	
 mov eax,ds:dword ptr[et_u+edx]	
 mov ebx,ds:dword ptr[et_u_step+edx]	
 add eax,ebx	
 mov esi,ds:dword ptr[et_next+edx]	
 mov ds:dword ptr[et_u+edx],eax	
 cmp eax,edi	
 jl LPushBack	

 mov edi,ds:dword ptr[et_u+esi]	
 mov ebx,ds:dword ptr[et_u_step+esi]	
 add edi,ebx	
 mov edx,ds:dword ptr[et_next+esi]	
 mov ds:dword ptr[et_u+esi],edi	
 cmp edi,eax	
 jl LPushBack2	

 mov eax,ds:dword ptr[et_u+edx]	
 mov ebx,ds:dword ptr[et_u_step+edx]	
 add eax,ebx	
 mov esi,ds:dword ptr[et_next+edx]	
 mov ds:dword ptr[et_u+edx],eax	
 cmp eax,edi	
 jl LPushBack	

 mov edi,ds:dword ptr[et_u+esi]	
 mov ebx,ds:dword ptr[et_u_step+esi]	
 add edi,ebx	
 mov edx,ds:dword ptr[et_next+esi]	
 mov ds:dword ptr[et_u+esi],edi	
 cmp edi,eax	
 jnl LNextEdge	

LPushBack2:	
 mov ebx,edx	
 mov eax,edi	
 mov edx,esi	
 mov esi,ebx	

LPushBack:	
; push it back to keep it sorted
 mov ecx,ds:dword ptr[et_prev+edx]	
 mov ebx,ds:dword ptr[et_next+edx]	

; done if the -1 in edge_aftertail triggered this
 cmp edx,offset _edge_aftertail
 jz LUDone	

; pull the edge out of the edge list
 mov edi,ds:dword ptr[et_prev+ecx]	
 mov ds:dword ptr[et_prev+esi],ecx	
 mov ds:dword ptr[et_next+ecx],ebx	

; find out where the edge goes in the edge list
LPushBackLoop:	
 mov ecx,ds:dword ptr[et_prev+edi]	
 mov ebx,ds:dword ptr[et_u+edi]	
 cmp eax,ebx	
 jnl LPushBackFound	

 mov edi,ds:dword ptr[et_prev+ecx]	
 mov ebx,ds:dword ptr[et_u+ecx]	
 cmp eax,ebx	
 jl LPushBackLoop	

 mov edi,ecx	

; put the edge back into the edge list
LPushBackFound:	
 mov ebx,ds:dword ptr[et_next+edi]	
 mov ds:dword ptr[et_prev+edx],edi	
 mov ds:dword ptr[et_next+edx],ebx	
 mov ds:dword ptr[et_next+edi],edx	
 mov ds:dword ptr[et_prev+ebx],edx	

 mov edx,esi	
 mov esi,ds:dword ptr[et_prev+esi]	

 cmp edx,offset _edge_tail
 jnz LNewEdge	

LUDone:	
 pop ebx	; restore register variables
 pop esi	
 pop edi	

 ret	

;--------------------------------------------------------------------

surf	equ		4		; note this is loaded before any pushes

 align 4	
TrailingEdge:	
 mov eax,ds:dword ptr[st_spanstate+esi]	; check for edge inversion
 dec eax	
 jnz LInverted	

 mov ds:dword ptr[st_spanstate+esi],eax	
 mov ecx,ds:dword ptr[st_insubmodel+esi]	
 mov edx,ds:dword ptr[12345678h]	; surfaces[1].st_next
LPatch0:	
 mov eax,ds:dword ptr[_r_bmodelactive]	
 sub eax,ecx	
 cmp edx,esi	
 mov ds:dword ptr[_r_bmodelactive],eax	
 jnz LNoEmit	; surface isn't on top, just remove

; emit a span (current top going away)
 mov eax,ds:dword ptr[et_u+ebx]	
 shr eax,20	; iu = integral pixel u
 mov edx,ds:dword ptr[st_last_u+esi]	
 mov ecx,ds:dword ptr[st_next+esi]	
 cmp eax,edx	
 jle LNoEmit2	; iu <= surf->last_u, so nothing to emit

 mov ds:dword ptr[st_last_u+ecx],eax	; surf->next->last_u = iu;
 sub eax,edx	
 mov ds:dword ptr[espan_t_u+ebp],edx	; span->u = surf->last_u;

 mov ds:dword ptr[espan_t_count+ebp],eax	; span->count = iu - span->u;
 mov eax,ds:dword ptr[_current_iv]	
 mov ds:dword ptr[espan_t_v+ebp],eax	; span->v = current_iv;
 mov eax,ds:dword ptr[st_spans+esi]	
 mov ds:dword ptr[espan_t_pnext+ebp],eax	; span->pnext = surf->spans;
 mov ds:dword ptr[st_spans+esi],ebp	; surf->spans = span;
 add ebp,offset espan_t_size	

 mov edx,ds:dword ptr[st_next+esi]	; remove the surface from the surface
 mov esi,ds:dword ptr[st_prev+esi]	; stack

 mov ds:dword ptr[st_next+esi],edx	
 mov ds:dword ptr[st_prev+edx],esi	
 ret	

LNoEmit2:	
 mov ds:dword ptr[st_last_u+ecx],eax	; surf->next->last_u = iu;
 mov edx,ds:dword ptr[st_next+esi]	; remove the surface from the surface
 mov esi,ds:dword ptr[st_prev+esi]	; stack

 mov ds:dword ptr[st_next+esi],edx	
 mov ds:dword ptr[st_prev+edx],esi	
 ret	

LNoEmit:	
 mov edx,ds:dword ptr[st_next+esi]	; remove the surface from the surface
 mov esi,ds:dword ptr[st_prev+esi]	; stack

 mov ds:dword ptr[st_next+esi],edx	
 mov ds:dword ptr[st_prev+edx],esi	
 ret	

LInverted:	
 mov ds:dword ptr[st_spanstate+esi],eax	
 ret	

;--------------------------------------------------------------------

; trailing edge only
Lgs_trailing:	
 push offset Lgs_nextedge	
 jmp TrailingEdge	


 public _R_GenerateSpans	
_R_GenerateSpans:	
 push ebp	; preserve caller's stack frame
 push edi	
 push esi	; preserve register variables
 push ebx	

; clear active surfaces to just the background surface
 mov eax,ds:dword ptr[_surfaces]	
 mov edx,ds:dword ptr[_edge_head_u_shift20]	
 add eax,offset st_size	
; %ebp = span_p throughout
 mov ebp,ds:dword ptr[_span_p]	

 mov ds:dword ptr[_r_bmodelactive],0	

 mov ds:dword ptr[st_next+eax],eax	
 mov ds:dword ptr[st_prev+eax],eax	
 mov ds:dword ptr[st_last_u+eax],edx	
 mov ebx,ds:dword ptr[_edge_head+et_next]	; edge=edge_head.next

; generate spans
 cmp ebx,offset _edge_tail	; done if empty list
 jz Lgs_lastspan	

Lgs_edgeloop:	

 mov edi,ds:dword ptr[et_surfs+ebx]	
 mov eax,ds:dword ptr[_surfaces]	
 mov esi,edi	
 and edi,0FFFF0000h	
 and esi,0FFFFh	
 jz Lgs_leading	; not a trailing edge

; it has a left surface, so a surface is going away for this span
 shl esi,offset SURF_T_SHIFT	
 add esi,eax	
 test edi,edi	
 jz Lgs_trailing	

; both leading and trailing
 call near ptr TrailingEdge	
 mov eax,ds:dword ptr[_surfaces]	

; ---------------------------------------------------------------
; handle a leading edge
; ---------------------------------------------------------------

Lgs_leading:	
 shr edi,16-SURF_T_SHIFT	
 mov eax,ds:dword ptr[_surfaces]	
 add edi,eax	
 mov esi,ds:dword ptr[12345678h]	; surf2 = surfaces[1].next;
LPatch2:	
 mov edx,ds:dword ptr[st_spanstate+edi]	
 mov eax,ds:dword ptr[st_insubmodel+edi]	
 test eax,eax	
 jnz Lbmodel_leading	

; handle a leading non-bmodel edge

; don't start a span if this is an inverted span, with the end edge preceding
; the start edge (that is, we've already seen the end edge)
 test edx,edx	
 jnz Lxl_done	


; if (surf->key < surf2->key)
;		goto newtop;
 inc edx	
 mov eax,ds:dword ptr[st_key+edi]	
 mov ds:dword ptr[st_spanstate+edi],edx	
 mov ecx,ds:dword ptr[st_key+esi]	
 cmp eax,ecx	
 jl Lnewtop	

; main sorting loop to search through surface stack until insertion point
; found. Always terminates because background surface is sentinel
; do
; {
; 		surf2 = surf2->next;
; } while (surf->key >= surf2->key);
Lsortloopnb:	
 mov esi,ds:dword ptr[st_next+esi]	
 mov ecx,ds:dword ptr[st_key+esi]	
 cmp eax,ecx	
 jge Lsortloopnb	

 jmp LInsertAndExit	


; handle a leading bmodel edge
 align 4	
Lbmodel_leading:	

; don't start a span if this is an inverted span, with the end edge preceding
; the start edge (that is, we've already seen the end edge)
 test edx,edx	
 jnz Lxl_done	

 mov ecx,ds:dword ptr[_r_bmodelactive]	
 inc edx	
 inc ecx	
 mov ds:dword ptr[st_spanstate+edi],edx	
 mov ds:dword ptr[_r_bmodelactive],ecx	

; if (surf->key < surf2->key)
;		goto newtop;
 mov eax,ds:dword ptr[st_key+edi]	
 mov ecx,ds:dword ptr[st_key+esi]	
 cmp eax,ecx	
 jl Lnewtop	

; if ((surf->key == surf2->key) && surf->insubmodel)
; {
 jz Lzcheck_for_newtop	

; main sorting loop to search through surface stack until insertion point
; found. Always terminates because background surface is sentinel
; do
; {
; 		surf2 = surf2->next;
; } while (surf->key > surf2->key);
Lsortloop:	
 mov esi,ds:dword ptr[st_next+esi]	
 mov ecx,ds:dword ptr[st_key+esi]	
 cmp eax,ecx	
 jg Lsortloop	

 jne LInsertAndExit	

; Do 1/z sorting to see if we've arrived in the right position
 mov eax,ds:dword ptr[et_u+ebx]	
 sub eax,0FFFFFh	
 mov ds:dword ptr[Ltemp],eax	
 fild ds:dword ptr[Ltemp]	

 fmul ds:dword ptr[float_1_div_0100000h]	; fu = (float)(edge->u - 0xFFFFF) *
;      (1.0 / 0x100000);

 fld st(0)	; fu | fu
 fmul ds:dword ptr[st_d_zistepu+edi]	; fu*surf->d_zistepu | fu
 fld ds:dword ptr[_fv]	; fv | fu*surf->d_zistepu | fu
 fmul ds:dword ptr[st_d_zistepv+edi]	; fv*surf->d_zistepv | fu*surf->d_zistepu | fu
 fxch st(1)	; fu*surf->d_zistepu | fv*surf->d_zistepv | fu
 fadd ds:dword ptr[st_d_ziorigin+edi]	; fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu

 fld ds:dword ptr[st_d_zistepu+esi]	; surf2->d_zistepu |
;  fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu
 fmul st(0),st(3)	; fu*surf2->d_zistepu |
;  fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu
 fxch st(1)	; fu*surf->d_zistepu + surf->d_ziorigin |
;  fu*surf2->d_zistepu |
;  fv*surf->d_zistepv | fu
 faddp st(2),st(0)	; fu*surf2->d_zistepu | newzi | fu

 fld ds:dword ptr[_fv]	; fv | fu*surf2->d_zistepu | newzi | fu
 fmul ds:dword ptr[st_d_zistepv+esi]	; fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu
 fld st(2)	; newzi | fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu
 fmul ds:dword ptr[float_point_999]	; newzibottom | fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu

 fxch st(2)	; fu*surf2->d_zistepu | fv*surf2->d_zistepv |
;  newzibottom | newzi | fu
 fadd ds:dword ptr[st_d_ziorigin+esi]	; fu*surf2->d_zistepu + surf2->d_ziorigin |
;  fv*surf2->d_zistepv | newzibottom | newzi |
;  fu
 faddp st(1),st(0)	; testzi | newzibottom | newzi | fu
 fxch st(1)	; newzibottom | testzi | newzi | fu

; if (newzibottom >= testzi)
;     goto Lgotposition;

 fcomp st(1)	; testzi | newzi | fu

 fxch st(1)	; newzi | testzi | fu
 fmul ds:dword ptr[float_1_point_001]	; newzitop | testzi | fu
 fxch st(1)	; testzi | newzitop | fu

 fnstsw ax	
 test ah,001h	
 jz Lgotposition_fpop3	

; if (newzitop >= testzi)
; {

 fcomp st(1)	; newzitop | fu
 fnstsw ax	
 test ah,045h	
 jz Lsortloop_fpop2	

; if (surf->d_zistepu >= surf2->d_zistepu)
;     goto newtop;

 fld ds:dword ptr[st_d_zistepu+edi]	; surf->d_zistepu | newzitop| fu
 fcomp ds:dword ptr[st_d_zistepu+esi]	; newzitop | fu
 fnstsw ax	
 test ah,001h	
 jz Lgotposition_fpop2	

 fstp st(0)	; clear the FPstack
 fstp st(0)	
 mov eax,ds:dword ptr[st_key+edi]	
 jmp Lsortloop	


Lgotposition_fpop3:	
 fstp st(0)	
Lgotposition_fpop2:	
 fstp st(0)	
 fstp st(0)	
 jmp LInsertAndExit	


; emit a span (obscures current top)

Lnewtop_fpop3:	
 fstp st(0)	
Lnewtop_fpop2:	
 fstp st(0)	
 fstp st(0)	
 mov eax,ds:dword ptr[st_key+edi]	; reload the sorting key

Lnewtop:	
 mov eax,ds:dword ptr[et_u+ebx]	
 mov edx,ds:dword ptr[st_last_u+esi]	
 shr eax,20	; iu = integral pixel u
 mov ds:dword ptr[st_last_u+edi],eax	; surf->last_u = iu;
 cmp eax,edx	
 jle LInsertAndExit	; iu <= surf->last_u, so nothing to emit

 sub eax,edx	
 mov ds:dword ptr[espan_t_u+ebp],edx	; span->u = surf->last_u;

 mov ds:dword ptr[espan_t_count+ebp],eax	; span->count = iu - span->u;
 mov eax,ds:dword ptr[_current_iv]	
 mov ds:dword ptr[espan_t_v+ebp],eax	; span->v = current_iv;
 mov eax,ds:dword ptr[st_spans+esi]	
 mov ds:dword ptr[espan_t_pnext+ebp],eax	; span->pnext = surf->spans;
 mov ds:dword ptr[st_spans+esi],ebp	; surf->spans = span;
 add ebp,offset espan_t_size	

LInsertAndExit:	
; insert before surf2
 mov ds:dword ptr[st_next+edi],esi	; surf->next = surf2;
 mov eax,ds:dword ptr[st_prev+esi]	
 mov ds:dword ptr[st_prev+edi],eax	; surf->prev = surf2->prev;
 mov ds:dword ptr[st_prev+esi],edi	; surf2->prev = surf;
 mov ds:dword ptr[st_next+eax],edi	; surf2->prev->next = surf;

; ---------------------------------------------------------------
; leading edge done
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; see if there are any more edges
; ---------------------------------------------------------------

Lgs_nextedge:	
 mov ebx,ds:dword ptr[et_next+ebx]	
 cmp ebx,offset _edge_tail
 jnz Lgs_edgeloop	

; clean up at the right edge
Lgs_lastspan:	

; now that we've reached the right edge of the screen, we're done with any
; unfinished surfaces, so emit a span for whatever's on top
 mov esi,ds:dword ptr[12345678h]	; surfaces[1].st_next
LPatch3:	
 mov eax,ds:dword ptr[_edge_tail_u_shift20]	
 xor ecx,ecx	
 mov edx,ds:dword ptr[st_last_u+esi]	
 sub eax,edx	
 jle Lgs_resetspanstate	

 mov ds:dword ptr[espan_t_u+ebp],edx	
 mov ds:dword ptr[espan_t_count+ebp],eax	
 mov eax,ds:dword ptr[_current_iv]	
 mov ds:dword ptr[espan_t_v+ebp],eax	
 mov eax,ds:dword ptr[st_spans+esi]	
 mov ds:dword ptr[espan_t_pnext+ebp],eax	
 mov ds:dword ptr[st_spans+esi],ebp	
 add ebp,offset espan_t_size	

; reset spanstate for all surfaces in the surface stack
Lgs_resetspanstate:	
 mov ds:dword ptr[st_spanstate+esi],ecx	
 mov esi,ds:dword ptr[st_next+esi]	
 cmp esi,012345678h	; &surfaces[1]
LPatch4:	
 jnz Lgs_resetspanstate	

; store the final span_p
 mov ds:dword ptr[_span_p],ebp	

 pop ebx	; restore register variables
 pop esi	
 pop edi	
 pop ebp	; restore the caller's stack frame
 ret	


; ---------------------------------------------------------------
; 1/z sorting for bmodels in the same leaf
; ---------------------------------------------------------------
 align 4	
Lxl_done:	
 inc edx	
 mov ds:dword ptr[st_spanstate+edi],edx	

 jmp Lgs_nextedge	


 align 4	
Lzcheck_for_newtop:	
 mov eax,ds:dword ptr[et_u+ebx]	
 sub eax,0FFFFFh	
 mov ds:dword ptr[Ltemp],eax	
 fild ds:dword ptr[Ltemp]	

 fmul ds:dword ptr[float_1_div_0100000h]	; fu = (float)(edge->u - 0xFFFFF) *
;      (1.0 / 0x100000);

 fld st(0)	; fu | fu
 fmul ds:dword ptr[st_d_zistepu+edi]	; fu*surf->d_zistepu | fu
 fld ds:dword ptr[_fv]	; fv | fu*surf->d_zistepu | fu
 fmul ds:dword ptr[st_d_zistepv+edi]	; fv*surf->d_zistepv | fu*surf->d_zistepu | fu
 fxch st(1)	; fu*surf->d_zistepu | fv*surf->d_zistepv | fu
 fadd ds:dword ptr[st_d_ziorigin+edi]	; fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu

 fld ds:dword ptr[st_d_zistepu+esi]	; surf2->d_zistepu |
;  fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu
 fmul st(0),st(3)	; fu*surf2->d_zistepu |
;  fu*surf->d_zistepu + surf->d_ziorigin |
;  fv*surf->d_zistepv | fu
 fxch st(1)	; fu*surf->d_zistepu + surf->d_ziorigin |
;  fu*surf2->d_zistepu |
;  fv*surf->d_zistepv | fu
 faddp st(2),st(0)	; fu*surf2->d_zistepu | newzi | fu

 fld ds:dword ptr[_fv]	; fv | fu*surf2->d_zistepu | newzi | fu
 fmul ds:dword ptr[st_d_zistepv+esi]	; fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu
 fld st(2)	; newzi | fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu
 fmul ds:dword ptr[float_point_999]	; newzibottom | fv*surf2->d_zistepv |
;  fu*surf2->d_zistepu | newzi | fu

 fxch st(2)	; fu*surf2->d_zistepu | fv*surf2->d_zistepv |
;  newzibottom | newzi | fu
 fadd ds:dword ptr[st_d_ziorigin+esi]	; fu*surf2->d_zistepu + surf2->d_ziorigin |
;  fv*surf2->d_zistepv | newzibottom | newzi |
;  fu
 faddp st(1),st(0)	; testzi | newzibottom | newzi | fu
 fxch st(1)	; newzibottom | testzi | newzi | fu

; if (newzibottom >= testzi)
;     goto newtop;

 fcomp st(1)	; testzi | newzi | fu

 fxch st(1)	; newzi | testzi | fu
 fmul ds:dword ptr[float_1_point_001]	; newzitop | testzi | fu
 fxch st(1)	; testzi | newzitop | fu

 fnstsw ax	
 test ah,001h	
 jz Lnewtop_fpop3	

; if (newzitop >= testzi)
; {

 fcomp st(1)	; newzitop | fu
 fnstsw ax	
 test ah,045h	
 jz Lsortloop_fpop2	

; if (surf->d_zistepu >= surf2->d_zistepu)
;     goto newtop;

 fld ds:dword ptr[st_d_zistepu+edi]	; surf->d_zistepu | newzitop | fu
 fcomp ds:dword ptr[st_d_zistepu+esi]	; newzitop | fu
 fnstsw ax	
 test ah,001h	
 jz Lnewtop_fpop2	

Lsortloop_fpop2:	
 fstp st(0)	; clear the FP stack
 fstp st(0)	
 mov eax,ds:dword ptr[st_key+edi]	
 jmp Lsortloop	


 public _R_EdgeCodeEnd	
_R_EdgeCodeEnd:	


;----------------------------------------------------------------------
; Surface array address code patching routine
;----------------------------------------------------------------------

 align 4	
 public _R_SurfacePatch	
_R_SurfacePatch:	

 mov eax,ds:dword ptr[_surfaces]	
 add eax,offset st_size	
 mov ds:dword ptr[LPatch4-4],eax	

 add eax,offset st_next	
 mov ds:dword ptr[LPatch0-4],eax	
 mov ds:dword ptr[LPatch2-4],eax	
 mov ds:dword ptr[LPatch3-4],eax	

 ret	

_TEXT ENDS
endif	;id386
 END
