
TARGET=../bin/mdl2map
OBJS=main.o mdl.o map.o csendian.o
CFLAGS=-O -fomit-frame-pointer -Wall -I../../src

%.o : %.cpp
	$(CXX) -c $(CFLAGS) -o $@ $<

$(TARGET) : $(OBJS)
ifeq "$(wildcard ../bin)" ""
	mkdir $(dir $@)
endif
	$(CXX) -o $@ $^ $(LIBS)

clean:
	$(RM) $(OBJS) $(TARGET)

