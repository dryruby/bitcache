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
    # @private
    attr_reader :elements

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
