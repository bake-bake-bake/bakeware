#include "bakeware.h"

#include <ftw.h>
#include <unistd.h>
#include <limits.h>

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