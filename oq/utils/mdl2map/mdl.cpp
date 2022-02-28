/*
  Crystal Space QuakeMDL convertor : mdl reader
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

#include "mdl.h"
#include "csendian.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Mdl::Mdl()
{
  m_sError = NULL;
  noError();

  nbskins = 0;
  skinheight = skinwidth = 0;
  skins = NULL;
  nbframesets = 0;
  framesets = NULL;
  nbtriangles = 0;
  triangles = NULL;
  nbvertices = 0;
  vertices = NULL;
  originX = originY = originZ = 0.0;
  scaleX = scaleY = scaleZ = 1.0;
  skinheight = skinwidth = 0;
}

Mdl::Mdl(char * mdlfile)
{
  Mdl();
  ReadMDLFile(mdlfile);
}

Mdl::~Mdl()
{
/*
  need to make a good cleaner class here :-)
*/
}


bool Mdl::getError()
{
  return m_bError;
}

char * Mdl::getErrorString()
{
  return m_sError;
}

void Mdl::noError()
{
  setError("No error");
  m_bError = false;
}

bool Mdl::setError(char * errorstring)
{
  if(m_sError==NULL) delete m_sError;
  
  if(errorstring==NULL)
    m_sError = strdup("Unknown error");
  else
    m_sError = strdup(errorstring);

  m_bError = true;

  return !m_bError;
}

bool Mdl::ReadMDLFile(char * mdlfile)
{
  FILE *f;
  int i, ii;

  noError();

  if(mdlfile == NULL || strlen(mdlfile)==0)
    return setError("Cannot find a null file name");

  if((f=fopen(mdlfile, "rb"))==NULL)
    return setError("Cannot find mdl file !");

  // read mdl header
  magic_t magic;
  if(fread(&magic, sizeof(magic_t), 1, f)!=1)
    return setError("Cannot read magic header");
  magic.id = convert_endian (magic.id);
  magic.version = convert_endian (magic.version);

  // check if is a correct magic
  if(magic.id != (('O'<<24)+('P'<<16)+('D'<<8)+'I') )
    return setError("Invalid mdl magic");

  // check if is a correct version
  if(magic.version != 6)
    return setError("Invalid mdl version");

  // read mdl header
  mdl_t header;
  if(fread(&header, sizeof(mdl_t), 1, f)!=1)
    return setError("Cannot read mdl header");
  header.scale.x = convert_endian (header.scale.x);
  header.scale.y = convert_endian (header.scale.y);
  header.scale.z = convert_endian (header.scale.z);
  header.origin.x = convert_endian (header.origin.x);
  header.origin.y = convert_endian (header.origin.y);
  header.origin.z = convert_endian (header.origin.z);
  header.radius = convert_endian (header.radius);
  header.offsets.x = convert_endian (header.offsets.x);
  header.offsets.y = convert_endian (header.offsets.y);
  header.offsets.z = convert_endian (header.offsets.z);
  header.numskins = convert_endian (header.numskins);
  header.skinwidth = convert_endian (header.skinwidth);
  header.skinheight = convert_endian (header.skinheight);
  header.numverts = convert_endian (header.numverts);
  header.numtris = convert_endian (header.numtris);
  header.numframes = convert_endian (header.numframes);
  header.synctype = convert_endian (header.synctype);
  header.flags = convert_endian (header.flags);
  header.size = convert_endian (header.size);

  // sprite ops
  radiusbound = header.radius;
  originX = header.origin.x;
  originY = header.origin.y;
  originZ = header.origin.z;
  scaleX = header.scale.x;
  scaleY = header.scale.y;
  scaleZ = header.scale.z;

  // skins ops
  skinheight = header.skinheight;
  skinwidth = header.skinwidth;
  nbskins = header.numskins;
  skins = new skin_t[nbskins];
  for(i=0; i<nbskins; i++)
  {
    long group=0;
    if(fread(&group, sizeof(long), 1, f)!=1)
      return setError("Error then reading mdl file");
    group = convert_endian (group);

    if(group!=1 && group!=0)
      return setError("Incoherence in skin model properties");
    
    if(group==0) // one text skin
    {
      skins[i].group = false;
      skins[i].nbtexs = 1;
      skins[i].texs = new unsigned char *[1];
      skins[i].texs[0] = new unsigned char [skinheight*skinwidth];
      if(fread(skins[i].texs[0], skinheight*skinwidth, 1, f) !=1)
        return setError("Error then reading alone tex skin");
    }
    else // multi-tex skin
    {
      skins[i].group = true;
      if(fread(&skins[i].nbtexs, sizeof(long), 1, f)!=1)
        return setError("Error then reading mdl file");
      skins[i].nbtexs = convert_endian (skins[i].nbtexs);

      // read time between frame
      skins[i].timebtwskin = new float [skins[i].nbtexs];
      if(fread(skins[i].timebtwskin, sizeof(float)*skins[i].nbtexs, 1, f) !=1)
        return setError("Error then reading multi-tex skin");
      for (ii = 0 ; ii < skins[i].nbtexs ; ii++)
        skins[i].timebtwskin[ii] = convert_endian (skins[i].timebtwskin[ii]);

      // read all texture of group
      skins[i].texs = new unsigned char *[skins[i].nbtexs];
      for(int j=0; j<skins[i].nbtexs; j++)
      {
        skins[i].texs[j] = new unsigned char [skinheight*skinwidth];
        if(fread(skins[i].texs[j], skinheight*skinwidth, 1, f) !=1)
          return setError("Error then reading multi-tex skin");
      }
    }
  }

  // vertices ops
  nbvertices = header.numverts;
  vertices = new vertice_t[nbvertices];
  // read all vertices
  for(i=0; i<nbvertices; i++)
  {
    if(fread(&vertices[i], sizeof(vertice_t), 1, f) !=1)
      return setError("Error then reading mdl file");
    vertices[i].onseam = convert_endian (vertices[i].onseam);
    vertices[i].s = convert_endian (vertices[i].s);
    vertices[i].t = convert_endian (vertices[i].t);
  }

  // triangles ops
  nbtriangles = header.numtris;
  triangles = new triangle_t[nbtriangles];
  // read all triangles
  for(i=0; i<nbtriangles; i++)
  {
    if(fread(&triangles[i], sizeof(triangle_t), 1, f) !=1)
      return setError("Error then reading mdl file");
    triangles[i].facefront = convert_endian (triangles[i].facefront);
    triangles[i].vertice[0] = convert_endian (triangles[i].vertice[0]);
    triangles[i].vertice[1] = convert_endian (triangles[i].vertice[1]);
    triangles[i].vertice[2] = convert_endian (triangles[i].vertice[2]);
  }

  // frames ops
  nbframesets = header.numframes;
  framesets = new frameset_t [nbframesets];
  // check all framessets
  for(i=0; i<nbframesets; i++)
  {
    long typeframe = 0;
    if(fread(&typeframe, sizeof(long), 1, f) !=1)
      return setError("Error then reading mdl file");
    typeframe = convert_endian (typeframe);

    if(typeframe==0) // one animation frame
    {
      framesets[i].group = false;
      framesets[i].nbframes = 1;
      framesets[i].delay = new float[1];
      framesets[i].delay[0] = 0.0;
      framesets[i].frames = new frame_t[1];
      framesets[i].frames[0].trivert = new trivertx_t[nbvertices];

      // read min bound
      if(fread(&framesets[i].frames[0].min, sizeof(trivertx_t), 1, f) !=1)
        return setError("Error then reading mdl file");
      memcpy(&framesets[i].min, &framesets[i].frames[0].min, sizeof(trivertx_t));

      // read max bound
      if(fread(&framesets[i].frames[0].max, sizeof(trivertx_t), 1, f) !=1)
        return setError("Error then reading mdl file");
      memcpy(&framesets[i].max, &framesets[i].frames[0].max, sizeof(trivertx_t));

      // name of frame
      if(fread(framesets[i].frames[0].name, sizeof(char)*16, 1, f) !=1)
        return setError("Error then reading mdl file");

      // vertices
      if(fread(framesets[i].frames[0].trivert, sizeof(trivertx_t)*nbvertices, 1, f) !=1)
        return setError("Error then reading mdl file");      
    }
    else  // multi-frame animation
    {
      framesets[i].group = true;

      if(fread(&framesets[i].nbframes, sizeof(long), 1, f) !=1)
        return setError("Error then reading mdl file");
      framesets[i].nbframes = convert_endian (framesets[i].nbframes);

      framesets[i].delay = new float[framesets[i].nbframes];
      framesets[i].frames = new frame_t[framesets[i].nbframes];

      // read general min bound
      if(fread(&framesets[i].min, sizeof(trivertx_t), 1, f) !=1)
        return setError("Error then reading mdl file");

      // read general max bound
      if(fread(&framesets[i].max, sizeof(trivertx_t), 1, f) !=1)
        return setError("Error then reading mdl file");

      // read time between frame
      if(fread(framesets[i].delay, sizeof(float)*framesets[i].nbframes, 1, f) !=1)
        return setError("Error then reading mdl file");
      for (ii = 0 ; ii < framesets[i].nbframes ; ii++)
        framesets[i].delay[ii] = convert_endian (framesets[i].delay[ii]);

      // read all frames in frameset
      for(int j=0; j<framesets[i].nbframes; j++)
      {
        // read min bound
        if(fread(&framesets[i].frames[j].min, sizeof(trivertx_t), 1, f) !=1)
          return setError("Error then reading mdl file");

        // read max bound
        if(fread(&framesets[i].frames[j].max, sizeof(trivertx_t), 1, f) !=1)
          return setError("Error then reading mdl file");
        
        // frame name
        if(fread(framesets[i].frames[j].name, sizeof(char)*16, 1, f) !=1)
          return setError("Error then reading mdl file");
        
        // frame vertices
        framesets[i].frames[j].trivert = new trivertx_t[nbvertices];
        if(fread(framesets[i].frames[j].trivert, sizeof(trivertx_t)*nbvertices, 1, f) !=1)
          return setError("Error then reading mdl file");
      }
    }
  }

  fclose(f);

  return true;
}
