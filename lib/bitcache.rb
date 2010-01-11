require 'digest/sha1'
require 'pathname'
require 'stringio'
require 'addressable/uri'
require 'bitcache/version'

module Bitcache
  autoload :Adapter,    'bitcache/adapter'
  autoload :Encoder,    'bitcache/encoder'
  autoload :Repository, 'bitcache/repository'
  autoload :Stream,     'bitcache/stream'

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
end
