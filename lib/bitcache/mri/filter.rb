module Bitcache
  ##
  # A Bitcache filter.
  class Filter < Struct
    # TODO

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::Filter) if defined?(Bitcache::FFI::Filter)
  end # Filter
end # Bitcache
