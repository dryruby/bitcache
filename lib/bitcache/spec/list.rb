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

  describe "List#empty?" do
    it "returns a Boolean" do
      @list.empty?.should be_a_boolean
    end

    it "returns true if the list contains no elements" do
      @class[].should be_empty
    end

    it "returns false if the list contains any elements" do
      @class[@id1].should_not be_empty
    end
  end

  describe "List#length" do
    it "returns an Integer" do
      @list.length.should be_an Integer
    end

    it "returns the length of the list" do
      @list.length.should eql 3
    end

    it "returns zero if the list is empty" do
      @class[].length.should be_zero
    end
  end

  describe "List#count" do
    it "returns an Integer" do
      @list.count.should be_an Integer
    end

    it "returns the length of the list" do
      @list.count.should eql 3
    end
  end

  describe "List#count(id)" do
    it "returns an Integer" do
      @list.count(@id1).should be_an Integer
    end

    it "returns >= 1 if the list contains the identifier" do
      List[@id1, @id2].count(@id1).should eql 1
      List[@id1, @id1].count(@id1).should eql 2
    end

    it "returns 0 if the list doesn't contain the identifier" do
      @list.count(@id0.dup.fill(0xff)).should eql 0
    end
  end

  describe "List#count(&block)" do
    it "returns an Integer" do
      @list.count { |id| }.should be_an Integer
    end

    it "returns the number of matching identifiers" do
      @list.count { |id| }.should be_zero
      @list.count { |id| id == @id1 }.should eql 1
    end
  end

  describe "List#has_identifier?" do
    it "returns a Boolean" do
      @list.has_identifier?(@id0).should be_a_boolean
    end

    it "returns true if the list contains the identifier" do
      @list.should include @id1
    end

    it "returns false if the list doesn't contain the identifier" do
      @list.should_not include @id0.dup.fill(0xff)
    end
  end

  describe "List#each_identifier" do
    it "returns an Enumerator" do
      @list.each_identifier.should be_an Enumerator
    end

    it "yields each identifier in the list" do
      @list.each_identifier.to_a.should eql [@id0, @id1, @id2]
    end
  end

  describe "List#==" do
    it "returns a Boolean" do
      (@list == @list).should be_a_boolean
    end

    it "returns true if the lists are the same object" do
      @list.should == @list
    end

    it "returns true if the lists are both empty" do
      list1, list2 = @class[], @class[]
      list1.should == list2
    end

    it "returns true if the lists are equal" do
      list1, list2 = @class[@id1, @id2], @class[@id1, @id2]
      list1.should == list2
    end

    it "returns false if the lists are not equal" do
      list1, list2 = @class[@id1, @id2], @class[@id2, @id1]
      list1.should_not == list2
    end
  end

  describe "List#eql?" do
    it "returns a Boolean" do
      @list.eql?(@list).should be_a_boolean
    end

    it "returns true if the lists are the same object" do
      @list.should eql @list
    end

    it "returns true if the lists are both empty" do
      list1, list2 = @class[], @class[]
      list1.should eql list2
    end

    it "returns true if the lists are equal" do
      list1, list2 = @class[@id1, @id2], @class[@id1, @id2]
      list1.should eql list2
    end

    it "returns false if the lists are not equal" do
      list1, list2 = @class[@id1, @id2], @class[@id2, @id1]
      list1.should_not eql list2
    end
  end

  describe "List#hash" do
    it "returns a Fixnum" do
      @list.hash.should be_a Fixnum
    end

    #it "returns the same hash code for equal lists" do
    #  @class[@id1].hash.should eql @class[@id1].hash
    #end
  end

  describe "List#insert" do
    it "raises a TypeError if the list is frozen" do
      lambda { @list.freeze.insert(@id0) }.should raise_error TypeError
    end

    it "inserts the given identifier as the first element of the list" do
      id = @id0.dup.fill(0xff)
      @list.should_not include id
      @list.insert(id)
      @list.should include id
      # TODO: verify that it was inserted as the first element.
    end

    it "returns self" do
      @list.insert(@id0).should equal @list
    end
  end

  describe "List#delete" do
    it "raises a TypeError if the list is frozen" do
      lambda { @list.freeze.delete(@id0) }.should raise_error TypeError
    end

    it "removes the first occurrence of the given identifier from the list" do
      @list.should include @id0
      @list.delete(@id0)
      @list.should_not include @id0
      # TODO: verify that only the first occurrence was removed.
    end

    it "returns self" do
      @list.delete(@id0).should equal @list
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
