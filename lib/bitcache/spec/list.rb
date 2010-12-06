require 'bitcache/spec'

share_as :Bitcache_List do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @id0 = Bitcache::Identifier.new("\x00" * 16)
    @id1 = Bitcache::Identifier.new("\x01" * 16)
    @id2 = Bitcache::Identifier.new("\x02" * 16)
    @list = @class.new([@id0, @id1, @id2])
  end

  describe "List[]" do
    it "returns a List" do
      @class[@id0, @id1, @id2].should be_a List
    end
  end

  describe "List#clone" do
    it "returns a List" do
      @list.clone.should be_a List
    end

    it "returns an identical copy of the list" do
      @list.clone.to_a.should eql @list.to_a
    end
  end

  describe "List#dup" do
    it "returns a List" do
      @list.dup.should be_a List
    end

    it "returns an identical copy of the list" do
      @list.dup.to_a.should eql @list.to_a
    end
  end

  describe "List#freeze" do
    it "freezes the list" do
      @list.should_not be_frozen
      @list.freeze
      @list.should be_frozen
    end

    it "returns self" do
      @list.freeze.should equal @list
    end
  end

  describe "List#to_list" do
    it "returns self" do
      @list.to_list.should equal @list
    end
  end

  describe "List#to_set" do
    it "returns a Set" do
      @list.to_set.should be_a Set
    end

    it "returns an empty Set if the list is empty" do
      List[].to_set.should eql Set[]
    end

    it "returns a Set containing all elements in the list" do
      set = @list.to_set
      set.should include @id0
      set.should include @id1
      set.should include @id2
    end

    it "returns a Set of equal cardinality if the list has no duplicate elements" do
      List[@id1, @id2].to_set.size.should eql 2
    end

    it "returns a Set of lesser cardinality if the list has duplicate elements" do
      List[@id1, @id2, @id1, @id2].to_set.size.should eql 2
    end
  end

  describe "List#to_a" do
    it "returns an Array" do
      @list.to_a.should be_an Array
    end

    it "returns an Array of equal size" do
      @list.to_a.size.should eql @list.size
    end

    it "preserves element order" do
      # TODO
    end
  end

  describe "List#inspect" do
    it "returns a String" do
      @list.inspect.should be_a String
    end
  end
end
