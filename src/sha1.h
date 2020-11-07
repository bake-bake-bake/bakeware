/* public api for steve reid's public domain SHA-1 implementation */
/* this file is in the public domain */
#ifndef SHA1_H
#define SHA1_H

#include <stdint.h>
#include <stdlib.h>

typedef struct
{
    uint32_t state[5];
    uint32_t count[2];
    uint8_t  buffer[64];
} SHA1_CTX;

#define SHA1_DIGEST_SIZE 20

void SHA1Init(SHA1_CTX* context);
void SHA1Update(SHA1_CTX* context, const uint8_t* data, const size_t len);
void SHA1Final(SHA1_CTX* context, uint8_t digest[SHA1_DIGEST_SIZE]);

#endif /* SHA1_H */
