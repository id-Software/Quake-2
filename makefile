
CFLAGS = -Wall -c -g -DNO_PRIVATE
LDFLAGS = -sectcreate __ICON __header rhapsody/quake2.iconheader -segprot __ICON r r -sectcreate __ICON app rhapsody/quake2.tiff -framework AppKit -framework Foundation
ODIR = rhapsody/output

EXEBASE = QuakeWorld
EXE = $(ODIR)/$(EXEBASE)
all: $(EXE)

_next:
	make "CFLAGS = -Wall -c -g -DNO_PRIVATE" "ODIR = rhapsody/output"
	
_nextopt:
	make "CFLAGS = -O2 -c -g -DNO_PRIVATE" "ODIR = rhapsody/output"
	
_irix:
	make "CFLAGS = -c -Ofast=ip32_10k -Xcpluscomm -DNO_PRIVATE" "LDFLAGS = -Ofast=ip32_10k -lm" "ODIR = irix"
	
_osf:
	make "CFLAGS = -c -O4 -DNO_PRIVATE" "LDFLAGS = -lm" "ODIR = osf"

clean:
	rm -f $(ODIR)/*.o $(EXE)

REF_SOFT_SYSTEM_FILES = $(ODIR)/r_next.o 

REF_SOFT_FILES = $(ODIR)/r_polyse.o $(ODIR)/r_scan.o  $(ODIR)/r_model.o $(ODIR)/r_aclip.o $(ODIR)/r_alias.o $(ODIR)/r_bsp.o $(ODIR)/r_draw.o $(ODIR)/r_edge.o $(ODIR)/r_light.o $(ODIR)/r_main.o $(ODIR)/r_misc.o $(ODIR)/r_part.o $(ODIR)/r_sprite.o $(ODIR)/r_surf.o $(REF_SOFT_SYSTEM_FILES)

CLIENT_SYSTEM_FILES = $(ODIR)/in_next.o 
SOUND_FILES = $(ODIR)/snd_dma.o $(ODIR)/snd_mix.o $(ODIR)/snd_mem.o
CLIENT_FILES = $(ODIR)/cl_ents.o $(ODIR)/cl_input.o  $(ODIR)/cl_main.o $(ODIR)/cl_parse.o $(ODIR)/cl_pred.o $(ODIR)/cl_tent.o $(ODIR)/console.o $(ODIR)/keys.o $(ODIR)/menu.o $(SOUND_FILES) $(CLIENT_SYSTEM_FILES) $(REF_SOFT_FILES)
#CLIENT_FILES = $(ODIR)/cl_null.o


SERVER_FILES = $(ODIR)/sv_ccmds.o  $(ODIR)/sv_ents.o $(ODIR)/sv_init.o $(ODIR)/sv_main.o $(ODIR)/sv_send.o $(ODIR)/sv_user.o $(ODIR)/sv_world.o
#SERVER_FILES = $(ODIR)/sv_null.o


# QCOMMON_SYSTEM_FILES = $(ODIR)/sys_next.o 
QCOMMON_FILES = $(ODIR)/cmd.o $(ODIR)/cmodel.o $(ODIR)/common.o $(ODIR)/crc.o   $(ODIR)/cvar.o $(ODIR)/files.o $(ODIR)/net_chan.o $(ODIR)/pmove.o $(QCOMMON_SYSTEM_FILES)

$(EXE): $(CLIENT_FILES) $(SERVER_FILES) $(QCOMMON_FILES)
	cc -o $(EXE) $(CLIENT_FILES) $(SERVER_FILES) $(QCOMMON_FILES) $(LDFLAGS) 

#===========================================================================

$(ODIR)/cl_null.o : client/cl_null.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
	
$(ODIR)/cl_ents.o : client/cl_ents.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cl_input.o : client/cl_input.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cl_main.o : client/cl_main.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cl_parse.o : client/cl_parse.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cl_pred.o : client/cl_pred.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cl_tent.o : client/cl_tent.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/console.o : client/console.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/keys.o : client/keys.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/menu.o : client/menu.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/snd_dma.o : client/snd_dma.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/snd_mix.o : client/snd_mix.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/snd_mem.o : client/snd_mem.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/in_null.o : client/in_null.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/snd_null.o : client/snd_null.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/in_next.o : rhapsody/in_next.m
	cc $(CFLAGS) -o $@ $?


#===========================================================================

$(ODIR)/sv_null.o : server/sv_null.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/sv_ccmds.o : server/sv_ccmds.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_ents.o : server/sv_ents.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_init.o : server/sv_init.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_main.o : server/sv_main.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_send.o : server/sv_send.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_user.o : server/sv_user.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/sv_world.o : server/sv_world.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

#===========================================================================

$(ODIR)/r_polyse.o : ref_soft/r_polyse.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_scan.o : ref_soft/r_scan.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_model.o : ref_soft/r_model.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_aclip.o : ref_soft/r_aclip.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_alias.o : ref_soft/r_alias.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_bsp.o : ref_soft/r_bsp.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_draw.o : ref_soft/r_draw.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_edge.o : ref_soft/r_edge.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_light.o : ref_soft/r_light.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_main.o : ref_soft/r_main.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_misc.o : ref_soft/r_misc.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_part.o : ref_soft/r_part.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_sprite.o : ref_soft/r_sprite.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/r_surf.o : ref_soft/r_surf.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/r_next.o : rhapsody/r_next.m
	cc $(CFLAGS) -o $@ $?

#===========================================================================

$(ODIR)/cmd.o : qcommon/cmd.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cmodel.o : qcommon/cmodel.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/common.o : qcommon/common.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/crc.o : qcommon/crc.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/cvar.o : qcommon/cvar.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/files.o : qcommon/files.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/net_chan.o : qcommon/net_chan.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
$(ODIR)/pmove.o : qcommon/pmove.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i

$(ODIR)/sys_null.o : qcommon/sys_null.c
	cc $(CFLAGS) -E $? | tr -d '\015' > /tmp/temp.i
	cc $(CFLAGS) -o $@ /tmp/temp.i
