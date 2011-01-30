module Bitcache::ZeroMQ
  ##
  # Base class for ZeroMQ-based event loops.
  #
  # @see http://zguide.zeromq.org/chapter:all
  # @see http://rubydoc.info/gems/ffi-rzmq/0.7.0/frames
  class Loop
    # @return [ZMQ::Context]
    attr_reader :context

    # @return [ZMQ::Poller]
    attr_reader :poller

    # @return [Array<ZMQ::Socket>]
    attr_reader :sockets

    # @return [Integer]
    attr_reader :pid

    # @return [Hash]
    attr_reader :options

    ##
    # @param  [Hash{Symbol => Object}] options
    def initialize(options = {})
      @options = options.dup
    end

    ##
    # @return [void] `self`
    def start
      @pid = fork(&method(:run))
      return self
    end

    ##
    # @return [void] `self`
    def stop
      Process.kill(:TERM, @pid)
      Process.wait(@pid, Process::WNOHANG)
      return self
    end

    ##
    # @param  [ZMQ::Socket] socket
    # @return [void] `self`
    def register(socket, *args)
      @sockets ||= []
      @sockets << socket
      @poller.register(socket, *args)
      return self
    end

    ##
    # Note: this method is executed in a subprocess, and never returns
    # unless the process exits.
    #
    # @return [void]
    def run
      @context = ZMQ::Context.new(1)
      @poller  = ZMQ::Poller.new
      setup if respond_to?(:setup)
      loop do
        on_loop if respond_to?(:on_loop)
        @poller.poll(:blocking)
        @poller.readables.each do |socket|
          on_readable(socket)
        end
      end
    end

    ##
    # @return [void] `self`
    def setup
      Signal.trap(:TERM, method(:on_sigterm))
      Signal.trap(:INT, method(:on_sigint))
    end

    ##
    # Handles the `SIGINT` signal.
    #
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGINT_(POSIX)
    def on_sigint(*args)
      die
    end

    ##
    # Handles the `SIGTERM` signal.
    #
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGTERM
    # @see    http://en.wikipedia.org/wiki/SIGKILL
    def on_sigterm(*args)
      die
    end

  protected

    ##
    # @return [void]
    def die
      sockets.each { |socket| socket.close } if sockets
      context.terminate if context
      abort ""
    end
  end # Loop
end # Bitcache::ZeroMQ
