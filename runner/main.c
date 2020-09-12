#include "bakeware.h"
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static char our_path[4096];
static bool print_info = false;
static bool run_gc = false;
static bool install_only = false;

static void process_arguments(int argc, char *argv[])
{
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--") == 0) {
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-gc") == 0) {
            run_gc = true;
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-install") == 0) {
            install_only = true;
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-system-install") == 0) {
            bw_warnx("Ignoring --bw-system-install");
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-info") == 0) {
            print_info = true;
            argv[i] = 0;
            break;
        }
    }
}

static void update_environment(int argc, char *argv[])
{
    bw_set_environment("BAKEWARE_EXECUTABLE", -1, our_path);

    int arg_index = 0;
    for (int i = 1; i < argc; i++) {
        const char *arg = argv[i];

        if (*arg == 0)
            continue;

        arg_index++;
        bw_set_environment("BAKEWARE_ARG", arg_index, arg);
    }
    char buffer[12];
    snprintf(buffer, sizeof(buffer), "%d", arg_index);
    bw_set_environment("BAKEWARE_ARGC", -1, buffer);
}

int main(int argc, char *argv[])
{
    process_arguments(argc, argv);
    bw_find_executable_path(our_path, sizeof(our_path));

    char cache_dir[256];
    bw_cache_directory(cache_dir, sizeof(cache_dir));

    bw_warnx("starting '%s' (cachedir=%s)...", our_path, cache_dir);

    int fd = open(our_path, O_CLOEXEC);
    if (fd < 0)
        bw_err(EXIT_FAILURE, "Can't open '%s'", our_path);

    struct bakeware_trailer trailer;
    if (bw_read_trailer(fd, &trailer) < 0)
        bw_errx(EXIT_FAILURE, "Error reading trailer!");

    if (print_info) {
        printf("Trailer version: %d\n", trailer.trailer_version);
        printf("Compression: %d\n", trailer.compression);
        printf("Flags: 0x%04x\n", trailer.flags);
        printf("Contents offset: %d\n", (int) trailer.contents_offset);
        printf("Contents length: %d\n", (int) trailer.contents_length);
        printf("SHA256: %02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n",
            trailer.sha256[0], trailer.sha256[1],trailer.sha256[2],trailer.sha256[3],
            trailer.sha256[4], trailer.sha256[5],trailer.sha256[6],trailer.sha256[7],
            trailer.sha256[8], trailer.sha256[9],trailer.sha256[10],trailer.sha256[11],
            trailer.sha256[12], trailer.sha256[13],trailer.sha256[14],trailer.sha256[15],
            trailer.sha256[16], trailer.sha256[17],trailer.sha256[18],trailer.sha256[19],
            trailer.sha256[20], trailer.sha256[21],trailer.sha256[22],trailer.sha256[23],
            trailer.sha256[24], trailer.sha256[25],trailer.sha256[26],trailer.sha256[27],
            trailer.sha256[28], trailer.sha256[29],trailer.sha256[30],trailer.sha256[31]);
        exit(EXIT_SUCCESS);
    }

    if (trailer.trailer_version != 1)
        bw_errx(EXIT_FAILURE, "Expecting trailer version 1");
    if (trailer.compression != BAKEWARE_COMPRESSION_NONE)
        bw_errx(EXIT_FAILURE, "Don't know how to handle compression type %d", trailer.compression);

    update_environment(argc, argv);
}
