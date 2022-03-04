#ifndef __Primitive_h
#define __Primitive_h
#include "Procedure.h"
#include "Machine.h"

typedef SchemeObject *primfunc_t (SchemeObject *args, Machine *m);

@interface Primitive: Procedure
{
    primfunc_t func;
}
+ (id) newFromFunc: (primfunc_t) f;
- (id) initWithFunc: (primfunc_t) f;
@end

#endif //__Procedure_h
