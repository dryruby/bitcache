module Bitcache
  module Encodings
    class Base
      def self.base()   digits.size end
      def self.digits() const_get(:DIGITS) end

      def self.encode(number)
        result = []
        while number > 0
          number, digit = number.divmod(base)
          result.unshift digits[digit].chr
        end
        result.empty? ? digits.first.chr : result.join('')
      end

      def self.decode(string)
        result, index = 0, 0
        string.reverse.each_byte do |char|
          result += digits.index(char) * (base ** index)
          index  += 1
        end
        result
      end
    end

    class Base16 < Base
      DIGITS = (?0..?9).to_a + (?a..?f).to_a
    end

    class Base62 < Base
      DIGITS = (?0..?9).to_a + (?A..?Z).to_a + (?a..?z).to_a
    end

    class Base94 < Base
      DIGITS = (33..126).to_a
    end
  end
end
