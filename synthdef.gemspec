# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synthdef/version'

Gem::Specification.new do |spec|
  spec.name          = "synthdef"
  spec.version       = Synthdef::VERSION
  spec.authors       = ["Xavier Riley"]
  spec.email         = ["xavriley@hotmail.com"]
  spec.summary       = %q{Work with SuperCollider's binary synthdef format}
  spec.description   = %q{Use the power of Ruby to convert, edit and save synthdefs for SuperCollider}
  spec.homepage      = "https://github.com/xavriley/synthdef"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bindata"
  spec.add_dependency "rgl"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activesupport"
  # spec.add_development_dependency "guard"
  # spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  # spec.add_development_dependency "pry-remote"
  # spec.add_development_dependency "pry-nav"
end
