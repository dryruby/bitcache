module Bitcache
  ##
  # A Bitcache identifier.
  class Identifier
    ##
    # Initializes an identifier with the given `digest`.
    #
    # If no `digest` argumnt is provided, the identifier will be initialized
    # to all zeroes.
    #
    # @example
    #   Identifier.new("\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98e\xcf8\x42\x7e")
    #
    # @param  [String, #to_str] digest
    #   the identifier message digest
    def initialize(digest = nil)
      @digest = digest ? digest.to_str : "\0" * 20
    end

    ##
    # The message digest as a binary string.
    #
    # @return [String]
    attr_reader :digest
  end # Identifier
end # Bitcache
