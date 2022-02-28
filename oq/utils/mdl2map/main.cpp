// mdl Quake to sprite3d CrystalSpace

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mdl.h"

bool WriteMAP(char *spritename, Mdl mdl, float scaleMdl, float gridSnap,
  float positionMdlX, float positionMdlY, float positionMdlZ);

int main(int ac, char ** av)
{
  float scaleMdl = 16.0f;
  float gridSnap = 0.0f;
  float positionMdlX = 0.0;
  float positionMdlY = 0.0;
  float positionMdlZ = 0.0;

  bool help = false;

  fprintf(stdout, "mdl2map\n");
  fprintf(stdout, "\tGenerates Quake .MAP format terrain from Quake .MDLs\n");
  fprintf(stdout, "\tbased on mdl2spr version 0.31\n");
  fprintf(stdout, "\tA quake model convertor for CrystalSpace.\n");
  fprintf(stdout, "\tby NooTe (noote@bigfoot.com)\n\n");
  fprintf(stdout, "\tmodified by Seth Galbraith (sgalbrai@krl.org)\n");

  if(ac>3)
  {
    for(int i=1; i<ac-2; i++)
    {
      if(av[i][0]!='-' && av[i][0]!='/')
      {
        fprintf(stderr, "'%s' unreconized option\n", av[i]);
        help=true;
        break;
      }
      switch(av[i][1])
      {
      case 'h':
      case '?':
        {
          help = true;
        }
        break;

      case 'g':
        {
          float temp = atof(av[i+1]);
          if(temp==0.0)
          {
            fprintf(stderr, "cannot convert %s to a valid float !\n", av[i+1]);
            help = true;
          }
          else
          {
            gridSnap = temp;
            i++;
            fprintf(stdout, "set grid snap to %.3f.\n", gridSnap);
          }
        }
        break;

      case 's':
        {
          float temp = atof(av[i+1]);
          if(temp==0.0)
          {
            fprintf(stderr, "cannot convert %s to a valid float !\n", av[i+1]);
            help = true;
          }
          else
          {
            scaleMdl = temp;
            i++;
            fprintf(stdout, "set to %.3f general scale.\n", scaleMdl);
          }
        }
        break;

      case 'x':
        {
          float temp = atof(av[i+1]);
          if(temp==0.0)
          {
            fprintf(stderr, "cannot convert %s to a valid float !\n", av[i+1]);
            help = true;
          }
          else
          {
            positionMdlX = temp;
            i++;
            fprintf(stdout, "set to %.3f moving X axe position.\n", positionMdlX);
          }
        }
        break;

      case 'y':
        {
          float temp = atof(av[i+1]);
          if(temp==0.0)
          {
            fprintf(stderr, "cannot convert %s to a valid float !\n", av[i+1]);
            help = true;
          }
          else
          {
            positionMdlY = temp;
            i++;
            fprintf(stdout, "set to %.3f moving Y axe position.\n", positionMdlY);
          }
        }
        break;

      case 'z':
        {
          float temp = atof(av[i+1]);
          if(temp==0.0)
          {
            fprintf(stderr, "cannot convert %s to a valid float !\n", av[i+1]);
            help = true;
          }
          else
          {
            positionMdlZ = temp;
            i++;
            fprintf(stdout, "set to %.3f moving Z axe position.\n", positionMdlZ);
          }
        }
        break;

      default:
        {
          fprintf(stderr, "'%s' unreconized option !\n", av[i]);
          help=true;
        }
        break;
      }

      if(help) break;
    }
  }
  else if (ac<3) help = true;

  if(help)
  {
    fprintf(stdout, "\nmdl2map <option> [mdl file] [map name]\n");
    fprintf(stdout, "\toptions :\n");
    fprintf(stdout, "\t\t-h : help (this page)\n");
    fprintf(stdout, "\t\t-s [float] : global scale of mdl (default %.3f)\n", scaleMdl);
    fprintf(stdout, "\t\t-g [float] : grid snap (default %.3f)\n", gridSnap);
    fprintf(stdout, "\t\t-x [float] : sprite moving on X axis (default %.3f)\n", positionMdlX);
    fprintf(stdout, "\t\t-y [float] : sprite moving on Y axis (default %.3f)\n", positionMdlY);
    fprintf(stdout, "\t\t-z [float] : sprite moving on Z axis (default %.3f)\n", positionMdlZ);
    return -1;
  }

  Mdl mdl(av[ac-2]);
  
  if(mdl.getError())
  {
    fprintf(stderr, "\nerror : %s !\n", mdl.getErrorString());
    exit(-1);
  }
  
  fprintf(stdout, "\nQuake Model %s has :\n", av[ac-1]);
  fprintf(stdout, "\t %d Triangle%s\n", mdl.nbtriangles, (mdl.nbtriangles>1)?"s":"");
  fprintf(stdout, "\t %d Vertice%s\n\n", mdl.nbvertices, (mdl.nbvertices>1)?"s":"");
  
  WriteMAP(av[ac-1], mdl, scaleMdl, gridSnap, positionMdlX, positionMdlY, positionMdlZ);

  return 1;
}
