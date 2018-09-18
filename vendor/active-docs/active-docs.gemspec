# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "active-docs"
  gem.version       = '1.0.0'
  gem.authors       = ["Michal Cichra"]
  gem.email         = ["michal@o2h.cz"]
  gem.description   = %q{ActiveDocs}
  gem.summary       = %q{ActiveDocs}
  gem.homepage      = ""

  gem.files         = Dir["{app,lib,vendor}/assets/**/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "railties", "> 3.1"
end
