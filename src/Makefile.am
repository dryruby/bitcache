AM_CFLAGS       = -std=gnu99 -pedantic -fPIC -DPIC -pipe
AM_CPPFLAGS     = -D_GNU_SOURCE -D_REENTRANT $(GLIB_CFLAGS) -DG_DISABLE_DEPRECATED=1
AM_LDFLAGS      = -rdynamic
LDADD           = libbitcache.la
lib_LTLIBRARIES = libbitcache.la

libbitcache_la_LIBADD  = $(GLIB_LIBS) -lcrypto
libbitcache_la_SOURCES = bitcache.c \
  bitcache_filter.c \
  bitcache_id.c \
  bitcache_map.c \
  bitcache_set.c \
  bitcache_tree.c

include_HEADERS = bitcache.h

pkginclude_HEADERS = \
  bitcache_arch.h \
  bitcache_filter.h \
  bitcache_id.h \
  bitcache_map.h \
  bitcache_set.h \
  bitcache_tree.h
