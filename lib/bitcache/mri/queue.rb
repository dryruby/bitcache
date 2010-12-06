module Bitcache
  ##
  # A Bitcache queue.
  class Queue < Struct
    # TODO

    # Load optimized method implementations when available:
    include Bitcache::FFI::Queue if defined?(Bitcache::FFI::Queue)
  end # Queue
end # Bitcache
