cmake_minimum_required(VERSION 2.6)

project(quake2)

add_library(ref_gl SHARED
    ref_gl/gl_draw.c
    ref_gl/gl_image.c
    ref_gl/gl_light.c
    ref_gl/gl_mesh.c
    ref_gl/gl_model.c
    ref_gl/gl_rmain.c
    ref_gl/gl_rmisc.c
    ref_gl/gl_rsurf.c
    ref_gl/gl_warp.c
    win32/glw_imp.c
    win32/q_shwin.c
    win32/qgl_win.c
    game/q_shared.c)

add_library(game SHARED
    game/g_ai.c
    game/g_chase.c
    game/g_cmds.c
    game/g_combat.c
    game/g_func.c
    game/g_items.c
    game/g_main.c
    game/g_misc.c
    game/g_monster.c
    game/g_phys.c
    game/g_save.c
    game/g_spawn.c
    game/g_svcmds.c
    game/g_target.c
    game/g_trigger.c
    game/g_turret.c
    game/g_utils.c
    game/g_weapon.c
    game/m_actor.c
    game/m_berserk.c
    game/m_boss2.c
    game/m_boss31.c
    game/m_boss32.c
    game/m_boss3.c
    game/m_brain.c
    game/m_chick.c
    game/m_flash.c
    game/m_flipper.c
    game/m_float.c
    game/m_flyer.c
    game/m_gladiator.c
    game/m_gunner.c
    game/m_hover.c
    game/m_infantry.c
    game/m_insane.c
    game/m_medic.c
    game/m_move.c
    game/m_mutant.c
    game/m_parasite.c
    game/m_soldier.c
    game/m_supertank.c
    game/m_tank.c
    game/p_client.c
    game/p_hud.c
    game/p_trail.c
    game/p_view.c
    game/p_weapon.c
    game/q_shared.c
)

# WIN32 means WinMain()
add_executable(quake2 WIN32
    client/cl_view.c
    client/cl_pred.c
    client/cl_input.c
    client/cl_ents.c
    client/cl_scrn.c
    client/cl_parse.c
    client/cl_main.c
    client/cl_inv.c
    client/cl_fx.c
    client/cl_newfx.c
    client/cl_tent.c
    client/cl_cin.c
    client/console.c
    client/keys.c
    client/menu.c
    client/qmenu.c
    client/snd_mix.c
    client/snd_dma.c
    client/snd_mem.c
    
    server/sv_user.c
    server/sv_ents.c
    server/sv_send.c
    server/sv_world.c
    server/sv_main.c
    server/sv_game.c
    server/sv_ccmds.c
    server/sv_init.c

    qcommon/cmd.c
    qcommon/cmodel.c
    qcommon/common.c
    qcommon/crc.c
    qcommon/cvar.c
    qcommon/files.c
    qcommon/md4.c
    qcommon/net_chan.c
    qcommon/pmove.c

    game/m_flash.c
    game/q_shared.c

    win32/cd_win.c
    win32/net_wins.c
    win32/q_shwin.c
    win32/snd_win.c
    win32/vid_dll.c
    win32/vid_menu.c
    win32/sys_win.c
    win32/conproc.c
    win32/in_win.c
)

# Windows-only, required by timeGetTime
target_link_libraries(ref_gl winmm.lib)

# Windows-only, required by mciSendCommand, waveOutOpen and others
target_link_libraries(quake2 winmm.lib)

# Windows-only, required by Winsock-related stuff
target_link_libraries(quake2 ws2_32.lib)
