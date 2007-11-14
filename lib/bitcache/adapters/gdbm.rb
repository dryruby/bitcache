require 'gdbm'

module Bitcache::Adapters

  class GDBM < Bitcache::Adapter

    MODES = { :read => ::GDBM::READER, :write => ::GDBM::WRCREAT | ::GDBM::SYNC }

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        ::GDBM.open(path, 0644, ::Bitcache::Adapters::GDBM::MODES[mode], &block)
      end

      def path() config[:dbfile] end
      def uri() "file://#{File.expand_path(path)}" end
      def size() ::File.size(path) end
    end

    module BlobMethods #:nodoc:
      def path() [config[:dbfile], id].join('#') end
      def uri() "file://#{File.expand_path(path)}" end
    end

  end
end
