/* This is free and unencumbered software released into the public domain. */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <openssl/md5.h>
#include <openssl/sha.h>
#include "bitcache.h"

//////////////////////////////////////////////////////////////////////////////
// Digests

byte*
bitcache_md5(const byte* data, const size_t size, byte* id) {
  assert(data != NULL || size == 0);
  return MD5(data, size, id); // currently uses OpenSSL
}

byte*
bitcache_sha1(const byte* data, const size_t size, byte* id) {
  assert(data != NULL || size == 0);
  return SHA1(data, size, id); // currently uses OpenSSL
}

byte*
bitcache_sha256(const byte* data, const size_t size, byte* id) {
  assert(data != NULL || size == 0);
  return (id = NULL); // TODO
}

//////////////////////////////////////////////////////////////////////////////
// Identifiers

size_t
bitcache_id_sizeof(const bitcache_id_type type) {
  assert(type > BITCACHE_NONE);
  switch (type) {
    case BITCACHE_MD5:
      return sizeof(bitcache_id_md5);
    case BITCACHE_SHA1:
      return sizeof(bitcache_id_sha1);
    case BITCACHE_SHA256:
      return sizeof(bitcache_id_sha256);
    default:
      return 0; // unknown type
  }
}

bitcache_id*
bitcache_id_alloc(const bitcache_id_type type) {
  assert(type > BITCACHE_NONE);
  size_t size = bitcache_id_sizeof(type);
  return size > 0 ? bitcache_slice_alloc(size) : NULL;
}

bitcache_id*
bitcache_id_copy(const bitcache_id* id) {
  assert(id != NULL);
  return bitcache_slice_copy(bitcache_id_sizeof(id->type), id);
}

bitcache_id*
bitcache_id_new_md5(const byte* data) {
  return bitcache_id_new(BITCACHE_MD5, data);
}

bitcache_id*
bitcache_id_new_sha1(const byte* data) {
  return bitcache_id_new(BITCACHE_SHA1, data);
}

bitcache_id*
bitcache_id_new_sha256(const byte* data) {
  return bitcache_id_new(BITCACHE_SHA256, data);
}

bitcache_id*
bitcache_id_new(const bitcache_id_type type, const byte* data) {
  assert(type != BITCACHE_NONE);
  bitcache_id* id = bitcache_id_alloc(type);
  bitcache_id_init(id, type, data);
  return id;
}

bitcache_id*
bitcache_id_new_from_hex_string(const char* string) {
  assert(string != NULL);
  bitcache_id_type type = BITCACHE_NONE;
  switch (strlen(string)) {
    case 2 * BITCACHE_MD5_SIZE:
      type = BITCACHE_MD5;
      break;
    case 2 * BITCACHE_SHA1_SIZE:
      type = BITCACHE_SHA1;
      break;
    case 2 * BITCACHE_SHA256_SIZE:
      type = BITCACHE_SHA256;
      break;
    default:
      return NULL; // unknown type
  }
  bitcache_id* id = bitcache_id_alloc(type);
  id->type = type;
  // TODO: convert from hex string to binary
  return id;
}

bitcache_id*
bitcache_id_new_from_base64_string(const char* string) {
  assert(string != NULL);
  return NULL; // TODO
}

void
bitcache_id_init(bitcache_id* id, const bitcache_id_type type, const byte* data) {
  assert(type != BITCACHE_NONE);
  id->type = type;
  if (data != NULL) {
    bitcache_memmove(id->data, data, bitcache_id_get_size(id));
  }
}

void
bitcache_id_free(bitcache_id* id) {
  assert(id != NULL);
  bitcache_slice_free1(bitcache_id_sizeof(id->type), id);
}

void
bitcache_id_clear(bitcache_id* id) {
  assert(id != NULL);
  bzero(id->data, bitcache_id_get_size(id));
}

void
bitcache_id_fill(bitcache_id* id, const byte value) {
  assert(id != NULL);
  memset(id->data, value, bitcache_id_get_size(id));
}

bitcache_id_type
bitcache_id_get_type(const bitcache_id* id) {
  assert(id != NULL && id->type > BITCACHE_NONE);
  return id->type;
}

size_t
bitcache_id_get_size(const bitcache_id* id) {
  assert(id != NULL && id->type > BITCACHE_NONE);
  return (size_t)id->type; // HACK
}

bool
bitcache_id_equal(const bitcache_id* id1, const bitcache_id* id2) {
  assert(id1 != NULL && id2 != NULL);
  return (id1 == id2) || (id1->type == id2->type && bitcache_id_compare(id1, id2) == 0);
}

int
bitcache_id_compare(const bitcache_id* id1, const bitcache_id* id2) {
  assert(id1 != NULL && id2 != NULL && id1->type == id2->type);
  return memcmp(id1->data, id2->data, bitcache_id_get_size(id1));
}

guint
bitcache_id_hash(const bitcache_id* id) {
  assert(id != NULL);
  return (guint)(id->data[3] << 24) +
    (guint)(id->data[2] << 16) +
    (guint)(id->data[1] << 8) +
    (guint)(id->data[0] << 0);
}

char*
bitcache_id_to_hex_string(const bitcache_id* id, char* string) {
  assert(id != NULL);
  size_t size = bitcache_id_get_size(id);
  string = (string != NULL) ? string : bitcache_malloc(size * 2 + 1);
  for (int i = 0; i< (int)size; i++) {
    snprintf(string + i * 2, 3, "%02x", id->data[i]); // TODO: optimize this
  }
  return string;
}

char*
bitcache_id_to_base64_string(const bitcache_id* id, char* string) {
  assert(id != NULL);
  return (string = NULL); // TODO
}

byte*
bitcache_id_to_mpi(const bitcache_id* id) {
  assert(id != NULL);
  return NULL; // TODO
}

//////////////////////////////////////////////////////////////////////////////
// Lists

//////////////////////////////////////////////////////////////////////////////
// Sets

//////////////////////////////////////////////////////////////////////////////
// Queues

//////////////////////////////////////////////////////////////////////////////
// Streams
