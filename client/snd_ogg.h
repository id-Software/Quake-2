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

// snd_ogg.h -- Ogg Vorbis streaming functions

#ifndef _SND_OGG_H_
#define _SND_OGG_H_

// bypass filesystem for streaming audio to get around FS_Read 0 bytes error
#define OGG_DIRECT_FILE

typedef enum {
	PLAY,
	PAUSE,
	STOP
} ogg_status_t;

typedef enum {
	ABS,
	REL
} ogg_seek_t;

// snd_stream.c
extern int sound_started;

void S_UpdateBackgroundTrack (void);
void S_StartBackgroundTrack (const char *introTrack, const char *loopTrack);
void S_StopBackgroundTrack (void);
void S_StartStreaming (void);
void S_StopStreaming (void);
void S_OGG_Init (void);
void S_OGG_Shutdown (void);
void S_OGG_Restart (void);
void S_OGG_LoadFileList (void);
void S_OGG_ParseCmd (void);

#endif
