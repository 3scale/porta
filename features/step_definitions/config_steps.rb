# frozen_string_literal: true

Given "{provider} has signup {enabled}" do |provider, enabled|
  if enabled
    provider.enable_signup!
  else
    provider.disable_signup!
  end
end

# TODO: remove this nonsense
Given /^provider "([^"]*)" has Browser CMS (activated|deactivated)$/ do |provider, value|
  if value == 'deactivated'
    raise 'BCMS cannot be deactivated!'
  end
end

# TODO: too generic. Replace it with "{product} uses backend {backend_version}"
Given "{provider} uses backend {backend_version} in his default service" do |provider, backend_version|
  service = provider.default_service
  service.backend_version = backend_version
  service.save!
end

Given "{provider} uses {authentication_strategy} authentication" do |provider, strategy|
  settings = provider.settings
  settings.authentication_strategy = strategy.downcase
  settings.cas_server_url = "http://mamacit.as" if strategy.casecmp("cas").zero?

  settings.save!
end
