/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_SET_H
#define _BITCACHE_SET_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <glib.h>

typedef struct {
  GHashTable* hash_table;
  //bitcache_filter_t filter; // TODO
#ifdef HAVE_PTHREAD_H
  rwlock_t lock;
#endif
} bitcache_set_t;

typedef struct {
  long position;
  bitcache_set_t* set;
  GHashTableIter hash_table_iter;
} bitcache_set_iter_t;

extern int bitcache_set_init(bitcache_set_t* set, const GDestroyNotify id_destroy_func);
extern int bitcache_set_reset(bitcache_set_t* set);
extern int bitcache_set_clear(bitcache_set_t* set);
extern long bitcache_set_count(bitcache_set_t* set);
extern bool bitcache_set_lookup(bitcache_set_t* set, const bitcache_id_t* id);
extern int bitcache_set_insert(bitcache_set_t* set, const bitcache_id_t* id);
extern int bitcache_set_remove(bitcache_set_t* set, const bitcache_id_t* id);
extern int bitcache_set_replace(bitcache_set_t* set, const bitcache_id_t* id1, const bitcache_id_t* id2);

extern int bitcache_set_iter_init(bitcache_set_iter_t* iter, bitcache_set_t* set);
extern bool bitcache_set_iter_next(bitcache_set_iter_t* iter, bitcache_id_t** id);
extern int bitcache_set_iter_remove(bitcache_set_iter_t* iter);
extern int bitcache_set_iter_done(bitcache_set_iter_t* iter);

#ifdef HAVE_PTHREAD_H
#define BITCACHE_SET_LOCK_INITIALIZER RWLOCK_INIT
#define bitcache_set_crlock(set)      rwlock_init(&(set)->lock)
#define bitcache_set_rmlock(set)      rwlock_dispose(&(set)->lock)
#define bitcache_set_rdlock(set)      pthread_rwlock_rdlock(&(set)->lock.id)
#define bitcache_set_wrlock(set)      pthread_rwlock_wrlock(&(set)->lock.id)
#define bitcache_set_unlock(set)      pthread_rwlock_unlock(&(set)->lock.id)
#else
#define bitcache_set_crlock(set)
#define bitcache_set_rmlock(set)
#define bitcache_set_rdlock(set)
#define bitcache_set_wrlock(set)
#define bitcache_set_unlock(set)
#endif /* HAVE_PTHREAD_H */

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_SET_H */
