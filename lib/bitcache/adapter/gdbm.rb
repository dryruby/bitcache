module Bitcache class Adapter

  class GDBM < Adapter

    def initialize(config = {}, &block)
      require 'gdbm' unless defined?(::GDBM)
      super
    end

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        modes = { :read => ::GDBM::READER, :write => ::GDBM::WRCREAT | ::GDBM::SYNC }
        ::GDBM.open(path, 0644, modes[mode], &block)
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
