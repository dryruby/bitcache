module Bitcache
  ##
  # An index of Bitcache identifiers.
  #
  # Time Complexity
  # ---------------
  #
  # TODO
  #
  # Space Requirements
  # ------------------
  #
  # TODO
  #
  class Index < Struct
    # TODO

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::Index) if defined?(Bitcache::FFI::Index)
  end # Index
end # Bitcache
