/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_ID_H
#define _BITCACHE_ID_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h> /* for bool */
#include <stdint.h>  /* for uint8_t, uint32_t */
#include <unistd.h>  /* for ssize_t */

typedef struct {
  uint8_t digest[20];
} bitcache_id_t;

extern int bitcache_id_init(bitcache_id_t* id, const uint8_t* digest);
extern ssize_t bitcache_id_parse(bitcache_id_t* id, const char* hexstring);
extern ssize_t bitcache_id_serialize(const bitcache_id_t* id, char* buffer, size_t buffer_size);
extern int bitcache_id_clear(bitcache_id_t* id);
extern int bitcache_id_fill(bitcache_id_t* id, const uint8_t value);
extern bool bitcache_id_equal(const bitcache_id_t* id1, const bitcache_id_t* id2);
extern int bitcache_id_compare(const bitcache_id_t* id1, const bitcache_id_t* id2);
extern uint32_t bitcache_id_hash(const bitcache_id_t* id);

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_ID_H */
