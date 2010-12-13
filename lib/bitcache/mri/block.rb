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

    ##
    # Returns a read-only IO stream for accessing this block's data.
    #
    # @return [IO] a read-only IO stream
    def to_io
      data
    end

    ##
    # Returns the byte string representation of this block's data.
    #
    # @param  [Encoding] encoding
    #   an optional character encoding (Ruby 1.9+ only)
    # @return [String] a binary string
    def to_str(encoding = nil)
      str = data.send(data.respond_to?(:readbytes) ? :readbytes : :read, size)
      str.force_encoding(encoding) if encoding && str.respond_to?(:force_encoding) # Ruby 1.9+
      str
    end

    ##
    # Returns the hexadecimal string representation of this block's
    # identifier.
    #
    # @return [String] a hexadecimal string
    def to_s
      id.to_s
    end

    # Load accelerated method implementations when available:
    send(:include, Bitcache::FFI::Block) if defined?(Bitcache::FFI::Block)
  end # Block
end # Bitcache
