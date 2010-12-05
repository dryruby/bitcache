require 'bitcache/spec'

share_as :Bitcache_Identifier do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @id = @class.new("\0" * 16)
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

  describe "Identifier#size" do
    it "returns an Integer" do
      @id.size.should be_an Integer
    end

    it "returns 16 for MD5 identifiers" do
      @class.parse('d41d8cd98f00b204e9800998ecf8427e').size.should eql 16
    end

    it "returns 20 for SHA-1 identifiers" do
      @class.parse('da39a3ee5e6b4b0d3255bfef95601890afd80709').size.should eql 20
    end

    it "returns 32 for SHA-256 identifiers" do
      @class.parse('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855').size.should eql 32
    end
  end

  describe "Identifier#zero?" do
    it "returns a Boolean" do
      @id.zero?.should be_a_boolean
    end

    it "returns true if all bytes in the identifier are zero" do
      @class.new("\x00" * 16).should be_zero
    end

    it "returns false otherwise" do
      @class.new("\xff" * 16).should_not be_zero
    end
  end

  describe "Identifier#clear!" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "fills the identifier with the byte value 0x00" do
      @id.clear!
      @id.should be_zero
    end

    it "retains the identifier size unchanged" do
      size = @id.size
      @id.clear!
      @id.size.should eql size
    end

    it "returns self" do
      @id.clear!.should equal @id
    end
  end

  describe "Identifier#fill!" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "fills the identifier with the given byte value" do
      @id.fill!(0xff)
      @id.each_byte.all? { |byte| byte.should eql 0xff }
      @id.fill!("\xAB")
      @id.each_byte.all? { |byte| byte.should eql 0xab }
    end

    it "retains the identifier size unchanged" do
      size = @id.size
      @id.fill!(0xff)
      @id.size.should eql size
    end

    it "returns self" do
      @id.fill!(0xff).should equal @id
    end
  end

  describe "Identifier#[]" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "returns an Integer" do
      @id[0].should be_an Integer
    end

    it "returns the byte at the given index" do
      @id[0].should  eql 0xd4
      @id[7].should  eql 0x04
      @id[15].should eql 0x7e
    end

    it "returns nil if the index is out of bounds" do
      @id[100].should be_nil
    end
  end

  describe "Identifier#[]=" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "raises an IndexError if the index is out of bounds" do
      lambda { (@id[100] = 0xff) }.should raise_error IndexError
    end

    it "replaces the byte at the given index" do
      @id[0].should eql 0xd4
      @id[0] = 0xff
      @id[0].should eql 0xff
    end

    it "returns an Integer" do
      (@id[0] = 0xff).should be_an Integer
    end

    it "returns the new byte at the given index" do
      @id[0].should eql 0xd4
      (@id[0] = 0xff).should eql 0xff
    end
  end

  describe "Identifier#[]=(index, String)" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "replaces the byte at the given index" do
      @id[0].should eql 0xd4
      @id[0] = ?b.chr
      @id[0].should eql ?b.ord
    end
  end

  describe "Identifier#each_byte" do
    before :each do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "returns an Enumerator" do
      @id.each_byte.should be_an Enumerator
    end

    it "yields each byte in the identifier" do
      @id.each_byte.to_a.should eql [0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04, 0xe9, 0x80, 0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e]
    end
  end

  describe "Identifier#<=>" do
    it "returns an Integer" do
      (@id <=> @id).should be_an Integer
    end

    it "returns zero if the identifiers are the same object" do
      (@id <=> @id).should eql 0
    end

    it "returns zero if the identifiers are equal" do
      id1, id2 = @class.new("\1" * 16), @class.new("\1" * 16)
      (id1 <=> id2).should eql 0
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

  describe "Identifier#eql?" do
    it "returns a Boolean" do
      @id.eql?(@id).should be_a_boolean
    end

    it "returns true if the identifiers are the same object" do
      @id.should eql @id
    end

    it "returns true if the identifiers are equal" do
      id1, id2 = @class.new("\1" * 16), @class.new("\1" * 16)
      id1.should eql id2
    end

    it "returns false if the identifiers are not equal" do
      id1, id2 = @class.new("\1" * 16), @class.new("\2" * 16)
      id1.should_not eql id2
    end

    it "returns false if the identifiers are incompatible" do
      md5  = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
      sha1 = @class.parse('da39a3ee5e6b4b0d3255bfef95601890afd80709')
      md5.should_not eql sha1
    end
  end

  describe "Identifier#hash" do
    it "returns a Fixnum" do
      @id.hash.should be_a Fixnum
    end

    it "returns zero as the minimum value" do
      @id.clear!
      @id.hash.should eql 0
    end

    it "returns 0xffffffff as the maximum value" do
      @id.fill!(0xff)
      @id.hash.should eql 0xffffffff
    end

    it "returns the 32 most-significant bits in big-endian order" do
      @id = @class.parse('d41d8cd98f00b204e9800998ecf8427e')
      @id.hash.should eql 0xd41d8cd9
    end
  end

  describe "Identifier#to_i" do
    it "returns an Integer" do
      @id.to_i.should be_an Integer
    end

    it "returns the integer representation of the identifier" do
      @id = @class.parse(s = 'd41d8cd98f00b204e9800998ecf8427e')
      @id.to_i.should eql 0xd41d8cd98f00b204e9800998ecf8427e
    end
  end

  describe "Identifier#to_a" do
    it "returns an Array" do
      @id.to_a.should be_an Array
    end

    it "returns the byte array representation of the identifier" do
      @id = @class.parse(s = 'd41d8cd98f00b204e9800998ecf8427e')
      @id.to_a.should eql [0xd4, 0x1d, 0x8c, 0xd9, 0x8f, 0x00, 0xb2, 0x04, 0xe9, 0x80, 0x09, 0x98, 0xec, 0xf8, 0x42, 0x7e]
    end
  end

  describe "Identifier#to_str" do
    it "returns a String" do
      @id.to_str.should be_a String
    end

    it "returns the binary string representation of the identifier" do
      @id = @class.parse(s = 'd41d8cd98f00b204e9800998ecf8427e')
      @id.to_str.should eql "\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98\xec\xf8\x42\x7e"
    end
  end

  describe "Identifier#to_s" do
    it "returns a String" do
      @id.to_s.should be_a String
    end

    it "returns the hexadecimal string representation of the identifier" do
      @id = @class.parse(s = 'd41d8cd98f00b204e9800998ecf8427e')
      @id.to_s.should eql s
    end
  end

  describe "Identifier#to_base64" do
    it "returns a String" do
      @id.to_base64.should be_a String
    end

    it "returns the Base64 string representation of the identifier" do
      @id.clear!
      @id.to_base64.should eql 'AAAAAAAAAAAAAAAAAAAAAA=='
      @id = @class.parse(s = 'd41d8cd98f00b204e9800998ecf8427e')
      @id.to_base64.should eql '1B2M2Y8AsgTpgAmY7PhCfg=='
    end
  end

  describe "Identifier#inspect" do
    it "returns a String" do
      @id.inspect.should be_a String
    end
  end
end
