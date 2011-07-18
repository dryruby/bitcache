/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_TREE_H
#define _BITCACHE_TREE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <glib.h>

#ifdef HAVE_PTHREAD_H
//#define BITCACHE_TREE_MUTEX  TRUE
#define BITCACHE_TREE_RWLOCK TRUE
#endif

typedef struct {
  GTree* g_tree;
#if defined(BITCACHE_TREE_MUTEX)
  mutex_t lock;
#elif defined(BITCACHE_TREE_RWLOCK)
  rwlock_t lock;
#endif
} bitcache_tree_t;

typedef struct {
  int position;
  bitcache_tree_t* tree;
} bitcache_tree_iter_t;

extern int bitcache_tree_init(bitcache_tree_t* tree, const GDestroyNotify key_destroy_func, const GDestroyNotify value_destroy_func);
extern int bitcache_tree_reset(bitcache_tree_t* tree);
extern int bitcache_tree_clear(bitcache_tree_t* tree);
extern ssize_t bitcache_tree_size(bitcache_tree_t* tree);
extern ssize_t bitcache_tree_count(bitcache_tree_t* tree);
extern int bitcache_tree_height(bitcache_tree_t* tree);
extern bool bitcache_tree_lookup(bitcache_tree_t* tree, const bitcache_id_t* key, void** value);
extern int bitcache_tree_insert(bitcache_tree_t* tree, const bitcache_id_t* key, const void* value);
extern int bitcache_tree_remove(bitcache_tree_t* tree, const bitcache_id_t* key);

extern int bitcache_tree_iter_init(bitcache_tree_iter_t* iter, bitcache_tree_t* tree);
extern int bitcache_tree_iter_next(bitcache_tree_iter_t* iter, bitcache_id_t** key, void** value);
extern int bitcache_tree_iter_remove(bitcache_tree_iter_t* iter);
extern int bitcache_tree_iter_done(bitcache_tree_iter_t* iter);

#ifndef HAVE_PTHREAD_H
#define BITCACHE_TREE_LOCK_INIT    NULL
#define bitcache_tree_crlock(tree)
#define bitcache_tree_rmlock(tree)
#define bitcache_tree_rdlock(tree)
#define bitcache_tree_wrlock(tree)
#define bitcache_tree_unlock(tree)
#else
#if defined(BITCACHE_TREE_MUTEX)
#define BITCACHE_TREE_LOCK_INIT    MUTEX_INIT
#define bitcache_tree_crlock(tree) mutex_init(&(tree)->lock)
#define bitcache_tree_rmlock(tree) mutex_dispose(&(tree)->lock)
#define bitcache_tree_rdlock(tree) mutex_lock(&(tree)->lock)
#define bitcache_tree_wrlock(tree) mutex_lock(&(tree)->lock)
#define bitcache_tree_unlock(tree) mutex_unlock(&(tree)->lock)
#elif defined(BITCACHE_TREE_RWLOCK)
#define BITCACHE_TREE_LOCK_INIT    RWLOCK_INIT
#define bitcache_tree_crlock(tree) rwlock_init(&(tree)->lock)
#define bitcache_tree_rmlock(tree) rwlock_dispose(&(tree)->lock)
#define bitcache_tree_rdlock(tree) rwlock_rdlock(&(tree)->lock)
#define bitcache_tree_wrlock(tree) rwlock_wrlock(&(tree)->lock)
#define bitcache_tree_unlock(tree) rwlock_unlock(&(tree)->lock)
#endif
#endif /* HAVE_PTHREAD_H */

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_TREE_H */
