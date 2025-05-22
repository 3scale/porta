# frozen_string_literal: true

Then "(I )(they )should see the flash message {string}" do |message|
  assert_flash(message)
end
