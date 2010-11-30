require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/set'

describe Bitcache::FFI::Set do
  before :each do
    @class = Bitcache::FFI::Set
  end

  it_should_behave_like Bitcache_Set
end
