/* This is free and unencumbered software released into the public domain. */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <openssl/md5.h>
#include <openssl/sha.h>
#include "bitcache.h"
#include "config.h"

//////////////////////////////////////////////////////////////////////////////
// Constants

const char* const bitcache_version_string = PACKAGE_VERSION;

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

guint
bitcache_id_hash(const bitcache_id* id) {
  assert(id != NULL);
  return (guint)(id->data[3] << 24) +
    (guint)(id->data[2] << 16) +
    (guint)(id->data[1] << 8) +
    (guint)(id->data[0] << 0);
}

int
bitcache_id_compare(const bitcache_id* id1, const bitcache_id* id2) {
  assert(id1 != NULL && id2 != NULL && id1->type == id2->type);
  return memcmp(id1->data, id2->data, bitcache_id_get_size(id1));
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

bitcache_list*
bitcache_list_alloc() {
  return g_slist_alloc();
}

bitcache_list*
bitcache_list_copy(const bitcache_list* list) {
  return g_slist_copy((bitcache_list*)list);
}

bitcache_list*
bitcache_list_new() {
  bitcache_list* list = bitcache_list_alloc();
  bitcache_list_init(list);
  return list;
}

void
bitcache_list_init(bitcache_list* list) {
  assert(list != BITCACHE_LIST_EMPTY);
}

void
bitcache_list_free(bitcache_list* list) {
  g_slist_free(list);
}

bool
bitcache_list_equal(const bitcache_list* list1, const bitcache_list* list2) {
  return (list1 == list2) || (list1 == BITCACHE_LIST_EMPTY || list2 == BITCACHE_LIST_EMPTY) || FALSE; // TODO
}

guint
bitcache_list_hash(const bitcache_list* list) {
  return g_direct_hash(list);
}

bitcache_list*
bitcache_list_clear(bitcache_list* list) {
  bitcache_list_free(list);
  return BITCACHE_LIST_EMPTY;
}

bitcache_list*
bitcache_list_append(bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_append(list, (void*)id);
}

bitcache_list*
bitcache_list_prepend(const bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_prepend((bitcache_list*)list, (void*)id);
}

bitcache_list*
bitcache_list_insert_at(bitcache_list* list, const int position, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_insert(list, (void*)id, position);
}

bitcache_list*
bitcache_list_insert_before(bitcache_list* list, const bitcache_list* next, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_insert_before(list, (bitcache_list*)next, (void*)id);
}

bitcache_list*
bitcache_list_insert_after(bitcache_list* list, const bitcache_list* prev, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_insert_before(list, bitcache_list_next(prev), (void*)id);
}

bitcache_list*
bitcache_list_remove_at(bitcache_list* list, const gint position) {
  bitcache_list* nth = bitcache_list_nth(list, position);
  return (nth != NULL && nth != BITCACHE_LIST_EMPTY) ? g_slist_delete_link(list, nth) : list;
}

bitcache_list*
bitcache_list_remove(bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_remove(list, (void*)id);
}

bitcache_list*
bitcache_list_remove_all(bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_remove_all(list, (void*)id);
}

bitcache_list*
bitcache_list_reverse(const bitcache_list* list) {
  return g_slist_reverse((bitcache_list*)list);
}

bitcache_list*
bitcache_list_concat(bitcache_list* list1, const bitcache_list* list2) {
  return g_slist_concat(list1, (bitcache_list*)list2);
}

bool
bitcache_list_is_empty(const bitcache_list* list) {
  return list == BITCACHE_LIST_EMPTY;
}

guint
bitcache_list_length(const bitcache_list* list) {
  return g_slist_length((bitcache_list*)list);
}

guint
bitcache_list_count(const bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  guint count = 0;
  bitcache_list* head = (bitcache_list*)list;
  while (head != BITCACHE_LIST_EMPTY) {
    if (bitcache_id_equal(bitcache_list_first_id(head), id)) {
      count += 1;
    }
    head = bitcache_list_next(head);
  }
  return count;
}

gint
bitcache_list_position(const bitcache_list* list, const bitcache_list* link) {
  return g_slist_position((bitcache_list*)list, (bitcache_list*)link);
}

gint
bitcache_list_index(const bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_index((bitcache_list*)list, id);
}

bitcache_list*
bitcache_list_find(const bitcache_list* list, const bitcache_id* id) {
  assert(id != NULL);
  return g_slist_find((bitcache_list*)list, id);
}

bitcache_list*
bitcache_list_first(const bitcache_list* list) {
  return (bitcache_list*)list;
}

bitcache_list*
bitcache_list_next(const bitcache_list* list) {
  return g_slist_next(list);
}

bitcache_list*
bitcache_list_nth(const bitcache_list* list, const guint n) {
  return g_slist_nth((bitcache_list*)list, n);
}

bitcache_list*
bitcache_list_last(const bitcache_list* list) {
  return g_slist_last((bitcache_list*)list);
}

bitcache_id*
bitcache_list_first_id(const bitcache_list* list) {
  return (list != BITCACHE_LIST_EMPTY) ? list->data : NULL;
}

bitcache_id*
bitcache_list_next_id(const bitcache_list* list) {
  return (list != BITCACHE_LIST_EMPTY) ? bitcache_list_first_id(list->next) : NULL;
}

bitcache_id*
bitcache_list_nth_id(const bitcache_list* list, const guint n) {
  return g_slist_nth_data((bitcache_list*)list, n);
}

bitcache_id*
bitcache_list_last_id(const bitcache_list* list) {
  bitcache_list* last = bitcache_list_last(list);
  return bitcache_list_first_id(last);
}

void
bitcache_list_each_id(const bitcache_list* list, const bitcache_id_func func, void* user_data) {
  assert(func != NULL);
  g_slist_foreach((bitcache_list*)list, (GFunc)func, user_data);
}

/*bitcache_set*
bitcache_list_to_set(const bitcache_list* list) {
  return (list != BITCACHE_LIST_EMPTY) ? NULL : NULL; // TODO
}*/

//////////////////////////////////////////////////////////////////////////////
// Sets

//////////////////////////////////////////////////////////////////////////////
// Queues

//////////////////////////////////////////////////////////////////////////////
// Streams
