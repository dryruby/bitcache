require 'aws/s3'

module Bitcache class Adapter

  class AWS_S3 < Adapter

    module RepositoryMethods #:nodoc:
      def create!() end # for faster startup

      def open(mode = :read, &block)
        @conn ||= AWS::S3::Base.establish_connection!(
          :access_key_id     => config[:access] || ENV['AMAZON_ACCESS_KEY_ID'],
          :secret_access_key => config[:secret] || ENV['AMAZON_SECRET_ACCESS_KEY'])

        bucket = AWS::S3::Bucket.find(config[:bucket])
        block.call(bucket) if block_given?
      end

      def uri() "http://#{AWS::S3::DEFAULT_HOST}/#{config[:bucket]}/" end

      def each(filter = nil, &block)
        open(:read) do |bucket|
          options = {}
          options[:prefix] = filter if filter && !encoder
          bucket.objects(options).each do |object|
            if id = decode_key(object.key.to_s)
              next if should_ignore?(id, filter)
              stream = self[id]
              stream.instance_variable_set(:@size, object.size.to_i)
              block.call(stream)
            end
          end
        end
      end

      def each_key(filter = nil, &block)
        open(:read) do |bucket|
          options = {}
          options[:prefix] = filter if filter && !encoder
          bucket.objects(options).each do |object|
            if id = decode_key(object.key.to_s)
              block.call(id) unless should_ignore?(id, filter)
            end
          end
        end
      end

      def include?(id)
        open(:read) do |bucket|
          AWS::S3::S3Object.exists?(encode_key(id), bucket.name)
        end
      end

      def get(id, &block)
        open(:read) do |bucket|
          if body = AWS::S3::S3Object.value(encode_key(id), bucket.name) rescue nil
            io = StringIO.new(body)
            block_given? ? block.call(io) : io # TODO: S3Object streaming support?
          end
        end
      end

      def put!(id, data = nil, &block)
        data = slurp(data || block) # can't use aws/s3 streaming as it is buggy
        open(:write) do |bucket|
          options = {:content_type => 'application/octet-stream'}
          AWS::S3::S3Object.store(encode_key(id), data, bucket.name, options).success?
        end
      end

      def delete!(id)
        open(:write) do |bucket|
          !!AWS::S3::S3Object.delete(encode_key(id), bucket.name)
        end
      end
    end

    module StreamMethods #:nodoc:
      def uri()  URI.join(repo.uri, encode_key(self.id)) end
      #def uri()  AWS::S3::S3Object.url_for(encode_key(self.id), config[:bucket]) end
      def size() @size || -1 end
    end
  end

end end
