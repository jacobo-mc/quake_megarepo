/*
pcx2lmp - copyright Alexander Malmberg <alexander@malmberg.org>
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>


#include "pcx.h"

static unsigned char *image;
static int ix,iy;


static void LoadPCX(const char *filename)
{
   FILE *fp;
   int i, j, k;
   PCXHeader PCXHead;
   unsigned char *d;

   fp = fopen(filename, "rb");

   if (!fp)
   {
      perror(filename);
      exit(1);
   }

   if (fread(&PCXHead,1,sizeof(PCXHead),fp)!=sizeof(PCXHead))
   {
      perror(filename);
      fclose(fp);
      exit(1);
   }

   ix=PCXHead.xmax-PCXHead.xmin+1;
   iy=PCXHead.ymax-PCXHead.ymin+1;

   image=malloc(ix*iy);
   if (!image)
   {
      fprintf(stderr,"malloc failed\n");
      exit(1);
   }

   for (i=ix*iy,d=image;i;)
   {
      j=fgetc(fp);
      if ((j&0xc0)==0xc0)
      {
         j-=0xc0;
         k=fgetc(fp);
         i-=j;
         for (;j;j--)
            *d++=k;
      }
      else
         *d++=j,i--;
   }

   fclose(fp);
}


int main(int argc, char **argv)
{
   if (argc!=3)
   {
      fprintf(stderr,
         "%s foo.pcx bar.lmp\n"
         "   Converts foo.pcx to bar.lmp . foo.pcx had better be a normal 8-bit\n"
         "   pcx file with the right palette.\n"
         ,argv[0]);
      exit(1);
   }

   LoadPCX(argv[1]);
   {
      FILE *f;

      f=fopen(argv[2],"wb");
      if (!f)
      {
         perror(argv[2]);
         exit(1);
      }
      fwrite(&ix,1,4,f);
      fwrite(&iy,1,4,f);
      fwrite(image,1,ix*iy,f);
      fclose(f);
   }
   printf("%3ix%3i done.\n",ix,iy);

   return 0;
}

