module Bitcache
  ##
  # A Bitcache identifier.
  class Identifier
    include Comparable
    include Inspectable

    MD5_SIZE    = 16 # bytes
    SHA1_SIZE   = 20 # bytes
    SHA256_SIZE = 32 # bytes
    MIN_SIZE    = MD5_SIZE
    MAX_SIZE    = SHA256_SIZE

    ##
    # Parses an identifier string representation, returning the
    # corresponding identifier.
    #
    # Currently, only hexadecimal string parsing is implemented.
    #
    # @example Parsing a hexadecimal string
    #   id = Identifier.parse('d41d8cd98f00b204e9800998ecf8427e')
    #
    # @param  [String, #to_str] input
    #   the identifier string representation to parse
    # @param  [Hash{Symbol => Objec}] options
    #   any additional options
    # @option options [Integer] :base (16)
    #   the numeric base of the identifier string (defaults to hexadecimal)
    # @return [Identifier]
    # @raise  [ArgumentError] if the input is invalid
    def self.parse(input, options = {})
      input = input.to_str
      if input.length < (MIN_SIZE * 2) || input.length % 4 != 0
        raise ArgumentError, "invalid identifier string: #{input.inspect}"
      end
      self.new([input].pack('H*')) # TODO: support for `options[:base]`
    end

    ##
    # Initializes an identifier with the given `digest`.
    #
    # If no `digest` argument is provided, the identifier will be
    # initialized to all zeroes.
    #
    # @example Constructing an MD5 identifier
    #   id = Identifier.new("\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98e\xcf8\x42\x7e")
    #
    # @param  [String, #to_str] digest
    #   the identifier message digest
    def initialize(digest = nil)
      @digest = digest ? digest.to_str : "\0" * 20
      @digest.force_encoding(Encoding::BINARY) if @digest.respond_to?(:force_encoding) # for Ruby 1.9+
    end

    ##
    # The message digest as a binary string.
    #
    # @return [String]
    attr_reader :digest

    ##
    # Returns the byte size of this identifier.
    #
    # @return [Integer]
    def size
      digest.bytesize
    end
    alias_method :bytesize, :size
    alias_method :length,   :size

    ##
    # Returns `true` if this identifier is zero.
    #
    # @return [Boolean] `true` or `false`
    def zero?
      digest.each_byte.all? { |byte| byte.zero? }
    end
    alias_method :blank?, :zero?

    ##
    # Returns the byte at offset `index`.
    #
    # Returns `nil` if `index` is out of bounds.
    #
    # @param  [Integer, #to_i] index
    #   a byte offset in the range `(0...size)`
    # @return [Integer] `(0..255)`, or `nil`
    def [](index)
      index = index.to_i
      index >= 0 && index < size ? digest[index].ord : nil
    end

    ##
    # Replaces the byte at offset `index` with the given `byte` value.
    #
    # Raises an error if `index` is out of bounds.
    #
    # @param  [Integer, #to_i] index
    #   a byte offset in the range `(0...size)`
    # @param  [Integer, #ord]  byte
    #   the new byte value, `(0..255)`
    # @return [Integer] `byte`
    # @raise  [IndexError] if `index` is out of bounds
    def []=(index, byte)
      index = index.to_i
      raise IndexError, "index #{index} is out of bounds" unless index >= 0 && index < size
      byte = case byte
        when String
          byte = byte[0]
          byte.force_encoding(Encoding::BINARY) if byte.respond_to?(:force_encoding) # for Ruby 1.9+
          byte.ord
        else byte.ord & 0xff
      end
      digest[index] = byte.chr
      byte
    end

    ##
    # Compares this identifier to the given `other` identifier.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    # @see    Comparable#<=>
    def <=>(other)
      case other
        when Identifier
          size.eql?(other.size) ? digest <=> other.digest : nil
        when String
          size.eql?(other.size) ? digest <=> other : nil
        else nil
      end
    end

    ##
    # Returns the binary string representation of this identifier.
    #
    # @return [String]
    def to_str
      digest.dup
    end

    ##
    # Returns the hexadecimal string representation of this identifier.
    #
    # @return [String]
    def to_s
      digest.unpack('H*').first
    end

    ##
    # Returns a developer-friendly representation of this identifier.
    #
    # @return [String]
    def inspect
      super
    end
  end # Identifier
end # Bitcache
