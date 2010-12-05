require 'bitcache/spec'

share_as :Bitcache_Identifier do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @id = @class.new
  end

  describe "Identifier.parse" do
    it "raises an ArgumentError if given invalid input" do
      lambda { @class.parse('00') }.should raise_error ArgumentError
      lambda { @class.parse('d41d8cd98f00b204e9800998ecf8427e012') }.should raise_error ArgumentError
    end
  end

  describe "Identifier.parse(md5_as_hex)" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "returns an identifier" do
      @id.should be_a @class
    end

    it "returns an MD5 identifier" do
      @id.should == "\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98\xec\xf8\x42\x7e"
    end
  end

  describe "Identifier.parse(sha1_as_hex)" do
    before :each do
      @id = @class.parse('da39a3ee5e6b4b0d3255bfef95601890afd80709')
    end

    it "returns an identifier" do
      @id.should be_a @class
    end

    it "returns a SHA-1 identifier" do
      @id.should == "\xda\x39\xa3\xee\x5e\x6b\x4b\x0d\x32\x55\xbf\xef\x95\x60\x18\x90\xaf\xd8\x07\x09"
    end
  end

  describe "Identifier.parse(sha256_as_hex)" do
    before :each do
      @id = @class.parse('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855')
    end

    it "returns an identifier" do
      @id.should be_a @class
    end

    it "returns a SHA-256 identifier" do
      @id.should == "\xe3\xb0\xc4\x42\x98\xfc\x1c\x14\x9a\xfb\xf4\xc8\x99\x6f\xb9\x24\x27\xae\x41\xe4\x64\x9b\x93\x4c\xa4\x95\x99\x1b\x78\x52\xb8\x55"
    end
  end

  describe "Identifier#digest" do
    it "returns a String" do
      @id.digest.should be_a String
    end
  end

  describe "Identifier#<=>" do
    it "returns an Integer" do
      (@id <=> @id).should be_an Integer
    end

    it "returns zero if the identifiers are equal" do
      (@id <=> @id).should eql 0
    end

    it "returns -1 or 1 if the identifiers are not equal" do
      id1, id2 = @class.new("\1" * 16), @class.new("\2" * 16)
      (id1 <=> id2).should eql -1
      (id2 <=> id1).should eql 1
    end

    it "returns nil if the identifiers are incompatible" do
      md5  = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
      sha1 = @class.parse('da39a3ee5e6b4b0d3255bfef95601890afd80709')
      (md5 <=> sha1).should be_nil
    end
  end

  describe "Identifier#zero?" do
    # TODO
  end

  describe "Identifier#size" do
    # TODO
  end

  describe "Identifier#each_byte" do
    # TODO
  end

  describe "Identifier#[]" do
    # TODO
  end

  describe "Identifier#[]=" do
    # TODO
  end

  describe "Identifier#clear!" do
    # TODO
  end

  describe "Identifier#fill!" do
    # TODO
  end

  describe "Identifier#hash" do
    # TODO
  end

  describe "Identifier#eql?" do
    # TODO
  end

  describe "Identifier#to_a" do
    # TODO
  end

  describe "Identifier#to_str" do
    # TODO
  end

  describe "Identifier#to_s" do
    # TODO
  end

  describe "Identifier#inspect" do
    # TODO
  end
end
