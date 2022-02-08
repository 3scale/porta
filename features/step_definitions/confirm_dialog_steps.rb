# frozen_string_literal: true

Then /^(.+) and I confirm dialog box(?: "(.*)")?$/ do |original, text|
  if rack_test?
    step original
  else
    accept_confirm(text) do
      step original
    end
    wait_for_requests
  end
end

Then /^(.+) and I confirm dialog box twice$/ do |original|
  if rack_test?
    step original
  else
    accept_confirm do
      accept_confirm do
        step original
      end
    end
    wait_for_requests
  end
end

# should not work if it relies on some JS
def rack_test?
  %I[webkit selenium webkit_debug headless_chrome chrome headless_firefox firefox].exclude? Capybara.current_driver
end
