# -*- encoding: utf-8 -*-
require File.expand_path('../lib/labs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Radim Marek"]
  gem.email         = ["radim@10xengineer.me"]
  gem.description   = %q{10xEngineer Labs client library and command line tools}
  gem.summary       = %q{Interact with Labs API to create and manage automated lab environments}
  gem.homepage      = "http://10xengineer.me/labs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "labs"
  gem.require_paths = ["lib"]
  gem.version       = Labs::VERSION
end
