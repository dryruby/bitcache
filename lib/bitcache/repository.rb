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
    # Returns `true` if this repository has a bitstream identified by `id`.
    #
    # @return [Boolean]
    def has_id?(id)
      @streams.has_key?(id)
    end

    ##
    # Enumerates over each bitstream in this repository.
    #
    # @yield  [stream]
    # @yield  [Stream] stream
    # @return [Enumerator]
    def each(&block)
      @streams.each do |id, data|
        block.call(Stream.new(id, data))
      end
    end

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

    alias_method :store!, :store

    ##
    # Stores a bitstream in this repository.
    #
    # @param  [Stream] stream
    # @return [Stream]
    def []=(id, stream)
      raise ArgumentError.new("expected String identifier, got #{id.inspect}") unless id
      store(id, stream)
      stream
    end

    ##
    # Stores a bitstream in this repository.
    #
    # @param  [Stream] stream
    # @return [Repository]
    def <<(stream)
      store(nil, stream)
      self
    end

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

    ##
    # Deletes a bitstream from this repository.
    #
    # @param  [String] id
    # @param  [Hash{Symbol => Object}] options
    # @return [Boolean]
    def delete(id, options = {})
      if id && @streams.has_key?(id = id.to_str)
        @streams.delete(id)
      end
    end

    alias_method :delete!, :delete

    ##
    # Deletes all bitstreams from this repository.
    #
    # @param  [Hash{Symbol => Object}] options
    # @return [Integer]
    def clear(options = {})
      if empty?
        count = 0
      else
        count = @streams.size
        @streams.clear
        count
      end
    end

    alias_method :clear!, :clear
  end
end
