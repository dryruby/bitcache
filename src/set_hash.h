/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h> /* for assert() */

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

static int
bitcache_set_hash_init(bitcache_set_t* set) {
  bitcache_set_crlock(set);
  set->hash_table = g_hash_table_new_full(
    (GHashFunc)bitcache_id_hash,
    (GEqualFunc)bitcache_id_equal,
    (free_func_t)free, // FIXME
    (free_func_t)NULL);

  return 0;
}

static int
bitcache_set_hash_reset(bitcache_set_t* set) {
  bitcache_set_rmlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_destroy(set->hash_table);
    set->hash_table = NULL;
  }

  return 0;
}

static int
bitcache_set_hash_clear(bitcache_set_t* set) {
  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_remove_all(set->hash_table);
  }
  bitcache_set_unlock(set);

  return 0;
}

static long
bitcache_set_hash_count(bitcache_set_t* set) {
  long count = 0;

  bitcache_set_rdlock(set);
  if (likely(set->hash_table != NULL)) {
    count += g_hash_table_size(set->hash_table);
  }
  bitcache_set_unlock(set);

  return count;
}

static bool
bitcache_set_hash_lookup(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bool found = FALSE;

  bitcache_set_rdlock(set);
  if (likely(set->hash_table != NULL)) {
    found = g_hash_table_lookup_extended(set->hash_table, id, NULL, NULL);
  }
  bitcache_set_unlock(set);

  return found;
}

static int
bitcache_set_hash_insert(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_insert(set->hash_table, (void*)id, NULL);
  }
  else {
    assert(set->hash_table != NULL);
  }
  bitcache_set_unlock(set);

  return 0;
}

static int
bitcache_set_hash_remove(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_remove(set->hash_table, (void*)id);
  }
  bitcache_set_unlock(set);

  return 0;
}

static int
bitcache_set_hash_replace(bitcache_set_t* set, const bitcache_id_t* restrict id1, const bitcache_id_t* restrict id2) {
  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_remove(set->hash_table, (void*)id1);
    if (likely(id2 != NULL)) {
      g_hash_table_insert(set->hash_table, (void*)id2, NULL);
    }
  }
  bitcache_set_unlock(set);

  return 0;
}

const bitcache_set_class_t bitcache_set_hash = {
  .super   = NULL,
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
  g_hash_table_iter_init(&iter->hash_table_iter, set->hash_table);
  return 0;
}

static int
bitcache_set_iter_hash_reset(bitcache_set_iter_t* iter) {
#ifndef NDEBUG
  bzero(iter, sizeof(bitcache_set_iter_t));
#endif
  return 0;
}

static bool
bitcache_set_iter_hash_next(bitcache_set_iter_t* iter) {
  bool more = FALSE;

  if (likely(g_hash_table_iter_next(&iter->hash_table_iter, (void**)&iter->id, NULL) != FALSE)) {
    iter->position++;
    more = TRUE;
  }

  return more;
}

static int
bitcache_set_iter_hash_remove(bitcache_set_iter_t* iter) {
  g_hash_table_iter_remove(&iter->hash_table_iter);
  return 0;
}

const bitcache_set_iter_class_t bitcache_set_iter_hash = {
  .super   = NULL,
  .init    = bitcache_set_iter_hash_init,
  .reset   = bitcache_set_iter_hash_reset,
  .next    = bitcache_set_iter_hash_next,
  .remove  = bitcache_set_iter_hash_remove,
};
