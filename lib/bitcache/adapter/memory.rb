module Bitcache class Adapter

  class Memory < Adapter

    def initialize(config = {}, &block)
      super
    end

    def transient?() true end

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        block.call(@db ||= {})
      end
    end

    module StreamMethods end #:nodoc:

  end
end end
