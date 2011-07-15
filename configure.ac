AC_INIT([bitcache], [0.0.1], [bitcache@googlegroups.com])
AC_CONFIG_SRCDIR([src/bitcache.h])
AC_CONFIG_AUX_DIR([etc/aclocal])
AC_CONFIG_MACRO_DIR([etc/aclocal])
AM_INIT_AUTOMAKE([foreign -Wall -Werror dist-bzip2])
AM_SILENT_RULES([yes])
LT_INIT
AC_PROG_CC
AC_CANONICAL_HOST
dnl C89 header files:
AC_CHECK_HEADERS_ONCE([assert.h ctype.h limits.h setjmp.h stdarg.h])
dnl C99 header files:
AC_CHECK_HEADERS_ONCE([complex.h ctype.h inttypes.h stdbool.h stdint.h tgmath.h])
dnl C1X header files:
AC_CHECK_HEADERS_ONCE([stdatomic.h threads.h uchar.h])
dnl POSIX header files:
AC_CHECK_HEADERS_ONCE([dirent.h errno.h iconv.h libgen.h mqueue.h poll.h
                       pthread.h sched.h syslog.h])
dnl Linux header files:
AC_CHECK_HEADERS_ONCE([execinfo.h])
dnl libcprime (https://github.com/bendiken/libcprime)
AC_CHECK_HEADERS([cprime.h],
  AC_SEARCH_LIBS([string_alloc], [cprime]),
  AC_MSG_ERROR([*** Header file cprime.h not found; install https://github.com/bendiken/libcprime ***]))
dnl libcrypto (libssl-dev on Ubuntu, openssl on Mac OS X + MacPorts)
AC_CHECK_HEADERS([openssl/sha.h],
  AC_SEARCH_LIBS([SHA1], [crypto]),
  AC_MSG_ERROR([*** Header file openssl/sha.h not found; install the libssl-dev package ***]))
dnl glib (libglib2.0-dev on Ubuntu, glib2 on Mac OS X + MacPorts)
AM_PATH_GLIB_2_0([2.24.0], [], [], [gthread])
AC_CONFIG_HEADERS([config.h])
dnl AC_CONFIG_FILES([Makefile src/Makefile doc/Makefile doc/man/Makefile])
AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
