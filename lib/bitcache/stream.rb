module Bitcache
  ##
  class Stream
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
    # @return [String] the bitstream's identifier
    def to_s
      id
    end

    ##
    # @return [String] the bitstream's contents
    def to_str
      data
    end

    ##
    # Returns a developer-friendly representation of this object.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, id)
    end

    ##
    # Outputs a developer-friendly representation of this object to `stderr`.
    #
    # @return [void]
    def inspect!
      warn(inspect)
    end
  end
end
