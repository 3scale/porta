Dir[File.dirname(__FILE__) + '/../../test/test_helpers/**/*.rb'].each do |file|
  require file
end

World(TestHelpers::Time)
World(TestHelpers::Account)
World(TestHelpers::Country)
World(TestHelpers::Backend)
