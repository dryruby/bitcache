/* This is free and unencumbered software released into the public domain. */

#ifndef BITCACHE_MAP_H
#define BITCACHE_MAP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <string.h>
#include <glib.h>
#ifdef MT
#include <pthread.h>
#endif

#define BITCACHE_MAP_STRIPES 1 /* must be a power of 2 */

#ifdef MT
//#define BITCACHE_MAP_MUTEX  TRUE
#define BITCACHE_MAP_RWLOCK TRUE
#endif

typedef struct {
  GHashTable* hash_table;
#if defined(BITCACHE_MAP_MUTEX)
  pthread_mutex_t lock;
#elif defined(BITCACHE_MAP_RWLOCK)
  pthread_rwlock_t lock;
#endif
} bitcache_map_stripe_t;

typedef struct {
  int striping;
  bitcache_map_stripe_t stripes[BITCACHE_MAP_STRIPES];
} bitcache_map_t;

typedef struct {
  int stripe;
} bitcache_map_iter_t;

#if defined(BITCACHE_MAP_MUTEX)
#define bitcache_map_stripe_crlock(map_stripe) pthread_mutex_init(&(map_stripe)->lock, NULL)
#define bitcache_map_stripe_rmlock(map_stripe) pthread_mutex_destroy(&(map_stripe)->lock)
#define bitcache_map_stripe_rdlock(map_stripe) pthread_mutex_lock(&(map_stripe)->lock)
#define bitcache_map_stripe_wrlock(map_stripe) pthread_mutex_lock(&(map_stripe)->lock)
#define bitcache_map_stripe_unlock(map_stripe) pthread_mutex_unlock(&(map_stripe)->lock)
#elif defined(BITCACHE_MAP_RWLOCK)
#define bitcache_map_stripe_crlock(map_stripe) pthread_rwlock_init(&(map_stripe)->lock, NULL)
#define bitcache_map_stripe_rmlock(map_stripe) pthread_rwlock_destroy(&(map_stripe)->lock)
#define bitcache_map_stripe_rdlock(map_stripe) pthread_rwlock_rdlock(&(map_stripe)->lock)
#define bitcache_map_stripe_wrlock(map_stripe) pthread_rwlock_wrlock(&(map_stripe)->lock)
#define bitcache_map_stripe_unlock(map_stripe) pthread_rwlock_unlock(&(map_stripe)->lock)
#endif

extern int bitcache_map_init(bitcache_map_t* map, const GHashFunc hash_func, const GEqualFunc equal_func, const GDestroyNotify key_destroy_func, const GDestroyNotify value_destroy_func);
extern int bitcache_map_reset(bitcache_map_t* map);
extern int bitcache_map_clear(bitcache_map_t* map);
extern ssize_t bitcache_map_count(bitcache_map_t* map);
extern bool bitcache_map_lookup(bitcache_map_t* map, const char* key, void** value);
extern int bitcache_map_insert(bitcache_map_t* map, const char* key, const void* value);
extern int bitcache_map_remove(bitcache_map_t* map, const char* key);

#ifdef __cplusplus
}
#endif

#endif /* BITCACHE_MAP_H */
