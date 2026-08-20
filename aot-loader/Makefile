ARCH_HOST := $(shell uname -m)
CFLAGS = -O2 -g -Wall -fPIC
ifeq ($(ARCH_HOST), riscv64)
    CFLAGS += -march=rv64gv
endif

all: libaotloader.a

libaotloader.a: light_jitlink.o qemu_lightjit.o
	ar rcs $@ $^

%.o: %.cpp
	g++ $(CFLAGS) -c $< -o $@
clean:
	rm -f *.o libaotloader.a
