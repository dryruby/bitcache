module Bitcache
  ##
  # A Bitcache data block.
  class Block < Struct
    include Inspectable

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
    # @return [Integer] an integer in the range `(0...(2**64))`
    attr_reader :size
    alias_method :bytesize, :size

    ##
    # The block data stream.
    #
    # @return [IO]
    attr_reader :data

    ##
    # Returns `true` if the block size is zero.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      size.zero?
    end

    ##
    # Returns `true` unless all bytes in the block data are zero.
    #
    # @return [Boolean] `true` or `false`
    # @see    #zero?
    def nonzero?
      !(zero?)
    end

    ##
    # Returns `true` if all bytes in the block data are zero.
    #
    # @return [Boolean] `true` or `false`
    # @see    #nonzero?
    def zero?
      /\A\x00+\z/ === to_str
    end

    ##
    # Returns `true` if the block data contains any `0x00` bytes.
    #
    # @return [Boolean] `true` or `false`
    def binary?
      /\x00/ === to_str
    end

    ##
    # Returns `true` if the block data contains ASCII characters only.
    #
    # @return [Boolean] `true` or `false`
    def ascii?
      if ''.respond_to?(:ascii_only?)
        to_str.ascii_only?            # Ruby 1.9+
      else
        /\A[\x00-\x7F]+\z/ === to_str # Ruby 1.8
      end
    end
    alias_method :ascii_only?, :ascii?

    ##
    # Returns `true` if this block is equal to the given `other` block or
    # byte string.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def ==(other)
      return true if self.equal?(other)
      case other
        when Identifier
          id.eql?(other)
        when Block
          if id && other.id
            id.eql?(other.id)
          else
            size.eql?(other.size) && to_str.eql?(other.to_str)
          end
        when String
          size.eql?(other.bytesize) && to_str.eql?(other)
        else false
      end
    end
    alias_method :===, :==

    ##
    # Returns `true` if this block is equal to the given `other` block.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      other.is_a?(Block) && self == other
    end

    ##
    # Returns the hash code for the block identifier.
    #
    # @return [Fixnum] an integer in the range `(0...(2**32))`
    # @see    Identifier#hash
    def hash
      id ? id.to_hash : 0
    end

    ##
    # Returns the current read position as a byte offset from the beginning
    # of the block data.
    #
    # @return [Integer] an integer in the range `(0..size)`
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
      pos > 0 ? data.rewind : 0
    end

    ##
    # Seeks to a given byte `offset` in the block data according to the
    # value of `whence`.
    #
    # @param  [Integer] offset
    #   an integer offset
    # @param  [Integer] whence
    #   `IO::SEEK_CUR`, `IO::SEEK_END`, or `IO::SEEK_SET`
    # @return [Integer] `0`
    # @see    IO#seek
    def seek(offset, whence = IO::SEEK_SET)
      data.seek(offset, whence)
    end

    ##
    # Returns the byte at the given byte `offset` in the block data.
    #
    # @param  [Integer] offset
    #   an integer offset
    # @return [Integer] an integer in the range `(0..255)`
    # @see    String#[]
    def [](offset)
      case offset
        when Integer then case
          when offset < 0
            seek(offset, IO::SEEK_END) && readbytes(1)[0].ord
          when offset < size
            seek(offset, IO::SEEK_SET) && readbytes(1)[0].ord
          else nil
        end
        else to_str[offset] # FIXME
      end
    end

    ##
    # Reads at most `length` bytes from the current read position in the
    # block data, or to the end of the block if `length` is `nil`.
    #
    # @param  [Integer] length
    #   a non-negative integer or `nil`
    # @return [String]
    # @see    IO#read
    def read(length = nil)
      data.read(length)
    end

    ##
    # Reads at most `length` bytes from the current read position in the
    # block data, blocking only if no data is immediately available.
    #
    # @param  [Integer] length
    #   a non-negative integer
    # @return [String]
    # @raise  [EOFError] if `#pos` is past the end of the block data
    # @see    IO#readpartial
    def readpartial(length)
      data.readpartial(length)
    end

    ##
    # Reads the next byte from the block data.
    #
    # Raises an error if attempting to read past the end of the block data.
    #
    # @return [Integer] an integer in the range `(0..255)`
    # @raise  [EOFError] if `#pos` is past the end of the block data
    # @see    IO#readbyte
    def readbyte
      raise EOFError, "end of block reached" unless pos < size
      data.readbyte
    end

    ##
    # Reads exactly `length` bytes from the current read position in the
    # block data.
    #
    # @return [String]
    # @raise  [EOFError] if `#pos` is past the end of the block data
    # @raise  [TruncatedDataError] if the data read is too short
    def readbytes(length)
      raise EOFError, "end of block reached" unless pos < size # FIXME
      data.send(data.respond_to?(:readbytes) ? :readbytes : :read, length)
    end

    ##
    # Reads the next character from the block data.
    #
    # Raises an error if attempting to read past the end of the block data.
    #
    # @return [String] a character
    # @raise  [EOFError] if `#pos` is past the end of the block data
    # @see    IO#readchar
    def readchar
      raise EOFError, "end of block reached" unless pos < size
      data.readchar
    end

    ##
    # Reads the next line from the block data.
    #
    # Raises an error if attempting to read past the end of the block data.
    #
    # @param  [String] separator
    #   the line separator to use (defaults to `$/`)
    # @return [String] a string terminated by `separator`
    # @raise  [EOFError] if `#pos` is past the end of the block data
    # @see    IO#readline
    def readline(separator = $/)
      raise EOFError, "end of block reached" unless pos < size
      data.readline(separator)
    end

    ##
    # Reads all the lines in the block data, returning them as an array.
    #
    # Returns an empty array if attempting to read past the end of the block
    # data.
    #
    # @param  [String] separator
    #   the line separator to use (defaults to `$/`)
    # @return [Array] an array of strings
    # @see    IO#readlines
    def readlines(separator = $/)
      return [] unless pos < size
      data.readlines(separator)
    end

    ##
    # Reads the next byte from the block data.
    #
    # Returns `nil` if attempting to read past the end of the block data.
    #
    # @return [Integer] an integer in the range `(0..255)`, or `nil`
    # @see    IO#getbyte
    def getbyte
      data.getbyte
    end

    ##
    # Reads the next character from the block data.
    #
    # Returns `nil` if attempting to read past the end of the block data.
    #
    # @return [String] a character, or `nil`
    # @see    IO#getc
    def getc
      data.getc
    end

    ##
    # Reads the next line from the block data.
    #
    # Returns `nil` if attempting to read past the end of the block data.
    #
    # @param  [String] separator
    #   the line separator to use (defaults to `$/`)
    # @return [String] a string terminated by `separator`, or `nil`
    # @see    IO#gets
    def gets(separator = $/)
      data.gets(separator)
    end

    ##
    # Returns an enumerator yielding each byte in the block data.
    #
    # @return [Enumerator]
    # @see    IO#bytes
    def bytes
      each_byte
    end

    ##
    # Returns an enumerator yielding each character in the block data.
    #
    # @return [Enumerator]
    # @see    IO#chars
    def chars
      each_char
    end

    ##
    # Returns an enumerator yielding each line in the block data.
    #
    # @param  [String] separator
    #   the line separator to use (defaults to `$/`)
    # @return [Enumerator]
    # @see    IO#lines
    def lines(separator = $/)
      each_line(separator)
    end

    ##
    # Returns the current line number in the block data.
    #
    # This counts the number of times `#gets` is called, not necessarily the
    # actual number of newlines encountered.
    #
    # @return [Integer]
    # @see    IO#lineno
    def lineno
      data.lineno
    end

    ##
    # Enumerates each byte in the block data.
    #
    # @yield  [byte]
    #   each byte in the block data
    # @yieldparam  [Integer] byte
    #   an integer in the range `(0..255)`
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    # @see    IO#each_byte
    def each_byte(&block)
      rewind && data.each_byte(&block) if block_given?
      enum_for(:each_byte)
    end

    ##
    # Enumerates each character in the block data.
    #
    # @yield  [char]
    #   each character in the block data
    # @yieldparam  [String] char
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    # @see    IO#each_char
    def each_char(&block)
      rewind && data.each_char(&block) if block_given?
      enum_for(:each_char)
    end

    ##
    # Enumerates each line in the block data, where lines are separated by
    # the given `separator` string.
    #
    # @param  [String] separator
    #   the line separator to use (defaults to `$/`)
    # @yield  [line]
    #   each line in the block data
    # @yieldparam  [String] line
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    # @see    IO#each_line
    def each_line(separator = $/, &block)
      rewind && data.each_line(separator, &block) if block_given?
      enum_for(:each_line, separator)
    end

    ##
    # Decodes the block data according to the given `format` string,
    # returning an array containing each value extracted.
    #
    # @param  [String] format
    # @return [Array]
    # @see    String#unpack
    def unpack(format)
      to_str.unpack(format)
    end

    ##
    # Returns the block identifier.
    #
    # @return [Identifier]
    def to_id
      id
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
      str = rewind && read
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

    ##
    # Returns a developer-friendly representation of this block.
    #
    # @return [String]
    def inspect
      super
    end

    # Load accelerated method implementations when available:
    send(:include, Bitcache::FFI::Block) if defined?(Bitcache::FFI::Block)
  end # Block
end # Bitcache
