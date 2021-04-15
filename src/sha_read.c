#include <unistd.h>

#include "bakeware.h"
#include "sha1.h"

void SHA1_Init(SHA1_CTX* context);
void SHA1_Update(SHA1_CTX* context, const uint8_t* data, const size_t len);
void SHA1_Final(SHA1_CTX* context, uint8_t digest[SHA1_DIGEST_SIZE]);

static SHA1_CTX context;

void sha_init()
{
    SHA1Init(&context);
}

ssize_t sha_read(int fd, void *buf, size_t nbytes)
{
    ssize_t rc = read(fd, buf, nbytes);
    if (rc > 0)
        SHA1Update(&context, (const uint8_t *) buf, rc);

    return rc;
}

void sha_result(uint8_t *digest)
{
    SHA1Final(&context, digest);
}
