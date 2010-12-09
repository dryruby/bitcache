class Bitcache::Archive
  ##
  # A Bitcache archive section.
  class Section < Segment
    ##
    # Deserializes an archive section from the given `input` stream or
    # file.
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @return [Header]
    def self.load(input)
      self.new do |section|
        end_offset = input.read(8).unpack('Q').first + input.pos
        section.records << Record.load(input) until input.pos >= end_offset
      end
    end

    ##
    # Initializes a new archive section.
    #
    # @param  [Hash{Symbol => Object}] options
    def initialize(options = {}, &block)
      @records = options[:records] || []
      super
    end

    ##
    # The archive section records.
    #
    # @return [Array<Record>]
    attr_reader :records

    ##
    # Appends a new record to this section.
    #
    # @param  [Record] record
    # @return [void] `self`
    def <<(record)
      @records << case record
        when Record     then record
        when Identifier then Record.new(:id => record)
        else raise ArgumentError, "expected a Record, but got #{record.inspect}"
      end
      return self
    end

    ##
    # Returns the total byte size of this segment.
    #
    # @return [Integer]
    def size
      8 + @records.map(&:size).inject(0, :+)
    end

    ##
    # Serializes this section to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @return [void] `self`
    def dump(output)
      output.write([size - 8].pack('Q'))
      @records.each { |record| record.dump(output) }
      return self
    end
  end # Section
end # Bitcache::Archive
