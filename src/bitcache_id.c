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
bitcache_id_init(bitcache_id_t* id, const uint8_t* digest) {
  if (unlikely(id == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(id, sizeof(bitcache_id_t));

  if (unlikely(digest != NULL)) {
    bcopy(digest, id->digest, sizeof(bitcache_id_t));
  }
}

static inline int8_t bitcache_hex_parse(const char c) PURE;

ssize_t
bitcache_id_parse(bitcache_id_t* id, const char* hexstring) {
  if (unlikely(id == NULL || hexstring == NULL))
    return -(errno = EINVAL); // invalid argument

  char* s = (char*)hexstring;
  for (int i = 0; i< sizeof(bitcache_id_t); i++) {
    int c = (bitcache_hex_parse(s[0]) << 4) | bitcache_hex_parse(s[1]);
    if (unlikely(c & ~0xff))
      return -(errno = EINVAL); // invalid argument
    id->digest[i] = c, s += 2;
  }
  return s - hexstring;
}

ssize_t
bitcache_id_serialize(const bitcache_id_t* id, char* buffer, size_t buffer_size) {
  if (unlikely(id == NULL || buffer == NULL))
    return -(errno = EINVAL); // invalid argument
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
  if (unlikely(id == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(id, sizeof(bitcache_id_t));
}

int
bitcache_id_fill(bitcache_id_t* id, const uint8_t value) {
  if (unlikely(id == NULL))
    return -(errno = EINVAL); // invalid argument

  memset(id->digest, value, sizeof(bitcache_id_t));
}

bool HOT
bitcache_id_equal(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  if (unlikely(id1 == NULL || id2 == NULL))
    return errno = EINVAL, FALSE; // invalid argument

  return unlikely(id1 == id2) ? TRUE : (memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t)) == 0);
}

int HOT
bitcache_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2) {
  if (unlikely(id1 == NULL || id2 == NULL))
    return -(errno = EINVAL); // invalid argument

  return unlikely(id1 == id2) ? 0 : memcmp(id1->digest, id2->digest, sizeof(bitcache_id_t));
}

uint32_t HOT
bitcache_id_hash(const bitcache_id_t* id) {
  if (unlikely(id == NULL))
    return errno = EINVAL, 0; // invalid argument

  return *((uint32_t*)id); // the first 4 bytes of the identifier
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
