# Makefile for building application launcher
#
# Makefile targets:
#
# all/install   build and install the NIF
# clean         clean build products and intermediates
#
# Variables to override:
#
# MIX_APP_PATH  path to the build directory
#
# CC            C compiler
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries
#
ifeq ($(MIX_APP_PATH),)
calling_from_make:
	mix compile
endif

PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic

all: $(BUILD) $(PREFIX) $(PREFIX)/launcher

$(BUILD)/%.o: src/%.c
	$(CC) -c $(CFLAGS) -o $@ $<

$(PREFIX)/launcher: $(BUILD)/utils.o $(BUILD)/main.o $(BUILD)/trailer.o $(BUILD)/cpio.o $(BUILD)/cache.o
	$(CC) $^ $(LDFLAGS) -o $@
	strip $@

$(PREFIX) $(BUILD):
	mkdir -p $@

clean:
	$(RM) $(PREFIX)/launcher \
	    $(BUILD)/*.o

.PHONY: all clean calling_from_make

