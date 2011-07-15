/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h>
#include <errno.h>
#include <strings.h>

//////////////////////////////////////////////////////////////////////////////
// Set API

int
bitcache_set_init(bitcache_set_t* set, const GDestroyNotify id_destroy_func) {
  validate_with_errno_return(set != NULL);

  bzero(set, sizeof(bitcache_set_t));

  bitcache_set_crlock(set);
  set->hash_table = g_hash_table_new_full(
    (GHashFunc)bitcache_id_hash,
    (GEqualFunc)bitcache_id_equal,
    (GDestroyNotify)id_destroy_func,
    NULL);

  return 0;
}

int
bitcache_set_reset(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  bitcache_set_rmlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_destroy(set->hash_table);
    set->hash_table = NULL;
  }

  return 0;
}

int
bitcache_set_clear(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_remove_all(set->hash_table);
  }
  bitcache_set_unlock(set);

  return 0;
}

long
bitcache_set_count(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  long count = 0;

  bitcache_set_rdlock(set);
  if (likely(set->hash_table != NULL)) {
    count += g_hash_table_size(set->hash_table);
  }
  bitcache_set_unlock(set);

  return count;
}

bool
bitcache_set_lookup(bitcache_set_t* set, const bitcache_id_t* id) {
  validate_with_false_return(set != NULL && id != NULL);

  bool found = FALSE;

  bitcache_set_rdlock(set);
  if (likely(set->hash_table != NULL)) {
    found = g_hash_table_lookup_extended(set->hash_table, id, NULL, NULL);
  }
  bitcache_set_unlock(set);

  return found;
}

int
bitcache_set_insert(bitcache_set_t* set, const bitcache_id_t* id) {
  validate_with_errno_return(set != NULL && id != NULL);

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

int
bitcache_set_remove(bitcache_set_t* set, const bitcache_id_t* id) {
  validate_with_errno_return(set != NULL && id != NULL);

  bitcache_set_wrlock(set);
  if (likely(set->hash_table != NULL)) {
    g_hash_table_remove(set->hash_table, (void*)id);
  }
  bitcache_set_unlock(set);

  return 0;
}

int
bitcache_set_replace(bitcache_set_t* set, const bitcache_id_t* id1, const bitcache_id_t* id2) {
  validate_with_errno_return(set != NULL && id1 != NULL);

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

//////////////////////////////////////////////////////////////////////////////
// Set Iterator API

int
bitcache_set_iter_init(bitcache_set_iter_t* iter, bitcache_set_t* set) {
  validate_with_errno_return(iter != NULL && set != NULL);

  bzero(iter, sizeof(bitcache_set_iter_t));
  iter->set = set;
  g_hash_table_iter_init(&iter->hash_table_iter, set->hash_table);

  return 0;
}

bool
bitcache_set_iter_next(bitcache_set_iter_t* iter, bitcache_id_t** id) {
  validate_with_false_return(iter != NULL && iter->set != NULL);

  int more = FALSE;

  if (likely(g_hash_table_iter_next(&iter->hash_table_iter, (void**)id, NULL) != FALSE)) {
    iter->position++;
    more = TRUE;
  }

  return more;
}

int
bitcache_set_iter_remove(bitcache_set_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->set != NULL);

  g_hash_table_iter_remove(&iter->hash_table_iter);

  return 0;
}

int
bitcache_set_iter_done(bitcache_set_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->set != NULL);

  bzero(iter, sizeof(bitcache_set_iter_t));

  return 0;
}
