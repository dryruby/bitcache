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
  # Returns the Bitcache identifier for the given bitstream.
  #
  # @param  [String, #to_str] stream
  # @return [String]
  def self.identify(stream)
    if stream.respond_to?(:to_str)
      Digest::SHA1.hexdigest(stream.to_str)
    else
      raise ArgumentError.new("expected Bitcache::Stream or String, got #{stream.inspect}")
    end
  end
end
