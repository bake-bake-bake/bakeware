CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic

all: runner


runner: utils.o main.o
	$(CC) $^ $(LDFLAGS) -o $@
	strip $@

clean:
	$(RM) *.o runner