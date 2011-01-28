#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
begin
  require 'rakefile' # http://github.com/bendiken/rakefile
rescue LoadError => e
end
require 'bitcache'

desc "Build the bitcache-#{File.read('VERSION').chomp}.gem file"
task :build do
  sh "gem build .gemspec"
end

desc "Run all specs in spec directory"
task :spec do
  sh "bundle exec rspec spec"
end

desc "Open an IRB session with all libraries preloaded"
task :irb do
  sh "bundle exec irb -Ilib -rbitcache"
end
