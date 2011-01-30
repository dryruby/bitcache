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
      on_start if respond_to?(:on_start)
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
      Signal.trap(:INT,  method(:on_sigint))
      Signal.trap(:HUP,  method(:on_sighup))
      Signal.trap(:USR1, method(:on_sigusr1))
      Signal.trap(:USR2, method(:on_sigusr2))
    end

    ##
    # Handles the `SIGTERM` signal.
    #
    # @param  [Integer] signum
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGTERM
    # @see    http://en.wikipedia.org/wiki/SIGKILL
    def on_sigterm(signum)
      log.info("Received a SIGTERM (#{signum}) signal, terminating...") if respond_to?(:log)
      die
    end

    ##
    # Handles the `SIGINT` signal.
    #
    # @param  [Integer] signum
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGINT_(POSIX)
    def on_sigint(signum)
      log.info("Received a SIGINT (#{signum}) signal, terminating...") if respond_to?(:log)
      die
    end

    ##
    # Handles the `SIGHUP` signal.
    #
    # @param  [Integer] signum
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGHUP
    def on_sighup(signum)
      log.info("Received a SIGHUP (#{signum}) signal, terminating...") if respond_to?(:log)
      die
    end

    ##
    # Handles the `SIGUSR1` signal.
    #
    # @param  [Integer] signum
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGUSR1_and_SIGUSR2
    def on_sigusr1(signum)
      log.info("Received a SIGUSR1 (#{signum}) signal.") if respond_to?(:log)
      # no-op by default
    end

    ##
    # Handles the `SIGUSR2` signal.
    #
    # @param  [Integer] signum
    # @return [void]
    # @see    http://en.wikipedia.org/wiki/SIGUSR1_and_SIGUSR2
    def on_sigusr2(signum)
      log.info("Received a SIGUSR2 (#{signum}) signal.") if respond_to?(:log)
      # no-op by default
    end

  protected

    ##
    # @return [void]
    def die
      on_stop if respond_to?(:on_stop)
      sockets.each { |socket| socket.close } if sockets
      context.terminate if context
      on_exit if respond_to?(:on_exit)
      abort ""
    end
  end # Loop
end # Bitcache::ZeroMQ
