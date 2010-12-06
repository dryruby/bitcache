module Bitcache
  ##
  # A Bitcache list.
  class List < Struct
    # TODO

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::List) if defined?(Bitcache::FFI::List)
  end # List
end # Bitcache
