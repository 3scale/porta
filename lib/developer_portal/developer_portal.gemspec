# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "developer_portal"
  s.version     = '1.0.1'
  s.authors     = ["Jakub Hozak", "Jose Galisteo", "Aurelian Oancea"]
  s.email       = ["3scale-info@redhat.com"]
  s.homepage    = ""
  s.summary     = "3scale DeveloperPortal."
  s.description = "3scale DeveloperPortal."

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'liquid', '4.0.1'
  s.add_dependency "railties", ">= 3.2"
end
