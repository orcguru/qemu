LEX = flex
BISON = bison
ARCH_HOST := $(shell uname -m)
ARCH_TARGET := $(shell uname -m)
CFLAGS = -O2 -g -Wall

all: libaotloader.a

libaotloader.a: light_jitlink.o qemu_lightjit.o
	ar rcs $@ $^

%.o: %.cpp
	g++ $(CFLAGS) -c $< -o $@
clean:
	rm -f *.o libaotloader.a
