class Bitcache::Archive
  ##
  # A Bitcache archive section.
  class Section < Segment
    SIZE_LEN   = 8
    SIZE_PACK  = 'Q'
    COUNT_LEN  = 4
    COUNT_PACK = 'L'

    ##
    # @private
    # @param  [IO] input
    # @return [Integer]
    def self.size(input)
      input.read(SIZE_LEN).unpack(SIZE_PACK).first
    end

    ##
    # @private
    # @param  [IO] input
    # @return [Integer]
    def self.count(input)
      input.read(COUNT_LEN).unpack(COUNT_PACK).first
    end

    ##
    # Deserializes an archive section from the given `input` stream or
    # file.
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @return [Header]
    def self.load(input)
      self.new do |section|
        end_offset = self.size(input) + input.pos
        Record.count(input).times do
          section.records << Record.load(input)
        end
        input.seek(end_offset, IO::SEEK_SET) if input.pos < end_offset
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
      SIZE_LEN + COUNT_LEN + @records.map(&:size).inject(0, :+)
    end

    ##
    # Serializes this section to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @return [void] `self`
    def dump(output)
      output.write([size - SIZE_LEN, @records.count].pack(SIZE_PACK + COUNT_PACK))
      @records.each { |record| record.dump(output) }
      return self
    end
  end # Section
end # Bitcache::Archive
