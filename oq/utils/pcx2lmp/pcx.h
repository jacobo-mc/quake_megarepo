#ifndef PCX_H
#define PCX_H

typedef struct
{
   char  id;
   char  version;
   char  encoding;
   char  bpp;
   short xmin;
   short ymin;
   short xmax;
   short ymax;
   short hres;
   short vres;
   char  pal[48];
   char  reserved;
   char  nplanes;
   short bpl;
   short palinfo;
   char  filler[58];
} PCXHeader /*__attribute__ ((packed))*/;

#endif

