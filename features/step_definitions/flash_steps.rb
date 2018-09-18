Then /^I should see the flash message "([^"]*)"$/ do |flash_text|
  find(:xpath, "//div[@id='flash-messages']").text.should have_content(flash_text)
end
