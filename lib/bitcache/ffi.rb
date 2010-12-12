require 'ffi' # @see http://rubygems.org/gems/ffi

module Bitcache
  ##
  # A foreign-function interface (FFI) to `libbitcache`.
  #
  # @see https://github.com/ffi/ffi
  module FFI
    extend  ::FFI::Library
    ffi_lib const_defined?(:LIBBITCACHE) ? LIBBITCACHE : 'libbitcache'

    autoload :Block,      'bitcache/ffi/block'
    autoload :Filter,     'bitcache/ffi/filter'
    autoload :Identifier, 'bitcache/ffi/id'
    autoload :Index,      'bitcache/ffi/index'
    autoload :List,       'bitcache/ffi/list'
    autoload :Queue,      'bitcache/ffi/queue'
    autoload :Set,        'bitcache/ffi/set'
    autoload :Stream,     'bitcache/ffi/stream'

    send(:include, ::FFI) # roundabout, so as to avoid confusing YARD

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

    # Bitcache API: Typedefs
    typedef :uint8,   :byte
    typedef :int,     :bitcache_id_type # FIXME?
    typedef :pointer, :bitcache_id
    typedef :pointer, :bitcache_id_md5
    typedef :pointer, :bitcache_id_sha1
    typedef :pointer, :bitcache_id_sha256
    typedef :pointer, :bitcache_id_func
    typedef :pointer, :bitcache_filter
    typedef :pointer, :bitcache_list_element
    typedef :pointer, :bitcache_list
    typedef :int,     :bitcache_op # FIXME?
    typedef :pointer, :bitcache_set

    # Bitcache API: Constants
    NULL             = ::FFI::Pointer::NULL
    BITCACHE_OP_NOP  = 0 # no-op
    BITCACHE_OP_OR   = 1 # logical or  (set union)
    BITCACHE_OP_AND  = 2 # logical and (set intersection)
    BITCACHE_OP_XOR  = 3 # logical xor (set difference)

    # Bitcache API: Variables
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

    # Filter API: Allocators
    attach_function :bitcache_filter_alloc, [], :bitcache_filter
    attach_function :bitcache_filter_free, [:bitcache_filter], :void

    # Filter API: Constructors
    attach_function :bitcache_filter_new, [:size_t], :bitcache_filter
    #attach_function :bitcache_filter_new_union, [:bitcache_filter, :bitcache_filter], :bitcache_filter
    #attach_function :bitcache_filter_new_intersection, [:bitcache_filter, :bitcache_filter], :bitcache_filter
    #attach_function :bitcache_filter_new_difference, [:bitcache_filter, :bitcache_filter], :bitcache_filter
    attach_function :bitcache_filter_copy, [:bitcache_filter], :bitcache_filter

    # Filter API: Mutators
    attach_function :bitcache_filter_init, [:bitcache_filter, :size_t], :void
    attach_function :bitcache_filter_clear, [:bitcache_filter], :void
    attach_function :bitcache_filter_insert, [:bitcache_filter, :bitcache_id], :void
    attach_function :bitcache_filter_remove, [:bitcache_filter, :bitcache_id], :void
    attach_function :bitcache_filter_merge, [:bitcache_filter, :bitcache_filter, :bitcache_op], :void

    # Filter API: Accessors
    attach_function :bitcache_filter_get_hash, [:bitcache_filter], :uint
    attach_function :bitcache_filter_get_bitsize, [:bitcache_filter], :size_t
    attach_function :bitcache_filter_get_bytesize, [:bitcache_filter], :size_t
    attach_function :bitcache_filter_get_bitmap, [:bitcache_filter], :pointer
    attach_function :bitcache_filter_get_count, [:bitcache_filter, :bitcache_id], :size_t

    # Filter API: Predicates
    attach_function :bitcache_filter_is_equal, [:bitcache_filter, :bitcache_filter], :bool
    attach_function :bitcache_filter_is_empty, [:bitcache_filter], :bool
    attach_function :bitcache_filter_has_element, [:bitcache_filter, :bitcache_id], :bool

    # List API: Constants
    BITCACHE_LIST_SENTINEL = nil

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

    # List API: Converters
    attach_function :bitcache_list_to_filter, [:bitcache_list], :bitcache_filter
    attach_function :bitcache_list_to_set, [:bitcache_list], :bitcache_set

    # Set API: Allocators
    attach_function :bitcache_set_alloc, [], :bitcache_set
    attach_function :bitcache_set_free, [:bitcache_set], :void

    # Set API: Constructors
    attach_function :bitcache_set_new, [], :bitcache_set
    attach_function :bitcache_set_new_union, [:bitcache_set, :bitcache_set], :bitcache_set
    attach_function :bitcache_set_new_intersection, [:bitcache_set, :bitcache_set], :bitcache_set
    attach_function :bitcache_set_new_difference, [:bitcache_set, :bitcache_set], :bitcache_set
    attach_function :bitcache_set_copy, [:bitcache_set], :bitcache_set

    # Set API: Mutators
    attach_function :bitcache_set_init, [:bitcache_set], :void
    attach_function :bitcache_set_clear, [:bitcache_set], :void
    attach_function :bitcache_set_insert, [:bitcache_set, :bitcache_id], :void
    attach_function :bitcache_set_remove, [:bitcache_set, :bitcache_id], :void
    attach_function :bitcache_set_replace, [:bitcache_set, :bitcache_id, :bitcache_id], :void
    attach_function :bitcache_set_merge, [:bitcache_set, :bitcache_set, :bitcache_op], :void

    # Set API: Accessors
    attach_function :bitcache_set_get_hash, [:bitcache_set], :uint
    attach_function :bitcache_set_get_size, [:bitcache_set], :uint
    attach_function :bitcache_set_get_count, [:bitcache_set, :bitcache_id], :uint

    # Set API: Predicates
    attach_function :bitcache_set_is_equal, [:bitcache_set, :bitcache_set], :bool
    attach_function :bitcache_set_is_empty, [:bitcache_set], :bool
    attach_function :bitcache_set_has_element, [:bitcache_set, :bitcache_id], :bool

    # Set API: Iterators
    attach_function :bitcache_set_foreach, [:bitcache_set, :bitcache_id_func, :pointer], :void

    # Set API: Converters
    attach_function :bitcache_set_to_filter, [:bitcache_set], :bitcache_filter
    attach_function :bitcache_set_to_list, [:bitcache_set], :bitcache_list

    # DEBUG
    #attach_function :bitcache_id_inspect, [:bitcache_id], :void
    #attach_function :bitcache_filter_inspect, [:bitcache_filter], :void
    #attach_function :bitcache_list_inspect, [:bitcache_list], :void
    #attach_function :bitcache_set_inspect, [:bitcache_set], :void
  end # FFI
end # Bitcache

class FFI::Struct
  alias_method :aref, :[]
  alias_method :aset, :[]=
end
