/* This is free and unencumbered software released into the public domain. */

#include "build.h"

const char* const bitcache_version_string = PACKAGE_VERSION;

const char* const bitcache_feature_names[] = {
  "base",
#ifndef NDEBUG
  "debug",
#endif
#ifndef DISABLE_THREADS
  "threads",
#endif
#ifndef DISABLE_MD5
  "md5",
#endif
#ifndef DISABLE_SHA1
  "sha1",
#endif
  NULL
};

const unsigned int bitcache_feature_count =
  (sizeof(bitcache_feature_names) / sizeof(bitcache_feature_names[0])) - 1;

const char* const bitcache_module_names[] = {
  "filter",
  "id",
  "map",
  "set",
  "tree",
  NULL
};

const unsigned int bitcache_module_count =
  (sizeof(bitcache_module_names) / sizeof(bitcache_module_names[0])) - 1;

bool
bitcache_has_feature(const char* const restrict name) {
  validate_with_false_return(name != NULL);

  for (unsigned int i = 0; i < bitcache_feature_count; i++) {
    if (unlikely(str_equal(bitcache_feature_names[i], name))) {
      return TRUE;
    }
  }
  return FALSE;
}

bool
bitcache_has_module(const char* const restrict name) {
  validate_with_false_return(name != NULL);

  for (unsigned int i = 0; i < bitcache_module_count; i++) {
    if (unlikely(str_equal(bitcache_module_names[i], name))) {
      return TRUE;
    }
  }
  return FALSE;
}
