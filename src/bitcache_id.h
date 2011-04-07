/* This is free and unencumbered software released into the public domain. */

#ifndef BITCACHE_ID_H
#define BITCACHE_ID_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

typedef struct {
  uint8_t digest[20];
} bitcache_id_t;

#ifdef __cplusplus
}
#endif

#endif /* BITCACHE_ID_H */
