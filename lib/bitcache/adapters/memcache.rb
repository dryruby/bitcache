require 'memcache'

module Bitcache::Adapters

  class Memcache < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def available?
        open(:read) { |db| db.active? }
      end

      def open(mode = :read, &block)
        memcache = MemCache.new(server, :namespace => config[:namespace])
        block.call(memcache) if block_given?
      end

      def server() [config[:host] || 'localhost', config[:port] || 11211].join(':') end
      def uri()    "memcache://#{server}" end
      def size()   sum_stats(:bytes) end
      def count()  sum_stats(:curr_items) end

      def each_key(filter = nil, &block)
        nil # memcached doesn't provide any way of enumerating the stored keys
      end

      def include?(id)
        !!get(id)
      end

      def get(id, &block)
        if data = open(:read) { |db| db.get(id, true) }
          io = StringIO.new(data)
          block_given? ? block.call(io) : io
        end
      end

      def put!(id, data = nil, &block)
        ttl = config[:ttl] || 0

        if block_given?
          open(:write) do |db|
            block.call(io = StringIO.new)
            db.add(id, io.string, ttl, true)
          end
        else
          case
            when data.respond_to?(:read)
              open(:write) { |db| db.add(id, data.read, ttl, true) }
            when data.respond_to?(:to_str)
              open(:write) { |db| db.add(id, data.to_str, ttl, true) }
            else
              raise ArgumentError, data
          end
        end
        true
      end

      def clear!
        open(:write) { |db| db.flush_all }
      end

      protected

        def sum_stats(key)
          key = key.to_s
          open(:read) do |db|
            db.stats.inject(0) { |sum, (server, stats)| sum += stats[key].to_i }
          end
        end

    end

    module StreamMethods #:nodoc:
      def uri() [repo.uri, config[:namespace] ? "#{config[:namespace]}:#{id}" : id].join('/') end
    end

  end
end
