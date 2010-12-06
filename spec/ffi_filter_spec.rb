require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/filter'

describe Bitcache::FFI::Filter do
  before :all do
    @class = Bitcache::Filter
    @class.send(:include, Bitcache::FFI::Filter)
  end

  it_should_behave_like Bitcache_Filter
end
