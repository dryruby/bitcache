/* This is free and unencumbered software released into the public domain. */

#ifndef BITCACHE_ARCH_H
#define BITCACHE_ARCH_H

#ifdef __cplusplus
extern "C" {
#endif

/* branch prediction hints */
#if 1
#define likely(x)         __builtin_expect(!!(x), 1) /* `x` is likely to evaluate to TRUE   */
#define unlikely(x)       __builtin_expect(!!(x), 0) /* `x` is unlikely to evaluate to TRUE */
#else
#define likely(x)         x
#define unlikely(x)       x
#endif

#ifdef __cplusplus
}
#endif

#endif /* BITCACHE_ARCH_H */
