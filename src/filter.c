/* This is free and unencumbered software released into the public domain. */

#include "build.h"
#include <assert.h>
#include <errno.h>
#include <strings.h>
#include <sys/mman.h> /* for mmap() */
#include <sys/stat.h> /* for fstat() */
#include <unistd.h>   /* for getpagesize(), lseek(), write() */

//////////////////////////////////////////////////////////////////////////////
// Filter API

int
bitcache_filter_init(bitcache_filter_t* filter, const size_t size) {
  if (unlikely(filter == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(filter, sizeof(bitcache_filter_t));

  if (likely(size > 0)) {
    filter->size = size;
    filter->bitmap = calloc(1, size);
    if (unlikely(filter->bitmap == NULL))
      return -errno; // cannot allocate memory
  }

  return 0;
}

int
bitcache_filter_reset(bitcache_filter_t* filter) {
  if (unlikely(filter == NULL))
    return -(errno = EINVAL); // invalid argument

  if (likely(filter->bitmap != NULL)) {
    free(filter->bitmap), filter->bitmap = NULL;
    filter->size = 0;
  }

  return 0;
}

int
bitcache_filter_clear(bitcache_filter_t* filter) {
  if (unlikely(filter == NULL || filter->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument

  bzero(filter->bitmap, filter->size);

  return 0;
}

ssize_t PURE
bitcache_filter_size(const bitcache_filter_t* filter) {
  if (unlikely(filter == NULL))
    return -(errno = EINVAL); // invalid argument

  return sizeof(bitcache_filter_t) + filter->size;
}

long HOT
bitcache_filter_count(const bitcache_filter_t* filter, const bitcache_id_t* id) {
  if (unlikely(filter == NULL || filter->bitmap == NULL || id == NULL))
    return -(errno = EINVAL); // invalid argument

  // false positives are possible, but false negatives are not:
  return (bitcache_filter_lookup(filter, id) != FALSE) ? 1 : 0;
}

bool HOT
bitcache_filter_lookup(const bitcache_filter_t* filter, const bitcache_id_t* id) {
  if (unlikely(filter == NULL || filter->bitmap == NULL || id == NULL))
    return errno = EINVAL, FALSE; // invalid argument

  bool found = TRUE; // false positives are possible

  const uint32_t m = filter->size * 8;
  for (int k = 0; k < BITCACHE_FILTER_K_MAX; k++) {
    const uint32_t i = ((uint32_t*)id)[k] % m;
    const uint8_t* p = filter->bitmap + (i >> 3);
    const uint8_t  b = 1 << (i & 7);

    if ((*p & b) == 0) { // check whether the bit at bitmap[i] is 0
      found = FALSE; // false negatives are NOT possible
      break;
    }
  }

  return found;
}

int HOT
bitcache_filter_insert(bitcache_filter_t* filter, const bitcache_id_t* id) {
  if (unlikely(filter == NULL || filter->bitmap == NULL || id == NULL))
    return -(errno = EINVAL); // invalid argument

  const uint32_t m = filter->size * 8;
  for (int k = 0; k < BITCACHE_FILTER_K_MAX; k++) {
    const uint32_t i = ((uint32_t*)id)[k] % m;
    uint8_t* const p = filter->bitmap + (i >> 3);
    const uint8_t  b = 1 << (i & 7);

    *p |= b; // set the bit at bitmap[i] to 1
  }

  return 0;
}

int
bitcache_filter_compare(const bitcache_filter_t* filter1, const bitcache_filter_t* filter2) {
  if (unlikely(filter1 == NULL || filter1->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument
  if (unlikely(filter2 == NULL || filter2->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument
  if (unlikely(filter1->size != filter2->size))
    return -(errno = EINVAL); // invalid argument

  return bcmp(filter1->bitmap, filter2->bitmap, filter1->size);
}

int
bitcache_filter_merge(bitcache_filter_t* filter0, const bitcache_filter_op_t op, const bitcache_filter_t* filter1, const bitcache_filter_t* filter2) {
  if (unlikely(filter0 == NULL || filter0->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument
  if (unlikely(filter1 == NULL || filter1->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument
  if (unlikely(filter2 == NULL || filter2->bitmap == NULL))
    return -(errno = EINVAL); // invalid argument
  if (unlikely(filter0->size != filter1->size || filter1->size != filter2->size))
    return -(errno = EINVAL); // invalid argument

  switch (op) {
    case BITCACHE_FILTER_NOP:
      // do nothing
      break;
    case BITCACHE_FILTER_OR:
      for (int i = 0; i < filter0->size; i++)
        filter0->bitmap[i] = filter1->bitmap[i] | filter2->bitmap[i];
      break;
    case BITCACHE_FILTER_AND:
      for (int i = 0; i < filter0->size; i++)
        filter0->bitmap[i] = filter1->bitmap[i] & filter2->bitmap[i];
      break;
    case BITCACHE_FILTER_XOR:
      for (int i = 0; i < filter0->size; i++)
        filter0->bitmap[i] = filter1->bitmap[i] ^ filter2->bitmap[i];
      break;
    default:
      return -(errno = EINVAL); // invalid argument
  }

  return 0;
}

static inline NONNULL int
bitcache_filter_load_from_file(bitcache_filter_t* filter, const int fd, const off_t off) {
  if (likely(filter->size == 0)) {
    struct stat sb;
    if (unlikely(fstat(fd, &sb) == -1)) {
      return -errno;
    }
    filter->size = sb.st_size - off;
  }

  void* base = mmap(NULL, filter->size, PROT_READ, MAP_SHARED, fd, off);
  if (unlikely(base == MAP_FAILED)) {
    return -errno;
  }

  filter->bitmap = base;
  return filter->size;
}

static inline NONNULL int
bitcache_filter_load_from_pipe(bitcache_filter_t* filter, const int fd) {
  return -(errno = ESPIPE); // TODO
}

int COLD
bitcache_filter_load(bitcache_filter_t* filter, const int fd) {
  if (unlikely(filter == NULL || fd < 0))
    return -(errno = EINVAL); // invalid argument

  // figure out the current file offset:
  off_t off = lseek(fd, 0, SEEK_CUR);
  if (unlikely(off == -1)) {
    switch (errno) {
      case ESPIPE:
        // the file descriptor is associated with a pipe, socket, or FIFO:
        return bitcache_filter_load_from_pipe(filter, fd);
      default:
        return -errno;
    }
  }

  return bitcache_filter_load_from_file(filter, fd, off);
}

int COLD
bitcache_filter_dump(const bitcache_filter_t* filter, const int fd) {
  if (unlikely(filter == NULL || filter->bitmap == NULL || fd < 0))
    return -(errno = EINVAL); // invalid argument

  uint8_t* buffer = filter->bitmap;
  size_t buffer_size = filter->size;
  size_t bytes_written = 0;

  while (bytes_written < buffer_size) {
    bytes_written = write(fd, buffer, buffer_size);
    if (unlikely(bytes_written == -1)) {
      switch (errno) {
        case EINTR:
        case EAGAIN:
          continue; // retry the write()
        default:
          return -errno;
      }
    }
    buffer += bytes_written;
    buffer_size -= bytes_written;
  }

  return filter->size;
}
