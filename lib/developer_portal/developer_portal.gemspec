# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "developer_portal"
  s.version     = '1.0.0'
  s.authors     = ["Jakub Hozak", "Jose Galisteo", "Aurelian Oancea"]
  s.email       = ["3scale-info@redhat.com"]
  s.homepage    = ""
  s.summary     = "3scale DeveloperPortal."
  s.description = "3scale DeveloperPortal."

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "railties", ">= 3.2"
  s.add_dependency 'liquid', '~>3.0.5'


  # s.add_dependency "jquery-rails"

end
