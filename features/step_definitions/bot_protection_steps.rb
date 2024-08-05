# frozen_string_literal: true

RECAPTCHA_INPUT = 'input[name^="g-recaptcha-response-data"]'

Given "the client {will} be marked as a bot" do |bot|
  ApplicationController.any_instance.stubs(:verify_recaptcha).returns(!bot)
end

Then "the captcha {is} present" do |present|
  assert_equal present, has_selector?(RECAPTCHA_INPUT, visible: false)
end

Given "{provider} has bot protection {enabled}" do |provider, enabled|
  level = enabled ? :captcha : :none
  provider.settings.update_attribute(:admin_bot_protection_level, level)
end

Given "{provider} has bot protection {enabled} for its buyers" do |provider, enabled|
  level = enabled ? :captcha : :none
  provider.settings.update_attribute(:spam_protection_level, level)
end

