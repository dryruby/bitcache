module Bitcache
  ##
  # A Bloom filter for Bitcache identifiers.
  #
  # Bloom filters are space-efficient probabilistic data structures used to
  # test whether an element is a member of a set. False positives are
  # possible, but false negatives are not. Elements can be added to the set,
  # but not removed. The more elements that are added to the set, the larger
  # the probability of false positives.
  #
  # Time Complexity
  # ---------------
  #
  # The time needed to either add an identifier or to check whether an
  # identifier is a member of the set is a fixed constant, `O(k)`,
  # completely independent of the number of identifiers already in the set.
  #
  # The constant `k` is proportional to the length of the specific type of
  # identifier used; `k=4` for MD5 identifiers, `k=5` for SHA-1 identifiers,
  # and `k=8` for SHA-256 identifiers.
  #
  # Note: all time complexity information given for methods refers to the
  # `libbitcache` implementation. The pure-Ruby method implementations may
  # perform differently.
  #
  # Space Requirements
  # ------------------
  #
  # The Bitcache implementation of Bloom filters is tuned to by default use
  # 8 bits per element, giving a false positive probability of around ~2%.
  #
  # Limitations
  # -----------
  #
  # Identifiers can't be removed from a filter except by recreating the
  # filter afresh. This could be addressed by implementing a counting Bloom
  # filter, but that would add complexity as well as quadruple the space
  # requirements of filters. Still, counting filters may be provided as an
  # option in the future if there is demand for the feature.
  #
  # @see http://en.wikipedia.org/wiki/Bloom_filter
  class Filter < Struct
    include Inspectable

    DEFAULT_CAPACITY = 4096 # elements
    BITS_PER_ELEMENT = 8    # bits

    ##
    # Deserializes a filter from the given `input` stream or file.
    #
    # @param  [File, IO, StringIO] input
    #   the input stream to read from
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @return [Filter] a new filter
    def self.load(input, options = {})
      input = StringIO.new(input) if input.is_a?(String)
      read = input.respond_to?(:readbytes) ? :readbytes : :read
      bytesize = input.send(read, 8).unpack('Q').first # uint64 in native byte order
      self.new(input.send(read, bytesize))
    end

    ##
    # Constructs a filter from the identifiers yielded by `enum`.
    #
    # Unless explicitly otherwise specified, the filter will have a capacity
    # that matches the number of elements in `enum`.
    #
    # @example Constructing a filter from an array
    #   Filter.for([id1, id2, id3])
    #
    # @example Constructing a filter from a list
    #   Filter.for(List[id1, id2, id3])
    #
    # @example Constructing a filter from a set
    #   Filter.for(Set[id1, id2, id3])
    #
    # @example Rounding up the capacity to the nearest power of two
    #   Filter.for(enum, :capacity => (1 << enum.count.to_s(2).length))
    #
    # @param  [Enumerable<Identifier, #to_id>] enum
    #   an enumerable that yields identifiers
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Integer] :capacity (enum.count)
    #   the capacity to create the filter with
    # @return [Filter] a new filter
    def self.for(enum, options = {})
      if enum.respond_to?(:to_filter)
        enum.to_filter
      else
        self.new(options[:capacity] || enum.count) do |filter|
          enum.each { |element| filter.insert(element.to_id) }
        end
      end
    end

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
    # Returns the capacity of this filter.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @return [Integer] a positive integer
    def capacity
      bitmap.bytesize
    end
    alias_method :size,     :capacity
    alias_method :bytesize, :capacity
    alias_method :length,   :capacity

    ##
    # Returns `true` if no elements have been inserted into this filter.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # octet length of the filter.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      /\A\x00+\z/ === bitmap
    end
    alias_method :zero?, :empty?

    ##
    # Returns the percentage of unused space in this filter.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # octet length of the filter.
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
    # Returns `1` if this filter contains the identifier `id`, and `0`
    # otherwise.
    #
    # This method may return a false positive, but it will never return a
    # false negative.
    #
    # The time complexity of this operation is `O(k)`, with `k` being a
    # constant proportional to the length of the identifier.
    #
    # @param  [Identifier, #to_id] id
    # @return [Integer] `1` or `0`
    def count(id)
      has_identifier?(id) ? 1 : 0
    end

    ##
    # Returns `true` if this filter contains the identifier `id`.
    #
    # This method may return a false positive, but it will never return a
    # false negative.
    #
    # The time complexity of this operation is `O(k)`, with `k` being a
    # constant proportional to the length of the identifier.
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
    # Returns the hash code for this filter.
    #
    # @return [Fixnum]
    def hash
      bitmap.hash
    end

    ##
    # Returns the bit at the given `index`.
    #
    # The time complexity of this operation is `O(1)`.
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
    # The time complexity of this operation is `O(1)`.
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
    # Inserts the given identifier `id` into this filter.
    #
    # The time complexity of this operation is `O(k)`, with `k` being a
    # constant proportional to the length of the identifier.
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
    # The time complexity of this operation is `O(n)`, with `n` being the
    # octet length of the filter.
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
    # Returns a new filter resulting from merging this filter and the given
    # `other` filter or byte string.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @param  [Symbol, #to_sym] op
    #   the bitwise operation to use: `:|`, `:&`, or `:^`
    # @return [Filter] a new filter
    def merge(other, op = :|)
      dup.merge!(other, op)
    end

    ##
    # Merges the given `other` filter or byte string into this filter.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @param  [Symbol, #to_sym] op
    #   the bitwise operation to use: `:|`, `:&`, or `:^`
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def merge!(other, op = :|)
      raise TypeError, "can't modify frozen filter" if frozen?

      other = other.is_a?(Filter) ? other.bitmap : other.to_str
      raise ArgumentError, "incompatible filter sizes" unless bytesize.eql?(other.bytesize)

      if bitmap.respond_to?(fast_method = :"#{op}!")
        bitmap.send(fast_method, other)
      else
        bitmap.each_byte.with_index do |byte, index|
          bitmap[index] = byte.send(op, other[index].ord).chr
        end
      end

      return self
    end

    ##
    # Returns the union of this filter and the given `other` filter or byte
    # string.
    #
    # This operation is loss-less in the sense that the resulting filter is
    # equal to a filter created from scratch using the union of the two sets
    # of identifiers.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [Filter] a new filter
    def or(other)
      merge(other, :|)
    end
    alias_method :|, :or

    ##
    # Merges the given `other` filter or byte string into this filter using
    # a bitwise `OR` operation.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def or!(other)
      merge!(other, :|)
    end

    ##
    # Returns the intersection of this filter and the given `other` filter
    # or byte string.
    #
    # The false-positive probability in the resulting filter is at most the
    # false-positive probability of one of the constituent filters, and may
    # be larger than the false-positive probability in a filter created from
    # scratch using the intersection of the two sets of identifiers.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [Filter] a new filter
    def and(other)
      merge(other, :&)
    end
    alias_method :&, :and

    ##
    # Merges the given `other` filter or byte string into this filter using
    # a bitwise `AND` operation.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def and!(other)
      merge!(other, :&)
    end

    ##
    # Returns the difference of this filter and the given `other` filter
    # or byte string.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [Filter] a new filter
    def xor(other)
      merge(other, :^)
    end
    alias_method :^, :xor

    ##
    # Merges the given `other` filter or byte string into this filter using
    # a bitwise `XOR` operation.
    #
    # @param  [Filter, #to_str] other
    #   a filter or byte string of equal size
    # @return [void] `self`
    # @raise  [TypeError] if the filter is frozen
    def xor!(other)
      merge!(other, :^)
    end

    ##
    # Returns `self`.
    #
    # @return [Filter] `self`
    def to_filter
      self
    end

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

    ##
    # Returns a developer-friendly representation of this filter.
    #
    # @return [String]
    def inspect
      super
    end

    ##
    # Serializes the filter to the given `output` stream or file.
    #
    # @param  [File, IO, StringIO] output
    #   the output stream to write to
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Boolean] :header (false)
    #   whether to write an initial Bitcache header
    # @return [void] `self`
    def dump(output, options = {})
      output.write([MAGIC].pack('S')) if options[:header]
      output.write([bytesize].pack('Q')) # uint64 in native byte order
      output.write(bitmap)
      return self
    end

  protected

    ##
    # @private
    # @return [Array]
    # @see    Marshal.dump
    def marshal_dump
      [@bitmap]
    end

    ##
    # @private
    # @param  [Array] data
    # @return [void]
    # @see    Marshal.load
    def marshal_load(data)
      @bitmap  = data.first
      @bitsize = @bitmap.size * 8
    end

    # Load optimized method implementations when available:
    #send(:include, Bitcache::FFI::Filter) if defined?(Bitcache::FFI::Filter)
  end # Filter
end # Bitcache
