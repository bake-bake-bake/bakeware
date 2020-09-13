#include "bakeware.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define CPIO_MAGIC 0x070701 // CPIO newc format
#define CPIO_LAST  "TRAILER!!!"
#define CPIO_HEADER_SIZE 110

static unsigned int pad4(unsigned int x)
{
    return (x + 3) & ~3;
}

static int extract_file(int fd, const char *base_path, const char *path, mode_t mode, size_t len)
{
    char output_path[1024];
    snprintf(output_path, sizeof(output_path), "%s/%s", base_path, path);

    if (mode & 0040000) {
        // Ignore mode when creating directories
        if (mkdir(output_path, 0755) < 0 && errno != EEXIST) {
            bw_warn("Error creating directory %s??", output_path);
            return -1;
        }
    } else if (mode & 0100000) {
        FILE *dest = fopen(output_path, "wb");
        if (dest == NULL) {
            bw_warn("Error opening %s for write", output_path);
            return -1;
        }

        while (len > 0) {
            char buffer[1024];
            size_t to_read = len > sizeof(buffer) ? sizeof(buffer) : len;
            ssize_t num_read = read(fd, buffer, to_read);
            if (num_read < 0 || (size_t) num_read != to_read) {
                bw_warn("Error reading CPIO file data?");
                return -1;
            }
            fwrite(buffer, 1, num_read, dest);
            len -= num_read;
        }
        fclose(dest);
        chmod(output_path, mode & 0777);
    } else {
        bw_warnx("Unimplemented handling for CPIO mode=%o for %s", mode, path);
        return -1;

    }
    return 0;
}

// -1 is error
// 0 is last entry
// >0 is number of bytes processed
static ssize_t cpio_extract_one(int fd, size_t max_len, const char *dest_dir)
{
    char buffer[CPIO_HEADER_SIZE + 1];

    if (read(fd, buffer, CPIO_HEADER_SIZE) != CPIO_HEADER_SIZE) {
        bw_warn("CPIO read error?");
        return -1;
    }
    buffer[CPIO_HEADER_SIZE] = 0;

    unsigned int magic;
    unsigned int ignore;
    unsigned int mode;
    unsigned int filesize;
    unsigned int namesize;
    int rc = sscanf(buffer, "%06x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x%08x",
        &magic,
        &ignore, // inode
        &mode,
        &ignore, // uid
        &ignore, // gid
        &ignore, // nlink
        &ignore, // mtime
        &filesize,
        &ignore, // devmajor
        &ignore, // devminor
        &ignore, // rdevmajor
        &ignore, // rdevminor
        &namesize,
        &ignore  // check
        );
    if (rc != 14 || magic != CPIO_MAGIC) {
        bw_warnx("Bad CPIO header");
        return -1;
    }

    char name[512];
    int padded_name = pad4(namesize + 2) - 2;  // The +2 is since the CPIO header is 110 bytes (not on a 4-byte boundary)
    if (read(fd, name, padded_name) != padded_name) {
        bw_warn("Error reading name");
        return -1;
    }
    name[namesize] = 0;

    //printf("name is '%s', mode is %0o\n", name, mode);

    // Check for final CPIO entry
    if (memcmp(name, CPIO_LAST, sizeof(CPIO_LAST)) == 0)
       return 0;

    if (extract_file(fd, dest_dir, name, mode, filesize) < 0)
        return -1;

    unsigned int padded_filesize = pad4(filesize);
    if (padded_filesize != filesize &&
        lseek(fd, padded_filesize - filesize, SEEK_CUR) < 0) {
        bw_warn("lseek failed");
        return -1;
    }

    return CPIO_HEADER_SIZE + padded_name + padded_filesize;
}

int cpio_extract_all(int fd, size_t cpio_len, const char *dest_dir)
{
    for (;;) {
        ssize_t len_processed = cpio_extract_one(fd, cpio_len, dest_dir);

        // Success
        if (len_processed == 0)
            return 0;

        // Read error
        if (len_processed < 0)
            return -1;

        // Check if out of bytes
        cpio_len -= (size_t) len_processed;
        if (cpio_len == 0) {
            bw_warnx("No CPIO trailer?");
            return -1;
        }
    }
}