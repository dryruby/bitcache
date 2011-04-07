AM_CFLAGS              = -std=c99 -pedantic
AM_CPPFLAGS            = -DMT $(GLIB_CFLAGS) -DG_DISABLE_DEPRECATED=1
LDADD                  = libbitcache.la
lib_LTLIBRARIES        = libbitcache.la
libbitcache_la_SOURCES = bitcache.h bitcache.c bitcache_arch.h bitcache_id.h bitcache_id.c bitcache_map.h bitcache_map.c bitcache_tree.h bitcache_tree.c
libbitcache_la_LIBADD  = $(GLIB_LIBS) -lcrypto
include_HEADERS        = bitcache.h
bin_PROGRAMS           = bitcached bit bit-id
bitcached_SOURCES      = bitcache.h bitcached.c
bit_SOURCES            = bitcache.h bit.c
bit_id_SOURCES         = bitcache.h bit-id.c
