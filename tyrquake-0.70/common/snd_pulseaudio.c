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

#include <pulse/pulseaudio.h>

#include "common.h"
#include "console.h"
#include "quakedef.h"
#include "sound.h"
#include "sys.h"

static struct snd_params {
    int speed;
    int bits;
    int channels;
} snd_params = { 48000, 16, 2 };

static int snd_inited;
static dma_t snd_dma;

static struct {
    struct pa_mainloop *mainloop;
    struct pa_stream *stream;
    size_t read_index;
    qboolean corked;
} pa_info;

static void
SND_PA_Write_Callback(struct pa_stream *stream, size_t writelen, void *data)
{
    void *dest_buffer;

    /*
     * Allow Pulseaudio to dictate the length of writes, since we have
     * already set the target length for the buffer and enabled
     * latency control.
     */
    pa_stream_begin_write(stream, &dest_buffer, &writelen);

    size_t read_buffer_size = shm->samples * (shm->samplebits / 8);
    size_t bytes_to_copy = writelen;
    byte *dest = dest_buffer;
    while (pa_info.read_index + bytes_to_copy > read_buffer_size) {
        size_t copysize = read_buffer_size - pa_info.read_index;
        memcpy(dest, shm->buffer + pa_info.read_index, copysize);
        dest += copysize;
        bytes_to_copy -= copysize;
        pa_info.read_index = 0;
    }
    if (bytes_to_copy) {
        memcpy(dest, shm->buffer + pa_info.read_index, bytes_to_copy);
        pa_info.read_index += bytes_to_copy;
    }

    pa_stream_write(stream, dest_buffer, writelen, NULL, 0, PA_SEEK_RELATIVE);
}

qboolean
SNDDMA_Init(void)
{
    struct pa_channel_map channel_map;
    struct pa_sample_spec sample_format;
    struct pa_context *context;
    struct pa_proplist *proplist;
    enum pa_context_state context_state;
    enum pa_stream_state stream_state;
    double start;

    int argnum = COM_CheckParm("-sndspeed");
    if (argnum)
        snd_params.speed = atoi(com_argv[argnum + 1]);
    argnum = COM_CheckParm("-sndbits");
    if (argnum) {
        int bits = atoi(com_argv[argnum + 1]);
        if (bits == 8 || bits == 16)
            snd_params.bits = bits;
        else
            Con_Printf("WARNING: ignoring invalid -sndbits %d; must be 8 or 16\n", bits);
    }
    argnum = COM_CheckParm("-sndmono");
    if (argnum)
        snd_params.channels = 1;

    snd_inited = 0;
    shm = &snd_dma;
    shm->samplebits = snd_params.bits;
    shm->channels = snd_params.channels;
    shm->speed = snd_params.speed;

    /* Allow Quake to buffer approx 0.5-1.0 seconds.  Must be power of two */
    shm->samples = 1 << Q_log2(shm->speed * shm->channels);
    shm->buffer = Hunk_AllocName(shm->samples * (shm->samplebits / 8), "shm->buffer");
    shm->samplepos = 0;
    shm->submission_chunk = 1;

    sample_format.format = (shm->samplebits == 8) ? PA_SAMPLE_U8  : PA_SAMPLE_S16NE;
    sample_format.rate = shm->speed;
    sample_format.channels = shm->channels;

    /* Initialise Pulseaudio */
    pa_info.mainloop = pa_mainloop_new();
    context = pa_context_new(pa_mainloop_get_api(pa_info.mainloop), "TyrQuake");
    pa_channel_map_init_stereo(&channel_map);

    /* Request connection and wait for the context to become ready */
    pa_context_connect(context, NULL, PA_CONTEXT_NOFLAGS, NULL);
    start = Sys_DoubleTime();
    while (1) {
        pa_mainloop_iterate(pa_info.mainloop, 0, NULL);
        context_state = pa_context_get_state(context);
        if (context_state == PA_CONTEXT_READY)
            break;
        if (context_state == PA_CONTEXT_FAILED)
            goto fail;
        if (context_state == PA_CONTEXT_TERMINATED)
            goto fail;

        double now = Sys_DoubleTime();
        if (now - start > 1.0)
            goto fail;

        Sys_Sleep();
    }

    /* Initialise the stream */
    proplist = pa_proplist_new();
    pa_proplist_sets(proplist, PA_PROP_APPLICATION_NAME, "TyrQuake");
    pa_proplist_sets(proplist, PA_PROP_APPLICATION_ICON_NAME, "TyrQuake");
    pa_proplist_sets(proplist, PA_PROP_MEDIA_ROLE, "game");
    pa_info.stream = pa_stream_new_with_proplist(context, "TyrQuake", &sample_format, &channel_map, proplist);
    pa_proplist_free(proplist);

    /* Connect the stream for playback, giving latency parameters */
    struct pa_buffer_attr buffer_attributes = {
        .maxlength = (uint32_t)-1, // TODO: Lower this?
        .tlength = (shm->speed / 20) * 2 * 2, // Maximum 1/20s (50ms) of samples? (2 bytes, 2 channels)
        .prebuf = (uint32_t)-1,
        .minreq = (uint32_t)-1,
    };
    pa_stream_flags_t flags = PA_STREAM_INTERPOLATE_TIMING | PA_STREAM_AUTO_TIMING_UPDATE | PA_STREAM_ADJUST_LATENCY;
    pa_stream_connect_playback(pa_info.stream, NULL, &buffer_attributes, flags, NULL, NULL);
    pa_stream_set_write_callback(pa_info.stream, SND_PA_Write_Callback, NULL);

    start = Sys_DoubleTime();
    while (1) {
        pa_mainloop_iterate(pa_info.mainloop, 0, NULL);
        stream_state = pa_stream_get_state(pa_info.stream);
        if (stream_state == PA_STREAM_READY)
            break;
        if (stream_state == PA_STREAM_FAILED)
            goto fail;
        if (stream_state == PA_STREAM_TERMINATED)
            goto fail;

        double now = Sys_DoubleTime();
        if (now - start > 1.0)
            goto fail;

        Sys_Sleep();
    }

    snd_inited = 1;
    snd_blocked = 0;

    return true;

fail:
    pa_mainloop_free(pa_info.mainloop);

    return false;
}

int SNDDMA_LockBuffer(void) { return 0; }
void SNDDMA_UnlockBuffer(void) { }

int
SNDDMA_GetDMAPos(void)
{
    if (!snd_inited)
	return 0;

    shm->samplepos = pa_info.read_index / (shm->samplebits / 8);

    return shm->samplepos;
}

void
SNDDMA_Shutdown(void)
{
    if (snd_inited) {
        pa_mainloop_free(pa_info.mainloop);
        memset(&pa_info, 0, sizeof(pa_info));
	snd_inited = 0;
    }
}

/*
==============
SNDDMA_Submit

Send sound to device if buffer isn't really the dma buffer
===============
*/
void
SNDDMA_Submit(void)
{
    int progress;

    do {
        progress = pa_mainloop_iterate(pa_info.mainloop, 0, NULL);
    } while (progress > 0);
}

void
S_BlockSound(void)
{
    int progress;

    if (!snd_blocked && pa_info.stream) {
        pa_stream_cork(pa_info.stream, true, NULL, NULL);
        do {
            progress = pa_mainloop_iterate(pa_info.mainloop, 0, NULL);
        } while (progress > 0);
    }

    snd_blocked++;
}

void
S_UnblockSound(void)
{
    int progress;

    if (snd_blocked && pa_info.stream) {
        pa_stream_cork(pa_info.stream, false, NULL, NULL);
        do {
            progress = pa_mainloop_iterate(pa_info.mainloop, 0, NULL);
        } while (progress > 0);
    }

    snd_blocked--;
}
