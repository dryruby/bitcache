/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h>
#include <errno.h>
#include <strings.h>

#if 1
#  define BITCACHE_MAP_LOCK_INIT   MUTEX_INIT
#  define bitcache_map_crlock(map) rwlock_init(&(map)->lock)
#  define bitcache_map_rmlock(map) rwlock_dispose(&(map)->lock)
#  define bitcache_map_rdlock(map) rwlock_rdlock(&(map)->lock)
#  define bitcache_map_wrlock(map) rwlock_wrlock(&(map)->lock)
#  define bitcache_map_unlock(map) rwlock_unlock(&(map)->lock)
#else
#  define BITCACHE_MAP_LOCK_INIT   NULL
#  define bitcache_map_crlock(map)
#  define bitcache_map_rmlock(map)
#  define bitcache_map_rdlock(map)
#  define bitcache_map_wrlock(map)
#  define bitcache_map_unlock(map)
#endif /* HAVE_PTHREAD_H */

//////////////////////////////////////////////////////////////////////////////
// Map API

gboolean bitcache_id_equal_g(const bitcache_id_t* id1, const bitcache_id_t* id2);

int
bitcache_map_init(bitcache_map_t* map, const free_func_t key_destroy_func, const free_func_t value_destroy_func) {
  validate_with_errno_return(map != NULL);

  bzero(map, sizeof(bitcache_map_t));

  bitcache_map_crlock(map);
  map->hash_table = g_hash_table_new_full(
    (GHashFunc)bitcache_id_hash,
    (GEqualFunc)bitcache_id_equal_g,
    key_destroy_func, value_destroy_func);

  return 0;
}

int
bitcache_map_reset(bitcache_map_t* map) {
  validate_with_errno_return(map != NULL);

  bitcache_map_rmlock(map);
  if (likely(map->hash_table != NULL)) {
    g_hash_table_destroy(map->hash_table);
    map->hash_table = NULL;
  }

  return 0;
}

int
bitcache_map_clear(bitcache_map_t* map) {
  validate_with_errno_return(map != NULL);

  bitcache_map_wrlock(map);
  if (likely(map->hash_table != NULL)) {
    g_hash_table_remove_all(map->hash_table);
  }
  bitcache_map_unlock(map);

  return 0;
}

long
bitcache_map_count(bitcache_map_t* map) {
  validate_with_errno_return(map != NULL);

  long count = 0;

  bitcache_map_rdlock(map);
  if (likely(map->hash_table != NULL)) {
    count += g_hash_table_size(map->hash_table);
  }
  bitcache_map_unlock(map);

  return count;
}

bool
bitcache_map_lookup(bitcache_map_t* map, const bitcache_id_t* key, void** value) {
  validate_with_false_return(map != NULL && key != NULL);

  bool found = FALSE;

  bitcache_map_rdlock(map);
  if (likely(map->hash_table != NULL)) {
    found = g_hash_table_lookup_extended(map->hash_table, key, NULL, value);
  }
  bitcache_map_unlock(map);

  return found;
}

int
bitcache_map_insert(bitcache_map_t* map, const bitcache_id_t* key, const void* value) {
  validate_with_errno_return(map != NULL && key != NULL);

  bitcache_map_wrlock(map);
  if (likely(map->hash_table != NULL)) {
    g_hash_table_insert(map->hash_table, (void*)key, (void*)value);
  }
  else {
    assert(map->hash_table != NULL);
  }
  bitcache_map_unlock(map);

  return 0;
}

int
bitcache_map_remove(bitcache_map_t* map, const bitcache_id_t* key) {
  validate_with_errno_return(map != NULL && key != NULL);

  bitcache_map_wrlock(map);
  if (likely(map->hash_table != NULL)) {
    g_hash_table_remove(map->hash_table, (void*)key);
  }
  bitcache_map_unlock(map);

  return 0;
}

//////////////////////////////////////////////////////////////////////////////
// Map Iterator API

int
bitcache_map_iter_init(bitcache_map_iter_t* iter, bitcache_map_t* map) {
  validate_with_errno_return(iter != NULL && map != NULL);

  bzero(iter, sizeof(bitcache_map_iter_t));
  iter->map = map;
  g_hash_table_iter_init(&iter->hash_table_iter, map->hash_table);

  return 0;
}

bool
bitcache_map_iter_next(bitcache_map_iter_t* iter, bitcache_id_t** key, void** value) {
  validate_with_false_return(iter != NULL && iter->map != NULL);

  int more = FALSE;

  if (likely(g_hash_table_iter_next(&iter->hash_table_iter, (void**)key, value) != FALSE)) {
    iter->position++;
    more = TRUE;
  }

  return more;
}

int
bitcache_map_iter_remove(bitcache_map_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->map != NULL);

  g_hash_table_iter_remove(&iter->hash_table_iter);

  return 0;
}

int
bitcache_map_iter_done(bitcache_map_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->map != NULL);

  bzero(iter, sizeof(bitcache_map_iter_t));

  return 0;
}
