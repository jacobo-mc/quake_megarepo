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
// common.c -- misc functions used in client and server

#include <ctype.h>
#include <dirent.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#ifdef NQ_HACK
#include "quakedef.h"
#include "host.h"
#endif

#ifdef QW_HACK
#ifdef SERVERONLY
#include "qwsvdef.h"
#include "server.h"
#else
#include "client.h"
#include "quakedef.h"
#endif
#include "protocol.h"
#endif

#include "cmd.h"
#include "common.h"
#include "console.h"
#include "crc.h"
#include "draw.h"
#include "net.h"
#include "shell.h"
#include "sys.h"
#include "zone.h"


// ======================================================================
// STRING HANDLING
// ======================================================================

int
qvsnprintf(char *str, size_t size, const char *format, va_list argptr)
{
    int written;

    written = vsnprintf(str, size, format, argptr);
    if (written >= size)
        str[size - 1] = 0;

    return written;
}

int
qsnprintf(char *str, size_t size, const char *format, ...)
{
    va_list argptr;
    int written;

    va_start(argptr, format);
    written = qvsnprintf(str, size, format, argptr);
    va_end(argptr);

    return written;
}

char *
qstrncpy(char *dest, const char *src, size_t size)
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstringop-truncation"
    strncpy(dest, src, size - 1);
#pragma GCC diagnostic pop
    dest[size - 1] = 0;

    return dest;
}

// ======================================================================

#define NUM_SAFE_ARGVS 7

static const char *largv[MAX_NUM_ARGVS + NUM_SAFE_ARGVS + 1];
static const char *argvdummy = " ";

static const char *safeargvs[NUM_SAFE_ARGVS] = {
  "-stdvid", "-nolan", "-nosound", "-nocdaudio", "-nojoy", "-nomouse", "-dibonly"
};

cvar_t registered = { "registered", "0" };
static cvar_t cmdline = { "cmdline", "0", 0, true };

static qboolean com_modified;		// set true if using non-id files
static int static_registered = 1;	// only for startup check, then set

static void COM_Path_f(void);
static void *SZ_GetSpace(sizebuf_t *buf, int length);

/* Checksums for the original id pak directory structures */
#define ID1_PAK0_COUNT        339 /* id1/pak0.pak - v1.0x */
#define ID1_PAK0_CRC_V100   13900 /* id1/pak0.pak - v1.00 */
#define ID1_PAK0_CRC_V101   62751 /* id1/pak0.pak - v1.01 */
#define ID1_PAK0_CRC_V106   32981 /* id1/pak0.pak - v1.06 */
#define ID1_PAK0_COUNT_V091   308 /* id1/pak0.pak - v0.91/0.92, not supported */
#define ID1_PAK0_CRC_V091   28804 /* id1/pak0.pak - v0.91/0.92, not supported */
#define QW_PAK0_CRC         52883

#define CMDLINE_LENGTH	256
static char com_cmdline[CMDLINE_LENGTH];

qboolean standard_quake = true, rogue, hipnotic;

// this graphic needs to be in the pak file to use registered features
static unsigned short pop[] = {
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x6600, 0x0000, 0x0000, 0x0000, 0x6600, 0x0000,
    0x0000, 0x0066, 0x0000, 0x0000, 0x0000, 0x0000, 0x0067, 0x0000,
    0x0000, 0x6665, 0x0000, 0x0000, 0x0000, 0x0000, 0x0065, 0x6600,
    0x0063, 0x6561, 0x0000, 0x0000, 0x0000, 0x0000, 0x0061, 0x6563,
    0x0064, 0x6561, 0x0000, 0x0000, 0x0000, 0x0000, 0x0061, 0x6564,
    0x0064, 0x6564, 0x0000, 0x6469, 0x6969, 0x6400, 0x0064, 0x6564,
    0x0063, 0x6568, 0x6200, 0x0064, 0x6864, 0x0000, 0x6268, 0x6563,
    0x0000, 0x6567, 0x6963, 0x0064, 0x6764, 0x0063, 0x6967, 0x6500,
    0x0000, 0x6266, 0x6769, 0x6a68, 0x6768, 0x6a69, 0x6766, 0x6200,
    0x0000, 0x0062, 0x6566, 0x6666, 0x6666, 0x6666, 0x6562, 0x0000,
    0x0000, 0x0000, 0x0062, 0x6364, 0x6664, 0x6362, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0062, 0x6662, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0061, 0x6661, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x6500, 0x0000, 0x0000, 0x0000,
    0x0000, 0x0000, 0x0000, 0x0000, 0x6400, 0x0000, 0x0000, 0x0000
};

/*

All of Quake's data access is through a hierchal file system, but the contents
of the file system can be transparently merged from several sources.

The "base directory" is the path to the directory holding the quake.exe and
all game directories.  The sys_* files pass this to host_init in
quakeparms_t->basedir.  This can be overridden with the "-basedir" command
line parm to allow code debugging in a different directory.  The base
directory is only used during filesystem initialization.

The "game directory" is the first tree on the search path and directory that
all generated files (savegames, screenshots, demos, config files) will be
saved to.  This can be overridden with the "-game" command line parameter.
The game directory can never be changed while quake is executing.  This is a
precacution against having a malicious server instruct clients to write files
over areas they shouldn't.

*/

//============================================================================


// ClearLink is used for new headnodes
void
ClearLink(link_t *l)
{
    l->prev = l->next = l;
}

void
RemoveLink(link_t *l)
{
    l->next->prev = l->prev;
    l->prev->next = l->next;
}

void
InsertLinkBefore(link_t *l, link_t *before)
{
    l->next = before;
    l->prev = before->prev;
    l->prev->next = l;
    l->next->prev = l;
}

/* Unused */
#if 0
void
InsertLinkAfter(link_t *l, link_t *after)
{
    l->next = after->next;
    l->prev = after;
    l->prev->next = l;
    l->next->prev = l;
}
#endif

/*
============================================================================

			LIBRARY REPLACEMENT FUNCTIONS

============================================================================
*/

/*
 * Use this function to share static string buffers
 * between different text processing functions.
 * Try to avoid fixed-size intermediate buffers like this if possible
 */
#define COM_STRBUF_LEN 2048
static char *
COM_GetStrBuf(void)
{
    static char buffers[8][COM_STRBUF_LEN];
    static int index;
    return buffers[7 & ++index];
}


int
Q_atoi(const char *str)
{
    int val;
    int sign;
    int c;

    if (*str == '-') {
	sign = -1;
	str++;
    } else
	sign = 1;

    val = 0;

//
// check for hex
//
    if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) {
	str += 2;
	while (1) {
	    c = *str++;
	    if (c >= '0' && c <= '9')
		val = (val << 4) + c - '0';
	    else if (c >= 'a' && c <= 'f')
		val = (val << 4) + c - 'a' + 10;
	    else if (c >= 'A' && c <= 'F')
		val = (val << 4) + c - 'A' + 10;
	    else
		return val * sign;
	}
    }
//
// check for character
//
    if (str[0] == '\'') {
	return sign * str[1];
    }
//
// assume decimal
//
    while (1) {
	c = *str++;
	if (c < '0' || c > '9')
	    return val * sign;
	val = val * 10 + c - '0';
    }

    return 0;
}


float
Q_atof(const char *str)
{
    double val;
    int sign;
    int c;
    int decimal, total;

    if (*str == '-') {
	sign = -1;
	str++;
    } else
	sign = 1;

    val = 0;

//
// check for hex
//
    if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) {
	str += 2;
	while (1) {
	    c = *str++;
	    if (c >= '0' && c <= '9')
		val = (val * 16) + c - '0';
	    else if (c >= 'a' && c <= 'f')
		val = (val * 16) + c - 'a' + 10;
	    else if (c >= 'A' && c <= 'F')
		val = (val * 16) + c - 'A' + 10;
	    else
		return val * sign;
	}
    }
//
// check for character
//
    if (str[0] == '\'') {
	return sign * str[1];
    }
//
// assume decimal
//
    decimal = -1;
    total = 0;
    while (1) {
	c = *str++;
	if (c == '.') {
	    decimal = total;
	    continue;
	}
	if (c < '0' || c > '9')
	    break;
	val = val * 10 + c - '0';
	total++;
    }

    if (decimal == -1)
	return val * sign;
    while (total > decimal) {
	val /= 10;
	total--;
    }

    return val * sign;
}

/*
==============================================================================

			MESSAGE IO FUNCTIONS

Handles byte ordering and avoids alignment errors
==============================================================================
*/

#ifdef QW_HACK
usercmd_t nullcmd;		// guarenteed to be zero
#endif

//
// writing functions
//

void
MSG_WriteChar(sizebuf_t *sb, int c)
{
    byte *buf;

#ifdef PARANOID
    if (c < -128 || c > 127)
	Sys_Error("%s: range error", __func__);
#endif

    buf = SZ_GetSpace(sb, 1);
    buf[0] = c;
}

void
MSG_WriteByte(sizebuf_t *sb, int c)
{
    byte *buf;

#ifdef PARANOID
    if (c < 0 || c > 255)
	Sys_Error("%s: range error", __func__);
#endif

    buf = SZ_GetSpace(sb, 1);
    buf[0] = c;
}

void
MSG_WriteShort(sizebuf_t *sb, int c)
{
    byte *buf;

#ifdef PARANOID
    if (c < ((short)0x8000) || c > (short)0x7fff)
	Sys_Error("%s: range error", __func__);
#endif

    buf = SZ_GetSpace(sb, 2);
    buf[0] = c & 0xff;
    buf[1] = c >> 8;
}

void
MSG_WriteLong(sizebuf_t *sb, int c)
{
    byte *buf;

    buf = SZ_GetSpace(sb, 4);
    buf[0] = c & 0xff;
    buf[1] = (c >> 8) & 0xff;
    buf[2] = (c >> 16) & 0xff;
    buf[3] = c >> 24;
}

void
MSG_WriteFloat(sizebuf_t *sb, float f)
{
    union {
	float f;
	int l;
    } dat;

    dat.f = f;
    dat.l = LittleLong(dat.l);

    SZ_Write(sb, &dat.l, 4);
}

void
MSG_WriteString(sizebuf_t *sb, const char *s)
{
    if (!s)
	SZ_Write(sb, "", 1);
    else
	SZ_Write(sb, s, strlen(s) + 1);
}

void
MSG_WriteStringvf(sizebuf_t *sb, const char *fmt, va_list ap)
{
    int maxlen, len;

    /*
     * FIXME - Kind of ugly to check space first then do getspace
     * afterwards, but we don't know how much we'll need before
     * hand. Update the SZ interface?
     */
    maxlen = sb->maxsize - sb->cursize;
    len = qvsnprintf((char *)sb->data + sb->cursize, maxlen, fmt, ap);

    /* Use SZ_GetSpace to check for overflow */
    SZ_GetSpace(sb, len + 1);
}

void
MSG_WriteStringf(sizebuf_t *sb, const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    MSG_WriteStringvf(sb, fmt, ap);
    va_end(ap);
}

void
MSG_WriteCoord(sizebuf_t *sb, float f)
{
    /*
     * Co-ords are send as shorts, with the low 3 bits being the fractional
     * component
     */
    MSG_WriteShort(sb, (int)(f * (1 << 3)));
}

void
MSG_WriteAngle(sizebuf_t *sb, float f)
{
    MSG_WriteByte(sb, (int)floorf((f * 256 / 360) + 0.5f) & 255);
}

void
MSG_WriteAngle16(sizebuf_t *sb, float f)
{
    MSG_WriteShort(sb, (int)floorf((f * 65536 / 360) + 0.5f) & 65535);
}

#ifdef QW_HACK
void
MSG_WriteDeltaUsercmd(sizebuf_t *buf, const usercmd_t *from,
		      const usercmd_t *cmd)
{
    int bits;

//
// send the movement message
//
    bits = 0;
    if (cmd->angles[0] != from->angles[0])
	bits |= CM_ANGLE1;
    if (cmd->angles[1] != from->angles[1])
	bits |= CM_ANGLE2;
    if (cmd->angles[2] != from->angles[2])
	bits |= CM_ANGLE3;
    if (cmd->forwardmove != from->forwardmove)
	bits |= CM_FORWARD;
    if (cmd->sidemove != from->sidemove)
	bits |= CM_SIDE;
    if (cmd->upmove != from->upmove)
	bits |= CM_UP;
    if (cmd->buttons != from->buttons)
	bits |= CM_BUTTONS;
    if (cmd->impulse != from->impulse)
	bits |= CM_IMPULSE;

    MSG_WriteByte(buf, bits);

    if (bits & CM_ANGLE1)
	MSG_WriteAngle16(buf, cmd->angles[0]);
    if (bits & CM_ANGLE2)
	MSG_WriteAngle16(buf, cmd->angles[1]);
    if (bits & CM_ANGLE3)
	MSG_WriteAngle16(buf, cmd->angles[2]);

    if (bits & CM_FORWARD)
	MSG_WriteShort(buf, cmd->forwardmove);
    if (bits & CM_SIDE)
	MSG_WriteShort(buf, cmd->sidemove);
    if (bits & CM_UP)
	MSG_WriteShort(buf, cmd->upmove);

    if (bits & CM_BUTTONS)
	MSG_WriteByte(buf, cmd->buttons);
    if (bits & CM_IMPULSE)
	MSG_WriteByte(buf, cmd->impulse);
    MSG_WriteByte(buf, cmd->msec);
}
#endif /* QW_HACK */

#ifdef NQ_HACK
/*
 * Write the current message length to the start of the buffer (in big
 * endian format) with the control flag set.
 */
void
MSG_WriteControlHeader(sizebuf_t *sb)
{
    int c = NETFLAG_CTL | (sb->cursize & NETFLAG_LENGTH_MASK);

    sb->data[0] = c >> 24;
    sb->data[1] = (c >> 16) & 0xff;
    sb->data[2] = (c >> 8) & 0xff;
    sb->data[3] = c & 0xff;
}
#endif

//
// reading functions
//
int msg_readcount;
qboolean msg_badread;

void
MSG_BeginReading(void)
{
    msg_readcount = 0;
    msg_badread = false;
}

#ifdef QW_HACK
int
MSG_GetReadCount(void)
{
    return msg_readcount;
}
#endif

// returns -1 and sets msg_badread if no more characters are available
int
MSG_ReadChar(void)
{
    int c;

    if (msg_readcount + 1 > net_message.cursize) {
	msg_badread = true;
	return -1;
    }

    c = (signed char)net_message.data[msg_readcount];
    msg_readcount++;

    return c;
}

int
MSG_ReadByte(void)
{
    int c;

    if (msg_readcount + 1 > net_message.cursize) {
	msg_badread = true;
	return -1;
    }

    c = (unsigned char)net_message.data[msg_readcount];
    msg_readcount++;

    return c;
}

int
MSG_ReadShort(void)
{
    int c;

    if (msg_readcount + 2 > net_message.cursize) {
	msg_badread = true;
	return -1;
    }

    c = (short)(net_message.data[msg_readcount]
		+ (net_message.data[msg_readcount + 1] << 8));

    msg_readcount += 2;

    return c;
}

int
MSG_ReadLong(void)
{
    int c;

    if (msg_readcount + 4 > net_message.cursize) {
	msg_badread = true;
	return -1;
    }

    c = net_message.data[msg_readcount]
	+ (net_message.data[msg_readcount + 1] << 8)
	+ (net_message.data[msg_readcount + 2] << 16)
	+ (net_message.data[msg_readcount + 3] << 24);

    msg_readcount += 4;

    return c;
}

float
MSG_ReadFloat(void)
{
    union {
	byte b[4];
	float f;
	int l;
    } dat;

    dat.b[0] = net_message.data[msg_readcount];
    dat.b[1] = net_message.data[msg_readcount + 1];
    dat.b[2] = net_message.data[msg_readcount + 2];
    dat.b[3] = net_message.data[msg_readcount + 3];
    msg_readcount += 4;

    dat.l = LittleLong(dat.l);

    return dat.f;
}

char *
MSG_ReadString(void)
{
    char *buf;
    int len, c;

    buf = COM_GetStrBuf();
    len = 0;
    do {
	c = MSG_ReadChar();
	if (c == -1 || c == 0)
	    break;
	buf[len++] = c;
    } while (len < COM_STRBUF_LEN - 1);

    buf[len] = 0;

    return buf;
}

#ifdef QW_HACK
char *
MSG_ReadStringLine(void)
{
    char *buf;
    int len, c;

    buf = COM_GetStrBuf();
    len = 0;
    do {
	c = MSG_ReadChar();
	if (c == -1 || c == 0 || c == '\n')
	    break;
	buf[len++] = c;
    } while (len < COM_STRBUF_LEN - 1);

    buf[len] = 0;

    return buf;
}
#endif

float
MSG_ReadCoord(void)
{
    /*
     * Co-ords are send as shorts, with the low 3 bits being the fractional
     * component
     */
    return MSG_ReadShort() * (1.0 / (1 << 3));
}

float
MSG_ReadAngle(void)
{
    return MSG_ReadChar() * (360.0 / 256);
}

float
MSG_ReadAngle16(void)
{
    return MSG_ReadShort() * (360.0 / 65536);
}

#ifdef QW_HACK
void
MSG_ReadDeltaUsercmd(const usercmd_t *from, usercmd_t *move)
{
    int bits;

    memcpy(move, from, sizeof(*move));

    bits = MSG_ReadByte();

// read current angles
    if (bits & CM_ANGLE1)
	move->angles[0] = MSG_ReadAngle16();
    if (bits & CM_ANGLE2)
	move->angles[1] = MSG_ReadAngle16();
    if (bits & CM_ANGLE3)
	move->angles[2] = MSG_ReadAngle16();

// read movement
    if (bits & CM_FORWARD)
	move->forwardmove = MSG_ReadShort();
    if (bits & CM_SIDE)
	move->sidemove = MSG_ReadShort();
    if (bits & CM_UP)
	move->upmove = MSG_ReadShort();

// read buttons
    if (bits & CM_BUTTONS)
	move->buttons = MSG_ReadByte();

    if (bits & CM_IMPULSE)
	move->impulse = MSG_ReadByte();

// read time to run command
    move->msec = MSG_ReadByte();
}
#endif /* QW_HACK */

#ifdef NQ_HACK
/*
 * Read back the message control header
 * Essentially this is MSG_ReadLong, but big-endian byte order.
 */
int
MSG_ReadControlHeader(void)
{
    int c;

    if (msg_readcount + 4 > net_message.cursize) {
	msg_badread = true;
	return -1;
    }

    c = (net_message.data[msg_readcount] << 24)
	+ (net_message.data[msg_readcount + 1] << 16)
	+ (net_message.data[msg_readcount + 2] << 8)
	+ net_message.data[msg_readcount + 3];

    msg_readcount += 4;

    return c;
}
#endif

//===========================================================================

void
SZ_HunkAlloc(sizebuf_t *buf, int maxsize)
{
    maxsize = qmax(maxsize, 16);
    buf->data = Hunk_AllocName(maxsize, "sizebuf");
    buf->maxsize = maxsize;
    buf->cursize = 0;
}

void
SZ_Clear(sizebuf_t *buf)
{
    buf->cursize = 0;
    buf->overflowed = false;
}

static void *
SZ_GetSpace(sizebuf_t *buf, int length)
{
    void *data;

    if (buf->cursize + length > buf->maxsize) {
	if (!buf->allowoverflow)
	    Sys_Error("%s: overflow without allowoverflow set (%d > %d)",
		      __func__, buf->cursize + length, buf->maxsize);
	if (length > buf->maxsize)
	    Sys_Error("%s: %d is > full buffer size", __func__, length);
	if (developer.value)
	    /* Con_Printf may be redirected */
	    Sys_Printf("%s: overflow\n", __func__);
	SZ_Clear(buf);
	buf->overflowed = true;
    }
    data = buf->data + buf->cursize;
    buf->cursize += length;

    return data;
}

void
SZ_Write(sizebuf_t *buf, const void *data, int length)
{
    memcpy(SZ_GetSpace(buf, length), data, length);
}

void
SZ_Print(sizebuf_t *buf, const char *data)
{
    size_t len = strlen(data);

    /* If buf->data has a trailing zero, overwrite it */
    if (!buf->cursize || buf->data[buf->cursize - 1])
	memcpy(SZ_GetSpace(buf, len + 1), data, len + 1);
    else
	memcpy(SZ_GetSpace(buf, len) - 1, data, len + 1);
}


//============================================================================


/*
============
COM_SkipPath
============
*/
const char *
COM_SkipPath(const char *pathname)
{
    const char *last;

    last = pathname;
    while (*pathname) {
	if (*pathname == '/')
	    last = pathname + 1;
	pathname++;
    }
    return last;
}

/*
============
COM_StripExtension
============
*/
void
COM_StripExtension(const char *filename, char *out, size_t buflen)
{
    const char *start, *pos;
    size_t copylen;

    start = COM_SkipPath(filename);
    pos = strrchr(start, '.');
    if (out == filename) {
	if (pos && *pos)
	    out[pos - filename] = 0;
	return;
    }

    copylen = qmin((size_t)(pos - filename), buflen - 1);
    memcpy(out, filename, copylen);
    out[copylen] = 0;
}

/*
============
COM_FileExtension
============
*/
const char *
COM_FileExtension(const char *in)
{
    const char *dot = strrchr(in, '.');
    return dot ? ++dot : "";
}

/*
============
COM_FileBase
============
*/
void
COM_FileBase(const char *in, char *out, size_t buflen)
{
    const char *dot;
    int copylen;

    in = COM_SkipPath(in);
    dot = strrchr(in, '.');
    copylen = dot ? dot - in : strlen(in);

    if (copylen < 2) {
	in = "?model?";
	copylen = strlen(in);
    }
    qsnprintf(out, buflen, "%.*s", copylen, in);
}


/*
==================
COM_DefaultExtension
Returns non-zero if the extension wouldn't fit in the output buffer
==================
*/
int
COM_DefaultExtension(const char *path, const char *extension, char *out,
		     size_t buflen)
{
    COM_StripExtension(path, out, buflen);
    if (strlen(out) + strlen(extension) + 1 > buflen)
	return -1;

    /* Copy extension, including terminating null */
    memcpy(out + strlen(out), extension, strlen(extension) + 1);

    return 0;
}

static int
COM_CheckSuffix(const char *path, const char *suffix)
{
    int pathlen = strlen(path);
    int suffixlen = strlen(suffix);

    return pathlen >= suffixlen && !strcmp(path + pathlen - suffixlen, suffix);
}

//============================================================================

#define COM_MAX_TOKEN 4096
static char com_tokenbuf[COM_MAX_TOKEN];
const char *com_token = com_tokenbuf;
unsigned com_argc;
const char **com_argv;

/*
==============
COM_Parse

Parse a token out of a string
==============
*/
static const char single_chars[] = "{})(':";

static const char *
COM_Parse_(const char *data, qboolean split_single_chars)
{
    int c;
    int len;

    len = 0;
    com_tokenbuf[0] = 0;

    if (!data)
	return NULL;

// skip whitespace
  skipwhite:
    while ((c = *data) <= ' ') {
	if (c == 0)
	    return NULL;	// end of file;
	data++;
    }

// skip // comments
    if (c == '/' && data[1] == '/') {
	while (*data && *data != '\n')
	    data++;
	goto skipwhite;
    }
// skip /*..*/ comments
    if (c == '/' && data[1] == '*') {
	data += 2;
	while (*data && !(*data == '*' && data[1] == '/'))
	    data++;
	if (*data)
	    data += 2;
	goto skipwhite;
    }
// handle quoted strings specially
    if (c == '\"') {
	data++;
	while (1) {
	    c = *data;
	    if (c)
		data++;
	    if (c == '\"' || !c) {
		com_tokenbuf[len] = 0;
		return data;
	    }
	    if (len < sizeof(com_tokenbuf) - 1)
		com_tokenbuf[len++] = c;
	}
    }
// parse single characters
    if (split_single_chars && strchr(single_chars, c)) {
	if (len < sizeof(com_tokenbuf) - 1)
	    com_tokenbuf[len++] = c;
	com_tokenbuf[len] = 0;
	return data + 1;
    }
// parse a regular word
    do {
	if (len < sizeof(com_tokenbuf) - 1)
	    com_tokenbuf[len++] = c;
	data++;
	c = *data;
	if (split_single_chars && strchr(single_chars, c))
	    break;
    } while (c > 32);

    com_tokenbuf[len] = 0;

    return data;
}

const char *
COM_Parse(const char *data)
{
#ifdef NQ_HACK
    return COM_Parse_(data, true);
#endif
#ifdef QW_HACK
    return COM_Parse_(data, false);
#endif
}

/*
================
COM_CheckParm

Returns the position (1 to argc-1) in the program's argument list
where the given parameter apears, or 0 if not present
================
*/
unsigned
COM_CheckParm(const char *parm)
{
    unsigned i;

    for (i = 1; i < com_argc; i++) {
	if (!com_argv[i])
	    continue;		// NEXTSTEP sometimes clears appkit vars.
	if (!strcmp(parm, com_argv[i]))
	    return i;
    }

    return 0;
}

/*
================
COM_CheckRegistered

Looks for the pop.txt file and verifies it.
Sets the "registered" cvar.
Immediately exits out if an alternate game was attempted to be started without
being registered.
================
*/
void
COM_CheckRegistered(void)
{
    FILE *f;
    unsigned short check[128];
    int i;

    COM_FOpenFile("gfx/pop.lmp", &f);
    Cvar_Set("registered", "0");
    static_registered = 0;

    if (!f) {
	Con_Printf("Playing shareware version.\n");
#ifndef SERVERONLY
	if (com_modified)
#ifdef NQ_HACK
	    Sys_Error("You must have the registered version "
		      "to use modified games");
#endif
#ifdef QW_HACK
	    Sys_Error("You must have the registered version "
		      "to play QuakeWorld");
#endif
#endif /* SERVERONLY */
	return;
    }

    fread(check, 1, sizeof(check), f);
    fclose(f);

    for (i = 0; i < 128; i++)
	if (pop[i] != (unsigned short)BigShort(check[i]))
	    Sys_Error("Corrupted data file.");

    Cvar_Set("cmdline", com_cmdline);
    Cvar_Set("registered", "1");
    static_registered = 1;
    Con_Printf("Playing registered version.\n");
}


/*
================
COM_InitArgv
================
*/
void
COM_InitArgv(int argc, const char **argv)
{
    // Copy out the command line for the cmdline cvar
    int length = 0;
    for (int i = 0; i < MAX_NUM_ARGVS && i < argc; i++) {
        const char *source = argv[i];
        while (length < CMDLINE_LENGTH - 1 && *source) {
            com_cmdline[length++] = *source++;
        }
        if (length >= CMDLINE_LENGTH - 1 || i >= argc - 1)
            break;
        com_cmdline[length++] = ' ';
    }
    com_cmdline[length] = 0;

    // Copy out the argv pointers
    for (com_argc = 0; com_argc < MAX_NUM_ARGVS && com_argc < argc; com_argc++)
        largv[com_argc] = argv[com_argc];

    largv[com_argc] = argvdummy;
    com_argv = largv;

    if (COM_CheckParm("-safe")) {
	/*
         * Force all the safe-mode switches. Note that we reserved extra space in
         * case we need to add these, so we don't need an overflow check
         */
	for (int i = 0; i < NUM_SAFE_ARGVS; i++)
	    largv[com_argc++] = safeargvs[i];
    }

    largv[com_argc] = argvdummy;
    com_argv = largv;
}

/*
================
COM_AddParm

Adds the given string at the end of the current argument list
================
*/
#ifdef QW_HACK
void
COM_AddParm(const char *parm)
{
    largv[com_argc++] = parm;
}
#endif

void
COM_AddCommands()
{
    Cmd_AddCommand("path", COM_Path_f);
}

void
COM_RegisterVariables()
{
    Cvar_RegisterVariable(&registered);
    Cvar_RegisterVariable(&cmdline);
}

/*
============
va

does a varargs printf into a temp buffer, so I don't need to have
varargs versions of all text functions.
============
*/
const char *
va(const char *format, ...)
{
    va_list argptr;
    char *buf;
    int len;

    buf = COM_GetStrBuf();
    va_start(argptr, format);
    len = qvsnprintf(buf, COM_STRBUF_LEN, format, argptr);
    va_end(argptr);

    if (len > COM_STRBUF_LEN - 1)
	Con_DPrintf("%s: overflow (string truncated)\n", __func__);

    return buf;
}


/*
=============================================================================

QUAKE FILESYSTEM

=============================================================================
*/

//
// in memory
//

typedef struct {
    char name[MAX_QPATH];
    int filepos, filelen;
} packfile_t;

typedef struct pack_s {
    char filename[MAX_OSPATH];
    int numfiles;
    packfile_t *files;
} pack_t;

//
// on disk
//
#define MAX_PACKPATH 56
typedef struct {
    char name[MAX_PACKPATH];
    int filepos, filelen;
} dpackfile_t;

typedef struct {
    char id[4];
    int dirofs;
    int dirlen;
} dpackheader_t;

char com_basedir[MAX_OSPATH];
char com_gamedir[MAX_OSPATH];
char com_gamedirfile[MAX_OSPATH];
enum game_type com_game_type;

const char *com_game_type_names[] = {
    "id1",
    "qw",
    "hipnotic",
    "rogue",
    "quoth",
};

typedef struct searchpath_s {
    char filename[MAX_OSPATH];
    pack_t *pack;		// only one of filename / pack will be used
    struct searchpath_s *next;
} searchpath_t;

static searchpath_t *com_searchpaths;
static searchpath_t *com_base_searchpaths;

/*
================
COM_filelength
================
*/
static int
COM_filelength(FILE *f)
{
    int pos;
    int end;

    pos = ftell(f);
    fseek(f, 0, SEEK_END);
    end = ftell(f);
    fseek(f, pos, SEEK_SET);

    return end;
}

static int
COM_FileOpenRead(const char *path, FILE **hndl)
{
    FILE *f;

    f = fopen(path, "rb");
    if (!f) {
	*hndl = NULL;
	return -1;
    }
    *hndl = f;

    return COM_filelength(f);
}

/*
============
COM_Path_f

============
*/
static void
COM_Path_f(void)
{
    searchpath_t *s;

    Con_Printf("Current search path:\n");
    for (s = com_searchpaths; s; s = s->next) {
#ifdef QW_HACK
	if (s == com_base_searchpaths)
	    Con_Printf("----------\n");
#endif
	if (s->pack)
	    Con_Printf("%s (%i files)\n", s->pack->filename,
		       s->pack->numfiles);
	else
	    Con_Printf("%s\n", s->filename);
    }
}

/*
============
COM_WriteFile

The filename will be prefixed by the current game directory
============
*/
void
COM_WriteFile(const char *filename, const void *data, int len)
{
    FILE *f;

    f = COM_FOpenFileCreate(filename, "wb");
    if (!f) {
        Sys_Error("Error opening %s", filename);
    }
    fwrite(data, 1, len, f);
    fclose(f);
}


/*
============
COM_CreatePath
============
*/
void
COM_CreatePath(const char *relative_path)
{
    if (!relative_path || !relative_path[0])
	return;

    char path[MAX_OSPATH];
    qstrncpy(path, va("%s/%s", com_gamedir, relative_path), sizeof(path));

    for (char *ofs = path + 1; *ofs; ofs++) {
	if (*ofs == '/') {	// create the directory
	    *ofs = 0;

            Sys_Printf("%s: creating '%s'\n", __func__, path);

	    Sys_mkdir(path);
	    *ofs = '/';
	}
    }
}

/*
===========
COM_FOpenFile

Finds the file in the search path.
If the requested file is inside a packfile, a new FILE * will be opened
into the file.
===========
*/
int
COM_FOpenFile(const char *filename, FILE **file)
{
    const searchpath_t *search;
    const pack_t *pak;
    char path[MAX_OSPATH];

//
// search through the path, one element at a time
//
    for (search = com_searchpaths; search; search = search->next) {
	// is the element a pak file?
	if (search->pack) {
	    // look through all the pak file elements
	    pak = search->pack;
	    for (int i = 0; i < pak->numfiles; i++)
		if (!strcmp(pak->files[i].name, filename)) {	// found it!
		    // open a new file on the pakfile
		    *file = fopen(pak->filename, "rb");
		    if (!*file)
			Sys_Error("Couldn't reopen %s", pak->filename);
		    fseek(*file, pak->files[i].filepos, SEEK_SET);
		    return pak->files[i].filelen;
		}
	} else {
	    // check a file in the directory tree
	    if (!static_registered) {
		// if not a registered version, don't ever go beyond base
		if (strchr(filename, '/') || strchr(filename, '\\'))
		    continue;
	    }
	    qsnprintf(path, sizeof(path), "%s/%s", search->filename, filename);
	    *file = fopen(path, "rb");
            if (!*file)
                continue;

	    return COM_filelength(*file);
	}
    }
    *file = NULL;

    return -1;
}

FILE *
COM_FOpenFileCreate(const char *path, const char *mode)
{
    Sys_Printf("%s: path is '%s'\n", __func__, path);

    COM_CreatePath(path);
    return fopen(va("%s/%s", com_gamedir, path), mode);
}

/**
 * Returns the priority of a file in the current searchpaths.  Lower
 * numbers are higher priority.  If the file is not found, then -1 is
 * returned.
 */
int
COM_FilePriority(const char *filename)
{
    int priority = 0;
    const searchpath_t *search;
    const pack_t *pak;
    char path[MAX_OSPATH];

    for (search = com_searchpaths; search; search = search->next, priority++) {
	// is the element a pak file?
	if (search->pack) {
	    // look through all the pak file elements
	    pak = search->pack;
	    for (int i = 0; i < pak->numfiles; i++) {
		if (!strcmp(pak->files[i].name, filename))
                    return priority;
            }
	} else {
	    // check a file in the directory tree
	    if (!static_registered) {
		// if not a registered version, don't ever go beyond base
		if (strchr(filename, '/') || strchr(filename, '\\'))
		    continue;
	    }
	    qsnprintf(path, sizeof(path), "%s/%s", search->filename, filename);
            struct stat fileinfo;
            int error = stat(path, &fileinfo);
            if (!error && S_ISREG(fileinfo.st_mode))
                return priority;
	}
    }

    return -1;
}

static void
COM_ScanDirDir(struct stree_root *root, const char *path, const char *relative_path, DIR *dir,
               const char *prefix, const char *suffix, enum qscandir_flags flags)
{
    int prefix_len, suffix_len;
    struct dirent *d;
    char *fname;
    char relative_name[MAX_QPATH];

    prefix_len = prefix ? strlen(prefix) : 0;
    suffix_len = suffix ? strlen(suffix) : 0;

    while ((d = readdir(dir))) {
        if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
            continue;

        qsnprintf(relative_name, sizeof(relative_name), "%s%s", relative_path, d->d_name);
        if (flags & QSCANDIR_SUBDIRS) {
            struct stat fileinfo;
            char fullpath[MAX_OSPATH];

            qsnprintf(fullpath, sizeof(fullpath), "%s/%s", path, d->d_name);
            int error = stat(fullpath, &fileinfo);
            if (!error && S_ISDIR(fileinfo.st_mode)) {
                /* It's a directory.  If it doesn't conflict with prefix, check contents */
                int common_length = qmin(prefix_len, (int)strlen(relative_name));
                if (!common_length || !strncasecmp(prefix, relative_name, common_length)) {
                    DIR *subdir = opendir(fullpath);
                    if (subdir) {
                        qsnprintf(relative_name, sizeof(relative_name), "%s%s/", relative_path, d->d_name);
                        COM_ScanDirDir(root, fullpath, relative_name, subdir, prefix, suffix, flags);
                        closedir(subdir);
                        continue;
                    }
                }
            }
        }

	if (prefix && prefix_len && strncasecmp(relative_name, prefix, prefix_len))
	    continue;
	if (suffix && suffix_len && !COM_CheckSuffix(relative_name, suffix))
	    continue;

	int len = strlen(relative_name);
	if (suffix && !(flags & QSCANDIR_KEEP_SUFFIX))
	    len -= suffix_len;
	fname = Z_StrnDup(mainzone, relative_name, len);
	STree_InsertAlloc(root, fname, true);
	Z_Free(mainzone, fname);
    }
}

static void
COM_ScanDirPak(struct stree_root *root, const pack_t *pak, const char *path,
               const char *prefix, const char *suffix, enum qscandir_flags flags)
{
    int i, path_len, prefix_len, suffix_len, len;
    char *pak_f, *fname;

    path_len = path ? strlen(path) : 0;
    prefix_len = prefix ? strlen(prefix) : 0;
    suffix_len = suffix ? strlen(suffix) : 0;

    for (i = 0; i < pak->numfiles; i++) {
	/* Check the path prefix */
	pak_f = pak->files[i].name;
	if (path && path_len) {
	    if (strncasecmp(pak_f, path, path_len))
		continue;
	    if (pak_f[path_len] != '/')
		continue;
	    pak_f += path_len + 1;
	}

	if (strchr(pak_f, '/') && !(flags & QSCANDIR_SUBDIRS))
	    continue;

	/* Check the prefix and suffix, if set */
	if (prefix && prefix_len && strncasecmp(pak_f, prefix, prefix_len))
	    continue;
	if (suffix && suffix_len && !COM_CheckSuffix(pak_f, suffix))
	    continue;

	/* Ok, we have a match. Add it */
	len = strlen(pak_f);
	if (suffix && !(flags & QSCANDIR_KEEP_SUFFIX))
	    len -= suffix_len;
	fname = Z_StrnDup(mainzone, pak_f, len);
	STree_InsertAlloc(root, fname, true);
	Z_Free(mainzone, fname);
    }
}

/*
============
COM_ScanDir

Scan the contents of a the given directory. Any filenames that match
both the given prefix and suffix are added to the string tree.
Caller MUST have already called STree_AllocInit()
============
*/
void
COM_ScanDir(struct stree_root *root, const char *path,
            const char *prefix, const char *suffix, enum qscandir_flags flags)
{
    searchpath_t *search;
    char fullpath[MAX_OSPATH];
    DIR *dir;

    for (search = com_searchpaths; search; search = search->next) {
	if (search->pack) {
	    COM_ScanDirPak(root, search->pack, path, prefix, suffix, flags);
	} else {
	    qsnprintf(fullpath, sizeof(fullpath), "%s/%s", search->filename, path);
	    fullpath[MAX_OSPATH - 1] = '\0';
	    dir = opendir(fullpath);
	    if (dir) {
		COM_ScanDirDir(root, fullpath, "", dir, prefix, suffix, flags);
		closedir(dir);
	    }
	}
    }
}

/**
 * Scan the basedir for subdirectories.
 * Just for the game/gamedir command for now.
 */
void
COM_ScanBaseDir(struct stree_root *root, const char *prefix)
{
    DIR *directory;
    struct dirent *entry;

    directory = opendir(com_basedir);
    if (!directory)
        return;

    int prefix_len = prefix ? strlen(prefix) : 0;
    while ((entry = readdir(directory))) {
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, ".."))
            continue;
        if (prefix && prefix_len && strncasecmp(entry->d_name, prefix, prefix_len))
            continue;
        struct stat file_info;
        int error = stat(va("%s/%s", com_basedir, entry->d_name), &file_info);
        if (error || !(file_info.st_mode & S_IFDIR))
            continue;
        STree_InsertAlloc(root, entry->d_name, true);
    }
}

static void
COM_ReadFileAndClose(byte *buffer, size_t filesize, FILE *f)
{
#ifndef SERVERONLY
    Draw_BeginDisc();
#endif
    fread(buffer, 1, filesize, f);
    fclose(f);
#ifndef SERVERONLY
    Draw_EndDisc();
#endif
}

void *
COM_LoadHunkFile(const char *path, size_t *size)
{
    FILE *f;
    byte *buffer;
    size_t filesize;
    char hunkname[HUNK_NAMELEN + 1];

    filesize = COM_FOpenFile(path, &f);
    if (!f)
        return NULL;
    if (size)
        *size = filesize;

    COM_FileBase(path, hunkname, sizeof(hunkname));
    buffer = Hunk_AllocName(filesize + 1, hunkname);
    COM_ReadFileAndClose(buffer, filesize, f);
    buffer[filesize] = 0;

    return buffer;
}

void *
COM_LoadTempFile(const char *path, size_t *size)
{
    FILE *f;
    byte *buffer;
    size_t filesize;

    filesize = COM_FOpenFile(path, &f);
    if (!f)
        return NULL;
    if (size)
        *size = filesize;

    buffer = Hunk_TempAlloc(filesize + 1);
    COM_ReadFileAndClose(buffer, filesize, f);
    buffer[filesize] = 0;

    return buffer;
}

void
COM_LoadCacheFile(const char *path, struct cache_user_s *cache)
{
    FILE *f;
    byte *buffer;
    size_t filesize;

    filesize = COM_FOpenFile(path, &f);
    if (!filesize)
        Sys_Error("%s: Unable to load %s\n", __func__, path);

    buffer = Cache_Alloc(cache, filesize + 1, path);
    COM_ReadFileAndClose(buffer, filesize, f);
    buffer[filesize] = 0;
}

// uses temp hunk if larger than bufsize
// size is size of loaded file in bytes
void *
COM_LoadStackFile(const char *path, void *buffer, size_t buffersize, size_t *size)
{
    FILE *f;
    byte *bytebuffer;
    size_t filesize;

    filesize = COM_FOpenFile(path, &f);
    if (!f)
        return NULL;
    if (size)
        *size = filesize;

    /* Fall back to temp allocation if too large */
    bytebuffer = (buffersize < filesize + 1) ? Hunk_TempAlloc(filesize + 1) : buffer;
    COM_ReadFileAndClose(bytebuffer, filesize, f);
    bytebuffer[filesize] = 0;

    return bytebuffer;
}

/*
=================
COM_LoadPackFile

Takes an explicit (not game tree related) path to a pak file.

Loads the header and directory, adding the files at the beginning
of the list so they override previous pack files.
=================
*/
static pack_t *
COM_LoadPackFile(const char *packfile)
{
    FILE *packhandle;
    dpackheader_t header;
    dpackfile_t *dfiles;
    packfile_t *mfiles;
    pack_t *pack;
    int i, numfiles;
    unsigned short crc;

    if (COM_FileOpenRead(packfile, &packhandle) == -1)
	return NULL;

    fread(&header, 1, sizeof(header), packhandle);
    if (header.id[0] != 'P' || header.id[1] != 'A' || header.id[2] != 'C' || header.id[3] != 'K')
	Sys_Error("%s is not a packfile", packfile);
    header.dirofs = LittleLong(header.dirofs);
    header.dirlen = LittleLong(header.dirlen);

    numfiles = header.dirlen / sizeof(dpackfile_t);
    if (numfiles != ID1_PAK0_COUNT)
	com_modified = true;	// not the original file

    mfiles = Hunk_AllocName(numfiles * sizeof(*mfiles), "packfile");
    int mark = Hunk_LowMark();
    dfiles = Hunk_AllocName(numfiles * sizeof(*dfiles), "packtmp");

    fseek(packhandle, header.dirofs, SEEK_SET);
    fread(dfiles, 1, header.dirlen, packhandle);
    fclose(packhandle);

    /* crc the directory to check for modifications */
    crc = CRC_Block((byte *)dfiles, header.dirlen);
    switch (crc) {
#ifdef NQ_HACK
    case ID1_PAK0_CRC_V100:
    case ID1_PAK0_CRC_V101:
    case ID1_PAK0_CRC_V106:
#endif
#ifdef QW_HACK
    case QW_PAK0_CRC:
#endif
	com_modified = false;
	break;
    default:
	com_modified = true;
	break;
    }

    /* parse the directory */
    for (i = 0; i < numfiles; i++) {
	qsnprintf(mfiles[i].name, sizeof(mfiles[i].name), "%s", dfiles[i].name);
	mfiles[i].filepos = LittleLong(dfiles[i].filepos);
	mfiles[i].filelen = LittleLong(dfiles[i].filelen);
    }

    Hunk_FreeToLowMark(mark);
    pack = Hunk_AllocName(sizeof(pack_t), "pakheadr");
    qsnprintf(pack->filename, sizeof(pack->filename), "%s", packfile);
    pack->numfiles = numfiles;
    pack->files = mfiles;

    Con_Printf("Added packfile %s (%i files)\n", packfile, numfiles);

    return pack;
}


/*
================
COM_AddGameDirectory

Sets com_gamedir, adds the directory to the head of the path,
then loads and adds pak1.pak pak2.pak ...
================
*/
static void
COM_AddGameDirectory(const char *base, const char *directory)
{
    int i;
    searchpath_t *search;
    pack_t *pack;
    char pakfile[MAX_OSPATH];

    if (!base)
	return;

    qstrncpy(com_gamedir, va("%s/%s", base, directory), sizeof(com_gamedir));
    qstrncpy(com_gamedirfile, directory, sizeof(com_gamedirfile));

//
// add the directory to the search path
//
    search = Hunk_AllocName(sizeof(searchpath_t), "gamedir");
    qstrncpy(search->filename, com_gamedir, sizeof(search->filename));
    search->next = com_searchpaths;
    com_searchpaths = search;

//
// add any pak files in the format pak0.pak pak1.pak, ...
//
    for (i = 0;; i++) {
	qsnprintf(pakfile, sizeof(pakfile), "%s/pak%i.pak", com_gamedir, i);
	pack = COM_LoadPackFile(pakfile);
	if (!pack)
	    break;
        search = Hunk_AllocName(sizeof(searchpath_t), "gamedir");
	search->pack = pack;
	search->next = com_searchpaths;
	com_searchpaths = search;
    }
}

qboolean
COM_ValidGamedir(const char *name)
{
    char c;

    if (!name || !*name)
        return false;

    while ((c = *name++))
        if (!isalnum(c) && c != '_' && c != '-')
            return false;

    return true;
}

static int com_filesystem_mark;
static int com_basedir_mark;

/*
 * TODO: The global state might be better in a struct anyway and then we can just assign/memcpy it.
 */
static struct game_directory_state {
    qboolean saved;
    int hunk_mark;
    qboolean standard_quake;
    qboolean hipnotic;
    qboolean rogue;
    qboolean com_modified;
    enum game_type com_game_type;
    searchpath_t *com_searchpaths;
    char com_gamedir[MAX_OSPATH];
    char com_gamedirfile[MAX_OSPATH];
} saved_game_directory_state;

static void
COM_SaveGameDirectoryState()
{
    saved_game_directory_state.standard_quake  = standard_quake;
    saved_game_directory_state.hipnotic        = hipnotic;
    saved_game_directory_state.rogue           = rogue;
    saved_game_directory_state.com_modified    = com_modified;
    saved_game_directory_state.com_game_type   = com_game_type;
    saved_game_directory_state.com_searchpaths = com_searchpaths;
    qstrncpy(saved_game_directory_state.com_gamedir, com_gamedir, sizeof(saved_game_directory_state.com_gamedir));
    qstrncpy(saved_game_directory_state.com_gamedirfile, com_gamedirfile, sizeof(saved_game_directory_state.com_gamedirfile));

    saved_game_directory_state.saved = true;
    saved_game_directory_state.hunk_mark = Hunk_LowMark();
}

static void
COM_RestoreGameDirectoryState()
{
    assert(saved_game_directory_state.saved);

    standard_quake  = saved_game_directory_state.standard_quake;
    hipnotic        = saved_game_directory_state.hipnotic;
    rogue           = saved_game_directory_state.rogue;
    com_modified    = saved_game_directory_state.com_modified;
    com_game_type   = saved_game_directory_state.com_game_type;
    hipnotic        = saved_game_directory_state.hipnotic;
    com_searchpaths = saved_game_directory_state.com_searchpaths;
    qstrncpy(com_gamedir, saved_game_directory_state.com_gamedir, sizeof(com_gamedir));
    qstrncpy(com_gamedirfile, saved_game_directory_state.com_gamedirfile, sizeof(com_gamedirfile));

    saved_game_directory_state.saved = false;
    Hunk_FreeToLowMark(saved_game_directory_state.hunk_mark);
}

void
COM_InitTempGameDirectory(const char *directory, enum game_type game_type)
{
    COM_SaveGameDirectoryState();
    com_searchpaths = com_base_searchpaths;
    qstrncpy(com_gamedirfile, directory, sizeof(com_gamedirfile));
    COM_InitGameDirectory(directory, game_type);
}

void
COM_RestoreGameDirectory()
{
    COM_RestoreGameDirectoryState();
}

qboolean
COM_CheckForGameDirectoryChange(const char *directory, enum game_type game_type)
{
    if (!directory || !directory[0])
        return false;

    /* For the purposes of QW, the "id1" gamedir is the same as "qw" */
    if (game_type == GAME_TYPE_QW && !strcmp(directory, "id1"))
        directory = "qw";

    /* If directory and game type unchanged, nothing to do */
    return strcmp(com_gamedirfile, directory) || com_game_type != game_type;
}

/*
================
COM_Gamedir

Sets the gamedir and path to a different directory.
================
*/
qboolean
COM_Gamedir(const char *directory, enum game_type game_type)
{
    if (!COM_ValidGamedir(directory))
        return false;
    if (!COM_CheckForGameDirectoryChange(directory, game_type))
        return false;

    /* flush all data, so it will be forced to reload */
    Cache_Flush();
    Mod_ClearAll();
#ifdef GLQUAKE
    Draw_ResetPicTextures();
#endif

    /* Free up any current game directory info */
    host_hunklevel = 0;
    Hunk_FreeToLowMark(com_basedir_mark);
    com_searchpaths = com_base_searchpaths;

    /*
     * Set com_gamedirfile here, because if we are resetting to a base
     * path, InitGameDirectory won't write this via
     * COM_AddGameDirectory
     */
    qstrncpy(com_gamedirfile, directory, sizeof(com_gamedirfile));
    COM_InitGameDirectory(directory, game_type);

    return true;
}

/**
 * Initialise the filesystem up to the base gamedir (id1)
 */
void
COM_InitFileSystem()
{
    int i;
    char *home;

    com_searchpaths = NULL;

    /* Free any existing hunk allocations and mark the start */
    if (com_filesystem_mark)
        Hunk_FreeToLowMark(com_filesystem_mark);
    com_filesystem_mark = Hunk_LowMark();

    home = getenv("HOME");

//
// -basedir <path>
// Overrides the system supplied base directory (under id1)
//
    i = COM_CheckParm("-basedir");
    if (i && i < com_argc - 1)
	strcpy(com_basedir, com_argv[i + 1]);
    else
	strcpy(com_basedir, host_parms.basedir);

    /* Load ID1 by default */
    COM_AddGameDirectory(com_basedir, "id1");
    if (home)
        COM_AddGameDirectory(va("%s/.tyrquake", home), "id1");

#ifdef QW_HACK
    COM_AddGameDirectory(com_basedir, "qw");
    if (home)
        COM_AddGameDirectory(va("%s/.tyrquake", home), "qw");
    com_modified = true;
    com_game_type = GAME_TYPE_QW;
#endif

    com_base_searchpaths = com_searchpaths;
    com_basedir_mark = Hunk_LowMark();
    COM_CheckRegistered();
}

void
COM_InitGameDirectory(const char *gamedir, enum game_type game_type)
{
    /* TODO: use proper location for user files on Win32.  Sys_UserDir()? */
    const char *home = getenv("HOME");

    com_modified = false;
    rogue = false;
    hipnotic = false;
    standard_quake = true;

    switch (game_type) {
        case GAME_TYPE_HIPNOTIC:
            COM_AddGameDirectory(com_basedir, "hipnotic");
            if (home)
                COM_AddGameDirectory(va("%s/.tyrquake", home), "hipnotic");
            hipnotic = true;
            standard_quake = false;
            com_modified = true;
            break;
        case GAME_TYPE_QUOTH:
            COM_AddGameDirectory(com_basedir, "quoth");
            if (home)
                COM_AddGameDirectory(va("%s/.tyrquake", home), "quoth");
            hipnotic = true;
            standard_quake = false;
            com_modified = true;
            break;
        case GAME_TYPE_ROGUE:
            COM_AddGameDirectory(com_basedir, "rogue");
            if (home)
                COM_AddGameDirectory(va("%s/.tyrquake", home), "rogue");
            rogue = true;
            standard_quake = false;
            com_modified = true;
            break;
        case GAME_TYPE_QW:
            COM_AddGameDirectory(com_basedir, "qw");
            if (home)
                COM_AddGameDirectory(va("%s/.tyrquake", home), "qw");
            com_modified = true;
        default:
            break;
    }
    com_game_type = game_type;

    if (gamedir) {
        /* If gamedir is already in the search path, don't add */
        searchpath_t *search;
        for (search = com_searchpaths; search; search = search->next) {
            if (!search->pack && !strcmp(gamedir, COM_SkipPath(search->filename)))
                return;
        }

        COM_AddGameDirectory(com_basedir, gamedir);
        if (home)
            COM_AddGameDirectory(va("%s/.tyrquake", home), gamedir);
    }
}

void
COM_InitGameDirectoryFromCommandLine()
{
    enum game_type game_type = GAME_TYPE_ID1;
    const char *game_directory = "id1";

    /* Check for mission pack parameters */
#ifdef NQ_HACK
    if (COM_CheckParm("-hipnotic")) {
        game_type = GAME_TYPE_HIPNOTIC;
    } else if (COM_CheckParm("-quoth")) {
        game_type = GAME_TYPE_QUOTH;
    } else if (COM_CheckParm("-rogue")) {
        game_type = GAME_TYPE_ROGUE;
    }
#endif

    /* Check the -game parameter */
    int i = COM_CheckParm("-game");
    if (!i)
        return;
    game_directory = com_argv[i + 1];
    if (!COM_ValidGamedir(game_directory)) {
        Con_Printf("Invalid game directory name '%s'.  "
                   "Must be a single directory name and not a path.\n", com_argv[i + 1]);
        return;
    }

    COM_InitGameDirectory(game_directory, game_type);
}

/*
 * =====================================================================
 * Entity Key/Value Parsing
 * =====================================================================
 */

/*
 * Find the value for the given key and write it into the given buffer.
 * Returns a pointer to the buffer if found, NULL otherwise.
 */
char *
Entity_ValueForKey(const char *string, const char *key, char *buffer, int buflen)
{
    assert(buflen > 0);

    buffer[0] = 0;

    /* Ensure we actually find the start of the entity */
    if (!string)
        return NULL;
    string = COM_Parse(string);
    if (!string)
        return NULL;
    if (com_token[0] != '{')
        return NULL;

    /* Parse the keys until we find the one we want */
    while (1) {
        string = COM_Parse(string);
        if (!string)
            break;
        if (com_token[0] == '}')
            break;

        /*
         * Clean the key by excluding a leading underscore and
         * removing trailing whitespace.
         */
        const char *cur = (com_token[0] == '_') ? com_token + 1 : com_token;
        const char *end = cur + strlen(cur) - 1;
        while (*end == ' ')
            end--;

        /* If the key doesn't match, discard the value and continue */
        if (strncmp(cur, key, cur - end + 1)) {
            string = COM_Parse(string);
            if (!string)
                return NULL;
            continue;
        }

        /* Key matches - copy the value into the buffer and return */
        string = COM_Parse(string);
        qstrncpy(buffer, com_token, buflen);
        return buffer;
    }

    return NULL;
}


// FIXME - everything below is QW only... move it?
#ifdef QW_HACK
/*
=====================================================================

  INFO STRINGS

=====================================================================
*/

/*
 * INFO HELPER FUNCTIONS
 *
 * Helper fuction to copy off the next string in the info string
 * Copies the next '\\' separated string into the buffer of size buflen
 * Always zero terminates the buffer
 * Returns a pointer to the char following the returned string.
 *
 * Key/Value checks are consolidated into Info_ReadKey and Info_ReadValue
 */
static const char *
Info_ReadString(const char *infostring, char *buffer, int buflen)
{
    char *out = buffer;

    while (out - buffer < buflen - 1) {
	if (!*infostring || *infostring == '\\')
	    break;
	*out++ = *infostring++;
    }
    *out = 0;

    return infostring;
}

static const char *
Info_ReadKey(const char *infostring, char *buffer, int buflen)
{
    const char *pkey;

    if (*infostring == '\\')
	infostring++;

    pkey = infostring;
    infostring = Info_ReadString(infostring, buffer, buflen);

    /* If we aren't at a separator, then the key was too long */
    if (*buffer && *infostring != '\\')
	Con_DPrintf("WARNING: No separator after info key (%s)\n", pkey);

    return infostring;
}

static const char *
Info_ReadValue(const char *infostring, char *buffer, int buflen)
{
    infostring = Info_ReadString(infostring, buffer, buflen);

    /* If we aren't at a separator, then the value was too long */
    if (*infostring && *infostring != '\\')
	Con_DPrintf("WARNING: info value too long? (%s)\n", buffer);

    return infostring;
}

/*
===============
Info_ValueForKey

Searches the string for the given
key and returns the associated value, or an empty string.
===============
*/
char *
Info_ValueForKey(const char *infostring, const char *key)
{
    /* use multiple buffers so compares work without stomping on each other */
    static char buffers[4][MAX_INFO_STRING];
    static int buffer_index;

    char pkey[MAX_INFO_STRING];
    char *buf;

    buffer_index = (buffer_index + 1) & 3;
    buf = buffers[buffer_index];

    while (1) {
	/* Retrieve the key */
	infostring = Info_ReadKey(infostring, pkey, sizeof(pkey));
	if (*infostring != '\\') {
	    *buf = 0;
	    return buf;
	}
	infostring++;

	/* Retrieve the value */
	infostring = Info_ReadString(infostring, buf, sizeof(buffers[0]));
	if (*infostring && *infostring != '\\') {
	    *buf = 0;
	    return buf;
	}

	/* If the keys match, return the value in the buffer */
	if (!strcmp(key, pkey))
	    return buf;

	/* Return if we've reached the end of the infostring */
	if (!*infostring) {
	    *buf = 0;
	    return buf;
	}
	infostring++;
    }
}

void
Info_RemoveKey(char *infostring, const char *key)
{
    char *start;
    char pkey[MAX_INFO_STRING];
    char value[MAX_INFO_STRING];

    if (strstr(key, "\\")) {
	Con_Printf("Can't use a key with a \\\n");
	return;
    }

    while (1) {
	start = infostring;

	infostring = (char *)Info_ReadKey(infostring, pkey, sizeof(pkey));
	if (*infostring)
	    infostring++;
	infostring = (char *)Info_ReadValue(infostring, value, sizeof(value));
	if (*infostring)
	    infostring++;

	/* If the keys match, remove this part of the string */
	if (!strcmp(key, pkey)) {
	    memmove(start, infostring, strlen(infostring) + 1);
	    return;
	}
	if (!*infostring)
	    return;
    }
}

void
Info_RemovePrefixedKeys(char *infostring, char prefix)
{
    char *start;
    char pkey[MAX_INFO_STRING];
    char value[MAX_INFO_STRING];

    start = infostring;
    while (1) {
	infostring = (char *)Info_ReadKey(infostring, pkey, sizeof(pkey));
	if (*infostring)
	    infostring++;
	infostring = (char *)Info_ReadValue(infostring, value, sizeof(value));
	if (*infostring)
	    infostring++;

	/* If the prefix matches, remove the key */
	if (pkey[0] == prefix) {
	    Info_RemoveKey(start, pkey);
	    infostring = start;
	}
	if (!*infostring)
	    return;
    }
}

void
Info_SetValueForStarKey(char *infostring, const char *key, const char *value, int maxsize)
{
    char buffer[MAX_INFO_STRING * 2];
    char *oldvalue, *info;
    int c, len;

    if (strstr(key, "\\") || strstr(value, "\\")) {
	Con_Printf("Can't use keys or values with a \\\n");
	return;
    }
    if (strstr(key, "\"") || strstr(value, "\"")) {
	Con_Printf("Can't use keys or values with a \"\n");
	return;
    }
    if (strlen(key) > 63 || strlen(value) > 63) {
	Con_Printf("Keys and values must be < 64 characters.\n");
	return;
    }

    oldvalue = Info_ValueForKey(infostring, key);
    if (*oldvalue) {
	/*
	 * Key exists. Make sure we have enough room for new value.
	 * If we don't, don't change it!
	 */
	len = strlen(infostring) - strlen(oldvalue) + strlen(value);
	if (len > maxsize - 1)
	    goto ErrTooLong;
    }

    Info_RemoveKey(infostring, key);
    if (!value || !strlen(value))
	return;

    len = qsnprintf(buffer, sizeof(buffer), "\\%s\\%s", key, value);
    if (len > sizeof(buffer) - 1)
	goto ErrTooLong;

    len += strlen(infostring);
    if (len > maxsize - 1)
	goto ErrTooLong;

    /* Append the new key/value pair to the info string */
    infostring += strlen(infostring);
    info = buffer;
    while (*info) {
	c = (unsigned char)*info++;
#ifndef SERVERONLY
	/* client only allows highbits on name */
	if (strcasecmp(key, "name")) {
	    c &= 127;
	    if (c < 32 || c > 127)
		continue;
	    /* auto lowercase team */
	    if (!strcasecmp(key, "team"))
		c = tolower(c);
	}
#else
	if (!sv_highchars.value) {
	    c &= 127;
	    if (c < 32 || c > 127)
		continue;
	}
#endif
	if (c > 13)
	    *infostring++ = c;
    }
    *infostring = 0;
    return;

 ErrTooLong:
	Con_Printf("Info string length exceeded\n");
}

void
Info_SetValueForKey(char *infostring, const char *key, const char *value, int maxsize)
{
    if (key[0] == '*') {
	Con_Printf("Can't set * keys\n");
	return;
    }
    Info_SetValueForStarKey(infostring, key, value, maxsize);
}

void
Info_Print(const char *infostring)
{
    char key[MAX_INFO_STRING];
    char value[MAX_INFO_STRING];

    while (*infostring) {
	infostring = Info_ReadKey(infostring, key, sizeof(key));
	if (*infostring)
	    infostring++;
	infostring = Info_ReadValue(infostring, value, sizeof(value));
	if (*infostring)
	    infostring++;

	Con_Printf("%-20.20s %s\n", key, *value ? value : "MISSING VALUE");
    }
}

static byte chktbl[1024 + 4] = {
    0x78, 0xd2, 0x94, 0xe3, 0x41, 0xec, 0xd6, 0xd5, 0xcb, 0xfc, 0xdb, 0x8a, 0x4b, 0xcc, 0x85, 0x01,
    0x23, 0xd2, 0xe5, 0xf2, 0x29, 0xa7, 0x45, 0x94, 0x4a, 0x62, 0xe3, 0xa5, 0x6f, 0x3f, 0xe1, 0x7a,
    0x64, 0xed, 0x5c, 0x99, 0x29, 0x87, 0xa8, 0x78, 0x59, 0x0d, 0xaa, 0x0f, 0x25, 0x0a, 0x5c, 0x58,
    0xfb, 0x00, 0xa7, 0xa8, 0x8a, 0x1d, 0x86, 0x80, 0xc5, 0x1f, 0xd2, 0x28, 0x69, 0x71, 0x58, 0xc3,
    0x51, 0x90, 0xe1, 0xf8, 0x6a, 0xf3, 0x8f, 0xb0, 0x68, 0xdf, 0x95, 0x40, 0x5c, 0xe4, 0x24, 0x6b,
    0x29, 0x19, 0x71, 0x3f, 0x42, 0x63, 0x6c, 0x48, 0xe7, 0xad, 0xa8, 0x4b, 0x91, 0x8f, 0x42, 0x36,
    0x34, 0xe7, 0x32, 0x55, 0x59, 0x2d, 0x36, 0x38, 0x38, 0x59, 0x9b, 0x08, 0x16, 0x4d, 0x8d, 0xf8,
    0x0a, 0xa4, 0x52, 0x01, 0xbb, 0x52, 0xa9, 0xfd, 0x40, 0x18, 0x97, 0x37, 0xff, 0xc9, 0x82, 0x27,
    0xb2, 0x64, 0x60, 0xce, 0x00, 0xd9, 0x04, 0xf0, 0x9e, 0x99, 0xbd, 0xce, 0x8f, 0x90, 0x4a, 0xdd,
    0xe1, 0xec, 0x19, 0x14, 0xb1, 0xfb, 0xca, 0x1e, 0x98, 0x0f, 0xd4, 0xcb, 0x80, 0xd6, 0x05, 0x63,
    0xfd, 0xa0, 0x74, 0xa6, 0x86, 0xf6, 0x19, 0x98, 0x76, 0x27, 0x68, 0xf7, 0xe9, 0x09, 0x9a, 0xf2,
    0x2e, 0x42, 0xe1, 0xbe, 0x64, 0x48, 0x2a, 0x74, 0x30, 0xbb, 0x07, 0xcc, 0x1f, 0xd4, 0x91, 0x9d,
    0xac, 0x55, 0x53, 0x25, 0xb9, 0x64, 0xf7, 0x58, 0x4c, 0x34, 0x16, 0xbc, 0xf6, 0x12, 0x2b, 0x65,
    0x68, 0x25, 0x2e, 0x29, 0x1f, 0xbb, 0xb9, 0xee, 0x6d, 0x0c, 0x8e, 0xbb, 0xd2, 0x5f, 0x1d, 0x8f,
    0xc1, 0x39, 0xf9, 0x8d, 0xc0, 0x39, 0x75, 0xcf, 0x25, 0x17, 0xbe, 0x96, 0xaf, 0x98, 0x9f, 0x5f,
    0x65, 0x15, 0xc4, 0x62, 0xf8, 0x55, 0xfc, 0xab, 0x54, 0xcf, 0xdc, 0x14, 0x06, 0xc8, 0xfc, 0x42,
    0xd3, 0xf0, 0xad, 0x10, 0x08, 0xcd, 0xd4, 0x11, 0xbb, 0xca, 0x67, 0xc6, 0x48, 0x5f, 0x9d, 0x59,
    0xe3, 0xe8, 0x53, 0x67, 0x27, 0x2d, 0x34, 0x9e, 0x9e, 0x24, 0x29, 0xdb, 0x69, 0x99, 0x86, 0xf9,
    0x20, 0xb5, 0xbb, 0x5b, 0xb0, 0xf9, 0xc3, 0x67, 0xad, 0x1c, 0x9c, 0xf7, 0xcc, 0xef, 0xce, 0x69,
    0xe0, 0x26, 0x8f, 0x79, 0xbd, 0xca, 0x10, 0x17, 0xda, 0xa9, 0x88, 0x57, 0x9b, 0x15, 0x24, 0xba,
    0x84, 0xd0, 0xeb, 0x4d, 0x14, 0xf5, 0xfc, 0xe6, 0x51, 0x6c, 0x6f, 0x64, 0x6b, 0x73, 0xec, 0x85,
    0xf1, 0x6f, 0xe1, 0x67, 0x25, 0x10, 0x77, 0x32, 0x9e, 0x85, 0x6e, 0x69, 0xb1, 0x83, 0x00, 0xe4,
    0x13, 0xa4, 0x45, 0x34, 0x3b, 0x40, 0xff, 0x41, 0x82, 0x89, 0x79, 0x57, 0xfd, 0xd2, 0x8e, 0xe8,
    0xfc, 0x1d, 0x19, 0x21, 0x12, 0x00, 0xd7, 0x66, 0xe5, 0xc7, 0x10, 0x1d, 0xcb, 0x75, 0xe8, 0xfa,
    0xb6, 0xee, 0x7b, 0x2f, 0x1a, 0x25, 0x24, 0xb9, 0x9f, 0x1d, 0x78, 0xfb, 0x84, 0xd0, 0x17, 0x05,
    0x71, 0xb3, 0xc8, 0x18, 0xff, 0x62, 0xee, 0xed, 0x53, 0xab, 0x78, 0xd3, 0x65, 0x2d, 0xbb, 0xc7,
    0xc1, 0xe7, 0x70, 0xa2, 0x43, 0x2c, 0x7c, 0xc7, 0x16, 0x04, 0xd2, 0x45, 0xd5, 0x6b, 0x6c, 0x7a,
    0x5e, 0xa1, 0x50, 0x2e, 0x31, 0x5b, 0xcc, 0xe8, 0x65, 0x8b, 0x16, 0x85, 0xbf, 0x82, 0x83, 0xfb,
    0xde, 0x9f, 0x36, 0x48, 0x32, 0x79, 0xd6, 0x9b, 0xfb, 0x52, 0x45, 0xbf, 0x43, 0xf7, 0x0b, 0x0b,
    0x19, 0x19, 0x31, 0xc3, 0x85, 0xec, 0x1d, 0x8c, 0x20, 0xf0, 0x3a, 0xfa, 0x80, 0x4d, 0x2c, 0x7d,
    0xac, 0x60, 0x09, 0xc0, 0x40, 0xee, 0xb9, 0xeb, 0x13, 0x5b, 0xe8, 0x2b, 0xb1, 0x20, 0xf0, 0xce,
    0x4c, 0xbd, 0xc6, 0x04, 0x86, 0x70, 0xc6, 0x33, 0xc3, 0x15, 0x0f, 0x65, 0x19, 0xfd, 0xc2, 0xd3,

// map checksum goes here
    0x00, 0x00, 0x00, 0x00
};


#if 0
/*
====================
COM_BlockSequenceCheckByte

For proxy protecting
====================
*/
byte
COM_BlockSequenceCheckByte(const byte *base, int length, int sequence,
			   unsigned mapchecksum)
{
    static unsigned last_mapchecksum;
    unsigned char chkbuf[16 + 60 + 4];
    int checksum;
    byte *p;

    if (last_mapchecksum != mapchecksum) {
	last_mapchecksum = mapchecksum;
	chktbl[1024] = (mapchecksum & 0xff000000) >> 24;
	chktbl[1025] = (mapchecksum & 0x00ff0000) >> 16;
	chktbl[1026] = (mapchecksum & 0x0000ff00) >> 8;
	chktbl[1027] = (mapchecksum & 0x000000ff);

	Com_BlockFullChecksum(chktbl, sizeof(chktbl), chkbuf);
    }

    p = chktbl + (sequence % (sizeof(chktbl) - 8));

    if (length > 60)
	length = 60;
    memcpy(chkbuf + 16, base, length);

    length += 16;

    chkbuf[length] = (sequence & 0xff) ^ p[0];
    chkbuf[length + 1] = p[1];
    chkbuf[length + 2] = ((sequence >> 8) & 0xff) ^ p[2];
    chkbuf[length + 3] = p[3];

    length += 4;

    checksum = LittleLong(Com_BlockChecksum(chkbuf, length));

    checksum &= 0xff;

    return checksum;
}
#endif

/*
====================
COM_BlockSequenceCRCByte

For proxy protecting
====================
*/
byte
COM_BlockSequenceCRCByte(const byte *base, int length, int sequence)
{
    unsigned short crc;
    const byte *p;
    byte chkb[60 + 4];

    p = chktbl + (sequence % (sizeof(chktbl) - 8));

    if (length > 60)
	length = 60;
    memcpy(chkb, base, length);

    chkb[length] = (sequence & 0xff) ^ p[0];
    chkb[length + 1] = p[1];
    chkb[length + 2] = ((sequence >> 8) & 0xff) ^ p[2];
    chkb[length + 3] = p[3];

    length += 4;

    crc = CRC_Block(chkb, length);

    crc &= 0xff;

    return crc;
}

#endif /* QW_HACK */
