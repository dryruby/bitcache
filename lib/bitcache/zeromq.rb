require 'bitcache' # @see http://rubygems.org/gems/bitcache
require 'ffi-rzmq' # @see http://rubygems.org/gems/ffi-rzmq

module Bitcache
  ##
  # ZeroMQ network adapter for Bitcache.
  #
  # @see http://www.zeromq.org/
  module ZeroMQ
    include ::ZMQ

    autoload :Client, 'bitcache/zeromq/client'
    autoload :Loop,   'bitcache/zeromq/loop'
    autoload :Server, 'bitcache/zeromq/server'
  end # ZeroMQ
end # Bitcache
