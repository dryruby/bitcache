/* This is free and unencumbered software released into the public domain. */

#include "bitcache_arch.h"
#include "bitcache_tree.h"
#include "config.h"
#include <assert.h>
#include <errno.h>
#include <strings.h>

//////////////////////////////////////////////////////////////////////////////
// Tree API

static int
bitcache_tree_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2, const void* user_data) {
  return bitcache_id_compare(id1, id2);
}

int
bitcache_tree_init(bitcache_tree_t* tree, const GDestroyNotify key_destroy_func, const GDestroyNotify value_destroy_func) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(tree, sizeof(bitcache_tree_t));
  tree->g_tree = g_tree_new_full((GCompareDataFunc)bitcache_tree_id_compare, NULL, key_destroy_func, value_destroy_func);
  bitcache_tree_crlock(tree);

  return 0;
}

int
bitcache_tree_reset(bitcache_tree_t* tree) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  bitcache_tree_rmlock(tree);
  if (likely(tree->g_tree != NULL)) {
    g_tree_destroy(tree->g_tree), tree->g_tree = NULL;
  }

  return 0;
}

int
bitcache_tree_clear(bitcache_tree_t* tree) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  bitcache_tree_wrlock(tree);
  if (likely(tree->g_tree != NULL)) {
    g_tree_ref(tree->g_tree);
    g_tree_destroy(tree->g_tree);
  }
  bitcache_tree_unlock(tree);

  return 0;
}

ssize_t
bitcache_tree_size(bitcache_tree_t* tree) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  ssize_t size = 0;

  bitcache_tree_rdlock(tree);
  if (likely(tree->g_tree != NULL)) {
    int count = g_tree_nnodes(tree->g_tree);
    size += count * (sizeof(void*) * 5); // sizeof(_GTreeNode)
  }
  bitcache_tree_unlock(tree);

  return size;
}

ssize_t
bitcache_tree_count(bitcache_tree_t* tree) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  ssize_t count = 0;

  bitcache_tree_rdlock(tree);
  if (likely(tree->g_tree != NULL)) {
    count = g_tree_nnodes(tree->g_tree);
  }
  bitcache_tree_unlock(tree);

  return count;
}

int
bitcache_tree_height(bitcache_tree_t* tree) {
  if (unlikely(tree == NULL))
    return -(errno = EINVAL); // invalid argument

  int height = 0;

  bitcache_tree_rdlock(tree);
  if (likely(tree->g_tree != NULL)) {
    height = g_tree_height(tree->g_tree);
  }
  bitcache_tree_unlock(tree);

  return height;
}

bool
bitcache_tree_lookup(bitcache_tree_t* tree, const bitcache_id_t* key, void** value) {
  if (unlikely(tree == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  bool found = FALSE;

  bitcache_tree_rdlock(tree);
  if (likely(tree->g_tree != NULL)) {
    found = g_tree_lookup_extended(tree->g_tree, key, NULL, value);
  }
  bitcache_tree_unlock(tree);

  return found;
}

int
bitcache_tree_insert(bitcache_tree_t* tree, const bitcache_id_t* key, const void* value) {
  if (unlikely(tree == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  bitcache_tree_wrlock(tree);
  assert(tree->g_tree != NULL);
  g_tree_insert(tree->g_tree, (void*)key, (void*)value);
  bitcache_tree_unlock(tree);

  return 0;
}

int
bitcache_tree_remove(bitcache_tree_t* tree, const bitcache_id_t* key) {
  if (unlikely(tree == NULL || key == NULL))
    return -(errno = EINVAL); // invalid argument

  bitcache_tree_wrlock(tree);
  if (likely(tree->g_tree != NULL)) {
    g_tree_remove(tree->g_tree, (void*)key);
  }
  bitcache_tree_unlock(tree);

  return 0;
}

//////////////////////////////////////////////////////////////////////////////
// Tree Iterator API

int
bitcache_tree_iter_init(bitcache_tree_iter_t* iter, bitcache_tree_t* tree) {
  if (unlikely(iter == NULL || tree == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(iter, sizeof(bitcache_tree_iter_t));
  iter->tree = tree;

  // prevent any mutations to the tree while iterating over it:
  bitcache_tree_rdlock(iter->tree);

  return 0;
}

int
bitcache_tree_iter_next(bitcache_tree_iter_t* iter, bitcache_id_t** key, void** value) {
  if (unlikely(iter == NULL || iter->tree == NULL))
    return -(errno = EINVAL); // invalid argument

  int result = 0;

  // TODO: use g_tree_foreach() together with setjmp()/longjmp() ?

  return result;
}

int
bitcache_tree_iter_remove(bitcache_tree_iter_t* iter) {
  if (unlikely(iter == NULL || iter->tree == NULL))
    return -(errno = EINVAL); // invalid argument

  // TODO: mark the current node for removal.

  return 0;
}

int
bitcache_tree_iter_done(bitcache_tree_iter_t* iter) {
  if (unlikely(iter == NULL || iter->tree == NULL))
    return -(errno = EINVAL); // invalid argument

  // release the read lock obtained in bitcache_tree_iter_init():
  bitcache_tree_unlock(iter->tree);

  if (FALSE) {
    bitcache_tree_wrlock(iter->tree);
    // TODO: remove all nodes marked for removal.
    bitcache_tree_unlock(iter->tree);
  }

  bzero(iter, sizeof(bitcache_tree_iter_t));

  return 0;
}
