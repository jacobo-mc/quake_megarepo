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

//
// spritegen.c: generates a .spr file from a series of .lbm frame files.
// Result is stored in /raid/quake/id1/sprites/<scriptname>.spr.
//

#include <png.h>
#define PNG_BYTES_TO_CHECK 4

#define INCLUDELIBS


#ifdef NeXT
#include <libc.h>
#endif

#include "spritegn.h"

#define MAX_BUFFER_SIZE		0x100000
#define MAX_FRAMES			1000

dsprite_t		sprite;
byte			*byteimage, *lbmpalette;
int				byteimagewidth, byteimageheight;
byte			*lumpbuffer, *plump;
char			spritedir[1024];
char			spriteoutname[1024];
int				framesmaxs[2];
int				framecount;

typedef struct {
	spriteframetype_t	type;		// single frame or group of frames
	void				*pdata;		// either a dspriteframe_t or group info
	float				interval;	// only used for frames in groups
	int					numgroupframes;	// only used by group headers
} spritepackage_t;

spritepackage_t	frames[MAX_FRAMES];

void FinishSprite (void);
void Cmd_Spritename (void);


/*
============
WriteFrame
============
*/
void WriteFrame (FILE *spriteouthandle, int framenum)
{
	dspriteframe_t	*pframe;
	dspriteframe_t	frametemp;

	pframe = (dspriteframe_t *)frames[framenum].pdata;
	frametemp.origin[0] = LittleLong (pframe->origin[0]);
	frametemp.origin[1] = LittleLong (pframe->origin[1]);
	frametemp.width = LittleLong (pframe->width);
	frametemp.height = LittleLong (pframe->height);

	SafeWrite (spriteouthandle, &frametemp, sizeof (frametemp));
	SafeWrite (spriteouthandle,
			   (byte *)(pframe + 1),
			   pframe->height * pframe->width);
}


/*
============
WriteSprite
============
*/
void WriteSprite (FILE *spriteouthandle)
{
	int			i, groupframe, curframe;
	dsprite_t	spritetemp;

	sprite.boundingradius = sqrt (((framesmaxs[0] >> 1) *
								   (framesmaxs[0] >> 1)) +
								  ((framesmaxs[1] >> 1) *
								   (framesmaxs[1] >> 1)));

//
// write out the sprite header
//
	spritetemp.type = LittleLong (sprite.type);
	spritetemp.boundingradius = LittleFloat (sprite.boundingradius);
	spritetemp.width = LittleLong (framesmaxs[0]);
	spritetemp.height = LittleLong (framesmaxs[1]);
	spritetemp.numframes = LittleLong (sprite.numframes);
	spritetemp.beamlength = LittleFloat (sprite.beamlength);
	spritetemp.synctype = LittleFloat (sprite.synctype);
	spritetemp.version = LittleLong (SPRITE_VERSION);
	spritetemp.ident = LittleLong (IDSPRITEHEADER);

	SafeWrite (spriteouthandle, &spritetemp, sizeof(spritetemp));

//
// write out the frames
//
	curframe = 0;

	for (i=0 ; i<sprite.numframes ; i++)
	{
		SafeWrite (spriteouthandle, &frames[curframe].type,
				   sizeof(frames[curframe].type));

		if (frames[curframe].type == SPR_SINGLE)
		{
		//
		// single (non-grouped) frame
		//
			WriteFrame (spriteouthandle, curframe);
			curframe++;
		}
		else
		{
			int					j, numframes;
			dspritegroup_t		dsgroup;
			float				totinterval;

			groupframe = curframe;
			curframe++;
			numframes = frames[groupframe].numgroupframes;

		//
		// set and write the group header
		//
			dsgroup.numframes = LittleLong (numframes);

			SafeWrite (spriteouthandle, &dsgroup, sizeof(dsgroup));

		//
		// write the interval array
		//
			totinterval = 0.0;

			for (j=0 ; j<numframes ; j++)
			{
				dspriteinterval_t	temp;

				totinterval += frames[groupframe+1+j].interval;
				temp.interval = LittleFloat (totinterval);

				SafeWrite (spriteouthandle, &temp, sizeof(temp));
			}

			for (j=0 ; j<numframes ; j++)
			{
				WriteFrame (spriteouthandle, curframe);
				curframe++;
			}
		}
	}
}


/*
============
ExecCommand
============
*/
int	cmdsrun;

void ExecCommand (char *cmd, ...)
{
	int		ret;
	char	cmdline[1024];
	va_list	argptr;
	
	cmdsrun++;
	
	va_start (argptr, cmd);
	vsprintf (cmdline,cmd,argptr);
	va_end (argptr);
	
//	printf ("=============================================================\n");
//	printf ("spritegen: %s\n",cmdline);
	fflush (stdout);
	ret = system (cmdline);
//	printf ("=============================================================\n");
	
	if (ret)
		Error ("spritegen: exiting due to error");
}

/*
==============
LoadScreen
==============
*/
void LoadScreen (char *name)
{
	char	header[4];
	int		i, is_png, color_type, num_palette, color, row;
	FILE	*fp;

	png_structp png_ptr;
	png_infop info_ptr;
	png_infop end_info;
    png_bytep * row_pointers;
	png_color * palette;

	printf ("grabbing from %s...\n",name);

	// use libpng if the image is in png format

	for (i=0; name[i] != '\0'; i++)
	{
		if (!Q_strcasecmp (name + i,".PNG"))
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

			if (!(fp = fopen(name, "rb")))
				Error ("Couldn't open image %s", name);

			// check the header bytes

			fread(header, 1, PNG_BYTES_TO_CHECK, fp);
			if (!(is_png = !png_sig_cmp(header, 0, PNG_BYTES_TO_CHECK)))
			{
				fclose (fp);
				Error ("%s does not seem to be PNG format", name);
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
				Error ("%s is an RGB image, not supported", name);
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

	LoadLBM (name, &byteimage, &lbmpalette);

	byteimagewidth = bmhd.w;
	byteimageheight = bmhd.h;
}


/*
===============
Cmd_Type
===============
*/
void Cmd_Type (void)
{
	GetToken (false);
	if (!strcmp (token, "vp_parallel_upright"))
		sprite.type = SPR_VP_PARALLEL_UPRIGHT;
	else if (!strcmp (token, "facing_upright"))
		sprite.type = SPR_FACING_UPRIGHT;
	else if (!strcmp (token, "vp_parallel"))
		sprite.type = SPR_VP_PARALLEL;
	else if (!strcmp (token, "oriented"))
		sprite.type = SPR_ORIENTED;
	else if (!strcmp (token, "vp_parallel_oriented"))
		sprite.type = SPR_VP_PARALLEL_ORIENTED;
	else
		Error ("Bad sprite type\n");
}


/*
===============
Cmd_Beamlength
===============
*/
void Cmd_Beamlength ()
{
	GetToken (false);
	sprite.beamlength = atof (token);
}


/*
===============
Cmd_Load
===============
*/
void Cmd_Load (void)
{
	GetToken (false);
	LoadScreen (ExpandPathAndArchive(token));
}


/*
===============
Cmd_Frame
===============
*/
void Cmd_Frame ()
{
	int             x,y,xl,yl,xh,yh,w,h;
	byte            *screen_p, *source;
	int             linedelta;
	dspriteframe_t	*pframe;
	int				pix;
	
	GetToken (false);
	xl = atoi (token);
	GetToken (false);
	yl = atoi (token);
	GetToken (false);
	w = atoi (token);
	GetToken (false);
	h = atoi (token);

	if ((xl & 0x07) || (yl & 0x07) || (w & 0x07) || (h & 0x07))
		Warning ("Sprite dimensions not multiples of 8\n");

	if ((w > 255) || (h > 255))
		Warning ("Sprite has a dimension longer than 255");

	xh = xl+w;
	yh = yl+h;

	pframe = (dspriteframe_t *)plump;
	frames[framecount].pdata = pframe;
	frames[framecount].type = SPR_SINGLE;

	if (TokenAvailable ())
	{
		GetToken (false);
		frames[framecount].interval = atof (token);
		if (frames[framecount].interval <= 0.0)
			Error ("Non-positive interval");
	}
	else
	{
		frames[framecount].interval = 0.1;
	}
	
	if (TokenAvailable ())
	{
		GetToken (false);
		pframe->origin[0] = -atoi (token);
		GetToken (false);
		pframe->origin[1] = atoi (token);
	}
	else
	{
		pframe->origin[0] = -(w >> 1);
		pframe->origin[1] = h >> 1;
	}

	pframe->width = w;
	pframe->height = h;

	if (w > framesmaxs[0])
		framesmaxs[0] = w;
	
	if (h > framesmaxs[1])
		framesmaxs[1] = h;
	
	plump = (byte *)(pframe + 1);

	screen_p = byteimage + yl*byteimagewidth + xl;
	linedelta = byteimagewidth - w;

	source = plump;

	for (y=yl ; y<yh ; y++)
	{
		for (x=xl ; x<xh ; x++)
		{
			pix = *screen_p;
			*screen_p++ = 0;
//			if (pix == 255)
//				pix = 0;
			*plump++ = pix;
		}
		screen_p += linedelta;
	}

	framecount++;
	if (framecount >= MAX_FRAMES)
		Error ("Too many frames; increase MAX_FRAMES\n");
}


/*
===============
Cmd_GroupStart	
===============
*/
void Cmd_GroupStart (void)
{
	int			groupframe;

	groupframe = framecount++;

	frames[groupframe].type = SPR_GROUP;
	frames[groupframe].numgroupframes = 0;

	while (1)
	{
		GetToken (true);
		if (endofscript)
			Error ("End of file during group");

		if (!strcmp (token, "$frame"))
		{
			Cmd_Frame ();
			frames[groupframe].numgroupframes++;
		}
		else if (!strcmp (token, "$load"))
		{
			Cmd_Load ();
		}
		else if (!strcmp (token, "$groupend"))
		{
			break;
		}
		else
		{
			Error ("$frame, $load, or $groupend expected\n");
		}

	}

	if (frames[groupframe].numgroupframes == 0)
		Error ("Empty group\n");
}


/*
===============
ParseScript	
===============
*/
void ParseScript (void)
{
	while (1)
	{
		GetToken (true);
		if (endofscript)
			break;
	
		if (!strcmp (token, "$load"))
		{
			Cmd_Load ();
		}
		if (!strcmp (token, "$spritename"))
		{
			Cmd_Spritename ();
		}
		else if (!strcmp (token, "$type"))
		{
			Cmd_Type ();
		}
		else if (!strcmp (token, "$beamlength"))
		{
			Cmd_Beamlength ();
		}
		else if (!strcmp (token, "$sync"))
		{
			sprite.synctype = ST_SYNC;
		}
		else if (!strcmp (token, "$frame"))
		{
			Cmd_Frame ();
			sprite.numframes++;
		}		
		else if (!strcmp (token, "$load"))
		{
			Cmd_Load ();
		}
		else if (!strcmp (token, "$groupstart"))
		{
			Cmd_GroupStart ();
			sprite.numframes++;
		}
	}
}

/*
==============
Cmd_Spritename
==============
*/
void Cmd_Spritename (void)
{
	if (sprite.numframes)
		FinishSprite ();

	GetToken (false);
	sprintf (spriteoutname, "%s%s.spr", spritedir, token);
	memset (&sprite, 0, sizeof(sprite));
	framecount = 0;

	framesmaxs[0] = -9999999;
	framesmaxs[1] = -9999999;

	lumpbuffer = malloc (MAX_BUFFER_SIZE * 2);	// *2 for padding
	if (!lumpbuffer)
		Error ("Couldn't get buffer memory");

	plump = lumpbuffer;
	sprite.synctype = ST_RAND;	// default
}

/*
==============
FinishSprite	
==============
*/
void FinishSprite (void)
{
	FILE	*spriteouthandle;

	if (sprite.numframes == 0)
		Error ("no frames\n");

	if (!strlen(spriteoutname))
		Error ("Didn't name sprite file");
		
	if ((plump - lumpbuffer) > MAX_BUFFER_SIZE)
		Error ("Sprite package too big; increase MAX_BUFFER_SIZE");

	spriteouthandle = SafeOpenWrite (spriteoutname);
	printf ("saving in %s\n", spriteoutname);
	WriteSprite (spriteouthandle);
	fclose (spriteouthandle);
	
	printf ("spritegen: successful\n");
	printf ("%d frame(s)\n", sprite.numframes);
	printf ("%d ungrouped frame(s), including group headers\n", framecount);
	
	spriteoutname[0] = 0;		// clear for a new sprite
}

/*
==============
main
	
==============
*/
int main (int argc, char **argv)
{
	int		i;

	if (argc != 2 && argc != 4)
		Error ("usage: spritegen [-archive directory] file.qc");
		
	if (!strcmp(argv[1], "-archive"))
	{
		archive = true;
		strcpy (archivedir, argv[2]);
		printf ("Archiving source to: %s\n", archivedir);
		i = 3;
	}
	else
		i = 1;

	SetQdirFromPath (argv[i]);
	ExtractFilePath (argv[i], spritedir);	// chop the filename

//
// load the script
//
	LoadScriptFile (argv[i]);
	
	ParseScript ();
	FinishSprite ();

	return 0;
}

