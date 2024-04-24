# frozen_string_literal: true

Given 'a product' do
  @product = @provider.default_service
end

Given "a service {string} of {provider}" do |name, provider|
  @service = provider.services.create! name: name, mandatory_app_key: false
end

Given "a(nother) service/product {string}( with no backends)( with no plans)" do |name|
  @service = @product = @provider.services.create!(name: name, mandatory_app_key: false)
end

Given "a product {string} with no service plans" do |name|
  @service = @product = @provider.services.create!(name: name, mandatory_app_key: false)
  @service.service_plans.destroy_all
end

Given "{product} has no published application plans" do |product|
  product.reload.application_plans.published.each(&:hide!)
end

Given "{product} has no default application plan" do |product|
  product.reload.update!(default_application_plan: nil)
end

Given "(a )(the )default service/product of {provider} has name {string}" do |provider, name|
  @product = provider.default_service
  @product.update!(name: name)
end

Given "the service {string} of {provider} has deployment option {string}" do |service_name, provider, deployment_option|
  provider.services.find_by!(name: service_name).update_attribute(:deployment_option, deployment_option)
end

Given "the subscription is {word}" do |state|
  @subscription.update_column(:state, state) # rubocop:disable Rails/SkipsModelValidations
end

Given "{product} has {} {enabled}" do |product, toggle, enabled|
  product.update_attribute("#{underscore_spaces(toggle)}_enabled", enabled) # rubocop:disable Rails/SkipsModelValidations
end

Given "{product} has {} set to {string}" do |product, name, value|
  product.update_attribute(underscore_spaces(name), value) # rubocop:disable Rails/SkipsModelValidations
end

Given "the service of {provider} has {string} {enabled}" do |account, toggle, enabled|
  ActiveSupport::Deprecation.warn '[cucumber] stop using "the service of provider" use "product" instead'
  account.first_service!.update_attribute("#{underscore_spaces(toggle)}_enabled", enabled)
end

Given "the service of {provider} has {string} set to {string}" do |account, name, value|
  ActiveSupport::Deprecation.warn '[cucumber] stop using "the service of provider" use "product" instead'
  account.first_service!.update_attribute(underscore_spaces(name), value)
end

Given "the service of {provider} has traffic" do |account|
  # TODO: stop using "the service of provider" use "product" instead
  Service.any_instance.stubs(:has_traffic?).returns(true)
end

Given "{product} uses the following backends:" do |product, table|
  transform_table(table).hashes.each do |hash|
    name, path, endpoint = hash.values_at(:name, :path, :private_endpoint)
    backend = @provider.backend_apis.create!(name: name, private_endpoint: endpoint || 'https://foo')
    product.backend_api_configs.create!(backend_api: backend, path: path)
  end
end

Given "{product} uses backend {backend_version}" do |product, backend_version|
  product.update!(backend_version: backend_version)
end

Given "{product} {does} require referrer filters" do |product, required|
  product.update!(referrer_filters_required: required)
end

Given /^the product( doesn't)? allows? to choose plan on app creation$/ do |not_allowed|
  @product.set_change_plan_on_app_creation_permitted!(!not_allowed)
end

Given "{product} does not allow buyers to manage application keys" do |product|
  product.update!(buyers_manage_apps: true)
  product.update!(buyers_manage_keys: false)
end

Given "{product} has the following integration errors:" do |product, table|
  transform_table(table)
  errors = table.hashes.map { |error| ThreeScale::Core::ServiceError.new(error) }

  ThreeScale::Core::ServiceError.stubs(:load_all)
                                .with(product.id, any_parameters)
                                .returns(ThreeScale::Core::APIClient::Collection.new(errors, errors.size))

  ThreeScale::Core::ServiceError.stubs(:delete_all)
                                .with(product.id)
                                .at_most_once

end

Then /^I should see the following backends being used:$/ do |table|
  within backends_used_table do
    table.raw.each do |row|
      should have_css('[data-label="Name"]', text: row[0])
    end
  end
end

Then "new service subscriptions with {plan} will be pending for approval" do |plan|
  assert ServiceContract.create(plan: plan).pending?
end

When "an admin is reviewing services index page" do
  visit admin_services_path
end

def backends_used_table
  find('#backends-used-list-container')
end
