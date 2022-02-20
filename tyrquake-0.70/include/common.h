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
// common.h -- general definitions

#ifndef COMMON_H
#define COMMON_H

#include <stdarg.h>
#include <stdio.h>

#include "qtypes.h"
#include "shell.h"

#ifdef NQ_HACK
#include "quakedef.h"
#endif
#ifdef QW_HACK
#include "bothdefs.h"
#include "protocol.h"
#endif

#define MAX_NUM_ARGVS 50

#define stringify__(x) #x
#define stringify(x) stringify__(x)

//============================================================================

int qvsnprintf(char *str, size_t size, const char *format, va_list argptr);
int qsnprintf(char *str, size_t size, const char *format, ...) __attribute__((format(printf,3,4)));
char *qstrncpy(char *dest, const char *src, size_t size);

//============================================================================

#ifdef QW_HACK
#define	MAX_INFO_STRING 256
#define	MAX_SERVERINFO_STRING 1024
#define	MAX_LOCALINFO_STRING 32768
#endif

//============================================================================

typedef struct sizebuf_s {
    qboolean allowoverflow;	// if false, do a Sys_Error
    qboolean overflowed;	// set to true if the buffer size failed
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

void SZ_HunkAlloc(sizebuf_t *buf, int maxsize);
void SZ_Clear(sizebuf_t *buf);
void SZ_Write(sizebuf_t *buf, const void *data, int length);
void SZ_Print(sizebuf_t *buf, const char *data); // strcats onto the sizebuf

//============================================================================

typedef struct link_s {
    struct link_s *prev, *next;
} link_t;

void ClearLink(link_t *l);
void RemoveLink(link_t *l);
void InsertLinkBefore(link_t *l, link_t *before);
void InsertLinkAfter(link_t *l, link_t *after);

//============================================================================

#ifndef NULL
#define NULL ((void *)0)
#endif

#define Q_MAXCHAR ((char)0x7f)
#define Q_MAXSHORT ((short)0x7fff)
#define Q_MAXINT ((int)0x7fffffff)
#define Q_MAXLONG ((int)0x7fffffff)
#define Q_MAXFLOAT ((int)0x7fffffff)

#define Q_MINCHAR ((char)0x80)
#define Q_MINSHORT ((short)0x8000)
#define Q_MININT ((int)0x80000000)
#define Q_MINLONG ((int)0x80000000)
#define Q_MINFLOAT ((int)0x7fffffff)

/*
 * ========================================================================
 *                          BYTE ORDER FUNCTIONS
 * ========================================================================
 */

static inline short bswap16(short s)
{
    return ((s & 255) << 8) | ((s >> 8) & 255);
}
static inline int bswap32(int l)
{
    return
          (((l >>  0) & 255) << 24)
        | (((l >>  8) & 255) << 16)
        | (((l >> 16) & 255) <<  8)
        | (((l >> 24) & 255) <<  0);
}

#ifdef __BIG_ENDIAN__
static inline short BigShort(short s) { return s; }
static inline int BigLong(int l) { return l; }
static inline float BigFloat(float f) { return f; }
static inline short LittleShort(short s) { return bswap16(s); }
static inline int LittleLong(int l) { return bswap32(l); }
static inline float LittleFloat(float f)
{
    union { float f; int l; } u = { .f = f };
    u.l = bswap32(u.l);
    return u.f;
}
#else
static inline short BigShort(short s) { return bswap16(s); }
static inline int BigLong(int l) { return bswap32(l); }
static inline float BigFloat(float f)
{
    union { float f; int l; } u = { .f = f };
    u.l = bswap32(u.l);
    return u.f;
}
static inline short LittleShort(short s) { return s; }
static inline int LittleLong(int l) { return l; }
static inline float LittleFloat(float f) { return f; }
#endif

//============================================================================

#ifdef QW_HACK
extern struct usercmd_s nullcmd;
#endif

void MSG_WriteChar(sizebuf_t *sb, int c);
void MSG_WriteByte(sizebuf_t *sb, int c);
void MSG_WriteShort(sizebuf_t *sb, int c);
void MSG_WriteLong(sizebuf_t *sb, int c);
void MSG_WriteFloat(sizebuf_t *sb, float f);
void MSG_WriteString(sizebuf_t *sb, const char *s);
void MSG_WriteStringf(sizebuf_t *sb, const char *fmt, ...) __attribute__((format(printf,2,3)));
void MSG_WriteStringvf(sizebuf_t *sb, const char *fmt, va_list ap) __attribute__((format(printf,2,0)));
void MSG_WriteCoord(sizebuf_t *sb, float f);
void MSG_WriteAngle(sizebuf_t *sb, float f);
void MSG_WriteAngle16(sizebuf_t *sb, float f);
#ifdef QW_HACK
void MSG_WriteDeltaUsercmd(sizebuf_t *sb, const struct usercmd_s *from, const struct usercmd_s *cmd);
#endif
#ifdef NQ_HACK
void MSG_WriteControlHeader(sizebuf_t *sb);
#endif

extern int msg_readcount;
extern qboolean msg_badread;	// set if a read goes beyond end of message

void MSG_BeginReading(void);
#ifdef QW_HACK
int MSG_GetReadCount(void);
#endif
int MSG_ReadChar(void);
int MSG_ReadByte(void);
int MSG_ReadShort(void);
int MSG_ReadLong(void);
float MSG_ReadFloat(void);
char *MSG_ReadString(void);
#ifdef QW_HACK
char *MSG_ReadStringLine(void);
#endif

float MSG_ReadCoord(void);
float MSG_ReadAngle(void);
float MSG_ReadAngle16(void);
#ifdef QW_HACK
void MSG_ReadDeltaUsercmd(const struct usercmd_s *from, struct usercmd_s *cmd);
#endif
#ifdef NQ_HACK
int MSG_ReadControlHeader(void);
#endif

//============================================================================

int Q_atoi(const char *str);
float Q_atof(const char *str);

//============================================================================

extern const char *com_token;
extern qboolean com_eof;

const char *COM_Parse(const char *data);

extern unsigned com_argc;
extern const char **com_argv;

unsigned COM_CheckParm(const char *parm);
#ifdef QW_HACK
void COM_AddParm(const char *parm);
#endif

void COM_AddCommands();
void COM_RegisterVariables();

enum game_type {
    GAME_TYPE_ID1,
    GAME_TYPE_QW,
    GAME_TYPE_HIPNOTIC,
    GAME_TYPE_ROGUE,
    GAME_TYPE_QUOTH,
};
extern const char *com_game_type_names[];

void COM_InitArgv(int argc, const char **argv);
void COM_InitFileSystem();
void COM_InitGameDirectory(const char *gamedir, enum game_type game_type);
void COM_InitGameDirectoryFromCommandLine();
void COM_CheckRegistered();

qboolean COM_CheckForGameDirectoryChange(const char *gamedir, enum game_type game_type);

/*
 * So we can check for existance of files in the new game directory
 * before doing the switch, we allow a temp initialisation of the new
 * gamedir filesystem (hunk allocated).
 *
 * After tests are done, call the restore function to clean up the
 * temporary changes.
 */
void COM_InitTempGameDirectory(const char *directory, enum game_type game_type);
void COM_RestoreGameDirectory();

qboolean COM_ValidGamedir(const char *name);
qboolean COM_Gamedir(const char *dir, enum game_type game_type);

const char *COM_SkipPath(const char *pathname);
void COM_StripExtension(const char *filename, char *out, size_t buflen);
void COM_FileBase(const char *in, char *out, size_t buflen);
const char *COM_FileExtension(const char *in);
int COM_DefaultExtension(const char *path, const char *extension, char *out, size_t buflen);

// does a varargs printf into a temp buffer
const char *va(const char *format, ...) __attribute__((format(printf,1,2)));

//============================================================================

struct cache_user_s;

extern char com_basedir[];
extern char com_gamedir[];
extern char com_gamedirfile[];
extern enum game_type com_game_type;

enum qscandir_flags {
    QSCANDIR_KEEP_SUFFIX = (1 << 0),
    QSCANDIR_SUBDIRS     = (1 << 1),
};

void COM_WriteFile(const char *filename, const void *data, int len);
int COM_FilePriority(const char *filename);
int COM_FOpenFile(const char *filename, FILE **file);
FILE *COM_FOpenFileCreate(const char *path, const char *mode);
void COM_ScanDir(struct stree_root *root, const char *path, const char *prefix, const char *suffix, enum qscandir_flags flags);
void COM_ScanBaseDir(struct stree_root *root, const char *prefix);
void *COM_LoadStackFile(const char *path, void *buffer, size_t buffersize, size_t *size);
void *COM_LoadTempFile(const char *path, size_t *size);
void *COM_LoadHunkFile(const char *path, size_t *size);
void COM_LoadCacheFile(const char *path, struct cache_user_s *cu);
void COM_CreatePath(const char *path);

extern struct cvar_s registered;
extern qboolean standard_quake, rogue, hipnotic;

char *Entity_ValueForKey(const char *string, const char *key, char *buffer, int buflen);

#ifdef QW_HACK
char *Info_ValueForKey(const char *infostring, const char *key);
void Info_RemoveKey(char *infostring, const char *key);
void Info_RemovePrefixedKeys(char *infostring, char prefix);
void Info_SetValueForKey(char *infostring, const char *key, const char *value, int maxsize);
void Info_SetValueForStarKey(char *infostring, const char *key, const char *value, int maxsize);
void Info_Print(const char *infostring);

unsigned Com_BlockChecksum(const void *buffer, int length);
void Com_BlockFullChecksum(const void *buffer, int len, unsigned char outbuf[16]);
byte COM_BlockSequenceCheckByte(const byte *base, int length, int sequence, unsigned mapchecksum);
byte COM_BlockSequenceCRCByte(const byte *base, int length, int sequence);
#endif

#endif /* COMMON_H */
