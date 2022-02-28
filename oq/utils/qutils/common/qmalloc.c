#include <stdlib.h>

#include "qmalloc.h"

#include "cmdlib.h"


#define NoMem(x) \
   Error("Out of memory! %s failed for %i bytes!", \
      x,size)

void *Q_malloc(size_t size)
{
   void *r;
   r=malloc(size);
   if (!r)
      NoMem("malloc");
   return r;
}

void *Q_realloc(void *ptr,size_t size)
{
   void *r;
   r=realloc(ptr,size);
   if (!r)
      NoMem("realloc");
   return r;
}

void Q_free(void *ptr)
{
   if (!ptr)
      return;
   free(ptr);
}


#ifdef DJGPP
// all utils need a larger stack than the default 256kb
unsigned int _stklen=1024*1024; // 1mb should work
#endif

