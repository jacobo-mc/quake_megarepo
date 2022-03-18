#!/bin/sh

UHEXEN2_TOP=../..
. $UHEXEN2_TOP/scripts/cross_defs.dj

if test "$1" = "strip"; then
	$STRIPPER h2dos.exe server/h2ded.exe glh2dos.exe
	exit 0
fi

HOST_OS=`uname|sed -e s/_.*//|tr '[:upper:]' '[:lower:]'`
case "$HOST_OS" in
freebsd|openbsd|netbsd)
	MAKE_CMD=gmake ;;
linux)	MAKE_CMD=make ;;
*)	MAKE_CMD=make ;;
esac

if test "$1" = "h2ded"; then
	shift
	$MAKE_CMD -C server $* || exit 1
	exit 0
fi
if test "$1" = "all"; then
	shift

	$MAKE_CMD clean
	$MAKE_CMD h2 $*  || exit 1

	$MAKE_CMD clean
	$MAKE_CMD glh2 $*  || exit 1

	$MAKE_CMD -C server clean
	$MAKE_CMD -C server $* || exit 1

	$MAKE_CMD clean
	$MAKE_CMD -C server clean
	exit 0
fi

exec $MAKE_CMD $*

