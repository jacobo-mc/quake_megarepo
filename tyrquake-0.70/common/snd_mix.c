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
// snd_mix.c -- portable code to mix sounds for snd_dma.c

#include "common.h"
#include "console.h"
#include "quakedef.h"
#include "sound.h"

#define PAINTBUFFER_SIZE 2048
portable_samplepair_t paintbuffer[PAINTBUFFER_SIZE];
int snd_scaletable[32][256];
int *snd_p, snd_linear_count;
short *snd_out;

void Snd_WriteLinearBlastStereo16(void);

#ifndef USE_X86_ASM
void
Snd_WriteLinearBlastStereo16(void)
{
    int i;
    int val;

    for (i = 0; i < snd_linear_count; i += 2) {
	val = snd_p[i] >> 8;
	if (val > 0x7fff)
	    snd_out[i] = 0x7fff;
	else if (val < (short)0x8000)
	    snd_out[i] = (short)0x8000;
	else
	    snd_out[i] = val;

	val = snd_p[i + 1] >> 8;
	if (val > 0x7fff)
	    snd_out[i + 1] = 0x7fff;
	else if (val < (short)0x8000)
	    snd_out[i + 1] = (short)0x8000;
	else
	    snd_out[i + 1] = val;
    }
}
#endif

void
S_TransferStereo16(int endtime)
{
    int lpos;
    int lpaintedtime;

    snd_p = (int *)paintbuffer;
    lpaintedtime = paintedtime;

    while (lpaintedtime < endtime) {
	// handle recirculating buffer issues
	lpos = lpaintedtime & ((shm->samples >> 1) - 1);
	snd_out = (short *)shm->buffer + (lpos << 1);
	snd_linear_count = (shm->samples >> 1) - lpos;
	if (lpaintedtime + snd_linear_count > endtime)
	    snd_linear_count = endtime - lpaintedtime;
	snd_linear_count <<= 1;

	// write a linear blast of samples
	Snd_WriteLinearBlastStereo16();
	snd_p += snd_linear_count;
	lpaintedtime += (snd_linear_count >> 1);
    }
}

void
S_TransferPaintBuffer(int endtime)
{
    int out_idx;
    int count;
    int out_mask;
    int *p;
    int step;
    int val;

    if (shm->samplebits == 16 && shm->channels == 2) {
	S_TransferStereo16(endtime);
	return;
    }

    p = (int *)paintbuffer;
    count = (endtime - paintedtime) * shm->channels;
    out_mask = shm->samples - 1;
    out_idx = (paintedtime * shm->channels) & out_mask;
    step = 3 - shm->channels;

    if (shm->samplebits == 16) {
	short *out = (short *)shm->buffer;
	while (count--) {
	    val = *p >> 8;
	    p += step;
	    if (val > 0x7fff)
		val = 0x7fff;
	    else if (val < (short)0x8000)
		val = (short)0x8000;
	    out[out_idx] = val;
	    out_idx = (out_idx + 1) & out_mask;
	}
    } else if (shm->samplebits == 8) {
	unsigned char *out = (unsigned char *)shm->buffer;
	while (count--) {
	    val = *p >> 8;
	    p += step;
	    if (val > 0x7fff)
		val = 0x7fff;
	    else if (val < (short)0x8000)
		val = (short)0x8000;
	    out[out_idx] = (val >> 8) + 128;
	    out_idx = (out_idx + 1) & out_mask;
	}
    }
}


/*
===============================================================================

CHANNEL MIXING

===============================================================================
*/

static void SND_PaintChannelFrom8_Generic(channel_t *ch, sfxcache_t *sc, int endtime, int paintstart);
static void SND_PaintChannelFrom16(channel_t *ch, sfxcache_t *sc, int endtime, int paintstart);

#ifdef USE_X86_ASM

void SND_PaintChannelFrom8_ASM(channel_t *ch, sfxcache_t *sc, int endtime);
static inline void
SND_PaintChannelFrom8(channel_t *ch, sfxcache_t *sc, int endtime, int paintstart)
{
    /*
     * Use ASM version if painting from the start of the buffer.  This
     * is the common case with the offset only being non-zero when
     * dealing with the wrapping point of a looped sound effect.
     */
    if (paintstart || ch->kill)
        SND_PaintChannelFrom8_Generic(ch, sc, endtime, paintstart);
    else
        SND_PaintChannelFrom8_ASM(ch, sc, endtime);
}

#else

static inline void
SND_PaintChannelFrom8(channel_t *ch, sfxcache_t *sc, int endtime, int paintstart)
{
    SND_PaintChannelFrom8_Generic(ch, sc, endtime, paintstart);
}

#endif // USE_X86_ASM

void
S_PaintChannels(int endtime)
{
    int i;
    int end;
    channel_t *ch;
    sfxcache_t *sc;
    int ltime, count;

    while (paintedtime < endtime) {
	// if paintbuffer is smaller than DMA buffer
	end = endtime;
	if (endtime - paintedtime > PAINTBUFFER_SIZE)
	    end = paintedtime + PAINTBUFFER_SIZE;

	// clear the paint buffer
	memset(paintbuffer, 0, (end - paintedtime) * sizeof(portable_samplepair_t));

	// paint in the channels.
	ch = channels;
	for (i = 0; i < total_channels; i++, ch++) {
	    if (!ch->sfx)
		continue;
	    if (!ch->leftvol && !ch->rightvol)
		continue;
	    sc = S_LoadSound(ch->sfx);
	    if (!sc)
		continue;

	    ltime = paintedtime;

	    while (ltime < end) {	// paint up to end
		if (ch->end < end)
		    count = ch->end - ltime;
		else
		    count = end - ltime;

		if (count > 0) {
		    if (sc->width == 1) {
                        SND_PaintChannelFrom8(ch, sc, count, ltime - paintedtime);
                    } else {
                        SND_PaintChannelFrom16(ch, sc, count, ltime - paintedtime);
                    }
		    ltime += count;
		}
		// if at end of loop, restart
		if (ltime >= ch->end) {
                    /* Check sc->loopstart here as well in case a non-looping ambient gets used */
                    if (ch->looping && sc->loopstart >= 0) {
			ch->pos = sc->loopstart;
			ch->end = ltime + sc->length - ch->pos;
		    } else {	// channel just stopped
			ch->sfx = NULL;
			break;
		    }
		}
	    }
	}

        /* Halve the volume to make room for music and clamp */
        for (i = 0; i < end - paintedtime; i++) {
            paintbuffer[i].left  = qclamp(paintbuffer[i].left  / 2, -32768 * 256, 32767 * 256);
            paintbuffer[i].right = qclamp(paintbuffer[i].right / 2, -32768 * 256, 32767 * 256);
        }

        // Add in background music samples, if enabled
        S_PaintMusic(paintbuffer, end - paintedtime);

	// transfer out according to DMA format
	S_TransferPaintBuffer(end);
	paintedtime = end;
    }
}

void
SND_InitScaletable(void)
{
    int i, j;

    for (i = 0; i < 32; i++) {
        int scale = i * 8 * 256 * sfxvolume.value;
	for (j = 0; j < 128; j++)
	    snd_scaletable[i][j] = j * scale;
        for (j = 128; j < 256; j++)
            snd_scaletable[i][j] = (j - 256) * scale;
    }
}

static void
SND_PaintChannelFrom8_Generic(channel_t *ch, sfxcache_t *sc, int count, int paintstart)
{
    int data;
    int *lscale, *rscale;
    unsigned char *sfx;
    int i;

    if (ch->leftvol > 255)
	ch->leftvol = 255;
    if (ch->rightvol > 255)
	ch->rightvol = 255;

    lscale = snd_scaletable[ch->leftvol >> 3];
    rscale = snd_scaletable[ch->rightvol >> 3];
    sfx = (unsigned char *)sc->data + ch->pos;

    if (ch->kill) {
        /* Ramp down sound */
        int kill = ch->kill;
        int mincount = qmin(count, kill);
        for (i = 0; i < mincount; i++) {
            data = sfx[i];
            paintbuffer[paintstart + i].left  += (lscale[data] * (int)snd_ramp[kill]) / 256;
            paintbuffer[paintstart + i].right += (rscale[data] * (int)snd_ramp[kill]) / 256;
            kill--;
        }
        ch->kill -= mincount;
    } else {
        for (i = 0; i < count; i++) {
            data = sfx[i];
            paintbuffer[paintstart + i].left += lscale[data];
            paintbuffer[paintstart + i].right += rscale[data];
        }
    }

    ch->pos += count;
}

static void
SND_PaintChannelFrom16(channel_t *ch, sfxcache_t *sc, int count, int paintstart)
{
    int data;
    int left, right;
    int leftvol, rightvol;
    signed short *sfx;
    int i;

    leftvol = ch->leftvol * sfxvolume.value * 256;
    rightvol = ch->rightvol * sfxvolume.value * 256;
    sfx = (signed short *)sc->data + ch->pos;

    leftvol >>= 8;
    rightvol >>= 8;

    if (ch->kill) {
        /* Ramp down sound */
        int kill = ch->kill;
        int mincount = qmin(count, kill);
        for (i = 0; i < mincount; i++) {
            data = sfx[i];
            left = (data * leftvol);
            right = (data * rightvol);
            paintbuffer[paintstart + i].left  += (left  * (int)snd_ramp[kill]) / 256;
            paintbuffer[paintstart + i].right += (right * (int)snd_ramp[kill]) / 256;
            kill--;
        }
        ch->kill -= mincount;
    } else {
        for (i = 0; i < count; i++) {
            data = sfx[i];
            left = (data * leftvol);
            right = (data * rightvol);
            paintbuffer[paintstart + i].left  += left;
            paintbuffer[paintstart + i].right += right;
        }
    }

    ch->pos += count;
}
