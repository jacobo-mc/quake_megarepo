##### http://autoconf-archive.cryp.to/ax_c___attribute__.html
#
# SYNOPSIS
#
#   AX_C___ATTRIBUTE__
#
# DESCRIPTION
#
#   Provides a test for the compiler support of __attribute__
#   extensions. defines HAVE___ATTRIBUTE__ if it is found.
#
#   Originating from the 'pork' package by Ryan McCabe <ryan@numb.org>
#
# LAST MODIFICATION
#
#   2005-01-21
#
# COPYLEFT
#
#   Copyright (c) 2005 Christian Haggstrom <chm@c00.info>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2 of the
#   License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
#   02111-1307, USA.
#
#   As a special exception, the respective Autoconf Macro's copyright
#   owner gives unlimited permission to copy, distribute and modify the
#   configure scripts that are the output of Autoconf when processing
#   the Macro. You need not follow the terms of the GNU General Public
#   License when using or distributing such scripts, even though
#   portions of the text of the Macro appear in them. The GNU General
#   Public License (GPL) does govern all other use of the material that
#   constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the
#   Autoconf Macro released by the Autoconf Macro Archive. When you
#   make and distribute a modified version of the Autoconf Macro, you
#   may extend this special exception to the GPL to apply to your
#   modified version as well.

AC_DEFUN([AX_C___ATTRIBUTE__], [
  AC_MSG_CHECKING(for __attribute__)
  AC_CACHE_VAL(ac_cv___attribute__, [
    AC_TRY_COMPILE(
      [#include <stdlib.h>],
      [static void foo(void) __attribute__ ((unused));
      static void
      foo(void) {
          exit(1);
      }],
      ac_cv___attribute__=yes,
      ac_cv___attribute__=no
    )])
  if test "$ac_cv___attribute__" = "yes"; then
    AC_DEFINE(HAVE___ATTRIBUTE__, 1, [define if your compiler has __attribute__])
  fi
  AC_MSG_RESULT($ac_cv___attribute__)
])
