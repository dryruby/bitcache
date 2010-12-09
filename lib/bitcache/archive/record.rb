class Bitcache::Archive
  ##
  # A Bitcache archive record.
  class Record < Segment
    ##
    # Deserializes an archive record from the given `input` stream or
    # file.
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @return [Header]
    def self.load(input)
      self.new do |record|
        record.flags = input.read(2).unpack('S').first
        record.id = input.read(20) # FIXME
        record.id = Identifier.new(record.id) if record.id.size.eql?(20) # FIXME
        case
          when record.flags.zero?
            # all done
          when record.flags & 4
            record.length = input.read(4).unpack('L').first
            record.offset = input.read(4).unpack('L').first
            record.data   = input.read(record.length) if record.offset.zero?
          else
            raise "invalid record flags: #{record.flags.inspect}"
        end
      end
    end

    ##
    # Initializes a new archive record.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [Integer, #to_i]      :flags  (0)
    # @option options [Identifier, #to_str] :id
    # @option options [String, #to_str]     :data   (nil)
    # @option options [Integer, #to_i]      :length (nil)
    # @option options [Integer, #to_i]      :offset (nil)
    def initialize(options = {}, &block)
      @id     = options[:id]     || nil
      @data   = options[:data]   || nil
      @length = options[:length] || (@data ? @data.bytesize : nil)
      @offset = options[:offset] || (@data ? 0 : nil)
      @flags  = options[:flags]  || (@data ? 4 : 0)
      super
    end

    ##
    # The record flags.
    #
    # @return [Integer] a 16-bit unsigned integer
    attr_accessor :flags

    ##
    # The record identifier.
    #
    # @return [Identifier]
    attr_accessor :id

    ##
    # The record data bytes.
    #
    # @return [String] a byte string
    attr_accessor :data

    ##
    # The record data length.
    #
    # @return [Integer] a 32-bit unsigned integer
    attr_accessor :length

    ##
    # The record data offset.
    #
    # @return [Integer] a 32-bit unsigned integer
    attr_accessor :offset

    ##
    # Returns the total byte size of this segment.
    #
    # @return [Integer]
    def size
      size = 2 + @id.size
      size += case
        when @flags.zero?
          0
        when @flags & 4
          4 + 4 + (@data ? @data.bytesize : 0)
        when @flags & 1, @flags & 2, @flags & 8
          raise NotImplementedError, "only 32-bit offsets supported at present"
        else
          raise "invalid record flags: #{@flags.inspect}"
      end
      size
    end

    ##
    # Serializes this record to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @return [void] `self`
    def dump(output)
      case
        when @flags.zero?
          output.write([@flags.to_i].pack('S'))
          output.write(@id.to_str)
        when @flags & 4
          output.write([@flags.to_i].pack('S'))
          output.write(@id.to_str)
          output.write([@length.to_i, @offset.to_i].pack('LL'))
          output.write(@data.to_str) if @offset.to_i.zero?
        else
          raise "invalid record flags: #{@flags.inspect}"
      end
      return self
    end
  end # Record
end # Bitcache::Archive
