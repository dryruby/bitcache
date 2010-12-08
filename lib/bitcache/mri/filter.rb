module Bitcache
  ##
  # A Bloom filter for Bitcache identifiers.
  #
  # @see http://en.wikipedia.org/wiki/Bloom_filter
  class Filter < Struct
    include Inspectable

    DEFAULT_CAPACITY = 4096 # elements
    BITS_PER_ELEMENT = 8    # bits

    ##
    # Initializes a new filter from the given `bitmap`.
    #
    # @example Constructing a new filter
    #   Filter.new
    #
    # @param  [String, Integer] bitmap
    #   the initial bitmap for the filter
    # @yield  [filter]
    # @yieldparam  [Filter] `self`
    # @yieldreturn [void] ignored
    def initialize(bitmap = nil, &block)
      @bitmap = case bitmap
        when nil     then "\0" * DEFAULT_CAPACITY
        when Integer then "\0" * bitmap
        when String  then bitmap.dup
        else raise ArgumentError, "expected a String or Integer, but got #{bitmap.inspect}"
      end
      @bitmap.force_encoding(Encoding::BINARY) if @bitmap.respond_to?(:force_encoding) # for Ruby 1.9+
      @bitsize = @bitmap.size * 8

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Initializes a filter cloned from `original`.
    #
    # @param  [Filter] original
    # @return [void]
    def initialize_copy(original)
      @bitmap = original.instance_variable_get(:@bitmap).clone
    end

    ##
    # Prevents further modifications to this filter.
    #
    # @return [void] `self`
    def freeze
      bitmap.freeze
      super
    end

    ##
    # @private
    attr_reader :bitmap

    ##
    # Returns the byte size of this filter.
    #
    # @return [Integer] a positive integer
    def size
      bitmap.bytesize
    end
    alias_method :bytesize, :size
    alias_method :length,   :size

    ##
    # Returns `true` if no elements have been inserted into this filter.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      /\A\x00+\z/ === bitmap
    end
    alias_method :zero?, :empty?

    ##
    # Returns the percentage of unused space in this filter.
    #
    # @return [Float] `(0.0..1.0)`
    def space
      space = 0
      bitmap.each_byte do |byte|
        if byte.zero?
          space += 8
        else
          0.upto(7) do |r|
            space += 1 if (byte & (1 << r)).zero?
          end
        end
      end
      space / @bitsize.to_f
    end

    ##
    # Returns the bit at the given `index`.
    #
    # @example Checking the state of a given bit
    #   filter[42]          #=> true or false
    #
    # @param  [Integer, #to_i] index
    #   a bit offset
    # @return [Boolean] `true` or `false`; `nil` if `index` is out of bounds
    def [](index)
      q, r = index.to_i.divmod(8)
      byte = bitmap[q]
      byte ? !((byte.ord & (1 << r)).zero?) : nil
    end

    ##
    # Updates the bit at the given `index` to `value`.
    #
    # @example Toggling the state of a given bit
    #   filter[42] = true   # sets the bit at position 42
    #   filter[42] = false  # clears the bit at position 42
    #
    # @param  [Integer] index
    #   a bit offset
    # @param  [Boolean] value
    #   `true` or `false`
    # @return [Boolean] `value`
    # @raise  [IndexError] if `index` is out of bounds
    # @raise  [TypeError] if the filter is frozen
    def []=(index, value)
      q, r = index.to_i.divmod(8)
      byte = bitmap[q]
      raise IndexError, "index #{index} is out of bounds" unless byte
      raise TypeError, "can't modify frozen filter" if frozen?
      bitmap[q] = value ?
        (byte.ord | (1 << r)).chr :
        (byte.ord & (0xff ^ (1 << r))).chr
    end

    ##
    # Returns `true` if this filter contains the identifier `id`.
    #
    # This method may return a false positive, but it will never return a
    # false negative.
    #
    # @param  [Identifier, #to_id] id
    # @return [Boolean] `true` or `false`
    def has_identifier?(id)
      id.to_id.hashes.each do |hash|
        return false unless self[hash % @bitsize]
      end
      return true # may return a false positive
    end
    alias_method :has_id?,  :has_identifier?
    alias_method :include?, :has_identifier?
    alias_method :member?,  :has_identifier?

    ##
    # Returns `true` if this filter is equal to the given `other` filter or
    # byte string.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def ==(other)
      return true if self.equal?(other)
      case other
        when Filter
          bytesize.eql?(other.bytesize) && bitmap.eql?(other.bitmap)
        when String
          bytesize.eql?(other.bytesize) && bitmap.eql?(other)
        else false
      end
    end

    ##
    # Returns `true` if this filter is identical to the given `other`
    # filter.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      return true if self.equal?(other)
      case other
        when Filter
          self == other
        else false
      end
    end

    ##
    # Inserts the given identifier `id` into this filter.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def insert(id)
      raise TypeError, "can't modify frozen filter" if frozen?
      id.to_id.hashes.each do |hash|
        self[hash % @bitsize] = true
      end
      return self
    end
    alias_method :add, :insert
    alias_method :<<, :insert

    ##
    # Resets this filter, removing any and all information about inserted
    # elements.
    #
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def clear
      raise TypeError, "can't modify frozen filter" if frozen?
      bitmap.gsub!(/./m, "\0")
      return self
    end
    alias_method :clear!, :clear
    alias_method :reset!, :clear

    ##
    # Returns the byte string representation of this filter.
    #
    # @return [String]
    def to_str
      bitmap.dup
    end

    ##
    # Returns the hexadecimal string representation of this filter.
    #
    # @param  [Integer] base
    #   the numeric base to convert to: `2` or `16`
    # @return [String]
    # @raise  [ArgumentError] if `base` is invalid
    def to_s(base = 16)
      case base
        when 16 then bitmap.unpack('H*').first
        when 2  then bitmap.unpack('B*').first
        else raise ArgumentError, "invalid radix #{base}"
      end
    end

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::Filter) if defined?(Bitcache::FFI::Filter)
  end # Filter
end # Bitcache
