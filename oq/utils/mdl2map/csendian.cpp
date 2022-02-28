/*
    Copyright (C) 1998 by Jorrit Tyberghein
  
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

#include <time.h>

#include "csendian.h"

//---------------------------------------------------------------------------

static unsigned long test_value = 0x12345678L;
// Test for endianness.
inline int test_endian ()
{
  return (*((unsigned char*)&test_value) == 0x12);
}

float convert_endian (float l)
{
  // @@@ Is this right?
  if (test_endian ())
  {
    union
    {
      float l;
      struct { char a, b, c, d; } s;
    } swap;
    char s;

    swap.l = l;
    s = swap.s.a; swap.s.a = swap.s.d; swap.s.d = s;
    s = swap.s.b; swap.s.b = swap.s.c; swap.s.c = s;
    l = swap.l;
  }
  return l;
}

long convert_endian (long l)
{
  if (test_endian ())
  {
    union
    {
      long l;
      struct { char a, b, c, d; } s;
    } swap;
    char s;

    swap.l = l;
    s = swap.s.a; swap.s.a = swap.s.d; swap.s.d = s;
    s = swap.s.b; swap.s.b = swap.s.c; swap.s.c = s;
    l = swap.l;
  }
  return l;
}

short convert_endian (short l)
{
  if (test_endian ())
  {
    union
    {
      short l;
      struct { char a, b; } s;
    } swap;
    char s;

    swap.l = l;
    s = swap.s.a; swap.s.a = swap.s.b; swap.s.b = s;
    l = swap.l;
  }
  return l;
}

//---------------------------------------------------------------------------
