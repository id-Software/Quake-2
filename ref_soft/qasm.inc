;
; qasm.inc
;
; Include file for asm routines.
;

;
; !!! note that this file must match the corresponding C structures at all
; times !!!
;

; set to 0 to skip all asm code
id386	equ		1

; !!! must be kept the same as in d_iface.h !!!
TRANSPARENT_COLOR	equ		255

ifndef GLQUAKE
	externdef _d_zistepu:dword
	externdef _d_pzbuffer:dword
	externdef _d_zistepv:dword
	externdef _d_zrowbytes:dword
	externdef _d_ziorigin:dword
	externdef _r_turb_s:dword
	externdef _r_turb_t:dword
	externdef _r_turb_pdest:dword
	externdef _r_turb_spancount:dword
	externdef _r_turb_turb:dword
	externdef _r_turb_pbase:dword
	externdef _r_turb_sstep:dword
	externdef _r_turb_tstep:dword
	externdef	_r_bmodelactive:dword
	externdef	_d_sdivzstepu:dword
	externdef	_d_tdivzstepu:dword
	externdef	_d_sdivzstepv:dword
	externdef	_d_tdivzstepv:dword
	externdef	_d_sdivzorigin:dword
	externdef	_d_tdivzorigin:dword
	externdef	_sadjust:dword
	externdef	_tadjust:dword
	externdef	_bbextents:dword
	externdef	_bbextentt:dword
	externdef	_cacheblock:dword
	externdef	_d_viewbuffer:dword
	externdef	_cachewidth:dword
	externdef	_d_pzbuffer:dword
	externdef	_d_zrowbytes:dword
	externdef	_d_zwidth:dword
	externdef _d_scantable:dword
	externdef _r_lightptr:dword
	externdef _r_numvblocks:dword
	externdef _prowdestbase:dword
	externdef _pbasesource:dword
	externdef _r_lightwidth:dword
	externdef _lightright:dword
	externdef _lightrightstep:dword
	externdef _lightdeltastep:dword
	externdef _lightdelta:dword
	externdef _lightright:dword
	externdef _lightdelta:dword
	externdef _sourcetstep:dword
	externdef _surfrowbytes:dword
	externdef _lightrightstep:dword
	externdef _lightdeltastep:dword
	externdef _r_sourcemax:dword
	externdef _r_stepback:dword
	externdef _colormap:dword
	externdef _blocksize:dword
	externdef _sourcesstep:dword
	externdef _lightleft:dword
	externdef _blockdivshift:dword
	externdef _blockdivmask:dword
	externdef _lightleftstep:dword
	externdef _r_origin:dword
	externdef _r_ppn:dword
	externdef _r_pup:dword
	externdef _r_pright:dword
	externdef _ycenter:dword
	externdef _xcenter:dword
	externdef _d_vrectbottom_particle:dword
	externdef _d_vrectright_particle:dword
	externdef _d_vrecty:dword
	externdef _d_vrectx:dword
	externdef _d_pix_shift:dword
	externdef _d_pix_min:dword
	externdef _d_pix_max:dword
	externdef _d_y_aspect_shift:dword
	externdef _screenwidth:dword
	externdef _r_leftclipped:dword
	externdef _r_leftenter:dword
	externdef _r_rightclipped:dword
	externdef _r_rightenter:dword
	externdef _modelorg:dword
	externdef _xscale:dword
	externdef _r_refdef:dword
	externdef _yscale:dword
	externdef _r_leftexit:dword
	externdef _r_rightexit:dword
	externdef _r_lastvertvalid:dword
	externdef _cacheoffset:dword
	externdef _newedges:dword
	externdef _removeedges:dword
	externdef _r_pedge:dword
	externdef _r_framecount:dword
	externdef _r_u1:dword
	externdef _r_emitted:dword
	externdef _edge_p:dword
	externdef _surface_p:dword
	externdef _surfaces:dword
	externdef _r_lzi1:dword
	externdef _r_v1:dword
	externdef _r_ceilv1:dword
	externdef _r_nearzi:dword
	externdef _r_nearzionly:dword
	externdef _edge_aftertail:dword
	externdef _edge_tail:dword
	externdef _current_iv:dword
	externdef _edge_head_u_shift20:dword
	externdef _span_p:dword
	externdef _edge_head:dword
	externdef _fv:dword
	externdef _edge_tail_u_shift20:dword
	externdef _r_apverts:dword
	externdef _r_anumverts:dword
	externdef _aliastransform:dword
	externdef _r_avertexnormals:dword
	externdef _r_plightvec:dword
	externdef _r_ambientlight:dword
	externdef _r_shadelight:dword
	externdef _aliasxcenter:dword
	externdef _aliasycenter:dword
	externdef _a_sstepxfrac:dword
	externdef _r_affinetridesc:dword
	externdef _acolormap:dword
	externdef _d_pcolormap:dword
	externdef _r_affinetridesc:dword
	externdef _d_sfrac:dword
	externdef _d_ptex:dword
	externdef _d_pedgespanpackage:dword
	externdef _d_tfrac:dword
	externdef _d_light:dword
	externdef _d_zi:dword
	externdef _d_pdest:dword
	externdef _d_pz:dword
	externdef _d_aspancount:dword
	externdef _erroradjustup:dword
	externdef _errorterm:dword
	externdef _d_xdenom:dword
	externdef _r_p0:dword
	externdef _r_p1:dword
	externdef _r_p2:dword
	externdef _a_tstepxfrac:dword
	externdef _r_sstepx:dword
	externdef _r_tstepx:dword
	externdef _a_ststepxwhole:dword
	externdef _zspantable:dword
	externdef _skintable:dword
	externdef _r_zistepx:dword
	externdef _erroradjustdown:dword
	externdef _d_countextrastep:dword
	externdef _ubasestep:dword
	externdef _a_ststepxwhole:dword
	externdef _a_tstepxfrac:dword
	externdef _r_lstepx:dword
	externdef _a_spans:dword
	externdef _erroradjustdown:dword
	externdef _d_pdestextrastep:dword
	externdef _d_pzextrastep:dword
	externdef _d_sfracextrastep:dword
	externdef _d_ptexextrastep:dword
	externdef _d_countextrastep:dword
	externdef _d_tfracextrastep:dword
	externdef _d_lightextrastep:dword
	externdef _d_ziextrastep:dword
	externdef _d_pdestbasestep:dword
	externdef _d_pzbasestep:dword
	externdef _d_sfracbasestep:dword
	externdef _d_ptexbasestep:dword
	externdef _ubasestep:dword
	externdef _d_tfracbasestep:dword
	externdef _d_lightbasestep:dword
	externdef _d_zibasestep:dword
	externdef _zspantable:dword
	externdef _r_lstepy:dword
	externdef _r_sstepy:dword
	externdef _r_tstepy:dword
	externdef _r_zistepy:dword
	externdef _D_PolysetSetEdgeTable:dword
	externdef _D_RasterizeAliasPolySmooth:dword

	externdef float_point5:dword
	externdef Float2ToThe31nd:dword
	externdef izistep:dword
	externdef izi:dword
	externdef FloatMinus2ToThe31nd:dword
	externdef float_1:dword
	externdef float_particle_z_clip:dword
	externdef float_minus_1:dword
	externdef float_0:dword
	externdef fp_16:dword
	externdef fp_64k:dword
	externdef fp_1m:dword
	externdef fp_1m_minus_1:dword
	externdef fp_8 :dword
	externdef entryvec_table:dword
	externdef advancetable:dword
	externdef sstep:dword
	externdef tstep:dword
	externdef pspantemp:dword
	externdef counttemp:dword
	externdef jumptemp:dword
	externdef reciprocal_table:dword
	externdef DP_Count:dword
	externdef DP_u:dword
	externdef DP_v:dword
	externdef DP_32768:dword
	externdef DP_Color:dword
	externdef DP_Pix:dword
	externdef DP_EntryTable:dword
	externdef	pbase:dword
	externdef s:dword
	externdef t:dword
	externdef sfracf:dword
	externdef tfracf:dword
	externdef snext:dword
	externdef tnext:dword
	externdef	spancountminus1:dword
	externdef zi16stepu:dword
	externdef sdivz16stepu:dword
	externdef tdivz16stepu:dword
	externdef	zi8stepu:dword
	externdef sdivz8stepu:dword
	externdef tdivz8stepu:dword
	externdef reciprocal_table_16:dword
	externdef entryvec_table_16:dword
	externdef fp_64kx64k:dword
	externdef pz:dword
	externdef spr8entryvec_table:dword
endif

	externdef _fpu_ceil_cw:dword
	externdef _fpu_chop_cw:dword
	externdef _snd_scaletable:dword
	externdef _paintbuffer:dword
	externdef _snd_linear_count:dword
	externdef _snd_p:dword
	externdef _snd_vol:dword
	externdef _snd_out:dword
	externdef _vright:dword
	externdef _vup:dword
	externdef _vpn:dword
	externdef _BOPS_Error:dword

; plane_t structure
; !!! if this is changed, it must be changed in model.h too !!!
; !!! if the size of this is changed, the array lookup in SV_HullPointContents
;     must be changed too !!!
pl_normal	equ		0
pl_dist		equ		12
pl_type		equ		16
pl_signbits	equ		17
pl_pad		equ		18
pl_size		equ		20

; hull_t structure
; !!! if this is changed, it must be changed in model.h too !!!
hu_clipnodes		equ		0
hu_planes			equ		4
hu_firstclipnode	equ		8
hu_lastclipnode		equ		12
hu_clip_mins		equ		16
hu_clip_maxs		equ		28
hu_size  			equ		40

; dnode_t structure
; !!! if this is changed, it must be changed in bspfile.h too !!!
nd_planenum		equ		0
nd_children		equ		4
nd_mins			equ		8
nd_maxs			equ		20
nd_firstface	equ		32
nd_numfaces		equ		36
nd_size			equ		40

; sfxcache_t structure
; !!! if this is changed, it much be changed in sound.h too !!!
sfxc_length		equ		0
sfxc_loopstart	equ		4
sfxc_speed		equ		8
sfxc_width		equ		12
sfxc_stereo		equ		16
sfxc_data		equ		20

; channel_t structure
; !!! if this is changed, it much be changed in sound.h too !!!
ch_sfx			equ		0
ch_leftvol		equ		4
ch_rightvol		equ		8
ch_end			equ		12
ch_pos			equ		16
ch_looping		equ		20
ch_entnum		equ		24
ch_entchannel	equ		28
ch_origin		equ		32
ch_dist_mult	equ		44
ch_master_vol	equ		48
ch_size			equ		52

; portable_samplepair_t structure
; !!! if this is changed, it much be changed in sound.h too !!!
psp_left		equ		0
psp_right		equ		4
psp_size		equ		8

; !!! if this is changed, it must be changed in r_local.h too !!!
NEAR_CLIP	equ		0.01

; !!! if this is changed, it must be changed in r_local.h too !!!
CYCLE	equ		128

; espan_t structure
; !!! if this is changed, it must be changed in r_shared.h too !!!
espan_t_u    	equ		0
espan_t_v	    equ		4
espan_t_count   equ		8
espan_t_pnext	equ		12
espan_t_size    equ		16

; sspan_t structure
; !!! if this is changed, it must be changed in d_local.h too !!!
sspan_t_u    	equ		0
sspan_t_v	    equ		4
sspan_t_count   equ		8
sspan_t_size    equ		12

; spanpackage_t structure
; !!! if this is changed, it must be changed in d_polyset.c too !!!
spanpackage_t_pdest				equ		0
spanpackage_t_pz				equ		4
spanpackage_t_count				equ		8
spanpackage_t_ptex				equ		12
spanpackage_t_sfrac				equ		16
spanpackage_t_tfrac				equ		20
spanpackage_t_light				equ		24
spanpackage_t_zi				equ		28
spanpackage_t_size				equ		32 

; edge_t structure
; !!! if this is changed, it must be changed in r_shared.h too !!!
et_u			equ		0
et_u_step		equ		4
et_prev			equ		8
et_next			equ		12
et_surfs		equ		16
et_nextremove	equ		20
et_nearzi		equ		24
et_owner		equ		28
et_size			equ		32

; surf_t structure
; !!! if this is changed, it must be changed in r_shared.h too !!!
SURF_T_SHIFT	equ		6
st_next			equ		0
st_prev			equ		4
st_spans		equ		8
st_key			equ		12
st_last_u		equ		16
st_spanstate	equ		20
st_flags		equ		24
st_data			equ		28
st_entity		equ		32
st_nearzi		equ		36
st_insubmodel	equ		40
st_d_ziorigin	equ		44
st_d_zistepu	equ		48
st_d_zistepv	equ		52
st_pad			equ		56
st_size			equ		64

; clipplane_t structure
; !!! if this is changed, it must be changed in r_local.h too !!!
cp_normal		equ		0
cp_dist			equ		12
cp_next			equ		16
cp_leftedge		equ		20
cp_rightedge	equ		21
cp_reserved		equ		22
cp_size			equ		24

; medge_t structure
; !!! if this is changed, it must be changed in model.h too !!!
me_v				equ		0
me_cachededgeoffset	equ		4
me_size				equ		8

; mvertex_t structure
; !!! if this is changed, it must be changed in model.h too !!!
mv_position		equ		0
mv_size			equ		12

; refdef_t structure
; !!! if this is changed, it must be changed in render.h too !!!
rd_vrect					equ		0
rd_aliasvrect				equ		20
rd_vrectright				equ		40
rd_vrectbottom				equ		44
rd_aliasvrectright			equ		48
rd_aliasvrectbottom			equ		52
rd_vrectrightedge			equ		56
rd_fvrectx					equ		60
rd_fvrecty					equ		64
rd_fvrectx_adj				equ		68
rd_fvrecty_adj				equ		72
rd_vrect_x_adj_shift20		equ		76
rd_vrectright_adj_shift20	equ		80
rd_fvrectright_adj			equ		84
rd_fvrectbottom_adj			equ		88
rd_fvrectright				equ		92
rd_fvrectbottom				equ		96
rd_horizontalFieldOfView	equ		100
rd_xOrigin					equ		104
rd_yOrigin					equ		108
rd_vieworg					equ		112
rd_viewangles				equ		124
rd_ambientlight				equ		136
rd_size						equ		140

; mtriangle_t structure
; !!! if this is changed, it must be changed in model.h too !!!
mtri_facesfront		equ		0
mtri_vertindex		equ		4
mtri_size			equ		16	; !!! if this changes, array indexing in !!!
								; !!! d_polysa.s must be changed to match !!!
mtri_shift			equ		4

