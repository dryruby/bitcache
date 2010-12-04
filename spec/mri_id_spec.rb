require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/id'

describe Bitcache::Identifier do
  before :all do
    @class = Bitcache::Identifier
  end

  it_should_behave_like Bitcache_Identifier
end
