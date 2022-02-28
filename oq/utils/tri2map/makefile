TARGET = ../bin/tri2map

$(TARGET) : tri2map.c
ifeq "$(wildcard ../bin)" ""
	mkdir $(dir $@)
endif
	$(CC) -o $@ -O2 -lm -Wall $^

clean :
	$(RM) $(TARGET)

