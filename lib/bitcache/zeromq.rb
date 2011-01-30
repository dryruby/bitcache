require 'bitcache' # @see http://rubygems.org/gems/bitcache
require 'ffi-rzmq' # @see http://rubygems.org/gems/ffi-rzmq

module Bitcache
  ##
  # ZeroMQ network adapter for Bitcache.
  #
  # @see http://www.zeromq.org/
  module ZeroMQ
    include ::ZMQ

    autoload :Loop, 'bitcache/zeromq/loop'
  end # ZeroMQ
end # Bitcache
