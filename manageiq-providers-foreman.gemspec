# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'manageiq/providers/foreman/version'

Gem::Specification.new do |spec|
  spec.name          = "manageiq-providers-foreman"
  spec.version       = ManageIQ::Providers::Foreman::VERSION
  spec.authors       = ["ManageIQ Authors"]

  spec.summary       = "ManageIQ plugin for the Foreman provider."
  spec.description   = "ManageIQ plugin for the Foreman provider."
  spec.homepage      = "https://github.com/ManageIQ/manageiq-providers-foreman"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "foreman_api_client", "~>1.0"

  spec.add_development_dependency "simplecov"
end
