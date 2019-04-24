# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "skala/version"

Gem::Specification.new do |spec|
  spec.name          = "skala"
  spec.version       = Skala::VERSION
  spec.authors       = ["Michael Sievers", "René Sprotte"]
  spec.summary       = %q{Ruby on Rails based full-stack framework to build discovery solutions for libraries.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ubpb/skala"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bcrypt",      ">= 3.1"
  spec.add_dependency "bibtex-ruby", "~> 4.0"
  spec.add_dependency "rails",       ">= 4.2", "< 5.2"
  spec.add_dependency "hashie",      "~> 3.4"
  spec.add_dependency "servizio",    "~> 0.4"
  spec.add_dependency "mighty_tap",  "~> 0.5"
  spec.add_dependency "virtus",      "~> 1.0"
  spec.add_dependency "ox",          "~> 2.2"

  # aleph adapter
  spec.add_dependency "aleph_api", ">= 0.3.0"
  spec.add_dependency "weak_xml",  "~> 0.3"

  # elasticsearch adapter
  spec.add_dependency "elasticsearch", "~> 6.0"

  # all adapters
  spec.add_dependency "transformator", "~> 1.0"
end
