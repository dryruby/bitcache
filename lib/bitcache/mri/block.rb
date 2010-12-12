module Bitcache
  ##
  # A Bitcache data block.
  class Block < Struct
    # TODO

    # Load accelerated method implementations when available:
    send(:include, Bitcache::FFI::Block) if defined?(Bitcache::FFI::Block)
  end # Block
end # Bitcache
