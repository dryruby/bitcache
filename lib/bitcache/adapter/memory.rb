module Bitcache class Adapter

  class Memory < Adapter

    def initialize(config = {}, &block)
      super
    end

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        block.call(@db ||= {})
      end

      def transient?() true end
    end

    module StreamMethods end #:nodoc:

  end
end end
