require 'bitcache/spec'

share_as :Bitcache_Block do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @block = @class.new
  end

  describe "Block.new" do
    it "returns a new Block" do
      @class.new.should be_a @class
    end

    it "yields self if passed a block" do
      yielded = nil
      block = @class.new { |block| yielded = block }
      yielded.should be_a Block
      yielded.should equal block
    end
  end

  describe "Block#id" do
    it "returns an Identifier" do
      @block.id.should be_an Identifier
    end
  end

  describe "Block#size" do
    it "returns an Integer" do
      @block.size.should be_an Integer
    end
  end

  describe "Block#data" do
    it "returns an IO stream" do
      [IO, StringIO].should include @block.data.class
    end
  end
end
