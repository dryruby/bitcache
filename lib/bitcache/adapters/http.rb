require 'net/http'

module Bitcache::Adapters

  class HTTP < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        block.call(@db ||= {})
      end
    end

    module StreamMethods end #:nodoc:

  end
end
