#include <unistd.h>
#include <string.h>

#include "bakeware.h"
#include "zstd/lib/zstd.h"

struct unzstd_info
{
    ZSTD_DCtx *dctx;

    size_t bytes_left;

    void *input_buffer;
    size_t input_buffer_size;
    ZSTD_inBuffer input;
    ZSTD_outBuffer output;
    size_t our_output_pos;
};

static struct unzstd_info info;

void unzstd_init(size_t max_bytes)
{
    info.dctx = ZSTD_createDCtx();
    if (info.dctx == 0)
        bw_fatal("ZSTD_createDCtx");

    info.bytes_left = max_bytes;
    info.input_buffer_size = ZSTD_DStreamInSize();
    info.input_buffer = malloc(info.input_buffer_size);
    info.input.size = 0;
    info.input.src = info.input_buffer;
    info.input.pos = 0;
    info.output.size = ZSTD_DStreamOutSize();  /* Guarantee to successfully flush at least one complete compressed block in all circumstances. */
    info.output.dst = malloc(info.output.size);
    info.output.pos = 0;
    info.our_output_pos = 0;
}

void unzstd_free()
{
    ZSTD_freeDCtx(info.dctx);
    free(info.input_buffer);
    free(info.output.dst);
}

ssize_t unzstd_read(int fd, void *buf, size_t count)
{
    if (count == 0)
        return 0;

    char *p = (char *) buf;
    size_t amount_copied = 0;
    for (;;) {
        // Use any that's been decompressed
        if (info.our_output_pos < info.output.pos) {
            size_t max_to_copy = count - amount_copied;
            size_t to_copy = info.output.pos - info.our_output_pos;
            if (to_copy > max_to_copy)
                to_copy = max_to_copy;

            memcpy(p, (char *) info.output.dst + info.our_output_pos, to_copy);
            info.our_output_pos += to_copy;
            p += to_copy;
            amount_copied += to_copy;
            if (amount_copied == count)
                return amount_copied;
        }

        // Check if we need to read more compressed data
        if (info.input.pos >= info.input.size) {
            size_t to_read = info.input_buffer_size;
            if (to_read > info.bytes_left)
                to_read = info.bytes_left;
            if (to_read == 0)
                return 0;

            ssize_t amount = sha_read(fd, info.input_buffer, to_read);
            if (amount <= 0) {
                bw_fatal("Error reading %d bytes", (int) to_read);
                return -1;
            }
            info.input.size = amount;
            info.input.pos = 0;
            info.bytes_left -= amount;
        }

        // Decompress more
        info.output.pos = 0;
        info.our_output_pos = 0;

        //bw_debug("ZSTD_decompressStream: bytes_left=%d, input(%d,%d) -> output(%d,%d)", info.bytes_left, info.input.pos, info.input.size, info.output.pos, info.output.size);
        size_t const ret = ZSTD_decompressStream(info.dctx, &info.output, &info.input);
        if (ZSTD_isError(ret)) {
            bw_fatalx("decompression error");
            return -1;
        }
    }
}
