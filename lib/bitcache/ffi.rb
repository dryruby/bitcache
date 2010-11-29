require 'ffi' # @see http://rubygems.org/gems/ffi

module Bitcache
  ##
  # A foreign-function interface (FFI) to `libbitcache`.
  #
  # @see https://github.com/ffi/ffi
  module FFI
    extend ::FFI::Library
    ffi_lib const_defined?(:LIBBITCACHE) ? LIBBITCACHE : 'libbitcache'

    ##
    # Returns the installed `libbitcache` version number.
    #
    # @example
    #   Bitcache::FFI.version  #=> "0.0.1"
    #
    # @return [String] an "x.y.z" version string
    def version
      bitcache_version_string.freeze
    end
    module_function :version

    ##
    # An FFI wrapper for the `bitcache_id` data structure.
    #
    # @see Bitcache::Identifier
    class Identifier < ::FFI::Struct
      layout :type, :int
      # TODO: wrap the `bitcache_id` data structure.
    end # Identifier

    ##
    # An FFI wrapper for the `bitcache_list` data structure.
    #
    # @see Bitcache::List
    class List < ::FFI::Struct
      layout :data, :pointer,
             :next, :pointer
      # TODO: wrap the `bitcache_list` data structure.
    end # List

    ##
    # An FFI wrapper for the `bitcache_set` data structure.
    #
    # @see Bitcache::Set
    class Set < ::FFI::Struct
      # TODO: wrap the `bitcache_set` data structure.
    end # Set

    ##
    # An FFI wrapper for the `bitcache_queue` data structure.
    #
    # @see Bitcache::Queue
    class Queue < ::FFI::Struct
      # TODO: wrap the `bitcache_queue` data structure.
    end # Queue

    ##
    # An FFI wrapper for the `bitcache_index` data structure.
    #
    # @see Bitcache::Index
    class Index < ::FFI::Struct
      # TODO: wrap the `bitcache_index` data structure.
    end # Index

    ##
    # An FFI wrapper for the `bitcache_stream` data structure.
    #
    # @see Bitcache::Stream
    class Stream < ::FFI::Struct
      # TODO: wrap the `bitcache_stream` data structure.
    end # Stream

    # Bitcache API: Typedefs
    typedef :uint8, :byte

    # Bitcache API: Constants
    NULL             = ::FFI::Pointer::NULL
    attach_variable :bitcache_version_string, :string

    # Digest API
    attach_function :bitcache_md5, [:pointer, :size_t, :pointer], :pointer
    attach_function :bitcache_sha1, [:pointer, :size_t, :pointer], :pointer
    attach_function :bitcache_sha256, [:pointer, :size_t, :pointer], :pointer

    # Identifier API: Constants
    BITCACHE_MD5     = BITCACHE_MD5_SIZE     = 16 # bytes
    BITCACHE_SHA1    = BITCACHE_SHA1_SIZE    = 20 # bytes
    BITCACHE_SHA256  = BITCACHE_SHA256_SIZE  = 32 # bytes
    BITCACHE_ID_SIZE = BITCACHE_SHA256_SIZE

    # Identifier API: Typedefs
    typedef :int,     :bitcache_id_type # FIXME?
    typedef :pointer, :bitcache_id
    typedef :pointer, :bitcache_id_md5
    typedef :pointer, :bitcache_id_sha1
    typedef :pointer, :bitcache_id_sha256
    typedef :pointer, :bitcache_id_func

    # Identifier API: Allocators
    attach_function :bitcache_id_alloc, [:bitcache_id_type], :bitcache_id
    attach_function :bitcache_id_free, [:bitcache_id], :void

    # Identifier API: Constructors
    attach_function :bitcache_id_new, [:bitcache_id_type, :pointer], :bitcache_id
    attach_function :bitcache_id_new_md5, [:pointer], :bitcache_id
    attach_function :bitcache_id_new_sha1, [:pointer], :bitcache_id
    attach_function :bitcache_id_new_sha256, [:pointer], :bitcache_id
    attach_function :bitcache_id_new_from_hex_string, [:string], :bitcache_id
    attach_function :bitcache_id_new_from_base64_string, [:string], :bitcache_id
    attach_function :bitcache_id_copy, [:bitcache_id], :bitcache_id

    # Identifier API: Mutators
    attach_function :bitcache_id_init, [:bitcache_id, :bitcache_id_type, :pointer], :void
    attach_function :bitcache_id_clear, [:bitcache_id], :void
    attach_function :bitcache_id_fill, [:bitcache_id, :byte], :void

    # Identifier API: Accessors
    attach_function :bitcache_id_get_hash, [:bitcache_id], :uint
    attach_function :bitcache_id_get_type, [:bitcache_id], :bitcache_id_type
    attach_function :bitcache_id_get_digest, [:bitcache_id], :pointer
    attach_function :bitcache_id_get_digest_size, [:bitcache_id], :size_t

    # Identifier API: Predicates
    attach_function :bitcache_id_is_equal, [:bitcache_id, :bitcache_id], :bool
    attach_function :bitcache_id_is_zero, [:bitcache_id], :bool

    # Identifier API: Comparators
    attach_function :bitcache_id_compare, [:bitcache_id, :bitcache_id], :int

    # Identifier API: Converters
    attach_function :bitcache_id_to_hex_string, [:bitcache_id, :pointer], :string
    attach_function :bitcache_id_to_base64_string, [:bitcache_id, :pointer], :string
    attach_function :bitcache_id_to_mpi, [:bitcache_id, :pointer], :pointer

    # List API: Constants
    BITCACHE_LIST_SENTINEL = nil

    # List API: Typedefs
    typedef :pointer, :bitcache_list_element
    typedef :pointer, :bitcache_list

    # List API: Allocators
    attach_function :bitcache_list_element_alloc, [], :bitcache_list_element
    attach_function :bitcache_list_element_free, [:bitcache_list_element], :void
    attach_function :bitcache_list_alloc, [], :bitcache_list
    attach_function :bitcache_list_free, [:bitcache_list], :void

    # List API: Constructors
    attach_function :bitcache_list_element_new, [:bitcache_id, :bitcache_list_element], :bitcache_list_element
    attach_function :bitcache_list_element_copy, [:bitcache_list_element], :bitcache_list_element
    attach_function :bitcache_list_new, [:bitcache_list_element], :bitcache_list
    attach_function :bitcache_list_copy, [:bitcache_list], :bitcache_list

    # List API: Mutators
    attach_function :bitcache_list_element_init, [:bitcache_list_element, :bitcache_id, :bitcache_list_element], :void
    attach_function :bitcache_list_init, [:bitcache_list, :bitcache_list_element], :void
    attach_function :bitcache_list_clear, [:bitcache_list], :void
    attach_function :bitcache_list_prepend, [:bitcache_list, :bitcache_id], :void
    attach_function :bitcache_list_append, [:bitcache_list, :bitcache_id], :void
    attach_function :bitcache_list_insert, [:bitcache_list, :bitcache_id], :void
    attach_function :bitcache_list_insert_at, [:bitcache_list, :int, :bitcache_id], :void
    attach_function :bitcache_list_insert_before, [:bitcache_list, :bitcache_list_element, :bitcache_id], :void
    attach_function :bitcache_list_insert_after, [:bitcache_list, :bitcache_list_element, :bitcache_id], :void
    attach_function :bitcache_list_remove, [:bitcache_list, :bitcache_id], :void
    attach_function :bitcache_list_remove_all, [:bitcache_list, :bitcache_id], :void
    attach_function :bitcache_list_remove_at, [:bitcache_list, :int], :void
    attach_function :bitcache_list_reverse, [:bitcache_list], :void
    attach_function :bitcache_list_concat, [:bitcache_list, :bitcache_list], :void

    # List API: Accessors
    attach_function :bitcache_list_get_hash, [:bitcache_list], :uint
    attach_function :bitcache_list_get_length, [:bitcache_list], :uint
    attach_function :bitcache_list_get_count, [:bitcache_list, :bitcache_id], :uint
    attach_function :bitcache_list_get_position, [:bitcache_list, :bitcache_id], :uint
    attach_function :bitcache_list_get_rest, [:bitcache_list], :bitcache_list_element
    attach_function :bitcache_list_get_first, [:bitcache_list], :bitcache_id
    attach_function :bitcache_list_get_last, [:bitcache_list], :bitcache_id
    attach_function :bitcache_list_get_nth, [:bitcache_list, :int], :bitcache_id

    # List API: Predicates
    attach_function :bitcache_list_is_equal, [:bitcache_list, :bitcache_list], :bool
    attach_function :bitcache_list_is_empty, [:bitcache_list], :bool

    # List API: Iterators
    attach_function :bitcache_list_foreach, [:bitcache_list, :bitcache_id_func, :pointer], :void
  end # FFI
end # Bitcache
