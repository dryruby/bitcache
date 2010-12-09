class Bitcache::Archive
  ##
  # The Bitcache archive header.
  class Header < Segment
    SIZE = 4 + 2 + 2
    PACK = 'LSS'

    ##
    # @private
    # @param  [IO] input
    # @return [void]
    def self.skip(input)
      input.seek(SIZE, IO::SEEK_CUR)
    end

    ##
    # Deserializes an archive header from the given `input` stream or
    # file.
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @return [Header]
    def self.load(input)
      magic, version, flags = input.read(SIZE).unpack(PACK)
      raise "invalid archive magic number: #{magic.inspect}"     if magic   != MAGIC
      raise "invalid archive version number: #{version.inspect}" if version != VERSION
      self.new(:magic => magic, :version => version, :flags => flags)
    end

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
    # Returns `true` if this header is valid, `false` otherwise.
    #
    # @return [Boolean] `true` or `false`
    def valid?
      @magic.eql?(MAGIC) && @version.eql?(VERSION)
    end

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
      output.write([@magic, @version, @flags].pack(PACK))
      return self
    end
  end # Header
end # Bitcache::Archive
