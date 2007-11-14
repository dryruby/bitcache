require 'stringio'
require 'pathname'

module Bitcache

  class Repository
    include Enumerable

    attr_reader :adapter
    attr_reader :config

    def initialize(adapter, config = {}, &block)
      @adapter, @config = adapter, config
      self.extend(adapter.class.const_get(:RepositoryMethods))
      create!
      block.call(self) if block_given?
    end

    def available?
      true
    end

    def create!
      open(:write) { |db| }
    end

    def open(mode = :read, &block)
      raise NotImplementedError
    end

    def path
      nil
    end

    def uri
      nil
    end

    def size
      inject(0) { |sum, blob| sum + blob.size }
    end

    def each(&block)
      each_key { |id| block.call(self[id]) }
    end

    def each_key(&block)
      open(:read) { |db| db.keys.each(&block) }
    end

    def include?(id)
      open(:read) { |db| db.keys.include?(id) }
    end

    def <<(data)
      post!(data)
    end

    def []=(id, data)
      put!(id, data) unless include?(id)
    end

    def [](id)
      blob = Blob.new(self, id)
      blob.extend(adapter.class.const_get(:BlobMethods))
      blob
    end

    def get(id, &block)
      if data = open(:read) { |db| db[id] }
        io = StringIO.new(data)
        block_given? ? block.call(io) : io
      end
    end

    def post!(data = nil, &block)
      raise "Attempt to write to a read-only repository" unless adapter.supports?(:write)

      if data.nil?
        block.call(io = StringIO.new)
        data = io.string
      end

      id = Blob.hash(data)
      include?(id) ? false : put!(id, data)
    end

    def put!(id, data = nil, &block)
      if block_given?
        open(:write) do |db|
          block.call(io = StringIO.new)
          db[id] = io.string
        end
      else
        case
          when data.respond_to?(:read)   # Blob, IO, Pathname
            open(:write) { |db| db[id] = data.read }
          when data.respond_to?(:to_str) # String
            open(:write) { |db| db[id] = data.to_str }
          else
            raise ArgumentError, data
        end
      end
      true
    end

    def delete!(id)
      open(:write) { |db| db.delete(id) }
    end

    # Use with extreme caution.
    def clear!
      each_key { |id| delete!(id) }
    end

    alias post post!
    alias put put!
    alias delete delete!
    alias clear clear!

  end
end
