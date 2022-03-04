/*
	sound.h

	Sound headers.

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
// sound.h -- client sound i/o functions

#ifndef __QF_sound_h
#define __QF_sound_h

/** \defgroup sound QuakeForge sound engine
*/

#include "QF/mathlib.h"

/**
	\ingroup sound
*/
///@{
typedef struct sfx_s sfx_t;
struct sfx_s
{
	struct snd_s *snd;			//!< ownding snd_t instance
	const char *name;
	sfx_t      *owner;

	unsigned int length;
	unsigned int loopstart;

	union {
		struct sfxstream_s *stream;
		struct sfxblock_s *block;
	} data;

	struct sfxbuffer_s *(*touch) (sfx_t *sfx);
	struct sfxbuffer_s *(*retain) (sfx_t *sfx);
	void        (*release) (sfx_t *sfx);

	struct sfxbuffer_s *(*getbuffer) (sfx_t *sfx);
	struct wavinfo_s *(*wavinfo) (sfx_t *sfx);

	sfx_t      *(*open) (sfx_t *sfx);
	void        (*close) (sfx_t *sfx);
};
///@}

struct model_s;

/** \defgroup sound_init Initialization functions
	\ingroup sound
*/
///@{

/** Initialize the sound engine.
	\param viewentity pointer to view entity index
	\param host_frametime pointer to host frame time difference
*/
void S_Init (int *viewentity, double *host_frametime);

/** Initialize the Cvars for the sound engine. Call before calling S_Init().
*/
void S_Init_Cvars (void);

/** Shutdown the sound engine. Allows audio output modules to shutdown
	gracefully.
*/
void S_Shutdown (void);
///@}

/** \defgroup sound_stuff Unclassified
	\ingroup sound
*/
///@{

/** Start a sound playing.
	\param entnum	index of entity the sound is associated with.
	\param entchannel 0-7
		- 0 auto (never willingly overrides)
		- 1 weapon
		- 2 voice
		- 3 item
		- 4 body
	\param sfx		sound to play
	\param origin	3d coords of where the sound originates
	\param vol		absolute volume of the sound
	\param attenuation rate of volume dropoff vs distance
*/
void S_StartSound (int entnum, int entchannel, sfx_t *sfx, const vec3_t origin,
				   float vol,  float attenuation);

/** Create a sound generated by the world.
	\param sfx		sound to play
	\param origin	3d coords of where the sound originates
	\param vol		absolute volume of the sound
	\param attenuation rate of volume dropoff vs distance
*/
void S_StaticSound (sfx_t *sfx, const vec3_t origin, float vol,
					float attenuation);
/** Stop an entity's sound.
	\param entnum	index of entity the sound is associated with.
	\param entchannel channel to silence
*/
void S_StopSound (int entnum, int entchannel);

/** Stop all sounds from playing.
*/
void S_StopAllSounds(void);

/** Update the sound engine with the client's position and orientation and
	render some sound.
	\param origin	3d coords of the client
	\param v_forward 3d vector of the client's facing direction
	\param v_right	3d vector of the client's rightward direction
	\param v_up		3d vector of the client's upward direction
	\param ambient_sound_level NUM_AMBIENTS bytes indicating current ambient
					sound levels
*/
void S_Update (const vec3_t origin, const vec3_t v_forward,
			   const vec3_t v_right, const vec3_t v_up,
			   const byte *ambient_sound_level);

/** Render some more sound without updating the client's position/orientation.
*/
void S_ExtraUpdate (void);

/** Pause the sound output. Nested blocking is supported, so calls to
	S_BlockSound() and S_UnblockSound() must be balanced.
*/
void S_BlockSound (void);

/** Unpause the sound output. Nested blocking is supported, so calls to
	S_BlockSound() and S_UnblockSound() must be balanced.
*/
void S_UnblockSound (void);

/** Pre-load a sound into the cache.
	\param sample	name of sound to precache
*/
sfx_t *S_PrecacheSound (const char *sample);

/** Pre-load a sound.
	\param name		name of sound to load
*/
sfx_t *S_LoadSound (const char *name);

/** Allocate a sound channel that can be used for playing sounds.
*/
struct channel_s *S_AllocChannel (void);

/** Stop and safely free a channel.
	\param chan		channel to stop
*/
void S_ChannelStop (struct channel_s *chan);

/** Start a sound local to the client view.
	\param s name of sound to play
*/
void S_LocalSound (const char *s);

/** Disable ambient sounds.
	\todo not used, remove?
*/
void S_AmbientOff (void);

/** Enable ambient sounds.
	\todo not used, remove?
*/
void S_AmbientOn (void);

/** Link sound engine builtins into the specified progs vm
	\param pr	the vm to link the builtins into.
*/
struct progs_s;
void S_Progs_Init (struct progs_s *pr);

///@}

#endif//__QF_sound_h