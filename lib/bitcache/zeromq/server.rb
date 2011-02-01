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
          id = Bitcache::Identifier.new(socket.recv_string)
          data = socket.recv_string
          on_push(id, data)
        when @inputs[:rep]
          case message = socket.recv_string
            when 'get'
              id = Bitcache::Identifier.new(socket.recv_string)
              on_get_req(id)
            when 'put'
              id = Bitcache::Identifier.new(socket.recv_string)
              data = socket.recv_string
              on_put_req(id, data)
            else
              # TODO
          end
          socket.recv_string while socket.more_parts?
      end
    end

    ##
    # @param  [Identifier] id
    # @param  [String] data
    # @return [void]
    def on_push(id, data)
      @repository[id] = data
    end

    ##
    # @param  [Identifier] id
    # @return [void]
    def on_get_req(id)
      data = @repository[id]
      @inputs[:rep].send_string(data || '')
    end

    ##
    # @param  [Identifier] id
    # @param  [String] data
    # @return [void]
    def on_put_req(id, data)
      @repository[id] = data
      @inputs[:rep].send_string(id.to_str)
    end
  end # Server
end # Bitcache::ZeroMQ
