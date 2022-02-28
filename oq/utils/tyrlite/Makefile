############################
# Quake utilities Makefile #
############################

.PHONY:	all clean 

ifeq ($(OSTYPE),msys)
EXT =.exe
else
EXT =
endif

TARGET = ../bin/tyrlite$(EXT)

CC	 = gcc 
#CFLAGS	 = -Wall -O2 -fomit-frame-pointer
#CFLAGS	 = -Wall -O2 -fomit-frame-pointer -ffast-math
CFLAGS	 = -Wall -O3 -fomit-frame-pointer -ffast-math -mcpu=i686
#CFLAGS	 = -Wall -pg
CPPFLAGS = -DLINUX -I./include

###########
# TyrLite #
###########

TYRLITE_SOURCES = \
    tyrlite/entities.c \
    tyrlite/litfile.c  \
    tyrlite/ltface.c   \
    tyrlite/threads.c  \
    tyrlite/trace.c	   \
    tyrlite/tyrlite.c  \
    common/bspfile.c   \
    common/cmdlib.c	   \
    common/mathlib.c   \
    common/tyrlog.c

TYRLITE_SRC_EXTRA = Makefile

TYRLITE_OFILES = $(TYRLITE_SOURCES:%.c=%.o)

######################################
# default rule and maintenence rules #
######################################

all: $(TARGET) ;

clean:
	rm -f $(TYRLITE_OFILES)
	rm -f tyrlite/tyrlite.exe
	rm -f tyrlite/tyrlite

$(TARGET) : $(TYRLITE_OFILES)
ifeq "$(wildcard ../bin)" ""
	mkdir $(dir $@)
endif
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(TYRLITE_OFILES) -lm

