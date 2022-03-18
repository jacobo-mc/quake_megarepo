This is the initial decompilation of progs.dat from E3-beta version of hexen2.

Note that this particular version of hexen2 is from a time when Raven's calling
convention hadn't yet been invented.

The decompilation output from dhcc is weirder than usual for this one:  There
are a lot of return type conflicts which I fixed among other stuff, and I also
arranged it so that it compiles with hcc, but the binary output from the hcode
is not the same as the original progs.dat itself.
