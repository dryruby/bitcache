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
