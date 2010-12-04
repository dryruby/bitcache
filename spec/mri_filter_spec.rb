require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/filter'

describe Bitcache::Filter do
  before :all do
    @class = Bitcache::Filter
  end

  it_should_behave_like Bitcache_Filter
end
