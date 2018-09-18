Then /^the "(.*?)" field should contain the support email of (provider ".*?")$/ do |field, provider|
  step %(the "#{field}" field should contain "#{provider.support_email}")
end

Then /^the "(.*?)" field should contain the finance support email of (provider ".*?")$/ do |field, provider|
  step %(the "#{field}" field should contain "#{provider.finance_support_email}")
end

Then /^the "(.*?)" field should contain the support email of service "(.*?)" of (provider ".*?")$/ do |field, service_name, provider|
  step %(the "#{field}" field should contain "#{provider.services.find_by_name(service_name).support_email}")
end

Then /^(provider ".*?") support email should be "(.*?)"$/ do |provider, email|
  assert_equal email, provider.support_email
end

Then /^(provider ".*?") finance support email should be "(.*?)"$/ do |provider, email|
  assert_equal email, provider.finance_support_email
end

Then /^support email for service "(.*?)" of (provider ".*?") should be "(.*?)"$/ do |service_name, provider, email|
  assert_equal email, provider.services.find_by_name(service_name).support_email
end
