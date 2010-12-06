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

    # Load optimized method implementations when available:
    include Bitcache::FFI::Set if defined?(Bitcache::FFI::Set)
  end # Set
end # Bitcache
