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
end
