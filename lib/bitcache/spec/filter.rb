require 'bitcache/spec'

share_as :Bitcache_Filter do
  include Bitcache::Spec::Matchers

  before :each do
    raise '+@class+ must be defined in a before(:all) block' unless instance_variable_get(:@class)
    @filter = @class.new
  end
end
