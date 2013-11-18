# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/schema_generator/version'

Gem::Specification.new do |spec|
  spec.name          = "json-schema-generator"
  spec.version       = JSON::SchemaGenerator::VERSION
  spec.authors       = ["Max Lincoln"]
  spec.email         = ["max@devopsy.com"]
  spec.description   = %q{A very basic json-schema generator}
  spec.summary       = %q{A very basic json-schema generator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "jsonpath"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "json-schema"
  spec.add_development_dependency "travis"
end
