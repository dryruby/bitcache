/* This is free and unencumbered software released into the public domain. */

#ifndef BITCACHE_FILTER_H
#define BITCACHE_FILTER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "bitcache_id.h"
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#define BITCACHE_FILTER_K_MAX (sizeof(bitcache_id_t) / sizeof(uint32_t)) /* k=5 for SHA-1 */

typedef struct {
  size_t size;
  uint8_t* bitmap;
} bitcache_filter_t;

typedef enum {
  BITCACHE_FILTER_NOP = 0, // no-op
  BITCACHE_FILTER_OR  = 1, // bitwise or  (set union)
  BITCACHE_FILTER_AND = 2, // bitwise and (set intersection)
  BITCACHE_FILTER_XOR = 3, // bitwise xor (set difference)
} bitcache_filter_op_t;

extern int bitcache_filter_init(bitcache_filter_t* filter, const size_t size);
extern int bitcache_filter_reset(bitcache_filter_t* filter);
extern int bitcache_filter_clear(bitcache_filter_t* filter);
extern ssize_t bitcache_filter_size(const bitcache_filter_t* filter);
extern long bitcache_filter_count(const bitcache_filter_t* filter, const bitcache_id_t* id);
extern bool bitcache_filter_lookup(const bitcache_filter_t* filter, const bitcache_id_t* id);
extern int bitcache_filter_insert(bitcache_filter_t* filter, const bitcache_id_t* id);
extern int bitcache_filter_compare(const bitcache_filter_t* filter1, const bitcache_filter_t* filter2);
extern int bitcache_filter_merge(bitcache_filter_t* filter0, const bitcache_filter_op_t op, const bitcache_filter_t* filter1, const bitcache_filter_t* filter2);
extern int bitcache_filter_load(bitcache_filter_t* filter, const int fd);
extern int bitcache_filter_dump(const bitcache_filter_t* filter, const int fd);

#ifdef __cplusplus
}
#endif

#endif /* BITCACHE_FILTER_H */
