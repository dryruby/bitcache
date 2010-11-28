require 'ffi' # @see http://rubygems.org/gems/ffi

module Bitcache
  ##
  # A foreign-function interface (FFI) to `libbitcache`.
  #
  # @see https://github.com/ffi/ffi
  module FFI
    extend ::FFI::Library
    ffi_lib const_defined?(:LIBBITCACHE) ? LIBBITCACHE : 'libbitcache'

    ##
    # Returns the installed `libbitcache` version number.
    #
    # @example
    #   Bitcache::FFI.version  #=> "0.0.1"
    #
    # @return [String] an "x.y.z" version string
    def version
      bitcache_version_string.freeze
    end
    module_function :version

    ##
    # An FFI wrapper for the `bitcache_id` data structure.
    #
    # @see Bitcache::Identifier
    class Identifier < ::FFI::Struct
      layout :type, :int
      # TODO: wrap the `bitcache_id` data structure.
    end # Identifier

    ##
    # An FFI wrapper for the `bitcache_list` data structure.
    #
    # @see Bitcache::List
    class List < ::FFI::Struct
      layout :data, :pointer,
             :next, :pointer
      # TODO: wrap the `bitcache_list` data structure.
    end # List

    ##
    # An FFI wrapper for the `bitcache_set` data structure.
    #
    # @see Bitcache::Set
    class Set < ::FFI::Struct
      # TODO: wrap the `bitcache_set` data structure.
    end # Set

    ##
    # An FFI wrapper for the `bitcache_queue` data structure.
    #
    # @see Bitcache::Queue
    class Queue < ::FFI::Struct
      # TODO: wrap the `bitcache_queue` data structure.
    end # Queue

    ##
    # An FFI wrapper for the `bitcache_stream` data structure.
    #
    # @see Bitcache::Stream
    class Stream < ::FFI::Struct
      # TODO: wrap the `bitcache_stream` data structure.
    end # Stream

    attach_variable :bitcache_version_string, :string
  end # FFI
end # Bitcache
