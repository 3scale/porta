# frozen_string_literal: true

Given /^the asset host is unset$/ do
  Rails.configuration.three_scale.asset_host = nil
end

Given /^the asset host is set to "(.*)"$/ do |asset_host|
  cdn_url = "#{asset_host}:#{Capybara.current_session.server.port}"
  Rails.configuration.three_scale.asset_host = cdn_url
end

Then /^((javascript|font)\s)?assets should be loaded from the asset host$/ do |asset_type|
  cdn_url = Rails.configuration.three_scale.asset_host.presence
  is_full_url = cdn_url.match? %r{^https?://}
  js_regexp = %r{#{is_full_url ? '' : 'https?://'}#{cdn_url}/packs.*?\.js}
  font_regexp =  %r{#{is_full_url ? '' : 'https?://'}#{cdn_url}/packs.*?\.eot}

  assert cdn_url.present?
  assert_not_nil Capybara.page.source.match js_regexp if ['javascript', nil].include? asset_type
  assert_not_nil Capybara.page.source.match font_regexp if ['font', nil].include? asset_type
end

Then /^((javascript|font)\s)?assets shouldn't be loaded from the asset host$/ do |asset_type|
  # When no CDN is set, we expect to find relative paths for fonts and js
  js_regexp =  %r{src="/packs.*?\.js"}
  font_regexp =  %r{url\(/packs.*?\.eot\)}

  assert_not_nil Capybara.page.source.match js_regexp if ['javascript', nil].include? asset_type
  assert_not_nil Capybara.page.source.match font_regexp if ['font', nil].include? asset_type
end

Then /^provided assets should be loaded from the asset host$/ do
  cdn_url = Rails.configuration.three_scale.asset_host.presence
  is_full_url = cdn_url.match? %r{^https?://}
  js_regexp =  %r{#{is_full_url ? '' : 'https?://'}#{cdn_url}/dev-portal-assets/.*?\.js}

  assert cdn_url.present?
  assert_not_nil Capybara.page.source.match js_regexp
end

Then /^provided assets shouldn't be loaded from the asset host$/ do
  # When no CDN is set, we expect to find relative paths to reusable assets
  js_regexp =  %r{src="/dev-portal-assets/.*?\.js"}

  assert_not_nil Capybara.page.source.match js_regexp
end
