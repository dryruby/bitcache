require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/id'

describe Bitcache::FFI::Identifier do
  before :all do
    @class = Bitcache::Identifier
    @class.send(:include, Bitcache::FFI::Identifier)
  end

  it_should_behave_like Bitcache_Identifier

  describe "Identifier#to_ptr" do
    it "returns a Pointer" do
      @id = @class.new("\0" * 16)
      @id.to_ptr.should be_an FFI::Pointer
    end
  end
end
