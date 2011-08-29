/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <strings.h>

#include <cprime/ascii.h> /* for ascii_xdigit_table */
#include <glib.h>         /* for bitcache_id_equal_g() */

//////////////////////////////////////////////////////////////////////////////
// Identifier API

bitcache_id_t*
bitcache_id_alloc() {
  return calloc(1, sizeof(bitcache_id_t));
}

void
bitcache_id_free(bitcache_id_t* id) {
  if (likely(id != NULL)) {
    free(id);
  }
}

bitcache_id_t*
bitcache_id_clone(const bitcache_id_t* const id) {
  validate_with_null_return(id != NULL);

  bitcache_id_t* clone = malloc(sizeof(bitcache_id_t));
  if (likely(clone != NULL)) {
    bcopy(id, clone, sizeof(bitcache_id_t));
  }
  return clone;
}

int
bitcache_id_init(bitcache_id_t* id, const uint8_t* digest) {
  validate_with_errno_return(id != NULL);

  bzero(id, sizeof(bitcache_id_t));

  if (unlikely(digest != NULL)) {
    bcopy(digest, id->digest.data, sizeof(bitcache_id_t));
  }

  return 0;
}

static inline int8_t
bitcache_hex_parse(const uint8_t c) {
  return CHAR_IS_ASCII(c) ? ascii_xdigit_table[c] : -1;
}

long
bitcache_id_parse(bitcache_id_t* id, const char* hexstring) {
  validate_with_errno_return(id != NULL && hexstring != NULL);

  char* s = (char*)hexstring;
  for (size_t i = 0; i< sizeof(bitcache_id_t); i++) {
    const int c = (bitcache_hex_parse(s[0]) << 4) | bitcache_hex_parse(s[1]);
    if (unlikely(c & ~0xff))
      return -(errno = EINVAL); // invalid argument
    id->digest.data[i] = c, s += 2;
  }
  return s - hexstring;
}

long
bitcache_id_serialize(const bitcache_id_t* id, char* buffer, size_t buffer_size) {
  validate_with_errno_return(id != NULL && buffer != NULL);
  if (unlikely(buffer_size < sizeof(bitcache_id_t) * 2 + 1))
    return -(errno = EOVERFLOW); // buffer overflow

  static const char hex[] = "0123456789abcdef";

  char* s = buffer;
  for (size_t i = 0; i< sizeof(bitcache_id_t); i++) {
    const uint8_t c = id->digest.data[i];
    *s++ = hex[c >> 4];
    *s++ = hex[c & 0x0f];
  }
  *s++ = '\0';
  return s - buffer - 1;
}

long
bitcache_id_print(const bitcache_id_t* id, FILE* restrict stream) {
  validate_with_errno_return(id != NULL);

  char buffer[sizeof(bitcache_id_t) * 2 + 1];
  bitcache_id_serialize(id, buffer, sizeof(buffer));
  fputs(buffer, stream);

  return sizeof(buffer) - 1;
}

int
bitcache_id_clear(bitcache_id_t* id) {
  validate_with_errno_return(id != NULL);

  bzero(id, sizeof(bitcache_id_t));

  return 0;
}

int
bitcache_id_fill(bitcache_id_t* id, const uint8_t value) {
  validate_with_errno_return(id != NULL);

  memset(id->digest.data, value, sizeof(bitcache_id_t));

  return 0;
}

gboolean HOT
bitcache_id_equal_g(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  // This function is needed because sizeof(gboolean) != sizeof(bool);
  // without this wrapper, a compiler optimization level of -O2 or higher
  // will result in GHashTable applying bogus interpretations to the return
  // value of bitcache_id_equal(), and bad consequences follow.
  return bitcache_id_equal(id1, id2);
}

bool HOT
bitcache_id_equal(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  validate_with_false_return(id1 != NULL && id2 != NULL);

  return unlikely(id1 == id2) ? TRUE :
    (memcmp(id1->digest.data, id2->digest.data, sizeof(bitcache_id_t)) == 0);
}

int HOT
bitcache_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  validate_with_errno_return(id1 != NULL && id2 != NULL);

  return unlikely(id1 == id2) ? 0 :
    memcmp(id1->digest.data, id2->digest.data, sizeof(bitcache_id_t));
}

uint32_t HOT
bitcache_id_hash(const bitcache_id_t* id) {
  validate_with_zero_return(id != NULL);

  return id->digest.hash; // the first 4 bytes of the identifier digest
}
