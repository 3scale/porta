Given /^the plan the (provider "[^\"]*") signed has custom_plans enabled$/ do |provider|
  #FIXME: we do not use the step in features_steps.rb:11 because it's broken
  # Given /^feature "([^\"]*)" is (enabled|disabled) for (plan "[^"]*")$/
  provider.bought_plan
    .features << Feature.new(:system_name => 'custom_plans', :visible => true)
end

Given /^the plan the (provider "[^\"]*") signed has custom_plans disabled$/ do |provider|
  f = provider.bought_plan.features.find_by_system_name('custom_plans')
  f.destroy if f
end

Given /^(plan "[^"]*") is customized$/ do |plan|
  plan.customize
end

#TODO: FIXME: rename to: application plan
Given /^a (published|hidden) plan "([^\"]*)" of provider "([^\"]*)"$/ do |state, plan_name, account_name|
  if plan = ApplicationPlan.find_by_name(plan_name)
    raise %(There is already one plan called "#{plan_name}". For simplicity in cucumber features, the plan name must be globally unique)
  end

  account = Account.find_by_org_name!(account_name)
  plan = FactoryBot.create(:application_plan, :name => plan_name, :issuer => account.default_service)
  plan.publish! if state == 'published'
end

# TODO: make a general, attribute setting step for plan?
Given /^(plan "[^\"]*") has trial period of (\d+) days$/ do |plan, days|
  plan.update_attribute(:trial_period_days, days)
end

# TODO: make a general, attribute setting step for plan?
Given /^(plan "[^\"]*") has monthly fee of (\d+)$/ do |plan, fee|
  plan.update_attribute(:cost_per_month, fee)
end

# TODO: make a general, attribute setting step for plan?
Given /^(plan "[^\"]*") has setup fee of (\d+)$/ do |plan, fee|
  plan.update_attribute(:setup_fee, fee)
end

Given /^(plan "[^\"]*") has "([^\"]*)" (enabled|disabled)$/ do |plan, feature_name, enabled|
  feature = plan.service.features.find_or_create_by(name: feature_name)
  assert_not_nil feature

  if enabled == 'enabled'
    plan.features << feature
  else
    plan.features.delete(feature)
  end

  plan.save!
end

Given /^(provider "[^"]*") has no published application plans$/ do |provider|
  provider.application_plans.each{|p| p.hide!}
end

Given /^(plan "[^\"]*") has applications$/ do |plan|
  FactoryBot.create(:cinstance, :application_id => SecureRandom.hex(8), :plan => plan)
end

When /^I change application plan to "([^"]*)"$/ do |name|
  plan = ApplicationPlan.find_by_name(name)
  current_account.bought_cinstance.change_plan!(plan)
end

Then /^(plan "[^\"]*") should be published$/ do |plan|
  assert plan.published?
end

Then /^(plan "[^\"]*") should be hidden$/ do |plan|
  assert plan.hidden?
end

Then /^I should see the monthly fee is "([^\"]*)"$/ do |fee|
  assert(all('tr').any? do |tr|
    tr.has_css?('th', :text => "Monthly fee") &&
    tr.has_css?('td', :text => fee)
  end)
end


Then /^there should be plan "([^"]*)" of (provider "[^"]*")$/ do |plan_name, provider|
  assert_not_nil provider.default_service.plans.find_by_name(plan_name)
end

Then /^there should be no plan "([^"]*)"$/ do |plan_name|
  assert_nil Plan.find_by_name(plan_name)
end

Then /^I should see the (plan "[^"]*") is (\w+)$/ do |plan, status|
  assert has_xpath?("//tr[@id='plan_#{plan.id}']//td", :text => status)
end

Then /^I should see there are no plans available$/ do
  assert has_content? "There are no plans yet for this service"
end

Then /^I should see the details of plan "([^"]*)"$/ do |plan_name|
  assert has_css? 'h3', :text => plan_name
end

Then /^I should see I have signed up (plan "[^"]*")$/ do |plan|
  assert has_xpath?("//td[@id='plan_#{plan.id}']", :text => 'Your Plan')
end

Then /^I should see the plan details widget$/ do
  assert has_xpath?("//h3", :text => /Plan/)
end

Then /^I should not see the change plan widget$/ do
  assert has_no_xpath?("//h3", :text => "Change Plan")
end

Then /^I should see the app plan is "([^"]*)"$/ do |plan|
  assert has_xpath?("//h3", :text => "Plan: #{plan}")
end

Then /^I should see the app plan is customized$/ do
  assert has_xpath?("//h3", :text => "Custom Application Plan")
end

Then /^I should be able to customize the plan$/ do
  should have_link("Convert to a Custom Plan")
end

Then /^the application plans select should not contain custom plans of (provider "[^\"]*")$/ do |provider|
  provider.application_plans.customized.each do |custom_plan|
    step %{the "Application plan" select should not contain "#{custom_plan.name}" option}
  end
end
