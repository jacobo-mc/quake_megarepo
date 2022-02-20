/*
Copyright (C) 2021 Kevin Shanahan

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

#include "cdaudio.h"
#include "cmd.h"
#include "console.h"
#include "common.h"
#include "cvar.h"
#include "sound.h"
#include "sys.h"
#include "zone.h"

static void BGM_Music_Loop_f(cvar_t *cvar);

static qboolean bgm_extmusic_disabled;
static cvar_t bgm_extmusic = { "bgm_extmusic", "1", CVAR_CONFIG };
static cvar_t music_loop = { "music_loop", "1", .callback = BGM_Music_Loop_f };

static void S_Music_Arg_f(struct stree_root *root, int argnum);
static void S_Music_f();
static void S_Music_Pause_f();
static void S_Music_Resume_f();

static void
S_Music_Stop_f()
{
    BGM_Stop();
}

void
S_Music_RegisterVariables()
{
    Cvar_RegisterVariable(&bgm_extmusic);
    Cvar_RegisterVariable(&music_loop);
}

void
S_Music_AddCommands()
{
    Cmd_AddCommand("music", S_Music_f);
    Cmd_SetCompletion("music", S_Music_Arg_f);

    Cmd_AddCommand("music_stop", S_Music_Stop_f);
    Cmd_AddCommand("music_pause", S_Music_Pause_f);
    Cmd_AddCommand("music_resume", S_Music_Resume_f);
}

void
S_Music_Init()
{
    if (COM_CheckParm("-noextmusic"))
        bgm_extmusic_disabled = true;
}

/* ================================================ */
/* Attempt to generalise streams of different types */
/* ================================================ */

struct bgm_stream {
    const char *artist;
    const char *title;
    int sample_rate;
    int channels;
    int (*Read)(struct bgm_stream *stream, int16_t *dest, int count);
    void (*Rewind)(struct bgm_stream *stream);
    void (*Shutdown)(struct bgm_stream *stream);
    int (*GetSamples)(struct bgm_stream *stream, int16_t *buffer, int numsamples);
};

/* ================================================ */
/* Vorbis Streaming                                 */
/* ================================================ */

#define STB_VORBIS_NO_PUSHDATA_API
#include "stb_vorbis.c"

static struct bgm_stream *BGM_Vorbis_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out);
static int BGM_Vorbis_Read(struct bgm_stream *stream, int16_t *dest, int count);
static void BGM_Vorbis_Rewind(struct bgm_stream *stream);
static void BGM_Vorbis_Shutdown(struct bgm_stream *stream);

static struct bgm_vorbis_stream {
    struct bgm_stream stream;
    stb_vorbis *handle;
} bgm_vorbis_stream = {
    .stream = {
        .Read = BGM_Vorbis_Read,
        .Rewind = BGM_Vorbis_Rewind,
        .Shutdown = BGM_Vorbis_Shutdown,
    }
};

static struct bgm_stream *
BGM_Vorbis_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out)
{
    stb_vorbis_alloc buffer = { memory, memory_size };
    stb_vorbis *vorbis = stb_vorbis_open_file_section(f, false, error_out, &buffer, file_length);
    if (!vorbis)
        return NULL;

    /* TODO: could this be not a global struct? */
    bgm_vorbis_stream.handle = vorbis;
    struct bgm_stream *stream = &bgm_vorbis_stream.stream;

    stb_vorbis_info info = stb_vorbis_get_info(bgm_vorbis_stream.handle);
    stream->sample_rate = info.sample_rate;
    stream->channels = info.channels;

    stream->title = NULL;
    stream->artist = NULL;
    for (int i = 0; i < vorbis->comment_list_length; i++) {
        if (!strncasecmp(vorbis->comment_list[i], "title=", 6))
            stream->title = Z_StrDup(mainzone, vorbis->comment_list[i] + 6);
        if (!strncasecmp(vorbis->comment_list[i], "artist=", 7))
            stream->artist = Z_StrDup(mainzone, vorbis->comment_list[i] + 7);
    }

    return stream;
}

static int
BGM_Vorbis_Read(struct bgm_stream *stream, int16_t *dest, int count)
{
    struct bgm_vorbis_stream *vorbis = container_of(stream, struct bgm_vorbis_stream, stream);
    return stb_vorbis_get_samples_short_interleaved(vorbis->handle, 2, dest, count * 2);
}

static void
BGM_Vorbis_Rewind(struct bgm_stream *stream)
{
    struct bgm_vorbis_stream *vorbis = container_of(stream, struct bgm_vorbis_stream, stream);
    stb_vorbis_seek_start(vorbis->handle);
}

static void
BGM_Vorbis_Shutdown(struct bgm_stream *stream)
{
    struct bgm_vorbis_stream *vorbis = container_of(stream, struct bgm_vorbis_stream, stream);
    stb_vorbis_close(vorbis->handle);
}

/* ================================================ */
/* DrLib Helpers                                    */
/* ================================================ */

struct bgm_drlib_file_section {
    FILE *handle;
    int start;
    int offset;
    int length;
};

static void *
BGM_DrLib_Malloc(size_t size, void *pUserData)
{
    memzone_t *zone = pUserData;
    return Z_Malloc(zone, size);
}

static void *
BGM_DrLib_Realloc(void *p, size_t sz, void *pUserData)
{
    memzone_t *zone = pUserData;
    return Z_Realloc(zone, p, sz);
}

static void
BGM_DrLib_Free(void *p, void *pUserData)
{
    memzone_t *zone = pUserData;
    Z_Free(zone, p);
}

static size_t
BGM_DrLib_Read(void *pUserData, void *pBufferOut, size_t bytesToRead)
{
    struct bgm_drlib_file_section *file = pUserData;

    /* Ensure we don't read too far if this is a sub-region of a pack file */
    bytesToRead = qmin(bytesToRead, (size_t)file->length - file->offset);
    size_t count = fread(pBufferOut, 1, bytesToRead, file->handle);
    file->offset += count;

    return count;
}

enum bgm_seek_origin {
    bgm_seek_start,
    bgm_seek_current,
};

static qboolean
BGM_DrLib_Seek(void *pUserData, int offset, enum bgm_seek_origin origin)
{
    struct bgm_drlib_file_section *file = pUserData;

    if (origin == bgm_seek_current)
        offset = file->offset + offset;

    if (offset < 0 || offset > file->length)
        return false;
    int result = fseek(file->handle, file->start + offset, SEEK_SET);
    file->offset = offset;

    return result == 0;
}

/* ================================================ */
/* MP3 Streaming                                    */
/* ================================================ */

#define DR_MP3_NO_STDIO
#define DR_MP3_IMPLEMENTATION
#include "dr_mp3.h"

static struct bgm_stream *BGM_MP3_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out);
static int BGM_MP3_Read(struct bgm_stream *stream, int16_t *dest, int count);
static void BGM_MP3_Rewind(struct bgm_stream *stream);
static void BGM_MP3_Shutdown(struct bgm_stream *stream);

static drmp3_bool32
BGM_MP3_Seek(void *pUserData, int offset, drmp3_seek_origin origin)
{
    return BGM_DrLib_Seek(pUserData, offset, origin == drmp3_seek_origin_current ? bgm_seek_current : bgm_seek_start);
}

static struct bgm_mp3_stream {
    struct bgm_stream stream;
    drmp3 handle;
    drmp3_allocation_callbacks memory;
    struct bgm_drlib_file_section file;
} bgm_mp3_stream = {
    .memory = {
        .onMalloc = BGM_DrLib_Malloc,
        .onRealloc = BGM_DrLib_Realloc,
        .onFree = BGM_DrLib_Free,
    },
    .stream = {
        .Read = BGM_MP3_Read,
        .Rewind = BGM_MP3_Rewind,
        .Shutdown = BGM_MP3_Shutdown,
    },
};

static struct bgm_stream *
BGM_MP3_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out)
{
    struct bgm_mp3_stream *mp3 = &bgm_mp3_stream;
    mp3->file.handle = f;
    mp3->file.start = ftell(f);
    mp3->file.length = file_length;
    mp3->file.offset = 0;

    Z_ClearZone(memory, memory_size);
    mp3->memory.pUserData = memory;

    qboolean success = drmp3_init(&mp3->handle, BGM_DrLib_Read, BGM_MP3_Seek, &mp3->file, &mp3->memory);
    if (!success)
        return NULL;

    mp3->stream.sample_rate = mp3->handle.sampleRate;
    mp3->stream.channels = mp3->handle.channels;

    // TODO: ID3 tags?
    mp3->stream.title = NULL;
    mp3->stream.artist = NULL;

    return &mp3->stream;
}

static int
BGM_MP3_Read(struct bgm_stream *stream, int16_t *dest, int count)
{
    struct bgm_mp3_stream *mp3 = container_of(stream, struct bgm_mp3_stream, stream);
    return drmp3_read_pcm_frames_s16(&mp3->handle, count, dest);
}

static void
BGM_MP3_Rewind(struct bgm_stream *stream)
{
    struct bgm_mp3_stream *mp3 = container_of(stream, struct bgm_mp3_stream, stream);
    drmp3_seek_to_pcm_frame(&mp3->handle, 0);
}

static void
BGM_MP3_Shutdown(struct bgm_stream *stream)
{
    struct bgm_mp3_stream *mp3 = container_of(stream, struct bgm_mp3_stream, stream);
    drmp3_uninit(&mp3->handle);
}

/* ================================================ */
/* FLAC Streaming                                   */
/* ================================================ */

#define DR_FLAC_NO_STDIO
#define DR_FLAC_IMPLEMENTATION
#include "dr_flac.h"

static drflac_bool32
BGM_FLAC_Seek(void *pUserData, int offset, drflac_seek_origin origin)
{
    return BGM_DrLib_Seek(pUserData, offset, origin == drflac_seek_origin_current ? bgm_seek_current : bgm_seek_start);
}

static int BGM_FLAC_Read(struct bgm_stream *stream, int16_t *dest, int count);
static void BGM_FLAC_Rewind(struct bgm_stream *stream);
static void BGM_FLAC_Shutdown(struct bgm_stream *stream);

static struct bgm_flac_stream {
    struct bgm_stream stream;
    drflac *handle;
    drflac_allocation_callbacks memory;
    struct bgm_drlib_file_section file;
} bgm_flac_stream = {
    .memory = {
        .onMalloc = BGM_DrLib_Malloc,
        .onRealloc = BGM_DrLib_Realloc,
        .onFree = BGM_DrLib_Free,
    },
    .stream = {
        .Read = BGM_FLAC_Read,
        .Rewind = BGM_FLAC_Rewind,
        .Shutdown = BGM_FLAC_Shutdown,
    },
};

static struct bgm_stream *
BGM_FLAC_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out)
{
    struct bgm_flac_stream *flac = &bgm_flac_stream;
    flac->file.handle = f;
    flac->file.start = ftell(f);
    flac->file.length = file_length;
    flac->file.offset = 0;

    Z_ClearZone(memory, memory_size);
    flac->memory.pUserData = memory;

    flac->handle = drflac_open(BGM_DrLib_Read, BGM_FLAC_Seek, &flac->file, &flac->memory);
    if (!flac->handle)
        return NULL;

    flac->stream.sample_rate = flac->handle->sampleRate;
    flac->stream.channels = flac->handle->channels;

    // TODO: ID3 tags?
    flac->stream.title = NULL;
    flac->stream.artist = NULL;

    return &flac->stream;
}

static int
BGM_FLAC_Read(struct bgm_stream *stream, int16_t *dest, int count)
{
    struct bgm_flac_stream *flac = container_of(stream, struct bgm_flac_stream, stream);
    return drflac_read_pcm_frames_s16(flac->handle, count, dest);
}

static void
BGM_FLAC_Rewind(struct bgm_stream *stream)
{
    struct bgm_flac_stream *flac = container_of(stream, struct bgm_flac_stream, stream);
    drflac_seek_to_pcm_frame(flac->handle, 0);
}

static void
BGM_FLAC_Shutdown(struct bgm_stream *stream)
{
    struct bgm_flac_stream *flac = container_of(stream, struct bgm_flac_stream, stream);
    drflac_close(flac->handle);
}

/* ================================================ */
/* WAV Streaming                                    */
/* ================================================ */

#define DR_WAV_NO_STDIO
#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

static struct bgm_stream *BGM_WAV_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out);
static int BGM_WAV_Read(struct bgm_stream *stream, int16_t *dest, int count);
static void BGM_WAV_Rewind(struct bgm_stream *stream);
static void BGM_WAV_Shutdown(struct bgm_stream *stream);

static drwav_bool32
BGM_WAV_Seek(void *pUserData, int offset, drwav_seek_origin origin)
{
    return BGM_DrLib_Seek(pUserData, offset, origin == drwav_seek_origin_current ? bgm_seek_current : bgm_seek_start);
}

static struct bgm_wav_stream {
    struct bgm_stream stream;
    drwav handle;
    drwav_allocation_callbacks memory;
    struct bgm_drlib_file_section file;
} bgm_wav_stream = {
    .memory = {
        .onMalloc = BGM_DrLib_Malloc,
        .onRealloc = BGM_DrLib_Realloc,
        .onFree = BGM_DrLib_Free,
    },
    .stream = {
        .Read = BGM_WAV_Read,
        .Rewind = BGM_WAV_Rewind,
        .Shutdown = BGM_WAV_Shutdown,
    },
};

static struct bgm_stream *
BGM_WAV_Init(FILE *f, int file_length, void *memory, int memory_size, int *error_out)
{
    struct bgm_wav_stream *wav = &bgm_wav_stream;
    wav->file.handle = f;
    wav->file.start = ftell(f);
    wav->file.length = file_length;
    wav->file.offset = 0;

    Z_ClearZone(memory, memory_size);
    wav->memory.pUserData = memory;

    qboolean success = drwav_init(&wav->handle, BGM_DrLib_Read, BGM_WAV_Seek, &wav->file, &wav->memory);
    if (!success)
        return NULL;

    wav->stream.sample_rate = wav->handle.sampleRate;
    wav->stream.channels = wav->handle.channels;

    // TODO: ID3 tags?
    wav->stream.title = NULL;
    wav->stream.artist = NULL;

    return &wav->stream;
}

static int
BGM_WAV_Read(struct bgm_stream *stream, int16_t *dest, int count)
{
    struct bgm_wav_stream *wav = container_of(stream, struct bgm_wav_stream, stream);
    return drwav_read_pcm_frames_s16(&wav->handle, count, dest);
}

static void
BGM_WAV_Rewind(struct bgm_stream *stream)
{
    struct bgm_wav_stream *wav = container_of(stream, struct bgm_wav_stream, stream);
    drwav_seek_to_pcm_frame(&wav->handle, 0);
}

static void
BGM_WAV_Shutdown(struct bgm_stream *stream)
{
    struct bgm_wav_stream *wav = container_of(stream, struct bgm_wav_stream, stream);
    drwav_uninit(&wav->handle);
}

/* ================================================ */

struct stream_params {
    const char *extension;
    struct bgm_stream *(*Init)(FILE *f, int file_length, void *memory, int memory_size, int *error_out);
};

static struct stream_params bgm_stream_types[] = {
    { .extension = ".ogg",  .Init = BGM_Vorbis_Init, },
    { .extension = ".mp3",  .Init = BGM_MP3_Init,    },
    { .extension = ".flac", .Init = BGM_FLAC_Init,   },
    { .extension = ".wav",  .Init = BGM_WAV_Init,    },
};

/* ================================================ */

/*
 * Audio samples are streamed from the source, resampled and filtered
 * as neccessary to the game's output format and are returned
 * on-demand to the audio mixing process (S_PaintChannels).
 */
#define STREAMING_CHUNK_SIZE 256
static float raw_lerp;

struct sample_buffer {
    int16_t count;
    int16_t samples[STREAMING_CHUNK_SIZE * 4]; // Two chunks, two channels interleaved
};
static struct sample_buffer raw_sample_buffer;

/* 256k seems to be enough for all the decoders we are using */
#define BGM_DECODER_MEMORY_SIZE (256 * 1024)
struct bgm_state {
    struct bgm_stream *stream; // Non-null if a stream is playing
    FILE *file;
    void *decoder_memory;
    qboolean paused;
    qboolean looping;
} bgm;

static void
BGM_Music_Loop_f(cvar_t *cvar)
{
    bgm.looping = !!cvar->value;
}

static void
S_Music_Pause_f()
{
    bgm.paused = true;
}

static void
S_Music_Resume_f()
{
    bgm.paused = false;
}

/**
 * Attempt to ensure we have at least one streaming chunk of samples.
 * Handle all looping in here.  If we're not looping then the samples
 * will just run out.
 */
static void
BGM_EnsureRawSamples(struct bgm_stream *stream, struct sample_buffer *raw)
{
    qboolean try_loop = bgm.looping;

    while (raw->count < STREAMING_CHUNK_SIZE) {
        int16_t *buffer = raw->samples + raw->count * 2;
        int received = stream->Read(stream, buffer, STREAMING_CHUNK_SIZE);
        raw->count += received;
        if (received == STREAMING_CHUNK_SIZE)
            break;
        if (received)
            try_loop = bgm.looping;
        if (!try_loop)
            break;

        stream->Rewind(stream);
        try_loop = false; // Don't loop again unless some samples are recieved
    }
}

static int
GetUpsampledAudio(struct bgm_stream *stream, int16_t *buffer, int numsamples)
{
    const float scale = (float)stream->sample_rate / (float)shm->speed;
    struct sample_buffer *raw = &raw_sample_buffer;
    const int16_t *input = raw->samples;

    int filled = 0;
    while (filled < numsamples) {
        BGM_EnsureRawSamples(stream, raw);

        /* Upscale the samples into the output buffer */
        int start_filled = filled;
        int in_pos = 0;
        while (filled < numsamples && in_pos <= raw->count - 1) {
            buffer[filled * 2 + 0] = input[in_pos * 2 + 0] * (1.0f - raw_lerp) + input[in_pos * 2 + 2] * raw_lerp;
            buffer[filled * 2 + 1] = input[in_pos * 2 + 1] * (1.0f - raw_lerp) + input[in_pos * 2 + 3] * raw_lerp;
            filled++;
            raw_lerp += scale;
            if (raw_lerp > 1.0f) {
                raw_lerp -= 1.0f;
                in_pos++;
            }
        }
        if (in_pos) {
            memmove(raw->samples,  raw->samples + in_pos * 2, (raw->count - in_pos) * 4);
            raw->count -= in_pos;
        }

        if (filled == start_filled)
            break; // no more samples available
    }

    S_FilterMusic(buffer, filled);

    return filled;
}

static int
GetDownsampledAudio(struct bgm_stream *stream, int16_t *buffer, int numsamples)
{
    const float scale = (float)stream->sample_rate / (float)shm->speed;
    const float inv_scale = (float)shm->speed / (float)stream->sample_rate;
    struct sample_buffer *raw = &raw_sample_buffer;
    const int16_t *input = raw->samples;

    int filled = 0;
    while (filled < numsamples) {
        int existing_samples = raw->count;
        BGM_EnsureRawSamples(stream, raw);
        S_FilterMusic(raw->samples + existing_samples * 2, raw->count - existing_samples);

        /* Downsample the filtered audio into the output buffer */
        int start_filled = filled;
        int in_pos = 0;
        while (in_pos < raw->count) {
            /*
             * If there's not enough input samples to complete an output sample, then break to the
             * outer loop to try and retrieve more
             */
            if (raw->count - in_pos < scale)
                break;

            float left = 0.0f;
            float right = 0.0f;
            float in_samples = scale;
            while (in_pos < raw->count) {
                float frac = qmin(1.0f - raw_lerp, in_samples);
                left  += input[in_pos * 2 + 0] * frac;
                right += input[in_pos * 2 + 1] * frac;

                in_samples -= frac;
                if (in_samples <= 0) {
                    /*
                     * Completed an output sample.
                     * Save any partial input sample fraction.
                     */
                    if (frac < 1.0f) {
                        raw_lerp = frac;
                    } else {
                        raw_lerp = 0;
                        in_pos++;
                    }
                    break;
                }
                raw_lerp = 0.0f;
                in_pos++;
            }
            buffer[filled * 2 + 0] = left * inv_scale;
            buffer[filled * 2 + 1] = right * inv_scale;
            filled++;

            if (filled == numsamples)
                break;
        }

        if (in_pos) {
            memmove(raw->samples,  raw->samples + in_pos * 2, (raw->count - in_pos) * 4);
            raw->count -= in_pos;
        }

        if (filled == start_filled)
            break; // no more samples available
    }

    return filled;
}

void
S_PaintMusic(portable_samplepair_t *buffer, int numsamples)
{
    if (!bgm.stream || bgm.paused)
        return;

    const int volume_scale = 255 * qclamp(bgmvolume.value, 0.0f, 1.0f);

    // Paint music samples into the main buffer
    int16_t samples[STREAMING_CHUNK_SIZE * 2];

    int painted = 0;
    while (painted < numsamples) {
        int requested = qmin(numsamples - painted, STREAMING_CHUNK_SIZE);
        int retrieved = bgm.stream->GetSamples(bgm.stream, samples, requested);
        for (int i = 0; i < retrieved; i++) {
            buffer[painted + i].left  += samples[i * 2 + 0] * volume_scale;
            buffer[painted + i].right += samples[i * 2 + 1] * volume_scale;
        }
        painted += retrieved;

        /* Samples were cut off early - not looping... */
        if (retrieved < requested)
            break;
    }
}

void
BGM_Stop()
{
    if (bgm.stream) {
        /* Close off playing music */
        bgm.stream->Shutdown(bgm.stream);
        if (bgm.stream->title)
            Z_Free(mainzone, bgm.stream->title);
        if (bgm.stream->artist)
            Z_Free(mainzone, bgm.stream->artist);
        if (bgm.file)
            fclose(bgm.file);
        bgm.stream = NULL;
        bgm.file = NULL;

        /* Reset resampler */
        raw_sample_buffer.count = 0;
        raw_lerp = 0;
    }
}

static qboolean
BGM_Play(const char *filename, qboolean looping)
{
    FILE *file;
    int file_length = -1;
    struct stream_params *stream_type;

    /* If an extension was specified, try that first */
    const char *extension = COM_FileExtension(filename);
    if (*extension) {
        for (int i = 0; i < ARRAY_SIZE(bgm_stream_types); i++) {
            stream_type = &bgm_stream_types[i];
            if (!strcasecmp(stream_type->extension + 1, extension)) {
                file_length = COM_FOpenFile(va("music/%s", filename), &file);
                break;
            }
        }
    }

    /* If that failed or no extension was provided, try each supported extension in turn */
    if (file_length < 0) {
        for (int i = 0; i < ARRAY_SIZE(bgm_stream_types); i++) {
            stream_type = &bgm_stream_types[i];
            file_length = COM_FOpenFile(va("music/%s%s", filename, stream_type->extension), &file);
            if (file_length >= 0)
                break;
        }
        if (file_length < 0) {
            Con_Printf("Unable to open %s\n", filename);
            return false;
        }
    }

    BGM_Stop();
    bgm.file = file;

    if (!bgm.decoder_memory) {
        bgm.decoder_memory = Hunk_AllocName(BGM_DECODER_MEMORY_SIZE, "bgmdecode");
    }

    int error;
    bgm.stream = stream_type->Init(bgm.file, file_length, bgm.decoder_memory, BGM_DECODER_MEMORY_SIZE, &error);
    if (!bgm.stream) {
        fclose(bgm.file);
        bgm.file = NULL;
        Con_Printf("Unable to initalise BGM stream (%s).  Error code is %d\n", stream_type->extension, error);
        return false;
    }

    if (bgm.stream->channels != 2) {
        bgm.stream->Shutdown(bgm.stream);
        bgm.stream = NULL;
        fclose(bgm.file);
        bgm.file = NULL;
        Con_Printf("ERROR: Only stereo music files are currently supported\n");
        return false;
    }


    if (shm->speed >= bgm.stream->sample_rate) {
        S_InitMusicFilterParams(shm->speed, bgm.stream->sample_rate / 2);
        bgm.stream->GetSamples = GetUpsampledAudio;
    } else {
        S_InitMusicFilterParams(bgm.stream->sample_rate, shm->speed / 2);
        bgm.stream->GetSamples = GetDownsampledAudio;
    }

    // TODO: maybe only print this on request ('bgm info'?)
    if (bgm.stream->title)
        Con_Printf("  Music Title: %s\n", bgm.stream->title);
    if (bgm.stream->artist)
        Con_Printf("  Music Artist: %s\n", bgm.stream->artist);

    bgm.looping = looping;
    bgm.paused = false;

    return true;
}

void
BGM_PlayCDTrack(byte track, qboolean looping)
{
    if (bgm_extmusic.value && !bgm_extmusic_disabled) {
        int best_priority = INT_MAX;
        struct stream_params *bgm_type = NULL;
        for (int i = 0; i < ARRAY_SIZE(bgm_stream_types); i++) {
            int priority = COM_FilePriority(va("music/track%02d%s", (int)track, bgm_stream_types[i].extension));
            if (priority >= 0 && priority < best_priority) {
                best_priority = priority;
                bgm_type = &bgm_stream_types[i];
            }
        }
        if (bgm_type) {
            /* Try streaming audio files first, if enabled */
            char trackname[16];
            qsnprintf(trackname, sizeof(trackname), "track%02d", (int)track);
            qboolean success = BGM_Play(trackname, looping);
            if (success)
                return;
        }
    }

    /* Otherwise, try CD Audio */
    CDAudio_Play(track, looping);
}

void
BGM_ClearBuffers()
{
    BGM_Stop();
    bgm.decoder_memory = NULL;
}


static void
S_Music_Arg_f(struct stree_root *root, int argnum)
{
    if (argnum != 1)
        return;

    for (int i = 0; i < ARRAY_SIZE(bgm_stream_types); i++)
        COM_ScanDir(root, "music", Cmd_Argv(1), bgm_stream_types[i].extension, 0);
}


static void
S_Music_f()
{
    if (Cmd_Argc() != 2) {
        Con_Printf("Usage: music <filename>\n");
        return;
    }

    BGM_Play(Cmd_Argv(1), !!music_loop.value);
}
