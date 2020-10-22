# frozen_string_literal: true

Then "the {string} field should contain the support email of {provider}" do |field, provider|
  step %(the "#{field}" field should contain "#{provider.support_email}")
end

Then "the {string} field should contain the finance support email of {provider}" do |field, provider|
  step %(the "#{field}" field should contain "#{provider.finance_support_email}")
end

Then "the {string} field should contain the support email of service {string} of {provider}" do |field, service_name, provider|
  step %(the "#{field}" field should contain "#{provider.services.find_by!(name: service_name).support_email}")
end

Then "{provider} support email should be {string}" do |provider, email|
  assert_equal email, provider.support_email
end

Then "{provider} finance support email should be {string}" do |provider, email|
  assert_equal email, provider.finance_support_email
end

Then "support email for service {string} of {provider} should be {string}" do |service_name, provider, email|
  assert_equal email, provider.services.find_by!(name: service_name).support_email
end
