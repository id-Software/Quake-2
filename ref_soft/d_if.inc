;
; d_ifacea.h
;
; Include file for asm driver interface.
;

;
; !!! note that this file must match the corresponding C structures in
; d_iface.h at all times !!!
;

; !!! if this is changed, it must be changed in r_shared.h too !!!
ALIAS_ONSEAM				equ		00020h

; !!! if this is changed, it must be changed in d_iface.h too !!!
TURB_TEX_SIZE	equ		64

; !!! if this is changed, it must be changed in d_iface.h too !!!
CYCLE	equ		128

; !!! if this is changed, it must be changed in r_shared.h too !!!
MAXHEIGHT	equ		1024

; !!! if this is changed, it must be changed in quakedef.h too !!!
CACHE_SIZE	equ		32

; particle_t structure
; !!! if this is changed, it must be changed in d_iface.h too !!!
; driver-usable fields
pt_org				equ		0
pt_color			equ		12
; drivers never touch the following fields
pt_next				equ		16
pt_vel				equ		20
pt_ramp				equ		32
pt_die				equ		36
pt_type				equ		40
pt_size				equ		44

PARTICLE_Z_CLIP	equ		8.0

; finalvert_t structure
; !!! if this is changed, it must be changed in d_iface.h too !!!
fv_v				equ		0	; !!! if this is moved, cases where the !!!
								; !!! address of this field is pushed in !!!
								; !!! d_polysa.s must be changed !!!
fv_flags			equ		24
fv_reserved			equ		28
fv_size				equ		32
fv_shift			equ		5


; stvert_t structure
; !!! if this is changed, it must be changed in modelgen.h too !!!
stv_onseam	equ		0
stv_s		equ		4
stv_t		equ		8
stv_size	equ		12


; trivertx_t structure
; !!! if this is changed, it must be changed in modelgen.h too !!!
tv_v				equ		0
tv_lightnormalindex	equ		3
tv_size				equ		4

; affinetridesc_t structure
; !!! if this is changed, it must be changed in d_iface.h too !!!
atd_pskin			equ		0
atd_pskindesc		equ		4
atd_skinwidth		equ		8
atd_skinheight		equ		12
atd_ptriangles		equ		16
atd_pfinalverts		equ		20
atd_numtriangles	equ		24
atd_drawtype		equ		28
atd_seamfixupX16	equ		32
atd_do_vis_thresh	equ		36
atd_vis_thresh		equ		40
atd_size			equ		44

