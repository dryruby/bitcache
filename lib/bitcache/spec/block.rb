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

  describe "Block#empty?" do
    it "returns a Boolean" do
      @block.empty?.should be_a_boolean
    end
  end

  describe "Block#nonzero?" do
    it "returns a Boolean" do
      @block.nonzero?.should be_a_boolean
    end
  end

  describe "Block#zero?" do
    it "returns a Boolean" do
      @block.zero?.should be_a_boolean
    end
  end

  describe "Block#==" do
    it "returns a Boolean" do
      (@block == @block).should be_a_boolean
    end
  end

  describe "Block#eql?" do
    it "returns a Boolean" do
      @block.eql?(@block).should be_a_boolean
    end
  end

  describe "Block#hash" do
    it "returns a Fixnum" do
      @block.hash.should be_a Fixnum
    end
  end

  describe "Block#pos" do
    it "returns an Integer" do
      @block.pos.should be_an Integer
    end
  end

  describe "Block#rewind" do
    it "returns zero" do
      @block.rewind.should be_zero
    end
  end

  describe "Block#seek" do
    it "returns zero" do
      @block.seek(0, IO::SEEK_SET).should be_zero
    end
  end

  describe "Block#[]" do
    it "returns an Integer" do
      @block[0].should be_an Integer
    end
  end

  describe "Block#read" do
    it "returns a String" do
      @block.read(1).should be_a String
    end
  end

  describe "Block#readbytes" do
    it "returns a String" do
      @block.readbytes(1).should be_a String
    end
  end

  describe "Block#each_byte" do
    it "returns an Enumerator" do
      @block.each_byte.should be_an Enumerator
    end

    it "yields Integer bytes" do
      @block.each_byte do |byte|
        byte.should be_an Integer
      end
    end
  end

  describe "Block#each_line" do
    it "returns an Enumerator" do
      @block.each_line.should be_an Enumerator
    end

    it "yields String lines" do
      @block.each_line do |line|
        line.should be_a String
      end
    end
  end

  describe "Block#to_io" do
    it "returns an IO stream" do
      [IO, StringIO].should include @block.to_io.class
    end
  end

  describe "Block#to_str" do
    it "returns a String" do
      @block.to_str.should be_a String
    end
  end

  describe "Block#to_s" do
    it "returns a String" do
      @block.to_s.should be_a String
    end
  end

  describe "Block#inspect" do
    it "returns a String" do
      @block.inspect.should be_a String
    end
  end
end
