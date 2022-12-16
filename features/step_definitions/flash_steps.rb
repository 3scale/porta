# frozen_string_literal: true

Then /^I should see the flash message "([^"]*)"$/ do |flash_text|
  assert_flash flash_text
end

def assert_flash(message)
  # TODO: revisit and refactor this, maybe divide into 2 methods
  # Sometimes the flash hides before the a test asserts it and fails. Therefore, we target that the flash element
  # is rendered with the proper message, regardless of visibility.

  # For admin portal see app/views/shared/provider/_flash.html.erb
  # For dev portal see lib/developer_portal/app/views/shared/_flash_message.html.erb
  # and app/assets/javascripts/flash-buyer.js

  # NOTE: when @javascript enabled, flash messages in developer portal are styled in UPPER CASE so target string has to be asserted like that.

  if has_css?('#flashWrapper', visible: :all)
    assert has_css?('#flashWrapper span', visible: :all, text: message, wait: 10) ||
           has_css?('#flashWrapper p', visible: :all, text: message, wait: 10), "No flash has been found"
  else
    assert has_css?('#flash-messages', text: message), "No flash has been found"
  end
end
