require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/block'

describe Bitcache::Block do
  before :all do
    @class = Bitcache::Block
  end

  it_should_behave_like Bitcache_Block
end
