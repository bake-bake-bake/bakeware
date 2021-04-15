#include <ftw.h>
#include <stdio.h>
#include <unistd.h>
#include <limits.h>

#include "bakeware.h"

// OPEN_MAX isn't defined on some systems. Note that many nftw man pages say
// that the max open file handles parameter is ignored, but it's definitely not
// ignored in the musl libc. On brief inspection, it looks like the number of
// handles needed is related to the maximum directory depth, so this value
// probably doesn't need to be that large in practice.
#ifndef OPEN_MAX
#define OPEN_MAX 255
#endif

static int rm(const char *path, const struct stat *s, int flag, struct FTW *ftw)
{
    int status;
    if (flag & FTW_DP)
        status = rmdir(path);
    else
        status = unlink(path);

    if (status < 0)
        bw_warn("Could not delete '%s'", path);
    return status;
}

int rm_fr(const char *path)
{
    return nftw(path, rm, OPEN_MAX, FTW_DEPTH | FTW_PHYS | FTW_MOUNT);
}
