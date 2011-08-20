/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_MD5_H
#define _BITCACHE_MD5_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h> /* for uint8_t */
#include <unistd.h> /* for ssize_t */

/**
 * Represents a 16-byte MD5 digest.
 */
typedef uint8_t bitcache_md5_t[16];

/**
 * Computes an MD5 digest.
 */
extern int bitcache_md5(
  const uint8_t* restrict data,
  const ssize_t size,
  bitcache_md5_t* restrict md5);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_MD5_H */
