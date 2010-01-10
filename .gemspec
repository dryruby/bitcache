#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'bitcache'
  gem.homepage           = 'http://bitcache.org/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'A distributed content-addressable storage (CAS) system.'
  gem.description        = 'Bitcache is a distributed content-addressable storage (CAS) system.'
  gem.rubyforge_project  = 'bitcache'

  gem.authors            = ['Arto Bendiken']
  gem.email              = 'arto.bendiken@gmail.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.2'
  gem.requirements               = []
  gem.add_development_dependency 'rspec',       '>= 1.2.9'
  gem.add_development_dependency 'yard' ,       '>= 0.5.2'
  gem.add_runtime_dependency     'addressable', '>= 2.1.1'
  gem.post_install_message       = nil
end
