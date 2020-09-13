#include "bakeware.h"

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define BW_TRAILER_V1_LENGTH          48
#define BW_TRAILER_V1_MAGIC           (BW_TRAILER_V1_LENGTH - 4)
#define BW_TRAILER_V1_TRAILER_VERSION (BW_TRAILER_V1_LENGTH - 5)
#define BW_TRAILER_V1_COMPRESSION     (BW_TRAILER_V1_LENGTH - 6)
#define BW_TRAILER_V1_FLAGS           (BW_TRAILER_V1_LENGTH - 8)
#define BW_TRAILER_V1_CONTENTS_OFFSET (BW_TRAILER_V1_LENGTH - 12)
#define BW_TRAILER_V1_CONTENTS_LENGTH (BW_TRAILER_V1_LENGTH - 16)
#define BW_TRAILER_V1_SHA256          (BW_TRAILER_V1_LENGTH - 48)

static uint32_t read_be32(const uint8_t *buffer)
{
    return (buffer[0] << 24) + (buffer[1] << 16) + (buffer[2] << 8) + buffer[3];
}

static uint16_t read_be16(const uint8_t *buffer)
{
    return (buffer[0] << 8) + buffer[1];
}

static void sha256_to_ascii(const uint8_t *input, char *output)
{
    sprintf(output, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
        input[0], input[1],input[2],input[3],
        input[4], input[5],input[6],input[7],
        input[8], input[9],input[10],input[11],
        input[12], input[13],input[14],input[15],
        input[16], input[17],input[18],input[19],
        input[20], input[21],input[22],input[23],
        input[24], input[25],input[26],input[27],
        input[28], input[29],input[30],input[31]);
}

int bw_read_trailer(int fd, struct bakeware_trailer *trailer)
{
    memset(trailer, 0, sizeof(struct bakeware_trailer));
    if (lseek(fd, -BW_TRAILER_V1_LENGTH, SEEK_END) < 0) {
        bw_warn("lseek");
        return -1;
    }

    uint8_t buffer[BW_TRAILER_V1_LENGTH];
    if (read(fd, buffer, BW_TRAILER_V1_LENGTH) != BW_TRAILER_V1_LENGTH) {
        bw_warn("read");
        return -1;
    }

    if (memcmp(&buffer[BW_TRAILER_V1_MAGIC], "BAKE", 4) != 0) {
        bw_warnx("Incorrect Bakeware magic %d %d %d %d",
            buffer[BW_TRAILER_V1_MAGIC], buffer[BW_TRAILER_V1_MAGIC+1], buffer[BW_TRAILER_V1_MAGIC+2], buffer[BW_TRAILER_V1_MAGIC+3]);
        return -1;
    }

    trailer->trailer_version = buffer[BW_TRAILER_V1_TRAILER_VERSION];
    trailer->compression = buffer[BW_TRAILER_V1_COMPRESSION];
    trailer->flags = read_be16(&buffer[BW_TRAILER_V1_FLAGS]);
    trailer->contents_offset = read_be32(&buffer[BW_TRAILER_V1_CONTENTS_OFFSET]);
    trailer->contents_length = read_be32(&buffer[BW_TRAILER_V1_CONTENTS_LENGTH]);
    memcpy(trailer->sha256, &buffer[BW_TRAILER_V1_SHA256], sizeof(trailer->sha256));
    sha256_to_ascii(trailer->sha256, trailer->sha256_ascii);

    return 0;
}

