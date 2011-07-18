/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_MAP_H
#define _BITCACHE_MAP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <glib.h>

#ifdef HAVE_PTHREAD_H
//#define BITCACHE_MAP_MUTEX  TRUE
#define BITCACHE_MAP_RWLOCK TRUE
#endif

typedef struct {
  GHashTable* hash_table;
#if defined(BITCACHE_MAP_MUTEX)
  mutex_t lock;
#elif defined(BITCACHE_MAP_RWLOCK)
  rwlock_t lock;
#endif
} bitcache_map_t;

typedef struct {
  int position;
  bitcache_map_t* map;
  GHashTableIter hash_table_iter;
} bitcache_map_iter_t;

extern int bitcache_map_init(bitcache_map_t* map, const GDestroyNotify key_destroy_func, const GDestroyNotify value_destroy_func);
extern int bitcache_map_reset(bitcache_map_t* map);
extern int bitcache_map_clear(bitcache_map_t* map);
extern ssize_t bitcache_map_count(bitcache_map_t* map);
extern bool bitcache_map_lookup(bitcache_map_t* map, const bitcache_id_t* key, void** value);
extern int bitcache_map_insert(bitcache_map_t* map, const bitcache_id_t* key, const void* value);
extern int bitcache_map_remove(bitcache_map_t* map, const bitcache_id_t* key);

extern int bitcache_map_iter_init(bitcache_map_iter_t* iter, bitcache_map_t* map);
extern bool bitcache_map_iter_next(bitcache_map_iter_t* iter, bitcache_id_t** key, void** value);
extern int bitcache_map_iter_remove(bitcache_map_iter_t* iter);
extern int bitcache_map_iter_done(bitcache_map_iter_t* iter);

#if defined(BITCACHE_MAP_MUTEX)
#define BITCACHE_MAP_LOCK_INIT   MUTEX_INIT
#define bitcache_map_crlock(map) mutex_init(&(map)->lock)
#define bitcache_map_rmlock(map) mutex_dispose(&(map)->lock)
#define bitcache_map_rdlock(map) mutex_lock(&(map)->lock)
#define bitcache_map_wrlock(map) mutex_lock(&(map)->lock)
#define bitcache_map_unlock(map) mutex_unlock(&(map)->lock)
#elif defined(BITCACHE_MAP_RWLOCK)
#define BITCACHE_MAP_LOCK_INIT   RWLOCK_INIT
#define bitcache_map_crlock(map) rwlock_init(&(map)->lock)
#define bitcache_map_rmlock(map) rwlock_dispose(&(map)->lock)
#define bitcache_map_rdlock(map) rwlock_rdlock(&(map)->lock)
#define bitcache_map_wrlock(map) rwlock_wrlock(&(map)->lock)
#define bitcache_map_unlock(map) rwlock_unlock(&(map)->lock)
#else
#define BITCACHE_MAP_LOCK_INIT   NULL
#define bitcache_map_crlock(map)
#define bitcache_map_rmlock(map)
#define bitcache_map_rdlock(map)
#define bitcache_map_wrlock(map)
#define bitcache_map_unlock(map)
#endif /* HAVE_PTHREAD_H */

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_MAP_H */
