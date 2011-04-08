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

int
bitcache_id_cmp(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  return unlikely(id1 == id2) ? 0 : memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t));
}
