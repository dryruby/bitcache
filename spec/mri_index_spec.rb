require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/index'

describe Bitcache::Index do
  before :all do
    @class = Bitcache::Index
  end

  it_should_behave_like Bitcache_Index
end
