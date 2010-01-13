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

      define :be_inspectable do
        match do |value|
          value.should respond_to(:inspect)
          value.inspect.should be_a_kind_of(String)
          value.should respond_to(:inspect!)
          true
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

      define :be_a_stream do |id, data, size|
        match do |stream|
          stream.should be_a_kind_of(Bitcache::Stream)
          stream.id.should == id if id
          stream.data.should == data if data
          stream.size.should == (size || data.size) if size || data
          true
        end
      end

      define :have_id do |stream|
        match do |repository|
          repository.has_id?(stream)
        end
      end

      define :have_stream do |stream|
        match do |repository|
          repository.has_stream?(stream)
        end
      end
    end # module Matchers
  end # module Spec
end # module Bitcache
