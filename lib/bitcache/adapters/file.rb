require 'fileutils'

module Bitcache::Adapters

  class File < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def create!
        FileUtils.mkdir_p(path, :mode => (config[:chmod] || '0755').to_i(8))
      end

      def open(mode = :read, &block)
        block.call(Pathname.new(path)) if block_given?
      end

      def path() config[:path] end
      def uri()  "file://#{::File.expand_path(path)}" end

      # Returns the total byte size of the repository, approximate to the next 1K block.
      def size
        if result = `du -k #{::File.expand_path(path)}`.chomp.split("\t").first
          result.to_i * 1024
        else
          super # fall back to manually iterating over the keys
        end
      end

      def each_key(&block)
        Dir.glob("#{path}/[a-f0-9]*") do |file|
          block.call($1) if file =~ /\/([a-f0-9]{40})$/ # FIXME
        end
      end

      def include?(id)
        ::File.exists?(::File.join(path, id))
      end

      def get(id, &block)
        if block_given?
          ::File.open(::File.join(path, id), 'rb', &block)
        else
          ::File.new(::File.join(path, id), 'rb')
        end
      end

      def put!(id, data = nil, &block)
        file_path = ::File.join(path, id)

        if block_given?
          ::File.open(file_path, 'wb', &block)
        else
          case
            when data.is_a?(Pathname)      # Pathname
              FileUtils.cp(data.to_s, file_path)
            when data.respond_to?(:read)   # Stream, IO
              ::File.open(file_path, 'wb') { |file| FileUtils.copy_stream(data, file) }
            when data.respond_to?(:to_str) # String
              ::File.open(file_path, 'wb') { |file| file.write(data.to_str) }
            else
              raise ArgumentError, data
          end
        end
        true
      end

      def delete!(id)
        ::File.delete(::File.join(path, id)) rescue false
      end

    end

    module StreamMethods #:nodoc:
      def path() ::File.join(config[:path], self.id) end
      def uri()  "file://#{::File.expand_path(path)}" end
      def size() ::File.size(path) end

      def content_type() super end # TODO
    end

  end
end
