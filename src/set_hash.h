/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h> /* for assert() */
#include <cprime.h> /* for rwlock_t, free_func_t */
#include <glib.h>   /* for GHashTable, GHashTableIter, g_*() */

#include <stdio.h>

#if 1
#  define BITCACHE_SET_LOCK_INIT   RWLOCK_INIT
#  define bitcache_set_crlock(set) rwlock_init(&(set)->lock)
#  define bitcache_set_rmlock(set) rwlock_dispose(&(set)->lock)
#  define bitcache_set_rdlock(set) rwlock_rdlock(&(set)->lock)
#  define bitcache_set_wrlock(set) rwlock_wrlock(&(set)->lock)
#  define bitcache_set_unlock(set) rwlock_unlock(&(set)->lock)
#else
#  define bitcache_set_crlock(set)
#  define bitcache_set_rmlock(set)
#  define bitcache_set_rdlock(set)
#  define bitcache_set_wrlock(set)
#  define bitcache_set_unlock(set)
#endif /* HAVE_PTHREAD_H */

//////////////////////////////////////////////////////////////////////////////
// Set API (hash table implementation)

typedef struct {
  GHashTable* data; // FIXME
#if 1
  rwlock_t lock;
#endif
} bitcache_set_hash_t;

gboolean bitcache_id_equal_g(const bitcache_id_t* id1, const bitcache_id_t* id2);

static int
bitcache_set_hash_init(bitcache_set_t* set) {
  bitcache_set_hash_t* hash_table = calloc(1, sizeof(bitcache_set_hash_t));
  assert(hash_table != NULL);

  bitcache_set_crlock(hash_table);
  hash_table->data = g_hash_table_new_full(
    (GHashFunc)bitcache_id_hash,
    (GEqualFunc)bitcache_id_equal_g,
    (free_func_t)free, // FIXME
    (free_func_t)NULL);

  set->instance = hash_table;

  return 0;
}

static int
bitcache_set_hash_reset(bitcache_set_t* set) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  set->instance = NULL;

  bitcache_set_rmlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    g_hash_table_destroy(hash_table->data);
    hash_table->data = NULL;
  }

  free(hash_table);

  return 0;
}

static int
bitcache_set_hash_clear(bitcache_set_t* set) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  bitcache_set_wrlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    g_hash_table_remove_all(hash_table->data);
  }
  bitcache_set_unlock(hash_table);

  return 0;
}

static long
bitcache_set_hash_count(bitcache_set_t* set) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  long count = 0;

  bitcache_set_rdlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    count += g_hash_table_size(hash_table->data);
  }
  bitcache_set_unlock(hash_table);

  return count;
}

static bool
bitcache_set_hash_lookup(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  bool found = FALSE;

  bitcache_set_rdlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    found = g_hash_table_lookup_extended(hash_table->data, id, NULL, NULL);
  }
  bitcache_set_unlock(hash_table);

  return found;
}

static int
bitcache_set_hash_insert(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  bitcache_set_wrlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    g_hash_table_insert(hash_table->data, (void*)id, NULL);
  }
  else {
    assert(hash_table->data != NULL);
  }
  bitcache_set_unlock(hash_table);

  return 0;
}

static int
bitcache_set_hash_remove(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  bitcache_set_wrlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    g_hash_table_remove(hash_table->data, (void*)id);
  }
  bitcache_set_unlock(hash_table);

  return 0;
}

static int
bitcache_set_hash_replace(bitcache_set_t* set, const bitcache_id_t* restrict id1, const bitcache_id_t* restrict id2) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  bitcache_set_wrlock(hash_table);
  if (likely(hash_table->data != NULL)) {
    g_hash_table_remove(hash_table->data, (void*)id1);
    if (likely(id2 != NULL)) {
      g_hash_table_insert(hash_table->data, (void*)id2, NULL);
    }
  }
  bitcache_set_unlock(hash_table);

  return 0;
}

const bitcache_set_class_t bitcache_set_hash = {
  .super   = NULL,
  .name    = "bitcache_set_hash",
  .options = 0,
  .free    = bitcache_set_free,
  .init    = bitcache_set_hash_init,
  .reset   = bitcache_set_hash_reset,
  .clear   = bitcache_set_hash_clear,
  .count   = bitcache_set_hash_count,
  .lookup  = bitcache_set_hash_lookup,
  .insert  = bitcache_set_hash_insert,
  .remove  = bitcache_set_hash_remove,
  .replace = bitcache_set_hash_replace,
};

//////////////////////////////////////////////////////////////////////////////
// Set Iterator API (hash table implementation)

static int
bitcache_set_iter_hash_init(bitcache_set_iter_t* iter, bitcache_set_t* restrict set) {
  bitcache_set_hash_t* hash_table = set->instance;
  assert(hash_table != NULL);

  GHashTableIter* hash_table_iter = malloc(sizeof(GHashTableIter));
  assert(hash_table_iter != NULL);
  g_hash_table_iter_init(hash_table_iter, hash_table->data);

  iter->instance = hash_table_iter;

  return 0;
}

static int
bitcache_set_iter_hash_reset(bitcache_set_iter_t* iter) {
  GHashTableIter* hash_table_iter = iter->instance;
  assert(hash_table_iter != NULL);

  iter->instance = NULL;

#ifndef NDEBUG
  bzero(hash_table_iter, sizeof(GHashTableIter));
  bzero(iter, sizeof(bitcache_set_iter_t));
#endif

  free(hash_table_iter);

  return 0;
}

static bool
bitcache_set_iter_hash_next(bitcache_set_iter_t* iter) {
  GHashTableIter* hash_table_iter = iter->instance;
  assert(hash_table_iter != NULL);

  bool more = FALSE;

  if (likely(g_hash_table_iter_next(hash_table_iter, (void**)&iter->id, NULL) != FALSE)) {
    iter->position++;
    more = TRUE;
  }

  return more;
}

static int
bitcache_set_iter_hash_remove(bitcache_set_iter_t* iter) {
  GHashTableIter* hash_table_iter = iter->instance;
  assert(hash_table_iter != NULL);

  return g_hash_table_iter_remove(hash_table_iter), 0;
}

const bitcache_set_iter_class_t bitcache_set_iter_hash = {
  .super   = NULL,
  .name    = "bitcache_set_iter_hash",
  .options = 0,
  .init    = bitcache_set_iter_hash_init,
  .reset   = bitcache_set_iter_hash_reset,
  .next    = bitcache_set_iter_hash_next,
  .remove  = bitcache_set_iter_hash_remove,
};
