AM_CFLAGS              = -std=c99 -pedantic
AM_CPPFLAGS            = -DMT $(GLIB_CFLAGS) -DG_DISABLE_DEPRECATED=1
LDADD                  = libbitcache.la
lib_LTLIBRARIES        = libbitcache.la
libbitcache_la_SOURCES = bitcache.h bitcache.c bitcache_arch.h \
  bitcache_filter.h bitcache_filter.c \
  bitcache_id.h bitcache_id.c \
  bitcache_map.h bitcache_map.c \
  bitcache_set.h bitcache_set.c \
  bitcache_tree.h bitcache_tree.c
libbitcache_la_LIBADD  = $(GLIB_LIBS) -lcrypto
include_HEADERS        = bitcache.h
