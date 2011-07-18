/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_ARCH_H
#define _BITCACHE_ARCH_H

#ifdef __cplusplus
extern "C" {
#endif

/* GCC-specific optimizations */
// @see http://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html
#ifdef __GNUC__
# define NONNULL __attribute__((__nonnull__)) /* the function requires non-NULL arguments */
# define FLATTEN __attribute__((__flatten__)  /* inline every call inside the function, if possible */
# define PURE    __attribute__((__pure__))    /* declare that the function has no side effects */
# if __GNUC_VERSION__ >= 40300
#  define HOT    __attribute__((__hot__))     /* the function is a hot spot (GCC 4.3+ only) */
#  define COLD   __attribute__((__cold__))    /* the function is unlikely to be executed (GCC 4.3+ only) */
# else
#  define HOT
#  define COLD
# endif
#else  /* !__GNUC__ */
# define NONNULL
# define FLATTEN
# define PURE
# define HOT
# define COLD
#endif /* __GNUC__ */

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_ARCH_H */
