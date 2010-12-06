module Bitcache
  ##
  # A set of Bitcache identifiers.
  class Set < Struct
    include Enumerable
    include Inspectable

    ##
    # Initializes a new set with the given `elements`.
    #
    # @example Constructing a set
    #   Set.new([id1, id2, id3])
    #
    # @param  [Enumerable] elements
    #   the initial elements in the set
    def initialize(elements = [])
      @elements = {}
      elements.each do |element|
        @elements[element] ||= true
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
    # @return [Boolean] `true` or `false`
    def empty?
      elements.empty?
    end

    ##
    # Returns the number of elements in this set.
    #
    # @return [Integer]
    def size
      elements.size
    end
    alias_method :cardinality, :size
    alias_method :length, :size
    alias_method :count, :size

    ##
    # Inserts the given identifier `id` into this set.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
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
    def delete(id)
      raise TypeError, "can't modify frozen set" if frozen?
      elements.delete(id.to_id)
      self
    end
    alias_method :remove, :insert

    ##
    # Removes all elements from this set.
    #
    # @return [void] `self`
    def clear
      raise TypeError, "can't modify frozen set" if frozen?
      elements.clear
      self
    end
    alias_method :clear!, :clear

    ##
    # Returns `self`.
    #
    # @return [Set] `self`
    def to_set
      self
    end

    ##
    # Returns an array of the elements in this set.
    #
    # The array elements are returned in lexical order.
    #
    # @return [Array]
    def to_a
      elements.keys.sort
    end

    # Load optimized method implementations when available:
    include Bitcache::FFI::Set if defined?(Bitcache::FFI::Set)
  end # Set
end # Bitcache
