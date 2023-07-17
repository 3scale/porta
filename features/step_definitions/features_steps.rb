# frozen_string_literal: true

Given('a feature {string} of {provider}') do |feature_name, provider|
  @service_plan = provider.service_plans.where(name: "Basic").last
  feature = @service_plan.service.features.find_or_create_by(name: feature_name, scope: "ServicePlan")
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
  feature = @service_plan.service.features.find_by(name: string, scope: "ServicePlan")
  @service_plan.features.delete(feature)
end

And('I enable feature {string}') do |string|
  feature = @service_plan.service.features.find_by(name: string, scope: "ServicePlan")
  @service_plan.features << feature #feature enabled
  @service_plan.save!
end

Then('feature {string} should be enabled') do |string|
  feature = @service_plan.service.features.find_by(name: string)
  assert_equal feature.features_plans.count, 1
end

Then('feature {string} should be disabled') do |string|
  feature = @service_plan.service.features.find_by(name: string)
  assert_equal feature.features_plans.count, 0
end
