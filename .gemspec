#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'bitcache'
  gem.homepage           = 'http://bitcache.org/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'A distributed content-addressable storage (CAS) system.'
  gem.description        = 'Bitcache is a distributed content-addressable storage (CAS) system.'
  gem.rubyforge_project  = 'bitcache'

  gem.author             = 'Arto Bendiken'
  gem.email              = 'bitcache@googlegroups.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = []
  gem.add_runtime_dependency     'ffi',   '>= 1.0'
  gem.add_development_dependency 'yard' , '>= 0.6.0'
  gem.add_development_dependency 'rspec', '>= 2.4.0'
  gem.post_install_message       = nil
end
