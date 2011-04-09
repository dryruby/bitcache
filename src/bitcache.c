/* This is free and unencumbered software released into the public domain. */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <math.h>
#include <openssl/md5.h>
#include <openssl/sha.h>
#include "bitcache.h"
#include "config.h"

//////////////////////////////////////////////////////////////////////////////
// Constants

const char* const bitcache_version_string = PACKAGE_VERSION;

const bitcache_id_md5 const bitcache_md5_empty = {
  .type   = BITCACHE_MD5,
  .digest = { 0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04,
              0xe9, 0x80, 0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e },
  // d41d8cd98f00b204e9800998ecf8427e
};

const bitcache_id_sha1 const bitcache_sha1_empty = {
  .type   = BITCACHE_SHA1,
  .digest = { 0xda, 0x39, 0xa3, 0xee, 0x5e, 0x6b, 0x4b, 0x0d,
              0x32, 0x55, 0xbf, 0xef, 0x95, 0x60, 0x18, 0x90,
              0xaf, 0xd8, 0x07, 0x09 },
  // da39a3ee5e6b4b0d3255bfef95601890afd80709
};

const bitcache_id_sha256 const bitcache_sha256_empty = {
  .type   = BITCACHE_SHA256,
  .digest = { 0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14,
              0x9a, 0xfb, 0xf4, 0xc8, 0x99, 0x6f, 0xb9, 0x24,
              0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c,
              0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55 },
  // e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
};

//////////////////////////////////////////////////////////////////////////////
// Digest API

byte*
bitcache_md5(const byte* data, const size_t size, byte* buffer) {
  assert(data != NULL || size == 0);
  if (size == 0) {
    if (buffer != NULL) {
      memcpy(buffer, bitcache_md5_empty.digest, BITCACHE_MD5_SIZE);
      return buffer;
    }
    return (byte*)bitcache_md5_empty.digest;
  }
  return MD5(data, size, buffer); // currently uses OpenSSL
}

byte*
bitcache_sha1(const byte* data, const size_t size, byte* buffer) {
  assert(data != NULL || size == 0);
  if (size == 0) {
    if (buffer != NULL) {
      memcpy(buffer, bitcache_sha1_empty.digest, BITCACHE_SHA1_SIZE);
      return buffer;
    }
    return (byte*)bitcache_sha1_empty.digest;
  }
  return SHA1(data, size, buffer); // currently uses OpenSSL
}

byte*
bitcache_sha256(const byte* data, const size_t size, byte* buffer) {
  assert(data != NULL || size == 0);
  if (size == 0) {
    if (buffer != NULL) {
      memcpy(buffer, bitcache_sha256_empty.digest, BITCACHE_SHA256_SIZE);
      return buffer;
    }
    return (byte*)bitcache_sha256_empty.digest;
  }
  return (buffer = NULL); // TODO
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Internals

static inline size_t
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

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Allocators

bitcache_id*
bitcache_id_alloc(const bitcache_id_type type) {
  assert(type > BITCACHE_NONE);
  size_t size = bitcache_id_sizeof(type);
  if (size > 0) {
    bitcache_id* id = (bitcache_id*)bitcache_slice_alloc(size);
    id->type = type;
    return id;
  }
  return NULL;
}

void
bitcache_id_free(bitcache_id* id) {
  assert(id != NULL);
  bitcache_slice_free1(bitcache_id_sizeof(id->type), id);
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Constructors

bitcache_id*
bitcache_id_new(const bitcache_id_type type, const byte* digest) {
  assert(type != BITCACHE_NONE);
  bitcache_id* id = bitcache_id_alloc(type);
  bitcache_id_init(id, type, digest);
  return id;
}

bitcache_id*
bitcache_id_new_md5(const byte* digest) {
  return bitcache_id_new(BITCACHE_MD5, digest);
}

bitcache_id*
bitcache_id_new_sha1(const byte* digest) {
  return bitcache_id_new(BITCACHE_SHA1, digest);
}

bitcache_id*
bitcache_id_new_sha256(const byte* digest) {
  return bitcache_id_new(BITCACHE_SHA256, digest);
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

bitcache_id*
bitcache_id_copy(const bitcache_id* id) {
  assert(id != NULL);
  return bitcache_slice_copy(bitcache_id_sizeof(id->type), id);
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Mutators

void
bitcache_id_init(bitcache_id* id, const bitcache_id_type type, const byte* digest) {
  assert(type != BITCACHE_NONE);
  id->type = type;
  if (digest != NULL) {
    bitcache_memmove(id->digest, digest, bitcache_id_get_digest_size(id));
  }
}

void
bitcache_id_clear(bitcache_id* id) {
  assert(id != NULL);
  bzero(id->digest, bitcache_id_get_digest_size(id));
}

void
bitcache_id_fill(bitcache_id* id, const byte value) {
  assert(id != NULL);
  memset(id->digest, value, bitcache_id_get_digest_size(id));
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Accessors

guint
bitcache_id_get_hash(const bitcache_id* id) {
  assert(id != NULL);
  /*return (guint)id->digest[0] +
    (guint)(id->digest[1] << 8) +
    (guint)(id->digest[2] << 16) +
    (guint)(id->digest[3] << 24);*/
  return ((guint*)id->digest)[0];
}

bitcache_id_type
bitcache_id_get_type(const bitcache_id* id) {
  assert(id != NULL && id->type > BITCACHE_NONE);
  return id->type;
}

byte*
bitcache_id_get_digest(const bitcache_id* id) {
  assert(id != NULL && id->type > BITCACHE_NONE);
  return (byte*)id->digest;
}

size_t
bitcache_id_get_digest_size(const bitcache_id* id) {
  assert(id != NULL && id->type > BITCACHE_NONE);
  return (size_t)id->type; // HACK
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Predicates

bool
bitcache_id_is_equal(const bitcache_id* id1, const bitcache_id* id2) {
  assert(id1 != NULL && id2 != NULL);
  return (id1 == id2) || (id1->type == id2->type && bitcache_id_compare(id1, id2) == 0);
}

bool
bitcache_id_is_zero(const bitcache_id* id) {
  assert(id != NULL);
  for (int i = 0; i < bitcache_id_get_digest_size(id); i++) {
    if (id->digest[i] != 0)
      return FALSE;
  }
  return TRUE;
}

//////////////////////////////////////////////////////////////////////////////
// Identifier API: Converters

char*
bitcache_id_to_hex_string(const bitcache_id* id, char* buffer) {
  assert(id != NULL);
  size_t size = bitcache_id_get_digest_size(id);
  char* string = (buffer != NULL) ? buffer : bitcache_malloc(size * 2 + 1);
  for (int i = 0; i< (int)size; i++) {
    snprintf(string + i * 2, 3, "%02x", id->digest[i]); // TODO: optimize this
  }
  return string;
}

char*
bitcache_id_to_base64_string(const bitcache_id* id, char* buffer) {
  assert(id != NULL);
  return (buffer = NULL); // TODO
}

byte*
bitcache_id_to_mpi(const bitcache_id* id, byte* buffer) {
  assert(id != NULL);
  return (buffer = NULL); // TODO
}

//////////////////////////////////////////////////////////////////////////////
// Filter API: Predicates

/*
bool
bitcache_filter_is_equal(const bitcache_filter* filter1, const bitcache_filter* filter2) {
  assert(filter1 != NULL && filter2 != NULL);

  if (filter1 == filter2)
    return TRUE;
  if (bitcache_filter_get_bitsize(filter1) != bitcache_filter_get_bitsize(filter2))
    return FALSE;
  if (bitcache_filter_is_empty(filter1) && bitcache_filter_is_empty(filter2))
    return TRUE;

  assert(filter1->bitmap != NULL && filter2->bitmap != NULL);
  return memcmp(filter1->bitmap, filter2->bitmap, bitcache_filter_get_bytesize(filter1)) == 0;
}

bool
bitcache_filter_is_empty(const bitcache_filter* filter) {
  assert(filter != NULL);

  if (filter->bitmap == NULL)
    return TRUE;

  for (int i = 0; i < bitcache_filter_get_bytesize(filter); i++) {
    if (filter->bitmap[i] != 0)
      return FALSE;
  }
  return TRUE;
}
*/

//////////////////////////////////////////////////////////////////////////////
// List API: Allocators

bitcache_list_element*
bitcache_list_element_alloc() {
  return g_slist_alloc();
}

void
bitcache_list_element_free(bitcache_list_element* element) {
  if (element != BITCACHE_LIST_SENTINEL)
    g_slist_free(element);
}

bitcache_list*
bitcache_list_alloc() {
  return bitcache_slice_alloc(sizeof(bitcache_list));
}

void
bitcache_list_free(bitcache_list* list) {
  assert(list != NULL);
  bitcache_list_element_free(list->head);
  bitcache_slice_free1(sizeof(bitcache_list), list);
}

//////////////////////////////////////////////////////////////////////////////
// List API: Constructors

bitcache_list_element*
bitcache_list_element_new(const bitcache_id* first, const bitcache_list_element* rest) {
  bitcache_list_element* element = bitcache_list_element_alloc();
  bitcache_list_element_init(element, first, rest);
  return element;
}

bitcache_list_element*
bitcache_list_element_copy(const bitcache_list_element* element) {
  return g_slist_copy((bitcache_list_element*)element);
}

bitcache_list*
bitcache_list_new(const bitcache_list_element* head) {
  bitcache_list* list = bitcache_list_alloc();
  bitcache_list_init(list, head);
  return list;
}

bitcache_list*
bitcache_list_copy(const bitcache_list* list) {
  assert(list != NULL);
  return bitcache_list_new(list->head);
}

//////////////////////////////////////////////////////////////////////////////
// List API: Mutators

void
bitcache_list_element_init(bitcache_list_element* element, const bitcache_id* first, const bitcache_list_element* rest) {
  assert(element != NULL);
  element->data = (bitcache_id*)first;
  element->next = (bitcache_list_element*)rest;
}

void
bitcache_list_init(bitcache_list* list, const bitcache_list_element* head) {
  assert(list != NULL);
  list->head = (head != NULL) ? (bitcache_list_element*)head : BITCACHE_LIST_SENTINEL;
}

void
bitcache_list_clear(bitcache_list* list) {
  assert(list != NULL);
  if (list->head != BITCACHE_LIST_SENTINEL) {
    bitcache_list_element_free(list->head);
    list->head = BITCACHE_LIST_SENTINEL;
  }
}

void
bitcache_list_prepend(bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_prepend(list->head, (void*)id);
}

void
bitcache_list_append(bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_append(list->head, (void*)id);
}

void
bitcache_list_insert(bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  bitcache_list_prepend(list, id); // the most efficient insertion operation
}

void
bitcache_list_insert_at(bitcache_list* list, const gint position, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_insert(list->head, (void*)id, position);
}

void
bitcache_list_insert_before(bitcache_list* list, const bitcache_list_element* next, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_insert_before(list->head, (bitcache_list_element*)next, (void*)id);
}

void
bitcache_list_insert_after(bitcache_list* list, const bitcache_list_element* prev, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_insert_before(list->head, g_slist_next(prev), (void*)id);
}

void
bitcache_list_remove(bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_remove(list->head, (void*)id);
}

void
bitcache_list_remove_all(bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  list->head = g_slist_remove_all(list->head, (void*)id);
}

void
bitcache_list_remove_at(bitcache_list* list, const gint position) {
  assert(list != NULL);
  bitcache_list_element* element = g_slist_nth(list->head, position);
  if (element != NULL && element != BITCACHE_LIST_SENTINEL) {
    list->head = g_slist_delete_link(list->head, element);
  }
}

void
bitcache_list_reverse(bitcache_list* list) {
  assert(list != NULL);
  list->head = g_slist_reverse(list->head);
}

void
bitcache_list_concat(bitcache_list* list1, const bitcache_list* list2) {
  assert(list1 != NULL && list2 != NULL);
  list1->head = g_slist_concat(list1->head, list2->head);
}

//////////////////////////////////////////////////////////////////////////////
// List API: Accessors

guint
bitcache_list_get_hash(const bitcache_list* list) {
  assert(list != NULL);
  return g_direct_hash(list);
}

guint
bitcache_list_get_length(const bitcache_list* list) {
  assert(list != NULL);
  return g_slist_length(list->head);
}

guint
bitcache_list_get_count(const bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL);
  guint count = 0;
  if (id != NULL) {
    bitcache_list_element* head = list->head;
    while (head != BITCACHE_LIST_SENTINEL) {
      if (bitcache_id_is_equal(head->data, id)) {
        count += 1;
      }
      head = head->next;
    }
  }
  else {
    count = bitcache_list_get_length(list);
  }
  return count;
}

guint
bitcache_list_get_position(const bitcache_list* list, const bitcache_id* id) {
  assert(list != NULL && id != NULL);
  return g_slist_index(list->head, id);
}

bitcache_list_element*
bitcache_list_get_rest(const bitcache_list* list) {
  assert(list != NULL);
  return g_slist_next(list->head);
}

bitcache_id*
bitcache_list_get_first(const bitcache_list* list) {
  assert(list != NULL);
  if (list->head != BITCACHE_LIST_SENTINEL) {
    bitcache_list_element* element = list->head;
    assert(element != NULL);
    return element->data;
  }
  return NULL;
}

bitcache_id*
bitcache_list_get_last(const bitcache_list* list) {
  assert(list != NULL);
  if (list->head != BITCACHE_LIST_SENTINEL) {
    bitcache_list_element* element = g_slist_last(list->head);
    assert(element != NULL);
    return element->data;
  }
  return NULL;
}

bitcache_id*
bitcache_list_get_nth(const bitcache_list* list, const gint position) {
  assert(list != NULL);
  if (list->head != BITCACHE_LIST_SENTINEL) {
    bitcache_list_element* element = g_slist_nth(list->head, position);
    return element->data;
  }
  return NULL;
}

//////////////////////////////////////////////////////////////////////////////
// List API: Predicates

bool
bitcache_list_is_equal(const bitcache_list* list1, const bitcache_list* list2) {
  assert(list1 != NULL && list2 != NULL);
  return (list1 == list2) || FALSE; // TODO
}

bool
bitcache_list_is_empty(const bitcache_list* list) {
  assert(list != NULL);
  return list->head == BITCACHE_LIST_SENTINEL;
}

//////////////////////////////////////////////////////////////////////////////
// List API: Iterators

void
bitcache_list_foreach(const bitcache_list* list, const bitcache_id_func func, void* user_data) {
  assert(list != NULL && func != NULL);
  g_slist_foreach(list->head, (GFunc)func, user_data);
}

//////////////////////////////////////////////////////////////////////////////
// List API: Converters

/*
bitcache_filter*
bitcache_list_to_filter(const bitcache_list* list) {
  assert(list != NULL);

  bitcache_filter* filter = bitcache_filter_new(bitcache_list_get_length(list));
  if (!bitcache_list_is_empty(list)) {
    // TODO
  }
  return filter;
}
*/

bitcache_set*
bitcache_list_to_set(const bitcache_list* list) {
  assert(list != NULL);

  bitcache_set* set = bitcache_set_new();
  if (!bitcache_list_is_empty(list)) {
    // TODO
  }
  return set;
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Internals

// TODO

//////////////////////////////////////////////////////////////////////////////
// Set API: Allocators

bitcache_set*
bitcache_set_alloc() {
  return bitcache_slice_alloc(sizeof(bitcache_set));
}

void
bitcache_set_free(bitcache_set* set) {
  assert(set != NULL);
  if (set->root != NULL) {
    g_hash_table_destroy(set->root);
    set->root = NULL;
  }
  bitcache_slice_free1(sizeof(bitcache_set), set);
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Constructors

bitcache_set*
bitcache_set_new() {
  bitcache_set* set = bitcache_set_alloc();
  bitcache_set_init(set);
  return set;
}

bitcache_set*
bitcache_set_new_union(const bitcache_set* set1, const bitcache_set* set2) {
  assert(set1 != NULL && set2 != NULL);
  assert(set1->root != NULL && set2->root != NULL);

  if (set1 == set2)                // A | A = A
    return bitcache_set_copy(set1);
  if (bitcache_set_is_empty(set1)) // 0 | A = A
    return bitcache_set_copy(set2);
  if (bitcache_set_is_empty(set2)) // A | 0 = A
    return bitcache_set_copy(set1);

  bitcache_set* set3 = bitcache_set_new();
  bitcache_id* key;
  GHashTableIter iter;
  g_hash_table_iter_init(&iter, set1->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    bitcache_set_insert(set3, key);
  }
  g_hash_table_iter_init(&iter, set2->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    bitcache_set_insert(set3, key);
  }
  return set3;
}

bitcache_set*
bitcache_set_new_intersection(const bitcache_set* set1, const bitcache_set* set2) {
  assert(set1 != NULL && set2 != NULL);
  assert(set1->root != NULL && set2->root != NULL);

  if (set1 == set2)                // A & A = A
    return bitcache_set_copy(set1);
  if (bitcache_set_is_empty(set1)) // 0 & A = 0
    return bitcache_set_new();
  if (bitcache_set_is_empty(set2)) // A & 0 = 0
    return bitcache_set_new();

  if (g_hash_table_size(set2->root) < g_hash_table_size(set1->root)) {
    const bitcache_set* tmp = set1;
    set1 = set2;
    set2 = tmp;
  }

  bitcache_set* set3 = bitcache_set_new();
  bitcache_id* key;
  GHashTableIter iter;
  g_hash_table_iter_init(&iter, set1->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    if (bitcache_set_has_element(set2, key)) {
      bitcache_set_insert(set3, key);
    }
  }
  return set3;
}

bitcache_set*
bitcache_set_new_difference(const bitcache_set* set1, const bitcache_set* set2) {
  assert(set1 != NULL && set2 != NULL);
  assert(set1->root != NULL && set2->root != NULL);

  if (set1 == set2)                // A ^ A = 0
    return bitcache_set_new();
  if (bitcache_set_is_empty(set1)) // 0 ^ A = 0
    return bitcache_set_new();
  if (bitcache_set_is_empty(set2)) // A ^ 0 = 0
    return bitcache_set_new();

  bitcache_set* set3 = bitcache_set_new();
  bitcache_id* key;
  GHashTableIter iter;
  g_hash_table_iter_init(&iter, set1->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    if (!bitcache_set_has_element(set2, key)) {
      bitcache_set_insert(set3, key);
    }
  }
  g_hash_table_iter_init(&iter, set2->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    if (!bitcache_set_has_element(set1, key)) {
      bitcache_set_insert(set3, key);
    }
  }
  return set3;
}

bitcache_set*
bitcache_set_copy(const bitcache_set* set) {
  assert(set != NULL);
  bitcache_set* copy = bitcache_set_new();
  copy->root = set->root; // FIXME
  return copy;
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Mutators

void
bitcache_set_init(bitcache_set* set) {
  assert(set != NULL);
  set->root = g_hash_table_new(
    (GHashFunc)bitcache_id_get_hash,
    (GEqualFunc)bitcache_id_is_equal);
}

void
bitcache_set_clear(bitcache_set* set) {
  assert(set != NULL && set->root != NULL);
  g_hash_table_remove_all(set->root);
}

void
bitcache_set_insert(bitcache_set* set, const bitcache_id* id) {
  assert(set != NULL && set->root != NULL);
  assert(id != NULL);
  g_hash_table_insert(set->root, (bitcache_id*)id, NULL);
}

void
bitcache_set_remove(bitcache_set* set, const bitcache_id* id) {
  assert(set != NULL && set->root != NULL);
  assert(id != NULL);
  g_hash_table_remove(set->root, id);
}

void
bitcache_set_replace(bitcache_set* set, const bitcache_id* id1, const bitcache_id* id2) {
  assert(set != NULL && set->root != NULL);
  assert(id1 != NULL && id2 != NULL);

  bitcache_set_remove(set, id1);
  bitcache_set_insert(set, id2);
}

void
bitcache_set_merge(bitcache_set* set1, const bitcache_set* set2, const bitcache_op op) {
  assert(set1 != NULL && set2 != NULL);

  if (op == BITCACHE_OP_NOP)
    return;

  // TODO
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Accessors

guint
bitcache_set_get_hash(const bitcache_set* set) {
  assert(set != NULL && set->root != NULL);
  return g_direct_hash(set);
}

guint
bitcache_set_get_size(const bitcache_set* set) {
  assert(set != NULL && set->root != NULL);
  return g_hash_table_size(set->root);
}

guint
bitcache_set_get_count(const bitcache_set* set, const bitcache_id* id) {
  assert(set != NULL && id != NULL);
  return bitcache_set_has_element(set, id) ? 1 : 0;
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Predicates

bool
bitcache_set_is_equal(const bitcache_set* set1, const bitcache_set* set2) {
  assert(set1 != NULL && set2 != NULL);
  assert(set1->root != NULL && set2->root != NULL);

  if (set1 == set2)
    return TRUE;
  if (bitcache_set_is_empty(set1) && bitcache_set_is_empty(set2))
    return TRUE;
  if (bitcache_set_get_size(set1) != bitcache_set_get_size(set2))
    return FALSE;

  bitcache_id* key;
  GHashTableIter iter;
  g_hash_table_iter_init(&iter, set1->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    if (!bitcache_set_has_element(set2, key)) {
      return FALSE;
    }
  }
  return TRUE;
}

bool
bitcache_set_is_empty(const bitcache_set* set) {
  assert(set != NULL && set->root != NULL);
  return (g_hash_table_size(set->root) == 0);
}

bool
bitcache_set_has_element(const bitcache_set* set, const bitcache_id* id) {
  assert(set != NULL && id != NULL);
  assert(set->root != NULL);
  return g_hash_table_size(set->root) > 0 &&
    g_hash_table_lookup_extended(set->root, id, NULL, NULL);
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Iterators

void
bitcache_set_foreach(const bitcache_set* set, const bitcache_id_func func, void* user_data) {
  assert(set != NULL && func != NULL);
  // TODO

  /*bool result = FALSE;
  GHashTableIter iter;
  bitcache_id* key;

  assert(set->root != NULL);
  g_hash_table_iter_init(&iter, set->root);
  while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
    if (bitcache_id_is_equal(key, id)) {
      result = TRUE;
      break;
    }
  }
  return result;*/
}

//////////////////////////////////////////////////////////////////////////////
// Set API: Converters

/*
bitcache_filter*
bitcache_set_to_filter(const bitcache_set* set) {
  assert(set != NULL);

  bitcache_filter* filter = bitcache_filter_new(bitcache_set_get_size(set));
  if (!bitcache_set_is_empty(set)) {
    bitcache_id* key;
    GHashTableIter iter;
    g_hash_table_iter_init(&iter, set->root);
    while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
      bitcache_filter_insert(filter, key);
    }
  }
  return filter;
}
*/

bitcache_list*
bitcache_set_to_list(const bitcache_set* set) {
  assert(set != NULL);

  bitcache_list* list = bitcache_list_new(NULL);
  if (!bitcache_set_is_empty(set)) {
    bitcache_id* key;
    GHashTableIter iter;
    g_hash_table_iter_init(&iter, set->root);
    while (g_hash_table_iter_next(&iter, (void*)&key, NULL) != FALSE) {
      bitcache_list_insert(list, key);
    }
  }
  return list;
}

//////////////////////////////////////////////////////////////////////////////
// Queue API

//////////////////////////////////////////////////////////////////////////////
// Index API

//////////////////////////////////////////////////////////////////////////////
// Stream API
