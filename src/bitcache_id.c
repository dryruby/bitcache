/* This is free and unencumbered software released into the public domain. */

#include "bitcache_arch.h"
#include "bitcache_id.h"
#include "config.h"
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <strings.h>

//////////////////////////////////////////////////////////////////////////////
// Identifier API

int HOT
bitcache_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  if (unlikely(id1 == NULL || id2 == NULL))
    return -(errno = EINVAL); // invalid argument

  return unlikely(id1 == id2) ? 0 : memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t));
}
