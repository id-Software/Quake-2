#
# Quake2 Makefile for Linux 2.0
#
# Nov '97 by Zoid <zoid@idsoftware.com>
#
# ELF only
#

VERSION=3.21
VERSION_FN=$(VERSION)$(GLIBC)
RPM_RELEASE=6

ifneq (,$(findstring libc6,$(shell if [ -e /lib/libc.so.6* ];then echo libc6;fi)))
GLIBC=-glibc
else
GLIBC=
endif

ifneq (,$(findstring alpha,$(shell uname -m)))
ARCH=axp
RPMARCH=alpha
else
ARCH=i386
RPMARCH=i386
endif
NOARCH=noarch

MOUNT_DIR=..
VWEP_DIR=/grog/Projects/Quake2/vwep
QUAKE2_DIR=/grog/Projects/Quake2Master

BUILD_DEBUG_DIR=debug$(ARCH)$(GLIBC)
BUILD_RELEASE_DIR=release$(ARCH)$(GLIBC)
CLIENT_DIR=$(MOUNT_DIR)/client
SERVER_DIR=$(MOUNT_DIR)/server
REF_SOFT_DIR=$(MOUNT_DIR)/ref_soft
REF_GL_DIR=$(MOUNT_DIR)/ref_gl
COMMON_DIR=$(MOUNT_DIR)/qcommon
LINUX_DIR=$(MOUNT_DIR)/linux
GAME_DIR=$(MOUNT_DIR)/game
NULL_DIR=$(MOUNT_DIR)/null
CTF_DIR=$(MOUNT_DIR)/ctf
XATRIX_DIR=$(MOUNT_DIR)/xatrix
ROGUE_DIR=$(MOUNT_DIR)/rogue

MESA_DIR=/usr/local/src/Mesa-2.6

EGCS=/usr/local/egcs-1.1.2/bin/gcc

CC=gcc
BASE_CFLAGS=-Dstricmp=strcasecmp

ifeq ($(ARCH),axp)
RELEASE_CFLAGS=$(BASE_CFLAGS) -O6 -ffast-math -funroll-loops \
	-fomit-frame-pointer -fexpensive-optimizations
else
RELEASE_CFLAGS=$(BASE_CFLAGS) -g -mpentiumpro -O6 -ffast-math -funroll-loops \
	-fomit-frame-pointer -fexpensive-optimizations
endif

DEBUG_CFLAGS=$(BASE_CFLAGS) -g
LDFLAGS=-ldl -lm
SVGALDFLAGS=-lvga -lm
XLDFLAGS=-L/usr/X11R6/lib -lX11 -lXext -lXxf86dga
XCFLAGS=

GLLDFLAGS=-L/usr/X11R6/lib -L/usr/local/lib -L$(MESA_DIR)/lib -lX11 -lXext -lvga -lm
GLXLDFLAGS=-L/usr/X11R6/lib -L/usr/local/lib -L$(MESA_DIR)/lib -lX11 -lXext -lXxf86dga -lXxf86vm -lm
GLCFLAGS=-I$(MESA_DIR)/include -I/usr/include/glide

SHLIBEXT=so

SHLIBCFLAGS=-fPIC
SHLIBLDFLAGS=-shared

DO_CC=$(CC) $(CFLAGS) -o $@ -c $<
DO_DEBUG_CC=$(CC) $(DEBUG_CFLAGS) -o $@ -c $<
DO_DED_CC=$(CC) $(CFLAGS) -DDEDICATED_ONLY -o $@ -c $<
DO_DED_DEBUG_CC=$(CC) $(DEBUG_CFLAGS) -DDEDICATED_ONLY -o $@ -c $<
DO_O_CC=$(CC) $(CFLAGS) -O -o $@ -c $<
DO_SHLIB_CC=$(CC) $(CFLAGS) $(SHLIBCFLAGS) -o $@ -c $<
DO_SHLIB_O_CC=$(CC) $(CFLAGS) -O $(SHLIBCFLAGS) -o $@ -c $<
DO_SHLIB_DEBUG_CC=$(CC) $(DEBUG_CFLAGS) $(SHLIBCFLAGS) -o $@ -c $<
DO_GL_SHLIB_CC=$(CC) $(CFLAGS) $(SHLIBCFLAGS) $(GLCFLAGS) -o $@ -c $<
DO_GL_SHLIB_O_CC=$(CC) $(CFLAGS) -O $(SHLIBCFLAGS) $(GLCFLAGS) -o $@ -c $<
DO_AS=$(CC) $(CFLAGS) -DELF -x assembler-with-cpp -o $@ -c $<
DO_SHLIB_AS=$(CC) $(CFLAGS) $(SHLIBCFLAGS) -DELF -x assembler-with-cpp -o $@ -c $<

#############################################################################
# SETUP AND BUILD
#############################################################################

ifeq ($(ARCH),axp)
TARGETS=$(BUILDDIR)/q2ded \
	$(BUILDDIR)/game$(ARCH).$(SHLIBEXT) \
	$(BUILDDIR)/ctf/game$(ARCH).$(SHLIBEXT) \
#	$(BUILDDIR)/xatrix/game$(ARCH).$(SHLIBEXT) \
#	$(BUILDDIR)/rogue/game$(ARCH).$(SHLIBEXT)
else
TARGETS=$(BUILDDIR)/quake2 \
	$(BUILDDIR)/game$(ARCH).$(SHLIBEXT) \
	$(BUILDDIR)/ref_soft.$(SHLIBEXT) \
	$(BUILDDIR)/ref_softx.$(SHLIBEXT) \
	$(BUILDDIR)/ref_gl.$(SHLIBEXT) \
	$(BUILDDIR)/ref_glx.$(SHLIBEXT) \
	$(BUILDDIR)/ctf/game$(ARCH).$(SHLIBEXT) \
#	$(BUILDDIR)/xatrix/game$(ARCH).$(SHLIBEXT) \
#	$(BUILDDIR)/rogue/game$(ARCH).$(SHLIBEXT)
endif

build_debug:
	@-mkdir $(BUILD_DEBUG_DIR) \
		$(BUILD_DEBUG_DIR)/client \
		$(BUILD_DEBUG_DIR)/ded \
		$(BUILD_DEBUG_DIR)/ref_soft \
		$(BUILD_DEBUG_DIR)/ref_gl \
		$(BUILD_DEBUG_DIR)/game \
		$(BUILD_DEBUG_DIR)/ctf \
#		$(BUILD_DEBUG_DIR)/xatrix \
#		$(BUILD_DEBUG_DIR)/rogue
	$(MAKE) targets BUILDDIR=$(BUILD_DEBUG_DIR) CFLAGS="$(DEBUG_CFLAGS)"

build_release:
	@-mkdir $(BUILD_RELEASE_DIR) \
		$(BUILD_RELEASE_DIR)/client \
		$(BUILD_RELEASE_DIR)/ded \
		$(BUILD_RELEASE_DIR)/ref_soft \
		$(BUILD_RELEASE_DIR)/ref_gl \
		$(BUILD_RELEASE_DIR)/game \
		$(BUILD_RELEASE_DIR)/ctf \
#		$(BUILD_RELEASE_DIR)/xatrix \
#		$(BUILD_RELEASE_DIR)/rogue
	$(MAKE) targets BUILDDIR=$(BUILD_RELEASE_DIR) CFLAGS="$(RELEASE_CFLAGS)"

all: build_debug build_release

targets: $(TARGETS)

#############################################################################
# CLIENT/SERVER
#############################################################################

QUAKE2_OBJS = \
	$(BUILDDIR)/client/cl_cin.o \
	$(BUILDDIR)/client/cl_ents.o \
	$(BUILDDIR)/client/cl_fx.o \
	$(BUILDDIR)/client/cl_input.o \
	$(BUILDDIR)/client/cl_inv.o \
	$(BUILDDIR)/client/cl_main.o \
	$(BUILDDIR)/client/cl_newfx.o \
	$(BUILDDIR)/client/cl_parse.o \
	$(BUILDDIR)/client/cl_pred.o \
	$(BUILDDIR)/client/cl_tent.o \
	$(BUILDDIR)/client/cl_scrn.o \
	$(BUILDDIR)/client/cl_view.o \
	$(BUILDDIR)/client/console.o \
	$(BUILDDIR)/client/keys.o \
	$(BUILDDIR)/client/menu.o \
	$(BUILDDIR)/client/snd_dma.o \
	$(BUILDDIR)/client/snd_mem.o \
	$(BUILDDIR)/client/snd_mix.o \
	$(BUILDDIR)/client/qmenu.o \
	$(BUILDDIR)/client/m_flash.o \
	\
	$(BUILDDIR)/client/cmd.o \
	$(BUILDDIR)/client/cmodel.o \
	$(BUILDDIR)/client/common.o \
	$(BUILDDIR)/client/crc.o \
	$(BUILDDIR)/client/cvar.o \
	$(BUILDDIR)/client/files.o \
	$(BUILDDIR)/client/md4.o \
	$(BUILDDIR)/client/net_chan.o \
	\
	$(BUILDDIR)/client/sv_ccmds.o \
	$(BUILDDIR)/client/sv_ents.o \
	$(BUILDDIR)/client/sv_game.o \
	$(BUILDDIR)/client/sv_init.o \
	$(BUILDDIR)/client/sv_main.o \
	$(BUILDDIR)/client/sv_send.o \
	$(BUILDDIR)/client/sv_user.o \
	$(BUILDDIR)/client/sv_world.o \
	\
	$(BUILDDIR)/client/cd_linux.o \
	$(BUILDDIR)/client/q_shlinux.o \
	$(BUILDDIR)/client/vid_menu.o \
	$(BUILDDIR)/client/vid_so.o \
	$(BUILDDIR)/client/snd_linux.o \
	$(BUILDDIR)/client/sys_linux.o \
	$(BUILDDIR)/client/glob.o \
	$(BUILDDIR)/client/net_udp.o \
	\
	$(BUILDDIR)/client/q_shared.o \
	$(BUILDDIR)/client/pmove.o

ifeq ($(ARCH),axp)
QUAKE2_AS_OBJS =  #blank
else
QUAKE2_AS_OBJS = \
	$(BUILDDIR)/client/snd_mixa.o
endif

$(BUILDDIR)/quake2 : $(QUAKE2_OBJS) $(QUAKE2_AS_OBJS)
	$(CC) $(CFLAGS) -o $@ $(QUAKE2_OBJS) $(QUAKE2_AS_OBJS) $(LDFLAGS)

$(BUILDDIR)/client/cl_cin.o :     $(CLIENT_DIR)/cl_cin.c
	$(DO_CC)

$(BUILDDIR)/client/cl_ents.o :    $(CLIENT_DIR)/cl_ents.c
	$(DO_CC)

$(BUILDDIR)/client/cl_fx.o :      $(CLIENT_DIR)/cl_fx.c
	$(DO_CC)

$(BUILDDIR)/client/cl_input.o :   $(CLIENT_DIR)/cl_input.c
	$(DO_CC)

$(BUILDDIR)/client/cl_inv.o :     $(CLIENT_DIR)/cl_inv.c
	$(DO_CC)

$(BUILDDIR)/client/cl_main.o :    $(CLIENT_DIR)/cl_main.c
	$(DO_CC)

$(BUILDDIR)/client/cl_newfx.o :    $(CLIENT_DIR)/cl_newfx.c
	$(DO_CC)

$(BUILDDIR)/client/cl_parse.o :   $(CLIENT_DIR)/cl_parse.c
	$(DO_CC)

$(BUILDDIR)/client/cl_pred.o :    $(CLIENT_DIR)/cl_pred.c
	$(DO_CC)

$(BUILDDIR)/client/cl_tent.o :    $(CLIENT_DIR)/cl_tent.c
	$(DO_CC)

$(BUILDDIR)/client/cl_scrn.o :    $(CLIENT_DIR)/cl_scrn.c
	$(DO_CC)

$(BUILDDIR)/client/cl_view.o :    $(CLIENT_DIR)/cl_view.c
	$(DO_CC)

$(BUILDDIR)/client/console.o :    $(CLIENT_DIR)/console.c
	$(DO_CC)

$(BUILDDIR)/client/keys.o :       $(CLIENT_DIR)/keys.c
	$(DO_CC)

$(BUILDDIR)/client/menu.o :       $(CLIENT_DIR)/menu.c
	$(DO_CC)

$(BUILDDIR)/client/snd_dma.o :    $(CLIENT_DIR)/snd_dma.c
	$(DO_CC)

$(BUILDDIR)/client/snd_mem.o :    $(CLIENT_DIR)/snd_mem.c
	$(DO_CC)

$(BUILDDIR)/client/snd_mix.o :    $(CLIENT_DIR)/snd_mix.c
	$(DO_CC)

$(BUILDDIR)/client/qmenu.o :      $(CLIENT_DIR)/qmenu.c
	$(DO_CC)

$(BUILDDIR)/client/m_flash.o :    $(GAME_DIR)/m_flash.c
	$(DO_CC)

$(BUILDDIR)/client/cmd.o :        $(COMMON_DIR)/cmd.c
	$(DO_CC)

$(BUILDDIR)/client/cmodel.o :     $(COMMON_DIR)/cmodel.c
	$(DO_CC)

$(BUILDDIR)/client/common.o :     $(COMMON_DIR)/common.c
	$(DO_CC)

$(BUILDDIR)/client/crc.o :        $(COMMON_DIR)/crc.c
	$(DO_CC)

$(BUILDDIR)/client/cvar.o :       $(COMMON_DIR)/cvar.c
	$(DO_CC)

$(BUILDDIR)/client/files.o :      $(COMMON_DIR)/files.c
	$(DO_CC)

$(BUILDDIR)/client/md4.o :        $(COMMON_DIR)/md4.c
	$(DO_CC)

$(BUILDDIR)/client/net_chan.o :   $(COMMON_DIR)/net_chan.c
	$(DO_CC)

$(BUILDDIR)/client/q_shared.o :   $(GAME_DIR)/q_shared.c
	$(DO_DEBUG_CC)

$(BUILDDIR)/client/pmove.o :      $(COMMON_DIR)/pmove.c
	$(DO_CC)

$(BUILDDIR)/client/sv_ccmds.o :   $(SERVER_DIR)/sv_ccmds.c
	$(DO_CC)

$(BUILDDIR)/client/sv_ents.o :    $(SERVER_DIR)/sv_ents.c
	$(DO_CC)

$(BUILDDIR)/client/sv_game.o :    $(SERVER_DIR)/sv_game.c
	$(DO_CC)

$(BUILDDIR)/client/sv_init.o :    $(SERVER_DIR)/sv_init.c
	$(DO_CC)

$(BUILDDIR)/client/sv_main.o :    $(SERVER_DIR)/sv_main.c
	$(DO_CC)

$(BUILDDIR)/client/sv_send.o :    $(SERVER_DIR)/sv_send.c
	$(DO_CC)

$(BUILDDIR)/client/sv_user.o :    $(SERVER_DIR)/sv_user.c
	$(DO_CC)

$(BUILDDIR)/client/sv_world.o :   $(SERVER_DIR)/sv_world.c
	$(DO_CC)

$(BUILDDIR)/client/cd_linux.o :   $(LINUX_DIR)/cd_linux.c
	$(DO_CC)

$(BUILDDIR)/client/q_shlinux.o :  $(LINUX_DIR)/q_shlinux.c
	$(DO_O_CC)

$(BUILDDIR)/client/vid_menu.o :   $(LINUX_DIR)/vid_menu.c
	$(DO_CC)

$(BUILDDIR)/client/vid_so.o :     $(LINUX_DIR)/vid_so.c
	$(DO_CC)

$(BUILDDIR)/client/snd_linux.o :  $(LINUX_DIR)/snd_linux.c
	$(DO_CC)

$(BUILDDIR)/client/snd_mixa.o :   $(LINUX_DIR)/snd_mixa.s
	$(DO_AS)

$(BUILDDIR)/client/sys_linux.o :  $(LINUX_DIR)/sys_linux.c
	$(DO_CC)

$(BUILDDIR)/client/glob.o :       $(LINUX_DIR)/glob.c
	$(DO_CC)

$(BUILDDIR)/client/net_udp.o :    $(LINUX_DIR)/net_udp.c
	$(DO_CC)

#############################################################################
# DEDICATED SERVER
#############################################################################

Q2DED_OBJS = \
	\
	$(BUILDDIR)/ded/cmd.o \
	$(BUILDDIR)/ded/cmodel.o \
	$(BUILDDIR)/ded/common.o \
	$(BUILDDIR)/ded/crc.o \
	$(BUILDDIR)/ded/cvar.o \
	$(BUILDDIR)/ded/files.o \
	$(BUILDDIR)/ded/md4.o \
	$(BUILDDIR)/ded/net_chan.o \
	\
	$(BUILDDIR)/ded/sv_ccmds.o \
	$(BUILDDIR)/ded/sv_ents.o \
	$(BUILDDIR)/ded/sv_game.o \
	$(BUILDDIR)/ded/sv_init.o \
	$(BUILDDIR)/ded/sv_main.o \
	$(BUILDDIR)/ded/sv_send.o \
	$(BUILDDIR)/ded/sv_user.o \
	$(BUILDDIR)/ded/sv_world.o \
	\
	$(BUILDDIR)/ded/q_shlinux.o \
	$(BUILDDIR)/ded/sys_linux.o \
	$(BUILDDIR)/ded/glob.o \
	$(BUILDDIR)/ded/net_udp.o \
	\
	$(BUILDDIR)/ded/q_shared.o \
	$(BUILDDIR)/ded/pmove.o \
	\
	$(BUILDDIR)/ded/cl_null.o \
	$(BUILDDIR)/ded/cd_null.o

$(BUILDDIR)/q2ded : $(Q2DED_OBJS)
	$(CC) $(CFLAGS) -o $@ $(Q2DED_OBJS) $(LDFLAGS)

$(BUILDDIR)/ded/cmd.o :        $(COMMON_DIR)/cmd.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/cmodel.o :     $(COMMON_DIR)/cmodel.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/common.o :     $(COMMON_DIR)/common.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/crc.o :        $(COMMON_DIR)/crc.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/cvar.o :       $(COMMON_DIR)/cvar.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/files.o :      $(COMMON_DIR)/files.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/md4.o :        $(COMMON_DIR)/md4.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/net_chan.o :   $(COMMON_DIR)/net_chan.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/q_shared.o :   $(GAME_DIR)/q_shared.c
	$(DO_DED_DEBUG_CC)

$(BUILDDIR)/ded/pmove.o :      $(COMMON_DIR)/pmove.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_ccmds.o :   $(SERVER_DIR)/sv_ccmds.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_ents.o :    $(SERVER_DIR)/sv_ents.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_game.o :    $(SERVER_DIR)/sv_game.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_init.o :    $(SERVER_DIR)/sv_init.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_main.o :    $(SERVER_DIR)/sv_main.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_send.o :    $(SERVER_DIR)/sv_send.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_user.o :    $(SERVER_DIR)/sv_user.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sv_world.o :   $(SERVER_DIR)/sv_world.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/q_shlinux.o :  $(LINUX_DIR)/q_shlinux.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/sys_linux.o :  $(LINUX_DIR)/sys_linux.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/glob.o :       $(LINUX_DIR)/glob.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/net_udp.o :    $(LINUX_DIR)/net_udp.c
	$(DO_DED_CC)

$(BUILDDIR)/ded/cd_null.o     : $(NULL_DIR)/cd_null.c    
	$(DO_DED_CC)

$(BUILDDIR)/ded/cl_null.o     : $(NULL_DIR)/cl_null.c    
	$(DO_DED_CC)

#############################################################################
# GAME
#############################################################################

GAME_OBJS = \
	$(BUILDDIR)/game/q_shared.o \
	$(BUILDDIR)/game/g_ai.o \
	$(BUILDDIR)/game/p_client.o \
	$(BUILDDIR)/game/g_cmds.o \
	$(BUILDDIR)/game/g_svcmds.o \
	$(BUILDDIR)/game/g_chase.o \
	$(BUILDDIR)/game/g_combat.o \
	$(BUILDDIR)/game/g_func.o \
	$(BUILDDIR)/game/g_items.o \
	$(BUILDDIR)/game/g_main.o \
	$(BUILDDIR)/game/g_misc.o \
	$(BUILDDIR)/game/g_monster.o \
	$(BUILDDIR)/game/g_phys.o \
	$(BUILDDIR)/game/g_save.o \
	$(BUILDDIR)/game/g_spawn.o \
	$(BUILDDIR)/game/g_target.o \
	$(BUILDDIR)/game/g_trigger.o \
	$(BUILDDIR)/game/g_turret.o \
	$(BUILDDIR)/game/g_utils.o \
	$(BUILDDIR)/game/g_weapon.o \
	$(BUILDDIR)/game/m_actor.o \
	$(BUILDDIR)/game/m_berserk.o \
	$(BUILDDIR)/game/m_boss2.o \
	$(BUILDDIR)/game/m_boss3.o \
	$(BUILDDIR)/game/m_boss31.o \
	$(BUILDDIR)/game/m_boss32.o \
	$(BUILDDIR)/game/m_brain.o \
	$(BUILDDIR)/game/m_chick.o \
	$(BUILDDIR)/game/m_flipper.o \
	$(BUILDDIR)/game/m_float.o \
	$(BUILDDIR)/game/m_flyer.o \
	$(BUILDDIR)/game/m_gladiator.o \
	$(BUILDDIR)/game/m_gunner.o \
	$(BUILDDIR)/game/m_hover.o \
	$(BUILDDIR)/game/m_infantry.o \
	$(BUILDDIR)/game/m_insane.o \
	$(BUILDDIR)/game/m_medic.o \
	$(BUILDDIR)/game/m_move.o \
	$(BUILDDIR)/game/m_mutant.o \
	$(BUILDDIR)/game/m_parasite.o \
	$(BUILDDIR)/game/m_soldier.o \
	$(BUILDDIR)/game/m_supertank.o \
	$(BUILDDIR)/game/m_tank.o \
	$(BUILDDIR)/game/p_hud.o \
	$(BUILDDIR)/game/p_trail.o \
	$(BUILDDIR)/game/p_view.o \
	$(BUILDDIR)/game/p_weapon.o \
	$(BUILDDIR)/game/m_flash.o

$(BUILDDIR)/game$(ARCH).$(SHLIBEXT) : $(GAME_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(GAME_OBJS)

$(BUILDDIR)/game/g_ai.o :        $(GAME_DIR)/g_ai.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/p_client.o :    $(GAME_DIR)/p_client.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_cmds.o :      $(GAME_DIR)/g_cmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_svcmds.o :    $(GAME_DIR)/g_svcmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_chase.o :    $(GAME_DIR)/g_chase.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_combat.o :    $(GAME_DIR)/g_combat.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_func.o :      $(GAME_DIR)/g_func.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_items.o :     $(GAME_DIR)/g_items.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_main.o :      $(GAME_DIR)/g_main.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_misc.o :      $(GAME_DIR)/g_misc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_monster.o :   $(GAME_DIR)/g_monster.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_phys.o :      $(GAME_DIR)/g_phys.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_save.o :      $(GAME_DIR)/g_save.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_spawn.o :     $(GAME_DIR)/g_spawn.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_target.o :    $(GAME_DIR)/g_target.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_trigger.o :   $(GAME_DIR)/g_trigger.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_turret.o :    $(GAME_DIR)/g_turret.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_utils.o :     $(GAME_DIR)/g_utils.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/g_weapon.o :    $(GAME_DIR)/g_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_actor.o :     $(GAME_DIR)/m_actor.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_berserk.o :   $(GAME_DIR)/m_berserk.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_boss2.o :     $(GAME_DIR)/m_boss2.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_boss3.o :     $(GAME_DIR)/m_boss3.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_boss31.o :     $(GAME_DIR)/m_boss31.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_boss32.o :     $(GAME_DIR)/m_boss32.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_brain.o :     $(GAME_DIR)/m_brain.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_chick.o :     $(GAME_DIR)/m_chick.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_flipper.o :   $(GAME_DIR)/m_flipper.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_float.o :     $(GAME_DIR)/m_float.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_flyer.o :     $(GAME_DIR)/m_flyer.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_gladiator.o : $(GAME_DIR)/m_gladiator.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_gunner.o :    $(GAME_DIR)/m_gunner.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_hover.o :     $(GAME_DIR)/m_hover.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_infantry.o :  $(GAME_DIR)/m_infantry.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_insane.o :    $(GAME_DIR)/m_insane.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_medic.o :     $(GAME_DIR)/m_medic.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_move.o :      $(GAME_DIR)/m_move.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_mutant.o :    $(GAME_DIR)/m_mutant.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_parasite.o :  $(GAME_DIR)/m_parasite.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_soldier.o :   $(GAME_DIR)/m_soldier.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_supertank.o : $(GAME_DIR)/m_supertank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/m_tank.o :      $(GAME_DIR)/m_tank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/p_hud.o :       $(GAME_DIR)/p_hud.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/p_trail.o :     $(GAME_DIR)/p_trail.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/p_view.o :      $(GAME_DIR)/p_view.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/p_weapon.o :    $(GAME_DIR)/p_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/game/q_shared.o :    $(GAME_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)

$(BUILDDIR)/game/m_flash.o :     $(GAME_DIR)/m_flash.c
	$(DO_SHLIB_CC)

#############################################################################
# CTF
#############################################################################

CTF_OBJS = \
	$(BUILDDIR)/ctf/g_ai.o \
	$(BUILDDIR)/ctf/g_chase.o \
	$(BUILDDIR)/ctf/g_cmds.o \
	$(BUILDDIR)/ctf/g_combat.o \
	$(BUILDDIR)/ctf/g_ctf.o \
	$(BUILDDIR)/ctf/g_func.o \
	$(BUILDDIR)/ctf/g_items.o \
	$(BUILDDIR)/ctf/g_main.o \
	$(BUILDDIR)/ctf/g_misc.o \
	$(BUILDDIR)/ctf/g_monster.o \
	$(BUILDDIR)/ctf/g_phys.o \
	$(BUILDDIR)/ctf/g_save.o \
	$(BUILDDIR)/ctf/g_spawn.o \
	$(BUILDDIR)/ctf/g_svcmds.o \
	$(BUILDDIR)/ctf/g_target.o \
	$(BUILDDIR)/ctf/g_trigger.o \
	$(BUILDDIR)/ctf/g_utils.o \
	$(BUILDDIR)/ctf/g_weapon.o \
	$(BUILDDIR)/ctf/m_move.o \
	$(BUILDDIR)/ctf/p_client.o \
	$(BUILDDIR)/ctf/p_hud.o \
	$(BUILDDIR)/ctf/p_menu.o \
	$(BUILDDIR)/ctf/p_trail.o \
	$(BUILDDIR)/ctf/p_view.o \
	$(BUILDDIR)/ctf/p_weapon.o \
	$(BUILDDIR)/ctf/q_shared.o

$(BUILDDIR)/ctf/game$(ARCH).$(SHLIBEXT) : $(CTF_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(CTF_OBJS)

$(BUILDDIR)/ctf/g_ai.o :       $(CTF_DIR)/g_ai.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_chase.o :    $(CTF_DIR)/g_chase.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_cmds.o :     $(CTF_DIR)/g_cmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_combat.o :   $(CTF_DIR)/g_combat.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_ctf.o :      $(CTF_DIR)/g_ctf.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_func.o :     $(CTF_DIR)/g_func.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_items.o :    $(CTF_DIR)/g_items.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_main.o :     $(CTF_DIR)/g_main.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_misc.o :     $(CTF_DIR)/g_misc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_monster.o :  $(CTF_DIR)/g_monster.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_phys.o :     $(CTF_DIR)/g_phys.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_save.o :     $(CTF_DIR)/g_save.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_spawn.o :    $(CTF_DIR)/g_spawn.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_svcmds.o :   $(CTF_DIR)/g_svcmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_target.o :   $(CTF_DIR)/g_target.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_trigger.o :  $(CTF_DIR)/g_trigger.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_utils.o :    $(CTF_DIR)/g_utils.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/g_weapon.o :   $(CTF_DIR)/g_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/m_move.o :     $(CTF_DIR)/m_move.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_client.o :   $(CTF_DIR)/p_client.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_hud.o :      $(CTF_DIR)/p_hud.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_menu.o :     $(CTF_DIR)/p_menu.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_trail.o :    $(CTF_DIR)/p_trail.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_view.o :     $(CTF_DIR)/p_view.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/p_weapon.o :   $(CTF_DIR)/p_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ctf/q_shared.o :   $(CTF_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)

#############################################################################
# XATRIX
#############################################################################

XATRIX_OBJS = \
	$(BUILDDIR)/xatrix/g_ai.o \
	$(BUILDDIR)/xatrix/g_cmds.o \
	$(BUILDDIR)/xatrix/g_chase.o \
	$(BUILDDIR)/xatrix/g_combat.o \
	$(BUILDDIR)/xatrix/g_func.o \
	$(BUILDDIR)/xatrix/g_items.o \
	$(BUILDDIR)/xatrix/g_main.o \
	$(BUILDDIR)/xatrix/g_misc.o \
	$(BUILDDIR)/xatrix/g_monster.o \
	$(BUILDDIR)/xatrix/g_phys.o \
	$(BUILDDIR)/xatrix/g_save.o \
	$(BUILDDIR)/xatrix/g_spawn.o \
	$(BUILDDIR)/xatrix/g_svcmds.o \
	$(BUILDDIR)/xatrix/g_target.o \
	$(BUILDDIR)/xatrix/g_trigger.o \
	$(BUILDDIR)/xatrix/g_turret.o \
	$(BUILDDIR)/xatrix/g_utils.o \
	$(BUILDDIR)/xatrix/g_weapon.o \
	$(BUILDDIR)/xatrix/m_actor.o \
	$(BUILDDIR)/xatrix/m_berserk.o \
	$(BUILDDIR)/xatrix/m_boss2.o \
	$(BUILDDIR)/xatrix/m_boss3.o \
	$(BUILDDIR)/xatrix/m_boss31.o \
	$(BUILDDIR)/xatrix/m_boss32.o \
	$(BUILDDIR)/xatrix/m_boss5.o \
	$(BUILDDIR)/xatrix/m_brain.o \
	$(BUILDDIR)/xatrix/m_chick.o \
	$(BUILDDIR)/xatrix/m_fixbot.o \
	$(BUILDDIR)/xatrix/m_flash.o \
	$(BUILDDIR)/xatrix/m_flipper.o \
	$(BUILDDIR)/xatrix/m_float.o \
	$(BUILDDIR)/xatrix/m_flyer.o \
	$(BUILDDIR)/xatrix/m_gekk.o \
	$(BUILDDIR)/xatrix/m_gladb.o \
	$(BUILDDIR)/xatrix/m_gladiator.o \
	$(BUILDDIR)/xatrix/m_gunner.o \
	$(BUILDDIR)/xatrix/m_hover.o \
	$(BUILDDIR)/xatrix/m_infantry.o \
	$(BUILDDIR)/xatrix/m_insane.o \
	$(BUILDDIR)/xatrix/m_medic.o \
	$(BUILDDIR)/xatrix/m_move.o \
	$(BUILDDIR)/xatrix/m_mutant.o \
	$(BUILDDIR)/xatrix/m_parasite.o \
	$(BUILDDIR)/xatrix/m_soldier.o \
	$(BUILDDIR)/xatrix/m_supertank.o \
	$(BUILDDIR)/xatrix/m_tank.o \
	$(BUILDDIR)/xatrix/p_client.o \
	$(BUILDDIR)/xatrix/p_hud.o \
	$(BUILDDIR)/xatrix/p_trail.o \
	$(BUILDDIR)/xatrix/p_view.o \
	$(BUILDDIR)/xatrix/p_weapon.o \
	$(BUILDDIR)/xatrix/q_shared.o

$(BUILDDIR)/xatrix/game$(ARCH).$(SHLIBEXT) : $(XATRIX_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(XATRIX_OBJS)

$(BUILDDIR)/xatrix/g_ai.o :        $(XATRIX_DIR)/g_ai.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_cmds.o :      $(XATRIX_DIR)/g_cmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_chase.o :    $(XATRIX_DIR)/g_chase.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_combat.o :    $(XATRIX_DIR)/g_combat.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_func.o :      $(XATRIX_DIR)/g_func.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_items.o :     $(XATRIX_DIR)/g_items.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_main.o :      $(XATRIX_DIR)/g_main.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_misc.o :      $(XATRIX_DIR)/g_misc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_monster.o :   $(XATRIX_DIR)/g_monster.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_phys.o :      $(XATRIX_DIR)/g_phys.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_save.o :      $(XATRIX_DIR)/g_save.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_spawn.o :     $(XATRIX_DIR)/g_spawn.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_svcmds.o :    $(XATRIX_DIR)/g_svcmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_target.o :    $(XATRIX_DIR)/g_target.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_trigger.o :   $(XATRIX_DIR)/g_trigger.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_turret.o :    $(XATRIX_DIR)/g_turret.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_utils.o :     $(XATRIX_DIR)/g_utils.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/g_weapon.o :    $(XATRIX_DIR)/g_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_actor.o :     $(XATRIX_DIR)/m_actor.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_berserk.o :   $(XATRIX_DIR)/m_berserk.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_boss2.o :     $(XATRIX_DIR)/m_boss2.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_boss3.o :     $(XATRIX_DIR)/m_boss3.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_boss31.o :    $(XATRIX_DIR)/m_boss31.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_boss32.o :    $(XATRIX_DIR)/m_boss32.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_boss5.o :     $(XATRIX_DIR)/m_boss5.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_brain.o :     $(XATRIX_DIR)/m_brain.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_chick.o :     $(XATRIX_DIR)/m_chick.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_fixbot.o :    $(XATRIX_DIR)/m_fixbot.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_flash.o :     $(XATRIX_DIR)/m_flash.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_flipper.o :   $(XATRIX_DIR)/m_flipper.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_float.o :     $(XATRIX_DIR)/m_float.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_flyer.o :     $(XATRIX_DIR)/m_flyer.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_gekk.o :      $(XATRIX_DIR)/m_gekk.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_gladb.o :     $(XATRIX_DIR)/m_gladb.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_gladiator.o : $(XATRIX_DIR)/m_gladiator.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_gunner.o :    $(XATRIX_DIR)/m_gunner.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_hover.o :     $(XATRIX_DIR)/m_hover.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_infantry.o :  $(XATRIX_DIR)/m_infantry.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_insane.o :    $(XATRIX_DIR)/m_insane.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_medic.o :     $(XATRIX_DIR)/m_medic.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_move.o :      $(XATRIX_DIR)/m_move.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_mutant.o :    $(XATRIX_DIR)/m_mutant.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_parasite.o :  $(XATRIX_DIR)/m_parasite.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_soldier.o :   $(XATRIX_DIR)/m_soldier.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_supertank.o : $(XATRIX_DIR)/m_supertank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/m_tank.o :      $(XATRIX_DIR)/m_tank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/p_client.o :    $(XATRIX_DIR)/p_client.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/p_hud.o :       $(XATRIX_DIR)/p_hud.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/p_trail.o :     $(XATRIX_DIR)/p_trail.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/p_view.o :      $(XATRIX_DIR)/p_view.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/p_weapon.o :    $(XATRIX_DIR)/p_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/xatrix/q_shared.o :    $(XATRIX_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)

#############################################################################
# ROGUE
#############################################################################

ROGUE_OBJS = \
	$(BUILDDIR)/rogue/dm_ball.o \
	$(BUILDDIR)/rogue/dm_tag.o \
	$(BUILDDIR)/rogue/g_ai.o \
	$(BUILDDIR)/rogue/g_chase.o \
	$(BUILDDIR)/rogue/g_cmds.o \
	$(BUILDDIR)/rogue/g_combat.o \
	$(BUILDDIR)/rogue/g_func.o \
	$(BUILDDIR)/rogue/g_items.o \
	$(BUILDDIR)/rogue/g_main.o \
	$(BUILDDIR)/rogue/g_misc.o \
	$(BUILDDIR)/rogue/g_monster.o \
	$(BUILDDIR)/rogue/g_newai.o \
	$(BUILDDIR)/rogue/g_newdm.o \
	$(BUILDDIR)/rogue/g_newfnc.o \
	$(BUILDDIR)/rogue/g_newtarg.o \
	$(BUILDDIR)/rogue/g_newtrig.o \
	$(BUILDDIR)/rogue/g_newweap.o \
	$(BUILDDIR)/rogue/g_phys.o \
	$(BUILDDIR)/rogue/g_save.o \
	$(BUILDDIR)/rogue/g_spawn.o \
	$(BUILDDIR)/rogue/g_sphere.o \
	$(BUILDDIR)/rogue/g_svcmds.o \
	$(BUILDDIR)/rogue/g_target.o \
	$(BUILDDIR)/rogue/g_trigger.o \
	$(BUILDDIR)/rogue/g_turret.o \
	$(BUILDDIR)/rogue/g_utils.o \
	$(BUILDDIR)/rogue/g_weapon.o \
	$(BUILDDIR)/rogue/m_actor.o \
	$(BUILDDIR)/rogue/m_berserk.o \
	$(BUILDDIR)/rogue/m_boss2.o \
	$(BUILDDIR)/rogue/m_boss3.o \
	$(BUILDDIR)/rogue/m_boss31.o \
	$(BUILDDIR)/rogue/m_boss32.o \
	$(BUILDDIR)/rogue/m_brain.o \
	$(BUILDDIR)/rogue/m_carrier.o \
	$(BUILDDIR)/rogue/m_chick.o \
	$(BUILDDIR)/rogue/m_flash.o \
	$(BUILDDIR)/rogue/m_flipper.o \
	$(BUILDDIR)/rogue/m_float.o \
	$(BUILDDIR)/rogue/m_flyer.o \
	$(BUILDDIR)/rogue/m_gladiator.o \
	$(BUILDDIR)/rogue/m_gunner.o \
	$(BUILDDIR)/rogue/m_hover.o \
	$(BUILDDIR)/rogue/m_infantry.o \
	$(BUILDDIR)/rogue/m_insane.o \
	$(BUILDDIR)/rogue/m_medic.o \
	$(BUILDDIR)/rogue/m_move.o \
	$(BUILDDIR)/rogue/m_mutant.o \
	$(BUILDDIR)/rogue/m_parasite.o \
	$(BUILDDIR)/rogue/m_soldier.o \
	$(BUILDDIR)/rogue/m_stalker.o \
	$(BUILDDIR)/rogue/m_supertank.o \
	$(BUILDDIR)/rogue/m_tank.o \
	$(BUILDDIR)/rogue/m_turret.o \
	$(BUILDDIR)/rogue/m_widow.o \
	$(BUILDDIR)/rogue/m_widow2.o \
	$(BUILDDIR)/rogue/p_client.o \
	$(BUILDDIR)/rogue/p_hud.o \
	$(BUILDDIR)/rogue/p_trail.o \
	$(BUILDDIR)/rogue/p_view.o \
	$(BUILDDIR)/rogue/p_weapon.o \
	$(BUILDDIR)/rogue/q_shared.o

$(BUILDDIR)/rogue/game$(ARCH).$(SHLIBEXT) : $(ROGUE_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(ROGUE_OBJS)

$(BUILDDIR)/rogue/dm_ball.o :      $(ROGUE_DIR)/dm_ball.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/dm_tag.o :       $(ROGUE_DIR)/dm_tag.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_ai.o :         $(ROGUE_DIR)/g_ai.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_chase.o :      $(ROGUE_DIR)/g_chase.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_cmds.o :       $(ROGUE_DIR)/g_cmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_combat.o :     $(ROGUE_DIR)/g_combat.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_func.o :       $(ROGUE_DIR)/g_func.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_items.o :      $(ROGUE_DIR)/g_items.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_main.o :       $(ROGUE_DIR)/g_main.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_misc.o :       $(ROGUE_DIR)/g_misc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_monster.o :    $(ROGUE_DIR)/g_monster.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newai.o :      $(ROGUE_DIR)/g_newai.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newdm.o :      $(ROGUE_DIR)/g_newdm.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newfnc.o :     $(ROGUE_DIR)/g_newfnc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newtarg.o :    $(ROGUE_DIR)/g_newtarg.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newtrig.o :    $(ROGUE_DIR)/g_newtrig.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_newweap.o :    $(ROGUE_DIR)/g_newweap.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_phys.o :       $(ROGUE_DIR)/g_phys.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_save.o :       $(ROGUE_DIR)/g_save.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_spawn.o :      $(ROGUE_DIR)/g_spawn.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_sphere.o :     $(ROGUE_DIR)/g_sphere.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_svcmds.o :     $(ROGUE_DIR)/g_svcmds.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_target.o :     $(ROGUE_DIR)/g_target.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_trigger.o :    $(ROGUE_DIR)/g_trigger.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_turret.o :     $(ROGUE_DIR)/g_turret.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_utils.o :      $(ROGUE_DIR)/g_utils.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/g_weapon.o :     $(ROGUE_DIR)/g_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_actor.o :      $(ROGUE_DIR)/m_actor.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_berserk.o :    $(ROGUE_DIR)/m_berserk.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_boss2.o :      $(ROGUE_DIR)/m_boss2.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_boss3.o :      $(ROGUE_DIR)/m_boss3.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_boss31.o :     $(ROGUE_DIR)/m_boss31.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_boss32.o :     $(ROGUE_DIR)/m_boss32.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_brain.o :      $(ROGUE_DIR)/m_brain.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_carrier.o :    $(ROGUE_DIR)/m_carrier.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_chick.o :      $(ROGUE_DIR)/m_chick.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_flash.o :      $(ROGUE_DIR)/m_flash.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_flipper.o :    $(ROGUE_DIR)/m_flipper.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_float.o :      $(ROGUE_DIR)/m_float.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_flyer.o :      $(ROGUE_DIR)/m_flyer.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_gladiator.o :  $(ROGUE_DIR)/m_gladiator.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_gunner.o :     $(ROGUE_DIR)/m_gunner.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_hover.o :      $(ROGUE_DIR)/m_hover.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_infantry.o :   $(ROGUE_DIR)/m_infantry.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_insane.o :     $(ROGUE_DIR)/m_insane.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_medic.o :      $(ROGUE_DIR)/m_medic.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_move.o :       $(ROGUE_DIR)/m_move.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_mutant.o :     $(ROGUE_DIR)/m_mutant.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_parasite.o :   $(ROGUE_DIR)/m_parasite.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_soldier.o :    $(ROGUE_DIR)/m_soldier.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_stalker.o :    $(ROGUE_DIR)/m_stalker.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_supertank.o :  $(ROGUE_DIR)/m_supertank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_tank.o :       $(ROGUE_DIR)/m_tank.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_turret.o :     $(ROGUE_DIR)/m_turret.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_widow.o :      $(ROGUE_DIR)/m_widow.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/m_widow2.o :     $(ROGUE_DIR)/m_widow2.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/p_client.o :     $(ROGUE_DIR)/p_client.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/p_hud.o :        $(ROGUE_DIR)/p_hud.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/p_trail.o :      $(ROGUE_DIR)/p_trail.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/p_view.o :       $(ROGUE_DIR)/p_view.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/p_weapon.o :     $(ROGUE_DIR)/p_weapon.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/rogue/q_shared.o :     $(ROGUE_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)




#############################################################################
# REF_SOFT
#############################################################################

REF_SOFT_OBJS = \
	$(BUILDDIR)/ref_soft/r_aclip.o \
	$(BUILDDIR)/ref_soft/r_alias.o \
	$(BUILDDIR)/ref_soft/r_bsp.o \
	$(BUILDDIR)/ref_soft/r_draw.o \
	$(BUILDDIR)/ref_soft/r_edge.o \
	$(BUILDDIR)/ref_soft/r_image.o \
	$(BUILDDIR)/ref_soft/r_light.o \
	$(BUILDDIR)/ref_soft/r_main.o \
	$(BUILDDIR)/ref_soft/r_misc.o \
	$(BUILDDIR)/ref_soft/r_model.o \
	$(BUILDDIR)/ref_soft/r_part.o \
	$(BUILDDIR)/ref_soft/r_poly.o \
	$(BUILDDIR)/ref_soft/r_polyse.o \
	$(BUILDDIR)/ref_soft/r_rast.o \
	$(BUILDDIR)/ref_soft/r_scan.o \
	$(BUILDDIR)/ref_soft/r_sprite.o \
	$(BUILDDIR)/ref_soft/r_surf.o \
	\
	$(BUILDDIR)/ref_soft/r_aclipa.o \
	$(BUILDDIR)/ref_soft/r_draw16.o \
	$(BUILDDIR)/ref_soft/r_drawa.o \
	$(BUILDDIR)/ref_soft/r_edgea.o \
	$(BUILDDIR)/ref_soft/r_scana.o \
	$(BUILDDIR)/ref_soft/r_spr8.o \
	$(BUILDDIR)/ref_soft/r_surf8.o \
	$(BUILDDIR)/ref_soft/math.o \
	$(BUILDDIR)/ref_soft/d_polysa.o \
	$(BUILDDIR)/ref_soft/r_varsa.o \
	$(BUILDDIR)/ref_soft/sys_dosa.o \
	\
	$(BUILDDIR)/ref_soft/q_shared.o \
	$(BUILDDIR)/ref_soft/q_shlinux.o \
	$(BUILDDIR)/ref_soft/glob.o

REF_SOFT_SVGA_OBJS = \
	$(BUILDDIR)/ref_soft/rw_svgalib.o \
	$(BUILDDIR)/ref_soft/d_copy.o \
	$(BUILDDIR)/ref_soft/rw_in_svgalib.o

REF_SOFT_X11_OBJS = \
	$(BUILDDIR)/ref_soft/rw_x11.o

$(BUILDDIR)/ref_soft.$(SHLIBEXT) : $(REF_SOFT_OBJS) $(REF_SOFT_SVGA_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -Xlinker -Map -Xlinker map.out -o $@ $(REF_SOFT_OBJS) \
		$(REF_SOFT_SVGA_OBJS) $(SVGALDFLAGS)

$(BUILDDIR)/ref_softx.$(SHLIBEXT) : $(REF_SOFT_OBJS) $(REF_SOFT_X11_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(REF_SOFT_OBJS) \
		$(REF_SOFT_X11_OBJS) $(XLDFLAGS)

$(BUILDDIR)/ref_soft/r_aclip.o :      $(REF_SOFT_DIR)/r_aclip.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_alias.o :      $(REF_SOFT_DIR)/r_alias.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_bsp.o :        $(REF_SOFT_DIR)/r_bsp.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_draw.o :       $(REF_SOFT_DIR)/r_draw.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_edge.o :       $(REF_SOFT_DIR)/r_edge.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_image.o :      $(REF_SOFT_DIR)/r_image.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_light.o :      $(REF_SOFT_DIR)/r_light.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_main.o :       $(REF_SOFT_DIR)/r_main.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_misc.o :       $(REF_SOFT_DIR)/r_misc.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_model.o :      $(REF_SOFT_DIR)/r_model.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_part.o :       $(REF_SOFT_DIR)/r_part.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_poly.o :       $(REF_SOFT_DIR)/r_poly.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_polyse.o :     $(REF_SOFT_DIR)/r_polyse.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_rast.o :       $(REF_SOFT_DIR)/r_rast.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_scan.o :       $(REF_SOFT_DIR)/r_scan.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_sprite.o :     $(REF_SOFT_DIR)/r_sprite.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_surf.o :       $(REF_SOFT_DIR)/r_surf.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/r_aclipa.o :     $(LINUX_DIR)/r_aclipa.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_draw16.o :     $(LINUX_DIR)/r_draw16.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_drawa.o :      $(LINUX_DIR)/r_drawa.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_edgea.o :      $(LINUX_DIR)/r_edgea.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_scana.o :      $(LINUX_DIR)/r_scana.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_spr8.o :       $(LINUX_DIR)/r_spr8.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_surf8.o :      $(LINUX_DIR)/r_surf8.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/math.o :         $(LINUX_DIR)/math.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/d_polysa.o :     $(LINUX_DIR)/d_polysa.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/r_varsa.o :      $(LINUX_DIR)/r_varsa.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/sys_dosa.o :     $(LINUX_DIR)/sys_dosa.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/q_shared.o :     $(GAME_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)

$(BUILDDIR)/ref_soft/q_shlinux.o :    $(LINUX_DIR)/q_shlinux.c
	$(DO_SHLIB_O_CC)

$(BUILDDIR)/ref_soft/glob.o :         $(LINUX_DIR)/glob.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/rw_svgalib.o :   $(LINUX_DIR)/rw_svgalib.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/d_copy.o :       $(LINUX_DIR)/d_copy.s
	$(DO_SHLIB_AS)

$(BUILDDIR)/ref_soft/rw_in_svgalib.o : $(LINUX_DIR)/rw_in_svgalib.c
	$(DO_SHLIB_CC)

$(BUILDDIR)/ref_soft/rw_x11.o :       $(LINUX_DIR)/rw_x11.c
	$(DO_SHLIB_CC)

#############################################################################
# REF_GL
#############################################################################

REF_GL_OBJS = \
	$(BUILDDIR)/ref_gl/gl_draw.o \
	$(BUILDDIR)/ref_gl/gl_image.o \
	$(BUILDDIR)/ref_gl/gl_light.o \
	$(BUILDDIR)/ref_gl/gl_mesh.o \
	$(BUILDDIR)/ref_gl/gl_model.o \
	$(BUILDDIR)/ref_gl/gl_rmain.o \
	$(BUILDDIR)/ref_gl/gl_rmisc.o \
	$(BUILDDIR)/ref_gl/gl_rsurf.o \
	$(BUILDDIR)/ref_gl/gl_warp.o \
	\
	$(BUILDDIR)/ref_gl/qgl_linux.o \
	$(BUILDDIR)/ref_gl/q_shared.o \
	$(BUILDDIR)/ref_gl/q_shlinux.o \
	$(BUILDDIR)/ref_gl/glob.o

# TTimo: taking out Mesa
REF_GL_FXMESA_OBJS = \
	$(BUILDDIR)/ref_gl/rw_in_svgalib.o

#REF_GL_FXMESA_OBJS = \
#	$(BUILDDIR)/ref_gl/gl_fxmesa.o \
#	$(BUILDDIR)/ref_gl/rw_in_svgalib.o

REF_GL_GLX_OBJS = \
	$(BUILDDIR)/ref_gl/gl_glx.o

$(BUILDDIR)/ref_gl.$(SHLIBEXT) : $(REF_GL_OBJS) $(REF_GL_FXMESA_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(REF_GL_OBJS) $(REF_GL_FXMESA_OBJS) $(GLLDFLAGS)

$(BUILDDIR)/ref_glx.$(SHLIBEXT) : $(REF_GL_OBJS) $(REF_GL_GLX_OBJS)
	$(CC) $(CFLAGS) $(SHLIBLDFLAGS) -o $@ $(REF_GL_OBJS) $(REF_GL_GLX_OBJS) $(GLXLDFLAGS)

$(BUILDDIR)/ref_gl/gl_draw.o :        $(REF_GL_DIR)/gl_draw.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_image.o :       $(REF_GL_DIR)/gl_image.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_light.o :       $(REF_GL_DIR)/gl_light.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_mesh.o :        $(REF_GL_DIR)/gl_mesh.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_model.o :       $(REF_GL_DIR)/gl_model.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_rmain.o :       $(REF_GL_DIR)/gl_rmain.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_rmisc.o :       $(REF_GL_DIR)/gl_rmisc.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_rsurf.o :       $(REF_GL_DIR)/gl_rsurf.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_warp.o :        $(REF_GL_DIR)/gl_warp.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/qgl_linux.o :      $(LINUX_DIR)/qgl_linux.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_fxmesa.o :      $(LINUX_DIR)/gl_fxmesa.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/gl_glx.o :      $(LINUX_DIR)/gl_glx.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/rw_in_svgalib.o :  $(LINUX_DIR)/rw_in_svgalib.c
	$(DO_GL_SHLIB_CC)

$(BUILDDIR)/ref_gl/q_shared.o :       $(GAME_DIR)/q_shared.c
	$(DO_SHLIB_DEBUG_CC)

$(BUILDDIR)/ref_gl/q_shlinux.o :      $(LINUX_DIR)/q_shlinux.c
	$(DO_GL_SHLIB_O_CC)

$(BUILDDIR)/ref_gl/glob.o :           $(LINUX_DIR)/glob.c
	$(DO_GL_SHLIB_CC)

#############################################################################
# RPM
#############################################################################

# Make RPMs.  You need to be root to make this work
RPMROOT=/usr/src/redhat
RPM = rpm
RPMFLAGS = -bb
INSTALLDIR = /usr/local/games/quake2
TDFXGL_DIR = /home/zoid/3dfxgl
TMPDIR = /var/tmp

ifeq ($(ARCH),axp)

RPMDIR = $(TMPDIR)/q2ded-$(VERSION_FN)
DESTDIR= $(RPMDIR)/$(INSTALLDIR)

rpm: quake2.axp.spec
	touch $(RPMROOT)/SOURCES/q2ded-$(VERSION_FN).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	$(MAKE) copyfiles COPYDIR=$(DESTDIR)
	cp $(MOUNT_DIR)/linux/quake2.gif $(RPMROOT)/SOURCES/.
	cp quake2.axp.spec $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) quake2.axp.spec
	rm -rf $(RPMDIR)
	mv $(RPMROOT)/RPMS/$(RPMARCH)/q2ded-$(VERSION_FN)-$(RPM_RELEASE).$(RPMARCH).rpm archives/.

tar:
	if [ ! -d archives ];then mkdir archives;fi
	$(MAKE) copyfiles COPYDIR=$(RPMDIR)
	cd $(RPMDIR); tar czvf q2ded-$(VERSION_FN)-$(RPMARCH)-unknown-linux2.0.tar.gz *
	mv $(RPMDIR)/*.tar.gz archives/.
	rm -rf $(RPMDIR)

copyfiles:
	-mkdirhier $(COPYDIR)
	cp $(BUILD_RELEASE_DIR)/q2ded $(COPYDIR)
	strip $(COPYDIR)/q2ded
	chmod 755 $(COPYDIR)/q2ded
	-mkdir $(COPYDIR)/baseq2
	chmod 755 $(COPYDIR)/baseq2
	cp $(BUILD_RELEASE_DIR)/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/baseq2
	chmod 755 $(COPYDIR)/baseq2/game$(ARCH).$(SHLIBEXT)
	-mkdir $(COPYDIR)/ctf
	chmod 755 $(COPYDIR)/ctf
	cp $(BUILD_RELEASE_DIR)/ctf/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/ctf
	chmod 755 $(COPYDIR)/ctf/game$(ARCH).$(SHLIBEXT)
	-mkdir $(COPYDIR)/xatrix
	chmod 755 $(COPYDIR)/xatrix
	cp $(BUILD_RELEASE_DIR)/xatrix/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/xatrix
	chmod 755 $(COPYDIR)/xatrix/game$(ARCH).$(SHLIBEXT)
	-mkdir $(COPYDIR)/rogue
	chmod 755 $(COPYDIR)/rogue
	cp $(BUILD_RELEASE_DIR)/rogue/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/rogue
	chmod 755 $(COPYDIR)/rogue/game$(ARCH).$(SHLIBEXT)
	cp $(MOUNT_DIR)/linux/readme.axp $(COPYDIR)/README
	cp $(MOUNT_DIR)/readme.txt $(COPYDIR)
	cp $(MOUNT_DIR)/$(VERSION)_Changes.txt $(COPYDIR)


quake2.axp.spec : $(MOUNT_DIR)/linux/quake2.axp.spec.sh Makefile
	sh $< $(VERSION_FN) $(RPM_RELEASE) $(ARCH) $(INSTALLDIR) > $@

else

# rpm-quake2-patch
rpm:   rpm-quake2 rpm-quake2-data rpm-quake2-video \
		rpm-quake2-xatrix rpm-quake2-xatrix-video \
		rpm-quake2-rogue rpm-quake2-rogue-video \
		rpm-quake2-ctf

PATCHDIR = $(TMPDIR)/quake2-patch-$(VERSION_FN)
rpm-quake2-patch: quake2-patch.spec
	touch $(RPMROOT)/SOURCES/quake2-patch-$(VERSION_FN).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	$(MAKE) copyfiles COPYDIR=$(PATCHDIR)/$(INSTALLDIR)
	-mkdir $(RPMDIR)/etc
	cp $(MOUNT_DIR)/linux/quake2.conf $(PATCHDIR)/etc/quake2.conf
	cp $(MOUNT_DIR)/linux/quake2.gif $(RPMROOT)/SOURCES/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(PATCHDIR)
	mv $(RPMROOT)/RPMS/$(ARCH)/quake2-$(VERSION_FN)-$(RPM_RELEASE).$(ARCH).rpm archives/.

QUAKE2DIR = $(TMPDIR)/quake2-$(VERSION_FN)
QUAKE2INSTDIR = $(TMPDIR)/quake2-$(VERSION_FN)/$(INSTALLDIR)
rpm-quake2: quake2.spec
	touch $(RPMROOT)/SOURCES/quake2-$(VERSION_FN).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2INSTDIR)
	cp $(BUILD_RELEASE_DIR)/quake2 $(QUAKE2INSTDIR)/quake2
	strip $(QUAKE2INSTDIR)/quake2
	-mkdir $(QUAKE2INSTDIR)/baseq2
	chmod 1777 $(QUAKE2INSTDIR)/baseq2
	cp $(BUILD_RELEASE_DIR)/game$(ARCH).$(SHLIBEXT) $(QUAKE2INSTDIR)/baseq2
	cp $(BUILD_RELEASE_DIR)/ref_soft.$(SHLIBEXT)  $(QUAKE2INSTDIR)
	cp $(BUILD_RELEASE_DIR)/ref_softx.$(SHLIBEXT) $(QUAKE2INSTDIR)
	cp $(BUILD_RELEASE_DIR)/ref_gl.$(SHLIBEXT) $(QUAKE2INSTDIR)
	cp $(BUILD_RELEASE_DIR)/ref_glx.$(SHLIBEXT) $(QUAKE2INSTDIR)
	-mkdir $(QUAKE2INSTDIR)/ctf
	chmod 1777 $(QUAKE2INSTDIR)/ctf
	cp $(BUILD_RELEASE_DIR)/ctf/game$(ARCH).$(SHLIBEXT) $(QUAKE2INSTDIR)/ctf
	-mkdir $(QUAKE2INSTDIR)/xatrix
	chmod 1777 $(QUAKE2INSTDIR)/xatrix
	cp $(BUILD_RELEASE_DIR)/xatrix/game$(ARCH).$(SHLIBEXT) $(QUAKE2INSTDIR)/xatrix
	-mkdir $(QUAKE2INSTDIR)/rogue
	chmod 1777 $(QUAKE2INSTDIR)/rogue
	cp $(BUILD_RELEASE_DIR)/rogue/game$(ARCH).$(SHLIBEXT) $(QUAKE2INSTDIR)/rogue
	-mkdirhier $(QUAKE2DIR)/usr/lib
	cp $(TDFXGL_DIR)/release$(ARCH)$(GLIBC)/lib3dfxgl.so $(QUAKE2DIR)/usr/lib/lib3dfxgl.so
	cp $(MESA_DIR)/lib/libMesaGL.so.2.6 $(QUAKE2DIR)/usr/lib/libMesaGL.so.2.6
	cp $(MOUNT_DIR)/linux/README $(QUAKE2INSTDIR)
	cp $(MOUNT_DIR)/readme.txt $(QUAKE2INSTDIR)
	-mkdir $(QUAKE2DIR)/etc
	cp $(MOUNT_DIR)/linux/quake2.conf $(QUAKE2DIR)/etc/quake2.conf
	cp $(MOUNT_DIR)/linux/quake2.gif $(RPMROOT)/SOURCES/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(QUAKE2DIR)
	mv $(RPMROOT)/RPMS/$(ARCH)/quake2-$(VERSION_FN)-$(RPM_RELEASE).$(ARCH).rpm archives/.

# rpm-quake2-patch: quake2-patch.spec

QUAKE2DATADIR = $(TMPDIR)/quake2-data-$(VERSION)/$(INSTALLDIR)
rpm-quake2-data: quake2-data.spec
	touch $(RPMROOT)/SOURCES/quake2-data-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2DATADIR)/baseq2
	-mkdirhier $(QUAKE2DATADIR)/baseq2/players
	-mkdirhier $(QUAKE2DATADIR)/baseq2/players/cyborg
	-mkdirhier $(QUAKE2DATADIR)/baseq2/players/female
	-mkdirhier $(QUAKE2DATADIR)/baseq2/players/male
	cp $(QUAKE2_DIR)/baseq2/pak0.pak							 	 $(QUAKE2DATADIR)/baseq2/pak0.pak                         
	cp $(QUAKE2_DIR)/baseq2/pak1.pak                                 $(QUAKE2DATADIR)/baseq2/pak1.pak                         
	cp $(QUAKE2_DIR)/baseq2/pak2.pak                                 $(QUAKE2DATADIR)/baseq2/pak2.pak                         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/a_grenades.md2            $(QUAKE2DATADIR)/baseq2/players/cyborg/a_grenades.md2    
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_bfg.md2                 $(QUAKE2DATADIR)/baseq2/players/cyborg/w_bfg.md2         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_blaster.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_blaster.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_chainfist.md2           $(QUAKE2DATADIR)/baseq2/players/cyborg/w_chainfist.md2   
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_chaingun.md2            $(QUAKE2DATADIR)/baseq2/players/cyborg/w_chaingun.md2    
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_disrupt.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_disrupt.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_etfrifle.md2            $(QUAKE2DATADIR)/baseq2/players/cyborg/w_etfrifle.md2    
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_glauncher.md2           $(QUAKE2DATADIR)/baseq2/players/cyborg/w_glauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_grapple.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_grapple.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_hyperblaster.md2        $(QUAKE2DATADIR)/baseq2/players/cyborg/w_hyperblaster.md2
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_machinegun.md2          $(QUAKE2DATADIR)/baseq2/players/cyborg/w_machinegun.md2  
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_phalanx.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_phalanx.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_plasma.md2              $(QUAKE2DATADIR)/baseq2/players/cyborg/w_plasma.md2      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_plauncher.md2           $(QUAKE2DATADIR)/baseq2/players/cyborg/w_plauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_railgun.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_railgun.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_ripper.md2              $(QUAKE2DATADIR)/baseq2/players/cyborg/w_ripper.md2      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_rlauncher.md2           $(QUAKE2DATADIR)/baseq2/players/cyborg/w_rlauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_shotgun.md2             $(QUAKE2DATADIR)/baseq2/players/cyborg/w_shotgun.md2     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/w_sshotgun.md2            $(QUAKE2DATADIR)/baseq2/players/cyborg/w_sshotgun.md2    
	cp $(QUAKE2_DIR)/baseq2/players/female/a_grenades.md2            $(QUAKE2DATADIR)/baseq2/players/female/a_grenades.md2    
	cp $(QUAKE2_DIR)/baseq2/players/female/w_bfg.md2                 $(QUAKE2DATADIR)/baseq2/players/female/w_bfg.md2         
	cp $(QUAKE2_DIR)/baseq2/players/female/w_blaster.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_blaster.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_chainfist.md2           $(QUAKE2DATADIR)/baseq2/players/female/w_chainfist.md2   
	cp $(QUAKE2_DIR)/baseq2/players/female/w_chaingun.md2            $(QUAKE2DATADIR)/baseq2/players/female/w_chaingun.md2    
	cp $(QUAKE2_DIR)/baseq2/players/female/w_disrupt.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_disrupt.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_etfrifle.md2            $(QUAKE2DATADIR)/baseq2/players/female/w_etfrifle.md2    
	cp $(QUAKE2_DIR)/baseq2/players/female/w_glauncher.md2           $(QUAKE2DATADIR)/baseq2/players/female/w_glauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/female/w_grapple.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_grapple.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_hyperblaster.md2        $(QUAKE2DATADIR)/baseq2/players/female/w_hyperblaster.md2
	cp $(QUAKE2_DIR)/baseq2/players/female/w_machinegun.md2          $(QUAKE2DATADIR)/baseq2/players/female/w_machinegun.md2  
	cp $(QUAKE2_DIR)/baseq2/players/female/w_phalanx.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_phalanx.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_plasma.md2              $(QUAKE2DATADIR)/baseq2/players/female/w_plasma.md2      
	cp $(QUAKE2_DIR)/baseq2/players/female/w_plauncher.md2           $(QUAKE2DATADIR)/baseq2/players/female/w_plauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/female/w_railgun.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_railgun.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_ripper.md2              $(QUAKE2DATADIR)/baseq2/players/female/w_ripper.md2      
	cp $(QUAKE2_DIR)/baseq2/players/female/w_rlauncher.md2           $(QUAKE2DATADIR)/baseq2/players/female/w_rlauncher.md2   
	cp $(QUAKE2_DIR)/baseq2/players/female/w_shotgun.md2             $(QUAKE2DATADIR)/baseq2/players/female/w_shotgun.md2     
	cp $(QUAKE2_DIR)/baseq2/players/female/w_sshotgun.md2            $(QUAKE2DATADIR)/baseq2/players/female/w_sshotgun.md2    
	cp $(QUAKE2_DIR)/baseq2/players/male/a_grenades.md2              $(QUAKE2DATADIR)/baseq2/players/male/a_grenades.md2      
	cp $(QUAKE2_DIR)/baseq2/players/male/w_bfg.md2                   $(QUAKE2DATADIR)/baseq2/players/male/w_bfg.md2           
	cp $(QUAKE2_DIR)/baseq2/players/male/w_blaster.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_blaster.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_chainfist.md2             $(QUAKE2DATADIR)/baseq2/players/male/w_chainfist.md2     
	cp $(QUAKE2_DIR)/baseq2/players/male/w_chaingun.md2              $(QUAKE2DATADIR)/baseq2/players/male/w_chaingun.md2      
	cp $(QUAKE2_DIR)/baseq2/players/male/w_disrupt.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_disrupt.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_etfrifle.md2              $(QUAKE2DATADIR)/baseq2/players/male/w_etfrifle.md2      
	cp $(QUAKE2_DIR)/baseq2/players/male/w_glauncher.md2             $(QUAKE2DATADIR)/baseq2/players/male/w_glauncher.md2     
	cp $(QUAKE2_DIR)/baseq2/players/male/w_grapple.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_grapple.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_hyperblaster.md2          $(QUAKE2DATADIR)/baseq2/players/male/w_hyperblaster.md2  
	cp $(QUAKE2_DIR)/baseq2/players/male/w_machinegun.md2            $(QUAKE2DATADIR)/baseq2/players/male/w_machinegun.md2    
	cp $(QUAKE2_DIR)/baseq2/players/male/w_phalanx.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_phalanx.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_plasma.md2                $(QUAKE2DATADIR)/baseq2/players/male/w_plasma.md2        
	cp $(QUAKE2_DIR)/baseq2/players/male/w_plauncher.md2             $(QUAKE2DATADIR)/baseq2/players/male/w_plauncher.md2     
	cp $(QUAKE2_DIR)/baseq2/players/male/w_railgun.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_railgun.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_ripper.md2                $(QUAKE2DATADIR)/baseq2/players/male/w_ripper.md2        
	cp $(QUAKE2_DIR)/baseq2/players/male/w_rlauncher.md2             $(QUAKE2DATADIR)/baseq2/players/male/w_rlauncher.md2     
	cp $(QUAKE2_DIR)/baseq2/players/male/w_shotgun.md2               $(QUAKE2DATADIR)/baseq2/players/male/w_shotgun.md2       
	cp $(QUAKE2_DIR)/baseq2/players/male/w_sshotgun.md2              $(QUAKE2DATADIR)/baseq2/players/male/w_sshotgun.md2      
	cp $(QUAKE2_DIR)/baseq2/players/female/athena.pcx                $(QUAKE2DATADIR)/baseq2/players/female/athena.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/female/athena_i.pcx              $(QUAKE2DATADIR)/baseq2/players/female/athena_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/brianna.pcx               $(QUAKE2DATADIR)/baseq2/players/female/brianna.pcx       
	cp $(QUAKE2_DIR)/baseq2/players/female/brianna_i.pcx             $(QUAKE2DATADIR)/baseq2/players/female/brianna_i.pcx     
	cp $(QUAKE2_DIR)/baseq2/players/female/cobalt.pcx                $(QUAKE2DATADIR)/baseq2/players/female/cobalt.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/female/cobalt_i.pcx              $(QUAKE2DATADIR)/baseq2/players/female/cobalt_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/ensign.pcx                $(QUAKE2DATADIR)/baseq2/players/female/ensign.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/female/ensign_i.pcx              $(QUAKE2DATADIR)/baseq2/players/female/ensign_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/jezebel.pcx               $(QUAKE2DATADIR)/baseq2/players/female/jezebel.pcx       
	cp $(QUAKE2_DIR)/baseq2/players/female/jezebel_i.pcx             $(QUAKE2DATADIR)/baseq2/players/female/jezebel_i.pcx     
	cp $(QUAKE2_DIR)/baseq2/players/female/jungle.pcx                $(QUAKE2DATADIR)/baseq2/players/female/jungle.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/female/jungle_i.pcx              $(QUAKE2DATADIR)/baseq2/players/female/jungle_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/lotus.pcx                 $(QUAKE2DATADIR)/baseq2/players/female/lotus.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/female/lotus_i.pcx               $(QUAKE2DATADIR)/baseq2/players/female/lotus_i.pcx       
	cp $(QUAKE2_DIR)/baseq2/players/female/stiletto.pcx              $(QUAKE2DATADIR)/baseq2/players/female/stiletto.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/stiletto_i.pcx            $(QUAKE2DATADIR)/baseq2/players/female/stiletto_i.pcx    
	cp $(QUAKE2_DIR)/baseq2/players/female/tris.md2                  $(QUAKE2DATADIR)/baseq2/players/female/tris.md2          
	cp $(QUAKE2_DIR)/baseq2/players/female/venus.pcx                 $(QUAKE2DATADIR)/baseq2/players/female/venus.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/female/venus_i.pcx               $(QUAKE2DATADIR)/baseq2/players/female/venus_i.pcx       
	cp $(QUAKE2_DIR)/baseq2/players/female/voodoo.pcx                $(QUAKE2DATADIR)/baseq2/players/female/voodoo.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/female/voodoo_i.pcx              $(QUAKE2DATADIR)/baseq2/players/female/voodoo_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/female/weapon.md2                $(QUAKE2DATADIR)/baseq2/players/female/weapon.md2        
	cp $(QUAKE2_DIR)/baseq2/players/female/weapon.pcx                $(QUAKE2DATADIR)/baseq2/players/female/weapon.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/cipher.pcx                  $(QUAKE2DATADIR)/baseq2/players/male/cipher.pcx          
	cp $(QUAKE2_DIR)/baseq2/players/male/cipher_i.pcx                $(QUAKE2DATADIR)/baseq2/players/male/cipher_i.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/claymore.pcx                $(QUAKE2DATADIR)/baseq2/players/male/claymore.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/claymore_i.pcx              $(QUAKE2DATADIR)/baseq2/players/male/claymore_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/male/flak.pcx                    $(QUAKE2DATADIR)/baseq2/players/male/flak.pcx            
	cp $(QUAKE2_DIR)/baseq2/players/male/flak_i.pcx                  $(QUAKE2DATADIR)/baseq2/players/male/flak_i.pcx          
	cp $(QUAKE2_DIR)/baseq2/players/male/grunt.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/grunt.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/grunt_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/grunt_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/howitzer.pcx                $(QUAKE2DATADIR)/baseq2/players/male/howitzer.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/howitzer_i.pcx              $(QUAKE2DATADIR)/baseq2/players/male/howitzer_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/male/major.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/major.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/major_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/major_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/nightops.pcx                $(QUAKE2DATADIR)/baseq2/players/male/nightops.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/nightops_i.pcx              $(QUAKE2DATADIR)/baseq2/players/male/nightops_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/male/pointman.pcx                $(QUAKE2DATADIR)/baseq2/players/male/pointman.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/pointman_i.pcx              $(QUAKE2DATADIR)/baseq2/players/male/pointman_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/male/psycho.pcx                  $(QUAKE2DATADIR)/baseq2/players/male/psycho.pcx          
	cp $(QUAKE2_DIR)/baseq2/players/male/psycho_i.pcx                $(QUAKE2DATADIR)/baseq2/players/male/psycho_i.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/rampage.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/rampage.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/rampage_i.pcx               $(QUAKE2DATADIR)/baseq2/players/male/rampage_i.pcx       
	cp $(QUAKE2_DIR)/baseq2/players/male/razor.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/razor.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/razor_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/razor_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/recon.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/recon.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/recon_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/recon_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/scout.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/scout.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/scout_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/scout_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/sniper.pcx                  $(QUAKE2DATADIR)/baseq2/players/male/sniper.pcx          
	cp $(QUAKE2_DIR)/baseq2/players/male/sniper_i.pcx                $(QUAKE2DATADIR)/baseq2/players/male/sniper_i.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/male/tris.md2                    $(QUAKE2DATADIR)/baseq2/players/male/tris.md2            
	cp $(QUAKE2_DIR)/baseq2/players/male/viper.pcx                   $(QUAKE2DATADIR)/baseq2/players/male/viper.pcx           
	cp $(QUAKE2_DIR)/baseq2/players/male/viper_i.pcx                 $(QUAKE2DATADIR)/baseq2/players/male/viper_i.pcx         
	cp $(QUAKE2_DIR)/baseq2/players/male/weapon.md2                  $(QUAKE2DATADIR)/baseq2/players/male/weapon.md2          
	cp $(QUAKE2_DIR)/baseq2/players/male/weapon.pcx                  $(QUAKE2DATADIR)/baseq2/players/male/weapon.pcx          
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/bump1.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/bump1.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/death1.wav                $(QUAKE2DATADIR)/baseq2/players/cyborg/death1.wav        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/death2.wav                $(QUAKE2DATADIR)/baseq2/players/cyborg/death2.wav        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/death3.wav                $(QUAKE2DATADIR)/baseq2/players/cyborg/death3.wav        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/death4.wav                $(QUAKE2DATADIR)/baseq2/players/cyborg/death4.wav        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/drown1.wav                $(QUAKE2DATADIR)/baseq2/players/cyborg/drown1.wav        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/fall1.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/fall1.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/fall2.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/fall2.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/gurp1.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/gurp1.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/gurp2.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/gurp2.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/jump1.wav                 $(QUAKE2DATADIR)/baseq2/players/cyborg/jump1.wav         
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/oni911.pcx                $(QUAKE2DATADIR)/baseq2/players/cyborg/oni911.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/oni911_i.pcx              $(QUAKE2DATADIR)/baseq2/players/cyborg/oni911_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain100_1.wav             $(QUAKE2DATADIR)/baseq2/players/cyborg/pain100_1.wav     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain100_2.wav             $(QUAKE2DATADIR)/baseq2/players/cyborg/pain100_2.wav     
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain25_1.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain25_1.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain25_2.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain25_2.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain50_1.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain50_1.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain50_2.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain50_2.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain75_1.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain75_1.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/pain75_2.wav              $(QUAKE2DATADIR)/baseq2/players/cyborg/pain75_2.wav      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/ps9000.pcx                $(QUAKE2DATADIR)/baseq2/players/cyborg/ps9000.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/ps9000_i.pcx              $(QUAKE2DATADIR)/baseq2/players/cyborg/ps9000_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/tris.md2                  $(QUAKE2DATADIR)/baseq2/players/cyborg/tris.md2          
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/tyr574.pcx                $(QUAKE2DATADIR)/baseq2/players/cyborg/tyr574.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/tyr574_i.pcx              $(QUAKE2DATADIR)/baseq2/players/cyborg/tyr574_i.pcx      
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/weapon.md2                $(QUAKE2DATADIR)/baseq2/players/cyborg/weapon.md2        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/weapon.pcx                $(QUAKE2DATADIR)/baseq2/players/cyborg/weapon.pcx        
	cp $(QUAKE2_DIR)/baseq2/players/cyborg/weapon.pcx.pcx            $(QUAKE2DATADIR)/baseq2/players/cyborg/weapon.pcx.pcx    
	cp -r $(QUAKE2_DIR)/docs $(QUAKE2DATADIR)/docs
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-data-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-data-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2VIDEODIR = $(TMPDIR)/quake2-video-$(VERSION)/$(INSTALLDIR)
rpm-quake2-video: quake2-video.spec
	touch $(RPMROOT)/SOURCES/quake2-video-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2VIDEODIR)/baseq2
	-mkdirhier $(QUAKE2VIDEODIR)/baseq2/video
	cp $(QUAKE2_DIR)/baseq2/video/end.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou1_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou2_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou3_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou4_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou5_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou6_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou7_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/eou8_.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/idlog.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $(QUAKE2_DIR)/baseq2/video/ntro.cin		$(QUAKE2VIDEODIR)/baseq2/video/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-video-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-video-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2XATRIXDIR = $(TMPDIR)/quake2-xatrix-$(VERSION)/$(INSTALLDIR)
rpm-quake2-xatrix: quake2-xatrix.spec
	touch $(RPMROOT)/SOURCES/quake2-xatrix-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2XATRIXDIR)/xatrix/docs
	cp $(QUAKE2_DIR)/xatrix/pak0.pak			$(QUAKE2XATRIXDIR)/xatrix/.
	cp $(QUAKE2_DIR)/xatrix/docs/license.doc	$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/license.txt	$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/manual.doc		$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/manual.txt		$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/readme.htm		$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/readme.txt		$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/release.htm	$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $(QUAKE2_DIR)/xatrix/docs/release.txt	$(QUAKE2XATRIXDIR)/xatrix/docs/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-xatrix-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-xatrix-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2XATRIXVIDEODIR = $(TMPDIR)/quake2-xatrix-video-$(VERSION)/$(INSTALLDIR)
rpm-quake2-xatrix-video : quake2-xatrix-video.spec
	touch $(RPMROOT)/SOURCES/quake2-xatrix-video-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2XATRIXVIDEODIR)/xatrix/video
	cp $(QUAKE2_DIR)/xatrix/video/idlog.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/logo.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xin.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xout.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xu1.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xu2.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xu3.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $(QUAKE2_DIR)/xatrix/video/xu4.cin		$(QUAKE2XATRIXVIDEODIR)/xatrix/video/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-xatrix-video-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-xatrix-video-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2ROGUEDIR = $(TMPDIR)/quake2-rogue-$(VERSION)/$(INSTALLDIR)
rpm-quake2-rogue: quake2-rogue.spec
	touch $(RPMROOT)/SOURCES/quake2-rogue-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2ROGUEDIR)/rogue/docs
	cp $(QUAKE2_DIR)/rogue/pak0.pak				$(QUAKE2ROGUEDIR)/rogue/.
	cp $(QUAKE2_DIR)/rogue/docs/license.doc		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $(QUAKE2_DIR)/rogue/docs/license.txt		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $(QUAKE2_DIR)/rogue/docs/readme.htm		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $(QUAKE2_DIR)/rogue/docs/readme.txt		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $(QUAKE2_DIR)/rogue/docs/release.htm		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $(QUAKE2_DIR)/rogue/docs/release.txt		$(QUAKE2ROGUEDIR)/rogue/docs/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-rogue-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-rogue-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2ROGUEVIDEODIR = $(TMPDIR)/quake2-rogue-video-$(VERSION)/$(INSTALLDIR)
rpm-quake2-rogue-video: quake2-rogue-video.spec
	touch $(RPMROOT)/SOURCES/quake2-rogue-video-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2ROGUEVIDEODIR)/rogue/video
	cp $(QUAKE2_DIR)/rogue/video/logo.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/rend.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/reu1_.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/reu2_.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/reu3_.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/reu4_.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $(QUAKE2_DIR)/rogue/video/rintro.cin		$(QUAKE2ROGUEVIDEODIR)/rogue/video/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-rogue-video-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-rogue-video-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

QUAKE2CTFDIR = $(TMPDIR)/quake2-ctf-$(VERSION)/$(INSTALLDIR)
rpm-quake2-ctf: quake2-ctf.spec
	touch $(RPMROOT)/SOURCES/quake2-ctf-$(VERSION).tar.gz
	if [ ! -d archives ];then mkdir archives;fi
	-mkdirhier $(QUAKE2CTFDIR)/ctf/docs
	cp $(QUAKE2_DIR)/ctf/pak0.pak	$(QUAKE2CTFDIR)/ctf/.
	cp $(QUAKE2_DIR)/ctf/pak1.pak	$(QUAKE2CTFDIR)/ctf/.
	cp $(QUAKE2_DIR)/ctf/ctf2.ico	$(QUAKE2CTFDIR)/ctf/.
	cp $(QUAKE2_DIR)/ctf/readme.txt	$(QUAKE2CTFDIR)/ctf/.
	cp $(QUAKE2_DIR)/ctf/server.cfg	$(QUAKE2CTFDIR)/ctf/.
	cp $< $(RPMROOT)/SPECS/.
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) $<
	rm -rf $(TMPDIR)/quake2-ctf-$(VERSION)
	mv $(RPMROOT)/RPMS/$(NOARCH)/quake2-ctf-$(VERSION)-$(RPM_RELEASE).$(NOARCH).rpm archives/.

TARDIR=$(TMPDIR)/tar
tar:
	if [ ! -d archives ];then mkdir archives;fi
	$(MAKE) copyfiles COPYDIR=$(TARDIR)
	cp $(MOUNT_DIR)/linux/quake2.conf $(TARDIR)/quake2.conf
	cd $(TARDIR); sh $(MOUNT_DIR)/linux/fixperms.sh
	cd $(TARDIR); tar czvf quake2-$(VERSION_FN)-$(ARCH)-unknown-linux2.0.tar.gz *
	mv $(TARDIR)/*.tar.gz archives/.
	rm -rf $(TARDIR)


copyfiles:
	-mkdirhier $(COPYDIR)
	cp $(BUILD_RELEASE_DIR)/quake2 $(COPYDIR)/quake2
	strip $(COPYDIR)/quake2
	-mkdir $(COPYDIR)/baseq2
#	cp -R $(VWEP_DIR)/baseq2 $(COPYDIR)/.
#	for x in `find $(COPYDIR)/baseq2 -type d`; do chmod 755 $$x;done
#	for x in `find $(COPYDIR)/baseq2 -type f`; do chmod 644 $$x;done
	chmod 1777 $(COPYDIR)/baseq2
	cp $(BUILD_RELEASE_DIR)/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/baseq2
	cp $(BUILD_RELEASE_DIR)/ref_soft.$(SHLIBEXT)  $(COPYDIR)
	cp $(BUILD_RELEASE_DIR)/ref_softx.$(SHLIBEXT) $(COPYDIR)
	cp $(BUILD_RELEASE_DIR)/ref_gl.$(SHLIBEXT) $(COPYDIR)
	cp $(BUILD_RELEASE_DIR)/ref_glx.$(SHLIBEXT) $(COPYDIR)
#	-mkdir $(COPYDIR)/ctf
#	chmod 1777 $(COPYDIR)/ctf
#	cp $(BUILD_RELEASE_DIR)/ctf/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/ctf
	-mkdir $(COPYDIR)/xatrix
	chmod 1777 $(COPYDIR)/xatrix
	cp $(BUILD_RELEASE_DIR)/xatrix/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/xatrix
	-mkdir $(COPYDIR)/rogue
	chmod 1777 $(COPYDIR)/rogue
	cp $(BUILD_RELEASE_DIR)/rogue/game$(ARCH).$(SHLIBEXT) $(COPYDIR)/rogue
	cp $(TDFXGL_DIR)/release$(ARCH)$(GLIBC)/lib3dfxgl.so $(COPYDIR)
	cp $(MESA_DIR)/lib/libMesaGL.so.2.6 $(COPYDIR)
	cd $(COPYDIR); ln -sf libMesaGL.so.2.6 libMesaGL.so.2
	cd $(COPYDIR); ln -sf libMesaGL.so.2 libMesaGL.so
	cd $(COPYDIR); ln -sf libMesaGL.so libGL.so
	cp $(MOUNT_DIR)/linux/README $(COPYDIR)
	cp $(MOUNT_DIR)/readme.txt $(COPYDIR)
	cp $(MOUNT_DIR)/$(VERSION)_Changes.txt $(COPYDIR)

quake2.spec: $(MOUNT_DIR)/linux/quake2.spec.sh
	sh $< $(VERSION_FN) $(RPM_RELEASE) $(ARCH) $(INSTALLDIR) > $@

quake2-patch.spec: $(MOUNT_DIR)/linux/quake2-patch.spec.sh
	sh $< $(VERSION_FN) $(RPM_RELEASE) $(ARCH) $(INSTALLDIR) > $@

quake2-data.spec: $(MOUNT_DIR)/linux/quake2-data.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-video.spec: $(MOUNT_DIR)/linux/quake2-video.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-xatrix.spec: $(MOUNT_DIR)/linux/quake2-xatrix.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-xatrix-video.spec: $(MOUNT_DIR)/linux/quake2-xatrix-video.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-rogue.spec: $(MOUNT_DIR)/linux/quake2-rogue.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-rogue-video.spec: $(MOUNT_DIR)/linux/quake2-rogue-video.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@

quake2-ctf.spec: $(MOUNT_DIR)/linux/quake2-ctf.spec.sh
	sh $< $(VERSION) $(RPM_RELEASE) $(NOARCH) $(INSTALLDIR) > $@


endif


#############################################################################
# MISC
#############################################################################

clean: clean-debug clean-release

clean-debug:
	$(MAKE) clean2 BUILDDIR=$(BUILD_DEBUG_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clean-release:
	$(MAKE) clean2 BUILDDIR=$(BUILD_RELEASE_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clean2:
	-rm -f \
	$(QUAKE2_OBJS) \
	$(Q2DED_OBJS) \
	$(QUAKE2_AS_OBJS) \
	$(GAME_OBJS) \
	$(CTF_OBJS) \
	$(XATRIX_OBJS) \
	$(ROGUE_OBJS) \
	$(REF_SOFT_OBJS) \
	$(REF_SOFT_SVGA_OBJS) \
	$(REF_SOFT_X11_OBJS) \
	$(REF_GL_OBJS) \
	$(REF_GL_FXMESA_OBJS) \
	$(REF_GL_GLX_OBJS) 
