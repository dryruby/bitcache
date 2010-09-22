require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Bitcache::VERSION' do
  it "matches the VERSION file" do
    Bitcache::VERSION.to_s.should == File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
end
