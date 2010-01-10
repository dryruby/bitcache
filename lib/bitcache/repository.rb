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
  end
end
