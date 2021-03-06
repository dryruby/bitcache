module Bitcache
  ##
  # A set of Bitcache identifiers.
  #
  # Time Complexity
  # ---------------
  #
  # Note: all time complexity information given for methods refers to the
  # `libbitcache` implementation. The pure-Ruby method implementations may
  # perform differently.
  #
  # Space Requirements
  # ------------------
  #
  # TODO
  #
  # http://en.wikipedia.org/wiki/Set_(computer_science)
  class Set < Struct
    include Enumerable
    include Inspectable

    ##
    # Constructs a new set containing the given `elements`.
    #
    # @example Constructing a new set
    #   Set[id1, id2, id3]
    #
    # @param  [Array<Identifier, #to_id>] elements
    #   the initial elements in the set
    # @return [Set]
    def self.[](*elements)
      self.new(elements)
    end

    ##
    # Initializes a new set containing the given `elements`.
    #
    # @example Constructing a new set
    #   Set.new([id1, id2, id3])
    #
    # @param  [Enumerable<Identifier, #to_id>] elements
    #   the initial elements in the set
    # @yield  [set]
    # @yieldparam  [Set] `self`
    # @yieldreturn [void] ignored
    def initialize(elements = [], &block)
      @elements = {}
      elements.each do |element|
        @elements[element.to_id] ||= true
      end

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Initializes a set cloned from `original`.
    #
    # @param  [Set] original
    # @return [void]
    def initialize_copy(original)
      @elements = original.instance_variable_get(:@elements).clone
    end

    ##
    # Prevents further modifications to this set.
    #
    # @return [void] `self`
    def freeze
      elements.freeze
      super
    end

    ##
    # @private
    attr_reader :elements

    ##
    # Returns `true` if this set contains no elements.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      elements.empty?
    end

    ##
    # Returns the number of elements in this set.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @return [Integer] zero or a positive integer
    def cardinality
      elements.size
    end
    alias_method :size,   :cardinality
    alias_method :length, :cardinality

    ##
    # Counts elements in this set.
    #
    # @overload count
    #   Returns the number of elements in this set.
    #   
    #   The time complexity of this operation is `O(1)`.
    #   
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(id)
    #   Returns `1` if this set contains the identifier `id`, and `0`
    #   otherwise.
    #   
    #   @param  [Identifier, #to_id] id
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(&block)
    #   Returns the number of matching identifiers as determined by the
    #   given `block`.
    #   
    #   The time complexity of this operation is `O(n)`, with `n` being the
    #   cardinality of the set.
    #   
    #   @yield  [id]
    #     each identifier in this set
    #   @yieldparam  [Identifier] id
    #   @yieldreturn [Boolean] `true` or `false`
    #   @return [Integer] zero or a positive integer
    #
    # @return [Integer] zero or a positive integer
    def count(*args, &block)
      case args.size
        when 0 then block_given? ? super : cardinality
        when 1 then case
          when block_given? then super
          else has_identifier?((id = args.first).to_id) ? 1 : 0
        end
        else raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
      end
    end

    ##
    # Returns `true` if this set contains the identifier `id`.
    #
    # @param  [Identifier, #to_id] id
    # @return [Boolean] `true` or `false`
    def has_identifier?(id)
      elements.has_key?(id.to_id)
    end
    alias_method :has_id?,  :has_identifier?
    alias_method :has_key?, :has_identifier?
    alias_method :include?, :has_identifier?
    alias_method :member?,  :has_identifier?

    ##
    # Enumerates each identifier in this set.
    #
    # The identifiers are yielded in lexical order.
    #
    # @example
    #   set.each_identifier do |id|
    #     puts id.to_s
    #   end
    #
    # @yield  [id]
    #   each identifier in this set
    # @yieldparam  [Identifier] id
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    def each_identifier(&block)
      elements.keys.sort.each(&block) if block_given?
      enum_for(:each_identifier)
    end
    alias_method :each, :each_identifier

    ##
    # Returns `true` if this set is equal to the given `other` set.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def ==(other)
      return true if self.equal?(other)
      case other
        when Set
          cardinality.eql?(other.cardinality) && elements.eql?(other.elements)
        when Enumerable
          cardinality.eql?(other.count) && other.all? { |id| has_identifier?(id) }
        else false
      end
    end

    ##
    # Returns `true` if this set is identical to the given `other` set.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      return true if self.equal?(other)
      case other
        when Set
          self == other
        else false
      end
    end

    ##
    # Returns the hash code for this set.
    #
    # @return [Fixnum]
    def hash
      elements.hash
    end

    ##
    # Inserts the given identifier `id` into this set.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the set is frozen
    def insert(id)
      raise TypeError, "can't modify frozen set" if frozen?
      elements[id.to_id] ||= true
      self
    end
    alias_method :add, :insert
    alias_method :<<, :insert

    ##
    # Removes the given identifier `id` from this set.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the set is frozen
    def delete(id)
      raise TypeError, "can't modify frozen set" if frozen?
      elements.delete(id.to_id)
      self
    end
    alias_method :remove, :delete

    ##
    # Removes all elements from this set.
    #
    # @return [void] `self`
    # @raise  [TypeError] if the set is frozen
    def clear!
      raise TypeError, "can't modify frozen set" if frozen?
      elements.clear
      self
    end
    alias_method :clear, :clear!

    ##
    # Returns a new set containing all identifiers from both this set and
    # the given `other` set.
    #
    # @param  [Set, #each] other
    # @return [Set]
    def merge(other)
      dup.merge!(other)
    end

    ##
    # Merges all the identifiers from the given `other` set into this set.
    #
    # @param  [Set, #each] other
    # @return [void] `self`
    # @raise  [TypeError] if the set is frozen
    def merge!(other)
      raise TypeError, "can't modify frozen set" if frozen?
      case other
        when Set
          elements.merge!(other.elements)
        when Enumerable
          other.each { |id| insert(id) }
        else raise ArgumentError, "expected Enumerable, but got #{other.inspect}"
      end
      self
    end

    ##
    # Returns `self`.
    #
    # @return [Set] `self`
    def to_set
      self
    end

    ##
    # Returns a list of the elements in this set.
    #
    # Elements are returned in lexical order.
    #
    # @return [List]
    def to_list
      List.new(to_a)
    end

    ##
    # Returns a filter for recognizing the elements in this set.
    #
    # The filter capacity will be set equal to the set cardinality.
    #
    # @return [Filter]
    def to_filter
      Filter.for(elements.keys)
    end

    ##
    # Returns an array of the elements in this set.
    #
    # Elements are returned in lexical order.
    #
    # @return [Array]
    def to_a
      elements.keys.sort
    end

    ##
    # Returns a developer-friendly representation of this set.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x>", self.class.name, __id__) # TODO: improve this
    end

    # Load optimized method implementations when available:
    #send(:include, Bitcache::FFI::Set) if defined?(Bitcache::FFI::Set)
  end # Set
end # Bitcache
