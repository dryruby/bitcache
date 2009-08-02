module Bitcache
  class Adapter
    autoload :AWS_S3,   'bitcache/adapter/aws-s3'
    autoload :File,     'bitcache/adapter/file'
    autoload :GDBM,     'bitcache/adapter/gdbm'
    autoload :HTTP,     'bitcache/adapter/http'
    autoload :Memcache, 'bitcache/adapter/memcache'
    autoload :Memory,   'bitcache/adapter/memory'
    autoload :SDBM,     'bitcache/adapter/sdbm'
    autoload :SFTP,     'bitcache/adapter/sftp'
    #autoload :TFTP,    'bitcache/adapter/tftp' # TODO

    def self.each(&block)
      self.constants.each do |const|
        if (adapter = self.const_get(const)).superclass == Adapter
          block.call(adapter)
        end
      end
    end

    def self.for(adapter_name)
      adapter_name = adapter_name.to_sym
      require "bitcache/adapter/#{adapter_name}"
      @@registry[adapter_name]
    end

    def self.new(config = {}, &block)
      if self == Bitcache::Adapter
        self.for(config.delete(:adapter) || :memory).new(config, &block)
      else
        super
      end
    end

    def initialize(config = {}, &block)
      raise NotImplementedError if self.class == Bitcache::Adapter

      @config = config
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
        @@registry[$1.to_sym] = child if caller.first =~ /\/([\w\d_-]+)\.rb:\d+$/ # FIXME
        super
      end

  end
end
