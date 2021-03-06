# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'array_model/version'

Gem::Specification.new do |spec|
  spec.name          = "array_model"
  spec.version       = ArrayModel::VERSION
  spec.authors       = ["Nathan Reed"]
  spec.email         = ["reednj@gmail.com"]

  spec.summary       = %q{an ActiveRecord/Sequel style class for static reference data}
  spec.homepage      = "https://github.com/reednj/array_model"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
