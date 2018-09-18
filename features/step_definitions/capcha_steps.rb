# frozen_string_literal: true

RECAPTCHA_SCRIPT = 'script[src^="https://www.google.com/recaptcha/api.js"]'

Then /^I should not see the captcha$/ do
  page.should_not have_selector(RECAPTCHA_SCRIPT)
end

Then /^I should see the captcha$/ do
  page.should have_selector(RECAPTCHA_SCRIPT)
end

When /^I leave the captcha empty$/ do
  captcha_evaluates_to false
end

When /^I fill in the captcha incorrectly$/ do
  captcha_evaluates_to false
end

When /^I fill in the captcha correctly$/ do
  captcha_evaluates_to true
end

Then /^I should see captcha check fail$/ do
  page.should have_content('Word verification response is incorrect, please try again.')
end

