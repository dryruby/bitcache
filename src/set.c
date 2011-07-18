/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include "set_hash.h"

//////////////////////////////////////////////////////////////////////////////
// Set API

bitcache_set_t*
bitcache_set_alloc() {
  bitcache_set_t* set = malloc(sizeof(bitcache_set_t));
  bitcache_set_init(set, NULL);
  return set;
}

void
bitcache_set_free(bitcache_set_t* set) {
  if (likely(set != NULL)) {
    bitcache_set_reset(set);
    free(set);
  }
}

int
bitcache_set_init(bitcache_set_t* set, const bitcache_set_class_t* restrict class) {
  validate_with_errno_return(set != NULL);

  bzero(set, sizeof(bitcache_set_t));
  set->class = class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_init(set);

  if (likely(class->init != NULL)) // virtual dispatch
    return class->init(set);

  return 0;
}

int
bitcache_set_reset(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_reset(set);

  if (likely(class->reset != NULL)) // virtual dispatch
    return class->reset(set);

  return -(errno = ENOTSUP); // operation not supported
}

int
bitcache_set_clear(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_clear(set);

  if (likely(class->clear != NULL)) // virtual dispatch
    return class->clear(set);

  return -(errno = ENOTSUP); // operation not supported
}

long
bitcache_set_count(bitcache_set_t* set) {
  validate_with_errno_return(set != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_count(set);

  if (likely(class->count != NULL)) // virtual dispatch
    return class->count(set);

  return -(errno = ENOTSUP); // operation not supported
}

bool
bitcache_set_lookup(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  validate_with_false_return(set != NULL && id != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_lookup(set, id);

  if (likely(class->lookup != NULL)) // virtual dispatch
    return class->lookup(set, id);

  return (errno = ENOTSUP), FALSE; // operation not supported
}

int
bitcache_set_insert(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  validate_with_errno_return(set != NULL && id != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_insert(set, id);

  if (likely(class->insert != NULL)) // virtual dispatch
    return class->insert(set, id);

  return -(errno = ENOTSUP); // operation not supported
}

int
bitcache_set_remove(bitcache_set_t* set, const bitcache_id_t* restrict id) {
  validate_with_errno_return(set != NULL && id != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_remove(set, id);

  if (likely(class->remove != NULL)) // virtual dispatch
    return class->remove(set, id);

  return -(errno = ENOTSUP); // operation not supported
}

int
bitcache_set_replace(bitcache_set_t* set, const bitcache_id_t* restrict id1, const bitcache_id_t* restrict id2) {
  validate_with_errno_return(set != NULL && id1 != NULL);

  const bitcache_set_class_t* const class = set->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_hash_replace(set, id1, id2);

  if (likely(class->replace != NULL)) // virtual dispatch
    return class->replace(set, id1, id2);

  return -(errno = ENOTSUP); // operation not supported
}

//////////////////////////////////////////////////////////////////////////////
// Set Iterator API

int
bitcache_set_iter_init(bitcache_set_iter_t* iter, const bitcache_set_iter_class_t* restrict class, bitcache_set_t* set) {
  validate_with_errno_return(iter != NULL && set != NULL);

  bzero(iter, sizeof(bitcache_set_iter_t));
  iter->class = class;
  iter->set   = set;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_iter_hash_init(iter, set);

  if (likely(class->init != NULL)) // virtual dispatch
    return class->init(iter, set);

  return 0;
}

int
bitcache_set_iter_reset(bitcache_set_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->set != NULL);

  const bitcache_set_iter_class_t* const class = iter->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_iter_hash_reset(iter);

  if (likely(class->reset != NULL)) // virtual dispatch
    return class->reset(iter);

  return -(errno = ENOTSUP); // operation not supported
}

bool
bitcache_set_iter_next(bitcache_set_iter_t* iter) {
  validate_with_false_return(iter != NULL && iter->set != NULL);

  const bitcache_set_iter_class_t* const class = iter->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_iter_hash_next(iter);

  if (likely(class->next != NULL)) // virtual dispatch
    return class->next(iter);

  return (errno = ENOTSUP), FALSE; // operation not supported
}

int
bitcache_set_iter_remove(bitcache_set_iter_t* iter) {
  validate_with_errno_return(iter != NULL && iter->set != NULL);

  const bitcache_set_iter_class_t* const class = iter->class;

  if (likely(class == NULL)) // static dispatch
    return bitcache_set_iter_hash_remove(iter);

  if (likely(class->remove != NULL)) // virtual dispatch
    return class->remove(iter);

  return -(errno = ENOTSUP); // operation not supported
}
