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


#include "light.h"

/*
============
noise3d

returns the 3D noise value for a point in space
============
*/
float noise3d (vec3_t v, int num)
{
	int n;
	n = floor(v[0]) + floor(v[1]) * 57 + floor(v[2]) * 3251;
	n = (n << 13) ^ n;
	n = n * (n * n * 15731 + 789221) + 1376312589;
	return (n & 0x7fffffff) / 2147483648.0;
}

/*
===========
noiseXYZ

a variation of Noise3D that takes 3 floats
===========
*/
float noiseXYZ (float x, float y, float z, int num)
{
	vec3_t v;
	v[0] = x;
	v[1] = y;
	v[2] = z;
	return noise3d (v, num);
}

/*
============
noise_scaled

returns a noise value from a scaled up noise pattern

Actually created by sampling points on a certain grid 
and interpolating the inbetween value, making the noise smooth
============
*/
float noise_scaled (vec3_t v, float s, int num)
{
	float n = 0;
	vec3_t a,b,c,d;

	a[0]=floor(v[0]/s)*s;  b[0]=a[0]+s;  c[0]=(v[0]-a[0])/s;  d[0]=1-c[0];
	a[1]=floor(v[1]/s)*s;  b[1]=a[1]+s;  c[1]=(v[1]-a[1])/s;  d[1]=1-c[1];
	a[2]=floor(v[2]/s)*s;  b[2]=a[2]+s;  c[2]=(v[2]-a[2])/s;  d[2]=1-c[2];

	n += noiseXYZ (a[0], a[1], a[2], num) * d[0] * d[1] * d[2];
	n += noiseXYZ (a[0], a[1], b[2], num) * d[0] * d[1] * c[2];
	n += noiseXYZ (a[0], b[1], a[2], num) * d[0] * c[1] * d[2];
	n += noiseXYZ (a[0], b[1], b[2], num) * d[0] * c[1] * c[2];
	n += noiseXYZ (b[0], a[1], a[2], num) * c[0] * d[1] * d[2];
	n += noiseXYZ (b[0], a[1], b[2], num) * c[0] * d[1] * c[2];
	n += noiseXYZ (b[0], b[1], a[2], num) * c[0] * c[1] * d[2];
	n += noiseXYZ (b[0], b[1], b[2], num) * c[0] * c[1] * c[2];

	return n;
}

/*
============
noise_perlin

returns a Perlin noise value for a point in 3D space\

This noise function combines noise at several different scales
which makes it slower than just using one layer of noise
============
*/
float noise_perlin (vec3_t v, float p, int num)
{
	float n = 0;

	n +=        noise_scaled (v, 1024, num);
	n += 0.5 + (noise_scaled (v,  256, num) - 0.5) * p;
	n += 0.5 + (noise_scaled (v,   64, num) - 0.5) * p * p;
	n += 0.5 + (noise_scaled (v,   16, num) - 0.5) * p * p * p;

	return n / 2 - 0.5;
}

/*
===========
snap_vector

Use to create low-res noise patterns without interpolation
A good strategy for avoiding seams on terrain and curves
when called with a scale value of about 32

This is because surfaces have some texture pixels which are
actually not in the polygon at all so their edges don't
perfectly fit together.

Creates a random pattern of light and dark squares on flat
axis aligned surfaces, which is usually not what you want
but it may have interesting applications
===========
*/
void snap_vector (vec3_t v_old, vec3_t v_new, float scale)
{
	if (scale <= 0)
	{
		v_new[0] = v_old[0];
		v_new[1] = v_old[1];
		v_new[2] = v_old[2];
	}
	else
	{
		v_new[0] = floor (v_old[0] / scale + 0.5) * scale;
		v_new[1] = floor (v_old[1] / scale + 0.5) * scale;
		v_new[2] = floor (v_old[2] / scale + 0.5) * scale;
	}
}

/*
============
CastRay

Returns the distance between the points, or -1 if blocked
=============
*/
vec_t CastRay (vec3_t p1, vec3_t p2)
{
	int		i;
	vec_t	t;
	qboolean	trace;
		
	trace = TestLine (p1, p2);
		
	if (!trace)
		return -1;		// ray was blocked
		
	t = 0;
	for (i=0 ; i< 3 ; i++)
		t += (p2[i]-p1[i]) * (p2[i]-p1[i]);
		
	if (t == 0)
		t = 1;		// don't blow up...
	return sqrt(t);
}

/*
===============================================================================

SAMPLE POINT DETERMINATION

void SetupBlock (dface_t *f) Returns with surfpt[] set

This is a little tricky because the lightmap covers more area than the face.
If done in the straightforward fashion, some of the
sample points will be inside walls or on the other side of walls, causing
false shadows and light bleeds.

To solve this, I only consider a sample point valid if a line can be drawn
between it and the exact midpoint of the face.  If invalid, it is adjusted
towards the center until it is valid.

(this doesn't completely work)

===============================================================================
*/

#define	SINGLEMAP	(18*18*4)

typedef struct
{
	vec_t	lightmaps[MAXLIGHTMAPS][SINGLEMAP];
	int		numlightstyles;
	vec_t	*light;
	vec_t	facedist;
	vec3_t	facenormal;

	int		numsurfpt;
	vec3_t	surfpt[SINGLEMAP];

	vec3_t	texorg;
	vec3_t	worldtotex[2];	// s = (world - texorg) . worldtotex[0]
	vec3_t	textoworld[2];	// world = texorg + s * textoworld[0]

	vec_t	exactmins[2], exactmaxs[2];
	
	int		texmins[2], texsize[2];
	int		lightstyles[256];
	int		surfnum;
	dface_t	*face;
} lightinfo_t;


/*
================
CalcFaceVectors

Fills in texorg, worldtotex. and textoworld
================
*/
void CalcFaceVectors (lightinfo_t *l)
{
	texinfo_t	*tex;
	int			i, j;
	vec3_t	texnormal;
	float	distscale;
	vec_t	dist, len;

	tex = &texinfo[l->face->texinfo];
	
// convert from float to vec_t
	for (i=0 ; i<2 ; i++)
		for (j=0 ; j<3 ; j++)
			l->worldtotex[i][j] = tex->vecs[i][j];

// calculate a normal to the texture axis.  points can be moved along this
// without changing their S/T
	texnormal[0] = tex->vecs[1][1]*tex->vecs[0][2]
		- tex->vecs[1][2]*tex->vecs[0][1];
	texnormal[1] = tex->vecs[1][2]*tex->vecs[0][0]
		- tex->vecs[1][0]*tex->vecs[0][2];
	texnormal[2] = tex->vecs[1][0]*tex->vecs[0][1]
		- tex->vecs[1][1]*tex->vecs[0][0];
	VectorNormalize (texnormal);

// flip it towards plane normal
	distscale = DotProduct (texnormal, l->facenormal);
	if (!distscale)
		Error ("Texture axis perpendicular to face");
	if (distscale < 0)
	{
		distscale = -distscale;
		VectorSubtract (vec3_origin, texnormal, texnormal);
	}	

// distscale is the ratio of the distance along the texture normal to
// the distance along the plane normal
	distscale = 1/distscale;

	for (i=0 ; i<2 ; i++)
	{
		len = VectorLength (l->worldtotex[i]);
		dist = DotProduct (l->worldtotex[i], l->facenormal);
		dist *= distscale;
		VectorMA (l->worldtotex[i], -dist, texnormal, l->textoworld[i]);
		VectorScale (l->textoworld[i], (1/len)*(1/len), l->textoworld[i]);
	}


// calculate texorg on the texture plane
	for (i=0 ; i<3 ; i++)
		l->texorg[i] = -tex->vecs[0][3]* l->textoworld[0][i] - tex->vecs[1][3] * l->textoworld[1][i];

// project back to the face plane
	dist = DotProduct (l->texorg, l->facenormal) - l->facedist - 1;
	dist *= distscale;
	VectorMA (l->texorg, -dist, texnormal, l->texorg);
	
}

/*
================
CalcFaceExtents

Fills in s->texmins[] and s->texsize[]
also sets exactmins[] and exactmaxs[]
================
*/
void CalcFaceExtents (lightinfo_t *l)
{
	dface_t *s;
	vec_t	mins[2], maxs[2], val;
	int		i,j, e;
	dvertex_t	*v;
	texinfo_t	*tex;
	
	s = l->face;

	mins[0] = mins[1] = 999999;
	maxs[0] = maxs[1] = -99999;

	tex = &texinfo[s->texinfo];
	
	for (i=0 ; i<s->numedges ; i++)
	{
		e = dsurfedges[s->firstedge+i];
		if (e >= 0)
			v = dvertexes + dedges[e].v[0];
		else
			v = dvertexes + dedges[-e].v[1];
		
		for (j=0 ; j<2 ; j++)
		{
			val = v->point[0] * tex->vecs[j][0] + 
				v->point[1] * tex->vecs[j][1] +
				v->point[2] * tex->vecs[j][2] +
				tex->vecs[j][3];
			if (val < mins[j])
				mins[j] = val;
			if (val > maxs[j])
				maxs[j] = val;
		}
	}

	for (i=0 ; i<2 ; i++)
	{	
		l->exactmins[i] = mins[i];
		l->exactmaxs[i] = maxs[i];
		
		mins[i] = floor(mins[i]/16);
		maxs[i] = ceil(maxs[i]/16);

		l->texmins[i] = mins[i];
		l->texsize[i] = maxs[i] - mins[i];
		if (l->texsize[i] > 17)
			Error ("Bad surface extents");
	}
}

/*
=================
CalcPoints

For each texture aligned grid point, back project onto the plane
to get the world xyz value of the sample point
=================
*/
int c_bad;
void CalcPoints (lightinfo_t *l)
{
	int		i;
	int		s, t, j;
	int		w, h, step;
	vec_t	starts, startt, us, ut;
	vec_t	*surf;
	vec_t	mids, midt;
	vec3_t	facemid, move;

//
// fill in surforg
// the points are biased towards the center of the surface
// to help avoid edge cases just inside walls
//
	surf = l->surfpt[0];
	mids = (l->exactmaxs[0] + l->exactmins[0])/2;
	midt = (l->exactmaxs[1] + l->exactmins[1])/2;

	for (j=0 ; j<3 ; j++)
		facemid[j] = l->texorg[j] + l->textoworld[0][j]*mids + l->textoworld[1][j]*midt;

	if (extrasamples)
	{	// extra filtering
		h = (l->texsize[1]+1)*2;
		w = (l->texsize[0]+1)*2;
		starts = (l->texmins[0]-0.5)*16;
		startt = (l->texmins[1]-0.5)*16;
		step = 8;
	}
	else
	{
		h = l->texsize[1]+1;
		w = l->texsize[0]+1;
		starts = l->texmins[0]*16;
		startt = l->texmins[1]*16;
		step = 16;
	}

	l->numsurfpt = w * h;
	for (t=0 ; t<h ; t++)
	{
		for (s=0 ; s<w ; s++, surf+=3)
		{
			us = starts + s*step;
			ut = startt + t*step;

		// if a line can be traced from surf to facemid, the point is good
			for (i=0 ; i<6 ; i++)
			{
			// calculate texture point
				for (j=0 ; j<3 ; j++)
					surf[j] = l->texorg[j] + l->textoworld[0][j]*us
					+ l->textoworld[1][j]*ut;

				if (CastRay (facemid, surf) != -1)
					break;	// got it
				if (i & 1)
				{
					if (us > mids)
					{
						us -= 8;
						if (us < mids)
							us = mids;
					}
					else
					{
						us += 8;
						if (us > mids)
							us = mids;
					}
				}
				else
				{
					if (ut > midt)
					{
						ut -= 8;
						if (ut < midt)
							ut = midt;
					}
					else
					{
						ut += 8;
						if (ut > midt)
							ut = midt;
					}
				}
				
				// move surf 8 pixels towards the center
				VectorSubtract (facemid, surf, move);
				VectorNormalize (move);
				VectorMA (surf, 8, move, surf);
			}
			if (i == 2)
				c_bad++;
		}
	}
	
}


/*
===============================================================================

FACE LIGHTING

===============================================================================
*/

int		c_culldistplane, c_proper;

/*
================
SingleLightFace
================
*/
void SingleLightFace (entity_t *light, lightinfo_t *l)
{
	vec_t    dist;
	vec3_t   incoming;
	vec_t    angle;
	vec_t    add;
	vec_t    *surf;
	qboolean hit;
	int      mapnum;
	int      size;
	int      c, i;
	vec3_t   rel;
	vec3_t   spotvec;
	vec_t    falloff;
	vec_t    *lightsamp;
	int      x, y, width; // SerpLord - noise coordinates
	vec_t    *noise_surf; // SerpLord - used to "undersample" noise
	vec3_t   point;       // current surface point snapped to grid
	float    intensity=0; // noise intensity for the current point
	int      seed;        // unique random seed for each light source

	VectorSubtract (light->origin, bsp_origin, rel);
	dist = scaledist * (DotProduct (rel, l->facenormal) - l->facedist);
	
	// don't bother with lights behind the surface
	if (dist <= 0)
		return;

	// don't bother with light too far away
	// SerpLord - use radius to account for different attenuation types
	if (light->radius && dist > light->radius)
	{
		c_culldistplane++;
		return;
	}

	if (light->targetent)
	{
		VectorSubtract (light->targetent->origin, light->origin, spotvec);
		VectorNormalize (spotvec);
		if (!light->angle)
			falloff = -cos(20*Q_PI/180);	
		else
			falloff = -cos(light->angle/2*Q_PI/180);
	}
		falloff = 0;	// shut up compiler warnings
	
	mapnum = 0;
	for (mapnum=0 ; mapnum<l->numlightstyles ; mapnum++)
		if (l->lightstyles[mapnum] == light->style)
			break;
	lightsamp = l->lightmaps[mapnum];
	if (mapnum == l->numlightstyles)
	{	// init a new light map
		if (mapnum == MAXLIGHTMAPS)
		{
			printf ("WARNING: Too many light styles on a face\n");
			return;
		}
		size = (l->texsize[1]+1)*(l->texsize[0]+1);
		for (i=0 ; i<size ; i++)
			lightsamp[i] = 0;
	}

	//
	// check it for real
	//
	hit = false;
	c_proper++;

	surf = l->surfpt[0];
	for (c=0 ; c<l->numsurfpt ; c++, surf+=3)
	{
		dist = CastRay(light->origin, surf)*scaledist;
		if (dist < 0)
			continue;	// light doesn't reach

		if (light->radius && dist > light->radius)
			continue;  // SerpLord - maximum range

		VectorSubtract (light->origin, surf, incoming);
		VectorNormalize (incoming);
		angle = DotProduct (incoming, l->facenormal);
		if (light->targetent)
		{	// spotlight cutoff
			if (DotProduct (spotvec, incoming) > falloff)
				continue;
		}

		angle = (1.0-scalecos) + scalecos*angle;

		// Open Quartz - attenuation types

		add = light->light;
		if (light->light < 0) add *= -1; // negative light
		switch (light->attenuation)
		{
			case LIGHT_LINEAR:    add -= dist; break;
			case LIGHT_RADIUS:    add *= (light->radius - dist) / light->radius; break;
			case LIGHT_INVERSE:   add /= dist; break;
			case LIGHT_REALISTIC: add /= dist * dist; break;
		}

		// Open Quartz - random noise

		if (light->noise)
		{
			noise_surf = surf;
			if (extrasamples)
			{
				// We don't want to oversample noise because that just
				// waters it down.  So we "undersample" noise by using
				// the same surf coord for every group of 4 lightmap pixels
				// ("undersampling", "pixelation", "anti-interpolation" :-)
				width = (l->texsize[0] + 1) * 2;
				x = c % width;
				y = c / width;
				if (x % 2 && y % 2) noise_surf -= width * 3 + 3;
				else if     (y % 2) noise_surf -= width * 3;
				else if     (x % 2) noise_surf -= 3;
			}

			if (light->noisetype == NOISE_SMOOTH)
				snap_vector (noise_surf, point, 0);
			else
				snap_vector (noise_surf, point, light->resolution);

			seed = light - entities;

			if (light->noisetype == NOISE_RANDOM)
				intensity = noise3d (point, seed);
			if (light->noisetype == NOISE_SMOOTH)
				intensity = noise_scaled (point, light->resolution, seed);
			if (light->noisetype == NOISE_PERLIN)
				intensity = noise_perlin (point, light->persistence, seed);

			add *= intensity * light->noise + 1.0 - light->noise;
		}

		add *= angle;
		if (add < 0) continue;
		if (light->light < 0) add *= -1; // negative light
		lightsamp[c] += add;
		if (lightsamp[c] > 1) hit = true; // ignore real tiny lights
	}

	if (mapnum == l->numlightstyles && hit)
	{
		l->lightstyles[mapnum] = light->style;
		l->numlightstyles++;	// the style has some real data now
	}
}

/*
============
FixMinlight
============
*/
void FixMinlight (lightinfo_t *l)
{
	int		i, j;
	float	minlight;
	
	minlight = minlights[l->surfnum];

// if minlight is set, there must be a style 0 light map
	if (!minlight)
		return;
	
	for (i=0 ; i< l->numlightstyles ; i++)
	{
		if (l->lightstyles[i] == 0)
			break;
	}
	if (i == l->numlightstyles)
	{
		if (l->numlightstyles == MAXLIGHTMAPS)
			return;		// oh well..
		for (j=0 ; j<l->numsurfpt ; j++)
			l->lightmaps[i][j] = minlight;
		l->lightstyles[i] = 0;
		l->numlightstyles++;
	}
	else
	{
		for (j=0 ; j<l->numsurfpt ; j++)
			if ( l->lightmaps[i][j] < minlight)
				l->lightmaps[i][j] = minlight;
	}
}


/*
============
LightFace
============
*/
void LightFace (int surfnum)
{
	dface_t *f;
	lightinfo_t	l;
	int		s, t;
	int		i,j,c;
	vec_t	total;
	int		size;
	int		lightmapwidth, lightmapsize;
	byte	*out;
	vec_t	*light;
	int		w, h;
	
	f = dfaces + surfnum;

//
// some surfaces don't need lightmaps
//
	f->lightofs = -1;
	for (j=0 ; j<MAXLIGHTMAPS ; j++)
		f->styles[j] = 255;

	if ( texinfo[f->texinfo].flags & TEX_SPECIAL)
	{	// non-lit texture
		return;
	}

	memset (&l, 0, sizeof(l));
	l.surfnum = surfnum;
	l.face = f;

//
// rotate plane
//
	VectorCopy (dplanes[f->planenum].normal, l.facenormal);
	l.facedist = dplanes[f->planenum].dist;
	if (f->side)
	{
		VectorSubtract (vec3_origin, l.facenormal, l.facenormal);
		l.facedist = -l.facedist;
	}
	
	CalcFaceVectors (&l);
	CalcFaceExtents (&l);
	CalcPoints (&l);

	lightmapwidth = l.texsize[0]+1;

	size = lightmapwidth*(l.texsize[1]+1);
	if (size > SINGLEMAP)
		Error ("Bad lightmap size");

	for (i=0 ; i<MAXLIGHTMAPS ; i++)
		l.lightstyles[i] = 255;
	
//
// cast all lights
//	
	l.numlightstyles = 0;
	for (i=0 ; i<num_entities ; i++)
	{
		if (entities[i].light)
			SingleLightFace (&entities[i], &l);
	}

	FixMinlight (&l);
		
	if (!l.numlightstyles)
	{	// no light hitting it
		return;
	}
	
//
// save out the values
//
	for (i=0 ; i <MAXLIGHTMAPS ; i++)
		f->styles[i] = l.lightstyles[i];

	lightmapsize = size*l.numlightstyles;

	out = GetFileSpace (lightmapsize);
	f->lightofs = out - filebase;
	
// extra filtering
	h = (l.texsize[1]+1)*2;
	w = (l.texsize[0]+1)*2;

	for (i=0 ; i< l.numlightstyles ; i++)
	{
		if (l.lightstyles[i] == 0xff)
			Error ("Wrote empty lightmap");
		light = l.lightmaps[i];
		c = 0;
		for (t=0 ; t<=l.texsize[1] ; t++)
			for (s=0 ; s<=l.texsize[0] ; s++, c++)
			{
				if (extrasamples)
				{	// filtered sample
					total = light[t*2*w+s*2] + light[t*2*w+s*2+1]
					+ light[(t*2+1)*w+s*2] + light[(t*2+1)*w+s*2+1];
					total *= 0.25;
				}
				else
					total = light[c];
				total *= rangescale;	// scale before clamping
				if (total > 255) total = 255;
				if (total < 0)   total = 0; // SerpLord - allow negative light
				*out++ = total;
			}
	}
}

