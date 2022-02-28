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

#include <png.h>
#define PNG_BYTES_TO_CHECK 4

#define VERSION "2.0"
#include "qlumpy.h"

#define MAXLUMP		0x50000         // biggest possible lump


byte            *byteimage, *lbmpalette;
int              byteimagewidth, byteimageheight;

char            basepath[1024];
char            lumpname[16];

char			destfile[1024];

byte            *lumpbuffer, *lump_p;

qboolean		savesingle;
qboolean		outputcreated;

/*
=============================================================================

							MAIN

=============================================================================
*/

void GrabRaw (void);
void GrabPalette (void);
void GrabPic (void);
void GrabMip (void);
void GrabColormap (void);
void GrabColormap2 (void);

typedef struct
{
	char    *name;
	void    (*function) (void);
} command_t;

command_t       commands[] =
{
	{"palette",GrabPalette},
	{"colormap",GrabColormap},
	{"qpic",GrabPic},
	{"miptex",GrabMip},
	{"raw",GrabRaw},

	{"colormap2",GrabColormap2},

	{NULL,NULL}                     // list terminator
};



/*
==============
LoadScreen
==============
*/
void LoadScreen (char *name)
{
	char	*expanded;

	char	header[4];
	int		i, is_png, color_type, num_palette, color, row;
	FILE	*fp;

	png_structp png_ptr;
	png_infop info_ptr;
	png_infop end_info;
    png_bytep * row_pointers;
	png_color * palette;

	expanded = ExpandPathAndArchive (name);

	printf ("grabbing from %s...\n",expanded);

	// use libpng if the image is in png format

	for (i=0; expanded[i] != '\0'; i++)
	{
		if (!Q_strcasecmp (expanded + i,".PNG"))
		{
			if (!(png_ptr = png_create_read_struct (PNG_LIBPNG_VER_STRING, NULL, NULL, NULL)))
			{
				Error ("Failed to create PNG read struct");
			}
			if (!(info_ptr = png_create_info_struct (png_ptr)))
			{
				png_destroy_read_struct (&png_ptr, (png_infopp)NULL, (png_infopp)NULL);
				Error ("Failed to create PNG info struct");
			}
			if (!(end_info = png_create_info_struct (png_ptr)))
			{
				png_destroy_read_struct (&png_ptr, &info_ptr, (png_infopp)NULL);
				Error ("Failed to create PNG end struct");
			}
			if (setjmp (png_jmpbuf (png_ptr)))
			{
				png_destroy_read_struct (&png_ptr, &info_ptr, &end_info);
				Error ("Failed to set jump point expected by libpng");
			}

			// open the file

			if (!(fp = fopen(expanded, "rb")))
				Error ("Couldn't open image %s", expanded);

			// check the header bytes

			fread(header, 1, PNG_BYTES_TO_CHECK, fp);
			if (!(is_png = !png_sig_cmp(header, 0, PNG_BYTES_TO_CHECK)))
			{
				fclose (fp);
				Error ("%s does not seem to be PNG format", expanded);
			}

			// load image

			png_init_io			(png_ptr, fp);
			png_set_sig_bytes	(png_ptr, PNG_BYTES_TO_CHECK);
			png_read_png		(png_ptr, info_ptr,
				PNG_TRANSFORM_STRIP_16 | PNG_TRANSFORM_STRIP_ALPHA | PNG_TRANSFORM_PACKING,
				NULL);

			// PNG_TRANSFORM_STRIP_16		Strip 16-bit samples to 8 bits
			// PNG_TRANSFORM_STRIP_ALPHA	Discard the alpha channel
			// PNG_TRANSFORM_PACKING		Expand 1, 2 and 4-bit samples to bytes

			fclose (fp);

			row_pointers	= png_get_rows			(png_ptr, info_ptr);
			byteimagewidth	= png_get_image_width	(png_ptr, info_ptr);
			byteimageheight	= png_get_image_height	(png_ptr, info_ptr);
			color_type		= png_get_color_type	(png_ptr, info_ptr);

			if (color_type == PNG_COLOR_TYPE_RGB || color_type == PNG_COLOR_TYPE_RGB_ALPHA)
			{
				png_destroy_read_struct (&png_ptr, &info_ptr, &end_info);
				Error ("%s is an RGB image, not supported", expanded);
			}

			// get the palette

			if (!(lbmpalette = malloc (768)))
			{
				png_destroy_read_struct (&png_ptr, &info_ptr, &end_info);
				Error ("could not allocate 768 palette bytes");
			}
			memset (lbmpalette, 0, 768);
			if (color_type == PNG_COLOR_TYPE_PALETTE)
			{
			    png_get_PLTE (png_ptr, info_ptr, &palette, &num_palette);
				if (num_palette > 256) num_palette = 256;
				for (color = 0; color < num_palette; color++)
				{
					lbmpalette[color*3+0] = palette[color].red;
					lbmpalette[color*3+1] = palette[color].green;
					lbmpalette[color*3+2] = palette[color].blue;
				}
			}

			// get the pixels

			if (!(byteimage = malloc (byteimagewidth * byteimageheight)))
			{
				png_destroy_read_struct (&png_ptr, &info_ptr, &end_info);
				Error ("could not allocate %i image bytes", byteimagewidth * byteimageheight);
			}
			for (row=0; row < byteimageheight; row++)
				memcpy (byteimage + row * byteimagewidth, row_pointers[row], byteimagewidth);

			png_destroy_read_struct (&png_ptr, &info_ptr, &end_info);

			return;
		}
	}

	LoadLBM (expanded, &byteimage, &lbmpalette);

	byteimagewidth = bmhd.w;
	byteimageheight = bmhd.h;
}


/*
================
CreateOutput
================
*/
void CreateOutput (void)
{
	outputcreated = true;
//
// create the output wadfile file
//
	NewWad (destfile, false);	// create a new wadfile
}

/*
===============
WriteLump
===============
*/
void WriteLump (int type, int compression)
{
	int		size;
	
	if (!outputcreated)
		CreateOutput ();

//
// dword align the size
//
	while ((int)lump_p&3)
		*lump_p++ = 0;

	size = lump_p - lumpbuffer;
	if (size > MAXLUMP)
		Error ("Lump size exceeded %d, memory corrupted!",MAXLUMP);

//
// write the grabbed lump to the wadfile
//
	AddLump (lumpname,lumpbuffer,size,type, compression);
}

/*
===========
WriteFile

Save as a seperate file instead of as a wadfile lump
===========
*/
void WriteFile (void)
{
	char	filename[1024];
	char	*exp;

	sprintf (filename,"%s/%s.lmp", destfile, lumpname);
	exp = ExpandPath(filename);
	printf ("saved %s\n", exp);
	SaveFile (exp, lumpbuffer, lump_p-lumpbuffer);		
}

/*
================
ParseScript
================
*/
void ParseScript (void)
{
	int			cmd;
	int			size;
	
	do
	{
		//
		// get a command / lump name
		//
		GetToken (true);
		if (endofscript)
			break;
		if (!Q_strcasecmp (token,"$LOAD"))
		{
			GetToken (false);
			LoadScreen (token);
			continue;
		}

		if (!Q_strcasecmp (token,"$DEST"))
		{
			GetToken (false);
			strcpy (destfile, ExpandPath(token));
			continue;
		}

		if (!Q_strcasecmp (token,"$SINGLEDEST"))
		{
			GetToken (false);
			strcpy (destfile, token);
			savesingle = true;
			continue;
		}


		//
		// new lump
		//
		if (strlen(token) >= sizeof(lumpname) )
			Error ("\"%s\" is too long to be a lump name",token);
		memset (lumpname,0,sizeof(lumpname));			
		strcpy (lumpname, token);
		for (size=0 ; size<sizeof(lumpname) ; size++)
			lumpname[size] = tolower(lumpname[size]);

		//
		// get the grab command
		//
		lump_p = lumpbuffer;

		GetToken (false);

		//
		// call a routine to grab some data and put it in lumpbuffer
		// with lump_p pointing after the last byte to be saved
		//
		for (cmd=0 ; commands[cmd].name ; cmd++)
			if ( !Q_strcasecmp(token,commands[cmd].name) )
			{
				commands[cmd].function ();
				break;
			}

		if ( !commands[cmd].name )
			Error ("Unrecognized token '%s' at line %i",token,scriptline);
	
		grabbed++;
		
		if (savesingle)
			WriteFile ();
		else	
			WriteLump (TYP_LUMPY+cmd, 0);
		
	} while (script_p < scriptend_p);
}

/*
=================
ProcessLumpyScript

Loads a script file, then grabs everything from it
=================
*/
void ProcessLumpyScript (char *basename)
{
	char            script[256];

	printf ("qlumpy script: %s\n",basename);
	
//
// create default destination directory
//
	strcpy (destfile, ExpandPath(basename));
	StripExtension (destfile);
	strcat (destfile,".wad");		// unless the script overrides, save in cwd

//
// save in a wadfile by default
//
	savesingle = false;
	grabbed = 0;
	outputcreated = false;
	
	
//
// read in the script file
//
	strcpy (script, basename);
	DefaultExtension (script, ".ls");
	LoadScriptFile (script);
	
	strcpy (basepath, basename);
	
	ParseScript ();				// execute load / grab commands
	
	if (!savesingle)
	{
		WriteWad ();				// write out the wad directory
		printf ("%i lumps grabbed in a wad file\n",grabbed);
	}
	else
		printf ("%i lumps written seperately\n",grabbed);
}


/*
==============================
main
==============================
*/
int main (int argc, char **argv)
{
	int		i;
	
	printf ("\nqlumpy "VERSION" by John Carmack, copyright (c) 1994 Id Software\n");

	if (argc == 1)
		Error ("qlumpy [-archive directory] scriptfile [scriptfile ...]");

	lumpbuffer = malloc (MAXLUMP);

	if (!strcmp(argv[1], "-archive"))
	{
		archive = true;
		strcpy (archivedir, argv[2]);
		printf ("Archiving source to: %s\n", archivedir);
		i = 3;
	}
	else
		i = 1;


	for ( ; i<argc ; i++)
	{
		SetQdirFromPath (argv[i]);
		ProcessLumpyScript (argv[i]);
	}
		
	return 0;
}
