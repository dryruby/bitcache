module Bitcache::Adapters

  class Memory < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        block.call(@db ||= {})
      end

      def transient?() true end
    end

    module BlobMethods end #:nodoc:

  end
end
