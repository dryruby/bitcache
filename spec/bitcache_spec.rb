require File.join(File.dirname(__FILE__), 'spec_helper')

describe Bitcache do
  it "should identify bitstreams" do
    lambda { Bitcache.identify }.should raise_error(ArgumentError)
    lambda { Bitcache.identify(nil) }.should raise_error(ArgumentError)
    lambda { Bitcache.identify('') }.should_not raise_error(ArgumentError)
    Bitcache.identify('').should == 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    Bitcache.identify('Hello, world!').should == '943a702d06f34599aee1f8da8ef9f7296031d699'
    Bitcache.identify('Bitcache').should == 'c5d5b5aa0d1bdf791e87da90293c00f986ad32cd'
  end
end
