#include "bakeware.h"

#include <stdio.h>

void cache_init(struct bakeware *bw)
{
    snprintf(bw->cache_dir_app, sizeof(bw->cache_dir_app), "%s/%s", bw->cache_dir_base, bw->trailer.sha256_ascii);
}

int cache_validate(struct bakeware *bw)
{
    return -1;
}

int cache_read_app_data(struct bakeware *bw)
{
    return -1;
}

