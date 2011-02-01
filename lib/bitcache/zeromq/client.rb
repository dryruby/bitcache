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
      @push = @context.socket(ZMQ::PUSH) unless @push
      @push.setsockopt(ZMQ::LINGER, @options[:linger] || -1) # try to send the data indefinitely
      @push.connect("#{@endpoint}.push") # HACK
      @req = @context.socket(ZMQ::REQ) unless @req
      @req.setsockopt(ZMQ::LINGER, @options[:linger] || -1) # try to send the data indefinitely
      @req.connect("#{@endpoint}.req")   # HACK
      return self
    end

    ##
    # @return [void] `self`
    def disconnect
      @req.close
      @req = nil
      @push.close
      @push = nil
      @context.terminate unless @options[:context]
      return self
    end

    ##
    # @param  [Array<#to_s>] operands
    # @return [void] `self`
    def push(*operands)
      operands.map!(&:to_s)
      while operand = operands.shift
        @push.send_string(operand.to_s, operands.empty? ? 0 : ZMQ::SNDMORE)
      end
      return self
    end

    ##
    # @param  [Symbol] operator
    # @param  [Array<#to_s>] operands
    # @return [void]
    def req(operator, *operands)
      result = []
      @req.send_string(operator.to_s, operands.empty? ? 0 : ZMQ::SNDMORE)
      operands.map!(&:to_s)
      while operand = operands.shift
        @req.send_string(operand.to_s, operands.empty? ? 0 : ZMQ::SNDMORE)
      end
      result << @req.recv_string
      result << @req.recv_string while @req.more_parts?
      result
    end

    ##
    # @param  [Array<Identifier>] id
    # @return [Array<String>]
    def fetch(*ids)
      ids.empty? ? [] : req(:get, *ids.map(&:to_str))
    end

    ##
    # @param  [Identifier] id
    # @return [String]
    def [](id)
      @req.send_string('get', ZMQ::SNDMORE)
      @req.send_string(id.to_str)
      @req.recv_string
    end

    ##
    # @param  [Identifier] id
    # @param  [Object] data
    # @return [void]
    def []=(id, data)
      push(id.to_str, Bitcache.read(data))
      data
    end

    ##
    # @param  [Object] data
    # @return [void]
    def <<(data)
      @req.send_string('put', ZMQ::SNDMORE)
      @req.send_string('', ZMQ::SNDMORE)
      @req.send_string(Bitcache.read(data))
      @req.recv_string
    end
  end # Client
end # Bitcache::ZeroMQ
