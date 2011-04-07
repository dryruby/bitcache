/* This is free and unencumbered software released into the public domain. */

#include "bitcache_arch.h"
#include "bitcache_map.h"
#include "config.h"
#include <assert.h>
#include <errno.h>
#include <strings.h>

//////////////////////////////////////////////////////////////////////////////
// Map API

int
bitcache_map_init(bitcache_map_t* map, const GHashFunc hash_func, const GEqualFunc equal_func, const GDestroyNotify key_destroy_func, const GDestroyNotify value_destroy_func) {
  if (unlikely(map == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(map, sizeof(bitcache_map_t));
  map->striping = BITCACHE_MAP_STRIPES;

  for (int i = 0; i < map->striping; i++) {
    bitcache_map_stripe_t* map_stripe = &map->stripes[i];

    bitcache_map_stripe_crlock(map_stripe);
    map_stripe->hash_table = g_hash_table_new_full(
      (hash_func != NULL) ? hash_func : g_direct_hash,
      (equal_func != NULL) ? equal_func : g_direct_equal,
      key_destroy_func, value_destroy_func);
  }

  return 0;
}

int
bitcache_map_reset(bitcache_map_t* map) {
  if (unlikely(map == NULL))
    return -(errno = EINVAL); // invalid argument

  for (int i = 0; i < map->striping; i++) {
    bitcache_map_stripe_t* map_stripe = &map->stripes[i];

    bitcache_map_stripe_rmlock(map_stripe);
    if (map_stripe->hash_table != NULL) {
      g_hash_table_destroy(map_stripe->hash_table);
      map_stripe->hash_table = NULL;
    }
  }

  map->striping = 0;

  return 0;
}

int
bitcache_map_clear(bitcache_map_t* map) {
  if (unlikely(map == NULL))
    return -(errno = EINVAL); // invalid argument

  for (int i = 0; i < map->striping; i++) {
    bitcache_map_stripe_t* map_stripe = &map->stripes[i];

    bitcache_map_stripe_wrlock(map_stripe);
    if (map_stripe->hash_table != NULL) {
      g_hash_table_remove_all(map_stripe->hash_table);
    }
    bitcache_map_stripe_unlock(map_stripe);
  }

  return 0;
}

ssize_t
bitcache_map_count(bitcache_map_t* map) {
  if (unlikely(map == NULL))
    return -(errno = EINVAL); // invalid argument

  ssize_t count = 0;

  for (int i = 0; i < map->striping; i++) {
    bitcache_map_stripe_t* map_stripe = &map->stripes[i];

    bitcache_map_stripe_rdlock(map_stripe);
    if (map_stripe->hash_table != NULL) {
      count += g_hash_table_size(map_stripe->hash_table);
    }
    bitcache_map_stripe_unlock(map_stripe);
  }

  return count;
}

bool
bitcache_map_lookup(bitcache_map_t* map, const bitcache_id_t* key, void** value) {
  if (unlikely(map == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  bool found = FALSE;

  const int shard = (key->digest[0] & (map->striping - 1));
  bitcache_map_stripe_t* map_stripe = &map->stripes[shard];

  bitcache_map_stripe_rdlock(map_stripe);
  if (map_stripe->hash_table != NULL) {
    found = g_hash_table_lookup_extended(map_stripe->hash_table, key, NULL, value);
  }
  bitcache_map_stripe_unlock(map_stripe);

  return found;
}

int
bitcache_map_insert(bitcache_map_t* map, const bitcache_id_t* key, const void* value) {
  if (unlikely(map == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  const int shard = (key->digest[0] & (map->striping - 1));
  bitcache_map_stripe_t* map_stripe = &map->stripes[shard];

  bitcache_map_stripe_wrlock(map_stripe);
  g_hash_table_insert(map_stripe->hash_table, (void*)key, (void*)value);
  bitcache_map_stripe_unlock(map_stripe);

  return 0;
}

int
bitcache_map_remove(bitcache_map_t* map, const bitcache_id_t* key) {
  if (unlikely(map == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  const int shard = (key->digest[0] & (map->striping - 1));
  bitcache_map_stripe_t* map_stripe = &map->stripes[shard];

  bitcache_map_stripe_wrlock(map_stripe);
  if (map_stripe->hash_table != NULL) {
    g_hash_table_remove(map_stripe->hash_table, (void*)key);
  }
  bitcache_map_stripe_unlock(map_stripe);

  return 0;
}

//////////////////////////////////////////////////////////////////////////////
// Map Iterator API

int
bitcache_map_iter_init(bitcache_map_iter_t* iter, bitcache_map_t* map) {
  if (unlikely(iter == NULL || map == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(iter, sizeof(bitcache_map_iter_t));
  iter->map    = map;
  iter->stripe = 0;

  bitcache_map_stripe_t* map_stripe = &map->stripes[iter->stripe];
  g_hash_table_iter_init(&iter->hash_table_iter, map_stripe->hash_table);

  return 0;
}

int
bitcache_map_iter_next(bitcache_map_iter_t* iter, bitcache_id_t** key, void** value) {
  if (unlikely(iter == NULL))
    return -(errno = EINVAL); // invalid argument

  int result = 0;

  if (likely(g_hash_table_iter_next(&iter->hash_table_iter, (void**)key, value) != FALSE)) {
    result = 1;
  }
  else {
    while (++iter->stripe < iter->map->striping) {
      if (likely(g_hash_table_iter_next(&iter->hash_table_iter, (void**)key, value) != FALSE)) {
        result = 1;
        break;
      }
    }
  }

  return result;
}

int
bitcache_map_iter_remove(bitcache_map_iter_t* iter) {
  if (unlikely(iter == NULL))
    return -(errno = EINVAL); // invalid argument

  g_hash_table_iter_remove(&iter->hash_table_iter);

  return 0;
}

int
bitcache_map_iter_done(bitcache_map_iter_t* iter) {
  if (unlikely(iter == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(iter, sizeof(bitcache_map_iter_t));

  return 0;
}
