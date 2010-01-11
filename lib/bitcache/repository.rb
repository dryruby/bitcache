module Bitcache
  ##
  class Repository
    include Inspectable
    include Enumerable

    ##
    # @return [Hash{Symbol => Object}]
    attr_accessor :options

    ##
    # Initializes this repository instance.
    #
    # @overload initialize(url)
    #   @param  [String, #to_s] url
    #
    # @overload initialize(options = {})
    #   @param  [Hash{Symbol => Object}] options
    #
    # @yield  [repository]
    # @yieldparam [Repository] repository
    def initialize(url_or_options = {}, &block)
      case url_or_options
        when Hash
          @streams = url_or_options.delete(:data) || {}
          @options = url_or_options
        else
          uri = Addressable::URI.parse(url_or_options.to_s)
          # TODO
          @streams = {}
          @options = {}
      end

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
      end
    end

    ##
    # Returns `true` if this repository is accessible at present.
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

    ##
    # Returns the total octet size of this repository.
    #
    # @return [Integer]
    def size
      inject(0) { |sum, stream| sum + stream.size }
    end

    ##
    # Returns `true` if this repository contains a bitstream identified by
    # `id`.
    #
    # @param  [String, #to_str] id
    # @return [Boolean]
    def has_id?(id)
      @streams.has_key?(id.to_str)
    end

    alias_method :has_key?, :has_id?

    ##
    # Returns `true` if this repository contains `stream`.
    #
    # @param  [Stream, Proc, #read, #to_str] stream
    # @return [Boolean]
    def has_stream?(stream)
      @streams.has_key?(Bitcache.identify(stream))
    end

    alias_method :has_data?,  :has_stream?
    alias_method :has_value?, :has_stream?

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
    # @param  [Stream, Proc, #read, #to_str] stream
    # @param  [Hash{Symbol => Object}] options
    # @return [String] the bitstream's identifier
    def store(id, stream, options = {})
      if id ||= Bitcache.identify(stream)
        id = id.to_str
        @streams[id] = Bitcache.read(stream) unless has_id?(id)
        return id
      end
    end

    alias_method :store!, :store
    alias_method :set,    :store
    alias_method :put,    :store

    ##
    # Stores a bitstream in this repository.
    #
    # @param  [String] id
    # @param  [Stream, Proc, #read, #to_str] stream
    # @return [Stream]
    def []=(id, stream)
      raise ArgumentError.new("expected String identifier, got #{id.inspect}") unless id
      store(id, stream)
      stream # FIXME
    end

    ##
    # Stores a bitstream in this repository.
    #
    # @param  [Stream, Proc, #read, #to_str] stream
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
      if id && has_id?(id = id.to_str)
        Stream.new(id, @streams[id])
      end
    end

    alias_method :[],  :fetch
    alias_method :get, :fetch

    ##
    # Deletes a bitstream from this repository.
    #
    # @param  [String] id
    # @param  [Hash{Symbol => Object}] options
    # @return [Boolean]
    def delete(id, options = {})
      if id && has_id?(id = id.to_str)
        @streams.delete(id)
        true
      else
        false
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
        count = self.count
        @streams.clear
        count
      end
    end

    alias_method :clear!, :clear
  end
end
