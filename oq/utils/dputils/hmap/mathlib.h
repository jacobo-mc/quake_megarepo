#ifndef __MATHLIB__
#define __MATHLIB__

// mathlib.h

#include <math.h>

#pragma warning(disable : 4244)     // MIPS
#pragma warning(disable : 4136)     // X86
#pragma warning(disable : 4051)     // ALPHA

#ifdef DOUBLEVEC_T
typedef double vec_t;
#else
typedef float vec_t;
#endif
typedef vec_t vec3_t[3];

#define	SIDE_FRONT		0
#define	SIDE_ON			2
#define	SIDE_BACK		1
#define	SIDE_CROSS		-2

#define	Q_PI	3.14159265358979323846

extern vec3_t vec3_origin;
extern double vn_length;

#define	EQUAL_EPSILON	0.001

#define DotProduct(x,y) (x[0]*y[0]+x[1]*y[1]+x[2]*y[2])
#define VectorSubtract(a,b,c) {c[0]=a[0]-b[0];c[1]=a[1]-b[1];c[2]=a[2]-b[2];}
#define VectorAdd(a,b,c) {c[0]=a[0]+b[0];c[1]=a[1]+b[1];c[2]=a[2]+b[2];}
#define VectorCopy(a,b) {b[0]=a[0];b[1]=a[1];b[2]=a[2];}
#define VectorLength(v) (sqrt((v[0]*v[0]) + (v[1]*v[1]) + (v[2]*v[2])))
#define VectorCompare(v1, v2) (fabs(v1[0]-v2[0]) < EQUAL_EPSILON && \
				fabs(v1[1]-v2[1]) < EQUAL_EPSILON && \
				fabs(v1[2]-v2[2]) < EQUAL_EPSILON)
#define Q_rint(in) ((vec_t) floor(in + 0.5))
#define VectorMA(va, scale, vb, vc) {vc[0] = va[0] + scale*vb[0];vc[1] = va[1] + scale*vb[1];vc[2] = va[2] + scale*vb[2];}
#define CrossProduct(v1, v2, cross) {cross[0] = v1[1]*v2[2] - v1[2]*v2[1];cross[1] = v1[2]*v2[0] - v1[0]*v2[2];cross[2] = v1[0]*v2[1] - v1[1]*v2[0];}
#define VectorNormalize(v) {if ((vn_length = sqrt((v[0]*v[0]) + (v[1]*v[1]) + (v[2]*v[2])))) {v[0] /= vn_length; v[1] /= vn_length; v[2] /= vn_length;}}
#define VectorInverse(v) {v[0] = -v[0];v[1] = -v[1];v[2] = -v[2];}
#define VectorScale(v, scale, out) {out[0] = v[0] * scale;out[1] = v[1] * scale;out[2] = v[2] * scale;}
  //vec_t Q_rint (vec_t in);
  //void VectorMA (vec3_t va, double scale, vec3_t vb, vec3_t vc);

  //void CrossProduct (vec3_t v1, vec3_t v2, vec3_t cross);

  //vec_t VectorNormalize (vec3_t v);
  //void VectorInverse (vec3_t v);
  //void VectorScale (vec3_t v, vec_t scale, vec3_t out);
#endif

