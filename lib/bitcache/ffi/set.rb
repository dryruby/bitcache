module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_set` data structure.
  #
  # @see Bitcache::Set
  module Set
    LAYOUT = [:root, :pointer,
              :filter, :bitcache_filter]
    # TODO: wrap the `bitcache_set` data structure.
  end # Set
end # Bitcache::FFI
