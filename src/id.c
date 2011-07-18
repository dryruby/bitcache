/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <strings.h>

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

  bitcache_id_t* clone = bitcache_id_alloc();
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
    bcopy(digest, id->digest, sizeof(bitcache_id_t));
  }
}

static inline int8_t bitcache_hex_parse(const char c) PURE;

long
bitcache_id_parse(bitcache_id_t* id, const char* hexstring) {
  validate_with_errno_return(id != NULL && hexstring != NULL);

  char* s = (char*)hexstring;
  for (int i = 0; i< sizeof(bitcache_id_t); i++) {
    int c = (bitcache_hex_parse(s[0]) << 4) | bitcache_hex_parse(s[1]);
    if (unlikely(c & ~0xff))
      return -(errno = EINVAL); // invalid argument
    id->digest[i] = c, s += 2;
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
  for (int i = 0; i< sizeof(bitcache_id_t); i++) {
    uint8_t c = id->digest[i];
    *s++ = hex[c >> 4];
    *s++ = hex[c & 0x0f];
  }
  *s++ = '\0';
  return s - buffer - 1;
}

int
bitcache_id_clear(bitcache_id_t* id) {
  validate_with_errno_return(id != NULL);

  bzero(id, sizeof(bitcache_id_t));
}

int
bitcache_id_fill(bitcache_id_t* id, const uint8_t value) {
  validate_with_errno_return(id != NULL);

  memset(id->digest, value, sizeof(bitcache_id_t));
}

bool HOT
bitcache_id_equal(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  validate_with_false_return(id1 != NULL && id2 != NULL);

  return unlikely(id1 == id2) ? TRUE : (memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t)) == 0);
}

int HOT
bitcache_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  validate_with_errno_return(id1 != NULL && id2 != NULL);

  return unlikely(id1 == id2) ? 0 : memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t));
}

uint32_t HOT
bitcache_id_hash(const bitcache_id_t* id) {
  validate_with_zero_return(id != NULL);

  return *((uint32_t*)id->digest); // the first 4 bytes of the identifier digest
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Internals

static const int8_t bitcache_hex_table[] = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x00..0x0f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x10..0x1f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x20..0x2f
   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1, // 0x30..0x3f
  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x40..0x4f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x50..0x5f
  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x60..0x6f
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0x70..0x7f
};

int8_t
bitcache_hex_parse(const char c) {
  return likely(c >= 0) ? bitcache_hex_table[c] : -1;
}
