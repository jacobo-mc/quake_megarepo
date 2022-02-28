
#include "bsp5.h"


int		headclipnode;
int		firstface;

//===========================================================================

/*
==================
FindFinalPlane

Used to find plane index numbers for clip nodes read from child processes
==================
*/
int FindFinalPlane (dplane_t *p)
{
  int		i;
  dplane_t	*dplane;
	
  for (i=0, dplane = dplanes ; i<numplanes ; i++, dplane++)
    {
      if (p->type != dplane->type)
	continue;
      if (p->dist != dplane->dist)
	continue;
      if (p->normal[0] != dplane->normal[0])
	continue;
      if (p->normal[1] != dplane->normal[1])
	continue;
      if (p->normal[2] != dplane->normal[2])
	continue;
      return i;
    }
	
  //
  // new plane
  //
  if (numplanes == MAX_MAP_PLANES)
    Error ("numplanes == MAX_MAP_PLANES");
  dplane = &dplanes[numplanes];
  *dplane = *p;
  numplanes++;
	
  return numplanes - 1;
}



int		planemapping[MAX_MAP_PLANES];

void WriteNodePlanes_r (node_t *node)
{
  plane_t		*plane;
  dplane_t	*dplane;

  if (node->planenum == -1)
    return;
  if (planemapping[node->planenum] == -1)
    {	// a new plane
      planemapping[node->planenum] = numplanes;
		
      if (numplanes == MAX_MAP_PLANES)
	Error ("numplanes == MAX_MAP_PLANES");
      plane = &planes[node->planenum];
      dplane = &dplanes[numplanes];
      dplane->normal[0] = plane->normal[0];
      dplane->normal[1] = plane->normal[1];
      dplane->normal[2] = plane->normal[2];
      dplane->dist = plane->dist;
      dplane->type = plane->type;

      numplanes++;
    }

  node->outputplanenum = planemapping[node->planenum];
	
  WriteNodePlanes_r (node->children[0]);
  WriteNodePlanes_r (node->children[1]);
}

/*
==================
WriteNodePlanes

==================
*/
void WriteNodePlanes (node_t *nodes)
{
  memset (planemapping,-1, sizeof(planemapping));
  WriteNodePlanes_r (nodes);
}

//===========================================================================

/*
==================
WriteClipNodes_r

==================
*/
int WriteClipNodes_r (node_t *node)
{
  int			i, c;
  dclipnode_t	*cn;
  int			num;
	
  // FIXME: free more stuff?	
  if (node->planenum == -1)
    {
      num = node->contents;
      free (node);
      return num;
    }
	
  // emit a clipnode
  c = numclipnodes;
  cn = &dclipnodes[numclipnodes];
  numclipnodes++;
  cn->planenum = node->outputplanenum;
  for (i=0 ; i<2 ; i++)
    cn->children[i] = WriteClipNodes_r(node->children[i]);
	
  free (node);
  return c;
}

/*
==================
WriteClipNodes

Called after the clipping hull is completed.  Generates a disk format
representation and frees the original memory.
==================
*/
void WriteClipNodes (node_t *nodes)
{
  headclipnode = numclipnodes;
  WriteClipNodes_r (nodes);
}

//===========================================================================

/*
==================
WriteLeaf
==================
*/
void WriteLeaf (node_t *node)
{
  face_t		**fp, *f;
  dleaf_t		*leaf_p;
		
  // emit a leaf
  leaf_p = &dleafs[numleafs];
  numleafs++;

  leaf_p->contents = node->contents;

  //
  // write bounding box info
  //	
  VectorCopy (node->mins, leaf_p->mins);
  VectorCopy (node->maxs, leaf_p->maxs);
	
  leaf_p->visofs = -1;	// no vis info yet
	
  //
  // write the marksurfaces
  //
  leaf_p->firstmarksurface = nummarksurfaces;
	
  for (fp=node->markfaces ; *fp ; fp++)
    {
      // emit a marksurface
      if (nummarksurfaces == MAX_MAP_MARKSURFACES)
	Error ("nummarksurfaces == MAX_MAP_MARKSURFACES");
      f = *fp;
      do
	{
	  dmarksurfaces[nummarksurfaces] =  f->outputnumber;
	  nummarksurfaces++;
	  f=f->original;		// grab tjunction split faces
	} while (f);
    }
	
  leaf_p->nummarksurfaces = nummarksurfaces - leaf_p->firstmarksurface;
}


/*
==================
WriteDrawNodes_r
==================
*/
void WriteDrawNodes_r (node_t *node)
{
  dnode_t	*n;
  int		i;

  // emit a node	
  if (numnodes == MAX_MAP_NODES)
    Error ("numnodes == MAX_MAP_NODES");
  n = &dnodes[numnodes];
  numnodes++;

  VectorCopy (node->mins, n->mins);
  VectorCopy (node->maxs, n->maxs);

  n->planenum = node->outputplanenum;
  n->firstface = node->firstface;
  n->numfaces = node->numfaces;

  //
  // recursively output the other nodes
  //	
	
  for (i=0 ; i<2 ; i++)
    {
      if (node->children[i]->planenum == -1)
	{
	  if (node->children[i]->contents == CONTENTS_SOLID)
	    n->children[i] = -1;
	  else
	    {
	      n->children[i] = -(numleafs + 1);
	      WriteLeaf (node->children[i]);
	    }
	}
      else
	{
	  n->children[i] = numnodes;	
	  WriteDrawNodes_r (node->children[i]);
	}
    }
}

/*
==================
WriteDrawNodes
==================
*/
void WriteDrawNodes (node_t *headnode)
{
  int		i;
  int		start;
  dmodel_t	*bm;

#if 0
  if (headnode->contents < 0)
    Error ("FinishBSPModel: empty model");
#endif

  // emit a model
  if (nummodels == MAX_MAP_MODELS)
    Error ("nummodels == MAX_MAP_MODELS");
  bm = &dmodels[nummodels];
  nummodels++;
	
  bm->headnode[0] = numnodes;
  bm->firstface = firstface;
  bm->numfaces = numfaces - firstface;	
  firstface = numfaces;
	
  start = numleafs;

  if (headnode->contents < 0)	
    WriteLeaf (headnode);
  else
    WriteDrawNodes_r (headnode);
  bm->visleafs = numleafs - start;
	
  for (i=0 ; i<3 ; i++)
    {
      bm->mins[i] = headnode->mins[i] + SIDESPACE + 1;	// remove the padding
      bm->maxs[i] = headnode->maxs[i] - SIDESPACE - 1;
    }
  // FIXME: are all the children decendant of padded nodes?
}


/*
==================
BumpModel

Used by the clipping hull processes that only need to store headclipnode
==================
*/
void BumpModel (int hullnum)
{
  dmodel_t	*bm;

  // emit a model
  if (nummodels == MAX_MAP_MODELS)
    Error ("nummodels == MAX_MAP_MODELS");
  bm = &dmodels[nummodels];
  nummodels++;
	
  bm->headnode[hullnum] = headclipnode;
}

//=============================================================================

typedef struct
{
  char		identification[4];		// should be WAD2
  int			numlumps;
  int			infotableofs;
} wadinfo_t;


typedef struct
{
  int			filepos;
  int			disksize;
  int			size;					// uncompressed
  char		type;
  char		compression;
  char		pad1, pad2;
  char		name[16];				// must be null terminated
} lumpinfo_t;

FILE		*texfile[NUM_WADS];
wadinfo_t	wadinfo[NUM_WADS];
lumpinfo_t	*lumpinfo[NUM_WADS];

void CleanupName (char *in, char *out)
{
  int		i;
	
  for (i=0 ; i< 16 ; i++ )
    {
      if (!in[i])
	break;
			
      out[i] = toupper(in[i]);
    }
	
  for ( ; i< 16 ; i++ )
    out[i] = 0;
}

char strsepbuf[2048];

// LordHavoc: had to write this to parse the path, wasn't included with MSVC++ 4.0
char* strsep(char **list, char* seperator)
{
	char *current, *start;
	int c, sep, i;
	current = *list;
	if (*current == 0) // end of the list
		return 0;
	sep = *seperator;
	while (*current == sep)
		current++;
	start = current;
	i = 0;
	while ((c = *current) != 0 && c != sep)
	{
		strsepbuf[i++] = c;
		current++;
	}
	strsepbuf[i++] = 0;
	while (*current == sep)
		current++;
	*list = current;
	return &strsepbuf[0];
}

/*
=================
TEX_InitFromWad
=================
*/
void	TEX_InitFromWad (char *path)
{
  int			i, j = 0;
  char *word, buf[2048];
  
  while ((word = (char *) strsep(&path, ";")) && j < NUM_WADS) {
    //    sprintf(buf, "%s/%s", gamedir, word);
    strcpy(buf, word);
    printf("reading wadfile: '%s'\n", buf);
    texfile[j] = SafeOpenRead (buf);

    SafeRead (texfile[j], &wadinfo[j], sizeof(wadinfo_t));
    if (strncmp (wadinfo[j].identification, "WAD2", 4))
      Error ("TEX_InitFromWad: %s isn't a wadfile",buf);
    wadinfo[j].numlumps = LittleLong(wadinfo[j].numlumps);
    wadinfo[j].infotableofs = LittleLong(wadinfo[j].infotableofs);
    fseek (texfile[j], wadinfo[j].infotableofs, SEEK_SET);
    lumpinfo[j] = malloc(wadinfo[j].numlumps*sizeof(lumpinfo_t));
    SafeRead (texfile[j], lumpinfo[j], wadinfo[j].numlumps*sizeof(lumpinfo_t));
    
    for (i=0 ; i<wadinfo[j].numlumps ; i++)
      {
	CleanupName (lumpinfo[j][i].name, lumpinfo[j][i].name);
	lumpinfo[j][i].filepos = LittleLong(lumpinfo[j][i].filepos);
	lumpinfo[j][i].disksize = LittleLong(lumpinfo[j][i].disksize);
      }
    j++;
  }
}

/*
==================
LoadLump
==================
*/
int LoadLump (char *name, byte *dest)
{
  int		i, j;
  char	cname[16];
	
  CleanupName (name, cname);
	
  for (j = 0; j < NUM_WADS; j++) {
    for (i=0 ; i < wadinfo[j].numlumps ; i++) {
      if (!strcmp(cname, lumpinfo[j][i].name)) {
	fseek (texfile[j], lumpinfo[j][i].filepos, SEEK_SET);
	SafeRead (texfile[j], dest, lumpinfo[j][i].disksize);
	return lumpinfo[j][i].disksize;
      }
    }
  }
  printf ("WARNING: texture %s not found\n", name);
  return 0;
}


/*
==================
AddAnimatingTextures
==================
*/
void AddAnimatingTextures (void)
{
  int		base;
  int		i, j, k, p;
  char	name[32];

  base = nummiptex;
	
  for (i=0 ; i<base ; i++)
    {
      if (miptex[i][0] != '+')
	continue;
      strcpy (name, miptex[i]);

      for (j=0 ; j<20 ; j++)
	{
	  if (j < 10)
	    name[1] = '0'+j;
	  else
	    name[1] = 'A'+j-10;		// alternate animation
			

	  // see if this name exists in the wadfile
	  for (p = 0; p < NUM_WADS; p++) {
	    for (k=0 ; k<wadinfo[p].numlumps ; k++) {
	      if (!strcmp(name, lumpinfo[p][k].name)) {
		{
		  FindMiptex (name);	// add to the miptex list
		  break;
		}
	      }
	    }
	  }
	}
    }
	
  printf ("added %i animated texture frames\n", nummiptex - base);
}

/*
==================
WriteMiptex
==================
*/
void WriteMiptex (void)
{
  int		i, len;
  byte	*data;
  dmiptexlump_t	*l;
  char	*path;

  path = ValueForKey (&entities[0], "_wad");
  if (!path || !path[0])
    {
      path = ValueForKey (&entities[0], "wad");
      if (!path || !path[0])
	{
	  printf ("WARNING: no wadfile specified\n");
	  texdatasize = 0;
	  return;
	}
    }

  TEX_InitFromWad (path);

  AddAnimatingTextures ();

  l = (dmiptexlump_t *)dtexdata;
  data = (byte *)&l->dataofs[nummiptex];
  l->nummiptex = nummiptex;
  for (i=0 ; i < nummiptex ; i++)
    {
      printf("miptex used:  %s\n", miptex[i]);
      l->dataofs[i] = data - (byte *)l;
      len = LoadLump (miptex[i], data);
      if (data + len - dtexdata >= MAX_MAP_MIPTEX)
	Error ("Textures exceeded MAX_MAP_MIPTEX");
      if (!len)
	l->dataofs[i] = -1;	// didn't find the texture
      data += len;
    }

  texdatasize = data - dtexdata;
}

//===========================================================================


/*
==================
BeginBSPFile
==================
*/
void BeginBSPFile (void)
{
  // edge 0 is not used, because 0 can't be negated
  numedges = 1;

// leaf 0 is common solid with no faces
  numleafs = 1;
  dleafs[0].contents = CONTENTS_SOLID;

  firstface = 0;	
}

/*
==================
FinishBSPFile
==================
*/
void FinishBSPFile (void)
{
  printf ("--- FinishBSPFile ---\n");
  printf ("WriteBSPFile: %s\n", bspfilename);
	
  WriteMiptex ();

  PrintBSPFileSizes ();
  WriteBSPFile (bspfilename);
}

