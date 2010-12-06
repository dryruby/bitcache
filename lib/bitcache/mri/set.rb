module Bitcache
  ##
  # A Bitcache set.
  class Set < Struct
    # TODO

    # Load optimized method implementations when available:
    include Bitcache::FFI::Set if defined?(Bitcache::FFI::Set)
  end # Set
end # Bitcache
