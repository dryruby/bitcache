require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/queue'

describe Bitcache::FFI::Queue do
  before :all do
    @class = Bitcache::FFI::Queue
  end

  it_should_behave_like Bitcache_Queue
end
