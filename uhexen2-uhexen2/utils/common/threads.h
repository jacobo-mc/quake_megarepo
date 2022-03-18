/* threads.h
 * Copyright (C) 1996-1997  Id Software, Inc.
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

#ifndef H2UTILS_THREADS_H
#define H2UTILS_THREADS_H

#define	MAX_THREADS	32

int	Thread_GetNumCPUS (void);

typedef void (*threadfunc_t) (void *);

void	InitThreads (int wantthreads, size_t needstack);
void	ThreadLock (void);
void	ThreadUnlock (void);
void	RunThreadsOn (threadfunc_t func);

#endif	/* H2UTILS_THREADS_H */
