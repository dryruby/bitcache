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

//////////////////////////////////////////////////////////////////////////////
// Digests

extern byte* bitcache_md5(const byte* data, const size_t size, byte* id);
extern byte* bitcache_sha1(const byte* data, const size_t size, byte* id);
extern byte* bitcache_sha256(const byte* data, const size_t size, byte* id);

//////////////////////////////////////////////////////////////////////////////
// Identifiers

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
  byte data[BITCACHE_ID_SIZE];
} bitcache_id;

typedef struct {
  bitcache_id_type type;
  byte data[BITCACHE_MD5_SIZE];
} bitcache_id_md5;

typedef struct {
  bitcache_id_type type;
  byte data[BITCACHE_SHA1_SIZE];
} bitcache_id_sha1;

typedef struct {
  bitcache_id_type type;
  byte data[BITCACHE_SHA256_SIZE];
} bitcache_id_sha256;

typedef void (*bitcache_id_func)(const bitcache_id* id, void* user_data);

extern size_t bitcache_id_sizeof(const bitcache_id_type type);
extern bitcache_id* bitcache_id_alloc(const bitcache_id_type type);
extern bitcache_id* bitcache_id_copy(const bitcache_id* id);
extern bitcache_id* bitcache_id_new_md5(const byte* data);
extern bitcache_id* bitcache_id_new_sha1(const byte* data);
extern bitcache_id* bitcache_id_new_sha256(const byte* data);
extern bitcache_id* bitcache_id_new(const bitcache_id_type type, const byte* data);
extern bitcache_id* bitcache_id_new_from_hex_string(const char* string);
extern bitcache_id* bitcache_id_new_from_base64_string(const char* string);
extern void bitcache_id_init(bitcache_id* id, const bitcache_id_type type, const byte* data);
extern void bitcache_id_free(bitcache_id* id);
extern void bitcache_id_clear(bitcache_id* id);
extern void bitcache_id_fill(bitcache_id* id, const byte value);
extern bitcache_id_type bitcache_id_get_type(const bitcache_id* id);
extern size_t bitcache_id_get_size(const bitcache_id* id);
extern bool bitcache_id_equal(const bitcache_id* id1, const bitcache_id* id2);
extern guint bitcache_id_hash(const bitcache_id* id);
extern int bitcache_id_compare(const bitcache_id* id1, const bitcache_id* id2);
extern char* bitcache_id_to_hex_string(const bitcache_id* id, char* string);
extern char* bitcache_id_to_base64_string(const bitcache_id* id, char* string);
extern byte* bitcache_id_to_mpi(const bitcache_id* id);

//////////////////////////////////////////////////////////////////////////////
// Lists

#define BITCACHE_LIST_EMPTY   NULL // the canonical empty list sentinel

typedef GSList bitcache_list;
typedef void (*bitcache_list_func)(const bitcache_list* list, void* user_data);

extern bitcache_list* bitcache_list_alloc();
extern bitcache_list* bitcache_list_copy(const bitcache_list* list);
extern bitcache_list* bitcache_list_new();
extern void bitcache_list_init(bitcache_list* list);
extern void bitcache_list_free(bitcache_list* list);
extern bool bitcache_list_equal(const bitcache_list* list1, const bitcache_list* list2);
extern guint bitcache_list_hash(const bitcache_list* list);
extern bitcache_list* bitcache_list_clear(bitcache_list* list);
extern bitcache_list* bitcache_list_append(bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_prepend(const bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_insert_at(bitcache_list* list, const gint position, const bitcache_id* id);
extern bitcache_list* bitcache_list_insert_before(bitcache_list* list, const bitcache_list* next, const bitcache_id* id);
extern bitcache_list* bitcache_list_insert_after(bitcache_list* list, const bitcache_list* prev, const bitcache_id* id);
extern bitcache_list* bitcache_list_remove_at(bitcache_list* list, const gint position);
extern bitcache_list* bitcache_list_remove(bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_remove_all(bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_concat(bitcache_list* list1, const bitcache_list* list2);
extern bitcache_list* bitcache_list_reverse(const bitcache_list* list);
extern bool bitcache_list_is_empty(const bitcache_list* list);
extern guint bitcache_list_length(const bitcache_list* list);
extern guint bitcache_list_count(const bitcache_list* list, const bitcache_id* id);
extern gint bitcache_list_position(const bitcache_list* list, const bitcache_list* link);
extern gint bitcache_list_index(const bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_find(const bitcache_list* list, const bitcache_id* id);
extern bitcache_list* bitcache_list_first(const bitcache_list* list);
extern bitcache_list* bitcache_list_next(const bitcache_list* list);
extern bitcache_list* bitcache_list_nth(const bitcache_list* list, const guint n);
extern bitcache_list* bitcache_list_last(const bitcache_list* list);
extern bitcache_id* bitcache_list_first_id(const bitcache_list* list);
extern bitcache_id* bitcache_list_next_id(const bitcache_list* list);
extern bitcache_id* bitcache_list_nth_id(const bitcache_list* list, const guint n);
extern bitcache_id* bitcache_list_last_id(const bitcache_list* list);
extern void bitcache_list_each_id(const bitcache_list* list, const bitcache_id_func func, void* user_data);
//extern bitcache_set* bitcache_list_to_set(const bitcache_list* list);

//////////////////////////////////////////////////////////////////////////////
// Miscellaneous

#ifdef __cplusplus
}
#endif

#endif // BITCACHE_H
