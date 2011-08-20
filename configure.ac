dnl configure.ac                                        -*- Autoconf -*-
dnl
dnl Process this file with `autoconf` to produce a configure script.
dnl
dnl This is free and unencumbered software released into the public domain.
AC_PREREQ([2.60])

dnl Define version information:
m4_define([VERSION_MAJOR], 0)
m4_define([VERSION_MINOR], 0)
m4_define([VERSION_PATCH], 1)
m4_define([VERSION_STRING], [VERSION_MAJOR.VERSION_MINOR.VERSION_PATCH])

dnl Define package information:
AC_INIT([Bitcache], [VERSION_STRING],
  [bitcache@googlegroups.com], [bitcache],
  [https://github.com/bendiken/bitcache])

dnl Configure Autoconf:
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR([src/bitcache.h.in])
AC_CONFIG_AUX_DIR([etc/aclocal])
AC_CONFIG_MACRO_DIR([etc/aclocal])

dnl Configure Automake:
AM_INIT_AUTOMAKE([foreign -Wall -Werror dist-bzip2 subdir-objects])
AM_SILENT_RULES([yes])

dnl Check for programs:
LT_INIT
AC_PROG_CC
AC_PROG_CC_C99
AM_PROG_CC_C_O

dnl Check for configuration options:
AC_ARG_ENABLE([threads],
  [AS_HELP_STRING([--disable-threads], [omit support for thread safety])])
AS_IF([test "x$enable_threads" == "xno"], [
  AC_DEFINE([DISABLE_THREADS], 1, [Define to disable thread-safety features.])
])
AC_ARG_ENABLE([md5],
  [AS_HELP_STRING([--disable-md5], [omit support for the MD5 algorithm])])
AS_IF([test "x$enable_md5" == "xno"], [
  AC_DEFINE([DISABLE_MD5], 1, [Define to disable the MD5 algorithm.])
])
AM_CONDITIONAL([ENABLE_MD5], [test "x$enable_md5" != "xno"])
AC_ARG_ENABLE([sha1],
  [AS_HELP_STRING([--disable-sha1], [omit support for the SHA-1 algorithm])])
AS_IF([test "x$enable_sha1" == "xno"], [
  AC_DEFINE([DISABLE_SHA1], 1, [Define to disable the SHA-1 algorithm.])
])
AM_CONDITIONAL([ENABLE_SHA1], [test "x$enable_sha1" != "xno"])

dnl Check for libraries:
# libcprime (https://github.com/bendiken/libcprime)
AC_CHECK_HEADERS([cprime.h],
  AC_SEARCH_LIBS([string_alloc], [cprime], [],
    AC_MSG_ERROR([*** C′ library libcprime not found; install https://github.com/bendiken/libcprime ***])),
  AC_MSG_ERROR([*** C′ header file <cprime.h> not found; install https://github.com/bendiken/libcprime ***]))
# libcrypto (libssl-dev on Ubuntu, openssl on Mac OS X + MacPorts)
AC_CHECK_HEADERS([openssl/sha.h],
  AC_SEARCH_LIBS([SHA1], [crypto], [],
    AC_MSG_ERROR([*** OpenSSL library libcrypto not found; install the libssl-dev package ***])),
  AC_MSG_ERROR([*** OpenSSL header file <openssl/sha.h> not found; install the libssl-dev package ***]))
# glib (libglib2.0-dev on Ubuntu, glib2 on Mac OS X + MacPorts)
AM_PATH_GLIB_2_0([2.24.0], [], [], [gthread])

dnl Check for header files:
# C89 header files:
AC_CHECK_HEADERS_ONCE([assert.h ctype.h limits.h setjmp.h stdarg.h])
# C99 header files:
AC_CHECK_HEADERS_ONCE([complex.h ctype.h inttypes.h stdbool.h stdint.h tgmath.h])
AC_HEADER_STDBOOL
# C1X header files:
AC_CHECK_HEADERS_ONCE([stdatomic.h threads.h uchar.h])
# POSIX header files:
AC_CHECK_HEADERS_ONCE([dirent.h errno.h iconv.h libgen.h mqueue.h poll.h
                       sched.h signal.h syslog.h sys/resource.h sys/wait.h])
# GNU header files:
AC_CHECK_HEADERS_ONCE([execinfo.h])

dnl Check for types:

dnl Check for structures:

dnl Check for compiler characteristics:
AC_CANONICAL_HOST
AC_C_BIGENDIAN
AC_C_INLINE
AC_C_RESTRICT

dnl Check for library functions:
AC_FUNC_ALLOCA
AC_FUNC_FORK
AC_FUNC_FSEEKO
AC_FUNC_MMAP
AC_FUNC_STRERROR_R
AC_CHECK_FUNCS_ONCE([backtrace])

dnl Check for system services:
AC_SYS_LARGEFILE
AC_SYS_LONG_FILE_NAMES

dnl Generate output:
dnl AC_CONFIG_FILES([Makefile src/Makefile doc/Makefile doc/man/Makefile])
AC_CONFIG_FILES([Makefile src/Makefile])
AC_SUBST([PACKAGE_VERSION_MAJOR], ["VERSION_MAJOR"])
AC_SUBST([PACKAGE_VERSION_MINOR], ["VERSION_MINOR"])
AC_SUBST([PACKAGE_VERSION_PATCH], ["VERSION_PATCH"])
AC_CONFIG_FILES([src/bitcache.h])
AC_OUTPUT
