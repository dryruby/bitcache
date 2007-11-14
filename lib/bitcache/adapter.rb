module Bitcache
  class Adapter

    def self.new(config = {})
      if self == Bitcache::Adapter
        adapter = config[:adapter]
        require "bitcache/adapters/#{adapter}"
        @@registry[adapter].new(config)
      else
        super
      end
    end

    def initialize(config = {}, &block)
      raise NotImplementedError if self.class == Bitcache::Adapter

      block.call(self) if block_given?
    end

    def transient?
      false
    end

    def permanent?
      !transient?
    end

    def supports?(op)
      true
    end

    protected

      @@registry = {}

      def self.inherited(child) #:nodoc:
        @@registry[$1] = child if caller.first =~ /\/([\w-]+)\.rb:\d+$/
        super
      end

  end
end
