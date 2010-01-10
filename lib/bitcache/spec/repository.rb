require 'bitcache/spec'

share_as :Bitcache_Repository do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@repository+ must be defined in a before(:each) block' unless instance_variable_get('@repository')
  end

  it "should be accessible" do
    @repository.accessible?.should be_true
  end

  it "should be readable" do
    @repository.readable?.should be_true
  end

  it "should be writable" do
    @repository.writable?.should be_true
  end

  it "should be empty initially" do
    @repository.empty?.should be_true
    @repository.count.should be_zero
  end

  context "when storing bitstreams" do
    it "should support #store" do
      @repository.should respond_to(:store)

      @repository.store(nil, '').should == 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
      @repository.empty?.should be_false
      @repository.count.should == 1
    end
  end

  context "when fetching bitstreams" do
    it "should support #fetch" do
      @repository.should respond_to(:fetch)

      id = @repository.store(nil, data = 'Hello, world!')
      @repository.fetch(id).should be_instance_of(Bitcache::Stream)
      @repository.fetch(id).id.should == id
      @repository.fetch(id).data.should == data
    end
  end

  context "when enumerating bitstreams" do
    it "should support #each" do
      @repository.should respond_to(:each)

      @repository.store(nil, '')
      @repository.store(nil, '123')
      @repository.each do |stream|
        stream.should be_a_stream
      end
    end
  end

  context "when deleting bitstreams" do
    it "should support #delete" do
      @repository.should respond_to(:delete)

      id = @repository.store(nil, '')
      @repository.empty?.should be_false
      @repository.delete(id)
      @repository.empty?.should be_true
    end
  end

  context "when clearing all bitstreams" do
    it "should support #clear" do
      @repository.should respond_to(:clear)
    end
  end
end
