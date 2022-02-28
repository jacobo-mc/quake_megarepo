#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>

/*
changelog:
*/

void Error (char *message, ...)
{
	va_list argptr;

	puts("ERROR: ");

	va_start (argptr,message);
	vprintf (message,argptr);
	va_end (argptr);
	putchar('\n');
#if _DEBUG && WIN32
	printf ("press a key\n");
	getchar();
#endif
	exit (1);
}

int matchpattern(char *in, char *pattern)
{
	while (*pattern)
	{
		switch (*pattern)
		{
		case '?': // match any single character
			if (!*in)
				return 0; // no match
			in++;
			pattern++;
			break;
		case '*': // match anything until following string
			if (!*in)
				return 1; // match
			while (*pattern == '*')
				pattern++;
			if (*pattern == '?')
			{
				// *? (weird)
				break;
			}
			else if (*pattern)
			{
				// *text (typical)
				while (*in && *in != *pattern)
					in++;
			}
			else
			{
				// *null (* at end of pattern)
				return 1;
			}
			break;
		default:
			if (*in != *pattern)
				return 0; // no match
			in++;
			pattern++;
			break;
		}
	}
	if (*in)
		return 0; // reached end of pattern but not end of input
	return 1; // success
}

// a little chained strings system

// variable length
typedef struct stringlistsize_s
{
	struct stringlist_s *next;
} stringlistsize;

typedef struct stringlist_s
{
	struct stringlist_s *next;
	char text[1];
} stringlist;

stringlist *stringlistappend(stringlist *current, char *text)
{
	stringlist *newitem;
	newitem = malloc(strlen(text) + 1 + sizeof(stringlistsize));
	newitem->next = NULL;
	strcpy(newitem->text, text);
	if (current)
		current->next = newitem;
	return newitem;
}

void stringlistfree(stringlist *current)
{
	stringlist *next;
	while (current)
	{
		next = current->next;
		free(current);
		current = next;
	}
}

stringlist *stringlistsort(stringlist *start)
{
	int notdone;
	stringlist *previous, *temp2, *temp3, *temp4;
	stringlist *current;
	notdone = 1;
	while (notdone)
	{
		current = start;
		notdone = 0;
		previous = NULL;
		while (current && current->next)
		{
			if (strcmp(current->text, current->next->text) > 0)
			{
				// current is greater than next
				notdone = 1;
				temp2 = current->next;
				temp3 = current;
				temp4 = current->next->next;
				if (previous)
					previous->next = temp2;
				else
					start = temp2;
				temp2->next = temp3;
				temp3->next = temp4;
				break;
			}
			previous = current;
			current = current->next;
		}
	}
	return start;
}

// operating system specific code
#ifdef WIN32
#include <io.h>
stringlist *listdirectory(char *path)
{
	char pattern[4096];
	struct _finddata_t n_file;
    long hFile;
	stringlist *start, *current;
	strcpy(pattern, path);
	strcat(pattern, "\\*");
	// ask for the directory listing handle
	hFile = _findfirst(pattern, &n_file);
	if(hFile != -1)
	{
		// start a new chain with the the first name
		start = current = stringlistappend(NULL, n_file.name);
		// iterate through the directory
		while (_findnext(hFile, &n_file) == 0)
			current = stringlistappend(current, n_file.name);
		_findclose(hFile);
		// sort the list alphanumerically
		return stringlistsort(start);
	}
	else
		return NULL;
}
#else
#include <dirent.h>
stringlist *listdirectory(char *path)
{
	DIR *dir;
	struct dirent *ent;
	stringlist *start, *current;
	dir = opendir(path);
	if (!dir)
		return NULL;
	ent = readdir(dir);
	if (!ent)
	{
		closedir(dir);
		return NULL;
	}
	start = current = stringlistappend(NULL, ent->d_name);
	while((ent = readdir(dir)))
		current = stringlistappend(current, ent->d_name);
	closedir(dir);
	// sort the list alphanumerically
	return stringlistsort(start);
}
#endif

void StripExtension(char *in, char *out)
{
	char *dot;
	dot = strrchr(in, '.');
	if (dot)
	{
		if (dot < strrchr(in, '/'))
			dot = NULL;
		if (dot < strrchr(in, '\\'))
			dot = NULL;
		if (dot < strrchr(in, ':'))
			dot = NULL;
	}
	if (dot == NULL)
		dot = in + strlen(in);
	while (in < dot)
		*out++ = *in++;
	*out++ = 0;
}

int readfile(char *filename, void **mem, int *size)
{
	FILE *file;
	char *filemem;
	int filesize, readsize;
	*mem = NULL;
	*size = 0;
	file = fopen(filename, "rb");
	if (!file)
		return -1;
	fseek(file, 0, SEEK_END);
	filesize = ftell(file);
	fseek(file, 0, SEEK_SET);
	filemem = malloc(filesize+1);
	if (!filemem)
	{
		fclose(file);
		return -1;
	}
	readsize = fread(filemem, 1, filesize, file);
	fclose(file);
	if (readsize < filesize)
	{
		free(filemem);
		return -1;
	}
	((char *)filemem)[filesize] = 0; // null terminate the text file
	*mem = filemem;
	*size = filesize;
	return 0;
}

int writefile(char *filename, void *mem, int size)
{
	FILE *file;
	int writesize;
	file = fopen(filename, "wb");
	if (!file)
		return -1;
	writesize = fwrite(mem, 1, size, file);
	fclose(file);
	if (writesize < size)
		return -2;
	return 0;
}

int image_width, image_height;

int NoSwapLong(int num)
{
	return num;
}

int SwapLong(int num)
{
	return (((num >>  0) & 0xFF) << 24) + (((num >>  8) & 0xFF) << 16) + (((num >> 16) & 0xFF) << 8) + (((num >> 24) & 0xFF) << 0);
}

short NoSwapShort(short num)
{
	return num;
}

short SwapShort(short num)
{
	return (((num >>  0) & 0xFF) << 8) + (((num >>  8) & 0xFF) << 0);
}

int (*LittleLong)(int num);
int (*BigLong)(int num);
short (*LittleShort)(short num);
short (*BigShort)(short num);

void SwapDetect()
{
	unsigned char t[4] = {0, 0, 0, 1};
	int *test = (int *) t;
	if (*test == 1) // big endian
	{
		LittleLong = SwapLong;
		BigLong = NoSwapLong;
		LittleShort = SwapShort;
		BigShort = NoSwapShort;
	}
	else // little endian
	{
		LittleLong = NoSwapLong;
		BigLong = SwapLong;
		LittleShort = NoSwapShort;
		BigShort = SwapShort;
	}
}

typedef struct pcx_s
{
    char	manufacturer;
    char	version;
    char	encoding;
    char	bits_per_pixel;
    unsigned short	xmin, ymin, xmax, ymax;
    unsigned short	hres, vres;
    unsigned char	palette[48];
    char	reserved;
    char	color_planes;
    unsigned short	bytes_per_line;
    unsigned short	palette_type;
    char	filler[58];
}
pcx_t;

void WritePCX(char *filename, unsigned char *data, int width, int height, unsigned char *palette)
{
	int i, y, run, pix;
	pcx_t *pcx;
	unsigned char *pack, *dataend;

	pcx = malloc(width * height * 2 + 1000);
	if (!pcx)
	{
		printf("WritePCX: unable to allocate buffer\n");
		return;
	}
	memset(pcx, 0, sizeof(pcx_t));

	pcx->manufacturer = 0x0A;			// PCX id
	pcx->version = 5;					// 256 color
	pcx->encoding = 1;					// uncompressed
	pcx->bits_per_pixel = 8;			// 256 color
	pcx->xmin = 0;
	pcx->ymin = 0;
	pcx->xmax = LittleShort ((short) (width - 1));
	pcx->ymax = LittleShort ((short) (height - 1));
	pcx->hres = LittleShort ((short) width);
	pcx->vres = LittleShort ((short) height);
	pcx->color_planes = 1;				// chunky image
	pcx->bytes_per_line = LittleShort ((short) ((width + 1) & ~1));
	pcx->palette_type = LittleShort (2);	// not a grey scale

	// pack the image
	pack = (unsigned char*)&pcx[1];

	for (y = 0;y < height;y++)
	{
		for (dataend = data + width;data < dataend;)
		{
			for (pix = *data++, run = 0xC1;data < dataend && run < 0xFF && *data == pix;data++, run++);
			if (run > 0xC1 || pix >= 0xC0)
				*pack++ = run;
			*pack++ = pix;
		}
		if (width & 1)
			*pack++ = 0;
	}

	// write the palette
	*pack++ = 0x0c;						// palette ID byte
	for (i = 0; i < 768; i++)
		*pack++ = *palette++;

	// write output file
	writefile(filename, pcx, pack - (unsigned char *) pcx);

	free(pcx);
}

void WriteTGA(char *filename, unsigned char *data, int width, int height, const unsigned char *palettergb)
{
	int maxrun, run, c, y;
	unsigned char *buffer, *in, *end, *out;

	for (c = 0;c < width*height;c++)
		if (data[c] == 255)
			break;
	if (c < width*height)
	{
		// contains transparent pixels
		// BGRA truecolor since some programs can't deal with BGRA colormaps
		// a buffer big enough to store the worst compression ratio possible (1 extra byte per pixel)
		buffer = malloc(18+width*height*5);

		memset (buffer, 0, 18);
		buffer[2] = 10;		// RLE truecolor
		buffer[12] = (width >> 0) & 0xFF;
		buffer[13] = (width >> 8) & 0xFF;
		buffer[14] = (height >> 0) & 0xFF;
		buffer[15] = (height >> 8) & 0xFF;
		buffer[16] = 32;	// pixel size
		buffer[17] = 8; // 8 attribute bits per pixel, bottom left origin
		out = buffer + 18;

		// copy image
		for (y = 0;y < height;y++)
		{
			in = data + (height - 1 - y) * width;
			end = in + width;
			while (in < end)
			{
				maxrun = end - in;
				if (maxrun > 128)
					maxrun = 128;
				if (maxrun >= 2 && in[1] == in[0])
				{
					// run a loop that stops when the next byte is not the same
					for (run = 1;run < maxrun && in[run] == in[0];run++);
					*out++ = 0x80 + (run - 1);
					if (in[0] == 255)
					{
						*out++ = 0;
						*out++ = 0;
						*out++ = 0;
						*out++ = 0;
					}
					else
					{
						*out++ = palettergb[in[0]*3+2];
						*out++ = palettergb[in[0]*3+1];
						*out++ = palettergb[in[0]*3+0];
						*out++ = 255;
					}
					in += run;
				}
				else
				{
					// run a loop that stops when the next two bytes are the same
					for (run = 1;run < maxrun && (run >= maxrun - 1 || in[run+1] != in[run]);run++);
					*out++ = 0x00 + (run - 1);
					for (c = 0;c < run;c++)
					{
						if (in[0] == 255)
						{
							*out++ = 0;
							*out++ = 0;
							*out++ = 0;
							*out++ = 0;
						}
						else
						{
							*out++ = palettergb[in[0]*3+2];
							*out++ = palettergb[in[0]*3+1];
							*out++ = palettergb[in[0]*3+0];
							*out++ = 255;
						}
						in++;
					}
				}
			}
		}
	}
	else
	{
#if 1
		buffer = malloc(18+width*height*4);

		memset (buffer, 0, 18);
		buffer[2] = 10;		// RLE truecolor
		buffer[12] = (width >> 0) & 0xFF;
		buffer[13] = (width >> 8) & 0xFF;
		buffer[14] = (height >> 0) & 0xFF;
		buffer[15] = (height >> 8) & 0xFF;
		buffer[16] = 24;	// pixel size
		buffer[17] = 0; // 0 attribute bits per pixel, bottom left origin
		out = buffer + 18;

		// copy image
		for (y = 0;y < height;y++)
		{
			in = data + (height - 1 - y) * width;
			end = in + width;
			while (in < end)
			{
				maxrun = end - in;
				if (maxrun > 128)
					maxrun = 128;
				if (maxrun >= 2 && in[1] == in[0])
				{
					// run a loop that stops when the next byte is not the same
					for (run = 1;run < maxrun && in[run] == in[0];run++);
					*out++ = 0x80 + (run - 1);
					*out++ = palettergb[in[0]*3+2];
					*out++ = palettergb[in[0]*3+1];
					*out++ = palettergb[in[0]*3+0];
					in += run;
				}
				else
				{
					// run a loop that stops when the next two bytes are the same
					for (run = 1;run < maxrun && (run >= maxrun - 1 || in[run+1] != in[run]);run++);
					*out++ = 0x00 + (run - 1);
					for (c = 0;c < run;c++)
					{
						*out++ = palettergb[in[0]*3+2];
						*out++ = palettergb[in[0]*3+1];
						*out++ = palettergb[in[0]*3+0];
						in++;
					}
				}
			}
		}
#else
		// contains only opaque pixels
		// a buffer big enough to store the worst compression ratio possible (2 bytes per pixel)
		buffer = malloc(18+768+width*height*2);

		memset (buffer, 0, 18);
		buffer[1] = 1; // colormap type 1
		buffer[2] = 9;		// RLE compressed colormapped
		// colormap_index
		buffer[3] = (0 >> 0) & 0xFF;
		buffer[4] = (0 >> 8) & 0xFF;
		// colormap_length
		buffer[5] = (256 >> 0) & 0xFF;
		buffer[6] = (256 >> 8) & 0xFF;
		// colormap_size
		buffer[7] = 24; // 32bit BGRA colormap entries
		buffer[12] = (width >> 0) & 0xFF;
		buffer[13] = (width >> 8) & 0xFF;
		buffer[14] = (height >> 0) & 0xFF;
		buffer[15] = (height >> 8) & 0xFF;
		buffer[16] = 8;	// pixel size
		buffer[17] = 0; // 0 attribute bits per pixel, origin bottom left
		out = buffer + 18;

		// store BGRA palette of 256 RGB colors
		for (c = 0;c < 256;c++)
		{
			*out++ = palettergb[c*3+2];
			*out++ = palettergb[c*3+1];
			*out++ = palettergb[c*3+0];
		}

		// copy image
		for (y = 0;y < height;y++)
		{
			in = data + (height - 1 - y) * width;
			end = in + width;
			while (in < end)
			{
				maxrun = end - in;
				if (maxrun > 128)
					maxrun = 128;
				if (maxrun >= 2 && in[1] == in[0])
				{
					// run a loop that stops when the next byte is not the same
					for (run = 1;run < maxrun && in[run] == in[0];run++);
					*out++ = 0x80 + (run - 1);
					*out++ = in[0];
					in += run;
				}
				else
				{
					// run a loop that stops when the next two bytes are the same
					for (run = 1;run < maxrun && (run >= maxrun - 1 || in[run+1] != in[run]);run++);
					*out++ = 0x00 + (run - 1);
					for (c = 0;c < run;c++)
						*out++ = *in++;
				}
			}
		}
#endif
	}

	writefile(filename, buffer, out - buffer);

	free(buffer);
}


unsigned char quakepalette[768] =
{
	0x00,0x00,0x00,0x0F,0x0F,0x0F,0x1F,0x1F,0x1F,0x2F,0x2F,0x2F,0x3F,0x3F,0x3F,0x4B,
	0x4B,0x4B,0x5B,0x5B,0x5B,0x6B,0x6B,0x6B,0x7B,0x7B,0x7B,0x8B,0x8B,0x8B,0x9B,0x9B,
	0x9B,0xAB,0xAB,0xAB,0xBB,0xBB,0xBB,0xCB,0xCB,0xCB,0xDB,0xDB,0xDB,0xEB,0xEB,0xEB,
	0x0F,0x0B,0x07,0x17,0x0F,0x0B,0x1F,0x17,0x0B,0x27,0x1B,0x0F,0x2F,0x23,0x13,0x37,
	0x2B,0x17,0x3F,0x2F,0x17,0x4B,0x37,0x1B,0x53,0x3B,0x1B,0x5B,0x43,0x1F,0x63,0x4B,
	0x1F,0x6B,0x53,0x1F,0x73,0x57,0x1F,0x7B,0x5F,0x23,0x83,0x67,0x23,0x8F,0x6F,0x23,
	0x0B,0x0B,0x0F,0x13,0x13,0x1B,0x1B,0x1B,0x27,0x27,0x27,0x33,0x2F,0x2F,0x3F,0x37,
	0x37,0x4B,0x3F,0x3F,0x57,0x47,0x47,0x67,0x4F,0x4F,0x73,0x5B,0x5B,0x7F,0x63,0x63,
	0x8B,0x6B,0x6B,0x97,0x73,0x73,0xA3,0x7B,0x7B,0xAF,0x83,0x83,0xBB,0x8B,0x8B,0xCB,
	0x00,0x00,0x00,0x07,0x07,0x00,0x0B,0x0B,0x00,0x13,0x13,0x00,0x1B,0x1B,0x00,0x23,
	0x23,0x00,0x2B,0x2B,0x07,0x2F,0x2F,0x07,0x37,0x37,0x07,0x3F,0x3F,0x07,0x47,0x47,
	0x07,0x4B,0x4B,0x0B,0x53,0x53,0x0B,0x5B,0x5B,0x0B,0x63,0x63,0x0B,0x6B,0x6B,0x0F,
	0x07,0x00,0x00,0x0F,0x00,0x00,0x17,0x00,0x00,0x1F,0x00,0x00,0x27,0x00,0x00,0x2F,
	0x00,0x00,0x37,0x00,0x00,0x3F,0x00,0x00,0x47,0x00,0x00,0x4F,0x00,0x00,0x57,0x00,
	0x00,0x5F,0x00,0x00,0x67,0x00,0x00,0x6F,0x00,0x00,0x77,0x00,0x00,0x7F,0x00,0x00,
	0x13,0x13,0x00,0x1B,0x1B,0x00,0x23,0x23,0x00,0x2F,0x2B,0x00,0x37,0x2F,0x00,0x43,
	0x37,0x00,0x4B,0x3B,0x07,0x57,0x43,0x07,0x5F,0x47,0x07,0x6B,0x4B,0x0B,0x77,0x53,
	0x0F,0x83,0x57,0x13,0x8B,0x5B,0x13,0x97,0x5F,0x1B,0xA3,0x63,0x1F,0xAF,0x67,0x23,
	0x23,0x13,0x07,0x2F,0x17,0x0B,0x3B,0x1F,0x0F,0x4B,0x23,0x13,0x57,0x2B,0x17,0x63,
	0x2F,0x1F,0x73,0x37,0x23,0x7F,0x3B,0x2B,0x8F,0x43,0x33,0x9F,0x4F,0x33,0xAF,0x63,
	0x2F,0xBF,0x77,0x2F,0xCF,0x8F,0x2B,0xDF,0xAB,0x27,0xEF,0xCB,0x1F,0xFF,0xF3,0x1B,
	0x0B,0x07,0x00,0x1B,0x13,0x00,0x2B,0x23,0x0F,0x37,0x2B,0x13,0x47,0x33,0x1B,0x53,
	0x37,0x23,0x63,0x3F,0x2B,0x6F,0x47,0x33,0x7F,0x53,0x3F,0x8B,0x5F,0x47,0x9B,0x6B,
	0x53,0xA7,0x7B,0x5F,0xB7,0x87,0x6B,0xC3,0x93,0x7B,0xD3,0xA3,0x8B,0xE3,0xB3,0x97,
	0xAB,0x8B,0xA3,0x9F,0x7F,0x97,0x93,0x73,0x87,0x8B,0x67,0x7B,0x7F,0x5B,0x6F,0x77,
	0x53,0x63,0x6B,0x4B,0x57,0x5F,0x3F,0x4B,0x57,0x37,0x43,0x4B,0x2F,0x37,0x43,0x27,
	0x2F,0x37,0x1F,0x23,0x2B,0x17,0x1B,0x23,0x13,0x13,0x17,0x0B,0x0B,0x0F,0x07,0x07,
	0xBB,0x73,0x9F,0xAF,0x6B,0x8F,0xA3,0x5F,0x83,0x97,0x57,0x77,0x8B,0x4F,0x6B,0x7F,
	0x4B,0x5F,0x73,0x43,0x53,0x6B,0x3B,0x4B,0x5F,0x33,0x3F,0x53,0x2B,0x37,0x47,0x23,
	0x2B,0x3B,0x1F,0x23,0x2F,0x17,0x1B,0x23,0x13,0x13,0x17,0x0B,0x0B,0x0F,0x07,0x07,
	0xDB,0xC3,0xBB,0xCB,0xB3,0xA7,0xBF,0xA3,0x9B,0xAF,0x97,0x8B,0xA3,0x87,0x7B,0x97,
	0x7B,0x6F,0x87,0x6F,0x5F,0x7B,0x63,0x53,0x6B,0x57,0x47,0x5F,0x4B,0x3B,0x53,0x3F,
	0x33,0x43,0x33,0x27,0x37,0x2B,0x1F,0x27,0x1F,0x17,0x1B,0x13,0x0F,0x0F,0x0B,0x07,
	0x6F,0x83,0x7B,0x67,0x7B,0x6F,0x5F,0x73,0x67,0x57,0x6B,0x5F,0x4F,0x63,0x57,0x47,
	0x5B,0x4F,0x3F,0x53,0x47,0x37,0x4B,0x3F,0x2F,0x43,0x37,0x2B,0x3B,0x2F,0x23,0x33,
	0x27,0x1F,0x2B,0x1F,0x17,0x23,0x17,0x0F,0x1B,0x13,0x0B,0x13,0x0B,0x07,0x0B,0x07,
	0xFF,0xF3,0x1B,0xEF,0xDF,0x17,0xDB,0xCB,0x13,0xCB,0xB7,0x0F,0xBB,0xA7,0x0F,0xAB,
	0x97,0x0B,0x9B,0x83,0x07,0x8B,0x73,0x07,0x7B,0x63,0x07,0x6B,0x53,0x00,0x5B,0x47,
	0x00,0x4B,0x37,0x00,0x3B,0x2B,0x00,0x2B,0x1F,0x00,0x1B,0x0F,0x00,0x0B,0x07,0x00,
	0x00,0x00,0xFF,0x0B,0x0B,0xEF,0x13,0x13,0xDF,0x1B,0x1B,0xCF,0x23,0x23,0xBF,0x2B,
	0x2B,0xAF,0x2F,0x2F,0x9F,0x2F,0x2F,0x8F,0x2F,0x2F,0x7F,0x2F,0x2F,0x6F,0x2F,0x2F,
	0x5F,0x2B,0x2B,0x4F,0x23,0x23,0x3F,0x1B,0x1B,0x2F,0x13,0x13,0x1F,0x0B,0x0B,0x0F,
	0x2B,0x00,0x00,0x3B,0x00,0x00,0x4B,0x07,0x00,0x5F,0x07,0x00,0x6F,0x0F,0x00,0x7F,
	0x17,0x07,0x93,0x1F,0x07,0xA3,0x27,0x0B,0xB7,0x33,0x0F,0xC3,0x4B,0x1B,0xCF,0x63,
	0x2B,0xDB,0x7F,0x3B,0xE3,0x97,0x4F,0xE7,0xAB,0x5F,0xEF,0xBF,0x77,0xF7,0xD3,0x8B,
	0xA7,0x7B,0x3B,0xB7,0x9B,0x37,0xC7,0xC3,0x37,0xE7,0xE3,0x57,0x7F,0xBF,0xFF,0xAB,
	0xE7,0xFF,0xD7,0xFF,0xFF,0x67,0x00,0x00,0x8B,0x00,0x00,0xB3,0x00,0x00,0xD7,0x00,
	0x00,0xFF,0x00,0x00,0xFF,0xF3,0x93,0xFF,0xF7,0xC7,0xFF,0xFF,0xFF,0x9F,0x5B,0x53
};

/*
=============
LoadLMP
=============
*/
unsigned char* LoadLMP (char *filename)
{
	int lmpsize;
	unsigned char *data;
	void *lmpdata;
	if (readfile(filename, &lmpdata, &lmpsize))
	{
		printf("LoadLMP: unable to load \"%s\"\n", filename);
		return NULL;
	}
	image_width = LittleLong(((int *)lmpdata)[0]);
	image_height = LittleLong(((int *)lmpdata)[1]);
	if (image_width < 0 || image_height < 0 || image_width > 512 || image_height > 512)
	{
		free(lmpdata);
		printf("LoadLMP: \"%s\" is not an LMP file\n", filename);
		return NULL;
	}
	data = malloc(image_width*image_height);
	if (!data)
	{
		free(lmpdata);
		printf("LoadLMP: unable to allocate memory for \"%s\"\n", filename);
		return NULL;
	}
	memcpy(data, (unsigned char *)lmpdata + 8, image_width*image_height);
	free(lmpdata);
	return data;
}

void ConvertLMP(char *filename)
{
	unsigned char *data;
	char tempname[4096];
	data = LoadLMP(filename);
	if (!data)
		return;
	StripExtension(filename, tempname);
	strcat(tempname, ".pcx");
	WritePCX(tempname, data, image_width, image_height, quakepalette);
	StripExtension(filename, tempname);
	strcat(tempname, ".tga");
	WriteTGA(tempname, data, image_width, image_height, quakepalette);
	free(data);
}

/*
=============
LoadMIP
=============
*/
unsigned char* LoadMIP (char *filename)
{
	int mipsize;
	unsigned char *data;
	void *mipdata;
	if (readfile(filename, &mipdata, &mipsize))
	{
		printf("LoadMIP: unable to load \"%s\"\n", filename);
		return NULL;
	}
	image_width = LittleLong(((int *)mipdata)[4]);
	image_height = LittleLong(((int *)mipdata)[5]);
	if (image_width < 0 || image_height < 0 || image_width > 512 || image_height > 512)
	{
		free(mipdata);
		printf("LoadMIP: \"%s\" is not an MIP file\n", filename);
		return NULL;
	}
	data = malloc(image_width*image_height);
	if (!data)
	{
		free(mipdata);
		printf("LoadMIP: unable to allocate memory for \"%s\"\n", filename);
		return NULL;
	}
	memcpy(data, (unsigned char *)mipdata + 40, image_width*image_height);
	free(mipdata);
	return data;
}

void ConvertMIP(char *filename)
{
	unsigned char *data;
	char tempname[4096];
	data = LoadMIP(filename);
	if (!data)
		return;
	StripExtension(filename, tempname);
	strcat(tempname, ".pcx");
	WritePCX(tempname, data, image_width, image_height, quakepalette);
	StripExtension(filename, tempname);
	strcat(tempname, ".tga");
	WriteTGA(tempname, data, image_width, image_height, quakepalette);
	free(data);
}

#define	CMP_NONE		0

#define	TYP_NONE		0
#define	TYP_LABEL		1

#define	TYP_LUMPY		64				// 64 + grab command number
#define	TYP_PALETTE		64
#define	TYP_QTEX		65
#define	TYP_QPIC		66
#define	TYP_SOUND		67
#define	TYP_MIPTEX		68

typedef struct
{
	int			width, height;
	unsigned char		data[4];			// variably sized
}
qpic_t;

typedef struct
{
	char		identification[4];		// should be WAD2 or 2DAW
	int			numlumps;
	int			infotableofs;
}
wadinfo_t;

typedef struct
{
	int			filepos;
	int			disksize;
	int			size;					// uncompressed
	char		type;
	char		compression;
	char		pad1, pad2;
	char		name[16];				// must be null terminated
}
lumpinfo_t;

void wad_cleanname(char *in, char *out)
{
	int i, c;
	for (i = 0;i < 16 && *in;i++)
	{
		c = *in++;
		if (c >= 'A' && c <= 'Z')
			c += 'a' - 'A';
		*out++ = c;
	}
	for (;i < 17;i++)
		*out++ = 0;
}

void ConvertWAD(char *filename)
{
	char tempname[4096];
	int wadsize, size, numlumps, i, width, height;
	void *waddata;
	unsigned char *data;
	wadinfo_t *wad;
	lumpinfo_t *lump;
	if (readfile(filename, &waddata, &wadsize))
	{
		printf("ConvertWAD: could not load \"%s\"\n", filename);
		return;
	}
	wad = (void *)waddata;
	if (memcmp(wad->identification, "WAD2", 4))
	{
		printf("ConvertWAD: \"%s\" is not a quake wad2 file\n", filename);
		return;
	}
	numlumps = LittleLong(wad->numlumps);
	printf("ConvertWAD: converting \"%s\" (%i lumps)\n", filename, numlumps);
	lump = (void *)((int) waddata + wad->infotableofs);
	for (i = 0;i < numlumps;i++, lump++)
	{
		if (lump->compression != CMP_NONE)
		{
			printf("lump \"%s\" is compressed, compression is unsupported\n", lump->name);
			continue;
		}
		data = lump->filepos + (unsigned char *) waddata;
		size = lump->disksize;
		wad_cleanname(lump->name, tempname);
		// conchars = weird
		if (!strcmp(tempname, "conchars"))
		{
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".bin");
			writefile(tempname, data, size);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".pcx");
			WritePCX(tempname, data, 128, 128, quakepalette);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".tga");
			WriteTGA(tempname, data, 128, 128, quakepalette);
			continue;
		}
		switch(lump->type)
		{
		case TYP_NONE:
			printf("encountered lump type 'NONE' named \"%s\"\n", lump->name);
			break;
		case TYP_LABEL:
			printf("encountered lump type 'LABEL' named \"%s\"\n", lump->name);
			break;
		case TYP_LUMPY:
//			printf("encountered lump type 'LUMPY' named \"%s\"\n", lump->name);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".bin");
			writefile(tempname, data, size);
			break;
		case TYP_QTEX:
			printf("encountered lump type 'QTEX' named \"%s\"\n", lump->name);
			break;
		case TYP_QPIC:
//			printf("encountered lump type 'QPIC' named \"%s\"\n", lump->name);
			width = LittleLong(((int *)data)[0]);
			height = LittleLong(((int *)data)[1]);
			if (width < 0 || height < 0 || width > 512 || height > 512)
			{
				printf("\"%s\" is not a valid qpic\n", lump->name);
				continue;
			}
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".lmp");
			writefile(tempname, data, size);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".pcx");
			WritePCX(tempname, data+8, width, height, quakepalette);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".tga");
			WriteTGA(tempname, data+8, width, height, quakepalette);
			break;
		case TYP_SOUND:
			printf("encountered lump type 'SOUND' named \"%s\"\n", lump->name);
			break;
		case TYP_MIPTEX:
//			printf("encountered lump type 'MIPTEX' named \"%s\"\n", lump->name);
			width = LittleLong(((int *)data)[4]);
			height = LittleLong(((int *)data)[5]);
			if (width < 0 || height < 0 || width > 512 || height > 512)
			{
				printf("\"%s\" is not a valid miptex\n", lump->name);
				continue;
			}
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".mip");
			writefile(tempname, data, size);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".pcx");
			WritePCX(tempname, data+40, width, height, quakepalette);
			wad_cleanname(lump->name, tempname);
			strcat(tempname, ".tga");
			WriteTGA(tempname, data+40, width, height, quakepalette);
			break;
		default:
			printf("encountered unknown lump type named \"%s\"\n", lump->name);
			break;
		}
	}
	free(waddata);
}

void lmp2pcx()
{
	stringlist *s, *slstart;
	// get the directory listing
	slstart = s = listdirectory(".");
	// iterate through the string chain
	while (s)
	{
		if (matchpattern(s->text, "*.lmp"))
			ConvertLMP(s->text);
		if (matchpattern(s->text, "*.mip"))
			ConvertMIP(s->text);
		if (matchpattern(s->text, "*.wad"))
			ConvertWAD(s->text);
		s = s->next;
	}
	// free the string chain
	stringlistfree(slstart);
}

int main(int argc, char **argv)
{
	if (argc != 1)
		Error("lmp2pcx v1.02 by Forest \"LordHavoc\" Hale\nconverts all .lmp and .wad files in current directory to pcx files and tga files\nno commandline options\n");
	SwapDetect();
	lmp2pcx();
#if _DEBUG && WIN32
	printf ("press a key\n");
	getchar();
#endif
	return 0;
}
