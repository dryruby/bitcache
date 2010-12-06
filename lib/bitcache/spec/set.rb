require 'bitcache/spec'

share_as :Bitcache_Set do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @id0 = Identifier.new("\x00" * 16)
    @id1 = Identifier.new("\x01" * 16)
    @id2 = Identifier.new("\x02" * 16)
    @set = @class.new([@id0, @id1, @id2])
  end

  describe "Set#clone" do
    it "returns a Set" do
      @set.clone.should be_a Set
    end

    it "returns an identical copy of the set" do
      # TODO
    end
  end

  describe "Set#dup" do
    it "returns a Set" do
      @set.dup.should be_a Set
    end

    it "returns an identical copy of the set" do
      # TODO
    end
  end
end
