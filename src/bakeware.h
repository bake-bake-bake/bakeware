#ifndef BAKEWARE_H

#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>

// Utility functions
#ifdef __GNUC__
#define BW_FATAL_ATTRS __attribute__ ((__noreturn__, __format__ (__printf__, 1, 2)))
#define BW_WARN_ATTRS __attribute__ ((__format__ (__printf__, 1, 2)))
#else
#define BW_FATAL_ATTRS
#define BW_WARN_ATTRS
#endif

// err.h equivalents so this works on
void bw_fatal(const char *format, ...) BW_FATAL_ATTRS;
void bw_fatalx(const char *format, ...) BW_FATAL_ATTRS;
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
    char sha256_ascii[65];
};

#define BAKEWARE_COMPRESSION_NONE 0
#define BAKEWARE_COMPRESSION_ZSTD 1

int bw_read_trailer(int fd, struct bakeware_trailer *trailer);

// CPIO
int cpio_extract_all(int fd, size_t cpio_len, const char *dest_dir);

// Cache management

struct bakeware; // FIXME
void cache_init(struct bakeware *bw);
int cache_validate(struct bakeware *bw);
int cache_read_app_data(struct bakeware *bw);

// Program data
struct bakeware
{
    int argc;
    char **argv;

    char path[4096];
    struct bakeware_trailer trailer;

    int fd;

    bool print_info;
    bool run_gc;
    bool install_only;

    // Cache
    char cache_dir_base[256];
    char cache_dir_app[256 + 65];

    // Application invocation
    char app_path[256];
};

#endif