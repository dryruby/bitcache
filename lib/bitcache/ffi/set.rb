module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_set` data structure.
  #
  # @see Bitcache::Set
  class Set < ::FFI::Struct
    layout :root, :pointer,
           :filter, :bitcache_filter
    # TODO: wrap the `bitcache_set` data structure.
  end # Set
end # Bitcache::FFI
