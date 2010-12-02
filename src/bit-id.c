/* This is free and unencumbered software released into the public domain. */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "bitcache.h"
#include "config.h"

#define PROGRAM_DESCRIPTION "identify a byte stream or file"
#define PROGRAM_SUMMARY     "FILES... - " PROGRAM_DESCRIPTION
#define DIGEST_TYPE         BITCACHE_SHA1
#define DIGEST_SIZE         BITCACHE_SHA1_SIZE

static bool debug   = FALSE;
static bool verbose = FALSE;
static bool version = FALSE;

static GOptionEntry entries[] = {
   { "debug",   'd', 0, G_OPTION_ARG_NONE, &debug,   "Enable debug output for troubleshooting.", NULL },
   { "verbose", 'v', 0, G_OPTION_ARG_NONE, &verbose, "Enable verbose output. May be given more than once.", NULL },
   { "version", 'V', 0, G_OPTION_ARG_NONE, &version, "Display the Bitcache version and exit.", NULL },
   { NULL },
};

int main(int argc, char* argv[]) {
  GError* error = NULL;
  GOptionContext* context = g_option_context_new(PROGRAM_SUMMARY);
  g_option_context_add_main_entries(context, entries, NULL);
  if (!g_option_context_parse(context, &argc, &argv, &error)) {
    fprintf(stderr, "%s: %s\n", g_get_prgname(), error->message);
    return 1;
  }

  if (version) {
    // Display the Bitcache version and exit:
    printf("%s\n", PACKAGE_VERSION);
    return 0;
  }

  if (argc < 2) {
    // TODO: read standard input
    return 0;
  }

  char buffer[DIGEST_SIZE * 2 + 1];
  bitcache_id id;
  bitcache_id_init(&id, DIGEST_TYPE, NULL);

  for (int i = 1; i < argc; i++) {
    int fd = open(argv[i], O_RDONLY);
    if (fd == -1) {
      perror("open");
      return 1;
    }

    struct stat sb;
    if (fstat(fd, &sb) == -1) {
      perror("fstat");
      return 1;
    }

    if (!S_ISREG(sb.st_mode)) {
      fprintf(stderr, "%s: %s: Is not a file\n", g_get_prgname(), argv[i]);
      return 1;
    }

    byte* data = mmap(0, sb.st_size, PROT_READ, MAP_FILE | MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
      perror("mmap");
      return 1;
    }

    bitcache_id_clear(&id);
    bitcache_sha1(data, sb.st_size, id.digest);
    bitcache_id_to_hex_string(&id, buffer);
    printf("%s\n", buffer);

    if (munmap(data, sb.st_size) == -1) {
      perror("munmap");
      return 1;
    }

    if (close(fd) == -1) {
      perror("close");
      return 1;
    }
  }

  return 0;
}
