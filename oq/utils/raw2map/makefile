../bin/raw2map: raw2map.c
ifeq "$(wildcard ../bin)" ""
	-mkdir $(dir $@)
endif
	$(CC) -o $@ -O2 -lm -Wall $^
