module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_id` data structure.
  #
  # @see Bitcache::Identifier
  class Identifier < ::FFI::Struct
    layout :type, :int,
           :digest, [:byte, BITCACHE_ID_SIZE]
    # TODO: wrap the `bitcache_id` data structure.
  end # Identifier
end # Bitcache::FFI
