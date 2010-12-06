module Bitcache
  ##
  # An ordered list of Bitcache identifiers.
  #
  # Note: all time complexity information given for methods refers to the
  # `libbitcache` implementation. The pure-Ruby method implementations may
  # perform differently.
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
    # The time complexity of this operation is `O(1)`.
    #
    # @return [Boolean] `true` or `false`
    def empty?
      elements.empty?
    end

    ##
    # Returns the number of elements in this list.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
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
    #   The time complexity of this operation is `O(n)`, with `n` being the
    #   length of the list.
    #   
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(id)
    #   Returns the number of occurrences of the identifier `id` as an
    #   element of this list.
    #   
    #   The time complexity of this operation is `O(n)`, with `n` being the
    #   length of the list.
    #   
    #   @param  [Identifier, #to_id] id
    #   @return [Integer] zero or a positive integer
    #
    # @overload count(&block)
    #   Returns the number of matching identifiers as determined by the
    #   given `block`.
    #   
    #   The time complexity of this operation is `O(n)`, with `n` being the
    #   length of the list.
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
        when 0 then block_given? ? super : length
        when 1 then super(args.first.to_id, &block)
        else raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
      end
    end

    ##
    # Returns `true` if this list contains the identifier `id`.
    #
    # The time complexity of this operation is `O(n)` in the worst case,
    # with `n` being the length of the list.
    #
    # @param  [Identifier, #to_id] id
    # @return [Boolean] `true` or `false`
    def has_identifier?(id)
      elements.include?(id.to_id)
    end
    alias_method :has_id?,  :has_identifier?
    alias_method :include?, :has_identifier?
    alias_method :member?,  :has_identifier?

    ##
    # Enumerates each identifier in this list.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
    #
    # @example
    #   list.each_identifier do |id|
    #     puts id.to_s
    #   end
    #
    # @yield  [id]
    #   each identifier in this list
    # @yieldparam  [Identifier] id
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    def each_identifier(&block)
      elements.each(&block) if block_given?
      enum_for(:each_identifier)
    end
    alias_method :each, :each_identifier

    ##
    # Returns `true` if this list is equal to the given `other` list.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def ==(other)
      return true if self.equal?(other)
      case other
        when List
          length.eql?(other.length) && elements.eql?(other.elements)
        when Array
          length.eql?(other.length) && elements.eql?(other)
        when Enumerable
          length.eql?(other.count) && elements.eql?(other.to_a)
        else false
      end
    end

    ##
    # Returns `true` if this list is identical to the given `other` list.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      return true if self.equal?(other)
      case other
        when List
          self == other
        else false
      end
    end

    ##
    # Returns the hash code for this list.
    #
    # @return [Fixnum]
    def hash
      elements.hash
    end

    ##
    # Inserts the given identifier `id` into this list.
    #
    # The identifier is inserted as the first element of the list.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def insert(id)
      raise TypeError, "can't modify frozen list" if frozen?
      elements.unshift(id.to_id)
      self
    end
    alias_method :add, :insert
    alias_method :<<, :insert

    ##
    # Removes the given identifier `id` from this list.
    #
    # The time complexity of this operation is `O(n)` in the worst case,
    # with `n` being the length of the list.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def delete(id)
      raise TypeError, "can't modify frozen list" if frozen?
      elements.delete(id.to_id) # FIXME: only delete the first occurrence
      self
    end
    alias_method :remove, :delete

    ##
    # Removes all elements from this list.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
    #
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def clear!
      raise TypeError, "can't modify frozen list" if frozen?
      elements.clear
      self
    end
    alias_method :clear, :clear!

    ##
    # Prepends the given identifier `id` as the first element of this list.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def prepend(id)
      insert(id)
    end

    ##
    # Appends the given identifier `id` as the last element of this list.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
    #
    # @param  [Identifier, #to_id] id
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def append(id)
      raise TypeError, "can't modify frozen list" if frozen?
      elements.push(id.to_id)
      self
    end

    ##
    # Returns a new list containing the elements of this list in reverse
    # order.
    #
    # The time complexity of this operation is `O(2n)`, with `n` being the
    # length of the list.
    #
    # @return [List] a new list
    def reverse
      dup.reverse!
    end

    ##
    # Reverses the element order of this list in place.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
    #
    # @return [void] `self`
    # @raise  [TypeError] if the list is frozen
    def reverse!
      raise TypeError, "can't modify frozen list" if frozen?
      elements.reverse!
      self
    end

    ##
    # Returns the first identifier in this list, or `nil` if the list is
    # empty.
    #
    # The time complexity of this operation is `O(1)`.
    #
    # @return [Identifier] an identifier or `nil`
    def first
      elements.first
    end

    ##
    # Returns the last identifier in this list, or `nil` if the list is
    # empty.
    #
    # The time complexity of this operation is `O(n)`, with `n` being the
    # length of the list.
    #
    # @return [Identifier] an identifier or `nil`
    def last
      elements.last
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
