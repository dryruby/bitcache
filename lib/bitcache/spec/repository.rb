require 'bitcache/spec'

share_as :Bitcache_Repository do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@repository+ must be defined in a before(:each) block' unless instance_variable_get('@repository')
  end

  it "should be available" do
    @repository.available?.should be_true
  end

  it "should be readable" do
    @repository.readable?.should be_true
  end

  it "should be empty initially" do
    @repository.empty?.should be_true
    @repository.count.should be_zero
  end

  context "when enumerating bitstreams" do
    it "should support #each" do
      @repository.should respond_to(:each)
    end
  end

  context "when fetching bitstreams" do
    it "should support #fetch" do
      @repository.should respond_to(:fetch)
    end
  end

  context "when storing bitstreams" do
    it "should support #store" do
      @repository.should respond_to(:store)
    end
  end

  context "when deleting bitstreams" do
    it "should support #delete" do
      @repository.should respond_to(:delete)
    end
  end

  context "when clearing all bitstreams" do
    it "should support #clear" do
      @repository.should respond_to(:clear)
    end
  end
end
