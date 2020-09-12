#ifndef BAKEWARE_H

#include <stdlib.h>
#include <stdint.h>

// Utility functions
#ifdef __GNUC__
#define BW_ERR_ATTRS __attribute__ ((__noreturn__, __format__ (__printf__, 2, 3)))
#define BW_WARN_ATTRS __attribute__ ((__format__ (__printf__, 1, 2)))
#define BW_EXIT_ATTRS __attribute__ ((__noreturn__))
#else
#define BW_ERR_ATTRS
#define BW_WARN_ATTRS
#define BW_EXIT_ATTRS
#endif

// err.h equivalents so this works on
void bw_err(int status, const char *format, ...) BW_ERR_ATTRS;
void bw_errx(int status, const char *format, ...) BW_ERR_ATTRS;
void bw_warn(const char *format, ...) BW_WARN_ATTRS;
void bw_warnx(const char *format, ...) BW_WARN_ATTRS;

void bw_find_executable_path(char *path, size_t len);

void bw_cache_directory(char *path, size_t len);
int bw_set_environment(const char *key, int index, const char *value);



// Trailer parsing
struct bakeware_trailer
{
    uint8_t trailer_version;
    uint8_t compression;
    uint16_t flags;

    off_t contents_offset;
    size_t contents_length;

    uint8_t sha256[32];
};

#define BAKEWARE_COMPRESSION_NONE 0
#define BAKEWARE_COMPRESSION_ZSTD 1

int bw_read_trailer(int fd, struct bakeware_trailer *trailer);

// CPIO
int cpio_extract_all(int fd, size_t cpio_len);


// Cache management

#endif