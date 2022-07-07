# frozen_string_literal: true

RECAPTCHA_SCRIPT = 'script[src="https://www.recaptcha.net/recaptcha/api.js"]'

Then "I {should} see the captcha" do |should|
  if should
    page.should have_selector(RECAPTCHA_SCRIPT, visible: :all)
  else
    page.should_not have_selector(RECAPTCHA_SCRIPT)
  end
end

Then /^I should see submit button (disabled|enabled)$/ do |value|
  if value == 'disabled'
    page.should have_css("input[type='submit'][disabled]")
  else
    page.should_not have_css("input[type='submit'][disabled]")
  end
end

And /^I fill in the captcha (in)?correctly$/ do |incorrect|
  DeveloperPortal::LoginController.any_instance.expects(:spam_check).returns(incorrect.blank?).once
end
