TARGETS = ../bin/pcx2lmp

all: $(TARGETS)

../bin/%: %.c
ifeq "$(wildcard ../bin)" ""
	-mkdir $(dir $@)
endif
	$(CC) -o $@ -O2 -Wall $^

clean :
	$(RM) $(TARGETS)

