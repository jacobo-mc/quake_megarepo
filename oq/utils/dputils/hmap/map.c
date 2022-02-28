// map.c

#include "havocmap.h"

int			nummapbrushes;
mbrush_t	mapbrushes[MAX_MAP_BRUSHES];

int			num_entities;
entity_t	entities[MAX_MAP_ENTITIES];

int			nummiptex;
char		miptex[MAX_MAP_TEXINFO][16];

//============================================================================

/*
===============
FindMiptex

===============
*/
int FindMiptex (char *name)
{
	int		i;

	for (i=0 ; i<nummiptex ; i++)
		if (!strcmp (name, miptex[i]))
			return i;
	if (nummiptex == MAX_MAP_TEXINFO)
		Error ("nummiptex == MAX_MAP_TEXINFO");
	strcpy (miptex[i], name);
	nummiptex++;
	return i;
}

/*
===============
FindTexinfo

Returns a global texinfo number
===============
*/
int	FindTexinfo (texinfo_t *t)
{
	int			i, j;
	texinfo_t	*tex;

	// set the special flag
	if (miptex[t->miptex][0] == '*'  || !Q_strncasecmp (miptex[t->miptex], "sky",3) )
		t->flags |= TEX_SPECIAL;

	tex = texinfo;	
	for (i=0 ; i<numtexinfo;i++, tex++)
	{
		if (t->miptex != tex->miptex)
			continue;
		if (t->flags != tex->flags)
			continue;

		for (j=0 ; j<8 ; j++)
			if (t->vecs[0][j] != tex->vecs[0][j])
				break;
		if (j != 8)
			continue;

		return i;
	}

	// allocate a new texture
	if (numtexinfo == MAX_MAP_TEXINFO)
		Error ("numtexinfo == MAX_MAP_TEXINFO");
	texinfo[i] = *t;
	numtexinfo++;

	return i;
}


//============================================================================

#define	MAXTOKEN	128

char	token[MAXTOKEN];
qboolean	unget;
char	*script_p;
int		scriptline;

void	StartTokenParsing (char *data)
{
	scriptline = 1;
	script_p = data;
	unget = false;
}

qboolean GetToken (qboolean crossline)
{
	char    *token_p;

	if (unget)                         // is a token allready waiting?
	return true;

	//
	// skip space
	//
	skipspace:
	while (*script_p <= 32)
	{
		if (!*script_p)
		{
			if (!crossline)
				Error ("Line %i is incomplete",scriptline);
			return false;
		}
		if (*script_p++ == '\n')
		{
			if (!crossline)
				Error ("Line %i is incomplete",scriptline);
			scriptline++;
		}
	}

	if (script_p[0] == '/' && script_p[1] == '/')	// comment field
	{
		if (!crossline)
			Error ("Line %i is incomplete\n",scriptline);
		while (*script_p++ != '\n')
			if (!*script_p)
			{
				if (!crossline)
					Error ("Line %i is incomplete",scriptline);
				return false;
			}
		goto skipspace;
	}

	//
	// copy token
	//
	token_p = token;

	if (*script_p == '"')
	{
		script_p++;
		while ( *script_p != '"' )
		{
			if (!*script_p)
				Error ("EOF inside quoted token");
			*token_p++ = *script_p++;
			if (token_p > &token[MAXTOKEN-1])
				Error ("Token too large on line %i",scriptline);
		}
		script_p++;
	}
	else while ( *script_p > 32 )
	{
		*token_p++ = *script_p++;
		if (token_p > &token[MAXTOKEN-1])
			Error ("Token too large on line %i",scriptline);
	}

	*token_p = 0;

	return true;
}

void UngetToken ()
{
	unget = true;
}


//============================================================================

entity_t	*mapent;

int LightStyleForTargetname (char *targetname, qboolean alloc);
/*
=================
ParseEpair
=================
*/
void ParseEpair (void)
{
	epair_t	*e;
	double vec[4];
	int i;
	double temp;

	e = malloc (sizeof(epair_t));
	memset (e, 0, sizeof(epair_t));
	e->next = mapent->epairs;
	mapent->epairs = e;

	if (strlen(token) >= MAX_KEY-1)
		Error ("ParseEpair: token too long");
	e->key = copystring(token);
	GetToken (false);
	if (strlen(token) >= MAX_VALUE-1)
		Error ("ParseEpair: token too long");
	e->value = copystring(token);

	if (!strcmp(e->key, "classname"))
		strcpy (mapent->classname, e->value);
	else if (!strcmp(e->key, "target"))
		strcpy (mapent->target, e->value);			
	else if (!strcmp(e->key, "targetname"))
		strcpy (mapent->targetname, e->value);
	else if (!strcmp(e->key, "origin"))
	{
		// scan into doubles, then assign
		// which makes it vec_t size independent
		if (sscanf(e->value, "%lf %lf %lf", &vec[0], &vec[1], &vec[2]) != 3)
			Error ("ParseEpair: not 3 values for origin");
		for (i=0 ; i<3 ; i++)
			mapent->origin[i] = vec[i];
	}
	else if (!strncmp(e->key, "light", 5) || !strcmp (e->key, "_light") )
	{
		if (sscanf(e->value, "%lf %lf %lf %lf", &vec[0], &vec[1], &vec[2], &vec[3]) == 4)
		{ // HalfLife light
			mapent->color[0] = vec[0] * (1.0f / 255.0f);
			mapent->color[1] = vec[1] * (1.0f / 255.0f);
			mapent->color[2] = vec[2] * (1.0f / 255.0f);
			mapent->light = vec[3];
			// optimization of light size
										 temp = mapent->color[0];
			if (temp < mapent->color[1]) temp = mapent->color[1];
			if (temp < mapent->color[2]) temp = mapent->color[2];
			mapent->light *= temp;
			temp = 1.0f / temp;
			mapent->color[0] *= temp;
			mapent->color[1] *= temp;
			mapent->color[2] *= temp;
		}
		else if (sscanf(e->value, "%lf %lf %lf", &vec[0], &vec[1], &vec[2]) == 3)
		{
			mapent->color[0] = vec[0] * (1.0f / 255.0f);
			mapent->color[1] = vec[1] * (1.0f / 255.0f);
			mapent->color[2] = vec[2] * (1.0f / 255.0f);
			// optimization of light size
										 temp = mapent->color[0];
			if (temp < mapent->color[1]) temp = mapent->color[1];
			if (temp < mapent->color[2]) temp = mapent->color[2];
			mapent->light = temp;
			temp = 1.0f / temp;
			mapent->color[0] *= temp;
			mapent->color[1] *= temp;
			mapent->color[2] *= temp;
		}
		else if (sscanf(e->value, "%lf", &vec[0]) == 1)
		{
			mapent->light = vec[0];
			mapent->color[0] = mapent->color[1] = mapent->color[2] = 1.0f;
		}
		else
			Error ("ParseEpair: _light (or light) key must be 1 (Quake), 4 (HalfLife), or 3 (HLight) values\n");
	}
	else if (!strcmp (e->key, "wait") )
	{
		mapent->falloff = atof(e->value);
		mapent->falloff *= mapent->falloff; // square it for lighting calculations
	}
	else if (!strcmp(e->key, "style"))
	{
		mapent->style = atof(e->value);
		if ((unsigned)mapent->style > 254)
			Error ("Bad light style %i (must be 0-254)", mapent->style);
	}
	else if (!strcmp(e->key, "angle"))
		mapent->angle = atof(com_token);
	else if (!strcmp(e->key, "color") || !strcmp (e->key, "_color"))
	{
		// scan into doubles, then assign
		// which makes it vec_t size independent
		if (sscanf(e->value, "%lf %lf %lf", &vec[0], &vec[1], &vec[2]) != 3)
			Error ("LoadEntities: not 3 values for color");
		// scale the color to have at least one component at 1.0
		temp = vec[0];
		if (vec[1] > temp)
			temp = vec[1];
		if (vec[2] > temp)
			temp = vec[2];
		if (temp != 0.0)
			temp = 1.0 / temp;
		for (i=0 ; i<3 ; i++)
			mapent->color[i] = vec[i] * temp;
	}
}

//============================================================================


/*
==================
textureAxisFromPlane
==================
*/
vec3_t	baseaxis[18] =
{
	{0,0,1}, {1,0,0}, {0,-1,0},			// floor
	{0,0,-1}, {1,0,0}, {0,-1,0},		// ceiling
	{1,0,0}, {0,1,0}, {0,0,-1},			// west wall
	{-1,0,0}, {0,1,0}, {0,0,-1},		// east wall
	{0,1,0}, {1,0,0}, {0,0,-1},			// south wall
	{0,-1,0}, {1,0,0}, {0,0,-1}			// north wall
};

void TextureAxisFromPlane(plane_t *pln, vec3_t xv, vec3_t yv)
{
	int		bestaxis;
	float	dot,best;
	int		i;

	best = 0;
	bestaxis = 0;

	for (i=0 ; i<6 ; i++)
	{
		dot = DotProduct (pln->normal, baseaxis[i*3]);
		if (dot > best)
		{
			best = dot;
			bestaxis = i;
		}
	}

	VectorCopy (baseaxis[bestaxis*3+1], xv);
	VectorCopy (baseaxis[bestaxis*3+2], yv);
}


//=============================================================================


/*
=================
ParseBrush
=================
*/
void ParseBrush (void)
{
	mbrush_t	*b;
	mface_t		*f, *f2;
	vec3_t		planepts[3];
	vec3_t		t1, t2, t3;
	int			i,j;
	texinfo_t	tx;
	vec_t		d;
	float		shift[2], rotate, scale[2];

	b = &mapbrushes[nummapbrushes];
	nummapbrushes++;
	b->next = mapent->brushes;
	mapent->brushes = b;

	do
	{
		if (!GetToken (true))
			break;
		if (!strcmp (token, "}") )
			break;

		// read the three point plane definition
		for (i=0 ; i<3 ; i++)
		{
			if (i != 0)
				GetToken (true);
			if (strcmp (token, "(") )
				Error ("parsing brush");

			for (j=0 ; j<3 ; j++)
			{
				GetToken (false);
				planepts[i][j] = atof(token); // LordHavoc: float coords
			}

			GetToken (false);
			if (strcmp (token, ")") )
				Error ("parsing brush");
		}

		fflush(stdout);
		// read the texturedef
		memset (&tx, 0, sizeof(tx));
		GetToken (false);
		tx.miptex = FindMiptex (token);
		GetToken (false);
		shift[0] = atof(token); // LordHavoc: float coords
		GetToken (false);
		shift[1] = atof(token); // LordHavoc: float coords
		GetToken (false);
		rotate = atof(token);	 // LordHavoc: float coords
		GetToken (false);
		scale[0] = atof(token); // LordHavoc: was already float coords
		GetToken (false);
		scale[1] = atof(token); // LordHavoc: was already float coords

		// if the three points are all on a previous plane, it is a
		// duplicate plane
		for (f2 = b->faces ; f2 ; f2=f2->next)
		{
			for (i=0 ; i<3 ; i++)
			{
				d = DotProduct(planepts[i],f2->plane.normal) - f2->plane.dist;
				if (d < -ON_EPSILON || d > ON_EPSILON)
				break;
			}
			if (i==3)
				break;
		}
		if (f2)		
		{
			printf ("WARNING: brush with duplicate plane\n");
			continue;
		}

		f = malloc(sizeof(mface_t));
		f->next = b->faces;
		b->faces = f;

		// convert to a vector / dist plane
		for (j=0 ; j<3 ; j++)
		{
			t1[j] = planepts[0][j] - planepts[1][j];
			t2[j] = planepts[2][j] - planepts[1][j];
			t3[j] = planepts[1][j];
		}

		CrossProduct(t1,t2, f->plane.normal);
		if (VectorCompare (f->plane.normal, vec3_origin))
		{
			printf ("WARNING: brush plane with no normal\n");
			b->faces = f->next;
			free (f);
			break;
		}
		VectorNormalize (f->plane.normal);
		f->plane.dist = DotProduct (t3, f->plane.normal);

		//
		// fake proper texture vectors from QuakeEd style
		//
		{
			vec3_t	vecs[2];
			int		sv, tv;
			float	ang, sinv, cosv;
			float	ns, nt;

			TextureAxisFromPlane(&f->plane, vecs[0], vecs[1]);

			if (!scale[0])
				scale[0] = 1;
			if (!scale[1])
				scale[1] = 1;

			// rotate axis
			if (rotate == 0)
			{ sinv = 0 ; cosv = 1; }
			else if (rotate == 90)
			{ sinv = 1 ; cosv = 0; }
			else if (rotate == 180)
			{ sinv = 0 ; cosv = -1; }
			else if (rotate == 270)
			{ sinv = -1 ; cosv = 0; }
			else
			{	
				ang = rotate / 180 * Q_PI;
				sinv = sin(ang);
				cosv = cos(ang);
			}

			if (vecs[0][0])
				sv = 0;
			else if (vecs[0][1])
				sv = 1;
			else
				sv = 2;
					
			if (vecs[1][0])
				tv = 0;
			else if (vecs[1][1])
				tv = 1;
			else
				tv = 2;
						
			for (i=0 ; i<2 ; i++)
			{
				ns = cosv * vecs[i][sv] - sinv * vecs[i][tv];
				nt = sinv * vecs[i][sv] +  cosv * vecs[i][tv];
				vecs[i][sv] = ns;
				vecs[i][tv] = nt;
			}

			for (i=0 ; i<2 ; i++)
			for (j=0 ; j<3 ; j++)
			tx.vecs[i][j] = vecs[i][j] / scale[i];

			tx.vecs[0][3] = shift[0];
			tx.vecs[1][3] = shift[1];
		}

		// unique the texinfo
		f->texinfo = FindTexinfo (&tx);		
	} while (1);
}

/*
================
ParseEntity
================
*/
qboolean	ParseEntity (void)
{
	if (!GetToken (true))
		return false;

	if (strcmp (token, "{") )
		Error ("ParseEntity: { not found");

	if (num_entities == MAX_MAP_ENTITIES)
		Error ("num_entities == MAX_MAP_ENTITIES");

	mapent = &entities[num_entities];
	num_entities++;

	do
	{
		fflush(stdout);
		if (!GetToken (true))
			Error ("ParseEntity: EOF without closing brace");
		if (!strcmp (token, "}") )
			break;
		if (!strcmp (token, "{") )
			ParseBrush ();
		else
			ParseEpair ();
	} while (1);

	// all fields have been parsed
	if (!strncmp (mapent->classname, "light", 5))
	{
		if (!mapent->light)
		{
			mapent->color[0] = mapent->color[1] = mapent->color[2] = 1;
			mapent->light = DEFAULTLIGHTLEVEL;
		}
		// LordHavoc: added falloff and color
		if (!mapent->falloff)
			mapent->falloff = DEFAULTFALLOFF * DEFAULTFALLOFF;
	}

	if (!strcmp (mapent->classname, "light"))
		if (mapent->targetname[0] && !mapent->style)
		{
			char	s[16];
			mapent->style = LightStyleForTargetname (mapent->targetname, true);
			sprintf (s,"%i", mapent->style);
			SetKeyValue (mapent, "style", s);
		}

	GetVectorForKey (mapent, "origin", mapent->origin);
	return true;
}

/*
================
LoadMapFile
================
*/
void LoadMapFile (char *filename)
{
	char	*buf;

	LoadFile (filename, (void **)&buf);

	StartTokenParsing (buf);

	num_entities = 0;

	while (ParseEntity ())
	{
	}

	free (buf);

	qprintf ("--- LoadMapFile ---\n");
	qprintf ("%s\n", filename);
	qprintf ("%5i brushes\n", nummapbrushes);
	qprintf ("%5i entities\n", num_entities);
	qprintf ("%5i miptex\n", nummiptex);
	qprintf ("%5i texinfo\n", numtexinfo);
}

void PrintEntity (entity_t *ent)
{
	epair_t	*ep;

	for (ep=ent->epairs ; ep ; ep=ep->next)
	printf ("%20s : %s\n", ep->key, ep->value);
}


char 	*ValueForKey (entity_t *ent, char *key)
{
	epair_t	*ep;

	for (ep=ent->epairs ; ep ; ep=ep->next)
	if (!strcmp (ep->key, key) )
	return ep->value;
	return "";
}

void 	SetKeyValue (entity_t *ent, char *key, char *value)
{
	epair_t	*ep;

	for (ep=ent->epairs ; ep ; ep=ep->next)
		if (!strcmp (ep->key, key) )
		{
			free (ep->value);
			ep->value = copystring(value);
			return;
		}
	ep = malloc (sizeof(*ep));
	ep->next = ent->epairs;
	ent->epairs = ep;
	ep->key = copystring(key);
	ep->value = copystring(value);
}

float	FloatForKey (entity_t *ent, char *key)
{
	char	*k;

	k = ValueForKey (ent, key);
	return atof(k);
}

void 	GetVectorForKey (entity_t *ent, char *key, vec3_t vec)
{
	char	*k;
	double	v1, v2, v3;

	k = ValueForKey (ent, key);
	v1 = v2 = v3 = 0;
	// scanf into doubles, then assign, so it is vec_t size independent
	sscanf (k, "%lf %lf %lf", &v1, &v2, &v3);
	vec[0] = v1;
	vec[1] = v2;
	vec[2] = v3;
}

extern int numlighttargets;
/*
================
WriteEntitiesToString
================
*/
void WriteEntitiesToString (void)
{
	char	*buf, *end;
	epair_t	*ep;
	char	line[128];
	int		i;

	buf = dentdata;
	end = buf;
	*end = 0;

	printf ("%i switchable light styles\n", numlighttargets);

	for (i=0 ; i<num_entities ; i++)
	{
		ep = entities[i].epairs;
		if (!ep)
			continue;	// ent got removed

		strcat (end,"{\n");
		end += 2;

		for (ep = entities[i].epairs ; ep ; ep=ep->next)
		{
			sprintf (line, "\"%s\" \"%s\"\n", ep->key, ep->value);
			strcat (end, line);
			end += strlen(line);
		}
		strcat (end,"}\n");
		end += 2;

		if (end > buf + MAX_MAP_ENTSTRING)
			Error ("Entity text too long");
	}
	entdatasize = end - buf + 1;
}

