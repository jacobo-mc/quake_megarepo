#!/bin/sh

UHEXEN2_TOP=..
. $UHEXEN2_TOP/scripts/cross_defs.w32

if [ "$1" = "strip" ]; then
	$STRIPPER h2patch.exe
	exit 0
fi

HOST_OS=`uname|sed -e s/_.*//|tr '[:upper:]' '[:lower:]'`
case "$HOST_OS" in
freebsd|openbsd|netbsd)
	MAKE_CMD=gmake ;;
linux)	MAKE_CMD=make ;;
*)	MAKE_CMD=make ;;
esac

exec $MAKE_CMD -f Makefile.mingw32 $*

