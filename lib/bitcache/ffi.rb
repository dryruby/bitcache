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
    # An FFI wrapper for the `bitcache_stream` data structure.
    #
    # @see Bitcache::Stream
    class Stream < ::FFI::Struct
      # TODO: wrap the `bitcache_stream` data structure.
    end # Stream

    ##
    # @param  [Symbol] name
    # @return [void]
    def define_type(name, type = :pointer)
      self.class.send(:define_method, name) { type }
      self.send(:define_method, name) { type }
    end
    module_function :define_type

    # Types
    define_type     :byte, :uint8
    define_type     :bitcache_id_type, :int # FIXME?
    define_type     :bitcache_id, :pointer
    define_type     :bitcache_id_md5, :pointer
    define_type     :bitcache_id_sha1, :pointer
    define_type     :bitcache_id_sha256, :pointer
    define_type     :bitcache_list, :pointer

    # Constants
    attach_variable :bitcache_version_string, :string

    # Digests
    attach_function :bitcache_md5, [:pointer, :size_t, :pointer], :pointer
    attach_function :bitcache_sha1, [:pointer, :size_t, :pointer], :pointer
    attach_function :bitcache_sha256, [:pointer, :size_t, :pointer], :pointer

    # Identifiers
    BITCACHE_MD5_SIZE     = 16 # bytes
    BITCACHE_SHA1_SIZE    = 20 # bytes
    BITCACHE_SHA256_SIZE  = 32 # bytes
    BITCACHE_ID_SIZE      = BITCACHE_SHA256_SIZE
    attach_function :bitcache_id_alloc, [bitcache_id_type], bitcache_id
    attach_function :bitcache_id_copy, [bitcache_id], bitcache_id
    attach_function :bitcache_id_new_md5, [:pointer], bitcache_id
    attach_function :bitcache_id_new_sha1, [:pointer], bitcache_id
    attach_function :bitcache_id_new_sha256, [:pointer], bitcache_id
    attach_function :bitcache_id_new, [bitcache_id_type, :pointer], bitcache_id
    attach_function :bitcache_id_new_from_hex_string, [:string], bitcache_id
    attach_function :bitcache_id_new_from_base64_string, [:string], bitcache_id
    attach_function :bitcache_id_init, [bitcache_id, bitcache_id_type, :pointer], :void
    attach_function :bitcache_id_free, [bitcache_id], :void
    attach_function :bitcache_id_clear, [bitcache_id], :void
    attach_function :bitcache_id_fill, [bitcache_id, byte], :void
    attach_function :bitcache_id_get_type, [bitcache_id], bitcache_id_type
    attach_function :bitcache_id_get_size, [bitcache_id], :size_t
    attach_function :bitcache_id_equal, [bitcache_id, bitcache_id], :bool
    attach_function :bitcache_id_hash, [bitcache_id], :uint
    attach_function :bitcache_id_compare, [bitcache_id, bitcache_id], :int
    attach_function :bitcache_id_to_hex_string, [bitcache_id, :string], :string
    attach_function :bitcache_id_to_base64_string, [bitcache_id, :string], :string
    attach_function :bitcache_id_to_mpi, [bitcache_id], :pointer

    # Lists
    BITCACHE_LIST_EMPTY   = nil # the canonical empty list sentinel
    attach_function :bitcache_list_alloc, [], bitcache_list
    attach_function :bitcache_list_copy, [bitcache_list], bitcache_list
    attach_function :bitcache_list_new, [], bitcache_list
    attach_function :bitcache_list_init, [bitcache_list], :void
    attach_function :bitcache_list_free, [bitcache_list], :void
    attach_function :bitcache_list_equal, [bitcache_list, bitcache_list], :bool
    attach_function :bitcache_list_hash, [bitcache_list], :uint
    attach_function :bitcache_list_clear, [bitcache_list], bitcache_list
    attach_function :bitcache_list_append, [bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_prepend, [bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_insert_at, [bitcache_list, :int, bitcache_id], bitcache_list
    attach_function :bitcache_list_insert_before, [bitcache_list, bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_insert_after, [bitcache_list, bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_remove_at, [bitcache_list, :int], bitcache_list
    attach_function :bitcache_list_remove, [bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_remove_all, [bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_concat, [bitcache_list, bitcache_list], bitcache_list
    attach_function :bitcache_list_reverse, [bitcache_list], bitcache_list
    attach_function :bitcache_list_is_empty, [bitcache_list], :bool
    attach_function :bitcache_list_length, [bitcache_list], :uint
    attach_function :bitcache_list_count, [bitcache_list, bitcache_id], :uint
    attach_function :bitcache_list_position, [bitcache_list, bitcache_list], :int
    attach_function :bitcache_list_index, [bitcache_list, bitcache_id], :int
    attach_function :bitcache_list_find, [bitcache_list, bitcache_id], bitcache_list
    attach_function :bitcache_list_first, [bitcache_list], bitcache_list
    attach_function :bitcache_list_next, [bitcache_list], bitcache_list
    attach_function :bitcache_list_nth, [bitcache_list, :uint], bitcache_list
    attach_function :bitcache_list_last, [bitcache_list], bitcache_list
    attach_function :bitcache_list_first_id, [bitcache_list], bitcache_id
    attach_function :bitcache_list_next_id, [bitcache_list], bitcache_id
    attach_function :bitcache_list_nth_id, [bitcache_list, :uint], bitcache_id
    attach_function :bitcache_list_last_id, [bitcache_list], bitcache_id
    attach_function :bitcache_list_each_id, [bitcache_list, :pointer, :pointer], :void
  end # FFI
end # Bitcache
