/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_SET_H
#define _BITCACHE_SET_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */

#include <cprime.h>  /* for rwlock_t, free_func_t */
#include <glib.h>    /* for GHashTable, GHashTableIter */

/**
 * Represents a Bitcache set.
 */
typedef struct {
  GHashTable* hash_table;
  /* bitcache_filter_t filter; // TODO */
#if 1
  rwlock_t lock;
#endif
} bitcache_set_t;

/**
 * Represents a Bitcache set iterator.
 */
typedef struct {
  long position;
  bitcache_set_t* set;
  GHashTableIter hash_table_iter;
} bitcache_set_iter_t;

/**
 * Allocates heap memory for a new set.
 */
extern bitcache_set_t* bitcache_set_alloc();

/**
 * Releases the heap memory used by a set.
 */
extern void bitcache_set_free(bitcache_set_t* set);

/**
 * Initializes a set.
 */
extern int bitcache_set_init(bitcache_set_t* set,
  const free_func_t id_destroy_func);

/**
 * Resets a set back to an uninitialized state.
 */
extern int bitcache_set_reset(bitcache_set_t* set);

/**
 * Removes all identifiers from a set.
 */
extern int bitcache_set_clear(bitcache_set_t* set);

/**
 * Returns the cardinality of a set.
 */
extern long bitcache_set_count(bitcache_set_t* set);

/**
 * Checks whether a set contains a given identifier.
 */
extern bool bitcache_set_lookup(bitcache_set_t* set,
  const bitcache_id_t* id);

/**
 * Inserts a given identifier into a set.
 */
extern int bitcache_set_insert(bitcache_set_t* set,
  const bitcache_id_t* id);

/**
 * Removes a given identifier from a set.
 */
extern int bitcache_set_remove(bitcache_set_t* set,
  const bitcache_id_t* id);

/**
 * Replaces a given identifier in a set with another identifier.
 */
extern int bitcache_set_replace(bitcache_set_t* set,
  const bitcache_id_t* id1,
  const bitcache_id_t* id2);

/**
 * Initializes a set iterator for a given set.
 */
extern int bitcache_set_iter_init(bitcache_set_iter_t* iter,
  bitcache_set_t* set);

/**
 * Advances a set iterator to the next identifier in the set.
 */
extern bool bitcache_set_iter_next(bitcache_set_iter_t* iter,
  bitcache_id_t** id);

/**
 * Removes the current identifier pointed to by a set iterator.
 */
extern int bitcache_set_iter_remove(bitcache_set_iter_t* iter);

/**
 * Disposes of a set iterator, freeing any resources it used.
 */
extern int bitcache_set_iter_done(bitcache_set_iter_t* iter);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_SET_H */
