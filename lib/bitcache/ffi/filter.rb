module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_filter` data structure.
  #
  # @see Bitcache::Filter
  class Filter < ::FFI::Struct
    layout :bitsize, :size_t,
           :bitmap, :pointer
    # TODO: wrap the `bitcache_filter` data structure.
  end # Filter
end # Bitcache::FFI
