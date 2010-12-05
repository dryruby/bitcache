module Bitcache
  ##
  # A Bitcache identifier.
  class Identifier
    include Comparable

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
  end # Identifier
end # Bitcache
