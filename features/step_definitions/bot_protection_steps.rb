# frozen_string_literal: true

RECAPTCHA_INPUT = 'input[name^="g-recaptcha-response-data"]'

Given "the client {will} be marked as a bot" do |bot|
  ApplicationController.any_instance.stubs(:verify_recaptcha).returns(!bot)
end

Then "the captcha {is} present" do |present|
  page.should have_selector(RECAPTCHA_INPUT, visible: false) if present
  page.should_not have_selector(RECAPTCHA_INPUT, visible: false) unless present
end
