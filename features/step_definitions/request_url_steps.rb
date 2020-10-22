# frozen_string_literal: true

When "I request the settings page" do
  visit admin_site_settings_path
end

# TODO: remove
When "I request the url {string}" do |url|
  visit url
end
