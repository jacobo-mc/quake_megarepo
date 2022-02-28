TARGET = ../bin/mesh2map

$(TARGET) : mesh2map.c
ifeq "$(wildcard ../bin)" ""
	mkdir $(dir $@)
endif
	$(CC) -o $@ -O2 -lm -Wall $^

clean :
	$(RM) $(TARGET)
