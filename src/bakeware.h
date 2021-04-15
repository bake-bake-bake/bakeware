#ifndef BAKEWARE_H
#define BAKEWARE_H

#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>

// Utility functions
#ifdef __GNUC__
#define BW_FATAL_ATTRS __attribute__ ((__noreturn__, __format__ (__printf__, 1, 2)))
#define BW_WARN_ATTRS __attribute__ ((__format__ (__printf__, 1, 2)))
#else
#define BW_FATAL_ATTRS
#define BW_WARN_ATTRS
#endif

// err.h equivalents so this works everywhere
void bw_fatal(const char *format, ...) BW_FATAL_ATTRS;
void bw_fatalx(const char *format, ...) BW_FATAL_ATTRS;
void bw_warn(const char *format, ...) BW_WARN_ATTRS;
void bw_warnx(const char *format, ...) BW_WARN_ATTRS;

// #define DEBUG
#ifdef DEBUG
#define bw_debug(...) do { bw_warnx(__VA_ARGS__); } while(0)
#else
#define bw_debug(...)
#endif

void bw_find_executable_path(char *path, size_t len);

void bw_cache_directory(char *path, size_t len);
int bw_set_environment(const char *key, int index, const char *value);
void bw_bin_to_hex(const uint8_t *input, char *output, size_t input_len);

#define BAKEWARE_MAX_START_COMMAND_LEN 12

// Trailer parsing
struct bakeware_trailer
{
    uint8_t trailer_version;
    uint8_t compression;
    uint16_t flags;

    off_t contents_offset;
    size_t contents_length;

    uint8_t sha1[20];
    char sha1_ascii[41];

    char start_command[BAKEWARE_MAX_START_COMMAND_LEN + 1];
};

#define BAKEWARE_COMPRESSION_NONE 0
#define BAKEWARE_COMPRESSION_ZSTD 1

int bw_read_trailer(int fd, struct bakeware_trailer *trailer);

// CPIO
typedef ssize_t (*read_contents)(int, void*, size_t);
int cpio_extract_all(read_contents reader, int fd, const char *dest_dir);

// zstd
void unzstd_init(size_t max_bytes);
void unzstd_free();
ssize_t unzstd_read(int fd, void *buf, size_t count);

// sha_read
void sha_init();
ssize_t sha_read(int fd, void *buf, size_t nbytes);
void sha_result(uint8_t *digest);

// rm_fr
int rm_fr(const char *path);

// Cache management

struct bakeware; // FIXME
void cache_init(struct bakeware *bw);
int cache_validate(struct bakeware *bw);
int cache_read_app_data(struct bakeware *bw);

// index
void index_add_entry(const struct bakeware *bw);

// Program data
struct bakeware
{
    int argc;
    char **argv;

    char path[4096];
    struct bakeware_trailer trailer;

    int fd;
    read_contents reader;

    bool print_info;
    bool run_gc;
    bool install_only;

    // Cache
    char cache_dir_base[256];
    char cache_dir_tmp[256 + 16];
    char cache_dir_index[256 + 16];

    char cache_dir_app[256 + 65];

    // Application invocation
    char app_path[256 + 128];

    // Mix Release command
    char start_command[BAKEWARE_MAX_START_COMMAND_LEN + 1];
};

#if (defined(_WIN32) || defined(_WIN64))
#define mkdir(A, B) mkdir(A)
#endif

#if (!defined(_WIN32) && !defined(_WIN64))
#define O_BINARY 0
#endif

#endif
