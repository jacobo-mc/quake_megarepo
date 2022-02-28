/*
  Crystal Space QuakeMDL convertor : spr writer
  Copyright (C) 1998 by Jorrit Tyberghein
  Written by Nathaniel Saint Martin aka NooTe <noote@bigfoot.com>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#include "mdl.h"

bool WriteMAP(char *spritename, Mdl mdl, float scaleMdl, float gridSnap,
  float positionMdlX, float positionMdlY, float positionMdlZ)
{
  FILE *f;
  char *spritefilename;
  Mdl spr;
  int i = 0, j = 0, k = 0, v = 0, vertex = 0;

  if(spritename==NULL || strlen(spritename)==0)
  {
    fprintf(stderr, "void file name\n");
    return false;
  }

  spritefilename = new char [strlen(spritename)+5];
  strcpy(spritefilename, spritename);

  if((f=fopen(spritefilename, "w"))==NULL)
  {
    fprintf(stderr, "Cannot open file %s !\n", spritename);
    return false;
  }

  // begin hard work now

  fprintf(stdout, "Generate MDL/SPR vertex correspondence\n");

  // count back seam vertices
  long back_seam_verts = 0;
  long * BS_verts = new long [mdl.nbvertices];
  bool * verts    = new bool [mdl.nbvertices];
  memset (verts, false, mdl.nbvertices * sizeof(bool));

  // detect which vertices are back seam vertices
  for (i=0; i<mdl.nbtriangles; i++)
    if (!mdl.triangles[i].facefront)
      for (j=0; j<3; j++)
      {
        vertex = mdl.triangles[i].vertice[j];
        if (mdl.vertices[vertex].onseam) verts[vertex] = true;
      }

  // assign a new, unique vertex number to each back skin vertex
  for (i=0; i<mdl.nbvertices; i++)
    if (verts[i])
    {
      BS_verts[i] = mdl.nbvertices + back_seam_verts;
      back_seam_verts++;
    }

  fprintf(stdout, "\t%ld back seam vertices detected\n", back_seam_verts);

  // create sprite skin vertices
  spr.triangles = new triangle_t [mdl.nbtriangles];
  spr.vertices  = new vertice_t  [mdl.nbvertices+back_seam_verts];
  memset(spr.triangles, 0, mdl.nbtriangles*sizeof(triangle_t));
  memset(spr.vertices,  0, mdl.nbvertices*2*sizeof(vertice_t));

  // find corresponding mdl skin vertices
  for(i=0; i<mdl.nbtriangles; i++)
    for(j=0; j<3; j++)
    {
      vertex = mdl.triangles[i].vertice[j];

      // copy mdl vertices to sprite
      spr.vertices[vertex].s = mdl.vertices[vertex].s;
      spr.vertices[vertex].t = mdl.vertices[vertex].t;
      spr.triangles[i].vertice[j] = vertex;

      // create a duplicate vertex for back seam triangles
      if( (mdl.vertices[vertex].onseam) && (!mdl.triangles[i].facefront))
      {
        spr.vertices[BS_verts[vertex]].s = mdl.vertices[vertex].s + (mdl.skinwidth / 2);
        spr.vertices[BS_verts[vertex]].t = mdl.vertices[vertex].t;
        spr.triangles[i].vertice[j] = BS_verts[vertex];
      }
    }

  // create sprite frameset
  spr.framesets = new frameset_t [mdl.nbframesets];
  for (i=0; i<mdl.nbframesets; i++)
  {
    spr.framesets[i].nbframes = mdl.framesets[i].nbframes;
    spr.framesets[i].frames = new frame_t [spr.framesets[i].nbframes];
    for (j=0; j<mdl.framesets[i].nbframes; j++)
      spr.framesets[i].frames[j].trivert = new trivertx_t [mdl.nbvertices+back_seam_verts];
  }

  // copy corresponding mdl framesets
  for (i=0; i<mdl.nbframesets; i++)
    for (j=0; j<mdl.framesets[i].nbframes; j++)
      for (k=0; k<mdl.nbtriangles; k++)
        for (v=0; v<3; v++)
        {
          long SPR_vertex = spr.triangles[k].vertice[v];
          long MDL_vertex = mdl.triangles[k].vertice[v];

          spr.framesets[i].frames[j].trivert[SPR_vertex].packedposition[0]=
          mdl.framesets[i].frames[j].trivert[MDL_vertex].packedposition[0];
          spr.framesets[i].frames[j].trivert[SPR_vertex].packedposition[1]=
          mdl.framesets[i].frames[j].trivert[MDL_vertex].packedposition[1];
          spr.framesets[i].frames[j].trivert[SPR_vertex].packedposition[2]=
          mdl.framesets[i].frames[j].trivert[MDL_vertex].packedposition[2];
        }

  fprintf(stdout, "\nWriting .map file\n");

  fprintf(f, "{\n");
  fprintf(f, " \"classname\" \"worldspawn\"\n");
  fprintf(f, " \"message\" \"No Name\"\n");
  fprintf(f, " \"worldtype\" \"0\"\n");

  for(i=0; i<mdl.nbtriangles; i++)
  {
    float ax = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[0]].packedposition[0];
    float ay = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[0]].packedposition[1];
    float az = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[0]].packedposition[2];
    float bx = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[1]].packedposition[0];
    float by = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[1]].packedposition[1];
    float bz = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[1]].packedposition[2];
    float cx = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[2]].packedposition[0];
    float cy = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[2]].packedposition[1];
    float cz = (float) spr.framesets[0].frames[0].trivert[spr.triangles[i].vertice[2]].packedposition[2];
    
    ax = ((ax * mdl.scaleX) + mdl.originX) * scaleMdl + positionMdlX;
    ay = ((ay * mdl.scaleY) + mdl.originY) * scaleMdl + positionMdlY;
    az = ((az * mdl.scaleZ) + mdl.originZ) * scaleMdl + positionMdlZ;
    bx = ((bx * mdl.scaleX) + mdl.originX) * scaleMdl + positionMdlX;
    by = ((by * mdl.scaleY) + mdl.originY) * scaleMdl + positionMdlY;
    bz = ((bz * mdl.scaleZ) + mdl.originZ) * scaleMdl + positionMdlZ;
    cx = ((cx * mdl.scaleX) + mdl.originX) * scaleMdl + positionMdlX;
    cy = ((cy * mdl.scaleY) + mdl.originY) * scaleMdl + positionMdlY;
    cz = ((cz * mdl.scaleZ) + mdl.originZ) * scaleMdl + positionMdlZ;

    if (gridSnap != 0.0)
    {
      ax = gridSnap * floor (ax / gridSnap + 0.5);
      ay = gridSnap * floor (ay / gridSnap + 0.5);
      az = gridSnap * floor (az / gridSnap + 0.5);
      bx = gridSnap * floor (bx / gridSnap + 0.5);
      by = gridSnap * floor (by / gridSnap + 0.5);
      bz = gridSnap * floor (bz / gridSnap + 0.5);
      cx = gridSnap * floor (cx / gridSnap + 0.5);
      cy = gridSnap * floor (cy / gridSnap + 0.5);
      cz = gridSnap * floor (cz / gridSnap + 0.5);
    }

    fprintf(f, " {\n");

    fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) ground1_1 0 0 0 1 1\n",
      ax,ay,az, bx,by,bz, cx,cy,cz); // TOP
    fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) black 0 0 0 1 1\n",
      0.0f,0.0f,-4096.0f, 4096.0f,0.0f,-4096.0f, 0.0f,4096.0f,-4096.0f); // BOTTOM
    fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
      cx,cy,cz, bx,by,bz, bx,by,-4096.0f); // SIDE BC
    fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
      bx,by,bz, ax,ay,az, ax,ay,-4096.0f); // SIDE AB
    fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
      ax,ay,az, cx,cy,cz, cx,cy,-4096.0f); // SIDE AC

    fprintf(f, " }\n");
  }
  fprintf(f, "}\n");
  fprintf(f, "{\n");
  fprintf(f, " \"classname\" \"info_player_start\"\n");
  fprintf(f, " \"origin\" \"0 0 0\"\n");
  fprintf(f, " \"angle\" \"360\"\n");
  fprintf(f, "}\n");

  fclose(f);

  return true;
}
