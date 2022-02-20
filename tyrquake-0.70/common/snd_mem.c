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
// snd_mem.c: sound caching

#include <assert.h>

#include "common.h"
#include "console.h"
#include "quakedef.h"
#include "sound.h"
#include "sys.h"

typedef struct {
    int rate;
    int width;
    int channels;
    int loopstart;
    int samples;
    int dataofs;		// chunk starts this many bytes from file start
} wavinfo_t;

static wavinfo_t *GetWavinfo(const char *name, const byte *wav, int wavlength);

/*
================
ResampleSfx
================
*/
static void
ResampleSfx(sfx_t *sfx, int inrate, int inwidth, const byte *data)
{
    int outcount;
    int srcsample;
    float stepscale;
    int i;
    int sample;
    sfxcache_t *sc;

    sc = Cache_Check(&sfx->cache);
    if (!sc)
	return;

    const int in_length = sc->length;

    stepscale = (float)inrate / shm->speed;
    outcount = sc->length / stepscale;
    assert(outcount <= sc->alloc_samples);

    sc->length = outcount;
    if (sc->loopstart >= 0)
	sc->loopstart = roundf(sc->loopstart / stepscale);

    sc->speed = shm->speed;
    sc->width = loadas8bit.value ? 1 : inwidth;
    sc->stereo = 0;

    // Resample / decimate to the current source rate
    if (stepscale == 1 && inwidth == 1 && sc->width == 1) {
	for (i = 0; i < outcount; i++)
	    ((signed char *)sc->data)[i] = (int)((unsigned char)(data[i]) - 128);
        srcsample = in_length - 1;
    } else if (inwidth == 1 && sc->width == 1) {
        for (i = 0; i < outcount; i++) {
            srcsample = i * stepscale;
            assert(srcsample < in_length);
            ((int8_t *)sc->data)[i] = (int)((uint8_t)(data[srcsample])) - 128;
        }
    } else if (inwidth == 1 && sc->width == 2) {
        for (i = 0; i < outcount; i++) {
            srcsample = i * stepscale;
            assert(srcsample < in_length);
            sample = (int)((unsigned char)(data[srcsample]) - 128) << 8;
            ((short *)sc->data)[i] = sample;
        }
    } else if (inwidth == 2 && sc->width == 1) {
        for (i = 0; i < outcount; i++) {
            srcsample = i * stepscale;
            assert(srcsample < in_length);
            sample = LittleShort(((const short *)data)[srcsample]);
            ((signed char *)sc->data)[i] = sample >> 8;
        }
    } else if (inwidth == 2 && sc->width == 2) {
        for (i = 0; i < outcount; i++) {
            srcsample = i * stepscale;
            assert(srcsample < in_length);
            sample = LittleShort(((const short *)data)[srcsample]);
            ((short *)sc->data)[i] = sample;
        }
    } else {
        assert(!"Unsupported sound width in resampler");
    }

    assert(srcsample < in_length);
}

const byte *snd_ramp;
int snd_ramp_count;

void
S_InitRamp()
{
    snd_ramp_count = shm->speed / 64; // Only ~0.01 second - just enough to avoid a sharp 'pop'
    byte *ramp = Hunk_AllocName(snd_ramp_count * sizeof(*snd_ramp), "snd_ramp");

    for (int i = 0; i < snd_ramp_count; i++) {
        float fraction = (float)i / snd_ramp_count * M_PI;
        ramp[snd_ramp_count - 1 - i] = (cosf(fraction) + 1.0f) * 127;
    }
    snd_ramp = ramp;
}

// =============================================================================
// FILTERING
//
// When we upsample the lower quality effects audio we need to apply a low-pass filter to the result
// to remove aliasing effects in the higher frequencies (sounds like extra 'crunch' or 'rattles' in
// the audio.)
// =============================================================================

/*
 * Creates a windowed-sinc filter kernel using a blackman window for use as a low pass filter at the
 * given cutoff frequency.
 */
static void
S_CreateFilterKernel(float cutoff_frequency, int kernel_length, float *kernel)
{
    assert(!(kernel_length & 1)); // kernel length must be even

    const int M = kernel_length;
    const float f_c = cutoff_frequency;
    const float M_TAU_M = M_TAU / M;

    float sum = 0.0f;
    for (int i = 0; i <= M; i++) {
        if (i == M / 2) {
            kernel[i] = M_TAU * f_c;
        } else {
            const float shifted_sinc_function = sinf(M_TAU * f_c * (i - M / 2)) / (i - M / 2);
            const float blackman_window = 0.42f - 0.5f * cosf(i * M_TAU_M) + 0.08f * cosf(i * 2 * M_TAU_M);
            kernel[i] = shifted_sinc_function * blackman_window;
        }
        sum += kernel[i];
    }

    /* Normalise the kernel to cancel any gain */
    const float scale = 1.0f / sum;
    for (int i = 0; i <= M; i++)
        kernel[i] *= scale;
}

static void
Snd_FilterQuality_f(cvar_t *cvar)
{
    static float previous_value = -1.0f;
    if (cvar->value != previous_value) {
        // TODO: Only flush sounds, not the whole cache :)
        Cache_Flush();
        previous_value = cvar->value;
    }
}
cvar_t snd_filterquality = { "snd_filterquality", "3", .callback = Snd_FilterQuality_f };

struct windowed_sinc_filter {
    int kernel_size;
    int window_size;
    float cutoff_frequency;
    float *kernels[4];
};

struct filter_window {
    int pos;
    float *samples;
};

static const int filter_window_sizes[] = { 16, 32, 64, 128, 256 };
#define MAX_WINDOW_SIZE (filter_window_sizes[ARRAY_SIZE(filter_window_sizes) - 1])

static struct windowed_sinc_filter *sfx_filter;
static struct windowed_sinc_filter *music_filter;
static struct filter_window sfx_filter_window;
static struct filter_window music_filter_windows[2];

static inline int
S_CurrentFilterWindowSize()
{
    const int quality_index = qclamp((int)snd_filterquality.value, 1, (int)ARRAY_SIZE(filter_window_sizes)) - 1;
    return filter_window_sizes[quality_index];
}

void
S_HunkAllocFilterBuffers()
{
    int size;

    // SFX filter/window
    size = sizeof(struct windowed_sinc_filter) + 15; // Allow for pad to 16 byte boundary for kernel data
    size += 5 * MAX_WINDOW_SIZE * sizeof(float);     // 4 kernels + sfx window
    sfx_filter = Hunk_AllocName(size, "sfx_fltr");

    sfx_filter_window.samples = (float *)(((uintptr_t)sfx_filter + sizeof(*sfx_filter) + 15) & ~((uintptr_t)15));
    sfx_filter_window.samples += 4 * MAX_WINDOW_SIZE;

    // Music filter/windows
    size = sizeof(struct windowed_sinc_filter) + 15; // Allow for pad to 16 byte boundary for kernel data
    size += 6 * MAX_WINDOW_SIZE * sizeof(float);     // 4 kernels + L/R channel windows
    music_filter = Hunk_AllocName(size, "bgm_fltr");

    music_filter_windows[0].samples = (float *)(((uintptr_t)music_filter + sizeof(*music_filter) + 15) & ~((uintptr_t)15));
    music_filter_windows[0].samples += 4 * MAX_WINDOW_SIZE;
    music_filter_windows[1].samples = music_filter_windows[0].samples + MAX_WINDOW_SIZE;
}

static void
S_InitFilterKernels(struct windowed_sinc_filter *filter)
{
    /* Create one filter kernel, then make three copies offset by 1, 2 & 3 samples. */
    S_CreateFilterKernel(filter->cutoff_frequency, filter->kernel_size, filter->kernels[0]);
    const int window_mask = filter->window_size - 1;
    for (int i = 1; i < 4; i++) {
        for (int j = 0; j < filter->window_size; j++) {
            filter->kernels[i][j] = filter->kernels[0][(filter->window_size - i + j) & window_mask];
        }
    }
}

static void
S_EnsureFilterParameters(struct windowed_sinc_filter *filter, int window_size, float cutoff_frequency)
{
    if (filter->window_size == window_size && filter->cutoff_frequency == cutoff_frequency)
        return;

    filter->window_size = window_size;
    filter->kernel_size = window_size - 2;
    filter->cutoff_frequency = cutoff_frequency;

    /* Make sure the kernels/window are 16 byte aligned */
    filter->kernels[0] = (float *)(((uintptr_t)filter + sizeof(*filter) + 15) & ~((uintptr_t)15));
    float *buffer = filter->kernels[0] + window_size;
    for (int i = 1; i < 4; i++) {
        filter->kernels[i] = buffer;
        buffer += window_size;
    }

    memset(filter->kernels[0], 0, 4 * window_size * sizeof(float));
    S_InitFilterKernels(filter);
}

static void
S_ResetFilterWindow(const struct windowed_sinc_filter *filter, struct filter_window *window)
{
    window->pos = 0;
    memset(window->samples, 0, filter->window_size * sizeof(float));
}

static inline float
S_FilterSample(const struct windowed_sinc_filter *filter, struct filter_window *window, float sample)
{
    const int window_mask = filter->window_size - 1;
    window->samples[window->pos] = sample;

    /*
     * The order of the multiplications doesn't matter, we just need to line up the correct
     * sample in the window with the correct kernel value.  The window samples are in a circular
     * buffer so their alignment shifts with each sample.
     *
     * We keep four copies of the kernel (zero padded at the end) with offsets 0-3 so we can
     * line up four samples at a time.  This convoluted setup is to just so I can try adding
     * some simd optimisations later.  Currently, auto-vectorization in the compiler can't seem
     * to do this, but we get some speed benefits anyway.
     *
     * - Round down kernel position to nearest multiple of four samples
     * - Make up any remainder by selecting the appropriately shifted kernel
     */
    int kernel_pos = (filter->window_size + 1 - window->pos) & window_mask & ~3;
    const float *kernel = filter->kernels[(window->pos + 2) & 3];

    float accum[4] = {0};
    for (int j = 0; j <= filter->kernel_size; j += 4) {
        accum[0] += kernel[kernel_pos + 0] * window->samples[j + 0];
        accum[1] += kernel[kernel_pos + 1] * window->samples[j + 1];
        accum[2] += kernel[kernel_pos + 2] * window->samples[j + 2];
        accum[3] += kernel[kernel_pos + 3] * window->samples[j + 3];

        kernel_pos = (kernel_pos + 4) & window_mask;
    }
    window->pos = (window->pos + 1) & window_mask;

    return accum[0] + accum[1] + accum[2] + accum[3];
}

static void
S_ApplyFilter8(const struct windowed_sinc_filter *filter, struct filter_window *window, int8_t *samples, int numsamples)
{
    for (int i = 0; i < numsamples; i++) {
        float sample = samples[i];
        sample = S_FilterSample(filter, window, sample);
        samples[i] = qclamp(sample, -128.0f, 127.0f);
    }
}

static void
S_ApplyFilter16(const struct windowed_sinc_filter *filter, struct filter_window *window, int16_t *samples, int numsamples)
{
    for (int i = 0; i < numsamples; i++) {
        float sample = samples[i];
        sample = S_FilterSample(filter, window, sample);
        samples[i] = qclamp(sample, -32768.0f, 32767.0f);
    }
}

/*
 * Apply a filter to interleaved stereo samples
 */
static void
S_ApplyFilterStereo16(const struct windowed_sinc_filter *filter, struct filter_window windows[2], int16_t *samples, int numsamples)
{
    const int totalsamples = numsamples * 2;
    for (int channel = 0; channel < 2; channel++) {
        for (int i = channel; i < totalsamples; i += 2) {
            float sample = samples[i];
            sample = S_FilterSample(filter, &windows[channel], sample);
            samples[i] = qclamp(sample, -32768.0f, 32767.0f);
        }
    }
}

void
S_FilterSfx(sfxcache_t *sound, int cutoff_frequency)
{
    if (!snd_filterquality.value)
        return;

    const float cutoff_ratio = (float)cutoff_frequency / (float)sound->speed;
    if (cutoff_ratio >= 0.5f)
        return;

    const int window_size = S_CurrentFilterWindowSize();

    S_EnsureFilterParameters(sfx_filter, window_size, cutoff_ratio);
    S_ResetFilterWindow(sfx_filter, &sfx_filter_window);

    if (sound->loopstart >= 0 && sound->length - sound->loopstart > 0) {
        /*
         * Pad the end of the sound with the samples that we will loop
         * back to so the filter smoothly cuts across.
         */
        int remaining = sfx_filter->window_size / 2;
        int written = 0;
        while (remaining > 0) {
            int samples = qmin(remaining, sound->length - sound->loopstart);
            byte *dest = sound->data + (sound->length + written) * sound->width;
            const byte *source = sound->data + sound->loopstart * sound->width;
            memcpy(dest, source, samples * sound->width);
            written += samples;
            remaining -= samples;
        }
        sound->loopstart += sfx_filter->kernel_size / 2;
        sound->length += sfx_filter->kernel_size / 2;
        assert(sound->length <= sound->alloc_samples);
    } else {
        sound->length += sfx_filter->kernel_size + 1;
        assert(sound->length <= sound->alloc_samples);
    }

    assert(sound->length <= sound->alloc_samples);
    if (sound->width == 2) {
        S_ApplyFilter16(sfx_filter, &sfx_filter_window, (int16_t *)sound->data, sound->length);
    } else {
        S_ApplyFilter8(sfx_filter, &sfx_filter_window, (int8_t *)sound->data, sound->length);
    }
    //S_ApplyFilterSfx(sfx_filter, &sfx_filter_window, sound);
}

void
S_InitMusicFilterParams(int sample_rate, int cutoff_frequency)
{
    const float cutoff_ratio = (float)cutoff_frequency / (float)sample_rate;
    if (cutoff_ratio >= 0.5f) {
        music_filter->cutoff_frequency = cutoff_ratio;
        return;
    }

    const int window_size = S_CurrentFilterWindowSize();
    S_EnsureFilterParameters(music_filter, window_size, cutoff_ratio);
    S_ResetFilterWindow(music_filter, &music_filter_windows[0]);
    S_ResetFilterWindow(music_filter, &music_filter_windows[1]);
}

void
S_FilterMusic(int16_t *samples, int numsamples)
{
    // TODO: Music specific filtering cvar?
    if (!snd_filterquality.value)
        return;
    if (music_filter->cutoff_frequency >= 0.5f)
        return;

    S_ApplyFilterStereo16(music_filter, music_filter_windows, samples, numsamples);
}

//=============================================================================

/*
==============
S_LoadSound
==============
*/
sfxcache_t *
S_LoadSound(sfx_t *sfx)
{
    const byte *data;
    size_t datasize;
    wavinfo_t *info;
    int alloc_samples;
    int pad_samples;
    float stepscale;
    sfxcache_t *sc;
    char namebuffer[256];
    byte stackbuf[64 * 1024];

    sc = Cache_Check(&sfx->cache);
    if (sc)
	return sc;

    /* load it in */
    qsnprintf(namebuffer, sizeof(namebuffer), "sound/%s", sfx->name);
    data = COM_LoadStackFile(namebuffer, stackbuf, sizeof(stackbuf), &datasize);
    if (!data) {
	Con_Printf("Couldn't load %s\n", namebuffer);
	return NULL;
    }

    info = GetWavinfo(sfx->name, data, datasize);
    if (info->channels != 1) {
	return NULL;
    }

    stepscale = (float)info->rate / shm->speed;

    alloc_samples = (info->samples / stepscale);

    /*
     * We pad the allocation with extra samples to ensure the filter
     * window can pass over the entire sound.
     */
    pad_samples = 0;
    if (info->rate < shm->speed && snd_filterquality.value) {
        pad_samples = S_CurrentFilterWindowSize();
        if (info->loopstart >= 0)
            pad_samples /= 2;
    }

    sc = Cache_Alloc(&sfx->cache, sizeof(sfxcache_t) + (alloc_samples + pad_samples) * info->width, sfx->name);
    if (!sc)
	return NULL;

    /* Zero the pad bytes here as it is the common case */
    memset(sc->data + (alloc_samples * info->width), 0, pad_samples * info->width);

    sc->length = info->samples;
    sc->loopstart = info->loopstart;
    sc->alloc_samples = alloc_samples + pad_samples;
    sc->speed = info->rate;
    sc->width = info->width;
    sc->stereo = info->channels;

    ResampleSfx(sfx, info->rate, info->width, data + info->dataofs);

    if (info->rate < sc->speed)
        S_FilterSfx(sc, info->rate / 2);

    return sc;
}


/*
===============================================================================

WAV loading

===============================================================================
*/


static const byte *data_p;
static const byte *iff_end;
static const byte *last_chunk;
static const byte *iff_data;
static int iff_chunk_len;


static short
GetLittleShort(void)
{
    short val = 0;

    val = *data_p;
    val = val + (*(data_p + 1) << 8);
    data_p += 2;
    return val;
}

static int
GetLittleLong(void)
{
    int val = 0;

    val = *data_p;
    val = val + (*(data_p + 1) << 8);
    val = val + (*(data_p + 2) << 16);
    val = val + (*(data_p + 3) << 24);
    data_p += 4;
    return val;
}

static void
FindNextChunk(const char *name, const char *filename)
{
    while (1) {
	/* Need at least 8 bytes for a chunk */
	if (last_chunk + 8 >= iff_end) {
	    data_p = NULL;
	    return;
	}

	data_p = last_chunk + 4;
	iff_chunk_len = GetLittleLong();
	if (iff_chunk_len < 0 || iff_chunk_len > iff_end - data_p) {
	    Con_DPrintf("Bad \"%s\" chunk length (%d) in wav file %s\n",
			name, iff_chunk_len, filename);
	    data_p = NULL;
	    return;
	}
	last_chunk = data_p + ((iff_chunk_len + 1) & ~1);
	data_p -= 8;
	if (!strncmp((const char *)data_p, name, 4))
	    return;
    }
}

static void
FindChunk(const char *name, const char *filename)
{
    last_chunk = iff_data;
    FindNextChunk(name, filename);
}

#if 0
static void
DumpChunks(void)
{
    char str[5];

    str[4] = 0;
    data_p = iff_data;
    do {
	memcpy(str, data_p, 4);
	data_p += 4;
	iff_chunk_len = GetLittleLong();
	Con_Printf("0x%x : %s (%d)\n", (int)(data_p - 4), str, iff_chunk_len);
	data_p += (iff_chunk_len + 1) & ~1;
    } while (data_p < iff_end);
}
#endif

/*
============
GetWavinfo
============
*/
static wavinfo_t *
GetWavinfo(const char *name, const byte *wav, int wavlength)
{
    static wavinfo_t info;
    int i;
    int format;
    int samples;

    memset(&info, 0, sizeof(info));

    if (!wav)
	return &info;

    iff_data = wav;
    iff_end = wav + wavlength;

// find "RIFF" chunk
    FindChunk("RIFF", name);
    if (!(data_p && !strncmp((char *)data_p + 8, "WAVE", 4))) {
	Con_DPrintf("Missing RIFF/WAVE chunks\n");
	return &info;
    }
// get "fmt " chunk
    iff_data = data_p + 12;
// DumpChunks ();

    FindChunk("fmt ", name);
    if (!data_p) {
	Con_DPrintf("Missing fmt chunk\n");
	return &info;
    }
    data_p += 8;
    format = GetLittleShort();
    if (format != 1) {
	Con_DPrintf("Microsoft PCM format only\n");
	return &info;
    }

    info.channels = GetLittleShort();
    info.rate = GetLittleLong();
    data_p += 4 + 2;
    info.width = GetLittleShort() / 8;

// get cue chunk
    FindChunk("cue ", name);
    if (data_p) {
	data_p += 32;
	info.loopstart = GetLittleLong();

	// if the next chunk is a LIST chunk, look for a cue length marker
	FindNextChunk("LIST", name);
	if (data_p) {
	    /* this is not a proper parse, but it works with cooledit... */
	    if (!strncmp((char *)data_p + 28, "mark", 4)) {
		data_p += 24;
		i = GetLittleLong();	// samples in loop
		info.samples = info.loopstart + i;
	    }
	}
    } else
	info.loopstart = -1;

// find data chunk
    FindChunk("data", name);
    if (!data_p) {
	Con_DPrintf("Missing data chunk\n");
	return &info;
    }

    data_p += 4;
    samples = GetLittleLong() / info.width;

    if (info.samples) {
	if (samples < info.samples)
	    Sys_Error("Sound %s has a bad loop length", name);
    } else
	info.samples = samples;

    info.dataofs = data_p - wav;

    return &info;
}
