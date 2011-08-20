AM_CFLAGS       = -Wall -Wextra -pedantic -fPIC -DPIC -pipe
AM_CPPFLAGS     = -D_GNU_SOURCE -D_REENTRANT $(GLIB_CFLAGS) -DG_DISABLE_DEPRECATED=1
AM_LDFLAGS      = -rdynamic
LDADD           = libbitcache.la
lib_LTLIBRARIES = libbitcache.la

libbitcache_la_LIBADD  = $(GLIB_LIBS)
libbitcache_la_SOURCES = bitcache.c \
  filter.c \
  id.c \
  map.c \
  set.c \
  tree.c

include_HEADERS = bitcache.h

pkginclude_HEADERS = \
  arch.h \
  filter.h \
  id.h \
  map.h \
  set.h \
  tree.h

if ENABLE_MD5
  libbitcache_la_SOURCES += md5.c
  pkginclude_HEADERS     += md5.h
endif

if ENABLE_SHA1
  libbitcache_la_SOURCES += sha1.c
  pkginclude_HEADERS     += sha1.h
endif
