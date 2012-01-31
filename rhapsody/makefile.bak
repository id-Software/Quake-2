
CFLAGS = -O -g -DGAME_HARD_LINKED -DREF_HARD_LINKED
LDFLAGS = -sectcreate __ICON __header quake2.iconheader -segprot __ICON r r -sectcreate __ICON app quake2.tiff -framework AppKit -framework Foundation
EXE	= quake2
TARGETS	= $(EXE)

all: $(TARGETS)

#----------------------------------------------------------------------

SERVERFILES = sv_ccmds.o sv_ents.o sv_game.o sv_init.o sv_main.o sv_send.o sv_user.o sv_world.o

GAMEFILES = g_ai.o g_cmds.o g_combat.o g_func.o g_items.o g_main.o g_misc.o g_monster.o g_phys.o g_save.o g_spawn.o g_target.o g_trigger.o g_utils.o g_weapon.o g_turret.o m_actor.o m_berserk.o m_boss2.o m_boss3.o m_boss31.o m_boss32.o m_brain.o m_chick.o m_flipper.o m_float.o m_flyer.o m_gladiator.o m_gunner.o m_hover.o m_infantry.o m_insane.o m_medic.o m_move.o m_mutant.o m_parasite.o m_soldier.o m_supertank.o m_tank.o p_client.o p_hud.o p_trail.o p_view.o p_weapon.o

CLIENTFILES = cl_ents.o cl_fx.o cl_input.o cl_inv.o cl_main.o cl_parse.o cl_pred.o cl_scrn.o cl_cin.o cl_tent.o cl_view.o console.o keys.o menu.o qmenu.o snd_dma.o snd_mem.o snd_mix.o

# commonfiles are used by both client and server
COMMONFILES = m_flash.o cmd.o cmodel.o common.o cvar.o files.o md4.o net_chan.o net_udp.o pmove.o

REFGLFILES = gl_draw.o gl_light.o gl_mesh.o gl_model.o gl_rmain.o gl_rmisc.o gl_rsurf.o gl_warp.o gl_image.o

REFSOFTFILES = r_aclip.o r_alias.o r_bsp.o r_draw.o r_edge.o r_image.o r_light.o r_main.o r_misc.o r_model.o r_part.o r_polyse.o r_poly.o r_rast.o r_scan.o r_sprite.o r_surf.o

# sharedfiles are included in EVERY dll
SHAREDFILES = q_shared.o

IRIXFILES = cd_sgi.o glx_imp.o qgl_sgi.o sys_sgi.o vid_sgi.o in_sgi.o snddma_null.o

RHAPFILES = cd_null.o in_null.o snddma_null.o sys_rhap.o vid_null.o swimp_rhap.o

NULLFILES = cd_null.o in_null.o snddma_null.o sys_null.o vid_null.o swimp_null.o

#----------------------------------------------------------------------

FILES = $(SERVERFILES) $(GAMEFILES) $(COMMONFILES) $(CLIENTFILES) $(REFSOFTFILES) $(SHAREDFILES) $(RHAPFILES)

$(EXE) : $(FILES)
	cc -o $(EXE) $(FILES) $(LDFLAGS)

clean:
	rm -f $(EXE) $(FILES)

#----------------------------------------------------------------------

# gnumake pattern rules are so cool!

%.o : ../game/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../qcommon/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../client/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../server/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../ref_soft/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../ref_gl/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../null/%.c
	cc $(CFLAGS) -c -o $@ $?
%.o : ../rhapsody/%.m
	cc $(CFLAGS) -c -o $@ $?

