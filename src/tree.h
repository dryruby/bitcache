/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_TREE_H
#define _BITCACHE_TREE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */

#include <cprime.h>  /* for rwlock_t, free_func_t */
#include <glib.h>    /* for GTree */

/**
 * Represents a Bitcache tree.
 */
typedef struct {
  GTree* g_tree;
#if 1
  rwlock_t lock;
#endif
} bitcache_tree_t;

/**
 * Represents a Bitcache tree iterator.
 */
typedef struct {
  long position;
  bitcache_tree_t* tree;
} bitcache_tree_iter_t;

/**
 * Initializes a tree.
 */
extern int bitcache_tree_init(bitcache_tree_t* tree,
  const free_func_t key_destroy_func,
  const free_func_t value_destroy_func);

/**
 * Resets a tree back to an uninitialized state.
 */
extern int bitcache_tree_reset(bitcache_tree_t* tree);

/**
 * Removes all identifiers from a tree.
 */
extern int bitcache_tree_clear(bitcache_tree_t* tree);

/**
 * Returns the estimated size of a tree (in bytes).
 */
extern long bitcache_tree_size(bitcache_tree_t* tree);

/**
 * Returns the number of identifiers in a tree.
 */
extern long bitcache_tree_count(bitcache_tree_t* tree);

/**
 * Returns the current height of a tree.
 */
extern int bitcache_tree_height(bitcache_tree_t* tree);

/**
 * Checks whether a tree contains a given identifier.
 */
extern bool bitcache_tree_lookup(bitcache_tree_t* tree,
  const bitcache_id_t* key,
  void** value);

/**
 * Inserts a given identifier into a tree.
 */
extern int bitcache_tree_insert(bitcache_tree_t* tree,
  const bitcache_id_t* key,
  const void* value);

/**
 * Removes a given identifier from a tree.
 */
extern int bitcache_tree_remove(bitcache_tree_t* tree,
  const bitcache_id_t* key);

/**
 * Initializes a tree iterator for a given tree.
 */
extern int bitcache_tree_iter_init(bitcache_tree_iter_t* iter,
  bitcache_tree_t* tree);

/**
 * Advances a tree iterator to the next identifier in the tree.
 */
extern int bitcache_tree_iter_next(bitcache_tree_iter_t* iter,
  bitcache_id_t** key,
  void** value);

/**
 * Removes the current identifier pointed to by a tree iterator.
 */
extern int bitcache_tree_iter_remove(bitcache_tree_iter_t* iter);

/**
 * Disposes of a tree iterator, freeing any resources it used.
 */
extern int bitcache_tree_iter_done(bitcache_tree_iter_t* iter);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_TREE_H */
