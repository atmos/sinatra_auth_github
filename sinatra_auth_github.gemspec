# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "sinatra_auth_github"
  s.version     = "0.1.5"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Corey Donohoe"]
  s.email       = ["atmos@atmos.org"]
  s.homepage    = "http://github.com/atmos/sinatra_auth_github"
  s.summary     = "A sinatra extension for easy oauth integration with github"
  s.description = s.summary

  s.rubyforge_project = "sinatra_auth_github"

  s.add_dependency "sinatra",       "~>1.0"
  s.add_dependency "rest-client",   "~>1.6.1"
  s.add_dependency "warden-github", "~>0.1.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec",     "~>1.3.0"
  s.add_development_dependency "shotgun"
  s.add_development_dependency "ZenTest",   "~>4.5.0"
  s.add_development_dependency "bundler",   "~>1.0"
  s.add_development_dependency "randexp",   "~>0.1.5"
  s.add_development_dependency "rack-test", "~>0.5.3"
  s.add_development_dependency "ruby-debug"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
