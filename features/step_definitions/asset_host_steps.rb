# frozen_string_literal: true

Given /^the asset host is unset$/ do
  Rails.configuration.three_scale.asset_host = nil
end

Given /^the asset host is set to "(.*)"$/ do |asset_host|
  cdn_url = "#{asset_host}:#{Capybara.current_session.server.port}"
  Rails.configuration.three_scale.asset_host = cdn_url
end

Then /^(?:javascript\s)?assets should be loaded from the asset host$/ do
  cdn_url = Rails.configuration.three_scale.asset_host.presence
  is_full_url = cdn_url.match? %r{^https?://}
  js_regexp = %r{#{is_full_url ? '' : 'https?://'}#{cdn_url}/packs.*?\.js}

  assert cdn_url.present?
  assert_not_nil Capybara.page.source.match js_regexp
end

Then /^(?:javascript\s)?assets shouldn't be loaded from the asset host$/ do
  # When no CDN is set, we expect to find relative paths for js
  js_regexp =  %r{src="/packs.*?\.js"}

  assert_not_nil Capybara.page.source.match js_regexp
end

Then /^cdn assets should be loaded from the asset host$/ do
  cdn_url = Rails.configuration.three_scale.asset_host.presence
  is_full_url = cdn_url.match? %r{^https?://}
  js_regexp =  %r{#{is_full_url ? '' : 'https?://'}#{cdn_url}/dev-portal-assets/.*?\.js}

  assert cdn_url.present?
  assert_not_nil Capybara.page.source.match js_regexp
end

Then /^cdn assets shouldn't be loaded from the asset host$/ do
  # When no CDN is set, we expect to find relative paths to reusable assets
  js_regexp =  %r{src="/dev-portal-assets/.*?\.js"}

  assert_not_nil Capybara.page.source.match js_regexp
end
