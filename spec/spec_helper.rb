require 'bitcache'
require 'bitcache/spec'

Spec::Runner.configure do |config|
  config.include(Bitcache::Spec::Matchers)
end

include Bitcache

class Object
  def boolean?() false end
end

class TrueClass
  def boolean?() true end
end

class FalseClass
  def boolean?() true end
end

# FFI has problem if these get loaded on-demand:
require 'openssl'
require 'addressable/uri'
require 'rdf'
