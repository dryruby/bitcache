class Bitcache::Archive
  ##
  # A Bitcache archive segment.
  class Segment
    ##
    # Initializes a new archive segment.
    #
    # @param  [Hash{Symbol => Object}] options
    def initialize(options = {}, &block)
      @size = options[:size] if options[:size]

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Returns the total byte size of this segment.
    #
    # @return [Integer]
    def size
      @size || StringIO.open do |buffer|
        dump(buffer)
        buffer.string.bytesize
      end
    end
    alias_method :bytesize, :size

    ##
    # @private
    def bytesize
      size # defined here so that subclasses don't need to re-alias #bytesize
    end

    ##
    # Serializes this segment to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @return [void] `self`
    # @abstract
    def dump(output)
      raise NotImplementedError, "#{self.class}#dump"
    end
  end # Segment
end # Bitcache::Archive
