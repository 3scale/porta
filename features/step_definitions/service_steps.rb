Given /^a service "([^"]*)" of (provider "[^"]*")$/ do |name, provider|
  provider.services.create! :name => name, :mandatory_app_key => false
end

Given /^(?:a )?default service of (provider "[^"]*") has name "([^"]*)"$/ do |provider, name|
  provider.first_service!.update_attribute(:name, name)
end

Given /^the service "([^"]*)" of (provider "[^\"]*") has deployment option "([^"]*)"$/ do |service_name, provider, deployment_option|
  provider.services.find_by!(name: service_name).update_attribute(:deployment_option, deployment_option)
end

Given /^the service of (provider "[^\"]*") has terms$/ do |account|
  account.first_service!.update_attributes!(:terms => 'Some terms and conditions...')
end

Given /^the service of (provider "[^\"]*") requires intentions of use$/ do |account|
  account.first_service!.update_attribute(:intentions_required, true)
end

Given /^the service of (provider "[^\"]*") does not require intentions of use$/ do |account|
  account.first_service!.update_attribute(:intentions_required, false)
end


Given /^(buyer "[^"]*") subscribed to (service plan "[^"]*")$/ do |buyer, plan|
  buyer.buy!(plan)
end

Given /^(buyer ".*?") is subscribed to the default service of (provider ".*?")$/ do |buyer, provider|
  buyer.bought_service_contracts.create! :plan => provider.first_service!.service_plans.first
end

Given /^(buyer ".*?") is subscribed with state "(.*?)" to the default service of (provider ".*?")$/ do |buyer, state, provider|
  buyer.bought_service_contracts.map &:destroy
  contract = buyer.bought_service_contracts.create! :plan => provider.first_service!.service_plans.first
  contract.update_column(:state, state)
end

Given /^(buyer ".*?") is not subscribed to the default service of (provider ".*?")$/ do |buyer, provider|
  buyer.bought_service_contracts.map &:destroy
end

Given /^the service of (provider "[^\"]*") has "([^\"]*)" enabled$/ do |account, toggle|
  account.first_service!.update_attribute("#{underscore_spaces(toggle)}_enabled", true)
end

Given /^the service of (provider "[^\"]*") has "([^\"]*)" disabled$/ do |account, toggle|
  account.first_service!.update_attribute("#{underscore_spaces(toggle)}_enabled", false)
end

Given /^the service of (provider "[^\"]*") has "([^\"]*)" set to "([^\"]*)"$/ do |account, name, value|
  account.first_service!.update_attribute(underscore_spaces(name), value)
end

Given /^the service of (provider "[^\"]*") has traffic$/ do |account|
  Service.any_instance.stubs(:has_traffic?).returns(true)
end

Given /^the service has been successfully tested$/ do
  @provider.default_service.proxy.update_column(:api_test_success, true)
end
