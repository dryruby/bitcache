require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/stream'

describe Bitcache::Stream do
  before :all do
    @class = Bitcache::Stream
  end

  it_should_behave_like Bitcache_Stream

  # TODO: incorporate all the following into the shared spec.

  before :each do
    @streams = []
    @streams << Bitcache::Stream.new('da39a3ee5e6b4b0d3255bfef95601890afd80709', '')
  end

  it "should be a bitstream" do
    @streams.each do |stream|
      stream.should be_a_stream
    end
  end

  it "should be inspectable" do
    @streams.each do |stream|
      stream.should be_inspectable
    end
  end

  it "should have an identifier" do
    @streams.each do |stream|
      stream.should respond_to(:id)
      stream.id.should_not be_nil
      stream.id.should be_a_kind_of(String)
      stream.id.size.should == 40 # FIXME
    end
  end

  it "should have a size" do
    @streams.each do |stream|
      stream.should respond_to(:size)
      stream.size.should be_a_kind_of(Integer)
      stream.size.should == stream.data.size
    end
  end

  it "should have a string representation" do
    @streams.each do |stream|
      stream.should respond_to(:to_s)
      stream.to_s.should be_a_kind_of(String)
      stream.should respond_to(:to_str)
      stream.to_str.should be_a_kind_of(String)
    end
  end

  it "should have an Hash representation" do
    @streams.each do |stream|
      stream.should respond_to(:to_hash)
      stream.to_hash.should include(:id)
      stream.to_hash[:id].should == stream.id
      stream.to_hash.should include(:size)
      stream.to_hash[:size].should == stream.size
      stream.to_hash.should include(:data)
      stream.to_hash[:data].should == stream.data
    end
  end

  it "should have an RDF representation" do
    @streams.each do |stream|
      stream.should respond_to(:to_rdf)
      stream.to_rdf.should be_a_kind_of(RDF::Literal)
    end
  end
end
