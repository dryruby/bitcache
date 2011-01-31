module Bitcache::ZeroMQ
  ##
  # ZeroMQ-based network server for Bitcache repositories.
  #
  # @see http://zguide.zeromq.org/chapter:all
  class Server < Loop
    ##
    # @param  [String] endpoint
    # @param  [Repository] repository
    # @param  [Hash{Symbol => Object}] options
    # @return [Server]
    def self.start(endpoint, repository, options = {})
      self.new(endpoint, repository, options).start
    end

    # @return [String]
    attr_reader :endpoint

    # @return [Repository]
    attr_reader :repository

    # @return [ZMQ::Socket]
    attr_reader :socket

    ##
    # @param  [String] endpoint
    # @param  [Repository] repository
    # @param  [Hash{Symbol => Object}] options
    def initialize(endpoint, repository, options = {})
      @endpoint   = endpoint.to_s
      @repository = repository
      super(options)
    end

  protected

    ##
    # @return [void]
    def on_start
      @repository.open(:write)
      begin
        @socket = context.socket(ZMQ::REP)
        @socket.bind(@endpoint)
        register(@socket, ZMQ::POLLIN)
      rescue => error
        @repository.close
        raise error
      end
    end

    ##
    # @return [void]
    def on_stop
      @repository.close
    end

    ##
    # @param  [ZMQ::Socket] socket
    # @return [void]
    def on_readable(socket)
      return unless socket.equal?(@socket)
      case message = socket.recv_string
        when 'get'
          id = Bitcache::Identifier.new(socket.recv_string)
          on_get(id)
        when 'put'
          id = Bitcache::Identifier.new(socket.recv_string)
          data = socket.recv_string
          on_put(id, data)
        else
          # TODO
      end
      socket.recv_string while socket.more_parts?
    end

    ##
    # @param  [Identifier] id
    # @return [void]
    def on_get(id)
      data = @repository[id]
      socket.send_string(data || '')
    end

    ##
    # @param  [Identifier] id
    # @param  [String] data
    # @return [void]
    def on_put(id, data)
      @repository[id] = data
      socket.send_string(id.to_str)
    end
  end # Server
end # Bitcache::ZeroMQ
