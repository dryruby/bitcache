require 'bitcache'     # @see http://rubygems.org/gems/bitcache
require 'tokyocabinet' # @see http://rubygems.org/gems/tokyocabinet

module Bitcache
  ##
  # Tokyo Cabinet storage adapter for Bitcache.
  #
  # @see http://1978th.net/tokyocabinet/
  module TokyoCabinet
    include ::TokyoCabinet

    autoload :Repository, 'bitcache/tokyocabinet/repository'
  end # TokyoCabinet
end # Bitcache
