# frozen_string_literal: true

Given "DNS domains {are} readonly" do |readonly|
  Rails.application.config.three_scale.expects(:readonly_custom_domains_settings).returns(readonly)
end

Then "the {string} field should contain the support email of {provider}" do |field, provider|
  has_field?(field, with: provider.support_email)
end

Then "the {string} field should contain the finance support email of {provider}" do |field, provider|
  has_field?(field, with: provider.finance_support_email)
end

Then "the {string} field should contain the support email of service {string} of {provider}" do |field, service_name, provider|
  has_field?(field, with: provider.services.find_by(name: service_name).support_email)
end

Then "{provider} support email should be {string}" do |provider, email|
  assert_equal email, provider.support_email
end

Then "{provider} finance support email should be {string}" do |provider, email|
  assert_equal email, provider.finance_support_email
end

Then "the support email for service {string} of {provider} should be {string}" do |service_name, provider, email|
  assert_equal email, provider.services.find_by(name: service_name).support_email
end
