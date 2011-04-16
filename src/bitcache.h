/* This is free and unencumbered software released into the public domain. */

#ifndef BITCACHE_H
#define BITCACHE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <glib.h>

#define bitcache_malloc       g_malloc0
#define bitcache_calloc       g_malloc0_n
#define bitcache_realloc      g_realloc
#define bitcache_free         g_free
#define bitcache_slice_alloc  g_slice_alloc0
#define bitcache_slice_copy   g_slice_copy
#define bitcache_slice_free1  g_slice_free1
#define bitcache_memmove      g_memmove

typedef guint8 byte;

//////////////////////////////////////////////////////////////////////////////
// Constants

extern const char* const bitcache_version_string;

typedef enum {
  BITCACHE_OP_NOP = 0, // no-op
  BITCACHE_OP_OR  = 1, // logical or  (set union)
  BITCACHE_OP_AND = 2, // logical and (set intersection)
  BITCACHE_OP_XOR = 3, // logical xor (set difference)
} bitcache_op;

//////////////////////////////////////////////////////////////////////////////
// Digest API

extern byte* bitcache_md5(const byte* data, const size_t size, byte* buffer);
extern byte* bitcache_sha1(const byte* data, const size_t size, byte* buffer);
extern byte* bitcache_sha256(const byte* data, const size_t size, byte* buffer);

//////////////////////////////////////////////////////////////////////////////
// Identifier API

#define BITCACHE_MD5_SIZE     16 // bytes
#define BITCACHE_SHA1_SIZE    20 // bytes
#define BITCACHE_SHA256_SIZE  32 // bytes
#define BITCACHE_ID_SIZE      BITCACHE_SHA256_SIZE

typedef enum {
  BITCACHE_NONE   = 0,
  BITCACHE_MD5    = BITCACHE_MD5_SIZE,
  BITCACHE_SHA1   = BITCACHE_SHA1_SIZE,
  BITCACHE_SHA256 = BITCACHE_SHA256_SIZE,
} bitcache_id_type;

typedef struct {
  bitcache_id_type type;
  byte digest[BITCACHE_ID_SIZE];
} bitcache_id;

typedef struct {
  bitcache_id_type type;
  byte digest[BITCACHE_MD5_SIZE];
} bitcache_id_md5;

typedef struct {
  bitcache_id_type type;
  byte digest[BITCACHE_SHA1_SIZE];
} bitcache_id_sha1;

typedef struct {
  bitcache_id_type type;
  byte digest[BITCACHE_SHA256_SIZE];
} bitcache_id_sha256;

typedef void (*bitcache_id_func)(const bitcache_id* id, void* user_data);

// Allocators
extern bitcache_id* bitcache_id_alloc(const bitcache_id_type type);
extern void bitcache_id_free(bitcache_id* id);

// Constructors
extern bitcache_id* bitcache_id_new(const bitcache_id_type type, const byte* digest);
extern bitcache_id* bitcache_id_new_md5(const byte* digest);
extern bitcache_id* bitcache_id_new_sha1(const byte* digest);
extern bitcache_id* bitcache_id_new_sha256(const byte* digest);
extern bitcache_id* bitcache_id_new_from_hex_string(const char* string);
extern bitcache_id* bitcache_id_new_from_base64_string(const char* string);
extern bitcache_id* bitcache_id_copy(const bitcache_id* id);

// Accessors
extern guint bitcache_id_get_hash(const bitcache_id* id);
extern bitcache_id_type bitcache_id_get_type(const bitcache_id* id);
extern byte* bitcache_id_get_digest(const bitcache_id* id);
extern size_t bitcache_id_get_digest_size(const bitcache_id* id);

// Predicates
extern bool bitcache_id_is_equal(const bitcache_id* id1, const bitcache_id* id2);
extern bool bitcache_id_is_zero(const bitcache_id* id);

// Comparators
extern int bitcache_id_compare(const bitcache_id* id1, const bitcache_id* id2);

// Converters
extern char* bitcache_id_to_hex_string(const bitcache_id* id, char* buffer);
extern char* bitcache_id_to_base64_string(const bitcache_id* id, char* buffer);
extern byte* bitcache_id_to_mpi(const bitcache_id* id, byte* buffer);

//////////////////////////////////////////////////////////////////////////////
// Filter API

#define BITCACHE_FILTER_DEFAULT_CAPACITY 4096 // elements
#define BITCACHE_FILTER_BITS_PER_ELEMENT 8    // bits

//////////////////////////////////////////////////////////////////////////////
// List API

#define BITCACHE_LIST_SENTINEL NULL // the canonical end-of-list sentinel

typedef GSList bitcache_list_element;

typedef struct {
  bitcache_list_element* head;
} bitcache_list;

typedef void (*bitcache_list_element_func)(const bitcache_list_element* element, void* user_data);

// Allocators
extern bitcache_list_element* bitcache_list_element_alloc();
extern void bitcache_list_element_free(bitcache_list_element* element);
extern bitcache_list* bitcache_list_alloc();
extern void bitcache_list_free(bitcache_list* list);

// Constructors
extern bitcache_list_element* bitcache_list_element_new(const bitcache_id* first, const bitcache_list_element* rest);
extern bitcache_list_element* bitcache_list_element_copy(const bitcache_list_element* element);
extern bitcache_list* bitcache_list_new(const bitcache_list_element* head);
extern bitcache_list* bitcache_list_copy(const bitcache_list* list);

// Mutators
extern void bitcache_list_element_init(bitcache_list_element* element, const bitcache_id* first, const bitcache_list_element* rest);
extern void bitcache_list_init(bitcache_list* list, const bitcache_list_element* head);
extern void bitcache_list_clear(bitcache_list* list);
extern void bitcache_list_prepend(bitcache_list* list, const bitcache_id* id);
extern void bitcache_list_append(bitcache_list* list, const bitcache_id* id);
extern void bitcache_list_insert(bitcache_list* list, const bitcache_id* id);
extern void bitcache_list_insert_at(bitcache_list* list, const gint position, const bitcache_id* id);
extern void bitcache_list_insert_before(bitcache_list* list, const bitcache_list_element* next, const bitcache_id* id);
extern void bitcache_list_insert_after(bitcache_list* list, const bitcache_list_element* prev, const bitcache_id* id);
extern void bitcache_list_remove(bitcache_list* list, const bitcache_id* id);
extern void bitcache_list_remove_all(bitcache_list* list, const bitcache_id* id);
extern void bitcache_list_remove_at(bitcache_list* list, const gint position);
extern void bitcache_list_reverse(bitcache_list* list);
extern void bitcache_list_concat(bitcache_list* list1, const bitcache_list* list2);

// Accessors
extern guint bitcache_list_get_hash(const bitcache_list* list);
extern guint bitcache_list_get_length(const bitcache_list* list);
extern guint bitcache_list_get_count(const bitcache_list* list, const bitcache_id* id);
extern guint bitcache_list_get_position(const bitcache_list* list, const bitcache_id* id);
extern bitcache_list_element* bitcache_list_get_rest(const bitcache_list* list);
extern bitcache_id* bitcache_list_get_first(const bitcache_list* list);
extern bitcache_id* bitcache_list_get_last(const bitcache_list* list);
extern bitcache_id* bitcache_list_get_nth(const bitcache_list* list, const gint position);

// Predicates
extern bool bitcache_list_is_equal(const bitcache_list* list1, const bitcache_list* list2);
extern bool bitcache_list_is_empty(const bitcache_list* list);

// Iterators
extern void bitcache_list_foreach(const bitcache_list* list, const bitcache_id_func func, void* user_data);

// Converters
//extern bitcache_filter* bitcache_list_to_filter(const bitcache_list* list);
//extern bitcache_set* bitcache_list_to_set(const bitcache_list* list);

//////////////////////////////////////////////////////////////////////////////
// Set API

typedef GHashTable bitcache_set_map;

typedef struct {
  bitcache_set_map* root;
  //bitcache_filter* filter; // an optional Bloom filter
} bitcache_set;

// Allocators
extern bitcache_set* bitcache_set_alloc();
extern void bitcache_set_free(bitcache_set* set);

// Constructors
extern bitcache_set* bitcache_set_new();
extern bitcache_set* bitcache_set_new_union(const bitcache_set* set1, const bitcache_set* set2);
extern bitcache_set* bitcache_set_new_intersection(const bitcache_set* set1, const bitcache_set* set2);
extern bitcache_set* bitcache_set_new_difference(const bitcache_set* set1, const bitcache_set* set2);
extern bitcache_set* bitcache_set_copy(const bitcache_set* set);

// Mutators
extern void bitcache_set_init(bitcache_set* set);
extern void bitcache_set_clear(bitcache_set* set);
extern void bitcache_set_insert(bitcache_set* set, const bitcache_id* id);
extern void bitcache_set_remove(bitcache_set* set, const bitcache_id* id);
extern void bitcache_set_replace(bitcache_set* set, const bitcache_id* id1, const bitcache_id* id2);
extern void bitcache_set_merge(bitcache_set* set1, const bitcache_set* set2, const bitcache_op op);

// Accessors
extern guint bitcache_set_get_hash(const bitcache_set* set);
extern guint bitcache_set_get_size(const bitcache_set* set);
extern guint bitcache_set_get_count(const bitcache_set* set, const bitcache_id* id);

// Predicates
extern bool bitcache_set_is_equal(const bitcache_set* set1, const bitcache_set* set2);
extern bool bitcache_set_is_empty(const bitcache_set* set);
extern bool bitcache_set_has_element(const bitcache_set* set, const bitcache_id* id);

// Iterators
extern void bitcache_set_foreach(const bitcache_set* set, const bitcache_id_func func, void* user_data);

// Converters
//extern bitcache_filter* bitcache_set_to_filter(const bitcache_set* set);
extern bitcache_list* bitcache_set_to_list(const bitcache_set* set);

//////////////////////////////////////////////////////////////////////////////
// Miscellaneous

#ifdef __cplusplus
}
#endif

#endif // BITCACHE_H
