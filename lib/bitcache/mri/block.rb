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
    # The block size, in bytes.
    #
    # @return [Integer] a non-negative integer in the range `(0...(2**64))`
    attr_reader :size
    alias_method :bytesize, :size

    ##
    # The block data stream.
    #
    # @return [IO]
    attr_reader :data

    ##
    # Returns the current read position as a byte offset from the beginning
    # of the block data.
    #
    # @return [Integer] a non-negative integer in the range `(0..size)`
    # @see    IO#pos
    def pos
      data.pos
    end
    alias_method :tell, :pos

    ##
    # Positions the next read back to the beginning of the block data.
    #
    # This is equivalent to `#seek(0, IO::SEEK_SET)`.
    #
    # @return [Integer] `0`
    # @see    IO#rewind
    def rewind
      data.rewind
    end

    ##
    # Seeks to a given byte offset in the block data according to the value
    # of `whence`.
    #
    # @return [Integer] `0`
    # @see    IO#seek
    def seek(amount, whence = IO::SEEK_SET)
      data.seek(amount, whence)
    end

    ##
    # Reads at most `length` bytes from the current read position in the
    # block data, or to the end of the block if `length` is `nil`.
    #
    # @param  [Integer] length
    #   a non-negative integer of `nil`
    # @return [String]
    def read(length = nil)
      data.read(length)
    end

    ##
    # Reads exactly `length` bytes from the current read position in the
    # block data.
    #
    # @return [String]
    # @raise  [EOFError] if at the end of the block
    # @raise  [TruncatedDataError] if the data read is too short
    def readbytes(length)
      data.send(data.respond_to?(:readbytes) ? :readbytes : :read, length)
    end

    ##
    # Returns a read-only IO stream for accessing the block data.
    #
    # @return [IO] a read-only IO stream
    def to_io
      data
    end

    ##
    # Returns the byte string representation of the block data.
    #
    # @param  [Encoding] encoding
    #   an optional character encoding (Ruby 1.9+ only)
    # @return [String] a binary string
    def to_str(encoding = nil)
      rewind
      str = readbytes(size)
      str.force_encoding(encoding) if encoding && str.respond_to?(:force_encoding) # Ruby 1.9+
      str
    end

    ##
    # Returns the hexadecimal string representation of the block identifier.
    #
    # @return [String] a hexadecimal string
    def to_s
      id.to_s
    end

    # Load accelerated method implementations when available:
    send(:include, Bitcache::FFI::Block) if defined?(Bitcache::FFI::Block)
  end # Block
end # Bitcache
