ARCH_HOST := $(shell uname -m)
ARCH_TARGET ?= $(ARCH_HOST)
ifeq ($(ARCH_TARGET),riscv64)
    ifneq ($(ARCH_HOST),riscv64)
        CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
    endif
else ifeq ($(ARCH_TARGET),aarch64)
    ifneq ($(ARCH_HOST),aarch64)
        CROSS_COMPILE ?= aarch64-unknown-linux-gnu-
    endif
endif

CC := $(CROSS_COMPILE)g++
AR := $(CROSS_COMPILE)ar

CFLAGS = -O2 -g -Wall -fPIC

ifeq ($(ARCH_TARGET),riscv64)
    CFLAGS += -march=rv64gv
endif

all: libaotloader.a

libaotloader.a: light_jitlink.o qemu_lightjit.o
	$(AR) rcs $@ $^

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o libaotloader.a
