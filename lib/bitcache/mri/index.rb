module Bitcache
  ##
  # A Bitcache index.
  class Index < Struct
    # TODO

    # Load optimized method implementations when available:
    include Bitcache::FFI::Index if defined?(Bitcache::FFI::Index)
  end # Index
end # Bitcache
