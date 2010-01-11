module Bitcache
  ##
  class Stream
    include Inspectable
    include Comparable

    ##
    # @return [String] the bitstream's identifier
    attr_reader :id

    ##
    # @return [String] the bitstream's contents
    attr_reader :data

    ##
    # Initializes this bitstream instance.
    #
    # @param  [String] id
    # @param  [String] data
    def initialize(id, data)
      @id, @data = id, Bitcache.read(data)
    end

    ##
    # Returns `true` to indicate that this is a bitstream.
    def stream?
      true
    end

    ##
    # Returns `true` if this bitstream has an octet size of zero.
    #
    # @return [Boolean]
    def empty?
      size.zero?
    end

    alias_method :blank?, :empty?

    ##
    # Returns the octet size of this bitstream.
    #
    # @return [Integer]
    def size
      data.size
    end

    ##
    # Returns the contents of this bitstream.
    #
    # @return [String]
    def read
      data
    end

    ##
    # Returns a string representation of this bitstream.
    #
    # @return [String] the bitstream's identifier
    def to_s
      id
    end

    ##
    # Returns the contents of this bitstream as a string.
    #
    # @return [String] the bitstream's contents
    def to_str
      data
    end

    ##
    # Returns the contents of this bitstream as an RDF literal.
    #
    # @return [RDF::Literal]
    def to_rdf
      RDF::Literal.new(to_str)
    end

    ##
    # Returns a `Hash` representation of this bitstream.
    #
    # @return [Hash{Symbol => Object}]
    def to_hash
      { :id => id, :size => size, :data => data }
    end
  end
end
