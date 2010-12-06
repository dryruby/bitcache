module Bitcache::FFI
  ##
  # An FFI wrapper for the `bitcache_set` data structure.
  #
  # @see Bitcache::Set
  module Set
    LAYOUT = [:root, :pointer,
              :filter, :pointer]

    ##
    # @private
    def self.included(struct)
      struct.send(:include, Bitcache::FFI)
      struct.layout(*LAYOUT)
    end

    # TODO: wrap the `bitcache_set` data structure.
  end # Set
end # Bitcache::FFI
