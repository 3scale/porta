# frozen_string_literal: true

Given /^the asset host is unset$/ do
  Rails.configuration.three_scale.asset_host = nil
  Rails.configuration.asset_host = nil

  # Reconfigure CSP with original policy (without CDN URL)
  policy_config = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config
  Rails.application.config.content_security_policy do |policy|
    ThreeScale::ContentSecurityPolicy::AdminPortal.add_policy_config(policy, policy_config)
    Rails.application.instance_variable_get(:@app_env_config)&.[]=('action_dispatch.content_security_policy', policy)
  end
end

Given /^the asset host is set to "(.*)"$/ do |asset_host|
  cdn_url = "#{asset_host}:#{Capybara.current_session.server.port}"
  Rails.configuration.three_scale.asset_host = cdn_url
  Rails.configuration.asset_host = cdn_url

  # Get original policy and add CDN URL to CSP directives
  original_policy = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config
  policy_with_cdn = original_policy.deep_dup

  # Append CDN URL to script_src, style_src, and font_src
  policy_with_cdn[:script_src] = (policy_with_cdn[:script_src] || []) + [cdn_url]
  policy_with_cdn[:style_src] = (policy_with_cdn[:style_src] || []) + [cdn_url]
  policy_with_cdn[:font_src] = (policy_with_cdn[:font_src] || []) + [cdn_url]

  # Reconfigure CSP with CDN URL included
  # Rails set the CSP configuration just once during initialization,
  # This hack is needed to make it change between tests
  Rails.application.config.content_security_policy do |policy|
    ThreeScale::ContentSecurityPolicy::AdminPortal.add_policy_config(policy, policy_with_cdn)
    Rails.application.instance_variable_get(:@app_env_config)&.[]=('action_dispatch.content_security_policy', policy)
  end
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
