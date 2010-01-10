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
      true # FIXME
    end

    ##
    # Returns the number of bitstreams in this repository.
    #
    # @return [Integer]
    def count
      0 # FIXME
    end
  end
end
