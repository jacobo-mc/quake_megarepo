/* zone.h
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 1997-1998  Raven Software Corp.
 * Copyright (C) 2005-2012  O.Sezer <sezero@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef ZZONE_H
#define ZZONE_H

/*	Memory allocation

H_??? The hunk manages the entire memory block given to quake.  It must be
contiguous.  Memory can be allocated from either the low or high end in a
stack fashion.  The only way memory is released is by resetting one of the
pointers.

Hunk allocations should be given a name, so the Hunk_Print () function
can display usage.

Hunk allocations are guaranteed to be 16 byte aligned.

The video buffers are allocated high to avoid leaving a hole underneath
server allocations when changing to a higher video mode.


Z_??? Zone memory functions used for small, dynamic allocations like text
strings from command input.  There is only about 48K for it, allocated at
the very bottom of the hunk.

Cache_??? Cache memory is for objects that can be dynamically loaded and
can usefully stay persistant between levels.  The size of the cache
fluctuates from level to level.

To allocate a cachable object


Temp_??? Temp memory is used for file loading and surface caching.  The size
of the cache memory is adjusted so that there is a minimum of 512k remaining
for temp memory.


------ Top of Memory -------

high hunk allocations

<--- high hunk reset point held by vid

video buffer

z buffer

surface cache

<--- high hunk used

cachable memory

<--- low hunk used

client and server low hunk allocations

<-- low hunk reset point held by host

startup hunk allocations

Zone block

----- Bottom of Memory -----

*/


void Memory_Init (void *buf, int size);


/* valid values zone_idx arg: */
#define	Z_MAINZONE	(1 << 0)
#define	Z_SECZONE	(1 << 1)

#ifdef __cplusplus
extern "C" {
#endif
void Z_Free (void *ptr);
void *Z_Malloc (int size, int zone_id);	/* returns 0 filled memory */
void *Z_Realloc (void *ptr, int size, int zone_id);
char *Z_Strdup (const char *s);
#ifdef __cplusplus
}
#endif

void *Hunk_Alloc (int size);		/* returns 0 filled memory */
void *Hunk_AllocName (int size, const char *name);
void *Hunk_HighAllocName (int size, const char *name);
char *Hunk_Strdup (const char *s, const char *name);

void *Hunk_TempAlloc (int size);

int Hunk_LowMark (void);
void Hunk_FreeToLowMark (int mark);
int Hunk_HighMark (void);
void Hunk_FreeToHighMark (int mark);

void Hunk_Check (void);

#if !defined(SERVERONLY)
typedef struct cache_user_s
{
	void	*data;
} cache_user_t;

void Cache_Flush (void);

void *Cache_Check (cache_user_t *c);
/* returns the cached data, and moves to the head of the LRU list
 * if present, otherwise returns NULL */

void Cache_Free (cache_user_t *c);

void *Cache_Alloc (cache_user_t *c, int size, const char *name);
/* Returns NULL if all purgable data was tossed and there still
 * wasn't enough room */

void Cache_Report (void);
#endif	/* SERVERONLY */

#endif	/* ZZONE_H */
