require 'bitcache'
require 'bitcache/spec'

Spec::Runner.configure do |config|
  config.include(Bitcache::Spec::Matchers)
end

include Bitcache
