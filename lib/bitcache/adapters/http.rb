require 'net/http'
require 'uri'

module Bitcache::Adapters

  class HTTP < Bitcache::Adapter

    module RepositoryMethods #:nodoc:
      def open(mode = :read, &block)
        @url ||= URI.parse(uri)
        block.call(@http ||= Net::HTTP.start(@url.host, @url.port))
      end

      def uri() config[:url] end

      def each(&block)
        open(:read) do |http|
          response = http.get(@url.path, { 'Accept' => 'text/plain' })
          response.body.split("\n").each do |line|
            id, size = line.split(/\s/)
            if id =~ /([a-f0-9]{40})$/ # FIXME
              stream = self[id]
              stream.instance_variable_set(:@size, size.to_i)
              block.call(stream)
            end
          end
        end
      end

      def each_key(&block)
        open(:read) do |http|
          response = http.get(@url.path, { 'Accept' => 'text/plain' })
          response.body.split("\n").each do |line|
            id = line.split(/\s/)[0]
            block.call(id) if id =~ /([a-f0-9]{40})$/ # FIXME
          end
        end
      end

      def include?(id)
        open(:read) do |http|
          response = http.head(URI.join(uri, id).path)
          response.is_a?(Net::HTTPSuccess)
        end
      end

      def get(id, &block)
        open(:read) do |http|
          response = http.get(URI.join(uri, id).path, { 'Accept' => '*/*' })
          if response.is_a?(Net::HTTPSuccess)
            io = StringIO.new(response.body)
            block_given? ? block.call(io) : io
          else
            nil
          end
        end
      end

      def post!(data = nil, &block)
        data = slurp(data || block)
        open(:write) do |http|
          response = http.post(@url.path, data)
          response.is_a?(Net::HTTPSuccess) ?
            (response['content-sha1'] || response['etag']) : false
        end
      end

      def put!(id, data = nil, &block)
        data = slurp(data || block)
        open(:write) do |http|
          response = http.request(Net::HTTP::Put.new(URI.join(uri, id).path), data)
          response.is_a?(Net::HTTPSuccess)
        end
      end

      def delete!(id)
        open(:write) do |http|
          response = http.delete(URI.join(uri, id).path, {})
          response.is_a?(Net::HTTPSuccess)
        end
      end
    end

    module StreamMethods #:nodoc:
      def uri()  URI.join(config[:url], self.id) end
      def size() @size || -1 end
    end

  end
end
