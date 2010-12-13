module Bitcache
  ##
  # A Bitcache data block.
  class Block < Struct
    ##
    # Initializes a new block.
    def initialize(&block)
      @size, @data = 0, StringIO.new

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # The block identifier.
    #
    # @return [Identifier]
    attr_reader :id

    ##
    # The block size.
    #
    # @return [Integer]
    #   a non-negative integer in the range `(0...(2**64))`
    attr_reader :size

    ##
    # The block data stream.
    #
    # @return [IO]
    attr_reader :data

    # Load accelerated method implementations when available:
    send(:include, Bitcache::FFI::Block) if defined?(Bitcache::FFI::Block)
  end # Block
end # Bitcache
