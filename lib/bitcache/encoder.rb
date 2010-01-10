module Bitcache
  ##
  class Encoder
    ##
    # Returns an encoder class identified by `name`.
    #
    # @param  [Symbol, #to_sym] name
    # @return [Class]
    def self.for(name)
      case (name.to_sym rescue nil)
        when :base16 then Base16
        when :base62 then Base62
        when :base94 then Base94
      end
    end

    ##
    # Returns an encoder class identified by `name`.
    #
    # @param  [Symbol, #to_sym] name
    # @return [Class]
    def self.[](name)
      self.for(name)
    end

    private_class_method :new

    ##
    class Base < Encoder
      ##
      # Returns the numeric base for this encoder class.
      #
      # @return [Integer]
      def self.base
        digits.size
      end

      ##
      # Returns the array of digits for this encoder class.
      #
      # @return [Array<Integer>]
      def self.digits
        const_get(:DIGITS)
      end

      ##
      # Encodes a number using this encoder class.
      #
      # @param  [Integer] number
      # @return [String]
      def self.encode(number)
        result = []
        while number > 0
          number, digit = number.divmod(base)
          result.unshift digits[digit].chr
        end
        result.empty? ? digits.first.chr : result.join('')
      end

      ##
      # Decodes a string using this encoder class.
      #
      # @param  [String] string
      # @return [Integer]
      def self.decode(string)
        result, index = 0, 0
        string.reverse.each_byte do |char|
          result += digits.index(char) * (base ** index)
          index  += 1
        end
        result
      end
    end

    ##
    # Base-16 (hexadecimal) encoder.
    #
    # @see Base
    # @see http://en.wikipedia.org/wiki/Hexadecimal
    class Base16 < Base
      DIGITS = (?0..?9).to_a + (?a..?f).to_a
    end

    ##
    # Base-62 encoder.
    #
    # @see Base
    # @see http://en.wikipedia.org/wiki/Base_62
    class Base62 < Base
      DIGITS = (?0..?9).to_a + (?A..?Z).to_a + (?a..?z).to_a
    end

    ##
    # Base-94 encoder.
    #
    # @see Base
    class Base94 < Base
      DIGITS = (33..126).to_a
    end
  end
end
