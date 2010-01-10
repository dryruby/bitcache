module Bitcache
  ##
  class Repository
    include Enumerable

    ##
    # @return [Hash{Symbol => Object}]
    attr_accessor :options

    ##
    # Initializes this repository instance.
    #
    # @param  [Hash{Symbol => Object}] options
    # @yield  [repository]
    # @yieldparam [Repository] repository
    def initialize(options = {}, &block)
      @streams = options.delete(:data) || {}
      @options = options

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
      end
    end

    ##
    # Returns `true` if this repository is currently accessible.
    #
    # @return [Boolean]
    def accessible?
      true
    end

    ##
    # Returns `true` if this repository is readable.
    #
    # @return [Boolean]
    def readable?
      true
    end

    ##
    # Returns `true` if this repository is writable.
    #
    # @return [Boolean]
    def writable?
      true
    end

    alias_method :mutable?, :writable?

    ##
    # Returns `true` if this repository is empty.
    #
    # @return [Boolean]
    def empty?
      @streams.empty?
    end

    ##
    # Returns the number of bitstreams in this repository.
    #
    # @return [Integer]
    def count
      @streams.size
    end

    alias_method :size, :count

    ##
    # Stores a bitstream in this repository.
    #
    # @param  [String] id
    # @param  [Stream] stream
    # @param  [Hash{Symbol => Object}] options
    # @return [String] the bitstream's identifier
    def store(id, stream, options = {})
      if id ||= Bitcache.identify(stream)
        id = id.to_str
        @streams[id] = stream unless @streams.has_key?(id)
        return id
      end
    end

    alias_method :[]=, :store

    ##
    # Fetches a bitstream from this repository.
    #
    # @param  [String] id
    # @param  [Hash{Symbol => Object}] options
    # @return [Stream] the bitstream
    def fetch(id, options = {})
      if id && @streams.has_key?(id = id.to_str)
        Stream.new(id, @streams[id])
      end
    end

    alias_method :[], :fetch
  end
end
