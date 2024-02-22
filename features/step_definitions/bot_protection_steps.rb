# frozen_string_literal: true

RECAPTCHA_SCRIPT = 'script[src^="https://www.recaptcha.net/recaptcha/api.js"]'

Given "the client {will} be marked as a bot" do |bot|
  ApplicationController.any_instance.stubs(:verify_recaptcha).returns(!bot)
end

Then "the captcha {is} present" do |present|
  page.should have_selector(RECAPTCHA_SCRIPT, visible: false) if present
  page.should_not have_selector(RECAPTCHA_SCRIPT, visible: false) unless present
end
