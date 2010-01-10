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
    end # module Matchers
  end # module Spec
end # module Bitcache
