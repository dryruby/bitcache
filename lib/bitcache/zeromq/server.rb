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

    # @return [Hash{Symbol => ZMQ::Socket}]
    attr_reader :inputs

    ##
    # @param  [String] endpoint
    # @param  [Repository] repository
    # @param  [Hash{Symbol => Object}] options
    def initialize(endpoint, repository, options = {})
      @endpoint   = endpoint.to_s
      @repository = repository
      @inputs     = {}
      super(options)
    end

  protected

    ##
    # @return [void]
    def on_start
      @repository.open(:write)
      begin
        unless options[:pull].eql?(false)
          @inputs[:pull] = context.socket(ZMQ::PULL)
          @inputs[:pull].bind("#{@endpoint}.push") # HACK
          register(@inputs[:pull], ZMQ::POLLIN)
        end
        unless options[:rep].eql?(false)
          @inputs[:rep] = context.socket(ZMQ::REP)
          @inputs[:rep].bind("#{@endpoint}.req")   # HACK
          register(@inputs[:rep], ZMQ::POLLIN)
        end
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
      case socket
        when @inputs[:pull]
          on_push(socket)
        when @inputs[:rep]
          on_req(socket, req = socket.recv_string.to_sym)
      end
      socket.recv_string while socket.more_parts?
    end

    ##
    # @param  [ZMQ::Socket] socket
    # @return [void]
    def on_push(socket)
      id = Bitcache::Identifier.new(socket.recv_string)
      data = socket.recv_string
      @repository[id] = data
      on_put(id, data) if respond_to?(:on_put)
    end

    ##
    # @param  [ZMQ::Socket] socket
    # @param  [Symbol] req
    # @return [void]
    def on_req(socket, req)
      case req
        when :get
          parts = []
          while socket.more_parts?
            parts << Bitcache::Identifier.new(socket.recv_string)
          end
          while id = parts.shift
            socket.send_string(@repository[id] || '', parts.empty? ? 0 : ZMQ::SNDMORE)
          end
        when :put
          parts = []
          while socket.more_parts?
            parts << [Bitcache::Identifier.new(socket.recv_string), socket.recv_string]
          end
          while part = parts.shift
            id, data = part
            @repository[id] = data
            socket.send_string(id.to_str, parts.empty? ? 0 : ZMQ::SNDMORE)
            on_put(id, data) if respond_to?(:on_put)
          end
        else
          # TODO
      end
    end
  end # Server
end # Bitcache::ZeroMQ
