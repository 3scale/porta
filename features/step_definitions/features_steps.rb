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

When("I {string} the feature {string}") do |enable_disable, feature_name|
  feature = @service_plan.service.features.find_by(name: feature_name)

  within(:xpath, "//tr[@id='feature_#{feature.id}']") do
    case enable_disable
    when 'enable'
      find('i.excluded').click
    when 'disable'
      find('i.included').click
    end
  end
end

Then('I see feature {string} is {enabled_or_disabled}') do |string, enabled_or_disabled|
  wait_for_requests
  feature = @service_plan.service.features.find_by(name: string)
  within(:xpath, "//tr[@id='feature_#{feature.id}']") do
    case enabled_or_disabled
    when 'enabled'
      expect(page).to have_css('i.included[title="Feature is enabled for this plan"]')
      expect(find('i.included')).to be_visible
    when 'disabled'
      expect(page).to have_css('i.excluded[title="Metric is disabled for this plan"]')
      expect(find('i.excluded')).to be_visible
    end
  end
end
