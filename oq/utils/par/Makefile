CFLAGS = -Wall -O2
#CFLAGS = -Wall -g

TARGET = ../bin/par

all : $(TARGET) ;

../bin :
	mkdir $@

$(TARGET) : par.c header.h ../bin
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) $(TARGET)
	$(RM) file0 file1 file2 smoketest.pak


# run some unit tests

TESTS += test-smoke
test-smoke : $(TARGET)
	@echo "================ running test $@ =================="
	cp testdata/emptyfile.pak     file0
	cp testdata/500.pak           file1
	cp testdata/croppedheader.pak file2
	$(TARGET) -c  smoketest.pak file0
	$(TARGET) -c  smoketest.pak file1 file2 testdata/dir1/dir2/file
	$(TARGET) -l  smoketest.pak
	$(TARGET) -l  smoketest.pak file1
	$(TARGET) -l  smoketest.pak file0 || [[ "$$?" == "2" ]]
	$(TARGET) -lf smoketest.pak file0 || [[ "$$?" == "2" ]]
	$(RM) file0 file1 file2
	$(TARGET) -x smoketest.pak
	[ ! -x file0 ]
	cmp file1 testdata/500.pak
	cmp file2 testdata/croppedheader.pak
	$(RM) file0 file1 file2
	$(TARGET) -x smoketest.pak file1
	[ ! -x file0 ]
	cmp file1 testdata/500.pak
	[ ! -x file2 ]
	$(RM) file0 file1 file2
	$(RM) smoketest.pak
	@echo "test $@ PASSED"
	@echo 

TESTS += test-help
test-help : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -h
	@echo "test $@ PASSED"
	@echo 

TESTS += test-version
test-version : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -V
	@echo "test $@ PASSED"
	@echo 

TESTS += test-bad-commands
test-bad-commands : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET)                    || [[ "$$?" == "2" ]]
	$(TARGET) testdata/empty.pak || [[ "$$?" == "2" ]]
	$(TARGET) -3                 || [[ "$$?" == "2" ]]
	$(TARGET) -c                 || [[ "$$?" == "2" ]]
	$(TARGET) -l                 || [[ "$$?" == "2" ]]
	$(TARGET) -l does-not-exist  || [[ "$$?" == "2" ]]
	$(TARGET) -x                 || [[ "$$?" == "2" ]]
	$(TARGET) -x does-not-exist  || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-create-with-non-existent-file
test-create-with-non-existent-file : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -c test.pak does-not-exist || [[ "$$?" == "2" ]]
	[ ! -x test.pak ]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-empty-archive
test-empty-archive : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -c empty.pak
	cmp empty.pak testdata/empty.pak
	$(TARGET) -l empty.pak
	$(TARGET) -l empty.pak does-not-exist || [[ "$$?" == "2" ]]
	$(RM) empty.pak
	@echo "test $@ PASSED"
	@echo 


TESTS += test-empty-file
test-empty-file : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l testdata/emptyfile.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -l testdata/emptyfile.pak does-not-exist || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata/emptyfile.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata/emptyfile.pak does-not-exist || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-cropped-header
test-cropped-header : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l testdata/croppedheader.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -l testdata/croppedheader.pak does-not-exist || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata/croppedheader.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata/croppedheader.pak does-not-exist || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-bad-magic
test-bad-magic : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l    testdata/badmagic.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -l -v testdata/badmagic.pak does-not-exist || [[ "$$?" == "2" ]]
	$(TARGET) -x -v testdata/badmagic.pak                || [[ "$$?" == "2" ]]
	$(TARGET) -x    testdata/badmagic.pak does-not-exist || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-directory
test-directory : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l testdata                || [[ "$$?" == "2" ]]
	$(TARGET) -l testdata does-not-exist || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata                || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata does-not-exist || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-extract-empty-string
test-extract-empty-string : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l testdata/500.pak ''     || [[ "$$?" == "2" ]]
	$(TARGET) -x testdata/500.pak ''     || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

TESTS += test-fail-to-create-with-directory
test-fail-to-create-with-directory : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -c dir.pak testdata        || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 


TESTS += test-500
test-500 : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l testdata/500.pak
	$(TARGET) -l testdata/500.pak dir/file1 dir/file101
	$(TARGET) -x testdata/500.pak dir/file1
	cmp dir/file1 testdata/emptyfile.pak
	$(RM) dir/file1
	$(TARGET) -x testdata/500.pak
	$(RM) dir/file*
	rmdir dir
	@echo "test $@ PASSED"
	@echo 

TESTS += test-force
test-force : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -l -f testdata/500.pak does-not-exist
	$(TARGET) -x -f testdata/500.pak does-not-exist
	@echo "test $@ PASSED"
	@echo 

TESTS += test-good-manifest
test-good-manifest : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -lt testdata/500.pak testdata/manifest
	$(TARGET) -xt testdata/500.pak testdata/manifest
	cmp dir/file1 testdata/emptyfile.pak
	cmp dir/file3 testdata/emptyfile.pak
	cmp dir/file5 testdata/emptyfile.pak
	[ ! -x dir/file2 ]
	$(RM) dir/file1 dir/file3 dir/file5
	rmdir dir
	@echo "test $@ PASSED"
	@echo 

TESTS += test-bad-manifest
test-bad-manifest : $(TARGET)
	@echo "================ running test $@ =================="
	$(TARGET) -lt testdata/500.pak testdata/badmanifest || [[ "$$?" == "2" ]]
	$(TARGET) -xt testdata/500.pak testdata/badmanifest || [[ "$$?" == "2" ]]
	$(TARGET) -ct bad.pak          testdata/badmanifest || [[ "$$?" == "2" ]]
	@echo "test $@ PASSED"
	@echo 

# does not pass
#TESTS += test-add-pak-to-self
test-add-pak-to-self : $(TARGET)
	@echo "================ running test $@ =================="
	echo "my file" > self.pak
	$(TARGET) -c self.pak self.pak || [[ "$$?" == "2" ]]
	$(TARGET) -l self.pak 
	$(TARGET) -x self.pak self.pak
	@echo "test $@ PASSED"
	@echo 

test : $(TESTS) ;
