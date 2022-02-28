
#include "havocmap.h"

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
	return t; // LordHavoc: no longer a need for sqrt here
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

// LordHavoc: added a *3 to account for RGB space
#define	SINGLEMAP	(18*18*4*3)

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

extern float lh_brightestlightvalue;

/*
================
SingleLightFace
================
*/
void SingleLightFace (entity_t *light, lightinfo_t *l)
{
	vec_t	dist;
	vec_t	falloff2;

	vec3_t	incoming;
	vec_t	angle;
	vec_t	add;
	vec_t	*surf;
	qboolean	hit;
	int		mapnum;
	int		size;
	int		c, i;
	vec3_t	rel;
	vec3_t	spotvec;
	vec_t	falloff;
	vec_t	*lightsamp;
	
	VectorSubtract (light->origin, bsp_origin, rel);
	dist = scaledist * (DotProduct (rel, l->facenormal) - l->facedist);
	
// don't bother with lights behind the surface
	if (dist <= 0)
		return;
		
	if (ignorefalloff)
		falloff2 = lh_globalfalloff;
	else
		falloff2 = light->falloff * lh_globalfalloff;
	
	if (light->targetent)
	{
		VectorSubtract (light->targetent->origin, light->origin, spotvec);
		VectorNormalize (spotvec);
		if (!light->angle)
			falloff = -cos(20*Q_PI/180);	
		else
			falloff = -cos(light->angle/2*Q_PI/180);
	}
	else
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
		size = (l->texsize[1]+1)*(l->texsize[0]+1)*3; // LordHavoc: colored support
		for (i=0 ; i<size ; i++)
			lightsamp[i] = 0;
	}

//
// check it for real
//
	hit = false;
	c_proper++;

	surf = l->surfpt[0];
	for (c=0 ; c<l->numsurfpt*3 ; c+=3, surf+=3) // LordHavoc: color
	{
		if (light->targetent) // spotlight
		{
			VectorSubtract (light->origin, surf, incoming);
			VectorNormalize (incoming);
			if (DotProduct (spotvec, incoming) > falloff)
				continue;
		}

		dist = CastRay(light->origin, surf)*scaledist;
		if (dist < 0)
			continue;	// light doesn't reach

		if (!light->targetent) // not a spotlight
		{
			VectorSubtract (light->origin, surf, incoming);
			VectorNormalize (incoming);
		}
		angle = DotProduct (incoming, l->facenormal);

//		angle = (1.0-scalecos) + scalecos*angle;
		angle = angle * 0.5 + 0.5;
		if (angle <= 0)
			continue;
		// LordHavoc: changed to be more realistic(entirely different lighting model)
		add = light->light * 0.5f / (dist * falloff2 + 1.0f);
		add *= angle;
		lightsamp[c  ] += add * light->color[0];
		lightsamp[c+1] += add * light->color[1];
		lightsamp[c+2] += add * light->color[2];
		if ((lightsamp[c]+lightsamp[c+1]+lightsamp[c+2]) >= 8)		// ignore real tiny lights
			hit = true;
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
//	float	minlight;
	
//	minlight = minlights[l->surfnum];

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
		for (j=0 ; j<l->numsurfpt*3 ; j++) // LordHavoc: *3 for colored lighting
			l->lightmaps[i][j] = minlight;
		l->lightstyles[i] = 0;
		l->numlightstyles++;
	}
	else
	{
		for (j=0 ; j<l->numsurfpt*3 ; j++) // LordHavoc: *3 for colored lighting
			if ( l->lightmaps[i][j] < minlight)
				l->lightmaps[i][j] = minlight;
	}
}

extern	FILE		*litfile;

/*
============
LightFace
============
*/
void LightFace (int surfnum)
{
	dface_t *f;
	lightinfo_t	l;
	int		s, t, s2, t2, w2, w3;
	int		i,j,c;
	vec_t	red, green, blue;
	int		size;
	int		lightmapwidth, lightmapsize;
	byte	*out;
	vec_t	*light;
	int		w, h;
static	int		litpixelswritten = 0; // LordHavoc: used for padding out the .lit file to match lightofs
	
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
	if (size > (SINGLEMAP/3))
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
	// LordHavoc: pad out litfile to match the lightofs table
	if (!litpixelswritten)
		litpixelswritten = f->lightofs;
	for (;litpixelswritten < f->lightofs;litpixelswritten++)
	{
		fputc(0, litfile);
		fputc(0, litfile);
		fputc(0, litfile);
	}

// extra filtering
	h = (l.texsize[1]+1)*2;
	w = (l.texsize[0]+1)*2;

	for (i=0 ; i< l.numlightstyles ; i++)
	{
		if (l.lightstyles[i] == 0xff)
			Error ("Wrote empty lightmap");
		light = l.lightmaps[i];
		c = 0;
		w2 = w*3;w3 = w2 * 2;
		for (t2 = 0, t=0 ; t<=l.texsize[1] ; t2 += w3, t++)
		{
			for (s2 = t2, s=0 ; s<=l.texsize[0] ; s++, s2 += 6, c+=3)
			{
				// LordHavoc: overhauled for colored lighting
				if (extrasamples)
				{	// filtered sample
					red   = (light[s2  ] + light[s2+3] + light[s2+w2  ] + light[s2+w2+3]) * 0.25;
					green = (light[s2+1] + light[s2+4] + light[s2+w2+1] + light[s2+w2+4]) * 0.25;
					blue  = (light[s2+2] + light[s2+5] + light[s2+w2+2] + light[s2+w2+5]) * 0.25;
				}
				else
				{
					red   = light[c  ];
					green = light[c+1];
					blue  = light[c+2];
				}
				red   *= rangescale;	// scale before clamping
				green *= rangescale;
				blue  *= rangescale;
				if (red > 255) red = 255;
				if (red < 0) red = 0;
				if (green > 255) green = 255;
				if (green < 0) green = 0;
				if (blue > 255) blue = 255;
				if (blue < 0) blue = 0;
				// write to bsp file
				*out++ = (byte) ((int) (red+green+blue)/3);
				// write to .lit file
				litpixelswritten++;
				fputc(red, litfile);
				fputc(green, litfile);
				fputc(blue, litfile);
			}
		}
	}
}

