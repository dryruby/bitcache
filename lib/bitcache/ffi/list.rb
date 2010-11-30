module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_list` data structure.
  #
  # @see Bitcache::List
  class List < ::FFI::Struct
    layout :data, :pointer,
           :next, :pointer
    # TODO: wrap the `bitcache_list` data structure.
  end # List
end # Bitcache::FFI
