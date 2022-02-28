// Mdl.h: interface for the Mdl class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MDL_H__079698C2_09E0_11D2_9887_0060B08674B3__INCLUDED_)
#define AFX_MDL_H__079698C2_09E0_11D2_9887_0060B08674B3__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

// quake mdl type !

typedef float scalar_t;       // Scalar value,

typedef struct                // Vector or Position
{ scalar_t x;                 // horizontal
  scalar_t y;                 // horizontal
  scalar_t z;                 // vertical
} vec3_t;

typedef struct
{ long id;                    // 0x4F504449 = "IDPO" for IDPOLYGON
  long version;               // Version = 6
} magic_t;

typedef struct
{
  vec3_t scale;               // Model scale factors.
  vec3_t origin;              // Model origin.
  scalar_t radius;            // Model bounding radius.
  vec3_t offsets;             // Eye position (useless?)
  long numskins ;             // the number of skin textures
  long skinwidth;             // Width of skin texture
                              //           must be multiple of 8
  long skinheight;            // Height of skin texture
                              //           must be multiple of 8
  long numverts;              // Number of vertices
  long numtris;               // Number of triangles surfaces
  long numframes;             // Number of frames
  long synctype;              // 0= synchron, 1= random
  long flags;                 // 0 (see Alias models)
  scalar_t size;              // average size of triangles
} mdl_t;

typedef struct
{
  bool group;
  long nbtexs;                // number of pictures in group
  unsigned char **texs;       // the textures
  float *timebtwskin;         // time values, for each texture
} skin_t;

typedef struct
{
  long onseam;                // 0 or 0x20
  long s;                     // position, horizontally
                              //  in range [0,skinwidth[
  long t;                     // position, vertically
                              //  in range [0,skinheight[
} vertice_t;

typedef struct
{
  long facefront;             // boolean
  long vertice[3];            // Index of 3 triangle vertices
                              // in range [0,numverts[
} triangle_t;

typedef struct
{
  unsigned char packedposition[3];   // X,Y,Z coordinate, packed on 0-255
  unsigned char lightnormalindex;    // index of the vertex normal
} trivertx_t;

typedef struct
{
  trivertx_t min;             // minimum values of X,Y,Z
  trivertx_t max;             // maximum values of X,Y,Z
  char name[16];              // name of frame
  trivertx_t *trivert;        // array of vertices
} frame_t;

typedef struct
{
  bool group;                 // is a mdl group
  trivertx_t min;             // min position in all simple frames
  trivertx_t max;             // max position in all simple frames
  long nbframes;
  float *delay;               // time for each of the single frames
  frame_t *frames;            // a group of simple frames
} frameset_t;

class Mdl  
{
public:
	Mdl();
	Mdl(char * mdlfile);
	virtual ~Mdl();

public:
	static bool isMDLFile(char * file);
	char * getErrorString();
	bool getError();
  bool ReadMDLFile(char * mdlfile);

public:
  float radiusbound;
  float scaleX, scaleY, scaleZ;
  float originX, originY, originZ;

  int skinheight;
  int skinwidth;
  int nbskins;
  skin_t *skins;

  int nbvertices;
  vertice_t *vertices;

  int nbtriangles;
  triangle_t *triangles;

  int nbframesets;
  frameset_t *framesets;

private:
	bool m_bError;
	char * m_sError;

protected:
	void noError();
	bool setError(char *errorstring=NULL);
};

#endif // !defined(AFX_MDL_H__079698C2_09E0_11D2_9887_0060B08674B3__INCLUDED_)
