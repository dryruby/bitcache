require 'bitcache'

describe Bitcache::Adapter do
  context "enumerating available adapters" do
    it "should be possible" do
      Bitcache::Adapter.should respond_to(:each)
      Bitcache::Adapter.should be_kind_of(Enumerable)
    end

    it "should not raise errors" do
      lambda { Bitcache::Adapter.each do |adapter| adapter end }.should_not raise_error
    end

    it "should yield subclasses" do
      Bitcache::Adapter.each do |adapter|
        adapter.superclass.should == Bitcache::Adapter
      end
    end
  end

  context "obtaining adapters by name" do
    it "should be possible" do
      Bitcache::Adapter.for(:"aws-s3").should == Bitcache::Adapter::AWS_S3
      Bitcache::Adapter.for(:file).should     == Bitcache::Adapter::File
      Bitcache::Adapter.for(:gdbm).should     == Bitcache::Adapter::GDBM
      Bitcache::Adapter.for(:http).should     == Bitcache::Adapter::HTTP
      Bitcache::Adapter.for(:memcache).should == Bitcache::Adapter::Memcache
      Bitcache::Adapter.for(:memory).should   == Bitcache::Adapter::Memory
      Bitcache::Adapter.for(:sdbm).should     == Bitcache::Adapter::SDBM
      Bitcache::Adapter.for(:sftp).should     == Bitcache::Adapter::SFTP
    end
  end

  context "instantiating with defaults" do
    it "should yield an in-memory adapter" do
      Bitcache::Adapter.new.should be_a(Bitcache::Adapter::Memory)
    end
  end
end

describe Bitcache::Adapter::AWS_S3 do
  before(:each) { @adapter = Bitcache::Adapter::AWS_S3.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::File do
  before(:each) { @adapter = Bitcache::Adapter::File.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::GDBM do
  before(:each) { @adapter = Bitcache::Adapter::GDBM.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::HTTP do
  before(:each) { @adapter = Bitcache::Adapter::HTTP.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::Memcache do
  before(:each) { @adapter = Bitcache::Adapter::Memcache.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::Memory do
  before(:each) { @adapter = Bitcache::Adapter::Memory.new }

  it "should be transient" do
    @adapter.should be_transient
  end
end

describe Bitcache::Adapter::SDBM do
  before(:each) { @adapter = Bitcache::Adapter::SDBM.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end

describe Bitcache::Adapter::SFTP do
  before(:each) { @adapter = Bitcache::Adapter::SFTP.new }

  it "should not be transient" do
    @adapter.should_not be_transient
  end
end
