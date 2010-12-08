require 'digest'
require 'enumerator'
require 'pathname'
require 'stringio'

if RUBY_VERSION < '1.8.7'
  # @see http://rubygems.org/gems/backports
  begin
    require 'backports/1.8.7'
  rescue LoadError
    begin
      require 'rubygems'
      require 'backports/1.8.7'
    rescue LoadError
      abort "Bitcache requires Ruby 1.8.7 or the Backports gem (hint: `gem install backports')."
    end
  end
end

module Bitcache
  # For compatibility with both Ruby 1.8.x and Ruby 1.9.x:
  Enumerator = defined?(::Enumerator) ? ::Enumerator : ::Enumerable::Enumerator

  autoload :VERSION,     'bitcache/version'
  autoload :Adapter,     'bitcache/adapter'
  autoload :Archive,     'bitcache/archive'
  autoload :Encoder,     'bitcache/encoder'
  autoload :Inspectable, 'bitcache/inspectable'
  autoload :Repository,  'bitcache/repository'

  begin
    require 'bitcache/ffi'
    Struct = FFI::ManagedStruct
  rescue LoadError
    Struct = Object
  end

  autoload :Filter,      'bitcache/mri/filter'
  autoload :Identifier,  'bitcache/mri/id'
  autoload :Index,       'bitcache/mri/index'
  autoload :List,        'bitcache/mri/list'
  autoload :Queue,       'bitcache/mri/queue'
  autoload :Set,         'bitcache/mri/set'
  autoload :Stream,      'bitcache/mri/stream'

  ##
  # The magic number for Bitcache file headers.
  MAGIC = 0xBCBC

  ##
  # Returns the Bitcache identifier for `input`.
  #
  # @param  [Stream, Proc, #read, #to_str] input
  #   the input data
  # @param  [Hash{Symbol => Object} options
  #   any additional options
  # @return [Identifier]
  def self.identify(input, options = {})
    Identifier.for(Bitcache.read(input), options)
  end

  ##
  # Returns the contents of `input` as a raw bitstream.
  #
  # @param  [Stream, Proc, #read, #to_str] input
  # @return [String]
  def self.read(input)
    case
      when input.is_a?(Proc)          # data producer block
        buffer = StringIO.new
        case input.arity
          when 1 then input.call(buffer)
          else buffer.instance_eval(&input)
        end
        buffer.string
      when input.respond_to?(:read)   # Stream, IO, Pathname
        input.read
      when input.respond_to?(:to_str) # String
        input.to_str
      else
        raise ArgumentError.new("expected a Bitcache::Stream, IO, Proc or String, but got #{input.inspect}")
    end
  end
end # Bitcache
