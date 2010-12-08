module Bitcache
  ##
  # A queue of Bitcache identifiers.
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
  # @see http://en.wikipedia.org/wiki/Queue_(data_structure)
  class Queue < Struct
    # TODO

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::Queue) if defined?(Bitcache::FFI::Queue)
  end # Queue
end # Bitcache
