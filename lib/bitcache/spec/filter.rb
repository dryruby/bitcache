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
end
