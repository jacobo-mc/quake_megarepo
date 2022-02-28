/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// vis.h

#include "cmdlib.h"
#include "mathlib.h"
#include "bspfile.h"

#define	MAX_PORTALS	32768

#define	PORTALFILE	"PRT1-AM"

#define	ON_EPSILON	0.1

typedef struct
{
	vec3_t		normal;
	float		dist;
} plane_t;

typedef struct
{
	qboolean	original;			// don't free, it's part of the portal
	int		numpoints;
	vec3_t	points[8];			// variable sized
} winding_t;

#define MAX_POINTS_ON_WINDING	64

winding_t	*NewWinding (int points);
void		FreeWinding (winding_t *w);
winding_t *ClipWinding (winding_t *in, plane_t *split, qboolean keepon);
winding_t	*CopyWinding (winding_t *w);


typedef enum {stat_none, stat_working, stat_done} vstatus_t;
typedef struct
{
	plane_t		plane;    // normal pointing into neighbor
	int			cluster;  // neighbor
	winding_t	*winding;
	vstatus_t	status;
	byte		*visbits;
	byte		*mightsee;
	int			nummightsee;
	int			numcansee;
} portal_t;

typedef struct seperating_plane_s
{
	struct seperating_plane_s *next;
	plane_t		plane;		// from portal is on positive side
} sep_t;


typedef struct passage_s
{
	struct passage_s	*next;
	int			from, to;		// cluster numbers
	sep_t				*planes;
} passage_t;

#define	MAX_PORTALS_ON_CLUSTER 128
typedef struct cluster_s
{
	int			numportals;
	passage_t	*passages;
	portal_t	*portals[MAX_PORTALS_ON_CLUSTER];

   int     visofs;
} cluster_t;

	
typedef struct pstack_s
{
	struct pstack_s	*next;
	cluster_t		*cluster;
	portal_t	*portal;	// portal exiting
	winding_t	*source, *pass;
	plane_t		portalplane;
	byte		*mightsee;		// bit string
} pstack_t;

typedef struct
{
	byte		*clustervis;		// bit string
	portal_t	*base;
	pstack_t	pstack_head;
} threaddata_t;


#ifdef __alpha
#include <pthread.h>
extern	pthread_mutex_t	*my_mutex;
#define	LOCK	pthread_mutex_lock (my_mutex)
#define	UNLOCK	pthread_mutex_unlock (my_mutex)
#else
#define	LOCK
#define	UNLOCK
#endif


extern	int			numportals;
extern	int			portalclusters;
extern   int         numrealleafs;

extern	portal_t	*portals;
extern	cluster_t		*clusters;

extern   int        *leafcluster;

extern	int			c_portaltest, c_portalpass, c_portalcheck;
extern	int			c_portalskip, c_clusterskip;
extern	int			c_vistest, c_mighttest;
extern	int			c_chains;

extern	byte	*vismap, *vismap_p, *vismap_end;	// past visfile

extern	qboolean		showgetcluster;
extern	int			testlevel;

extern	byte		*uncompressed;
extern	int			bitbytes;
extern	int			bitlongs;
extern   int         bitbytes_l;


void ClusterFlow (int clusternum);
void BasePortalVis (void);

void PortalFlow (portal_t *p);

void CalcAmbientSounds (void);

