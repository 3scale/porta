# frozen_string_literal: true

Given /^the asset host is set to "(.*)"$/ do |asset_host|
  cdn_url = "#{asset_host}:#{Capybara.current_session.server.port}"
  Rails.configuration.asset_host = cdn_url
  Rails.configuration.three_scale.asset_host = cdn_url
end

Then /^((javascript|font)\s)?assets should be loaded from the asset host$/ do |asset_type|
  cdn_url = Rails.configuration.asset_host
  js_regexp = Regexp.new("https?://#{cdn_url}/packs.*?\\.js")
  font_regexp = Regexp.new("https?://#{cdn_url}/packs.*?\\.eot")

  assert_not_nil Capybara.page.source.match js_regexp if ['javascript', nil].include? asset_type
  assert_not_nil Capybara.page.source.match font_regexp if ['font', nil].include? asset_type
end

Then /^assets shouldn't be loaded from the asset host$/ do
  # When no CDN is set, we expect to find relative paths for fonts and js
  js_regexp = Regexp.new('src="/packs.*?\.js"')
  font_regexp = Regexp.new('url\(/packs.*?\.eot\)')

  assert_not_nil Capybara.page.source.match js_regexp
  assert_not_nil Capybara.page.source.match font_regexp
end
