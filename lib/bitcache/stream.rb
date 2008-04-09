module Bitcache

  class Stream
    ID_FORMAT = /([a-f0-9]{40})$/

    def self.hash(file)
      Digest::SHA1.file(file).hexdigest
    end

    attr_reader :id
    attr_reader :repo

    def initialize(repo, id)
      @repo, @id = repo, id.to_s
    end

    def ==(other)
      self.id == other.id
    end

    def readable?() true end

    # Returns +false+, as bitstreams are immutable after creation.
    def writable?() false end

    def path
      raise NotImplementedError
    end

    def uri
      raise NotImplementedError
    end

    def size
      repo.get(id).size
    end

    # Returns +true+ if this is a zero-length bitstream; +false+ otherwise.
    def zero?
      size == 0
    end

    alias content_length size

    def content_type
      'application/octet-stream' # TODO
    end

    def read(length = nil, buffer = nil)
      if io = repo.get(id)
        io.read
      end
    end

    def to_s
      read
    end

    def inspect
      super
    end

    protected

      def config() @repo.config end
      def encode_key(key) @repo.send(:encode_key, key) end
      def decode_key(key) @repo.send(:decode_key, key) end

  end
end
