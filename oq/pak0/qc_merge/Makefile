all: ../qwprogs.dat ../progs.dat
.PHONY: all

QCC=../../utils/qutils/bin/qcc

../qwprogs.dat:
	$(QCC) -o ../qwprogs.dat -p ../qwdefs.h qw.qc

../progs.dat:
	$(QCC) -o ../progs.dat -p ../progdefs.h quake.qc

clean:
	rm -f ../qwprogs.dat qw.d ../qwdefs.h ../progs.dat quake.d ../progdefs.h


ifneq ($(MAKECMDGOALS),clean)
include quake.d
include qw.d
endif

qw.d:
	gcc -x c -MM qw.qc | sed -e "s:.*\.o[ :]*:../qwprogs.dat qw.d \: :g" > qw.d

quake.d:
	gcc -x c -MM quake.qc | sed -e "s:.*\.o[ :]*:../progs.dat quake.d \: :g" > quake.d
