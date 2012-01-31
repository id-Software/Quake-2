/*
Copyright (C) 1997-2001 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// cl_ents.c -- entity parsing and management

#include "client.h"


extern	struct model_s	*cl_mod_powerscreen;

//PGM
int	vidref_val;
//PGM

/*
=========================================================================

FRAME PARSING

=========================================================================
*/

#if 0

typedef struct
{
	int		modelindex;
	int		num; // entity number
	int		effects;
	vec3_t	origin;
	vec3_t	oldorigin;
	vec3_t	angles;
	qboolean present;
} projectile_t;

#define	MAX_PROJECTILES	64
projectile_t	cl_projectiles[MAX_PROJECTILES];

void CL_ClearProjectiles (void)
{
	int i;

	for (i = 0; i < MAX_PROJECTILES; i++) {
//		if (cl_projectiles[i].present)
//			Com_DPrintf("PROJ: %d CLEARED\n", cl_projectiles[i].num);
		cl_projectiles[i].present = false;
	}
}

/*
=====================
CL_ParseProjectiles

Flechettes are passed as efficient temporary entities
=====================
*/
void CL_ParseProjectiles (void)
{
	int		i, c, j;
	byte	bits[8];
	byte	b;
	projectile_t	pr;
	int lastempty = -1;
	qboolean old = false;

	c = MSG_ReadByte (&net_message);
	for (i=0 ; i<c ; i++)
	{
		bits[0] = MSG_ReadByte (&net_message);
		bits[1] = MSG_ReadByte (&net_message);
		bits[2] = MSG_ReadByte (&net_message);
		bits[3] = MSG_ReadByte (&net_message);
		bits[4] = MSG_ReadByte (&net_message);
		pr.origin[0] = ( ( bits[0] + ((bits[1]&15)<<8) ) <<1) - 4096;
		pr.origin[1] = ( ( (bits[1]>>4) + (bits[2]<<4) ) <<1) - 4096;
		pr.origin[2] = ( ( bits[3] + ((bits[4]&15)<<8) ) <<1) - 4096;
		VectorCopy(pr.origin, pr.oldorigin);

		if (bits[4] & 64)
			pr.effects = EF_BLASTER;
		else
			pr.effects = 0;

		if (bits[4] & 128) {
			old = true;
			bits[0] = MSG_ReadByte (&net_message);
			bits[1] = MSG_ReadByte (&net_message);
			bits[2] = MSG_ReadByte (&net_message);
			bits[3] = MSG_ReadByte (&net_message);
			bits[4] = MSG_ReadByte (&net_message);
			pr.oldorigin[0] = ( ( bits[0] + ((bits[1]&15)<<8) ) <<1) - 4096;
			pr.oldorigin[1] = ( ( (bits[1]>>4) + (bits[2]<<4) ) <<1) - 4096;
			pr.oldorigin[2] = ( ( bits[3] + ((bits[4]&15)<<8) ) <<1) - 4096;
		}

		bits[0] = MSG_ReadByte (&net_message);
		bits[1] = MSG_ReadByte (&net_message);
		bits[2] = MSG_ReadByte (&net_message);

		pr.angles[0] = 360*bits[0]/256;
		pr.angles[1] = 360*bits[1]/256;
		pr.modelindex = bits[2];

		b = MSG_ReadByte (&net_message);
		pr.num = (b & 0x7f);
		if (b & 128) // extra entity number byte
			pr.num |= (MSG_ReadByte (&net_message) << 7);

		pr.present = true;

		// find if this projectile already exists from previous frame 
		for (j = 0; j < MAX_PROJECTILES; j++) {
			if (cl_projectiles[j].modelindex) {
				if (cl_projectiles[j].num == pr.num) {
					// already present, set up oldorigin for interpolation
					if (!old)
						VectorCopy(cl_projectiles[j].origin, pr.oldorigin);
					cl_projectiles[j] = pr;
					break;
				}
			} else
				lastempty = j;
		}

		// not present previous frame, add it
		if (j == MAX_PROJECTILES) {
			if (lastempty != -1) {
				cl_projectiles[lastempty] = pr;
			}
		}
	}
}

/*
=============
CL_LinkProjectiles

=============
*/
void CL_AddProjectiles (void)
{
	int		i, j;
	projectile_t	*pr;
	entity_t		ent;

	memset (&ent, 0, sizeof(ent));

	for (i=0, pr=cl_projectiles ; i < MAX_PROJECTILES ; i++, pr++)
	{
		// grab an entity to fill in
		if (pr->modelindex < 1)
			continue;
		if (!pr->present) {
			pr->modelindex = 0;
			continue; // not present this frame (it was in the previous frame)
		}

		ent.model = cl.model_draw[pr->modelindex];

		// interpolate origin
		for (j=0 ; j<3 ; j++)
		{
			ent.origin[j] = ent.oldorigin[j] = pr->oldorigin[j] + cl.lerpfrac * 
				(pr->origin[j] - pr->oldorigin[j]);

		}

		if (pr->effects & EF_BLASTER)
			CL_BlasterTrail (pr->oldorigin, ent.origin);
		V_AddLight (pr->origin, 200, 1, 1, 0);

		VectorCopy (pr->angles, ent.angles);
		V_AddEntity (&ent);
	}
}
#endif

/*
=================
CL_ParseEntityBits

Returns the entity number and the header bits
=================
*/
int	bitcounts[32];	/// just for protocol profiling
int CL_ParseEntityBits (unsigned *bits)
{
	unsigned	b, total;
	int			i;
	int			number;

	total = MSG_ReadByte (&net_message);
	if (total & U_MOREBITS1)
	{
		b = MSG_ReadByte (&net_message);
		total |= b<<8;
	}
	if (total & U_MOREBITS2)
	{
		b = MSG_ReadByte (&net_message);
		total |= b<<16;
	}
	if (total & U_MOREBITS3)
	{
		b = MSG_ReadByte (&net_message);
		total |= b<<24;
	}

	// count the bits for net profiling
	for (i=0 ; i<32 ; i++)
		if (total&(1<<i))
			bitcounts[i]++;

	if (total & U_NUMBER16)
		number = MSG_ReadShort (&net_message);
	else
		number = MSG_ReadByte (&net_message);

	*bits = total;

	return number;
}

/*
==================
CL_ParseDelta

Can go from either a baseline or a previous packet_entity
==================
*/
void CL_ParseDelta (entity_state_t *from, entity_state_t *to, int number, int bits)
{
	// set everything to the state we are delta'ing from
	*to = *from;

	VectorCopy (from->origin, to->old_origin);
	to->number = number;

	if (bits & U_MODEL)
		to->modelindex = MSG_ReadByte (&net_message);
	if (bits & U_MODEL2)
		to->modelindex2 = MSG_ReadByte (&net_message);
	if (bits & U_MODEL3)
		to->modelindex3 = MSG_ReadByte (&net_message);
	if (bits & U_MODEL4)
		to->modelindex4 = MSG_ReadByte (&net_message);
		
	if (bits & U_FRAME8)
		to->frame = MSG_ReadByte (&net_message);
	if (bits & U_FRAME16)
		to->frame = MSG_ReadShort (&net_message);

	if ((bits & U_SKIN8) && (bits & U_SKIN16))		//used for laser colors
		to->skinnum = MSG_ReadLong(&net_message);
	else if (bits & U_SKIN8)
		to->skinnum = MSG_ReadByte(&net_message);
	else if (bits & U_SKIN16)
		to->skinnum = MSG_ReadShort(&net_message);

	if ( (bits & (U_EFFECTS8|U_EFFECTS16)) == (U_EFFECTS8|U_EFFECTS16) )
		to->effects = MSG_ReadLong(&net_message);
	else if (bits & U_EFFECTS8)
		to->effects = MSG_ReadByte(&net_message);
	else if (bits & U_EFFECTS16)
		to->effects = MSG_ReadShort(&net_message);

	if ( (bits & (U_RENDERFX8|U_RENDERFX16)) == (U_RENDERFX8|U_RENDERFX16) )
		to->renderfx = MSG_ReadLong(&net_message);
	else if (bits & U_RENDERFX8)
		to->renderfx = MSG_ReadByte(&net_message);
	else if (bits & U_RENDERFX16)
		to->renderfx = MSG_ReadShort(&net_message);

	if (bits & U_ORIGIN1)
		to->origin[0] = MSG_ReadCoord (&net_message);
	if (bits & U_ORIGIN2)
		to->origin[1] = MSG_ReadCoord (&net_message);
	if (bits & U_ORIGIN3)
		to->origin[2] = MSG_ReadCoord (&net_message);
		
	if (bits & U_ANGLE1)
		to->angles[0] = MSG_ReadAngle(&net_message);
	if (bits & U_ANGLE2)
		to->angles[1] = MSG_ReadAngle(&net_message);
	if (bits & U_ANGLE3)
		to->angles[2] = MSG_ReadAngle(&net_message);

	if (bits & U_OLDORIGIN)
		MSG_ReadPos (&net_message, to->old_origin);

	if (bits & U_SOUND)
		to->sound = MSG_ReadByte (&net_message);

	if (bits & U_EVENT)
		to->event = MSG_ReadByte (&net_message);
	else
		to->event = 0;

	if (bits & U_SOLID)
		to->solid = MSG_ReadShort (&net_message);
}

/*
==================
CL_DeltaEntity

Parses deltas from the given base and adds the resulting entity
to the current frame
==================
*/
void CL_DeltaEntity (frame_t *frame, int newnum, entity_state_t *old, int bits)
{
	centity_t	*ent;
	entity_state_t	*state;

	ent = &cl_entities[newnum];

	state = &cl_parse_entities[cl.parse_entities & (MAX_PARSE_ENTITIES-1)];
	cl.parse_entities++;
	frame->num_entities++;

	CL_ParseDelta (old, state, newnum, bits);

	// some data changes will force no lerping
	if (state->modelindex != ent->current.modelindex
		|| state->modelindex2 != ent->current.modelindex2
		|| state->modelindex3 != ent->current.modelindex3
		|| state->modelindex4 != ent->current.modelindex4
		|| abs(state->origin[0] - ent->current.origin[0]) > 512
		|| abs(state->origin[1] - ent->current.origin[1]) > 512
		|| abs(state->origin[2] - ent->current.origin[2]) > 512
		|| state->event == EV_PLAYER_TELEPORT
		|| state->event == EV_OTHER_TELEPORT
		)
	{
		ent->serverframe = -99;
	}

	if (ent->serverframe != cl.frame.serverframe - 1)
	{	// wasn't in last update, so initialize some things
		ent->trailcount = 1024;		// for diminishing rocket / grenade trails
		// duplicate the current state so lerping doesn't hurt anything
		ent->prev = *state;
		if (state->event == EV_OTHER_TELEPORT)
		{
			VectorCopy (state->origin, ent->prev.origin);
			VectorCopy (state->origin, ent->lerp_origin);
		}
		else
		{
			VectorCopy (state->old_origin, ent->prev.origin);
			VectorCopy (state->old_origin, ent->lerp_origin);
		}
	}
	else
	{	// shuffle the last state to previous
		ent->prev = ent->current;
	}

	ent->serverframe = cl.frame.serverframe;
	ent->current = *state;
}

/*
==================
CL_ParsePacketEntities

An svc_packetentities has just been parsed, deal with the
rest of the data stream.
==================
*/
void CL_ParsePacketEntities (frame_t *oldframe, frame_t *newframe)
{
	int			newnum;
	int			bits;
	entity_state_t	*oldstate;
	int			oldindex, oldnum;

	newframe->parse_entities = cl.parse_entities;
	newframe->num_entities = 0;

	// delta from the entities present in oldframe
	oldindex = 0;
	if (!oldframe)
		oldnum = 99999;
	else
	{
		if (oldindex >= oldframe->num_entities)
			oldnum = 99999;
		else
		{
			oldstate = &cl_parse_entities[(oldframe->parse_entities+oldindex) & (MAX_PARSE_ENTITIES-1)];
			oldnum = oldstate->number;
		}
	}

	while (1)
	{
		newnum = CL_ParseEntityBits (&bits);
		if (newnum >= MAX_EDICTS)
			Com_Error (ERR_DROP,"CL_ParsePacketEntities: bad number:%i", newnum);

		if (net_message.readcount > net_message.cursize)
			Com_Error (ERR_DROP,"CL_ParsePacketEntities: end of message");

		if (!newnum)
			break;

		while (oldnum < newnum)
		{	// one or more entities from the old packet are unchanged
			if (cl_shownet->value == 3)
				Com_Printf ("   unchanged: %i\n", oldnum);
			CL_DeltaEntity (newframe, oldnum, oldstate, 0);
			
			oldindex++;

			if (oldindex >= oldframe->num_entities)
				oldnum = 99999;
			else
			{
				oldstate = &cl_parse_entities[(oldframe->parse_entities+oldindex) & (MAX_PARSE_ENTITIES-1)];
				oldnum = oldstate->number;
			}
		}

		if (bits & U_REMOVE)
		{	// the entity present in oldframe is not in the current frame
			if (cl_shownet->value == 3)
				Com_Printf ("   remove: %i\n", newnum);
			if (oldnum != newnum)
				Com_Printf ("U_REMOVE: oldnum != newnum\n");

			oldindex++;

			if (oldindex >= oldframe->num_entities)
				oldnum = 99999;
			else
			{
				oldstate = &cl_parse_entities[(oldframe->parse_entities+oldindex) & (MAX_PARSE_ENTITIES-1)];
				oldnum = oldstate->number;
			}
			continue;
		}

		if (oldnum == newnum)
		{	// delta from previous state
			if (cl_shownet->value == 3)
				Com_Printf ("   delta: %i\n", newnum);
			CL_DeltaEntity (newframe, newnum, oldstate, bits);

			oldindex++;

			if (oldindex >= oldframe->num_entities)
				oldnum = 99999;
			else
			{
				oldstate = &cl_parse_entities[(oldframe->parse_entities+oldindex) & (MAX_PARSE_ENTITIES-1)];
				oldnum = oldstate->number;
			}
			continue;
		}

		if (oldnum > newnum)
		{	// delta from baseline
			if (cl_shownet->value == 3)
				Com_Printf ("   baseline: %i\n", newnum);
			CL_DeltaEntity (newframe, newnum, &cl_entities[newnum].baseline, bits);
			continue;
		}

	}

	// any remaining entities in the old frame are copied over
	while (oldnum != 99999)
	{	// one or more entities from the old packet are unchanged
		if (cl_shownet->value == 3)
			Com_Printf ("   unchanged: %i\n", oldnum);
		CL_DeltaEntity (newframe, oldnum, oldstate, 0);
		
		oldindex++;

		if (oldindex >= oldframe->num_entities)
			oldnum = 99999;
		else
		{
			oldstate = &cl_parse_entities[(oldframe->parse_entities+oldindex) & (MAX_PARSE_ENTITIES-1)];
			oldnum = oldstate->number;
		}
	}
}



/*
===================
CL_ParsePlayerstate
===================
*/
void CL_ParsePlayerstate (frame_t *oldframe, frame_t *newframe)
{
	int			flags;
	player_state_t	*state;
	int			i;
	int			statbits;

	state = &newframe->playerstate;

	// clear to old value before delta parsing
	if (oldframe)
		*state = oldframe->playerstate;
	else
		memset (state, 0, sizeof(*state));

	flags = MSG_ReadShort (&net_message);

	//
	// parse the pmove_state_t
	//
	if (flags & PS_M_TYPE)
		state->pmove.pm_type = MSG_ReadByte (&net_message);

	if (flags & PS_M_ORIGIN)
	{
		state->pmove.origin[0] = MSG_ReadShort (&net_message);
		state->pmove.origin[1] = MSG_ReadShort (&net_message);
		state->pmove.origin[2] = MSG_ReadShort (&net_message);
	}

	if (flags & PS_M_VELOCITY)
	{
		state->pmove.velocity[0] = MSG_ReadShort (&net_message);
		state->pmove.velocity[1] = MSG_ReadShort (&net_message);
		state->pmove.velocity[2] = MSG_ReadShort (&net_message);
	}

	if (flags & PS_M_TIME)
		state->pmove.pm_time = MSG_ReadByte (&net_message);

	if (flags & PS_M_FLAGS)
		state->pmove.pm_flags = MSG_ReadByte (&net_message);

	if (flags & PS_M_GRAVITY)
		state->pmove.gravity = MSG_ReadShort (&net_message);

	if (flags & PS_M_DELTA_ANGLES)
	{
		state->pmove.delta_angles[0] = MSG_ReadShort (&net_message);
		state->pmove.delta_angles[1] = MSG_ReadShort (&net_message);
		state->pmove.delta_angles[2] = MSG_ReadShort (&net_message);
	}

	if (cl.attractloop)
		state->pmove.pm_type = PM_FREEZE;		// demo playback

	//
	// parse the rest of the player_state_t
	//
	if (flags & PS_VIEWOFFSET)
	{
		state->viewoffset[0] = MSG_ReadChar (&net_message) * 0.25;
		state->viewoffset[1] = MSG_ReadChar (&net_message) * 0.25;
		state->viewoffset[2] = MSG_ReadChar (&net_message) * 0.25;
	}

	if (flags & PS_VIEWANGLES)
	{
		state->viewangles[0] = MSG_ReadAngle16 (&net_message);
		state->viewangles[1] = MSG_ReadAngle16 (&net_message);
		state->viewangles[2] = MSG_ReadAngle16 (&net_message);
	}

	if (flags & PS_KICKANGLES)
	{
		state->kick_angles[0] = MSG_ReadChar (&net_message) * 0.25;
		state->kick_angles[1] = MSG_ReadChar (&net_message) * 0.25;
		state->kick_angles[2] = MSG_ReadChar (&net_message) * 0.25;
	}

	if (flags & PS_WEAPONINDEX)
	{
		state->gunindex = MSG_ReadByte (&net_message);
	}

	if (flags & PS_WEAPONFRAME)
	{
		state->gunframe = MSG_ReadByte (&net_message);
		state->gunoffset[0] = MSG_ReadChar (&net_message)*0.25;
		state->gunoffset[1] = MSG_ReadChar (&net_message)*0.25;
		state->gunoffset[2] = MSG_ReadChar (&net_message)*0.25;
		state->gunangles[0] = MSG_ReadChar (&net_message)*0.25;
		state->gunangles[1] = MSG_ReadChar (&net_message)*0.25;
		state->gunangles[2] = MSG_ReadChar (&net_message)*0.25;
	}

	if (flags & PS_BLEND)
	{
		state->blend[0] = MSG_ReadByte (&net_message)/255.0;
		state->blend[1] = MSG_ReadByte (&net_message)/255.0;
		state->blend[2] = MSG_ReadByte (&net_message)/255.0;
		state->blend[3] = MSG_ReadByte (&net_message)/255.0;
	}

	if (flags & PS_FOV)
		state->fov = MSG_ReadByte (&net_message);

	if (flags & PS_RDFLAGS)
		state->rdflags = MSG_ReadByte (&net_message);

	// parse stats
	statbits = MSG_ReadLong (&net_message);
	for (i=0 ; i<MAX_STATS ; i++)
		if (statbits & (1<<i) )
			state->stats[i] = MSG_ReadShort(&net_message);
}


/*
==================
CL_FireEntityEvents

==================
*/
void CL_FireEntityEvents (frame_t *frame)
{
	entity_state_t		*s1;
	int					pnum, num;

	for (pnum = 0 ; pnum<frame->num_entities ; pnum++)
	{
		num = (frame->parse_entities + pnum)&(MAX_PARSE_ENTITIES-1);
		s1 = &cl_parse_entities[num];
		if (s1->event)
			CL_EntityEvent (s1);

		// EF_TELEPORTER acts like an event, but is not cleared each frame
		if (s1->effects & EF_TELEPORTER)
			CL_TeleporterParticles (s1);
	}
}


/*
================
CL_ParseFrame
================
*/
void CL_ParseFrame (void)
{
	int			cmd;
	int			len;
	frame_t		*old;

	memset (&cl.frame, 0, sizeof(cl.frame));

#if 0
	CL_ClearProjectiles(); // clear projectiles for new frame
#endif

	cl.frame.serverframe = MSG_ReadLong (&net_message);
	cl.frame.deltaframe = MSG_ReadLong (&net_message);
	cl.frame.servertime = cl.frame.serverframe*100;

	// BIG HACK to let old demos continue to work
	if (cls.serverProtocol != 26)
		cl.surpressCount = MSG_ReadByte (&net_message);

	if (cl_shownet->value == 3)
		Com_Printf ("   frame:%i  delta:%i\n", cl.frame.serverframe,
		cl.frame.deltaframe);

	// If the frame is delta compressed from data that we
	// no longer have available, we must suck up the rest of
	// the frame, but not use it, then ask for a non-compressed
	// message 
	if (cl.frame.deltaframe <= 0)
	{
		cl.frame.valid = true;		// uncompressed frame
		old = NULL;
		cls.demowaiting = false;	// we can start recording now
	}
	else
	{
		old = &cl.frames[cl.frame.deltaframe & UPDATE_MASK];
		if (!old->valid)
		{	// should never happen
			Com_Printf ("Delta from invalid frame (not supposed to happen!).\n");
		}
		if (old->serverframe != cl.frame.deltaframe)
		{	// The frame that the server did the delta from
			// is too old, so we can't reconstruct it properly.
			Com_Printf ("Delta frame too old.\n");
		}
		else if (cl.parse_entities - old->parse_entities > MAX_PARSE_ENTITIES-128)
		{
			Com_Printf ("Delta parse_entities too old.\n");
		}
		else
			cl.frame.valid = true;	// valid delta parse
	}

	// clamp time 
	if (cl.time > cl.frame.servertime)
		cl.time = cl.frame.servertime;
	else if (cl.time < cl.frame.servertime - 100)
		cl.time = cl.frame.servertime - 100;

	// read areabits
	len = MSG_ReadByte (&net_message);
	MSG_ReadData (&net_message, &cl.frame.areabits, len);

	// read playerinfo
	cmd = MSG_ReadByte (&net_message);
	SHOWNET(svc_strings[cmd]);
	if (cmd != svc_playerinfo)
		Com_Error (ERR_DROP, "CL_ParseFrame: not playerinfo");
	CL_ParsePlayerstate (old, &cl.frame);

	// read packet entities
	cmd = MSG_ReadByte (&net_message);
	SHOWNET(svc_strings[cmd]);
	if (cmd != svc_packetentities)
		Com_Error (ERR_DROP, "CL_ParseFrame: not packetentities");
	CL_ParsePacketEntities (old, &cl.frame);

#if 0
	if (cmd == svc_packetentities2)
		CL_ParseProjectiles();
#endif

	// save the frame off in the backup array for later delta comparisons
	cl.frames[cl.frame.serverframe & UPDATE_MASK] = cl.frame;

	if (cl.frame.valid)
	{
		// getting a valid frame message ends the connection process
		if (cls.state != ca_active)
		{
			cls.state = ca_active;
			cl.force_refdef = true;
			cl.predicted_origin[0] = cl.frame.playerstate.pmove.origin[0]*0.125;
			cl.predicted_origin[1] = cl.frame.playerstate.pmove.origin[1]*0.125;
			cl.predicted_origin[2] = cl.frame.playerstate.pmove.origin[2]*0.125;
			VectorCopy (cl.frame.playerstate.viewangles, cl.predicted_angles);
			if (cls.disable_servercount != cl.servercount
				&& cl.refresh_prepped)
				SCR_EndLoadingPlaque ();	// get rid of loading plaque
		}
		cl.sound_prepped = true;	// can start mixing ambient sounds
	
		// fire entity events
		CL_FireEntityEvents (&cl.frame);
		CL_CheckPredictionError ();
	}
}

/*
==========================================================================

INTERPOLATE BETWEEN FRAMES TO GET RENDERING PARMS

==========================================================================
*/

struct model_s *S_RegisterSexedModel (entity_state_t *ent, char *base)
{
	int				n;
	char			*p;
	struct model_s	*mdl;
	char			model[MAX_QPATH];
	char			buffer[MAX_QPATH];

	// determine what model the client is using
	model[0] = 0;
	n = CS_PLAYERSKINS + ent->number - 1;
	if (cl.configstrings[n][0])
	{
		p = strchr(cl.configstrings[n], '\\');
		if (p)
		{
			p += 1;
			strcpy(model, p);
			p = strchr(model, '/');
			if (p)
				*p = 0;
		}
	}
	// if we can't figure it out, they're male
	if (!model[0])
		strcpy(model, "male");

	Com_sprintf (buffer, sizeof(buffer), "players/%s/%s", model, base+1);
	mdl = re.RegisterModel(buffer);
	if (!mdl) {
		// not found, try default weapon model
		Com_sprintf (buffer, sizeof(buffer), "players/%s/weapon.md2", model);
		mdl = re.RegisterModel(buffer);
		if (!mdl) {
			// no, revert to the male model
			Com_sprintf (buffer, sizeof(buffer), "players/%s/%s", "male", base+1);
			mdl = re.RegisterModel(buffer);
			if (!mdl) {
				// last try, default male weapon.md2
				Com_sprintf (buffer, sizeof(buffer), "players/male/weapon.md2");
				mdl = re.RegisterModel(buffer);
			}
		} 
	}

	return mdl;
}

/*
===============
CL_AddPacketEntities

===============
*/
void CL_AddPacketEntities (frame_t *frame)
{
	entity_t			ent;
	entity_state_t		*s1;
	float				autorotate;
	int					i;
	int					pnum;
	centity_t			*cent;
	int					autoanim;
	clientinfo_t		*ci;
	unsigned int		effects, renderfx;

	// bonus items rotate at a fixed rate
	autorotate = anglemod(cl.time/10);

	// brush models can auto animate their frames
	autoanim = 2*cl.time/1000;

	memset (&ent, 0, sizeof(ent));

	for (pnum = 0 ; pnum<frame->num_entities ; pnum++)
	{
		s1 = &cl_parse_entities[(frame->parse_entities+pnum)&(MAX_PARSE_ENTITIES-1)];

		cent = &cl_entities[s1->number];

		effects = s1->effects;
		renderfx = s1->renderfx;

			// set frame
		if (effects & EF_ANIM01)
			ent.frame = autoanim & 1;
		else if (effects & EF_ANIM23)
			ent.frame = 2 + (autoanim & 1);
		else if (effects & EF_ANIM_ALL)
			ent.frame = autoanim;
		else if (effects & EF_ANIM_ALLFAST)
			ent.frame = cl.time / 100;
		else
			ent.frame = s1->frame;

		// quad and pent can do different things on client
		if (effects & EF_PENT)
		{
			effects &= ~EF_PENT;
			effects |= EF_COLOR_SHELL;
			renderfx |= RF_SHELL_RED;
		}

		if (effects & EF_QUAD)
		{
			effects &= ~EF_QUAD;
			effects |= EF_COLOR_SHELL;
			renderfx |= RF_SHELL_BLUE;
		}
//======
// PMM
		if (effects & EF_DOUBLE)
		{
			effects &= ~EF_DOUBLE;
			effects |= EF_COLOR_SHELL;
			renderfx |= RF_SHELL_DOUBLE;
		}

		if (effects & EF_HALF_DAMAGE)
		{
			effects &= ~EF_HALF_DAMAGE;
			effects |= EF_COLOR_SHELL;
			renderfx |= RF_SHELL_HALF_DAM;
		}
// pmm
//======
		ent.oldframe = cent->prev.frame;
		ent.backlerp = 1.0 - cl.lerpfrac;

		if (renderfx & (RF_FRAMELERP|RF_BEAM))
		{	// step origin discretely, because the frames
			// do the animation properly
			VectorCopy (cent->current.origin, ent.origin);
			VectorCopy (cent->current.old_origin, ent.oldorigin);
		}
		else
		{	// interpolate origin
			for (i=0 ; i<3 ; i++)
			{
				ent.origin[i] = ent.oldorigin[i] = cent->prev.origin[i] + cl.lerpfrac * 
					(cent->current.origin[i] - cent->prev.origin[i]);
			}
		}

		// create a new entity
	
		// tweak the color of beams
		if ( renderfx & RF_BEAM )
		{	// the four beam colors are encoded in 32 bits of skinnum (hack)
			ent.alpha = 0.30;
			ent.skinnum = (s1->skinnum >> ((rand() % 4)*8)) & 0xff;
			ent.model = NULL;
		}
		else
		{
			// set skin
			if (s1->modelindex == 255)
			{	// use custom player skin
				ent.skinnum = 0;
				ci = &cl.clientinfo[s1->skinnum & 0xff];
				ent.skin = ci->skin;
				ent.model = ci->model;
				if (!ent.skin || !ent.model)
				{
					ent.skin = cl.baseclientinfo.skin;
					ent.model = cl.baseclientinfo.model;
				}

//============
//PGM
				if (renderfx & RF_USE_DISGUISE)
				{
					if(!strncmp((char *)ent.skin, "players/male", 12))
					{
						ent.skin = re.RegisterSkin ("players/male/disguise.pcx");
						ent.model = re.RegisterModel ("players/male/tris.md2");
					}
					else if(!strncmp((char *)ent.skin, "players/female", 14))
					{
						ent.skin = re.RegisterSkin ("players/female/disguise.pcx");
						ent.model = re.RegisterModel ("players/female/tris.md2");
					}
					else if(!strncmp((char *)ent.skin, "players/cyborg", 14))
					{
						ent.skin = re.RegisterSkin ("players/cyborg/disguise.pcx");
						ent.model = re.RegisterModel ("players/cyborg/tris.md2");
					}
				}
//PGM
//============
			}
			else
			{
				ent.skinnum = s1->skinnum;
				ent.skin = NULL;
				ent.model = cl.model_draw[s1->modelindex];
			}
		}

		// only used for black hole model right now, FIXME: do better
		if (renderfx == RF_TRANSLUCENT)
			ent.alpha = 0.70;

		// render effects (fullbright, translucent, etc)
		if ((effects & EF_COLOR_SHELL))
			ent.flags = 0;	// renderfx go on color shell entity
		else
			ent.flags = renderfx;

		// calculate angles
		if (effects & EF_ROTATE)
		{	// some bonus items auto-rotate
			ent.angles[0] = 0;
			ent.angles[1] = autorotate;
			ent.angles[2] = 0;
		}
		// RAFAEL
		else if (effects & EF_SPINNINGLIGHTS)
		{
			ent.angles[0] = 0;
			ent.angles[1] = anglemod(cl.time/2) + s1->angles[1];
			ent.angles[2] = 180;
			{
				vec3_t forward;
				vec3_t start;

				AngleVectors (ent.angles, forward, NULL, NULL);
				VectorMA (ent.origin, 64, forward, start);
				V_AddLight (start, 100, 1, 0, 0);
			}
		}
		else
		{	// interpolate angles
			float	a1, a2;

			for (i=0 ; i<3 ; i++)
			{
				a1 = cent->current.angles[i];
				a2 = cent->prev.angles[i];
				ent.angles[i] = LerpAngle (a2, a1, cl.lerpfrac);
			}
		}

		if (s1->number == cl.playernum+1)
		{
			ent.flags |= RF_VIEWERMODEL;	// only draw from mirrors
			// FIXME: still pass to refresh

			if (effects & EF_FLAG1)
				V_AddLight (ent.origin, 225, 1.0, 0.1, 0.1);
			else if (effects & EF_FLAG2)
				V_AddLight (ent.origin, 225, 0.1, 0.1, 1.0);
			else if (effects & EF_TAGTRAIL)						//PGM
				V_AddLight (ent.origin, 225, 1.0, 1.0, 0.0);	//PGM
			else if (effects & EF_TRACKERTRAIL)					//PGM
				V_AddLight (ent.origin, 225, -1.0, -1.0, -1.0);	//PGM

			continue;
		}

		// if set to invisible, skip
		if (!s1->modelindex)
			continue;

		if (effects & EF_BFG)
		{
			ent.flags |= RF_TRANSLUCENT;
			ent.alpha = 0.30;
		}

		// RAFAEL
		if (effects & EF_PLASMA)
		{
			ent.flags |= RF_TRANSLUCENT;
			ent.alpha = 0.6;
		}

		if (effects & EF_SPHERETRANS)
		{
			ent.flags |= RF_TRANSLUCENT;
			// PMM - *sigh*  yet more EF overloading
			if (effects & EF_TRACKERTRAIL)
				ent.alpha = 0.6;
			else
				ent.alpha = 0.3;
		}
//pmm

		// add to refresh list
		V_AddEntity (&ent);

		// color shells generate a seperate entity for the main model
		if (effects & EF_COLOR_SHELL)
		{
			ent.flags = renderfx | RF_TRANSLUCENT;
			ent.alpha = 0.30;
			V_AddEntity (&ent);
		}

		ent.skin = NULL;		// never use a custom skin on others
		ent.skinnum = 0;
		ent.flags = 0;
		ent.alpha = 0;

		// duplicate for linked models
		if (s1->modelindex2)
		{
			if (s1->modelindex2 == 255)
			{	// custom weapon
				ci = &cl.clientinfo[s1->skinnum & 0xff];
				i = (s1->skinnum >> 8); // 0 is default weapon model
				if (!cl_vwep->value || i > MAX_CLIENTWEAPONMODELS - 1)
					i = 0;
				ent.model = ci->weaponmodel[i];
				if (!ent.model) {
					if (i != 0)
						ent.model = ci->weaponmodel[0];
					if (!ent.model)
						ent.model = cl.baseclientinfo.weaponmodel[0];
				}
			}
			//PGM - hack to allow translucent linked models (defender sphere's shell)
			//		set the high bit 0x80 on modelindex2 to enable translucency
			else if(s1->modelindex2 & 0x80)
			{
				ent.model = cl.model_draw[s1->modelindex2 & 0x7F];
				ent.alpha = 0.32;
				ent.flags = RF_TRANSLUCENT;
			}
			//PGM
			else
				ent.model = cl.model_draw[s1->modelindex2];
			V_AddEntity (&ent);

			//PGM - make sure these get reset.
			ent.flags = 0;
			ent.alpha = 0;
			//PGM
		}
		if (s1->modelindex3)
		{
			ent.model = cl.model_draw[s1->modelindex3];
			V_AddEntity (&ent);
		}
		if (s1->modelindex4)
		{
			ent.model = cl.model_draw[s1->modelindex4];
			V_AddEntity (&ent);
		}

		if ( effects & EF_POWERSCREEN )
		{
			ent.model = cl_mod_powerscreen;
			ent.oldframe = 0;
			ent.frame = 0;
			ent.flags |= (RF_TRANSLUCENT | RF_SHELL_GREEN);
			ent.alpha = 0.30;
			V_AddEntity (&ent);
		}

		// add automatic particle trails
		if ( (effects&~EF_ROTATE) )
		{
			if (effects & EF_ROCKET)
			{
				CL_RocketTrail (cent->lerp_origin, ent.origin, cent);
				V_AddLight (ent.origin, 200, 1, 1, 0);
			}
			// PGM - Do not reorder EF_BLASTER and EF_HYPERBLASTER. 
			// EF_BLASTER | EF_TRACKER is a special case for EF_BLASTER2... Cheese!
			else if (effects & EF_BLASTER)
			{
//				CL_BlasterTrail (cent->lerp_origin, ent.origin);
//PGM
				if (effects & EF_TRACKER)	// lame... problematic?
				{
					CL_BlasterTrail2 (cent->lerp_origin, ent.origin);
					V_AddLight (ent.origin, 200, 0, 1, 0);		
				}
				else
				{
					CL_BlasterTrail (cent->lerp_origin, ent.origin);
					V_AddLight (ent.origin, 200, 1, 1, 0);
				}
//PGM
			}
			else if (effects & EF_HYPERBLASTER)
			{
				if (effects & EF_TRACKER)						// PGM	overloaded for blaster2.
					V_AddLight (ent.origin, 200, 0, 1, 0);		// PGM
				else											// PGM
					V_AddLight (ent.origin, 200, 1, 1, 0);
			}
			else if (effects & EF_GIB)
			{
				CL_DiminishingTrail (cent->lerp_origin, ent.origin, cent, effects);
			}
			else if (effects & EF_GRENADE)
			{
				CL_DiminishingTrail (cent->lerp_origin, ent.origin, cent, effects);
			}
			else if (effects & EF_FLIES)
			{
				CL_FlyEffect (cent, ent.origin);
			}
			else if (effects & EF_BFG)
			{
				static int bfg_lightramp[6] = {300, 400, 600, 300, 150, 75};

				if (effects & EF_ANIM_ALLFAST)
				{
					CL_BfgParticles (&ent);
					i = 200;
				}
				else
				{
					i = bfg_lightramp[s1->frame];
				}
				V_AddLight (ent.origin, i, 0, 1, 0);
			}
			// RAFAEL
			else if (effects & EF_TRAP)
			{
				ent.origin[2] += 32;
				CL_TrapParticles (&ent);
				i = (rand()%100) + 100;
				V_AddLight (ent.origin, i, 1, 0.8, 0.1);
			}
			else if (effects & EF_FLAG1)
			{
				CL_FlagTrail (cent->lerp_origin, ent.origin, 242);
				V_AddLight (ent.origin, 225, 1, 0.1, 0.1);
			}
			else if (effects & EF_FLAG2)
			{
				CL_FlagTrail (cent->lerp_origin, ent.origin, 115);
				V_AddLight (ent.origin, 225, 0.1, 0.1, 1);
			}
//======
//ROGUE
			else if (effects & EF_TAGTRAIL)
			{
				CL_TagTrail (cent->lerp_origin, ent.origin, 220);
				V_AddLight (ent.origin, 225, 1.0, 1.0, 0.0);
			}
			else if (effects & EF_TRACKERTRAIL)
			{
				if (effects & EF_TRACKER)
				{
					float intensity;

					intensity = 50 + (500 * (sin(cl.time/500.0) + 1.0));
					// FIXME - check out this effect in rendition
					if(vidref_val == VIDREF_GL)
						V_AddLight (ent.origin, intensity, -1.0, -1.0, -1.0);
					else
						V_AddLight (ent.origin, -1.0 * intensity, 1.0, 1.0, 1.0);
					}
				else
				{
					CL_Tracker_Shell (cent->lerp_origin);
					V_AddLight (ent.origin, 155, -1.0, -1.0, -1.0);
				}
			}
			else if (effects & EF_TRACKER)
			{
				CL_TrackerTrail (cent->lerp_origin, ent.origin, 0);
				// FIXME - check out this effect in rendition
				if(vidref_val == VIDREF_GL)
					V_AddLight (ent.origin, 200, -1, -1, -1);
				else
					V_AddLight (ent.origin, -200, 1, 1, 1);
			}
//ROGUE
//======
			// RAFAEL
			else if (effects & EF_GREENGIB)
			{
				CL_DiminishingTrail (cent->lerp_origin, ent.origin, cent, effects);				
			}
			// RAFAEL
			else if (effects & EF_IONRIPPER)
			{
				CL_IonripperTrail (cent->lerp_origin, ent.origin);
				V_AddLight (ent.origin, 100, 1, 0.5, 0.5);
			}
			// RAFAEL
			else if (effects & EF_BLUEHYPERBLASTER)
			{
				V_AddLight (ent.origin, 200, 0, 0, 1);
			}
			// RAFAEL
			else if (effects & EF_PLASMA)
			{
				if (effects & EF_ANIM_ALLFAST)
				{
					CL_BlasterTrail (cent->lerp_origin, ent.origin);
				}
				V_AddLight (ent.origin, 130, 1, 0.5, 0.5);
			}
		}

		VectorCopy (ent.origin, cent->lerp_origin);
	}
}



/*
==============
CL_AddViewWeapon
==============
*/
void CL_AddViewWeapon (player_state_t *ps, player_state_t *ops)
{
	entity_t	gun;		// view model
	int			i;

	// allow the gun to be completely removed
	if (!cl_gun->value)
		return;

	// don't draw gun if in wide angle view
	if (ps->fov > 90)
		return;

	memset (&gun, 0, sizeof(gun));

	if (gun_model)
		gun.model = gun_model;	// development tool
	else
		gun.model = cl.model_draw[ps->gunindex];
	if (!gun.model)
		return;

	// set up gun position
	for (i=0 ; i<3 ; i++)
	{
		gun.origin[i] = cl.refdef.vieworg[i] + ops->gunoffset[i]
			+ cl.lerpfrac * (ps->gunoffset[i] - ops->gunoffset[i]);
		gun.angles[i] = cl.refdef.viewangles[i] + LerpAngle (ops->gunangles[i],
			ps->gunangles[i], cl.lerpfrac);
	}

	if (gun_frame)
	{
		gun.frame = gun_frame;	// development tool
		gun.oldframe = gun_frame;	// development tool
	}
	else
	{
		gun.frame = ps->gunframe;
		if (gun.frame == 0)
			gun.oldframe = 0;	// just changed weapons, don't lerp from old
		else
			gun.oldframe = ops->gunframe;
	}

	gun.flags = RF_MINLIGHT | RF_DEPTHHACK | RF_WEAPONMODEL;
	gun.backlerp = 1.0 - cl.lerpfrac;
	VectorCopy (gun.origin, gun.oldorigin);	// don't lerp at all
	V_AddEntity (&gun);
}


/*
===============
CL_CalcViewValues

Sets cl.refdef view values
===============
*/
void CL_CalcViewValues (void)
{
	int			i;
	float		lerp, backlerp;
	centity_t	*ent;
	frame_t		*oldframe;
	player_state_t	*ps, *ops;

	// find the previous frame to interpolate from
	ps = &cl.frame.playerstate;
	i = (cl.frame.serverframe - 1) & UPDATE_MASK;
	oldframe = &cl.frames[i];
	if (oldframe->serverframe != cl.frame.serverframe-1 || !oldframe->valid)
		oldframe = &cl.frame;		// previous frame was dropped or involid
	ops = &oldframe->playerstate;

	// see if the player entity was teleported this frame
	if ( fabs(ops->pmove.origin[0] - ps->pmove.origin[0]) > 256*8
		|| abs(ops->pmove.origin[1] - ps->pmove.origin[1]) > 256*8
		|| abs(ops->pmove.origin[2] - ps->pmove.origin[2]) > 256*8)
		ops = ps;		// don't interpolate

	ent = &cl_entities[cl.playernum+1];
	lerp = cl.lerpfrac;

	// calculate the origin
	if ((cl_predict->value) && !(cl.frame.playerstate.pmove.pm_flags & PMF_NO_PREDICTION))
	{	// use predicted values
		unsigned	delta;

		backlerp = 1.0 - lerp;
		for (i=0 ; i<3 ; i++)
		{
			cl.refdef.vieworg[i] = cl.predicted_origin[i] + ops->viewoffset[i] 
				+ cl.lerpfrac * (ps->viewoffset[i] - ops->viewoffset[i])
				- backlerp * cl.prediction_error[i];
		}

		// smooth out stair climbing
		delta = cls.realtime - cl.predicted_step_time;
		if (delta < 100)
			cl.refdef.vieworg[2] -= cl.predicted_step * (100 - delta) * 0.01;
	}
	else
	{	// just use interpolated values
		for (i=0 ; i<3 ; i++)
			cl.refdef.vieworg[i] = ops->pmove.origin[i]*0.125 + ops->viewoffset[i] 
				+ lerp * (ps->pmove.origin[i]*0.125 + ps->viewoffset[i] 
				- (ops->pmove.origin[i]*0.125 + ops->viewoffset[i]) );
	}

	// if not running a demo or on a locked frame, add the local angle movement
	if ( cl.frame.playerstate.pmove.pm_type < PM_DEAD )
	{	// use predicted values
		for (i=0 ; i<3 ; i++)
			cl.refdef.viewangles[i] = cl.predicted_angles[i];
	}
	else
	{	// just use interpolated values
		for (i=0 ; i<3 ; i++)
			cl.refdef.viewangles[i] = LerpAngle (ops->viewangles[i], ps->viewangles[i], lerp);
	}

	for (i=0 ; i<3 ; i++)
		cl.refdef.viewangles[i] += LerpAngle (ops->kick_angles[i], ps->kick_angles[i], lerp);

	AngleVectors (cl.refdef.viewangles, cl.v_forward, cl.v_right, cl.v_up);

	// interpolate field of view
	cl.refdef.fov_x = ops->fov + lerp * (ps->fov - ops->fov);

	// don't interpolate blend color
	for (i=0 ; i<4 ; i++)
		cl.refdef.blend[i] = ps->blend[i];

	// add the weapon
	CL_AddViewWeapon (ps, ops);
}

/*
===============
CL_AddEntities

Emits all entities, particles, and lights to the refresh
===============
*/
void CL_AddEntities (void)
{
	if (cls.state != ca_active)
		return;

	if (cl.time > cl.frame.servertime)
	{
		if (cl_showclamp->value)
			Com_Printf ("high clamp %i\n", cl.time - cl.frame.servertime);
		cl.time = cl.frame.servertime;
		cl.lerpfrac = 1.0;
	}
	else if (cl.time < cl.frame.servertime - 100)
	{
		if (cl_showclamp->value)
			Com_Printf ("low clamp %i\n", cl.frame.servertime-100 - cl.time);
		cl.time = cl.frame.servertime - 100;
		cl.lerpfrac = 0;
	}
	else
		cl.lerpfrac = 1.0 - (cl.frame.servertime - cl.time) * 0.01;

	if (cl_timedemo->value)
		cl.lerpfrac = 1.0;

//	CL_AddPacketEntities (&cl.frame);
//	CL_AddTEnts ();
//	CL_AddParticles ();
//	CL_AddDLights ();
//	CL_AddLightStyles ();

	CL_CalcViewValues ();
	// PMM - moved this here so the heat beam has the right values for the vieworg, and can lock the beam to the gun
	CL_AddPacketEntities (&cl.frame);
#if 0
	CL_AddProjectiles ();
#endif
	CL_AddTEnts ();
	CL_AddParticles ();
	CL_AddDLights ();
	CL_AddLightStyles ();
}



/*
===============
CL_GetEntitySoundOrigin

Called to get the sound spatialization origin
===============
*/
void CL_GetEntitySoundOrigin (int ent, vec3_t org)
{
	centity_t	*old;

	if (ent < 0 || ent >= MAX_EDICTS)
		Com_Error (ERR_DROP, "CL_GetEntitySoundOrigin: bad ent");
	old = &cl_entities[ent];
	VectorCopy (old->lerp_origin, org);

	// FIXME: bmodel issues...
}
