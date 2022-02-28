/*
mkwad - copyright Alexander Malmberg <alexander@malmberg.org>

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
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <fnmatch.h>


typedef struct
{
   unsigned char id[4];
   unsigned int num;
   unsigned int ofs;
} wad_header_t;

typedef struct
{
   unsigned int pos;
   unsigned int dsize;
   unsigned int size;
   unsigned char type;
   unsigned char compr;
   unsigned char pad[2];
   char name[16];
} wad_entry_t;


static wad_header_t h;
#define MAX_ENTRIES 1024
/* A normal gfx.wad has around 100-150 entries, so this should be safe */
static wad_entry_t l[MAX_ENTRIES];


static FILE *G_f;
static char G_fname[512],G_lname[512];
static unsigned int G_type;

static void IGetNames(void)
{
   G_f=fopen("mkwad.txt","rt");
   if (!G_f)
   {
      perror("mkwad.txt");
      exit(1);
   }
}

static int GetName(void)
{
   return fscanf(G_f,"%s %s %i",G_fname,G_lname,&G_type)==3;
}

static void DGetNames(void)
{
   fclose(G_f);
}

static void CreateWAD(const char *wname)
{
   FILE *f;
   FILE *f2;
   unsigned char *buf;
   int size;

   f=fopen(wname,"wb");
   if (!f)
   {
      perror(wname);
      exit(1);
   }

   strncpy(h.id,"WAD2",4);
   h.num=0;
   h.ofs=sizeof(h);
   fwrite(&h,1,sizeof(h),f);

   IGetNames();
   while (GetName())
   {

      f2=fopen(G_fname,"rb");
      if (!f2)
      {
         perror(G_fname);
         exit(1);
      }
      fseek(f2,0,SEEK_END);
      size=ftell(f2);
      fseek(f2,0,SEEK_SET);
      buf=malloc(size);
      if (!buf)
      {
         fprintf(stderr,"malloc failed\n");
         exit(1);
      }
      fread(buf,1,size,f2);
      fclose(f2);
      fwrite(buf,1,size,f);

      strcpy(l[h.num].name,G_lname);
      l[h.num].pos=h.ofs;
      l[h.num].size=l[h.num].dsize=size;
      l[h.num].type=G_type;
      h.num++;
      if (h.num==MAX_ENTRIES)
      {
         fprintf(stderr,"too many entries, increase MAX_ENTRIES\n");
         exit(1);
      }
      h.ofs+=size;

      printf("%02x %10i %16s %s\n",G_type,size,G_lname,G_fname);
   }
   if (!feof(G_f))
   {
      fprintf(stderr,"Parse error in mkwad.txt\n");
      exit(1);
   }
   DGetNames();

   fwrite(l,1,h.num*sizeof(wad_entry_t),f);
   fseek(f,0,SEEK_SET);
   fwrite(&h,1,sizeof(h),f);

   fclose(f);
}


int main(int argc, char **argv)
{
   if (argc<2)
   {
      fprintf(stderr,
         "%s w foo.wad\n"
         "   Creates foo.wad from list of files in mkwad.txt\n"
         "\n"
         "%s r foo.wad wildcard [extract]\n"
         "   Reads foo.wad, prints information about entries matching wildcard. If\n"
         "   there is a fifth argument, extracts matching entries.\n"
         ,argv[0],argv[0]);
      return 1;
   }

   if (!strcmp(argv[1],"w"))
   {
      CreateWAD(argv[2]);
   }
   else
   if (!strcmp(argv[1],"r"))
   {
      FILE *f;
      int i;
      wad_entry_t *e;

      f=fopen(argv[2],"rb");
      if (!f)
      {
         perror(argv[2]);
         exit(1);
      }

      fread(&h,1,sizeof(wad_header_t),f);
      if (h.num>MAX_ENTRIES)
      {
         fprintf(stderr,"Too many entries, increase MAX_ENTRIES\n");
         exit(1);
      }

      fseek(f,h.ofs,SEEK_SET);
      fread(l,1,sizeof(wad_entry_t)*h.num,f);

      for (i=0,e=l;i<h.num;i++,e++)
      {
         if (fnmatch(argv[3],e->name,0)) continue;
         printf("%8i %8i %02x %i %s\n",
            e->pos,e->size,e->type,e->compr,e->name);
         if (argc==5)
         {
            FILE *f2;
            char fname[32];
            unsigned char *buf;

            strcpy(fname,e->name);
            strcat(fname,".wlmp");
            f2=fopen(fname,"wb");
            if (!f2)
            {
               perror(fname);
               exit(1);
            }

            buf=malloc(e->size);
            if (!buf)
            {
               fprintf(stderr,"malloc failed\n");
               exit(1);
            }

            fseek(f,e->pos,SEEK_SET);
            fread(buf,1,e->size,f);
            fwrite(buf,1,e->size,f2);
            free(buf);

            fclose(f2);
         }
      }

      fclose(f);
   }
   else
   {
      fprintf(stderr,"Invalid arguments!\n");
   }

   return 0;
}

