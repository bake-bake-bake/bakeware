CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic

all: runner


runner: utils.o main.o trailer.o cpio.o cache.o
	$(CC) $^ $(LDFLAGS) -o $@
	strip $@

clean:
	$(RM) *.o runner
