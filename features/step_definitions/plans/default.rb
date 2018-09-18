Then /^(plan "[^"]*") should be the default$/ do |plan|
  assert plan.master?
end

Given /^((?:account|service|application|)\s?plan "[^"]*") is( not)? default$/ do |plan,unmark|
  if unmark
    assert !default_plan?(plan)
  else
    make_plan_default(plan)
  end
end

Given /^a default application plan of provider "([^"]*)"$/ do |provider_name|
  step %(a default application plan "Default" of provider "#{provider_name}")
end

Given(/^the provider has a default application plan$/) do
  step "a default application plan of provider \"#{provider_or_master_name}\""
end

Given /^a default service plan of provider "([^"]*)"$/ do |provider_name|
  step %(a default service plan "Default" of provider "#{provider_name}")
end

Given /^(provider "[^"]*") has no default application plan$/ do |provider|
  provider.services.each do |service|
    service.update_attribute :default_application_plan, nil
  end
end

Given /^(provider "[^"]*") has default service and account plan$/ do |provider|
  service = provider.first_service!
  service.publish!
  provider.update_attribute( :default_account_plan, provider.account_plans.first)

  plans = service.service_plans
  plans.default!(plans.default_or_first || plans.first)
end


