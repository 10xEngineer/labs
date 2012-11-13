# -*- encoding: utf-8 -*-
require File.expand_path('../lib/labs/version', __FILE__)
require File.expand_path('../spec_helper', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Radim Marek"]
  gem.email         = ["radim@10xengineer.me"]
  gem.description   = %q{10xEngineer Labs client library and command line tools}
  gem.summary       = %q{Interact with Labs API to create and manage automated lab environments}
  gem.homepage      = "http://10xengineer.me/labs"

  gem.files         = Labs::SpecHelper.unix_files
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "labs"
  gem.require_paths = ["lib"]
  gem.version       = Labs::VERSION

  gem.add_dependency "commander", "~> 4.1.2"
  gem.add_dependency "httparty", "~> 0.9.0"
  gem.add_dependency "yajl-ruby", "~> 1.1.0"
  gem.add_dependency "terminal-table", "~> 1.4.5"
  gem.add_dependency "net-ssh", "~> 2.6.1"
  gem.add_dependency "sshkey", "~> 1.3.1"

  gem.add_development_dependency "rspec", "~> 2"
end
