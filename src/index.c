#include "bakeware.h"
#include "sha1.h"

#include <stdio.h>
#include <string.h>

static void src_path_to_hash_name(const char *path, char *out)
{
    SHA1_CTX context;
    SHA1Init(&context);
    SHA1Update(&context, (const uint8_t *) path, strlen(path));
    uint8_t digest[SHA1_DIGEST_SIZE];
    SHA1Final(&context, digest);

    bw_bin_to_hex(digest, out, SHA1_DIGEST_SIZE);
}

void index_add_entry(const struct bakeware *bw)
{
    char index_filename[SHA1_DIGEST_SIZE * 2 + 1];
    src_path_to_hash_name(bw->path, index_filename);

    char *full_path;
    if (asprintf(&full_path, "%s/%s", bw->cache_dir_index, index_filename) < 0)
        bw_fatal("asprintf");
    FILE *fp = fopen(full_path, "w");
    if (fp != NULL) {
        fprintf(fp, "%s\n", bw->path);
        fclose(fp);
    }
    free(full_path);
}
