module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_id` data structure.
  #
  # @see Bitcache::Identifier
  module Identifier
    LAYOUT = [:type, :int,
              :digest, [:uint8, BITCACHE_ID_SIZE]]

    ##
    # @private
    def self.included(struct)
      struct.send(:include, Bitcache::FFI)
      struct.layout(*LAYOUT)

      self.instance_methods(false).each do |method|
        if struct.method_defined?(method)
          begin
            struct.send(:remove_method, method)
          rescue NameError
          end
        end
      end

      struct.send(:define_method, :initialize) { |*args| super(initialize_from(*args)) }
      def struct.release(ptr)
        Bitcache::FFI.bitcache_id_free(ptr) # TODO: implement reference counting
      end
    end

    ##
    # @private
    def initialize(digest = nil)
      super(initialize_from(digest))
    end

    ##
    # @private
    def initialize_from(digest = nil)
      case digest
        when String
          bitcache_id_new(digest.bytesize, FFI::MemoryPointer.from_string(digest))
        when nil
          bitcache_id_new(BITCACHE_SHA1, nil)
        when FFI::Pointer
          digest
        else raise ArgumentError, "expected an FFI::Pointer, but got #{digest.inspect}"
      end
    end

    ##
    # @private
    def clone
      copy = self.class.new(bitcache_id_copy(self))
      copy.taint  if tainted?
      copy.freeze if frozen?
      copy
    end

    ##
    # @private
    def dup
      copy = self.class.new(bitcache_id_copy(self))
      copy.taint if tainted?
      copy
    end

    ##
    # @private
    def freeze
      # NOTE: `aref(:digest)` returns a fresh object every time it is
      # called, so there's no way to freeze any constituent objects.
      super
    end

    ##
    # @private
    def digest
      digest = aref(:digest).to_ptr.read_string(size)
      digest.freeze if frozen?
      digest
    end
    alias_method :data, :digest

    ##
    # @private
    def size
      bitcache_id_get_digest_size(self)
    end
    alias_method :bytesize, :size
    alias_method :length,   :size

    ##
    # @private
    def zero?
      bitcache_id_is_zero(self)
    end
    alias_method :blank?, :zero?

    ##
    # @private
    def clear!
      raise TypeError, "can't modify frozen identifier" if frozen?
      bitcache_id_clear(self)
      self
    end
    alias_method :clear, :clear!

    ##
    # @private
    def fill!(byte)
      raise TypeError, "can't modify frozen identifier" if frozen?
      bitcache_id_fill(self, byte(byte).ord)
      self
    end
    alias_method :fill, :fill!

    ##
    # @private
    def []=(index, byte)
      index = index.to_i
      raise IndexError, "index #{index} is out of bounds" unless index >= 0 && index < size
      raise TypeError, "can't modify frozen identifier" if frozen?
      digest = aref(:digest)
      digest[index] = byte(byte).ord
    end

    ##
    # @private
    def <=>(other)
      return 0 if self.equal?(other)
      case other
        when Identifier
          size.eql?(other.size) ? bitcache_id_compare(self, other) : nil # FIXME
        when String
          size.eql?(other.size) ? digest <=> other : nil
        else nil
      end
    end

    ##
    # @private
    def eql?(other)
      return true if self.equal?(other)
      case other
        when Identifier
          bitcache_id_is_equal(self, other)
        else case
          when other.respond_to?(:to_ptr)
            to_ptr.eql?(other.to_ptr)
          else false
        end
      end
    end

    ##
    # @private
    def hash
      bitcache_id_get_hash(self)
    end

    ##
    # @private
    def hashes
      aref(:digest).to_ptr.get_array_of_uint32(0, size.div(4))
    end

    ##
    # @private
    def to_str
      frozen? ? digest.dup : digest
    end

    ##
    # @private
    def to_s(base = 16)
      case base
        when 16 then bitcache_id_to_hex_string(self, nil)
        when 10 then to_i.to_s(10).ljust((size * Math.log10(256)).ceil, '0')
        when 8  then to_i.to_s(8).ljust((size * (Math.log(256) / Math.log(8))).ceil, '0')
        when 2  then to_i.to_s(2).ljust(size * 8, '0') # TODO: optimize
        else raise ArgumentError, "invalid radix #{base}"
      end
    end
  end # Identifier
end # Bitcache::FFI
