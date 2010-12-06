require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/list'

describe Bitcache::FFI::List do
  before :all do
    @class = Bitcache::List
    @class.send(:include, Bitcache::FFI::List)
  end

  it_should_behave_like Bitcache_List
end
