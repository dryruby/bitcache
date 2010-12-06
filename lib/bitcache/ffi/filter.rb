module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_filter` data structure.
  #
  # @see Bitcache::Filter
  module Filter
    LAYOUT = [:bitsize, :size_t,
              :bitmap, :pointer]
    # TODO: wrap the `bitcache_filter` data structure.
  end # Filter
end # Bitcache::FFI
