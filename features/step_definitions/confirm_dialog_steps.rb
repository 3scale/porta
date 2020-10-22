# frozen_string_literal: true

DRIVERS = %i[webkit selenium webkit_debug headless_chrome chrome headless_firefox firefox].freeze

Then /^(.+) and I confirm dialog box(?: "(.*)")?$/ do |original, text|
  if DRIVERS.include? Capybara.current_driver
    accept_confirm(text) do
      step original
    end
    wait_for_requests
  else # :rack_test but should not work if it relies on some JS
    step original
  end
end
