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
      inject(0) { |sum, stream| sum + stream.size }
    end

    def keys
      keys = []
      each_key { |key| keys << key }
      keys
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
      stream = Stream.new(self, id)
      stream.extend(adapter.class.const_get(:StreamMethods))
      stream
    end

    def get(id, &block)
      if data = open(:read) { |db| db[id] }
        io = StringIO.new(data)
        block_given? ? block.call(io) : io
      end
    end

    def post!(data = nil, &block)
      ensure_writable

      unless data
        block.call(io = StringIO.new)
        data = io.string
      end

      id = Stream.hash(data)
      include?(id) ? false : put!(id, data)
    end

    def put!(id, data = nil, &block)
      ensure_writable

      if block_given?
        open(:write) do |db|
          block.call(io = StringIO.new)
          db[id] = io.string
        end
      else
        open(:write) { |db| db[id] = slurp(data) }
      end
      true
    end

    def delete!(id)
      ensure_writable

      open(:write) { |db| db.delete(id) }
    end

    # Use with extreme caution.
    def clear!
      ensure_writable

      each_key { |id| delete!(id) }
    end

    alias post post!
    alias put put!
    alias delete delete!
    alias clear clear!

    protected

      def slurp(data)
        case
          when data.is_a?(Proc)           # data producer block
            data.call(io = StringIO.new)
            io.string
          when data.respond_to?(:read)    # Stream, IO, Pathname
            data.read
          when data.respond_to?(:to_str)  # String
            data.to_str
          else
            raise ArgumentError, data
        end
      end

      def ensure_writable
        raise "Attempt to write to a read-only repository" unless adapter.supports?(:write)
      end

  end
end
