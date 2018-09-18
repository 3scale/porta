# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "codeclimate_rails"
  spec.version       = '0.1.0'
  spec.authors       = ["Michal Cichra"]
  spec.email         = ["michal@3scale.net"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.license       = "MIT"


  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'codeclimate_batch'
  spec.add_dependency 'codeclimate-test-reporter'
end
