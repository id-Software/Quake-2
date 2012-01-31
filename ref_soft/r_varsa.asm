 .386P
 .model FLAT
;
; d_varsa.s
;

include qasm.inc
include d_if.inc

if	id386

_DATA SEGMENT	

;-------------------------------------------------------
; ASM-only variables
;-------------------------------------------------------
 public float_1, float_particle_z_clip, float_point5	
 public float_minus_1, float_0	
float_0 dd 0.0	
float_1 dd 1.0	
float_minus_1 dd -1.0	
float_particle_z_clip dd PARTICLE_Z_CLIP	
float_point5 dd 0.5	

 public fp_16, fp_64k, fp_1m, fp_64kx64k	
 public fp_1m_minus_1	
 public fp_8	
fp_1m dd 1048576.0	
fp_1m_minus_1 dd 1048575.0	
fp_64k dd 65536.0	
fp_8 dd 8.0	
fp_16 dd 16.0	
fp_64kx64k dd 04f000000h	; (float)0x8000*0x10000


 public FloatZero, Float2ToThe31nd, FloatMinus2ToThe31nd	
FloatZero dd 0	
Float2ToThe31nd dd 04f000000h	
FloatMinus2ToThe31nd dd 0cf000000h	

 public _r_bmodelactive	
_r_bmodelactive dd 0	


;-------------------------------------------------------
; global refresh variables
;-------------------------------------------------------

; FIXME: put all refresh variables into one contiguous block. Make into one
; big structure, like cl or sv?

 align 4	
 public _d_sdivzstepu	
 public _d_tdivzstepu	
 public _d_zistepu	
 public _d_sdivzstepv	
 public _d_tdivzstepv	
 public _d_zistepv	
 public _d_sdivzorigin	
 public _d_tdivzorigin	
 public _d_ziorigin	
_d_sdivzstepu dd 0	
_d_tdivzstepu dd 0	
_d_zistepu dd 0	
_d_sdivzstepv dd 0	
_d_tdivzstepv dd 0	
_d_zistepv dd 0	
_d_sdivzorigin dd 0	
_d_tdivzorigin dd 0	
_d_ziorigin dd 0	

 public _sadjust	
 public _tadjust	
 public _bbextents	
 public _bbextentt	
_sadjust dd 0	
_tadjust dd 0	
_bbextents dd 0	
_bbextentt dd 0	

 public _cacheblock	
 public _d_viewbuffer	
 public _cachewidth	
 public _d_pzbuffer	
 public _d_zrowbytes	
 public _d_zwidth	
_cacheblock dd 0	
_cachewidth dd 0	
_d_viewbuffer dd 0	
_d_pzbuffer dd 0	
_d_zrowbytes dd 0	
_d_zwidth dd 0	


;-------------------------------------------------------
; ASM-only variables
;-------------------------------------------------------
 public izi	
izi dd 0	

 public pbase, s, t, sfracf, tfracf, snext, tnext	
 public spancountminus1, zi16stepu, sdivz16stepu, tdivz16stepu	
 public zi8stepu, sdivz8stepu, tdivz8stepu, pz	
s dd 0	
t dd 0	
snext dd 0	
tnext dd 0	
sfracf dd 0	
tfracf dd 0	
pbase dd 0	
zi8stepu dd 0	
sdivz8stepu dd 0	
tdivz8stepu dd 0	
zi16stepu dd 0	
sdivz16stepu dd 0	
tdivz16stepu dd 0	
spancountminus1 dd 0	
pz dd 0	

 public izistep	
izistep dd 0	

;-------------------------------------------------------
; local variables for d_draw16.s
;-------------------------------------------------------

 public reciprocal_table_16, entryvec_table_16	
; 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9, 1/10, 1/11, 1/12, 1/13,
; 1/14, and 1/15 in 0.32 form
reciprocal_table_16 dd 040000000h, 02aaaaaaah, 020000000h	
 dd 019999999h, 015555555h, 012492492h	
 dd 010000000h, 0e38e38eh, 0ccccccch, 0ba2e8bah	
 dd 0aaaaaaah, 09d89d89h, 09249249h, 08888888h	

 externdef Entry2_16:dword	
 externdef Entry3_16:dword	
 externdef Entry4_16:dword	
 externdef Entry5_16:dword	
 externdef Entry6_16:dword	
 externdef Entry7_16:dword	
 externdef Entry8_16:dword	
 externdef Entry9_16:dword	
 externdef Entry10_16:dword	
 externdef Entry11_16:dword	
 externdef Entry12_16:dword	
 externdef Entry13_16:dword	
 externdef Entry14_16:dword	
 externdef Entry15_16:dword	
 externdef Entry16_16:dword	

entryvec_table_16 dd 0, Entry2_16, Entry3_16, Entry4_16	
 dd Entry5_16, Entry6_16, Entry7_16, Entry8_16	
 dd Entry9_16, Entry10_16, Entry11_16, Entry12_16	
 dd Entry13_16, Entry14_16, Entry15_16, Entry16_16	

;-------------------------------------------------------
; local variables for d_parta.s
;-------------------------------------------------------
 public DP_Count, DP_u, DP_v, DP_32768, DP_Color, DP_Pix
DP_Count dd 0	
DP_u dd 0	
DP_v dd 0	
DP_32768 dd 32768.0	
DP_Color dd 0	
DP_Pix dd 0	


;externdef DP_1x1:dword	
;externdef DP_2x2:dword	
;externdef DP_3x3:dword	
;externdef DP_4x4:dword	

;DP_EntryTable dd DP_1x1, DP_2x2, DP_3x3, DP_4x4	

;
; advancetable is 8 bytes, but points to the middle of that range so negative
; offsets will work
;
 public advancetable, sstep, tstep, pspantemp, counttemp, jumptemp	
advancetable dd 0, 0	
sstep dd 0	
tstep dd 0	

pspantemp dd 0	
counttemp dd 0	
jumptemp dd 0	

; 1/2, 1/3, 1/4, 1/5, 1/6, and 1/7 in 0.32 form
; public reciprocal_table, entryvec_table	
reciprocal_table dd 040000000h, 02aaaaaaah, 020000000h	
 dd 019999999h, 015555555h, 012492492h	


; externdef Entry2_8:dword	
; externdef Entry3_8:dword	
; externdef Entry4_8:dword	
; externdef Entry5_8:dword	
; externdef Entry6_8:dword	
; externdef Entry7_8:dword	
; externdef Entry8_8:dword	

;entryvec_table dd 0, Entry2_8, Entry3_8, Entry4_8	
; dd Entry5_8, Entry6_8, Entry7_8, Entry8_8	

 externdef Spr8Entry2_8:dword	
 externdef Spr8Entry3_8:dword	
 externdef Spr8Entry4_8:dword	
 externdef Spr8Entry5_8:dword	
 externdef Spr8Entry6_8:dword	
 externdef Spr8Entry7_8:dword	
 externdef Spr8Entry8_8:dword	

 public spr8entryvec_table	
spr8entryvec_table dd 0, Spr8Entry2_8, Spr8Entry3_8, Spr8Entry4_8	
 dd Spr8Entry5_8, Spr8Entry6_8, Spr8Entry7_8, Spr8Entry8_8	


_DATA ENDS
endif	; id386
 END
