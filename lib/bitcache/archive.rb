module Bitcache
  ##
  # A Bitcache archive.
  #
  # @example Writing an archive to a file
  #   Archive.new do |archive|
  #     archive << Identifier.for("Hello, world!")
  #     archive.dump(File.open("archive.bin", 'wb+'))
  #   end
  #
  # @example Reading an archive from a file
  #   Archive.load(File.open("archive.bin")) do |archive|
  #     puts archive.inspect
  #   end
  #
  class Archive
    autoload :Segment, 'bitcache/archive/segment'
    autoload :Header,  'bitcache/archive/header'
    autoload :Section, 'bitcache/archive/section'
    autoload :Record,  'bitcache/archive/record'

    ##
    # The magic number for the file header.
    MAGIC   = 0xBCBCBCBC

    ##
    # The current archive format version number.
    VERSION = 0x0000

    ##
    # Deserializes an archive from the given `input` stream or file.
    #
    # @example
    #   File.open("archive.bin", 'rb') do |file|
    #     archive = Archive.load(file)
    #     puts archive.inspect
    #   end
    #
    # @example
    #   File.open("archive.bin", 'rb') do |file|
    #     Archive.load(file) do |archive|
    #       puts archive.inspect
    #     end
    #   end
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @return [Archive]
    def self.load(input, options = {}, &block)
      archive = self.new(:header => nil) do |archive|
        archive.header = Header.load(input)
        archive.sections << Section.load(input) until input.eof?
      end
      block_given? ? block.call(archive) : archive
    end

    ##
    # Constructs an archive and serializes it to the given `output` stream
    # or file.
    #
    # @example
    #   File.open("archive.bin", 'wb+') do |file|
    #     Archive.dump(file) do |archive|
    #       archive << Identifier.for("Hello, world!")
    #     end
    #   end
    #
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @yield  [archive]
    # @yieldparam  [Archive] archive
    # @yieldreturn [void] ignored
    # @return [void]
    def self.dump(output, options = {}, &block)
      self.new(options, &block).dump(output)
    end

    ##
    # Initializes a new archive.
    #
    # @example
    #   Archive.new do |archive|
    #     archive << Identifier.for("Hello, world!")
    #     File.open("archive.bin", 'wb+') do |file|
    #       archive.dump(file)
    #     end
    #   end
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
    attr_accessor :header

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
    def <<(segment)
      @sections << case segment
        when Section    then segment
        when Record     then Section.new(:records => [segment])
        when Identifier then Section.new(:records => [Record.new(:id => segment)])
        else raise ArgumentError, "expected a Section, but got #{segment.inspect}"
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
  end # Archive
end # Bitcache
