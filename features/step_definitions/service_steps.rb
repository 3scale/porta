# frozen_string_literal: true

Given "a service {string} of {provider}" do |name, provider|
  provider.services.create!(name: name, mandatory_app_key: false)
end

Given "a backend api {string}" do |name|
  @provider.backend_apis.create!(name: name, private_endpoint: 'https://foo')
end

Given "a service {string}" do |name|
  @provider.services.create!(name: name, mandatory_app_key: false)
end

Given "(a )default service of {provider} has name {string}" do |provider, name|
  provider.first_service!.update!(name: name)
end

Given "the service {string} of {provider} has deployment option {string}" do |service_name, provider, deployment_option|
  provider.services.find_by!(name: service_name)
                   .update!(deployment_option: deployment_option)
end

Given "the service of {provider} has terms" do |provider|
  provider.first_service!.update!(terms: 'Some terms and conditions...')
end

Given "the service of {provider} requires intentions of use" do |provider|
  provider.first_service!.update!(intentions_required: true)
end

Given "the service of {provider} does not require intentions of use" do |provider|
  provider.first_service!.update!(intentions_required: false)
end

Given "{buyer} subscribed to {plan_with_type}" do |buyer, plan|
  buyer.buy!(plan)
end

Given "{buyer} is subscribed to the default service of {provider}" do |buyer, provider|
  buyer.bought_service_contracts.create! plan: provider.first_service!.service_plans.first
end

Given "{buyer} is subscribed with state {state} to the default service of {provider}" do |buyer, state, provider|
  buyer.bought_service_contracts.map(&:destroy)
  contract = buyer.bought_service_contracts.create! plan: provider.first_service!.service_plans.first
  contract.update!(state: state)
end

Given "{buyer} is not subscribed to the default service of {provider}" do |buyer, provider|
  buyer.bought_service_contracts.map(&:destroy)
end

Given "the service of {provider} has {string} {enabled}" do |account, toggle, enabled|
  account.first_service!.update!("#{underscore_spaces(toggle)}_enabled": enabled)
end

Given "the service of {provider} has {string} set to {string}" do |account, name, value|
  account.first_service!.update!(underscore_spaces(name), value)
end

Given "the service of {provider} has traffic" do |account|
  Service.any_instance.stubs(:has_traffic?).returns(true)
end

Given "the service has been successfully tested" do
  @provider.default_service.proxy.update!(api_test_success: true)
end

Given "the service {string} does not have service plan" do |name|
  Service.find_by(name: name).service_plans.destroy_all
end
