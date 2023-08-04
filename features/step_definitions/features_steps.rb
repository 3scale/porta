# frozen_string_literal: true

Given('a feature {string} of {provider}') do |feature_name, provider|
  @service_plan = provider.service_plans.where(name: "Basic").last
  feature = @service_plan.service.features.find_or_create_by(name: feature_name, scope: "ServicePlan")
end

Given('an enabled feature {string} of {provider}') do |feature_name, provider|
  @service_plan = provider.service_plans.where(name: "Basic").last
  feature = @service_plan.service.features.find_or_create_by(name: feature_name, scope: "ServicePlan")
  @service_plan.features << feature
  @service_plan.save!
end

Then('there {is} no feature named {string}') do |is, string|  
  feature_name = @service_plan.service.features.last.name
  assert_not_equal feature_name, string
end

Then('there {is} feature named {string}') do |is, string|
  feature_name = @service_plan.service.features.last.name
  assert_equal feature_name, string
end

And('I disable feature {string}') do |string|
  element = find('.fa-check-circle')
  element.click
end

And('I enable feature {string}') do |string|
  element = find('.fa-times-circle')
  element.click
end

Then('feature {string} should be enabled') do |string|
  feature = @service_plan.service.features.find_by(name: string)
  assert_equal 1, feature.features_plans.count
end

Then('feature {string} should be disabled') do |string|
  using_wait_time(10) do
    feature = @service_plan.service.features.find_by(name: string)
    assert_equal 0, feature.features_plans.count
  end
end
