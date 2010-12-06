module Bitcache
  ##
  # An ordered list of Bitcache identifiers.
  class List < Struct
    include Enumerable
    include Inspectable

    ##
    # Constructs a new list containing the given `elements`.
    #
    # @example Constructing a new list
    #   List[id1, id2, id3]
    #
    # @param  [Array<Identifier, #to_id>] elements
    #   the initial elements of the list
    # @return [List]
    def self.[](*elements)
      self.new(elements)
    end

    ##
    # Initializes a new list containing the given `elements`.
    #
    # @example Constructing a new list
    #   List.new([id1, id2, id3])
    #
    # @param  [Enumerable<Identifier, #to_id>] elements
    #   the initial elements of the list
    # @yield  [list]
    # @yieldparam  [List] `self`
    # @yieldreturn [void] ignored
    def initialize(elements = [], &block)
      @elements = case elements
        when List  then elements.to_a
        when Array then elements.dup.map!(&:to_id)
        else elements.each.to_a.map!(&:to_id)
      end

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Initializes a list cloned from `original`.
    #
    # @param  [List] original
    # @return [void]
    def initialize_copy(original)
      @elements = original.instance_variable_get(:@elements).clone
    end

    ##
    # Prevents further modifications to this list.
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
    # Returns `true` if this list contains no elements.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      elements.empty?
    end

    ##
    # Returns the number of elements in this list.
    #
    # @return [Integer] zero or a positive integer
    def length
      elements.size
    end
    alias_method :size, :length

    ##
    # Counts elements in this list.
    #
    # @overload count
    #   Returns the number of elements in this list.
    #   
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(id)
    #   Returns the number of occurrences of the identifier `id` as an
    #   element of this list.
    #   
    #   @param  [Identifier, #to_id] id
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(&block)
    #   Returns the number of matching identifiers as determined by the
    #   given `block`.
    #   
    #   @yield  [id]
    #     each identifier in this list
    #   @yieldparam  [Identifier] id
    #   @yieldreturn [Boolean] `true` or `false`
    #   @return [Integer] zero or a positive integer
    #
    # @return [Integer] zero or a positive integer
    def count(*args, &block)
      case args.size
        when 0 then super
        when 1 then super(args.first.to_id, &block)
        else raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
      end
    end

    ##
    # Returns `self`.
    #
    # @return [List] `self`
    def to_list
      self
    end

    ##
    # Returns a set of the unique elements in this list.
    #
    # Duplicate elements are discarded.
    #
    # @return [Set]
    def to_set
      Set.new(elements)
    end

    ##
    # Returns an array of the elements in this list.
    #
    # Element order is preserved.
    #
    # @return [Array]
    def to_a
      elements.dup
    end

    ##
    # Returns a developer-friendly representation of this list.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x[%s]>", self.class.name, __id__, elements.map(&:to_s).join(', '))
    end

    # Load optimized method implementations when available:
    send(:include, Bitcache::FFI::List) if defined?(Bitcache::FFI::List)
  end # List
end # Bitcache
