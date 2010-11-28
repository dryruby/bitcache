AM_CFLAGS              = -std=c99 -pedantic
AM_CPPFLAGS            = $(GLIB_CFLAGS) -DG_DISABLE_DEPRECATED=1
LDADD                  = libbitcache.la
lib_LTLIBRARIES        = libbitcache.la
libbitcache_la_SOURCES = bitcache.h bitcache.c
libbitcache_la_LIBADD  = $(GLIB_LIBS) -lcrypto
include_HEADERS        = bitcache.h
bin_PROGRAMS           = bit bitcached
bit_SOURCES            = bitcache.h bit.c
bitcached_SOURCES      = bitcache.h bitcached.c
