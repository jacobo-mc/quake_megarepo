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

// map.c

#include "bsp5.h"

#include "qmalloc.h"

int      nummapbrushes;
mbrush_t	mapbrushes[MAX_MAP_BRUSHES];

int		num_entities;
entity_t	entities[MAX_MAP_ENTITIES];

int		nummiptex;
char		miptex[MAX_MAP_TEXINFO][16];

int      numdetailbrushes;

//============================================================================

/*
===============
FindMiptex

===============
*/
int FindMiptex (char *name)
{
	int		i;

// detect and flag HINT and SKIP textures
   if (!Q_strcasecmp(name,"hint"))
      return TEX_HINT;
   if (!Q_strcasecmp(name,"skip"))
      return TEX_SKIP;

	for (i=0 ; i<nummiptex ; i++)
	{
		if (!strcmp (name, miptex[i]))
			return i;
	}
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

   if (t->miptex<0) return t->miptex; // it's HINT or SKIP

// set the special flag
	if (miptex[t->miptex][0] == '*' 
	|| !Q_strncasecmp (miptex[t->miptex], "sky",3) )
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
char	txcommand; // used by Quake Army Knife (QuArK)'s texture alignment

void	StartTokenParsing (char *data)
{
	scriptline = 1;
	script_p = data;
	unget = false;
}

qboolean GetToken (qboolean crossline)
{
	char    *token_p;

	if (unget)                         // is a token already waiting?
   {
      unget=false;
		return true;
   }

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

qboolean TokenAvailable (qboolean crossline)
{
   char *sp;

	if (unget)                         // is a token already waiting?
		return true;

   sp=script_p;

//
// skip space
//
skipspace:
	while (*sp <= 32)
	{
		if (!*sp)
			return false;
		if (*sp++ == '\n')
		{
			if (!crossline)
				return false;
		}
	}

	if (sp[0] == '/' && sp[1] == '/')	// comment field
	{
		if (!crossline)
			return false;
		while (*sp++ != '\n')
			if (!*sp)
				return false;
		goto skipspace;
	}
   return true;
}

void UngetToken ()
{
	unget = true;
}


//============================================================================

entity_t	*mapent;

/*
=================
ParseEpair
=================
*/
void ParseEpair (void)
{
	epair_t	*e;
	
	e = Q_malloc (sizeof(epair_t));
	memset (e, 0, sizeof(epair_t));
	e->next = mapent->epairs;
	mapent->epairs = e;
	
	if (strlen(token) >= MAX_KEY-1)
		Error ("ParseEpar: token too long");
	e->key = copystring(token);
	GetToken (false);
	if (strlen(token) >= MAX_VALUE-1)
		Error ("ParseEpar: token too long");
	e->value = copystring(token);
}

//============================================================================


/*
==================
textureAxisFromPlane
==================
*/
vec3_t	baseaxis[18] =
{
{ 0, 0, 1}, {1,0,0}, {0,-1, 0},		// floor
{ 0, 0,-1}, {1,0,0}, {0,-1, 0},		// ceiling
{ 1, 0, 0}, {0,1,0}, {0, 0,-1},		// west wall
{-1, 0, 0}, {0,1,0}, {0, 0,-1},		// east wall
{ 0, 1, 0}, {1,0,0}, {0, 0,-1},		// south wall
{ 0,-1, 0}, {1,0,0}, {0, 0,-1}		// north wall
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

// used by Quake Army Knife (QuArK)'s three points texture alignment system
#define ScaleCorrection	(1.0/128.0)

/*
=================
ParseBrush
=================
*/
void ParseBrush (void)
{
	mbrush_t	  *b;
	mface_t	  *f, *f2;
	vec3_t		planepts[3];
	vec3_t		t1, t2, t3;
	int			i,j;
	texinfo_t	tx;
	vec_t		   d;
	float		   shift[2], rotate, scale[2];

	b = &mapbrushes[nummapbrushes];
	nummapbrushes++;
	b->next = mapent->brushes;
	mapent->brushes = b;

   GetToken(true);
   if (strcmp(token,"("))  // check if it's an old or new style brush
   { // a new-style brush
      vec3_t *vecs;
      int n_vecs;
      int i,j;
      int n_v;
      int v;

      if (token[0]!=':')
         Error("parsing brush");
      n_vecs=atoi(&token[1]);
      vecs=Q_malloc(sizeof(vec3_t)*n_vecs);

      for (i=0;i<n_vecs;i++)
      {
         GetToken(true);
         vecs[i][0]=atof(token);
         GetToken(false);
         vecs[i][1]=atof(token);
         GetToken(false);
         vecs[i][2]=atof(token);
      }

      GetToken(true);
      while (strcmp(token,"}"))
      {
         n_v=atoi(token);

         GetToken(false);

         for (i=0;i<n_v;i++)
         {
            GetToken(false);
            v=atoi(token);
            if (i<3)
               for (j=0;j<3;j++)
                  planepts[i][j]=vecs[v][j];
         }

         GetToken(false);

      	//
   		// read the texturedef
   		//

   		memset (&tx, 0, sizeof(tx));
   		GetToken (false);
   		tx.miptex = FindMiptex (token);
   		GetToken (false);
   		shift[0] = atoi(token);
   		GetToken (false);
   		shift[1] = atoi(token);
   		GetToken (false);
   		rotate = atoi(token);	
   		GetToken (false);
   		scale[0] = atof(token);
   		GetToken (false);
   		scale[1] = atof(token);

         while (TokenAvailable(false))
         {
            GetToken(false);
            if (!strcmp(token,"detail"))
               b->detail=1;
            else
               Error("Parse error on line %i",scriptline);
         }
   
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
   
   		f = Q_malloc(sizeof(mface_t));
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
   			Q_free (f);
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

         GetToken(true);
      }

      Q_free(vecs);
   }
   else // old style brush
   {
      UngetToken();
   	do
   	{
   		if (!GetToken (true))
   			break;
   		if (!strcmp (token, "}") )
   			break;
   		
		txcommand = 0; // used by Quake Army Knife (QuArK)'s texture alignment

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
   				planepts[i][j] = atof(token);
   			}
   			
   			GetToken (false);
   			if (strcmp (token, ")") )
   				Error ("parsing brush");
   				
   		}
   
   	// read the texturedef
   		memset (&tx, 0, sizeof(tx));
   		GetToken (false);
   		tx.miptex = FindMiptex (token);
   		GetToken (false);
   		shift[0] = atoi(token);
   		GetToken (false);
   		shift[1] = atoi(token);
   		GetToken (false);
   		rotate = atoi(token);	
   		GetToken (false);
   		scale[0] = atof(token);
   		GetToken (false);
   		scale[1] = atof(token);

         while (TokenAvailable(false))
         {
            GetToken(false);
            if (!strcmp(token,"detail"))
               b->detail=1;
            else
               Error("Parse error on line %i",scriptline);
         }

		// Look for TX1 or TX2 used by the "three points"
		// texture alignment system of the Quake Army Knife (QuArK) editor:
		while (script_p[0] != '\n' && script_p[0] != '\0')
		{
			if (script_p[0] == '/' &&
				script_p[1] == '/' &&
				script_p[2] == 'T' &&
				script_p[3] == 'X')
				txcommand = script_p[4];
			script_p++;
		}
   
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
   
   		f = Q_malloc(sizeof(mface_t));
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
   			Q_free (f);
   			break;
   		}
   		VectorNormalize (f->plane.normal);
   		f->plane.dist = DotProduct (t3, f->plane.normal);

		// Quake Army Knife (QuArK)'s special texture alignment system
		// the texture vectors are given directly from the three points
		if (txcommand=='1' || txcommand=='2')
		{		
			vec3_t	TexPt[2];
			int		k;
			float	dot22, dot23, dot33, mdet, aa, bb, dd;
			
			k = txcommand-'0';
			for (j=0; j<3; j++)
				TexPt[1][j] = (planepts[k][j] - planepts[0][j]) * ScaleCorrection;
			k = 3-k;
			for (j=0; j<3; j++)
				TexPt[0][j] = (planepts[k][j] - planepts[0][j]) * ScaleCorrection;

			dot22 = DotProduct (TexPt[0], TexPt[0]);
			dot23 = DotProduct (TexPt[0], TexPt[1]);
			dot33 = DotProduct (TexPt[1], TexPt[1]);
			mdet = dot22*dot33-dot23*dot23;
			if (mdet<1E-6 && mdet>-1E-6)
			{
				aa = bb = dd = 0;
				printf ("WARNING: degenerate QuArK-style brush texture\n");
			}
			else
			{
				mdet = 1.0/mdet;
      			aa = dot33*mdet;
      			bb = -dot23*mdet;
				//cc = -dot23*mdet;     // cc = bb
				dd = dot22*mdet;
			}

			for (j=0; j<3; j++)
			{
				tx.vecs[0][j] = aa * TexPt[0][j] + bb * TexPt[1][j];
				tx.vecs[1][j] = -(/*cc*/ bb * TexPt[0][j] + dd * TexPt[1][j]);
			}
			
			tx.vecs[0][3] = -DotProduct(tx.vecs[0], planepts[0]);
			tx.vecs[1][3] = -DotProduct(tx.vecs[1], planepts[0]);
		}
		else
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
		if (!GetToken (true))
			Error ("ParseEntity: EOF without closing brace");
		if (!strcmp (token, "}") )
			break;
		if (!strcmp (token, "{") )
			ParseBrush ();
		else
			ParseEpair ();
	} while (1);

   if (!strcmp("am_detail",ValueForKey(mapent,"classname")))
   {
      mbrush_t *b,*lb;
// set detail flag
      for (lb=b=mapent->brushes;b;lb=b,b=b->next)
         b->detail=1,numdetailbrushes++;
// add to worldspawn
      lb->next=entities->brushes;
      entities->brushes=mapent->brushes;
      num_entities--;
		memset(mapent,0,sizeof(entity_t));
      return true;
   }
   else
   {
      mbrush_t *b;
      for (b=mapent->brushes;b;b=b->next)
         if (b->detail) numdetailbrushes++;
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
	
	Q_free (buf);
	
	qprintf ("--- LoadMapFile ---\n");
	qprintf ("%s\n", filename);
	qprintf ("%5i brushes (%i detail)\n", nummapbrushes,numdetailbrushes);
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
			Q_free (ep->value);
			ep->value = copystring(value);
			return;
		}
	ep = Q_malloc (sizeof(*ep));
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


void WriteEntitiesToString (void)
{
	char	*buf, *end;
	epair_t	*ep;
	char	line[128];
	int		i;
	
	buf = dentdata;
	end = buf;
	*end = 0;
	
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

