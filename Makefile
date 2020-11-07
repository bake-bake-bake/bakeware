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

PREFIX = $(MIX_APP_PATH)/launcher
BUILD  = $(MIX_APP_PATH)/obj

CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic
CFLAGS += -D_GNU_SOURCE
LDFLAGS ?=

BAKEWARE_OBJECTS = \
	$(BUILD)/cache.o \
	$(BUILD)/cpio.o \
	$(BUILD)/index.o \
	$(BUILD)/main.o \
	$(BUILD)/rm_fr.o \
	$(BUILD)/sha1.o \
	$(BUILD)/sha_read.o \
	$(BUILD)/trailer.o \
	$(BUILD)/unzstd.o \
	$(BUILD)/utils.o

ZSTD_OBJECTS = $(BUILD)/zstd/lib/decompress/huf_decompress.o \
	$(BUILD)/zstd/lib/decompress/zstd_ddict.o \
	$(BUILD)/zstd/lib/decompress/zstd_decompress.o \
	$(BUILD)/zstd/lib/decompress/zstd_decompress_block.o \
	$(BUILD)/zstd/lib/common/debug.o \
	$(BUILD)/zstd/lib/common/entropy_common.o \
	$(BUILD)/zstd/lib/common/error_private.o \
	$(BUILD)/zstd/lib/common/fse_decompress.o \
	$(BUILD)/zstd/lib/common/pool.o \
	$(BUILD)/zstd/lib/common/threading.o \
	$(BUILD)/zstd/lib/common/xxhash.o \
	$(BUILD)/zstd/lib/common/zstd_common.o

ZSTD_BUILD_DIRS = $(BUILD)/zstd/lib/decompress $(BUILD)/zstd/lib/common

all: $(BUILD) $(PREFIX) $(ZSTD_BUILD_DIRS) $(PREFIX)/launcher

$(BUILD)/%.o: src/%.c
	$(CC) -c $(CFLAGS) -o $@ $<

$(PREFIX)/launcher: $(BAKEWARE_OBJECTS) $(ZSTD_OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@
	strip $@

$(PREFIX) $(BUILD) $(ZSTD_BUILD_DIRS):
	mkdir -p $@

clean:
	$(RM) $(PREFIX)/launcher \
	    $(BUILD)/*.o

.PHONY: all clean calling_from_make

