/*
lmp2pcx - copyright Alexander Malmberg <alexander@malmberg.org>
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>


#include "pcx.h"

#include "pal.h"

static int ix,iy;
static unsigned char *image;


static void SavePCX(const char *filename)
{
   FILE *fp;
   int i, j;
   PCXHeader PCXHead;

   fp = fopen(filename, "wb");
   if (!fp)
   {
      perror(filename);
      exit(1);
   }

   memset(&PCXHead,0,sizeof(PCXHead));

   PCXHead.id=10;
   PCXHead.version=5;
   PCXHead.encoding=1;
   PCXHead.bpp=8;

   PCXHead.xmin=PCXHead.ymin=0;
   PCXHead.xmax=ix-1;
   PCXHead.ymax=iy-1;

   PCXHead.hres=0x9600;
   PCXHead.vres=0x9600;

   PCXHead.nplanes=1;
   PCXHead.bpl=ix;
   PCXHead.palinfo=2;

   if (fwrite(&PCXHead,1,sizeof(PCXHead),fp)!=sizeof(PCXHead))
   {
      perror(filename);
      fclose(fp);
      exit(1);
   }

   for (i=0; i<iy; i++)
   {
      unsigned char *buf;
      int last,num;

      buf=&image[i*ix];
      last=*buf++;
      num=1;
      for (j=1;j<ix;j++,buf++)
      {
         if (last==*buf)
         {
            num++;
            if (num==63)
            {
               fputc(0xC0|num,fp);
               fputc(last,fp);
               num=0;
            }
         }
         else
         {
            if (num)
            {
               if ((num==1) && ((last & 0xC0)!=0xC0))
               {
                  fputc(last,fp);
               }
               else
               {
                  fputc(0xC0|num,fp);
                  fputc(last,fp);
               }
               num=0;
            }
            last=*buf;
            num=1;
         }
      }
      if (num)
      {
         if ((num==1) && ((last & 0xc0)!=0xC0))
         {
            fputc(last,fp);
         }
         else
         {
            fputc(0xC0|num,fp);
            fputc(last,fp);
         }
         num=0;
      }
   }

   fputc(12, fp);

   fwrite(default_pal,1,768,fp);

   fclose(fp);
}

int main(int argc, char **argv)
{
   if (argc!=3)
   {
      fprintf(stderr,
         "%s foo.lmp bar.pcx\n"
         "   Converts foo.lmp to bar.pcx . foo.pcx will be a normal 8-bit\n"
         "   pcx file with the right palette.\n"
         ,argv[0]);
      exit(1);
   }

   {
      FILE *f;
      f=fopen(argv[1],"rb");
      if (!f)
      {
         perror(argv[1]);
         exit(1);
      }
      fread(&ix,1,4,f);
      fread(&iy,1,4,f);
      image=malloc(ix*iy);
      if (!image)
      {
         fprintf(stderr,"malloc failed\n");
         exit(1);
      }
      fread(image,1,ix*iy,f);
      fclose(f);
   }

   SavePCX(argv[2]);

   printf("%s -> %s %ix%i done.\n",argv[1],argv[2],ix,iy);

   return 0;
}

