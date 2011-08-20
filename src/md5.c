/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <string.h>      /* for strlen() */

#ifdef HAVE_OPENSSL_SHA_H
#include <openssl/md5.h> /* for MD5() */
#else
#include <glib.h>        /* for g_checksum_*() */
#endif

//////////////////////////////////////////////////////////////////////////////
// Digest API: MD5

#ifndef HAVE_OPENSSL_SHA_H
static __thread GChecksum* bitcache_md5_checksum = NULL;
#endif

int
bitcache_md5(const uint8_t* restrict data, const ssize_t size, bitcache_md5_t* restrict md5) {
  validate_with_errno_return(data != NULL && size >= -1 && md5 != NULL);

#ifdef HAVE_OPENSSL_SHA_H
  MD5(data, unlikely(size == -1) ? strlen((char*)data) : (unsigned long)size, (uint8_t*)md5);
#else
  if (unlikely(bitcache_md5_checksum == NULL)) { // once only
    bitcache_md5_checksum = g_checksum_new(G_CHECKSUM_MD5);
  }
  gsize digest_size = sizeof(bitcache_md5_t);
  g_checksum_reset(bitcache_md5_checksum);
  g_checksum_update(bitcache_md5_checksum, (guchar*)data, size);
  g_checksum_get_digest(bitcache_md5_checksum, (guint8*)md5, &digest_size);
#endif /* HAVE_OPENSSL_SHA_H */

  return 0;
}
