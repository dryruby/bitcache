require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/list'

describe Bitcache::List do
  before :all do
    @class = Bitcache::List
  end

  it_should_behave_like Bitcache_List
end
