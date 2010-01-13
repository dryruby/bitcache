require 'bitcache/spec'

share_as :Bitcache_Repository do
  include Bitcache::Spec::Matchers

  DATA = {
    'da39a3ee5e6b4b0d3255bfef95601890afd80709' => '',
    '5ba93c9db0cff93f52b521d7420e43f6eda2784f' => "\0",
    '943a702d06f34599aee1f8da8ef9f7296031d699' => 'Hello, world!',
  }
  DATA[Bitcache.identify(File.read(__FILE__))] = File.read(__FILE__)

  before :each do
    raise '+@repository+ must be defined in a before(:each) block' unless instance_variable_get('@repository')
  end

  it "should be a repository" do
    @repository.should be_a_repository
  end

  it "should be inspectable" do
    @repository.should be_inspectable
  end

  it "should be accessible" do
    @repository.should be_accessible
  end

  it "should be readable" do
    @repository.should be_readable
  end

  it "should be writable" do
    @repository.should be_writable
  end

  it "should be empty initially" do
    @repository.should be_empty
    @repository.count.should be_zero
  end

  context "when storing bitstreams" do
    it "should support #store" do
      @repository.should respond_to(:store)

      count = 0
      DATA.each do |id, data|
        @repository.count.should == count
        @repository.should_not have_id(id)

        @repository.store(nil, data).should == id

        @repository.should have_id(id)
        @repository.should_not be_empty
        @repository.count.should == (count += 1)
      end
      @repository.count.should == DATA.size
    end

    it "should support #[]=" do
      @repository.should respond_to(:[]=)

      lambda { @repository[nil] = '' }.should raise_error(ArgumentError)

      count = 0
      DATA.each do |id, data|
        @repository.count.should == count
        @repository.should_not have_id(id)

        (@repository[id] = data).should == data

        @repository.should have_id(id)
        @repository.should_not be_empty
        @repository.count.should == (count += 1)
      end
      @repository.count.should == DATA.size
    end

    it "should support #<<" do
      @repository.should respond_to(:<<)
 
      count = 0
      DATA.each do |id, data|
        @repository.count.should == count
        @repository.should_not have_id(id)

        (@repository << data).should == @repository

        @repository.should have_id(id)
        @repository.should_not be_empty
        @repository.count.should == (count += 1)
      end
      @repository.count.should == DATA.size
    end

    it "should discard duplicates" do
      count = 0
      DATA.each do |id, data|
        3.times { (@repository << data).should == @repository }
        @repository.count.should == (count += 1)
      end
      @repository.count.should == DATA.size
    end
  end

  context "when fetching bitstreams" do
    it "should support #fetch" do
      @repository.should respond_to(:fetch)

      DATA.each do |id, data|
        @repository.store(nil, data).should == id

        @repository.fetch(id).should be_a_stream(id, data)
      end
    end

    it "should support #[]" do
      @repository.should respond_to(:[])

      DATA.each do |id, data|
        @repository.store(nil, data).should == id

        @repository[id].should be_a_stream(id, data)
      end
    end
  end

  context "when enumerating bitstreams" do
    it "should support #each" do
      @repository.should respond_to(:each)

      DATA.each { |id, data| @repository << data }

      @repository.each { |stream| stream.should be_a_stream }
    end

    it "should include Enumerable" do
      @repository.class.included_modules.should include(Enumerable)
    end
  end

  context "when deleting bitstreams" do
    it "should support #delete" do
      @repository.should respond_to(:delete)

      DATA.each do |id, data|
        @repository.store(nil, data).should == id

        @repository.should_not be_empty
        @repository.count.should == 1

        @repository.delete(id)

        @repository.should be_empty
        @repository.count.should == 0
      end
    end

    it "should ignore non-existent identifiers"
  end

  context "when clearing all bitstreams" do
    it "should support #clear" do
      @repository.should respond_to(:clear)

      @repository.should be_empty
      lambda { @repository.clear }.should_not raise_error

      DATA.each { |id, data| @repository << data }

      @repository.should_not be_empty
      @repository.count.should == DATA.size
      lambda { @repository.clear }.should_not raise_error

      @repository.should be_empty
      @repository.count.should == 0
    end
  end
end
