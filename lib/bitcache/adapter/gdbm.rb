require 'gdbm'

module Bitcache class Adapter

  class GDBM < Adapter

    MODES = { :read => ::GDBM::READER, :write => ::GDBM::WRCREAT | ::GDBM::SYNC }

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        ::GDBM.open(path, 0644, ::Bitcache::Adapter::GDBM::MODES[mode], &block)
      end

      def path() config[:dbfile] end
      def uri() "gdbm://#{::File.expand_path(path)}" end
      def size() ::File.size(path) end
    end

    module StreamMethods #:nodoc:
      def path() [config[:dbfile], id].join('#') end
      def uri() "gdbm://#{::File.expand_path(path)}" end
    end

  end
end end
