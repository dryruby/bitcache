require 'digest/sha1'
require 'bitcache/utils'
require 'bitcache/api'

module Bitcache
  autoload :Adapter,    'bitcache/adapter'
  autoload :Config,     'bitcache/config'
  autoload :Encoders,   'bitcache/encoders' # FIXME
  autoload :Repository, 'bitcache/repository'
  autoload :Stream,     'bitcache/stream'
  autoload :VERSION,    'bitcache/version'
end
