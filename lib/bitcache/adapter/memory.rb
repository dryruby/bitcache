module Bitcache class Adapter

  class Memory < Adapter

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        block.call(@db ||= {})
      end

      def transient?() true end
    end

    module StreamMethods end #:nodoc:

  end
end end
