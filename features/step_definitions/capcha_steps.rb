# frozen_string_literal: true

RECAPTCHA_SCRIPT = 'script[src^="https://www.google.com/recaptcha/api.js"]'

Then /^I should not see the captcha$/ do
  page.should_not have_selector(RECAPTCHA_SCRIPT)
end

Then /^I should see the captcha$/ do
  page.should have_selector(RECAPTCHA_SCRIPT, visible: false)
end

Then /^I should see submit button (disabled|enabled)$/ do |value|
  if value == 'disabled'
    page.should have_css("input[type='submit'][disabled]")
  else
    page.should_not have_css("input[type='submit'][disabled]")
  end
end