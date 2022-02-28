TARGET = ../bin/toon

$(TARGET) : toon.c
ifeq "$(wildcard ../bin)" ""
	mkdir $(dir $@)
endif
	$(CC) -o $@ -O2 -lm -Wall $^

clean :
	$(RM) $(TARGET)

