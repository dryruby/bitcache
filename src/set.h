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
  const struct bitcache_set_class_t* class;
  GHashTable* hash_table; // FIXME
#if 1
  rwlock_t lock;
#endif
} bitcache_set_t;

/**
 * Represents a Bitcache set iterator.
 */
typedef struct {
  const struct bitcache_set_iter_class_t* class;
  long position;
  bitcache_set_t* set;
  bitcache_id_t* id;
  GHashTableIter hash_table_iter; // FIXME
} bitcache_set_iter_t;

/**
 * Represents a Bitcache set's virtual dispatch table.
 */
typedef struct bitcache_set_class_t {
  struct bitcache_set_class_t* super;
  void (*free)(bitcache_set_t* set);
  int (*init)(bitcache_set_t* set);
  int (*reset)(bitcache_set_t* set);
  int (*clear)(bitcache_set_t* set);
  long (*count)(bitcache_set_t* set);
  bool (*lookup)(bitcache_set_t* set, const bitcache_id_t* id);
  int (*insert)(bitcache_set_t* set, const bitcache_id_t* id);
  int (*remove)(bitcache_set_t* set, const bitcache_id_t* id);
  int (*replace)(bitcache_set_t* set, const bitcache_id_t* id1,
                                      const bitcache_id_t* id2);
} bitcache_set_class_t;

/**
 * Represents a Bitcache set iterator's virtual dispatch table.
 */
typedef struct bitcache_set_iter_class_t {
  struct bitcache_set_iter_class_t* super;
  void (*free)(bitcache_set_iter_t* iter);
  int (*init)(bitcache_set_iter_t* iter, bitcache_set_t* set);
  int (*reset)(bitcache_set_iter_t* iter);
  bool (*next)(bitcache_set_iter_t* iter);
  int (*remove)(bitcache_set_iter_t* iter);
} bitcache_set_iter_class_t;

/**
 * The default virtual dispatch table for Bitcache sets.
 */
extern const bitcache_set_class_t bitcache_set_hash;

/**
 * The default virtual dispatch table for Bitcache set iterators.
 */
extern const bitcache_set_iter_class_t bitcache_set_iter_hash;

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
  const bitcache_set_class_t* restrict class);

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
  const bitcache_id_t* restrict id);

/**
 * Inserts a given identifier into a set.
 */
extern int bitcache_set_insert(bitcache_set_t* set,
  const bitcache_id_t* restrict id);

/**
 * Removes a given identifier from a set.
 */
extern int bitcache_set_remove(bitcache_set_t* set,
  const bitcache_id_t* restrict id);

/**
 * Replaces a given identifier in a set with another identifier.
 */
extern int bitcache_set_replace(bitcache_set_t* set,
  const bitcache_id_t* restrict id1,
  const bitcache_id_t* restrict id2);

/**
 * Initializes a set iterator for a given set.
 */
extern int bitcache_set_iter_init(bitcache_set_iter_t* iter,
  const bitcache_set_iter_class_t* restrict class,
  bitcache_set_t* set);

/**
 * Disposes of a set iterator, freeing any resources it used.
 */
extern int bitcache_set_iter_reset(bitcache_set_iter_t* iter);

/**
 * Advances a set iterator to the next identifier in the set.
 */
extern bool bitcache_set_iter_next(bitcache_set_iter_t* iter);

/**
 * Removes the current identifier pointed to by a set iterator.
 */
extern int bitcache_set_iter_remove(bitcache_set_iter_t* iter);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_SET_H */
