// lighting.c

#include "light.h"

/*

NOTES
-----

*/

float		scaledist = 1.0;
float		scalecos = 0.5;
float		rangescale = 0.5;

byte		*filebase, *file_p, *file_end;

dmodel_t	*bspmodel;
int			bspfileface;	// next surface to dispatch

vec3_t	bsp_origin;

qboolean	extrasamples;

float		minlights[MAX_MAP_FACES];

//JIM
qboolean	nolightface[MAX_MAP_FACES];
vec3_t		faceoffset[MAX_MAP_FACES];

byte *GetFileSpace (int size)
{
	byte	*buf;
	
	LOCK;
	file_p = (byte *)(((long)file_p + 3)&~3);
	buf = file_p;
	file_p += size;
	UNLOCK;
	if (file_p > file_end)
		Error ("GetFileSpace: overrun");
	return buf;
}


void LightThread (void *junk)
{
	int			i;
	
	while (1)
	{
		LOCK;
		i = bspfileface++;
		UNLOCK;
		if (i >= numfaces)
			return;
//JIM
		LightFace (i, nolightface[i], faceoffset[ i ]);
	}
}

//JIM
void FindFaceOffsets( void )
   {
   extern int		nummodels;
   extern dmodel_t	dmodels[MAX_MAP_MODELS];
   int i,j;
   entity_t *ent;
   char name[ 20 ];
   char *classname;
   vec3_t org;
   
   memset( nolightface, 0, sizeof( nolightface ) );

   for( j = dmodels[ 0 ].firstface; j < dmodels[ 0 ].numfaces; j++ )
	  {
	  nolightface[ j ] = 0;
	  }
   for( i = 1; i < nummodels; i++ )
      {
      sprintf( name, "*%d", i );	  
	  ent = FindEntityWithKeyPair( "model", name );
	  if ( !ent )
	     {
		 Error( "FindFaceOffsets: Couldn't find entity for model %s.\n", 
		    name );
		 }
		 
	  classname = ValueForKey ( ent, "classname" );
	  if ( !strncmp( classname, "rotate_", 7 ) )
	     {
		 int start;
		 int end;

		 GetVectorForKey(ent, "origin", org);

		 start = dmodels[ i ].firstface;
		 end = start + dmodels[ i ].numfaces;
         for( j = start; j < end; j++ )
	        {
		    nolightface[ j ] = 300;
			faceoffset[ j ][ 0 ] = org[ 0 ];
			faceoffset[ j ][ 1 ] = org[ 1 ];
			faceoffset[ j ][ 2 ] = org[ 2 ];
	     	}
		 }
	  }
   }

/*
=============
LightWorld
=============
*/
void LightWorld (void)
{
	filebase = file_p = dlightdata;
	file_end = filebase + MAX_MAP_LIGHTING;

	RunThreadsOn (LightThread);

	lightdatasize = file_p - filebase;
	
	printf ("lightdatasize: %i\n", lightdatasize);
}


/*
========
main

light modelfile
========
*/
int main (int argc, char **argv)
{
	int		i;
	double		start, end;
	char		source[1024];

	printf ("----- LightFaces ----\n");

	for (i=1 ; i<argc ; i++)
	{
		if (!strcmp(argv[i],"-threads"))
		{
			numthreads = atoi (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-extra"))
		{
			extrasamples = true;
			printf ("extra sampling enabled\n");
		}
		else if (!strcmp(argv[i],"-dist"))
		{
			scaledist = atof (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-range"))
		{
			rangescale = atof (argv[i+1]);
			i++;
		}
		else if (argv[i][0] == '-')
			Error ("Unknown option \"%s\"", argv[i]);
		else
			break;
	}

	if (i != argc - 1)
		Error ("usage: light [-threads num] [-extra] bspfile");

	InitThreads ();

	start = I_FloatTime ();

	strcpy (source, argv[i]);
	StripExtension (source);
	DefaultExtension (source, ".bsp");
	
	LoadBSPFile (source);
	LoadEntities ();
		
	MakeTnodes (&dmodels[0]);

//JIM
	FindFaceOffsets();
	LightWorld ();

	WriteEntitiesToString ();	
	WriteBSPFile (source);

	end = I_FloatTime ();
	printf ("%5.1f seconds elapsed\n", end-start);
	
	return 0;
}

