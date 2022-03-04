#ifndef __Continuation_h
#define __Continuation_h
#include "SchemeObject.h"
#include "Procedure.h"
#include "state.h"

@interface Continuation: Procedure
{
    state_t state;
}
+ (id) newWithState: (state_t *) st pc: (int) p;
- (id) initWithState: (state_t *) st pc: (int) p;
- (void) restoreOnMachine: (Machine *) m;

@end

#endif //__Procedure_h
