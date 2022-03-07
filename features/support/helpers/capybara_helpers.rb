# frozen_string_literal: true

module CapybaraHelpers
  def rack_test?
    %I[webkit selenium webkit_debug headless_chrome chrome headless_firefox firefox].exclude? Capybara.current_driver
  end
end
