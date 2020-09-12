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

void bw_err(int status, const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    int err = errno;
    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, ": %s\n", strerror(err));

    va_end(ap);
    exit(status);
}

void bw_errx(int status, const char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    fprintf(stderr, "bakeware: ");
    vfprintf(stderr, format, ap);
    fprintf(stderr, "\n");

    va_end(ap);
    exit(status);
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
        bw_errx(EXIT_FAILURE, "Couldn't determine executable path");
#elif __linux
    if (readlink("/proc/self/exe", path, len) < 0)
        bw_errx(EXIT_FAILURE, "Couldn't determine executable path");
#elif __unix // Probably want BSDs...
    if (readlink("/proc/curproc/file", path, len) < 0)
        bw_errx(EXIT_FAILURE, "Couldn't determine executable path");
#elif __posix
#error "POSIX unsupported"
#else
#error "What system is this???"
#endif
}