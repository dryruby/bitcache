/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_SHA1_H
#define _BITCACHE_SHA1_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h> /* for uint8_t */
#include <unistd.h> /* for ssize_t */

/**
 * Represents a 20-byte SHA-1 digest.
 */
typedef uint8_t bitcache_sha1_t[20];

/**
 * Computes a SHA-1 digest.
 */
extern int bitcache_sha1(
  const uint8_t* restrict data,
  const ssize_t size,
  bitcache_sha1_t* restrict sha1);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_SHA1_H */
