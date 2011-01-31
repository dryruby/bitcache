module Bitcache::ZeroMQ
  ##
  # ZeroMQ-based network client for Bitcache repositories.
  #
  # @see http://zguide.zeromq.org/chapter:all
  class Client
    ##
    # @param  [String] endpoint
    # @param  [Hash{Symbol => Object}] options
    # @return [Client]
    def self.connect(endpoint, options = {})
      self.new(endpoint, options).connect
    end

    # @return [String]
    attr_reader :endpoint

    # @return [ZMQ::Socket]
    attr_reader :socket

    # @return [Hash]
    attr_reader :options

    ##
    # @param  [String] endpoint
    # @param  [Hash{Symbol => Object}] options
    # @option options [ZMQ::Context] :context (ZMQ::Context.new)
    def initialize(endpoint, options = {})
      @endpoint = endpoint.to_s
      @options  = options.dup
    end

    ##
    # @return [void] `self`
    def connect
      @context ||= @options[:context] || ZMQ::Context.new
      @socket = @context.socket(ZMQ::REQ) unless @socket
      @socket.connect(@endpoint)
      return self
    end

    ##
    # @return [void] `self`
    def disconnect
      @socket.close
      @socket = nil
      @context.terminate unless @options[:context]
      return self
    end

    ##
    # @param  [Identifier] id
    # @return [String]
    def [](id)
      socket.send_string('get', ZMQ::SNDMORE)
      socket.send_string(id.to_str)
      socket.recv_string
    end

    ##
    # @param  [Identifier] id
    # @param  [Object] data
    # @return [void]
    def []=(id, data)
      socket.send_string('put', ZMQ::SNDMORE)
      socket.send_string(id.to_str, ZMQ::SNDMORE)
      socket.send_string(Bitcache.read(data))
      socket.recv_string
    end

    ##
    # @param  [Object] data
    # @return [void]
    def <<(data)
      socket.send_string('put', ZMQ::SNDMORE)
      socket.send_string('', ZMQ::SNDMORE)
      socket.send_string(Bitcache.read(data))
      socket.recv_string
    end
  end # Client
end # Bitcache::ZeroMQ
