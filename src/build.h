/* This is free and unencumbered software released into the public domain. */

#ifndef _BITCACHE_BUILD_H
#define _BITCACHE_BUILD_H

#ifdef __cplusplus
extern "C" {
#endif

/* private headers for the build process only */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

/* libcprime headers */
#include <cprime.h>
#include <cprime/memory.h>

/* private headers for the build process only */
#include "arch.h"

/* public headers included from <bitcache.h> */
#ifndef DISABLE_MD5
#include "md5.h"
#endif
#ifndef DISABLE_SHA1
#include "sha1.h"
#endif
#include "id.h"
#include "filter.h"
#include "map.h"
#include "set.h"
#include "tree.h"

/* standard library headers */
#include <stdlib.h> /* for calloc(), free(), malloc() */

#ifdef __cplusplus
}
#endif

#endif /* _BITCACHE_BUILD_H */
