#include "bakeware.h"

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

void cache_init(struct bakeware *bw)
{
    snprintf(bw->cache_dir_tmp, sizeof(bw->cache_dir_tmp), "%s/.tmp", bw->cache_dir_base);
    snprintf(bw->cache_dir_index, sizeof(bw->cache_dir_index), "%s/.index", bw->cache_dir_base);
    snprintf(bw->cache_dir_app, sizeof(bw->cache_dir_app), "%s/%s", bw->cache_dir_base, bw->trailer.sha1_ascii);
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
    if (asprintf(&path, "%s/%s/%s", bw->cache_dir_base, bw->trailer.sha1_ascii, relpath) < 0)
        bw_fatal("asprintf");
    FILE *fp = fopen(path, modes);
    free(path);
    return fp;
}

static bool file_exists_in_cache_dir(const struct bakeware *bw, const char *relpath)
{
    FILE *fp = fopen_in_cache_dir(bw, relpath, "r");
    if (fp) {
        fclose(fp);
        return true;
    } else {
        return false;
    }
}

static bool is_cache_valid(const struct bakeware *bw)
{
    return file_exists_in_cache_dir(bw, "source_paths") &&
        file_exists_in_cache_dir(bw, "start");
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

    bw_debug("Cache invalid. Extracting...");

    // Create the bakeware cache directory structure, but don't worry if they fails.
    (void) mkdir(bw->cache_dir_base, 0755);
    (void) mkdir(bw->cache_dir_tmp, 0700);
    (void) mkdir(bw->cache_dir_index, 0700);

    // Expand to a temporary directory
    char tmp_dir_template[256+64];
    snprintf(tmp_dir_template, sizeof(tmp_dir_template), "%s/XXXXXX", bw->cache_dir_tmp);
    char *tmp_dir = mkdtemp(tmp_dir_template);
    if (tmp_dir == NULL) {
        bw_warn("Can't create expand archive under '%s'", bw->cache_dir_base);
        return -1;
    }

    if (lseek(bw->fd, bw->trailer.contents_offset, SEEK_SET) < 0) {
        bw_warn("Couldn't seek to start of CPIO");
        return -1;
    }

    sha_init();

    switch (bw->trailer.compression) {
    case BAKEWARE_COMPRESSION_NONE:
        bw->reader = sha_read;
        break;

    case BAKEWARE_COMPRESSION_ZSTD:
        unzstd_init(bw->trailer.contents_length);
        bw->reader = unzstd_read;
        break;

    default:
        bw_fatalx("Don't know how to handle compression type %d", bw->trailer.compression);
        break;
    }
    if (cpio_extract_all(bw->reader, bw->fd, tmp_dir) < 0) {
        bw_warn("CPIO extraction failed.");
        return -1;
    }

    if (bw->trailer.compression == BAKEWARE_COMPRESSION_ZSTD)
        unzstd_free();

    uint8_t computed_sha[20];
    sha_result(computed_sha);
    if (memcmp(computed_sha, bw->trailer.sha1, sizeof(computed_sha)) != 0) {
        bw_warn("SHA-1 mismatch. Corrupt archive");
        return -1;
    }

    // Success, so make temp directory real.
    if (rename(tmp_dir, bw->cache_dir_app) < 0) {
        // Someone else beat us to extracting it.
        bw_warn("TODODODODODOD - erase tmp_dir");
    }

    if (!file_exists_in_cache_dir(bw, "start")) {
        bw_warn("Missing `start` script in archive");
        return -1;
    }

    // Adding the source path says that we think the extraction is successful
    add_source_path(bw);
    return 0;
}

int cache_read_app_data(struct bakeware *bw)
{
    snprintf(bw->app_path, sizeof(bw->app_path), "%s/%s/start", bw->cache_dir_base, bw->trailer.sha1_ascii);

    return 0;
}

