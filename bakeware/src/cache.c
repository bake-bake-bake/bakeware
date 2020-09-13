#define _GNU_SOURCE

#include "bakeware.h"

#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

void cache_init(struct bakeware *bw)
{
    snprintf(bw->cache_dir_app, sizeof(bw->cache_dir_app), "%s/%s", bw->cache_dir_base, bw->trailer.sha256_ascii);
}

static void trim_line(char *line)
{
    size_t len = strlen(line);
    if (len > 0 && line[len - 1] == '\n')
        line[len - 1] = 0;
}

static FILE *fopen_in_cache_dir(const struct bakeware *bw, const char *relpath, const char *modes)
{
    char *path;
    if (asprintf(&path, "%s/%s/%s", bw->cache_dir_base, bw->trailer.sha256_ascii, relpath) < 0)
        bw_fatal("asprintf");
    FILE *fp = fopen(path, modes);
    free(path);
    return fp;
}

static bool is_cache_valid(const struct bakeware *bw)
{
    FILE *fp = fopen_in_cache_dir(bw, "source_paths", "r");

    bool is_valid = false;
    if (fp) {
        is_valid = true;
        fclose(fp);
    } else {
        bw_warnx("<cachedir>/source_paths not found, so this is a first time extraction.");
    }

    return is_valid;
}

static bool has_source_path(const struct bakeware *bw)
{
    FILE *fp = fopen_in_cache_dir(bw, "source_paths", "r");

    bool has_path = false;
    if (fp) {
        char line[256];
        while (fgets(line, sizeof(line), fp)) {
            trim_line(line);
            if (strcmp(line, bw->path) == 0) {
                has_path = true;
                break;
            }
        }
        fclose(fp);
    }
    return has_path;
}

static void add_source_path(const struct bakeware *bw)
{
    if (has_source_path(bw))
        return;

    FILE *fp = fopen_in_cache_dir(bw, "source_paths", "a");
    if (!fp)
        bw_fatal("Error updating source_paths in cache");
    fprintf(fp, "%s\n", bw->path);
    fclose(fp);

}

int cache_validate(struct bakeware *bw)
{
    // Logic: if the cache directory exists for the app AND the source_paths file points back to the
    //        executable, THEN the cache is valid.
    if (is_cache_valid(bw)) {
        add_source_path(bw);
        return 0;
    }

    // Create the bakeware cache directory, but don't worry if this fails.
    (void) mkdir(bw->cache_dir_base, 0755);

    if (mkdir(bw->cache_dir_app, 0755) < 0) {
        bw_warn("Can't create %s", bw->cache_dir_app);
        return -1;
    }

    add_source_path(bw);
    return -1;
}

int cache_read_app_data(struct bakeware *bw)
{
    return -1;
}

