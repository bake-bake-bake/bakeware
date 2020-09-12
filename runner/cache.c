#define _GNU_SOURCE

#include "bakeware.h"

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>

void cache_init(struct bakeware *bw)
{
    snprintf(bw->cache_dir_app, sizeof(bw->cache_dir_app), "%s/%s", bw->cache_dir_base, bw->trailer.sha256_ascii);
}

static bool is_cache_valid(const struct bakeware *bw)
{
    char *source_paths_filename;
    if (asprintf(&source_paths_filename, "%s/source_paths", bw->cache_dir_app) < 0)
        bw_err(EXIT_FAILURE, "asprintf");
    FILE *fp = fopen(source_paths_filename, "r");
    free(source_paths_filename);

    if (!fp) {
        bw_warnx("source_paths not found, so this is a first time extraction.");
        return false;
    }
    return false;
    // char line[256];
    // while
}

int cache_validate(struct bakeware *bw)
{
    // Logic: if the cache directory exists for the app AND the source_paths file points back to the
    //        executable, THEN the cache is valid.
    if (is_cache_valid(bw))
        return 0;

    if (mkdir(bw->cache_dir_app, 0755) < 0) {
        bw_warn("Can't create %s", bw->cache_dir_app);
        return -1;
    }
    return -1;
}

int cache_read_app_data(struct bakeware *bw)
{
    return -1;
}

