#include <stdio.h>

#include "work.h"

#include "cmdlib.h"


static int per_dot;
static int wleft;

static float start;

static int sprint;


void InitWork(int numwork,int print)
{
   int i,j;

   sprint=print;
   if (!print)
      return;
   start=I_FloatTime();

   if (numwork<=60)
      per_dot=1;
   else
      per_dot=numwork/60+1;
   j=numwork/per_dot;
//   if (numwork%per_dot) j++;
   printf("[ %i %*c]\b",per_dot,j,' ');
   for (i=0;i<j;i++) printf("\b");
   fflush(stdout);
   wleft=per_dot;
}

void NextWork(void)
{
   if (!sprint)
      return;

   wleft--;
   if (!wleft)
   {
      printf(".");
      fflush(stdout);
      wleft=per_dot;
   }
}

void DoneWork(void)
{
   float end;

   if (!sprint)
      return;
   end=I_FloatTime();
   printf("] (%0.2f)\n",end-start);
}

