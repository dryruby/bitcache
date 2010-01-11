require 'spec'

module Bitcache
  ##
  # Bitcache extensions for RSpec.
  #
  # @see http://rspec.info/
  module Spec
    ##
    # Bitcache matchers for RSpec.
    #
    # @see http://rspec.rubyforge.org/rspec/1.2.9/classes/Spec/Matchers.html
    module Matchers
      ##
      # Defines a new RSpec matcher.
      #
      # @param  [Symbol] name
      # @return [void]
      def self.define(name, &declarations)
        define_method name do |*expected|
          ::Spec::Matchers::Matcher.new(name, *expected, &declarations)
        end
      end

      define :be_an_adapter do
        match do |value|
          value.kind_of?(Bitcache::Adapter)
        end
      end

      define :be_a_repository do
        match do |value|
          value.kind_of?(Bitcache::Repository)
        end
      end

      define :be_a_bitstream do
        match do |value|
          value.kind_of?(Bitcache::Stream) || value.is_a?(String) # FIXME
        end
      end

      define :have_id do |stream|
        match do |repository|
          repository.has_id?(stream)
        end
      end

      define :have_bitstream do |stream|
        match do |repository|
          repository.has_stream?(stream)
        end
      end
    end # module Matchers
  end # module Spec
end # module Bitcache
