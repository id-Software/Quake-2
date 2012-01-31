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
/*
==============================================================================

insane

==============================================================================
*/

#include "g_local.h"
#include "m_insane.h"


static int	sound_fist;
static int	sound_shake;
static int	sound_moan;
static int	sound_scream[8];

void insane_fist (edict_t *self)
{
	gi.sound (self, CHAN_VOICE, sound_fist, 1, ATTN_IDLE, 0);
}

void insane_shake (edict_t *self)
{
	gi.sound (self, CHAN_VOICE, sound_shake, 1, ATTN_IDLE, 0);
}

void insane_moan (edict_t *self)
{
	gi.sound (self, CHAN_VOICE, sound_moan, 1, ATTN_IDLE, 0);
}

void insane_scream (edict_t *self)
{
	gi.sound (self, CHAN_VOICE, sound_scream[rand()%8], 1, ATTN_IDLE, 0);
}


void insane_stand (edict_t *self);
void insane_dead (edict_t *self);
void insane_cross (edict_t *self);
void insane_walk (edict_t *self);
void insane_run (edict_t *self);
void insane_checkdown (edict_t *self);
void insane_checkup (edict_t *self);
void insane_onground (edict_t *self);


mframe_t insane_frames_stand_normal [] =
{
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, NULL,
	ai_stand, 0, insane_checkdown
};
mmove_t insane_move_stand_normal = {FRAME_stand60, FRAME_stand65, insane_frames_stand_normal, insane_stand};

mframe_t insane_frames_stand_insane [] =
{
	ai_stand,	0,	insane_shake,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	NULL,
	ai_stand,	0,	insane_checkdown
};
mmove_t insane_move_stand_insane = {FRAME_stand65, FRAME_stand94, insane_frames_stand_insane, insane_stand};

mframe_t insane_frames_uptodown [] =
{
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	insane_moan,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,

	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,

	ai_move,	2.7,	NULL,
	ai_move,	4.1,	NULL,
	ai_move,	6,		NULL,
	ai_move,	7.6,	NULL,
	ai_move,	3.6,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	insane_fist,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,

	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	insane_fist,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL,
	ai_move,	0,	NULL
};
mmove_t insane_move_uptodown = {FRAME_stand1, FRAME_stand40, insane_frames_uptodown, insane_onground};


mframe_t insane_frames_downtoup [] =
{
	ai_move,	-0.7,	NULL,			// 41
	ai_move,	-1.2,	NULL,			// 42
	ai_move,	-1.5,		NULL,		// 43
	ai_move,	-4.5,		NULL,		// 44
	ai_move,	-3.5,	NULL,			// 45
	ai_move,	-0.2,	NULL,			// 46
	ai_move,	0,	NULL,			// 47
	ai_move,	-1.3,	NULL,			// 48
	ai_move,	-3,	NULL,				// 49
	ai_move,	-2,	NULL,			// 50
	ai_move,	0,	NULL,				// 51
	ai_move,	0,	NULL,				// 52
	ai_move,	0,	NULL,				// 53
	ai_move,	-3.3,	NULL,			// 54
	ai_move,	-1.6,	NULL,			// 55
	ai_move,	-0.3,	NULL,			// 56
	ai_move,	0,	NULL,				// 57
	ai_move,	0,	NULL,				// 58
	ai_move,	0,	NULL				// 59
};
mmove_t insane_move_downtoup = {FRAME_stand41, FRAME_stand59, insane_frames_downtoup, insane_stand};

mframe_t insane_frames_jumpdown [] =
{
	ai_move,	0.2,	NULL,
	ai_move,	11.5,	NULL,
	ai_move,	5.1,	NULL,
	ai_move,	7.1,	NULL,
	ai_move,	0,	NULL
};
mmove_t insane_move_jumpdown = {FRAME_stand96, FRAME_stand100, insane_frames_jumpdown, insane_onground};


mframe_t insane_frames_down [] =
{
	ai_move,	0,		NULL,		// 100
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,		// 110
	ai_move,	-1.7,		NULL,
	ai_move,	-1.6,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		insane_fist,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,		// 120
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,		// 130
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		insane_moan,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,		// 140
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,		// 150
	ai_move,	0.5,		NULL,
	ai_move,	0,		NULL,
	ai_move,	-0.2,		insane_scream,
	ai_move,	0,		NULL,
	ai_move,	0.2,		NULL,
	ai_move,	0.4,		NULL,
	ai_move,	0.6,		NULL,
	ai_move,	0.8,		NULL,
	ai_move,	0.7,		NULL,
	ai_move,	0,		insane_checkup		// 160
};
mmove_t insane_move_down = {FRAME_stand100, FRAME_stand160, insane_frames_down, insane_onground};

mframe_t insane_frames_walk_normal [] =
{
	ai_walk,	0,		insane_scream,
	ai_walk,	2.5,	NULL,
	ai_walk,	3.5,	NULL,
	ai_walk,	1.7,	NULL,
	ai_walk,	2.3,	NULL,
	ai_walk,	2.4,	NULL,
	ai_walk,	2.2,	NULL,
	ai_walk,	4.2,	NULL,
	ai_walk,	5.6,	NULL,
	ai_walk,	3.3,	NULL,
	ai_walk,	2.4,	NULL,
	ai_walk,	0.9,	NULL,
	ai_walk,	0,		NULL
};
mmove_t insane_move_walk_normal = {FRAME_walk27, FRAME_walk39, insane_frames_walk_normal, insane_walk};
mmove_t insane_move_run_normal = {FRAME_walk27, FRAME_walk39, insane_frames_walk_normal, insane_run};

mframe_t insane_frames_walk_insane [] =
{
	ai_walk,	0,		insane_scream,		// walk 1
	ai_walk,	3.4,	NULL,		// walk 2
	ai_walk,	3.6,	NULL,		// 3
	ai_walk,	2.9,	NULL,		// 4
	ai_walk,	2.2,	NULL,		// 5
	ai_walk,	2.6,	NULL,		// 6
	ai_walk,	0,		NULL,		// 7
	ai_walk,	0.7,	NULL,		// 8
	ai_walk,	4.8,	NULL,		// 9
	ai_walk,	5.3,	NULL,		// 10
	ai_walk,	1.1,	NULL,		// 11
	ai_walk,	2,		NULL,		// 12
	ai_walk,	0.5,	NULL,		// 13
	ai_walk,	0,		NULL,		// 14
	ai_walk,	0,		NULL,		// 15
	ai_walk,	4.9,	NULL,		// 16
	ai_walk,	6.7,	NULL,		// 17
	ai_walk,	3.8,	NULL,		// 18
	ai_walk,	2,		NULL,		// 19
	ai_walk,	0.2,	NULL,		// 20
	ai_walk,	0,		NULL,		// 21
	ai_walk,	3.4,	NULL,		// 22
	ai_walk,	6.4,	NULL,		// 23
	ai_walk,	5,		NULL,		// 24
	ai_walk,	1.8,	NULL,		// 25
	ai_walk,	0,		NULL		// 26
};
mmove_t insane_move_walk_insane = {FRAME_walk1, FRAME_walk26, insane_frames_walk_insane, insane_walk};
mmove_t insane_move_run_insane = {FRAME_walk1, FRAME_walk26, insane_frames_walk_insane, insane_run};

mframe_t insane_frames_stand_pain [] =
{
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_stand_pain = {FRAME_st_pain2, FRAME_st_pain12, insane_frames_stand_pain, insane_run};

mframe_t insane_frames_stand_death [] =
{
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_stand_death = {FRAME_st_death2, FRAME_st_death18, insane_frames_stand_death, insane_dead};

mframe_t insane_frames_crawl [] =
{
	ai_walk,	0,		insane_scream,
	ai_walk,	1.5,	NULL,
	ai_walk,	2.1,	NULL,
	ai_walk,	3.6,	NULL,
	ai_walk,	2,		NULL,
	ai_walk,	0.9,	NULL,
	ai_walk,	3,		NULL,
	ai_walk,	3.4,	NULL,
	ai_walk,	2.4,	NULL
};
mmove_t insane_move_crawl = {FRAME_crawl1, FRAME_crawl9, insane_frames_crawl, NULL};
mmove_t insane_move_runcrawl = {FRAME_crawl1, FRAME_crawl9, insane_frames_crawl, NULL};

mframe_t insane_frames_crawl_pain [] =
{
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_crawl_pain = {FRAME_cr_pain2, FRAME_cr_pain10, insane_frames_crawl_pain, insane_run};

mframe_t insane_frames_crawl_death [] =
{
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_crawl_death = {FRAME_cr_death10, FRAME_cr_death16, insane_frames_crawl_death, insane_dead};

mframe_t insane_frames_cross [] =
{
	ai_move,	0,		insane_moan,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_cross = {FRAME_cross1, FRAME_cross15, insane_frames_cross, insane_cross};

mframe_t insane_frames_struggle_cross [] =
{
	ai_move,	0,		insane_scream,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL,
	ai_move,	0,		NULL
};
mmove_t insane_move_struggle_cross = {FRAME_cross16, FRAME_cross30, insane_frames_struggle_cross, insane_cross};

void insane_cross (edict_t *self)
{
	if (random() < 0.8)		
		self->monsterinfo.currentmove = &insane_move_cross;
	else
		self->monsterinfo.currentmove = &insane_move_struggle_cross;
}

void insane_walk (edict_t *self)
{
	if ( self->spawnflags & 16 )			// Hold Ground?
		if (self->s.frame == FRAME_cr_pain10)
		{
			self->monsterinfo.currentmove = &insane_move_down;
			return;
		}
	if (self->spawnflags & 4)
		self->monsterinfo.currentmove = &insane_move_crawl;
	else
		if (random() <= 0.5)
			self->monsterinfo.currentmove = &insane_move_walk_normal;
		else
			self->monsterinfo.currentmove = &insane_move_walk_insane;
}

void insane_run (edict_t *self)
{
	if ( self->spawnflags & 16 )			// Hold Ground?
		if (self->s.frame == FRAME_cr_pain10)
		{
			self->monsterinfo.currentmove = &insane_move_down;
			return;
		}
	if (self->spawnflags & 4)				// Crawling?
		self->monsterinfo.currentmove = &insane_move_runcrawl;
	else
		if (random() <= 0.5)				// Else, mix it up
			self->monsterinfo.currentmove = &insane_move_run_normal;
		else
			self->monsterinfo.currentmove = &insane_move_run_insane;
}


void insane_pain (edict_t *self, edict_t *other, float kick, int damage)
{
	int	l,r;

//	if (self->health < (self->max_health / 2))
//		self->s.skinnum = 1;

	if (level.time < self->pain_debounce_time)
		return;

	self->pain_debounce_time = level.time + 3;

	r = 1 + (rand()&1);
	if (self->health < 25)
		l = 25;
	else if (self->health < 50)
		l = 50;
	else if (self->health < 75)
		l = 75;
	else
		l = 100;
	gi.sound (self, CHAN_VOICE, gi.soundindex (va("player/male/pain%i_%i.wav", l, r)), 1, ATTN_IDLE, 0);

	if (skill->value == 3)
		return;		// no pain anims in nightmare

	// Don't go into pain frames if crucified.
	if (self->spawnflags & 8)
	{
		self->monsterinfo.currentmove = &insane_move_struggle_cross;			
		return;
	}
	
	if  ( ((self->s.frame >= FRAME_crawl1) && (self->s.frame <= FRAME_crawl9)) || ((self->s.frame >= FRAME_stand99) && (self->s.frame <= FRAME_stand160)) )
	{
		self->monsterinfo.currentmove = &insane_move_crawl_pain;
	}
	else
		self->monsterinfo.currentmove = &insane_move_stand_pain;

}

void insane_onground (edict_t *self)
{
	self->monsterinfo.currentmove = &insane_move_down;
}

void insane_checkdown (edict_t *self)
{
//	if ( (self->s.frame == FRAME_stand94) || (self->s.frame == FRAME_stand65) )
	if (self->spawnflags & 32)				// Always stand
		return;
	if (random() < 0.3)
		if (random() < 0.5)
			self->monsterinfo.currentmove = &insane_move_uptodown;
		else
			self->monsterinfo.currentmove = &insane_move_jumpdown; 
}

void insane_checkup (edict_t *self)
{
	// If Hold_Ground and Crawl are set
	if ( (self->spawnflags & 4) && (self->spawnflags & 16) )
		return;
	if (random() < 0.5)
		self->monsterinfo.currentmove = &insane_move_downtoup;				

}

void insane_stand (edict_t *self)
{
	if (self->spawnflags & 8)			// If crucified
	{
		self->monsterinfo.currentmove = &insane_move_cross;
		self->monsterinfo.aiflags |= AI_STAND_GROUND;
	}
	// If Hold_Ground and Crawl are set
	else if ( (self->spawnflags & 4) && (self->spawnflags & 16) )
		self->monsterinfo.currentmove = &insane_move_down;
	else
		if (random() < 0.5)
			self->monsterinfo.currentmove = &insane_move_stand_normal;
		else
			self->monsterinfo.currentmove = &insane_move_stand_insane;
}

void insane_dead (edict_t *self)
{
	if (self->spawnflags & 8)
	{
		self->flags |= FL_FLY;
	}
	else
	{
		VectorSet (self->mins, -16, -16, -24);
		VectorSet (self->maxs, 16, 16, -8);
		self->movetype = MOVETYPE_TOSS;
	}
	self->svflags |= SVF_DEADMONSTER;
	self->nextthink = 0;
	gi.linkentity (self);
}


void insane_die (edict_t *self, edict_t *inflictor, edict_t *attacker, int damage, vec3_t point)
{
	int		n;

	if (self->health <= self->gib_health)
	{
		gi.sound (self, CHAN_VOICE, gi.soundindex ("misc/udeath.wav"), 1, ATTN_IDLE, 0);
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

	gi.sound (self, CHAN_VOICE, gi.soundindex(va("player/male/death%i.wav", (rand()%4)+1)), 1, ATTN_IDLE, 0);

	self->deadflag = DEAD_DEAD;
	self->takedamage = DAMAGE_YES;

	if (self->spawnflags & 8)
	{
		insane_dead (self);
	}
	else
	{
		if ( ((self->s.frame >= FRAME_crawl1) && (self->s.frame <= FRAME_crawl9)) || ((self->s.frame >= FRAME_stand99) && (self->s.frame <= FRAME_stand160)) )		
			self->monsterinfo.currentmove = &insane_move_crawl_death;
		else
			self->monsterinfo.currentmove = &insane_move_stand_death;
	}
}


/*QUAKED misc_insane (1 .5 0) (-16 -16 -24) (16 16 32) Ambush Trigger_Spawn CRAWL CRUCIFIED STAND_GROUND ALWAYS_STAND
*/
void SP_misc_insane (edict_t *self)
{
//	static int skin = 0;	//@@

	if (deathmatch->value)
	{
		G_FreeEdict (self);
		return;
	}

	sound_fist = gi.soundindex ("insane/insane11.wav");
	sound_shake = gi.soundindex ("insane/insane5.wav");
	sound_moan = gi.soundindex ("insane/insane7.wav");
	sound_scream[0] = gi.soundindex ("insane/insane1.wav");
	sound_scream[1] = gi.soundindex ("insane/insane2.wav");
	sound_scream[2] = gi.soundindex ("insane/insane3.wav");
	sound_scream[3] = gi.soundindex ("insane/insane4.wav");
	sound_scream[4] = gi.soundindex ("insane/insane6.wav");
	sound_scream[5] = gi.soundindex ("insane/insane8.wav");
	sound_scream[6] = gi.soundindex ("insane/insane9.wav");
	sound_scream[7] = gi.soundindex ("insane/insane10.wav");

	self->movetype = MOVETYPE_STEP;
	self->solid = SOLID_BBOX;
	self->s.modelindex = gi.modelindex("models/monsters/insane/tris.md2");

	VectorSet (self->mins, -16, -16, -24);
	VectorSet (self->maxs, 16, 16, 32);

	self->health = 100;
	self->gib_health = -50;
	self->mass = 300;

	self->pain = insane_pain;
	self->die = insane_die;

	self->monsterinfo.stand = insane_stand;
	self->monsterinfo.walk = insane_walk;
	self->monsterinfo.run = insane_run;
	self->monsterinfo.dodge = NULL;
	self->monsterinfo.attack = NULL;
	self->monsterinfo.melee = NULL;
	self->monsterinfo.sight = NULL;
	self->monsterinfo.aiflags |= AI_GOOD_GUY;

//@@
//	self->s.skinnum = skin;
//	skin++;
//	if (skin > 12)
//		skin = 0;

	gi.linkentity (self);

	if (self->spawnflags & 16)				// Stand Ground
		self->monsterinfo.aiflags |= AI_STAND_GROUND;

	self->monsterinfo.currentmove = &insane_move_stand_normal;
	
	self->monsterinfo.scale = MODEL_SCALE;

	if (self->spawnflags & 8)					// Crucified ?
	{
		VectorSet (self->mins, -16, 0, 0);
		VectorSet (self->maxs, 16, 8, 32);
		self->flags |= FL_NO_KNOCKBACK;
		flymonster_start (self);
	}
	else
	{
		walkmonster_start (self);
		self->s.skinnum = rand()%3;
	}
}
