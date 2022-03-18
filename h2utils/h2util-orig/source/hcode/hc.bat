@hcc -quiet
@attrib -r c:\h3\test\data1\progs.dat
@copy progs.dat c:\h3\test\data1 > nul
@attrib +r c:\h3\test\data1\progs.dat
@attrib -r c:\h3\test\data1\files.dat
@copy files.dat c:\h3\test\data1 > nul
@attrib +r c:\h3\test\data1\files.dat

