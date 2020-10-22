# frozen_string_literal: true

Then "I should see the flash message {string}" do |flash_text|
  find(:xpath, "//div[@id='flash-messages'] | //div[@id='flashWrapper']").text.should have_content(flash_text)
end
