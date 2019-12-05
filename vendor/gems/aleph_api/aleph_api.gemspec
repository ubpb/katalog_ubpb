# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aleph_api/version'

Gem::Specification.new do |spec|
  spec.name          = "aleph_api"
  spec.version       = AlephApi::VERSION
  spec.authors       = ["Michael Sievers"]
  spec.summary       = %q{A ruby wrapper for the aleph rest and xservices apis}
  spec.homepage      = "http://github.com/ubpb/aleph_api"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "faraday"

  spec.add_development_dependency "bundler",   ">= 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",     ">= 3.0.0",  "< 4.0.0"
  spec.add_development_dependency "simplecov", ">= 0.8.0"
end
