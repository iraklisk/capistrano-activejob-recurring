# -*- encoding: utf-8 -*-
require File.expand_path("../lib/capistrano-activejob-recurring/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "capistrano-activejob-recurring"
  gem.version     = CapistranoActiveJobRecurring::VERSION.dup
  gem.author      = "Iraklis Karagkiozoglou"
  gem.email       = "iraklisk@outlook.com"
  gem.homepage    = "https://github.com/iraklisk/capistrano-activejob-recurring"
  gem.summary     = %q{ActiveJob recurring integration for Capistrano}
  gem.description = %q{Capistrano plugin that integrates ActiveJOb recurring server tasks.}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "capistrano"
  gem.add_runtime_dependency "activejob-recurring"
end
