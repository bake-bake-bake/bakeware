#ifndef BAKEWARE_H

#include <stdlib.h>

#ifdef __GNUC__
#define BW_ERR_ATTRS __attribute__ ((__noreturn__, __format__ (__printf__, 2, 3)))
#define BW_WARN_ATTRS __attribute__ ((__format__ (__printf__, 1, 2)))
#define BW_EXIT_ATTRS __attribute__ ((__noreturn__))
#else
#define BW_ERR_ATTRS
#define BW_WARN_ATTRS
#define BW_EXIT_ATTRS
#endif

void bw_err(int status, const char *format, ...) BW_ERR_ATTRS;
void bw_errx(int status, const char *format, ...) BW_ERR_ATTRS;
void bw_warnx(const char *format, ...) BW_WARN_ATTRS;
void bw_exit(int status) BW_EXIT_ATTRS;

int bw_find_executable_path(char *path, size_t len);

#endif