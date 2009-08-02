require 'net/ssh'
require 'net/sftp'

module Bitcache class Adapter

  class SFTP < Adapter

    module RepositoryMethods #:nodoc:
      def available?
        super
      end

      def create!
        return false unless path

        open(:write) do |sftp|
          sftp.mkdir(path, :permissions => (config[:chmod] || '0755').to_i(8)) rescue false
        end
      end

      def open(mode = :read, &block)
        @sftp_options ||= config.clone.delete_if { |k, v| ![:port, :compression, :timeout, :username, :password].include?(k) }
        @sftp ||= Net::SFTP.start(config[:host] || 'localhost', @sftp_options).connect
        block_given? ? block.call(@sftp) : @sftp
      end

      def close
        @sftp.close if @sftp
      end

      def path() config[:path] end

      def uri
        @uri ||= 'sftp://' << [
          config[:user] ? "#{config[:user]}@" : '',
          config[:host],
          config[:port] ? ":#{config[:port]}" : '',
          path].join
      end

      def size() super end

      def each_key(filter = nil, &block)
        open(:read) do |sftp|
          handle = sftp.opendir(path)
          sftp.readdir(handle).each do |item|
            block.call($1) if item.filename =~ /^([a-f0-9]{40})$/ # FIXME
          end
          sftp.close_handle(handle)
        end
      end

      def include?(id)
        open(:read) { |sftp| !!sftp.stat(file_path(id)) rescue false }
      end

      def get(id, &block)
        io = open(:read) do |sftp|
          sftp.open_handle(file_path(id)) do |handle|
            StringIO.new(sftp.read(handle))
          end
        end
        block_given? ? block.call(io) : io
      end

      def put!(id, data = nil, &block)
        if block_given?
          ::File.open(file_path(id), 'wb', &block)
        else
          case
            when data.is_a?(Pathname)
              open(:write) { |sftp| sftp.put_file(data.to_s, file_path(id)) }
            when data.respond_to?(:read)
              open(:write) do |sftp|
                sftp.open_handle(file_path(id), 'w') { |handle| sftp.write(handle, data.read) } # FIXME
              end
            when data.respond_to?(:to_str)
              open(:write) do |sftp|
                sftp.open_handle(file_path(id), 'w') { |handle| sftp.write(handle, data.to_str) }
              end
            else
              raise ArgumentError, data
          end
        end
        true
      end

      def delete!(id)
        open(:write) { |sftp| sftp.remove(file_path(id)) rescue false }
      end

      protected

        def file_path(id) ::File.join(path, id) end

        def file_size(id)
          open(:read) { |sftp| sftp.stat(file_path(id)).size }
        end

    end

    module StreamMethods #:nodoc:
      def path() [repo.path, id].join('/') end
      def uri()  [repo.uri, id].join('/') end
      def size() @size ||= repo.send(:file_size, id) end
    end

  end
end end
