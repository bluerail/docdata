# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docdata/version'

Gem::Specification.new do |spec|
  spec.name          = "docdata"
  spec.version       = Docdata::VERSION
  spec.authors       = ["Henk Meijer", "Eskes Media"]
  spec.email         = ["meijerhenk@gmail.com"]
  spec.description   = %q{A ruby binder for the DocData payment gateway.}
  spec.summary       = %q{This gem provides a ruby API for the DocData payment gateway.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
