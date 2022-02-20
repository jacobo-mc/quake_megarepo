/*
Copyright (C) 1996-1997 Id Software, Inc.

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

#ifndef SOUND_H
#define SOUND_H

#include "cvar.h"
#include "mathlib.h"
#include "qtypes.h"
#include "zone.h"

#ifdef NQ_HACK
#include "quakedef.h"
#endif
#ifdef QW_HACK
#include "bothdefs.h"
#endif

// sound.h -- client sound i/o functions

// FIXME - QW defines these in protocol.h, which is better?
#ifdef NQ_HACK
#define DEFAULT_SOUND_PACKET_VOLUME 255
#define DEFAULT_SOUND_PACKET_ATTENUATION 1.0
#endif

// !!! if this is changed, it much be changed in asm_i386.h too !!!
typedef struct {
    int left;
    int right;
} portable_samplepair_t;

typedef struct sfx_s {
    char name[MAX_QPATH];
    cache_user_t cache;
} sfx_t;

// !!! if this is changed, it much be changed in asm_i386.h too !!!
typedef struct {
    int length;
    int loopstart;
    int alloc_samples;
    int speed;
    uint16_t width;
    uint16_t stereo;
    byte data[0];		// variable sized
} sfxcache_t;

typedef struct {
    int channels;
    int samples;		// mono samples in buffer
    int submission_chunk;	// don't mix less than this #
    int samplepos;		// in mono samples
    int samplebits;
    int speed;
    unsigned char *buffer;
} dma_t;

// !!! if this is changed, it much be changed in asm_i386.h too !!!
typedef struct {
    sfx_t *sfx;			// sfx number
    int leftvol;		// 0-255 volume
    int rightvol;		// 0-255 volume
    int end;			// end time in global paintsamples
    int pos;			// sample position in sfx
    int looping;		// where to loop, -1 = no looping
    int entnum;			// to allow overriding a specific sound
    int entchannel;		//
    vec3_t origin;		// origin of sound effect
    vec_t dist_mult;		// distance multiplier (attenuation/clipK)
    int master_vol;		// 0-255 master volume
    int kill;                   // Number of samples left, ramping down volume
} channel_t;

void S_AddCommands();
void S_RegisterVariables();
void S_Init();
void S_HunkAllocFilterBuffers();
void S_ClearOverflow();

void S_Music_RegisterVariables();
void S_Music_AddCommands();
void S_Music_Init();
void S_InitMusicFilterParams(int sample_rate, int cutoff_frequency);
void S_FilterMusic(int16_t *samples, int numsamples);

void S_Startup(void);
void S_Shutdown(void);
void S_StartSound(int entnum, int entchannel, sfx_t *sfx,
		  vec3_t origin, float fvol, float attenuation);
void S_StaticSound(sfx_t *sfx, vec3_t origin, float vol, float attenuation);
void S_StopSound(int entnum, int entchannel);
void S_StopAllSounds(qboolean clear);
void S_ClearBuffer(void);
void S_Update(vec3_t origin, vec3_t v_forward, vec3_t v_right, vec3_t v_up);
void S_ExtraUpdate(void);

void S_BlockSound(void);
void S_UnblockSound(void);

sfx_t *S_PrecacheSound(const char *sample);
void S_TouchSound(const char *sample);
void S_BeginPrecaching(void);
void S_EndPrecaching(void);
void S_PaintChannels(int endtime);
void S_InitPaintChannels(void);
void S_PaintMusic(portable_samplepair_t *buffer, int numsamples);

// Background Music
void BGM_Stop();
void BGM_PlayCDTrack(byte track, qboolean looping);
void BGM_ClearBuffers();

// initializes cycling through a DMA buffer and returns information on it
qboolean SNDDMA_Init(void);

// gets the current DMA position
int SNDDMA_GetDMAPos(void);

/* Lock and unlock the DMA sound buffer */
int SNDDMA_LockBuffer(void);
void SNDDMA_UnlockBuffer(void);

// shutdown the DMA xfer.
void SNDDMA_Shutdown(void);

// ====================================================================
// User-setable variables
// ====================================================================

#define	MAX_CHANNELS		512
#define	MAX_DYNAMIC_CHANNELS	128

extern channel_t channels[MAX_CHANNELS];

// 0 to MAX_DYNAMIC_CHANNELS-1  = normal entity sounds
// MAX_DYNAMIC_CHANNELS to MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS -1 = water, etc
// MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS to total_channels = static sounds

extern int total_channels;

extern int paintedtime;
extern dma_t *shm;

extern int snd_ramp_count;
extern const byte *snd_ramp;
void S_InitRamp();

extern cvar_t loadas8bit;
extern cvar_t bgmvolume;
extern cvar_t sfxvolume;
extern cvar_t _snd_mixahead;
extern cvar_t snd_filterquality;

extern int snd_blocked;

void S_LocalSound(const char *s);
sfxcache_t *S_LoadSound(sfx_t *s);

void SND_InitScaletable(void);
void SNDDMA_Submit(void);

void S_AmbientOff(void);
void S_AmbientOn(void);

#endif /* SOUND_H */
