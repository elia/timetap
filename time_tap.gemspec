# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'time_tap/version'

Gem::Specification.new do |s|
  s.name        = 'time_tap'
  s.version     = TimeTap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Elia Schito']
  s.email       = ['perlelia@gmail']
  s.homepage    = 'http://github.com/elia/timetap'
  s.summary     = %q{Unobtrusive time-tracking for TextMate.}
  s.description = %q{TimeTap helps you track the time you spend coding on each project while in TextMate.}

  s.rubyforge_project = 'time_tap'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.extra_rdoc_files = %w[LICENSE README.md]
  
  s.add_runtime_dependency 'sinatra',        '~> 1.0'
  s.add_runtime_dependency 'actionpack',     '~> 3.1.0'
  s.add_runtime_dependency 'activesupport',  '~> 3.1.0'
  s.add_runtime_dependency 'haml'
  s.add_runtime_dependency 'sass'
  s.add_runtime_dependency 'rb-appscript'

  s.add_development_dependency 'rspec',   '~> 2.0'
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'spectator', '~> 1.1.a'
end
