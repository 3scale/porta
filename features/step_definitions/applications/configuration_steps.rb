# frozen_string_literal: true

Given "the {provider} does not allow its partners to manage applications" do |provider|
  provider.default_service.update!(buyers_manage_apps: false)
end

Given "the {provider} does not allow its partners to manage application keys" do |provider|
  provider.default_service.update!(buyers_manage_apps: true)
  provider.default_service.update!(buyers_manage_keys: false)
end
