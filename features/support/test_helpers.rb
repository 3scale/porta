# frozen_string_literal: true

if defined?(Rails.root)
  Dir[Rails.root.join('test', 'test_helpers', '**', '*.rb')].each(&method(:require))

  World(TestHelpers::Time)
  World(TestHelpers::Country)
  World(TestHelpers::Backend)
end
