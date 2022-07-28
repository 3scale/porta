# frozen_string_literal: true

Then /^I should see the flash message "([^"]*)"$/ do |flash_text|
  assert_flash flash_text
end

def assert_flash(message)
  # Sometimes the flash hides before the a test asserts it and fails. Therefore, we target that the flash element
  # is rendered with the proper message, regardless of visibility.

  # For admin portal see app/views/shared/provider/_flash.html.erb
  if has_css?('#flashWrapper span', visible: :all)
    wrapper = find('#flashWrapper span', visible: :all)
  # lib/developer_portal/app/views/shared/_flash_message.html.erb
  elsif has_css?('#flashWrapper p', visible: :all)
    wrapper = find('#flashWrapper p', visible: :all)
  # For dev portal see app/assets/javascripts/flash-buyer.js
  elsif has_css?('#flash-messages')
    wrapper = find('#flash-messages .alert .container')
  else
    raise "No flash messages container has been found"
  end

  wrapper.assert_text(:all, message)
end
