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
// g_actor.c

#include "g_local.h"
#include "m_actor.h"

#define	MAX_ACTOR_NAMES		8
char *actor_names[MAX_ACTOR_NAMES] =
{
	"Hellrot",
	"Tokay",
	"Killme",
	"Disruptor",
	"Adrianator",
	"Rambear",
	"Titus",
	"Bitterman"
};


mframe_t actor_frames_stand [] =
{
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,

	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,

	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,

	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL
};
mmove_t actor_move_stand = {FRAME_stand101, FRAME_stand140, actor_frames_stand, NULL};

void actor_stand (edict_t *self)
{
	self->monsterinfo.currentmove = &actor_move_stand;

	// randomize on startup
	if (level.time < 1.0)
		self->s.frame = self->monsterinfo.currentmove->firstframe + (rand() % (self->monsterinfo.currentmove->lastframe - self->monsterinfo.currentmove->firstframe + 1));
}


mframe_t actor_frames_walk [] =
{
	ai_walk, 0,  NULL,
	ai_walk, 6,  NULL,
	ai_walk, 10, NULL,
	ai_walk, 3,  NULL,
	ai_walk, 2,  NULL,
	ai_walk, 7,  NULL,
	ai_walk, 10, NULL,
	ai_walk, 1,  NULL,
	ai_walk, 4,  NULL,
	ai_walk, 0,  NULL,
	ai_walk, 0,  NULL
};
mmove_t actor_move_walk = {FRAME_walk01, FRAME_walk08, actor_frames_walk, NULL};

void actor_walk (edict_t *self)
{
	self->monsterinfo.currentmove = &actor_move_walk;
}


mframe_t actor_frames_run [] =
{
	ai_run, 4,  NULL,
	ai_run, 15, NULL,
	ai_run, 15, NULL,
	ai_run, 8,  NULL,
	ai_run, 20, NULL,
	ai_run, 15, NULL,
	ai_run, 8,  NULL,
	ai_run, 17, NULL,
	ai_run, 12, NULL,
	ai_run, -2, NULL,
	ai_run, -2, NULL,
	ai_run, -1, NULL
};
mmove_t actor_move_run = {FRAME_run02, FRAME_run07, actor_frames_run, NULL};

void actor_run (edict_t *self)
{
	if ((level.time < self->pain_debounce_time) && (!self->enemy))
	{
		if (self->movetarget)
			actor_walk(self);
		else
			actor_stand(self);
		return;
	}

	if (self->monsterinfo.aiflags & AI_STAND_GROUND)
	{
		actor_stand(self);
		return;
	}

	self->monsterinfo.currentmove = &actor_move_run;
}


mframe_t actor_frames_pain1 [] =
{
	ai_move, -5, NULL,
	ai_move, 4,  NULL,
	ai_move, 1,  NULL
};
mmove_t actor_move_pain1 = {FRAME_pain101, FRAME_pain103, actor_frames_pain1, actor_run};

mframe_t actor_frames_pain2 [] =
{
	ai_move, -4, NULL,
	ai_move, 4,  NULL,
	ai_move, 0,  NULL
};
mmove_t actor_move_pain2 = {FRAME_pain201, FRAME_pain203, actor_frames_pain2, actor_run};

mframe_t actor_frames_pain3 [] =
{
	ai_move, -1, NULL,
	ai_move, 1,  NULL,
	ai_move, 0,  NULL
};
mmove_t actor_move_pain3 = {FRAME_pain301, FRAME_pain303, actor_frames_pain3, actor_run};

mframe_t actor_frames_flipoff [] =
{
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL
};
mmove_t actor_move_flipoff = {FRAME_flip01, FRAME_flip14, actor_frames_flipoff, actor_run};

mframe_t actor_frames_taunt [] =
{
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL,
	ai_turn, 0,  NULL
};
mmove_t actor_move_taunt = {FRAME_taunt01, FRAME_taunt17, actor_frames_taunt, actor_run};

char *messages[] =
{
	"Watch it",
	"#$@*&",
	"Idiot",
	"Check your targets"
};

void actor_pain (edict_t *self, edict_t *other, float kick, int damage)
{
	int		n;

	if (self->health < (self->max_health / 2))
		self->s.skinnum = 1;

	if (level.time < self->pain_debounce_time)
		return;

	self->pain_debounce_time = level.time + 3;
//	gi.sound (self, CHAN_VOICE, actor.sound_pain, 1, ATTN_NORM, 0);

	if ((other->client) && (random() < 0.4))
	{
		vec3_t	v;
		char	*name;

		VectorSubtract (other->s.origin, self->s.origin, v);
		self->ideal_yaw = vectoyaw (v);
		if (random() < 0.5)
			self->monsterinfo.currentmove = &actor_move_flipoff;
		else
			self->monsterinfo.currentmove = &actor_move_taunt;
		name = actor_names[(self - g_edicts)%MAX_ACTOR_NAMES];
		gi.cprintf (other, PRINT_CHAT, "%s: %s!\n", name, messages[rand()%3]);
		return;
	}

	n = rand() % 3;
	if (n == 0)
		self->monsterinfo.currentmove = &actor_move_pain1;
	else if (n == 1)
		self->monsterinfo.currentmove = &actor_move_pain2;
	else
		self->monsterinfo.currentmove = &actor_move_pain3;
}


void actorMachineGun (edict_t *self)
{
	vec3_t	start, target;
	vec3_t	forward, right;

	AngleVectors (self->s.angles, forward, right, NULL);
	G_ProjectSource (self->s.origin, monster_flash_offset[MZ2_ACTOR_MACHINEGUN_1], forward, right, start);
	if (self->enemy)
	{
		if (self->enemy->health > 0)
		{
			VectorMA (self->enemy->s.origin, -0.2, self->enemy->velocity, target);
			target[2] += self->enemy->viewheight;
		}
		else
		{
			VectorCopy (self->enemy->absmin, target);
			target[2] += (self->enemy->size[2] / 2);
		}
		VectorSubtract (target, start, forward);
		VectorNormalize (forward);
	}
	else
	{
		AngleVectors (self->s.angles, forward, NULL, NULL);
	}
	monster_fire_bullet (self, start, forward, 3, 4, DEFAULT_BULLET_HSPREAD, DEFAULT_BULLET_VSPREAD, MZ2_ACTOR_MACHINEGUN_1);
}


void actor_dead (edict_t *self)
{
	VectorSet (self->mins, -16, -16, -24);
	VectorSet (self->maxs, 16, 16, -8);
	self->movetype = MOVETYPE_TOSS;
	self->svflags |= SVF_DEADMONSTER;
	self->nextthink = 0;
	gi.linkentity (self);
}

mframe_t actor_frames_death1 [] =
{
	ai_move, 0,   NULL,
	ai_move, 0,   NULL,
	ai_move, -13, NULL,
	ai_move, 14,  NULL,
	ai_move, 3,   NULL,
	ai_move, -2,  NULL,
	ai_move, 1,   NULL
};
mmove_t actor_move_death1 = {FRAME_death101, FRAME_death107, actor_frames_death1, actor_dead};

mframe_t actor_frames_death2 [] =
{
	ai_move, 0,   NULL,
	ai_move, 7,   NULL,
	ai_move, -6,  NULL,
	ai_move, -5,  NULL,
	ai_move, 1,   NULL,
	ai_move, 0,   NULL,
	ai_move, -1,  NULL,
	ai_move, -2,  NULL,
	ai_move, -1,  NULL,
	ai_move, -9,  NULL,
	ai_move, -13, NULL,
	ai_move, -13, NULL,
	ai_move, 0,   NULL
};
mmove_t actor_move_death2 = {FRAME_death201, FRAME_death213, actor_frames_death2, actor_dead};

void actor_die (edict_t *self, edict_t *inflictor, edict_t *attacker, int damage, vec3_t point)
{
	int		n;

// check for gib
	if (self->health <= -80)
	{
//		gi.sound (self, CHAN_VOICE, actor.sound_gib, 1, ATTN_NORM, 0);
		for (n= 0; n < 2; n++)
			ThrowGib (self, "models/objects/gibs/bone/tris.md2", damage, GIB_ORGANIC);
		for (n= 0; n < 4; n++)
			ThrowGib (self, "models/objects/gibs/sm_meat/tris.md2", damage, GIB_ORGANIC);
		ThrowHead (self, "models/objects/gibs/head2/tris.md2", damage, GIB_ORGANIC);
		self->deadflag = DEAD_DEAD;
		return;
	}

	if (self->deadflag == DEAD_DEAD)
		return;

// regular death
//	gi.sound (self, CHAN_VOICE, actor.sound_die, 1, ATTN_NORM, 0);
	self->deadflag = DEAD_DEAD;
	self->takedamage = DAMAGE_YES;

	n = rand() % 2;
	if (n == 0)
		self->monsterinfo.currentmove = &actor_move_death1;
	else
		self->monsterinfo.currentmove = &actor_move_death2;
}


void actor_fire (edict_t *self)
{
	actorMachineGun (self);

	if (level.time >= self->monsterinfo.pausetime)
		self->monsterinfo.aiflags &= ~AI_HOLD_FRAME;
	else
		self->monsterinfo.aiflags |= AI_HOLD_FRAME;
}

mframe_t actor_frames_attack [] =
{
	ai_charge, -2,  actor_fire,
	ai_charge, -2,  NULL,
	ai_charge, 3,   NULL,
	ai_charge, 2,   NULL
};
mmove_t actor_move_attack = {FRAME_attak01, FRAME_attak04, actor_frames_attack, actor_run};

void actor_attack(edict_t *self)
{
	int		n;

	self->monsterinfo.currentmove = &actor_move_attack;
	n = (rand() & 15) + 3 + 7;
	self->monsterinfo.pausetime = level.time + n * FRAMETIME;
}


void actor_use (edict_t *self, edict_t *other, edict_t *activator)
{
	vec3_t		v;

	self->goalentity = self->movetarget = G_PickTarget(self->target);
	if ((!self->movetarget) || (strcmp(self->movetarget->classname, "target_actor") != 0))
	{
		gi.dprintf ("%s has bad target %s at %s\n", self->classname, self->target, vtos(self->s.origin));
		self->target = NULL;
		self->monsterinfo.pausetime = 100000000;
		self->monsterinfo.stand (self);
		return;
	}

	VectorSubtract (self->goalentity->s.origin, self->s.origin, v);
	self->ideal_yaw = self->s.angles[YAW] = vectoyaw(v);
	self->monsterinfo.walk (self);
	self->target = NULL;
}


/*QUAKED misc_actor (1 .5 0) (-16 -16 -24) (16 16 32)
*/

void SP_misc_actor (edict_t *self)
{
	if (deathmatch->value)
	{
		G_FreeEdict (self);
		return;
	}

	if (!self->targetname)
	{
		gi.dprintf("untargeted %s at %s\n", self->classname, vtos(self->s.origin));
		G_FreeEdict (self);
		return;
	}

	if (!self->target)
	{
		gi.dprintf("%s with no target at %s\n", self->classname, vtos(self->s.origin));
		G_FreeEdict (self);
		return;
	}

	self->movetype = MOVETYPE_STEP;
	self->solid = SOLID_BBOX;
	self->s.modelindex = gi.modelindex("players/male/tris.md2");
	VectorSet (self->mins, -16, -16, -24);
	VectorSet (self->maxs, 16, 16, 32);

	if (!self->health)
		self->health = 100;
	self->mass = 200;

	self->pain = actor_pain;
	self->die = actor_die;

	self->monsterinfo.stand = actor_stand;
	self->monsterinfo.walk = actor_walk;
	self->monsterinfo.run = actor_run;
	self->monsterinfo.attack = actor_attack;
	self->monsterinfo.melee = NULL;
	self->monsterinfo.sight = NULL;

	self->monsterinfo.aiflags |= AI_GOOD_GUY;

	gi.linkentity (self);

	self->monsterinfo.currentmove = &actor_move_stand;
	self->monsterinfo.scale = MODEL_SCALE;

	walkmonster_start (self);

	// actors always start in a dormant state, they *must* be used to get going
	self->use = actor_use;
}


/*QUAKED target_actor (.5 .3 0) (-8 -8 -8) (8 8 8) JUMP SHOOT ATTACK x HOLD BRUTAL
JUMP			jump in set direction upon reaching this target
SHOOT			take a single shot at the pathtarget
ATTACK			attack pathtarget until it or actor is dead 

"target"		next target_actor
"pathtarget"	target of any action to be taken at this point
"wait"			amount of time actor should pause at this point
"message"		actor will "say" this to the player

for JUMP only:
"speed"			speed thrown forward (default 200)
"height"		speed thrown upwards (default 200)
*/

void target_actor_touch (edict_t *self, edict_t *other, cplane_t *plane, csurface_t *surf)
{
	vec3_t	v;

	if (other->movetarget != self)
		return;
	
	if (other->enemy)
		return;

	other->goalentity = other->movetarget = NULL;

	if (self->message)
	{
		int		n;
		edict_t	*ent;

		for (n = 1; n <= game.maxclients; n++)
		{
			ent = &g_edicts[n];
			if (!ent->inuse)
				continue;
			gi.cprintf (ent, PRINT_CHAT, "%s: %s\n", actor_names[(other - g_edicts)%MAX_ACTOR_NAMES], self->message);
		}
	}

	if (self->spawnflags & 1)		//jump
	{
		other->velocity[0] = self->movedir[0] * self->speed;
		other->velocity[1] = self->movedir[1] * self->speed;
		
		if (other->groundentity)
		{
			other->groundentity = NULL;
			other->velocity[2] = self->movedir[2];
			gi.sound(other, CHAN_VOICE, gi.soundindex("player/male/jump1.wav"), 1, ATTN_NORM, 0);
		}
	}

	if (self->spawnflags & 2)	//shoot
	{
	}
	else if (self->spawnflags & 4)	//attack
	{
		other->enemy = G_PickTarget(self->pathtarget);
		if (other->enemy)
		{
			other->goalentity = other->enemy;
			if (self->spawnflags & 32)
				other->monsterinfo.aiflags |= AI_BRUTAL;
			if (self->spawnflags & 16)
			{
				other->monsterinfo.aiflags |= AI_STAND_GROUND;
				actor_stand (other);
			}
			else
			{
				actor_run (other);
			}
		}
	}

	if (!(self->spawnflags & 6) && (self->pathtarget))
	{
		char *savetarget;

		savetarget = self->target;
		self->target = self->pathtarget;
		G_UseTargets (self, other);
		self->target = savetarget;
	}

	other->movetarget = G_PickTarget(self->target);

	if (!other->goalentity)
		other->goalentity = other->movetarget;

	if (!other->movetarget && !other->enemy)
	{
		other->monsterinfo.pausetime = level.time + 100000000;
		other->monsterinfo.stand (other);
	}
	else if (other->movetarget == other->goalentity)
	{
		VectorSubtract (other->movetarget->s.origin, other->s.origin, v);
		other->ideal_yaw = vectoyaw (v);
	}
}

void SP_target_actor (edict_t *self)
{
	if (!self->targetname)
		gi.dprintf ("%s with no targetname at %s\n", self->classname, vtos(self->s.origin));

	self->solid = SOLID_TRIGGER;
	self->touch = target_actor_touch;
	VectorSet (self->mins, -8, -8, -8);
	VectorSet (self->maxs, 8, 8, 8);
	self->svflags = SVF_NOCLIENT;

	if (self->spawnflags & 1)
	{
		if (!self->speed)
			self->speed = 200;
		if (!st.height)
			st.height = 200;
		if (self->s.angles[YAW] == 0)
			self->s.angles[YAW] = 360;
		G_SetMovedir (self->s.angles, self->movedir);
		self->movedir[2] = st.height;
	}

	gi.linkentity (self);
}
