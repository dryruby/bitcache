/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <string.h>      /* for strlen() */

#ifdef HAVE_OPENSSL_SHA_H
#include <openssl/sha.h> /* for SHA1() */
#else
#include <glib.h>        /* for g_checksum_*() */
#endif

//////////////////////////////////////////////////////////////////////////////
// Digest API: SHA-1

#ifndef HAVE_OPENSSL_SHA_H
static __thread GChecksum* bitcache_sha1_checksum = NULL;
#endif

int
bitcache_sha1(const uint8_t* restrict data, const ssize_t size, bitcache_sha1_t* restrict sha1) {
  validate_with_errno_return(data != NULL && size >= -1 && sha1 != NULL);

#ifdef HAVE_OPENSSL_SHA_H
  SHA1(data, unlikely(size == -1) ? strlen((char*)data) : (unsigned long)size, (uint8_t*)sha1);
#else
  if (unlikely(bitcache_sha1_checksum == NULL)) { // once only
    bitcache_sha1_checksum = g_checksum_new(G_CHECKSUM_SHA1);
  }
  gsize digest_size = sizeof(bitcache_sha1_t);
  g_checksum_reset(bitcache_sha1_checksum);
  g_checksum_update(bitcache_sha1_checksum, (guchar*)data, size);
  g_checksum_get_digest(bitcache_sha1_checksum, (guint8*)sha1, &digest_size);
#endif /* HAVE_OPENSSL_SHA_H */

  return 0;
}
