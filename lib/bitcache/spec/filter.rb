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
end
