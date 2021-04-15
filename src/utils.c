#include "bakeware.h"
#include <errno.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// See bw_find_executable_path
#if defined(_WIN64) || defined(_WIN32)
#include <windows.h>
#elif __APPLE__
#include <mach-o/dyld.h>
#elif __linux
#include <unistd.h>
#endif

void bw_fatal(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    int err = errno;
    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, ": %s\n", strerror(err));

    va_end(ap);
    exit(EXIT_FAILURE);
}

void bw_fatalx(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, "\n");

    va_end(ap);
    exit(EXIT_FAILURE);
}

void bw_warn(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    int err = errno;
    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, ": %s\n", strerror(err));

    va_end(ap);
}

void bw_warnx(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, "\n");

    va_end(ap);
}

void bw_find_executable_path(char *path, size_t len)
{
    memset(path, 0, len);

    // See https://stackoverflow.com/questions/1023306/finding-current-executables-path-without-proc-self-exe
#ifdef _WIN64
    GetModuleFileName(NULL, path, len);
    // use _pgmptr instead???
#elif _WIN32
    GetModuleFileName(NULL, path, len);
#elif __APPLE__
    uint32_t size = len;
    if (_NSGetExecutablePath(path, &size) != 0)
        bw_fatalx("Couldn't determine executable path");
#elif __linux
    if (readlink("/proc/self/exe", path, len) < 0)
        bw_fatalx("Couldn't determine executable path");
#elif __unix // Probably want BSDs...
    if (readlink("/proc/curproc/file", path, len) < 0)
        bw_fatalx("Couldn't determine executable path");
#elif __posix
#error "POSIX unsupported"
#else
#error "What system is this???"
#endif
}

/**
 * Return the path to the user's cache directory for Bakeware data
 */
void bw_cache_directory(char *path, size_t len)
{
    const char *cache_path = getenv("BAKEWARE_CACHE");
    if (cache_path) {
        strncpy(path, cache_path, len - 1);
        path[len - 1] = '\0';
        return;
    } else {
#if defined (_WIN64) || defined(_WIN32)
    snprintf(path, len, "%s\\AppData\\Local\\Bakeware", getenv("userprofile"));
#elif __APPLE__
    snprintf(path, len, "%s//Library/Caches/Bakeware", getenv("HOME"));
#elif (__linux || __unix || __posix)
    snprintf(path, len, "%s/.cache/bakeware", getenv("HOME"));
#else
#error Implement
#endif
    }
}

/**
 * Helper function for setting environment variables
 */
int bw_set_environment(const char *key, int index, const char *value)
{
    char *str;
    int len;
    if (index < 0)
      len = asprintf(&str, "%s=%s", key, value);
    else
      len = asprintf(&str, "%s%d=%s", key, index, value);

    if (len < 0)
        bw_fatal("asprintf");
    return putenv(str);
}

void bw_bin_to_hex(const uint8_t *input, char *output, size_t input_len)
{
    const char *lookup = "0123456789ABCDEF";
    while (input_len > 0) {
        uint8_t v = *input++;
        output[0] = lookup[v >> 4];
        output[1] = lookup[v & 0xf];
        output += 2;
        input_len--;
    }
    *output = '\0';
}
