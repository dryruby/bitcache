module Bitcache
  ##
  # A Bitcache archive file.
  class Archive
    ##
    # The magic number for the file header.
    MAGIC   = 0xBCBCBCBC

    ##
    # The current archive format version number.
    VERSION = 0x0000

    ##
    # Initializes a new archive.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [Integer, #to_i] :version (VERSION)
    def initialize(options = {}, &block)
      @header   = options[:header] || Header.new(options)
      @sections = []

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # The archive header.
    #
    # @return [Header]
    attr_reader :header

    ##
    # The archive sections.
    #
    # @return [Array<Section>]
    attr_reader :sections

    ##
    # Appends a new section to this archive.
    #
    # @param  [Section] section
    # @return [void] `self`
    def <<(section)
      @sections << case section
        when Section then section
        else raise ArgumentError, "expected a Section, but got #{section.inspect}"
      end
      return self
    end

    ##
    # Serializes this archive to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @return [void] `self`
    def dump(output)
      header.dump(output)
      @sections.each { |section| section.dump(output) }
      return self
    end

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
    end

    ##
    # The Bitcache archive header.
    class Header < Segment
      SIZE = 4 + 2 + 2

      ##
      # Initializes a new archive header.
      #
      # @param  [Hash{Symbol => Object}] options
      # @option options [Integer, #to_i] :magic   (MAGIC)
      # @option options [Integer, #to_i] :version (VERSION)
      # @option options [Integer, #to_i] :flags   (0)
      def initialize(options = {}, &block)
        @magic   = (options[:magic]   || MAGIC).to_i
        @version = (options[:version] || VERSION).to_i
        @flags   = (options[:flags]   || 0).to_i
        super
      end

      ##
      # The archive format magic number.
      #
      # @return [Integer]
      attr_accessor :magic

      ##
      # The archive format version number.
      #
      # @return [Integer]
      attr_accessor :version

      ##
      # The archive format version number.
      #
      # @return [Integer]
      attr_accessor :flags

      ##
      # Returns the total byte size of this segment.
      #
      # @return [Integer]
      def size
        SIZE
      end

      ##
      # Serializes this header to the given `output` stream or file.
      #
      # @param  [File, IO, StringIO] output
      #   the output stream to write to
      # @return [void] `self`
      def dump(output)
        output.write([@magic, @version, @flags].pack('LSS'))
      end
    end

    ##
    # A Bitcache archive section.
    class Section < Segment
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
          when Record then record
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
      end
    end

    ##
    # A Bitcache archive record.
    class Record < Segment
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
      end
    end
  end # Archive
end # Bitcache
