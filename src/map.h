/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_MAP_H
#define _BITCACHE_MAP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */

#include <cprime.h>  /* for rwlock_t */
#include <glib.h>    /* for GHashTable, GHashTableIter, GDestroyNotify */

/**
 * Represents a Bitcache map.
 */
typedef struct {
  GHashTable* hash_table;
#if 1
  rwlock_t lock;
#endif
} bitcache_map_t;

/**
 * Represents a Bitcache map iterator.
 */
typedef struct {
  long position;
  bitcache_map_t* map;
  GHashTableIter hash_table_iter;
} bitcache_map_iter_t;

/**
 * Initializes a map.
 */
extern int bitcache_map_init(bitcache_map_t* map,
  const GDestroyNotify key_destroy_func,
  const GDestroyNotify value_destroy_func);

/**
 * Resets a map back to an uninitialized state.
 */
extern int bitcache_map_reset(bitcache_map_t* map);

/**
 * Removes all mappings from a map.
 */
extern int bitcache_map_clear(bitcache_map_t* map);

/**
 * Returns the number of mappings in a map.
 */
extern long bitcache_map_count(bitcache_map_t* map);

/**
 * Checks whether a map contains a mapping for a given identifier.
 */
extern bool bitcache_map_lookup(bitcache_map_t* map,
  const bitcache_id_t* key,
  void** value);

/**
 * Inserts a given identifier-to-value mapping into a map.
 */
extern int bitcache_map_insert(bitcache_map_t* map,
  const bitcache_id_t* key,
  const void* value);

/**
 * Removes a given identifier-to-value mapping from a map.
 */
extern int bitcache_map_remove(bitcache_map_t* map,
  const bitcache_id_t* key);

/**
 * Initializes a map iterator for a given map.
 */
extern int bitcache_map_iter_init(bitcache_map_iter_t* iter,
  bitcache_map_t* map);

/**
 * Advances a map iterator to the next mapping in the map.
 */
extern bool bitcache_map_iter_next(bitcache_map_iter_t* iter,
  bitcache_id_t** key,
  void** value);

/**
 * Removes the current mapping pointed to by a map iterator.
 */
extern int bitcache_map_iter_remove(bitcache_map_iter_t* iter);

/**
 * Disposes of a map iterator, freeing any resources it used.
 */
extern int bitcache_map_iter_done(bitcache_map_iter_t* iter);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_MAP_H */
