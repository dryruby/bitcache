require 'spec' # @see http://rubygems.org/gems/rspec

module Bitcache
  ##
  # Bitcache extensions for RSpec.
  #
  # @see http://rspec.info/
  module Spec
    ##
    # Bitcache matchers for RSpec.
    #
    # @see http://rspec.rubyforge.org/rspec/1.3.0/classes/Spec/Matchers.html
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
        match do |adapter|
          adapter.is_a?(Bitcache::Adapter)
        end
      end

      define :be_a_repository do
        match do |repository|
          repository.is_a?(Bitcache::Repository)
        end
      end

      define :be_an_identifier do
        match do |id|
          id.is_a?(Bitcache::FFI::Identifier) # FIXME
        end
      end

      define :be_an_index do
        match do |index|
          index.is_a?(Bitcache::FFI::Index) # FIXME
        end
      end

      define :be_a_list do
        match do |list|
          list.is_a?(Bitcache::FFI::List) # FIXME
        end
      end

      define :be_a_queue do
        match do |queue|
          queue.is_a?(Bitcache::FFI::Queue) # FIXME
        end
      end

      define :be_a_set do
        match do |set|
          set.is_a?(Bitcache::FFI::Set) # FIXME
        end
      end

      define :be_a_stream do |id, data, size|
        match do |stream|
          stream.should be_a(Bitcache::FFI::Stream) # FIXME
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
    end # Matchers
  end # Spec
end # Bitcache
