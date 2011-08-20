/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_ID_H
#define _BITCACHE_ID_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */
#include <stddef.h>  /* for size_t */
#include <stdint.h>  /* for uint8_t, uint32_t */
#include <stdio.h>   /* for FILE */

/**
 * Represents a Bitcache identifier.
 */
typedef struct bitcache_id_t {
  union {
    bitcache_md5_t md5;
    bitcache_sha1_t sha1;
    uint8_t data[20];
    uint32_t hash;
  } digest;
} bitcache_id_t;

/**
 * Allocates heap memory for a new identifier.
 */
extern bitcache_id_t* bitcache_id_alloc();

/**
 * Releases the heap memory used by an identifier.
 */
extern void bitcache_id_free(bitcache_id_t* id);

/**
 * Clones an existing identifier onto the heap.
 */
extern bitcache_id_t* bitcache_id_clone(const bitcache_id_t* const id);

/**
 * Initializes an identifier from a given SHA-1 digest.
 */
extern int bitcache_id_init(bitcache_id_t* id,
  const uint8_t* digest);

/**
 * Parses a hexadecimal string representation of an identifier.
 */
extern long bitcache_id_parse(bitcache_id_t* id,
  const char* hexdigest);

/**
 * Serializes an identifier into its hexadecimal string representation.
 */
extern long bitcache_id_serialize(const bitcache_id_t* id,
  char* buffer,
  size_t buffer_size);

/**
 * Prints out an identifier's hexadecimal string representation.
 */
extern long bitcache_id_print(const bitcache_id_t* id,
  FILE* restrict stream);

/**
 * Zeroes out every byte of an identifier.
 */
extern int bitcache_id_clear(bitcache_id_t* id);

/**
 * Fills every byte of an identifier with a given byte value.
 */
extern int bitcache_id_fill(bitcache_id_t* id,
  const uint8_t value);

/**
 * Returns `TRUE` if two given identifiers are equal.
 */
extern bool bitcache_id_equal(const bitcache_id_t* id1,
  const bitcache_id_t* id2);

/**
 * Compares two identifiers for equality.
 */
extern int bitcache_id_compare(const bitcache_id_t* id1,
  const bitcache_id_t* id2);

/**
 * Returns a hash code for an identifier.
 */
extern uint32_t bitcache_id_hash(const bitcache_id_t* id);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_ID_H */
