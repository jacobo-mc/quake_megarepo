/*
 * Copyright (c) 2010 Jacob Meuser <jakemsr@sdf.lonestar.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <errno.h>

#include <sndio.h>

#include "common.h"
#include "console.h"
#include "quakedef.h"
#include "sound.h"

static struct snd_params {
    int speed;
    int bits;
    int channels;
} snd_params = { 48000, 16, 2 };

static dma_t sndio_shm;
static struct sio_hdl *hdl;
static qboolean snd_inited;

unsigned char *dma_buffer;
size_t dma_buffer_size, dma_ptr;

qboolean
SNDDMA_Init(void)
{
    struct sio_par par;
    char *s;
    int i;

    if (snd_inited == true) {
	Con_Printf("Sound already inited\n");
	return false;
    }

    hdl = sio_open(NULL, SIO_PLAY, 1);
    if (hdl == NULL) {
	Con_Printf("Could not open sndio device\n");
	return false;
    }

    // Get sound sample rate
    s = getenv("QUAKE_SOUND_SPEED");
    if (s)
	snd_params.speed = atoi(s);
    else if ((i = COM_CheckParm("-sndspeed")) != 0)
	snd_params.speed = atoi(com_argv[i + 1]);

    // Get sample format
    int bits = 0;
    s = getenv("QUAKE_SOUND_SAMPLEBITS");
    if (s) {
	bits = atoi(s);
    } else if ((i = COM_CheckParm("-sndbits")) != 0) {
        bits = atoi(com_argv[i + 1]);
    }
    if (bits) {
        if (bits == 8 || bits == 16)
            snd_params.bits = bits;
        else
            Con_Printf("WARNING: ignoring invalid -sndbits %d; must be 8 or 16\n", bits);
    }

    // Get number of sound channels
    s = getenv("QUAKE_SOUND_CHANNELS");
    if (s)
	snd_params.channels = atoi(s);
    else if ((i = COM_CheckParm("-sndmono")) != 0)
	snd_params.channels = 1;
    else if ((i = COM_CheckParm("-sndstereo")) != 0)
	snd_params.channels = 2;

    sio_initpar(&par);
    par.rate = snd_params.speed;
    par.bits = snd_params.bits;
    par.sig = 1;
    par.le = SIO_LE_NATIVE;
    par.pchan = snd_params.channels;
    par.appbufsz = par.rate / 10;	/* 1/10 second latency */

    if (!sio_setpar(hdl, &par) || !sio_getpar(hdl, &par)) {
	Con_Printf("Error setting audio parameters\n");
	sio_close(hdl);
	return false;
    }
    if ((par.pchan != 1 && par.pchan != 2) ||
	(par.bits != 16 || par.sig != 1)) {
	Con_Printf("Could not set appropriate audio parameters\n");
	sio_close(hdl);
	return false;
    }
    memset(&sndio_shm, 0, sizeof(sndio_shm));
    shm = &sndio_shm;
    shm->speed = par.rate;
    shm->channels = par.pchan;
    shm->samplebits = par.bits;

    /*
     * find the smallest power of two larger than the buffer size
     * and use it as the internal buffer's size
     */
    for (i = 1; i < par.appbufsz; i <<= 1)
	; /* nothing */
    shm->samples = i * par.pchan;

    dma_buffer_size = shm->samples * shm->samplebits / 8;
    dma_buffer = calloc(1, dma_buffer_size);
    if (dma_buffer == NULL) {
	Con_Printf("Could not allocate audio ring buffer\n");
	return false;
    }
    dma_ptr = 0;
    shm->buffer = dma_buffer;
    if (!sio_start(hdl)) {
	Con_Printf("Could not start audio\n");
	sio_close(hdl);
	return false;
    }
    shm->submission_chunk = 1;
    shm->samplepos = 0;
    snd_inited = true;
    return true;
}

void
SNDDMA_Shutdown(void)
{
    if (snd_inited == true) {
	sio_close(hdl);
	snd_inited = false;
    }
    free(dma_buffer);
}

int
SNDDMA_GetDMAPos(void)
{
    if (!snd_inited)
	return (0);
    shm->samplepos = dma_ptr / (shm->samplebits / 8);
    return shm->samplepos;
}

void
SNDDMA_Submit(void)
{
    struct pollfd pfd;
    size_t count, todo, avail;
    int n;

    n = sio_pollfd(hdl, &pfd, POLLOUT);
    while (poll(&pfd, n, 0) < 0 && errno == EINTR)
	; /* nothing */
    if (!(sio_revents(hdl, &pfd) & POLLOUT))
	return;
    avail = dma_buffer_size;
    while (avail > 0) {
	todo = dma_buffer_size - dma_ptr;
	if (todo > avail)
	    todo = avail;
	count = sio_write(hdl, dma_buffer + dma_ptr, todo);
	if (count == 0)
	    break;
	dma_ptr += count;
	if (dma_ptr >= dma_buffer_size)
	    dma_ptr -= dma_buffer_size;
	avail -= count;
    }
}

int
SNDDMA_LockBuffer(void)
{
    return 0;
}

void
SNDDMA_UnlockBuffer(void)
{
}

/* TODO: check if we can pause/cork the buffer? */
void S_BlockSound() {}
void S_UnblockSound() {}
