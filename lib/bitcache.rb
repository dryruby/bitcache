require 'digest/sha1'
require 'pathname'
require 'stringio'

module Bitcache
  autoload :VERSION,     'bitcache/version'

  autoload :Adapter,     'bitcache/adapter'
  autoload :Encoder,     'bitcache/encoder'
  autoload :Inspectable, 'bitcache/inspectable'
  autoload :Repository,  'bitcache/repository'

  # Optimized FFI data structure
  autoload :FFI,         'bitcache/ffi'

  # Pure-Ruby data structures
  autoload :Filter,      'bitcache/mri/filter'
  autoload :Identifier,  'bitcache/mri/id'
  autoload :Index,       'bitcache/mri/index'
  autoload :List,        'bitcache/mri/list'
  autoload :Queue,       'bitcache/mri/queue'
  autoload :Set,         'bitcache/mri/set'
  autoload :Stream,      'bitcache/mri/stream'

  ##
  # Returns the Bitcache identifier for `input`.
  #
  # @param  [Stream, Proc, #read, #to_str] input
  # @param  [Hash{Symbol => Object} options
  # @return [String]
  def self.identify(input, options = {})
    Digest::SHA1.hexdigest(Bitcache.read(input))
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
