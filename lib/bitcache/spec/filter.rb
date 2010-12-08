require 'bitcache/spec'

share_as :Bitcache_Filter do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @filter = @class.new
  end

  describe "Filter.for(enum)" do
    it "returns a Filter" do
      # TODO
    end
  end

  describe "Filter.new" do
    it "returns a Filter" do
      @class.new.should be_a Filter
    end
  end

  describe "Filter.new(Integer)" do
    it "returns a Filter" do
      @class.new(1024).should be_a Filter
    end
  end

  describe "Filter.new(String)" do
    it "returns a Filter" do
      @class.new("\0" * 128).should be_a Filter
    end
  end

  describe "Filter#clone" do
    it "returns a Filter" do
      @filter.clone.should be_a Filter
    end

    it "returns an identical copy of the filter" do
      @filter.clone.bitmap.should_not equal @filter.bitmap
      @filter.clone.bitmap.should eql @filter.bitmap
    end
  end

  describe "Filter#dup" do
    it "returns a Filter" do
      @filter.dup.should be_a Filter
    end

    it "returns an identical copy of the filter" do
      @filter.dup.bitmap.should_not equal @filter.bitmap
      @filter.dup.bitmap.should eql @filter.bitmap
    end
  end

  describe "Filter#freeze" do
    it "freezes the filter" do
      @filter.should_not be_frozen
      @filter.freeze
      @filter.should be_frozen
    end

    it "returns self" do
      @filter.freeze.should equal @filter
    end
  end

  describe "Filter#size" do
    it "returns an Integer" do
      @filter.size.should be_an Integer
    end

    it "returns the byte size of the filter" do
      @class.new(128).size.should eql 128
    end
  end

  describe "Filter#empty?" do
    it "returns a Boolean" do
      @filter.empty?.should be_a_boolean
    end

    it "returns true if no elements have been inserted into the filter" do
      @class.new.should be_empty
    end

    it "returns false if any elements have been inserted into the filter" do
      # TODO
    end
  end

  describe "Filter#space" do
    it "returns a Float" do
      @filter.space.should be_a Float
    end

    it "returns 1.0 if the filter is empty" do
      @filter.space.should eql 1.0
    end

    it "returns < 1.0 if the filter is not empty" do
      1000.times do |n|
        @filter.insert(Bitcache::Identifier.for(n.to_s))
      end
      @filter.space.should < 1.0
    end
  end

  describe "Filter#[]" do
    before :each do
      @filter = @class.new(0b10101010.chr)
    end

    it "returns an Boolean" do
      @filter[0].should be_a_boolean
    end

    it "returns the bit at the given index" do
      @filter[0].should eql false
      @filter[1].should eql true
      @filter[2].should eql false
      @filter[3].should eql true
      @filter[4].should eql false
      @filter[5].should eql true
      @filter[6].should eql false
      @filter[7].should eql true
    end

    it "returns nil if the index is out of bounds" do
      @filter[8].should be_nil
    end
  end

  describe "Filter#[]=" do
    before :each do
      @filter = @class.new(0b10101010.chr)
    end

    it "raises a TypeError if the filter is frozen" do
      lambda { @filter.freeze[0] = true }.should raise_error TypeError
    end

    it "raises an IndexError if the index is out of bounds" do
      lambda { @filter[100] = true }.should raise_error IndexError
    end

    it "updates the bit at the given index" do
      @filter[0].should eql false
      @filter[0] = true
      @filter[0].should eql true
      @filter[0] = true
      @filter[0].should eql true
      @filter[0] = false
      @filter[0].should eql false
      @filter[0] = false
      @filter[0].should eql false
    end
  end

  describe "Filter#has_identifier?" do
    before :each do
      @filter = @class.new
      @md5    = Bitcache::Identifier.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "returns a Boolean" do
      @filter.has_identifier?(@md5).should be_a_boolean
    end

    it "returns true if the filter contains the identifier" do
      @filter.should_not include @md5
      @filter.insert(@md5)
      @filter.should include @md5
    end

    it "returns false if the filter doesn't contain the identifier" do
      @filter.should_not include @md5.dup.fill(0xff)
    end

    it "returns false positives occasionally, but never false negatives" do
      # TODO
    end
  end

  describe "Filter#==" do
    it "returns a Boolean" do
      (@filter == @filter).should be_a_boolean
    end

    it "returns true if the filters are the same object" do
      @filter.should eql @filter
    end

    it "returns true if the filters are equal" do
      filter1, filter2 = @class.new("\1" * 16), @class.new("\1" * 16)
      filter1.should == filter2
    end

    it "returns false if the filters are not equal" do
      filter1, filter2 = @class.new("\1" * 16), @class.new("\2" * 16)
      filter1.should_not eql filter2
    end

    it "returns true if a given byte string is equal to the filter" do
      @class.new("\1" * 16).should == "\1" * 16
    end
  end

  describe "Filter#eql?" do
    it "returns a Boolean" do
      @filter.eql?(@filter).should be_a_boolean
    end

    it "returns true if the filters are the same object" do
      @filter.should eql @filter
    end

    it "returns true if the filters are equal" do
      filter1, filter2 = @class.new("\1" * 16), @class.new("\1" * 16)
      filter1.should eql filter2
    end

    it "returns false if the filters are not equal" do
      filter1, filter2 = @class.new("\1" * 16), @class.new("\2" * 16)
      filter1.should_not eql filter2
    end
  end

  describe "Filter#hash" do
    it "returns a Fixnum" do
      @filter.hash.should be_a Fixnum
    end
  end

  describe "Filter#insert" do
    before :each do
      @filter = @class.new
      @md5    = Bitcache::Identifier.parse('d41d8cd98f00b204e9800998ecf8427e')
    end

    it "raises a TypeError if the filter is frozen" do
      lambda { @filter.freeze.insert(@md5) }.should raise_error TypeError
    end

    it "inserts the given identifier into the filter" do
      @filter.should be_empty
      @filter.insert(@md5)
      @filter.should_not be_empty
    end

    it "returns self" do
      @filter.insert(@md5).should equal @filter
    end
  end

  describe "Filter#clear" do
    it "raises a TypeError if the filter is frozen" do
      lambda { @filter.freeze.clear }.should raise_error TypeError
    end

    it "resets the filter back to the empty state" do
      1000.times do |n|
        @filter.insert(Bitcache::Identifier.for(n.to_s))
      end
      @filter.should_not be_empty
      @filter.clear
      @filter.should be_empty
    end

    it "returns self" do
      @filter.clear.should equal @filter
    end
  end

  describe "Filter#to_str" do
    it "returns a String" do
      @filter.to_str.should be_a String
    end
  end

  describe "Filter#to_s" do
    it "returns a String" do
      @filter.to_s.should be_a String
    end
  end

  describe "Filter#to_s(2)" do
    it "returns a String" do
      @filter.to_s(2).should be_a String
    end

    it "returns the binary string representation of the filter" do
      @filter = @class.new(n = 16)
      @filter.to_s(2).should have(n * 8).digits
      @filter.to_s(2).should eql ('0' * n * 8)
    end
  end

  describe "Filter#to_s(16)" do
    it "returns a String" do
      @filter.to_s(16).should be_a String
    end

    it "returns the hexadecimal string representation of the filter" do
      @filter = @class.new(n = 16)
      @filter.to_s(16).should have(n * 2).digits
      @filter.to_s(16).should eql ('0' * n * 2)
    end
  end

  describe "Filter#inspect" do
    it "returns a String" do
      @filter.inspect.should be_a String
    end
  end
end
