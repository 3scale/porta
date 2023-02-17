# frozen_string_literal: true

Given 'a product' do
  @product = @provider.default_service
end

Given "a service {string} of {provider}" do |name, provider|
  provider.services.create! :name => name, :mandatory_app_key => false
end

Given /^a service "([^"]*)"$/ do |name|
  @provider.services.create!(name: name, mandatory_app_key: false)
end

Given "(a )default service of {provider} has name {string}" do |provider, name|
  provider.first_service!.update_attribute(:name, name)
end

Given "the service {string} of {provider} has deployment option {string}" do |service_name, provider, deployment_option|
  provider.services.find_by!(name: service_name).update_attribute(:deployment_option, deployment_option)
end

Given "{buyer} subscribed to {plan}" do |buyer, plan|
  buyer.buy!(plan)
end

Given "{buyer} is subscribed to the default service of {provider}" do |buyer, provider|
  buyer.bought_service_contracts.create! :plan => provider.first_service!.service_plans.first
end

Given "{buyer} is subscribed with state {string} to the default service of {provider}" do |buyer, state, provider|
  buyer.bought_service_contracts.map &:destroy
  contract = buyer.bought_service_contracts.create! :plan => provider.first_service!.service_plans.first
  contract.update_column(:state, state)
end

Given "{buyer} is not subscribed to the default service of {provider}" do |buyer, provider|
  buyer.bought_service_contracts.map &:destroy
end

Given "the service of {provider} has {string} {enabled}" do |account, toggle, enabled|
  account.first_service!.update_attribute("#{underscore_spaces(toggle)}_enabled", enabled)
end

Given "the service of {provider} has {string} set to {string}" do |account, name, value|
  account.first_service!.update_attribute(underscore_spaces(name), value)
end

Given "the service of {provider} has traffic" do |account|
  Service.any_instance.stubs(:has_traffic?).returns(true)
end

Given /^it uses the following backends:$/ do |table|
  transform_table(table).hashes.each do |hash|
    name, path = hash.values_at(:name, :path)
    backend = @provider.backend_apis.create!(name: name, private_endpoint: 'https://foo')
    @service.backend_api_configs.create!(backend_api: backend, path: path)
  end
end

Then /^I should see the following backends being used:$/ do |table|
  within backends_used_table do
    table.raw.each do |row|
      should have_css('[data-label="Name"]', text: row[0])
    end
  end
end

def backends_used_table
  find('#backends-used-list-container')
end
