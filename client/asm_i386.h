
#ifndef __ASM_I386__
#define __ASM_I386__

#ifdef ELF
#define C(label) label
#else
#define C(label) _##label
#endif

//
// !!! note that this file must match the corresponding C structures at all
// times !!!
//

// plane_t structure
// !!! if this is changed, it must be changed in model.h too !!!
// !!! if the size of this is changed, the array lookup in SV_HullPointContents
//     must be changed too !!!
#define pl_normal	0
#define pl_dist		12
#define pl_type		16
#define pl_signbits	17
#define pl_pad		18
#define pl_size		20

// hull_t structure
// !!! if this is changed, it must be changed in model.h too !!!
#define	hu_clipnodes		0
#define	hu_planes			4
#define	hu_firstclipnode	8
#define	hu_lastclipnode		12
#define	hu_clip_mins		16
#define	hu_clip_maxs		28
#define hu_size  			40

// dnode_t structure
// !!! if this is changed, it must be changed in bspfile.h too !!!
#define	nd_planenum		0
#define	nd_children		4
#define	nd_mins			8
#define	nd_maxs			20
#define	nd_firstface	32
#define	nd_numfaces		36
#define nd_size			40

// sfxcache_t structure
// !!! if this is changed, it much be changed in sound.h too !!!
#define sfxc_length		0
#define sfxc_loopstart	4
#define sfxc_speed		8
#define sfxc_width		12
#define sfxc_stereo		16
#define sfxc_data		20

// channel_t structure
// !!! if this is changed, it much be changed in sound.h too !!!
#define ch_sfx			0
#define ch_leftvol		4
#define ch_rightvol		8
#define ch_end			12
#define ch_pos			16
#define ch_looping		20
#define ch_entnum		24
#define ch_entchannel	28
#define ch_origin		32
#define ch_dist_mult	44
#define ch_master_vol	48
#define ch_size			52

// portable_samplepair_t structure
// !!! if this is changed, it much be changed in sound.h too !!!
#define psp_left		0
#define psp_right		4
#define psp_size		8

// !!! must be kept the same as in d_iface.h !!!
#define TRANSPARENT_COLOR	255

#endif

