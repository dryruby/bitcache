require 'sdbm'

module Bitcache::Adapters

  class SDBM < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        ::SDBM.open(path, 0644, &block)
      end

      def path() config[:dbfile] end
      def uri()  "file://#{File.expand_path(path)}" end
      def size() ::File.size(path) end
    end

    module BlobMethods #:nodoc:
      def path() [config[:dbfile], id].join('#') end
      def uri()  "file://#{File.expand_path(path)}" end
    end

  end
end
