/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_FILTER_H
#define _BITCACHE_FILTER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */
#include <stddef.h>  /* for size_t */
#include <stdint.h>  /* for uint8_t, uint32_t */

/**
 * Defines the number of hashes used in a Bitcache filter.
 */
#define BITCACHE_FILTER_K_MAX \
  (sizeof(bitcache_id_t) / sizeof(uint32_t)) /* k=5 for SHA-1 */

/**
 * Represents a Bitcache filter.
 */
typedef struct {
  size_t size;
  uint8_t* bitmap;
} bitcache_filter_t;

/**
 * Represents a Bitcache filter operation.
 */
typedef enum {
  BITCACHE_FILTER_NOP = 0, /* no-op */
  BITCACHE_FILTER_OR  = 1, /* bitwise OR  (set union) */
  BITCACHE_FILTER_AND = 2, /* bitwise AND (set intersection) */
  BITCACHE_FILTER_XOR = 3, /* bitwise XOR (set difference) */
} bitcache_filter_op_t;

/**
 * Initializes a filter using a given bitmap size (in bytes).
 */
extern int bitcache_filter_init(bitcache_filter_t* filter,
  const size_t size);

/**
 * Resets a filter back to an uninitialized state.
 */
extern int bitcache_filter_reset(bitcache_filter_t* filter);

/**
 * Clears the bitmap of a filter.
 */
extern int bitcache_filter_clear(bitcache_filter_t* filter);

/**
 * Returns the bitmap size of a filter (in bytes).
 */
extern long bitcache_filter_size(const bitcache_filter_t* filter);

/**
 * Checks whether a filter recognizes a given identifier.
 */
extern long bitcache_filter_count(const bitcache_filter_t* filter,
  const bitcache_id_t* id);

/**
 * Checks whether a filter recognizes a given identifier.
 */
extern bool bitcache_filter_lookup(const bitcache_filter_t* filter,
  const bitcache_id_t* id);

/**
 * Inserts a given identifier into a filter.
 */
extern int bitcache_filter_insert(bitcache_filter_t* filter,
  const bitcache_id_t* id);

/**
 * Compares two filters for equality.
 */
extern int bitcache_filter_compare(const bitcache_filter_t* filter1,
  const bitcache_filter_t* filter2);

/**
 * Merges two filters into a given filter using a specific operation.
 */
extern int bitcache_filter_merge(bitcache_filter_t* filter0,
  const bitcache_filter_op_t op,
  const bitcache_filter_t* filter1,
  const bitcache_filter_t* filter2);

/**
 * Reads in a filter from a file descriptor.
 */
extern int bitcache_filter_load(bitcache_filter_t* filter,
  const int fd);

/**
 * Writes out a filter to a file descriptor.
 */
extern int bitcache_filter_dump(const bitcache_filter_t* filter,
  const int fd);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_FILTER_H */
