module Bitcache class Adapter

  class SDBM < Adapter

    def initialize(config = {}, &block)
      require 'sdbm' unless defined?(::SDBM)
      super
    end

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        ::SDBM.open(path, 0644, &block)
      end

      def path() config[:dbfile] end
      def uri()  "sdbm://#{::File.expand_path(path)}" end
      def size() ::File.size(path) end
    end

    module StreamMethods #:nodoc:
      def path() [config[:dbfile], id].join('#') end
      def uri()  "sdbm://#{::File.expand_path(path)}" end
    end

  end
end end
