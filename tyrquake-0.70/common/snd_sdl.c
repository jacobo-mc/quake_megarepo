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

#include <assert.h>
#include <stdio.h>

#include "SDL.h"
#include "SDL_audio.h"
#include "SDL_endian.h"

#include "common.h"
#include "console.h"
#include "quakedef.h"
#include "sdl_common.h"
#include "sound.h"
#include "sys.h"

#define SND_DEFAULT_BITS 16
#define SND_DEFAULT_RATE 48000

static dma_t the_shm;
static int snd_inited;
static int sdl_read_index;

/*
 * paint_audio()
 *
 * SDL calls this function from another thread, so any shared variables need
 * access to be serialised in some way. We use SDL_LockAudio() to ensure the
 * SDL thread is locked out before we update the shared buffer or read/write
 * positions.
 */
static void
paint_audio(void *unused, Uint8 *stream, int len)
{
    assert(!(len % (shm->channels * shm->samplebits)));

    int read_buffer_size = shm->samples * (shm->samplebits / 8);
    while (sdl_read_index + len > read_buffer_size) {
        int copy_size = read_buffer_size - sdl_read_index;
        memcpy(stream, shm->buffer + sdl_read_index, copy_size);
        stream += copy_size;
        len -= copy_size;
        sdl_read_index = 0;
    }
    if (len) {
        memcpy(stream, shm->buffer + sdl_read_index, len);
        sdl_read_index = (sdl_read_index + len) & (read_buffer_size - 1);
    }
}

qboolean
SNDDMA_Init(void)
{
    int argnum;
    int desired_bits;
    SDL_AudioSpec desired, obtained;

    snd_inited = 0;

    /* Set up the desired format */
    desired.freq = SND_DEFAULT_RATE;
    argnum = COM_CheckParm("-sndspeed");
    if (argnum)
        desired.freq = atoi(com_argv[argnum + 1]);

    desired_bits = SND_DEFAULT_BITS;
    argnum = COM_CheckParm("-sndbits");
    if (argnum) {
        int specified_bits = atoi(com_argv[argnum + 1]);
        if (specified_bits == 8 || specified_bits == 16) {
            desired_bits = specified_bits;
        } else {
            Con_Printf("WARNING: ignoring invalid -sndbits %d; must be 8 or 16\n", specified_bits);
        }
    }

    switch (desired_bits) {
    case 8:
	desired.format = AUDIO_U8;
	break;
    case 16:
	if (SDL_BYTEORDER == SDL_BIG_ENDIAN)
	    desired.format = AUDIO_S16MSB;
	else
	    desired.format = AUDIO_S16LSB;
	break;
    default:
	Con_Printf("Unknown number of audio bits: %d\n", desired_bits);
	return false;
    }

    argnum = COM_CheckParm("-sndmono");
    if (argnum)
        desired.channels = 1;
    else
        desired.channels = 2;

    /*
     * Selecting the nearest power of two samples, just under half the
     * mixahead buffer seems about right.  This is ~50ms by default.
     */
    desired.samples = 1 << Q_log2(desired.freq * _snd_mixahead.value * 0.5f);
    desired.callback = paint_audio;

    /* Init the SDL Audio Sub-system */
    Q_SDL_InitOnce();
    if (SDL_InitSubSystem(SDL_INIT_AUDIO) < 0) {
	Con_Printf("Couldn't init SDL audio: %s\n", SDL_GetError());
	return false;
    }

    /* Open the audio device */
    if (SDL_OpenAudio(&desired, &obtained) < 0) {
	Con_Printf("Couldn't open SDL audio: %s\n", SDL_GetError());
	return false;
    }

    /* Make sure we can support the audio format */
    switch (obtained.format) {
    case AUDIO_U8:
	/* Supported */
	break;
    case AUDIO_S16LSB:
    case AUDIO_S16MSB:
	if (((obtained.format == AUDIO_S16LSB) &&
	     (SDL_BYTEORDER == SDL_LIL_ENDIAN)) ||
	    ((obtained.format == AUDIO_S16MSB) &&
	     (SDL_BYTEORDER == SDL_BIG_ENDIAN))) {
	    /* Supported */
	    break;
	}
	/* Unsupported, fall through */;
    default:
	/* Not supported -- force SDL to do our bidding */
	SDL_CloseAudio();
	if (SDL_OpenAudio(&desired, NULL) < 0) {
	    Con_Printf("Couldn't open SDL audio: %s\n",
		       SDL_GetError());
	    return 0;
	}
	memcpy(&obtained, &desired, sizeof(desired));
	break;
    }

    /* Fill the audio DMA information block */
    shm = &the_shm;
    shm->samplebits = (obtained.format & 0xFF);
    shm->speed = obtained.freq;
    shm->channels = obtained.channels;
    shm->samplepos = 0;
    shm->submission_chunk = 1;

    /* Allow enough SHM buffer to mix ahead up to 0.5 seconds. */
    shm->samples = 1 << Q_log2(shm->speed * shm->channels / 2);

    int buffer_size = shm->samples * (shm->samplebits / 8);
    shm->buffer = Hunk_AllocName(buffer_size, "shm->buffer");
    memset(shm->buffer, obtained.silence, buffer_size);
    snd_inited = 1;

    /* FIXME - hack because sys_win does this differently */
    snd_blocked = 0;

    SDL_PauseAudio(0);

    return true;
}

int
SNDDMA_GetDMAPos(void)
{
    if (!snd_inited)
	return 0;

    SDL_LockAudio();
    shm->samplepos = sdl_read_index / (shm->samplebits / 8);
    SDL_UnlockAudio();

    return shm->samplepos;
}

void
SNDDMA_Shutdown(void)
{
    if (snd_inited) {
	SDL_CloseAudio();
	snd_inited = 0;
    }
}

/*
==============
SNDDMA_Submit

Send sound to device if buffer isn't really the dma buffer
===============
*/
void SNDDMA_Submit(void)
{
}

void
S_BlockSound(void)
{
    if (!snd_blocked)
	SDL_PauseAudio(1);
    snd_blocked++;
}

void
S_UnblockSound(void)
{
    snd_blocked--;
    if (!snd_blocked)
	SDL_PauseAudio(0);
}

int
SNDDMA_LockBuffer()
{
    SDL_LockAudio();
    return 0;
}

void
SNDDMA_UnlockBuffer()
{
    SDL_UnlockAudio();
}
