require File.join(File.dirname(__FILE__), 'spec_helper')
require 'bitcache/spec/repository'

describe Bitcache::Repository do
  before :each do
    @repository = Bitcache::Repository.new
  end

  it_should_behave_like Bitcache_Repository
end
