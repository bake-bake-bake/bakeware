#include "bakeware.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static char our_path[4096];

static void process_arguments(int argc, char *argv[])
{
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--") == 0) {
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-gc") == 0) {
            bw_warnx("Ignoring --bw-gc");
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-install") == 0) {
            bw_warnx("Ignoring --bw-install");
            argv[i] = 0;
            break;
        } else if (strcmp(argv[i], "--bw-system-install") == 0) {
            bw_warnx("Ignoring --bw-system-install");
            argv[i] = 0;
            break;
        }
    }
}

int main(int argc, char *argv[])
{
    process_arguments(argc, argv);
    bw_find_executable_path(our_path, sizeof(our_path));

    bw_warnx("starting '%s'...", our_path);
}

