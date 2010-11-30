require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/stream'

describe Bitcache::FFI::Stream do
  before :each do
    @class = Bitcache::FFI::Stream
  end

  it_should_behave_like Bitcache_Stream
end
